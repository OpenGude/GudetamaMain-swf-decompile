package gudetama.data
{
   import flash.net.registerClassAlias;
   import flash.system.Capabilities;
   import gudetama.common.GudetamaUtil;
   import gudetama.common.PushNotificationManager;
   import gudetama.engine.Engine;
   import gudetama.engine.LoadingDialog;
   import gudetama.engine.Logger;
   import gudetama.net.HttpConnector;
   import gudetama.util.SharedObjectWrapper;
   import org.twit.oauth.OAuthToken;
   
   public class DataStorage
   {
      
      private static var localData:LocalData;
      
      private static var bindName:String = "gudetama_storage";
      
      private static var uiid:String;
      
      private static var uiidBindName:String = "gudetama_uiid";
      
      private static var lastConnectedServletHost:String;
      
      private static var lastConnectedServletHostBindName:String = "gudetama_lasthost";
      
      private static var twitterTokenBindName:String = "twitter_token";
      
      private static var accessToken:OAuthToken;
      
      private static var requestToken:OAuthToken;
      
      private static var userBlockBindName:String = "gudetama_block";
       
      
      public function DataStorage()
      {
         super();
      }
      
      public static function init(param1:Function) : void
      {
         var _loc5_:* = null;
         var _loc6_:* = null;
         if(uiid != null)
         {
            param1(true);
            return;
         }
         registerClassAlias("LocalData",LocalData);
         registerClassAlias("LocalUserBlockData",LocalUserBlockData);
         var _loc2_:SharedObjectWrapper = new SharedObjectWrapper();
         if(_loc2_.bind(lastConnectedServletHostBindName))
         {
            lastConnectedServletHost = _loc2_.data#2.lastConnectedServletHost;
            if(!null && lastConnectedServletHost)
            {
               var _loc7_:* = HttpConnector;
               if(gudetama.net.HttpConnector.mainConnector == null)
               {
                  gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
               }
               gudetama.net.HttpConnector.mainConnector.setServletHost(lastConnectedServletHost);
            }
         }
         else
         {
            Logger.warn("[DataStorage] can\'t bind SharedObject!! " + lastConnectedServletHostBindName);
         }
         var _loc4_:SharedObjectWrapper;
         if((_loc4_ = new SharedObjectWrapper()).bind(uiidBindName))
         {
            uiid = _loc4_.data#2.uiid;
            _loc4_.close();
            var _loc3_:SharedObjectWrapper = new SharedObjectWrapper();
            if(_loc3_.bind(twitterTokenBindName))
            {
               _loc5_ = _loc3_.data#2.accessTokenkey;
               _loc6_ = _loc3_.data#2.accessTokensecret;
               if(_loc5_ && _loc6_)
               {
                  accessToken = new OAuthToken(_loc5_,_loc6_);
               }
            }
            else
            {
               Logger.warn("[DataStorage] twitter token can\'t bind SharedObject!! " + twitterTokenBindName);
            }
            if(!isValidUiid())
            {
               uiid = null;
               generateAndSetUiid(param1);
            }
            else
            {
               param1(true);
            }
            return;
         }
         throw new StorageError("[DataStorage] UIID can\'t bind SharedObject!! " + uiidBindName);
      }
      
      public static function generateAndSetUiid(param1:Function, param2:int = 4) : void
      {
         var callback:Function = param1;
         var retryMax:int = param2;
         var _loc3_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.generateUiid(function(param1:String):void
         {
            var result:String = param1;
            if(result == null)
            {
               callback(false);
               return;
            }
            uiid = result;
            var uiidStorage:SharedObjectWrapper = new SharedObjectWrapper();
            uiidStorage.bind(uiidBindName);
            uiidStorage.data#2.uiid = uiid;
            uiidStorage.close(0,function():void
            {
               Logger.info("[DataStorage] uiid saved: " + uiid);
            });
            callback(true);
         },retryMax);
      }
      
      public static function setAccessToken(param1:OAuthToken) : void
      {
         var _accessToken:OAuthToken = param1;
         var twitterStorage:SharedObjectWrapper = new SharedObjectWrapper();
         twitterStorage.bind(twitterTokenBindName);
         twitterStorage.data#2.accessTokenkey = _accessToken.key;
         twitterStorage.data#2.accessTokensecret = _accessToken.secret;
         twitterStorage.close(0,function():void
         {
            Logger.info("[DataStorage] accessToken saved: " + _accessToken);
         });
         accessToken = _accessToken;
      }
      
      public static function resetTwitterToken() : void
      {
         var twitterStorage:SharedObjectWrapper = new SharedObjectWrapper();
         twitterStorage.bind(twitterTokenBindName);
         twitterStorage.data#2.accessTokenkey = null;
         twitterStorage.data#2.accessTokensecret = null;
         twitterStorage.close(0,function():void
         {
            Logger.info("[DataStorage] accessToken reset");
         });
         accessToken = null;
         requestToken = null;
      }
      
      public static function getAccessToken() : OAuthToken
      {
         return accessToken;
      }
      
      public static function setRequestToken(param1:String, param2:String) : void
      {
         var _loc3_:OAuthToken = new OAuthToken(param1,param2);
         requestToken = _loc3_;
      }
      
      public static function getRequestToken() : OAuthToken
      {
         return requestToken;
      }
      
      public static function resetRequestToken() : void
      {
         requestToken = null;
      }
      
      public static function loadLocalData() : void
      {
         var _loc1_:* = null;
         var _loc2_:SharedObjectWrapper = new SharedObjectWrapper();
         if(_loc2_.bind(bindName))
         {
            if(!_loc2_.data#2.localData)
            {
               localData = new LocalData();
            }
            else
            {
               localData = _loc2_.data#2.localData;
            }
         }
         else
         {
            localData = new LocalData();
            Logger.warn("DataStorage can\'t load " + bindName);
         }
         localData.restorationSnsImageByByteArray();
         var _loc3_:String = localData.getLocale();
         if(_loc3_ == "")
         {
            _loc1_ = Capabilities.language#2;
            if(_loc1_ == "xu" || _loc1_ == "xv")
            {
               _loc1_ = Capabilities.languages[0];
            }
            _loc3_ = GudetamaUtil.getEnableLocal(_loc1_);
            localData.needSelectLocale = true;
         }
         else
         {
            _loc3_ = GudetamaUtil.getEnableLocal(_loc3_);
            localData.setLocale(_loc3_);
            localData.needSelectLocale = false;
         }
         Engine.setLocale(_loc3_);
         if(_loc3_ != "ja")
         {
            LoadingDialog.resetLoadingText();
            if(localData.needSelectLocale)
            {
               localData.setNeedDownloadFirstRsrc(true);
            }
         }
      }
      
      public static function saveLocalData(param1:Function = null) : Boolean
      {
         var callback:Function = param1;
         if(uiid == null)
         {
            return false;
         }
         var storage:SharedObjectWrapper = new SharedObjectWrapper();
         if(storage.bind(bindName))
         {
            storage.data#2.localData = localData;
            storage.close(0,function(param1:Boolean):void
            {
               Logger.debug("save completed " + bindName);
               if(callback)
               {
                  callback(param1);
               }
            });
            return true;
         }
         localData = new LocalData();
         return false;
      }
      
      public static function resetLocalData() : void
      {
         var _loc1_:SharedObjectWrapper = new SharedObjectWrapper();
         if(_loc1_.bind(bindName))
         {
            _loc1_.erase();
         }
      }
      
      public static function getLocalData() : LocalData
      {
         return localData;
      }
      
      public static function RSHash(param1:String) : uint
      {
         var _loc4_:int = 0;
         var _loc3_:int = 378551;
         var _loc2_:* = 63689;
         var _loc5_:uint = 0;
         _loc4_ = 0;
         while(_loc4_ < param1.length)
         {
            _loc5_ = _loc5_ * _loc2_ + uint(param1.charCodeAt(_loc4_));
            _loc2_ *= _loc3_;
            _loc4_++;
         }
         return _loc5_;
      }
      
      public static function getHashId() : uint
      {
         return 2235824828 ^ RSHash(uiid);
      }
      
      public static function getUiid() : String
      {
         return uiid;
      }
      
      public static function isValidUiid(param1:String = null) : Boolean
      {
         if(param1 == null)
         {
            param1 = uiid;
         }
         if(!param1)
         {
            return false;
         }
         if(param1 == "000000000000000000000000000000000000" || param1.length != 36)
         {
            Logger.warn("uiid is invalid",param1);
            return false;
         }
         return true;
      }
      
      public static function setUiidForDebug(param1:String) : String
      {
         var str:String = param1;
         var newUiid:String = (String(str + "000000000000000000000000000000000000")).slice(0,36);
         if(uiid == newUiid)
         {
            return uiid;
         }
         uiid = newUiid;
         var storage:SharedObjectWrapper = new SharedObjectWrapper();
         storage.bind(uiidBindName);
         storage.data#2.uiid = uiid;
         storage.close(0,function():void
         {
            Logger.debug("[DataStorage] uiid saved: " + uiid);
         });
         localData.reset();
         resetUserBlockData();
         return uiid;
      }
      
      public static function changeUiidByTakeover(param1:String) : void
      {
         var newUiid:String = param1;
         var storage:SharedObjectWrapper = new SharedObjectWrapper();
         storage.bind(uiidBindName);
         storage.data#2.lastUiid = uiid;
         storage.data#2.uiid = newUiid;
         storage.close(0,function():void
         {
            Logger.info("[DataStorage] uiid saved: " + newUiid);
         });
         uiid = newUiid;
         localData.reset();
         saveLocalData();
         if(PushNotificationManager.isSupport())
         {
            PushNotificationManager.resetPushToken();
         }
         resetUserBlockData();
      }
      
      public static function getLastConnectedServletHost() : String
      {
         return lastConnectedServletHost;
      }
      
      public static function setLastConnectedServletHost(param1:String) : void
      {
         var host:String = param1;
         if(lastConnectedServletHost == host)
         {
            return;
         }
         var storage:SharedObjectWrapper = new SharedObjectWrapper();
         storage.bind(lastConnectedServletHostBindName);
         storage.data#2.lastConnectedServletHost = host;
         storage.close(0,function():void
         {
            Logger.info("[DataStorage] lastConnectedServletHost saved: ",lastConnectedServletHost,"->",host);
            lastConnectedServletHost = host;
         });
      }
      
      public static function loadUserBlockData() : LocalUserBlockData
      {
         var _loc1_:SharedObjectWrapper = new SharedObjectWrapper();
         if(_loc1_.bind(userBlockBindName))
         {
            if(!_loc1_.data#2.blockData)
            {
               return new LocalUserBlockData();
            }
            return _loc1_.data#2.blockData;
         }
         Logger.warn("DataStorage can\'t load " + userBlockBindName);
         return new LocalUserBlockData();
      }
      
      public static function saveUserBlockData(param1:LocalUserBlockData) : void
      {
         var blockData:LocalUserBlockData = param1;
         var storage:SharedObjectWrapper = new SharedObjectWrapper();
         if(storage.bind(userBlockBindName))
         {
            storage.data#2.blockData = blockData;
            storage.close(0,function(param1:Boolean):void
            {
               Logger.debug("save completed " + userBlockBindName);
            });
         }
         else
         {
            Logger.warn("save failed " + userBlockBindName);
         }
      }
      
      private static function resetUserBlockData() : void
      {
         var _loc1_:LocalUserBlockData = loadUserBlockData();
         _loc1_.reset();
      }
   }
}
