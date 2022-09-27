package gudetama.scene.home
{
   import feathers.controls.IScrollBar;
   import feathers.controls.ScrollBar;
   import feathers.controls.ScrollContainer;
   import flash.display.BitmapData;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import gudetama.common.GudetamaUtil;
   import gudetama.data.DataStorage;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.GudetamaDef;
   import gudetama.data.compati.HomeDecoData;
   import gudetama.data.compati.ItemParam;
   import gudetama.data.compati.StampDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.scene.home.ui.CarnaviUI;
   import gudetama.scene.home.ui.CupGachaButton;
   import gudetama.scene.home.ui.EventButton;
   import gudetama.scene.home.ui.HomeDecoShareDialog;
   import gudetama.scene.home.ui.HomeDecorationListDialog;
   import gudetama.scene.home.ui.InfoButtonUI;
   import gudetama.scene.home.ui.ProfileButton;
   import gudetama.scene.shop.ShopScene_Gudetama;
   import gudetama.ui.LocalMessageDialog;
   import gudetama.ui.MessageDialog;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.util.SpriteExtractor;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.display.ManuallySpineButton;
   import muku.display.PagedScrollContainer;
   import muku.display.SimpleImageButton;
   import muku.display.SpineModel;
   import muku.display.ToggleButton;
   import muku.util.SpineUtil;
   import muku.util.StarlingUtil;
   import spine.SkeletonData;
   import spine.animation.AnimationStateData;
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
   
   public class HomeDecoScene extends BaseScene
   {
      
      private static var uniqueCounter:uint = 0;
      
      public static const CAPTURED_IMAGE_WIDTH:Number = 600;
      
      public static const CAPTURED_IMAGE_HEIGHT:Number = 514;
      
      public static const STAMP_OFFSET_POSX:int = 30;
      
      public static const STAMP_OFFSET_POSY:int = 8;
      
      public static var imageDefaultScale:Number = 0.5;
      
      public static var spainDefaultScale:Number = 0.5;
      
      public static var imageMaxScale:Number = 1.5;
      
      public static var spainMaxScale:Number = 1.75;
       
      
      private var callback:Function;
      
      private var stampExtractor:SpriteExtractor;
      
      private var stampMap:Object;
      
      private var selectedUniqueId:int;
      
      private var scrollRenderSprite:ScrollContainer;
      
      private var bgQuad:Quad;
      
      private var mountainImage:Image;
      
      private var weatherSpineModel:SpineModel;
      
      private var stampLayer:Sprite;
      
      private var uiLayer:Sprite;
      
      private var resetBtn:ContainerButton;
      
      private var backBtn:ContainerButton;
      
      private var homeBtn:ContainerButton;
      
      private var saveBtn:ContainerButton;
      
      private var interiorBtn:ContainerButton;
      
      private var uiVisibleBtn:ToggleButton;
      
      private var btnGoShop:ContainerButton;
      
      private var infoButton:InfoButtonUI;
      
      private var btnMenu:ContainerButton;
      
      private var frameBtnListContainer:Sprite;
      
      private var menuScrollRenderSprite:ScrollContainer;
      
      private var menuCloseBtn:ContainerButton;
      
      private var stampListManager:StampListManager;
      
      private var stampListExtractor:SpriteExtractor;
      
      private var editUI:EditUI;
      
      private var shareBonusItem:ItemParam;
      
      private var loadCount:int;
      
      private var gudetamaButton:ManuallySpineButton;
      
      private var dishImage:Image;
      
      private var homeSprite:Sprite;
      
      private var homeSceneLayout:Sprite;
      
      private var kitchenwares:Vector.<KitchenwareButton>;
      
      private var roomScaleX:Number;
      
      private var roomScaleY:Number;
      
      private var spCup:Sprite;
      
      private var table:Image;
      
      private var shareButton:ContainerButton;
      
      private var hasStamp:Boolean = false;
      
      private var isChanged:Boolean = false;
      
      private var scrollGroup:Sprite;
      
      private var scrollContainer:PagedScrollContainer;
      
      private var gudetamaGroup:Sprite;
      
      private var kitchenwareGroup:Sprite;
      
      private var eventButton:EventButton;
      
      private var roomImage:Image;
      
      private var collectionSprite:Sprite;
      
      private var collectionButton:SimpleImageButton;
      
      private var collectionBookinfoSprite:Sprite;
      
      private var challengeButton:SimpleImageButton;
      
      private var friendButton:Sprite;
      
      private var gachaButton:ContainerButton;
      
      private var usefulGroup:Sprite;
      
      private var usefulButton:ContainerButton;
      
      private var shopButton:ContainerButton;
      
      private var profileButton:ProfileButton;
      
      private var cameraButton:SimpleImageButton;
      
      private var carnaviUI:CarnaviUI;
      
      private var gudetamaOriginalX:Number;
      
      private var gudetamaOriginalY:Number;
      
      private var enableCollection:Boolean = false;
      
      private var enableChallenge:Boolean = false;
      
      private var enableFriend:Boolean = false;
      
      private var enableGacha:Boolean = false;
      
      private var enableUseful:Boolean = false;
      
      private var enableCamera:Boolean = false;
      
      private var visible_ui:Boolean = false;
      
      private var currentHomeDecorationId:int = -1;
      
      private var prepearDecoListlen:int;
      
      private var dacoDataList:Array;
      
      private var prepearCallback:Function;
      
      private var homeDecoStapmMap:Object;
      
      private var forceChange:Boolean = false;
      
      private var count:int = -1;
      
      public function HomeDecoScene()
      {
         stampMap = {};
         kitchenwares = new Vector.<KitchenwareButton>();
         super(0);
      }
      
      public static function generateUniqueID() : uint
      {
         return ++uniqueCounter;
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"HomeDecoLayout",function(param1:Object):void
         {
            var layout:Object = param1;
            displaySprite = layout.object;
            scrollRenderSprite = displaySprite.getChildByName("scrollRenderLayer") as ScrollContainer;
            homeSprite = scrollRenderSprite.getChildByName("home") as Sprite;
            scrollRenderSprite.verticalScrollBarFactory = function():IScrollBar
            {
               var _loc1_:ScrollBar = new ScrollBar();
               _loc1_.userObject["scene"] = HomeScene;
               _loc1_.thumbProperties.alpha = 0.6;
               _loc1_.minimumTrackProperties.alpha = 0.6;
               return _loc1_;
            };
            scrollRenderSprite.scrollBarDisplayMode = "fixedFloat";
            scrollRenderSprite.verticalScrollPolicy = "off";
            scrollRenderSprite.horizontalScrollPolicy = "off";
            scrollRenderSprite.autoHideBackground = true;
            scrollRenderSprite.hasElasticEdges = false;
            scrollRenderSprite.interactionMode = "touchAndScrollBars";
            scrollRenderSprite.removeEventListener("touch",null);
            uiLayer = displaySprite.getChildByName("uiLayer") as Sprite;
            resetBtn = uiLayer.getChildByName("resetBtn") as ContainerButton;
            resetBtn.addEventListener("triggered",triggeredResetBtn);
            saveBtn = uiLayer.getChildByName("saveBtn") as ContainerButton;
            saveBtn.addEventListener("triggered",triggeredSaveBtn);
            uiVisibleBtn = uiLayer.getChildByName("uiBtn") as ToggleButton;
            uiVisibleBtn.addEventListener("triggered",triggeredVisibleUI);
            backBtn = uiLayer.getChildByName("backBtn") as ContainerButton;
            backBtn.addEventListener("triggered",triggeredBackToHomeRButton);
            btnMenu = uiLayer.getChildByName("menuBtn") as ContainerButton;
            btnMenu.addEventListener("triggered",triggeredMenuButton);
            stampListManager = new StampListManager(scene as HomeDecoScene,uiLayer.getChildByName("stampListContainer") as Sprite);
            frameBtnListContainer = displaySprite.getChildByName("frameBtnListContainer") as Sprite;
            frameBtnListContainer.touchable = false;
            frameBtnListContainer.visible = false;
            menuScrollRenderSprite = frameBtnListContainer.getChildByName("scrollRenderLayer") as ScrollContainer;
            menuScrollRenderSprite.verticalScrollBarFactory = function():IScrollBar
            {
               var _loc1_:ScrollBar = new ScrollBar();
               _loc1_.trackLayoutMode = "single";
               return _loc1_;
            };
            menuScrollRenderSprite.scrollBarDisplayMode = "fixedFloat";
            menuScrollRenderSprite.horizontalScrollPolicy = "off";
            menuScrollRenderSprite.verticalScrollPolicy = "auto";
            menuScrollRenderSprite.interactionMode = "touchAndScrollBars";
            menuCloseBtn = frameBtnListContainer.getChildByName("closeBtn") as ContainerButton;
            menuCloseBtn.addEventListener("triggered",triggeredMenuCloseButton);
            shareButton = menuScrollRenderSprite.getChildByName("btn_share") as ContainerButton;
            shareButton.addEventListener("triggered",triggeredShareButton);
            btnGoShop = menuScrollRenderSprite.getChildByName("btnGoShop") as ContainerButton;
            btnGoShop.addEventListener("triggered",triggeredGoShopButton);
            interiorBtn = menuScrollRenderSprite.getChildByName("interiorBtn") as ContainerButton;
            interiorBtn.addEventListener("triggered",triggeredInteriorButton);
            frameBtnListContainer.alpha = 0;
            displaySprite.visible = false;
         });
         setupLayoutForTask(queue,"_ARGudetamaStampListItem",function(param1:Object):void
         {
            setStampListExtractor(SpriteExtractor.forGross(param1.object,param1));
         });
         setupLayoutForTask(queue,"_ARStamp",function(param1:Object):void
         {
            setStampExtractor(SpriteExtractor.forGross(param1.object,param1));
         });
         queue.addTask(function():void
         {
            var defStampSpainPath:String = GameSetting.getRule().defStampSpainPath;
            var extra:Boolean = SpineUtil.existSkeletonAnimationData(defStampSpainPath);
            if(!extra)
            {
               defStampSpainPath = GameSetting.getRule().defStampSpainPath;
            }
            SpineUtil.loadSkeletonAnimation(defStampSpainPath,function(param1:SkeletonData, param2:AnimationStateData):void
            {
               queue.taskDone();
            },null,1);
         });
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            addChild(displaySprite);
         });
         queue.startTask(onProgress);
      }
      
      override public function dispose() : void
      {
         if(roomImage)
         {
            roomImage.texture.dispose();
            roomImage.texture = null;
         }
         scrollGroup.dispose();
         scrollContainer.dispose();
         gudetamaGroup.dispose();
         kitchenwareGroup.dispose();
         eventButton.dispose();
         interiorBtn.dispose();
         roomImage.dispose();
         collectionButton.dispose();
         challengeButton.dispose();
         friendButton.dispose();
         gachaButton.dispose();
         usefulGroup.dispose();
         usefulButton.dispose();
         shopButton.dispose();
         profileButton.dispose();
         cameraButton.dispose();
         carnaviUI.dispose();
         super.dispose();
      }
      
      public function setStampExtractor(param1:SpriteExtractor) : void
      {
         stampExtractor = param1;
      }
      
      public function setStampListExtractor(param1:SpriteExtractor) : void
      {
         stampListExtractor = param1;
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
         stampListManager.setupList(stampListExtractor);
         load();
      }
      
      override protected function addedToContainer() : void
      {
         setBackButtonCallback(function():void
         {
            triggeredBackToHomeRButton(null);
         });
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         Engine.unlockTouchInput(HomeDecoScene);
         resumeNoticeTutorial(28);
      }
      
      private function load() : void
      {
         var innerQueue:TaskQueue = new TaskQueue();
         loadHomeLayout(innerQueue);
         innerQueue.registerOnProgress(function(param1:Number):void
         {
            var ratio:Number = param1;
            if(ratio < 1)
            {
               return;
            }
            show(function(param1:Boolean):void
            {
            });
         });
         innerQueue.startTask();
      }
      
      private function loadHomeLayout(param1:TaskQueue) : void
      {
         var _queue:TaskQueue = param1;
         _queue.addTask(function():void
         {
            Engine.setupLayoutForTask(queue,"HomeLayout_1",function(param1:Object):void
            {
               var layout:Object = param1;
               homeSceneLayout = layout.object;
               roomScaleX = 600 / homeSceneLayout.width;
               roomScaleY = 514 / homeSceneLayout.height;
               scrollGroup = homeSceneLayout.getChildByName("scrollGroup") as Sprite;
               scrollContainer = scrollGroup.getChildByName("scrollContainer") as PagedScrollContainer;
               scrollContainer.touchable = false;
               scrollContainer.visibleAllChildren(false);
               roomImage = scrollContainer.getChildByName("room") as Image;
               weatherSpineModel = scrollContainer.getChildByName("weatherSpineModel") as SpineModel;
               var weatherName:String = GudetamaUtil.getWeatherSpineAnimeName();
               weatherSpineModel.show();
               weatherSpineModel.setChangedAnimation(weatherName);
               weatherSpineModel.changeAnimation(weatherName);
               mountainImage = scrollContainer.getChildByName("mountain") as Image;
               mountainImage.visible = true;
               dishImage = scrollContainer.getChildByName("dish") as Image;
               bgQuad = scrollContainer.getChildByName("bgQuad") as Quad;
               gudetamaGroup = scrollContainer.getChildByName("gudetamaGroup") as Sprite;
               var origin:Sprite = gudetamaGroup.getChildByName("origin") as Sprite;
               gudetamaOriginalX = gudetamaGroup.x;
               gudetamaOriginalY = gudetamaGroup.y;
               var offset_x:int = -13;
               var offset_y:int = -14;
               gudetamaButton = gudetamaGroup.getChildByName("gudetamaButton") as ManuallySpineButton;
               gudetamaButton.setOrigin(origin.x,origin.y);
               shiftToRootContainer(offset_x,offset_y,gudetamaGroup);
               eventButton = new EventButton(scrollContainer.getChildByName("eventButton") as ContainerButton);
               eventButton.setup(function():void
               {
                  eventButton.visibleImgText(false);
                  shiftToRootContainer(offset_x,offset_y,eventButton.getDisplaySprite());
                  collectionSprite = scrollContainer.getChildByName("collectionSprite") as Sprite;
                  collectionButton = collectionSprite.getChildByName("collectionButton") as SimpleImageButton;
                  collectionBookinfoSprite = collectionSprite.getChildByName("bookinfo") as Sprite;
                  collectionBookinfoSprite.visible = false;
                  shiftToRootContainer(offset_x,offset_y,collectionSprite);
                  kitchenwareGroup = scrollContainer.getChildByName("kitchenwareGroup") as Sprite;
                  shiftToRootContainer(offset_x,offset_y,kitchenwareGroup);
                  var i:int = 0;
                  while(i < 5)
                  {
                     var sprite:Sprite = kitchenwareGroup.getChildByName("kitchenware" + i) as Sprite;
                     var kitchen:KitchenwareButton = new KitchenwareButton(sprite,i);
                     kitchen.setup();
                     kitchenwares.push(kitchen);
                     i++;
                  }
                  spCup = scrollContainer.getChildByName("spCup") as Sprite;
                  shiftToRootContainer(offset_x,offset_y,spCup);
                  (spCup.getChildByName("stateSprite") as Sprite).visible = false;
                  var btnCupGacha:CupGachaButton = new CupGachaButton(spCup);
                  btnCupGacha.setup();
                  spCup.visible = false;
                  table = scrollContainer.getChildByName("home1@table") as Image;
                  shiftToRootContainer(offset_x,offset_y,table);
                  table.visible = true;
                  challengeButton = scrollContainer.getChildByName("challengeButton") as SimpleImageButton;
                  shiftToRootContainer(offset_x,offset_y,challengeButton);
                  friendButton = scrollContainer.getChildByName("friendButton") as ContainerButton;
                  (friendButton.getChildByName("noticeGroup") as Sprite).visible = false;
                  shiftToRootContainer(offset_x,offset_y,friendButton);
                  gachaButton = scrollContainer.getChildByName("gachaButton") as ContainerButton;
                  shiftToRootContainer(offset_x,offset_y,gachaButton);
                  (gachaButton.getChildByName("pickup") as Image).visible = false;
                  (gachaButton.getChildByName("playableGroup") as Sprite).visible = false;
                  usefulGroup = scrollContainer.getChildByName("usefulGroup") as Sprite;
                  usefulButton = usefulGroup.getChildByName("usefulButton") as ContainerButton;
                  usefulButton.setStopPropagation(true);
                  shiftToRootContainer(offset_x,offset_y,usefulGroup);
                  shopButton = scrollContainer.getChildByName("shopButton") as ContainerButton;
                  shiftToRootContainer(offset_x,offset_y,shopButton);
                  profileButton = new ProfileButton(scrollContainer.getChildByName("profileButton") as ContainerButton);
                  _queue.addTask(function():void
                  {
                     var innerQueue:TaskQueue = new TaskQueue();
                     profileButton.setup(innerQueue,false);
                     innerQueue.registerOnProgress(function(param1:Number):void
                     {
                        if(param1 < 1)
                        {
                           return;
                        }
                        shiftToRootContainer(offset_x,offset_y,profileButton.getDisplaySprite());
                        _queue.taskDone();
                     });
                     innerQueue.startTask();
                  });
                  cameraButton = scrollContainer.getChildByName("cameraButton") as SimpleImageButton;
                  shiftToRootContainer(offset_x,offset_y,cameraButton);
                  carnaviUI = new CarnaviUI(scrollContainer.getChildByName("carnaviGroup") as Sprite);
                  shiftToRootContainer(offset_x,offset_y,carnaviUI.getDisplaySprite());
                  carnaviUI.load(queue);
                  carnaviUI.setup();
                  infoButton = new InfoButtonUI(scrollContainer.getChildByName("infoButton") as ContainerButton,scene);
                  shiftToRootContainer(offset_x,offset_y,infoButton.getDisplaySprite());
                  infoButton.setupMin();
                  stampLayer = scrollRenderSprite.getChildByName("stampLayer") as Sprite;
                  editUI = new EditUI(scene as HomeDecoScene,stampLayer.getChildByName("editSprite") as Sprite);
                  editUI.visible = false;
                  homeSprite.addChild(homeSceneLayout);
                  visibleCentralHomeScene(true);
                  checkEnableContents();
                  loadHomeScene(_queue);
               });
            });
         });
      }
      
      private function shiftToRootContainer(param1:int, param2:int, param3:DisplayObject) : void
      {
         param3.touchable = false;
         param3.x = param3.x * roomScaleX + param1;
         param3.y = param3.y * roomScaleY + param2;
         param3.scaleX = roomScaleX;
         param3.scaleY = roomScaleY;
         scrollRenderSprite.addChildAt(param3,2);
      }
      
      private function visibleCentralHomeScene(param1:Boolean) : void
      {
         weatherSpineModel.visible = param1;
         mountainImage.visible = param1;
         stampLayer.visible = param1;
         dishImage.visible = param1;
         bgQuad.visible = param1;
         gudetamaGroup.visible = param1;
         roomImage.visible = param1;
         kitchenwareGroup.visible = param1;
         eventButton.visible(param1);
      }
      
      private function triggeredVisibleUI() : void
      {
         visible_ui = !visible_ui;
         spCup.visible = visible_ui;
         collectionSprite.visible = visible_ui && enableCollection;
         challengeButton.visible = visible_ui && enableChallenge;
         friendButton.visible = visible_ui && enableFriend;
         gachaButton.visible = visible_ui && enableGacha;
         usefulGroup.visible = visible_ui && enableUseful;
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
         shopButton.visible = visible_ui;
         (shopButton.getChildByName("pack") as Image).visible = UserDataWrapper.wrapper.isNoticeMonthlyBonus();
         profileButton.setVisible(visible_ui);
         cameraButton.visible = visible_ui && enableCamera;
         carnaviUI.getDisplaySprite().visible = visible_ui;
         carnaviUI.update();
         infoButton.setVisible(visible_ui);
      }
      
      private function loadHomeScene(param1:TaskQueue) : void
      {
         var _queue:TaskQueue = param1;
         var innerQueue:TaskQueue = new TaskQueue();
         setRoomTexture(innerQueue);
         setRoomGudetama(innerQueue);
         innerQueue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            homeSceneLayout.scaleX = roomScaleX;
            homeSceneLayout.scaleY = roomScaleY;
            _queue.taskDone();
         });
         innerQueue.startTask();
      }
      
      private function checkEnableContents() : void
      {
         enableCollection = UserDataWrapper.featurePart.existsFeature(0);
         enableChallenge = UserDataWrapper.featurePart.existsFeature(8);
         enableFriend = UserDataWrapper.featurePart.existsFeature(12);
         enableGacha = UserDataWrapper.featurePart.existsFeature(10);
         enableUseful = UserDataWrapper.featurePart.existsFeature(9) || UserDataWrapper.featurePart.existsFeature(14);
         enableCamera = UserDataWrapper.featurePart.existsFeature(1);
      }
      
      public function setRoomTexture(param1:TaskQueue, param2:Boolean = true) : void
      {
         var _queue:TaskQueue = param1;
         var _fromHomeScene:Boolean = param2;
         var chage:Boolean = false;
         if(currentHomeDecorationId == -1)
         {
            chage = true;
         }
         else if(UserDataWrapper.decorationPart.getHomeDecorationId() != currentHomeDecorationId)
         {
            chage = true;
         }
         currentHomeDecorationId != UserDataWrapper.decorationPart.getHomeDecorationId();
         if(chage)
         {
            if(GameSetting.getRule().useHomeDecoEachType)
            {
               resetPlacedStamp();
            }
            _queue.addTask(function():void
            {
               TextureCollector.loadTexture("room-" + UserDataWrapper.decorationPart.getHomeDecorationId() + "-bg",function(param1:Texture):void
               {
                  var tex:Texture = param1;
                  roomImage.texture = tex;
                  var backgroundName:String = !!UserDataWrapper.eventPart.getBackgroundName() ? UserDataWrapper.eventPart.getBackgroundName() : "bg-mountain2";
                  TextureCollector.loadTextureRsrc(backgroundName,function(param1:Texture):void
                  {
                     var texture:Texture = param1;
                     mountainImage.texture = texture;
                     if(UserDataWrapper.wrapper.hasHomeDecoData())
                     {
                        setupSceneDecoData(UserDataWrapper.wrapper.getHomeDecoData(),function():void
                        {
                           _queue.taskDone();
                        },_fromHomeScene);
                     }
                     else
                     {
                        _queue.taskDone();
                     }
                  });
               });
            });
         }
         else
         {
            _queue.taskDone();
         }
      }
      
      private function setRoomGudetama(param1:TaskQueue) : void
      {
         var _loc2_:GudetamaDef = GameSetting.getGudetama(UserDataWrapper.wrapper.getPlacedGudetamaId());
         gudetamaButton.setup(param1,_loc2_.id#2,true);
         dishImage.visible = _loc2_.dish;
      }
      
      public function show(param1:Function) : void
      {
         this.callback = param1;
         GudetamaUtil.setBGQuadColor(bgQuad,mountainImage);
         resumeNoticeTutorial(28,null,null);
         scenePermanent = true;
         displaySprite.visible = true;
      }
      
      private function triggeredResetBtn(param1:Event) : void
      {
         if(hasStamp)
         {
            isChanged = true;
         }
         else
         {
            isChanged = false;
         }
         LocalMessageDialog.show(9,GameSetting.getUIText("ar.stamp.reset.msg"),null,GameSetting.getUIText("ar.stamp.reset.title"),68);
         resetPlacedStamp();
      }
      
      private function triggeredSaveBtn(param1:Event = null) : void
      {
         var event:Event = param1;
         var jsonStrData:String = "";
         var localdecodatalist:Array = getCurrentDecoDataList();
         if(localdecodatalist)
         {
            jsonStrData = JSON.stringify(localdecodatalist);
         }
         var _loc3_:*;
         UserDataWrapper.wrapper.setHomeDecoData(!!GameSetting.getRule().useHomeDecoEachType ? (_loc3_ = UserDataWrapper, gudetama.data.UserDataWrapper.wrapper._data.decorationId) : 0,localdecodatalist);
         var _loc4_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithObject(16777462,jsonStrData),function(param1:*):void
         {
            processClose(true);
         });
      }
      
      public function getCurrentDecoDataList() : Array
      {
         var _loc3_:* = 0;
         var _loc2_:* = null;
         var _loc1_:Array = null;
         if(hasStapmMap())
         {
            _loc1_ = [];
            for(_loc3_ in stampMap)
            {
               _loc2_ = stampMap[_loc3_] as HomeStampView;
               _loc2_.fixDecoData();
               _loc2_.setIndexToDecoData(stampLayer.getChildIndex(_loc2_.getDisplayObject()));
               _loc1_.push(_loc2_.getHomeDecoData());
            }
         }
         return _loc1_;
      }
      
      private function processClose(param1:Boolean) : void
      {
         var _b:Boolean = param1;
         uniqueCounter = 0;
         if(callback)
         {
            callback(_b);
            callback = null;
         }
         ResidentMenuUI_Gudetama.getInstance().sendChangeState(60,function():void
         {
            Engine.switchScene(new HomeScene());
         });
      }
      
      private function triggeredGotoHomeButton(param1:Event) : void
      {
         resetPlacedStamp();
         displaySprite.visible = false;
         processClose(true);
      }
      
      private function triggeredShareButton(param1:Event) : void
      {
         HomeDecoShareDialog.show(takeCapturedComposition());
      }
      
      private function triggeredBackToHomeRButton(param1:Event) : void
      {
         var event:Event = param1;
         if(forceChange)
         {
            triggeredSaveBtn();
         }
         else
         {
            if(isChanged)
            {
               MessageDialog.show(2,GameSetting.getUIText("homedeco.btn.back.confirmation"),function(param1:int):void
               {
                  if(param1 == 0)
                  {
                     goHome();
                  }
               });
               return;
            }
            goHome();
         }
      }
      
      private function goHome() : void
      {
         Engine.showLoading(HomeDecoScene);
         getSceneJuggler().delayCall(function():void
         {
            var _loc1_:* = null;
            if(stampMap[selectedUniqueId])
            {
               _loc1_ = stampMap[selectedUniqueId] as HomeStampView;
               _loc1_.hideGrid();
            }
            selectedUniqueId = -1;
            Engine.hideLoading(HomeDecoScene);
            processClose(false);
         },0.5);
      }
      
      private function triggeredMenuButton(param1:Event) : void
      {
         var event:Event = param1;
         frameBtnListContainer.alpha = 0;
         frameBtnListContainer.visible = true;
         TweenAnimator.startItself(frameBtnListContainer,"on",false,function():void
         {
            TweenAnimator.startItself(frameBtnListContainer,"show",false,function():void
            {
               frameBtnListContainer.touchable = true;
               btnMenu.touchable = false;
            });
         });
      }
      
      private function triggeredMenuCloseButton(param1:Event) : void
      {
         var event:Event = param1;
         TweenAnimator.startItself(frameBtnListContainer,"hide",false,function():void
         {
            TweenAnimator.startItself(frameBtnListContainer,"off",false,function():void
            {
               frameBtnListContainer.touchable = false;
               frameBtnListContainer.visible = false;
               btnMenu.touchable = true;
            });
         });
      }
      
      public function triggeredGoShopButton(param1:Event) : void
      {
         var event:Event = param1;
         DataStorage.getLocalData().stampDataMap = getCurrentDecoDataList();
         ResidentMenuUI_Gudetama.getInstance().sendChangeState(62,function():void
         {
            Engine.switchScene(new ShopScene_Gudetama(6).addBackClass(HomeDecoScene));
         });
      }
      
      private function triggeredInteriorButton(param1:Event) : void
      {
         HomeDecorationListDialog.show(this);
      }
      
      private function touchedRenderImage(param1:TouchEvent) : void
      {
         var _loc2_:* = null;
         var _loc3_:Touch = param1.getTouch(roomImage,"ended");
         if(_loc3_)
         {
            if(stampMap[selectedUniqueId])
            {
               _loc2_ = stampMap[selectedUniqueId] as HomeStampView;
               _loc2_.hideGrid();
            }
            editUI.visible = false;
            selectedUniqueId = -1;
         }
      }
      
      private function triggeredRemoveStamp(param1:Event) : void
      {
         removeStamp(selectedUniqueId);
         editUI.visible = false;
      }
      
      public function removeStamp(param1:int) : void
      {
         var _loc2_:HomeStampView = stampMap[param1] as HomeStampView;
         _loc2_.dispose();
         stampMap[param1] = null;
         delete stampMap[param1];
         stampListManager.notifyRemovedStamp(_loc2_.getStampID(),false);
      }
      
      public function focusNextStamp() : void
      {
         var _loc2_:* = 0;
         var _loc1_:* = null;
         for(_loc2_ in stampMap)
         {
            _loc1_ = stampMap[_loc2_] as HomeStampView;
            if(_loc1_)
            {
               setSelectedStamp(_loc1_.getUniqueID());
               return;
            }
         }
      }
      
      private function resetPlacedStamp() : void
      {
         var _loc1_:* = null;
         for(var _loc2_ in stampMap)
         {
            _loc1_ = stampMap[_loc2_] as HomeStampView;
            _loc1_.dispose();
            stampMap[_loc2_] = null;
            delete stampMap[_loc2_];
            stampListManager.notifyRemovedStamp(_loc1_.getStampID(),true);
         }
         editUI.visible = false;
      }
      
      public function setSelectedStamp(param1:int) : void
      {
         var _loc2_:* = null;
         if(selectedUniqueId == param1)
         {
            return;
         }
         if(stampMap[selectedUniqueId])
         {
            _loc2_ = stampMap[selectedUniqueId] as HomeStampView;
            _loc2_.hideGrid();
         }
         selectedUniqueId = param1;
         _loc2_ = stampMap[selectedUniqueId] as HomeStampView;
         _loc2_.showGrid(editUI);
         var _loc3_:int = stampLayer.numChildren;
         stampLayer.setChildIndex(_loc2_.getDisplayObject(),stampLayer.numChildren);
         stampLayer.setChildIndex(editUI.displaySprite,stampLayer.numChildren);
      }
      
      public function createStamp(param1:int, param2:Function) : void
      {
         var stampId:int = param1;
         var callback:Function = param2;
         var uniqueId:uint = generateUniqueID();
         var stampDef:StampDef = GameSetting.getStamp(stampId);
         if(!stampDef.isSpine)
         {
            var view:Sprite = stampExtractor.duplicateAll() as Sprite;
            var image:Image = view.getChildAt(0) as Image;
         }
         var stampView:HomeStampView = new HomeStampView(stampDef,image);
         stampView.init(this,stampId,uniqueId,onStampTouchFunction,function():void
         {
            if(stampView.isSpine)
            {
               stampView.gudetamaSpineModel.x = roomImage.texture.width * homeSceneLayout.scaleX / 2;
               stampView.gudetamaSpineModel.y = roomImage.texture.height * homeSceneLayout.scaleY / 2;
               stampView.gudetamaSpineModel.scale = spainDefaultScale;
               var _loc1_:* = Starling;
               (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).add(stampView.gudetamaSpineModel);
            }
            else
            {
               image.x = roomImage.texture.width * homeSceneLayout.scaleX / 2;
               image.y = roomImage.texture.height * homeSceneLayout.scaleY / 2;
               image.scale = imageDefaultScale;
            }
            stampLayer.addChild(stampView.getDisplayObject());
            stampMap[uniqueId] = stampView;
            stampView.setScreenPosRate();
            callback(stampView);
         });
         isChanged = true;
      }
      
      private function onStampTouchFunction(param1:String) : void
      {
         if(frameBtnListContainer.visible)
         {
            if("began" == param1)
            {
               frameBtnListContainer.alpha = 0.3;
            }
            else if("ended" == param1)
            {
               frameBtnListContainer.alpha = 1;
            }
         }
      }
      
      public function setupSceneDecoData(param1:Array, param2:Function, param3:Boolean = true) : void
      {
         var _loc7_:int = 0;
         var _loc4_:* = null;
         var _loc5_:* = null;
         homeDecoStapmMap = UserDataWrapper.wrapper.getHomeDecoStampNumsMap();
         if(!param1)
         {
            param2();
            return;
         }
         selectedUniqueId = 1;
         dacoDataList = param1;
         prepearDecoListlen = param1.length;
         var _loc6_:int = 0;
         prepearCallback = param2;
         uniqueCounter = prepearDecoListlen;
         hasStamp = true;
         if(!param3)
         {
            prepearCallback();
            return;
         }
         addStampFunction(0);
      }
      
      public function addStampFunction(param1:int) : void
      {
         if(param1 == prepearDecoListlen)
         {
            prepearCallback();
         }
         else
         {
            addDecoDataToStamp(param1,addStampFunction);
         }
      }
      
      public function addDecoDataToStamp(param1:int, param2:Function) : void
      {
         var _index:int = param1;
         var _callback:Function = param2;
         var decoData:HomeDecoData = dacoDataList[_index] as HomeDecoData;
         var checked:Boolean = checkHomeStampNum(decoData.stampId);
         if(!checked)
         {
            forceChange = true;
            _callback(_index + 1);
            return;
         }
         var uniqueId:uint = decoData.index;
         var stampDef:StampDef = GameSetting.getStamp(decoData.stampId);
         if(!stampDef.isSpine)
         {
            var view:Sprite = stampExtractor.duplicateAll() as Sprite;
            var image:Image = view.getChildAt(0) as Image;
         }
         var stampView:HomeStampView = new HomeStampView(stampDef,image);
         stampView.init(this,decoData.stampId,uniqueId,onStampTouchFunction,function():void
         {
            if(stampView.isSpine)
            {
               stampView.gudetamaSpineModel.x = decoData.x;
               stampView.gudetamaSpineModel.y = decoData.y;
               stampView.gudetamaSpineModel.scale = decoData.scale;
            }
            else
            {
               image.x = decoData.x;
               image.y = decoData.y;
            }
            stampView.setRotation(decoData.rotation);
            stampView.setScale(decoData.scale);
            if(stampView.isSpine)
            {
               stampLayer.addChild(stampView.gudetamaSpineModel);
               var _loc1_:* = Starling;
               (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).add(stampView.gudetamaSpineModel);
            }
            else
            {
               stampLayer.addChild(image);
            }
            stampMap[uniqueId] = stampView;
            stampView.setScreenPosRate();
            stampListManager.notifyAddedStamp(decoData.stampId);
            _callback(_index + 1);
         });
      }
      
      private function checkHomeStampNum(param1:int) : Boolean
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(!homeDecoStapmMap)
         {
            return false;
         }
         for(var _loc2_ in homeDecoStapmMap)
         {
            if(_loc2_ == param1)
            {
               _loc3_ = homeDecoStapmMap[_loc2_];
               if(_loc3_ > 0)
               {
                  _loc4_ = UserDataWrapper.stampPart.getNumStamp(_loc2_);
                  homeDecoStapmMap[_loc2_] = _loc3_ - 1;
                  return _loc4_ >= _loc3_;
               }
               return false;
            }
         }
         return false;
      }
      
      public function hasStapmMap() : Boolean
      {
         var _loc1_:* = 0;
         var _loc3_:int = 0;
         var _loc2_:* = stampMap;
         for(_loc1_ in _loc2_)
         {
            return true;
         }
         return false;
      }
      
      public function takeCapturedComposition(param1:Boolean = false, param2:Boolean = true) : BitmapData
      {
         var _withGudetama:Boolean = param1;
         var _half:Boolean = param2;
         var numchildren:int = stampLayer.numChildren;
         var capturedWidth:Number = roomImage.texture.width;
         var capturedHeight:Number = roomImage.texture.height;
         var roomimage:Image = new Image(roomImage.texture);
         var dishimage:Image = new Image(dishImage.texture);
         var weatherspainindex:int = scrollContainer.getChildIndex(weatherSpineModel);
         var weatherspainX:Number = weatherSpineModel.x;
         var weatherspainY:Number = weatherSpineModel.y;
         var gudetamaDef:GudetamaDef = GameSetting.getGudetama(UserDataWrapper.wrapper.getPlacedGudetamaId());
         dishimage.visible = gudetamaDef.dish;
         var mountainimage:Image = new Image(mountainImage.texture);
         mountainimage.y = 30;
         var bgCopyQuad:Quad = new Quad(capturedWidth,capturedHeight);
         GudetamaUtil.setBGQuadColor(bgCopyQuad);
         var canvas:Sprite = new Sprite();
         canvas.addChild(bgCopyQuad);
         canvas.addChild(weatherSpineModel);
         canvas.addChild(mountainimage);
         canvas.addChild(roomimage);
         dishimage.x = dishImage.x;
         dishimage.y = dishImage.y;
         canvas.addChild(dishimage);
         if(_withGudetama)
         {
            var gudeorignalX:Number = gudetamaGroup.x;
            var gudeorignalY:Number = gudetamaGroup.y;
            gudetamaGroup.scale = 1;
            gudetamaGroup.x = gudetamaOriginalX;
            gudetamaGroup.y = gudetamaOriginalY;
         }
         var map:Object = {};
         var indexmap:Object = {};
         var stampindexmap:Object = {};
         for(key in stampMap)
         {
            var view:HomeStampView = stampMap[key] as HomeStampView;
            var dObj:DisplayObject = view.getDisplayObject();
            dObj.userObject["key"] = key;
            map[key] = stampLayer.getChildIndex(dObj);
            indexmap[stampLayer.getChildIndex(dObj)] = key;
            stamplen++;
         }
         for(key in stampMap)
         {
            view = stampMap[key] as HomeStampView;
            dObj = view.getDisplayObject();
            canvas.addChild(dObj);
            dObj.x = capturedWidth * view.screenPosX + 30;
            dObj.y = capturedHeight * view.screenPosY + 8;
            dObj.scaleX = dObj.scaleX * capturedWidth / 600;
            dObj.scaleY = dObj.scaleY * capturedHeight / 514;
         }
         canvas.sortChildren(function(param1:DisplayObject, param2:DisplayObject):int
         {
            if(map[param1.userObject.key] > map[param2.userObject.key])
            {
               return 1;
            }
            if(map[param1.userObject.key] < map[param2.userObject.key])
            {
               return -1;
            }
            return 0;
         });
         if(stampMap[selectedUniqueId])
         {
            view = stampMap[selectedUniqueId] as HomeStampView;
            view.hideGrid();
         }
         if(_withGudetama)
         {
            canvas.addChild(gudetamaGroup);
         }
         var visibleeditui:Boolean = editUI.visible;
         editUI.visible = false;
         selectedUniqueId = -1;
         var _loc8_:* = Starling;
         var _starling:Starling = starling.core.Starling.sCurrent;
         var _loc9_:* = Starling;
         var painter:Painter = !!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._painter : null;
         var viewPort:Rectangle = _starling.viewPort;
         var stageWidth:Number = viewPort.width;
         var stageHeight:Number = viewPort.height;
         var sectionResult:BitmapData = new BitmapData(stageWidth,stageHeight,true,0);
         var sectionResultRect:Rectangle = StarlingUtil.getRectangleFromPool();
         sectionResultRect.setTo(0,0,stageWidth,stageHeight);
         var result:BitmapData = new BitmapData(capturedWidth,capturedHeight,true,0);
         var point:Point = StarlingUtil.getPointFromPool();
         var i:int = 0;
         while(i < Math.ceil(capturedWidth / stageWidth))
         {
            var j:int = 0;
            while(j < Math.ceil(capturedHeight / stageHeight))
            {
               canvas.x = -i * stageWidth;
               canvas.y = -j * stageHeight;
               painter.clear();
               painter.pushState();
               painter.state.renderTarget = null;
               painter.state.setModelviewMatricesToIdentity();
               painter.setStateTo(canvas.transformationMatrix);
               if(stage)
               {
                  painter.state.setProjectionMatrix(0,0,stageWidth,stageHeight,stageWidth,stageHeight,stage.cameraPosition);
               }
               else
               {
                  painter.state.setProjectionMatrix(0,0,stageWidth,stageHeight,stageWidth,stageHeight,new Vector3D(346,568,-633.3487517125084));
               }
               canvas.render(painter);
               painter.finishMeshBatch();
               painter.context.drawToBitmapData(sectionResult);
               painter.popState();
               point.setTo(i * stageWidth,j * stageHeight);
               result.copyPixels(sectionResult,sectionResultRect,point);
               j++;
            }
            i++;
         }
         sectionResult.dispose();
         sectionResult = null;
         roomimage.removeFromParent(true);
         canvas.removeChildren();
         canvas.dispose();
         for(index in indexmap)
         {
            view = stampMap[indexmap[index]] as HomeStampView;
            dObj = view.getDisplayObject();
            dObj.x = 600 * view.screenPosX;
            dObj.y = 514 * view.screenPosY;
            dObj.scaleX *= 600 / capturedWidth;
            dObj.scaleY *= 514 / capturedHeight;
            stampLayer.addChild(dObj);
         }
         stampLayer.setChildIndex(editUI.displaySprite,stampLayer.numChildren);
         editUI.visible = visibleeditui;
         weatherSpineModel.x = weatherspainX;
         weatherSpineModel.y = weatherspainY;
         scrollContainer.addChildAt(weatherSpineModel,weatherspainindex);
         if(_withGudetama)
         {
            gudetamaGroup.x = gudeorignalX;
            gudetamaGroup.y = gudeorignalY;
            gudetamaGroup.scaleX = roomScaleX;
            gudetamaGroup.scaleY = roomScaleY;
            scrollRenderSprite.addChildAt(gudetamaGroup,2);
         }
         if(_half)
         {
            var res:BitmapData = new BitmapData(700,capturedHeight - 200);
            res.copyPixels(result,new Rectangle(670,40,700,capturedHeight - 150),new Point(0,0));
            return res;
         }
         return result;
      }
      
      override public function advanceTime(param1:Number) : void
      {
         super.advanceTime(param1);
         if(carnaviUI)
         {
            carnaviUI.advanceTime(param1);
         }
      }
      
      public function changeScrollEnable(param1:Boolean) : void
      {
         isChanged = true;
      }
   }
}

