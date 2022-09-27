package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class UserData
   {
      
      public static const METAL_MAX:int = 999999999;
      
      public static const METAL_EXCHANGE_RATE:int = 100;
      
      public static const MONEY_MAX:int = 999999999;
      
      public static const MAX_KEEP_PRESENT_SECS:int = 2592000;
      
      public static const DEFAULT_MAX_FRIENDS:int = 10;
       
      
      public var uid:int;
      
      public var encodedUid:int;
      
      public var playerName:String;
      
      public var gender:int;
      
      public var doneFirstLogin:Boolean;
      
      public var pushFlags:int;
      
      public var nextDailyPresentTime:Number;
      
      public var timeZoneOffset:int;
      
      public var noticeFlagData:NoticeFlagData;
      
      public var locale:String;
      
      public var rank:int;
      
      public var chargeMetal:int;
      
      public var freeMetal:int;
      
      public var subMetal:int;
      
      public var chargeMoney:int;
      
      public var freeMoney:int;
      
      public var avatar:int;
      
      public var avatarMap:Object;
      
      public var area:int;
      
      public var comment:int;
      
      public var placedGudetamaId:int;
      
      public var kitchenwareMap:Object;
      
      public var recipeNoteMap:Object;
      
      public var gudetamaMap:Object;
      
      public var gachaMap:Object;
      
      public var friendPresentMoneyParamMap:Object;
      
      public var stampMap:Object;
      
      public var usefulMap:Object;
      
      public var utensilMap:Object;
      
      public var decorationMap:Object;
      
      public var decorationId:int;
      
      public var wantedGudetamas:Array;
      
      public var maxDelusion:int;
      
      public var delusionStartTimeSecs:int;
      
      public var touchInfo:TouchInfo;
      
      public var dropItemEvent:TouchEventParam;
      
      public var heavenEvent:TouchEventParam;
      
      public var userAbilities:Array;
      
      public var features:Array;
      
      public var numAcquiredVideoAdReward:int;
      
      public var videoAdRewardUpdateTimeSecs:int;
      
      public var linkageMap:Object;
      
      public var numPurchaseMap:Object;
      
      public var numFriendsExtension:int;
      
      public var snsInterlockType:int;
      
      public var snsTwitterUid:String;
      
      public var snsFacebookUid:String;
      
      public var purchasePresentMap:Object;
      
      public var placeGudetamaExpansionCount:int;
      
      public var placeStampExpansionCount:int;
      
      public var commentList:Array;
      
      public var finishMonthlyPremiumBonusTimeSec:int;
      
      public var noticeMonthlyPremiumBonusTimeSec:int;
      
      public var sendTouchCount:int;
      
      public var numAcquiredIdentifiedPresentMap:Object;
      
      public var setItemBuyMap:Object;
      
      public var numFriendPresentForGPWhileEventMap:Object;
      
      public var cupGachaData:CupGachaData;
      
      public var cupGachaConditionClearIds:Array;
      
      public var homeDecoDataMap:Object;
      
      public var placeHomeStampExpansionCount:int;
      
      public function UserData()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:* = 0;
         var _loc3_:int = 0;
         uid = param1.readInt();
         encodedUid = param1.readInt();
         playerName = param1.readUTF();
         gender = param1.readInt();
         doneFirstLogin = param1.readBoolean();
         pushFlags = param1.readInt();
         nextDailyPresentTime = param1.readDouble();
         timeZoneOffset = param1.readInt();
         noticeFlagData = CompatibleDataIO.read(param1) as NoticeFlagData;
         locale = param1.readUTF();
         rank = param1.readInt();
         chargeMetal = param1.readInt();
         freeMetal = param1.readInt();
         subMetal = param1.readInt();
         chargeMoney = param1.readInt();
         freeMoney = param1.readInt();
         avatar = param1.readInt();
         _loc2_ = uint(param1.readShort());
         avatarMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            avatarMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         area = param1.readInt();
         comment = param1.readShort();
         placedGudetamaId = param1.readInt();
         _loc2_ = uint(param1.readShort());
         kitchenwareMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            kitchenwareMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         recipeNoteMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            recipeNoteMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         gudetamaMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            gudetamaMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         gachaMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            gachaMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         friendPresentMoneyParamMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            friendPresentMoneyParamMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         stampMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            stampMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         usefulMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            usefulMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         utensilMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            utensilMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         decorationMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            decorationMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         decorationId = param1.readInt();
         wantedGudetamas = CompatibleDataIO.read(param1) as Array;
         maxDelusion = param1.readInt();
         delusionStartTimeSecs = param1.readInt();
         touchInfo = CompatibleDataIO.read(param1) as TouchInfo;
         dropItemEvent = CompatibleDataIO.read(param1) as TouchEventParam;
         heavenEvent = CompatibleDataIO.read(param1) as TouchEventParam;
         userAbilities = CompatibleDataIO.read(param1) as Array;
         features = CompatibleDataIO.read(param1) as Array;
         numAcquiredVideoAdReward = param1.readInt();
         videoAdRewardUpdateTimeSecs = param1.readInt();
         _loc2_ = uint(param1.readShort());
         linkageMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            linkageMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         numPurchaseMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            numPurchaseMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         numFriendsExtension = param1.readInt();
         snsInterlockType = param1.readByte();
         snsTwitterUid = param1.readUTF();
         snsFacebookUid = param1.readUTF();
         _loc2_ = uint(param1.readShort());
         purchasePresentMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            purchasePresentMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         placeGudetamaExpansionCount = param1.readShort();
         placeStampExpansionCount = param1.readShort();
         _loc2_ = uint(param1.readShort());
         commentList = new Array(_loc2_);
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            commentList[_loc3_] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         finishMonthlyPremiumBonusTimeSec = param1.readInt();
         noticeMonthlyPremiumBonusTimeSec = param1.readInt();
         sendTouchCount = param1.readInt();
         _loc2_ = uint(param1.readShort());
         numAcquiredIdentifiedPresentMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            numAcquiredIdentifiedPresentMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         setItemBuyMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            setItemBuyMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         numFriendPresentForGPWhileEventMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            numFriendPresentForGPWhileEventMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         cupGachaData = CompatibleDataIO.read(param1) as CupGachaData;
         _loc2_ = uint(param1.readShort());
         cupGachaConditionClearIds = new Array(_loc2_);
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            cupGachaConditionClearIds[_loc3_] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         homeDecoDataMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            homeDecoDataMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         placeHomeStampExpansionCount = param1.readShort();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(uid);
         param1.writeInt(encodedUid);
         param1.writeUTF(playerName);
         param1.writeInt(gender);
         param1.writeBoolean(doneFirstLogin);
         param1.writeInt(pushFlags);
         param1.writeDouble(nextDailyPresentTime);
         param1.writeInt(timeZoneOffset);
         CompatibleDataIO.write(param1,noticeFlagData);
         param1.writeUTF(locale);
         param1.writeInt(rank);
         param1.writeInt(chargeMetal);
         param1.writeInt(freeMetal);
         param1.writeInt(subMetal);
         param1.writeInt(chargeMoney);
         param1.writeInt(freeMoney);
         param1.writeInt(avatar);
         CompatibleDataIO.write(param1,avatarMap,7);
         param1.writeInt(area);
         param1.writeShort(comment);
         param1.writeInt(placedGudetamaId);
         CompatibleDataIO.write(param1,kitchenwareMap,7);
         CompatibleDataIO.write(param1,recipeNoteMap,7);
         CompatibleDataIO.write(param1,gudetamaMap,7);
         CompatibleDataIO.write(param1,gachaMap,7);
         CompatibleDataIO.write(param1,friendPresentMoneyParamMap,7);
         CompatibleDataIO.write(param1,stampMap,7);
         CompatibleDataIO.write(param1,usefulMap,7);
         CompatibleDataIO.write(param1,utensilMap,7);
         CompatibleDataIO.write(param1,decorationMap,7);
         param1.writeInt(decorationId);
         CompatibleDataIO.write(param1,wantedGudetamas,1);
         param1.writeInt(maxDelusion);
         param1.writeInt(delusionStartTimeSecs);
         CompatibleDataIO.write(param1,touchInfo);
         CompatibleDataIO.write(param1,dropItemEvent);
         CompatibleDataIO.write(param1,heavenEvent);
         CompatibleDataIO.write(param1,userAbilities,1);
         CompatibleDataIO.write(param1,features,2);
         param1.writeInt(numAcquiredVideoAdReward);
         param1.writeInt(videoAdRewardUpdateTimeSecs);
         CompatibleDataIO.write(param1,linkageMap,7);
         CompatibleDataIO.write(param1,numPurchaseMap,7);
         param1.writeInt(numFriendsExtension);
         param1.writeByte(snsInterlockType);
         param1.writeUTF(snsTwitterUid);
         param1.writeUTF(snsFacebookUid);
         CompatibleDataIO.write(param1,purchasePresentMap,7);
         param1.writeShort(placeGudetamaExpansionCount);
         param1.writeShort(placeStampExpansionCount);
         CompatibleDataIO.write(param1,commentList,9);
         param1.writeInt(finishMonthlyPremiumBonusTimeSec);
         param1.writeInt(noticeMonthlyPremiumBonusTimeSec);
         param1.writeInt(sendTouchCount);
         CompatibleDataIO.write(param1,numAcquiredIdentifiedPresentMap,7);
         CompatibleDataIO.write(param1,setItemBuyMap,7);
         CompatibleDataIO.write(param1,numFriendPresentForGPWhileEventMap,7);
         CompatibleDataIO.write(param1,cupGachaData);
         CompatibleDataIO.write(param1,cupGachaConditionClearIds,9);
         CompatibleDataIO.write(param1,homeDecoDataMap,7);
         param1.writeShort(placeHomeStampExpansionCount);
      }
   }
}
