package gudetama.data
{
   import flash.filesystem.File;
   import flash.system.Capabilities;
   import flash.utils.ByteArray;
   import gudetama.data.compati.ARExpansionGoodsDef;
   import gudetama.data.compati.AvatarDef;
   import gudetama.data.compati.CommentDef;
   import gudetama.data.compati.CompatibleDataIO;
   import gudetama.data.compati.CupGachaDef;
   import gudetama.data.compati.DecorationDef;
   import gudetama.data.compati.DelusionDef;
   import gudetama.data.compati.FeatureDef;
   import gudetama.data.compati.FriendlyDef;
   import gudetama.data.compati.GachaDef;
   import gudetama.data.compati.GameDef;
   import gudetama.data.compati.GudetamaDef;
   import gudetama.data.compati.HelperCharaDef;
   import gudetama.data.compati.HomeExpansionGoodsDef;
   import gudetama.data.compati.HomeStampSettingDef;
   import gudetama.data.compati.IdentifiedPresentDef;
   import gudetama.data.compati.ItemParam;
   import gudetama.data.compati.KitchenwareDef;
   import gudetama.data.compati.LinearTable;
   import gudetama.data.compati.LinkageDef;
   import gudetama.data.compati.MetalShopDef;
   import gudetama.data.compati.MetalShopItemDef;
   import gudetama.data.compati.MissionData;
   import gudetama.data.compati.MissionDef;
   import gudetama.data.compati.MonthlyPremiumBonusDef;
   import gudetama.data.compati.OnlyShowItemDef;
   import gudetama.data.compati.PromotionVideoDef;
   import gudetama.data.compati.PurchasePresentDef;
   import gudetama.data.compati.PurchasePresentItemDef;
   import gudetama.data.compati.QuestionDef;
   import gudetama.data.compati.RankingContentDef;
   import gudetama.data.compati.RankingDef;
   import gudetama.data.compati.RankingRewardDef;
   import gudetama.data.compati.RecipeNoteDef;
   import gudetama.data.compati.RefreshCacheDef;
   import gudetama.data.compati.RuleDef;
   import gudetama.data.compati.SequenceTable;
   import gudetama.data.compati.SetItemDef;
   import gudetama.data.compati.ShareBonusDef;
   import gudetama.data.compati.StampDef;
   import gudetama.data.compati.TouchDef;
   import gudetama.data.compati.UsefulDef;
   import gudetama.data.compati.UtensilDef;
   import gudetama.data.compati.VideoAdRewardDef;
   import gudetama.data.compati.VoiceDef;
   import gudetama.data.compati._AbilityParam;
   import gudetama.engine.ApplicationSettings;
   import gudetama.engine.Engine;
   import gudetama.engine.Logger;
   import gudetama.engine.RsrcManager;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.util.StringUtil;
   import gudetama.util.TimeZoneUtil;
   import muku.core.MukuGlobal;
   import muku.util.ObjectUtil;
   import starling.textures.ConcreteTexture;
   import starling.utils.MathUtil;
   
   public class GameSetting
   {
      
      public static var def:GameDef;
      
      public static var language#2:String;
       
      
      public function GameSetting()
      {
         super();
      }
      
      public static function checkAndUncompress(param1:ByteArray) : void
      {
         var _loc3_:uint = param1.readUnsignedByte();
         var _loc2_:uint = param1.readUnsignedByte();
         if(_loc3_ == 120 && _loc2_ == 218)
         {
            param1.position = 0;
            param1.uncompress("zlib");
            Logger.debug("GameSetting was uncompressed.");
         }
         param1.position = 0;
      }
      
      public static function setup(param1:Function) : void
      {
         var completed:Function = param1;
         language#2 = Capabilities.language#2;
         Logger.debug("GameSetting#setup " + language#2);
         RsrcManager.getInstance().loadLocalGameSetting(function(param1:ByteArray):void
         {
            var data:ByteArray = param1;
            checkAndUncompress(data);
            try
            {
               def = CompatibleDataIO.read(data) as GameDef;
               Logger.debug("GameSetting#setup done: " + def);
            }
            catch(e:Error)
            {
               Logger.warn("GameSetting#setup failed: " + e.getStackTrace());
               RsrcManager.getInstance().clearGameSettingCache();
               RsrcManager.getInstance().loadLocalGameSetting(function(param1:ByteArray):void
               {
                  def = CompatibleDataIO.read(param1) as GameDef;
                  setupDone();
                  completed();
               });
               return;
            }
            setupDone();
            completed();
         });
      }
      
      public static function setupForVersion(param1:int, param2:Function, param3:Boolean = false) : void
      {
         var version:int = param1;
         var completed:Function = param2;
         var silent:Boolean = param3;
         RsrcManager.getInstance().downloadGameSetting(version,silent,function(param1:ByteArray):void
         {
            var _loc2_:int = getRefreshCacheLatestVersion();
            def = CompatibleDataIO.read(param1) as GameDef;
            setupDone();
            ResidentMenuUI_Gudetama.update();
            refreshCache(_loc2_);
            completed();
         });
      }
      
      private static function setupDone() : void
      {
         var _loc2_:* = null;
         ConcreteTexture.setTraceEnabled(GameSetting.hasScreeningFlag(0));
         RsrcManager.getInstance().setupFileCheckMap(def.fileInfos);
         var _loc1_:Object = {};
         for(_loc2_ in def.dict.uitext)
         {
            _loc1_[_loc2_] = def.dict.uitext[_loc2_];
         }
         for(_loc2_ in def.initDict.uitext)
         {
            _loc1_[_loc2_] = def.initDict.uitext[_loc2_];
         }
         var _loc8_:* = _loc1_;
         var _loc7_:* = MukuGlobal;
         muku.core.MukuGlobal._uitext = _loc8_;
         if(def.resourceUrl)
         {
            ApplicationSettings.setResourceUrlBase(def.resourceUrl);
         }
      }
      
      public static function setupForLocale(param1:String, param2:Function) : void
      {
      }
      
      public static function needsSystemFont() : Boolean
      {
         return language#2 == "ja" || language#2 == "ko" || language#2 == "zh-TW" || language#2 == "zh-CN" || language#2 == "zh-CN" || language#2 == "xu" || language#2 == "xv";
      }
      
      public static function getRuleLocale() : String
      {
         return def.rule.locale;
      }
      
      public static function hasScreeningFlag(param1:int) : Boolean
      {
         return getScreeningFlagValue(param1) != 0;
      }
      
      public static function getScreeningFlagValue(param1:int) : int
      {
         return def.screening.getFlagValue(param1);
      }
      
      private static function getRefreshCacheLatestVersion() : int
      {
         return 0;
      }
      
      private static function getRefreshCacheOldestVersion() : int
      {
         return 2147483647;
      }
      
      private static function refreshCache(param1:int) : void
      {
         var _loc4_:Boolean = false;
         var _loc3_:int = getRefreshCacheOldestVersion();
         var _loc2_:int = getRefreshCacheLatestVersion();
         if(_loc2_ > param1)
         {
            _loc4_ = false;
            if(_loc3_ > param1)
            {
               _loc4_ = true;
            }
            if(_loc4_)
            {
               clearResourceDirectory();
            }
         }
      }
      
      private static function clearResourceDirectory() : void
      {
         var _loc1_:File = RsrcManager.getInstance().getCacheFile("rsrc");
         if(_loc1_.exists)
         {
            _loc1_.deleteDirectory(true);
         }
      }
      
      private static function processRefreshCache(param1:RefreshCacheDef) : void
      {
         var _loc3_:int = 0;
         var _loc2_:* = null;
         for each(_loc3_ in param1.ability)
         {
            executeRefreshCache("rsrc/ability/ability" + _loc3_ + ".png");
         }
         for each(_loc3_ in param1.battleitem)
         {
            executeRefreshCache("rsrc/battleitem/battleitem" + _loc3_ + ".png");
            executeRefreshCache("rsrc/battleitem/r_battleitem" + _loc3_ + ".png");
            executeRefreshCache("rsrc/battleitem/s_battleitem" + _loc3_ + ".png");
         }
         for each(_loc3_ in param1.boost)
         {
            executeRefreshCache("rsrc/boost/boost" + _loc3_ + ".png");
            executeRefreshCache("rsrc/boost/boost_big" + _loc3_ + ".png");
         }
         for each(_loc2_ in param1.effect)
         {
            executeRefreshCache("rsrc/effect/" + _loc2_ + ".png");
         }
         for each(_loc3_ in param1.emo)
         {
            executeRefreshCache("rsrc/emo/" + _loc3_ + ".png");
         }
         for each(_loc3_ in param1.field)
         {
            executeRefreshCache("rsrc/field/bg" + _loc3_ + ".png");
         }
         for each(_loc3_ in param1.gacha)
         {
            executeRefreshCache("rsrc/gacha/picture" + _loc3_ + ".png");
         }
         for each(_loc2_ in param1.image)
         {
            executeRefreshCache("rsrc/image/" + _loc2_ + ".png");
         }
         for each(_loc2_ in param1.music)
         {
            executeRefreshCache("rsrc/music/" + _loc2_ + ".mp3");
         }
         for each(_loc2_ in param1.other)
         {
            executeRefreshCache("rsrc/other/" + _loc2_ + ".png");
         }
         for each(_loc3_ in param1.planet)
         {
            executeRefreshCache("rsrc/planet/planet" + _loc3_ + ".png");
            executeRefreshCache("rsrc/planet/planetname" + _loc3_ + ".png");
         }
         for each(_loc3_ in param1.stage)
         {
            executeRefreshCache("rsrc/stage/stage" + _loc3_ + ".png");
         }
         for each(_loc2_ in param1.test)
         {
            executeRefreshCache("rsrc/test/" + _loc2_ + ".png");
         }
         for each(_loc2_ in param1.ui)
         {
            executeRefreshCache("rsrc/ui/" + _loc2_ + ".png");
         }
         for each(_loc3_ in param1.upgrade)
         {
            executeRefreshCache("rsrc/upgrade/upgrade" + _loc3_ + ".png");
         }
         for each(_loc3_ in param1.voice)
         {
            executeRefreshCache("rsrc/voice/" + _loc3_ + ".mp3");
         }
         for each(_loc3_ in param1.robo)
         {
            executeRefreshCache("rsrc/robo/_" + _loc3_ + ".png");
            executeRefreshCache("rsrc/robo/cutin" + _loc3_ + ".png");
            executeRefreshCache("rsrc/robo/face" + _loc3_ + ".png");
            executeRefreshCache("rsrc/robo/rob" + _loc3_ + ".png");
         }
         for each(_loc2_ in param1.dialog)
         {
            executeRefreshCache("rsrc/dialog/" + _loc2_ + ".png");
         }
      }
      
      private static function executeRefreshCache(param1:String) : void
      {
         var _loc2_:File = RsrcManager.getInstance().getCacheFile(param1);
         if(_loc2_.exists)
         {
            _loc2_.deleteFile();
         }
      }
      
      public static function getInitUIText(param1:String) : String
      {
         var _loc2_:String = def.initDict.uitext[param1];
         return _loc2_ != null ? _loc2_ : "?" + param1;
      }
      
      public static function getInitUITextWithOutKey(param1:String) : String
      {
         return def.initDict.uitext[param1];
      }
      
      public static function getInitOtherText(param1:String) : String
      {
         var _loc2_:String = def.initDict.others[param1];
         return _loc2_ != null ? _loc2_ : "?" + param1;
      }
      
      public static function getInitOtherInt(param1:String, param2:int = 0) : int
      {
         var _loc3_:* = def.initDict.others[param1];
         if(_loc3_ is int)
         {
            return _loc3_;
         }
         return param2;
      }
      
      public static function getUIText(param1:String) : String
      {
         var _loc2_:String = def.dict.uitext[param1];
         return _loc2_ != null ? _loc2_ : getInitUIText(param1);
      }
      
      public static function getUITextWithOutKey(param1:String) : String
      {
         var _loc2_:String = def.dict.uitext[param1];
         return _loc2_ != null ? _loc2_ : getInitUITextWithOutKey(param1);
      }
      
      public static function getUITextArray(param1:String, param2:int) : String
      {
         if(def.dict.uitext[param1] == null)
         {
            return "?" + param1;
         }
         var _loc4_:String;
         var _loc3_:Array = (_loc4_ = def.dict.uitext[param1].replace("\\,","<br>")).split(",");
         return _loc3_ != null ? _loc3_[param2].replace("<br>",",") : "?" + param1;
      }
      
      public static function getTextPlain(param1:String) : String
      {
         var _loc2_:String = def.dict.textplain[param1];
         return _loc2_ != null ? _loc2_ : param1;
      }
      
      public static function getOtherText(param1:String) : String
      {
         var _loc2_:String = def.dict.others[param1];
         return _loc2_ != null ? _loc2_ : getInitOtherText(param1);
      }
      
      public static function getOtherTextWithOutKey(param1:String) : String
      {
         return def.dict.others[param1];
      }
      
      public static function getGuideText(param1:String) : String
      {
         var _loc2_:String = def.dict.guide[param1];
         return _loc2_ != null ? _loc2_ : "?" + param1;
      }
      
      public static function getGuideTextWithOutKey(param1:String) : String
      {
         return def.dict.others[param1];
      }
      
      public static function getNotice(param1:int) : String
      {
         var _loc2_:String = def.dict.notice[param1];
         return _loc2_ != null ? _loc2_ : "?" + param1;
      }
      
      public static function getHintNum() : int
      {
         return def.dict.hintNum;
      }
      
      public static function getUIVoice(param1:String) : Array
      {
         return def.dict.voice[param1];
      }
      
      public static function getARExpansionGoods(param1:int) : ARExpansionGoodsDef
      {
         var _loc2_:ARExpansionGoodsDef = def.arExpansionGoodsMap[param1];
         if(_loc2_ == null)
         {
            Logger.error("arExpansionGoodsMap undefined: " + param1);
         }
         return _loc2_;
      }
      
      public static function getARExpansionGoodsAtCount(param1:int, param2:int) : ARExpansionGoodsDef
      {
         var _loc3_:int = param1 == 1 ? 100 + param2 : Number(10 + param2);
         return getARExpansionGoods(_loc3_);
      }
      
      public static function getHomeExpansionGoods(param1:int) : HomeExpansionGoodsDef
      {
         var _loc2_:HomeExpansionGoodsDef = def.homeExpansionGoodsMap[param1];
         if(_loc2_ == null)
         {
            Logger.error("homeExpansionGoodsMap undefined: " + param1);
         }
         return _loc2_;
      }
      
      public static function getHomeExpansionGoodsAtCount(param1:int) : HomeExpansionGoodsDef
      {
         return getHomeExpansionGoods(param1);
      }
      
      public static function getMonthlyPremiumBonusTable() : Object
      {
         return def.monthlyPremiumBonusTable;
      }
      
      public static function getMonthlyPremiumBonus(param1:int) : MonthlyPremiumBonusDef
      {
         return def.monthlyPremiumBonusTable[param1];
      }
      
      public static function getMetalShop(param1:int) : MetalShopDef
      {
         return def.metalShopTable[param1];
      }
      
      public static function hasMetalShopCampaignSetting(param1:int) : Boolean
      {
         var _loc3_:int = 0;
         var _loc4_:* = null;
         var _loc2_:MetalShopDef = getMetalShop(param1);
         _loc3_ = 0;
         while(_loc3_ < _loc2_.items.length)
         {
            _loc4_ = checkOverlap(_loc2_.items[_loc3_]);
            if(GameSetting.checkLimit(_loc4_) && UserDataWrapper.wrapper.isPurchasable(_loc4_) && _loc4_.campaign > 0)
            {
               return true;
            }
            _loc3_++;
         }
         return false;
      }
      
      public static function checkLimit(param1:MetalShopItemDef) : Boolean
      {
         var _loc2_:Boolean = checkRankLimit(param1);
         if(!_loc2_)
         {
            return false;
         }
         return checkAppLimit(param1);
      }
      
      private static function checkRankLimit(param1:MetalShopItemDef) : Boolean
      {
         if(param1.ranklimit == -1)
         {
            return true;
         }
         return UserDataWrapper.wrapper.getRank() < param1.ranklimit;
      }
      
      public static function checkAppLimit(param1:MetalShopItemDef) : Boolean
      {
         var _loc3_:int = getChargeAppType();
         return (param1.applimit & _loc3_) != 0;
      }
      
      public static function getChargeAppType() : int
      {
         var _loc1_:int = 0;
         switch(int(Engine.platform))
         {
            case 0:
               _loc1_ = 2;
               break;
            case 1:
               _loc1_ = 4;
               break;
            case 2:
               _loc1_ = 1;
         }
         var _loc2_:Boolean = false;
         if(_loc2_)
         {
            _loc1_ = 8;
         }
         return _loc1_;
      }
      
      private static function checkOverlap(param1:MetalShopItemDef) : MetalShopItemDef
      {
         if(!param1.overlap)
         {
            return param1;
         }
         if(!UserDataWrapper.wrapper.isPurchasable(param1.overlap))
         {
            return param1;
         }
         if(!GameSetting.checkLimit(param1.overlap))
         {
            return param1;
         }
         return checkOverlap(param1.overlap);
      }
      
      public static function isAbilityInTerm(param1:_AbilityParam) : Boolean
      {
         var _loc2_:Number = TimeZoneUtil.epochMillisToOffsetSecs();
         if(param1.startTimeSecs > 0 && param1.startTimeSecs > _loc2_)
         {
            return false;
         }
         if(param1.endTimeSecs > 0 && param1.endTimeSecs <= _loc2_)
         {
            return false;
         }
         return true;
      }
      
      public static function getRanking(param1:int) : RankingDef
      {
         return def.rankingMap[param1];
      }
      
      public static function existsRankingContent(param1:int, param2:int) : Boolean
      {
         var _loc3_:RankingDef = getRanking(param1);
         if(!_loc3_)
         {
            return false;
         }
         for each(var _loc4_ in _loc3_.content)
         {
            if(_loc4_.type == param2)
            {
               return true;
            }
         }
         return false;
      }
      
      public static function getRankingReward(param1:int) : RankingRewardDef
      {
         return def.rankingRewardMap[param1];
      }
      
      public static function getSequenceValue(param1:SequenceTable, param2:int) : Number
      {
         return param1.values[MathUtil.clamp(param2 - param1.indexOffset,0,param1.values.length - 1)] * param1.rate + param1.offset;
      }
      
      public static function getLinearValue(param1:LinearTable, param2:int) : Number
      {
         var _loc7_:int = param2 - param1.indexOffset;
         var _loc12_:int;
         var _loc6_:int = (_loc12_ = (_loc12_ = ObjectUtil.binarySearch(param1.indexes,_loc7_)) < 0 ? -(_loc12_ + 1) : Number(_loc12_ + 1)) - 1;
         var _loc5_:int = Math.max(0,MathUtil.clamp(_loc6_,0,param1.values.length - 2));
         var _loc8_:int = param1.indexes[_loc5_];
         var _loc13_:Number = param1.values[_loc5_];
         var _loc9_:int = Math.min(param1.values.length - 1,MathUtil.clamp(_loc12_,1,param1.values.length - 1));
         var _loc11_:int = param1.indexes[_loc9_];
         var _loc4_:Number = param1.values[_loc9_];
         var _loc3_:int = _loc11_ - _loc8_;
         var _loc10_:Number = _loc4_ - _loc13_;
         var _loc14_:Number;
         return (_loc14_ = _loc13_ + (_loc7_ - _loc8_) * (_loc3_ != 0 ? _loc10_ / _loc3_ : 0)) * param1.rate + param1.offset;
      }
      
      public static function getHelperSetting(param1:int = -1) : HelperCharaDef
      {
         var _loc5_:* = null;
         var _loc6_:int = 0;
         var _loc7_:* = null;
         var _loc4_:int = 0;
         var _loc2_:Object = def.helperSettingMap;
         var _loc3_:* = null;
         if(param1 != -1)
         {
            return _loc2_[param1] as HelperCharaDef;
         }
         for(_loc5_ in _loc2_)
         {
            _loc6_ = Math.floor(Math.random() * 100);
            _loc4_ = (_loc7_ = _loc2_[_loc5_] as HelperCharaDef).showRate;
            if(!_loc3_ || _loc3_.showRate < _loc7_.showRate)
            {
               _loc3_ = _loc7_;
            }
            if(_loc4_ > _loc6_)
            {
               _loc3_ = _loc7_;
               break;
            }
         }
         DataStorage.getLocalData().helperId = parseInt(_loc5_);
         DataStorage.saveLocalData();
         return _loc3_;
      }
      
      public static function getHelperSettingLen() : int
      {
         var _loc1_:* = 0;
         for(var _loc2_ in def.helperSettingMap)
         {
            _loc1_++;
         }
         return _loc1_;
      }
      
      public static function getKitchenwareMap() : Object
      {
         return def.kitchenwareMap;
      }
      
      public static function getKitchenware(param1:int) : KitchenwareDef
      {
         return def.kitchenwareMap[param1];
      }
      
      public static function getKitchenwareByType(param1:int, param2:int) : KitchenwareDef
      {
         for each(var _loc3_ in def.kitchenwareMap)
         {
            if(_loc3_.type == param1 && _loc3_.grade == param2)
            {
               return _loc3_;
            }
         }
         return null;
      }
      
      public static function getRecipeNote(param1:int) : RecipeNoteDef
      {
         return def.recipeNoteMap[param1];
      }
      
      public static function getRecipeNotoId(param1:int) : int
      {
         var _loc5_:* = 0;
         var _loc4_:* = null;
         var _loc3_:Object = def.recipeNoteMap;
         for(_loc5_ in _loc3_)
         {
            if(!(_loc4_ = _loc3_[_loc5_] as RecipeNoteDef))
            {
               return -1;
            }
            for each(var _loc2_ in _loc4_.defaults)
            {
               if(_loc2_ == param1)
               {
                  return _loc4_.id#2;
               }
            }
            for each(_loc2_ in _loc4_.appends)
            {
               if(_loc2_ == param1)
               {
                  return _loc4_.id#2;
               }
            }
            for each(_loc2_ in _loc4_.happeningIds)
            {
               if(_loc2_ == param1)
               {
                  return _loc4_.id#2;
               }
            }
         }
         return -1;
      }
      
      public static function getGudetama(param1:int) : GudetamaDef
      {
         return def.gudetamaMap[param1];
      }
      
      public static function getGudetamaMap() : Object
      {
         return def.gudetamaMap;
      }
      
      public static function getVoice(param1:int) : VoiceDef
      {
         return def.voiceMap[param1];
      }
      
      public static function getVoiceMap() : Object
      {
         return def.voiceMap;
      }
      
      public static function getGacha(param1:int) : GachaDef
      {
         return def.gachaMap[param1];
      }
      
      public static function getStamp(param1:int) : StampDef
      {
         return def.stampMap[param1];
      }
      
      public static function getStampMap() : Object
      {
         return def.stampMap;
      }
      
      public static function getHomeStampSetting(param1:int) : HomeStampSettingDef
      {
         return def.homeStampSettingMap[param1];
      }
      
      public static function getUseful(param1:int) : UsefulDef
      {
         return def.usefulMap[param1];
      }
      
      public static function getUsefulMap() : Object
      {
         return def.usefulMap;
      }
      
      public static function getUtensil(param1:int) : UtensilDef
      {
         return def.utensilMap[param1];
      }
      
      public static function getUtensilMap() : Object
      {
         return def.utensilMap;
      }
      
      public static function getDecoration(param1:int) : DecorationDef
      {
         return def.decorationMap[param1];
      }
      
      public static function getDecorationMap() : Object
      {
         return def.decorationMap;
      }
      
      public static function existsDecorationPrice() : Boolean
      {
         for each(var _loc1_ in def.decorationMap)
         {
            if(_loc1_.price)
            {
               return true;
            }
         }
         return false;
      }
      
      public static function getMission(param1:int) : MissionDef
      {
         return def.missionMap[param1];
      }
      
      public static function getMissionDataType(param1:int) : Array
      {
         var _loc4_:* = 0;
         var _loc6_:* = null;
         var _loc5_:* = null;
         var _loc3_:Array = [];
         var _loc2_:Object = def.missionMap;
         for(_loc4_ in _loc2_)
         {
            if(((_loc6_ = GameSetting.getMission(_loc4_)).eventTypeFlags & param1) != 0)
            {
               if(_loc5_ = UserDataWrapper.missionPart.getMissionDataById(_loc6_.id#2))
               {
                  _loc3_.push({
                     "missionData":_loc5_,
                     "id":_loc4_,
                     "goalValue":_loc5_.goal
                  });
               }
            }
         }
         _loc3_.sortOn("goalValue",16);
         return _loc3_;
      }
      
      public static function getCurrentMissionDataByType(param1:int) : Object
      {
         var _loc3_:* = null;
         var _loc5_:* = null;
         var _loc6_:* = null;
         var _loc4_:* = null;
         var _loc7_:Array = getMissionDataType(param1);
         for each(_loc5_ in _loc7_)
         {
            if(_loc4_ = _loc5_.missionData as MissionData)
            {
               _loc6_ = _loc4_;
               if(_loc4_.goal - _loc4_.currentValue > 0)
               {
                  _loc3_ = _loc4_;
                  break;
               }
            }
         }
         var _loc2_:Object = {};
         if(_loc3_)
         {
            _loc2_ = {
               "resultcode":0,
               "missiondata":_loc3_
            };
         }
         else
         {
            _loc2_ = {
               "resultcode":-1,
               "missiondata":_loc6_
            };
         }
         return _loc2_;
      }
      
      public static function getMissionMap() : Object
      {
         return def.missionMap;
      }
      
      public static function getRule() : RuleDef
      {
         return def.rule;
      }
      
      public static function getDelusion() : DelusionDef
      {
         return def.delusion;
      }
      
      public static function getFeature() : FeatureDef
      {
         return def.feature;
      }
      
      public static function getFriendly() : FriendlyDef
      {
         return def.friendly;
      }
      
      public static function getVideoAdReward() : VideoAdRewardDef
      {
         return def.videoAdReward;
      }
      
      public static function getLinkage(param1:int) : LinkageDef
      {
         return def.linkageMap[param1];
      }
      
      public static function getLinkageMap() : Object
      {
         return def.linkageMap;
      }
      
      public static function getAvatar(param1:int) : AvatarDef
      {
         return def.avatarMap[param1];
      }
      
      public static function getAvatarMap() : Object
      {
         return def.avatarMap;
      }
      
      public static function getQuestion(param1:int) : QuestionDef
      {
         return def.questionMap[param1];
      }
      
      public static function getCommentDef(param1:int) : CommentDef
      {
         return def.commentMap[param1];
      }
      
      public static function getComment(param1:int) : String
      {
         var _loc2_:CommentDef = getCommentDef(param1);
         if(_loc2_ != null)
         {
            return _loc2_.name#2;
         }
         return getCommentDef(1).name#2;
      }
      
      public static function getPromotionVideo(param1:int) : PromotionVideoDef
      {
         return def.promotionVideoMap[param1];
      }
      
      public static function getTouch() : TouchDef
      {
         return def.touch;
      }
      
      public static function getPurchasePresent(param1:int) : PurchasePresentDef
      {
         var _loc2_:* = null;
         for each(var _loc3_ in def.purchasePresentTable)
         {
            _loc2_ = _loc3_.getItem(param1);
            if(_loc2_ != null)
            {
               return _loc3_;
            }
         }
         return null;
      }
      
      public static function isPrivately(param1:int, param2:int) : Boolean
      {
         var _loc4_:* = null;
         var _loc3_:* = null;
         switch(int(param1) - 8)
         {
            case 0:
               if(!(_loc4_ = getUseful(param2)))
               {
                  return true;
               }
               return _loc4_.privately;
               break;
            case 3:
               _loc3_ = getStamp(param2);
               if(!_loc3_)
               {
                  return true;
               }
               return _loc3_.privately;
               break;
            default:
               return false;
         }
      }
      
      public static function getIdentifiedPresent(param1:int) : IdentifiedPresentDef
      {
         return def.identifiedPresentMap[param1];
      }
      
      public static function getOnlyShowItem(param1:int) : OnlyShowItemDef
      {
         return def.onlyShowMap[param1];
      }
      
      public static function getShareBonus(param1:int) : ShareBonusDef
      {
         return def.shareBonusMap[param1];
      }
      
      public static function getSetItem(param1:int) : SetItemDef
      {
         return def.setItemMap[param1];
      }
      
      public static function getAddableSetItems(param1:int) : Array
      {
         var _loc2_:SetItemDef = getSetItem(param1);
         if(!_loc2_)
         {
            return null;
         }
         if(_loc2_.items)
         {
            for(var _loc3_ in _loc2_.items)
            {
               if(UserDataWrapper.wrapper.isItemAddable(_loc3_))
               {
                  return _loc2_.items;
               }
            }
            if(_loc2_.alternativeParam)
            {
               return _loc2_.alternativeParam.items;
            }
            return null;
         }
         if(_loc2_.alternativeParam)
         {
            return _loc2_.alternativeParam.items;
         }
         return null;
      }
      
      public static function isEnableBannerByPlatformVersion(param1:String, param2:String) : Boolean
      {
         var _loc5_:int = 0;
         if(!def || !def.rule || !def.rule.disableBannerOSVersionMap)
         {
            return true;
         }
         var _loc6_:Array = null;
         for(var _loc3_ in def.rule.disableBannerOSVersionMap)
         {
            if(StringUtil.startsWith(param1,_loc3_))
            {
               _loc6_ = def.rule.disableBannerOSVersionMap[_loc3_];
               break;
            }
         }
         if(!_loc6_)
         {
            return true;
         }
         var _loc4_:int = _loc6_.length;
         _loc5_ = 0;
         while(_loc5_ < _loc4_)
         {
            if(StringUtil.startsWith(param2,_loc6_[_loc5_]))
            {
               return false;
            }
            _loc5_++;
         }
         return true;
      }
      
      public static function getCupGacha(param1:int) : CupGachaDef
      {
         return def.cupGachaMap[param1];
      }
      
      public static function getCupGachaNameByMissionCommonID(param1:int) : String
      {
         var _loc4_:* = null;
         var _loc3_:* = 0;
         var _loc5_:* = null;
         var _loc2_:Object = def.cupGachaMap;
         for(_loc3_ in _loc2_)
         {
            if((_loc4_ = _loc2_[_loc3_]).missionCommonID == param1)
            {
               _loc5_ = _loc4_;
               if(_loc4_.cookMin != 0)
               {
                  return _loc4_.name#2;
               }
            }
         }
         if(_loc5_)
         {
            return _loc5_.name#2;
         }
         return "";
      }
   }
}
