package gudetama.data
{
   import flash.display.BitmapData;
   import flash.display.Loader;
   import flash.errors.IOError;
   import flash.events.Event;
   import flash.utils.ByteArray;
   import flash.utils.IDataInput;
   import flash.utils.IDataOutput;
   import flash.utils.IExternalizable;
   import gudetama.common.NativeExtensions;
   import gudetama.engine.Engine;
   import gudetama.util.TimeZoneUtil;
   import starling.textures.Texture;
   
   public class LocalData implements IExternalizable
   {
      
      private static const VERSION:uint = 4;
       
      
      public var tutorialMode:Boolean = true;
      
      public var friendKey:String = "";
      
      public var pushToken:String = "";
      
      public var playerName:String = "";
      
      public var gender:int;
      
      private var receiptsMap:Object;
      
      private var receivedMailList:Array;
      
      private var sentMailList:Array;
      
      private var locale:String = "";
      
      private var appsFlyerUid:String = "";
      
      public var musicVolume:Number = 1.0;
      
      public var effectVolume:Number = 1.0;
      
      public var voiceVolume:Number = 1.0;
      
      private var receivedOperatorMessageMap:Object;
      
      private var noUseSoundPool:Boolean;
      
      public var pendingNums:Vector.<int>;
      
      public var isTouchStarted:Boolean;
      
      public var touchNumForEvent:int;
      
      public var pendingBonusValues:int;
      
      private var pendingFriendEncodedUid:int;
      
      private var pendingFriendPresentMoney:int;
      
      private var videoAdsCompanyList:Array;
      
      private var videoAdsRate:Object;
      
      private var bannerAdsCompanyList:Array;
      
      private var bannerAdsRate:Object;
      
      private var bannerAdsTimeRate:Array;
      
      private var interstitialAdsCompanyList:Array;
      
      private var interstitialAdsRate:Object;
      
      private var priorityVideoAdsCompanyList:Array;
      
      private var snsProfileByteArrayImages:Object;
      
      private var snsProfileImageTextures:Object;
      
      private var snsTwitterFriendUids:Array;
      
      private var snsFacebookFriendUids:Array;
      
      private var snsTwitterFriendNameMap:Object;
      
      private var snsFacebookFriendNameMap:Object;
      
      private var requestedFirstStoragePermission:Boolean;
      
      private var requestedFirstPermissionAR:Boolean;
      
      private var arMode:Boolean = true;
      
      private var needDownloadFirstRsrc:Boolean = false;
      
      private var interstitialIntervalSecs:int;
      
      private var tempBitFlag:int = 0;
      
      public var tempIdfv:String = "";
      
      public var showedPriorityVideoCount:int = 0;
      
      public var lastedShowPriorityVideoDate:Date;
      
      private var friendSortType:int = 0;
      
      public var videoAdRewardUpdateTimeSecs:int;
      
      private var tmpStampMap:Array;
      
      private var helperIndex:int = -1;
      
      public function LocalData()
      {
         receiptsMap = {};
         receivedMailList = [];
         sentMailList = [];
         receivedOperatorMessageMap = {};
         pendingNums = new Vector.<int>();
         snsProfileByteArrayImages = {};
         snsProfileImageTextures = {};
         snsTwitterFriendUids = [];
         snsFacebookFriendUids = [];
         snsTwitterFriendNameMap = {};
         snsFacebookFriendNameMap = {};
         super();
      }
      
      public function reset(param1:Boolean = true) : void
      {
         receiptsMap = {};
         receivedOperatorMessageMap = {};
         receivedMailList = [];
         sentMailList = [];
         if(param1)
         {
            locale = "";
         }
         appsFlyerUid = "";
         snsProfileByteArrayImages = {};
         snsProfileImageTextures = {};
         snsTwitterFriendUids = [];
         snsFacebookFriendUids = [];
         snsTwitterFriendNameMap = {};
         snsFacebookFriendNameMap = {};
         arMode = true;
         requestedFirstPermissionAR = false;
         requestedFirstStoragePermission = false;
         tmpStampMap = null;
      }
      
      public function addReceipt(param1:int, param2:String) : void
      {
         var _loc4_:Array;
         if((_loc4_ = receiptsMap[param1]) == null)
         {
            _loc4_ = [];
         }
         var _loc5_:Boolean = false;
         for each(var _loc3_ in _loc4_)
         {
            if(_loc3_ === param2)
            {
               _loc5_ = true;
               break;
            }
         }
         if(_loc5_)
         {
            return;
         }
         _loc4_.push(param2);
         receiptsMap[param1] = _loc4_;
      }
      
      public function getOldestReceipt(param1:int) : String
      {
         var _loc2_:Array = receiptsMap[param1];
         if(_loc2_ == null)
         {
            return null;
         }
         return _loc2_[0];
      }
      
      public function shiftReceipt(param1:int) : String
      {
         var _loc2_:Array = receiptsMap[param1];
         if(_loc2_ == null)
         {
            return null;
         }
         var _loc3_:String = _loc2_.shift();
         receiptsMap[param1] = _loc2_;
         return _loc3_;
      }
      
      public function removeReceipt(param1:int, param2:String) : void
      {
         var _loc5_:int = 0;
         var _loc4_:Array;
         if((_loc4_ = receiptsMap[param1]) == null)
         {
            return;
         }
         var _loc3_:int = _loc4_.length;
         _loc5_ = 0;
         while(_loc5_ < _loc3_)
         {
            if(_loc4_[_loc5_] == param2)
            {
               _loc4_.splice(_loc5_,1);
               break;
            }
            _loc5_++;
         }
         receiptsMap[param1] = _loc4_;
      }
      
      public function existsReceiptDate(param1:int, param2:String) : Boolean
      {
         var _loc5_:int = 0;
         var _loc4_:Array;
         if((_loc4_ = receiptsMap[param1]) == null)
         {
            return false;
         }
         var _loc3_:int = _loc4_.length;
         _loc5_ = 0;
         while(_loc5_ < _loc3_)
         {
            if(_loc4_[_loc5_] == param2)
            {
               return true;
            }
            _loc5_++;
         }
         return false;
      }
      
      public function existsReceipt(param1:int) : Boolean
      {
         var _loc2_:Array = receiptsMap[param1];
         if(_loc2_ == null)
         {
            return false;
         }
         return _loc2_.length > 0;
      }
      
      public function addOperatorMessageData(param1:int, param2:LocalMessageData) : void
      {
         if(receivedOperatorMessageMap != null && receivedOperatorMessageMap[param1])
         {
            return;
         }
         receivedOperatorMessageMap[param1] = param2;
      }
      
      public function removeOperatorMessageData(param1:int) : void
      {
         if(receivedOperatorMessageMap != null)
         {
            delete receivedOperatorMessageMap[param1];
         }
      }
      
      public function getOperatorMessageMap() : Object
      {
         var _loc2_:* = null;
         var _loc1_:Object = {};
         for(var _loc3_ in receivedOperatorMessageMap)
         {
            _loc2_ = receivedOperatorMessageMap[_loc3_] as LocalMessageData;
            if(_loc2_.type == 4 && _loc2_.sender == 0)
            {
               _loc1_[_loc3_] = _loc2_;
            }
         }
         return _loc1_;
      }
      
      public function deleteOperatorMessageData() : void
      {
         receivedOperatorMessageMap = {};
      }
      
      public function addLocalMailData(param1:LocalMailData) : void
      {
         var _loc2_:int = 0;
         if(receivedMailList != null)
         {
            _loc2_ = 0;
            while(_loc2_ < receivedMailList.length)
            {
               if(receivedMailList[_loc2_].uniqueKey == param1.uniqueKey)
               {
                  return;
               }
               _loc2_++;
            }
         }
         receivedMailList.push(param1);
      }
      
      public function removeLocalMailData(param1:int) : void
      {
         var _loc2_:int = 0;
         if(receivedMailList != null)
         {
            _loc2_ = 0;
            while(_loc2_ < receivedMailList.length)
            {
               if(receivedMailList[_loc2_].uniqueKey == param1)
               {
                  receivedMailList.splice(_loc2_,1);
                  break;
               }
               _loc2_++;
            }
         }
      }
      
      public function replyLocalMailData(param1:int) : void
      {
         var _loc2_:int = 0;
         if(receivedMailList != null)
         {
            _loc2_ = 0;
            while(_loc2_ < receivedMailList.length)
            {
               if(receivedMailList[_loc2_].uniqueKey == param1)
               {
                  receivedMailList[_loc2_].send();
                  break;
               }
               _loc2_++;
            }
         }
      }
      
      public function getLocalMailData() : Array
      {
         return receivedMailList;
      }
      
      public function deleteLocalMailData() : void
      {
         receivedMailList = null;
         receivedMailList = [];
      }
      
      public function addMyMailToLocalData(param1:int, param2:String, param3:String, param4:* = false) : void
      {
         var _loc5_:LocalSentMailData;
         (_loc5_ = new LocalSentMailData()).setMailData(param1,param2,param3,param4);
         addMyLocalMailData(_loc5_);
      }
      
      public function addMyLocalMailData(param1:LocalSentMailData) : void
      {
         sentMailList.push(param1);
      }
      
      public function getMyLocalMailData() : Array
      {
         return sentMailList;
      }
      
      public function getMySentMailByUniqukey(param1:int) : Array
      {
         var _loc2_:int = 0;
         var _loc4_:* = null;
         var _loc3_:int = 0;
         if(sentMailList.length > 0)
         {
            _loc2_ = sentMailList.length;
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               if(sentMailList[_loc3_].receivedMailUKey == param1)
               {
                  if(_loc4_ == null)
                  {
                     _loc4_ = [];
                  }
                  _loc4_.push(sentMailList[_loc3_]);
               }
               _loc3_++;
            }
            return _loc4_;
         }
         return null;
      }
      
      public function setPushToken(param1:String) : void
      {
         pushToken = param1 == null ? "" : param1;
      }
      
      public function checkSamePushToken(param1:String) : Boolean
      {
         return pushToken == param1;
      }
      
      public function getPushToken() : String
      {
         return pushToken;
      }
      
      public function getLocale() : String
      {
         return locale;
      }
      
      public function setLocale(param1:String) : void
      {
         locale = param1;
      }
      
      public function setAppsFlyerUid(param1:String) : void
      {
         appsFlyerUid = param1 == null ? "" : param1;
      }
      
      public function getAppsFlyerUid() : String
      {
         return appsFlyerUid;
      }
      
      public function setNoUseSoundPool(param1:Boolean) : void
      {
         noUseSoundPool = param1;
      }
      
      public function isUseSoundPool() : Boolean
      {
         return !noUseSoundPool;
      }
      
      public function incrementPendingNum(param1:int) : void
      {
         if(param1 >= pendingNums.length)
         {
            pendingNums.length = param1 + 1;
         }
         pendingNums[param1]++;
         isTouchStarted = true;
      }
      
      public function incrementTouchNumForEvent() : void
      {
         touchNumForEvent++;
      }
      
      public function existsPendingNum() : Boolean
      {
         if(!UserDataWrapper.isInitialized())
         {
            return false;
         }
         for each(var _loc1_ in pendingNums)
         {
            if(_loc1_ > 0)
            {
               return true;
            }
         }
         return false;
      }
      
      public function popPendingNums() : Vector.<int>
      {
         if(!UserDataWrapper.isInitialized())
         {
            return null;
         }
         var _loc1_:Vector.<int> = pendingNums;
         pendingNums = new Vector.<int>(_loc1_.length);
         touchNumForEvent = 0;
         DataStorage.saveLocalData();
         return _loc1_;
      }
      
      public function getPendingNum(param1:int) : int
      {
         if(param1 >= pendingNums.length)
         {
            return 0;
         }
         return pendingNums[param1];
      }
      
      public function getTouchNumForEvent() : int
      {
         return touchNumForEvent;
      }
      
      public function addPendingBonusValue(param1:int) : void
      {
         pendingBonusValues += param1;
      }
      
      public function popPendingBonusValues() : int
      {
         if(!UserDataWrapper.isInitialized())
         {
            return 0;
         }
         var _loc1_:int = pendingBonusValues;
         pendingBonusValues = 0;
         DataStorage.saveLocalData();
         return _loc1_;
      }
      
      public function incrementPendingFriendTouchEventCount(param1:int, param2:int) : void
      {
         if(param2 <= 0)
         {
            return;
         }
         if(pendingFriendEncodedUid > 0 && param1 != pendingFriendEncodedUid)
         {
            pendingFriendEncodedUid = 0;
            pendingFriendPresentMoney = 0;
         }
         if(pendingFriendEncodedUid <= 0)
         {
            pendingFriendEncodedUid = param1;
         }
         pendingFriendPresentMoney += param2;
      }
      
      public function popPendingFriendTouchEventCounts() : Array
      {
         var _loc2_:int = pendingFriendEncodedUid;
         if(_loc2_ <= 0)
         {
            return null;
         }
         var _loc1_:int = pendingFriendPresentMoney;
         if(_loc1_ <= 0)
         {
            return null;
         }
         pendingFriendEncodedUid = 0;
         pendingFriendPresentMoney = 0;
         DataStorage.saveLocalData();
         return [_loc2_,_loc1_];
      }
      
      public function setInterstitialAdsRate(param1:String) : void
      {
         var _loc5_:int = 0;
         var _loc3_:* = null;
         var _loc4_:Array;
         var _loc2_:int = (_loc4_ = param1.split(",")).length;
         _loc5_ = 0;
         while(_loc5_ < _loc2_)
         {
            _loc3_ = _loc4_[_loc5_].split(":");
            if(!interstitialAdsRate)
            {
               interstitialAdsRate = {};
            }
            interstitialAdsRate[_loc3_[0]] = _loc3_[1];
            if(!interstitialAdsCompanyList)
            {
               interstitialAdsCompanyList = [];
            }
            interstitialAdsCompanyList[_loc5_] = _loc3_[0];
            _loc5_++;
         }
      }
      
      public function getInterstitialAdsList() : Array
      {
         return interstitialAdsCompanyList;
      }
      
      public function getInterstitialAdsRate(param1:String) : int
      {
         if(!interstitialAdsRate)
         {
            return 0;
         }
         trace("getInterstitialAdsRate : " + interstitialAdsRate[param1]);
         return interstitialAdsRate[param1];
      }
      
      public function setBannerAdsRate(param1:String) : void
      {
         var _loc5_:int = 0;
         var _loc4_:* = null;
         var _loc6_:* = 0;
         trace("setBannerAdsRate : " + param1);
         var _loc7_:Array;
         var _loc3_:int = (_loc7_ = param1.split(",")).length;
         var _loc2_:int = GameSetting.getRule().bannerCircleSec;
         bannerAdsTimeRate = null;
         _loc5_ = 0;
         while(_loc5_ < _loc3_)
         {
            _loc4_ = _loc7_[_loc5_].split(":");
            if(!bannerAdsRate)
            {
               bannerAdsRate = {};
            }
            bannerAdsRate[_loc4_[0]] = _loc4_[1];
            if(!bannerAdsCompanyList)
            {
               bannerAdsCompanyList = [];
            }
            bannerAdsCompanyList[_loc5_] = _loc4_[0];
            if(!bannerAdsTimeRate)
            {
               bannerAdsTimeRate = [];
            }
            bannerAdsTimeRate.push({
               "company":_loc4_[0],
               "rate":_loc2_ * _loc4_[1] / 100
            });
            _loc5_++;
         }
         bannerAdsTimeRate.sortOn(["rate","company"],[2 | 16,null]);
         _loc6_ = uint(0);
         while(_loc6_ < bannerAdsTimeRate.length)
         {
            trace(bannerAdsTimeRate[_loc6_].company + ", " + bannerAdsTimeRate[_loc6_].rate);
            _loc6_++;
         }
      }
      
      public function getBannerAdsList() : Array
      {
         return bannerAdsCompanyList;
      }
      
      public function getBannerAdsRate(param1:String) : int
      {
         if(!isEnableBanner(param1))
         {
            return 0;
         }
         if(!bannerAdsRate)
         {
            return 0;
         }
         return bannerAdsRate[param1];
      }
      
      public function isEnableBanner(param1:String) : Boolean
      {
         return NativeExtensions.isEnableBannerByPlatformVersion(param1);
      }
      
      public function getBannerAdsTimeRate() : Array
      {
         return bannerAdsTimeRate;
      }
      
      public function getbannerAdsTimeCompanyRate(param1:String) : int
      {
         var _loc2_:* = 0;
         if(!bannerAdsTimeRate)
         {
            return 0;
         }
         _loc2_ = uint(0);
         while(_loc2_ < bannerAdsTimeRate.length)
         {
            if(bannerAdsTimeRate[_loc2_].company == param1)
            {
               return bannerAdsTimeRate[_loc2_].rate;
            }
            _loc2_++;
         }
         return 0;
      }
      
      public function setVideoAdsRate(param1:String) : void
      {
         var _loc5_:int = 0;
         var _loc4_:* = null;
         trace("setVideoAdsRate : " + param1);
         var _loc3_:Array = param1.split(",");
         var _loc2_:int = _loc3_.length;
         _loc5_ = 0;
         while(_loc5_ < _loc2_)
         {
            _loc4_ = _loc3_[_loc5_].split(":");
            if(!videoAdsRate)
            {
               videoAdsRate = {};
            }
            videoAdsRate[_loc4_[0]] = _loc4_[1];
            if(!videoAdsCompanyList)
            {
               videoAdsCompanyList = [];
            }
            videoAdsCompanyList[_loc5_] = _loc4_[0];
            _loc5_++;
         }
      }
      
      public function getVideoAdsList() : Array
      {
         return videoAdsCompanyList;
      }
      
      public function getVideoAdsRate(param1:String) : int
      {
         if(!videoAdsRate)
         {
            return 0;
         }
         return videoAdsRate[param1];
      }
      
      public function setPriorityvideoAdsCompanyList(param1:String) : void
      {
         var _loc4_:int = 0;
         trace("setPriorityvideoAdsCompanyList : " + param1);
         var _loc3_:Array = param1.split(",");
         var _loc2_:int = _loc3_.length;
         _loc4_ = 0;
         while(_loc4_ < _loc2_)
         {
            if(!priorityVideoAdsCompanyList)
            {
               priorityVideoAdsCompanyList = [];
            }
            priorityVideoAdsCompanyList[_loc4_] = _loc3_[_loc4_];
            _loc4_++;
         }
      }
      
      public function getPriorityvideoAdsCompanyList() : Array
      {
         return priorityVideoAdsCompanyList;
      }
      
      public function get needSelectLocale() : Boolean
      {
         return (tempBitFlag & 1) > 0;
      }
      
      public function set needSelectLocale(param1:Boolean) : void
      {
         if(param1)
         {
            tempBitFlag |= 1;
         }
         else
         {
            tempBitFlag &= -2;
         }
      }
      
      public function setSnsImageByteArray(param1:int, param2:ByteArray, param3:Boolean, param4:Function = null) : void
      {
         var _snstype:int = param1;
         var _bytearray:ByteArray = param2;
         var _save:Boolean = param3;
         var _callback:Function = param4;
         if(!_bytearray)
         {
            return;
         }
         snsProfileByteArrayImages[_snstype] = _bytearray;
         var loader:Loader = new Loader();
         loader.contentLoaderInfo.addEventListener("complete",function(param1:Event):void
         {
            var _loc2_:BitmapData = new BitmapData(loader.width,loader.height);
            _loc2_.draw(loader);
            snsProfileImageTextures[_snstype] = Texture.fromBitmapData(_loc2_);
            if(_save)
            {
               DataStorage.saveLocalData();
            }
            if(_callback)
            {
               _callback(snsProfileImageTextures[_snstype]);
            }
         });
         loader.loadBytes(_bytearray);
      }
      
      public function getSnsImageByteArray(param1:int) : ByteArray
      {
         if(param1 == -1)
         {
            return null;
         }
         return snsProfileByteArrayImages[param1];
      }
      
      public function getSnsImageTexture(param1:int) : Texture
      {
         if(param1 == -1)
         {
            return null;
         }
         return snsProfileImageTextures[param1];
      }
      
      public function restorationSnsImageByByteArray() : void
      {
         if(snsProfileByteArrayImages)
         {
            for(var _loc1_ in snsProfileByteArrayImages)
            {
               setSnsImageByteArray(_loc1_,snsProfileByteArrayImages[_loc1_],false);
            }
         }
      }
      
      public function getAllSnsImageTexture() : Object
      {
         return snsProfileImageTextures;
      }
      
      public function getTwitterUids() : Array
      {
         return snsTwitterFriendUids;
      }
      
      public function setSnsTwitterUids(param1:Array) : void
      {
         if(!param1)
         {
            return;
         }
         snsTwitterFriendUids = param1;
      }
      
      public function addSnsTwitterUid(param1:String) : void
      {
         if(!param1)
         {
            return;
         }
         snsTwitterFriendUids.push(param1);
      }
      
      public function setTwitterNameMap(param1:Object) : void
      {
         if(!param1)
         {
            return;
         }
         snsTwitterFriendNameMap = param1;
      }
      
      public function getTwitterName(param1:String) : String
      {
         return snsTwitterFriendNameMap[param1];
      }
      
      public function resetSnsTwitterLink() : void
      {
         snsTwitterFriendUids = [];
         snsTwitterFriendNameMap = {};
      }
      
      public function getSnsFacebookUids() : Array
      {
         return snsFacebookFriendUids;
      }
      
      public function setSnsFacebookUids(param1:Array) : void
      {
         if(!param1)
         {
            return;
         }
         snsFacebookFriendUids = param1;
      }
      
      public function addSnsFacebookUid(param1:String) : void
      {
         if(!param1)
         {
            return;
         }
         snsFacebookFriendUids.push(param1);
      }
      
      public function setFacebookFriendNameMap(param1:Object) : void
      {
         if(!param1)
         {
            return;
         }
         snsFacebookFriendNameMap = param1;
      }
      
      public function getFacebookName(param1:String) : String
      {
         return snsFacebookFriendNameMap[param1];
      }
      
      public function resetFacebookLink() : void
      {
         snsFacebookFriendUids = [];
         snsFacebookFriendNameMap = {};
      }
      
      public function getInterstitialIntervalSecs() : int
      {
         return interstitialIntervalSecs;
      }
      
      public function setInterstitialIntervalSecs(param1:int) : void
      {
         interstitialIntervalSecs = param1;
      }
      
      public function setRequestedARPermissions(param1:Boolean) : void
      {
         requestedFirstPermissionAR = param1;
      }
      
      public function isRequestedFirstARPermissions() : Boolean
      {
         return requestedFirstPermissionAR && gudetama.engine.Engine.platform == 1;
      }
      
      public function setRequestedStoragePermission(param1:Boolean) : void
      {
         requestedFirstStoragePermission = param1;
      }
      
      public function isRequestedFirstStoragePermission() : Boolean
      {
         return requestedFirstStoragePermission && gudetama.engine.Engine.platform == 1;
      }
      
      public function setARMode(param1:Boolean) : void
      {
         arMode = param1;
      }
      
      public function isARMode() : Boolean
      {
         return arMode;
      }
      
      public function setNeedDownloadFirstRsrc(param1:Boolean) : void
      {
         needDownloadFirstRsrc = param1;
      }
      
      public function isNeedDownloadFirstRsrc() : Boolean
      {
         return needDownloadFirstRsrc;
      }
      
      public function getFriendSortType() : int
      {
         return friendSortType;
      }
      
      public function setFriendSortType(param1:int) : void
      {
         friendSortType = param1;
      }
      
      public function setPriorityDate() : void
      {
         lastedShowPriorityVideoDate = new Date();
         trace("setPriorityDate");
      }
      
      public function notEqualShowedPriorityVideoDate() : Boolean
      {
         if(lastedShowPriorityVideoDate == null)
         {
            return true;
         }
         var _loc3_:Date = new Date();
         var _loc2_:Date = new Date(_loc3_.fullYear,_loc3_.month,_loc3_.date);
         var _loc1_:Date = new Date(lastedShowPriorityVideoDate.fullYear,lastedShowPriorityVideoDate.month,lastedShowPriorityVideoDate.date);
         if(_loc2_.time == _loc1_.time)
         {
            return false;
         }
         return true;
      }
      
      public function canShowVideo() : Boolean
      {
         var _loc1_:int = TimeZoneUtil.epochMillisToOffsetSecs();
         trace("LocalData#canShowVideo : " + (_loc1_ > videoAdRewardUpdateTimeSecs));
         return _loc1_ > videoAdRewardUpdateTimeSecs;
      }
      
      public function set stampDataMap(param1:Array) : void
      {
         tmpStampMap = param1;
      }
      
      public function get stampDataMap() : Array
      {
         return tmpStampMap;
      }
      
      public function set helperId(param1:int) : void
      {
         helperIndex = param1;
      }
      
      public function get helperId() : int
      {
         return helperIndex;
      }
      
      public function writeExternal(param1:IDataOutput) : void
      {
         var _loc2_:* = 0;
         var _loc3_:int = 0;
         var _loc4_:* = null;
         var _loc10_:int = 0;
         var _loc5_:int = 0;
         var _loc7_:int = 0;
         try
         {
            param1.writeByte(4);
            param1.writeUnsignedInt(DataStorage.getHashId());
            param1.writeUTF(friendKey);
            _loc2_ = (!!requestedFirstPermissionAR ? 1 : 0) | (!!requestedFirstStoragePermission ? 2 : 0) | (!!arMode ? 4 : 0) | (!!needDownloadFirstRsrc ? 8 : 0);
            param1.writeInt(_loc2_);
            _loc3_ = 0;
            for(var _loc9_ in receiptsMap)
            {
               _loc3_++;
            }
            param1.writeByte(_loc3_);
            for(_loc9_ in receiptsMap)
            {
               param1.writeInt(_loc9_);
               _loc4_ = receiptsMap[_loc9_];
               param1.writeByte(_loc4_.length);
               for each(var _loc6_ in _loc4_)
               {
                  param1.writeUTF(_loc6_);
               }
            }
            _loc10_ = receivedMailList.length;
            param1.writeInt(_loc10_);
            _loc5_ = 0;
            while(_loc5_ < _loc10_)
            {
               receivedMailList[_loc5_].writeExternal(param1);
               _loc5_++;
            }
            _loc10_ = sentMailList.length;
            param1.writeInt(_loc10_);
            _loc7_ = 0;
            while(_loc7_ < _loc10_)
            {
               sentMailList[_loc7_].writeExternal(param1);
               _loc7_++;
            }
            param1.writeUTF(pushToken);
            param1.writeUTF(locale);
            param1.writeUTF(playerName);
            param1.writeInt(gender);
            param1.writeUTF(appsFlyerUid);
            param1.writeInt(musicVolume * 100);
            param1.writeInt(effectVolume * 100);
            param1.writeInt(voiceVolume * 100);
            _loc10_ = 0;
            for(_loc9_ in receivedOperatorMessageMap)
            {
               _loc10_++;
            }
            param1.writeInt(_loc10_);
            for(_loc9_ in receivedOperatorMessageMap)
            {
               param1.writeInt(_loc9_);
               receivedOperatorMessageMap[_loc9_].writeExternal(param1);
            }
            param1.writeBoolean(noUseSoundPool);
            param1.writeByte(pendingNums.length);
            for each(var _loc8_ in pendingNums)
            {
               param1.writeInt(_loc8_);
            }
            param1.writeInt(pendingBonusValues);
            param1.writeInt(pendingFriendEncodedUid);
            param1.writeInt(pendingFriendPresentMoney);
            param1.writeObject(snsProfileByteArrayImages);
            param1.writeObject(snsTwitterFriendUids);
            param1.writeObject(snsFacebookFriendUids);
            param1.writeObject(snsTwitterFriendNameMap);
            param1.writeObject(snsFacebookFriendNameMap);
            param1.writeInt(interstitialIntervalSecs);
            param1.writeByte(friendSortType);
            param1.writeInt(showedPriorityVideoCount);
            param1.writeUTF(!!lastedShowPriorityVideoDate ? lastedShowPriorityVideoDate.fullYear + " " + lastedShowPriorityVideoDate.month + " " + lastedShowPriorityVideoDate.date : "");
            param1.writeInt(videoAdRewardUpdateTimeSecs);
            param1.writeInt(helperIndex);
         }
         catch(e:Error)
         {
            trace("LocalData writeExternal reset ");
            reset();
         }
      }
      
      public function readExternal(param1:IDataInput) : void
      {
         var _loc17_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:* = null;
         var _loc15_:int = 0;
         var _loc14_:int = 0;
         var _loc16_:* = null;
         var _loc5_:* = null;
         var _loc18_:* = null;
         var _loc3_:* = null;
         var _loc8_:* = null;
         var _loc4_:* = null;
         var _loc12_:uint = param1.readByte();
         var _loc2_:* = param1.readUnsignedInt() != DataStorage.getHashId();
         if(_loc2_)
         {
            throw new IOError("broken data");
         }
         friendKey = param1.readUTF();
         var _loc6_:int;
         requestedFirstPermissionAR = ((_loc6_ = param1.readInt()) & 1) != 0;
         requestedFirstStoragePermission = (_loc6_ & 2) != 0;
         arMode = (_loc6_ & 4) != 0;
         needDownloadFirstRsrc = (_loc6_ & 8) != 0;
         receiptsMap = {};
         var _loc7_:int = param1.readByte();
         _loc9_ = 0;
         while(_loc9_ < _loc7_)
         {
            _loc17_ = param1.readInt();
            _loc10_ = [];
            _loc15_ = param1.readByte();
            _loc14_ = 0;
            while(_loc14_ < _loc15_)
            {
               _loc16_ = param1.readUTF();
               _loc10_.push(_loc16_);
               _loc14_++;
            }
            receiptsMap[_loc17_] = _loc10_;
            _loc9_++;
         }
         var _loc13_:int = param1.readInt();
         receivedMailList = [];
         var _loc11_:int = 0;
         _loc11_ = 0;
         while(_loc11_ < _loc13_)
         {
            (_loc5_ = new LocalMailData()).readExternal(param1);
            receivedMailList.push(_loc5_);
            _loc11_++;
         }
         _loc13_ = param1.readInt();
         sentMailList = [];
         _loc11_ = 0;
         while(_loc11_ < _loc13_)
         {
            (_loc18_ = new LocalSentMailData()).readExternal(param1);
            sentMailList.push(_loc18_);
            _loc11_++;
         }
         pushToken = param1.readUTF();
         locale = param1.readUTF();
         playerName = param1.readUTF();
         gender = param1.readInt();
         appsFlyerUid = param1.readUTF();
         musicVolume = param1.readInt() / 100;
         effectVolume = param1.readInt() / 100;
         voiceVolume = param1.readInt() / 100;
         receivedOperatorMessageMap = [];
         _loc13_ = param1.readInt();
         _loc11_ = 0;
         while(_loc11_ < _loc13_)
         {
            _loc3_ = new LocalMessageData();
            _loc17_ = param1.readInt();
            _loc3_.readExternal(param1);
            receivedOperatorMessageMap[_loc17_] = _loc3_;
            _loc11_++;
         }
         noUseSoundPool = param1.readBoolean();
         _loc15_ = param1.readByte();
         pendingNums = new Vector.<int>(_loc15_);
         _loc9_;
         while(_loc9_ < _loc15_)
         {
            pendingNums[_loc9_] = param1.readInt();
            _loc9_++;
         }
         pendingBonusValues = param1.readInt();
         pendingFriendEncodedUid = param1.readInt();
         pendingFriendPresentMoney = param1.readInt();
         snsProfileByteArrayImages = param1.readObject();
         snsTwitterFriendUids = param1.readObject();
         snsFacebookFriendUids = param1.readObject();
         snsTwitterFriendNameMap = param1.readObject();
         snsFacebookFriendNameMap = param1.readObject();
         interstitialIntervalSecs = param1.readInt();
         if(_loc12_ >= 1)
         {
            friendSortType = param1.readByte();
         }
         if(_loc12_ >= 2)
         {
            showedPriorityVideoCount = param1.readInt();
            if((_loc8_ = param1.readUTF()) != "")
            {
               _loc4_ = _loc8_.split(" ");
               lastedShowPriorityVideoDate = new Date(_loc4_[0],_loc4_[1],_loc4_[2]);
               if(notEqualShowedPriorityVideoDate())
               {
                  showedPriorityVideoCount = 0;
               }
            }
         }
         if(_loc12_ >= 3)
         {
            videoAdRewardUpdateTimeSecs = param1.readInt();
         }
         if(_loc12_ >= 4)
         {
            helperIndex = param1.readInt();
         }
      }
   }
}
