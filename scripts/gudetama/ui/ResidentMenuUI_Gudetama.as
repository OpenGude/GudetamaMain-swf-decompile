package gudetama.ui
{
   import gudetama.common.BannerAdvertisingManager;
   import gudetama.common.NativeExtensions;
   import gudetama.data.DataStorage;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.NoticeFlagData;
   import gudetama.data.compati.RankingContentDef;
   import gudetama.data.compati.RankingDef;
   import gudetama.data.compati.RankingRewardDef;
   import gudetama.data.compati.RankingRewardItemDef;
   import gudetama.data.compati.SystemMailData;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.Logger;
   import gudetama.engine.RsrcManager;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.scene.home.HomeScene;
   import gudetama.util.SpriteExtractor;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ImageButton;
   import starling.core.Starling;
   import starling.display.Image;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.textures.Texture;
   
   public class ResidentMenuUI_Gudetama extends BaseScene
   {
      
      public static const STATE_OTHER:int = -1;
      
      public static const STATE_DEBUG:int = 0;
      
      public static const STATE_HOME:int = 60;
      
      public static const STATE_SHOP:int = 62;
      
      public static const STATE_FRIEND:int = 63;
      
      public static const STATE_OPENING:int = 77;
      
      public static const STATE_COOKING:int = 141;
      
      public static const STATE_COLLECTION:int = 142;
      
      public static const STATE_GACHA:int = 143;
      
      public static const STATE_MISSION:int = 144;
      
      public static const STATE_PROFILE:int = 145;
      
      public static const STATE_DECORATION:int = 146;
      
      public static const STATE_LINKAGE:int = 147;
      
      public static const STATE_OPTION:int = 148;
      
      public static const STATE_AR:int = 149;
      
      public static const VISIBLE_NONE:int = 1;
      
      public static const VISIBLE_ON_UPPER_SPRITE:int = 2;
      
      public static const VISIBLE_ON_LOWER_SPRITE:int = 4;
      
      public static const BTN_BACK:int = 8;
      
      public static const BTN_ROOM:int = 16;
      
      public static const VISIBLE_UPPER_ABILITY:int = 32;
      
      public static const VISIBLE_LOWER_ABILITY:int = 64;
      
      public static const VISIBLE_ON_LOWER_BACK:int = 12;
      
      public static const VISIBLE_ON_LOWER_SPRITE_WITH_LOWER_ABILITY:int = 68;
      
      public static const VISIBLE_ON_UPPER_UI_ALL:int = 66;
      
      public static const VISIBLE_ON_LOWER_UI_ALL:int = 92;
      
      public static const VISIBLE_ON_LOWER_UI_WITHOUT_ROOM_BUTTON:int = 76;
      
      public static const VISIBLE_ON_LOWER_SPRITE_WITHOUT_ROOM_BUTTON:int = 12;
      
      public static const VISIBLE_ON_WITHOUT_LOWER_BUTTON:int = 70;
      
      public static const VISIBLE_ON_SPRITE_WITH_UPPER_ABILITY:int = 38;
      
      public static const VISIBLE_ON_WITHOUT_ROOM_BUTTON:int = 78;
      
      public static const VISIBLE_ON_WITHOUT_LOWER_ABILITY:int = 30;
      
      public static const VISIBLE_ON_LOWER_SPRITE_WITHOUT_LOWER_ABILITY:int = 28;
      
      public static const VISIBLE_ON_ALLWITHOUT_LOWER_BACK:int = 86;
      
      public static const VISIBLE_ON_ALL:int = 94;
      
      private static var instance:ResidentMenuUI_Gudetama;
       
      
      private var upperPart:UpperPart;
      
      private var lowerPart:LowerPart;
      
      private var spUpper:Sprite;
      
      private var spLower:Sprite;
      
      private var amountExtractor:SpriteExtractor;
      
      private var currentState:int;
      
      private var currentRequestedFramerate:Number;
      
      private var skipUnchangedFrames:Boolean;
      
      private var spAdBG:Sprite;
      
      private var quadAd:Quad;
      
      private var imgAdDot:Image;
      
      private var imgPR:Image;
      
      private var texPR:Texture;
      
      private var imgNoAd:Image;
      
      private var bannerButton:ImageButton;
      
      private var bannarManager:BannerManager;
      
      private var bannerIds:Object;
      
      private var setupAd:Boolean = false;
      
      private var setupMenu:Boolean = false;
      
      private const UPPER_X:int = 320;
      
      private const LOWER_Y:int = 1000;
      
      public function ResidentMenuUI_Gudetama(param1:TaskQueue)
      {
         var _queue:TaskQueue = param1;
         currentRequestedFramerate = Engine.requestedFramerate;
         var _loc2_:* = Starling;
         skipUnchangedFrames = starling.core.Starling.sCurrent.skipUnchangedFrames;
         super(3);
         Engine.setupLayoutForTask(_queue,"MenuLayout_Gudetama",function(param1:Object):void
         {
            displaySprite = param1.object as Sprite;
            displaySprite.visible = false;
            spAdBG = displaySprite.getChildByName("spAdBG") as Sprite;
            quadAd = spAdBG.getChildByName("quad") as Quad;
            imgAdDot = spAdBG.getChildByName("imgDot") as Image;
            imgPR = spAdBG.getChildByName("imgPR") as Image;
            imgNoAd = spAdBG.getChildByName("imgNoAd") as Image;
            var _loc2_:String = RsrcManager.getRsrcLocale(Engine.getLocale());
            if(_loc2_ == "ko")
            {
               _loc2_ = "ja";
            }
            imgPR.texture = Engine.assetManager.getTexture("webview0@pr_" + _loc2_);
            bannerButton = spAdBG.getChildByName("banner") as ImageButton;
            bannerIds = GameSetting.def.bannerTable;
            bannarManager = new BannerManager(bannerButton,bannerIds,_queue);
            addChild(displaySprite);
            scenePermanent = true;
         },1);
         Engine.setupLayoutForTask(_queue,"_CounterAmount",function(param1:Object):void
         {
            amountExtractor = SpriteExtractor.forGross(param1.object,param1);
         },1);
      }
      
      public static function createAndSetup(param1:TaskQueue) : void
      {
         if(instance)
         {
            return;
         }
         instance = new ResidentMenuUI_Gudetama(param1);
      }
      
      public static function getInstance() : ResidentMenuUI_Gudetama
      {
         return instance;
      }
      
      public static function clearInstance() : void
      {
         if(instance == null)
         {
            return;
         }
         instance.dispose();
         instance = null;
      }
      
      public static function show(param1:int) : void
      {
         if(instance == null)
         {
            return;
         }
         instance.updateVisibles(param1);
         Engine.pushScene(instance);
      }
      
      public static function setVisibleState(param1:int) : void
      {
         if(instance == null)
         {
            return;
         }
         instance.updateVisibles(param1);
      }
      
      public static function setBackButtonCallback(param1:Function) : void
      {
         if(instance == null)
         {
            return;
         }
         instance.setBackButtonCallback(param1);
      }
      
      public static function setRoomButtonCallback(param1:Function) : void
      {
         if(instance == null)
         {
            return;
         }
         instance.setRoomButtonCallback(param1);
      }
      
      public static function isHomeState() : Boolean
      {
         if(instance == null)
         {
            return false;
         }
         return instance.isHomeState();
      }
      
      public static function setSceneFrameRate(param1:Number) : void
      {
         instance.currentRequestedFramerate = param1;
      }
      
      public static function setSkipUnchangedFrames(param1:Boolean) : void
      {
         instance.skipUnchangedFrames = param1;
      }
      
      public static function canShowFuddaBanner() : Boolean
      {
         if(instance == null)
         {
            return false;
         }
         return instance._canShowFuddaBanner();
      }
      
      public static function visibleFuddaBanner(param1:Boolean) : void
      {
         if(instance == null)
         {
            return;
         }
         instance._visibleFuddaBanner(param1);
      }
      
      public static function startFuddaBanner() : void
      {
         if(instance == null)
         {
            return;
         }
         instance._startFuddaBanner();
      }
      
      public static function initUpperPart() : void
      {
         if(instance == null)
         {
            return;
         }
         instance.initUpperPart();
      }
      
      public static function updateCounter() : void
      {
         if(instance == null)
         {
            return;
         }
         if(!UserDataWrapper.isInitialized())
         {
            return;
         }
         instance._updateCounter();
      }
      
      public static function updateSale() : void
      {
         if(instance == null)
         {
            return;
         }
         if(!UserDataWrapper.isInitialized())
         {
            return;
         }
         instance._updateSale();
      }
      
      public static function addFreeMetal(param1:int, param2:String = "start") : void
      {
         if(instance == null)
         {
            return;
         }
         UserDataWrapper.wrapper.addFreeMetal(param1);
         instance._updateMetal(param2);
      }
      
      public static function addChargeMetal(param1:int, param2:String = "start") : void
      {
         if(instance == null)
         {
            return;
         }
         UserDataWrapper.wrapper.addChargeMetal(param1);
         instance._updateMetal(param2);
      }
      
      public static function consumeMetal(param1:int, param2:String = "start") : void
      {
         if(instance == null)
         {
            return;
         }
         UserDataWrapper.wrapper.consumeMetal(param1);
         instance._updateMetal(param2);
      }
      
      public static function consumeChargeMetal(param1:int, param2:String = "start") : void
      {
         if(instance == null)
         {
            return;
         }
         UserDataWrapper.wrapper.consumeChargeMetal(param1);
         instance._updateMetal(param2);
      }
      
      public static function setFreeMoney(param1:int, param2:String = "start") : void
      {
         if(instance == null)
         {
            return;
         }
         UserDataWrapper.wrapper.setFreeMoney(param1);
         instance._updateMoney(param2);
      }
      
      public static function addFreeMoney(param1:int, param2:String = "start") : void
      {
         if(instance == null)
         {
            return;
         }
         UserDataWrapper.wrapper.addFreeMoney(param1);
         instance._updateMoney(param2);
      }
      
      public static function addChargeMoney(param1:int, param2:String = "start") : void
      {
         if(instance == null)
         {
            return;
         }
         UserDataWrapper.wrapper.addChargeMoney(param1);
         instance._updateMoney(param2);
      }
      
      public static function consumeMoney(param1:int, param2:String = "start") : void
      {
         if(instance == null)
         {
            return;
         }
         UserDataWrapper.wrapper.consumeMoney(param1);
         instance._updateMoney(param2);
      }
      
      public static function consumeFreeMoney(param1:int, param2:String = "start") : void
      {
         if(instance == null)
         {
            return;
         }
         UserDataWrapper.wrapper.consumeFreeMoney(param1);
         instance._updateMoney(param2);
      }
      
      public static function consumeChargeMoney(param1:int, param2:String = "start") : void
      {
         if(instance == null)
         {
            return;
         }
         UserDataWrapper.wrapper.consumeChargeMoney(param1);
         instance._updateMoney(param2);
      }
      
      public static function setEnabledMetalButton(param1:Boolean) : void
      {
         if(instance == null || instance.upperPart == null)
         {
            return;
         }
         instance.upperPart.setEnabledMetalButton(param1);
      }
      
      public static function setEnabledMoneyButton(param1:Boolean) : void
      {
         if(instance == null || instance.upperPart == null)
         {
            return;
         }
         instance.upperPart.setEnabledMoneyButton(param1);
      }
      
      public static function update() : void
      {
         if(instance == null)
         {
            return;
         }
         instance.update();
         instance._reloadFuddaBanner();
      }
      
      public static function changeBannerBGLayout() : void
      {
         if(instance == null)
         {
            return;
         }
         instance.changeAdBGLayout();
      }
      
      public static function setupExtraResponse() : void
      {
         var _loc1_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.setExtraResponseCallback(handleExtraResponse);
      }
      
      private static function handleExtraResponse(param1:*) : Boolean
      {
         var obj:* = param1;
         if(!UserDataWrapper.isInitialized())
         {
            return false;
         }
         Logger.debug("___handleExtraResponse " + obj);
         if(obj is String)
         {
            handleExtraResponseString(obj);
         }
         else if(obj is SystemMailData)
         {
            UserDataWrapper.wrapper.pushDialogSystemMail(obj);
         }
         else if(obj is NoticeFlagData)
         {
            var _loc2_:* = UserDataWrapper;
            gudetama.data.UserDataWrapper.wrapper._data.noticeFlagData = obj;
         }
         else if(obj is Array)
         {
            var list:Array = obj as Array;
            var responseType:String = list[0];
            if(responseType == "m_mod:")
            {
               UserDataWrapper.missionPart.updateMission(list[1]);
               UserDataWrapper.missionPart.updateDailyMissionKeyList(list[2]);
               UserDataWrapper.missionPart.setNextDailyMissionSupplySecs((list[3] as Array)[0]);
            }
            else if(responseType == "touch_info:")
            {
               UserDataWrapper.wrapper.updateTouchInfo(list[1]);
            }
            else if(responseType == "set_item:")
            {
               var _loc4_:* = UserDataWrapper;
               gudetama.data.UserDataWrapper.wrapper._data.setItemBuyMap = list[1];
            }
            else if(responseType == "ability:")
            {
               UserDataWrapper.abilityPart.updateAbilities(list[1]);
            }
            else if(responseType == "feature:")
            {
               UserDataWrapper.featurePart.updateFeatures(list[1]);
            }
            else if(responseType == "kitchenware:")
            {
               UserDataWrapper.kitchenwarePart.addKitchenwares(list[1]);
            }
            else if(responseType == "recipe_note:")
            {
               UserDataWrapper.recipeNotePart.addRecipeNotes(list[1]);
            }
            else if(responseType == "gudetama:")
            {
               UserDataWrapper.wrapper.addRecipes(list[1]);
            }
            else if(responseType == "avatar:")
            {
               UserDataWrapper.avatarPart.updateAvatars(list[1]);
            }
            else if(responseType == "decoration:")
            {
               UserDataWrapper.decorationPart.updateDecorations(list[1]);
            }
            else if(responseType == "stamp:")
            {
               UserDataWrapper.stampPart.updateStamps(list[1]);
            }
            else if(responseType == "useful:")
            {
               UserDataWrapper.usefulPart.updateUsefuls(list[1]);
            }
            else if(responseType == "utensil:")
            {
               UserDataWrapper.utensilPart.updateUtensils(list[1]);
            }
            else if(responseType == "linkage:")
            {
               UserDataWrapper.linkagePart.update(list[1]);
            }
            else if(responseType == "slb:")
            {
               UserDataWrapper.wrapper.setBitFlag(1,true);
               ItemGetDialog.show(list[1],null,GameSetting.getUIText("sns.link.bonus.desc"),GameSetting.getUIText("sns.link.bonus.title"));
            }
            else if(responseType == "event:")
            {
               UserDataWrapper.eventPart.update(list[1]);
            }
            else if(responseType == "id_present:")
            {
               UserDataWrapper.wrapper.updateNumAcquiredIdentifiedPresent(list[1]);
            }
            else if(responseType == "rpadd:")
            {
               var rDef:RankingDef = GameSetting.getRanking(list[1]);
               if(rDef == null)
               {
                  return true;
               }
               showAddRankingPoint(rDef.title,list[2],null);
            }
            else if(responseType == "rpreward:")
            {
               rDef = GameSetting.getRanking(list[1]);
               if(rDef == null)
               {
                  return true;
               }
               var content:RankingContentDef = rDef.content[list[4]];
               if(content == null)
               {
                  return true;
               }
               var rewardDef:RankingRewardDef = GameSetting.def.rankingRewardMap[content.rewardId];
               showAddRankingPoint(rDef.title,list[2],function():void
               {
                  if(rewardDef == null || rewardDef.pointRewards == null)
                  {
                     showRankingGlobalPointRewards(rDef.id#2);
                     return;
                  }
                  showGetRankingPointReward(rDef,rewardDef,list[3],function():void
                  {
                     showRankingGlobalPointRewards(rDef.id#2);
                  });
               });
            }
            else if(responseType == "rgpreward:")
            {
               UserDataWrapper.wrapper.pushRankingGlobalPointRewardParam(list[1],list[3],list[2]);
            }
            else if(responseType == "cgacha:")
            {
               UserDataWrapper.wrapper.addCupGachaConditionClearIds(list[1]);
            }
         }
         return true;
      }
      
      private static function showAddRankingPoint(param1:String, param2:int, param3:Function) : void
      {
         var rankingName:String = param1;
         var addPts:int = param2;
         var callback:Function = param3;
         var pointUnit:String = UserDataWrapper.eventPart.getRankingPointText();
         var title:String = GameSetting.getUIText("ranking.get.pts.title").replace("%1",pointUnit);
         var msg:String = UserDataWrapper.eventPart.getRankingPointGetText().replace("%1",rankingName).replace("%2",pointUnit).replace("%3",StringUtil.getNumStringCommas(addPts));
         LocalMessageDialog.show(0,msg,function():void
         {
            if(callback != null)
            {
               callback();
            }
         },title);
      }
      
      private static function showGetRankingPointReward(param1:RankingDef, param2:RankingRewardDef, param3:Array, param4:Function) : void
      {
         var rDef:RankingDef = param1;
         var rewardDef:RankingRewardDef = param2;
         var points:Array = param3;
         var callback:Function = param4;
         if(points.length == 0)
         {
            return;
         }
         var pointUnit:String = UserDataWrapper.eventPart.getRankingPointText();
         var title:String = GameSetting.getUIText("ranking.tab.pts.reward").replace("%1",pointUnit);
         var items:Array = [];
         var msgs:Array = [];
         while(points.length > 0)
         {
            var point:int = points.shift();
            var i:int = 0;
            while(i < rewardDef.pointRewards.length)
            {
               var itemDef:RankingRewardItemDef = rewardDef.pointRewards[i];
               if(itemDef.argi == point)
               {
                  items.push(itemDef.screeningItems[0]);
                  msgs.push(UserDataWrapper.eventPart.getRankingPointRewardText().replace("%1",rDef.title).replace("%2",pointUnit).replace("%3",StringUtil.getNumStringCommas(point)));
                  break;
               }
               i++;
            }
         }
         RankingRewardGetDialog.show(rDef.id#2,items,function():void
         {
            if(callback)
            {
               callback();
            }
         },msgs,[title]);
      }
      
      public static function showRankingGlobalPointRewards(param1:int, param2:Function = null) : void
      {
         AcquiredRankingTotalPointRewardDialog.show(param1,param2);
      }
      
      private static function handleExtraResponseString(param1:String) : void
      {
         var obj:String = param1;
         if(obj.indexOf("reload_setting:") == 0)
         {
            var newVersion:int = obj.slice("reload_setting:".length);
            Engine.lockTouchInput(obj);
            GameSetting.setupForVersion(newVersion,function():void
            {
               Engine.unlockTouchInput(obj);
            });
         }
         if(obj.indexOf("prs:") == 0)
         {
            var nums:Array = obj.slice("prs:".length).split(",");
            UserDataWrapper.wrapper.setNumUnreadInfoAndPresents(int(nums[0]));
            UserDataWrapper.wrapper.setNumFriendPresents(int(nums[1]));
         }
         else if(obj.indexOf("num_followers:") == 0)
         {
            nums = obj.slice("num_followers:".length).split(",");
            UserDataWrapper.friendPart.setNumFollowers(nums[0]);
            UserDataWrapper.friendPart.setNumFriends(nums[1]);
         }
         else if(obj.indexOf("num_follows:") == 0)
         {
            nums = obj.slice("num_follows:".length).split(",");
            UserDataWrapper.friendPart.setNumFollows(nums[0]);
            UserDataWrapper.friendPart.setNumFriends(nums[1]);
         }
         else if(obj.indexOf("interstitialads:") == 0)
         {
            DataStorage.getLocalData().setInterstitialAdsRate(obj.slice("interstitialads:".length));
         }
         else if(obj.indexOf("bannerads:") == 0)
         {
            DataStorage.getLocalData().setBannerAdsRate(obj.slice("bannerads:".length));
            BannerAdvertisingManager.showBannerAds();
         }
         else if(obj.indexOf("videoads:") == 0)
         {
            DataStorage.getLocalData().setVideoAdsRate(obj.slice("videoads:".length));
         }
         else if(obj.indexOf("priorityvideoads:") == 0)
         {
            DataStorage.getLocalData().setPriorityvideoAdsCompanyList(obj.slice("priorityvideoads:".length));
         }
         else if(obj.indexOf("video_ad_reward:") == 0)
         {
            nums = obj.slice("video_ad_reward:".length).split(",");
            UserDataWrapper.videoAdPart.updateNumAcquiredReward(nums[0]);
            UserDataWrapper.videoAdPart.updateRestTimeSecs(nums[1]);
         }
         else if(obj.indexOf("touch:") == 0)
         {
            var money:int = obj.slice("touch:".length);
            if(money)
            {
               ResidentMenuUI_Gudetama.addFreeMoney(money);
            }
         }
         else if(obj.indexOf("touch_u:") == 0)
         {
            money = obj.slice("touch_u:".length);
            ResidentMenuUI_Gudetama.setFreeMoney(money);
         }
         else if(obj.indexOf("new_friend:") == 0)
         {
            UserDataWrapper.friendPart.setNumNewFriend(int(obj.slice("new_friend:".length)));
         }
         else if(obj.indexOf("present_money:") == 0)
         {
            UserDataWrapper.wrapper.setNumPresentMoneyFromFriend(int(obj.slice("present_money:".length)));
         }
         else if(obj.indexOf("assist:") == 0)
         {
            UserDataWrapper.wrapper.setNumAssistFromFriend(int(obj.slice("assist:".length)));
         }
         else if(obj.indexOf("hidegude:") == 0)
         {
            UserDataWrapper.wrapper.hideGudeId = int(obj.slice("hidegude:".length));
         }
         else if(obj.indexOf("offerwall:") == 0)
         {
            UserDataWrapper.wrapper.updateDisabledOfferwallFlag(int(obj.slice("offerwall:".length)) == 1);
         }
         else if(obj.indexOf("monthly:") == 0)
         {
            UserDataWrapper.wrapper.setFinishMonthlyBonusTimeSec(int(obj.slice("monthly:".length)));
         }
         else if(obj.indexOf("menu:") == 0)
         {
            UserDataWrapper.wrapper.updateMenuItems(obj.slice("menu:".length).split(","));
         }
         else if(obj.indexOf("touch_count:") == 0)
         {
            UserDataWrapper.wrapper.sendTouchCount = int(obj.slice("touch_count:".length));
         }
         else if(obj.indexOf("n_pre:") == 0)
         {
            UserDataWrapper.wrapper.setNoticeMonthlyBonusTimeSec(int(obj.slice("n_pre:".length)));
         }
         else if(obj.indexOf("helper:") == 0)
         {
            var canUseHelper:Boolean = obj.slice("helper:".length) == "true";
            UserDataWrapper.wrapper.setHelperState(canUseHelper);
         }
      }
      
      private static function checkAndroidInventory(param1:Function) : void
      {
         var _callback:Function = param1;
         NativeExtensions.getInventory(function(param1:Array, param2:Array = null):void
         {
            var list:Array = param1;
            var _signatureList:Array = param2;
            NativeExtensions.resetInventory();
            if(list != null && list.length > 0)
            {
               var len:int = list.length;
               if(len < 0)
               {
                  _callback();
                  return;
               }
               var sendinventory:String = "";
               var signatures:String = "";
               var i:int = 0;
               while(i < len)
               {
                  sendinventory = sendinventory + list[i] + ";";
                  if(_signatureList != null)
                  {
                     signatures = signatures + _signatureList[i] + ";";
                  }
                  i++;
               }
               var sendData:Array = [];
               sendData[0] = sendinventory;
               sendData[1] = signatures;
               var _loc4_:* = HttpConnector;
               if(gudetama.net.HttpConnector.mainConnector == null)
               {
                  gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
               }
               gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithObject(GENERAL_PURCHASE_CHECK,sendData),function(param1:Array):void
               {
                  var response:Array = param1;
                  if(response != null)
                  {
                     var itemIDs:Array = response[0] as Array;
                     var addMetal:int = (response[1] as Array)[0];
                     var bonusMetal:int = (response[1] as Array)[1];
                     var addMoney:int = (response[1] as Array)[2];
                     var bonusMoney:int = (response[1] as Array)[3];
                     var getItemResults:Array = response[2];
                     var _loc3_:* = UserDataWrapper;
                     gudetama.data.UserDataWrapper.wrapper._data.setItemBuyMap = response[3];
                     UserDataWrapper.wrapper.increaseNumPurchase(response[4]);
                     var itemlen:int = itemIDs.length;
                     var l:int = 0;
                     while(l < itemlen)
                     {
                        NativeExtensions.consume(itemIDs[l]);
                        l++;
                     }
                     var i:int = 0;
                     while(i < len)
                     {
                        DataStorage.getLocalData().removeReceipt(UserDataWrapper.wrapper.getUid(),list[i]);
                        DataStorage.saveLocalData();
                        i++;
                     }
                     if(addMetal > 0)
                     {
                        UserDataWrapper.wrapper.addChargeMetal(addMetal);
                     }
                     if(bonusMetal > 0)
                     {
                        UserDataWrapper.wrapper.addFreeMetal(bonusMetal);
                     }
                     if(addMetal + bonusMetal > 0)
                     {
                        ResidentMenuUI_Gudetama.getInstance()._updateMetal();
                     }
                     if(addMoney > 0)
                     {
                        UserDataWrapper.wrapper.addChargeMoney(addMoney);
                     }
                     if(bonusMoney > 0)
                     {
                        UserDataWrapper.wrapper.addFreeMoney(bonusMoney);
                     }
                     if(addMoney + bonusMoney > 0)
                     {
                        ResidentMenuUI_Gudetama.getInstance()._updateMoney();
                     }
                     Engine.unlockTouchInput(ResidentMenuUI_Gudetama);
                     MessageDialog.show(0,GameSetting.getUIText("receipt.pending"),function(param1:int):void
                     {
                        Engine.showGetPurchaseItem(getItemResults,_callback);
                     });
                  }
                  else
                  {
                     _callback();
                  }
               });
            }
            else
            {
               _callback();
            }
         });
      }
      
      private static function checkiOSReceipt(param1:Function) : void
      {
         var callback:Function = param1;
         Engine.sendReceiptForiOS(false,function(param1:int):void
         {
            callback();
         });
      }
      
      private static function checkOneStoreReceipt(param1:Function) : void
      {
         var callback:Function = param1;
         Engine.sendReceiptAndSetupCallbackOneStore(false,function():void
         {
            callback();
         });
      }
      
      override public function isSkipUnchangedFrames() : Boolean
      {
         return skipUnchangedFrames;
      }
      
      override public function getSceneFrameRate() : Number
      {
         return currentRequestedFramerate;
      }
      
      public function completeAdUI() : void
      {
         if(setupAd)
         {
            return;
         }
         setupAd = true;
         changeAdBGLayout();
      }
      
      public function changeAdBGLayout() : void
      {
         if(Engine.isJapanIp() || bannarManager.hasShowingBanner())
         {
            imgNoAd.visible = false;
            quadAd.visible = true;
            imgPR.visible = true;
            imgAdDot.visible = true;
         }
         else
         {
            quadAd.visible = false;
            imgPR.visible = false;
            imgAdDot.visible = false;
            imgNoAd.visible = true;
         }
      }
      
      public function loadMenuUI(param1:TaskQueue) : void
      {
         var _queue:TaskQueue = param1;
         if(setupMenu)
         {
            return;
         }
         Engine.setupLayoutForTask(_queue,"_UpperMenu_Gudetama",function(param1:Object):void
         {
            spUpper = param1.object as Sprite;
            spUpper.pivotX = 320;
            spUpper.x = 320;
            spUpper.visible = false;
         },1);
         Engine.setupLayoutForTask(_queue,"_LowerMenu_Gudetama",function(param1:Object):void
         {
            spLower = param1.object as Sprite;
            spLower.y = 1000;
            spLower.visible = false;
         },1);
      }
      
      public function completeMenuUI() : void
      {
         if(setupMenu)
         {
            return;
         }
         setupMenu = true;
         upperPart = new UpperPart(spUpper);
         upperPart.setExtractor(amountExtractor);
         lowerPart = new LowerPart(spLower);
         spUpper.visible = true;
         displaySprite.addChild(spUpper);
         spLower.visible = true;
         displaySprite.addChild(spLower);
         updateUserInfo();
         initUpperPart();
      }
      
      override protected function setupProgressForPermanent(param1:Function) : void
      {
         displaySprite.visible = true;
         param1(1);
      }
      
      public function setBackButtonCallback(param1:Function) : void
      {
         if(!lowerPart)
         {
            return;
         }
         lowerPart.setBackButtonCallback(param1);
      }
      
      public function setRoomButtonCallback(param1:Function) : void
      {
         if(!lowerPart)
         {
            return;
         }
         lowerPart.setRoomButtonCallback(param1);
      }
      
      public function _reloadFuddaBanner() : void
      {
         bannerIds = GameSetting.def.bannerTable;
         bannarManager.dispose();
         bannarManager = null;
         bannarManager = new BannerManager(bannerButton,bannerIds);
         _startFuddaBanner();
      }
      
      public function _canShowFuddaBanner() : Boolean
      {
         if(!bannarManager)
         {
            return false;
         }
         return bannarManager.hasShowingBanner();
      }
      
      public function _visibleFuddaBanner(param1:Boolean) : void
      {
         if(bannarManager)
         {
            bannarManager.visible = param1;
         }
      }
      
      public function _startFuddaBanner() : void
      {
         if(bannarManager)
         {
            bannarManager.start();
         }
      }
      
      public function initUpperPart() : void
      {
         if(upperPart == null)
         {
            return;
         }
         upperPart.init();
      }
      
      public function updateUserInfo() : void
      {
         if(upperPart == null)
         {
            return;
         }
         upperPart.updateUserInfo();
      }
      
      public function _updateCounter() : void
      {
         if(upperPart == null)
         {
            return;
         }
         upperPart.updateCounter();
      }
      
      public function _updateSale() : void
      {
         upperPart.updateSale();
      }
      
      public function update() : void
      {
         if(upperPart == null)
         {
            return;
         }
         upperPart.update();
      }
      
      public function _updateMetal(param1:String = "start") : void
      {
         if(upperPart == null)
         {
            return;
         }
         upperPart.updateMetal(UserDataWrapper.wrapper.getMetal(),param1);
      }
      
      public function _addMoney(param1:int, param2:String = "start") : void
      {
         if(upperPart == null)
         {
            return;
         }
         upperPart.addMoney(param1,param2);
      }
      
      public function _addMoneyActual(param1:int) : void
      {
         if(upperPart == null)
         {
            return;
         }
         upperPart.addMoneyActual(param1);
      }
      
      public function _updateMoney(param1:String = "start") : void
      {
         if(upperPart == null)
         {
            return;
         }
         upperPart.updateMoney(UserDataWrapper.wrapper.getMoney(),param1);
      }
      
      public function _setTouchableMetalButton(param1:Boolean) : void
      {
         if(upperPart == null)
         {
            return;
         }
         upperPart.setTouchableMetalButton(param1);
      }
      
      public function updateVisibles(param1:int) : void
      {
         if(isHomeState())
         {
            param1 &= ~16;
         }
         var _loc2_:Boolean = param1 & 4;
         spAdBG.visible = _loc2_;
         if(!setupMenu)
         {
            return;
         }
         upperPart.updateVisibles(param1);
         lowerPart.updateVisibles(param1);
         upperPart.setVisible(param1 & 2);
         lowerPart.setVisible(_loc2_);
         if((param1 & 32) != 0)
         {
            upperPart.abilityTimeUI.setVisible(true);
            lowerPart.abilityTimeUI.setVisible(false);
         }
         else if((param1 & 64) != 0)
         {
            upperPart.abilityTimeUI.setVisible(false);
            lowerPart.abilityTimeUI.setVisible(true);
         }
         else
         {
            upperPart.abilityTimeUI.setVisible(false);
            lowerPart.abilityTimeUI.setVisible(false);
         }
      }
      
      override public function advanceTime(param1:Number) : void
      {
         super.advanceTime(param1);
         if(!setupMenu)
         {
            return;
         }
         upperPart.advanceTime(param1);
         lowerPart.advanceTime(param1);
      }
      
      public function sendChangeState(param1:int, param2:Function, param3:Boolean = true, param4:Boolean = false) : void
      {
         var id:int = param1;
         var callback:Function = param2;
         var _loadingMode:Boolean = param3;
         var beforeExtraResponse:Boolean = param4;
         if(id == -1 || id == 0)
         {
            currentState = id;
            callback();
            return;
         }
         Engine.showLoading(sendChangeState,_loadingMode);
         var _loc5_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(id),function(param1:Array):void
         {
            Engine.hideLoading(sendChangeState);
            currentState = id;
            callback();
         },false,beforeExtraResponse);
      }
      
      public function goHomeScene() : void
      {
         sendChangeState(60,function():void
         {
            Engine.switchScene(new HomeScene());
         });
      }
      
      public function isHomeState() : Boolean
      {
         return currentState == 60;
      }
      
      public function getCurrentSate() : int
      {
         return currentState;
      }
      
      public function checkClearedMission(param1:Function = null) : void
      {
         var callback:Function = param1;
         Engine.showLoading(checkClearedMission);
         var _loc2_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(GENERAL_CHECK_CLEARED_MISSION),function(param1:Array):void
         {
            Engine.hideLoading(checkClearedMission);
            if(param1.length > 0)
            {
               MissionRewardDialog.show(param1,callback);
               UserDataWrapper.wrapper.addNumUnreadInfoAndPresents(param1.length);
               Engine.broadcastEventToSceneStackWith("update_scene");
            }
            else if(callback)
            {
               callback();
            }
         });
      }
      
      public function showMetalShop(param1:Function = null) : void
      {
         var callback:Function = param1;
         var func:Function = function(param1:int):void
         {
            upperPart.updateUserInfo();
            if(callback)
            {
               callback();
            }
         };
         var isOneStore:Boolean = false;
         if(isOneStore)
         {
            checkOneStoreReceipt(function():void
            {
               MetalShopDialog_Gudetama.show(2,func);
            });
         }
         else
         {
            var _loc3_:* = Engine;
            if(gudetama.engine.Engine.platform == 1)
            {
               checkAndroidInventory(function():void
               {
                  MetalShopDialog_Gudetama.show(2,func);
               });
            }
            else
            {
               checkiOSReceipt(function():void
               {
                  MetalShopDialog_Gudetama.show(2,func);
               });
            }
         }
      }
      
      public function showMoneyShop(param1:Function = null) : void
      {
         var callback:Function = param1;
         var func:Function = function(param1:int):void
         {
            upperPart.updateUserInfo();
            if(callback)
            {
               callback();
            }
         };
         var isOneStore:Boolean = false;
         if(isOneStore)
         {
            checkOneStoreReceipt(function():void
            {
               MoneyShopDialog.show(1,func);
            });
         }
         else
         {
            var _loc3_:* = Engine;
            if(gudetama.engine.Engine.platform == 1)
            {
               checkAndroidInventory(function():void
               {
                  MoneyShopDialog.show(1,func);
               });
            }
            else
            {
               checkiOSReceipt(function():void
               {
                  MoneyShopDialog.show(1,func);
               });
            }
         }
      }
      
      public function checkReceipt(param1:Function = null) : void
      {
         var callback:Function = param1;
         var _loc2_:* = Engine;
         if(gudetama.engine.Engine.platform == 1)
         {
            checkAndroidInventory(function():void
            {
               if(callback)
               {
                  callback();
               }
            });
         }
         else
         {
            checkiOSReceipt(function():void
            {
               if(callback)
               {
                  callback();
               }
            });
         }
      }
   }
}

