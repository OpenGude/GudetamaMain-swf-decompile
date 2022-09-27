package gudetama.net
{
   import flash.events.Event;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestDefaults;
   import flash.net.URLVariables;
   import flash.net.navigateToURL;
   import flash.utils.ByteArray;
   import flash.utils.getTimer;
   import gudetama.common.NativeExtensions;
   import gudetama.data.DataStorage;
   import gudetama.data.GameSetting;
   import gudetama.data.LocalData;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.CompatibleDataIO;
   import gudetama.data.compati.FriendlyData;
   import gudetama.data.compati.Packet;
   import gudetama.data.compati.UserData;
   import gudetama.engine.ApplicationSettings;
   import gudetama.engine.Engine;
   import gudetama.engine.Logger;
   import gudetama.scene.home.HomeScene;
   import gudetama.scene.opening.OpeningScene;
   import gudetama.scene.title.TitleScene;
   import gudetama.ui.MessageDialog;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.ui.WebViewDialog;
   import gudetama.util.TimeZoneUtil;
   import muku.util.ObjectUtil;
   import starling.core.Starling;
   
   public class HttpConnector
   {
      
      public static const URL_PATH_SERVLET:String = "/gde/";
      
      public static const SERVLET_ENTRANCE:String = "entrance";
      
      public static const SERVLET_MAIN:String = "main";
      
      public static const SERVLET_REPORT:String = "report";
      
      public static const SERVLET_UIID:String = "uiid";
      
      public static const SERVLET_TAKEOVER:String = "takeover";
      
      public static const SERVLET_DIRECT:String = "direct";
      
      public static const URL_PATH_STATIC:String = "/gde/static/";
      
      public static const RETRY_TIME:uint = 7000;
      
      public static const CONFIRM_RETRY_TIME:uint = 18000;
      
      private static var mainConnector:HttpConnector;
      
      public static var lastResponseCode:int;
       
      
      private var servletHost:String;
      
      private var encryptor:AESEncryptor;
      
      private var sessionId:String;
      
      private var responseCallback:Function;
      
      private var loader:URLLoader;
      
      private var retryLoader:URLLoader;
      
      private var sequenceNumber:uint = 180;
      
      private var responseSequences:ByteArray;
      
      private var extraResponseCallback:Function;
      
      private var beforeExecuteExtraResponse:Boolean;
      
      private var loginRetryCount:int = 0;
      
      private var loginHostHistory:Vector.<String>;
      
      private var afterReloginPacket:Packet;
      
      private var afterReloginCallback:Function;
      
      private var afterReloginState:int;
      
      private const RELOGIN_STATE_NONE:int = 0;
      
      private const RELOGIN_STATE_SEND_PING:int = 1;
      
      private const RELOGIN_STATE_SEND_PING_SUCCESS:int = 2;
      
      private const RELOGIN_STATE_SEND_OTHER:int = 11;
      
      public function HttpConnector()
      {
         responseSequences = new ByteArray();
         loginHostHistory = new Vector.<String>();
         super();
         servletHost = ApplicationSettings.getDefaultServletHost();
         URLRequestDefaults.idleTimeout = 20000;
         URLRequestDefaults.useCache = false;
         encryptor = new AESEncryptor();
      }
      
      public static function get main() : HttpConnector
      {
         if(mainConnector == null)
         {
            mainConnector = new HttpConnector();
         }
         return mainConnector;
      }
      
      private static function needsHttps(param1:String) : Boolean
      {
         if(param1 == "entrance" || param1 == "takeover" || param1 == "direct" || param1 == "uiid")
         {
            return true;
         }
         return false;
      }
      
      public static function sendTraceLog(param1:String) : void
      {
         var log:String = param1;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         var request:URLRequest = gudetama.net.HttpConnector.mainConnector.createURLRequest("report");
         var variables:URLVariables = new URLVariables();
         variables["ui"] = UserDataWrapper.wrapper.getUid();
         variables["u"] = DataStorage.getUiid();
         variables["log"] = log;
         request.data#2 = variables;
         var requestor:URLLoader = new URLLoader();
         var stackTrace:String = "";
         stackTrace = new Error().getStackTrace();
         requestor.addEventListener("ioError",function(param1:Event):void
         {
            trace("sendTraceLog failed. IO_ERROR {} {}",param1,stackTrace);
         });
         requestor.load(request);
      }
      
      public function setServletHost(param1:String) : void
      {
         servletHost = param1;
      }
      
      public function getWebSocketUrl(param1:String) : String
      {
         var _loc2_:String = "";
         if(servletHost.indexOf(":") < 0)
         {
            _loc2_ = ":8080";
         }
         return "ws://" + servletHost + _loc2_ + "/gde/" + param1;
      }
      
      public function getServletResourceUrl(param1:String) : String
      {
         var _loc2_:String = "";
         if(servletHost.indexOf(":") < 0)
         {
            _loc2_ = ":8080";
         }
         return "http://" + servletHost + _loc2_ + "/gde/static/" + param1;
      }
      
      private function getServletUrl(param1:String) : String
      {
         var _loc2_:String = "";
         var _loc3_:String = "";
         if(servletHost.indexOf("://") < 0)
         {
            if(needsHttps(param1) && !null)
            {
               _loc2_ = "https://";
               if(servletHost.indexOf(":") < 0)
               {
                  _loc3_ = ":8443";
               }
            }
            else
            {
               _loc2_ = "http://";
               if(servletHost.indexOf(":") < 0)
               {
                  _loc3_ = ":8080";
               }
            }
         }
         return _loc2_ + servletHost + _loc3_ + "/gde/" + param1;
      }
      
      private function createURLRequest(param1:String) : URLRequest
      {
         var _loc2_:URLRequest = new URLRequest();
         _loc2_.method#2 = "POST";
         _loc2_.url#2 = getServletUrl(param1);
         Logger.debug("request.url " + _loc2_.url#2);
         return _loc2_;
      }
      
      public function setExtraResponseCallback(param1:Function) : void
      {
         extraResponseCallback = param1;
      }
      
      public function isLoggedIn() : Boolean
      {
         return sessionId != null;
      }
      
      public function getSessionId() : String
      {
         return sessionId;
      }
      
      public function generateUiid(param1:Function, param2:int = 4) : void
      {
         var callback:Function = param1;
         var retryMax:int = param2;
         var request:URLRequest = createURLRequest("uiid");
         var alreadyResponsed:Boolean = false;
         beforeExecuteExtraResponse = false;
         responseCallback = function(param1:*):void
         {
            loginRetryCount = 0;
            alreadyResponsed = true;
            if(!(param1 is String) || param1.length != 36)
            {
               throw new ResponseMismatchError("response " + param1);
            }
            callback(param1);
         };
         beginRequest(request,false);
         var _loader:URLLoader = loader;
         var retryOrOverFunc:Function = function():void
         {
            if(alreadyResponsed)
            {
               return;
            }
            alreadyResponsed = true;
            Logger.debug("generateUiid loginRetryCount " + loginRetryCount);
            DataStorage.setLastConnectedServletHost(null);
            loader = null;
            if(loginRetryCount < retryMax)
            {
               servletHost = ApplicationSettings.getDefaultServletHost(loginRetryCount++);
               generateUiid(callback,retryMax);
            }
            else
            {
               Logger.warn("generateUiid failed");
               callback(null);
            }
         };
         _loader.addEventListener("ioError",function(param1:Event):void
         {
            Logger.warn("\tgenerateUiid IO_ERROR");
            retryOrOverFunc();
         });
      }
      
      public function useTakeoverCode(param1:String, param2:String, param3:String, param4:Function) : void
      {
         var code:String = param1;
         var _passwd:String = param2;
         var uiid:String = param3;
         var callback:Function = param4;
         var platform:String = "w";
         var _loc6_:* = Engine;
         if(gudetama.engine.Engine.platform == 1)
         {
            platform = "a";
         }
         else
         {
            var _loc7_:* = Engine;
            if(gudetama.engine.Engine.platform == 0)
            {
               platform = "i";
            }
         }
         var isOneStore:Boolean = false;
         if(isOneStore)
         {
            platform = "o";
         }
         var request:URLRequest = createURLRequest("takeover");
         var variables:URLVariables = new URLVariables();
         variables["t"] = code;
         variables["u"] = uiid;
         variables["tp"] = platform;
         variables["pwt"] = _passwd;
         variables["l"] = Engine.getLocale();
         request.data#2 = variables;
         beforeExecuteExtraResponse = false;
         responseCallback = function(param1:*):void
         {
            if(!(param1 is Array))
            {
               throw new ResponseMismatchError("response " + param1);
            }
            callback(param1);
         };
         beginRequest(request,false);
      }
      
      public function getGameSettingVersionWithoutLogin(param1:String, param2:Number, param3:Function) : void
      {
         var _loc4_:URLVariables;
         (_loc4_ = new URLVariables())["d"] = param1;
         requestDirectWithoutLogin(_loc4_,param2,param3);
      }
      
      public function getBannerProbability(param1:String, param2:Number, param3:Function) : void
      {
         var _loc4_:URLVariables;
         (_loc4_ = new URLVariables())["d"] = param1;
         _loc4_["a"] = Engine.platform;
         _loc4_["va"] = Engine.applicationVersion;
         requestDirectWithoutLogin(_loc4_,param2,param3);
      }
      
      private function requestDirectWithoutLogin(param1:URLVariables, param2:Number, param3:Function) : void
      {
         var variables:URLVariables = param1;
         var timeout:Number = param2;
         var callback:Function = param3;
         var request:URLRequest = createURLRequest("direct");
         request.data#2 = variables;
         var responsed:Boolean = false;
         beforeExecuteExtraResponse = false;
         responseCallback = function(param1:*):void
         {
            if(!responsed)
            {
               responsed = true;
            }
            callback(param1);
         };
         beginRequest(request,false);
         if(timeout > 0)
         {
            var _loc5_:* = Starling;
            (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).delayCall(function():void
            {
               if(!responsed)
               {
                  responsed = true;
                  cancel();
                  callback(null);
               }
            },timeout);
         }
      }
      
      public function login(param1:Function, param2:String, param3:Boolean = false) : void
      {
         var callback:Function = param1;
         var idfv:String = param2;
         var noRedirect:Boolean = param3;
         var variables:URLVariables = new URLVariables();
         variables["u"] = DataStorage.getUiid();
         variables["v"] = Engine.applicationVersion;
         variables["p"] = Engine.platform;
         variables["c"] = 34;
         variables["i"] = idfv;
         variables["l"] = Engine.getLocale();
         variables["o"] = 0;
         if(noRedirect)
         {
            variables["n"] = "";
         }
         loginHostHistory.push(servletHost);
         var alreadyResponsed:Boolean = false;
         var request:URLRequest = createURLRequest("entrance");
         request.data#2 = variables;
         Logger.debug("login " + request.url#2);
         beforeExecuteExtraResponse = false;
         responseCallback = function(param1:Array):void
         {
            var response:Array = param1;
            alreadyResponsed = true;
            loginRetryCount = 0;
            if(!(response[0] is Array))
            {
               throw new ResponseMismatchError("response[0] " + response[0]);
            }
            var intArray:Array = response[0] as Array;
            var responseCode:int = intArray[0];
            if(responseCode == 7)
            {
               if(!(response[1] is String))
               {
                  throw new ResponseMismatchError("responseCode, response[1] " + responseCode + ", " + response[1]);
               }
               var redirectTo:String = response[1];
               var noRedirect:Boolean = false;
               if(loginHostHistory.indexOf(redirectTo) >= 0)
               {
                  noRedirect = true;
                  Logger.debug("___________redirect loop occurred! " + redirectTo);
               }
               else
               {
                  loginHostHistory.push(redirectTo);
               }
               Logger.debug("\tredirect " + servletHost + " -> " + redirectTo + " noRedirect: " + noRedirect);
               servletHost = redirectTo;
               login(callback,idfv,noRedirect);
            }
            else if(responseCode == 11)
            {
               Engine.hideLoading();
               var _loc3_:* = Engine;
               var updateMessage:String = gudetama.engine.Engine.platform == 0 ? GameSetting.getUIText("message.error.needupdate.ios") : GameSetting.getUIText("message.error.needupdate.android");
               var isOneStore:Boolean = false;
               if(isOneStore)
               {
                  updateMessage = GameSetting.getUIText("message.error.needupdate.onestore");
               }
               MessageDialog.show(1,updateMessage,function(param1:int):void
               {
                  if(param1 == 0)
                  {
                     if(isOneStore)
                     {
                        navigateToURL(new URLRequest(GameSetting.getOtherText("url.onestore")),"_self");
                     }
                     else
                     {
                        var _loc2_:* = Engine;
                        navigateToURL(new URLRequest(GameSetting.getOtherText(gudetama.engine.Engine.platform == 0 ? "url.appstore" : "url.googleplay")),"_self");
                     }
                  }
               });
            }
            else
            {
               if(responseCode != 14)
               {
                  throw new ResponseMismatchError("responseCode " + responseCode);
               }
               DataStorage.setLastConnectedServletHost(servletHost);
               loginHostHistory.length = 0;
               var version:int = intArray[1];
               var beforeJapanIp:Boolean = Engine.isJapanIp();
               Engine.setCountryCode(intArray[2]);
               if(beforeJapanIp != Engine.isJapanIp())
               {
                  ResidentMenuUI_Gudetama.changeBannerBGLayout();
               }
               if(!(response[1] is String))
               {
                  throw new ResponseMismatchError("responseCode, response[1] " + responseCode + ", " + response[1]);
               }
               sessionId = response[1] as String;
               if(!(response[2] is ByteArray))
               {
                  throw new ResponseMismatchError("responseCode, response[2] " + responseCode + ", " + response[2]);
               }
               encryptor.setKeyBytes(response[2] as ByteArray);
               trace("response[3] " + response[3]);
               ApplicationSettings.setResourceUrlBase(response[3] as String,true);
               callback(version);
            }
         };
         beginRequest(request,false);
         var _loader:URLLoader = loader;
         var retryOrOverFunc:Function = function():void
         {
            Logger.debug("loginRetryCount " + loginRetryCount + ", alreadyResponsed " + alreadyResponsed);
            if(alreadyResponsed)
            {
               return;
            }
            alreadyResponsed = true;
            DataStorage.setLastConnectedServletHost(null);
            loader = null;
            if(loginRetryCount < 3)
            {
               servletHost = ApplicationSettings.getDefaultServletHost(loginRetryCount++);
               login(callback,idfv);
            }
            else
            {
               var message:String = GameSetting.getUIText("message.connection.error.atlogin");
               MessageDialog.show(12,message,function(param1:int):void
               {
                  loginRetryCount = 0;
                  if(param1 == 0)
                  {
                     WebViewDialog.showMaintenance();
                  }
                  Engine.hideLoadingForce(true);
               });
            }
         };
         _loader.addEventListener("ioError",function(param1:Event):void
         {
            Logger.warn("login IO_ERROR",param1);
            retryOrOverFunc();
         });
      }
      
      public function sendRequest(param1:Packet, param2:Function, param3:Boolean = false, param4:Boolean = false) : void
      {
         var _loc5_:Boolean = false;
         if(sessionId == null)
         {
            throw new Error();
         }
         sequenceNumber = sequenceNumber + 1 & 255;
         responseSequences[sequenceNumber] = 0;
         param1.sequence = sequenceNumber;
         Logger.debug("sendRequest " + sequenceNumber + ", type=" + param1.type + ", payloadInt=" + param1.payloadInt);
         afterReloginPacket = param1;
         var _loc9_:ByteArray = new ByteArray();
         CompatibleDataIO.write(_loc9_,param1);
         var _loc7_:String = encryptor.encryptForBase64(_loc9_);
         var _loc8_:URLVariables;
         (_loc8_ = new URLVariables())["s"] = sessionId;
         _loc8_["e"] = _loc7_;
         var _loc6_:URLRequest;
         (_loc6_ = createURLRequest("main")).data#2 = _loc8_;
         beginRequestWithCheckOverlap(_loc6_,param2,_loc5_,!param3,param3,param4);
      }
      
      public function isResponseWaiting() : Boolean
      {
         return loader != null;
      }
      
      public function cancel() : Boolean
      {
         lastResponseCode = -1;
         responseSequences[sequenceNumber] = 1;
         sequenceNumber = sequenceNumber + 1 & 255;
         if(loader == null)
         {
            return false;
         }
         try
         {
            loader.close();
         }
         catch(e:Error)
         {
            Logger.warn(e.getStackTrace());
         }
         loader = null;
         if(retryLoader)
         {
            try
            {
               retryLoader.close();
            }
            catch(e:Error)
            {
               Logger.debug(e.getStackTrace());
            }
            retryLoader = null;
         }
         return true;
      }
      
      public function isLastRequestSuccessed() : Boolean
      {
         return lastResponseCode >= 0;
      }
      
      private function beginRequestWithCheckOverlap(param1:URLRequest, param2:Function, param3:Boolean, param4:Boolean, param5:Boolean, param6:Boolean) : void
      {
         var request:URLRequest = param1;
         var callback:Function = param2;
         var useCurtain:Boolean = param3;
         var useRetryTimer:Boolean = param4;
         var forwardTitle:Boolean = param5;
         var beforeExtraResponse:Boolean = param6;
         var oneway:Boolean = false;
         if(loader == null)
         {
            beforeExecuteExtraResponse = beforeExtraResponse;
            responseCallback = function(param1:*):void
            {
               if(callback)
               {
                  callback(param1);
               }
            };
            beginRequest(request,oneway,useCurtain,useRetryTimer,forwardTitle);
            return;
         }
         var func:Function = function():void
         {
            if(loader == null)
            {
               Logger.debug("beginRequest overlapped success");
               beforeExecuteExtraResponse = beforeExtraResponse;
               responseCallback = function(param1:*):void
               {
                  if(callback)
                  {
                     callback(param1);
                  }
               };
               beginRequest(request,oneway,useCurtain,useRetryTimer,forwardTitle);
            }
            else
            {
               var _loc1_:* = Starling;
               (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).delayCall(func,0.03);
            }
         };
         Logger.debug("beginRequest overlapped trace: " + new Error().getStackTrace());
         var _loc8_:* = Starling;
         (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).delayCall(func,0.03);
      }
      
      private function beginRequest(param1:URLRequest, param2:Boolean, param3:Boolean = false, param4:Boolean = false, param5:Boolean = false) : void
      {
         var request:URLRequest = param1;
         var oneway:Boolean = param2;
         var useCurtain:Boolean = param3;
         var useRetryTimer:Boolean = param4;
         var forwardTitle:Boolean = param5;
         if(loader != null)
         {
            Logger.warn("beginRequest overlapped error: " + new Error().getStackTrace());
            return;
         }
         if(oneway)
         {
            doRequest(request,oneway,false,false);
         }
         else
         {
            loader = doRequest(request,oneway,useRetryTimer,forwardTitle);
            if(useRetryTimer)
            {
               var seq:uint = sequenceNumber;
               var _loc7_:* = Starling;
               (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).delayCall(function():void
               {
                  if(responseSequences[seq] != 0)
                  {
                     return;
                  }
                  Logger.debug("doRequest retry " + seq + " - " + responseSequences[seq]);
                  retryLoader = doRequest(request,oneway,useRetryTimer,forwardTitle);
               },7000 * 0.001);
               var _loc8_:* = Starling;
               (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).delayCall(function():void
               {
                  if(responseSequences[seq] != 0)
                  {
                     return;
                  }
                  var message:String = GameSetting.getUIText("message.connection.error");
                  MessageDialog.show(11,message,function(param1:int):void
                  {
                     loader = null;
                     if(param1 == 0)
                     {
                        beginRequest(request,false,true,true);
                     }
                     else
                     {
                        Engine.recoverScene();
                     }
                  });
               },18000 * 0.001);
            }
         }
      }
      
      private function doRequest(param1:URLRequest, param2:Boolean, param3:Boolean, param4:Boolean) : URLLoader
      {
         var request:URLRequest = param1;
         var oneway:Boolean = param2;
         var noRetry:Boolean = param3;
         var forwardTitle:Boolean = param4;
         var requestTime:int = getTimer();
         var _loader:URLLoader = new URLLoader(request);
         _loader.dataFormat = "binary";
         if(!oneway)
         {
            _loader.addEventListener("complete",function(param1:Event):void
            {
               var ev:Event = param1;
               try
               {
                  loader = null;
                  handleComplete(ev);
               }
               catch(e:Error)
               {
                  Logger.warn("handleComplete failed: ",e.getStackTrace());
                  MessageDialog.show(10,GameSetting.getUIText("message.error.response_mismatch"),function(param1:int):void
                  {
                     Engine.recoverScene();
                  });
               }
            });
            var retryOrOverFunc:Function = function():void
            {
               if(Engine.isSuspended())
               {
                  var _loc1_:* = Starling;
                  (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).delayCall(retryOrOverFunc,0.2);
                  return;
               }
               if(noRetry)
               {
                  return;
               }
               if(forwardTitle)
               {
                  Engine.recoverScene();
                  return;
               }
            };
            _loader.addEventListener("ioError",function(param1:Event):void
            {
               Logger.warn("IO_ERROR " + param1 + " time: " + (getTimer() - requestTime));
               afterReloginState = 0;
               retryOrOverFunc();
            });
         }
         _loader.addEventListener("securityError",function(param1:Event):void
         {
            Logger.warn("SECURITY_ERROR " + param1 + " time: " + (getTimer() - requestTime));
            afterReloginState = 0;
         });
         _loader.load(request);
         lastResponseCode = -1;
         return _loader;
      }
      
      private function resetOnError() : void
      {
         responseSequences[sequenceNumber] = 1;
         sequenceNumber = sequenceNumber + 1 & 255;
         Engine.unlockTouchInputForce();
         Engine.hideLoadingForce(true);
         Engine.suspend(false);
      }
      
      private function handleComplete(param1:Event) : void
      {
         var ev:Event = param1;
         var _loc2_:* = Engine;
         if(!(gudetama.engine.Engine.platform == 1 || gudetama.engine.Engine.platform == 0) && Engine.isSuspended())
         {
            var _loc3_:* = Starling;
            (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).delayCall(function():void
            {
               handleComplete(ev);
            },0.2);
            return;
         }
         var bytes:ByteArray = ev.target.data as ByteArray;
         var responseCode:int = bytes.readByte();
         lastResponseCode = responseCode;
         if(responseCode < 0)
         {
            if(ev.target == retryLoader)
            {
               return;
            }
            Engine.hideLoading();
            Logger.warn("error response: " + responseCode + ", sequenceNumber: " + sequenceNumber);
            if(responseCode == -3)
            {
               MessageDialog.show(12,GameSetting.getUIText("message.error.maintenance"),function(param1:int):void
               {
                  var choose:int = param1;
                  if(choose == 0)
                  {
                     WebViewDialog.showMaintenance(function():void
                     {
                        Engine.recoverScene();
                     });
                  }
                  else
                  {
                     Engine.recoverScene();
                  }
               });
            }
            else if(responseCode == -4)
            {
               MessageDialog.show(10,GameSetting.getUIText("message.error.congestion"),function():void
               {
                  Engine.recoverScene();
               });
            }
            else if(responseCode == -8)
            {
               Engine.hideLoading();
               var rejectMessage:String = bytes.readUTF();
               MessageDialog.show(10,rejectMessage,function():void
               {
                  Engine.recoverScene();
               });
            }
            else if(responseCode == -2)
            {
               cancel();
               afterReloginCallback = responseCallback;
               reEntranceLogin();
            }
            else if(responseCode == -6)
            {
               switch(int(afterReloginState) - 2)
               {
                  case 0:
                  case 9:
                     if(Engine.containsSceneStack(TitleScene) || Engine.containsSceneStack(OpeningScene))
                     {
                        MessageDialog.show(0,GameSetting.getUIText("error.msg.timeout2"),function():void
                        {
                           Engine.recoverScene();
                        });
                     }
                     else
                     {
                        Engine.procErrorOccurred();
                        MessageDialog.show(0,GameSetting.getUIText("error.msg.timeout"),function():void
                        {
                           ResidentMenuUI_Gudetama.getInstance().sendChangeState(60,function():void
                           {
                              Engine.switchScene(new HomeScene());
                           });
                        });
                     }
                     break;
                  default:
                     procCheatError();
               }
            }
            else if(responseCode == -9)
            {
               procCheatError();
            }
            else
            {
               MessageDialog.show(10,GameSetting.getUIText("message.error.server_internal"),function(param1:int):void
               {
                  Engine.recoverScene();
               });
            }
            if(responseCode != -2)
            {
               afterReloginState = 0;
            }
            return;
         }
         var payloadBytes:ByteArray = new ByteArray();
         payloadBytes.writeBytes(bytes,1,bytes.length - 1);
         var sequence:int = -1;
         if(responseCode == 64 || responseCode == 78)
         {
            encryptor.decrypt(payloadBytes);
            if(responseCode == 64)
            {
               sequence = payloadBytes[0] & 255;
               if(responseSequences[sequence] != 0)
               {
                  return;
               }
               responseSequences[sequence] = 1;
               payloadBytes.position = 1;
            }
            else
            {
               payloadBytes.position = 0;
            }
         }
         else
         {
            payloadBytes.position = 0;
         }
         var responseObj:* = CompatibleDataIO.read(payloadBytes);
         var responseObjExtra:* = null;
         if(responseObj is ByteArray)
         {
            Logger.debug("__HttpConnector#handleComplete seq: " + sequence + ", pos:" + payloadBytes.position + " len:" + payloadBytes.length);
         }
         else
         {
            Logger.debug("__HttpConnector#handleComplete seq: " + sequence + ", " + responseObj + " pos:" + payloadBytes.position + " len:" + payloadBytes.length);
         }
         if(payloadBytes.position < payloadBytes.length)
         {
            responseObjExtra = CompatibleDataIO.read(payloadBytes);
            Logger.debug("___HttpConnector#handleComplete extra " + responseObjExtra);
            if(!(responseObjExtra is Array))
            {
               throw new ResponseMismatchError("responseObjExtra " + responseObjExtra);
            }
         }
         if(afterReloginState == 1)
         {
            afterReloginState = 2;
         }
         else
         {
            afterReloginState = 0;
         }
         if(beforeExecuteExtraResponse)
         {
            executeExtraResponseCallback(responseObjExtra,sequence,responseObj);
         }
         var callback:Function = responseCallback;
         if(callback)
         {
            responseCallback = null;
            callback(responseObj);
         }
         if(!beforeExecuteExtraResponse)
         {
            executeExtraResponseCallback(responseObjExtra,sequence,responseObj);
         }
      }
      
      private function executeExtraResponseCallback(param1:*, param2:int, param3:*) : void
      {
         var _loc5_:Boolean = false;
         if(extraResponseCallback == null)
         {
            return;
         }
         for each(var _loc4_ in param1)
         {
            if(!(_loc5_ = extraResponseCallback(_loc4_)))
            {
               Logger.error("UserData not set yet: ",param2,param3,ObjectUtil.concatString(param3));
            }
         }
      }
      
      private function procCheatError() : void
      {
         MessageDialog.show(10,GameSetting.getUIText("message.error.response_mismatch"),function(param1:int):void
         {
            Engine.recoverScene();
         });
      }
      
      private function reEntranceLogin() : void
      {
         var localData:LocalData = DataStorage.getLocalData();
         if(localData.tempIdfv == "")
         {
            NativeExtensions.getNativeIdfv(function(param1:String):void
            {
               localData.tempIdfv = param1;
               login(procReEntranceResponse,param1);
            });
         }
         else
         {
            login(procReEntranceResponse,localData.tempIdfv);
         }
      }
      
      private function procReEntranceResponse(param1:int) : void
      {
         var serverSettingVer:int = param1;
         if(serverSettingVer == GameSetting.def.version)
         {
            procReloginAndRetry();
         }
         else
         {
            Engine.showLoading();
            GameSetting.setupForVersion(serverSettingVer,function():void
            {
               Engine.hideLoading();
               procReloginAndRetry();
            });
         }
      }
      
      private function procReloginAndRetry() : void
      {
         var _afterReloginPacket:Packet = afterReloginPacket;
         var _loc2_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithIntAndArrayObject(11,TimeZoneUtil.epochMillisToOffsetSecs(),Engine.getLocale()),function(param1:Array):void
         {
            UserDataWrapper.init(param1[0] as UserData);
            var _loc4_:Array = param1[2];
            Engine.serverTimeOffsetSec = _loc4_[0];
            UserDataWrapper.wrapper.hasPresentLimitSoon = _loc4_[1] != 0;
            UserDataWrapper.friendPart.setNumFollowers(param1[3][0]);
            UserDataWrapper.friendPart.setNumFriends(param1[3][1]);
            var _loc5_:Array = param1[4];
            for each(var _loc3_ in _loc5_)
            {
               UserDataWrapper.wrapper.updateFriendlyData(_loc3_);
            }
            DataStorage.getLocalData().friendKey = UserDataWrapper.wrapper.getFriendKey();
            var _loc8_:* = UserDataWrapper;
            if(gudetama.data.UserDataWrapper.wrapper._data.playerName.length > 0)
            {
               var _loc9_:* = UserDataWrapper;
               DataStorage.getLocalData().playerName = gudetama.data.UserDataWrapper.wrapper._data.playerName;
               var _loc10_:* = UserDataWrapper;
               DataStorage.getLocalData().gender = gudetama.data.UserDataWrapper.wrapper._data.gender;
            }
            DataStorage.saveLocalData();
            ResidentMenuUI_Gudetama.getInstance().updateUserInfo();
            ResidentMenuUI_Gudetama.initUpperPart();
            var _loc2_:Function = afterReloginCallback;
            afterReloginCallback = null;
            if(_afterReloginPacket.type == 59)
            {
               afterReloginState = 1;
            }
            else
            {
               afterReloginState = 11;
            }
            _afterReloginPacket.relogin = true;
            sendRequest(_afterReloginPacket,_loc2_);
         });
      }
   }
}