import flash.geom.Point;
import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.HomeSkeltonAnimation;
import gudetama.data.compati.HomeDecoData;
import gudetama.data.compati.HomeStampSettingDef;
import gudetama.data.compati.StampDef;
import gudetama.engine.TextureCollector;
import gudetama.scene.home.HomeDecoScene;
import muku.core.TaskQueue;
import muku.util.SpineUtil;
import muku.util.StarlingUtil;
import spine.SkeletonData;
import spine.animation.AnimationStateData;
import spine.starling.SkeletonAnimation;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.textures.Texture;

class HomeStampView extends DisplayObject
{
    
   
   private var uniqueId:int;
   
   private var control:HomeDecoScene;
   
   private var view:Image;
   
   private var editUI:EditUI;
   
   public var isSpine:Boolean = false;
   
   private var decoData:HomeDecoData;
   
   public var gudetamaSpineModel:SkeletonAnimation;
   
   private var stampWidth:Number;
   
   private var stampHeight:Number;
   
   public var stampScale:Number;
   
   private var stampDef:StampDef;
   
   private var homeStampSetting:HomeStampSettingDef;
   
   private var onTouchFunction:Function;
   
   function HomeStampView(param1:StampDef, param2:Image)
   {
      super();
      decoData = new HomeDecoData();
      view = param2;
      stampDef = param1;
   }
   