import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.engine.TweenAnimator;
import gudetama.ui.ResidentMenuUI_Gudetama;
import gudetama.ui.UIBase;
import gudetama.util.SpriteExtractor;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;

class UpperPart extends UIBase
{
    
   
   private var levelText:ColorTextField;
   
   private var metalCounter:CounterUI;
   
   private var metalButton:ContainerButton;
   
   private var plusImage:Image;
   
   private var moneyCounter:CounterUI;
   
   private var moneyButton:ContainerButton;
   
   private var moneyPlusImage:Image;
   
   public var abilityTimeUI:AbilityTimeUI;
   
   private var debugMoneyUI:DebugMoneyUI;
   
   private var saleImage:Image;
   
   function UpperPart(param1:Sprite)
   {
      super(param1);
      var _loc2_:Sprite = param1.getChildByName("level") as Sprite;
      levelText = _loc2_.getChildByName("text") as ColorTextField;
      metalCounter = new CounterUI(param1.getChildByName("metal") as ContainerButton,999999999);
      metalButton = metalCounter.getDisplaySprite() as ContainerButton;
      metalButton.addEventListener("triggered",triggeredMetalButton);
      plusImage = metalButton.getChildByName("plus") as Image;
      saleImage = metalButton.getChildByName("sale") as Image;
      updateSale();
      moneyCounter = new CounterUI(param1.getChildByName("money") as ContainerButton,999999999);
      moneyButton = moneyCounter.getDisplaySprite() as ContainerButton;
      moneyButton.addEventListener("triggered",triggeredMoneyButton);
      moneyPlusImage = moneyButton.getChildByName("plus") as Image;
      abilityTimeUI = new AbilityTimeUI(param1.getChildByName("ability") as Sprite);
   }
   
