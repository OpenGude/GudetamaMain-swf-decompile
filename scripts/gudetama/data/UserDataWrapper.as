package gudetama.data
{
   import flash.utils.ByteArray;
   import flash.utils.getTimer;
   import gudetama.common.FacebookManager;
   import gudetama.common.GudetamaUtil;
   import gudetama.common.TwitterManager;
   import gudetama.data.compati.AvatarData;
   import gudetama.data.compati.ConvertParam;
   import gudetama.data.compati.CupGachaData;
   import gudetama.data.compati.CupGachaDef;
   import gudetama.data.compati.CupGachaResult;
   import gudetama.data.compati.FriendlyData;
   import gudetama.data.compati.GudetamaData;
   import gudetama.data.compati.GudetamaDef;
   import gudetama.data.compati.HomeDecoData;
   import gudetama.data.compati.IdentifiedPresentDef;
   import gudetama.data.compati.ItemParam;
   import gudetama.data.compati.KitchenwareData;
   import gudetama.data.compati.KitchenwareDef;
   import gudetama.data.compati.MetalShopItemDef;
   import gudetama.data.compati.NoticeFlagData;
   import gudetama.data.compati.PresentLogData;
   import gudetama.data.compati.PurchasePresentDef;
   import gudetama.data.compati.RecipeNoteDef;
   import gudetama.data.compati.SetItemBuyData;
   import gudetama.data.compati.SetItemDef;
   import gudetama.data.compati.StaminaData;
   import gudetama.data.compati.SystemMailData;
   import gudetama.data.compati.TouchEventParam;
   import gudetama.data.compati.TouchInfo;
   import gudetama.data.compati.UsefulDef;
   import gudetama.data.compati.UserData;
   import gudetama.engine.Engine;
   import gudetama.engine.Logger;
   import gudetama.ui.CupGachaAnimePanel;
   import gudetama.ui.CupGachaResultDialog;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.util.TimeZoneUtil;
   
   public class UserDataWrapper
   {
      
      public static var wrapper:UserDataWrapper = new UserDataWrapper();
      
      public static var missionPart:MissionPart = new MissionPart();
      
      public static var kitchenwarePart:KitchenwarePart = new KitchenwarePart();
      
      public static var recipeNotePart:RecipeNotePart = new RecipeNotePart();
      
      public static var gudetamaPart:GudetamaPart = new GudetamaPart();
      
      public static var gachaPart:GachaPart = new GachaPart();
      
      public static var usefulPart:UsefulPart = new UsefulPart();
      
      public static var utensilPart:UtensilPart = new UtensilPart();
      
      public static var decorationPart:DecorationPart = new DecorationPart();
      
      public static var avatarPart:AvatarPart = new AvatarPart();
      
      public static var stampPart:StampPart = new StampPart();
      
      public static var friendPart:FriendPart = new FriendPart();
      
      public static var wantedPart:WantedPart = new WantedPart();
      
      public static var abilityPart:AbilityPart = new AbilityPart();
      
      public static var featurePart:FeaturePart = new FeaturePart();
      
      public static var videoAdPart:VideoAdPart = new VideoAdPart();
      
      public static var linkagePart:LinkagePart = new LinkagePart();
      
      public static var eventPart:EventPart = new EventPart();
      
      public static const HOME_RIGHT:int = 0;
      
      public static const HOME_LEFT:int = 1;
       
      
      private var dialogSystemMails:Array;
      
      private var numUnreadInfoAndPresent:int;
      
      private var numFriendPresent:int;
      
      private var presentLogs:Array;
      
      private var friendPresentLogMap:Object;
      
      private var friendlyDataMap:Object;
      
      private var assists:Array;
      
      private var nextTouchEvent:TouchEventParam;
      
      private var lastHomeScrollPosition:int = 0;
      
      private var newRecipeMap:Object;
      
      private var numNewRecipeMap:Object;
      
      private var numPresentMoneyFromFriend:int;
      
      private var numAssistFromFriend:int;
      
      private var disabledOfferwall:Boolean;
      
      private var menuItems:Array;
      
      private var mailNoticeIconIds:Array;
      
      private var updatedMailNoticeIconIds:Boolean;
      
      public var hasPresentLimitSoon:Boolean;
      
      private var rankingGlobalPointRewardParams:Array;
      
      private var cupGachaResults:Array;
      
      private var cupGachaLastUpdateSec:int;
      
      private var canUseHelper:Boolean = false;
      
      private var _data:UserData;
      
      private var lastUpdateStaminaTime:int;
      
      private var lastUpdateBoostTime:int;
      
      private var roomType:int;
      
      private var mailNum:int;
      
      private var presentNum:int;
      
      private var clearMissionNum:int;
      
      private var newMission:Boolean;
      
      private var newDailyMissionList:ByteArray;
      
      private var eventBannerIDs:Array;
      
      private var _hideGudeId:int;
      
      public function UserDataWrapper()
      {
         dialogSystemMails = [];
         presentLogs = [];
         friendPresentLogMap = {};
         friendlyDataMap = {};
         assists = [];
         newRecipeMap = {};
         numNewRecipeMap = {};
         rankingGlobalPointRewardParams = [];
         cupGachaResults = [];
         super();
      }
      
      public static function get data#2() : UserData
      {
         return wrapper._data;
      }
      
      public static function init(param1:UserData) : void
      {
         Engine.setLocale(param1.locale);
         var _loc2_:int = !!isInitialized() ? gudetama.data.UserDataWrapper.wrapper._data.uid : 0;
         wrapper._data = param1;
         wrapper.lastUpdateStaminaTime = getTimer();
         wrapper.newRecipeMap = {};
         kitchenwarePart.init(gudetama.data.UserDataWrapper.wrapper._data);
         recipeNotePart.init(gudetama.data.UserDataWrapper.wrapper._data);
         gudetamaPart.init(gudetama.data.UserDataWrapper.wrapper._data);
         gachaPart.init(gudetama.data.UserDataWrapper.wrapper._data);
         usefulPart.init(gudetama.data.UserDataWrapper.wrapper._data);
         utensilPart.init(gudetama.data.UserDataWrapper.wrapper._data);
         decorationPart.init(gudetama.data.UserDataWrapper.wrapper._data);
         avatarPart.init(gudetama.data.UserDataWrapper.wrapper._data);
         stampPart.init(gudetama.data.UserDataWrapper.wrapper._data);
         friendPart.init(gudetama.data.UserDataWrapper.wrapper._data);
         wantedPart.init(gudetama.data.UserDataWrapper.wrapper._data);
         abilityPart.init(gudetama.data.UserDataWrapper.wrapper._data);
         featurePart.init(gudetama.data.UserDataWrapper.wrapper._data);
         videoAdPart.init(gudetama.data.UserDataWrapper.wrapper._data);
         linkagePart.init(gudetama.data.UserDataWrapper.wrapper._data);
         eventPart.init(gudetama.data.UserDataWrapper.wrapper._data);
         if(_loc2_ != gudetama.data.UserDataWrapper.wrapper._data.uid)
         {
            missionPart.init();
         }
         wrapper.dialogSystemMails = [];
         wrapper.presentLogs = [];
         wrapper.friendPresentLogMap = {};
         wrapper.friendlyDataMap = {};
         wrapper.mailNoticeIconIds = [];
         wrapper.rankingGlobalPointRewardParams = [];
         wrapper.cupGachaResults = [];
         wrapper.cupGachaLastUpdateSec = TimeZoneUtil.epochMillisToOffsetSecs();
         wrapper.lastHomeScrollPosition = 0;
         wrapper.updatePlayerRank();
         if(param1.snsTwitterUid.length == 0)
         {
            param1.snsTwitterUid = null;
         }
         if(param1.snsFacebookUid.length == 0)
         {
            param1.snsFacebookUid = null;
         }
         if(param1.snsTwitterUid && !DataStorage.getLocalData().getSnsImageTexture(0))
         {
            TwitterManager.loadMyProfileImage();
         }
         if(param1.snsFacebookUid && !DataStorage.getLocalData().getSnsImageTexture(1))
         {
            FacebookManager.loadProfileImage(param1.snsFacebookUid);
         }
      }
      
      public static function isInitialized() : Boolean
      {
         return wrapper._data != null;
      }
      
      public static function toFriendKey(param1:int) : String
      {
         var _loc2_:String = String(param1);
         if(_loc2_.length < 5)
         {
            return ("0000" + _loc2_).slice(-5);
         }
         return _loc2_;
      }
      
      public static function useSnsLinkBanner() : Boolean
      {
         return featurePart.existsFeature(13) && (GameSetting.def.rule.useSnsTwitter || GameSetting.def.rule.useSnsFacebook);
      }
      
      public function getUid() : int
      {
         if(_data == null)
         {
            return -1;
         }
         return _data.uid;
      }
      
      public function getEncodedUid() : int
      {
         if(_data == null)
         {
            return -1;
         }
         return _data.encodedUid;
      }
      
      public function get questRoomType() : int
      {
         return roomType;
      }
      
      public function set questRoomType(param1:int) : void
      {
         roomType = param1;
      }
      
      public function isEventQuest() : Boolean
      {
         return roomType == 5 || roomType == 6;
      }
      
      public function getFriendKey() : String
      {
         if(_data == null)
         {
            return "---";
         }
         return toFriendKey(_data.encodedUid);
      }
      
      public function setNoticeFlag(param1:int, param2:int) : int
      {
         return _data.noticeFlagData.noticeFlags[param1] = param2;
      }
      
      public function getNoticeFlag(param1:int) : int
      {
         return _data.noticeFlagData.noticeFlags[param1] & 15;
      }
      
      private function checkNoticeFlag(param1:int, param2:int) : Boolean
      {
         var _loc4_:* = null;
         var _loc3_:int = 0;
         try
         {
            if((_loc4_ = _data.noticeFlagData) == null)
            {
               return false;
            }
            _loc3_ = _loc4_.noticeFlags[param1];
            if((_loc3_ & 15) == param2)
            {
               return true;
            }
            return false;
         }
         catch(e:Error)
         {
            Logger.error("checkNoticeFlag notice:" + param1 + " state:" + param2 + " _data:" + _data + " noticeFlagData:" + (!!_data ? _data.noticeFlagData : "null") + " noticeFlags:" + (_data && _data.noticeFlagData ? _data.noticeFlagData.noticeFlags : "null") + " length:" + (_data && _data.noticeFlagData && _data.noticeFlagData.noticeFlags ? _data.noticeFlagData.noticeFlags.length : "null") + " flag:" + (_data && _data.noticeFlagData && _data.noticeFlagData.noticeFlags && _data.noticeFlagData.noticeFlags.length > param1 ? _data.noticeFlagData.noticeFlags[param1] : "null") + " " + e.getStackTrace());
            throw e;
         }
      }
      
      public function isCanStartNoticeFlag(param1:int) : Boolean
      {
         return checkNoticeFlag(param1,1);
      }
      
      public function isDoneNoticeFlag(param1:int) : Boolean
      {
         return checkNoticeFlag(param1,2);
      }
      
      public function isFirstGudetamaTouch() : Boolean
      {
         return wrapper.equalsTutorialProgress(2);
      }
      
      public function isCompletedTutorial() : Boolean
      {
         return _data.noticeFlagData.tutorialProgress >= 7;
      }
      
      public function isGetableLoginBonus() : Boolean
      {
         return _data.noticeFlagData.tutorialProgress >= 11;
      }
      
      public function equalsTutorialProgress(param1:int) : Boolean
      {
         return param1 == _data.noticeFlagData.tutorialProgress;
      }
      
      public function belowTutorialProgress(param1:int) : Boolean
      {
         return param1 >= _data.noticeFlagData.tutorialProgress;
      }
      
      public function getTutorialProgress() : int
      {
         return _data.noticeFlagData.tutorialProgress;
      }
      
      public function isBitFlag(param1:int) : Boolean
      {
         return (_data.noticeFlagData.bitFlags & param1) != 0;
      }
      
      public function setBitFlag(param1:int, param2:Boolean) : void
      {
         if(param2)
         {
            _data.noticeFlagData.bitFlags |= param1;
         }
         else
         {
            _data.noticeFlagData.bitFlags &= ~param1;
         }
      }
      
      public function addMetalEnabled(param1:int = 0) : Boolean
      {
         return getMetal() <= 999999999 - param1;
      }
      
      public function setItemNum(param1:ItemParam, param2:int) : void
      {
         setItemNumAtParam(param1.id#2,param1.kind,param2);
      }
      
      public function setItemNumAtParam(param1:int, param2:int, param3:int) : void
      {
         switch(int(param2))
         {
            case 0:
               _data.freeMoney = param3;
               break;
            case 1:
               _data.freeMetal = param3;
               break;
            case 2:
               _data.chargeMetal = param3;
               break;
            case 14:
               _data.chargeMoney = param3;
         }
      }
      
      public function hasItemNum(param1:ItemParam) : int
      {
         switch(int(param1.kind))
         {
            case 0:
               return getMoney();
            case 1:
               return getMetal();
            case 2:
               return getChargeMetal();
            case 14:
               return getChargeMoney();
            default:
               return 0;
         }
      }
      
      public function getNextDailyPresentTime() : Number
      {
         return gudetama.data.UserDataWrapper.wrapper._data.nextDailyPresentTime;
      }
      
      public function setStaminaData(param1:StaminaData) : void
      {
         lastUpdateStaminaTime = getTimer();
      }
      
      public function addNumPresents(param1:int) : void
      {
         presentNum += param1;
      }
      
      public function setNumPresents(param1:int) : void
      {
         presentNum = param1;
      }
      
      public function getNumPresents() : int
      {
         return presentNum;
      }
      
      public function updateMailNoticeIconIds(param1:Array) : void
      {
         if(!param1)
         {
            return;
         }
         if(GudetamaUtil.compareArray(param1,mailNoticeIconIds))
         {
            return;
         }
         mailNoticeIconIds = param1;
         updatedMailNoticeIconIds = true;
      }
      
      public function getMailNoticeIconIds() : Array
      {
         return mailNoticeIconIds;
      }
      
      public function resetMailNoticeIconIds() : void
      {
         mailNoticeIconIds = null;
      }
      
      public function resetMailNoticeIconIdsUpdatedFlag() : void
      {
         updatedMailNoticeIconIds = false;
      }
      
      public function isUpdatedMailNoticeIconIds() : Boolean
      {
         return updatedMailNoticeIconIds;
      }
      
      public function getTimeZoneOffset() : int
      {
         if(!gudetama.data.UserDataWrapper.wrapper._data)
         {
            return 0;
         }
         return gudetama.data.UserDataWrapper.wrapper._data.timeZoneOffset;
      }
      
      public function getTimeZoneTime() : Date
      {
         return TimeZoneUtil.getTimeZoneTime(gudetama.data.UserDataWrapper.wrapper._data.timeZoneOffset);
      }
      
      public function getTimeZoneTimeInMillis() : Number
      {
         if(!gudetama.data.UserDataWrapper.wrapper._data)
         {
            return 0;
         }
         return TimeZoneUtil.getTimeZoneTimeInMillis(gudetama.data.UserDataWrapper.wrapper._data.timeZoneOffset);
      }
      
      public function getGender() : int
      {
         return gudetama.data.UserDataWrapper.wrapper._data.gender;
      }
      
      public function getPlayerName() : String
      {
         return gudetama.data.UserDataWrapper.wrapper._data.playerName;
      }
      
      public function setPlayerName(param1:String) : void
      {
         gudetama.data.UserDataWrapper.wrapper._data.playerName = param1;
      }
      
      public function getComment() : int
      {
         if(gudetama.data.UserDataWrapper.wrapper._data.comment >= 0)
         {
            return gudetama.data.UserDataWrapper.wrapper._data.comment;
         }
         return 65536 + gudetama.data.UserDataWrapper.wrapper._data.comment;
      }
      
      public function setComment(param1:int) : void
      {
         gudetama.data.UserDataWrapper.wrapper._data.comment = param1;
      }
      
      public function isCurrentComment(param1:int) : Boolean
      {
         if(getComment() == param1)
         {
            return true;
         }
         return false;
      }
      
      public function getCurrentAvatar() : int
      {
         return gudetama.data.UserDataWrapper.wrapper._data.avatar;
      }
      
      public function setAvatar(param1:int, param2:int) : void
      {
         gudetama.data.UserDataWrapper.wrapper._data.avatar = param1;
         gudetama.data.UserDataWrapper.wrapper._data.snsInterlockType = param2;
      }
      
      public function isCurrentAvatar(param1:int, param2:int) : Boolean
      {
         if(param2 != -1 || gudetama.data.UserDataWrapper.wrapper._data.snsInterlockType != -1)
         {
            return gudetama.data.UserDataWrapper.wrapper._data.snsInterlockType == param2;
         }
         if(gudetama.data.UserDataWrapper.wrapper._data.avatar == param1)
         {
            return true;
         }
         return false;
      }
      
      private function getAvatarData(param1:int) : AvatarData
      {
         return gudetama.data.UserDataWrapper.wrapper._data.avatarMap[param1];
      }
      
      public function getAvatarMap() : Object
      {
         return gudetama.data.UserDataWrapper.wrapper._data.avatarMap;
      }
      
      public function hasAvatar(param1:int) : Boolean
      {
         var _loc2_:AvatarData = getAvatarData(param1);
         if(!_loc2_)
         {
            return false;
         }
         if(!_loc2_.acquired)
         {
            return false;
         }
         return true;
      }
      
      public function isExtraAvatar() : Boolean
      {
         return gudetama.data.UserDataWrapper.wrapper._data.snsInterlockType != -1;
      }
      
      public function getCurrentExtraAvatar() : int
      {
         return gudetama.data.UserDataWrapper.wrapper._data.snsInterlockType;
      }
      
      public function getArea() : int
      {
         return gudetama.data.UserDataWrapper.wrapper._data.area;
      }
      
      public function get areaName() : String
      {
         return GameSetting.getUIText("profile.area." + gudetama.data.UserDataWrapper.wrapper._data.area);
      }
      
      public function placeGudetama(param1:int) : void
      {
         gudetama.data.UserDataWrapper.wrapper._data.placedGudetamaId = param1;
      }
      
      public function getPlacedGudetamaId() : int
      {
         return gudetama.data.UserDataWrapper.wrapper._data.placedGudetamaId;
      }
      
      public function getRank() : int
      {
         return _data.rank;
      }
      
      public function updatePlayerRank() : void
      {
         _data.rank = 0;
         var _loc1_:Object = gudetamaPart.getGudetamaMap();
         for(var _loc2_ in _loc1_)
         {
            if(gudetamaPart.isCooked(_loc2_))
            {
               _data.rank++;
            }
         }
      }
      
      public function addChargeMetal(param1:int) : void
      {
         if(param1 <= 0)
         {
            throw new Error();
         }
         _data.chargeMetal += param1;
      }
      
      public function addFreeMetal(param1:int) : void
      {
         if(param1 <= 0)
         {
            throw new Error();
         }
         _data.freeMetal += param1;
      }
      
      public function addSubMetal(param1:ConvertParam) : void
      {
         if(param1.num <= 0)
         {
            throw new Error();
         }
         _data.subMetal += param1.num;
         Logger.info("addSubMetal subMetal:" + _data.subMetal + " freeMetal:" + _data.freeMetal);
         if(param1.originalItem)
         {
            useItem(param1.originalItem);
            addItem(param1.convertedItem,param1.convertedParam);
         }
      }
      
      public function consumeChargeMetal(param1:int) : void
      {
         if(param1 <= 0)
         {
            throw new Error();
         }
         if(param1 > _data.chargeMetal)
         {
            throw new Error();
         }
         _data.chargeMetal -= param1;
      }
      
      public function consumeMetal(param1:int) : void
      {
         var _loc2_:int = 0;
         if(param1 <= 0)
         {
            throw new Error();
         }
         if(_data.chargeMetal >= param1)
         {
            _data.chargeMetal -= param1;
         }
         else
         {
            _loc2_ = param1 - _data.chargeMetal;
            if(_loc2_ > _data.freeMetal)
            {
               throw new Error();
            }
            _data.freeMetal -= _loc2_;
            _data.chargeMetal = 0;
         }
      }
      
      public function consumeSubMetal(param1:int) : void
      {
         if(param1 <= 0)
         {
            throw new Error("consumeSubMetal amount <= 0");
         }
         if(param1 > _data.subMetal)
         {
            throw new Error("consumeSubMetal amount:" + param1 + " subMetal:" + _data.subMetal);
         }
         _data.subMetal -= param1;
      }
      
      public function hasChargeMetal(param1:int) : Boolean
      {
         return getChargeMetal() >= param1;
      }
      
      public function hasMetal(param1:int) : Boolean
      {
         return getMetal() >= param1;
      }
      
      public function hasSubMetal(param1:int) : Boolean
      {
         return getSubMetal() >= param1;
      }
      
      public function getChargeMetal() : int
      {
         return _data.chargeMetal;
      }
      
      public function getFreeMetal() : int
      {
         return _data.freeMetal;
      }
      
      public function getMetal() : int
      {
         return _data.chargeMetal + _data.freeMetal;
      }
      
      public function getSubMetal() : int
      {
         return _data.subMetal;
      }
      
      public function isMetalAddable(param1:int) : Boolean
      {
         return getMetal() <= 999999999 - param1;
      }
      
      public function getPurchasePresent(param1:int) : PurchasePresentDef
      {
         var _loc2_:PurchasePresentDef = GameSetting.getPurchasePresent(param1);
         if(!_loc2_)
         {
            return null;
         }
         if(_data.purchasePresentMap[_loc2_.id#2])
         {
            return null;
         }
         return _loc2_;
      }
      
      public function getRemainingMonthlyPremiumBonusDate() : int
      {
         var _loc1_:int = _data.finishMonthlyPremiumBonusTimeSec - TimeZoneUtil.epochMillisToOffsetSecs();
         return _loc1_ / 86400 + 1;
      }
      
      public function isPurchasableMonthlyPremiumBonus() : Boolean
      {
         return _data.finishMonthlyPremiumBonusTimeSec <= 0;
      }
      
      public function setFinishMonthlyBonusTimeSec(param1:int) : void
      {
         _data.finishMonthlyPremiumBonusTimeSec = param1;
         if(param1 > 0)
         {
            _data.noticeMonthlyPremiumBonusTimeSec = 0;
         }
      }
      
      public function setNoticeMonthlyBonusTimeSec(param1:int) : void
      {
         _data.noticeMonthlyPremiumBonusTimeSec = param1;
      }
      
      public function isNoticeMonthlyBonus() : Boolean
      {
         return TimeZoneUtil.epochMillisToOffsetSecs() < _data.noticeMonthlyPremiumBonusTimeSec;
      }
      
      public function canUseHelperState() : Boolean
      {
         return canUseHelper;
      }
      
      public function setHelperState(param1:Boolean) : void
      {
         canUseHelper = param1;
      }
      
      public function createPossessingRecipeNoteIds(param1:int, param2:int) : Array
      {
         var _loc5_:* = null;
         var _loc3_:Array = [];
         var _loc4_:KitchenwareData;
         if(!(_loc4_ = kitchenwarePart.getKitchenwareByType(param1)))
         {
            return _loc3_;
         }
         var _loc8_:* = null;
         for(var _loc7_ in _loc4_.paramMap)
         {
            if((_loc5_ = GameSetting.getKitchenware(_loc7_)).grade == param2)
            {
               _loc8_ = _loc5_;
               break;
            }
         }
         if(!_loc8_)
         {
            return _loc3_;
         }
         for each(var _loc6_ in _loc8_.recipeNoteIds)
         {
            if(eventPart.inTerm(GameSetting.getRecipeNote(_loc6_).eventId,true))
            {
               if(recipeNotePart.isVisible(_loc6_))
               {
                  _loc3_.push(_loc6_);
               }
            }
         }
         return _loc3_;
      }
      
      public function isHappeningCompleted(param1:int) : Boolean
      {
         var _loc3_:RecipeNoteDef = GameSetting.getRecipeNote(param1);
         for each(var _loc2_ in _loc3_.happeningIds)
         {
            if(!gudetamaPart.isCooked(_loc2_))
            {
               return false;
            }
         }
         return true;
      }
      
      public function isFailureCompleted(param1:int) : Boolean
      {
         var _loc3_:RecipeNoteDef = GameSetting.getRecipeNote(param1);
         for each(var _loc2_ in _loc3_.failureIds)
         {
            if(!gudetamaPart.isCooked(_loc2_))
            {
               return false;
            }
         }
         return true;
      }
      
      public function addRecipe(param1:GudetamaData) : void
      {
         gudetamaPart.addRecipe(param1);
         updatePlayerRank();
      }
      
      public function addRecipes(param1:Array) : void
      {
         gudetamaPart.addRecipes(param1);
         updatePlayerRank();
      }
      
      public function isScreenableInCollection(param1:int) : Boolean
      {
         var _loc3_:* = null;
         var _loc4_:* = null;
         var _loc2_:GudetamaDef = GameSetting.getGudetama(param1);
         if(_loc2_.type == 3)
         {
            return true;
         }
         if(!gudetamaPart.hasRecipe(param1) || !gudetamaPart.isAvailable(param1))
         {
            return false;
         }
         if(_loc2_.isGacha)
         {
            return true;
         }
         if(_loc2_.recipeNoteId > 0)
         {
            _loc3_ = GameSetting.getRecipeNote(_loc2_.recipeNoteId);
            if(_loc3_.eventId > 0)
            {
               return true;
            }
            if(!recipeNotePart.isAvailable(_loc2_.recipeNoteId))
            {
               return false;
            }
            if(!recipeNotePart.isPurchased(_loc2_.recipeNoteId))
            {
               return false;
            }
            if(_loc3_.kitchenwareId > 0)
            {
               _loc4_ = GameSetting.getKitchenware(_loc3_.kitchenwareId);
               if(!kitchenwarePart.isAvailable(_loc4_.type,_loc4_.grade,false) && !_loc3_.eventId > 0)
               {
                  return false;
               }
            }
         }
         return true;
      }
      
      public function updateNewRecipe(param1:int, param2:int, param3:Boolean) : void
      {
         var _loc4_:* = null;
         if(param3)
         {
            if(!newRecipeMap[param1])
            {
               newRecipeMap[param1] = [];
            }
            if((_loc4_ = newRecipeMap[param1]).indexOf(param2) >= 0)
            {
               return;
            }
            _loc4_.push(param2);
         }
         else
         {
            if(!newRecipeMap[param1])
            {
               return;
            }
            if((_loc4_ = newRecipeMap[param1]).indexOf(param2) < 0)
            {
               return;
            }
            _loc4_.removeAt(_loc4_.indexOf(param2));
         }
      }
      
      public function updateNumNewRecipe() : void
      {
         var _loc2_:int = 0;
         var _loc4_:* = null;
         for(var _loc3_ in newRecipeMap)
         {
            _loc2_ = 0;
            _loc4_ = newRecipeMap[_loc3_];
            for each(var _loc1_ in _loc4_)
            {
               if(isScreenableInRecipeNote(_loc1_))
               {
                  _loc2_++;
               }
            }
            numNewRecipeMap[_loc3_] = _loc2_;
         }
      }
      
      public function isScreenableInRecipeNote(param1:int) : Boolean
      {
         if(!gudetamaPart.isAvailable(param1))
         {
            return false;
         }
         var _loc2_:GudetamaDef = GameSetting.getGudetama(param1);
         if(_loc2_.recipeNoteId <= 0)
         {
            return false;
         }
         if(!recipeNotePart.isAvailable(_loc2_.recipeNoteId))
         {
            return false;
         }
         if(!recipeNotePart.isPurchased(_loc2_.recipeNoteId))
         {
            return false;
         }
         var _loc3_:RecipeNoteDef = GameSetting.getRecipeNote(_loc2_.recipeNoteId);
         if(!eventPart.inTerm(_loc3_.eventId,true))
         {
            return false;
         }
         if(_loc3_.kitchenwareId <= 0)
         {
            return false;
         }
         var _loc4_:KitchenwareDef = GameSetting.getKitchenware(_loc3_.kitchenwareId);
         if(!kitchenwarePart.isAvailable(_loc4_.type,_loc4_.grade,true))
         {
            return false;
         }
         return true;
      }
      
      public function getNewRecipeCount(param1:int) : int
      {
         if(!numNewRecipeMap[param1])
         {
            return 0;
         }
         return numNewRecipeMap[param1];
      }
      
      public function getHurryUsefulId(param1:int, param2:int) : Array
      {
         var _loc10_:* = null;
         var _loc11_:Boolean = false;
         var _loc5_:int = 0;
         var _loc7_:int = 0;
         var _loc9_:int = 0;
         var _loc6_:int = 0;
         var _loc8_:Array;
         if(!(_loc8_ = UserDataWrapper.usefulPart.getHurryUsefulIds()) || _loc8_.length <= 0)
         {
            return null;
         }
         var _loc3_:Array = [];
         for each(var _loc4_ in _loc8_)
         {
            _loc10_ = GameSetting.getUseful(_loc4_);
            if(param2 == 4)
            {
               if(_loc10_.event && !UserDataWrapper.eventPart.existsGudetamaId(param1))
               {
                  continue;
               }
               if(_loc10_.eventId > 0 && !UserDataWrapper.eventPart.isRunningEvent(_loc10_.eventId))
               {
                  continue;
               }
            }
            if(_loc10_.kitchenwareTypes)
            {
               _loc11_ = false;
               _loc5_ = _loc10_.kitchenwareTypes.length;
               _loc7_ = 0;
               while(_loc7_ < _loc5_)
               {
                  _loc9_ = _loc10_.kitchenwareTypes[_loc7_];
                  if(param2 == _loc9_)
                  {
                     if((_loc6_ = UserDataWrapper.usefulPart.getNumUseful(_loc4_)) > 0)
                     {
                        _loc11_ = true;
                     }
                  }
                  _loc7_++;
               }
               if(!_loc11_)
               {
                  continue;
               }
            }
            _loc3_.push(_loc4_);
         }
         return _loc3_;
      }
      
      public function getAllHurryUsefulId(param1:int, param2:int) : Array
      {
         var _loc10_:* = null;
         var _loc11_:Boolean = false;
         var _loc5_:int = 0;
         var _loc7_:int = 0;
         var _loc9_:int = 0;
         var _loc6_:int = 0;
         var _loc8_:Array;
         if(!(_loc8_ = UserDataWrapper.usefulPart.getAllHurryUsefulIds()) || _loc8_.length <= 0)
         {
            return null;
         }
         var _loc3_:Array = [];
         for each(var _loc4_ in _loc8_)
         {
            _loc10_ = GameSetting.getUseful(_loc4_);
            if(param2 == 4)
            {
               if(_loc10_.event && !UserDataWrapper.eventPart.existsGudetamaId(param1))
               {
                  continue;
               }
               if(_loc10_.eventId > 0 && !UserDataWrapper.eventPart.isRunningEvent(_loc10_.eventId))
               {
                  continue;
               }
            }
            else if(_loc10_.kitchenwareTypes)
            {
               _loc11_ = false;
               _loc5_ = _loc10_.kitchenwareTypes.length;
               _loc7_ = 0;
               while(_loc7_ < _loc5_)
               {
                  _loc9_ = _loc10_.kitchenwareTypes[_loc7_];
                  if(param2 == _loc9_)
                  {
                     _loc11_ = true;
                  }
                  _loc7_++;
               }
               if(!_loc11_)
               {
                  continue;
               }
            }
            _loc6_ = UserDataWrapper.usefulPart.getNumUseful(_loc4_);
            if(!(_loc10_.privately || !_loc10_.price && _loc6_ <= 0))
            {
               _loc3_.push(_loc4_);
            }
         }
         return _loc3_;
      }
      
      public function addChargeMoney(param1:int) : void
      {
         if(param1 <= 0)
         {
            throw new Error();
         }
         _data.chargeMoney += param1;
      }
      
      public function addFreeMoney(param1:int) : void
      {
         if(param1 <= 0)
         {
            throw new Error();
         }
         _data.freeMoney += param1;
      }
      
      public function setFreeMoney(param1:int) : void
      {
         _data.freeMoney = param1;
      }
      
      public function consumeMoney(param1:int) : void
      {
         var _loc2_:int = 0;
         if(param1 <= 0)
         {
            throw new Error();
         }
         if(_data.chargeMoney >= param1)
         {
            _data.chargeMoney -= param1;
         }
         else
         {
            _loc2_ = param1 - _data.chargeMoney;
            if(_loc2_ > _data.freeMoney)
            {
               throw new Error();
            }
            _data.freeMoney -= _loc2_;
            _data.chargeMoney = 0;
         }
      }
      
      public function consumeChargeMoney(param1:int) : void
      {
         if(param1 <= 0)
         {
            throw new Error();
         }
         if(param1 > _data.chargeMoney)
         {
            throw new Error();
         }
         _data.chargeMoney -= param1;
      }
      
      public function consumeFreeMoney(param1:int) : void
      {
         if(param1 <= 0)
         {
            throw new Error();
         }
         if(param1 > _data.freeMoney)
         {
            throw new Error();
         }
         _data.freeMoney -= param1;
      }
      
      public function getMoney() : int
      {
         return _data.freeMoney + _data.chargeMoney;
      }
      
      public function getFreeMoney() : int
      {
         return _data.freeMoney;
      }
      
      public function getChargeMoney() : int
      {
         return _data.chargeMoney;
      }
      
      public function hasMoney(param1:int) : Boolean
      {
         return getMoney() >= param1;
      }
      
      public function hasChargeMoney(param1:int) : Boolean
      {
         return getChargeMoney() >= param1;
      }
      
      public function isMoneyAddable(param1:int) : Boolean
      {
         return getMoney() <= 999999999 - param1;
      }
      
      public function pushDialogSystemMail(param1:SystemMailData) : void
      {
         dialogSystemMails.push(param1);
      }
      
      public function popDialogSystemMail() : SystemMailData
      {
         return dialogSystemMails.shift();
      }
      
      public function setNumUnreadInfoAndPresents(param1:int) : void
      {
         numUnreadInfoAndPresent = param1;
      }
      
      public function addNumUnreadInfoAndPresents(param1:int) : void
      {
         numUnreadInfoAndPresent += param1;
      }
      
      public function existsUnreadInfoOrPresent() : Boolean
      {
         return numUnreadInfoAndPresent > 0;
      }
      
      public function setNumFriendPresents(param1:int) : void
      {
         numFriendPresent = param1;
      }
      
      public function addNumFriendPresents(param1:int) : void
      {
         numFriendPresent += param1;
      }
      
      public function getNumFriendPresents() : int
      {
         return numFriendPresent;
      }
      
      public function addPresentLogs(param1:Array) : void
      {
         if(!param1)
         {
            return;
         }
         for each(var _loc2_ in param1)
         {
            presentLogs.push(_loc2_);
         }
      }
      
      public function getPresentLogs() : Array
      {
         return presentLogs;
      }
      
      public function existsFriendPresentLogs(param1:int) : Boolean
      {
         return friendPresentLogMap[param1];
      }
      
      public function addFriendPresentLogs(param1:int, param2:Array) : void
      {
         if(!friendPresentLogMap[param1])
         {
            friendPresentLogMap[param1] = [];
         }
         if(!param2)
         {
            return;
         }
         for each(var _loc3_ in param2)
         {
            friendPresentLogMap[param1].push(_loc3_);
         }
      }
      
      public function getFriendPresentLogs(param1:int) : Array
      {
         return friendPresentLogMap[param1];
      }
      
      public function updateFriendlyData(param1:FriendlyData) : void
      {
         friendlyDataMap[param1.encodedUid] = param1;
      }
      
      public function getFriendly(param1:int) : int
      {
         if(!friendlyDataMap[param1])
         {
            return 0;
         }
         return FriendlyData(friendlyDataMap[param1]).friendly;
      }
      
      public function getFriendlyLevel(param1:int) : int
      {
         if(!friendlyDataMap[param1])
         {
            return 0;
         }
         return FriendlyData(friendlyDataMap[param1]).friendlyLevel;
      }
      
      public function getFriendlyData(param1:int) : FriendlyData
      {
         return friendlyDataMap[param1];
      }
      
      public function pushAssists(param1:Array) : void
      {
         if(!param1)
         {
            return;
         }
         assists = assists.concat(param1);
      }
      
      public function getAssists() : Array
      {
         return assists;
      }
      
      public function clearAssists() : void
      {
         assists.length = 0;
      }
      
      public function existsAssist() : Boolean
      {
         return assists.length > 0;
      }
      
      public function updateFriendPresentMoneyParam(param1:int, param2:Array) : void
      {
         gudetama.data.UserDataWrapper.wrapper._data.friendPresentMoneyParamMap[param1] = param2;
      }
      
      public function updateAllFriendPresentMoneyParam(param1:Object) : void
      {
         gudetama.data.UserDataWrapper.wrapper._data.friendPresentMoneyParamMap = param1;
      }
      
      public function isEnabledPresentMoneyToFriend(param1:int, param2:int) : Boolean
      {
         if(!gudetama.data.UserDataWrapper.wrapper._data.friendPresentMoneyParamMap[param1])
         {
            return true;
         }
         var _loc4_:Array;
         var _loc3_:int = (_loc4_ = gudetama.data.UserDataWrapper.wrapper._data.friendPresentMoneyParamMap[param1])[0];
         if(_loc4_.length >= 3)
         {
            param2 = _loc4_[2];
         }
         return _loc3_ < param2;
      }
      
      public function currentFriendPresentMoney(param1:int) : int
      {
         if(!gudetama.data.UserDataWrapper.wrapper._data.friendPresentMoneyParamMap[param1])
         {
            return 0;
         }
         var _loc2_:Array = gudetama.data.UserDataWrapper.wrapper._data.friendPresentMoneyParamMap[param1];
         return _loc2_[0];
      }
      
      public function presentMoneyToFriend(param1:int, param2:int, param3:int) : int
      {
         var _loc6_:Array;
         if(!(_loc6_ = gudetama.data.UserDataWrapper.wrapper._data.friendPresentMoneyParamMap[param1]))
         {
            _loc6_ = [0,0,0];
            gudetama.data.UserDataWrapper.wrapper._data.friendPresentMoneyParamMap[param1] = _loc6_;
         }
         var _loc5_:int = currentFriendPresentMoney(param1);
         var _loc4_:int = Math.max(0,param2 + _loc5_ - param3);
         param2 -= _loc4_;
         _loc6_[0] += param2;
         if(_loc6_[2] <= 0)
         {
            _loc6_[2] = param3;
         }
         return param2;
      }
      
      public function getMaxPresentMoneyToFriend(param1:int, param2:int) : int
      {
         var _loc3_:Array = gudetama.data.UserDataWrapper.wrapper._data.friendPresentMoneyParamMap[param1];
         if(_loc3_ && _loc3_.length >= 3)
         {
            return _loc3_[2];
         }
         return param2;
      }
      
      public function setNumPresentMoneyFromFriend(param1:int) : void
      {
         numPresentMoneyFromFriend = param1;
      }
      
      public function getNumPresentMoneyFromFriend() : int
      {
         return numPresentMoneyFromFriend;
      }
      
      public function setNumAssistFromFriend(param1:int) : void
      {
         numAssistFromFriend = param1;
      }
      
      public function getNumAssistFromFriend() : int
      {
         return numAssistFromFriend;
      }
      
      public function increaseNumFriendPresentForGPWhileEvent(param1:Array) : void
      {
         if(!param1)
         {
            return;
         }
         for each(var _loc2_ in param1)
         {
            if(!gudetama.data.UserDataWrapper.wrapper._data.numFriendPresentForGPWhileEventMap[_loc2_])
            {
               gudetama.data.UserDataWrapper.wrapper._data.numFriendPresentForGPWhileEventMap[_loc2_] = [1];
            }
            else
            {
               gudetama.data.UserDataWrapper.wrapper._data.numFriendPresentForGPWhileEventMap[_loc2_][0]++;
            }
         }
      }
      
      public function isEnabledFriendPresentForGPWhileEvent() : Boolean
      {
         var _loc3_:Array = eventPart.getRankingEventIds(true);
         if(!_loc3_)
         {
            return true;
         }
         var _loc2_:int = GameSetting.getRule().maximumFriendPresentForGPWhileEvent;
         if(_loc2_ <= 0)
         {
            return true;
         }
         for each(var _loc1_ in _loc3_)
         {
            if(gudetama.data.UserDataWrapper.wrapper._data.numFriendPresentForGPWhileEventMap[_loc1_])
            {
               if(gudetama.data.UserDataWrapper.wrapper._data.numFriendPresentForGPWhileEventMap[_loc1_][0] >= _loc2_)
               {
                  return false;
               }
            }
         }
         return true;
      }
      
      public function updateTouchInfo(param1:TouchInfo) : void
      {
         gudetama.data.UserDataWrapper.wrapper._data.touchInfo = param1;
         nextTouchEvent = null;
      }
      
      public function getNextTouchEvent() : TouchEventParam
      {
         if(!nextTouchEvent)
         {
            updateNextTouchEvent();
         }
         return nextTouchEvent;
      }
      
      public function updateNextTouchEvent() : Boolean
      {
         nextTouchEvent = gudetama.data.UserDataWrapper.wrapper._data.touchInfo.next(nextTouchEvent);
         return nextTouchEvent;
      }
      
      public function getTouchBonusRange() : Array
      {
         return gudetama.data.UserDataWrapper.wrapper._data.touchInfo.bonusRange;
      }
      
      public function setDropItemEvent(param1:TouchEventParam) : void
      {
         gudetama.data.UserDataWrapper.wrapper._data.dropItemEvent = param1;
      }
      
      public function removeDropItemEvent() : void
      {
         gudetama.data.UserDataWrapper.wrapper._data.dropItemEvent = null;
      }
      
      public function existsDropItemEvent() : Boolean
      {
         return gudetama.data.UserDataWrapper.wrapper._data.dropItemEvent;
      }
      
      public function getDropItemEvent() : TouchEventParam
      {
         return gudetama.data.UserDataWrapper.wrapper._data.dropItemEvent;
      }
      
      public function setHeavenEvent(param1:TouchEventParam) : void
      {
         gudetama.data.UserDataWrapper.wrapper._data.heavenEvent = param1;
      }
      
      public function removeHeavenEvent() : void
      {
         gudetama.data.UserDataWrapper.wrapper._data.heavenEvent = null;
      }
      
      public function existsHeavenEvent() : Boolean
      {
         return gudetama.data.UserDataWrapper.wrapper._data.heavenEvent;
      }
      
      public function getHeavenEvent() : TouchEventParam
      {
         return gudetama.data.UserDataWrapper.wrapper._data.heavenEvent;
      }
      
      public function setHomeScrollPosition(param1:int) : void
      {
         lastHomeScrollPosition = param1;
      }
      
      public function lastHomeScrollPositionIsRight() : Boolean
      {
         return lastHomeScrollPosition == 0;
      }
      
      public function get hideGudeId() : int
      {
         return _hideGudeId;
      }
      
      public function set hideGudeId(param1:int) : void
      {
         _hideGudeId = param1;
      }
      
      public function get sendTouchCount() : int
      {
         return gudetama.data.UserDataWrapper.wrapper._data.sendTouchCount;
      }
      
      public function set sendTouchCount(param1:int) : void
      {
         gudetama.data.UserDataWrapper.wrapper._data.sendTouchCount = param1;
      }
      
      public function hasHomeDecoData() : Boolean
      {
         if(gudetama.data.UserDataWrapper.wrapper._data && gudetama.data.UserDataWrapper.wrapper._data.homeDecoDataMap)
         {
            return gudetama.data.UserDataWrapper.wrapper._data.homeDecoDataMap[!!GameSetting.getRule().useHomeDecoEachType ? gudetama.data.UserDataWrapper.wrapper._data.decorationId : 0];
         }
         return false;
      }
      
      public function getHomeDecoData() : Array
      {
         var _loc1_:Array = DataStorage.getLocalData().stampDataMap;
         if(_loc1_)
         {
            DataStorage.getLocalData().stampDataMap = null;
            return _loc1_;
         }
         if(!gudetama.data.UserDataWrapper.wrapper._data.homeDecoDataMap)
         {
            return null;
         }
         var _loc2_:Array = gudetama.data.UserDataWrapper.wrapper._data.homeDecoDataMap[!!GameSetting.getRule().useHomeDecoEachType ? gudetama.data.UserDataWrapper.wrapper._data.decorationId : 0];
         if(!_loc2_)
         {
            return null;
         }
         if(_loc2_.length > 0)
         {
            return _loc2_.sort(homedecosort);
         }
         return null;
      }
      
      private function homedecosort(param1:HomeDecoData, param2:HomeDecoData) : int
      {
         return param1.index - param2.index;
      }
      
      public function setHomeDecoData(param1:int, param2:Array) : void
      {
         gudetama.data.UserDataWrapper.wrapper._data.homeDecoDataMap[param1] = param2;
      }
      
      public function getHomeDecoStampNumsMap() : Object
      {
         var _loc1_:* = null;
         var _loc2_:* = null;
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         var _loc6_:Array = DataStorage.getLocalData().stampDataMap;
         var _loc3_:int = 0;
         if(_loc6_)
         {
            _loc3_ = _loc6_.length;
            _loc5_ = 0;
            while(_loc5_ < _loc3_)
            {
               _loc2_ = _loc6_[_loc5_] as HomeDecoData;
               if(!_loc1_)
               {
                  _loc1_ = {};
               }
               if(_loc1_[_loc2_.stampId])
               {
                  _loc4_ = _loc1_[_loc2_.stampId];
                  _loc1_[_loc2_.stampId] = _loc4_ + 1;
               }
               else
               {
                  _loc1_[_loc2_.stampId] = 1;
               }
               _loc5_++;
            }
            return _loc1_;
         }
         if(!gudetama.data.UserDataWrapper.wrapper._data.homeDecoDataMap)
         {
            return _loc1_;
         }
         var _loc7_:Array;
         if(!(_loc7_ = gudetama.data.UserDataWrapper.wrapper._data.homeDecoDataMap[!!GameSetting.getRule().useHomeDecoEachType ? gudetama.data.UserDataWrapper.wrapper._data.decorationId : 0]))
         {
            return _loc1_;
         }
         _loc3_ = _loc7_.length;
         _loc5_ = 0;
         while(_loc5_ < _loc3_)
         {
            _loc2_ = _loc7_[_loc5_] as HomeDecoData;
            if(!_loc1_)
            {
               _loc1_ = {};
            }
            if(_loc1_[_loc2_.stampId])
            {
               _loc4_ = _loc1_[_loc2_.stampId];
               _loc1_[_loc2_.stampId] = _loc4_ + 1;
            }
            else
            {
               _loc1_[_loc2_.stampId] = 1;
            }
            _loc5_++;
         }
         return _loc1_;
      }
      
      public function getHomeDecoStampNum(param1:int) : int
      {
         var _loc2_:* = null;
         var _loc5_:int = 0;
         var _loc6_:Array = DataStorage.getLocalData().stampDataMap;
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         if(_loc6_)
         {
            _loc3_ = _loc6_.length;
            _loc5_ = 0;
            while(_loc5_ < _loc3_)
            {
               _loc2_ = _loc6_[_loc5_] as HomeDecoData;
               if(_loc2_ && _loc2_.stampId == param1)
               {
                  _loc4_++;
               }
               _loc5_++;
            }
            return _loc4_;
         }
         if(!gudetama.data.UserDataWrapper.wrapper._data.homeDecoDataMap)
         {
            return _loc4_;
         }
         var _loc7_:Array;
         _loc3_ = (_loc7_ = gudetama.data.UserDataWrapper.wrapper._data.homeDecoDataMap[!!GameSetting.getRule().useHomeDecoEachType ? gudetama.data.UserDataWrapper.wrapper._data.decorationId : 0]).length;
         _loc5_ = 0;
         while(_loc5_ < _loc3_)
         {
            _loc2_ = _loc7_ as HomeDecoData;
            if(_loc2_ && _loc2_.stampId == param1)
            {
               _loc4_++;
            }
            _loc5_++;
         }
         return _loc4_;
      }
      
      public function updateDisabledOfferwallFlag(param1:Boolean) : void
      {
         disabledOfferwall = param1;
      }
      
      public function isEnabledOfferwall() : Boolean
      {
         return !disabledOfferwall && Engine.isJapanIp();
      }
      
      public function updateMenuItems(param1:Array) : void
      {
         this.menuItems = param1;
      }
      
      public function getMenuItems() : Array
      {
         return menuItems;
      }
      
      public function pushRankingGlobalPointRewardParam(param1:int, param2:int, param3:Array) : void
      {
         rankingGlobalPointRewardParams.push({
            "rankingId":param1,
            "contentId":param2,
            "points":param3
         });
      }
      
      public function popRankingGlobalPointRewardParam() : Object
      {
         return rankingGlobalPointRewardParams.pop();
      }
      
      public function isPurchasable(param1:MetalShopItemDef) : Boolean
      {
         if(param1.limit <= 0 || !gudetama.data.UserDataWrapper.wrapper._data.numPurchaseMap[param1.key])
         {
            return true;
         }
         return gudetama.data.UserDataWrapper.wrapper._data.numPurchaseMap[param1.key][0] < param1.limit;
      }
      
      public function increaseNumPurchase(param1:Array) : void
      {
         for each(var _loc2_ in param1)
         {
            if(!gudetama.data.UserDataWrapper.wrapper._data.numPurchaseMap[_loc2_])
            {
               gudetama.data.UserDataWrapper.wrapper._data.numPurchaseMap[_loc2_] = [1,0];
            }
            else
            {
               gudetama.data.UserDataWrapper.wrapper._data.numPurchaseMap[_loc2_][0]++;
            }
         }
      }
      
      public function isCooking4CupGacha() : Boolean
      {
         return gudetama.data.UserDataWrapper.wrapper._data.cupGachaData.cookIndex >= 0;
      }
      
      public function getCookIndex4CupGacha() : int
      {
         return gudetama.data.UserDataWrapper.wrapper._data.cupGachaData.cookIndex;
      }
      
      public function cookCupGacha(param1:int, param2:int) : void
      {
         gudetama.data.UserDataWrapper.wrapper._data.cupGachaData.cookIndex = param1;
         setCupGachaRestSec(param2);
      }
      
      public function setCupGachaRestSec(param1:int) : void
      {
         gudetama.data.UserDataWrapper.wrapper._data.cupGachaData.restSec = param1;
         cupGachaLastUpdateSec = TimeZoneUtil.epochMillisToOffsetSecs();
      }
      
      public function getCupGachaIndexNoEmpty() : int
      {
         var _loc2_:int = 0;
         var _loc1_:Array = gudetama.data.UserDataWrapper.wrapper._data.cupGachaData.cupGachaIds;
         _loc2_ = 0;
         while(_loc2_ < _loc1_.length)
         {
            if(_loc1_[_loc2_] > 0)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
      
      public function getShowAdNum4CupGacha() : int
      {
         return gudetama.data.UserDataWrapper.wrapper._data.cupGachaData.showAdNum;
      }
      
      public function incrementShowAdNum4CupGacha() : void
      {
         gudetama.data.UserDataWrapper.wrapper._data.cupGachaData.showAdNum++;
      }
      
      public function getRestSec4CupGacha() : int
      {
         var _loc3_:CupGachaData = gudetama.data.UserDataWrapper.wrapper._data.cupGachaData;
         if(_loc3_.restSec <= 0)
         {
            return 0;
         }
         var _loc2_:int = TimeZoneUtil.epochMillisToOffsetSecs();
         var _loc1_:int = _loc2_ - cupGachaLastUpdateSec;
         if(_loc1_ > 0)
         {
            _loc3_.restSec -= _loc1_;
            cupGachaLastUpdateSec = _loc2_;
         }
         return _loc3_.restSec;
      }
      
      public function canAddCupGacha(param1:int) : Boolean
      {
         if(GameSetting.getCupGacha(param1).cookMin == 0)
         {
            return true;
         }
         var _loc2_:Array = gudetama.data.UserDataWrapper.wrapper._data.cupGachaData.cupGachaIds;
         for each(var _loc3_ in _loc2_)
         {
            if(_loc3_ == 0)
            {
               return true;
            }
         }
         return false;
      }
      
      public function getCupGachaIdAt(param1:int) : int
      {
         return gudetama.data.UserDataWrapper.wrapper._data.cupGachaData.cupGachaIds[param1];
      }
      
      public function setCupGachaAt(param1:int, param2:int) : void
      {
         if(param1 < 0)
         {
            return;
         }
         var _loc3_:CupGachaData = gudetama.data.UserDataWrapper.wrapper._data.cupGachaData;
         _loc3_.cupGachaIds[param1] = param2;
         if(param2 == 0 && param1 == _loc3_.cookIndex)
         {
            _loc3_.cookIndex = -1;
            _loc3_.showAdNum = 0;
         }
      }
      
      public function getSameIdCupGachaSlotNum(param1:int) : int
      {
         var _loc2_:int = 0;
         var _loc3_:Array = gudetama.data.UserDataWrapper.wrapper._data.cupGachaData.cupGachaIds;
         for each(var _loc4_ in _loc3_)
         {
            if(param1 == _loc4_)
            {
               _loc2_++;
            }
         }
         return _loc2_;
      }
      
      public function hasCupGachaResult() : Boolean
      {
         return cupGachaResults.length > 0;
      }
      
      public function addCupGachaResult(param1:CupGachaResult) : void
      {
         cupGachaResults.push(param1);
      }
      
      public function showCupGachaResults(param1:int, param2:Function) : void
      {
         var placeGudeId:int = param1;
         var callback:Function = param2;
         var cupResultLen:int = cupGachaResults.length;
         if(cupResultLen == 0)
         {
            if(callback)
            {
               callback();
            }
            return;
         }
         var result:CupGachaResult = cupGachaResults.shift();
         var cupGudeRsrcID:int = GameSetting.getCupGacha(result.id#2).rsrc;
         CupGachaAnimePanel.show(true,cupGudeRsrcID,function(param1:CupGachaAnimePanel):void
         {
            var animePanel:CupGachaAnimePanel = param1;
            CupGachaResultDialog.show(animePanel,result,cupResultLen == 1 ? placeGudeId : 0,function():void
            {
               showCupGachaResults(placeGudeId,callback);
            });
         },null);
      }
      
      public function addCupGachaConditionClearIds(param1:Array) : void
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < param1.length)
         {
            gudetama.data.UserDataWrapper.wrapper._data.cupGachaConditionClearIds.push(param1[_loc2_]);
            _loc2_++;
         }
      }
      
      public function isAvailableCupGacha(param1:int) : Boolean
      {
         var _loc2_:CupGachaDef = GameSetting.getCupGacha(param1);
         if(_loc2_.conditionDesc.length == 0)
         {
            return true;
         }
         return gudetama.data.UserDataWrapper.wrapper._data.cupGachaConditionClearIds.indexOf(param1) >= 0;
      }
      
      public function increaseNumAcquiredIdentifiedPresent(param1:int) : void
      {
         gudetama.data.UserDataWrapper.wrapper._data.numAcquiredIdentifiedPresentMap[param1] = [getNumAcquiredIdentifiedPresent(param1) + 1];
      }
      
      public function getNumAcquiredIdentifiedPresent(param1:int) : int
      {
         var _loc2_:int = 0;
         if(gudetama.data.UserDataWrapper.wrapper._data.numAcquiredIdentifiedPresentMap[param1])
         {
            _loc2_ = gudetama.data.UserDataWrapper.wrapper._data.numAcquiredIdentifiedPresentMap[param1][0];
         }
         return _loc2_;
      }
      
      public function isAcquirableIdentifiedPresent(param1:*) : Boolean
      {
         var _loc2_:IdentifiedPresentDef = GameSetting.getIdentifiedPresent(param1);
         return getNumAcquiredIdentifiedPresent(param1) < _loc2_.limit;
      }
      
      public function updateNumAcquiredIdentifiedPresent(param1:Array) : void
      {
         for each(var _loc2_ in param1)
         {
            delete gudetama.data.UserDataWrapper.wrapper._data.numAcquiredIdentifiedPresentMap[_loc2_];
         }
      }
      
      public function addItems(param1:Array, param2:Array) : void
      {
         var _loc3_:int = 0;
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            addItem(param1[_loc3_],param2[_loc3_]);
            _loc3_++;
         }
      }
      
      public function addItem(param1:ItemParam, param2:*) : void
      {
         var _loc5_:* = null;
         var _loc3_:* = null;
         var _loc4_:int = 0;
         var _loc6_:* = null;
         var _loc8_:int = 0;
         var _loc7_:int = 0;
         var _loc9_:int = 0;
         if(!param2)
         {
            return;
         }
         switch(param1.kind)
         {
            case 0:
               ResidentMenuUI_Gudetama.addFreeMoney(ItemParam(param2).num);
               return;
            case 14:
               ResidentMenuUI_Gudetama.addChargeMoney(ItemParam(param2).num);
               return;
            case 1:
               ResidentMenuUI_Gudetama.addFreeMetal(ItemParam(param2).num);
               return;
            case 2:
               ResidentMenuUI_Gudetama.addChargeMetal(ItemParam(param2).num);
               return;
            case 3:
               addSubMetal(param2);
               return;
            case 4:
               kitchenwarePart.addKitchenware(param2);
               return;
            case 5:
               recipeNotePart.addRecipeNote(param2);
               return;
            case 6:
               break;
            case 7:
               break;
            case 8:
               usefulPart.addUseful(param2);
               return;
            case 10:
               utensilPart.addUtensil(param2);
               return;
            case 9:
               decorationPart.addDecoration(param2);
               return;
            case 12:
               avatarPart.addAvatar(param2);
               return;
            case 11:
               stampPart.addStamp(param2);
               return;
            case 13:
               addComment(param2);
               return;
            case 16:
               _loc3_ = param2[0];
               _loc4_ = param2[1][0];
               if(_loc3_)
               {
                  ResidentMenuUI_Gudetama.addChargeMetal(_loc3_.num);
               }
               setFinishMonthlyBonusTimeSec(_loc4_);
               return;
            case 19:
               if((_loc6_ = param2)[0] is CupGachaResult)
               {
                  _loc8_ = 0;
                  while(_loc8_ < _loc6_.length)
                  {
                     addCupGachaResult(_loc6_[_loc8_]);
                     _loc8_++;
                  }
               }
               else
               {
                  _loc7_ = _loc6_[0];
                  _loc9_ = _loc6_[1];
                  if(_loc7_ >= 0)
                  {
                     setCupGachaAt(_loc7_,_loc9_);
                  }
               }
               return;
            default:
               return;
         }
         addRecipe(param2);
      }
      
      public function useItem(param1:ItemParam) : void
      {
         switch(int(param1.kind))
         {
            case 0:
               ResidentMenuUI_Gudetama.consumeMoney(param1.num);
               return;
            case 1:
               ResidentMenuUI_Gudetama.consumeMetal(param1.num);
               return;
            case 2:
               ResidentMenuUI_Gudetama.consumeChargeMetal(param1.num);
               return;
            case 3:
               consumeSubMetal(param1.num);
               return;
            case 7:
               gudetamaPart.consumeGudetama(param1.id#2,param1.num);
               return;
            case 8:
               usefulPart.consumeUsefulItem(param1);
               return;
            case 14:
               ResidentMenuUI_Gudetama.consumeChargeMoney(param1.num);
               return;
            default:
               return;
         }
      }
      
      public function getNumItem(param1:int, param2:int) : int
      {
         switch(int(param1))
         {
            case 0:
               return getMoney();
            case 1:
               return getMetal();
            case 2:
               return getChargeMetal();
            case 3:
               return getSubMetal();
            case 4:
               return !!kitchenwarePart.hasKitchenware(param2) ? 1 : 0;
            case 5:
               return !!recipeNotePart.hasRecipeNote(param2) ? 1 : 0;
            case 6:
               return !!gudetamaPart.hasRecipe(param2) ? 1 : 0;
            case 7:
               return gudetamaPart.getNumGudetama(param2);
            case 8:
               return usefulPart.getNumUseful(param2);
            case 9:
               return !!decorationPart.hasDecoration(param2) ? 1 : 0;
            case 10:
               return !!utensilPart.hasUtensil(param2) ? 1 : 0;
            case 11:
               return stampPart.getNumStamp(param2);
            case 12:
               return !!hasAvatar(param2) ? 1 : 0;
            case 13:
               return !!hasComment(param2) ? 1 : 0;
            case 14:
               return getChargeMoney();
            default:
               return 0;
         }
      }
      
      public function hasItem(param1:ItemParam) : Boolean
      {
         switch(int(param1.kind))
         {
            case 0:
               return hasMoney(param1.num);
            case 1:
               return hasMetal(param1.num);
            case 2:
               return hasChargeMetal(param1.num);
            case 3:
               return hasSubMetal(param1.num);
            case 4:
               return kitchenwarePart.hasKitchenware(param1.id#2);
            case 5:
               return recipeNotePart.hasRecipeNote(param1.id#2);
            case 6:
               return gudetamaPart.hasRecipe(param1.id#2);
            case 7:
               return gudetamaPart.hasGudetama(param1.id#2,param1.num);
            case 8:
               return usefulPart.hasUsefulItem(param1);
            case 9:
               return decorationPart.hasDecoration(param1.id#2);
            case 10:
               return utensilPart.hasUtensil(param1.id#2);
            case 11:
               return stampPart.hasStampItem(param1);
            case 12:
               return avatarPart.hasAvatar(param1.id#2);
            case 13:
               return hasComment(param1.id#2);
            case 14:
               return hasChargeMoney(param1.num);
            default:
               return false;
         }
      }
      
      public function isItemAddable(param1:ItemParam) : Boolean
      {
         switch(param1.kind)
         {
            case 0:
               break;
            case 14:
               break;
            case 1:
            case 2:
               return isMetalAddable(param1.num);
            case 3:
               return true;
            case 4:
               return !kitchenwarePart.hasKitchenware(param1.id#2);
            case 5:
               return !recipeNotePart.hasRecipeNote(param1.id#2);
            case 6:
               return !gudetamaPart.hasRecipe(param1.id#2);
            case 7:
               return gudetamaPart.isGudetamaAddable(param1.id#2,param1.num);
            case 8:
               return usefulPart.isUsefulAddable(param1);
            case 10:
               return !utensilPart.hasUtensil(param1.id#2);
            case 9:
               return !decorationPart.hasDecoration(param1.id#2);
            case 12:
               return !avatarPart.hasAvatar(param1.id#2);
            case 11:
               return stampPart.isStampAddable(param1);
            case 13:
               return !hasComment(param1.id#2);
            case 16:
               return isPurchasableMonthlyPremiumBonus();
            case 19:
               return canAddCupGacha(param1.id#2);
            default:
               return false;
         }
         return isMoneyAddable(param1.num);
      }
      
      public function isAvailable(param1:ItemParam) : Boolean
      {
         switch(int(param1.kind) - 8)
         {
            case 0:
               return usefulPart.isAvailable(param1.id#2);
            case 1:
               return decorationPart.isAvailable(param1.id#2);
            case 2:
               return utensilPart.isAvailable(param1.id#2);
            case 3:
               return stampPart.isAvailable(param1.id#2);
            case 4:
               return avatarPart.isAvailable(param1.id#2);
            case 11:
               return isAvailableCupGacha(param1.id#2);
            default:
               return false;
         }
      }
      
      private function addComment(param1:ItemParam) : void
      {
         if(param1 == null)
         {
            return;
         }
         gudetama.data.UserDataWrapper.wrapper._data.commentList.push(param1.id#2);
      }
      
      public function hasComment(param1:int) : Boolean
      {
         return gudetama.data.UserDataWrapper.wrapper._data.commentList.indexOf(param1) > -1;
      }
      
      public function isBuyableSetItem(param1:SetItemDef) : Boolean
      {
         if(param1.buyableCount == 0)
         {
            return true;
         }
         var _loc2_:SetItemBuyData = gudetama.data.UserDataWrapper.wrapper._data.setItemBuyMap[param1.id#2];
         if(_loc2_ == null)
         {
            return true;
         }
         return _loc2_.count < param1.buyableCount;
      }
      
      public function getSetItemBuyableCount(param1:SetItemDef) : int
      {
         if(param1.buyableCount == 0)
         {
            return -1;
         }
         var _loc2_:SetItemBuyData = gudetama.data.UserDataWrapper.wrapper._data.setItemBuyMap[param1.id#2];
         if(_loc2_ == null)
         {
            return param1.buyableCount;
         }
         return Math.max(0,param1.buyableCount - _loc2_.count);
      }
   }
}

import gudetama.data.GameSetting;
import gudetama.data.compati.MissionData;
import gudetama.data.compati.MissionDef;
import gudetama.engine.Logger;
import muku.util.StarlingUtil;

class MissionPart
{
    
   
   private var missionTable:Object;
   
   private var idifiedMissionTable:Object;
   
   private var dailyMissionKeyList:Array;
   
   private var nextDailyMissionSupplySecs:int;
   
   private var eventMissionIds:Array;
   
   function MissionPart()
   {
      super();
      init();
   }
   
   public function init() : void
   {
      missionTable = {};
      idifiedMissionTable = {};
      dailyMissionKeyList = [];
      nextDailyMissionSupplySecs = -1;
      eventMissionIds = [];
   }
   
   public function updateMission(param1:Object) : void
   {
      var _loc6_:* = null;
      var _loc9_:* = null;
      var _loc3_:* = null;
      var _loc4_:int = 0;
      var _loc5_:int = 0;
      var _loc8_:int = 0;
      var _loc7_:int = 0;
      var _loc2_:* = null;
      if(param1 is MissionData)
      {
         _loc6_ = param1 as MissionData;
         missionTable[_loc6_.key] = _loc6_;
         if(_loc6_.id#2 > 0)
         {
            idifiedMissionTable[_loc6_.id#2] = _loc6_;
            if((_loc9_ = GameSetting.getMission(_loc6_.id#2)).eventId > 0 && eventMissionIds.indexOf(_loc9_.eventId) < 0)
            {
               eventMissionIds.push(_loc9_.eventId);
            }
         }
         Logger.debug("key:{}, title:{}, value:{}, data:{}",_loc6_.key,_loc6_.title,_loc6_.currentValue,param1);
      }
      else if(param1 is Array)
      {
         _loc3_ = param1 as Array;
         _loc4_ = _loc3_.length;
         try
         {
            _loc5_ = 0;
            while(_loc5_ < _loc4_)
            {
               if(_loc3_[_loc5_] is MissionData)
               {
                  _loc6_ = _loc3_[_loc5_] as MissionData;
                  missionTable[_loc6_.key] = _loc6_;
                  if(_loc6_.id#2 > 0)
                  {
                     idifiedMissionTable[_loc6_.id#2] = _loc6_;
                     if((_loc9_ = GameSetting.getMission(_loc6_.id#2)).eventId > 0 && eventMissionIds.indexOf(_loc9_.eventId) < 0)
                     {
                        eventMissionIds.push(_loc9_.eventId);
                     }
                  }
                  Logger.debug("key:{}, title:{}, value:{}, data:{}",_loc6_.key,_loc6_.title,_loc6_.currentValue,param1);
               }
               else if(_loc3_[_loc5_] is Array)
               {
                  _loc8_ = _loc3_[_loc5_][0];
                  if((_loc7_ = _loc3_[_loc5_][1]) < 0)
                  {
                     Logger.debug("finished mission key:{}",_loc8_);
                     if(_loc6_ = missionTable[_loc8_])
                     {
                        delete missionTable[_loc8_];
                     }
                     if(idifiedMissionTable[_loc6_.id#2])
                     {
                        delete idifiedMissionTable[_loc6_.id#2];
                        if((_loc9_ = GameSetting.getMission(_loc6_.id#2)).eventId > 0 && eventMissionIds.indexOf(_loc9_.eventId) >= 0)
                        {
                           eventMissionIds.removeAt(eventMissionIds.indexOf(_loc9_.eventId));
                        }
                     }
                  }
                  else
                  {
                     _loc2_ = missionTable[_loc8_] as MissionData;
                     if(_loc2_)
                     {
                        _loc2_.currentValue = _loc7_;
                        Logger.debug("key:{}, title:{}, value:{}, data:{}",_loc2_.key,_loc2_.title,_loc2_.currentValue,param1);
                     }
                     else
                     {
                        Logger.info("missionTable[key] is null.key:{}, value:{}, data:{}, missionTable keys:{}",_loc8_,_loc7_,param1,StarlingUtil.toObjectKeyString(missionTable));
                     }
                  }
               }
               _loc5_++;
            }
         }
         catch(error:Error)
         {
            Logger.error("missionTable[key] is null.key:{}, value:{}, data:{}, missionTable keys:{}",_loc8_,_loc7_,param1,StarlingUtil.toObjectKeyString(missionTable));
         }
      }
   }
   
   public function getMissionData(param1:int) : MissionData
   {
      return missionTable[param1];
   }
   
   public function getMissionDataById(param1:int) : MissionData
   {
      return idifiedMissionTable[param1];
   }
   
   public function getMissionTable() : Object
   {
      return missionTable;
   }
   
   public function updateDailyMissionKeyList(param1:Array) : void
   {
      if(!param1)
      {
         return;
      }
      dailyMissionKeyList = param1;
   }
   
   public function getDailyMissionKeyList() : Array
   {
      return dailyMissionKeyList;
   }
   
   public function isDailyMission(param1:int) : Boolean
   {
      return dailyMissionKeyList.indexOf(param1) >= 0;
   }
   
   public function isCleared(param1:int) : Boolean
   {
      var _loc2_:MissionData = getMissionData(param1);
      if(!_loc2_)
      {
         return false;
      }
      return _loc2_.currentValue >= _loc2_.goal;
   }
   
   public function isClearedById(param1:int) : Boolean
   {
      var _loc2_:MissionData = getMissionDataById(param1);
      if(!_loc2_)
      {
         return false;
      }
      return _loc2_.currentValue >= _loc2_.goal;
   }
   
   public function setNextDailyMissionSupplySecs(param1:int) : void
   {
      nextDailyMissionSupplySecs = param1;
   }
   
   public function getNextDailyMissionSupplySecs() : int
   {
      return nextDailyMissionSupplySecs;
   }
   
   public function getNumEventMission() : int
   {
      return eventMissionIds.length;
   }
}

import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.KitchenwareData;
import gudetama.data.compati.KitchenwareDef;
import gudetama.data.compati.KitchenwareParam;
import gudetama.data.compati.UserData;
import gudetama.util.TimeZoneUtil;

class KitchenwarePart
{
    
   
   private var data:UserData;
   
   private var newlyActivatedKitchenwares:Array;
   
   private var updateTimeMap:Object;
   
   private var updateRestTimeMapOneTime:Object;
   
   function KitchenwarePart()
   {
      newlyActivatedKitchenwares = [];
      updateTimeMap = {};
      updateRestTimeMapOneTime = {};
      super();
   }
   
   public function init(param1:UserData) : void
   {
      data = param1;
      for(var _loc2_ in data.kitchenwareMap)
      {
         updateTimeMap[_loc2_] = TimeZoneUtil.epochMillisToOffsetSecs();
      }
   }
   
   public function updateKitchenwareMap(param1:Object) : void
   {
      for each(var _loc2_ in param1)
      {
         addKitchenware(_loc2_);
      }
   }
   
   public function getKitchenwareMap() : Object
   {
      return data.kitchenwareMap;
   }
   
   public function hasKitchenwareTypes() : Boolean
   {
      var _loc3_:int = 0;
      var _loc1_:* = null;
      var _loc2_:int = 0;
      _loc3_ = 0;
      while(_loc3_ < 5)
      {
         _loc1_ = UserDataWrapper.kitchenwarePart.getKitchenwareByType(_loc3_);
         if(_loc1_ != null)
         {
            if(isAvailableByKitchenware(_loc1_,0,!_loc1_.isCooking()))
            {
               _loc2_++;
               if(_loc2_ >= 2)
               {
                  return true;
               }
            }
         }
         _loc3_++;
      }
      return false;
   }
   
   public function getKitchenwareIdMap() : Object
   {
      var _loc2_:Object = {};
      for each(var _loc1_ in data.kitchenwareMap)
      {
         for(var _loc3_ in _loc1_.paramMap)
         {
            _loc2_[_loc3_] = _loc1_;
         }
      }
      return _loc2_;
   }
   
   public function addKitchenware(param1:KitchenwareData) : void
   {
      var _loc5_:* = 0;
      var _loc3_:* = null;
      var _loc2_:* = null;
      if(!param1)
      {
         return;
      }
      var _loc4_:KitchenwareData;
      if(_loc4_ = data.kitchenwareMap[param1.type])
      {
         for(_loc5_ in param1.paramMap)
         {
            _loc3_ = param1.paramMap[_loc5_];
            _loc2_ = _loc4_.paramMap[_loc5_];
            if(_loc3_.available && (!_loc2_ || !_loc2_.available))
            {
               newlyActivatedKitchenwares.push(_loc5_);
            }
         }
      }
      else
      {
         for(_loc5_ in param1.paramMap)
         {
            _loc3_ = param1.paramMap[_loc5_];
            if(_loc3_.available)
            {
               newlyActivatedKitchenwares.push(_loc5_);
            }
         }
      }
      data.kitchenwareMap[param1.type] = param1;
      updateTimeMap[param1.type] = TimeZoneUtil.epochMillisToOffsetSecs();
   }
   
   public function addKitchenwares(param1:Array) : void
   {
      for each(var _loc2_ in param1)
      {
         addKitchenware(_loc2_);
      }
   }
   
   public function popNewlyActivatedKitchenware() : int
   {
      return newlyActivatedKitchenwares.pop();
   }
   
   public function addNewlyActivatedKitchenware(param1:int) : void
   {
      newlyActivatedKitchenwares.push(param1);
   }
   
   public function getKitchenwareByType(param1:int) : KitchenwareData
   {
      return data.kitchenwareMap[param1];
   }
   
   public function hasKitchenwareByType(param1:int, param2:Boolean = false) : Boolean
   {
      var _loc3_:* = null;
      if(!param2 || param1 != 4)
      {
         return data.kitchenwareMap[param1];
      }
      var _loc4_:KitchenwareData;
      if((_loc4_ = data.kitchenwareMap[param1]) == null)
      {
         return false;
      }
      for(var _loc5_ in _loc4_.paramMap)
      {
         _loc3_ = GameSetting.getKitchenware(_loc5_);
         if(inTermEventKitchenware(_loc3_,true))
         {
            return true;
         }
      }
      return false;
   }
   
   public function hasKitchenware(param1:int) : Boolean
   {
      var _loc4_:KitchenwareDef;
      var _loc3_:int = (_loc4_ = GameSetting.getKitchenware(param1)).type;
      if(!hasKitchenwareByType(_loc3_))
      {
         return false;
      }
      var _loc2_:KitchenwareData = getKitchenwareByType(_loc3_);
      return _loc2_.paramMap[param1];
   }
   
   public function isAvailableGrade(param1:int, param2:int = 0, param3:Boolean = false) : Boolean
   {
      var _loc4_:KitchenwareData = getKitchenwareByType(param1);
      return isAvailableByKitchenwareGrade(_loc4_,param2,param3);
   }
   
   public function isAvailableByKitchenwareGrade(param1:KitchenwareData, param2:int = 0, param3:Boolean = false) : Boolean
   {
      var _loc6_:* = null;
      var _loc4_:* = null;
      if(!param1)
      {
         return false;
      }
      var _loc7_:* = param1.type == 4;
      for(var _loc5_ in param1.paramMap)
      {
         _loc6_ = GameSetting.getKitchenware(_loc5_);
         if(!(_loc7_ && !inTermEventKitchenware(_loc6_,param3)))
         {
            if(_loc6_.grade == param2)
            {
               return (_loc4_ = param1.paramMap[_loc5_]).available;
            }
         }
      }
      return false;
   }
   
   public function isAvailable(param1:int, param2:int = 0, param3:Boolean = false) : Boolean
   {
      var _loc4_:KitchenwareData = getKitchenwareByType(param1);
      return isAvailableByKitchenware(_loc4_,param2,param3);
   }
   
   public function isAvailableByKitchenware(param1:KitchenwareData, param2:int = 0, param3:Boolean = false, param4:int = 0) : Boolean
   {
      var _loc8_:* = null;
      var _loc5_:* = null;
      var _loc6_:*;
      if(_loc6_ = param4 == 3)
      {
         trace("isAvailableByKitchenware kitchenware : " + param1);
      }
      if(!param1)
      {
         return false;
      }
      var _loc9_:* = param1.type == 4;
      for(var _loc7_ in param1.paramMap)
      {
         _loc8_ = GameSetting.getKitchenware(_loc7_);
         if(!(_loc9_ && !inTermEventKitchenware(_loc8_,param3)))
         {
            if(_loc8_.grade == param2)
            {
               _loc5_ = param1.paramMap[_loc7_];
               if(_loc6_)
               {
                  trace("isAvailableByKitchenware : " + data.kitchenwareMap[param4]);
               }
               return _loc5_.available;
            }
         }
      }
      return false;
   }
   
   private function inTermEventKitchenware(param1:KitchenwareDef, param2:Boolean) : Boolean
   {
      var _loc3_:int = 0;
      if(param1.eventIds == null)
      {
         return false;
      }
      _loc3_ = 0;
      while(_loc3_ < param1.eventIds.length)
      {
         if(UserDataWrapper.eventPart.inTerm(param1.eventIds[_loc3_],param2))
         {
            return true;
         }
         _loc3_++;
      }
      return false;
   }
   
   public function getHighestGradeKitchenwareId(param1:int) : int
   {
      var _loc2_:KitchenwareData = getKitchenwareByType(param1);
      return getHighestGradeKitchenwareIdByKitchenware(_loc2_);
   }
   
   public function getHighestGradeKitchenwareIdByKitchenware(param1:KitchenwareData) : int
   {
      var _loc4_:* = 0;
      var _loc2_:* = null;
      var _loc6_:* = null;
      if(!param1)
      {
         return 0;
      }
      var _loc3_:int = -1;
      for(var _loc5_ in param1.paramMap)
      {
         _loc2_ = param1.paramMap[_loc5_];
         if(_loc2_.available)
         {
            if((_loc6_ = GameSetting.getKitchenware(_loc5_)).grade > _loc3_)
            {
               _loc3_ = _loc6_.grade;
               _loc4_ = _loc5_;
            }
         }
      }
      return _loc4_;
   }
   
   public function getKitichenwareHighestGrade(param1:int) : int
   {
      var _loc3_:* = null;
      var _loc6_:* = null;
      var _loc2_:KitchenwareData = getKitchenwareByType(param1);
      if(!_loc2_)
      {
         return 0;
      }
      var _loc4_:int = -1;
      for(var _loc5_ in _loc2_.paramMap)
      {
         _loc3_ = _loc2_.paramMap[_loc5_];
         if(_loc3_.available)
         {
            if((_loc6_ = GameSetting.getKitchenware(_loc5_)).grade > _loc4_)
            {
               _loc4_ = _loc6_.grade;
            }
         }
      }
      return _loc4_;
   }
   
   public function isCooking(param1:int) : Boolean
   {
      var _loc2_:KitchenwareData = getKitchenwareByType(param1);
      return isCookingByKitchenware(_loc2_);
   }
   
   public function isCookingByKitchenware(param1:KitchenwareData) : Boolean
   {
      if(!param1)
      {
         return false;
      }
      return param1.recipeNoteId > 0;
   }
   
   public function isCookingTooMatchTime(param1:int) : Boolean
   {
      if(!isCooking(param1))
      {
         return false;
      }
      return -getRestCookingTime(param1) >= GameSetting.getRule().cookingTooMatchTimeHours * 60 * 60;
   }
   
   public function getRestCookingTimeByKitchenware(param1:KitchenwareData) : int
   {
      var _loc3_:int = TimeZoneUtil.epochMillisToOffsetSecs();
      var _loc2_:int = _loc3_ - updateTimeMap[param1.type];
      if(_loc2_ > 0)
      {
         param1.restTimeSecs -= _loc2_;
         updateTimeMap[param1.type] = _loc3_;
      }
      return param1.restTimeSecs;
   }
   
   public function getRestCookingTimeByKitchenwareOneTime(param1:KitchenwareData) : int
   {
      var _loc3_:int = TimeZoneUtil.epochMillisToOffsetSecs();
      if(!updateRestTimeMapOneTime[param1.type])
      {
         updateRestTimeMapOneTime[param1.type] = _loc3_;
      }
      var _loc2_:int = _loc3_ - updateRestTimeMapOneTime[param1.type];
      if(_loc2_ > 0)
      {
         param1.restTimeSecs -= _loc2_;
         updateRestTimeMapOneTime[param1.type] = _loc3_;
      }
      return param1.restTimeSecs;
   }
   
   public function resetUpdateRestTimeMapOnetime() : void
   {
      updateRestTimeMapOneTime = {};
   }
   
   public function getRestCookingTime(param1:int) : int
   {
      if(!isCooking(param1))
      {
         return 0;
      }
      var _loc2_:KitchenwareData = getKitchenwareByType(param1);
      return getRestCookingTimeByKitchenware(_loc2_);
   }
   
   public function finishedCooking(param1:int) : Boolean
   {
      if(!isCooking(param1))
      {
         return false;
      }
      return getRestCookingTime(param1) < 0;
   }
   
   public function finishedCookingByKitchenware(param1:KitchenwareData) : Boolean
   {
      if(!isCookingByKitchenware(param1))
      {
         return false;
      }
      return getRestCookingTimeByKitchenware(param1) < 0;
   }
   
   public function finishedCookingByKitchenwareOneTime(param1:KitchenwareData) : Boolean
   {
      if(!isCookingByKitchenware(param1))
      {
         return false;
      }
      return getRestCookingTimeByKitchenwareOneTime(param1) < 0;
   }
   
   public function getGudetamaId(param1:int) : int
   {
      var _loc2_:KitchenwareData = getKitchenwareByType(param1);
      if(!_loc2_)
      {
         return 0;
      }
      return _loc2_.gudetamaId;
   }
   
   public function getKitchenwareTypes() : Array
   {
      var _loc1_:Array = [];
      for(var _loc2_ in data.kitchenwareMap)
      {
         _loc1_.push(_loc2_);
      }
      _loc1_.sort(ascendingSortFunc);
      return _loc1_;
   }
   
   private function ascendingSortFunc(param1:int, param2:int) : Number
   {
      if(param1 > param2)
      {
         return 1;
      }
      if(param1 < param2)
      {
         return -1;
      }
      return 0;
   }
   
   public function getNumCompleted(param1:Object) : int
   {
      var _loc3_:int = 0;
      for each(var _loc2_ in param1)
      {
         if(finishedCookingByKitchenware(_loc2_))
         {
            _loc3_++;
         }
      }
      return _loc3_;
   }
   
   public function getNumCooking(param1:Object) : int
   {
      var _loc3_:int = 0;
      for each(var _loc2_ in param1)
      {
         if(!finishedCookingByKitchenware(_loc2_) && isCookingByKitchenware(_loc2_))
         {
            _loc3_++;
         }
      }
      return _loc3_;
   }
   
   public function getNumEmpty(param1:Object) : int
   {
      var _loc3_:int = 0;
      for each(var _loc2_ in param1)
      {
         if(isAvailableByKitchenware(_loc2_,0,true) && !isCookingByKitchenware(_loc2_))
         {
            _loc3_++;
         }
      }
      return _loc3_;
   }
   
   public function getMinimumCompletedType() : int
   {
      var _loc2_:int = -1;
      for each(var _loc1_ in data.kitchenwareMap)
      {
         if(finishedCookingByKitchenware(_loc1_))
         {
            if(_loc2_ < 0)
            {
               _loc2_ = _loc1_.type;
            }
            else
            {
               _loc2_ = Math.min(_loc2_,_loc1_.type);
            }
         }
      }
      return _loc2_;
   }
   
   public function getMinimumCookingType() : int
   {
      var _loc2_:int = -1;
      for each(var _loc1_ in data.kitchenwareMap)
      {
         if(!(finishedCookingByKitchenware(_loc1_) || !isCookingByKitchenware(_loc1_)))
         {
            if(_loc2_ < 0)
            {
               _loc2_ = _loc1_.type;
            }
            else
            {
               _loc2_ = Math.min(_loc2_,_loc1_.type);
            }
         }
      }
      return _loc2_;
   }
   
   public function getMinimumEmptyType() : int
   {
      var _loc2_:int = -1;
      for each(var _loc1_ in data.kitchenwareMap)
      {
         if(isAvailableByKitchenware(_loc1_,0,true))
         {
            if(!isCookingByKitchenware(_loc1_))
            {
               if(_loc2_ < 0)
               {
                  _loc2_ = _loc1_.type;
               }
               else
               {
                  _loc2_ = Math.min(_loc2_,_loc1_.type);
               }
            }
         }
      }
      return _loc2_;
   }
   
   public function getKitchenwareGrades(param1:int) : Array
   {
      var _loc3_:Array = [];
      var _loc2_:Object = GameSetting.getKitchenwareMap();
      for each(var _loc4_ in _loc2_)
      {
         if(_loc4_.type == param1)
         {
            _loc3_.push(_loc4_.grade);
         }
      }
      _loc3_.sort(ascendingSortFunc);
      return _loc3_;
   }
}

import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.KitchenwareDef;
import gudetama.data.compati.RecipeNoteData;
import gudetama.data.compati.RecipeNoteDef;
import gudetama.data.compati.UserData;

class RecipeNotePart
{
    
   
   private var data:UserData;
   
   private var newlyActivatedRecipeNotes:Array;
   
   function RecipeNotePart()
   {
      newlyActivatedRecipeNotes = [];
      super();
   }
   
   public function init(param1:UserData) : void
   {
      data = param1;
   }
   
   public function addRecipeNote(param1:RecipeNoteData) : void
   {
      if(!param1)
      {
         return;
      }
      var _loc2_:RecipeNoteData = data.recipeNoteMap[param1.id#2];
      if(_loc2_)
      {
         if(!_loc2_.purchased && param1.purchased)
         {
            newlyActivatedRecipeNotes.push(param1);
         }
      }
      else if(param1.purchased)
      {
         newlyActivatedRecipeNotes.push(param1);
      }
      checkNewRecipe(param1);
      data.recipeNoteMap[param1.id#2] = param1;
   }
   
   private function checkNewRecipe(param1:RecipeNoteData) : void
   {
      var _loc4_:Boolean = false;
      if(!param1.available || !param1.purchased)
      {
         return;
      }
      var _loc3_:int = -1;
      var _loc5_:RecipeNoteDef;
      if(!(_loc5_ = GameSetting.getRecipeNote(param1.id#2)))
      {
         return;
      }
      var _loc6_:KitchenwareDef;
      if(_loc6_ = GameSetting.getKitchenware(_loc5_.kitchenwareId))
      {
         if(!UserDataWrapper.kitchenwarePart.isAvailable(_loc6_.type,_loc6_.grade,true))
         {
            return;
         }
         _loc3_ = _loc6_.type;
      }
      if(_loc3_ < 0)
      {
         return;
      }
      for each(var _loc2_ in _loc5_.defaults)
      {
         _loc4_ = UserDataWrapper.gudetamaPart.isNewGudetama(_loc2_);
         UserDataWrapper.wrapper.updateNewRecipe(_loc3_,_loc2_,UserDataWrapper.gudetamaPart.isAvailable(_loc2_) && _loc4_);
         checkNewUnlockRecipe(UserDataWrapper.gudetamaPart.getUnlockableGudetamaIdsByID(_loc2_));
      }
      for each(_loc2_ in _loc5_.appends)
      {
         _loc4_ = UserDataWrapper.gudetamaPart.isNewGudetama(_loc2_);
         UserDataWrapper.wrapper.updateNewRecipe(_loc3_,_loc2_,UserDataWrapper.gudetamaPart.isAvailable(_loc2_) && _loc4_);
         checkNewUnlockRecipe(UserDataWrapper.gudetamaPart.getUnlockableGudetamaIdsByID(_loc2_));
      }
   }
   
   public function checkNewUnlockRecipe(param1:Array) : void
   {
      var _loc4_:int = 0;
      var _loc2_:int = 0;
      var _loc8_:int = 0;
      var _loc6_:* = null;
      var _loc7_:* = null;
      var _loc5_:Boolean = false;
      var _loc3_:int = 0;
      if(param1 && param1.length > 0)
      {
         _loc4_ = -1;
         _loc3_ = 0;
         for(; _loc3_ < param1.length; _loc3_++)
         {
            _loc2_ = param1[_loc3_];
            _loc8_ = GameSetting.getRecipeNotoId(_loc2_);
            _loc6_ = GameSetting.getRecipeNote(_loc8_);
            if(_loc7_ = GameSetting.getKitchenware(_loc6_.kitchenwareId))
            {
               if(!UserDataWrapper.kitchenwarePart.isAvailable(_loc7_.type,_loc7_.grade,true))
               {
                  continue;
               }
               _loc4_ = _loc7_.type;
            }
            _loc5_ = UserDataWrapper.gudetamaPart.isNewGudetama(_loc2_);
            UserDataWrapper.wrapper.updateNewRecipe(_loc4_,_loc2_,UserDataWrapper.gudetamaPart.isAvailable(_loc2_) && _loc5_);
         }
      }
   }
   
   public function addRecipeNotes(param1:Array) : void
   {
      for each(var _loc2_ in param1)
      {
         addRecipeNote(_loc2_);
      }
   }
   
   public function popNewlyActivatedRecipeNote() : RecipeNoteData
   {
      return newlyActivatedRecipeNotes.pop();
   }
   
   public function getRecipeNote(param1:int) : RecipeNoteData
   {
      return data.recipeNoteMap[param1];
   }
   
   public function getRecipeNoteMap() : Object
   {
      return data.recipeNoteMap;
   }
   
   public function hasRecipeNote(param1:int) : Boolean
   {
      return data.recipeNoteMap[param1];
   }
   
   public function isVisible(param1:int) : Boolean
   {
      var _loc2_:RecipeNoteData = getRecipeNote(param1);
      if(!_loc2_)
      {
         return false;
      }
      return _loc2_.visible;
   }
   
   public function isAvailable(param1:int) : Boolean
   {
      var _loc2_:RecipeNoteData = getRecipeNote(param1);
      if(!_loc2_)
      {
         return false;
      }
      return _loc2_.available;
   }
   
   public function isPurchased(param1:int) : Boolean
   {
      var _loc2_:RecipeNoteData = getRecipeNote(param1);
      if(!_loc2_)
      {
         return false;
      }
      return _loc2_.purchased;
   }
   
   public function getPurchasedRecipeNoteMap() : Object
   {
      var _loc2_:Object = {};
      for(var _loc1_ in data.recipeNoteMap)
      {
         if(isPurchased(_loc1_))
         {
            _loc2_[_loc1_] = getRecipeNote(_loc1_);
         }
      }
      return _loc2_;
   }
}

import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.GudetamaData;
import gudetama.data.compati.GudetamaDef;
import gudetama.data.compati.ItemParam;
import gudetama.data.compati.KitchenwareDef;
import gudetama.data.compati.RecipeNoteDef;
import gudetama.data.compati.UserData;

class GudetamaPart
{
    
   
   private var data:UserData;
   
   function GudetamaPart()
   {
      super();
   }
   
   public function init(param1:UserData) : void
   {
      var _loc5_:Boolean = false;
      var _loc4_:int = 0;
      var _loc3_:* = null;
      var _loc6_:* = null;
      var _loc7_:* = null;
      data = param1;
      for each(var _loc2_ in data.gudetamaMap)
      {
         if(_loc5_ = isNewGudetama(_loc2_.id#2))
         {
            _loc4_ = -1;
            _loc3_ = GameSetting.getGudetama(_loc2_.id#2);
            if(_loc6_ = GameSetting.getRecipeNote(_loc3_.recipeNoteId))
            {
               if(!UserDataWrapper.recipeNotePart.isAvailable(_loc6_.id#2) || !UserDataWrapper.recipeNotePart.isPurchased(_loc6_.id#2))
               {
                  continue;
               }
               if(_loc7_ = GameSetting.getKitchenware(_loc6_.kitchenwareId))
               {
                  if(!UserDataWrapper.kitchenwarePart.isAvailable(_loc7_.type,_loc7_.grade,true))
                  {
                     continue;
                  }
                  _loc4_ = _loc7_.type;
               }
            }
            if(_loc4_ >= 0)
            {
               if(!(_loc6_.happeningIds && _loc6_.happeningIds.indexOf(_loc2_.id#2) >= 0))
               {
                  UserDataWrapper.wrapper.updateNewRecipe(_loc4_,_loc2_.id#2,UserDataWrapper.gudetamaPart.isAvailable(_loc2_.id#2) && _loc5_);
               }
            }
         }
      }
   }
   
   public function addRecipe(param1:GudetamaData) : void
   {
      data.gudetamaMap[param1.id#2] = param1;
      checkNewRecipe(param1);
   }
   
   private function checkNewRecipe(param1:GudetamaData) : void
   {
      var _loc7_:* = null;
      var _loc5_:Boolean = false;
      var _loc4_:int = -1;
      var _loc3_:GudetamaDef = GameSetting.getGudetama(param1.id#2);
      var _loc6_:RecipeNoteDef;
      if(_loc6_ = GameSetting.getRecipeNote(_loc3_.recipeNoteId))
      {
         if(!UserDataWrapper.recipeNotePart.isAvailable(_loc6_.id#2) || !UserDataWrapper.recipeNotePart.isPurchased(_loc6_.id#2))
         {
            return;
         }
         if(_loc7_ = GameSetting.getKitchenware(_loc6_.kitchenwareId))
         {
            if(!UserDataWrapper.kitchenwarePart.isAvailable(_loc7_.type,_loc7_.grade,true))
            {
               return;
            }
            _loc4_ = _loc7_.type;
         }
      }
      if(_loc4_ < 0)
      {
         return;
      }
      var _loc2_:Boolean = false;
      if(_loc6_.happeningIds && _loc6_.happeningIds.indexOf(param1.id#2) >= 0)
      {
         _loc2_ = true;
      }
      if(!_loc2_)
      {
         _loc5_ = isNewGudetama(param1.id#2);
         UserDataWrapper.wrapper.updateNewRecipe(_loc4_,param1.id#2,UserDataWrapper.gudetamaPart.isAvailable(param1.id#2) && _loc5_);
      }
      UserDataWrapper.recipeNotePart.checkNewUnlockRecipe(UserDataWrapper.gudetamaPart.getUnlockableGudetamaIdsByID(param1.id#2));
   }
   
   public function addRecipes(param1:Array) : void
   {
      for each(var _loc2_ in param1)
      {
         addRecipe(_loc2_);
      }
   }
   
   public function hasRecipe(param1:int) : Boolean
   {
      return data.gudetamaMap[param1];
   }
   
   public function getGudetama(param1:int) : GudetamaData
   {
      return data.gudetamaMap[param1];
   }
   
   public function getGudetamaMap() : Object
   {
      return data.gudetamaMap;
   }
   
   public function getNumGudetama(param1:int) : int
   {
      var _loc2_:GudetamaData = getGudetama(param1);
      if(!_loc2_)
      {
         return 0;
      }
      return _loc2_.num;
   }
   
   public function isCooked(param1:int) : Boolean
   {
      var _loc2_:GudetamaData = getGudetama(param1);
      if(!_loc2_)
      {
         return false;
      }
      return _loc2_.count > 0;
   }
   
   public function isCookedHappening(param1:int) : Boolean
   {
      var _loc2_:GudetamaData = getGudetama(param1);
      if(!_loc2_)
      {
         return false;
      }
      return _loc2_.cookedHappening;
   }
   
   public function isCookedFailure(param1:int) : Boolean
   {
      var _loc2_:GudetamaData = getGudetama(param1);
      if(!_loc2_)
      {
         return false;
      }
      return _loc2_.cookedFailure;
   }
   
   public function isAvailable(param1:int) : Boolean
   {
      var _loc2_:GudetamaData = getGudetama(param1);
      if(!_loc2_)
      {
         return false;
      }
      return _loc2_.available;
   }
   
   public function canUnlockable(param1:int) : Boolean
   {
      return !isUnlocked(param1) && isAvailable(param1) && hasRequiredGudetama(param1) && isUnlockable(param1);
   }
   
   public function isNewGudetama(param1:int) : Boolean
   {
      if(isCooked(param1))
      {
         return false;
      }
      if(!isUnlocked(param1) && isAvailable(param1) && hasRequiredGudetama(param1))
      {
         if(isUnlockable(param1))
         {
            return true;
         }
         return false;
      }
      return true;
   }
   
   public function isUnlockable(param1:int) : Boolean
   {
      var _loc3_:GudetamaDef = GameSetting.getGudetama(param1);
      if(!_loc3_.requiredGudetamas)
      {
         return true;
      }
      var _loc4_:* = true;
      for each(var _loc2_ in _loc3_.requiredGudetamas)
      {
         if(_loc4_)
         {
            _loc4_ = getNumGudetama(_loc2_.id#2) >= _loc2_.num;
         }
      }
      return _loc4_;
   }
   
   public function hasUnlockable(param1:int, param2:int) : Boolean
   {
      var _loc5_:GudetamaDef;
      if(!(_loc5_ = GameSetting.getGudetama(param1)).requiredGudetamas)
      {
         return true;
      }
      var _loc6_:* = true;
      var _loc3_:Boolean = false;
      for each(var _loc4_ in _loc5_.requiredGudetamas)
      {
         if(_loc4_.id#2 == param2)
         {
            _loc3_ = true;
         }
         if(_loc6_)
         {
            _loc6_ = getNumGudetama(_loc4_.id#2) >= _loc4_.num;
         }
      }
      return _loc6_ && _loc3_;
   }
   
   public function getUnlockableGudetamaIds() : Array
   {
      var _loc2_:* = null;
      var _loc3_:* = null;
      var _loc4_:int = 0;
      var _loc1_:Object = GameSetting.getGudetamaMap();
      for each(_loc2_ in _loc1_)
      {
         if(_loc2_.requiredGudetamas)
         {
            if(!isCooked(_loc2_.id#2))
            {
               if(isAvailable(_loc2_.id#2))
               {
                  if(!isUnlocked(_loc2_.id#2))
                  {
                     if((_loc4_ = GameSetting.getRecipeNotoId(_loc2_.id#2)) != -1)
                     {
                        if(UserDataWrapper.recipeNotePart.isAvailable(_loc4_))
                        {
                           if(UserDataWrapper.recipeNotePart.isPurchased(_loc4_))
                           {
                              if(isUnlockable(_loc2_.id#2))
                              {
                                 if(!_loc3_)
                                 {
                                    _loc3_ = [];
                                 }
                                 _loc3_.push(_loc2_.id#2);
                              }
                           }
                        }
                     }
                  }
               }
            }
         }
      }
      return _loc3_;
   }
   
   public function getUnlockableGudetamaIdsByID(param1:int) : Array
   {
      var _loc3_:* = null;
      var _loc4_:* = null;
      var _loc5_:int = 0;
      if(param1 == -1)
      {
         return null;
      }
      var _loc2_:Object = GameSetting.getGudetamaMap();
      for each(_loc3_ in _loc2_)
      {
         if(_loc3_.requiredGudetamas)
         {
            if(!isCooked(_loc3_.id#2))
            {
               if(isAvailable(_loc3_.id#2))
               {
                  if(!isUnlocked(_loc3_.id#2))
                  {
                     if((_loc5_ = GameSetting.getRecipeNotoId(_loc3_.id#2)) != -1)
                     {
                        if(UserDataWrapper.recipeNotePart.isAvailable(_loc5_))
                        {
                           if(UserDataWrapper.recipeNotePart.isPurchased(_loc5_))
                           {
                              if(hasUnlockable(_loc3_.id#2,param1))
                              {
                                 if(!_loc4_)
                                 {
                                    _loc4_ = [];
                                 }
                                 _loc4_.push(_loc3_.id#2);
                              }
                           }
                        }
                     }
                  }
               }
            }
         }
      }
      return _loc4_;
   }
   
   public function hasRequiredGudetama(param1:int) : Boolean
   {
      var _loc2_:GudetamaDef = GameSetting.getGudetama(param1);
      if(!_loc2_.requiredGudetamas)
      {
         return false;
      }
      return true;
   }
   
   public function isUnlocked(param1:int) : Boolean
   {
      var _loc2_:GudetamaData = getGudetama(param1);
      if(!_loc2_)
      {
         return false;
      }
      return _loc2_.unlocked;
   }
   
   public function isAlreadyChallenge(param1:int) : Boolean
   {
      var _loc2_:GudetamaData = getGudetama(param1);
      if(!_loc2_)
      {
         return false;
      }
      return _loc2_.alreadyChallenge;
   }
   
   public function consumeGudetama(param1:int, param2:int) : void
   {
      var _loc3_:GudetamaData = getGudetama(param1);
      if(!_loc3_ || param2 <= 0 || _loc3_.num < param2)
      {
         throw new Error();
      }
      _loc3_.num -= param2;
   }
   
   public function setGudetamaNum(param1:int, param2:int) : void
   {
      var _loc3_:GudetamaData = getGudetama(param1);
      if(_loc3_ == null)
      {
         return;
      }
      if(param2 < 0)
      {
         throw new Error();
      }
      _loc3_.num = param2;
   }
   
   public function hasGudetama(param1:int, param2:int) : Boolean
   {
      var _loc3_:GudetamaData = getGudetama(param1);
      if(!_loc3_)
      {
         return false;
      }
      return _loc3_.num >= param2;
   }
   
   public function isGudetamaAddable(param1:int, param2:int) : Boolean
   {
      var _loc4_:int = 0;
      var _loc3_:GudetamaData = getGudetama(param1);
      if(_loc3_)
      {
         _loc4_ = _loc3_.num;
      }
      return _loc4_ <= 999 - param2;
   }
   
   public function unlockVoice(param1:int, param2:int) : void
   {
      var _loc3_:GudetamaData = getGudetama(param1);
      if(!_loc3_)
      {
         return;
      }
      _loc3_.unlockedVoiceIndex |= 1 << param2;
   }
   
   public function isUnlockedVoice(param1:int, param2:int) : Boolean
   {
      var _loc3_:GudetamaData = getGudetama(param1);
      if(!_loc3_)
      {
         return false;
      }
      return (_loc3_.unlockedVoiceIndex & 1 << param2) != 0;
   }
   
   public function getNumUnlockedVoice(param1:int) : int
   {
      var _loc4_:int = 0;
      var _loc2_:GudetamaData = getGudetama(param1);
      if(!_loc2_)
      {
         return 0;
      }
      var _loc3_:int = 0;
      _loc4_ = 0;
      while(_loc4_ < 2)
      {
         if((_loc2_.unlockedVoiceIndex & 1 << _loc4_) != 0)
         {
            _loc3_++;
         }
         _loc4_++;
      }
      return _loc3_;
   }
   
   public function hasCookableGP(param1:int) : Boolean
   {
      var _loc2_:GudetamaDef = GameSetting.getGudetama(param1);
      if(data.chargeMoney + data.freeMoney >= _loc2_.cost)
      {
         return true;
      }
      return false;
   }
   
   public function getCookableGudetamaIds(param1:int) : Array
   {
      var _loc3_:Array = [];
      var _loc4_:RecipeNoteDef;
      if(!(_loc4_ = GameSetting.getRecipeNote(param1)))
      {
         return _loc3_;
      }
      for each(var _loc2_ in _loc4_.defaults)
      {
         if(hasRecipe(_loc2_))
         {
            _loc3_.push(_loc2_);
         }
      }
      for each(_loc2_ in _loc4_.appends)
      {
         if(hasRecipe(_loc2_))
         {
            _loc3_.push(_loc2_);
         }
      }
      return _loc3_;
   }
   
   public function isHappening(param1:int) : Boolean
   {
      var _loc2_:GudetamaDef = GameSetting.getGudetama(param1);
      var _loc3_:RecipeNoteDef = GameSetting.getRecipeNote(_loc2_.recipeNoteId);
      if(!_loc3_ || !_loc3_.happeningIds)
      {
         return false;
      }
      return _loc3_.happeningIds.indexOf(param1) >= 0;
   }
   
   public function isFailure(param1:int) : Boolean
   {
      var _loc2_:GudetamaDef = GameSetting.getGudetama(param1);
      return GameSetting.getKitchenware(_loc2_.kitchenwareId);
   }
}

import gudetama.data.GameSetting;
import gudetama.data.compati.GachaDef;
import gudetama.data.compati.GachaPriceDef;
import gudetama.data.compati.UserData;
import gudetama.data.compati.UserGachaData;

class GachaPart
{
    
   
   private var data:UserData;
   
   function GachaPart()
   {
      super();
   }
   
   public function init(param1:UserData) : void
   {
      data = param1;
   }
   
   public function getRestCountAtDaily(param1:int, param2:int) : int
   {
      var _loc6_:GachaDef = GameSetting.getGacha(param1);
      if(param2 >= _loc6_.prices.length)
      {
         return 0;
      }
      var _loc3_:GachaPriceDef = _loc6_.prices[param2];
      if(_loc3_.numDaily <= 0)
      {
         return -1;
      }
      var _loc5_:UserGachaData = data.gachaMap[param1];
      var _loc4_:int = 0;
      if(_loc5_ && param2 < _loc5_.prices.length)
      {
         _loc4_ = _loc5_.prices[param2].dailyPlayCount;
      }
      return Math.max(0,_loc3_.numDaily - _loc4_);
   }
   
   public function getRestCountAtFree(param1:int) : int
   {
      var _loc3_:GachaDef = GameSetting.getGacha(param1);
      var _loc2_:UserGachaData = data.gachaMap[param1];
      var _loc4_:int = 0;
      if(_loc2_)
      {
         _loc4_ = _loc2_.freePlayCount;
      }
      return Math.max(0,_loc3_.numFree - _loc4_);
   }
   
   public function playableAtDaily(param1:int, param2:int) : Boolean
   {
      return getRestCountAtDaily(param1,param2) != 0;
   }
   
   public function playableAtFree(param1:int) : Boolean
   {
      return getRestCountAtFree(param1) > 0;
   }
   
   public function updateUserGachaData(param1:UserGachaData) : void
   {
      data.gachaMap[param1.id#2] = param1;
   }
}

import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.ItemParam;
import gudetama.data.compati.UsefulData;
import gudetama.data.compati.UsefulDef;
import gudetama.data.compati.UsefulInfo;
import gudetama.data.compati.UserData;

class UsefulPart
{
    
   
   private var data:UserData;
   
   function UsefulPart()
   {
      super();
   }
   
   public function init(param1:UserData) : void
   {
      data = param1;
   }
   
   public function updateUsefuls(param1:UsefulInfo) : void
   {
      if(param1.updateUsefuls)
      {
         for each(var _loc3_ in param1.updateUsefuls)
         {
            updateUseful(_loc3_);
         }
      }
      if(param1.removeUsefulIds)
      {
         for each(var _loc2_ in param1.removeUsefulIds)
         {
            removeUseful(_loc2_);
         }
      }
   }
   
   public function createAndGetUsefulData(param1:int) : UsefulData
   {
      if(!data.usefulMap[param1])
      {
         data.usefulMap[param1] = new UsefulData(param1);
      }
      return data.usefulMap[param1];
   }
   
   public function updateUseful(param1:UsefulData) : void
   {
      data.usefulMap[param1.id#2] = param1;
   }
   
   public function addUseful(param1:ItemParam) : void
   {
      var _loc3_:UsefulData = createAndGetUsefulData(param1.id#2);
      _loc3_.num += param1.num;
      var _loc4_:UsefulDef = GameSetting.getUseful(_loc3_.id#2);
      var _loc2_:int = Math.max(0,_loc3_.num - _loc4_.possessionLimit);
      if(_loc2_ > 0)
      {
         _loc3_.num = _loc4_.possessionLimit;
      }
   }
   
   public function removeUseful(param1:int) : void
   {
      delete data.usefulMap[param1];
   }
   
   public function getUseful(param1:int) : UsefulData
   {
      return createAndGetUsefulData(param1);
   }
   
   public function getUsefulMap() : Object
   {
      return data.usefulMap;
   }
   
   public function consumeUsefulItem(param1:ItemParam) : void
   {
      consumeUseful(param1.id#2,param1.num);
   }
   
   public function consumeUseful(param1:int, param2:int) : void
   {
      var _loc3_:UsefulData = createAndGetUsefulData(param1);
      if(param2 < 0 || _loc3_.num < param2)
      {
         throw new Error();
      }
      _loc3_.num -= param2;
   }
   
   public function hasUsefulItem(param1:ItemParam) : Boolean
   {
      var _loc2_:UsefulData = createAndGetUsefulData(param1.id#2);
      return _loc2_.num >= param1.num;
   }
   
   public function hasUseful(param1:int) : Boolean
   {
      var _loc2_:UsefulData = createAndGetUsefulData(param1);
      return _loc2_.num > 0;
   }
   
   public function isUsefulAddable(param1:ItemParam) : Boolean
   {
      var _loc2_:UsefulData = createAndGetUsefulData(param1.id#2);
      var _loc3_:UsefulDef = GameSetting.getUseful(_loc2_.id#2);
      return _loc2_.num <= _loc3_.possessionLimit - param1.num;
   }
   
   public function getNumUseful(param1:int) : int
   {
      var _loc2_:UsefulData = createAndGetUsefulData(param1);
      return _loc2_.num;
   }
   
   public function isAvailable(param1:int) : Boolean
   {
      var _loc2_:UsefulData = getUseful(param1);
      if(!_loc2_)
      {
         return false;
      }
      return _loc2_.available;
   }
   
   public function getHurryUsefulIds() : Array
   {
      var _loc4_:* = null;
      var _loc1_:Object = GameSetting.getUsefulMap();
      var _loc2_:Array = [];
      for(var _loc3_ in _loc1_)
      {
         if((_loc4_ = GameSetting.getUseful(_loc3_)).existsAbilityKind(7))
         {
            if(UserDataWrapper.usefulPart.hasUseful(_loc3_))
            {
               trace("getHurryUsefulId usefulDef : " + _loc4_.id#2);
               _loc2_.push(_loc3_);
            }
         }
      }
      _loc2_.sort(ascendingKeyComparator);
      return _loc2_;
   }
   
   public function getAllHurryUsefulIds() : Array
   {
      var _loc4_:* = null;
      var _loc1_:Object = GameSetting.getUsefulMap();
      var _loc2_:Array = [];
      for(var _loc3_ in _loc1_)
      {
         if((_loc4_ = GameSetting.getUseful(_loc3_)).existsAbilityKind(7))
         {
            _loc2_.push(_loc3_);
         }
      }
      _loc2_.sort(ascendingKeyComparator);
      return _loc2_;
   }
   
   private function ascendingKeyComparator(param1:int, param2:int) : Number
   {
      if(param1 > param2)
      {
         return 1;
      }
      if(param1 < param2)
      {
         return -1;
      }
      return 0;
   }
}

import gudetama.data.compati.UserData;
import gudetama.data.compati.UtensilData;
import gudetama.data.compati.UtensilInfo;

class UtensilPart
{
    
   
   private var data:UserData;
   
   function UtensilPart()
   {
      super();
   }
   
   public function init(param1:UserData) : void
   {
      data = param1;
   }
   
   public function updateUtensils(param1:UtensilInfo) : void
   {
      if(param1.updateUtensils)
      {
         for each(var _loc2_ in param1.updateUtensils)
         {
            addUtensil(_loc2_);
         }
      }
      if(param1.removeUtensilIds)
      {
         for each(var _loc3_ in param1.removeUtensilIds)
         {
            removeUtensil(_loc3_);
         }
      }
   }
   
   public function addUtensil(param1:UtensilData) : void
   {
      if(!param1)
      {
         return;
      }
      data.utensilMap[param1.id#2] = param1;
   }
   
   public function removeUtensil(param1:int) : void
   {
      delete data.utensilMap[param1];
   }
   
   public function getUtensil(param1:int) : UtensilData
   {
      return data.utensilMap[param1];
   }
   
   public function getUtensilMap() : Object
   {
      return data.utensilMap;
   }
   
   public function hasUtensil(param1:int) : Boolean
   {
      var _loc2_:UtensilData = getUtensil(param1);
      if(!_loc2_)
      {
         return false;
      }
      return _loc2_.acquired;
   }
   
   public function isAvailable(param1:int) : Boolean
   {
      var _loc2_:UtensilData = getUtensil(param1);
      if(!_loc2_)
      {
         return false;
      }
      return _loc2_.available;
   }
}

import gudetama.data.UserDataWrapper;
import gudetama.data.compati.DecorationData;
import gudetama.data.compati.DecorationInfo;
import gudetama.data.compati.UserData;

class DecorationPart
{
    
   
   private var data:UserData;
   
   function DecorationPart()
   {
      super();
   }
   
   public function init(param1:UserData) : void
   {
      data = param1;
   }
   
   public function updateDecorations(param1:DecorationInfo) : void
   {
      if(param1.updateDecorations)
      {
         for each(var _loc3_ in param1.updateDecorations)
         {
            addDecoration(_loc3_);
         }
      }
      if(param1.removeDecorationIds)
      {
         for each(var _loc2_ in param1.removeDecorationIds)
         {
            removeDecoration(_loc2_);
         }
      }
   }
   
   public function addDecoration(param1:DecorationData) : void
   {
      data.decorationMap[param1.id#2] = param1;
   }
   
   public function removeDecoration(param1:int) : void
   {
      delete data.decorationMap[param1];
   }
   
   public function getDecoration(param1:int) : DecorationData
   {
      return data.decorationMap[param1];
   }
   
   public function getDecorationMap() : Object
   {
      return data.decorationMap;
   }
   
   public function getAcquiredDecorationMap() : Object
   {
      var _loc2_:Object = {};
      for(var _loc1_ in data.decorationMap)
      {
         if(hasDecoration(_loc1_))
         {
            _loc2_[_loc1_] = getDecoration(_loc1_);
         }
      }
      return _loc2_;
   }
   
   public function hasDecoration(param1:int) : Boolean
   {
      var _loc2_:DecorationData = getDecoration(param1);
      if(!_loc2_)
      {
         return false;
      }
      return _loc2_.acquired;
   }
   
   public function isAvailable(param1:int) : Boolean
   {
      var _loc2_:DecorationData = getDecoration(param1);
      if(!_loc2_)
      {
         return false;
      }
      return _loc2_.available;
   }
   
   public function getCurrentDecorationId() : int
   {
      return data.decorationId;
   }
   
   public function getHomeDecorationId() : int
   {
      var _loc1_:int = UserDataWrapper.eventPart.getEventDecorationId();
      if(_loc1_ > 0)
      {
         return _loc1_;
      }
      return getCurrentDecorationId();
   }
   
   public function setDecorationId(param1:int) : void
   {
      data.decorationId = param1;
   }
}

import gudetama.data.compati.AvatarData;
import gudetama.data.compati.AvatarInfo;
import gudetama.data.compati.UserData;

class AvatarPart
{
    
   
   private var data:UserData;
   
   function AvatarPart()
   {
      super();
   }
   
   public function init(param1:UserData) : void
   {
      data = param1;
   }
   
   public function updateAvatars(param1:AvatarInfo) : void
   {
      if(param1.updateAvatars)
      {
         for each(var _loc2_ in param1.updateAvatars)
         {
            addAvatar(_loc2_);
         }
      }
      if(param1.removeAvatarIds)
      {
         for each(var _loc3_ in param1.removeAvatarIds)
         {
            removeAvatar(_loc3_);
         }
      }
   }
   
   public function addAvatar(param1:AvatarData) : void
   {
      if(!param1)
      {
         return;
      }
      data.avatarMap[param1.id#2] = param1;
   }
   
   public function removeAvatar(param1:int) : void
   {
      delete data.avatarMap[param1];
   }
   
   public function getAvatar(param1:int) : AvatarData
   {
      return data.avatarMap[param1];
   }
   
   public function getAvatarMap() : Object
   {
      return data.avatarMap;
   }
   
   public function hasAvatar(param1:int) : Boolean
   {
      var _loc2_:AvatarData = getAvatar(param1);
      if(!_loc2_)
      {
         return false;
      }
      return _loc2_.acquired;
   }
   
   public function isAvailable(param1:int) : Boolean
   {
      var _loc2_:AvatarData = getAvatar(param1);
      if(!_loc2_)
      {
         return false;
      }
      return _loc2_.available;
   }
}

import gudetama.data.compati.ItemParam;
import gudetama.data.compati.StampData;
import gudetama.data.compati.StampInfo;
import gudetama.data.compati.UserData;

class StampPart
{
    
   
   private var data:UserData;
   
   public var hasStampData:Boolean = false;
   
   function StampPart()
   {
      super();
   }
   
   public function init(param1:UserData) : void
   {
      data = param1;
      checkStampData();
   }
   
   private function checkStampData() : void
   {
      var _loc3_:* = 0;
      var _loc1_:* = null;
      var _loc2_:* = null;
      if(data.stampMap)
      {
         _loc2_ = data.stampMap;
         for(_loc3_ in _loc2_)
         {
            _loc1_ = _loc2_[_loc3_] as StampData;
            if(_loc1_.num > 0)
            {
               hasStampData = true;
               break;
            }
         }
      }
   }
   
   public function updateStamps(param1:StampInfo) : void
   {
      if(param1.updateStamps)
      {
         for each(var _loc2_ in param1.updateStamps)
         {
            updateStamp(_loc2_);
         }
      }
      if(param1.removeStampIds)
      {
         for each(var _loc3_ in param1.removeStampIds)
         {
            removeStamp(_loc3_);
         }
      }
      checkStampData();
   }
   
   public function createAndGetStampData(param1:int) : StampData
   {
      if(!data.stampMap[param1])
      {
         data.stampMap[param1] = new StampData(param1);
      }
      return data.stampMap[param1];
   }
   
   public function updateStamp(param1:StampData) : void
   {
      data.stampMap[param1.id#2] = param1;
      checkStampData();
   }
   
   public function addStamp(param1:ItemParam) : void
   {
      var _loc2_:StampData = createAndGetStampData(param1.id#2);
      _loc2_.num += param1.num;
      var _loc3_:int = Math.max(0,_loc2_.num - 99999);
      if(_loc3_ > 0)
      {
         _loc2_.num = 99999;
      }
      checkStampData();
   }
   
   public function removeStamp(param1:int) : void
   {
      delete data.stampMap[param1];
      checkStampData();
   }
   
   public function getStamp(param1:int) : StampData
   {
      return data.stampMap[param1];
   }
   
   public function getStampMap() : Object
   {
      return data.stampMap;
   }
   
   public function consumeStampItem(param1:ItemParam) : void
   {
      consumeStamp(param1.id#2,param1.num);
   }
   
   public function consumeStamp(param1:int, param2:int) : void
   {
      var _loc3_:StampData = createAndGetStampData(param1);
      if(param2 < 0 || _loc3_.num < param2)
      {
         throw new Error();
      }
      _loc3_.num -= param2;
   }
   
   public function hasStampItem(param1:ItemParam) : Boolean
   {
      var _loc2_:StampData = createAndGetStampData(param1.id#2);
      return _loc2_.num >= param1.num;
   }
   
   public function hasStamp(param1:int) : Boolean
   {
      var _loc2_:StampData = createAndGetStampData(param1);
      return _loc2_.num > 0;
   }
   
   public function isStampAddable(param1:ItemParam) : Boolean
   {
      var _loc2_:StampData = createAndGetStampData(param1.id#2);
      return _loc2_.num <= 99999 - param1.num;
   }
   
   public function getNumStamp(param1:int) : int
   {
      var _loc2_:StampData = createAndGetStampData(param1);
      return _loc2_.num;
   }
   
   public function isAvailable(param1:int) : Boolean
   {
      var _loc2_:StampData = getStamp(param1);
      if(!_loc2_)
      {
         return false;
      }
      return _loc2_.available;
   }
}

import flash.utils.getTimer;
import gudetama.data.DataStorage;
import gudetama.data.GameSetting;
import gudetama.data.compati.UserData;
import gudetama.data.compati.UserProfileData;
import gudetama.util.FriendSortUtil;

class FriendPart
{
    
   
   private var data:UserData;
   
   private var followerList:Array;
   
   private var numFollower:int = -1;
   
   private var requestUpdateFollower:Boolean;
   
   private var lastUpdateFollowerTime:int;
   
   private var followList:Array;
   
   private var numFollow:int;
   
   private var requestUpdateFollow:Boolean;
   
   private var lastUpdateFollowTime:int;
   
   private var friendList:Array;
   
   private var friendMap:Object;
   
   private var numFriend:int = -1;
   
   private var numNewFriend:int;
   
   function FriendPart()
   {
      followerList = [];
      followList = [];
      friendList = [];
      friendMap = {};
      super();
   }
   
   public function init(param1:UserData) : void
   {
      data = param1;
      followerList.length = 0;
      numFollower = -1;
      requestUpdateFollower = false;
      lastUpdateFollowerTime = 0;
      followList.length = 0;
      numFollow = 0;
      requestUpdateFollow = false;
      lastUpdateFollowTime = 0;
      friendList.length = 0;
      friendMap = {};
      numFriend = -1;
      setNumFollowers(0);
      setNumFriends(0);
   }
   
   public function setupList(param1:Array) : void
   {
      var _loc3_:int = 0;
      var _loc2_:* = null;
      if(!param1)
      {
         return;
      }
      _loc3_ = 0;
      while(_loc3_ < param1.length)
      {
         _loc2_ = param1[_loc3_] as UserProfileData;
         if(_loc2_.followState == 1)
         {
            addFollow(_loc2_);
         }
         else if(_loc2_.followState == 2)
         {
            addFollower(_loc2_);
         }
         else if(_loc2_.followState == 3)
         {
            addFriend(_loc2_);
         }
         _loc3_++;
      }
   }
   
   public function setFollowerList(param1:Array) : void
   {
      setupList(param1);
      checkFollowerAndFriendStatus(param1);
   }
   
   public function setFollowList(param1:Array) : void
   {
      setupList(param1);
      checkFollowAndFriendStatus(param1);
   }
   
   public function addFollow(param1:UserProfileData) : void
   {
      add(followList,param1);
      numFollow = followList.length;
      removeFollower(param1);
      removeFriend(param1);
   }
   
   public function addFollower(param1:UserProfileData) : void
   {
      add(followerList,param1);
      numFollower = followerList.length;
      removeFollow(param1);
      removeFriend(param1);
   }
   
   public function addFriend(param1:UserProfileData) : void
   {
      add(friendList,param1);
      friendMap[param1.encodedUid] = param1;
      numFriend = friendList.length;
      removeFollow(param1);
      removeFollower(param1);
   }
   
   private function add(param1:Array, param2:UserProfileData) : void
   {
      var _loc4_:int = 0;
      var _loc3_:* = null;
      _loc4_ = 0;
      while(_loc4_ < param1.length)
      {
         _loc3_ = param1[_loc4_];
         if(_loc3_.encodedUid == param2.encodedUid)
         {
            param1[_loc4_] = param2;
            return;
         }
         _loc4_++;
      }
      param1.push(param2);
   }
   
   public function removeFollower(param1:UserProfileData) : void
   {
      remove(followerList,param1.encodedUid);
      numFollower = followerList.length;
   }
   
   public function removeFollowerByEncodeUid(param1:int) : void
   {
      remove(followerList,param1);
      numFollower = followerList.length;
   }
   
   public function removeFollow(param1:UserProfileData) : void
   {
      remove(followList,param1.encodedUid);
      numFollow = followList.length;
   }
   
   public function removeFriend(param1:UserProfileData) : void
   {
      remove(friendList,param1.encodedUid);
      delete friendMap[param1.encodedUid];
      numFriend = friendList.length;
   }
   
   private function remove(param1:Array, param2:int) : void
   {
      var _loc4_:int = 0;
      var _loc3_:* = null;
      _loc4_ = 0;
      while(_loc4_ < param1.length)
      {
         _loc3_ = param1[_loc4_];
         if(_loc3_.encodedUid == param2)
         {
            param1.splice(_loc4_,1);
            break;
         }
         _loc4_++;
      }
   }
   
   public function setNumFollows(param1:int) : void
   {
      if(numFollow == param1)
      {
         return;
      }
      numFollow = param1;
      requestUpdateFollow = true;
   }
   
   public function setNumFollowers(param1:int) : void
   {
      if(numFollower == param1)
      {
         return;
      }
      numFollower = param1;
      requestUpdateFollower = true;
   }
   
   public function setNumFriends(param1:int) : void
   {
      if(numFriend == param1)
      {
         return;
      }
      numFriend = param1;
      requestUpdateFollower = true;
      requestUpdateFollow = true;
   }
   
   public function setNumNewFriend(param1:int) : void
   {
      numNewFriend = param1;
   }
   
   public function getNumNewFriend() : int
   {
      return numNewFriend;
   }
   
   private function exists(param1:Array, param2:int) : Boolean
   {
      var _loc4_:int = 0;
      var _loc3_:int = param1.length;
      _loc4_ = 0;
      while(_loc4_ < param1.length)
      {
         if(param1[_loc4_].encodedUid == param2)
         {
            return true;
         }
         _loc4_++;
      }
      return false;
   }
   
   public function existsInFollow(param1:int) : Boolean
   {
      return exists(followList,param1);
   }
   
   public function existsInFollower(param1:int) : Boolean
   {
      return exists(followerList,param1);
   }
   
   public function existsInFriend(param1:int) : Boolean
   {
      return exists(friendList,param1);
   }
   
   private function checkFollowerAndFriendStatus(param1:Array) : void
   {
      var _loc2_:int = 0;
      var _loc3_:int = 0;
      if(followerList != null)
      {
         _loc2_ = followerList.length - 1;
         while(_loc2_ >= 0)
         {
            if(!exists(param1,followerList[_loc2_].encodedUid))
            {
               followerList.splice(_loc2_,1);
            }
            _loc2_--;
         }
      }
      if(friendList != null)
      {
         _loc2_ = friendList.length - 1;
         while(_loc2_ >= 0)
         {
            _loc3_ = friendList[_loc2_].encodedUid;
            if(!exists(param1,_loc3_))
            {
               friendList.splice(_loc2_,1);
               delete friendMap[_loc3_];
            }
            _loc2_--;
         }
      }
   }
   
   private function checkFollowAndFriendStatus(param1:Array) : void
   {
      var _loc2_:int = 0;
      var _loc3_:int = 0;
      if(followList != null)
      {
         _loc2_ = followList.length - 1;
         while(_loc2_ >= 0)
         {
            if(!exists(param1,followList[_loc2_].encodedUid))
            {
               followList.splice(_loc2_,1);
            }
            _loc2_--;
         }
      }
      if(friendList != null)
      {
         _loc2_ = friendList.length - 1;
         while(_loc2_ >= 0)
         {
            _loc3_ = friendList[_loc2_].encodedUid;
            if(!exists(param1,_loc3_))
            {
               friendList.splice(_loc2_,1);
               delete friendMap[_loc3_];
            }
            _loc2_--;
         }
      }
   }
   
   public function isRequestedUpdateFollower() : Boolean
   {
      var _loc2_:int = getTimer();
      var _loc1_:int = _loc2_ - lastUpdateFollowerTime;
      if(requestUpdateFollower || _loc1_ > GameSetting.getRule().updateFollowerTime)
      {
         lastUpdateFollowerTime = _loc2_;
         requestUpdateFollower = false;
         return true;
      }
      return false;
   }
   
   public function isRequestedUpdateFollow() : Boolean
   {
      var _loc2_:int = getTimer();
      var _loc1_:int = _loc2_ - lastUpdateFollowTime;
      if(requestUpdateFollow || _loc1_ > GameSetting.getRule().updateFollowerTime)
      {
         lastUpdateFollowTime = _loc2_;
         requestUpdateFollow = false;
         return true;
      }
      return false;
   }
   
   public function getFollowList() : Array
   {
      return followList;
   }
   
   public function getFollowerList() : Array
   {
      return followerList;
   }
   
   public function getFriendList() : Array
   {
      return friendList;
   }
   
   public function getFriendProfile(param1:int) : UserProfileData
   {
      return friendMap[param1];
   }
   
   public function getNumFriends() : int
   {
      return numFriend;
   }
   
   public function getNumFollowers() : int
   {
      return numFollower;
   }
   
   public function getMaxFriends() : int
   {
      return 10 + data.numFriendsExtension * GameSetting.getRule().friendsExtensionValue;
   }
   
   public function isMaxFriendsExtensible() : Boolean
   {
      return data.numFriendsExtension < GameSetting.getRule().maxFriendsExtension;
   }
   
   public function increaseNumFriendsExtension() : void
   {
      data.numFriendsExtension += 1;
   }
   
   public function getFriendsExtensionNum() : int
   {
      return data.numFriendsExtension;
   }
   
   public function getPrevFriend(param1:UserProfileData) : UserProfileData
   {
      var _loc3_:int = 0;
      var _loc4_:Array = FriendSortUtil.processCopyAndSort(friendList,true,DataStorage.getLocalData().getFriendSortType());
      var _loc2_:* = -1;
      _loc3_ = 0;
      while(_loc3_ < _loc4_.length)
      {
         if(_loc4_[_loc3_].encodedUid == param1.encodedUid)
         {
            _loc2_ = _loc3_;
            break;
         }
         _loc3_++;
      }
      if(_loc2_ < 0)
      {
         if(_loc4_.length > 0)
         {
            return _loc4_[0];
         }
         return null;
      }
      _loc2_--;
      if(_loc2_ < 0)
      {
         _loc2_ = int(_loc4_.length - 1);
      }
      return _loc4_[_loc2_];
   }
   
   public function getNextFriend(param1:UserProfileData) : UserProfileData
   {
      var _loc3_:int = 0;
      var _loc4_:Array = FriendSortUtil.processCopyAndSort(friendList,true,DataStorage.getLocalData().getFriendSortType());
      var _loc2_:* = -1;
      _loc3_ = 0;
      while(_loc3_ < _loc4_.length)
      {
         if(_loc4_[_loc3_].encodedUid == param1.encodedUid)
         {
            _loc2_ = _loc3_;
            break;
         }
         _loc3_++;
      }
      if(_loc2_ < 0)
      {
         if(_loc4_.length > 0)
         {
            return _loc4_[0];
         }
         return null;
      }
      _loc2_++;
      if(_loc2_ >= _loc4_.length)
      {
         _loc2_ = 0;
      }
      return _loc4_[_loc2_];
   }
}

import gudetama.data.compati.UserData;
import gudetama.data.compati.UserWantedData;

class WantedPart
{
    
   
   private var data:UserData;
   
   function WantedPart()
   {
      super();
   }
   
   public function init(param1:UserData) : void
   {
      data = param1;
   }
   
   public function getUserWantedData(param1:int) : UserWantedData
   {
      if(param1 >= data.wantedGudetamas.length)
      {
         return null;
      }
      return data.wantedGudetamas[param1];
   }
   
   public function isEmpty(param1:int) : Boolean
   {
      var _loc2_:UserWantedData = getUserWantedData(param1);
      if(!_loc2_)
      {
         return false;
      }
      return _loc2_.id#2 == 0;
   }
   
   public function getAllWantedIds() : Array
   {
      var _loc3_:int = 0;
      var _loc1_:* = null;
      var _loc2_:Array = [];
      _loc3_ = 0;
      while(_loc3_ < 3)
      {
         _loc1_ = getUserWantedData(_loc3_);
         if(!(_loc1_ == null || _loc1_.id#2 == 0))
         {
            _loc2_.push(_loc1_.id#2);
         }
         _loc3_++;
      }
      return _loc2_;
   }
   
   public function equals(param1:int, param2:int) : Boolean
   {
      var _loc3_:* = null;
      if(isEmpty(param1))
      {
         return param2 == 0;
      }
      _loc3_ = getUserWantedData(param1);
      return _loc3_.id#2 == param2;
   }
   
   public function exists(param1:int) : Boolean
   {
      for each(var _loc2_ in data.wantedGudetamas)
      {
         if(_loc2_.id#2 == param1)
         {
            return true;
         }
      }
      return false;
   }
   
   public function setWantedGudetamas(param1:Array) : void
   {
      data.wantedGudetamas = param1;
   }
   
   public function getWantedGudetamas() : Array
   {
      return data.wantedGudetamas;
   }
}

import gudetama.data.compati.UserAbilityData;
import gudetama.data.compati.UserData;
import gudetama.util.TimeZoneUtil;

class AbilityPart
{
    
   
   private var data:UserData;
   
   private var updateTimeSecs:int;
   
   private var kindBitFlag:int;
   
   function AbilityPart()
   {
      super();
   }
   
   public function init(param1:UserData) : void
   {
      data = param1;
      updateTimeSecs = TimeZoneUtil.epochMillisToOffsetSecs();
   }
   
   public function updateAbilities(param1:Array) : void
   {
      data.userAbilities = param1;
      updateTimeSecs = TimeZoneUtil.epochMillisToOffsetSecs();
      updateKindBitFlag();
   }
   
   public function advanceTime() : Boolean
   {
      var _loc4_:int = 0;
      var _loc5_:* = null;
      if(data.userAbilities.length == 0)
      {
         return false;
      }
      var _loc3_:int = TimeZoneUtil.epochMillisToOffsetSecs();
      var _loc1_:int = getDt();
      if(_loc1_ == 0)
      {
         return false;
      }
      var _loc2_:Boolean = false;
      _loc4_ = data.userAbilities.length - 1;
      while(_loc4_ >= 0)
      {
         _loc5_.restTimeSecs = (_loc5_ = data.userAbilities[_loc4_]).restTimeSecs - _loc1_;
         if(_loc5_.restTimeSecs < 0 && _loc5_.ability.secs != -1)
         {
            data.userAbilities.removeAt(_loc4_);
            _loc2_ = true;
            updateKindBitFlag();
         }
         _loc4_--;
      }
      updateTimeSecs = _loc3_;
      return _loc2_;
   }
   
   public function getAlive(param1:int) : UserAbilityData
   {
      var _loc3_:int = 0;
      var _loc4_:* = null;
      var _loc5_:int = 0;
      if(data.userAbilities.length == 0)
      {
         return null;
      }
      var _loc2_:int = getDt();
      _loc3_ = 0;
      while(_loc3_ < data.userAbilities.length)
      {
         if((_loc5_ = (_loc4_ = data.userAbilities[(param1 + _loc3_) % data.userAbilities.length]).restTimeSecs - _loc2_) >= 0 || _loc4_.ability.secs == -1)
         {
            return _loc4_;
         }
         _loc3_++;
      }
      return null;
   }
   
   public function getAliveAtType(param1:int) : Boolean
   {
      var _loc3_:int = 0;
      var _loc4_:* = null;
      if(data.userAbilities.length == 0)
      {
         return null;
      }
      var _loc2_:int = getDt();
      _loc3_ = 0;
      while(_loc3_ < data.userAbilities.length)
      {
         if(!(_loc4_ = data.userAbilities[_loc3_]).ability.type != param1)
         {
            if(_loc4_.restTimeSecs - _loc2_ >= 0)
            {
               return true;
            }
            if(_loc4_.ability.secs == -1)
            {
               return true;
            }
         }
         _loc3_++;
      }
      return false;
   }
   
   public function existsAbility() : Boolean
   {
      return data.userAbilities.length > 0;
   }
   
   public function getDt() : int
   {
      var _loc1_:int = TimeZoneUtil.epochMillisToOffsetSecs();
      return _loc1_ - updateTimeSecs;
   }
   
   private function updateKindBitFlag() : void
   {
      kindBitFlag = 0;
      for each(var _loc1_ in data.userAbilities)
      {
         kindBitFlag |= 1 << _loc1_.ability.getKind();
      }
   }
   
   public function existsKind(param1:int) : Boolean
   {
      return (kindBitFlag & 1 << param1) != 0;
   }
   
   public function removeAbility(param1:int) : void
   {
      var _loc2_:int = 0;
      var _loc3_:* = null;
      if(data.userAbilities.length == 0)
      {
         return;
      }
      _loc2_ = data.userAbilities.length - 1;
      while(_loc2_ >= 0)
      {
         _loc3_ = data.userAbilities[_loc2_];
         if(_loc3_.ability.type == param1)
         {
            data.userAbilities.removeAt(_loc2_);
            updateKindBitFlag();
         }
         _loc2_--;
      }
   }
}

import gudetama.data.GameSetting;
import gudetama.data.compati.UserData;

class FeaturePart
{
    
   
   private var data:UserData;
   
   function FeaturePart()
   {
      super();
   }
   
   public function init(param1:UserData) : void
   {
      data = param1;
   }
   
   public function updateFeatures(param1:Array) : void
   {
      data.features = param1;
   }
   
   public function existsFeature(param1:int) : Boolean
   {
      if(!GameSetting.getFeature().exists(param1))
      {
         return true;
      }
      return data.features.indexOf(param1) >= 0;
   }
   
   public function getValue(param1:int) : int
   {
      if(!existsFeature(param1))
      {
         return 0;
      }
      var _loc2_:Object = GameSetting.getFeature().paramMap;
      if(!_loc2_[param1])
      {
         return 0;
      }
      return _loc2_[param1].value;
   }
}

import gudetama.data.DataStorage;
import gudetama.data.GameSetting;
import gudetama.data.compati.UserData;
import gudetama.data.compati.VideoAdRewardDef;
import gudetama.util.TimeZoneUtil;

class VideoAdPart
{
    
   
   private var data:UserData;
   
   private var restTimeSecs:int;
   
   private var updateTimeSecs:int;
   
   function VideoAdPart()
   {
      super();
   }
   
   public function init(param1:UserData) : void
   {
      data = param1;
   }
   
   public function updateNumAcquiredReward(param1:int) : void
   {
      data.numAcquiredVideoAdReward = param1;
   }
   
   public function updateRestTimeSecs(param1:int) : void
   {
      this.restTimeSecs = param1;
      DataStorage.getLocalData().videoAdRewardUpdateTimeSecs = param1 + TimeZoneUtil.epochMillisToOffsetSecs() - GameSetting.getRule().preLoadingVideoSecs;
      updateTimeSecs = TimeZoneUtil.epochMillisToOffsetSecs();
      DataStorage.saveLocalData();
   }
   
   public function getRestNum() : int
   {
      var _loc1_:VideoAdRewardDef = GameSetting.getVideoAdReward();
      var _loc2_:int = _loc1_ != null ? _loc1_.items.length : 0;
      return _loc2_ - data.numAcquiredVideoAdReward;
   }
   
   public function getRestTimeSecs() : int
   {
      var _loc2_:int = TimeZoneUtil.epochMillisToOffsetSecs();
      var _loc1_:int = _loc2_ - updateTimeSecs;
      if(_loc1_ > 0)
      {
         restTimeSecs = Math.max(0,restTimeSecs - _loc1_);
         updateTimeSecs = _loc2_;
      }
      return restTimeSecs;
   }
   
   public function isLast() : Boolean
   {
      var _loc1_:VideoAdRewardDef = GameSetting.getVideoAdReward();
      var _loc2_:int = _loc1_ != null ? _loc1_.items.length : 0;
      return _loc2_ - data.numAcquiredVideoAdReward == 1;
   }
   
   public function isAcquirable() : Boolean
   {
      var _loc1_:VideoAdRewardDef = GameSetting.getVideoAdReward();
      var _loc2_:int = _loc1_ != null ? _loc1_.items.length : 0;
      return data.numAcquiredVideoAdReward < _loc2_;
   }
   
   public function isAcquiredOneOrMoreTimes() : Boolean
   {
      return data.numAcquiredVideoAdReward > 0;
   }
   
   public function needsUpdate() : Boolean
   {
      return isAcquiredOneOrMoreTimes() && getRestTimeSecs() <= 0;
   }
}

import gudetama.data.compati.LinkageData;
import gudetama.data.compati.UserData;

class LinkagePart
{
    
   
   private var data:UserData;
   
   function LinkagePart()
   {
      super();
   }
   
   public function init(param1:UserData) : void
   {
      data = param1;
   }
   
   public function update(param1:Array) : void
   {
      for each(var _loc2_ in param1)
      {
         data.linkageMap[_loc2_.id#2] = _loc2_;
      }
   }
   
   public function exists(param1:int) : Boolean
   {
      return data.linkageMap[param1];
   }
   
   public function getLinkage(param1:int) : LinkageData
   {
      return data.linkageMap[param1];
   }
   
   public function getLinkageMap() : Object
   {
      return data.linkageMap;
   }
   
   public function isAllNotified() : Boolean
   {
      for each(var _loc1_ in data.linkageMap)
      {
         if(!_loc1_.notified)
         {
            return false;
         }
      }
      return true;
   }
   
   public function notify(param1:int) : void
   {
      var _loc2_:LinkageData = getLinkage(param1);
      if(!_loc2_)
      {
         return;
      }
      _loc2_.notified = true;
   }
}

import gudetama.data.GameSetting;
import gudetama.data.compati.EventData;
import gudetama.data.compati.SystemMailData;
import gudetama.data.compati.UserData;
import gudetama.util.TimeZoneUtil;

class EventPart
{
    
   
   private var data:UserData;
   
   private var eventMap:Object;
   
   private var numEvent:int;
   
   private var updateTimeSecs:int;
   
   function EventPart()
   {
      super();
   }
   
   public function init(param1:UserData) : void
   {
      data = param1;
   }
   
   public function update(param1:Array) : void
   {
      eventMap = {};
      numEvent = 0;
      for each(var _loc2_ in param1)
      {
         eventMap[_loc2_.id#2] = _loc2_;
         numEvent++;
      }
      updateTimeSecs = TimeZoneUtil.epochMillisToOffsetSecs();
   }
   
   public function advanceTime() : void
   {
      var _loc3_:* = null;
      if(!eventMap)
      {
         return;
      }
      if(numEvent == 0)
      {
         return;
      }
      var _loc4_:int;
      var _loc1_:int = (_loc4_ = TimeZoneUtil.epochMillisToOffsetSecs()) - updateTimeSecs;
      if(_loc1_ == 0)
      {
         return;
      }
      for(var _loc2_ in eventMap)
      {
         _loc3_ = eventMap[_loc2_];
         _loc3_.endRestTimeSecs -= _loc1_;
         _loc3_.endTallyRestTimeSecs -= _loc1_;
         if(_loc3_.endRestTimeSecs < 0)
         {
            delete eventMap[_loc2_];
            numEvent--;
         }
      }
      updateTimeSecs = _loc4_;
   }
   
   public function inTerm(param1:int, param2:Boolean) : Boolean
   {
      var _loc3_:* = null;
      if(param1 <= 0)
      {
         return true;
      }
      if(eventMap == null)
      {
         return false;
      }
      if(param2)
      {
         _loc3_ = eventMap[param1];
         return _loc3_ != null ? _loc3_.endTallyRestTimeSecs > 0 : false;
      }
      return eventMap[param1];
   }
   
   public function getBackgroundName() : String
   {
      var _loc2_:* = null;
      for(var _loc1_ in eventMap)
      {
         _loc2_ = eventMap[_loc1_];
         if(_loc2_.background && _loc2_.background.length > 0)
         {
            return _loc2_.background;
         }
      }
      return null;
   }
   
   public function getButtonImageName() : String
   {
      var _loc2_:* = null;
      for(var _loc1_ in eventMap)
      {
         _loc2_ = eventMap[_loc1_];
         if(_loc2_.buttonImage && _loc2_.buttonImage.length > 0)
         {
            return _loc2_.buttonImage;
         }
      }
      return null;
   }
   
   public function getSystemMailData() : SystemMailData
   {
      var _loc2_:* = null;
      for(var _loc1_ in eventMap)
      {
         _loc2_ = getEventMailData(eventMap[_loc1_]);
         if(_loc2_)
         {
            return _loc2_;
         }
      }
      return null;
   }
   
   public function getEventMailData(param1:EventData) : SystemMailData
   {
      if(!param1.title && !param1.message && !param1.url#2)
      {
         return null;
      }
      var _loc2_:SystemMailData = new SystemMailData();
      _loc2_.type = 10;
      _loc2_.title = param1.title;
      _loc2_.message = param1.message;
      _loc2_.url#2 = param1.url#2;
      return _loc2_;
   }
   
   public function getRestTimeSecs(param1:int) : int
   {
      var _loc2_:EventData = eventMap[param1];
      if(!_loc2_)
      {
         return 0;
      }
      return _loc2_.endRestTimeSecs;
   }
   
   public function getEventDecorationId() : int
   {
      var _loc2_:* = null;
      for(var _loc1_ in eventMap)
      {
         _loc2_ = eventMap[_loc1_];
         if(_loc2_.decorationId > 0)
         {
            return _loc2_.decorationId;
         }
      }
      return 0;
   }
   
   public function getRentalDecorationIds() : Array
   {
      var _loc2_:Array = [];
      for each(var _loc1_ in eventMap)
      {
         if(_loc1_.rentalDecorations)
         {
            for each(var _loc3_ in _loc1_.rentalDecorations)
            {
               if(_loc2_.indexOf(_loc3_) < 0)
               {
                  _loc2_.push(_loc3_);
               }
            }
         }
      }
      return _loc2_;
   }
   
   public function getEventBGM(param1:int) : String
   {
      var _loc3_:* = null;
      for(var _loc2_ in eventMap)
      {
         _loc3_ = eventMap[_loc2_];
         if(_loc3_.chBGM != null)
         {
            return _loc3_.chBGM[param1];
         }
      }
      if(param1 == 0)
      {
         return "Title_home";
      }
      return "Home";
   }
   
   public function getRankingIds(param1:Boolean, param2:Boolean = true) : Array
   {
      var _loc5_:* = null;
      var _loc3_:Array = null;
      for(var _loc4_ in eventMap)
      {
         if((_loc5_ = eventMap[_loc4_]).isRankingEvent())
         {
            if(inTerm(_loc4_,param1))
            {
               if(!(param2 && !_loc5_.attendable))
               {
                  if(_loc3_ == null)
                  {
                     _loc3_ = [];
                  }
                  _loc3_.push(_loc5_.rankingId);
               }
            }
         }
      }
      return _loc3_;
   }
   
   public function getRankingEventIds(param1:Boolean, param2:Boolean = true) : Array
   {
      var _loc5_:* = null;
      var _loc3_:Array = null;
      for(var _loc4_ in eventMap)
      {
         if((_loc5_ = eventMap[_loc4_]).isRankingEvent())
         {
            if(inTerm(_loc4_,param1))
            {
               if(!(param2 && !_loc5_.attendable))
               {
                  if(_loc3_ == null)
                  {
                     _loc3_ = [];
                  }
                  _loc3_.push(_loc5_.id#2);
               }
            }
         }
      }
      return _loc3_;
   }
   
   public function getEventDataByRankingId(param1:int) : EventData
   {
      var _loc3_:* = null;
      for(var _loc2_ in eventMap)
      {
         _loc3_ = eventMap[_loc2_];
         if(_loc3_.rankingId == param1)
         {
            return _loc3_;
         }
      }
      return null;
   }
   
   public function getEventMap() : Object
   {
      return eventMap;
   }
   
   public function existsGudetamaId(param1:int) : Boolean
   {
      var _loc3_:* = null;
      for(var _loc2_ in eventMap)
      {
         _loc3_ = eventMap[_loc2_];
         if(_loc3_.gudetamaIds && _loc3_.gudetamaIds.indexOf(param1) >= 0)
         {
            return true;
         }
      }
      return false;
   }
   
   public function getRankingPointText(param1:Boolean = true) : String
   {
      var _loc3_:Array = getRankingIds(true,param1);
      if(!_loc3_ || _loc3_.length <= 0)
      {
         return GameSetting.getUIText("%ranking.pts");
      }
      var _loc2_:String = GameSetting.getUIText("%ranking.pts." + _loc3_[0]);
      if(_loc2_.charAt(0) == "?")
      {
         return GameSetting.getUIText("%ranking.pts");
      }
      return _loc2_;
   }
   
   public function getRankingPointRewardText() : String
   {
      var _loc2_:Array = getRankingIds(true);
      if(!_loc2_ || _loc2_.length <= 0)
      {
         return GameSetting.getUIText("ranking.get.pts.reward");
      }
      var _loc1_:String = GameSetting.getUIText("ranking.get.pts.reward." + _loc2_[0]);
      if(_loc1_.charAt(0) == "?")
      {
         return GameSetting.getUIText("ranking.get.pts.reward");
      }
      return _loc1_;
   }
   
   public function getRankingPointGetText() : String
   {
      var _loc2_:Array = getRankingIds(true);
      if(!_loc2_ || _loc2_.length <= 0)
      {
         return GameSetting.getUIText("ranking.get.pts");
      }
      var _loc1_:String = GameSetting.getUIText("ranking.get.pts." + _loc2_[0]);
      if(_loc1_.charAt(0) == "?")
      {
         return GameSetting.getUIText("ranking.get.pts");
      }
      return _loc1_;
   }
   
   public function isRunningEvent(param1:int) : Boolean
   {
      return eventMap[param1];
   }
}
