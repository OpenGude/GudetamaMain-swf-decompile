package gudetama.scene.home
{
   import flash.display.BitmapData;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import gudetama.common.BannerAdvertisingManager;
   import gudetama.common.DialogSystemMailChecker;
   import gudetama.common.GudetamaUtil;
   import gudetama.common.HomeDecoUtil;
   import gudetama.common.InterstitialAdvertisingManager;
   import gudetama.common.SimpleVoiceManager;
   import gudetama.common.VoiceManager;
   import gudetama.data.DataStorage;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.ComicDef;
   import gudetama.data.compati.GetItemResult;
   import gudetama.data.compati.GudetamaDef;
   import gudetama.data.compati.HelperCharaDef;
   import gudetama.data.compati.ItemParam;
   import gudetama.data.compati.QuestionInfo;
   import gudetama.data.compati.RankingDef;
   import gudetama.data.compati.SystemMailData;
   import gudetama.data.compati.TouchDef;
   import gudetama.data.compati.TouchEventDef;
   import gudetama.data.compati.TouchEventParam;
   import gudetama.data.compati.TouchInfo;
   import gudetama.data.compati.UtensilDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.Logger;
   import gudetama.engine.SoundManager;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.scene.ar.ARScene;
   import gudetama.scene.ar.SnsShareDialog;
   import gudetama.scene.collection.CollectionScene;
   import gudetama.scene.decoration.DecorationScene;
   import gudetama.scene.home.ui.CarnaviUI;
   import gudetama.scene.home.ui.CupGachaButton;
   import gudetama.scene.home.ui.EventButton;
   import gudetama.scene.home.ui.InfoButtonUI;
   import gudetama.scene.home.ui.ProfileButton;
   import gudetama.scene.home.ui.SerifUI;
   import gudetama.scene.home.ui.TouchTextGroup;
   import gudetama.scene.kitchen.CookingScene;
   import gudetama.scene.mission.MissionScene;
   import gudetama.scene.shop.GachaScene_Gudetama;
   import gudetama.scene.shop.ShopScene_Gudetama;
   import gudetama.scene.world.AssistNoticeDialog;
   import gudetama.ui.AcquiredKitchenwareDialog;
   import gudetama.ui.AcquiredRecipeNoteDialog;
   import gudetama.ui.ComicDialog;
   import gudetama.ui.FeatureNoticeDialog;
   import gudetama.ui.GuideTalkPanel;
   import gudetama.ui.HelperComicDialog;
   import gudetama.ui.HomeScroller;
   import gudetama.ui.InfoListDialog;
   import gudetama.ui.ItemGetDialog;
   import gudetama.ui.LinkageAchievementDialog;
   import gudetama.ui.LocalMessageDialog;
   import gudetama.ui.MenuDialog;
   import gudetama.ui.MessageDialog;
   import gudetama.ui.PresentMoneyAndFriendlyDialog;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.ui.UsefulDetailDialog;
   import gudetama.util.PermissionRequestWrapper;
   import gudetama.util.SpriteExtractor;
   import gudetama.util.StringUtil;
   import gudetama.util.TimeZoneUtil;
   import muku.core.MukuGlobal;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.display.ManuallySpineButton;
   import muku.display.PagedScrollContainer;
   import muku.display.SimpleImageButton;
   import muku.display.SpineModel;
   import muku.text.ColorTextField;
   import muku.util.StarlingUtil;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   import starling.display.Image;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   import starling.rendering.Painter;
   import starling.textures.Texture;
   
   public class HomeScene extends BaseScene
   {
      
      private static const UPDATE_INTERVAL:int = 1000;
      
      private static const TIME_TYPE_MORNING:uint = 0;
      
      private static const TIME_TYPE_NOON:uint = 1;
      
      private static const TIME_TYPE_NIGHT:uint = 2;
      
      public static const SCENE_USEFUL:String = "useful";
      
      public static const SCENE_USEFULDETAIL:String = "useful_detail";
      
      public static const TUTORIAL_GUDETAMA_LIST:Array = [10,17];
       
      
      private var tutorialSpineParams:Array;
      
      private var gudetamaSpineParam:Object;
      
      private var kitchenwareType:int;
      
      private var navigateParam:Object;
      
      private var scrollGroup:Sprite;
      
      private var scrollContainer:PagedScrollContainer;
      
      private var homeScroller:HomeScroller;
      
      private var weatherSpineModel:SpineModel;
      
      private var mountainImage:Image;
      
      private var roomImage:Image;
      
      private var dishImage:Image;
      
      private var gudetamaButton:ManuallySpineButton;
      
      private var dropItemButton:ContainerButton;
      
      private var imgDrop:Image;
      
      private var noticeButtonUIs:Vector.<NoticeButtonUI>;
      
      private var infoButton:InfoButtonUI;
      
      private var infoIcon:InfoIconUI;
      
      private var shopButton:ContainerButton;
      
      private var menuButton:SimpleImageButton;
      
      private var gudetamaGroup:Sprite;
      
      private var helperGroup:Sprite;
      
      private var helperGroupPosX:Number;
      
      private var helperSpineModel:SpineModel;
      
      private var helperMessages:Array;
      
      private var helperMessage:ColorTextField;
      
      private var gachaButton:ContainerButton;
      
      private var gachaFreePlayGroup:Sprite;
      
      private var gachaPickupImage:Image;
      
      private var collectionSprite:Sprite;
      
      private var collectionButton:SimpleImageButton;
      
      private var collectionBookinfoSprite:Sprite;
      
      private var friendButton:FriendButtonUI;
      
      private var cameraButton:SimpleImageButton;
      
      private var kitchenwares:Vector.<KitchenwareButton>;
      
      private var cookingScene:CookingScene;
      
      private var challengeButton:SimpleImageButton;
      
      private var carnaviUI:CarnaviUI;
      
      private var bombEffectImage:BombEffectImage;
      
      private var movieButton:MovieButton;
      
      private var profileButton:ProfileButton;
      
      private var delusionButton:DelusionButton;
      
      private var usefulGroup:Sprite;
      
      private var usefulButton:ContainerButton;
      
      private var heavenUI:HeavenUI;
      
      private var serifUI:SerifUI;
      
      private var touchTextGroup:TouchTextGroup;
      
      private var hideGudetamaGroup:Sprite;
      
      private var eventButton:EventButton;
      
      private var eventNoticeButton:EventNoticeButton;
      
      private var messageUI:MessageUI;
      
      private var gudetamaQuad:Quad;
      
      private var heavenItemExtractor:SpriteExtractor;
      
      private var delusionItemExtractor:SpriteExtractor;
      
      private var touchTextItemExtractor:SpriteExtractor;
      
      private var questionData:QuestionInfo;
      
      private var delusionRestTimes:Array;
      
      private var enabledGachaFreePlay:Boolean;
      
      private var existsPickup:Boolean;
      
      private var loadCount:int;
      
      private var nextUpdateTime:int;
      
      private var lockTouchEvent:Boolean;
      
      private var finishGudetamaQuadTime:uint;
      
      private var firstGudetamaTouchBG:Sprite;
      
      private var bgQuad:Quad;
      
      private var bgMountain:Image;
      
      private var dropItemTouches:Vector.<Touch>;
      
      private var dropItemTouch:Touch;
      
      private var dropItemEvent:TouchEvent;
      
      private var scrollPageIndex:int;
      
      private var visibleGudetamaQuad:Boolean;
      
      private var hideGude:HideGudetama;
      
      private var appearHideGudeCookingBack:Boolean = false;
      
      private var btnCupGacha:CupGachaButton;
      
      private var btnCupGachaMini:ContainerButton;
      
      private var stampLayer:Sprite;
      
      private var currentHelperDef:HelperCharaDef;
      
      private var forceVisibleHelperFlag:Boolean = false;
      
      private var alreadyAddTo:Boolean = false;
      
      private var isTouchableHelper:Boolean = true;
      
      private var voiceManager:SimpleVoiceManager;
      
      private var canTouchHelper:Boolean = true;
      
      private var voicegettype:int = 1;
      
      private var svoiceManager:SimpleVoiceManager;
      
      public function HomeScene(param1:int = -1, param2:Object = null)
      {
         tutorialSpineParams = new Array(TUTORIAL_GUDETAMA_LIST.length);
         noticeButtonUIs = new Vector.<NoticeButtonUI>();
         helperMessages = [];
         kitchenwares = new Vector.<KitchenwareButton>();
         super(0);
         this.kitchenwareType = param1;
         this.navigateParam = param2;
         if(isNavigate())
         {
            UserDataWrapper.wrapper.setHomeScrollPosition(1);
         }
         cookingScene = new CookingScene(showCookingSceneCallback,backFromCookingSceneCallback);
         addEventListener("refreshed_scene_container",refreshedSceneContainer);
         addEventListener("update_scene",updateScene);
      }
      
      public static function getVoicePaths(param1:Array) : Array
      {
         var _loc6_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:* = null;
         var _loc4_:* = null;
         var _loc7_:Array = [];
         var _loc2_:TouchDef = GameSetting.getTouch();
         _loc6_ = 0;
         while(_loc6_ < _loc2_.randomVoiceIds.length)
         {
            _loc8_ = 0;
            while(_loc8_ < _loc2_.randomVoiceIds[_loc6_].length)
            {
               _loc9_ = _loc2_.randomVoiceIds[_loc6_][_loc8_];
               if(_loc7_.indexOf(_loc9_) == -1)
               {
                  _loc7_.push(_loc9_);
               }
               _loc8_++;
            }
            _loc6_++;
         }
         _loc6_ = 0;
         while(_loc6_ < _loc2_.voiceEvents.length)
         {
            if((_loc9_ = TouchEventDef(_loc2_.voiceEvents[_loc6_]).voice) > 0 && _loc7_.indexOf(_loc9_) == -1)
            {
               _loc7_.push(_loc9_);
            }
            _loc6_++;
         }
         _loc6_ = 0;
         while(_loc6_ < _loc2_.itemEvents.length)
         {
            if((_loc9_ = TouchEventDef(_loc2_.itemEvents[_loc6_]).voice) > 0 && _loc7_.indexOf(_loc9_) == -1)
            {
               _loc7_.push(_loc9_);
            }
            _loc6_++;
         }
         _loc6_ = 0;
         while(_loc6_ < param1.length)
         {
            if((_loc10_ = GameSetting.getGudetama(param1[_loc6_])) != null)
            {
               _loc8_ = 0;
               while(_loc8_ < _loc10_.voices.length)
               {
                  _loc9_ = _loc10_.voices[_loc8_];
                  if(_loc7_.indexOf(_loc9_) == -1)
                  {
                     _loc7_.push(_loc9_);
                  }
                  _loc8_++;
               }
            }
            _loc6_++;
         }
         var _loc5_:Array = [];
         var _loc3_:Array = [];
         _loc6_ = 0;
         while(_loc6_ < _loc7_.length)
         {
            _loc5_ = VoiceManager.getPaths(GameSetting.getVoice(_loc7_[_loc6_]));
            _loc8_ = 0;
            while(_loc8_ < _loc5_.length)
            {
               _loc4_ = _loc5_[_loc8_];
               if(_loc3_.indexOf(_loc4_) == -1)
               {
                  _loc3_.push(_loc4_);
               }
               _loc8_++;
            }
            _loc6_++;
         }
         return _loc3_;
      }
      
      public static function isStartableConditionByNotice(param1:int, param2:UserDataWrapper) : Boolean
      {
         if(!param2.isCanStartNoticeFlag(param1))
         {
            return false;
         }
         switch(param1)
         {
            case 17:
               return UserDataWrapper.featurePart.existsFeature(1);
            case 15:
               return true;
            case 7:
               return UserDataWrapper.featurePart.existsFeature(9);
            case 9:
               return UserDataWrapper.featurePart.existsFeature(8);
            case 10:
               return UserDataWrapper.featurePart.existsFeature(11);
            case 21:
               return UserDataWrapper.missionPart.getNumEventMission() > 0;
            case 5:
               return UserDataWrapper.featurePart.existsFeature(12);
            case 22:
               return true;
            case 23:
               return UserDataWrapper.eventPart.getRankingIds(true) != null;
            case 18:
               return UserDataWrapper.featurePart.existsFeature(10);
            case 4:
               return true;
            case 19:
               return UserDataWrapper.featurePart.existsFeature(13);
            case 25:
               return true;
            case 26:
               return UserDataWrapper.featurePart.existsFeature(14);
            case 27:
               return GudetamaUtil.cupGachaEnable();
            case 28:
               return HomeDecoUtil.enableHomeDeco();
            case 29:
               return GameSetting.hasScreeningFlag(15) && UserDataWrapper.wrapper.isDoneNoticeFlag(3);
            default:
               return false;
         }
      }
      
      public static function usefulButtonSE() : void
      {
         SoundManager.playEffect("voice_useful_def");
      }
      
      private function isNavigate() : Boolean
      {
         return kitchenwareType >= 0;
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"HomeLayout_1",function(param1:Object):void
         {
            var _loc11_:* = null;
            var _loc7_:int = 0;
            var _loc5_:* = null;
            displaySprite = param1.object;
            var _loc10_:Boolean = isTutorial();
            scrollGroup = displaySprite.getChildByName("scrollGroup") as Sprite;
            scrollContainer = scrollGroup.getChildByName("scrollContainer") as PagedScrollContainer;
            homeScroller = new HomeScroller(displaySprite,scene,horizontalThrowToPageCallback,horizontalScrollCallback);
            homeScroller.setupLeftAndRightButton();
            weatherSpineModel = scrollContainer.getChildByName("weatherSpineModel") as SpineModel;
            mountainImage = scrollContainer.getChildByName("mountain") as Image;
            stampLayer = scrollContainer.getChildByName("stampLayer") as Sprite;
            roomImage = scrollContainer.getChildByName("room") as Image;
            dishImage = scrollContainer.getChildByName("dish") as Image;
            bgQuad = scrollContainer.getChildByName("bgQuad") as Quad;
            bgMountain = scrollContainer.getChildByName("mountain") as Image;
            setBGQuadColor();
            gudetamaGroup = scrollContainer.getChildByName("gudetamaGroup") as Sprite;
            var _loc2_:Sprite = gudetamaGroup.getChildByName("origin") as Sprite;
            gudetamaButton = gudetamaGroup.getChildByName("gudetamaButton") as ManuallySpineButton;
            if(_loc10_ && UserDataWrapper.wrapper.equalsTutorialProgress(2))
            {
               gudetamaButton.addEventListener("triggered",triggeredGudetamaButton4Tutorial);
               gudetamaButton.setReleaseBeganCallback(gudetamaButtonReleaseBeganCallback4Tutorial);
            }
            else
            {
               gudetamaButton.addEventListener("triggered",triggeredGudetamaButton);
               gudetamaButton.setReleaseBeganCallback(gudetamaButtonReleaseBeganCallback);
               gudetamaButton.setRubCallback(gudetamaButtonRubCallback);
            }
            if(_loc10_)
            {
               gudetamaButton.setTouchEndedCallback(gudetamaButtonTouchEndedCallback4Tutorial);
            }
            else
            {
               gudetamaButton.setTouchEndedCallback(gudetamaButtonTouchEndedCallback);
            }
            helperGroup = scrollContainer.getChildByName("helperGroup") as Sprite;
            helperSpineModel = helperGroup.getChildByName("helperSpineModel") as SpineModel;
            helperGroupPosX = helperGroup.x;
            var _loc3_:int = 0;
            while(_loc11_ = helperGroup.getChildByName("message" + _loc3_) as ColorTextField)
            {
               _loc11_.visible = false;
               helperMessages.push(_loc11_);
               _loc3_++;
            }
            helperGroup.visible = false;
            gudetamaButton.setOrigin(_loc2_.x,_loc2_.y);
            gudetamaButton.setTouchBeganCallback(gudetamaButtonTouchBeganCallback);
            dropItemButton = scrollContainer.getChildByName("dropItemButton") as ContainerButton;
            dropItemButton.addEventListener("triggered",triggeredDropItemButton);
            imgDrop = dropItemButton.getChildByName("imgDrop") as Image;
            var _loc4_:ContainerButton;
            (_loc4_ = scrollContainer.getChildByName("completedButton") as ContainerButton).setStopPropagation(true);
            noticeButtonUIs.push(new NoticeButtonUI(_loc4_,NoticeButtonUI.TYPE_COMPLETE,triggeredNoticeButtonCallback));
            var _loc12_:ContainerButton = scrollContainer.getChildByName("emptyButton") as ContainerButton;
            noticeButtonUIs.push(new NoticeButtonUI(_loc12_,2,triggeredNoticeButtonCallback));
            infoButton = new InfoButtonUI(scrollContainer.getChildByName("infoButton") as ContainerButton,scene);
            infoIcon = new InfoIconUI(scrollContainer.getChildByName("infoIconButton") as ContainerButton,triggeredInfoIconUICallback);
            if(infoIcon)
            {
               infoIcon.invisible = true;
               infoIcon.setVisible(false);
            }
            shopButton = scrollContainer.getChildByName("shopButton") as ContainerButton;
            shopButton.setStopPropagation(true);
            shopButton.addEventListener("triggered",triggeredShopButton);
            menuButton = scrollContainer.getChildByName("menuButton") as SimpleImageButton;
            menuButton.setStopPropagation(true);
            menuButton.addEventListener("triggered",triggeredMenuButton);
            gachaButton = scrollContainer.getChildByName("gachaButton") as ContainerButton;
            gachaButton.setStopPropagation(true);
            gachaButton.addEventListener("triggered",triggeredGachaButton);
            gachaFreePlayGroup = gachaButton.getChildByName("playableGroup") as Sprite;
            gachaPickupImage = gachaButton.getChildByName("pickup") as Image;
            collectionSprite = scrollContainer.getChildByName("collectionSprite") as Sprite;
            collectionButton = collectionSprite.getChildByName("collectionButton") as SimpleImageButton;
            collectionButton.setStopPropagation(true);
            collectionButton.addEventListener("triggered",triggeredCollectionButton);
            collectionBookinfoSprite = collectionSprite.getChildByName("bookinfo") as Sprite;
            collectionBookinfoSprite.visible = false;
            friendButton = new FriendButtonUI(scrollContainer.getChildByName("friendButton") as ContainerButton);
            cameraButton = scrollContainer.getChildByName("cameraButton") as SimpleImageButton;
            cameraButton.setStopPropagation(true);
            cameraButton.addEventListener("triggered",triggeredCameraButton);
            var _loc6_:Sprite = scrollContainer.getChildByName("spCup") as Sprite;
            btnCupGachaMini = scrollContainer.getChildByName("btnCupGachaMini") as ContainerButton;
            btnCupGacha = new CupGachaButton(_loc6_,btnCupGachaMini,scene);
            var _loc8_:Sprite = scrollContainer.getChildByName("kitchenwareGroup") as Sprite;
            _loc7_ = 0;
            while(_loc7_ < 5)
            {
               _loc5_ = _loc8_.getChildByName("kitchenware" + _loc7_) as Sprite;
               kitchenwares.push(new KitchenwareButton(_loc5_,scene,_loc7_));
               _loc7_++;
            }
            challengeButton = scrollContainer.getChildByName("challengeButton") as SimpleImageButton;
            challengeButton.setStopPropagation(true);
            challengeButton.addEventListener("triggered",triggeredChallengeButton);
            carnaviUI = new CarnaviUI(scrollContainer.getChildByName("carnaviGroup") as Sprite);
            bombEffectImage = new BombEffectImage(scrollContainer.getChildByName("bombEffect") as Image);
            movieButton = new MovieButton(scrollContainer.getChildByName("movieButton") as Sprite);
            profileButton = new ProfileButton(scrollContainer.getChildByName("profileButton") as ContainerButton);
            delusionButton = new DelusionButton(scrollContainer.getChildByName("delusionButton") as ContainerButton);
            usefulGroup = scrollContainer.getChildByName("usefulGroup") as Sprite;
            usefulButton = usefulGroup.getChildByName("usefulButton") as ContainerButton;
            usefulButton.setStopPropagation(true);
            usefulButton.addEventListener("triggered",triggeredUsefulButton);
            heavenUI = new HeavenUI(scrollContainer,scene,displaySprite.getChildByName("heavenQuad") as Quad);
            serifUI = new SerifUI(scrollContainer.getChildByName("rightSerifGroup") as Sprite,scrollContainer.getChildByName("leftSerifGroup") as Sprite);
            touchTextGroup = new TouchTextGroup(scrollContainer.getChildByName("touchTextGroup") as Sprite);
            hideGudetamaGroup = scrollContainer.getChildByName("hideGudetamaGroup") as Sprite;
            eventButton = new EventButton(scrollContainer.getChildByName("eventButton") as ContainerButton);
            eventNoticeButton = new EventNoticeButton(scrollContainer.getChildByName("eventNoticeButton") as ContainerButton,triggeredEventNoticeButtonCallback);
            var _loc9_:Quad = displaySprite.getChildByName("messageQuad") as Quad;
            messageUI = new MessageUI(scrollContainer.getChildByName("messageGroup") as Sprite,scene,_loc9_);
            gudetamaQuad = displaySprite.getChildByName("gudetamaQuad") as Quad;
            gudetamaQuad.addEventListener("touch",onTouchGudetamaQuad);
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         setupLayoutForTask(queue,"_HeavenItem",function(param1:Object):void
         {
            heavenItemExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         setupLayoutForTask(queue,"_DelusionItem",function(param1:Object):void
         {
            delusionItemExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         setupLayoutForTask(queue,"_TouchText",function(param1:Object):void
         {
            touchTextItemExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         cookingScene.loadCookingScene(queue);
         addTask(function():void
         {
            var _loc1_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(HOME_GET_INFO),function(param1:Array):void
            {
               var _loc2_:TouchInfo = param1[0];
               questionData = param1[1];
               delusionRestTimes = param1[2];
               var _loc3_:Array = param1[3];
               var _loc4_:Array = param1[4];
               UserDataWrapper.wrapper.updateTouchInfo(_loc2_);
               UserDataWrapper.wrapper.removeDropItemEvent();
               UserDataWrapper.wrapper.removeHeavenEvent();
               enabledGachaFreePlay = _loc3_[0] != 0;
               existsPickup = _loc3_[1] != 0;
               UserDataWrapper.decorationPart.setDecorationId(_loc3_[2]);
               UserDataWrapper.wrapper.resetMailNoticeIconIds();
               UserDataWrapper.wrapper.updateMailNoticeIconIds(_loc4_);
               taskDone();
            });
         });
         preloadVoice();
         addTask(function():void
         {
            preloadHelperSetting(function():void
            {
               taskDone();
            });
         });
         preloadTutorialSpineParam();
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            setup();
         });
         queue.startTask(onProgress);
      }
      
      private function preloadVoice() : void
      {
         var _loc2_:int = 0;
         var _loc1_:Array = getVoicePaths([UserDataWrapper.wrapper.getPlacedGudetamaId()]);
         _loc2_ = 0;
         while(_loc2_ < _loc1_.length)
         {
            _preloadVoice(_loc1_[_loc2_]);
            _loc2_++;
         }
      }
      
      private function preloadHelperSetting(param1:Function, param2:int = -1) : void
      {
         var _callback:Function = param1;
         var _index:int = param2;
         loadHelperSetting(_index);
         if(!currentHelperDef)
         {
            _callback();
            return;
         }
         var voices:Object = currentHelperDef.voices;
         var innerQueue:TaskQueue = new TaskQueue();
         for(voicekey in voices)
         {
            _preloadHelperVoice(voices[voicekey],innerQueue);
         }
         innerQueue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            _callback();
         });
         innerQueue.startTask();
      }
      
      private function _preloadHelperVoice(param1:String, param2:TaskQueue) : void
      {
         var _voiceId:String = param1;
         var _innerQueue:TaskQueue = param2;
         _innerQueue.addTask(function():void
         {
            var path:String = "rsrc/voice/" + _voiceId + ".mp3";
            SoundManager.loadVoice(SoundManager.getVoiceId(path),path,function(param1:int):void
            {
               _innerQueue.taskDone();
            });
         });
      }
      
      private function _preloadVoice(param1:String) : void
      {
         var path:String = param1;
         addTask(function():void
         {
            SoundManager.loadVoice(SoundManager.getVoiceId(path),path,function(param1:int):void
            {
               taskDone();
            });
         });
      }
      
      private function preloadTutorialSpineParam() : void
      {
         if(!isTutorial())
         {
            return;
         }
         var i:int = 0;
         while(i < TUTORIAL_GUDETAMA_LIST.length)
         {
            _preloadTutorialSpineParam(i);
            i++;
         }
         addTask(function():void
         {
            var gudetamaDef:GudetamaDef = GameSetting.getGudetama(UserDataWrapper.wrapper.getPlacedGudetamaId());
            if(!gudetamaDef.disabledSpine)
            {
               SpineModel.preload(GudetamaUtil.getSpineName(gudetamaDef.id#2),function(param1:Object):void
               {
                  gudetamaSpineParam = param1;
                  taskDone();
               });
            }
            else
            {
               TextureCollector.loadTexture("gudetama-" + gudetamaDef.rsrc + "-image",function(param1:Texture):void
               {
                  taskDone();
               });
            }
         });
      }
      
      private function _preloadTutorialSpineParam(param1:int) : void
      {
         var index:int = param1;
         addTask(function():void
         {
            var gudetamaDef:GudetamaDef = GameSetting.getGudetama(TUTORIAL_GUDETAMA_LIST[index]);
            if(!gudetamaDef.disabledSpine)
            {
               SpineModel.preload(GudetamaUtil.getSpineName(gudetamaDef.id#2),function(param1:Object):void
               {
                  tutorialSpineParams[index] = param1;
                  taskDone();
               });
            }
            else
            {
               TextureCollector.loadTexture("gudetama-" + gudetamaDef.rsrc + "-image",function(param1:Texture):void
               {
                  taskDone();
               });
            }
         });
      }
      
      private function addHelperSpainModel(param1:TaskQueue) : void
      {
         var _queue:TaskQueue = param1;
         _queue.addTask(function():void
         {
            loadHelperSpainModel(function():void
            {
               _queue.taskDone();
            });
         });
      }
      
      private function loadHelperSetting(param1:int = -1) : void
      {
         if(!GameSetting.hasScreeningFlag(15))
         {
            return;
         }
         var _loc2_:* = param1;
         if(_loc2_ == -1 && DataStorage.getLocalData().helperId != -1)
         {
            _loc2_ = int(DataStorage.getLocalData().helperId);
         }
         currentHelperDef = GameSetting.getHelperSetting(_loc2_);
      }
      
      private function loadHelperSpainModel(param1:Function) : void
      {
         var _callback:Function = param1;
         if(!currentHelperDef)
         {
            _callback();
            return;
         }
         var helperSpineName:String = GudetamaUtil.getHelperSpineName(currentHelperDef.rsrc);
         helperSpineModel.load(helperSpineName,function():void
         {
            visibleHelper(canShowHelperChara());
            _callback();
         });
         checkHelperPosition();
      }
      
      private function checkHelperPosition() : void
      {
         var _loc1_:Number = NaN;
         if(currentHelperDef)
         {
            _loc1_ = gudetamaGroup.x + gudetamaButton.width / 2 + currentHelperDef.fixHelperPosX;
            helperGroup.x = helperGroupPosX;
            if(_loc1_ < helperGroupPosX)
            {
               helperGroup.x = _loc1_;
            }
         }
      }
      
      private function visibleHelper(param1:Boolean) : void
      {
         var _b:Boolean = param1;
         if(!alreadyAddTo)
         {
            return;
         }
         if(forceVisibleHelperFlag)
         {
            return;
         }
         if(helperSpineModel.visible == _b)
         {
            return;
         }
         if(_b)
         {
            helperGroup.visible = true;
            helperSpineModel.visible = true;
            helperSpineModel.show();
            helperSpineModel.changeAnimation("start",false,function():void
            {
               helperSpineModel.changeAnimation("idle_loop");
               helperSpineModel.touchable = isTouchableHelper;
               helperSpineModel.addEventListener("touch",triggeredHelperEvent);
            });
         }
         else
         {
            helperGroup.visible = false;
            helperSpineModel.visible = false;
            helperSpineModel.hide();
            helperSpineModel.touchable = false;
            helperSpineModel.removeEventListener("touch",triggeredHelperEvent);
         }
      }
      
      private function setupLayoutForTask(param1:TaskQueue, param2:Object, param3:Function) : void
      {
         var queue:TaskQueue = param1;
         var layoutData:Object = param2;
         var callback:Function = param3;
         loadCount++;
         Engine.setupLayoutForTask(queue,layoutData,function(param1:Object):void
         {
            loadCount--;
            callback(param1);
            checkInit();
         });
      }
      
      private function addTask(param1:Function) : void
      {
         loadCount++;
         queue.addTask(param1);
      }
      
      private function taskDone() : void
      {
         loadCount--;
         checkInit();
         queue.taskDone();
      }
      
      private function checkInit() : void
      {
         if(loadCount > 0)
         {
            return;
         }
         init();
      }
      
      private function init() : void
      {
         bombEffectImage.init();
         delusionButton.init(delusionItemExtractor);
         load();
      }
      
      private function load() : void
      {
         queue.addTask(function():void
         {
            var innerQueue:TaskQueue = new TaskQueue();
            var gudetamaDef:GudetamaDef = GameSetting.getGudetama(UserDataWrapper.wrapper.getPlacedGudetamaId());
            gudetamaButton.setup(innerQueue,gudetamaDef.id#2,true,function():void
            {
               checkHelperPosition();
            });
            gudetamaButton.setDispatcher(gudetamaQuad);
            createHideGude(innerQueue);
            addHelperSpainModel(innerQueue);
            ResidentMenuUI_Gudetama.getInstance().loadMenuUI(innerQueue);
            setRoomTexture(innerQueue);
            innerQueue.registerOnProgress(function(param1:Number):void
            {
               var ratio:Number = param1;
               if(ratio < 1)
               {
                  return;
               }
               dishImage.visible = gudetamaDef.dish;
               profileButton.setup(queue);
               carnaviUI.load(queue);
               var gudetamaRect:Rectangle = new Rectangle(gudetamaGroup.x - gudetamaGroup.pivotX - 0.5 * gudetamaButton.width - (gudetamaButton.pivotX - 0.5 * gudetamaButton.width),gudetamaGroup.y - gudetamaGroup.pivotY - 0.5 * gudetamaButton.height - (gudetamaButton.pivotY - 0.5 * gudetamaButton.height),gudetamaButton.width,gudetamaButton.height);
               serifUI.setup(gudetamaRect);
               touchTextGroup.setup(queue,gudetamaDef.id#2,touchTextItemExtractor,gudetamaRect);
               queue.addTask(function():void
               {
                  if(UserDataWrapper.wrapper.equalsTutorialProgress(2))
                  {
                     firstGudetamaTouchBG = scrollContainer.getChildByName("firstGudetamaTouchBG") as Sprite;
                     TextureCollector.loadTextureRsrc("bg-tutorial",function(param1:Texture):void
                     {
                        GudetamaBg = new Image(param1);
                        GudetamaBg.pivotX = GudetamaBg.width / 2;
                        GudetamaBg.pivotY = GudetamaBg.height / 2;
                        firstGudetamaTouchBG.addChild(GudetamaBg);
                        queue.taskDone();
                     });
                  }
                  else
                  {
                     queue.taskDone();
                  }
               });
               queue.taskDone();
            });
            innerQueue.startTask();
         });
         messageUI.setup(queue,questionData);
         eventNoticeButton.setup(queue);
      }
      
      private function setRoomTexture(param1:TaskQueue, param2:Boolean = false) : void
      {
         var _queue:TaskQueue = param1;
         var _fromCooking:Boolean = param2;
         _queue.addTask(function():void
         {
            TextureCollector.loadTexture("room-" + UserDataWrapper.decorationPart.getHomeDecorationId() + "-bg",function(param1:Texture):void
            {
               roomImage.texture = param1;
               if(!_fromCooking && UserDataWrapper.wrapper.hasHomeDecoData())
               {
                  HomeDecoUtil.setDecoData(UserDataWrapper.wrapper.getHomeDecoData(),roomImage,stampLayer,_queue);
                  _queue.taskDone();
               }
               else
               {
                  _queue.taskDone();
               }
            });
         });
      }
      
      private function setup() : void
      {
         ResidentMenuUI_Gudetama.getInstance().completeMenuUI();
         if(UserDataWrapper.wrapper.lastHomeScrollPositionIsRight() || isTutorial())
         {
            homeScroller.scrollToPageIndex(homeScroller.horizontalPageCount,0);
         }
         else
         {
            homeScroller.setupLeft();
         }
         homeScroller.resetViewPort();
         weatherSpineModel.show();
         weatherSpineModel.changeAnimation(GudetamaUtil.getWeatherSpineAnimeName());
         dropItemButton.visible = false;
         dropItemButton.touchable = false;
         heavenUI.setup(heavenItemExtractor);
         delusionButton.setup(delusionRestTimes);
         movieButton.update();
         carnaviUI.setup();
         visibleGudetamaQuad = false;
         updateGudetamaQuad();
         updateScene();
      }
      
      override protected function addedToContainer() : void
      {
         var _loc2_:* = null;
         var _loc3_:int = 0;
         var _loc1_:* = null;
         displaySprite.visible = true;
         infoButton.show();
         eventNoticeButton.show();
         if(GudetamaUtil.decorationEnbale())
         {
            TweenAnimator.startItself(usefulButton,"show");
         }
         else
         {
            TweenAnimator.startItself(usefulButton,"useful");
         }
         if(UserDataWrapper.wrapper.isFirstGudetamaTouch())
         {
            showResidentMenuUI(68);
            SoundManager.fadeOutMusic(0.5);
         }
         else
         {
            showResidentMenuUI(38);
            playHomeMusic();
         }
         Engine.lockTouchInput(HomeScene);
         hideButton4Tutorial();
         setBackButtonCallback(confirmGameExit);
         if(subSceneObject)
         {
            _loc2_ = subSceneObject.subScene;
            switch(_loc2_)
            {
               case "useful":
                  triggeredUsefulButton();
                  break;
               case "useful_detail":
                  _loc3_ = subSceneObject.id;
                  _loc1_ = subSceneObject.callback;
                  UsefulDetailDialog.show(_loc3_,HomeScene,_loc1_);
            }
         }
      }
      
      private function confirmGameExit() : void
      {
         if(isTutorial() || Engine.getGuideTalkPanel() != null)
         {
            return;
         }
         GudetamaUtil.confirmGameExit();
      }
      
      private function hideButton4Tutorial() : void
      {
         var _loc3_:* = 0;
         if(!isTutorial())
         {
            return;
         }
         if(!UserDataWrapper.wrapper.equalsTutorialProgress(2))
         {
            touchable = false;
         }
         else
         {
            carnaviUI.setVisible(false);
         }
         if(menuButton)
         {
            menuButton.visible = false;
         }
         if(shopButton)
         {
            shopButton.visible = false;
         }
         if(infoButton)
         {
            infoButton.setVisible(false);
         }
         if(infoIcon)
         {
            infoIcon.setVisible(false);
         }
         if(movieButton)
         {
            movieButton.setVisible(false);
         }
         if(profileButton != null)
         {
            profileButton.setVisible(false);
         }
         if(eventButton)
         {
            eventButton.setTouchable(false);
         }
         if(eventNoticeButton)
         {
            eventNoticeButton.setTutorial(true);
         }
         if(collectionSprite)
         {
            collectionSprite.visible = false;
         }
         if(helperGroup)
         {
            helperGroup.visible = false;
         }
         homeScroller.setTutorialFlag(true);
         homeScroller.setRightButtonVisible(false);
         homeScroller.setLeftButtonVisible(false);
         var _loc2_:uint = kitchenwares.length;
         _loc3_ = uint(1);
         while(_loc3_ < _loc2_)
         {
            (kitchenwares[_loc3_] as KitchenwareButton).setEnable();
            _loc3_++;
         }
         btnCupGacha.setDisable();
         for each(var _loc1_ in noticeButtonUIs)
         {
            _loc1_.setVisible(false);
         }
      }
      
      override protected function transitionOpenFinished() : void
      {
         if(isTutorial())
         {
            processTutorial();
            return;
         }
         if(checkNoticeTutorial())
         {
            alreadyAddTo = true;
            return;
         }
         Engine.unlockTouchInput(HomeScene);
         if(isNavigate())
         {
            alreadyAddTo = true;
            kitchenwares[kitchenwareType].triggered(null,navigateParam);
            return;
         }
         checkVariousDialog(false);
      }
      
      private function checkVariousDialog(param1:Boolean) : void
      {
         var callCookingBack:Boolean = param1;
         DialogSystemMailChecker.checkDialogMail(function():void
         {
            AcquiredKitchenwareDialog.show(function():void
            {
               AcquiredRecipeNoteDialog.show(function():void
               {
                  ResidentMenuUI_Gudetama.getInstance().checkClearedMission(function():void
                  {
                     LinkageAchievementDialog.show(function():void
                     {
                        PresentMoneyAndFriendlyDialog.show(function():void
                        {
                           AssistNoticeDialog.show(function():void
                           {
                              showRankingGlobalPointRewards(function():void
                              {
                                 showPresentLimitSoon(function():void
                                 {
                                    ResidentMenuUI_Gudetama.getInstance().checkReceipt(function():void
                                    {
                                       messageUI.show();
                                       if(!callCookingBack || appearHideGudeCookingBack)
                                       {
                                          appearHideGudeCookingBack = false;
                                          if(!startHideGude())
                                          {
                                             InterstitialAdvertisingManager.showInterstitialAds();
                                          }
                                       }
                                       else
                                       {
                                          InterstitialAdvertisingManager.showInterstitialAds();
                                       }
                                       alreadyAddTo = true;
                                       trace("!!!!!HomeScene show various dialogs finished!!!!!");
                                    });
                                 });
                              });
                           });
                        });
                     });
                  });
               });
            });
         });
      }
      
      private function showRankingGlobalPointRewards(param1:Function) : void
      {
         var _loc2_:Array = UserDataWrapper.eventPart.getRankingIds(false,false);
         if(!_loc2_ || _loc2_.length <= 0)
         {
            param1();
            return;
         }
         ResidentMenuUI_Gudetama.showRankingGlobalPointRewards(_loc2_[0],param1);
      }
      
      private function showPresentLimitSoon(param1:Function) : void
      {
         if(!UserDataWrapper.wrapper.hasPresentLimitSoon)
         {
            param1();
            return;
         }
         UserDataWrapper.wrapper.hasPresentLimitSoon = false;
         LocalMessageDialog.show(0,GameSetting.getUIText("present.limit.soon"),param1);
      }
      
      private function createHideGude(param1:TaskQueue) : void
      {
         if(isStartableConditionByNotice(25,UserDataWrapper.wrapper))
         {
            createHideGude4Guide(param1);
            return;
         }
         if(UserDataWrapper.wrapper.hideGudeId == 0)
         {
            return;
         }
         if(hideGude != null)
         {
            hideGudetamaGroup.removeChild(hideGude,true);
         }
         hideGude = new HideGudetama(param1,UserDataWrapper.wrapper.hideGudeId);
         hideGudetamaGroup.addChild(hideGude);
      }
      
      private function createHideGude4Guide(param1:TaskQueue) : void
      {
         var queue:TaskQueue = param1;
         var _loc2_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(GENERATE_HIDE_GUDE_4GUIDE,2),function(param1:*):void
         {
            UserDataWrapper.wrapper.hideGudeId = 2;
            if(hideGude != null)
            {
               hideGudetamaGroup.removeChild(hideGude,true);
            }
            hideGude = new HideGudetama(queue,UserDataWrapper.wrapper.hideGudeId);
            hideGudetamaGroup.addChild(hideGude);
         });
      }
      
      private function startHideGude() : Boolean
      {
         if(hideGude == null)
         {
            return false;
         }
         hideGude.setHomeScene(this);
         hideGude.startMove();
         return true;
      }
      
      private function checkNoticeTutorial() : Boolean
      {
         var wrapper:UserDataWrapper = UserDataWrapper.wrapper;
         var noticeFlags:Vector.<int> = new <int>[17,15,7,9,10,21,5,22,23,26,27,28,29,18,4,19,25];
         var len:uint = noticeFlags.length;
         var i:uint = 0;
         while(i < len)
         {
            if(isStartableConditionByNotice(noticeFlags[i],wrapper))
            {
               setTouchableButton4Tutorial(false,noticeFlags[i]);
               processNoticeTutorial(noticeFlags[i],noticeTutorialAction,getGuideArrowPos,function():void
               {
                  Engine.hideLoading(HomeScene);
               });
               return true;
            }
            i++;
         }
         return false;
      }
      
      public function checkNoticeTargetTutorial(param1:int) : Boolean
      {
         var flag:int = param1;
         if(!isStartableConditionByNotice(flag,UserDataWrapper.wrapper))
         {
            return false;
         }
         setTouchableButton4Tutorial(false,flag);
         processNoticeTutorial(flag,noticeTutorialAction,getGuideArrowPos,function():void
         {
            Engine.hideLoading(HomeScene);
         });
         return true;
      }
      
      private function setTouchableButton4Tutorial(param1:Boolean, param2:int) : void
      {
         var _loc5_:* = 0;
         if(param2 == 4)
         {
            return;
         }
         if(menuButton)
         {
            menuButton.touchable = param1;
         }
         if(shopButton)
         {
            shopButton.touchable = param1;
         }
         if(infoButton)
         {
            infoButton.touchable = param1;
         }
         if(infoIcon)
         {
            infoIcon.getDisplaySprite().touchable = param1;
         }
         if(movieButton)
         {
            movieButton.setTouchable(param1);
         }
         if(usefulButton)
         {
            usefulButton.touchable = param1;
         }
         if(friendButton)
         {
            friendButton.touchable = param1;
         }
         if(challengeButton)
         {
            challengeButton.touchable = param1;
         }
         if(gachaButton)
         {
            gachaButton.touchable = param1;
         }
         if(cameraButton)
         {
            cameraButton.touchable = param1;
         }
         if(profileButton)
         {
            profileButton.setTouchable(param1);
         }
         if(collectionButton)
         {
            collectionButton.touchable = param1;
         }
         if(gudetamaButton)
         {
            gudetamaButton.touchable = param1;
         }
         if(eventButton)
         {
            eventButton.getDisplaySprite().touchable = param1;
         }
         if(eventNoticeButton)
         {
            eventNoticeButton.getDisplaySprite().touchable = param1;
         }
         isTouchableHelper = param1;
         if(helperSpineModel)
         {
            helperSpineModel.touchable = isTouchableHelper;
         }
         homeScroller.setTutorialFlag(!param1);
         if(param1)
         {
            homeScroller.setupLeftAndRightButton();
         }
         else
         {
            homeScroller.setRightButtonVisible(false);
            homeScroller.setLeftButtonVisible(false);
         }
         homeScroller.setHorizontalScrollPolicy(!!param1 ? "auto" : "off");
         var _loc4_:uint = kitchenwares.length;
         _loc5_ = uint(0);
         while(_loc5_ < _loc4_)
         {
            (kitchenwares[_loc5_] as KitchenwareButton).setTouchable(param1);
            _loc5_++;
         }
         btnCupGacha.setTouchable(param1);
         for each(var _loc3_ in noticeButtonUIs)
         {
            _loc3_.touchable = param1;
         }
         btnCupGachaMini.touchable = param1;
         switch(param2)
         {
            case 7:
            case 26:
               usefulButton.touchable = true;
               break;
            case 28:
            case 9:
               challengeButton.touchable = true;
               break;
            case 10:
            case 21:
               eventButton.getDisplaySprite().touchable = true;
               break;
            case 23:
               friendButton.touchable = true;
               break;
            case 5:
            case 15:
               shopButton.touchable = true;
               break;
            case 22:
               btnCupGacha.setTouchable(true);
               btnCupGacha.setVisible(true);
               break;
            case 27:
         }
      }
      
      private function processTutorial() : Boolean
      {
         var _loc2_:UserDataWrapper = UserDataWrapper.wrapper;
         var _loc1_:int = _loc2_.getTutorialProgress();
         checkTutorialGuideTalk(_loc1_,202);
         return true;
      }
      
      private function isTutorial() : Boolean
      {
         return !UserDataWrapper.wrapper.isCompletedTutorial();
      }
      
      private function resumeTutorial() : void
      {
         if(!isTutorial())
         {
            Logger.warn("warn : [tutorial completed] failed resumeGuideTalk() in " + this);
         }
         if(!Engine.resumeGuideTalk())
         {
            Logger.warn("warn : failed resumeGuideTalk() in " + this);
         }
      }
      
      private function tutorialAction(param1:int) : void
      {
         var index:int = param1;
         switch(int(index))
         {
            case 0:
               gudetamaButton.change(TUTORIAL_GUDETAMA_LIST[0],tutorialSpineParams[0]);
               break;
            case 1:
               gudetamaButton.change(TUTORIAL_GUDETAMA_LIST[1],tutorialSpineParams[1]);
               break;
            case 2:
               gudetamaButton.change(UserDataWrapper.wrapper.getPlacedGudetamaId(),gudetamaSpineParam);
               break;
            case 3:
               touchable = false;
               getSceneJuggler().delayCall(function():void
               {
                  nextTutorial();
               },0.3);
               break;
            case 4:
               homeScroller.scrollLeft();
               break;
            case 5:
               homeScroller.setHorizontalScrollPolicy("off");
               break;
            case 6:
               homeScroller.setHorizontalScrollPolicy("off");
               break;
            case 7:
               touchable = false;
               Engine.showLoading(HomeScene);
               var _loc2_:* = HttpConnector;
               if(gudetama.net.HttpConnector.mainConnector == null)
               {
                  gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
               }
               gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(PACKET_GET_GUDETAMA_VOICE_EVENT_TUTORIAL),function(param1:TouchInfo):void
               {
                  Engine.hideLoading(HomeScene);
                  if(param1)
                  {
                     UserDataWrapper.wrapper.updateTouchInfo(param1);
                     touchable = true;
                  }
               });
               break;
            case 8:
               touchable = false;
               Engine.showLoading(HomeScene);
               var _loc3_:* = HttpConnector;
               if(gudetama.net.HttpConnector.mainConnector == null)
               {
                  gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
               }
               gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(PACKET_GET_HEAVEN_EVENT_TUTORIAL),function(param1:TouchInfo):void
               {
                  Engine.hideLoading(HomeScene);
                  if(param1)
                  {
                     UserDataWrapper.wrapper.updateTouchInfo(param1);
                     touchable = true;
                  }
               });
               break;
            case 9:
               nextTutorial();
               break;
            case 10:
               PushInfoDialog.show(function():void
               {
                  Engine.checkPushToken(completeTutorial);
               });
               break;
            case 11:
               triggeredCameraButton(null);
         }
      }
      
      public function noticeTutorialAction(param1:int) : void
      {
         var index:int = param1;
         switch(int(index))
         {
            case 0:
               setTouchableButton4Tutorial(true,-1);
               break;
            case 1:
               homeScroller.scrollLeft();
               break;
            case 2:
               FeatureNoticeDialog.show(1);
               break;
            case 3:
               FeatureNoticeDialog.show(10);
               break;
            case 4:
               FeatureNoticeDialog.show(13);
               break;
            case 5:
               homeScroller.scrollRight();
               break;
            case 6:
               playHomeMusic();
               var rankingIds:Array = UserDataWrapper.eventPart.getRankingIds(true);
               if(rankingIds != null)
               {
                  var rDef:RankingDef = GameSetting.def.rankingMap[rankingIds[0]];
                  var comic:ComicDef = GameSetting.def.comicMap[rDef.storyComicId];
                  if(comic != null)
                  {
                     ComicDialog.show(rDef.id#2,comic,null,function():void
                     {
                        resumeNoticeTutorial(23);
                     });
                     break;
                  }
               }
               setTouchableButton4Tutorial(true,-1);
               Engine.getGuideTalkPanel().finish();
               break;
            case 7:
               startHideGude();
               break;
            case 8:
               Engine.showLoading(noticeTutorialAction);
               var _loc3_:* = HttpConnector;
               if(gudetama.net.HttpConnector.mainConnector == null)
               {
                  gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
               }
               gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(HOME_CUP_GACHA_GUIDE),function(param1:*):void
               {
                  Engine.hideLoading(noticeTutorialAction);
                  if(!(param1 is Array))
                  {
                     getSceneJuggler().delayCall(procCupGachaGuideResume,0.1);
                     return;
                  }
                  var _loc3_:ItemParam = new ItemParam();
                  _loc3_.kind = 19;
                  _loc3_.id#2 = param1[1];
                  _loc3_.num = 1;
                  var _loc2_:GetItemResult = new GetItemResult();
                  _loc2_.item = _loc3_;
                  _loc2_.param = param1;
                  _loc2_.toMail = false;
                  ItemGetDialog.show(_loc2_,procCupGachaGuideResume,GameSetting.getUIText("cupgacha.first.present"));
               });
               break;
            case 9:
               playHomeMusic();
               HelperComicDialog.show(function():void
               {
                  resumeNoticeTutorial(29);
               });
         }
      }
      
      private function procCupGachaGuideResume() : void
      {
         btnCupGacha.setup();
         resumeNoticeTutorial(27);
      }
      
      public function getGuideArrowPos(param1:int) : Vector.<Number>
      {
         var _loc2_:* = undefined;
         switch(int(param1))
         {
            case 0:
               return GudetamaUtil.getCenterPosAndWHOnEngine(friendButton.getDisplaySprite());
            case 1:
               return GudetamaUtil.getCenterPosAndWHOnEngine(usefulButton);
            case 2:
               return GudetamaUtil.getCenterPosAndWHOnEngine(challengeButton);
            case 3:
               return GudetamaUtil.getCenterPosAndWHOnEngine(kitchenwares[0].getDisplaySprite());
            case 4:
               return GudetamaUtil.getCenterPosAndWHOnEngine(shopButton);
            case 5:
               return GudetamaUtil.getCenterPosAndWHOnEngine(cameraButton);
            case 6:
               return GudetamaUtil.getCenterPosAndWHOnEngine(gudetamaButton.getSpineDisplayObject(),gudetamaButton.getGuideArrowPosOffsX(),gudetamaButton.getGuideArrowPosOffsY());
            case 7:
               return GudetamaUtil.getCenterPosAndWHOnEngine(eventButton.getDisplaySprite(),eventButton.getDisplaySprite().pivotX,eventButton.getDisplaySprite().pivotY);
            case 8:
               return GudetamaUtil.getCenterPosAndWHOnEngine(hideGude);
            case 9:
               return GudetamaUtil.getCenterPosAndWHOnEngine(btnCupGacha.getDisplaySprite());
            default:
               return _loc2_;
         }
      }
      
      private function nextTutorial() : void
      {
         var _loc1_:int = UserDataWrapper.wrapper.getTutorialProgress() + 1;
         checkTutorialGuideTalk(_loc1_,203);
      }
      
      private function checkTutorialGuideTalk(param1:int, param2:int) : void
      {
         var progress:int = param1;
         var packetId:int = param2;
         touchable = false;
         Engine.showLoading(HomeScene);
         var _loc3_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(packetId,progress),function(param1:Object):void
         {
            var response:Object = param1;
            var resumeIndex:uint = 0;
            var isGudetamaIntroduction:Boolean = progress == 3;
            if(isGudetamaIntroduction)
            {
               resumeIndex = 9;
            }
            GuideTalkPanel.showTutorial(GameSetting.def.guideTalkTable[progress],tutorialAction,getGuideArrowPos,function():void
            {
               touchable = true;
               Engine.hideLoading(HomeScene);
            },resumeIndex);
         });
      }
      
      private function completeTutorial() : void
      {
         var tutorialProgress:int = UserDataWrapper.wrapper.getTutorialProgress();
         Engine.showLoading(HomeScene);
         var _loc2_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(PACKET_FINISHED_TUTORIAL_GUIDE),function(param1:*):void
         {
            Engine.hideLoading(HomeScene);
            Engine.switchScene(new HomeScene());
         });
      }
      
      override public function advanceTime(param1:Number) : void
      {
         var _loc6_:Boolean = false;
         var _loc5_:int = 0;
         var _loc4_:* = null;
         super.advanceTime(param1);
         if(heavenUI)
         {
            if(_loc6_ = heavenUI.advanceTime(param1))
            {
               UserDataWrapper.wrapper.removeHeavenEvent();
               switch(int(_loc5_ = Math.random() * 4))
               {
                  case 0:
                     SoundManager.playEffect("voice_heaven1");
                     break;
                  case 1:
                     SoundManager.playEffect("voice_heaven2");
                     break;
                  case 2:
                     SoundManager.playEffect("voice_heaven3");
                     break;
                  case 3:
                     SoundManager.playEffect("9969");
               }
               if(isTutorial())
               {
                  resumeTutorial();
               }
            }
         }
         if(gudetamaQuad && visibleGudetamaQuad && Engine.now > finishGudetamaQuadTime)
         {
            visibleGudetamaQuad = false;
            updateGudetamaQuad();
         }
         if(serifUI)
         {
            serifUI.advanceTime(param1);
         }
         if(bombEffectImage)
         {
            bombEffectImage.advanceTime(param1);
         }
         if(delusionButton)
         {
            delusionButton.advanceTime(param1);
         }
         if(homeScroller)
         {
            homeScroller.advanceTime(param1);
         }
         if(gudetamaButton)
         {
            gudetamaButton.advanceTime(param1);
         }
         if(helperGroup)
         {
            visibleHelper(canShowHelperChara());
         }
         if(voiceManager)
         {
            voiceManager.updateVoice();
         }
         if(svoiceManager)
         {
            svoiceManager.updateVoice();
         }
         if(Engine.now < nextUpdateTime)
         {
            return;
         }
         if(kitchenwares)
         {
            for each(var _loc3_ in kitchenwares)
            {
               _loc3_.advanceTime(param1);
            }
         }
         if(btnCupGacha)
         {
            btnCupGacha.advanceTime(param1);
         }
         if(carnaviUI)
         {
            carnaviUI.advanceTime(param1);
         }
         advanceTimeForAbilities();
         if(noticeButtonUIs)
         {
            _loc4_ = UserDataWrapper.kitchenwarePart.getKitchenwareMap();
            for each(var _loc2_ in noticeButtonUIs)
            {
               _loc2_.setup(_loc4_);
            }
         }
         eventNoticeButton.advanceTime(param1);
         infoIcon.advanceTime(param1);
         nextUpdateTime = Engine.now + 1000;
      }
      
      private function advanceTimeForAbilities() : void
      {
         var removed:Boolean = UserDataWrapper.abilityPart.advanceTime();
         if(removed)
         {
            Engine.showLoading(HomeScene);
            var _loc2_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(GENERAL_EXTRA),function(param1:Array):void
            {
               Engine.hideLoading(HomeScene);
            });
         }
      }
      
      private function refreshedSceneContainer(param1:Event) : void
      {
      }
      
      public function setHorizontalScrollPolicy(param1:String) : void
      {
         homeScroller.setHorizontalScrollPolicy(param1);
      }
      
      private function horizontalThrowToPageCallback(param1:int) : void
      {
         heavenUI.setScrollPageIndex(param1);
         setScrollPageIndex(param1);
      }
      
      private function horizontalScrollCallback(param1:Number) : void
      {
         var _loc3_:Number = Math.max(0,(param1 - 0.5) / 0.5);
         profileButton.alpha = _loc3_;
         for each(var _loc2_ in noticeButtonUIs)
         {
            _loc2_.alpha = _loc3_;
         }
         eventNoticeButton.alpha = _loc3_;
         btnCupGachaMini.alpha = _loc3_;
      }
      
      private function gudetamaButtonTouchBeganCallback() : void
      {
         homeScroller.setHorizontalScrollPolicy("off");
      }
      
      private function gudetamaButtonTouchEndedCallback() : void
      {
         homeScroller.setHorizontalScrollPolicy("auto");
      }
      
      private function gudetamaButtonTouchEndedCallback4Tutorial() : void
      {
      }
      
      public function setScrollPageIndex(param1:int) : void
      {
         scrollPageIndex = param1;
         updateGudetamaQuad();
      }
      
      public function updateGudetamaQuad() : void
      {
         gudetamaQuad.visible = scrollPageIndex == 1 && visibleGudetamaQuad;
      }
      
      private function gudetamaButtonReleaseBeganCallback() : void
      {
         visibleGudetamaQuad = true;
         updateGudetamaQuad();
         finishGudetamaQuadTime = Engine.now + gudetamaButton.releaseTweenTime * 1000;
         var rate:Number = Math.random();
         if(rate > 0.5)
         {
            SoundManager.playEffect("put_egg");
         }
         else
         {
            SoundManager.playEffect("tap_nisetama");
         }
         if(rate > 0.97 && !lockTouchEvent)
         {
            lockTouchEvent = true;
            gudetamaButton.startSwingAnime(0.25 + Math.random() * 0.75,function():void
            {
               lockTouchEvent = false;
            });
         }
      }
      
      private function gudetamaButtonRubCallback() : void
      {
         if(!Engine.isTopScene(scene))
         {
            return;
         }
         addMoneyByIndex(0);
         touchTextGroup.show(true);
         checkTouchParam();
         var _loc1_:Number = Math.random();
         if(_loc1_ > 0.5)
         {
            SoundManager.playEffect("put_egg");
         }
         else
         {
            SoundManager.playEffect("tap_nisetama");
         }
      }
      
      private function gudetamaButtonReleaseBeganCallback4Tutorial() : void
      {
         gudetamaButtonReleaseBeganCallback();
         firstGudetamaTouchBG.visible = false;
         playHomeMusic();
         if(isTutorial())
         {
            resumeTutorial();
         }
      }
      
      private function playHomeMusic() : void
      {
         var _loc1_:uint = getHours();
         switch(int(getTimeType(_loc1_)))
         {
            case 0:
            case 1:
               SoundManager.playMusic(UserDataWrapper.eventPart.getEventBGM(0),-1);
               break;
            case 2:
               SoundManager.playMusic(UserDataWrapper.eventPart.getEventBGM(1),-1);
         }
      }
      
      private function setBGQuadColor() : void
      {
         var _loc1_:uint = getHours();
         switch(int(getTimeType(_loc1_)))
         {
            case 0:
               bgQuad.color = 11926271;
               bgMountain.color = 16777215;
               break;
            case 1:
               bgQuad.color = 8310775;
               bgMountain.color = 16777215;
               break;
            case 2:
               bgQuad.color = 4883885;
               bgMountain.color = 9024481;
         }
      }
      
      private function getWeatherSpineAnimeName() : String
      {
         var _loc1_:uint = getHours();
         switch(int(getTimeType(_loc1_)))
         {
            case 0:
            case 1:
               return "start_loop";
            case 2:
               return "start2_loop";
            default:
               return "start_loop";
         }
      }
      
      private function getTimeType(param1:uint) : uint
      {
         if(param1 >= 4 && param1 < 12)
         {
            return 0;
         }
         if(param1 >= 12 && param1 < 18)
         {
            return 1;
         }
         return 2;
      }
      
      private function getHours() : uint
      {
         var _loc2_:String = TimeZoneUtil.getDateHHmm(TimeZoneUtil.epochMillisToOffsetSecs()).substr(0,2);
         return uint(_loc2_);
      }
      
      public function addMoneyByIndex(param1:int, param2:String = "start") : int
      {
         var _loc4_:int = 0;
         if(param1 == 0)
         {
            _loc4_ = getBonusValue();
         }
         var _loc3_:int = GameSetting.getRule().touchRewards[param1] * UserDataWrapper.wrapper.getRank() * (1 + _loc4_);
         UserDataWrapper.wrapper.addFreeMoney(_loc3_);
         if(param2)
         {
            ResidentMenuUI_Gudetama.getInstance()._updateMoney(param2);
         }
         DataStorage.getLocalData().incrementPendingNum(param1);
         if(_loc4_ > 0)
         {
            DataStorage.getLocalData().addPendingBonusValue(_loc4_);
         }
         return _loc3_;
      }
      
      public function getBonusValue() : int
      {
         var _loc5_:Array;
         if(!(_loc5_ = UserDataWrapper.wrapper.getTouchBonusRange()) || _loc5_.length == 0)
         {
            return 0;
         }
         var _loc4_:int = _loc5_[0];
         var _loc3_:int = _loc5_.length >= 2 ? _loc5_[1] : 0;
         var _loc1_:int = Math.min(_loc4_,_loc3_);
         var _loc2_:int = Math.max(_loc4_,_loc3_);
         return _loc1_ + int(Math.random() * (_loc2_ - _loc1_ + 1));
      }
      
      private function triggeredGudetamaButton(param1:Event) : void
      {
         var _loc2_:Boolean = isTutorial();
         if(_loc2_ && isUntouchableGudetama4Tutorial())
         {
            return;
         }
         if(!Engine.isTopScene(scene))
         {
            return;
         }
         addMoneyByIndex(0);
         touchTextGroup.show();
         checkTouchParam();
      }
      
      private function triggeredGudetamaButton4Tutorial(param1:Event) : void
      {
      }
      
      private function isUntouchableGudetama4Tutorial() : Boolean
      {
         if(lockTouchEvent)
         {
            return true;
         }
         if(serifUI.isPlaying())
         {
            return true;
         }
         return false;
      }
      
      private function checkTouchParam() : void
      {
         var nextTouchParam:TouchEventParam = UserDataWrapper.wrapper.getNextTouchEvent();
         if(!nextTouchParam)
         {
            return;
         }
         var processable:Boolean = !lockTouchEvent && !serifUI.isPlaying();
         if(processable)
         {
            DataStorage.getLocalData().incrementTouchNumForEvent();
         }
         var touchNum:int = DataStorage.getLocalData().getTouchNumForEvent();
         if(nextTouchParam.touchNum != touchNum)
         {
            return;
         }
         if(processable)
         {
            if(!nextTouchParam.isHeaven())
            {
               processPlayVoice(nextTouchParam);
               if(nextTouchParam.isDropItem())
               {
                  if(!UserDataWrapper.wrapper.existsDropItemEvent())
                  {
                     processDropItem(nextTouchParam);
                  }
                  else
                  {
                     processAnime();
                  }
               }
               else
               {
                  processAnime();
               }
            }
            else if(!UserDataWrapper.wrapper.existsHeavenEvent())
            {
               processHeaven(nextTouchParam);
            }
         }
         if(!UserDataWrapper.wrapper.updateNextTouchEvent())
         {
            Engine.showLoading(HomeScene);
            var _loc2_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(GENERAL_EXTRA),function(param1:Array):void
            {
               Engine.hideLoading(HomeScene);
            });
         }
      }
      
      private function triggeredHelperEvent(param1:TouchEvent) : void
      {
         var _loc5_:* = null;
         var _loc6_:* = null;
         var _loc7_:int = 0;
         var _loc3_:* = null;
         var _loc2_:* = null;
         var _loc4_:int = 0;
         if((_loc5_ = param1.getTouch(helperSpineModel,"ended")) && canTouchHelper)
         {
            _loc6_ = GameSetting.getGudetama(UserDataWrapper.wrapper.getPlacedGudetamaId());
            voicegettype = 1;
            if(UserDataWrapper.gudetamaPart.isUnlockedVoice(_loc6_.id#2,1))
            {
               voicegettype = 0;
               if(UserDataWrapper.gudetamaPart.isUnlockedVoice(_loc6_.id#2,0))
               {
                  voicegettype = -1;
               }
            }
            _loc7_ = voicegettype;
            if(!UserDataWrapper.featurePart.existsFeature(5))
            {
               _loc7_ = 2;
               if(voicegettype != -1)
               {
                  voicegettype = 0;
               }
            }
            if(_loc7_ == 2)
            {
               _loc2_ = GameSetting.getUtensil(6);
               _loc3_ = StringUtil.format(GameSetting.getUIText("home.helpchara.voice.desc." + _loc7_),_loc2_.name#2);
            }
            else
            {
               _loc3_ = StringUtil.format(GameSetting.getUIText("home.helpchara.voice.desc." + _loc7_),_loc6_.name#2);
            }
            _loc4_ = voicegettype == -1 ? 28 : 29;
            showHelpDialog(_loc4_,_loc3_,_loc7_);
         }
      }
      
      private function showHelpDialog(param1:int, param2:String, param3:int) : void
      {
         var _dialogtype:int = param1;
         var _dialogmsg:String = param2;
         var _msgtype:int = param3;
         MessageDialog.show(_dialogtype,_dialogmsg,function(param1:int):void
         {
            var _c:int = param1;
            if(_c == 3)
            {
               HelperComicDialog.show(function():void
               {
                  showHelpDialog(_dialogtype,_dialogmsg,_msgtype);
               });
            }
            else if(_c == 0 && voicegettype != -1)
            {
               displaySprite.disableAllEventDispatcherChildren();
               canTouchHelper = false;
               var msgindex:String = loadHelperMessage();
               helperMessage.visible = true;
               helperSpineModel.changeAnimation("animation");
               helperSpineModel.show();
               lockTouchEvent = true;
               gudetamaButton.startTween("item1",true,function(param1:DisplayObject):void
               {
                  lockTouchEvent = false;
               });
               voiceManager = new SimpleVoiceManager(showHelperMessage,hideHelperMessage);
               voiceManager.playVoice(currentHelperDef.id#2,MukuGlobal.makePathFromVoiceName(0,currentHelperDef.voices[msgindex]));
            }
            else if(_c == 2 || _c == 0 && _msgtype == -1)
            {
               collectionButtonSE();
               ResidentMenuUI_Gudetama.getInstance().sendChangeState(142,function():void
               {
                  Engine.switchScene(new CollectionScene(0));
               });
            }
         });
      }
      
      private function showHelperMessage() : void
      {
         BannerAdvertisingManager.visibleBanner(false);
         ResidentMenuUI_Gudetama.getInstance()._setTouchableMetalButton(false);
         TweenAnimator.startItself(helperMessage,"showMessage",false,function():void
         {
         });
      }
      
      private function hideHelperMessage(param1:int) : void
      {
         var _id:int = param1;
         voiceManager = null;
         var gudetamaDef:GudetamaDef = GameSetting.getGudetama(UserDataWrapper.wrapper.getPlacedGudetamaId());
         TweenAnimator.startItself(helperMessage,"hideMessage",false,function():void
         {
            helperSpineModel.changeAnimation("end",false,function():void
            {
               helperMessage.visible = false;
               visibleHelper(false);
               forceVisibleHelperFlag = true;
               loadPlayVoice(gudetamaDef,voicegettype,1,function():void
               {
                  BannerAdvertisingManager.visibleBanner(true);
                  ResidentMenuUI_Gudetama.getInstance()._setTouchableMetalButton(true);
                  canTouchHelper = true;
                  if(UserDataWrapper.abilityPart.existsKind(9))
                  {
                     UserDataWrapper.abilityPart.removeAbility(521);
                  }
                  UserDataWrapper.wrapper.setHelperState(false);
                  forceVisibleHelperFlag = false;
                  displaySprite.enableAllEventDispatcherChildren();
                  DataStorage.getLocalData().helperId = -1;
                  helperSpineModel.onRemove();
                  preloadHelperSetting(function():void
                  {
                     DataStorage.saveLocalData();
                     loadHelperSpainModel(function():void
                     {
                     });
                  });
               });
            });
         });
      }
      
      private function loadHelperMessage() : String
      {
         var _loc8_:* = null;
         var _loc6_:int = 0;
         var _loc1_:int = 0;
         var _loc7_:Object = currentHelperDef.massages;
         var _loc5_:* = "";
         for(var _loc4_ in _loc7_)
         {
            _loc8_ = _loc7_[_loc4_] as String;
            _loc6_ = Math.floor(Math.random() * 100);
            _loc6_ = Math.floor(Math.random() * 100);
            _loc1_ = parseInt(_loc8_);
            if(_loc5_ == "")
            {
               _loc5_ = _loc4_;
            }
            if(_loc1_ > _loc6_)
            {
               _loc5_ = _loc4_;
               break;
            }
         }
         var _loc3_:int = Math.floor(Math.random() * helperMessages.length);
         var _loc2_:Object = currentHelperDef.massagePosIndex;
         if(_loc2_ && _loc2_[_loc5_])
         {
            _loc3_ = _loc2_[_loc5_];
         }
         helperMessage = helperMessages[_loc3_];
         helperMessage.text#2 = GameSetting.getUIText("helper.word." + _loc5_);
         return _loc5_;
      }
      
      public function processPlayVoice(param1:TouchEventParam) : void
      {
         var param:TouchEventParam = param1;
         if(!param.isPlayVoice())
         {
            return;
         }
         addMoneyByIndex(1,"start2");
         var gudetamaDef:GudetamaDef = GameSetting.getGudetama(UserDataWrapper.wrapper.getPlacedGudetamaId());
         if(param.voice == -1)
         {
            var voiceIndex:int = 0;
            if(UserDataWrapper.gudetamaPart.isUnlockedVoice(gudetamaDef.id#2,voiceIndex))
            {
               serifUI.play(GameSetting.getVoice(gudetamaDef.voices[voiceIndex]));
            }
            else
            {
               Engine.showLoading(HomeScene);
               var _loc3_:* = HttpConnector;
               if(gudetama.net.HttpConnector.mainConnector == null)
               {
                  gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
               }
               gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(HOME_UNLOCK_VOICE,-1),function(param1:Array):void
               {
                  var response:Array = param1;
                  Engine.hideLoading(HomeScene);
                  var result:GetItemResult = response[0];
                  UserDataWrapper.gudetamaPart.unlockVoice(gudetamaDef.id#2,voiceIndex);
                  UnlockVoiceDialog.show(voiceIndex,-1,function():void
                  {
                     var _loc1_:* = null;
                     if(result && result.item)
                     {
                        _loc1_ = GudetamaUtil.getItemName(result.item.kind,result.item.id#2);
                        ItemGetDialog.show(result,null,StringUtil.format(GameSetting.getUIText("presentComment.msg"),_loc1_),GameSetting.getUIText("presentComment.title"));
                     }
                  });
               });
            }
         }
         else if(param.voice == -2)
         {
            voiceIndex = 1;
            if(UserDataWrapper.gudetamaPart.isUnlockedVoice(gudetamaDef.id#2,voiceIndex))
            {
               serifUI.play(GameSetting.getVoice(gudetamaDef.voices[voiceIndex]));
            }
            else
            {
               Engine.showLoading(HomeScene);
               var _loc4_:* = HttpConnector;
               if(gudetama.net.HttpConnector.mainConnector == null)
               {
                  gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
               }
               gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(HOME_UNLOCK_VOICE,-2),function(param1:Array):void
               {
                  var response:Array = param1;
                  Engine.hideLoading(HomeScene);
                  var result:GetItemResult = response[0];
                  UserDataWrapper.gudetamaPart.unlockVoice(gudetamaDef.id#2,voiceIndex);
                  UnlockVoiceDialog.show(voiceIndex,-1,function():void
                  {
                     var _loc1_:* = null;
                     if(result && result.item)
                     {
                        _loc1_ = GudetamaUtil.getItemName(result.item.kind,result.item.id#2);
                        ItemGetDialog.show(result,null,StringUtil.format(GameSetting.getUIText("presentComment.msg"),_loc1_),GameSetting.getUIText("presentComment.title"));
                     }
                  });
               });
            }
         }
         else
         {
            serifUI.play(GameSetting.getVoice(getRandomVoice(param)));
            if(isTutorial())
            {
               resumeTutorial();
            }
         }
      }
      
      private function loadPlayVoice(param1:GudetamaDef, param2:int, param3:* = 0, param4:Function = null) : void
      {
         var gudetamaDef:GudetamaDef = param1;
         var voiceIndex:int = param2;
         var loadtype:* = param3;
         var callback:Function = param4;
         var voiceEventId:int = voiceIndex == 0 ? -1 : -2;
         if(UserDataWrapper.gudetamaPart.isUnlockedVoice(gudetamaDef.id#2,voiceIndex))
         {
            serifUI.play(GameSetting.getVoice(gudetamaDef.voices[voiceIndex]));
         }
         else
         {
            Engine.showLoading(HomeScene);
            var _loc6_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(loadtype == 0 ? 16777410 : 16777464,voiceEventId),function(param1:Array):void
            {
               var response:Array = param1;
               Engine.hideLoading(HomeScene);
               var result:GetItemResult = response[0];
               UserDataWrapper.gudetamaPart.unlockVoice(gudetamaDef.id#2,voiceIndex);
               UnlockVoiceDialog.show(voiceIndex,-1,function():void
               {
                  var _loc1_:* = null;
                  if(result && result.item)
                  {
                     _loc1_ = GudetamaUtil.getItemName(result.item.kind,result.item.id#2);
                     ItemGetDialog.show(result,callback,StringUtil.format(GameSetting.getUIText("presentComment.msg"),_loc1_),GameSetting.getUIText("presentComment.title"));
                  }
                  else
                  {
                     callback();
                  }
               });
            });
         }
      }
      
      private function getRandomVoice(param1:TouchEventParam) : int
      {
         var _loc3_:* = 0;
         var _loc4_:* = null;
         var _loc2_:int = param1.voice;
         var _loc5_:int = GameSetting.getGudetama(UserDataWrapper.wrapper.getPlacedGudetamaId()).voiceType;
         if(param1.isPlayRamdomVoice() || _loc5_ != 0)
         {
            if(_loc5_ == 0)
            {
               _loc3_ = uint(getHours());
               switch(int(getTimeType(_loc3_)))
               {
                  case 0:
                     _loc5_ = 0;
                     break;
                  case 1:
                     _loc5_ = 0 + 1;
                     break;
                  case 2:
                     _loc5_ = 0 + 2;
               }
            }
            else
            {
               _loc5_ += 2;
            }
            _loc2_ = (_loc4_ = GameSetting.def.touch).randomVoiceIds[_loc5_][int(Math.random() * _loc4_.randomVoiceIds[_loc5_].length)];
         }
         return _loc2_;
      }
      
      private function processDropItem(param1:TouchEventParam) : void
      {
         var param:TouchEventParam = param1;
         if(!param.isDropItem())
         {
            return;
         }
         processAnime();
         TextureCollector.loadTextureRsrc(GudetamaUtil.getDropItemIconName(param),function(param1:Texture):void
         {
            var texture:Texture = param1;
            if(imgDrop == null || dropItemButton == null)
            {
               return;
            }
            imgDrop.texture = texture;
            dropItemButton.visible = true;
            TweenAnimator.startItself(imgDrop,!!param.isDropItem0() ? "drop1" : "drop2",false,function():void
            {
               dropItemButton.touchable = true;
            });
         });
         UserDataWrapper.wrapper.setDropItemEvent(param);
      }
      
      private function processAnime() : void
      {
         var gudetamaDef:GudetamaDef = GameSetting.getGudetama(UserDataWrapper.wrapper.getPlacedGudetamaId());
         if(!gudetamaDef.disabledSpine && (Math.random() > 0.5 || isTutorial()))
         {
            lockTouchEvent = true;
            gudetamaButton.startSwingAnime(3,function():void
            {
               lockTouchEvent = false;
            });
            return;
         }
         switch(int(gudetamaDef.dropAnime))
         {
            case 0:
               var tweenName:String = "item0";
               break;
            case 1:
               tweenName = "item1";
         }
         lockTouchEvent = true;
         gudetamaButton.startTween(tweenName,true,function(param1:DisplayObject):void
         {
            lockTouchEvent = false;
         });
      }
      
      private function processHeaven(param1:TouchEventParam) : void
      {
         var param:TouchEventParam = param1;
         if(!param.isHeaven())
         {
            return;
         }
         Engine.cancelTouches();
         lockTouchEvent = true;
         SoundManager.playEffect("egg_shake");
         heavenUI.prepare();
         gudetamaButton.startTween("fever",true,function(param1:DisplayObject):void
         {
            var dObj:DisplayObject = param1;
            gudetamaButton.startTween("shoot",true,function(param1:DisplayObject):void
            {
               SoundManager.playEffect("heaven_shine");
               if(isTutorial())
               {
                  resumeTutorial();
               }
            });
            heavenUI.generate(param.paramByte,function():void
            {
               lockTouchEvent = false;
            });
         });
         UserDataWrapper.wrapper.setHeavenEvent(param);
      }
      
      private function triggeredDropItemButton(param1:Event) : void
      {
         var event:Event = param1;
         var dropItemTouchParam:TouchEventParam = UserDataWrapper.wrapper.getDropItemEvent();
         SoundManager.playEffect("popup_open_item");
         dropItemButton.touchable = false;
         TweenAnimator.startItself(imgDrop,"acquire_start",false,function():void
         {
            addMoneyByIndex(dropItemTouchParam.getTouchIndex());
            TweenAnimator.startItself(imgDrop,"acquire_finish",false,function():void
            {
               dropItemButton.visible = false;
               UserDataWrapper.wrapper.removeDropItemEvent();
            });
         });
      }
      
      private function triggeredNoticeButtonCallback(param1:int) : void
      {
         var type:int = param1;
         homeScroller.scrollToPageIndex(0,-1,function():void
         {
            if(type == NoticeButtonUI.TYPE_COMPLETE)
            {
               showCompletedKitchenware();
            }
            else if(type == 2)
            {
               showEmptyKitchenware();
            }
         });
      }
      
      private function triggeredEventNoticeButtonCallback(param1:SystemMailData) : void
      {
         var mail:SystemMailData = param1;
         homeScroller.scrollToPageIndex(0,-1,function():void
         {
            DialogSystemMailChecker.processDialogMail(mail);
         });
      }
      
      private function triggeredInfoIconUICallback(param1:int) : void
      {
         showInfoListDialog(param1);
      }
      
      private function onTouchGudetamaQuad(param1:TouchEvent) : void
      {
         var _loc3_:* = null;
         var _loc2_:Touch = param1.getTouch(gudetamaQuad);
         if(_loc2_)
         {
            _loc3_ = StarlingUtil.getCoordLocal(dropItemButton,_loc2_.globalX,_loc2_.globalY);
            if(dropItemButton.hitTest(_loc3_))
            {
               if(!dropItemEvent)
               {
                  dropItemTouches = new Vector.<Touch>();
                  dropItemTouch = _loc2_.clone();
                  dropItemTouch.target = dropItemButton;
                  dropItemTouches.push(dropItemTouch);
                  dropItemEvent = new TouchEvent("touch",dropItemTouches);
               }
               dropItemTouch.globalX = _loc2_.globalX;
               dropItemTouch.globalY = _loc2_.globalY;
               dropItemTouch.phase = _loc2_.phase;
               dropItemTouch.tapCount = _loc2_.tapCount;
               dropItemTouch.timestamp = _loc2_.timestamp;
               dropItemTouch.pressure = _loc2_.pressure;
               dropItemTouch.width = _loc2_.width;
               dropItemTouch.height = _loc2_.height;
               dropItemTouch.cancelled = _loc2_.cancelled;
               dropItemButton.dispatchEvent(dropItemEvent);
            }
         }
         gudetamaButton.dispatchEvent(param1);
      }
      
      private function showCompletedKitchenware() : void
      {
         var type:int = UserDataWrapper.kitchenwarePart.getMinimumCompletedType();
         if(type < 0)
         {
            return;
         }
         Engine.lockTouchInput(showCookingScene);
         setupCookingScene(type,null,function():void
         {
            showCookingScene();
            Engine.unlockTouchInput(showCookingScene);
         });
      }
      
      private function showCookingKitchenware() : void
      {
         var type:int = UserDataWrapper.kitchenwarePart.getMinimumCookingType();
         if(type < 0)
         {
            return;
         }
         Engine.lockTouchInput(showCookingScene);
         setupCookingScene(type,null,function():void
         {
            showCookingScene();
            Engine.unlockTouchInput(showCookingScene);
         });
      }
      
      private function showEmptyKitchenware() : void
      {
         var type:int = UserDataWrapper.kitchenwarePart.getMinimumEmptyType();
         if(type < 0)
         {
            return;
         }
         Engine.lockTouchInput(showCookingScene);
         setupCookingScene(type,null,function():void
         {
            showCookingScene();
            Engine.unlockTouchInput(showCookingScene);
         });
      }
      
      private function updateKitchenware() : void
      {
         for each(var _loc1_ in kitchenwares)
         {
            _loc1_.setup();
         }
      }
      
      private function triggeredShopButton(param1:Event) : void
      {
         var event:Event = param1;
         shopButtonSE();
         ResidentMenuUI_Gudetama.getInstance().sendChangeState(62,function():void
         {
            if(Engine.getGuideTalkPanel())
            {
               Engine.switchScene(new ShopScene_Gudetama(),1,0.5,true);
            }
            else
            {
               Engine.switchScene(new ShopScene_Gudetama());
            }
         });
      }
      
      private function triggeredMenuButton(param1:Event) : void
      {
         MenuDialog.show();
      }
      
      private function triggeredGachaButton(param1:Event) : void
      {
         var event:Event = param1;
         gachaButtonSE();
         ResidentMenuUI_Gudetama.getInstance().sendChangeState(143,function():void
         {
            Engine.switchScene(new GachaScene_Gudetama());
         });
      }
      
      private function triggeredCollectionButton(param1:Event) : void
      {
         var event:Event = param1;
         collectionButtonSE();
         ResidentMenuUI_Gudetama.getInstance().sendChangeState(142,function():void
         {
            Engine.switchScene(new CollectionScene());
         });
      }
      
      private function triggeredCameraButton(param1:Event) : void
      {
         var event:Event = param1;
         GudetamaUtil.cameraButtonSE();
         if(UserDataWrapper.wrapper.isDoneNoticeFlag(14))
         {
            openArScene();
            return;
         }
         var msg:String = GameSetting.getUIText("%ar.confirm.dialog.msg") + "\n\n" + GameSetting.getUIText("%ar.confirm.dialog.info");
         MessageDialog.show(23,msg,function(param1:int):void
         {
            if(param1 == 1)
            {
               if(isTutorial())
               {
                  nextTutorial();
               }
            }
            else
            {
               openArScene();
            }
         });
      }
      
      private function openArScene() : void
      {
         Engine.lockTouchInput(this);
         PermissionRequestWrapper.requestAR(function(param1:int):void
         {
            var result:int = param1;
            if(result == 1)
            {
               ResidentMenuUI_Gudetama.getInstance().sendChangeState(149,function():void
               {
                  Engine.unlockTouchInput(this);
                  ARScene.show();
               });
            }
            else if(result == -3)
            {
               Engine.unlockTouchInput(this);
               var _loc2_:* = Engine;
               if(gudetama.engine.Engine.platform == 1)
               {
                  var msg:String = GameSetting.getUIText("%ar.permissionRequest.reject.camera.android");
                  var msg:String = msg + ("\n" + GameSetting.getUIText("%ar.permissionRequestForDenied.android"));
               }
               else
               {
                  msg = GameSetting.getUIText("%ar.permissionRequest.reject.camera");
                  msg += "\n" + GameSetting.getUIText("%ar.permissionRequestForDenied");
                  var _loc4_:* = Engine;
                  msg = StringUtil.format(msg,GameSetting.getUIText("%ar.permission.cameraRoll." + (!!gudetama.engine.Engine.isIosPlatform() ? "ios" : (!!gudetama.engine.Engine.isAndroidPlatform() ? "android" : "android"))));
               }
               PermissionRequestWrapper.showInductionAppConfigDialog(msg);
            }
            else
            {
               Engine.unlockTouchInput(this);
               var _loc5_:* = Engine;
               if(gudetama.engine.Engine.platform == 1)
               {
                  msg = GameSetting.getUIText("%ar.permissionRequest.reject.camera.android");
               }
               else
               {
                  msg = GameSetting.getUIText("%ar.permissionRequest.reject.camera");
                  var _loc6_:* = Engine;
                  msg = StringUtil.format(msg,GameSetting.getUIText("%ar.permission.cameraRoll." + (!!gudetama.engine.Engine.isIosPlatform() ? "ios" : (!!gudetama.engine.Engine.isAndroidPlatform() ? "android" : "android"))));
               }
               juggler.delayCall(function():void
               {
                  LocalMessageDialog.show(2,msg,null,GameSetting.getUIText("%ar.permissionRequest.title"));
               },0.2);
            }
         });
      }
      
      private function triggeredChallengeButton(param1:Event) : void
      {
         var event:Event = param1;
         challengeButtonSE();
         ResidentMenuUI_Gudetama.getInstance().sendChangeState(144,function():void
         {
            var _loc1_:Boolean = false;
            if(UserDataWrapper.wrapper.isCanStartNoticeFlag(9) || UserDataWrapper.wrapper.isCanStartNoticeFlag(10) || UserDataWrapper.wrapper.isCanStartNoticeFlag(21))
            {
               _loc1_ = true;
            }
            Engine.switchScene(new MissionScene(),1,0.5,_loc1_);
         });
      }
      
      private function triggeredDecorationButton(param1:Event) : void
      {
         var event:Event = param1;
         roomdecoButtonSE();
         ResidentMenuUI_Gudetama.getInstance().sendChangeState(146,function():void
         {
            Engine.switchScene(new DecorationScene());
         });
      }
      
      private function triggeredEventButton(param1:Event) : void
      {
         var _loc2_:Number = Math.random();
         if(_loc2_ > 0.5)
         {
            SoundManager.playEffect("put_egg");
         }
         else
         {
            SoundManager.playEffect("tap_nisetama");
         }
      }
      
      private function triggeredUsefulButton(param1:Event = null) : void
      {
         usefulButtonSE();
         if(GudetamaUtil.decorationEnbale())
         {
            UsefulAndDecorationListDialog.show(HomeScene);
         }
         else
         {
            UsefulListDialog.show(HomeScene);
         }
      }
      
      private function challengeButtonSE() : void
      {
         SoundManager.playEffect("voice_challenge_def");
      }
      
      private function collectionButtonSE() : void
      {
         var _loc1_:int = Math.random() * 3;
         switch(int(_loc1_))
         {
            case 0:
               SoundManager.playEffect("voice_collection1");
               break;
            case 1:
               SoundManager.playEffect("voice_collection2");
               break;
            case 2:
               SoundManager.playEffect("voice_collection_def");
         }
      }
      
      private function eventButtonSE() : void
      {
         var _loc1_:int = Math.random() * 2;
         switch(int(_loc1_))
         {
            case 0:
               SoundManager.playEffect("voice_event_def");
               break;
            case 1:
               SoundManager.playEffect("voice_event1");
         }
      }
      
      private function gachaButtonSE() : void
      {
         SoundManager.playEffect("voice_gacha2");
      }
      
      private function roomdecoButtonSE() : void
      {
         var _loc1_:int = Math.random() * 2;
         switch(int(_loc1_))
         {
            case 0:
               SoundManager.playEffect("voice_roomdeco");
               break;
            case 1:
               SoundManager.playEffect("voice_roomdeco_def");
         }
      }
      
      private function shopButtonSE() : void
      {
         var _loc1_:int = Math.random() * 3;
         switch(int(_loc1_))
         {
            case 0:
               SoundManager.playEffect("voice_shop1");
               break;
            case 1:
               SoundManager.playEffect("voice_shop2");
               break;
            case 2:
               SoundManager.playEffect("voice_shop_def");
         }
      }
      
      private function updateScene() : void
      {
         UserDataWrapper.wrapper.updateNumNewRecipe();
         updateKitchenware();
         if(GudetamaUtil.cupGachaEnable())
         {
            btnCupGacha.setup();
         }
         else
         {
            btnCupGacha.setVisible(false);
         }
         for each(noticeButtonUI in noticeButtonUIs)
         {
            noticeButtonUI.setup(UserDataWrapper.kitchenwarePart.getKitchenwareMap());
         }
         updateInfoButton();
         movieButton.update();
         carnaviUI.update();
         friendButton.setVisible(UserDataWrapper.featurePart.existsFeature(12));
         friendButton.update();
         usefulGroup.visible = UserDataWrapper.featurePart.existsFeature(9) || UserDataWrapper.featurePart.existsFeature(14);
         if(usefulGroup.visible)
         {
            if(GudetamaUtil.decorationEnbale())
            {
               TweenAnimator.startItself(usefulButton,"show");
            }
            else
            {
               TweenAnimator.startItself(usefulButton,"useful");
            }
         }
         gachaButton.visible = UserDataWrapper.featurePart.existsFeature(10);
         if(gachaButton.visible)
         {
            gachaFreePlayGroup.visible = enabledGachaFreePlay;
            if(enabledGachaFreePlay)
            {
               TweenAnimator.startItself(gachaFreePlayGroup,"show",true);
            }
            gachaPickupImage.visible = existsPickup;
            if(existsPickup)
            {
               TweenAnimator.startItself(gachaPickupImage,"show",true);
            }
         }
         collectionSprite.visible = UserDataWrapper.featurePart.existsFeature(0);
         challengeButton.visible = UserDataWrapper.featurePart.existsFeature(8);
         cameraButton.visible = UserDataWrapper.featurePart.existsFeature(1);
         if(UserDataWrapper.wrapper.isNoticeMonthlyBonus())
         {
            TweenAnimator.startItself(shopButton,"pack");
            TweenAnimator.finishItself(shopButton);
            TweenAnimator.startItself(shopButton,"show");
         }
         else
         {
            TweenAnimator.startItself(shopButton,"none");
            TweenAnimator.finishItself(shopButton);
         }
         var backgroundName:String = UserDataWrapper.eventPart.getBackgroundName();
         if(backgroundName)
         {
            TextureCollector.loadTextureRsrc(backgroundName,function(param1:Texture):void
            {
               mountainImage.texture = param1;
            });
         }
         else
         {
            TextureCollector.loadTextureRsrc("bg-mountain2",function(param1:Texture):void
            {
               mountainImage.texture = param1;
            });
         }
         eventButton.setup(null);
         eventNoticeButton.setupAndShow();
         infoIcon.setupAndShow();
         helperGroup.visible = canShowHelperChara();
         collectionBookinfoSprite.visible = false;
         if(UserDataWrapper.wrapper.isCanStartNoticeFlag(30))
         {
            TweenAnimator.startItself(collectionBookinfoSprite,"show");
            collectionBookinfoSprite.visible = true;
         }
      }
      
      public function canShowHelperChara() : Boolean
      {
         if(!UserDataWrapper.wrapper.isDoneNoticeFlag(3))
         {
            return false;
         }
         if(UserDataWrapper.wrapper.canUseHelperState())
         {
            return true;
         }
         return UserDataWrapper.abilityPart.existsKind(9);
      }
      
      public function updateInfoButton() : void
      {
         infoButton.update();
      }
      
      public function showInfoListDialog(param1:int = 0) : void
      {
         var noticeIconId:int = param1;
         InfoListDialog.show(function():void
         {
            AcquiredKitchenwareDialog.show(function():void
            {
               AcquiredRecipeNoteDialog.show(function():void
               {
                  checkNoticeTargetTutorial(7);
               });
            });
         },noticeIconId);
      }
      
      public function zoomToPosition(param1:Sprite, param2:Number, param3:Number, param4:Number, param5:Number = 1.0) : void
      {
         var _loc6_:Point = new Point(param2,param3);
         _loc6_ = param1.localToGlobal(_loc6_);
         homeScroller.zoom(param4,param5,_loc6_.x,_loc6_.y);
      }
      
      public function pushCupButtonMini(param1:int, param2:Number = -1, param3:Function = null) : void
      {
         homeScroller.scrollToPageIndex(param1,param2,param3);
      }
      
      public function setupCookingScene(param1:int, param2:Object, param3:Function) : void
      {
         var kitchenwareType:int = param1;
         var navigateParam:Object = param2;
         var callback:Function = param3;
         var queue:TaskQueue = new TaskQueue();
         queue.addTask(function():void
         {
            ResidentMenuUI_Gudetama.getInstance().sendChangeState(141,function():void
            {
               cookingScene.setupCookingScene(queue,kitchenwareType,navigateParam);
               queue.taskDone();
            },false);
         });
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            callback();
         });
         queue.startTask();
      }
      
      public function showCookingScene() : void
      {
         Engine.pushScene(cookingScene);
      }
      
      private function showCookingSceneCallback() : void
      {
         displaySprite.visible = false;
         gudetamaButton.finish();
         Engine.removeSpineCache("gudetama-" + UserDataWrapper.wrapper.getPlacedGudetamaId() + "-manually_spine");
         TextureCollector.clearAtName("gudetama-" + UserDataWrapper.wrapper.getPlacedGudetamaId() + "-image");
         roomImage.texture = null;
         TextureCollector.clearAtName("room-" + UserDataWrapper.decorationPart.getHomeDecorationId() + "-bg");
      }
      
      public function waitChangeGudetama(param1:int, param2:Function) : void
      {
         var gudeId:int = param1;
         var callback:Function = param2;
         var tmpQueue:TaskQueue = new TaskQueue();
         gudetamaButton.setup(tmpQueue,gudeId,true,function():void
         {
            checkHelperPosition();
         });
         tmpQueue.registerOnProgress(function(param1:Number):void
         {
            var ratio:Number = param1;
            if(ratio < 1)
            {
               return;
            }
            var gudeDef:GudetamaDef = GameSetting.getGudetama(gudeId);
            dishImage.visible = gudeDef.dish;
            var gudetamaRect:Rectangle = new Rectangle(gudetamaGroup.x - gudetamaGroup.pivotX - 0.5 * gudetamaButton.width - (gudetamaButton.pivotX - 0.5 * gudetamaButton.width),gudetamaGroup.y - gudetamaGroup.pivotY - 0.5 * gudetamaButton.height - (gudetamaButton.pivotY - 0.5 * gudetamaButton.height),gudetamaButton.width,gudetamaButton.height);
            serifUI.setup(gudetamaRect);
            var innerQueue:TaskQueue = new TaskQueue();
            touchTextGroup.setup(innerQueue,gudeDef.id#2,touchTextItemExtractor,gudetamaRect);
            innerQueue.registerOnProgress(function(param1:Number):void
            {
               if(param1 < 1)
               {
                  return;
               }
               if(callback)
               {
                  callback();
               }
            });
            innerQueue.startTask();
            checkHelperPosition();
         });
         tmpQueue.startTask();
      }
      
      private function backFromCookingSceneCallback() : void
      {
         displaySprite.visible = true;
         Engine.broadcastEventToSceneStackWith("update_scene");
         Engine.showLoading(backFromCookingSceneCallback);
         var queue:TaskQueue = new TaskQueue();
         var gudetamaDef:GudetamaDef = GameSetting.getGudetama(UserDataWrapper.wrapper.getPlacedGudetamaId());
         gudetamaButton.setup(queue,gudetamaDef.id#2,true,function():void
         {
            checkHelperPosition();
         });
         setRoomTexture(queue,true);
         if(hideGude == null || hideGude.isLost())
         {
            createHideGude(queue);
            if(hideGude != null)
            {
               appearHideGudeCookingBack = true;
            }
         }
         queue.registerOnProgress(function(param1:Number):void
         {
            var ratio:Number = param1;
            if(ratio < 1)
            {
               return;
            }
            dishImage.visible = gudetamaDef.dish;
            var gudetamaRect:Rectangle = new Rectangle(gudetamaGroup.x - gudetamaGroup.pivotX - 0.5 * gudetamaButton.width - (gudetamaButton.pivotX - 0.5 * gudetamaButton.width),gudetamaGroup.y - gudetamaGroup.pivotY - 0.5 * gudetamaButton.height - (gudetamaButton.pivotY - 0.5 * gudetamaButton.height),gudetamaButton.width,gudetamaButton.height);
            serifUI.setup(gudetamaRect);
            var innerQueue:TaskQueue = new TaskQueue();
            touchTextGroup.setup(innerQueue,gudetamaDef.id#2,touchTextItemExtractor,gudetamaRect);
            innerQueue.registerOnProgress(function(param1:Number):void
            {
               if(param1 < 1)
               {
                  return;
               }
               Engine.hideLoading(backFromCookingSceneCallback);
               processZoomOut();
            });
            innerQueue.startTask();
         });
         queue.startTask();
      }
      
      private function processZoomOut() : void
      {
         cookingScene.fadeOut();
         Engine.lockTouchInput(backFromCookingSceneCallback);
         var _loc1_:* = Engine;
         var _loc2_:* = Engine;
         homeScroller.zoom(1,0.5,0.5 * gudetama.engine.Engine.designWidth,0.5 * gudetama.engine.Engine.designHeight,function():void
         {
            Engine.unlockTouchInput(backFromCookingSceneCallback);
            if(checkNoticeTutorial())
            {
               return;
            }
            checkVariousDialog(true);
         });
      }
      
      public function procHideGudetamaShare(param1:String, param2:Function) : void
      {
         var _loc11_:Number = 640;
         var _loc8_:Number = 1136;
         var _loc14_:* = Starling;
         var _loc10_:Starling = starling.core.Starling.sCurrent;
         var _loc15_:* = Starling;
         var _loc6_:Painter = !!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._painter : null;
         var _loc4_:Rectangle;
         var _loc3_:Number = (_loc4_ = _loc10_.viewPort).width;
         var _loc9_:Number = _loc4_.height;
         var _loc12_:BitmapData = new BitmapData(_loc3_,_loc9_,true,0);
         var _loc13_:Rectangle;
         (_loc13_ = StarlingUtil.getRectangleFromPool()).setTo(0,0,_loc3_,_loc9_);
         var _loc7_:BitmapData = new BitmapData(_loc11_,_loc8_,false,0);
         var _loc5_:Point;
         (_loc5_ = StarlingUtil.getPointFromPool()).setTo(0,0);
         _loc6_.clear();
         _loc6_.pushState();
         _loc6_.state.renderTarget = null;
         _loc6_.state.setModelviewMatricesToIdentity();
         _loc6_.setStateTo(displaySprite.transformationMatrix);
         _loc6_.state.setProjectionMatrix(0,0,_loc3_,_loc9_,_loc3_,_loc9_,stage.cameraPosition);
         displaySprite.render(_loc6_);
         _loc6_.finishMeshBatch();
         _loc6_.context.drawToBitmapData(_loc12_);
         _loc6_.popState();
         _loc7_.copyPixels(_loc12_,_loc13_,_loc5_);
         _loc12_.dispose();
         _loc12_ = null;
         SnsShareDialog.show(_loc7_,2,false,param2,param1);
      }
      
      private function triggeredDebug() : void
      {
      }
      
      override protected function removedPushedSceneFromContainer(param1:Event) : void
      {
         super.removedPushedSceneFromContainer(param1);
         homeScroller.throwHorizontally();
      }
      
      override public function dispose() : void
      {
         removeEventListener("refreshed_scene_container",refreshedSceneContainer);
         removeEventListener("update_scene",updateScene);
         if(homeScroller)
         {
            homeScroller.dispose();
            homeScroller = null;
         }
         weatherSpineModel = null;
         mountainImage = null;
         roomImage = null;
         dishImage = null;
         gudetamaGroup = null;
         if(gudetamaButton)
         {
            gudetamaButton.dispose();
            gudetamaButton = null;
         }
         if(dropItemButton)
         {
            dropItemButton.removeEventListener("triggered",triggeredDropItemButton);
            dropItemButton = null;
         }
         imgDrop = null;
         if(infoButton)
         {
            infoButton.dispose();
            infoButton = null;
         }
         if(infoIcon)
         {
            infoIcon.dispose();
            infoIcon = null;
         }
         if(shopButton)
         {
            shopButton.removeEventListener("triggered",triggeredShopButton);
            shopButton = null;
         }
         if(menuButton)
         {
            menuButton.removeEventListener("triggered",triggeredMenuButton);
            menuButton = null;
         }
         if(gachaButton)
         {
            gachaButton.removeEventListener("triggered",triggeredGachaButton);
            gachaButton = null;
         }
         gachaFreePlayGroup = null;
         if(collectionButton)
         {
            collectionButton.removeEventListener("triggered",triggeredCollectionButton);
            collectionButton = null;
         }
         if(collectionBookinfoSprite)
         {
            collectionBookinfoSprite = null;
         }
         if(collectionSprite)
         {
            collectionSprite = null;
         }
         if(friendButton)
         {
            friendButton.dispose();
            friendButton = null;
         }
         for each(var _loc1_ in kitchenwares)
         {
            _loc1_.dispose();
         }
         kitchenwares.length = 0;
         _loc1_ = null;
         if(btnCupGacha)
         {
            btnCupGacha.dispose();
            btnCupGacha = null;
         }
         if(cookingScene)
         {
            cookingScene.dispose();
            cookingScene = null;
         }
         if(challengeButton)
         {
            challengeButton.removeEventListener("triggered",triggeredChallengeButton);
            challengeButton = null;
         }
         if(bombEffectImage)
         {
            bombEffectImage.dispose();
            bombEffectImage = null;
         }
         if(movieButton)
         {
            movieButton.dispose();
            movieButton = null;
         }
         if(profileButton)
         {
            profileButton.dispose();
            profileButton = null;
         }
         if(delusionButton)
         {
            delusionButton.dispose();
            delusionButton = null;
         }
         usefulGroup = null;
         if(usefulButton)
         {
            usefulButton.removeEventListener("triggered",triggeredUsefulButton);
            usefulButton = null;
         }
         if(heavenUI)
         {
            heavenUI.dispose();
            heavenUI = null;
         }
         if(serifUI)
         {
            serifUI.dispose();
            serifUI = null;
         }
         if(touchTextGroup)
         {
            touchTextGroup.dispose();
            touchTextGroup = null;
         }
         hideGudetamaGroup = null;
         if(eventButton)
         {
            eventButton.dispose();
            eventButton = null;
         }
         if(eventNoticeButton)
         {
            eventNoticeButton.dispose();
            eventNoticeButton = null;
         }
         if(carnaviUI)
         {
            carnaviUI.dispose();
            carnaviUI = null;
         }
         if(bombEffectImage)
         {
            bombEffectImage.dispose();
            bombEffectImage = null;
         }
         if(messageUI)
         {
            messageUI.dispose();
            messageUI = null;
         }
         if(gudetamaQuad)
         {
            gudetamaQuad.removeEventListener("touch",onTouchGudetamaQuad);
            gudetamaQuad = null;
         }
         if(firstGudetamaTouchBG)
         {
            firstGudetamaTouchBG = null;
         }
         heavenItemExtractor = null;
         touchTextItemExtractor = null;
         questionData = null;
         if(bgQuad)
         {
            bgQuad.dispose();
            bgQuad = null;
         }
         if(bgMountain)
         {
            bgMountain.dispose();
            bgMountain = null;
         }
         if(hideGude != null)
         {
            hideGude = null;
         }
         super.dispose();
      }
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.UserDataWrapper;
import gudetama.engine.Engine;
import gudetama.scene.friend.FriendScene_Gudetama;
import gudetama.ui.ResidentMenuUI_Gudetama;
import gudetama.ui.UIBase;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Sprite;
import starling.events.Event;

class FriendButtonUI extends UIBase
{
    
   
   private var noticeGroup:Sprite;
   
   private var numText:ColorTextField;
   
   function FriendButtonUI(param1:Sprite)
   {
      super(param1);
      ContainerButton(param1).setStopPropagation(true);
      param1.addEventListener("triggered",triggeredButton);
      noticeGroup = param1.getChildByName("noticeGroup") as Sprite;
      numText = noticeGroup.getChildByName("num") as ColorTextField;
   }
   
   public function update() : void
   {
      var _loc2_:int = UserDataWrapper.friendPart.getNumNewFriend();
      var _loc1_:int = UserDataWrapper.friendPart.getNumFollowers();
      var _loc3_:int = _loc2_ + _loc1_;
      noticeGroup.visible = _loc3_ > 0;
      numText.text#2 = _loc3_.toString();
   }
   
   public function set touchable(param1:Boolean) : void
   {
      displaySprite.touchable = param1;
   }
   
   private function triggeredButton(param1:Event) : void
   {
      var event:Event = param1;
      GudetamaUtil.playFriendSE();
      ResidentMenuUI_Gudetama.getInstance().sendChangeState(63,function():void
      {
         if(UserDataWrapper.wrapper.isCanStartNoticeFlag(5))
         {
            Engine.switchScene(new FriendScene_Gudetama(),1,0.5,true);
         }
         else
         {
            Engine.switchScene(new FriendScene_Gudetama());
         }
      });
   }
   
   public function dispose() : void
   {
      displaySprite.removeEventListener("triggered",triggeredButton);
      noticeGroup = null;
      numText = null;
   }
}

import gudetama.data.UserDataWrapper;
import gudetama.engine.Engine;
import gudetama.engine.TextureCollector;
import gudetama.engine.TweenAnimator;
import gudetama.ui.UIBase;
import muku.core.TaskQueue;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class InfoIconUI extends UIBase
{
   
   private static const INTERVAL:int = 5000;
    
   
   private var nextTime:uint = 0;
   
   private var callback:Function;
   
   private var sprite:Sprite;
   
   private var icons:Vector.<Image>;
   
   private var mailNoticeIconIds:Array;
   
   private var textureMap:Object;
   
   private var index:int;
   
   private var currentIconId:int;
   
   public var invisible:Boolean;
   
   function InfoIconUI(param1:Sprite, param2:Function)
   {
      var _loc4_:int = 0;
      var _loc3_:* = null;
      icons = new Vector.<Image>();
      textureMap = {};
      super(param1);
      param1.addEventListener("triggered",triggeredButton);
      this.callback = param2;
      sprite = param1.getChildByName("sprite") as Sprite;
      _loc4_ = 0;
      while(_loc4_ < sprite.numChildren)
      {
         _loc3_ = sprite.getChildByName("icon" + _loc4_) as Image;
         if(_loc3_)
         {
            icons.push(_loc3_);
         }
         _loc4_++;
      }
   }
   
   public function setupAndShow() : void
   {
      if(!UserDataWrapper.wrapper.isUpdatedMailNoticeIconIds())
      {
         return;
      }
      UserDataWrapper.wrapper.resetMailNoticeIconIdsUpdatedFlag();
      var queue:TaskQueue = new TaskQueue();
      setup(queue);
      queue.registerOnProgress(function(param1:Number):void
      {
         if(param1 < 1)
         {
            return;
         }
         show();
      });
      queue.startTask();
   }
   
   private function setup(param1:TaskQueue) : void
   {
      mailNoticeIconIds = UserDataWrapper.wrapper.getMailNoticeIconIds();
      for each(var _loc2_ in mailNoticeIconIds)
      {
         loadIconTexture(param1,_loc2_);
      }
      setVisible(false);
   }
   
   private function loadIconTexture(param1:TaskQueue, param2:int) : void
   {
      var queue:TaskQueue = param1;
      var id:int = param2;
      queue.addTask(function():void
      {
         TextureCollector.loadTexture("mail-notice_" + id,function(param1:Texture):void
         {
            textureMap[id] = param1;
            queue.taskDone();
         });
      });
   }
   
   public function show() : void
   {
      if(mailNoticeIconIds.length <= 0)
      {
         return;
      }
      index = 0;
      setVisible(!invisible);
      TweenAnimator.startItself(sprite,"show",true);
      currentIconId = mailNoticeIconIds[index % mailNoticeIconIds.length];
      icons[0].texture = textureMap[currentIconId];
      icons[1].visible = mailNoticeIconIds.length > 1;
      next();
   }
   
   private function next() : void
   {
      if(!mailNoticeIconIds || mailNoticeIconIds.length <= 1)
      {
         return;
      }
      index++;
      var _currentIconId:int = mailNoticeIconIds[index % mailNoticeIconIds.length];
      var preIndex:int = index - 1;
      if(preIndex >= 0)
      {
         TweenAnimator.startItself(icons[preIndex % icons.length],"fadeOut");
      }
      icons[index % icons.length].texture = textureMap[_currentIconId];
      TweenAnimator.startItself(icons[index % icons.length],"fadeIn",false,function():void
      {
         currentIconId = _currentIconId;
      });
      nextTime = Engine.now + 5000;
   }
   
   public function advanceTime(param1:Number) : void
   {
      if(Engine.now < nextTime)
      {
         return;
      }
      next();
   }
   
   private function triggeredButton(param1:Event) : void
   {
      if(!mailNoticeIconIds || mailNoticeIconIds.length <= 0)
      {
         return;
      }
      callback(currentIconId);
   }
   
   public function dispose() : void
   {
      displaySprite.removeEventListener("triggered",triggeredButton);
      sprite = null;
      if(icons)
      {
         icons.length = 0;
         icons = null;
      }
      if(textureMap)
      {
         for(var _loc1_ in textureMap)
         {
            delete textureMap[_loc1_];
         }
         textureMap = null;
      }
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.KitchenwareData;
import gudetama.data.compati.KitchenwareDef;
import gudetama.engine.BaseScene;
import gudetama.engine.Engine;
import gudetama.engine.TextureCollector;
import gudetama.engine.TweenAnimator;
import gudetama.scene.home.HomeScene;
import gudetama.ui.LocalMessageDialog;
import gudetama.ui.UIBase;
import muku.display.ContainerButton;
import muku.display.SimpleImageButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class KitchenwareButton extends UIBase
{
    
   
   private var scene:HomeScene;
   
   private var type:int;
   
   private var button:ContainerButton;
   
   private var image:Image;
   
   private var lockButton:SimpleImageButton;
   
   private var stateSprite:Sprite;
   
   private var newSprite:Sprite;
   
   private var timeText:ColorTextField;
   
   private var lastHour:int = -1;
   
   private var lastMinute:int = -1;
   
   private var lastSecond:int = -1;
   
   private var state:int = -1;
   
   function KitchenwareButton(param1:Sprite, param2:BaseScene, param3:int)
   {
      super(param1);
      this.scene = HomeScene(param2);
      this.type = param3;
      button = param1.getChildByName("button") as ContainerButton;
      button.setStopPropagation(true);
      button.addEventListener("triggered",triggered);
      image = button.getChildByName("image") as Image;
      lockButton = param1.getChildByName("lockButton") as SimpleImageButton;
      lockButton.addEventListener("triggered",triggeredLockButton);
      lockButton.visible = false;
      stateSprite = param1.getChildByName("stateSprite") as Sprite;
      newSprite = stateSprite.getChildByName("newSprite") as Sprite;
      newSprite.visible = false;
      var _loc4_:Sprite;
      timeText = (_loc4_ = stateSprite.getChildByName("making") as Sprite).getChildByName("time") as ColorTextField;
   }
   
   public function setup() : void
   {
      var isAvailable:Boolean = false;
      var kwData:KitchenwareData = UserDataWrapper.kitchenwarePart.getKitchenwareByType(type);
      if(kwData != null)
      {
         isAvailable = UserDataWrapper.kitchenwarePart.isAvailableByKitchenware(kwData,0,!kwData.isCooking());
      }
      var hasKitchenware:Boolean = UserDataWrapper.kitchenwarePart.hasKitchenwareByType(type,true);
      if(isAvailable)
      {
         stateSprite.visible = true;
         button.visible = true;
         var kitchenwareId:int = UserDataWrapper.kitchenwarePart.getHighestGradeKitchenwareIdByKitchenware(kwData);
         TextureCollector.loadTexture("kitchen0@image" + kitchenwareId,function(param1:Texture):void
         {
            image.texture = param1;
         });
         lockButton.visible = false;
         if(UserDataWrapper.kitchenwarePart.finishedCookingByKitchenware(kwData))
         {
            if(state != 2)
            {
               TweenAnimator.startItself(stateSprite,"state2");
               TweenAnimator.finishItself(stateSprite);
            }
            state = 2;
            newSprite.visible = false;
         }
         else if(UserDataWrapper.kitchenwarePart.isCookingByKitchenware(kwData))
         {
            if(state != 1)
            {
               TweenAnimator.startItself(stateSprite,"state1");
               TweenAnimator.finishItself(stateSprite);
            }
            state = 1;
            newSprite.visible = false;
         }
         else
         {
            if(state != 0)
            {
               TweenAnimator.startItself(stateSprite,"state0");
               TweenAnimator.finishItself(stateSprite);
            }
            state = 0;
            newSprite.visible = UserDataWrapper.wrapper.getNewRecipeCount(type) > 0;
         }
         TweenAnimator.startItself(stateSprite,"show");
         advanceTime();
      }
      else if(!isAvailable && hasKitchenware)
      {
         stateSprite.visible = false;
         button.visible = false;
         lockButton.visible = true;
      }
      else
      {
         stateSprite.visible = false;
         button.visible = false;
         lockButton.visible = false;
      }
   }
   
   public function setEnable() : void
   {
      setTouchable(false);
      button.visible = false;
      lockButton.visible = false;
      stateSprite.visible = false;
   }
   
   public function advanceTime(param1:Number = 0) : void
   {
      if(state == 1)
      {
         update();
         if(UserDataWrapper.kitchenwarePart.finishedCooking(type))
         {
            setup();
         }
      }
   }
   
   private function update() : void
   {
      var _loc2_:int = Math.max(0,UserDataWrapper.kitchenwarePart.getRestCookingTime(type));
      var _loc1_:int = _loc2_ / 3600;
      var _loc3_:int = (_loc2_ - _loc1_ * 60 * 60) / 60;
      var _loc4_:int = _loc2_ - _loc1_ * 60 * 60 - _loc3_ * 60;
      if(_loc1_ == lastHour && _loc3_ == lastMinute && _loc4_ == lastSecond)
      {
         return;
      }
      timeText.text#2 = GudetamaUtil.getRestTimeString(_loc1_,_loc3_,_loc4_);
      lastHour = _loc1_;
      lastMinute = _loc3_;
      lastSecond = _loc4_;
   }
   
   public function triggered(param1:Event, param2:Object = null) : void
   {
      var event:Event = param1;
      var navigateParam:Object = param2;
      if(!UserDataWrapper.wrapper.isCompletedTutorial())
      {
         Engine.resumeGuideTalk();
      }
      Engine.lockTouchInput(scene.showCookingScene);
      scene.setupCookingScene(type,navigateParam,function():void
      {
         scene.zoomToPosition(getDisplaySprite(),button.x + 0.5 * button.width,button.y + 0.5 * button.height,2,0.5);
         scene.showCookingScene();
         Engine.unlockTouchInput(scene.showCookingScene);
      });
   }
   
   private function triggeredLockButton(param1:Event) : void
   {
      var _loc2_:KitchenwareDef = GameSetting.getKitchenwareByType(type,0);
      LocalMessageDialog.show(0,_loc2_.conditionDesc);
   }
   
   public function dispose() : void
   {
      button.removeEventListener("triggered",triggered);
      button = null;
      image = null;
      lockButton.removeEventListener("triggered",triggeredLockButton);
      lockButton = null;
      stateSprite = null;
      timeText = null;
   }
}

import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.engine.Engine;
import gudetama.engine.Logger;
import gudetama.net.HttpConnector;
import gudetama.net.PacketUtil;
import gudetama.scene.home.HomeScene;
import gudetama.ui.AcquiredItemDialog;
import gudetama.ui.ResidentMenuUI_Gudetama;
import gudetama.ui.UIBase;
import gudetama.ui.VideoAdConfirmDialog;
import gudetama.ui.VideoAdWaitingDialog;
import gudetama.util.StringUtil;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Sprite;
import starling.events.Event;

class MovieButton extends UIBase
{
    
   
   private var button:ContainerButton;
   
   private var balloonGroup:Sprite;
   
   private var numText:ColorTextField;
   
   function MovieButton(param1:Sprite)
   {
      super(param1);
      button = param1.getChildByName("button") as ContainerButton;
      button.setStopPropagation(true);
      button.addEventListener("triggered",triggered);
      balloonGroup = param1.getChildByName("balloonGroup") as Sprite;
      numText = balloonGroup.getChildByName("num") as ColorTextField;
   }
   
   private function triggered(param1:Event = null) : void
   {
      var event:Event = param1;
      if(UserDataWrapper.videoAdPart.needsUpdate())
      {
         Engine.showLoading(HomeScene);
         var _loc2_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(GENERAL_EXTRA),function(param1:Array):void
         {
            Engine.hideLoading(HomeScene);
            showVideoAdConfirmOrWaitingDialog();
         });
      }
      else
      {
         showVideoAdConfirmOrWaitingDialog();
      }
   }
   
   private function showVideoAdConfirmOrWaitingDialog() : void
   {
      if(!UserDataWrapper.videoAdPart.isAcquirable())
      {
         VideoAdWaitingDialog.show();
      }
      else
      {
         showVideoAdConfirmDialog();
      }
   }
   
   private function showVideoAdConfirmDialog() : void
   {
      if(!UserDataWrapper.videoAdPart.isLast())
      {
         var message:String = GameSetting.getUIText("videoAdConfirm.carnavi.desc");
      }
      else
      {
         message = GameSetting.getUIText("videoAdConfirm.carnavi.last.desc");
      }
      if(UserDataWrapper.videoAdPart.needsUpdate())
      {
         Engine.showLoading(HomeScene);
         var _loc2_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(GENERAL_EXTRA),function(param1:Array):void
         {
            Engine.hideLoading(HomeScene);
            VideoAdConfirmDialog.show("start1",GameSetting.getUIText("videoAdConfirm.title"),message,GameSetting.getUIText("videoAdConfirm.carnavi.caution"),videoAdRewardCallback,UserDataWrapper.videoAdPart.getRestNum());
         });
      }
      else
      {
         VideoAdConfirmDialog.show("start1",GameSetting.getUIText("videoAdConfirm.title"),message,GameSetting.getUIText("videoAdConfirm.carnavi.caution"),videoAdRewardCallback,UserDataWrapper.videoAdPart.getRestNum());
      }
   }
   
   private function videoAdRewardCallback(param1:int) : void
   {
      var choose:int = param1;
      if(choose == 1)
      {
         return;
      }
      Engine.showLoading(HomeScene);
      var _loc2_:* = HttpConnector;
      if(gudetama.net.HttpConnector.mainConnector == null)
      {
         gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
      }
      gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(HOME_VIDEO_AD_REWARD),function(param1:Array):void
      {
         var response:Array = param1;
         try
         {
            Engine.hideLoading(HomeScene);
            var items:Array = response[0];
            var params:Array = response[1];
            var numAcquiredVideoAdReward:int = response[2][0];
            var restTimeSecs:int = response[2][1];
            UserDataWrapper.wrapper.addItems(items,params);
            UserDataWrapper.videoAdPart.updateNumAcquiredReward(numAcquiredVideoAdReward);
            UserDataWrapper.videoAdPart.updateRestTimeSecs(restTimeSecs);
            Engine.broadcastEventToSceneStackWith("update_scene");
            AcquiredItemDialog.show(items,params,function():void
            {
               ResidentMenuUI_Gudetama.getInstance().updateUserInfo();
               triggered();
            });
         }
         catch(e:Error)
         {
            Logger.warn("MovieButton.videoAdRewardCallback response:" + response + " videoAdPart:" + UserDataWrapper.videoAdPart + " trace:" + e.getStackTrace());
         }
      });
   }
   
   public function update() : void
   {
      var _loc1_:int = UserDataWrapper.videoAdPart.getRestNum();
      if(_loc1_ > 0)
      {
         balloonGroup.visible = true;
         numText.text#2 = StringUtil.format(GameSetting.getUIText("home.movieButton.num"),_loc1_);
      }
      else
      {
         balloonGroup.visible = false;
      }
   }
   
   public function dispose() : void
   {
      button.removeEventListener("triggered",triggered);
      button = null;
      balloonGroup = null;
      numText = null;
   }
}

import gudetama.data.UserDataWrapper;
import gudetama.ui.UIBase;
import muku.text.ColorTextField;
import starling.display.Sprite;
import starling.events.Event;

class NoticeButtonUI extends UIBase
{
   
   public static const TYPE_COMPLETE:int = 0;
   
   public static const TYPE_EMPTY:int = 2;
    
   
   private var type:int;
   
   private var callback:Function;
   
   private var numText:ColorTextField;
   
   private var currentNum:int = -1;
   
   private var visible:Boolean = true;
   
   function NoticeButtonUI(param1:Sprite, param2:int, param3:Function)
   {
      super(param1);
      this.type = param2;
      this.callback = param3;
      param1.addEventListener("triggered",triggeredButton);
      numText = param1.getChildByName("num") as ColorTextField;
   }
   
   public function setup(param1:Object) : void
   {
      var _loc2_:int = 0;
      if(type == 0)
      {
         _loc2_ = UserDataWrapper.kitchenwarePart.getNumCompleted(param1);
      }
      else
      {
         _loc2_ = UserDataWrapper.kitchenwarePart.getNumEmpty(param1);
      }
      _setup(_loc2_);
   }
   
   private function _setup(param1:int) : void
   {
      if(currentNum == param1)
      {
         return;
      }
      numText.text#2 = param1.toString();
      setVisible(param1 > 0);
      currentNum = param1;
      startTween("show");
   }
   
   public function set touchable(param1:Boolean) : void
   {
      displaySprite.touchable = param1;
   }
   
   override public function setVisible(param1:Boolean) : void
   {
      visible = param1;
      alpha = displaySprite.alpha;
   }
   
   public function set alpha(param1:Number) : void
   {
      setAlpha(param1);
      displaySprite.visible = visible && param1 > 0;
   }
   
   private function triggeredButton(param1:Event) : void
   {
      callback(type);
   }
   
   public function dispose() : void
   {
      callback = null;
      displaySprite.removeEventListener("triggered",triggeredButton);
      displaySprite = null;
      numText = null;
   }
}

import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.engine.Engine;
import gudetama.engine.SoundManager;
import gudetama.engine.TweenAnimator;
import gudetama.net.HttpConnector;
import gudetama.net.PacketUtil;
import gudetama.scene.home.HomeScene;
import gudetama.ui.ResidentMenuUI_Gudetama;
import gudetama.ui.UIBase;
import gudetama.util.SpriteExtractor;
import gudetama.util.StringUtil;
import gudetama.util.TimeZoneUtil;
import muku.display.ContainerButton;
import muku.display.SpineModel;
import muku.text.ColorTextField;
import spine.Bone;
import starling.display.Sprite;
import starling.events.Event;

class DelusionButton extends UIBase
{
   
   private static const UPDATE_INTERVAL:int = 1000;
    
   
   private var delusionRestTimes:Array;
   
   private var delusionStartTimeSecs:int;
   
   private var delusionSpineModel:SpineModel;
   
   private var delusionText:ColorTextField;
   
   private var delusionGroup:Sprite;
   
   private var cacheManager:DelusionItemCacheManager;
   
   private var delusionBone:Bone;
   
   private var lastCount:int = 0;
   
   private var nextUpdateTime:int;
   
   private var lockedUpdateFrame:Boolean;
   
   private var lockedTouch:Boolean;
   
   function DelusionButton(param1:ContainerButton)
   {
      super(param1);
      param1.setStopPropagation(true);
      param1.addEventListener("triggered",triggeredButton);
      delusionSpineModel = param1.getChildByName("spineModel") as SpineModel;
      delusionText = param1.getChildByName("delusion") as ColorTextField;
      delusionGroup = param1.getChildByName("delusionGroup") as Sprite;
   }
   
   public function init(param1:SpriteExtractor) : void
   {
      cacheManager = new DelusionItemCacheManager(param1,delusionGroup);
   }
   
   public function setup(param1:Array) : void
   {
      this.delusionRestTimes = param1;
      delusionStartTimeSecs = TimeZoneUtil.epochMillisToOffsetSecs();
      lastCount = 0;
      displaySprite.touchable = false;
      update();
   }
   
   private function getCount() : int
   {
      var _loc3_:int = 0;
      var _loc1_:int = TimeZoneUtil.epochMillisToOffsetSecs() - delusionStartTimeSecs;
      var _loc2_:int = 0;
      if(!delusionRestTimes)
      {
         return 0;
      }
      _loc3_ = 0;
      while(_loc3_ < delusionRestTimes.length)
      {
         var _loc4_:* = _loc3_;
         var _loc5_:* = delusionRestTimes[_loc4_] - _loc1_;
         delusionRestTimes[_loc4_] = _loc5_;
         if(delusionRestTimes[_loc3_] < 0)
         {
            _loc2_++;
         }
         _loc3_++;
      }
      delusionStartTimeSecs = TimeZoneUtil.epochMillisToOffsetSecs();
      return _loc2_;
   }
   
   public function advanceTime(param1:Number) : void
   {
      var _loc2_:int = 0;
      if(!UserDataWrapper.wrapper.isCompletedTutorial())
      {
         return;
      }
      if(!lockedUpdateFrame && Engine.now >= nextUpdateTime)
      {
         _loc2_ = getCount();
         if(_loc2_ != lastCount)
         {
            update(_loc2_);
         }
         nextUpdateTime = Engine.now + 1000;
      }
      if(isVisible())
      {
         if(!delusionBone)
         {
            delusionBone = delusionSpineModel.getBoneAtName("number");
         }
         if(delusionBone)
         {
            delusionText.x = delusionSpineModel.x + delusionBone.worldX;
            delusionText.y = delusionSpineModel.y + delusionBone.worldY;
            delusionText.scaleX = delusionBone.worldScaleX;
            delusionText.scaleY = delusionBone.worldScaleY;
         }
      }
   }
   
   private function update(param1:int = 0, param2:Function = null) : void
   {
      var count:int = param1;
      var callback:Function = param2;
      if(!delusionText)
      {
         return;
      }
      var _lastCount:int = lastCount;
      lastCount = count;
      if(_lastCount == 0 && count > 0)
      {
         setVisible(true);
         SoundManager.playEffect("Tap_Balloon");
         delusionText.text#2 = StringUtil.format(GameSetting.getUIText("mult.mark"),count);
         delusionSpineModel.show();
         delusionSpineModel.changeAnimation("start",false,function():void
         {
            delusionSpineModel.changeAnimation("loop");
            displaySprite.touchable = !lockedTouch;
            if(callback)
            {
               callback();
            }
         });
         TweenAnimator.startItself(delusionText,"show");
      }
      else if(count == 0 && _lastCount > 0)
      {
         delusionText.text#2 = StringUtil.format(GameSetting.getUIText("mult.mark"),count);
         delusionSpineModel.changeAnimation("finish",false,function():void
         {
            delusionSpineModel.hide();
            setVisible(false);
            if(callback)
            {
               callback();
            }
         });
         TweenAnimator.startItself(delusionText,"hide");
         displaySprite.touchable = false;
      }
      else if(count == 0 && _lastCount == 0)
      {
         setVisible(false);
         if(callback)
         {
            callback();
         }
      }
      else
      {
         delusionText.text#2 = StringUtil.format(GameSetting.getUIText("mult.mark"),count);
         if(callback)
         {
            callback();
         }
      }
   }
   
   private function triggeredButton(param1:Event) : void
   {
      var event:Event = param1;
      Engine.showLoading(HomeScene);
      var _loc2_:* = HttpConnector;
      if(gudetama.net.HttpConnector.mainConnector == null)
      {
         gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
      }
      gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(HOME_DELUSION),function(param1:Array):void
      {
         var response:Array = param1;
         Engine.hideLoading(HomeScene);
         var rewards:Array = response[0];
         delusionRestTimes = response[1];
         delusionStartTimeSecs = TimeZoneUtil.epochMillisToOffsetSecs();
         lockedUpdateFrame = true;
         lockedTouch = true;
         displaySprite.touchable = !lockedTouch;
         update(rewards.length);
         var i:int = rewards.length - 1;
         while(i >= 0)
         {
            UserDataWrapper.wrapper.addFreeMoney(rewards[i]);
            ResidentMenuUI_Gudetama.getInstance()._addMoneyActual(rewards[i]);
            i--;
         }
         addReward(rewards.length - 1,rewards,function():void
         {
            lockedUpdateFrame = false;
            lockedTouch = false;
         });
      });
   }
   
   private function addReward(param1:int, param2:Array, param3:Function) : void
   {
      var index:int = param1;
      var rewards:Array = param2;
      var callback:Function = param3;
      if(!delusionText)
      {
         return;
      }
      update(index,index > 0 ? null : callback);
      SoundManager.playEffect("popup_open_item");
      cacheManager.show(function():void
      {
         ResidentMenuUI_Gudetama.getInstance()._addMoney(rewards[index]);
         var _loc1_:int = index - 1;
         if(_loc1_ >= 0)
         {
            addReward(_loc1_,rewards,callback);
         }
      });
   }
   
   public function dispose() : void
   {
      displaySprite.removeEventListener("triggered",triggeredButton);
      delusionSpineModel = null;
      delusionText = null;
      delusionGroup = null;
      if(cacheManager)
      {
         cacheManager.dispose();
         cacheManager = null;
      }
      delusionBone = null;
   }
}

import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class DelusionItemCacheManager
{
    
   
   private var extractor:SpriteExtractor;
   
   private var group:Sprite;
   
   private var pool:Vector.<DelusionItemUI>;
   
   function DelusionItemCacheManager(param1:SpriteExtractor, param2:Sprite)
   {
      pool = new Vector.<DelusionItemUI>();
      super();
      this.extractor = param1;
      this.group = param2;
   }
   
   public function show(param1:Function) : void
   {
      var _loc2_:* = null;
      if(pool.length == 0)
      {
         _loc2_ = new DelusionItemUI(extractor.duplicateAll() as Sprite);
      }
      else
      {
         _loc2_ = pool.pop();
      }
      group.addChild(_loc2_.getDisplaySprite());
      _loc2_.show(param1,finish);
   }
   
   private function finish(param1:DelusionItemUI) : void
   {
      group.removeChild(param1.getDisplaySprite());
      pool.push(param1);
   }
   
   public function dispose() : void
   {
      extractor = null;
      group = null;
      pool.length = 0;
      pool = null;
   }
}

import gudetama.engine.TweenAnimator;
import gudetama.ui.UIBase;
import starling.display.Sprite;

class DelusionItemUI extends UIBase
{
    
   
   function DelusionItemUI(param1:Sprite)
   {
      super(param1);
   }
   
   public function show(param1:Function, param2:Function) : void
   {
      var startCallback:Function = param1;
      var finishCallback:Function = param2;
      var thisObj:DelusionItemUI = this;
      TweenAnimator.startItself(displaySprite,"start",false,function():void
      {
         startCallback();
         TweenAnimator.startItself(displaySprite,"finish",false,function():void
         {
            finishCallback(thisObj);
         });
      });
   }
}

import flash.geom.Point;
import flash.geom.Rectangle;
import gudetama.data.GameSetting;
import gudetama.engine.BaseScene;
import gudetama.engine.Engine;
import gudetama.engine.SoundManager;
import gudetama.scene.home.HomeScene;
import gudetama.ui.UIBase;
import gudetama.util.SpriteExtractor;
import muku.util.StarlingUtil;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Touch;
import starling.events.TouchEvent;

class HeavenUI extends UIBase
{
   
   private static const SHOOT_INTERVAL:Number = 0.035;
    
   
   private var scene:HomeScene;
   
   private var frontestQuad:Quad;
   
   private var backGroup:Sprite;
   
   private var backItems:Sprite;
   
   private var frontGroup:Sprite;
   
   private var quad:Quad;
   
   private var frontItems:Sprite;
   
   private var pool:HeavenItemPool;
   
   private var endTime:int;
   
   private var finish:Boolean;
   
   private var localPoint:Point;
   
   private var shootPoint:Point;
   
   private var fallRectangle:Rectangle;
   
   private var quadTouches:Vector.<Touch>;
   
   private var quadTouch:Touch;
   
   private var quadTouchEvent:TouchEvent;
   
   private var scrollPageIndex:int;
   
   private var visibleFrontestQuad:Boolean;
   
   private var nextGetSoundTime:int;
   
   function HeavenUI(param1:Sprite, param2:BaseScene, param3:Quad)
   {
      localPoint = new Point();
      shootPoint = new Point();
      fallRectangle = new Rectangle();
      super(param1);
      this.scene = HomeScene(param2);
      this.frontestQuad = param3;
      param3.addEventListener("touch",onTouchHeavenQuad);
      backGroup = param1.getChildByName("backHeavenGroup") as Sprite;
      backItems = backGroup.getChildByName("itemGroup") as Sprite;
      frontGroup = param1.getChildByName("frontHeavenGroup") as Sprite;
      quad = frontGroup.getChildByName("quad") as Quad;
      quad.addEventListener("touch",onTouch);
      frontItems = frontGroup.getChildByName("itemGroup") as Sprite;
   }
   
   public function setup(param1:SpriteExtractor) : void
   {
      backGroup.visible = false;
      frontGroup.visible = false;
      frontestQuad.visible = false;
      pool = new HeavenItemPool(param1);
      var _loc2_:HeavenItemUI = pool.fromPool();
      if(_loc2_)
      {
         shootPoint.setTo(0,frontItems.y);
         frontGroup.localToGlobal(shootPoint,shootPoint);
         shootPoint.setTo(0,-(shootPoint.y + _loc2_.getDisplaySprite().height));
         fallRectangle.setTo(-0.5 * (frontGroup.width - _loc2_.getDisplaySprite().width),0.5 * _loc2_.getDisplaySprite().height,frontGroup.width - _loc2_.getDisplaySprite().width,quad.height - _loc2_.getDisplaySprite().height);
         pool.toPool(_loc2_);
      }
   }
   
   public function setScrollPageIndex(param1:int) : void
   {
      scrollPageIndex = param1;
      updateFrontestQuad();
   }
   
   public function updateFrontestQuad() : void
   {
      frontestQuad.visible = scrollPageIndex == 1 && visibleFrontestQuad;
   }
   
   public function prepare() : void
   {
      visibleFrontestQuad = true;
      updateFrontestQuad();
   }
   
   public function generate(param1:int, param2:Function) : void
   {
      var _loc4_:int = 0;
      var _loc3_:* = false;
      backGroup.visible = true;
      frontGroup.visible = true;
      _loc4_ = 0;
      while(_loc4_ < param1)
      {
         _loc3_ = _loc4_ == param1 - 1;
         generateItem(_loc4_,param1,_loc3_,param2);
         _loc4_++;
      }
   }
   
   private function generateItem(param1:int, param2:int, param3:Boolean, param4:Function) : void
   {
      var index:int = param1;
      var num:int = param2;
      var isLast:Boolean = param3;
      var callback:Function = param4;
      scene.getSceneJuggler().delayCall(function():void
      {
         var x:Number = fallRectangle.x + fallRectangle.width * Math.random();
         var y:Number = fallRectangle.y + fallRectangle.height * Math.random();
         var r:Number = Math.random();
         var topY:Number = -300 - 600 * r;
         var time:Number = 0.5 + 0.5 * r;
         var item:HeavenItemUI = pool.fromPool();
         if(!item)
         {
            return;
         }
         if(index % 5 == 0)
         {
            SoundManager.playEffect("tap_nisetama");
         }
         item.shoot(x,y,topY,time,function():void
         {
            if(index % 5 == 0)
            {
               SoundManager.playEffect("heaven_burning");
            }
            item.fall(function():void
            {
               if(isLast)
               {
                  callback();
               }
            });
         });
         scene.getSceneJuggler().delayCall(function():void
         {
            backItems.removeChild(item.getDisplaySprite());
            frontItems.addChild(item.getDisplaySprite());
            if(isLast)
            {
               endTime = Engine.now + GameSetting.getRule().heavenTimeSecs * 1000;
            }
         },0.5 * time);
         backItems.addChild(item.getDisplaySprite());
      },0.035 * index);
   }
   
   private function onTouch(param1:TouchEvent) : void
   {
      var _loc2_:Touch = param1.getTouch(quad);
      if(_loc2_ == null)
      {
         return;
      }
      if(_loc2_.phase == "began")
      {
         if(!finish)
         {
            scene.setHorizontalScrollPolicy("off");
         }
         checkAcquireItem(_loc2_.globalX,_loc2_.globalY);
      }
      else if(_loc2_.phase == "moved")
      {
         checkAcquireItem(_loc2_.globalX,_loc2_.globalY);
      }
      else if(_loc2_.phase == "ended")
      {
         scene.setHorizontalScrollPolicy("auto");
      }
   }
   
   private function checkAcquireItem(param1:Number, param2:Number) : void
   {
      localPoint.setTo(param1,param2);
      frontItems.globalToLocal(localPoint,localPoint);
      var _loc3_:HeavenItemUI = pool.hitTest(localPoint) as HeavenItemUI;
      while(_loc3_)
      {
         acquireItem(_loc3_);
         _loc3_ = pool.hitTest(localPoint) as HeavenItemUI;
      }
   }
   
   private function acquireItem(param1:HeavenItemUI) : void
   {
      var item:HeavenItemUI = param1;
      item.acquire(function():void
      {
         if(nextGetSoundTime <= Engine.now)
         {
            SoundManager.playEffect("popup_open_item");
            nextGetSoundTime = Engine.now + 200;
         }
         frontItems.removeChild(item.getDisplaySprite());
         pool.toPool(item);
         scene.addMoneyByIndex(8);
         if(frontItems.numChildren <= 0)
         {
            finish = true;
            scene.setHorizontalScrollPolicy("auto");
         }
      });
   }
   
   public function advanceTime(param1:Number) : Boolean
   {
      var _loc2_:* = null;
      if(endTime == 0 && !finish)
      {
         return false;
      }
      if(finish)
      {
         if(frontItems.numChildren <= 0)
         {
            finish = false;
            backGroup.visible = false;
            frontGroup.visible = false;
            visibleFrontestQuad = false;
            updateFrontestQuad();
            endTime = 0;
            return true;
         }
      }
      else if(Engine.now >= endTime)
      {
         _loc2_ = pool.getItem();
         while(_loc2_)
         {
            removeItem(_loc2_);
            _loc2_ = pool.getItem();
         }
         finish = true;
         endTime = 0;
         scene.setHorizontalScrollPolicy("auto");
      }
      return false;
   }
   
   private function removeItem(param1:HeavenItemUI) : void
   {
      var item:HeavenItemUI = param1;
      item.remove(function():void
      {
         frontItems.removeChild(item.getDisplaySprite());
         pool.toPool(item);
      });
   }
   
   private function onTouchHeavenQuad(param1:TouchEvent) : void
   {
      var _loc3_:* = null;
      var _loc2_:Touch = param1.getTouch(frontestQuad);
      if(_loc2_)
      {
         _loc3_ = StarlingUtil.getCoordLocal(frontGroup,_loc2_.globalX,_loc2_.globalY);
         if(frontGroup.hitTest(_loc3_))
         {
            if(!quadTouchEvent)
            {
               quadTouches = new Vector.<Touch>();
               quadTouch = _loc2_.clone();
               quadTouch.target = quad;
               quadTouches.push(quadTouch);
               quadTouchEvent = new TouchEvent("touch",quadTouches);
            }
            quadTouch.globalX = _loc2_.globalX;
            quadTouch.globalY = _loc2_.globalY;
            quadTouch.phase = _loc2_.phase;
            quadTouch.tapCount = _loc2_.tapCount;
            quadTouch.timestamp = _loc2_.timestamp;
            quadTouch.pressure = _loc2_.pressure;
            quadTouch.width = _loc2_.width;
            quadTouch.height = _loc2_.height;
            quadTouch.cancelled = _loc2_.cancelled;
            quad.dispatchEvent(quadTouchEvent);
         }
      }
   }
   
   public function dispose() : void
   {
      scene = null;
      if(frontestQuad)
      {
         frontestQuad.removeEventListener("touch",onTouchHeavenQuad);
         frontestQuad = null;
      }
      if(quad)
      {
         quad.removeEventListener("touch",onTouch);
         quad = null;
      }
      backGroup = null;
      backItems = null;
      frontGroup = null;
      frontItems = null;
      if(pool)
      {
         pool.dispose();
         pool = null;
      }
      localPoint = null;
      shootPoint = null;
      fallRectangle = null;
   }
}

import flash.geom.Point;
import flash.geom.Rectangle;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class HeavenItemPool
{
    
   
   private var extractor:SpriteExtractor;
   
   private var pool:Vector.<HeavenItemUI>;
   
   private var using:Vector.<HeavenItemUI>;
   
   private var bounds:Rectangle;
   
   function HeavenItemPool(param1:SpriteExtractor)
   {
      pool = new Vector.<HeavenItemUI>(0);
      using = new Vector.<HeavenItemUI>(0);
      bounds = new Rectangle();
      super();
      this.extractor = param1;
   }
   
   public function fromPool() : HeavenItemUI
   {
      var _loc1_:* = null;
      if(!pool)
      {
         return null;
      }
      if(pool.length)
      {
         _loc1_ = pool.pop().reset();
      }
      else
      {
         _loc1_ = new HeavenItemUI(extractor.duplicateAll() as Sprite);
      }
      using.push(_loc1_);
      return _loc1_;
   }
   
   public function toPool(param1:HeavenItemUI) : void
   {
      pool.push(param1);
      using.removeAt(using.indexOf(param1));
   }
   
   public function hitTest(param1:Point) : HeavenItemUI
   {
      var _loc4_:int = 0;
      var _loc2_:* = null;
      var _loc3_:* = null;
      _loc4_ = using.length - 1;
      while(_loc4_ >= 0)
      {
         _loc2_ = using[_loc4_];
         if(_loc2_.isLand())
         {
            if(!_loc2_.isAcquired())
            {
               _loc3_ = _loc2_.getDisplaySprite();
               bounds.setTo(_loc3_.x - _loc2_.offsX,_loc3_.y - _loc2_.offsY,_loc3_.width,_loc3_.height);
               if(bounds.containsPoint(param1))
               {
                  return _loc2_;
               }
            }
         }
         _loc4_--;
      }
      return null;
   }
   
   public function getItem(param1:Boolean = false) : HeavenItemUI
   {
      var _loc3_:int = 0;
      var _loc2_:* = null;
      _loc3_ = using.length - 1;
      while(_loc3_ >= 0)
      {
         _loc2_ = using[_loc3_];
         if(!(!param1 && !_loc2_.isLand()))
         {
            if(!_loc2_.isAcquired())
            {
               return _loc2_;
            }
         }
         _loc3_--;
      }
      return null;
   }
   
   public function dispose() : void
   {
      var _loc1_:* = null;
      extractor = null;
      for each(_loc1_ in pool)
      {
         _loc1_.dispose();
      }
      pool.length = 0;
      pool = null;
      for each(_loc1_ in using)
      {
         _loc1_.dispose();
      }
      using.length = 0;
      using = null;
      bounds = null;
   }
}

import gudetama.engine.TweenAnimator;
import gudetama.ui.UIBase;
import starling.display.Image;
import starling.display.Sprite;

class HeavenItemUI extends UIBase
{
    
   
   private var image:Image;
   
   private var land:Boolean;
   
   private var acquired:Boolean;
   
   public var offsX:Number;
   
   public var offsY:Number;
   
   function HeavenItemUI(param1:Sprite)
   {
      super(param1);
      image = param1.getChildByName("item") as Image;
      setVisible(false);
   }
   
   public function reset() : HeavenItemUI
   {
      setVisible(false);
      land = false;
      acquired = false;
      return this;
   }
   
   public function shoot(param1:Number, param2:Number, param3:Number, param4:Number, param5:Function) : void
   {
      var x:Number = param1;
      var y:Number = param2;
      var topY:Number = param3;
      var time:Number = param4;
      var callback:Function = param5;
      setVisible(true);
      displaySprite.x = x;
      displaySprite.y = y;
      image.rotation = 2 * 3.141592653589793 * Math.random();
      offsX = 0.5 * image.width;
      offsY = 0.5 * image.height;
      TweenAnimator.startTween(displaySprite,"HEAVEN",{
         "x":x,
         "y":y,
         "topY":topY,
         "time":time,
         "halfTime":0.5 * time
      },function():void
      {
         callback();
      });
   }
   
   public function fall(param1:Function) : void
   {
      var callback:Function = param1;
      TweenAnimator.startItself(displaySprite,"land",false,function():void
      {
         land = true;
         callback();
      });
   }
   
   public function isLand() : Boolean
   {
      return land;
   }
   
   public function acquire(param1:Function) : void
   {
      var callback:Function = param1;
      acquired = true;
      TweenAnimator.startItself(displaySprite,"acquire",false,function():void
      {
         callback();
      });
   }
   
   public function isAcquired() : Boolean
   {
      return acquired;
   }
   
   public function remove(param1:Function) : void
   {
      acquired = true;
      param1();
   }
   
   public function dispose() : void
   {
      image = null;
   }
}

import flash.geom.Point;
import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.QuestionDef;
import gudetama.data.compati.QuestionInfo;
import gudetama.data.compati.QuestionParam;
import gudetama.data.compati.UserProfileData;
import gudetama.data.compati.VoiceDef;
import gudetama.engine.BaseScene;
import gudetama.engine.Engine;
import gudetama.engine.SoundManager;
import gudetama.engine.TextureCollector;
import gudetama.net.HttpConnector;
import gudetama.net.PacketUtil;
import gudetama.scene.friend.FriendDetailDialog;
import gudetama.scene.home.HomeScene;
import gudetama.ui.ResidentMenuUI_Gudetama;
import gudetama.ui.UIBase;
import muku.core.MukuGlobal;
import muku.core.TaskQueue;
import muku.text.ColorTextField;
import muku.util.StarlingUtil;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.textures.Texture;

class MessageUI extends UIBase
{
    
   
   private var scene:BaseScene;
   
   private var fullScreenQuad:Quad;
   
   private var quad:Quad;
   
   private var prefixText:ColorTextField;
   
   private var messageText:ColorTextField;
   
   private var profileGroup:Sprite;
   
   private var avatarImage:Image;
   
   private var imgSns:Image;
   
   private var nameText:ColorTextField;
   
   private var questionInfo:QuestionInfo;
   
   private var shown:Boolean;
   
   private var messageVoiceDef:VoiceDef;
   
   private var touches:Vector.<Touch>;
   
   private var touch:Touch;
   
   private var touchEvent:TouchEvent;
   
   function MessageUI(param1:Sprite, param2:BaseScene, param3:Quad)
   {
      super(param1);
      this.scene = param2;
      this.fullScreenQuad = param3;
      param3.addEventListener("touch",onTouchFullScreenQuad);
      param3.visible = false;
      prefixText = param1.getChildByName("prefix") as ColorTextField;
      messageText = param1.getChildByName("message") as ColorTextField;
      profileGroup = param1.getChildByName("profileGroup") as Sprite;
      quad = profileGroup.getChildByName("quad") as Quad;
      quad.addEventListener("touch",onTouchQuad);
      avatarImage = profileGroup.getChildByName("avatar") as Image;
      imgSns = profileGroup.getChildByName("imgSns") as Image;
      imgSns.visible = false;
      nameText = profileGroup.getChildByName("name") as ColorTextField;
   }
   
   public function setup(param1:TaskQueue, param2:QuestionInfo) : void
   {
      var queue:TaskQueue = param1;
      var questionInfo:QuestionInfo = param2;
      this.questionInfo = questionInfo;
      setVisible(false);
      if(!questionInfo)
      {
         return;
      }
      var questionDef:QuestionDef = GameSetting.getQuestion(questionInfo.questionId);
      var questionParam:QuestionParam = questionDef.params#2[questionInfo.choiceIndex];
      var splited:Array = questionParam.message.split("%1");
      var prefix:String = splited[0];
      var message:String = splited[1];
      prefixText.width = displaySprite.width - prefixText.x;
      prefixText.text#2 = prefix;
      prefixText.width = prefixText.textBounds.width;
      profileGroup.x = prefixText.x + prefixText.width + (prefixText.width > 0 ? 11 : 0);
      messageText.text#2 = message;
      if(questionInfo.snsProfileImage != null)
      {
         queue.addTask(function():void
         {
            GudetamaUtil.loadByteArray2Texture(questionInfo.snsProfileImage,function(param1:Texture):void
            {
               avatarImage.texture = param1;
               queue.taskDone();
            });
         });
         TextureCollector.loadSnsImage(questionInfo.snsType,queue,function(param1:Texture):void
         {
            if(param1 != null)
            {
               imgSns.texture = param1;
               imgSns.visible = true;
            }
         });
      }
      else
      {
         queue.addTask(function():void
         {
            TextureCollector.loadTextureRsrc("avatar-" + GameSetting.getAvatar(questionInfo.avatar).rsrc,function(param1:Texture):void
            {
               avatarImage.texture = param1;
               queue.taskDone();
            });
         });
      }
      queue.addTask(function():void
      {
         messageVoiceDef = GameSetting.getVoice(questionParam.messageVoiceId);
         var path:String = MukuGlobal.makePathFromVoiceName(messageVoiceDef.id#2,messageVoiceDef.rsrc);
         SoundManager.loadVoice(SoundManager.getVoiceId(path),path,function(param1:int):void
         {
            queue.taskDone();
         });
      });
      nameText.text#2 = questionInfo.friendName;
   }
   
   public function show() : void
   {
      if(!questionInfo)
      {
         return;
      }
      if(isVisible())
      {
         return;
      }
      setVisible(true);
      fullScreenQuad.visible = true;
      SoundManager.playVoice(MukuGlobal.makePathFromVoiceName(messageVoiceDef.id#2,messageVoiceDef.rsrc),true,0,0);
      startTween("show",false,function():void
      {
         scene.getSceneJuggler().delayCall(function():void
         {
            shown = true;
         },0.001 * GameSetting.getRule().minimumMessageTime);
      });
   }
   
   private function onTouchQuad(param1:TouchEvent) : void
   {
      var event:TouchEvent = param1;
      var touch:Touch = event.getTouch(quad);
      if(!touch)
      {
         return;
      }
      if(touch.phase == "ended")
      {
         var profile:UserProfileData = UserDataWrapper.friendPart.getFriendProfile(questionInfo.encodedUid);
         if(!profile)
         {
            return;
         }
         FriendDetailDialog.show({
            "profile":profile,
            "removeFunc":function():void
            {
               Engine.showLoading(HomeScene);
               var _loc1_:* = HttpConnector;
               if(gudetama.net.HttpConnector.mainConnector == null)
               {
                  gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
               }
               gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(GENERAL_FRIEND_REMOVE_FOLLOW,profile.encodedUid),function(param1:Array):void
               {
                  Engine.hideLoading(HomeScene);
                  profile.followState = 0;
                  UserDataWrapper.friendPart.removeFollow(profile);
                  UserDataWrapper.friendPart.removeFollower(profile);
                  UserDataWrapper.friendPart.removeFriend(profile);
               });
            },
            "backFromRoomFunc":function():void
            {
               ResidentMenuUI_Gudetama.getInstance().sendChangeState(60,function():void
               {
                  Engine.switchScene(new HomeScene());
               });
            }
         });
      }
   }
   
   private function onTouchFullScreenQuad(param1:TouchEvent) : void
   {
      var _loc3_:* = null;
      var _loc2_:Touch = param1.getTouch(fullScreenQuad);
      if(_loc2_)
      {
         _loc3_ = StarlingUtil.getCoordLocal(quad,_loc2_.globalX,_loc2_.globalY);
         if(quad.hitTest(_loc3_))
         {
            if(!touchEvent)
            {
               touches = new Vector.<Touch>();
               this.touch = _loc2_.clone();
               this.touch.target = quad;
               touches.push(this.touch);
               touchEvent = new TouchEvent("touch",touches);
            }
            this.touch.globalX = _loc2_.globalX;
            this.touch.globalY = _loc2_.globalY;
            this.touch.phase = _loc2_.phase;
            this.touch.tapCount = _loc2_.tapCount;
            this.touch.timestamp = _loc2_.timestamp;
            this.touch.pressure = _loc2_.pressure;
            this.touch.width = _loc2_.width;
            this.touch.height = _loc2_.height;
            this.touch.cancelled = _loc2_.cancelled;
            quad.dispatchEvent(touchEvent);
            return;
         }
         if(_loc2_.phase == "ended")
         {
            hide();
         }
      }
   }
   
   public function hide() : void
   {
      if(!shown)
      {
         return;
      }
      fullScreenQuad.visible = false;
      startTween("hide",false,function():void
      {
         setVisible(false);
         questionInfo = null;
      });
   }
   
   public function dispose() : void
   {
      scene = null;
      if(fullScreenQuad)
      {
         fullScreenQuad.removeEventListener("touch",onTouchFullScreenQuad);
         fullScreenQuad = null;
      }
      prefixText = null;
      messageText = null;
      profileGroup = null;
      if(quad)
      {
         quad.removeEventListener("touch",onTouchQuad);
         quad = null;
      }
      avatarImage = null;
      imgSns = null;
      nameText = null;
      questionInfo = null;
   }
}

import gudetama.data.UserDataWrapper;
import gudetama.engine.TweenAnimator;
import starling.display.Image;

class BombEffectImage
{
   
   private static const ROTATE_TIME:Number = 10;
    
   
   private var image:Image;
   
   private var passedTime:Number = 0;
   
   function BombEffectImage(param1:Image)
   {
      super();
      this.image = param1;
   }
   
   public function init() : void
   {
      image.visible = false;
   }
   
   public function advanceTime(param1:Number) : void
   {
      if(!image.visible && UserDataWrapper.abilityPart.existsKind(1))
      {
         image.visible = true;
         TweenAnimator.startItself(image,"start");
      }
      else if(image.visible && !UserDataWrapper.abilityPart.existsKind(1))
      {
         image.visible = false;
      }
      if(image.visible)
      {
         passedTime += param1;
         image.rotation = 2 * 3.141592653589793 * passedTime / 10;
      }
   }
   
   public function dispose() : void
   {
      image = null;
   }
}

import gudetama.data.UserDataWrapper;
import gudetama.engine.BaseScene;
import gudetama.engine.Engine;
import gudetama.engine.TweenAnimator;
import gudetama.net.HttpConnector;
import gudetama.net.PacketUtil;
import muku.display.ContainerButton;
import starling.display.Sprite;

class PushInfoDialog extends BaseScene
{
    
   
   private var callback:Function;
   
   private var closeButton:ContainerButton;
   
   private var decideButton:ContainerButton;
   
   private var orgPushFlags:int;
   
   function PushInfoDialog(param1:Function)
   {
      super(2);
      callback = param1;
      var _loc2_:* = UserDataWrapper;
      orgPushFlags = gudetama.data.UserDataWrapper.wrapper._data.pushFlags;
   }
   
   public static function show(param1:Function) : void
   {
      Engine.pushScene(new PushInfoDialog(param1),1,true);
   }
   
   override protected function setupProgress(param1:Function) : void
   {
      var onProgress:Function = param1;
      Engine.setupLayoutForTask(queue,"PushInfoDialog",function(param1:Object):void
      {
         displaySprite = param1.object;
         var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
         closeButton = _loc2_.getChildByName("btn_no") as ContainerButton;
         closeButton.addEventListener("triggered",triggeredCloseButton);
         decideButton = _loc2_.getChildByName("btn_yes") as ContainerButton;
         decideButton.addEventListener("triggered",triggeredDecideButton);
         var _loc3_:* = Engine;
         if(gudetama.engine.Engine.isIosPlatform() || true)
         {
            TweenAnimator.startItself(closeButton,"ios");
            TweenAnimator.startItself(decideButton,"ios");
         }
         else
         {
            TweenAnimator.startItself(closeButton,"android");
            TweenAnimator.startItself(decideButton,"android");
         }
         displaySprite.visible = false;
         addChild(displaySprite);
      });
      queue.registerOnProgress(function(param1:Number):void
      {
         if(param1 < 1)
         {
            return;
         }
      });
      queue.startTask(onProgress);
   }
   
   override protected function addedToContainer() : void
   {
      Engine.lockTouchInput(PushInfoDialog);
      setBackButtonCallback(triggeredCloseButton);
   }
   
   override protected function transitionOpenFinished() : void
   {
      displaySprite.visible = true;
      TweenAnimator.startItself(displaySprite,"show",false,function():void
      {
         Engine.unlockTouchInput(PushInfoDialog);
      });
   }
   
   override public function backButtonCallback() : void
   {
      super.backButtonCallback();
      Engine.lockTouchInput(PushInfoDialog);
      setBackButtonCallback(null);
      TweenAnimator.startItself(displaySprite,"hide",false,function():void
      {
         callback();
         Engine.unlockTouchInput(PushInfoDialog);
      });
   }
   
   private function triggeredDecideButton() : void
   {
      procYesNo(true);
   }
   
   private function triggeredCloseButton() : void
   {
      procYesNo(false);
   }
   
   private function procYesNo(param1:Boolean) : void
   {
      var yes:Boolean = param1;
      var pushFlags:int = !!yes ? 63 : 0;
      if(pushFlags != orgPushFlags)
      {
         var _loc3_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(GENERAL_PUSH_PERMIT,pushFlags),function(param1:int):void
         {
            var _loc2_:* = UserDataWrapper;
            gudetama.data.UserDataWrapper.wrapper._data.pushFlags = param1;
            backButtonCallback();
         });
      }
      else
      {
         backButtonCallback();
      }
   }
   
   override public function dispose() : void
   {
      closeButton.removeEventListener("triggered",triggeredCloseButton);
      closeButton = null;
      decideButton.removeEventListener("triggered",triggeredDecideButton);
      decideButton = null;
      callback = null;
      super.dispose();
   }
}

import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.EventData;
import gudetama.data.compati.SystemMailData;
import gudetama.engine.Engine;
import gudetama.engine.TextureCollector;
import gudetama.engine.TweenAnimator;
import gudetama.ui.UIBase;
import muku.core.TaskQueue;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class EventNoticeButton extends UIBase
{
   
   private static const INTERVAL:int = 5000;
    
   
   private var callback:Function;
   
   private var noticeGroup:Sprite;
   
   private var noticeUIs:Vector.<EventNoticeUI>;
   
   private var eventDataList:Array;
   
   private var iconTextureMap:Object;
   
   private var dataIndex:int = -1;
   
   private var noticeIndex:int = -1;
   
   private var nextTime:uint = 0;
   
   private var visible:Boolean = true;
   
   private var tutorial:Boolean;
   
   function EventNoticeButton(param1:Sprite, param2:Function)
   {
      var _loc4_:int = 0;
      var _loc3_:* = null;
      noticeUIs = new Vector.<EventNoticeUI>();
      eventDataList = [];
      iconTextureMap = {};
      super(param1);
      this.callback = param2;
      param1.addEventListener("triggered",triggeredButton);
      noticeGroup = param1.getChildByName("noticeGroup") as Sprite;
      _loc4_ = 0;
      while(_loc4_ < noticeGroup.numChildren)
      {
         _loc3_ = noticeGroup.getChildByName("notice" + _loc4_) as Sprite;
         if(_loc3_)
         {
            noticeUIs.push(new EventNoticeUI(_loc3_));
         }
         _loc4_++;
      }
   }
   
   public function setupAndShow() : void
   {
      var queue:TaskQueue = new TaskQueue();
      setup(queue);
      queue.registerOnProgress(function(param1:Number):void
      {
         if(param1 < 1)
         {
            return;
         }
         show();
      });
      queue.startTask();
   }
   
   public function setup(param1:TaskQueue) : void
   {
      var _loc6_:* = null;
      var _loc5_:int = 0;
      var _loc2_:Object = UserDataWrapper.eventPart.getEventMap();
      var _loc4_:Array = [];
      for each(var _loc3_ in _loc2_)
      {
         _loc4_.push(_loc3_.id#2);
      }
      _loc4_.sort(ascendingKeyComparator);
      eventDataList.length = 0;
      for each(var _loc7_ in _loc4_)
      {
         _loc3_ = _loc2_[_loc7_];
         if(!((_loc6_ = GameSetting.getUIText("event.notice." + _loc3_.id#2)).length == 0 || _loc6_.charAt(0) == "?"))
         {
            loadIcon(param1,_loc3_);
            eventDataList.push(_loc3_);
         }
      }
      _loc5_ = 0;
      while(_loc5_ < noticeUIs.length)
      {
         noticeUIs[_loc5_].startTween("hide");
         noticeUIs[_loc5_].finishTween();
         _loc5_++;
      }
      setVisible(false);
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
   
   private function loadIcon(param1:TaskQueue, param2:EventData) : void
   {
      var queue:TaskQueue = param1;
      var eventData:EventData = param2;
      if(eventData.noticeIconRsrc <= 0)
      {
         return;
      }
      queue.addTask(function():void
      {
         TextureCollector.loadTexture("event-notice_" + eventData.noticeIconRsrc,function(param1:Texture):void
         {
            iconTextureMap[eventData.id#2] = param1;
            queue.taskDone();
         });
      });
   }
   
   public function show() : void
   {
      var _loc2_:int = 0;
      var _loc1_:* = null;
      if(eventDataList.length <= 0)
      {
         return;
      }
      setVisible(true);
      TweenAnimator.startItself(noticeGroup,"show",true);
      if(eventDataList.length == 1)
      {
         _loc1_ = eventDataList[0];
         noticeUIs[0].setup(_loc1_,iconTextureMap[_loc1_.id#2]);
         noticeUIs[0].startTween("show");
         noticeUIs[0].finishTween();
      }
      else
      {
         next();
      }
   }
   
   private function next() : void
   {
      if(!noticeUIs || !eventDataList)
      {
         return;
      }
      if(eventDataList.length <= 1)
      {
         return;
      }
      dataIndex++;
      noticeIndex++;
      var _loc2_:EventData = eventDataList[dataIndex % eventDataList.length];
      var _loc1_:int = noticeIndex - 1;
      if(_loc1_ >= 0)
      {
         noticeUIs[_loc1_ % noticeUIs.length].startTween("fadeOut");
      }
      noticeUIs[noticeIndex % noticeUIs.length].setup(_loc2_,iconTextureMap[_loc2_.id#2]);
      noticeUIs[noticeIndex % noticeUIs.length].startTween("fadeIn");
      nextTime = Engine.now + 5000;
   }
   
   public function advanceTime(param1:Number) : void
   {
      if(Engine.now < nextTime)
      {
         return;
      }
      next();
   }
   
   override public function setVisible(param1:Boolean) : void
   {
      visible = param1 && !tutorial;
      alpha = displaySprite.alpha;
   }
   
   public function set alpha(param1:Number) : void
   {
      setAlpha(param1);
      displaySprite.visible = visible && param1 > 0;
   }
   
   public function setTutorial(param1:Boolean) : void
   {
      tutorial = param1;
      setVisible(visible);
   }
   
   private function triggeredButton(param1:Event) : void
   {
      var _loc2_:SystemMailData = UserDataWrapper.eventPart.getEventMailData(eventDataList[dataIndex % eventDataList.length]);
      if(_loc2_)
      {
         callback(_loc2_);
      }
   }
   
   public function dispose() : void
   {
      displaySprite.removeEventListener("triggered",triggeredButton);
      noticeGroup = null;
      if(noticeUIs)
      {
         for each(var _loc1_ in noticeUIs)
         {
            _loc1_.dispose();
         }
         noticeUIs.length = 0;
         noticeUIs = null;
      }
      if(eventDataList)
      {
         eventDataList.length = 0;
         eventDataList = null;
      }
      if(iconTextureMap)
      {
         for(var _loc2_ in iconTextureMap)
         {
            delete iconTextureMap[_loc2_];
         }
         iconTextureMap = null;
      }
   }
}

import gudetama.data.GameSetting;
import gudetama.data.compati.EventData;
import gudetama.ui.UIBase;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

class EventNoticeUI extends UIBase
{
    
   
   private var iconImage:Image;
   
   private var messageText:ColorTextField;
   
   function EventNoticeUI(param1:Sprite)
   {
      super(param1);
      iconImage = param1.getChildByName("icon") as Image;
      messageText = param1.getChildByName("message") as ColorTextField;
   }
   
   public function setup(param1:EventData, param2:Texture) : void
   {
      messageText.text#2 = GameSetting.getUIText(param1.noticeTextKey);
      if(param1.noticeIconRsrc > 0)
      {
         iconImage.texture = param2;
         iconImage.readjustSize();
         startTween("withRsrc");
      }
      else
      {
         startTween("noRsrc");
      }
      finishTween();
   }
   
   public function dispose() : void
   {
      messageText = null;
   }
}