   public function setExtractor(param1:SpriteExtractor) : void
   {
      metalCounter.setExtractor(param1);
      moneyCounter.setExtractor(param1);
   }
   
   public function init() : void
   {
      metalCounter.init(UserDataWrapper.wrapper.getMetal());
      moneyCounter.init(UserDataWrapper.wrapper.getMoney());
      update();
   }
   
   public function update() : void
   {
      if(GameSetting.getRule().enabledMoneyShop)
      {
         TweenAnimator.startItself(moneyButton,"pos1");
         moneyButton.touchable = true;
      }
      else
      {
         TweenAnimator.startItself(moneyButton,"pos0");
         moneyButton.touchable = false;
      }
   }
   
   public function updateUserInfo() : void
   {
      levelText.text#2 = String(UserDataWrapper.wrapper.getRank());
      updateSale();
   }
   
   public function updateCounter() : void
   {
      metalCounter.init(UserDataWrapper.wrapper.getMetal());
      moneyCounter.init(UserDataWrapper.wrapper.getMoney());
      updateSale();
   }
   
   public function updateSale() : void
   {
      if(saleImage)
      {
         saleImage.visible = GameSetting.hasMetalShopCampaignSetting(2);
         if(saleImage.visible)
         {
            TweenAnimator.startItself(saleImage);
         }
      }
   }
   
