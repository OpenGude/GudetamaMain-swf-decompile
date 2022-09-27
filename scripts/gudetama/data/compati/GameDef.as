package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class GameDef
   {
       
      
      public var version:int;
      
      public var dict:DictDef;
      
      public var initDict:InitDictDef;
      
      public var rule:RuleDef;
      
      public var screening:ScreeningDef;
      
      public var kitchenwareMap:Object;
      
      public var recipeNoteMap:Object;
      
      public var gudetamaMap:Object;
      
      public var voiceMap:Object;
      
      public var gachaMap:Object;
      
      public var usefulMap:Object;
      
      public var decorationMap:Object;
      
      public var utensilMap:Object;
      
      public var stampMap:Object;
      
      public var avatarMap:Object;
      
      public var missionMap:Object;
      
      public var touch:TouchDef;
      
      public var delusion:DelusionDef;
      
      public var feature:FeatureDef;
      
      public var friendly:FriendlyDef;
      
      public var videoAdReward:VideoAdRewardDef;
      
      public var linkageMap:Object;
      
      public var questionMap:Object;
      
      public var arExpansionGoodsMap:Object;
      
      public var hideGudeMap:Object;
      
      public var commentMap:Object;
      
      public var promotionVideoMap:Object;
      
      public var identifiedPresentMap:Object;
      
      public var shareBonusMap:Object;
      
      public var quizGenreIdMax:int;
      
      public var battleItemIdMax:int;
      
      public var metalShopTable:Object;
      
      public var monthlyPremiumBonusTable:Object;
      
      public var guideTalkTable:Object;
      
      public var rankingMap:Object;
      
      public var rankingRewardMap:Object;
      
      public var fileInfos:Array;
      
      public var locale:String;
      
      public var resourceUrl:String;
      
      public var purchasePresentTable:Object;
      
      public var bannerTable:Object;
      
      public var interTable:Object;
      
      public var deliverPointTableMap:Object;
      
      public var setItemMap:Object;
      
      public var comicMap:Object;
      
      public var onlyShowMap:Object;
      
      public var cupGachaMap:Object;
      
      public var homeExpansionGoodsMap:Object;
      
      public var homeStampSettingMap:Object;
      
      public var kitchenwareConditionMap:Object;
      
      public var helperSettingMap:Object;
      
      public var helperComicDef:ComicDef;
      
      public function GameDef()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:* = 0;
         var _loc3_:int = 0;
         version = param1.readInt();
         dict = CompatibleDataIO.read(param1) as DictDef;
         initDict = CompatibleDataIO.read(param1) as InitDictDef;
         rule = CompatibleDataIO.read(param1) as RuleDef;
         screening = CompatibleDataIO.read(param1) as ScreeningDef;
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
         voiceMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            voiceMap[param1.readInt()] = CompatibleDataIO.read(param1);
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
         usefulMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            usefulMap[param1.readInt()] = CompatibleDataIO.read(param1);
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
         _loc2_ = uint(param1.readShort());
         utensilMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            utensilMap[param1.readInt()] = CompatibleDataIO.read(param1);
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
         avatarMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            avatarMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         missionMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            missionMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         touch = CompatibleDataIO.read(param1) as TouchDef;
         delusion = CompatibleDataIO.read(param1) as DelusionDef;
         feature = CompatibleDataIO.read(param1) as FeatureDef;
         friendly = CompatibleDataIO.read(param1) as FriendlyDef;
         videoAdReward = CompatibleDataIO.read(param1) as VideoAdRewardDef;
         _loc2_ = uint(param1.readShort());
         linkageMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            linkageMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         questionMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            questionMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         arExpansionGoodsMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            arExpansionGoodsMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         hideGudeMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            hideGudeMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         commentMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            commentMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         promotionVideoMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            promotionVideoMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         identifiedPresentMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            identifiedPresentMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         shareBonusMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            shareBonusMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         quizGenreIdMax = param1.readInt();
         battleItemIdMax = param1.readInt();
         _loc2_ = uint(param1.readShort());
         metalShopTable = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            metalShopTable[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         monthlyPremiumBonusTable = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            monthlyPremiumBonusTable[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         guideTalkTable = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            guideTalkTable[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         rankingMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            rankingMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         rankingRewardMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            rankingRewardMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         fileInfos = CompatibleDataIO.read(param1) as Array;
         locale = param1.readUTF();
         resourceUrl = param1.readUTF();
         _loc2_ = uint(param1.readShort());
         purchasePresentTable = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            purchasePresentTable[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         bannerTable = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            bannerTable[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         interTable = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            interTable[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         deliverPointTableMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            deliverPointTableMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         setItemMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            setItemMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         comicMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            comicMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         onlyShowMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            onlyShowMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         cupGachaMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            cupGachaMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         homeExpansionGoodsMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            homeExpansionGoodsMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         homeStampSettingMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            homeStampSettingMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         kitchenwareConditionMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            kitchenwareConditionMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         helperSettingMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            helperSettingMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         helperComicDef = CompatibleDataIO.read(param1) as ComicDef;
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(version);
         CompatibleDataIO.write(param1,dict);
         CompatibleDataIO.write(param1,initDict);
         CompatibleDataIO.write(param1,rule);
         CompatibleDataIO.write(param1,screening);
         CompatibleDataIO.write(param1,kitchenwareMap,7);
         CompatibleDataIO.write(param1,recipeNoteMap,7);
         CompatibleDataIO.write(param1,gudetamaMap,7);
         CompatibleDataIO.write(param1,voiceMap,7);
         CompatibleDataIO.write(param1,gachaMap,7);
         CompatibleDataIO.write(param1,usefulMap,7);
         CompatibleDataIO.write(param1,decorationMap,7);
         CompatibleDataIO.write(param1,utensilMap,7);
         CompatibleDataIO.write(param1,stampMap,7);
         CompatibleDataIO.write(param1,avatarMap,7);
         CompatibleDataIO.write(param1,missionMap,7);
         CompatibleDataIO.write(param1,touch);
         CompatibleDataIO.write(param1,delusion);
         CompatibleDataIO.write(param1,feature);
         CompatibleDataIO.write(param1,friendly);
         CompatibleDataIO.write(param1,videoAdReward);
         CompatibleDataIO.write(param1,linkageMap,7);
         CompatibleDataIO.write(param1,questionMap,7);
         CompatibleDataIO.write(param1,arExpansionGoodsMap,7);
         CompatibleDataIO.write(param1,hideGudeMap,7);
         CompatibleDataIO.write(param1,commentMap,7);
         CompatibleDataIO.write(param1,promotionVideoMap,7);
         CompatibleDataIO.write(param1,identifiedPresentMap,7);
         CompatibleDataIO.write(param1,shareBonusMap,7);
         param1.writeInt(quizGenreIdMax);
         param1.writeInt(battleItemIdMax);
         CompatibleDataIO.write(param1,metalShopTable,7);
         CompatibleDataIO.write(param1,monthlyPremiumBonusTable,7);
         CompatibleDataIO.write(param1,guideTalkTable,7);
         CompatibleDataIO.write(param1,rankingMap,7);
         CompatibleDataIO.write(param1,rankingRewardMap,7);
         CompatibleDataIO.write(param1,fileInfos,1);
         param1.writeUTF(locale);
         param1.writeUTF(resourceUrl);
         CompatibleDataIO.write(param1,purchasePresentTable,7);
         CompatibleDataIO.write(param1,bannerTable,7);
         CompatibleDataIO.write(param1,interTable,7);
         CompatibleDataIO.write(param1,deliverPointTableMap,7);
         CompatibleDataIO.write(param1,setItemMap,7);
         CompatibleDataIO.write(param1,comicMap,7);
         CompatibleDataIO.write(param1,onlyShowMap,7);
         CompatibleDataIO.write(param1,cupGachaMap,7);
         CompatibleDataIO.write(param1,homeExpansionGoodsMap,7);
         CompatibleDataIO.write(param1,homeStampSettingMap,7);
         CompatibleDataIO.write(param1,kitchenwareConditionMap,7);
         CompatibleDataIO.write(param1,helperSettingMap,7);
         CompatibleDataIO.write(param1,helperComicDef);
      }
   }
}
