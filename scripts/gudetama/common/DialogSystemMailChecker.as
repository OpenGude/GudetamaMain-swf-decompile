package gudetama.common
{
   import flash.display.BitmapData;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.utils.escapeMultiByte;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.SystemMailData;
   import gudetama.engine.Engine;
   import gudetama.engine.RsrcManager;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.scene.ar.SnsShareDialog;
   import gudetama.scene.mission.MissionScene;
   import gudetama.scene.ranking.RankingScene;
   import gudetama.ui.AcquiredItemDialog;
   import gudetama.ui.LocalMessageDialog;
   import gudetama.ui.MessageDialog;
   import gudetama.ui.MetalShopDialog_Gudetama;
   import gudetama.ui.MoneyShopDialog;
   import gudetama.ui.NoticeMonthlyDialog;
   import gudetama.ui.PublicRelationsDialog;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.ui.WebViewDialog;
   
   public class DialogSystemMailChecker
   {
      
      private static var keys:Array = ["navigate","color","image","direct","adjust","adjustWithUid","type","scene","present","premium","pr","flat","fparam","noFrame","mbilling","gbilling"];
      
      private static var androidKeys:Array = ["message","install","navigate"];
      
      private static var onFocusGainedCallback:Function;
       
      
      public function DialogSystemMailChecker()
      {
         super();
      }
      
      public static function checkDialogMail(param1:Function = null) : void
      {
         var _loc2_:SystemMailData = UserDataWrapper.wrapper.popDialogSystemMail();
         trace("checkDialogMail " + _loc2_);
         if(_loc2_ == null)
         {
            if(param1)
            {
               param1();
            }
            return;
         }
         processDialogMail(_loc2_,checkDialogMail,param1);
      }
      
      public static function processDialogMail(param1:SystemMailData, param2:Function = null, param3:Function = null) : void
      {
         var mail:SystemMailData = param1;
         var callback:Function = param2;
         var checkFinishedCallback:Function = param3;
         var message:String = GudetamaUtil.getSystemMailMessage(mail);
         message = message.replace("%FRIENDKEY%",UserDataWrapper.wrapper.getFriendKey());
         var title:String = mail.title;
         var url:String = mail.url#2;
         var type:int = -1;
         var useNavigate:Boolean = false;
         var isStore:Boolean = false;
         var directWebView:Boolean = false;
         var systemMailBgType:int = 0;
         var adjustToken:Array = null;
         var adjustWithUid:Boolean = false;
         var scene:String = null;
         var identifiedPresentId:int = 0;
         var isPR:Boolean = false;
         var flat:String = null;
         var noFrame:Boolean = false;
         var androidInstallUrl:String = null;
         var androidInstallUseNavigate:Boolean = false;
         var mbilling:Boolean = false;
         var gbilling:Boolean = false;
         if(!url)
         {
            url = null;
         }
         else
         {
            url = url.replace("%FRIENDKEY%",UserDataWrapper.wrapper.getFriendKey());
            if(url == "store")
            {
               var isOneStore:Boolean = false;
               if(isOneStore)
               {
                  url = GameSetting.getOtherText("url.onestore");
               }
               else
               {
                  var _loc5_:* = Engine;
                  url = gudetama.engine.Engine.platform == 1 ? GameSetting.getOtherText("url.googleplay") : GameSetting.getOtherText("url.appstore");
               }
               useNavigate = true;
               isStore = true;
               var messageType:int = 15;
            }
            else if(url.indexOf("twitter:") == 0)
            {
               var twitterMessage:String = url.slice("twitter:".length);
               url = GameSetting.getOtherText("url.twitter").replace("%1",escapeMultiByte(twitterMessage));
               useNavigate = true;
               messageType = 8;
            }
            else
            {
               messageType = 5;
               var len:int = keys.length;
               var i:int = 0;
               while(i < len)
               {
                  var keyindex:int = url.indexOf("!");
                  if(keyindex >= 0)
                  {
                     var key:String = url.slice(0,url.indexOf("!"));
                     if(key.indexOf(keys[0]) >= 0)
                     {
                        url = url.slice(key.length + 1);
                        useNavigate = true;
                     }
                     else if(key.indexOf(keys[1]) >= 0)
                     {
                        var index:int = url.indexOf(key);
                        var endindex:int = url.indexOf("#") + 1;
                        if(index >= 0)
                        {
                           systemMailBgType = key.slice(index + endindex,key.length);
                           url = url.slice(key.length + 1,url.length);
                        }
                     }
                     else if(key.indexOf(keys[2]) >= 0)
                     {
                        index = url.indexOf(key);
                        endindex = url.indexOf("#") + 1;
                        if(index >= 0)
                        {
                           var imagePath:String = key.slice(index + endindex,key.length);
                           url = url.slice(key.length + 1,url.length);
                        }
                     }
                     else if(key.indexOf(keys[3]) >= 0)
                     {
                        url = url.slice(key.length + 1);
                        directWebView = true;
                     }
                     else if(key.indexOf(keys[4]) >= 0)
                     {
                        index = url.indexOf(key);
                        endindex = url.indexOf("#") + 1;
                        if(index >= 0)
                        {
                           var token:Array = key.slice(index + endindex,key.length).split(",");
                           if(token && token.length >= 2)
                           {
                              adjustToken = token;
                           }
                           url = url.slice(key.length + 1,url.length);
                        }
                     }
                     else if(key.indexOf(keys[5]) >= 0)
                     {
                        index = url.indexOf(key);
                        endindex = url.indexOf("#") + 1;
                        if(index >= 0)
                        {
                           token = key.slice(index + endindex,key.length).split(",");
                           if(token && token.length >= 2)
                           {
                              adjustToken = token;
                           }
                           url = url.slice(key.length + 1,url.length);
                           adjustWithUid = true;
                        }
                     }
                     else if(key.indexOf(keys[6]) >= 0)
                     {
                        index = url.indexOf(key);
                        endindex = url.indexOf("#") + 1;
                        if(index >= 0)
                        {
                           type = parseInt(key.slice(index + endindex,key.length));
                           url = url.slice(key.length + 1,url.length);
                        }
                     }
                     else if(key.indexOf(keys[7]) >= 0)
                     {
                        index = url.indexOf(key);
                        endindex = url.indexOf("#") + 1;
                        if(index >= 0)
                        {
                           scene = key.slice(index + endindex,key.length);
                           url = url.slice(key.length + 1,url.length);
                        }
                     }
                     else if(key.indexOf(keys[8]) >= 0)
                     {
                        index = url.indexOf(key);
                        endindex = url.indexOf("#") + 1;
                        if(index >= 0)
                        {
                           identifiedPresentId = parseInt(key.slice(index + endindex,key.length));
                           url = url.slice(key.length + 1,url.length);
                        }
                     }
                     else if(key.indexOf(keys[9]) >= 0)
                     {
                        index = url.indexOf(key);
                        endindex = url.indexOf("#") + 1;
                        if(index >= 0)
                        {
                           var premiumId:int = parseInt(key.slice(index + endindex,key.length));
                           url = url.slice(key.length + 1,url.length);
                        }
                     }
                     else if(key.indexOf(keys[10]) >= 0)
                     {
                        url = url.slice(key.length + 1);
                        isPR = true;
                     }
                     else if(key.indexOf(keys[11]) >= 0)
                     {
                        index = url.indexOf(key);
                        endindex = url.indexOf("#") + 1;
                        if(index >= 0)
                        {
                           flat = key.slice(index + endindex,key.length);
                           url = url.slice(key.length + 1,url.length);
                        }
                     }
                     else if(key.indexOf(keys[12]) >= 0)
                     {
                        index = url.indexOf(key);
                        endindex = url.indexOf("#") + 1;
                        if(index >= 0)
                        {
                           var fparam:int = parseInt(key.slice(index + endindex,key.length));
                           url = url.slice(key.length + 1,url.length);
                        }
                     }
                     else if(key.indexOf(keys[13]) >= 0)
                     {
                        url = url.slice(key.length + 1);
                        noFrame = true;
                     }
                     else if(key.indexOf(keys[14]) >= 0)
                     {
                        url = url.slice(key.length + 1);
                        mbilling = true;
                     }
                     else if(key.indexOf(keys[15]) >= 0)
                     {
                        url = url.slice(key.length + 1);
                        gbilling = true;
                     }
                  }
                  i++;
               }
            }
            trace("\turl " + url);
         }
         if(message && message.charAt(0) == "{")
         {
            var json:Object = JSON.parse(message);
            message = json.message;
            title = json.title;
            url = json.url;
            if(url == "store")
            {
               isOneStore = false;
               if(isOneStore)
               {
                  url = GameSetting.getOtherText("url.onestore");
               }
               else
               {
                  var _loc6_:* = Engine;
                  url = gudetama.engine.Engine.platform == 1 ? GameSetting.getOtherText("url.googleplay") : GameSetting.getOtherText("url.appstore");
               }
               useNavigate = true;
               isStore = true;
               messageType = 15;
            }
            if(json.tweet)
            {
               url = GameSetting.getOtherText("url.twitter").replace("%1",escapeMultiByte(json.tweet));
               useNavigate = true;
               messageType = 8;
            }
            if(url)
            {
               if(url.substring(0,10) == "twitter://")
               {
                  useNavigate = true;
                  messageType = 8;
               }
               else
               {
                  messageType = 5;
               }
            }
            if(json.browser)
            {
               useNavigate = json.browser == "navigate";
            }
            if(json.type)
            {
               type = parseInt(json.type);
            }
            if(json.scene)
            {
               scene = json.scene;
            }
            if(json.present)
            {
               identifiedPresentId = parseInt(json.present);
            }
            if(json.pr)
            {
               isPR = json.pr == "true";
            }
            if(json.flat)
            {
               flat = json.flat;
            }
            if(json.fparam)
            {
               fparam = parseInt(json.fparam);
            }
            if(json.noFrame)
            {
               noFrame = json.frame == "true";
            }
            if(json.premium)
            {
               premiumId = parseInt(json.premium);
            }
            if(json.mbilling)
            {
               mbilling = true;
            }
            if(json.gbilling)
            {
               gbilling = true;
            }
            var _loc7_:* = Engine;
            if(gudetama.engine.Engine.platform == 1 && json.urlAndroid)
            {
               url = json.urlAndroid;
               var j:int = 0;
               while(j < androidKeys.length)
               {
                  var androidKeyindex:int = url.indexOf("!");
                  if(androidKeyindex >= 0)
                  {
                     var androidKey:String = url.slice(0,url.indexOf("!"));
                     if(androidKey.indexOf(androidKeys[0]) >= 0)
                     {
                        var androidIndex:int = url.indexOf(androidKey);
                        var androidEndindex:int = url.indexOf("#") + 1;
                        if(androidIndex >= 0)
                        {
                           var androidInstallMessage:String = androidKey.slice(androidIndex + androidEndindex,androidKey.length);
                           if(androidInstallMessage.charAt(0) == "%")
                           {
                              message = GameSetting.getUIText(androidInstallMessage);
                           }
                           else
                           {
                              message = androidInstallMessage;
                           }
                           url = url.slice(androidKey.length + 1,url.length);
                        }
                     }
                     else if(androidKey.indexOf(androidKeys[1]) >= 0)
                     {
                        androidIndex = url.indexOf(androidKey);
                        androidEndindex = url.indexOf("#") + 1;
                        if(androidIndex >= 0)
                        {
                           androidInstallUrl = androidKey.slice(androidIndex + androidEndindex,androidKey.length);
                           messageType = 27;
                           url = url.slice(androidKey.length + 1,url.length);
                        }
                     }
                     else if(androidKey.indexOf(androidKeys[2]) >= 0)
                     {
                        url = url.slice(androidKey.length + 1);
                        androidInstallUseNavigate = true;
                     }
                  }
                  j++;
               }
            }
            imagePath = json.image;
            directWebView = !message && !imagePath;
         }
         if(title && title.length > 0 && title.charAt(0) == "%")
         {
            title = GameSetting.getUIText(title);
         }
         if(message && message.length > 0 && message.charAt(0) == "%")
         {
            message = GameSetting.getUIText(message);
         }
         if(url && url.length > 0 && url.charAt(0) == "%")
         {
            url = GameSetting.getUIText(url);
         }
         if(url)
         {
            index = url.indexOf("@[");
         }
         else
         {
            index = -1;
         }
         while(index >= 0)
         {
            endindex = url.indexOf("]",index + 2) + 1;
            var paramKey:String = url.substring(index,endindex);
            var paramName:String = url.substring(index + 2,endindex - 1);
            try
            {
               var parameter:* = UserDataWrapper.wrapper[paramName];
            }
            catch(e:Error)
            {
               var _loc8_:* = UserDataWrapper;
               parameter = gudetama.data.UserDataWrapper.wrapper._data[paramName];
            }
            if(parameter is String)
            {
               parameter = encodeURI(parameter);
            }
            url = url.replace(paramKey,parameter);
            index = url.indexOf("@[");
         }
         if(!isPR && identifiedPresentId > 0 && !UserDataWrapper.wrapper.isAcquirableIdentifiedPresent(identifiedPresentId))
         {
            if(callback)
            {
               callback(checkFinishedCallback);
            }
            return;
         }
         if(mail.type == 10 || mail.type == 11 || mail.type == 12 || mail.type == 1)
         {
            if(isStore)
            {
               LocalMessageDialog.show(6,GameSetting.getUIText("general.message.review.confirm"),function(param1:int):void
               {
                  var choose:int = param1;
                  if(choose == 0)
                  {
                     var reviewMessage:String = GameSetting.getUIText("general.message.review.message.os");
                     isOneStore = false;
                     var storeindex:int = Engine.platform;
                     if(isOneStore)
                     {
                        storeindex = 4;
                     }
                     reviewMessage = reviewMessage.replace("%STORE%",GameSetting.getUIText("store.name." + Math.min(1,storeindex)));
                     LocalMessageDialog.show(7,reviewMessage,function(param1:int):void
                     {
                        if(param1 == 0)
                        {
                           navigateToURL(new URLRequest(url),"_self");
                        }
                        else if(callback)
                        {
                           callback(checkFinishedCallback);
                        }
                     },GameSetting.getUIText("general.message.review.title"));
                  }
                  else
                  {
                     LocalMessageDialog.show(8,GameSetting.getUIText("general.message.opinion.message"),function(param1:int):void
                     {
                        var choose:int = param1;
                        if(choose == 0)
                        {
                           WebViewDialog.show(GameSetting.getOtherText("url.contact").replace("%1",UserDataWrapper.wrapper.getFriendKey()),function():void
                           {
                              if(callback)
                              {
                                 callback(checkFinishedCallback);
                              }
                           });
                        }
                        else if(callback)
                        {
                           callback(checkFinishedCallback);
                        }
                     },GameSetting.getUIText("general.message.opinion.title"));
                  }
               },title);
            }
            else if(premiumId > 0)
            {
               NoticeMonthlyDialog.show(GameSetting.getMonthlyPremiumBonus(premiumId),function():void
               {
                  if(callback)
                  {
                     callback(checkFinishedCallback);
                  }
               });
            }
            else if(isPR)
            {
               PublicRelationsDialog.show(message,imagePath,identifiedPresentId,function():void
               {
                  if(callback)
                  {
                     callback(checkFinishedCallback);
                  }
               });
            }
            else if(url)
            {
               if(directWebView)
               {
                  if(useNavigate)
                  {
                     navigateToURL(new URLRequest(url),"_self");
                  }
                  else
                  {
                     WebViewDialog.show(url,function():void
                     {
                        if(callback)
                        {
                           callback(checkFinishedCallback);
                        }
                     });
                  }
               }
               else if(type >= 0)
               {
                  LocalMessageDialog.show(type,message,function(param1:int):void
                  {
                     var choose:int = param1;
                     if(choose == 0)
                     {
                        if(!moveScene(scene))
                        {
                           identifiedPresent(identifiedPresentId,function():void
                           {
                              if(useNavigate)
                              {
                                 navigateToURL(new URLRequest(url),"_self");
                              }
                              else
                              {
                                 WebViewDialog.show(url,function():void
                                 {
                                    onFocusGained();
                                 });
                              }
                           },function():void
                           {
                              if(callback)
                              {
                                 callback(checkFinishedCallback);
                              }
                           });
                        }
                     }
                     else if(choose == 2)
                     {
                        if(!moveScene(flat,fparam,imagePath,function():void
                        {
                           if(callback)
                           {
                              callback(checkFinishedCallback);
                           }
                        }))
                        {
                           if(callback)
                           {
                              callback(checkFinishedCallback);
                           }
                        }
                     }
                     else if(callback)
                     {
                        callback(checkFinishedCallback);
                     }
                  },title,94,imagePath,noFrame);
               }
               else
               {
                  MessageDialog.show(messageType,message,function(param1:int):void
                  {
                     var choose:int = param1;
                     if(choose == 0)
                     {
                        identifiedPresent(identifiedPresentId,function():void
                        {
                           if(mbilling || gbilling)
                           {
                              if(mbilling)
                              {
                                 MetalShopDialog_Gudetama.show(2,function(param1:int):void
                                 {
                                    onFocusGained();
                                 });
                              }
                              else if(gbilling)
                              {
                                 MoneyShopDialog.show(1,function(param1:int):void
                                 {
                                    onFocusGained();
                                 });
                              }
                           }
                           else if(useNavigate)
                           {
                              navigateToURL(new URLRequest(url),"_self");
                           }
                           else
                           {
                              WebViewDialog.show(url,function():void
                              {
                                 onFocusGained();
                              });
                           }
                        },function():void
                        {
                           if(callback)
                           {
                              callback(checkFinishedCallback);
                           }
                        });
                     }
                     else if(androidInstallUrl)
                     {
                        if(choose == 2)
                        {
                           if(androidInstallUseNavigate)
                           {
                              setFocusGainedCallback(function():void
                              {
                                 if(callback)
                                 {
                                    callback(checkFinishedCallback);
                                 }
                              });
                              navigateToURL(new URLRequest(androidInstallUrl),"_self");
                           }
                           else
                           {
                              WebViewDialog.show(androidInstallUrl,function():void
                              {
                                 if(callback)
                                 {
                                    callback(checkFinishedCallback);
                                 }
                              });
                           }
                        }
                        else if(callback)
                        {
                           callback(checkFinishedCallback);
                        }
                     }
                     else if(callback)
                     {
                        callback(checkFinishedCallback);
                     }
                  },title,systemMailBgType,imagePath);
               }
            }
            else if(type == 11 && scene)
            {
               if(!moveScene(scene))
               {
                  if(callback)
                  {
                     callback(checkFinishedCallback);
                  }
               }
            }
            else if(type >= 0)
            {
               LocalMessageDialog.show(type,message,function(param1:int):void
               {
                  var choose:int = param1;
                  if(choose == 0)
                  {
                     if(!moveScene(scene))
                     {
                        identifiedPresent(identifiedPresentId,function():void
                        {
                           onFocusGained();
                        },function():void
                        {
                           if(callback)
                           {
                              callback(checkFinishedCallback);
                           }
                        });
                     }
                  }
                  else if(choose == 2)
                  {
                     if(!moveScene(flat,fparam,imagePath,function():void
                     {
                        if(callback)
                        {
                           callback(checkFinishedCallback);
                        }
                     }))
                     {
                        if(callback)
                        {
                           callback(checkFinishedCallback);
                        }
                     }
                  }
                  else if(callback)
                  {
                     callback(checkFinishedCallback);
                  }
               },title,94,imagePath,noFrame);
            }
            else
            {
               MessageDialog.show(6,message,function(param1:int):void
               {
                  var choose:int = param1;
                  if(choose == 0)
                  {
                     identifiedPresent(identifiedPresentId,function():void
                     {
                        onFocusGained();
                     },function():void
                     {
                        if(callback)
                        {
                           callback(checkFinishedCallback);
                        }
                     });
                  }
                  else if(androidInstallUrl)
                  {
                     if(choose == 2)
                     {
                        if(androidInstallUseNavigate)
                        {
                           setFocusGainedCallback(function():void
                           {
                              if(callback)
                              {
                                 callback(checkFinishedCallback);
                              }
                           });
                           navigateToURL(new URLRequest(androidInstallUrl),"_self");
                        }
                        else
                        {
                           WebViewDialog.show(url,function():void
                           {
                              if(callback)
                              {
                                 callback(checkFinishedCallback);
                              }
                           });
                        }
                     }
                     else if(callback)
                     {
                        callback(checkFinishedCallback);
                     }
                  }
                  else if(callback)
                  {
                     callback(checkFinishedCallback);
                  }
               },title,systemMailBgType,imagePath);
            }
         }
      }
      
      private static function moveScene(param1:String, param2:int = 0, param3:String = null, param4:Function = null) : Boolean
      {
         var scene:String = param1;
         var argi:int = param2;
         var argv:String = param3;
         var callback:Function = param4;
         switch(scene)
         {
            case "mission":
               ResidentMenuUI_Gudetama.getInstance().sendChangeState(144,function():void
               {
                  var _loc1_:Boolean = false;
                  if(UserDataWrapper.wrapper.isCanStartNoticeFlag(9) || UserDataWrapper.wrapper.isCanStartNoticeFlag(10) || UserDataWrapper.wrapper.isCanStartNoticeFlag(21))
                  {
                     _loc1_ = true;
                  }
                  Engine.switchScene(new MissionScene(),1,0.5,_loc1_);
               });
               return true;
            case "ranking":
               var rankingIds:Array = UserDataWrapper.eventPart.getRankingIds(false,false);
               if(rankingIds == null)
               {
                  procNoRanking();
                  return false;
               }
               Engine.showLoading(moveScene);
               var _loc6_:* = HttpConnector;
               if(gudetama.net.HttpConnector.mainConnector == null)
               {
                  gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
               }
               gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(51,rankingIds),function(param1:*):void
               {
                  var res:* = param1;
                  Engine.hideLoading(moveScene);
                  if(res == null)
                  {
                     procNoRanking();
                     return;
                  }
                  var rankingInfoMap:Object = res;
                  ResidentMenuUI_Gudetama.getInstance().sendChangeState(150,function():void
                  {
                     Engine.switchScene(new RankingScene(rankingInfoMap),1,0.5,Engine.getGuideTalkPanel() != null);
                  });
               });
               return true;
               break;
            case "share":
               Engine.showLoading(moveScene);
               return loadBitmapData(argv,function(param1:BitmapData):void
               {
                  Engine.hideLoading(moveScene);
                  SnsShareDialog.show(param1,5,false,callback,null,argi);
               });
            default:
               return false;
         }
      }
      
      private static function procNoRanking() : void
      {
         LocalMessageDialog.show(0,GameSetting.getUIText("ranking.msg.no.ranking"));
      }
      
      private static function loadBitmapData(param1:String, param2:Function) : Boolean
      {
         if(!param1)
         {
            return false;
         }
         if(param1.indexOf("://") > 0)
         {
            RsrcManager.getInstance().loadBitmapData(param1,param2);
         }
         else
         {
            RsrcManager.loadDialogPicture(param1,param2);
         }
         return true;
      }
      
      private static function identifiedPresent(param1:int, param2:Function, param3:Function) : void
      {
         var id:int = param1;
         var callback:Function = param2;
         var finishFunc:Function = param3;
         if(id <= 0)
         {
            onFocusGainedCallback = function():void
            {
               onFocusGainedCallback = null;
               if(finishFunc)
               {
                  finishFunc();
               }
            };
            if(callback)
            {
               callback();
            }
            return;
         }
         Engine.showLoading(identifiedPresent);
         var _loc4_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(240,id),function(param1:Array):void
         {
            var response:Array = param1;
            Engine.hideLoading(identifiedPresent);
            onFocusGainedCallback = function():void
            {
               var _loc2_:Array = response[0];
               var _loc1_:Array = response[1];
               UserDataWrapper.wrapper.addItems(_loc2_,_loc1_);
               UserDataWrapper.wrapper.increaseNumAcquiredIdentifiedPresent(id);
               onFocusGainedCallback = null;
               AcquiredItemDialog.show(_loc2_,_loc1_,finishFunc);
            };
            if(callback)
            {
               callback();
            }
         });
      }
      
      public static function setFocusGainedCallback(param1:Function) : void
      {
         var callback:Function = param1;
         onFocusGainedCallback = function():void
         {
            onFocusGainedCallback = null;
            if(callback)
            {
               callback();
            }
         };
      }
      
      public static function onFocusGained() : void
      {
         if(onFocusGainedCallback)
         {
            onFocusGainedCallback();
         }
      }
   }
}