   public function updateMetal(param1:int, param2:String) : void
   {
      metalCounter.update(param1,param2);
   }
   
   public function addMoney(param1:int, param2:String) : void
   {
      moneyCounter.apply(param1,param2);
   }
   
   public function addMoneyActual(param1:int) : void
   {
      moneyCounter.addActual(param1);
   }
   
   public function updateMoney(param1:int, param2:String) : void
   {
      moneyCounter.update(param1,param2);
   }
   
   public function setEnabledMetalButton(param1:Boolean) : void
   {
      metalButton.touchable = param1;
      plusImage.color = !!param1 ? 16777215 : 8421504;
   }
   
   public function setEnabledMoneyButton(param1:Boolean) : void
   {
      moneyButton.touchable = param1 && GameSetting.getRule().enabledMoneyShop;
      moneyPlusImage.color = !!param1 ? 16777215 : 8421504;
   }
   
   public function triggeredMetalButton(param1:Event) : void
   {
      ResidentMenuUI_Gudetama.getInstance().showMetalShop();
   }
   
   public function triggeredMoneyButton(param1:Event) : void
   {
      ResidentMenuUI_Gudetama.getInstance().showMoneyShop();
   }
   
   public function setTouchableMetalButton(param1:Boolean) : void
   {
      metalCounter.setTouchable(param1);
      moneyCounter.setTouchable(param1);
   }
   
