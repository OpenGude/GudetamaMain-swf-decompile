package gudetama.common
{
   import com.twit.api.twitter.TwitterAPI;
   import com.twit.api.twitter.commands.account.VerifyCredentials;
   import com.twit.api.twitter.commands.status.UpdateStatus;
   import com.twit.api.twitter.commands.user.LoadFriendsInfo;
   import com.twit.api.twitter.data.TwitterUser;
   import com.twit.api.twitter.events.TwitterEvent;
   import com.twit.api.twitter.net.TwitterOperation;
   import com.twit.api.twitter.net.UsersOperation;
   import com.twit.api.twitter.oauth.OAuthTwitterConnection;
   import com.twit.api.twitter.oauth.events.OAuthTwitterEvent;
   import flash.desktop.NativeApplication;
   import flash.display.BitmapData;
   import flash.display.PNGEncoderOptions;
   import flash.events.InvokeEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.utils.ByteArray;
   import gudetama.data.DataStorage;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.engine.Engine;
   import gudetama.engine.RsrcManager;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.ui.MessageDialog;
   import org.twit.oauth.OAuthToken;
   import starling.display.Sprite;
   
   public class TwitterManager extends Sprite
   {
      
      private static var _instance:TwitterManager;
       
      
      private var api:TwitterAPI;
      
      private const CONSUMER_KEY:String = GameSetting.def.rule.twitter_Key;
      
      private const CONSUMER_SECRET:String = GameSetting.def.rule.twitter_Secret;
      
      private var twitteruserid:String;
      
      private var twitterScreenName:String;
      
      private var twitterProfileImgPath:String;
      
      private var friendnum:Number = -1;
      
      private var isAuthentic:Boolean = false;
      
      private var accessToken:OAuthToken;
      
      private var callback:Function;
      
      private var frinedcallback:Function;
      
      private var force:Boolean = false;
      
      private var preReload:Boolean = false;
      
      public function TwitterManager()
      {
         api = new TwitterAPI();
         super();
         accessToken = DataStorage.getAccessToken();
         if(accessToken)
         {
            startup();
         }
      }
      
      public static function load(param1:Function = null, param2:Boolean = false, param3:Function = null) : void
      {
         var _frinedcallback:Function = param1;
         var _force:Boolean = param2;
         var _callback:Function = param3;
         Engine.showLoading();
         getInstance().frinedcallback = _frinedcallback;
         getInstance().force = _force;
         getInstance().callback = _callback;
         if(getInstance().isCertify())
         {
            var _loc4_:* = UserDataWrapper;
            if(gudetama.data.UserDataWrapper.wrapper._data.snsTwitterUid)
            {
               if(getInstance().force)
               {
                  getInstance().loadTwitterFriendIds(false);
               }
               else
               {
                  checkReloadTwitterInfo(function(param1:int):void
                  {
                     var choose:int = param1;
                     if(choose == 0)
                     {
                        getInstance().loadMyProfile(true,function():void
                        {
                           getInstance().loadTwitterFriendIds(true);
                        });
                     }
                     else
                     {
                        Engine.hideLoading();
                        if(getInstance().callback)
                        {
                           getInstance().callback(0,2);
                        }
                     }
                  });
               }
            }
            else
            {
               getInstance().loadMyProfile(true,function():void
               {
                  getInstance().loadTwitterFriendIds(true);
               });
            }
         }
         else
         {
            MessageDialog.show(2,GameSetting.getUIText("sns.link.twitter"),function(param1:int):void
            {
               if(param1 == 0)
               {
                  DataStorage.resetRequestToken();
                  getInstance().startAuth();
               }
               else
               {
                  getInstance().frinedcallback(0,null);
               }
            });
         }
      }
      
      public static function loadMyProfileImage(param1:Function = null) : void
      {
         if(param1)
         {
            getInstance().frinedcallback = param1;
         }
         if(getInstance().isCertify())
         {
            getInstance().loadMyProfileImage();
         }
      }
      
      public static function isLinked() : Boolean
      {
         return getInstance().isAuthentic;
      }
      
      public static function sendTweet(param1:String) : void
      {
         if(getInstance().isAuthentic && gudetama.data.UserDataWrapper.wrapper._data.snsTwitterUid)
         {
            getInstance().tweet(param1);
         }
      }
      
      private static function checkReloadTwitterInfo(param1:Function) : void
      {
         var _callback:Function = param1;
         MessageDialog.show(2,GameSetting.getUIText("sns.link.twitter.update"),function(param1:int):void
         {
            _callback(param1);
         });
      }
      
      public static function unlink(param1:Function = null) : void
      {
         getInstance().callback = param1;
         getInstance().unlinkFunction();
      }
      
      public static function getInstance() : TwitterManager
      {
         if(!TwitterManager._instance)
         {
            TwitterManager._instance = new TwitterManager();
         }
         return TwitterManager._instance;
      }
      
      public static function isPreLoading() : Boolean
      {
         if(!TwitterManager._instance)
         {
            return false;
         }
         return TwitterManager._instance.preReload;
      }
      
      private function startup() : void
      {
         isAuthentic = true;
         api.connection.setConsumer(CONSUMER_KEY,CONSUMER_SECRET);
         api.connection.setAccessToken(accessToken.key,accessToken.secret);
         var _loc1_:* = UserDataWrapper;
         twitteruserid = gudetama.data.UserDataWrapper.wrapper._data.snsTwitterUid;
      }
      
      private function isCertify() : Boolean
      {
         return isAuthentic;
      }
      
      public function startAuth() : void
      {
         NativeApplication.nativeApplication.addEventListener("invoke",twitterInvokeEvent);
         api.connection.setConsumer(CONSUMER_KEY,CONSUMER_SECRET);
         api.connection.addEventListener("requestTokenReceived",function(param1:OAuthTwitterEvent):void
         {
            api.connection.removeEventListener("requestTokenReceived",arguments.callee);
            var _loc3_:OAuthToken = api.connection.requestToken;
            DataStorage.setRequestToken(_loc3_.key,_loc3_.secret);
            Engine.hideLoading();
            preReload = true;
            navigateToURL(new URLRequest(api.connection.authorizeURL));
         });
         api.connection.addEventListener("requestTokenError",function(param1:OAuthTwitterEvent):void
         {
            var e:OAuthTwitterEvent = param1;
            api.connection.removeEventListener("requestTokenError",arguments.callee);
            Engine.hideLoading();
            MessageDialog.show(0,GameSetting.getUIText("sns.link.twitter.err"),function(param1:int):void
            {
            });
         });
         var _loc1_:* = Engine;
         var schemeCallbackURL:String = gudetama.engine.Engine.platform == 1 ? GameSetting.getRule().tiwtterSchemeAndroidURL : GameSetting.getRule().tiwtterSchemeIOSURL;
         OAuthTwitterConnection(api.connection).authorize(CONSUMER_KEY,CONSUMER_SECRET,schemeCallbackURL);
      }
      
      private function twitterInvokeEvent(param1:InvokeEvent) : void
      {
         var _loc2_:* = null;
         if(param1.arguments.length > 0 && DataStorage.getRequestToken())
         {
            _loc2_ = DataStorage.getRequestToken();
            DataStorage.resetRequestToken();
            NativeApplication.nativeApplication.removeEventListener("invoke",twitterInvokeEvent);
            setAuth(param1.arguments[0] as String,_loc2_);
         }
      }
      
      private function setAuth(param1:String, param2:OAuthToken) : void
      {
         var param:String = param1;
         var _requestToken:OAuthToken = param2;
         var verifier:String = getVerifier(param);
         if(_requestToken)
         {
            Engine.showLoading();
            api.connection.setConsumer(CONSUMER_KEY,CONSUMER_SECRET);
            OAuthTwitterConnection(api.connection).setRequestToken(_requestToken.key,_requestToken.secret);
            api.connection.addEventListener("authorized",function(param1:OAuthTwitterEvent):void
            {
               var _loc3_:* = null;
               api.connection.removeEventListener("authorized",arguments.callee);
               if(api.connection.hasAccessToken())
               {
                  _loc3_ = api.connection.accessToken;
                  accessToken = new OAuthToken(_loc3_.key,_loc3_.secret);
                  DataStorage.setAccessToken(accessToken);
                  startup();
                  dispatchEvent(new OAuthTwitterEvent("authorized"));
               }
               else
               {
                  api.connection.authorized = false;
               }
            });
            api.connection.addEventListener("authorized",function(param1:OAuthTwitterEvent):void
            {
               api.connection.removeEventListener("authorized",arguments.callee);
               twitteruserid = api.connection.twitterUserId;
               twitterScreenName = api.connection.twitterScreenName;
               loadMyProfile(true);
            });
            api.connection.grantAccess(verifier);
         }
      }
      
      private function getVerifier(param1:String) : String
      {
         var _loc2_:* = null;
         if(param1 == null)
         {
            return null;
         }
         var _loc3_:Array = param1.split("?");
         if(_loc3_.length > 1)
         {
            _loc2_ = _loc3_[1].split("&");
            if(_loc2_.length > 1)
            {
               return _loc2_[1].split("=")[1];
            }
         }
         return null;
      }
      
      private function tweet(param1:String) : void
      {
         var _loc2_:TwitterOperation = new UpdateStatus(param1);
         api.post(_loc2_);
      }
      
      private function loadMyProfile(param1:Boolean, param2:Function = null) : void
      {
         var _updateprofileimg:Boolean = param1;
         var _callback:Function = param2;
         preReload = true;
         if(isAuthentic)
         {
            var op:TwitterOperation = new VerifyCredentials();
            var handler:Function = function(param1:TwitterEvent):void
            {
               var event:TwitterEvent = param1;
               op.removeEventListener("complete",handler);
               if(event.success)
               {
                  var owneruser:TwitterUser = TwitterUser(event.data#2);
                  var myprofilepath:String = owneruser.profileImageUrl#2;
                  var path:String = "twitter/" + owneruser.id#2 + ".png";
                  friendnum = owneruser.friendsCount#2;
                  twitteruserid = owneruser.id#2;
                  if(_updateprofileimg)
                  {
                     GudetamaUtil.registerSnsId(owneruser.id#2,0,myprofilepath,path,function():void
                     {
                        if(frinedcallback)
                        {
                           loadTwitterFriendIds(false);
                        }
                        else if(_callback)
                        {
                           if(_callback)
                           {
                              _callback();
                           }
                        }
                     });
                  }
                  else if(_callback)
                  {
                     _callback();
                  }
                  if(callback)
                  {
                     callback(0,0);
                  }
               }
               else
               {
                  showTwitterErrorDialog();
                  trace("Verification error. Twitter error message: " + event.data#2);
               }
            };
            op.addEventListener("complete",handler);
            api.post(op,"asyncStatic",9);
         }
      }
      
      private function loadMyProfileImage(param1:Function = null) : void
      {
         var _callback:Function = param1;
         if(isAuthentic)
         {
            var op:TwitterOperation = new VerifyCredentials();
            var handler:Function = function(param1:TwitterEvent):void
            {
               var _loc2_:* = null;
               var _loc3_:* = null;
               op.removeEventListener("complete",handler);
               if(param1.success)
               {
                  _loc2_ = TwitterUser(param1.data#2);
                  _loc3_ = _loc2_.profileImageUrl#2;
                  loadProfileImage(_loc2_.id#2,_loc3_,_callback);
               }
               else
               {
                  showTwitterErrorDialog();
                  trace("Verification error. Twitter error message: " + param1.data#2);
               }
            };
            op.addEventListener("complete",handler);
            api.post(op,"asyncStatic",9);
         }
      }
      
      public function loadTwitterFriendIds(param1:Boolean) : void
      {
         var _force:Boolean = param1;
         if(isAuthentic)
         {
            if(!_force)
            {
               var localtwitterids:Array = DataStorage.getLocalData().getTwitterUids();
               if(localtwitterids != null && localtwitterids.length > 0)
               {
                  if(frinedcallback)
                  {
                     frinedcallback(0,localtwitterids);
                     frinedcallback = null;
                     return;
                  }
               }
            }
            var op:UsersOperation = new LoadFriendsInfo(twitteruserid,null);
            var handler:Function = function(param1:TwitterEvent):void
            {
               var _loc5_:* = null;
               var _loc2_:int = 0;
               var _loc3_:* = null;
               var _loc6_:* = null;
               var _loc4_:int = 0;
               var _loc7_:* = null;
               op.removeEventListener("complete",handler);
               if(param1.success)
               {
                  _loc2_ = (_loc5_ = param1.data#2).length;
                  _loc3_ = [];
                  while(_loc4_ < _loc2_)
                  {
                     _loc7_ = _loc5_[_loc4_];
                     _loc3_.push(_loc7_.id#2);
                     if(!_loc6_)
                     {
                        _loc6_ = {};
                     }
                     _loc6_[_loc7_.id#2] = _loc7_.name#2;
                     _loc4_++;
                  }
                  if(_loc6_)
                  {
                     DataStorage.getLocalData().setTwitterNameMap(_loc6_);
                  }
                  if(frinedcallback)
                  {
                     frinedcallback(0,_loc3_);
                     frinedcallback = null;
                  }
               }
               else
               {
                  showTwitterErrorDialog();
                  trace("loadTwitterFollowerInfo. Twitter error message: " + param1.data#2);
               }
            };
            op.addEventListener("complete",handler);
            api.post(op,"asyncStatic",9);
         }
      }
      
      private function loadProfileImage(param1:String, param2:String, param3:Function = null) : void
      {
         var _ownerid:String = param1;
         var _imgurl:String = param2;
         var _callback:Function = param3;
         if(isAuthentic)
         {
            var path:String = "twitter/" + _ownerid + ".png";
            RsrcManager.loadImageDirectly(_imgurl,path,function(param1:BitmapData):void
            {
               var _loc2_:ByteArray = new ByteArray();
               param1.encode(param1.rect,new PNGEncoderOptions(),_loc2_);
               DataStorage.getLocalData().setSnsImageByteArray(0,_loc2_,true,_callback);
            });
         }
      }
      
      private function showTwitterErrorDialog(param1:int = 1) : void
      {
         var _errortype:int = param1;
         Engine.hideLoading();
         MessageDialog.show(0,GameSetting.getUIText("sns.link.twitter.error." + _errortype),function(param1:int):void
         {
         });
      }
      
      private function unlinkFunction() : void
      {
         var _loc1_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(225,0),function(param1:Array):void
         {
            var _loc2_:int = 0;
            if(param1 != null)
            {
               _loc2_ = param1[0];
               var _loc3_:* = UserDataWrapper;
               gudetama.data.UserDataWrapper.wrapper._data.snsTwitterUid = null;
               isAuthentic = false;
               twitteruserid = null;
               DataStorage.resetTwitterToken();
               DataStorage.getLocalData().resetSnsTwitterLink();
               api.connection.authorized = false;
               api.connection.resetOAuthParam();
               if(_loc2_ == 1)
               {
                  var _loc4_:* = UserDataWrapper;
                  gudetama.data.UserDataWrapper.wrapper._data.snsInterlockType = -1;
               }
               if(callback)
               {
                  callback(0,-1);
               }
            }
            Engine.hideLoading();
         });
      }
   }
}