   override public function dispose() : void
   {
      if(isSpine)
      {
         gudetamaSpineModel.removeFromParent(true);
      }
      else
      {
         view.removeFromParent(true);
      }
      control = null;
   }
   
   public function get screenPosX() : Number
   {
      return decoData.screenPosRateX;
   }
   
   public function get screenPosY() : Number
   {
      return decoData.screenPosRateY;
   }
   
   public function getDisplayObject() : DisplayObject
   {
      return !!isSpine ? gudetamaSpineModel : view;
   }
   
   public function getStampID() : int
   {
      return decoData.stampId;
   }
   
   public function getUniqueID() : int
   {
      return uniqueId;
   }
   
   public function getHomeDecoData() : HomeDecoData
   {
      return decoData;
   }
   
   public function getStampWidth() : Number
   {
      return stampWidth * gudetamaSpineModel.scale;
   }
   
   public function getStampHeight() : Number
   {
      return stampHeight * gudetamaSpineModel.scale;
   }
   
   public function init(param1:HomeDecoScene, param2:int, param3:int, param4:Function, param5:Function) : void
   {
      var control:HomeDecoScene = param1;
      var sid:int = param2;
      var uid:int = param3;
      var _onTouchFunction:Function = param4;
      var callback:Function = param5;
      this.control = control;
      decoData.stampId = sid;
      uniqueId = uid;
      onTouchFunction = _onTouchFunction;
      isSpine = stampDef.isSpine;
      var queue:TaskQueue = new TaskQueue();
      if(isSpine)
      {
         queue.addTask(function():void
         {
            var defStampSpainPath:String = "stamp/" + decoData.stampId + "/stamp_" + decoData.stampId + "_spine";
            var extra:Boolean = SpineUtil.existSkeletonAnimationData(defStampSpainPath);
            if(!extra)
            {
               defStampSpainPath = GameSetting.getRule().defStampSpainPath;
            }
            SpineUtil.loadSkeletonAnimation(defStampSpainPath,function(param1:SkeletonData, param2:AnimationStateData):void
            {
               var _skeletonData:SkeletonData = param1;
               var _stateData:AnimationStateData = param2;
               homeStampSetting = GameSetting.getHomeStampSetting(GameSetting.getStamp(decoData.stampId).homeStampSettingId);
               gudetamaSpineModel = new SkeletonAnimation(_skeletonData,_stateData);
               gudetamaSpineModel.touchable = true;
               gudetamaSpineModel.addEventListener("touch",onTouchTranslate);
               gudetamaSpineModel.skeleton.setToSetupPose();
               gudetamaSpineModel.state.update(0);
               gudetamaSpineModel.state.apply(gudetamaSpineModel.skeleton);
               gudetamaSpineModel.skeleton.updateWorldTransform();
               if(homeStampSetting.animationName && homeStampSetting.animationName != "")
               {
                  gudetamaSpineModel.state.setAnimationByName(0,homeStampSetting.animationName,true);
               }
               stampWidth = _stateData.skeletonData.width * gudetamaSpineModel.scale;
               stampHeight = _stateData.skeletonData.height * gudetamaSpineModel.scale;
               gudetamaSpineModel.pivotX = gudetamaSpineModel.width * 0.5;
               gudetamaSpineModel.pivotY = 15;
               gudetamaSpineModel.scale = 0.2;
               if(!extra)
               {
                  TextureCollector.loadTextureForTask(queue,GudetamaUtil.getARStampName(stampDef.id#2),function(param1:Texture):void
                  {
                     SpineUtil.changeSkeletonAttachmentTexture(gudetamaSpineModel.skeleton,param1,homeStampSetting.slotName,homeStampSetting.attachmentName,null);
                     queue.taskDone();
                  });
               }
               else
               {
                  queue.taskDone();
               }
            },null,1);
         });
      }
      else
      {
         view.touchable = true;
         view.addEventListener("touch",onTouchTranslate);
         TextureCollector.loadTextureForTask(queue,GudetamaUtil.getARStampName(stampDef.id#2),function(param1:Texture):void
         {
            view.texture = param1;
            view.readjustSize();
            view.pivotX = param1.width * 0.5;
            view.pivotY = param1.height * 0.5;
         });
      }
      queue.startTask(function(param1:Number):void
      {
         if(param1 < 1)
         {
            return;
         }
         callback();
         control.setSelectedStamp(uniqueId);
      });
   }
   
   public function showGrid(param1:EditUI) : void
   {
      editUI = param1;
      editUI.visible = true;
      editUI.setView(this);
   }
   
   public function hideGrid() : void
   {
      editUI = null;
   }
   
   public function hasTouchAction() : Boolean
   {
      return homeStampSetting.touchSetting;
   }
   
   public function startTouchAction() : void
   {
      HomeSkeltonAnimation.startTouchAction(gudetamaSpineModel,homeStampSetting);
   }
   
   private function onTouchTranslate(param1:TouchEvent) : void
   {
      var _loc3_:* = null;
      var _loc2_:* = null;
      var _loc4_:* = null;
      if(isSpine)
      {
         _loc3_ = param1.getTouch(gudetamaSpineModel,"began");
         if(_loc3_)
         {
            onTouchFunction("began");
            control.setSelectedStamp(uniqueId);
            control.changeScrollEnable(false);
         }
         _loc3_ = param1.getTouch(gudetamaSpineModel,"moved");
         if(_loc3_)
         {
            _loc2_ = StarlingUtil.getPointFromPool();
            _loc4_ = StarlingUtil.getPointFromPool();
            _loc3_.getLocation(gudetamaSpineModel.parent,_loc2_);
            _loc3_.getPreviousLocation(gudetamaSpineModel.parent,_loc4_);
            gudetamaSpineModel.x += _loc2_.x - _loc4_.x;
            gudetamaSpineModel.y += _loc2_.y - _loc4_.y;
            control.setSelectedStamp(uniqueId);
         }
         _loc3_ = param1.getTouch(gudetamaSpineModel,"ended");
         if(_loc3_)
         {
            onTouchFunction("ended");
            decoData.screenPosRateX = gudetamaSpineModel.x / 600;
            decoData.screenPosRateY = gudetamaSpineModel.y / 514;
            control.changeScrollEnable(true);
         }
      }
      else
      {
         _loc3_ = param1.getTouch(view,"began");
         if(_loc3_)
         {
            onTouchFunction("began");
            control.setSelectedStamp(uniqueId);
            control.changeScrollEnable(false);
         }
         _loc3_ = param1.getTouch(view,"moved");
         if(_loc3_)
         {
            _loc2_ = StarlingUtil.getPointFromPool();
            _loc4_ = StarlingUtil.getPointFromPool();
            _loc3_.getLocation(view.parent,_loc2_);
            _loc3_.getPreviousLocation(view.parent,_loc4_);
            view.x += _loc2_.x - _loc4_.x;
            view.y += _loc2_.y - _loc4_.y;
            control.setSelectedStamp(uniqueId);
         }
         _loc3_ = param1.getTouch(view,"ended");
         if(_loc3_)
         {
            onTouchFunction("ended");
            decoData.screenPosRateX = view.x / 600;
            decoData.screenPosRateY = view.y / 514;
            control.changeScrollEnable(true);
         }
      }
   }
   
   public function setScreenPosRate() : void
   {
      if(isSpine)
      {
         decoData.screenPosRateX = gudetamaSpineModel.x / 600;
         decoData.screenPosRateY = gudetamaSpineModel.y / 514;
      }
      else
      {
         decoData.screenPosRateX = view.x / 600;
         decoData.screenPosRateY = view.y / 514;
      }
   }
   
   public function fixDecoData() : void
   {
      if(isSpine)
      {
         decoData.x = gudetamaSpineModel.x;
         decoData.y = gudetamaSpineModel.y;
         decoData.rotation = gudetamaSpineModel.rotation;
         decoData.scale = gudetamaSpineModel.scale;
         decoData.screenPosRateX = gudetamaSpineModel.x / 600;
         decoData.screenPosRateY = gudetamaSpineModel.y / 514;
      }
      else
      {
         decoData.x = view.x;
         decoData.y = view.y;
         decoData.rotation = view.rotation;
         decoData.scale = view.scale;
         decoData.screenPosRateX = view.x / 600;
         decoData.screenPosRateY = view.y / 514;
      }
      decoData.isSpain = isSpine;
   }
   
   public function setIndexToDecoData(param1:int) : void
   {
      decoData.index = param1;
   }
   
   public function setRotation(param1:Number) : void
   {
      if(isSpine)
      {
         gudetamaSpineModel.rotation = param1;
      }
      else
      {
         view.rotation = param1;
      }
   }
   
   public function setScale(param1:Number) : void
   {
      if(isSpine)
      {
         gudetamaSpineModel.scale = param1;
      }
      else
      {
         view.scale = param1;
      }
   }
}

import feathers.controls.IScrollBar;
import feathers.controls.List;
import feathers.controls.ScrollBar;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.TiledRowsLayout;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.StampData;
import gudetama.scene.ar.ui.ARGudetamaStampItemRenderer;
import gudetama.scene.home.HomeDecoScene;
import gudetama.scene.home.HomeExpansionDialog;
import gudetama.ui.LocalMessageDialog;
import gudetama.ui.MessageDialog;
import gudetama.util.SpriteExtractor;
import muku.display.ImageButton;
import muku.display.SimpleImageButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;

class StampListManager
{
    
   
   private var control:HomeDecoScene;
   
   private var ListContainer:Sprite;
   
   private var list:List;
   
   private var collection:ListCollection;
   
   private var plusBtn:SimpleImageButton;
   
   private var placedStampNumText:ColorTextField;
   
   private var currentPlaceNum:int;
   
   private var placeCountMap:Object;
   
   private var emptyStampButton:ImageButton;
   
   function StampListManager(param1:HomeDecoScene, param2:Sprite)
   {
      super();
      this.control = param1;
      this.ListContainer = param2;
      list = ListContainer.getChildByName("list") as List;
      (ListContainer.getChildByName("bg_mat") as Image).touchable = true;
      (ListContainer.getChildByName("bar_mat") as Image).touchable = true;
      var _loc3_:Sprite = ListContainer.getChildByName("plusContainer") as Sprite;
      plusBtn = _loc3_.getChildByName("plusBtn") as SimpleImageButton;
      plusBtn.addEventListener("triggered",triggeredGudetamaPlus);
      placedStampNumText = _loc3_.getChildByName("numText") as ColorTextField;
      emptyStampButton = ListContainer.getChildByName("stampShortage_btn") as ImageButton;
      emptyStampButton.addEventListener("triggered",param1.triggeredGoShopButton);
      emptyStampButton.visible = false;
      collection = new ListCollection();
      currentPlaceNum = 0;
      placeCountMap = {};
      updatePlaceNum();
   }
   
   public function setupList(param1:SpriteExtractor) : void
   {
      var extractor:SpriteExtractor = param1;
      var map:Object = UserDataWrapper.stampPart.getStampMap();
      var count:int = 0;
      for(key in map)
      {
         var stampData:StampData = map[key] as StampData;
         if(stampData.num > 0)
         {
            placeCountMap[key] = stampData.num;
            collection.push({
               "stampId":key,
               "countMap":placeCountMap
            });
            count++;
         }
      }
      if(count == 0)
      {
         emptyStampButton.visible = true;
      }
      (collection.data#2 as Array).sort(function(param1:Object, param2:Object):int
      {
         return param1.stampId - param2.stampId;
      });
      var layout:TiledRowsLayout = new TiledRowsLayout();
      layout.verticalAlign = "center";
      layout.horizontalAlign = "left";
      layout.useSquareTiles = false;
      layout.requestedColumnCount = 6;
      layout.horizontalGap = 15;
      layout.verticalGap = 5;
      list.layout = layout;
      list.hasElasticEdges = false;
      list.autoHideBackground = true;
      list.itemRendererFactory = function():IListItemRenderer
      {
         var _loc1_:ARGudetamaStampItemRenderer = new ARGudetamaStampItemRenderer(extractor);
         _loc1_.addEventListener("triggered",triggeredStampItemEvent);
         return _loc1_;
      };
      list.verticalScrollBarFactory = function():IScrollBar
      {
         var _loc1_:ScrollBar = new ScrollBar();
         _loc1_.userObject["scene"] = HomeDecoScene;
         return _loc1_;
      };
      list.scrollBarDisplayMode = "fixed";
      list.horizontalScrollPolicy = "off";
      list.interactionMode = "touchAndScrollBars";
      list.dataProvider = collection;
      list.validate();
   }
   
   private function triggeredStampItemEvent(param1:Event) : void
   {
      var event:Event = param1;
      var data:Object = event.data#2;
      var dialogtype:int = 0;
      var needexpansion:Boolean = false;
      if(!data)
      {
         return;
      }
      if(isAlreadyPlaceMax())
      {
         var _loc3_:* = UserDataWrapper;
         if(GameSetting.getRule().placeHomeStampNumTable.length - 1 <= gudetama.data.UserDataWrapper.wrapper._data.placeHomeStampExpansionCount)
         {
            dialogtype = 1;
            var key:String = "ar.stamp.expansion.fullMsg";
         }
         else
         {
            needexpansion = true;
            key = "homedeco.create.err1";
            dialogtype = 2;
         }
      }
      else if(placeCountMap[data.stampId] <= 0)
      {
         key = "homedeco.create.err2";
         dialogtype = 1;
      }
      if(key)
      {
         MessageDialog.show(dialogtype,GameSetting.getUIText(key),function(param1:int):void
         {
            if(param1 == 0 && needexpansion)
            {
               triggeredGudetamaPlus();
            }
         });
         return;
      }
      notifyAddedStamp(data.stampId);
      control.createStamp(data.stampId,function(param1:HomeStampView):void
      {
      });
   }
   
   public function notifyAddedStamp(param1:int) : void
   {
      currentPlaceNum++;
      updatePlaceNum();
      placeCountMap[param1]--;
      collection.updateAll();
   }
   
   public function notifyRemovedStamp(param1:int, param2:Boolean) : void
   {
      if(currentPlaceNum > 0)
      {
         currentPlaceNum--;
      }
      updatePlaceNum();
      placeCountMap[param1]++;
      if(param2)
      {
         if(currentPlaceNum <= 0)
         {
            collection.updateAll();
         }
      }
      else
      {
         collection.updateAll();
      }
   }
   
   private function triggeredGudetamaPlus(param1:Event = null) : void
   {
      var event:Event = param1;
      var _loc2_:* = UserDataWrapper;
      var maxPlace:int = GameSetting.getRule().placeHomeStampNumTable[gudetama.data.UserDataWrapper.wrapper._data.placeHomeStampExpansionCount];
      var _loc4_:* = UserDataWrapper;
      if(GameSetting.getRule().placeHomeStampNumTable.length - 1 <= gudetama.data.UserDataWrapper.wrapper._data.placeHomeStampExpansionCount)
      {
         LocalMessageDialog.show(2,GameSetting.getUIText("ar.stamp.expansion.fullMsg"),null,GameSetting.getUIText("ar.stamp.expansion.title"),68);
         return;
      }
      HomeExpansionDialog.show(function(param1:Boolean):void
      {
         if(!param1)
         {
            return;
         }
         updatePlaceNum();
      });
   }
   
   private function updatePlaceNum() : void
   {
      var _loc2_:* = UserDataWrapper;
      var _loc1_:int = GameSetting.getRule().placeHomeStampNumTable[gudetama.data.UserDataWrapper.wrapper._data.placeHomeStampExpansionCount];
      placedStampNumText.text#2 = currentPlaceNum.toString() + "/" + _loc1_.toString();
   }
   
   private function isAlreadyPlaceMax() : Boolean
   {
      var _loc2_:* = UserDataWrapper;
      var _loc1_:int = GameSetting.getRule().placeHomeStampNumTable[gudetama.data.UserDataWrapper.wrapper._data.placeHomeStampExpansionCount];
      return currentPlaceNum >= _loc1_;
   }
}

import flash.geom.Point;
import gudetama.scene.home.HomeDecoScene;
import muku.display.SimpleImageButton;
import muku.util.StarlingUtil;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.utils.MathUtil;

class EditUI
{
    
   
   private var control:HomeDecoScene;
   
   public var displaySprite:Sprite;
   
   private var frame:Image;
   
   private var removeBtn:SimpleImageButton;
   
   private var actionBtn:SimpleImageButton;
   
   private var ctrlLeftTopBtn:Quad;
   
   private var ctrlLeftBottomBtn:Quad;
   
   private var ctrlRightBottomBtn:Quad;
   
   private var view:HomeStampView;
   
   private var maxScale:Number;
   
   function EditUI(param1:HomeDecoScene, param2:Sprite)
   {
      super();
      this.control = param1;
      displaySprite = param2;
      frame = displaySprite.getChildByName("frame") as Image;
      removeBtn = displaySprite.getChildByName("removeBtn") as SimpleImageButton;
      removeBtn.addEventListener("triggered",triggeredRemoveBtn);
      actionBtn = displaySprite.getChildByName("actionBtn") as SimpleImageButton;
      actionBtn.addEventListener("triggered",triggeredActionBtn);
      ctrlLeftTopBtn = displaySprite.getChildByName("ctrlLeftTopBtn") as Quad;
      ctrlLeftTopBtn.touchable = true;
      ctrlLeftTopBtn.addEventListener("touch",touchedCtrlBtn);
      ctrlLeftBottomBtn = displaySprite.getChildByName("ctrlLeftBottomBtn") as Quad;
      ctrlLeftBottomBtn.touchable = true;
      ctrlLeftBottomBtn.addEventListener("touch",touchedCtrlBtn);
      ctrlRightBottomBtn = displaySprite.getChildByName("ctrlRightBottomBtn") as Quad;
      ctrlRightBottomBtn.touchable = true;
      ctrlRightBottomBtn.addEventListener("touch",touchedCtrlBtn);
      displaySprite.addEventListener("enterFrame",update);
   }
   
   public function set visible(param1:Boolean) : void
   {
      displaySprite.visible = param1;
   }
   
   public function get visible() : Boolean
   {
      return displaySprite.visible;
   }
   
   public function setView(param1:HomeStampView) : void
   {
      view = param1;
      maxScale = !!view.isSpine ? HomeDecoScene.spainMaxScale : Number(HomeDecoScene.imageMaxScale);
      var _loc2_:Boolean = !view.isSpine ? false : Boolean(view.hasTouchAction());
      actionBtn.touchable = _loc2_;
      actionBtn.visible = _loc2_;
   }
   
   public function update() : void
   {
      if(!displaySprite.visible)
      {
         return;
      }
      if(!view)
      {
         return;
      }
      var _loc2_:DisplayObject = view.getDisplayObject();
      var _loc1_:Number = _loc2_.width;
      var _loc3_:Number = _loc2_.height;
      if(view.isSpine)
      {
         _loc1_ = view.getStampWidth();
         _loc3_ = view.getStampHeight();
      }
      frame.width = _loc1_ + 60;
      frame.height = _loc3_ + 60;
      removeBtn.x = _loc1_ + 40;
      removeBtn.y = 38.5;
      ctrlLeftTopBtn.x = 30;
      ctrlLeftTopBtn.y = 30;
      ctrlLeftBottomBtn.x = 30;
      ctrlLeftBottomBtn.y = _loc3_ + 30;
      ctrlRightBottomBtn.x = _loc1_ + 30;
      ctrlRightBottomBtn.y = _loc3_ + 30;
      displaySprite.x = _loc2_.x;
      displaySprite.y = _loc2_.y;
      displaySprite.pivotX = frame.width * 0.5;
      displaySprite.pivotY = frame.height * 0.5;
      displaySprite.rotation = _loc2_.rotation;
   }
   
   private function triggeredRemoveBtn(param1:Event) : void
   {
      control.removeStamp(view.getUniqueID());
      visible = false;
      control.focusNextStamp();
   }
   
   private function triggeredActionBtn(param1:Event) : void
   {
      view.startTouchAction();
   }
   
   private function touchedCtrlBtn(param1:TouchEvent) : void
   {
      var _loc8_:* = null;
      var _loc11_:* = null;
      var _loc10_:* = null;
      var _loc4_:* = null;
      var _loc6_:* = null;
      var _loc9_:Number = NaN;
      var _loc5_:* = null;
      var _loc3_:Number = NaN;
      var _loc7_:Number = NaN;
      param1.stopPropagation();
      var _loc2_:Quad = param1.target as Quad;
      if(_loc8_ = param1.getTouch(_loc2_,"began"))
      {
         control.changeScrollEnable(false);
      }
      if(_loc8_ = param1.getTouch(_loc2_,"moved"))
      {
         _loc11_ = view.getDisplayObject();
         (_loc10_ = StarlingUtil.getPointFromPool()).setTo(_loc11_.x,_loc11_.y);
         _loc4_ = StarlingUtil.getPointFromPool();
         _loc8_.getLocation(_loc11_.parent,_loc4_);
         _loc6_ = _loc4_.subtract(_loc10_);
         _loc9_ = Math.atan2(_loc6_.y,_loc6_.x);
         _loc5_ = StarlingUtil.getPointFromPool();
         _loc8_.getPreviousLocation(_loc11_.parent,_loc5_);
         _loc6_ = _loc5_.subtract(_loc10_);
         _loc9_ -= Math.atan2(_loc6_.y,_loc6_.x);
         _loc11_.rotation += _loc9_;
         _loc3_ = StarlingUtil.distance(_loc10_.x,_loc10_.y,_loc4_.x,_loc4_.y);
         _loc7_ = StarlingUtil.distance(_loc10_.x,_loc10_.y,_loc5_.x,_loc5_.y);
         _loc11_.scale = MathUtil.clamp(_loc11_.scale + (_loc3_ - _loc7_) * 0.01,0.2,HomeDecoScene.imageMaxScale);
         control.setSelectedStamp(view.getUniqueID());
      }
      if(_loc8_ = param1.getTouch(_loc2_,"ended"))
      {
         control.changeScrollEnable(true);
      }
   }
}

import gudetama.data.UserDataWrapper;
import gudetama.data.compati.KitchenwareData;
import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import muku.display.ContainerButton;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

class KitchenwareButton extends UIBase
{
    
   
   private var type:int;
   
   private var button:ContainerButton;
   
   private var image:Image;
   
   private var orgTex:Texture;
   
   function KitchenwareButton(param1:Sprite, param2:int)
   {
      super(param1);
      this.type = param2;
      param1.visibleAllChildren(false);
      button = param1.getChildByName("button") as ContainerButton;
      button.setStopPropagation(true);
      button.visible = true;
      button.touchable = false;
      image = button.getChildByName("image") as Image;
      image.visible = true;
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
         button.visible = true;
         var kitchenwareId:int = UserDataWrapper.kitchenwarePart.getHighestGradeKitchenwareIdByKitchenware(kwData);
         TextureCollector.loadTexture("kitchen0@image" + kitchenwareId,function(param1:Texture):void
         {
            image.texture = param1;
            orgTex = param1;
         });
      }
      else if(!isAvailable && hasKitchenware)
      {
         button.visible = false;
      }
      else
      {
         button.visible = false;
      }
   }
}