   public function updateVisibles(param1:int) : void
   {
   }
   
   public function advanceTime(param1:Number) : void
   {
      metalCounter.advanceTime(param1);
      moneyCounter.advanceTime(param1);
      abilityTimeUI.advanceTime(param1);
   }
}

import gudetama.engine.TweenAnimator;
import gudetama.ui.AmountCacheManager;
import gudetama.ui.UIBase;
import gudetama.util.SpriteExtractor;
import gudetama.util.StringUtil;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;

class CounterUI extends UIBase
{
   
   private static const INTERVAL:Number = 0.1;
    
   
   private var max:int;
   
   private var bgGroup:Sprite;
   
   private var iconImage:Image;
   
   private var text:ColorTextField;
   
   private var amountText:ColorTextField;
   
   private var amountCache:AmountCacheManager;
   
   private var before:int;
   
   private var after:int;
   
   private var current:int;
   
   private var amount:int;
   
   private var actual:int;
   
   private var time:Number;
   
   function CounterUI(param1:Sprite, param2:int)
   {
      super(param1);
      this.max = param2;
      bgGroup = param1.getChildByName("bgGroup") as Sprite;
      iconImage = param1.getChildByName("icon") as Image;
      text = param1.getChildByName("text") as ColorTextField;
      amountText = param1.getChildByName("amount") as ColorTextField;
   }
   
