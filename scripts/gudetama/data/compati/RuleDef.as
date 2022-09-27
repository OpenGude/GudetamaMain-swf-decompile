package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class RuleDef
   {
      
      public static const GACHA_RATE_SCREENING_NONE:int = 0;
      
      public static const GACHA_RATE_SCREENING_KIND:int = 1;
      
      public static const GACHA_RATE_SCREENING_ALL:int = 2;
      
      public static const TYPE_SHARE_BONUS_AFTER:int = 0;
      
      public static const TYPE_SHARE_BONUS_BEFORE:int = 1;
       
      
      public var focusGainedLimitTimeMinites:int;
      
      public var reloadFollowerTime:int;
      
      public var ruleFlags:ByteArray;
      
      public var roundingFollowPastDay:int;
      
      public var locale:String;
      
      public var localeCode:Array;
      
      public var titleMusic:int;
      
      public var heavenTimeSecs:int;
      
      public var touchRewards:Array;
      
      public var carnaviIds:Array;
      
      public var enabledMoneyShop:Boolean;
      
      public var menuItems:Array;
      
      public var shopItems:Array;
      
      public var collectionTypes:Array;
      
      public var hurryUpReduceMinutesPerMetal:int;
      
      public var hurryUpMetalBase:int;
      
      public var cookingTooMatchTimeHours:int;
      
      public var lowerLimitPercentForRouletteSpeed:int;
      
      public var hurryUpItemBaseMap:Object;
      
      public var hurryUpReduceMinutesPerItem:Object;
      
      public var gachaRateScreeningLevel:int;
      
      public var missionCommentAchievePercent:Array;
      
      public var maxFriendsExtension:int;
      
      public var friendsExtensionValue:int;
      
      public var friendsExtensionPrices:Array;
      
      public var updateFollowerTime:int;
      
      public var maximumFriendPresentForGPWhileEvent:int;
      
      public var friendlyValueByAssist:int;
      
      public var gudetamaTeamIds:Array;
      
      public var minimumMessageTime:int;
      
      public var messagePercents:Array;
      
      public var messageResetHourOffset:int;
      
      public var friendPresentCost:int;
      
      public var friendPresentGp:int;
      
      public var friendPresentGpCountPerDay:int;
      
      public var friendPresentGpGlobalCountPerDay:int;
      
      public var freeFriendPresentCountPerDay:int;
      
      public var placeArGudetamaNumTable:Array;
      
      public var placeArStampNumTable:Array;
      
      public var placeHomeStampNumTable:Array;
      
      public var numScreeningPresentLogs:int;
      
      public var maxFriendPresentMoneyPerRank:int;
      
      public var maxAssistPerDay:int;
      
      public var defStampSpainPath:String;
      
      public var imobileAndroidPlacement:Array;
      
      public var imobileIOSPlacement:Array;
      
      public var fiveAdsAndroidId:String;
      
      public var fiveAdsIOSId:String;
      
      public var fiveAdsAndroidSlotId:Array;
      
      public var fiveAdsIOSSlotId:Array;
      
      public var nendAdsAndroidIds:Array;
      
      public var nendAdsIOSIds:Array;
      
      public var eventBannerUpdateTime:int;
      
      public var bannerCircleSec:int;
      
      public var bannerCircle:Boolean;
      
      public var disableBannerOSVersionMap:Object;
      
      public var maioAdsAndroidId:String;
      
      public var maioAdsIOSId:String;
      
      public var maioAdsZoneAndroidId:String;
      
      public var maioAdsZoneIOSId:String;
      
      public var videoTraceErrorSec:int;
      
      public var tapjoyAdsAndroidId:Array;
      
      public var tapjoyAdsIOSId:Array;
      
      public var vangleAdsAndroidId:String;
      
      public var vangleAdsIOSId:String;
      
      public var vangleAdsAndroidPlacementIds:Array;
      
      public var vangleAdsIOSPlacementIds:Array;
      
      public var ironsourceAdsAndroidId:String;
      
      public var ironsourceAdsIOSId:String;
      
      public var ironSourceGlobalAdsAndroidId:String;
      
      public var ironSourceGlobalAdsIOSId:String;
      
      public var admobBannerAndroidId:String;
      
      public var admobBannerIOSId:String;
      
      public var admobVideoAndroidId:String;
      
      public var admobVideoIOSId:String;
      
      public var nendAndroidIds:Array;
      
      public var nendIOSIds:Array;
      
      public var chartboosVideoAndroidIds:Array;
      
      public var chartboosVideoIOSIds:Array;
      
      public var promotionVideoNames:Array;
      
      public var promotionVideoIdAndRatio:Array;
      
      public var priorityMaxVideoCount:int;
      
      public var preLoadingVideoSecs:int;
      
      public var videoLodingIntervalMillisec:int;
      
      public var videoGlobalLodingIntervalMillisec:int;
      
      public var videoInitGiveupMilliSec:int;
      
      public var imobileInterstitialAndroidPlacement:Array;
      
      public var imobileInterstitialIOSPlacement:Array;
      
      public var nendInterstitialAndroid:Array;
      
      public var nendInterstitialIOS:Array;
      
      public var interstitiaIntervalSecs:int;
      
      public var interstitiaIntervalGlobalSecs:int;
      
      public var ironVideoPlacementAndroidId:Array;
      
      public var ironVideoPlacementIOSId:Array;
      
      public var ironOfferPlacementAndroidId:Array;
      
      public var ironOfferPlacementIOSId:Array;
      
      public var ironInterPlacementAndroidId:Array;
      
      public var ironInterPlacementIOSId:Array;
      
      public var twitter_Key:String;
      
      public var twitter_Secret:String;
      
      public var facebook_Key:String;
      
      public var useSnsTwitter:Boolean;
      
      public var useSnsFacebook:Boolean;
      
      public var tiwtterSchemeAndroidURL:String;
      
      public var tiwtterSchemeIOSURL:String;
      
      public var snsLinkBonusNum:int;
      
      public var usefulShopShortcut:Boolean;
      
      public var presentDeliverPtsPercent:int;
      
      public var snsShareBonusType:int;
      
      public var cupGachaOpenMinPerTier:int;
      
      public var cupGachaOpenMetalPerTier:int;
      
      public var cupGachaShortMinByAd:int;
      
      public var cupGachaShortNumByAd:int;
      
      public var cupGachaMailKeepDay:int;
      
      public var useHomeDecoEachType:Boolean;
      
      public var cookingShortCut:Boolean;
      
      public var memoryCookingRecipe:Boolean;
      
      public var frameIds:Array;
      
      public var titleName:String;
      
      public var titleSpineName:String;
      
      public var titleGudetamaSpineName:String;
      
      public var duplicateSceneCheckClasses:Array;
      
      public var titleNameCountry:Object;
      
      public var titleSpineNameCountry:Object;
      
      public var titleGudetamaSpineNameCountry:Object;
      
      public function RuleDef()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:* = 0;
         var _loc3_:int = 0;
         focusGainedLimitTimeMinites = param1.readByte();
         reloadFollowerTime = param1.readInt();
         ruleFlags = CompatibleDataIO.read(param1) as ByteArray;
         roundingFollowPastDay = param1.readByte();
         locale = param1.readUTF();
         localeCode = CompatibleDataIO.read(param1) as Array;
         titleMusic = param1.readInt();
         heavenTimeSecs = param1.readInt();
         touchRewards = CompatibleDataIO.read(param1) as Array;
         carnaviIds = CompatibleDataIO.read(param1) as Array;
         enabledMoneyShop = param1.readBoolean();
         menuItems = CompatibleDataIO.read(param1) as Array;
         shopItems = CompatibleDataIO.read(param1) as Array;
         collectionTypes = CompatibleDataIO.read(param1) as Array;
         hurryUpReduceMinutesPerMetal = param1.readInt();
         hurryUpMetalBase = param1.readInt();
         cookingTooMatchTimeHours = param1.readInt();
         lowerLimitPercentForRouletteSpeed = param1.readInt();
         _loc2_ = uint(param1.readShort());
         hurryUpItemBaseMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            hurryUpItemBaseMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         hurryUpReduceMinutesPerItem = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            hurryUpReduceMinutesPerItem[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         gachaRateScreeningLevel = param1.readInt();
         missionCommentAchievePercent = CompatibleDataIO.read(param1) as Array;
         maxFriendsExtension = param1.readShort();
         friendsExtensionValue = param1.readShort();
         friendsExtensionPrices = CompatibleDataIO.read(param1) as Array;
         updateFollowerTime = param1.readInt();
         maximumFriendPresentForGPWhileEvent = param1.readInt();
         friendlyValueByAssist = param1.readInt();
         gudetamaTeamIds = CompatibleDataIO.read(param1) as Array;
         minimumMessageTime = param1.readInt();
         messagePercents = CompatibleDataIO.read(param1) as Array;
         messageResetHourOffset = param1.readInt();
         friendPresentCost = param1.readInt();
         friendPresentGp = param1.readInt();
         friendPresentGpCountPerDay = param1.readInt();
         friendPresentGpGlobalCountPerDay = param1.readInt();
         freeFriendPresentCountPerDay = param1.readInt();
         placeArGudetamaNumTable = CompatibleDataIO.read(param1) as Array;
         placeArStampNumTable = CompatibleDataIO.read(param1) as Array;
         placeHomeStampNumTable = CompatibleDataIO.read(param1) as Array;
         numScreeningPresentLogs = param1.readInt();
         maxFriendPresentMoneyPerRank = param1.readInt();
         maxAssistPerDay = param1.readInt();
         defStampSpainPath = param1.readUTF();
         imobileAndroidPlacement = CompatibleDataIO.read(param1) as Array;
         imobileIOSPlacement = CompatibleDataIO.read(param1) as Array;
         fiveAdsAndroidId = param1.readUTF();
         fiveAdsIOSId = param1.readUTF();
         fiveAdsAndroidSlotId = CompatibleDataIO.read(param1) as Array;
         fiveAdsIOSSlotId = CompatibleDataIO.read(param1) as Array;
         nendAdsAndroidIds = CompatibleDataIO.read(param1) as Array;
         nendAdsIOSIds = CompatibleDataIO.read(param1) as Array;
         eventBannerUpdateTime = param1.readInt();
         bannerCircleSec = param1.readInt();
         bannerCircle = param1.readBoolean();
         _loc2_ = uint(param1.readShort());
         disableBannerOSVersionMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            disableBannerOSVersionMap[param1.readUTF()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         maioAdsAndroidId = param1.readUTF();
         maioAdsIOSId = param1.readUTF();
         maioAdsZoneAndroidId = param1.readUTF();
         maioAdsZoneIOSId = param1.readUTF();
         videoTraceErrorSec = param1.readInt();
         tapjoyAdsAndroidId = CompatibleDataIO.read(param1) as Array;
         tapjoyAdsIOSId = CompatibleDataIO.read(param1) as Array;
         vangleAdsAndroidId = param1.readUTF();
         vangleAdsIOSId = param1.readUTF();
         vangleAdsAndroidPlacementIds = CompatibleDataIO.read(param1) as Array;
         vangleAdsIOSPlacementIds = CompatibleDataIO.read(param1) as Array;
         ironsourceAdsAndroidId = param1.readUTF();
         ironsourceAdsIOSId = param1.readUTF();
         ironSourceGlobalAdsAndroidId = param1.readUTF();
         ironSourceGlobalAdsIOSId = param1.readUTF();
         admobBannerAndroidId = param1.readUTF();
         admobBannerIOSId = param1.readUTF();
         admobVideoAndroidId = param1.readUTF();
         admobVideoIOSId = param1.readUTF();
         nendAndroidIds = CompatibleDataIO.read(param1) as Array;
         nendIOSIds = CompatibleDataIO.read(param1) as Array;
         chartboosVideoAndroidIds = CompatibleDataIO.read(param1) as Array;
         chartboosVideoIOSIds = CompatibleDataIO.read(param1) as Array;
         promotionVideoNames = CompatibleDataIO.read(param1) as Array;
         promotionVideoIdAndRatio = CompatibleDataIO.read(param1) as Array;
         priorityMaxVideoCount = param1.readInt();
         preLoadingVideoSecs = param1.readInt();
         videoLodingIntervalMillisec = param1.readInt();
         videoGlobalLodingIntervalMillisec = param1.readInt();
         videoInitGiveupMilliSec = param1.readInt();
         imobileInterstitialAndroidPlacement = CompatibleDataIO.read(param1) as Array;
         imobileInterstitialIOSPlacement = CompatibleDataIO.read(param1) as Array;
         nendInterstitialAndroid = CompatibleDataIO.read(param1) as Array;
         nendInterstitialIOS = CompatibleDataIO.read(param1) as Array;
         interstitiaIntervalSecs = param1.readInt();
         interstitiaIntervalGlobalSecs = param1.readInt();
         ironVideoPlacementAndroidId = CompatibleDataIO.read(param1) as Array;
         ironVideoPlacementIOSId = CompatibleDataIO.read(param1) as Array;
         ironOfferPlacementAndroidId = CompatibleDataIO.read(param1) as Array;
         ironOfferPlacementIOSId = CompatibleDataIO.read(param1) as Array;
         ironInterPlacementAndroidId = CompatibleDataIO.read(param1) as Array;
         ironInterPlacementIOSId = CompatibleDataIO.read(param1) as Array;
         twitter_Key = param1.readUTF();
         twitter_Secret = param1.readUTF();
         facebook_Key = param1.readUTF();
         useSnsTwitter = param1.readBoolean();
         useSnsFacebook = param1.readBoolean();
         tiwtterSchemeAndroidURL = param1.readUTF();
         tiwtterSchemeIOSURL = param1.readUTF();
         snsLinkBonusNum = param1.readByte();
         usefulShopShortcut = param1.readBoolean();
         presentDeliverPtsPercent = param1.readInt();
         snsShareBonusType = param1.readInt();
         cupGachaOpenMinPerTier = param1.readInt();
         cupGachaOpenMetalPerTier = param1.readInt();
         cupGachaShortMinByAd = param1.readByte();
         cupGachaShortNumByAd = param1.readByte();
         cupGachaMailKeepDay = param1.readShort();
         useHomeDecoEachType = param1.readBoolean();
         cookingShortCut = param1.readBoolean();
         memoryCookingRecipe = param1.readBoolean();
         frameIds = CompatibleDataIO.read(param1) as Array;
         titleName = param1.readUTF();
         titleSpineName = param1.readUTF();
         titleGudetamaSpineName = param1.readUTF();
         duplicateSceneCheckClasses = CompatibleDataIO.read(param1) as Array;
         _loc2_ = uint(param1.readShort());
         titleNameCountry = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            titleNameCountry[param1.readUTF()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         titleSpineNameCountry = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            titleSpineNameCountry[param1.readUTF()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         titleGudetamaSpineNameCountry = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            titleGudetamaSpineNameCountry[param1.readUTF()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeByte(focusGainedLimitTimeMinites);
         param1.writeInt(reloadFollowerTime);
         CompatibleDataIO.write(param1,ruleFlags,4);
         param1.writeByte(roundingFollowPastDay);
         param1.writeUTF(locale);
         CompatibleDataIO.write(param1,localeCode,1);
         param1.writeInt(titleMusic);
         param1.writeInt(heavenTimeSecs);
         CompatibleDataIO.write(param1,touchRewards,2);
         CompatibleDataIO.write(param1,carnaviIds,2);
         param1.writeBoolean(enabledMoneyShop);
         CompatibleDataIO.write(param1,menuItems,2);
         CompatibleDataIO.write(param1,shopItems,2);
         CompatibleDataIO.write(param1,collectionTypes,2);
         param1.writeInt(hurryUpReduceMinutesPerMetal);
         param1.writeInt(hurryUpMetalBase);
         param1.writeInt(cookingTooMatchTimeHours);
         param1.writeInt(lowerLimitPercentForRouletteSpeed);
         CompatibleDataIO.write(param1,hurryUpItemBaseMap,7);
         CompatibleDataIO.write(param1,hurryUpReduceMinutesPerItem,7);
         param1.writeInt(gachaRateScreeningLevel);
         CompatibleDataIO.write(param1,missionCommentAchievePercent,2);
         param1.writeShort(maxFriendsExtension);
         param1.writeShort(friendsExtensionValue);
         CompatibleDataIO.write(param1,friendsExtensionPrices,2);
         param1.writeInt(updateFollowerTime);
         param1.writeInt(maximumFriendPresentForGPWhileEvent);
         param1.writeInt(friendlyValueByAssist);
         CompatibleDataIO.write(param1,gudetamaTeamIds,2);
         param1.writeInt(minimumMessageTime);
         CompatibleDataIO.write(param1,messagePercents,2);
         param1.writeInt(messageResetHourOffset);
         param1.writeInt(friendPresentCost);
         param1.writeInt(friendPresentGp);
         param1.writeInt(friendPresentGpCountPerDay);
         param1.writeInt(friendPresentGpGlobalCountPerDay);
         param1.writeInt(freeFriendPresentCountPerDay);
         CompatibleDataIO.write(param1,placeArGudetamaNumTable,3);
         CompatibleDataIO.write(param1,placeArStampNumTable,3);
         CompatibleDataIO.write(param1,placeHomeStampNumTable,3);
         param1.writeInt(numScreeningPresentLogs);
         param1.writeInt(maxFriendPresentMoneyPerRank);
         param1.writeInt(maxAssistPerDay);
         param1.writeUTF(defStampSpainPath);
         CompatibleDataIO.write(param1,imobileAndroidPlacement,1);
         CompatibleDataIO.write(param1,imobileIOSPlacement,1);
         param1.writeUTF(fiveAdsAndroidId);
         param1.writeUTF(fiveAdsIOSId);
         CompatibleDataIO.write(param1,fiveAdsAndroidSlotId,1);
         CompatibleDataIO.write(param1,fiveAdsIOSSlotId,1);
         CompatibleDataIO.write(param1,nendAdsAndroidIds,1);
         CompatibleDataIO.write(param1,nendAdsIOSIds,1);
         param1.writeInt(eventBannerUpdateTime);
         param1.writeInt(bannerCircleSec);
         param1.writeBoolean(bannerCircle);
         CompatibleDataIO.write(param1,disableBannerOSVersionMap,8);
         param1.writeUTF(maioAdsAndroidId);
         param1.writeUTF(maioAdsIOSId);
         param1.writeUTF(maioAdsZoneAndroidId);
         param1.writeUTF(maioAdsZoneIOSId);
         param1.writeInt(videoTraceErrorSec);
         CompatibleDataIO.write(param1,tapjoyAdsAndroidId,1);
         CompatibleDataIO.write(param1,tapjoyAdsIOSId,1);
         param1.writeUTF(vangleAdsAndroidId);
         param1.writeUTF(vangleAdsIOSId);
         CompatibleDataIO.write(param1,vangleAdsAndroidPlacementIds,1);
         CompatibleDataIO.write(param1,vangleAdsIOSPlacementIds,1);
         param1.writeUTF(ironsourceAdsAndroidId);
         param1.writeUTF(ironsourceAdsIOSId);
         param1.writeUTF(ironSourceGlobalAdsAndroidId);
         param1.writeUTF(ironSourceGlobalAdsIOSId);
         param1.writeUTF(admobBannerAndroidId);
         param1.writeUTF(admobBannerIOSId);
         param1.writeUTF(admobVideoAndroidId);
         param1.writeUTF(admobVideoIOSId);
         CompatibleDataIO.write(param1,nendAndroidIds,1);
         CompatibleDataIO.write(param1,nendIOSIds,1);
         CompatibleDataIO.write(param1,chartboosVideoAndroidIds,1);
         CompatibleDataIO.write(param1,chartboosVideoIOSIds,1);
         CompatibleDataIO.write(param1,promotionVideoNames,1);
         CompatibleDataIO.write(param1,promotionVideoIdAndRatio,1);
         param1.writeInt(priorityMaxVideoCount);
         param1.writeInt(preLoadingVideoSecs);
         param1.writeInt(videoLodingIntervalMillisec);
         param1.writeInt(videoGlobalLodingIntervalMillisec);
         param1.writeInt(videoInitGiveupMilliSec);
         CompatibleDataIO.write(param1,imobileInterstitialAndroidPlacement,1);
         CompatibleDataIO.write(param1,imobileInterstitialIOSPlacement,1);
         CompatibleDataIO.write(param1,nendInterstitialAndroid,1);
         CompatibleDataIO.write(param1,nendInterstitialIOS,1);
         param1.writeInt(interstitiaIntervalSecs);
         param1.writeInt(interstitiaIntervalGlobalSecs);
         CompatibleDataIO.write(param1,ironVideoPlacementAndroidId,1);
         CompatibleDataIO.write(param1,ironVideoPlacementIOSId,1);
         CompatibleDataIO.write(param1,ironOfferPlacementAndroidId,1);
         CompatibleDataIO.write(param1,ironOfferPlacementIOSId,1);
         CompatibleDataIO.write(param1,ironInterPlacementAndroidId,1);
         CompatibleDataIO.write(param1,ironInterPlacementIOSId,1);
         param1.writeUTF(twitter_Key);
         param1.writeUTF(twitter_Secret);
         param1.writeUTF(facebook_Key);
         param1.writeBoolean(useSnsTwitter);
         param1.writeBoolean(useSnsFacebook);
         param1.writeUTF(tiwtterSchemeAndroidURL);
         param1.writeUTF(tiwtterSchemeIOSURL);
         param1.writeByte(snsLinkBonusNum);
         param1.writeBoolean(usefulShopShortcut);
         param1.writeInt(presentDeliverPtsPercent);
         param1.writeInt(snsShareBonusType);
         param1.writeInt(cupGachaOpenMinPerTier);
         param1.writeInt(cupGachaOpenMetalPerTier);
         param1.writeByte(cupGachaShortMinByAd);
         param1.writeByte(cupGachaShortNumByAd);
         param1.writeShort(cupGachaMailKeepDay);
         param1.writeBoolean(useHomeDecoEachType);
         param1.writeBoolean(cookingShortCut);
         param1.writeBoolean(memoryCookingRecipe);
         CompatibleDataIO.write(param1,frameIds,3);
         param1.writeUTF(titleName);
         param1.writeUTF(titleSpineName);
         param1.writeUTF(titleGudetamaSpineName);
         CompatibleDataIO.write(param1,duplicateSceneCheckClasses,1);
         CompatibleDataIO.write(param1,titleNameCountry,8);
         CompatibleDataIO.write(param1,titleSpineNameCountry,8);
         CompatibleDataIO.write(param1,titleGudetamaSpineNameCountry,8);
      }
   }
}
