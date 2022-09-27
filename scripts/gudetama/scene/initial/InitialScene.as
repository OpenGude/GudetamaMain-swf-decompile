package gudetama.scene.initial
{
   import gudetama.common.BannerAdvertisingManager;
   import gudetama.common.GudetamaUtil;
   import gudetama.common.NativeExtensions;
   import gudetama.data.DataStorage;
   import gudetama.data.GameSetting;
   import gudetama.data.LocalData;
   import gudetama.data.UserDataWrapper;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.LoadingDialog;
   import gudetama.engine.Logger;
   import gudetama.engine.RsrcManager;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TouchEffect;
   import gudetama.net.HttpConnector;
   import gudetama.scene.opening.LanguageSelectDialog;
   import gudetama.scene.title.CautionScene;
   import gudetama.scene.title.CompanyLogoScene;
   import gudetama.scene.title.TitleScene;
   import gudetama.ui.MessageDialog;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.ui.WebViewDialog;
   import muku.core.TaskQueue;
   import starling.core.Starling;
   
   public class InitialScene extends BaseScene
   {
       
      
      public function InitialScene()
      {
         super(0);
      }
      
      public static function switchNextScene(param1:Boolean = true) : void
      {
         var goTitle:Boolean = param1;
         var titleSceneClass:Class = null;
         if(!titleSceneClass)
         {
            titleSceneClass = TitleScene;
         }
         Engine.setRecoverSceneFunction(function():void
         {
            UserDataWrapper.wrapper.questRoomType = 0;
            Engine.openTransition(null,-1,true);
            Engine.switchScene(new titleSceneClass());
         });
         if(!goTitle)
         {
            var _loc3_:* = Engine;
            if(gudetama.engine.Engine.platform == 0)
            {
               Engine.switchScene(new CautionScene());
            }
            else
            {
               Engine.switchScene(new CompanyLogoScene());
            }
         }
         else
         {
            Engine.switchScene(new titleSceneClass());
         }
      }
      
      public static function showLocaleSelect(param1:Function, param2:Boolean) : void
      {
         var callback:Function = param1;
         var needCancel:Boolean = param2;
         LanguageSelectDialog.show(function(param1:String):void
         {
            if(param1 == null)
            {
               callback();
               return;
            }
            var _loc2_:LocalData = DataStorage.getLocalData();
            _loc2_.setLocale(param1);
            _loc2_.needSelectLocale = false;
            DataStorage.saveLocalData();
            Engine.setLocale(param1);
            callback();
         },needCancel);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         MessageDialog.createSingleton();
         WebViewDialog.createSingleton();
         Engine.showLoading();
         var func:Function = function():void
         {
            DataStorage.init(function(param1:Boolean):void
            {
               var uiidInitialized:Boolean = param1;
               try
               {
                  DataStorage.loadLocalData();
               }
               catch(error:Error)
               {
                  Logger.warn("data broken: ",error);
                  DataStorage.resetLocalData();
                  DataStorage.loadLocalData();
               }
               GameSetting.setup(function():void
               {
                  checkGameSettingVersion(onProgress,function():void
                  {
                     if(GameSetting.hasScreeningFlag(5))
                     {
                        setupBannerProbability(onProgress,uiidInitialized);
                     }
                     else
                     {
                        setupFinish(uiidInitialized);
                     }
                  });
               });
            });
         };
         Engine.setRecoverSceneFunction(func);
         func();
      }
      
      private function checkGameSettingVersion(param1:Function, param2:Function) : void
      {
         var onProgress:Function = param1;
         var _finishCallback:Function = param2;
         queue.addTask(function():void
         {
            var versionCheckDone:Boolean = false;
            var _loc2_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.getGameSettingVersionWithoutLogin("g",0,function(param1:*):void
            {
               var response:* = param1;
               trace("requestDirectWithoutLogin g",response,GameSetting.def.version);
               if(!response || !(response is Array) || !(response[0] is int))
               {
                  DataStorage.setLastConnectedServletHost(null);
                  queue.taskDone();
                  if(!versionCheckDone)
                  {
                     versionCheckDone = true;
                     queue.taskDone();
                  }
                  return;
               }
               var serverGameSettingVersion:int = response[0];
               Engine.setCountryCode(response[1]);
               if(serverGameSettingVersion == GameSetting.def.version)
               {
                  trace("serverGameSettingVersion == GameSetting.def.version",GameSetting.def.version);
                  queue.taskDone();
                  if(!versionCheckDone)
                  {
                     versionCheckDone = true;
                     queue.taskDone();
                  }
               }
               else
               {
                  GameSetting.setupForVersion(serverGameSettingVersion,function():void
                  {
                     trace("setupForVersion done",serverGameSettingVersion,GameSetting.def.version);
                     queue.taskDone();
                     if(!versionCheckDone)
                     {
                        versionCheckDone = true;
                        queue.taskDone();
                     }
                  },true);
               }
            });
            var _loc3_:* = Starling;
            (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).delayCall(function():void
            {
               if(!versionCheckDone)
               {
                  versionCheckDone = true;
                  var _loc1_:* = HttpConnector;
                  if(gudetama.net.HttpConnector.mainConnector == null)
                  {
                     gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
                  }
                  gudetama.net.HttpConnector.mainConnector.cancel();
                  DataStorage.setLastConnectedServletHost(null);
                  queue.taskDone();
               }
            },6.5);
         });
         queue.registerOnProgress(function(param1:Number):void
         {
            var ratio:Number = param1;
            if(ratio < 1)
            {
               return;
            }
            var queueNext:TaskQueue = new TaskQueue();
            NativeExtensions.adsSetup(queueNext);
            queueNext.addTask(function():void
            {
               juggler.delayCall(function():void
               {
                  GudetamaUtil.initFont(function():void
                  {
                     queueNext.taskDone();
                  });
               },0.001);
            });
            queueNext.registerOnProgress(function(param1:Number):void
            {
               var ratio:Number = param1;
               if(ratio < 1)
               {
                  return;
               }
               juggler.delayCall(function():void
               {
                  _finishCallback();
               },0.001);
            });
            queueNext.startTask();
         });
         TouchEffect.init(queue);
         queue.startTask(onProgress);
      }
      
      private function setupBannerProbability(param1:Function, param2:Boolean) : void
      {
         var onProgress:Function = param1;
         var uiidInitialized:Boolean = param2;
         queue.addTask(function():void
         {
            var setuped:Boolean = false;
            var _loc2_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.getBannerProbability("b",0,function(param1:*):void
            {
               if(!param1 || !(param1 is String))
               {
                  if(!setuped)
                  {
                     setuped = true;
                     queue.taskDone();
                  }
                  return;
               }
               if(!setuped)
               {
                  setuped = true;
                  DataStorage.getLocalData().setBannerAdsRate(param1);
                  if(!DataStorage.getLocalData().needSelectLocale)
                  {
                     BannerAdvertisingManager.showBannerAds();
                  }
                  queue.taskDone();
               }
            });
            var _loc3_:* = Starling;
            (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).delayCall(function():void
            {
               if(!setuped)
               {
                  setuped = true;
                  var _loc1_:* = HttpConnector;
                  if(gudetama.net.HttpConnector.mainConnector == null)
                  {
                     gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
                  }
                  gudetama.net.HttpConnector.mainConnector.cancel();
                  queue.taskDone();
               }
            },6.5);
         });
         var queueNext:TaskQueue = new TaskQueue();
         queueNext.registerOnProgress(function(param1:Number):void
         {
            var ratio:Number = param1;
            if(ratio < 1)
            {
               return;
            }
            juggler.delayCall(function():void
            {
               setupFinish(uiidInitialized);
            },0.001);
         });
         queueNext.startTask();
         queue.startTask(onProgress);
      }
      
      private function setupFinish(param1:Boolean) : void
      {
         var uiidInitialized:Boolean = param1;
         var localData:LocalData = DataStorage.getLocalData();
         if(localData.needSelectLocale)
         {
            if(GudetamaUtil.isMultiLang())
            {
               var setupLocale:* = function():void
               {
                  var locale:String = Engine.getLocale();
                  if(orgLocale != locale)
                  {
                     localData.setNeedDownloadFirstRsrc(locale != "ja");
                     Engine.clearCache();
                     TextureCollector.clearAll(1);
                     RsrcManager.clearFileCache();
                     RsrcManager.getInstance().setupFileCheckMap(null);
                     LoadingDialog.resetLoadingText();
                     GudetamaUtil.initFont(function():void
                     {
                        GameSetting.setup(function():void
                        {
                           GameSetting.def.version = -1;
                           MessageDialog.clearSingleton();
                           MessageDialog.createSingleton();
                           setupFinish(uiidInitialized);
                        });
                     });
                  }
                  else
                  {
                     setupFinish(uiidInitialized);
                  }
               };
               var orgLocale:String = Engine.getLocale();
               var _loc3_:* = Engine;
               if(gudetama.engine.Engine.platform == 1 && GameSetting.hasScreeningFlag(11))
               {
                  localData.needSelectLocale = false;
                  setupLocale();
               }
               else
               {
                  InitialScene.showLocaleSelect(setupLocale,false);
               }
               return;
            }
            localData.needSelectLocale = false;
            var locale:String = Engine.getLocale();
            if(locale != "ja")
            {
               localData.setLocale("ja");
               DataStorage.saveLocalData();
               Engine.setLocale("ja");
               LoadingDialog.resetLoadingText();
               GudetamaUtil.initFont(function():void
               {
                  GameSetting.setup(function():void
                  {
                     GameSetting.def.version = -1;
                     setupFinish(uiidInitialized);
                  });
               });
               return;
            }
         }
         var queue:TaskQueue = new TaskQueue();
         ResidentMenuUI_Gudetama.setupExtraResponse();
         queue.registerOnProgress(function(param1:Number):void
         {
            var ratio:Number = param1;
            if(ratio < 1)
            {
               return;
            }
            if(uiidInitialized)
            {
               switchNextScene(false);
               return;
            }
            var message:String = GameSetting.getUIText("message.connection.error.atlogin");
            var retryFunc:Function = function():void
            {
               DataStorage.generateAndSetUiid(function(param1:Boolean):void
               {
                  var _uiidInitialized:Boolean = param1;
                  uiidInitialized = _uiidInitialized;
                  if(!uiidInitialized)
                  {
                     MessageDialog.show(12,message,function(param1:int):void
                     {
                        if(param1 == 0)
                        {
                           WebViewDialog.showMaintenance(retryFunc);
                        }
                        else
                        {
                           retryFunc();
                        }
                     });
                  }
                  else
                  {
                     switchNextScene(false);
                  }
               });
            };
            retryFunc();
         });
         queue.startTask();
      }
   }
}