   public function setExtractor(param1:SpriteExtractor) : void
   {
      amountCache = new AmountCacheManager(param1,displaySprite.getChildByName("amountGroup") as Sprite);
   }
   
   public function init(param1:int) : void
   {
      text.text#2 = StringUtil.getNumStringCommas(param1);
      before = after = current = actual = param1;
      time = 0;
   }
   
   public function addActual(param1:int) : void
   {
      actual += param1;
   }
   
   public function update(param1:int, param2:String = "start") : void
   {
      var _loc3_:int = param1 - actual;
      if(_loc3_ != 0)
      {
         apply(_loc3_,param2);
      }
      actual = param1;
   }
   
   public function apply(param1:int, param2:String = "start") : void
   {
      this.amount = param1;
      before = current = after;
      after = Math.min(max,after + param1);
      time = 0;
      amountCache.show(param1,param2);
      if(!TweenAnimator.isRunning(bgGroup))
      {
         TweenAnimator.startItself(bgGroup,"start",true);
         TweenAnimator.startItself(iconImage,"start",true);
      }
   }
   
   public function advanceTime(param1:Number) : void
   {
      var _loc3_:int = 0;
      var _loc4_:* = false;
      var _loc2_:int = 0;
      if(current != after)
      {
         time += param1;
         _loc3_ = current;
         if(!(_loc4_ = amount < 0))
         {
            current = before + Math.min(amount,amount * time / 0.1);
         }
         else
         {
            _loc2_ = Math.abs(amount);
            current = before - Math.min(_loc2_,_loc2_ * time / 0.1);
         }
         if(_loc3_ != current)
         {
            text.text#2 = StringUtil.getNumStringCommas(current);
         }
      }
   }
}

import gudetama_dev.DebugMoneyInputDialog;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Touch;
import starling.events.TouchEvent;

class DebugMoneyUI
{
    
   
   private var quad:Quad;
   
   function DebugMoneyUI(param1:Sprite)
   {
      super();
      quad = new Quad(46,54);
      quad.x = 370;
      quad.y = 10;
      quad.alpha = 0;
      quad.addEventListener("touch",touchQuad);
      param1.addChild(quad);
   }
   
   private function touchQuad(param1:TouchEvent) : void
   {
      var _loc2_:Touch = param1.getTouch(quad);
      if(_loc2_ == null)
      {
         return;
      }
      if(_loc2_.phase == "ended")
      {
         DebugMoneyInputDialog.show();
      }
   }
}

import gudetama.engine.Engine;
import gudetama.scene.home.HomeScene;
import gudetama.ui.ResidentMenuUI_Gudetama;
import gudetama.ui.UIBase;
import muku.display.SimpleImageButton;
import starling.display.Sprite;
import starling.events.Event;

class LowerPart extends UIBase
{
    
   
   private var backButton:SimpleImageButton;
   
   private var roomButton:SimpleImageButton;
   
   public var abilityTimeUI:AbilityTimeUI;
   
   private var backButtonCallback:Function;
   
   private var roomButtonCallback:Function;
   
   function LowerPart(param1:Sprite)
   {
      super(param1);
      backButton = param1.getChildByName("backButton") as SimpleImageButton;
      backButton.addEventListener("triggered",triggeredBackButton);
      roomButton = param1.getChildByName("roomButton") as SimpleImageButton;
      roomButton.addEventListener("triggered",triggeredRoomButton);
      abilityTimeUI = new AbilityTimeUI(param1.getChildByName("ability") as Sprite);
   }
   
   public function setBackButtonCallback(param1:Function) : void
   {
      backButtonCallback = param1;
   }
   
   public function setRoomButtonCallback(param1:Function) : void
   {
      roomButtonCallback = param1;
   }
   
   private function triggeredBackButton(param1:Event) : void
   {
      if(backButtonCallback)
      {
         backButtonCallback();
      }
   }
   
   private function triggeredRoomButton(param1:Event) : void
   {
      var event:Event = param1;
      if(roomButtonCallback)
      {
         roomButtonCallback();
         return;
      }
      ResidentMenuUI_Gudetama.getInstance().sendChangeState(60,function():void
      {
         Engine.switchScene(new HomeScene());
      });
   }
   
   public function updateVisibles(param1:int) : void
   {
      backButton.visible = param1 & 8;
      roomButton.visible = param1 & 16;
   }
   
   public function advanceTime(param1:Number) : void
   {
      abilityTimeUI.advanceTime(param1);
   }
}

import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.UserAbilityData;
import gudetama.engine.Engine;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;

class AbilityTimeUI extends UIBase
{
   
   private static const SWITCH_INTERVAL:int = 5000;
   
   private static const UPDATE_INTERVAL:int = 1000;
    
   
   private var timeText:ColorTextField;
   
   private var backgroundMap:Object;
   
   private var nextSwitchTime:int;
   
   private var nextUpdateTime:int;
   
   private var userAbilityData:UserAbilityData;
   
   private var nextIndex:int;
   
   public var visible:Boolean;
   
   private var exists:Boolean;
   
   function AbilityTimeUI(param1:Sprite)
   {
      backgroundMap = {};
      super(param1);
      backgroundMap[256] = param1.getChildByName("bg_heaven") as Image;
      backgroundMap[257] = param1.getChildByName("bg_bomb") as Image;
      backgroundMap[261] = param1.getChildByName("bg_extract") as Image;
      backgroundMap[6] = param1.getChildByName("bg_perfume") as Image;
      backgroundMap[1032] = param1.getChildByName("spRanking") as Sprite;
      timeText = param1.getChildByName("time") as ColorTextField;
   }
   
   override public function setVisible(param1:Boolean) : void
   {
      super.setVisible(param1);
      visible = param1;
      nextUpdateTime = 0;
      advanceTime();
   }
   
   public function advanceTime(param1:Number = 0) : void
   {
      var _loc3_:* = null;
      var _loc5_:* = null;
      var _loc6_:int = 0;
      var _loc2_:int = 0;
      var _loc8_:int = 0;
      var _loc9_:int = 0;
      if(!UserDataWrapper.isInitialized())
      {
         super.setVisible(false);
         return;
      }
      if(!visible)
      {
         return;
      }
      var _loc4_:Boolean = UserDataWrapper.abilityPart.existsAbility();
      if(!this.exists && _loc4_)
      {
         nextUpdateTime = 0;
      }
      this.exists = _loc4_;
      if(Engine.now < nextUpdateTime)
      {
         return;
      }
      updateUserAbilityData();
      if(userAbilityData && backgroundMap[userAbilityData.ability.type])
      {
         super.setVisible(true);
         for(var _loc7_ in backgroundMap)
         {
            backgroundMap[_loc7_].visible = _loc7_ == userAbilityData.ability.type;
         }
         if(userAbilityData.ability.type == 1032)
         {
            _loc3_ = backgroundMap[userAbilityData.ability.type];
            (_loc5_ = _loc3_.getChildByName("lblValue") as ColorTextField).text#2 = userAbilityData.ability.values[0] + "%";
         }
         _loc2_ = (_loc6_ = userAbilityData.restTimeSecs - UserDataWrapper.abilityPart.getDt()) / 3600;
         _loc8_ = (_loc6_ - _loc2_ * 60 * 60) / 60;
         _loc9_ = _loc6_ - _loc2_ * 60 * 60 - _loc8_ * 60;
         timeText.text#2 = StringUtil.format(GameSetting.getUIText("residentMenu.time"),(_loc2_ < 10 ? "0" : "") + _loc2_,(_loc8_ < 10 ? "0" : "") + _loc8_,(_loc9_ < 10 ? "0" : "") + _loc9_);
      }
      else
      {
         super.setVisible(false);
      }
      nextUpdateTime = Engine.now + 1000;
   }
   
   private function updateUserAbilityData() : void
   {
      userAbilityData = UserDataWrapper.abilityPart.getAlive(nextIndex);
      if(Engine.now >= nextSwitchTime)
      {
         nextIndex++;
         nextSwitchTime = Engine.now + 5000;
      }
   }
}
