package gudetama.scene.kitchen
{
   import gestouch.events.GestureEvent;
   import gestouch.gestures.SwipeGesture;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.GudetamaDef;
   import gudetama.data.compati.KitchenwareData;
   import gudetama.data.compati.KitchenwareDef;
   import gudetama.data.compati.RecipeNoteDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.Logger;
   import gudetama.engine.SoundManager;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.ui.AcquiredKitchenwareDialog;
   import gudetama.ui.AcquiredRecipeNoteDialog;
   import gudetama.ui.CupItemsListShowDialog;
   import gudetama.ui.LocalMessageDialog;
   import gudetama.ui.LockedRecipeDialog;
   import gudetama.ui.LockedRecipeNoteDialog;
   import gudetama.ui.MessageDialog;
   import gudetama.ui.PurchaseRecipeDialog;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.util.SpriteExtractor;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.display.SpineModel;
   import starling.display.DisplayObject;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class CookingScene extends BaseScene
   {
      
      private static const UPDATE_INTERVAL:int = 1000;
      
      public static const KITCHENWARE_ANIME_START:int = 0;
      
      public static const KITCHENWARE_ANIME_COOKING:int = 1;
      
      public static const KITCHENWARE_ANIME_COMPLETED:int = 2;
      
      public static const KITCHENWARE_ANIME_FAILED:int = 3;
      
      public static const STATE_NONE:int = 0;
      
      public static const STATE_COOKING:int = 1;
      
      public static const STATE_FINISHED:int = 2;
       
      
      private var showCallback:Function;
      
      private var backCallback:Function;
      
      private var kitchenwareType:int;
      
      private var navigateParam:Object;
      
      private var kitchenwareSpineName:String;
      
      private var backgroundImage:Image;
      
      private var kitchenwareBgImage:Image;
      
      private var kitchenwareImage:Image;
      
      private var kitchenwareSpineModel:SpineModel;
      
      private var arrowSpineModel:SpineModel;
      
      private var materialGroupUI:MaterialGroupUI;
      
      private var kitchenwareButton:ContainerButton;
      
      private var cookingTimeUI:CookingTimeUI;
      
      private var hurryButton:ContainerButton;
      
      private var hurryUsefulGroup:Sprite;
      
      private var hurryUsefulImage:Image;
      
      private var hurryUsefulSilverImage:Image;
      
      private var hurryUsefulGoldImage:Image;
      
      private var hurryUsefulFifteenImage:Image;
      
      private var currentHurryUsefulImage:Image;
      
      private var currentHurryUsefulName:String = "balloon_isogi";
      
      private var cancelButton:ContainerButton;
      
      private var recipeButton:ContainerButton;
      
      private var recipeButtonImg:Image;
      
      private var recipeNoteUI:RecipeNoteUI;
      
      private var recipeGroup:Sprite;
      
      private var recipeUI:RecipeUI;
      
      private var confirmUI:ConfirmUI;
      
      private var unlockUI:UnlockUI;
      
      private var pageSpineModel:SpineModel;
      
      private var unlockedRecipeNoteExtractor:SpriteExtractor;
      
      private var lockedRecipeNoteExtractor:SpriteExtractor;
      
      private var unpurchasedRecipeNoteExtractor:SpriteExtractor;
      
      private var recipeGudetamaExtractor:SpriteExtractor;
      
      private var materialExtractor:SpriteExtractor;
      
      private var loadCount:int;
      
      private var state:int = 0;
      
      private var currentKitchenwareAnime:int;
      
      private var nextUpdateTime:int;
      
      private var kitchenwareSE;
      
      private var cachedRsrcNameMap:Object;
      
      private var usefulIds:Array;
      
      private var usefulIndex:int;
      
      private var spCurtain:Sprite;
      
      private var swipeGesture:SwipeGesture;
      
      private var spPageBtn:Sprite;
      
      private var btnL:ContainerButton;
      
      private var btnR:ContainerButton;
      
      private var cupButton:ContainerButton;
      
      private var forceRecipe:Boolean = false;
      
      private var memoryRecipeArray:Array;
      
      public function CookingScene(param1:Function = null, param2:Function = null)
      {
         cachedRsrcNameMap = {};
         memoryRecipeArray = [];
         super(4);
         scenePermanent = true;
         this.showCallback = param1;
         this.backCallback = param2;
         addEventListener("update_scene",updateScene);
      }
      
      public function loadCookingScene(param1:TaskQueue) : void
      {
         var queue:TaskQueue = param1;
         setupLayoutForTask(queue,"CookingLayout",function(param1:Object):void
         {
            var layout:Object = param1;
            displaySprite = layout.object;
            backgroundImage = displaySprite.getChildByName("bg") as Image;
            var dialogSprite:Sprite = displaySprite.getChildByName("dialog") as Sprite;
            var kitchenwareGroup:Sprite = dialogSprite.getChildByName("kitchenwareGroup") as Sprite;
            kitchenwareGroup.touchable = false;
            kitchenwareBgImage = kitchenwareGroup.getChildByName("bg") as Image;
            kitchenwareImage = kitchenwareGroup.getChildByName("kitchenware") as Image;
            kitchenwareSpineModel = kitchenwareGroup.getChildByName("spineModel") as SpineModel;
            arrowSpineModel = kitchenwareGroup.getChildByName("arrowSpineModel") as SpineModel;
            materialGroupUI = new MaterialGroupUI(kitchenwareGroup,scene);
            kitchenwareButton = dialogSprite.getChildByName("kitchenwareButton") as ContainerButton;
            kitchenwareButton.addEventListener("triggered",triggeredKitchenwareButton);
            var cookingSprite:Sprite = dialogSprite.getChildByName("cookingSprite") as Sprite;
            cookingSprite.touchable = false;
            cookingTimeUI = new CookingTimeUI(cookingSprite,scene);
            hurryButton = dialogSprite.getChildByName("hurryButton") as ContainerButton;
            hurryButton.enableDrawCache();
            hurryButton.addEventListener("triggered",triggeredHurryButton);
            hurryUsefulGroup = dialogSprite.getChildByName("usefulGroup") as Sprite;
            hurryUsefulImage = hurryUsefulGroup.getChildByName("useful0") as Image;
            hurryUsefulSilverImage = hurryUsefulGroup.getChildByName("useful1") as Image;
            hurryUsefulGoldImage = hurryUsefulGroup.getChildByName("useful2") as Image;
            hurryUsefulFifteenImage = hurryUsefulGroup.getChildByName("useful3") as Image;
            cancelButton = dialogSprite.getChildByName("cancelButton") as ContainerButton;
            cancelButton.enableDrawCache();
            cancelButton.addEventListener("triggered",triggeredCancelButton);
            recipeButton = dialogSprite.getChildByName("recipeButton") as ContainerButton;
            recipeButton.enableDrawCache();
            recipeButton.addEventListener("triggered",triggeredRecipeButton);
            recipeButton.visible = false;
            recipeButtonImg = recipeButton.getChildByName("recipeButtonImg") as Image;
            recipeNoteUI = new RecipeNoteUI(dialogSprite.getChildByName("recipeNote") as Sprite,scene);
            recipeGroup = dialogSprite.getChildByName("recipeGroup") as Sprite;
            recipeUI = new RecipeUI(recipeGroup.getChildByName("recipe") as Sprite,scene);
            confirmUI = new ConfirmUI(recipeGroup.getChildByName("confirm") as Sprite,scene);
            unlockUI = new UnlockUI(recipeGroup.getChildByName("unlock") as Sprite,scene,hideUnlockUICallback);
            pageSpineModel = recipeGroup.getChildByName("page") as SpineModel;
            spPageBtn = dialogSprite.getChildByName("spPageBtn") as Sprite;
            btnL = (spPageBtn.getChildByName("btnL") as Sprite).getChildByName("ArrowButton") as ContainerButton;
            btnL.addEventListener("triggered",backPage);
            btnR = (spPageBtn.getChildByName("btnR") as Sprite).getChildByName("ArrowButton") as ContainerButton;
            btnR.addEventListener("triggered",nextPage);
            swipeGesture = new SwipeGesture(dialogSprite.getChildByName("quad4Swipe"));
            Engine.setSwipeGestureDefaultParam(swipeGesture);
            swipeGesture.addEventListener("gestureRecognized",gesture);
            spCurtain = displaySprite.getChildByName("spCurtain") as Sprite;
            spCurtain.visible = false;
            cupButton = dialogSprite.getChildByName("cupButton") as ContainerButton;
            cupButton.addEventListener("triggered",showCupGachaLineup);
            displaySprite.visible = false;
            addChild(displaySprite);
            queue.addTask(function():void
            {
               arrowSpineModel.load("efx_spine-arrow",function():void
               {
                  queue.taskDone();
               });
            });
         });
         setupLayoutForTask(queue,"_RecipeItem",function(param1:Object):void
         {
            unlockedRecipeNoteExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         setupLayoutForTask(queue,"_RecipeLock",function(param1:Object):void
         {
            lockedRecipeNoteExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         setupLayoutForTask(queue,"_RecipePurchase",function(param1:Object):void
         {
            unpurchasedRecipeNoteExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         setupLayoutForTask(queue,"_RecipeGudetama",function(param1:Object):void
         {
            recipeGudetamaExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         setupLayoutForTask(queue,"_Material",function(param1:Object):void
         {
            materialExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
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
         materialGroupUI.init(materialExtractor);
      }
      
      public function setupCookingScene(param1:TaskQueue, param2:int, param3:Object = null) : void
      {
         var queue:TaskQueue = param1;
         var kitchenwareType:int = param2;
         var navigateParam:Object = param3;
         this.kitchenwareType = kitchenwareType;
         this.navigateParam = navigateParam;
         var kitchenwareId:int = UserDataWrapper.kitchenwarePart.getHighestGradeKitchenwareId(kitchenwareType);
         var kitchenwareDef:KitchenwareDef = GameSetting.getKitchenware(kitchenwareId);
         recipeNoteUI.setupSpriteManager(unlockedRecipeNoteExtractor,lockedRecipeNoteExtractor,unpurchasedRecipeNoteExtractor);
         recipeUI.setupSpriteManager(recipeGudetamaExtractor);
         recipeNoteUI.setVisible(false);
         recipeGroup.visible = false;
         recipeUI.setVisible(false);
         confirmUI.setVisible(false);
         unlockUI.setVisible(false);
         currentKitchenwareAnime = -1;
         setPageChangeEnable(true);
         queue.addTask(function():void
         {
            loadTexture("bg-background_kitchenware" + kitchenwareType,function(param1:Texture):void
            {
               backgroundImage.texture = param1;
               backgroundImage.width = param1.width;
               backgroundImage.height = param1.height;
               queue.taskDone();
            });
         });
         if(kitchenwareType != 4)
         {
            queue.addTask(function():void
            {
               loadTexture("cooking-" + kitchenwareType,function(param1:Texture):void
               {
                  kitchenwareBgImage.texture = param1;
                  kitchenwareBgImage.width = param1.width;
                  kitchenwareBgImage.height = param1.height;
                  var _loc2_:KitchenwareDef = GameSetting.getKitchenwareByType(kitchenwareType,0);
                  kitchenwareBgImage.x = _loc2_.bgPos[0];
                  kitchenwareBgImage.y = _loc2_.bgPos[1];
                  queue.taskDone();
               });
            });
         }
         if(kitchenwareDef.existsImage)
         {
            queue.addTask(function():void
            {
               loadTexture("kitchenware-" + kitchenwareDef.rsrc + "-bg",function(param1:Texture):void
               {
                  kitchenwareImage.texture = param1;
                  kitchenwareImage.readjustSize();
                  kitchenwareImage.pivotX = 0.5 * kitchenwareImage.width;
                  kitchenwareImage.visible = true;
                  queue.taskDone();
               });
            });
         }
         else
         {
            kitchenwareImage.visible = false;
         }
         queue.addTask(function():void
         {
            kitchenwareSpineName = "kitchenware-" + kitchenwareDef.rsrc + "-bg_spine2";
            kitchenwareSpineModel.finish();
            kitchenwareSpineModel.load(kitchenwareSpineName,function():void
            {
               kitchenwareSpineModel.show();
               kitchenwareSpineModel.changeAnimation("start",true);
               queue.taskDone();
            });
         });
         var kitchenwareMap:Object = GameSetting.getKitchenwareMap();
         for each(kitchenware in kitchenwareMap)
         {
            queue.addTask(function():void
            {
               TextureCollector.loadTexture("recipe0@recipe" + kitchenware.type,function(param1:Texture):void
               {
                  queue.taskDone();
               });
            });
         }
         arrowSpineModel.visible = false;
         queue.addTask(function():void
         {
            setup(function():void
            {
               queue.taskDone();
            },-1,true);
         });
      }
      
      private function setup(param1:Function, param2:int = -1, param3:Boolean = false) : void
      {
         var callback:Function = param1;
         var grade:int = param2;
         var navigate:Boolean = param3;
         forceRecipe = false;
         cupButton.visible = false;
         var queue:TaskQueue = new TaskQueue();
         if(recipeButtonImg)
         {
            queue.addTask(function():void
            {
               TextureCollector.loadTexture("recipe0@recipe" + kitchenwareType,function(param1:Texture):void
               {
                  recipeButtonImg.texture = param1;
                  queue.taskDone();
               });
            });
         }
         if(navigate && navigateParam && navigateParam.forceRecipeOnetime)
         {
            forceRecipe = true;
            navigateParam = null;
         }
         if(navigate && navigateParam && navigateParam.forceRecipe)
         {
            forceRecipe = true;
         }
         if(finishedCooking())
         {
            setupCookedUI();
         }
         else if(isCooking())
         {
            setupCookingUI(queue);
         }
         else
         {
            if(navigate && navigateParam)
            {
               var kitchenwareDef:KitchenwareDef = GameSetting.getKitchenware(navigateParam.kitchenwareId);
               var grade:int = kitchenwareDef.grade;
               if(navigateParam.recipeNoteId)
               {
                  setupRecipeUI(queue,navigateParam.recipeNoteId);
               }
            }
            cupButton.visible = checkHasCupGachaLineup(grade);
            setupRecipeNoteUI(queue,grade);
         }
         materialGroupUI.setup(queue,kitchenwareType);
         queue.registerOnProgress(function(param1:Number):void
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
         queue.startTask();
      }
      
      private function checkHasCupGachaLineup(param1:int) : Boolean
      {
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         var _loc6_:* = null;
         var _loc2_:Array = UserDataWrapper.wrapper.createPossessingRecipeNoteIds(kitchenwareType,param1 == -1 ? 0 : param1);
         var _loc3_:Boolean = false;
         _loc5_ = 0;
         while(_loc5_ < _loc2_.length)
         {
            _loc4_ = _loc2_[_loc5_];
            _loc6_ = GameSetting.getRecipeNote(_loc4_);
            if(!_loc3_ && _loc6_.hasBonusPrize)
            {
               _loc3_ = true;
            }
            _loc5_++;
         }
         return _loc3_;
      }
      
      private function setupRecipeNoteUI(param1:TaskQueue, param2:int) : void
      {
         kitchenwareButton.touchable = false;
         cookingTimeUI.setVisible(false);
         hurryButton.visible = false;
         hurryUsefulGroup.visible = false;
         cancelButton.visible = false;
         recipeButton.visible = false;
         recipeNoteUI.setup(param1,kitchenwareType,param2);
         kitchenwareSpineModel.changeAnimation("start");
         state = 0;
      }
      
      public function setupRecipeUI(param1:TaskQueue, param2:int) : void
      {
         kitchenwareButton.touchable = false;
         cookingTimeUI.setVisible(false);
         hurryButton.visible = false;
         hurryUsefulGroup.visible = false;
         cancelButton.visible = false;
         recipeButton.visible = false;
         recipeUI.setup(param1,param2);
         state = 0;
      }
      
      private function setupCookingUI(param1:TaskQueue) : void
      {
         var _loc2_:int = UserDataWrapper.kitchenwarePart.getGudetamaId(kitchenwareType);
         kitchenwareButton.touchable = false;
         cookingTimeUI.setVisible(true);
         cookingTimeUI.setup(param1,kitchenwareType);
         if(!isTutorial())
         {
            hurryButton.visible = true;
         }
         else
         {
            hurryButton.visible = false;
         }
         usefulIds = UserDataWrapper.wrapper.getHurryUsefulId(_loc2_,kitchenwareType);
         currentHurryUsefulImage = null;
         usefulIndex = 0;
         TweenAnimator.finishItself(hurryUsefulGroup);
         TweenAnimator.cancelTween(hurryUsefulGoldImage);
         TweenAnimator.cancelTween(hurryUsefulSilverImage);
         TweenAnimator.cancelTween(hurryUsefulImage);
         TweenAnimator.cancelTween(hurryUsefulFifteenImage);
         hurryUsefulGoldImage.visible = false;
         hurryUsefulSilverImage.visible = false;
         hurryUsefulImage.visible = false;
         hurryUsefulFifteenImage.visible = false;
         hurryUsefulGoldImage.alpha = 1;
         hurryUsefulSilverImage.alpha = 1;
         hurryUsefulImage.alpha = 1;
         hurryUsefulFifteenImage.alpha = 1;
         hurryUsefulGroup.visible = usefulIds && usefulIds.length > 0;
         if(hurryUsefulGroup.visible)
         {
            if(usefulIds && usefulIds.length > 0)
            {
               TweenAnimator.startItself(hurryUsefulGroup,"show",true);
               checkHurryImage();
            }
         }
         cancelButton.visible = true;
         if(!finishedCooking())
         {
            recipeButton.visible = true;
         }
         changeSetupKitchenwareAnime(1);
         state = 1;
      }
      
      private function checkHurryImage() : void
      {
         var _loc1_:int = 0;
         if(usefulIds.length > 1)
         {
            showHurryImage();
         }
         else
         {
            _loc1_ = usefulIds[0];
            if(_loc1_ == 62)
            {
               hurryUsefulGoldImage.visible = true;
               hurryUsefulSilverImage.visible = false;
               hurryUsefulImage.visible = false;
               hurryUsefulFifteenImage.visible = false;
            }
            else if(_loc1_ == 63)
            {
               hurryUsefulGoldImage.visible = false;
               hurryUsefulSilverImage.visible = true;
               hurryUsefulImage.visible = false;
               hurryUsefulFifteenImage.visible = false;
            }
            else if(_loc1_ == 64)
            {
               hurryUsefulGoldImage.visible = false;
               hurryUsefulSilverImage.visible = false;
               hurryUsefulImage.visible = false;
               hurryUsefulFifteenImage.visible = true;
            }
            else
            {
               hurryUsefulGoldImage.visible = false;
               hurryUsefulSilverImage.visible = false;
               hurryUsefulImage.visible = true;
               hurryUsefulFifteenImage.visible = false;
            }
         }
      }
      
      private function showHurryImage(param1:Object = null) : void
      {
         var args:Object = param1;
         if(currentHurryUsefulImage)
         {
            var lastHurryUsefulImage:Image = currentHurryUsefulImage;
            TweenAnimator.finishItself(lastHurryUsefulImage);
            TweenAnimator.startItself(lastHurryUsefulImage,"fadeOut",true,function():void
            {
               lastHurryUsefulImage.visible = false;
            });
         }
         var usefulId:int = usefulIds[usefulIndex++ % usefulIds.length];
         if(usefulId == 62)
         {
            hurryUsefulGoldImage.visible = true;
            TweenAnimator.finishItself(hurryUsefulGoldImage);
            TweenAnimator.startItself(hurryUsefulGoldImage,"fadeIn",true,showHurryImage);
            currentHurryUsefulImage = hurryUsefulGoldImage;
         }
         else if(usefulId == 63)
         {
            hurryUsefulSilverImage.visible = true;
            TweenAnimator.finishItself(hurryUsefulSilverImage);
            TweenAnimator.startItself(hurryUsefulSilverImage,"fadeIn",true,showHurryImage);
            currentHurryUsefulImage = hurryUsefulSilverImage;
         }
         else if(usefulId == 64)
         {
            hurryUsefulFifteenImage.visible = true;
            TweenAnimator.finishItself(hurryUsefulFifteenImage);
            TweenAnimator.startItself(hurryUsefulFifteenImage,"fadeIn",true,showHurryImage);
            currentHurryUsefulImage = hurryUsefulFifteenImage;
         }
         else
         {
            hurryUsefulImage.visible = true;
            TweenAnimator.finishItself(hurryUsefulImage);
            TweenAnimator.startItself(hurryUsefulImage,"fadeIn",true,showHurryImage);
            currentHurryUsefulImage = hurryUsefulImage;
         }
      }
      
      private function setupCookedUI() : void
      {
         kitchenwareButton.touchable = true;
         cookingTimeUI.setVisible(false);
         hurryButton.visible = false;
         hurryUsefulGroup.visible = false;
         cancelButton.visible = false;
         changeSetupKitchenwareAnime(2);
         state = 2;
      }
      
      override protected function setupProgressForPermanent(param1:Function) : void
      {
         var onProgress:Function = param1;
         queue = new TaskQueue();
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
         Engine.lockTouchInput(CookingScene);
         if(!isTutorial())
         {
            showResidentMenuUI(94);
         }
         else
         {
            showResidentMenuUI(70);
         }
         displaySprite.visible = true;
         spCurtain.visible = false;
      }
      
      override protected function transitionOpenFinished() : void
      {
         show(function():void
         {
            var _loc1_:* = null;
            if(navigateParam && navigateParam.gudetamaId && !isCooking())
            {
               _loc1_ = GameSetting.getRecipeNote(navigateParam.recipeNoteId);
               if(_loc1_.existsInRecipe(navigateParam.gudetamaId))
               {
                  setupForConfirm(navigateParam.gudetamaId,navigateParam.recipeNoteId,false);
               }
            }
            Engine.unlockTouchInput(CookingScene);
         },true,false,true);
         Engine.lockTouchInput(displaySprite);
         TweenAnimator.startItself(displaySprite,"fadeIn",true,function():void
         {
            Engine.unlockTouchInput(displaySprite);
            if(showCallback)
            {
               showCallback();
            }
         });
         TweenAnimator.startItself(btnL,"start");
         TweenAnimator.startItself(btnR,"start");
      }
      
      override protected function setBackButtonCallback(param1:Function) : void
      {
         super.setBackButtonCallback(!isTutorial() ? param1 : null);
      }
      
      public function show(param1:Function, param2:Boolean, param3:Boolean, param4:Boolean = false) : void
      {
         var callback:Function = param1;
         var recipeNoteAnimation:Boolean = param2;
         var spineAnimation:Boolean = param3;
         var navigate:Boolean = param4;
         var queue:TaskQueue = new TaskQueue();
         if(finishedCooking())
         {
            showCookedUI(spineAnimation);
            setBackButtonCallback(backButtonCallback);
         }
         else if(isCooking())
         {
            recipeNoteUI.setVisible(false);
            recipeGroup.visible = false;
            recipeUI.setVisible(false);
            confirmUI.setVisible(false);
            unlockUI.setVisible(false);
            changeKitchenwareAnime(1,spineAnimation);
            arrowSpineModel.hide();
            setBackButtonCallback(backButtonCallback);
         }
         else
         {
            changeKitchenwareAnime(0,spineAnimation);
            arrowSpineModel.hide();
            if(navigate && navigateParam && navigateParam.recipeNoteId)
            {
               showRecipeUI(queue);
               setBackButtonCallback(setupForRecipeNoteBackKey);
            }
            else
            {
               showRecipeNoteUI(queue,recipeNoteAnimation);
               setBackButtonCallback(backButtonCallback);
            }
         }
         materialGroupUI.show(spineAnimation);
         setRoomButtonCallback(backButtonCallback);
         queue.registerOnProgress(function(param1:Number):void
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
         queue.startTask();
      }
      
      private function checkPlayKitchenwareSE() : Boolean
      {
         if(kitchenwareSE is int)
         {
            return kitchenwareSE > 0;
         }
         return kitchenwareSE != null;
      }
      
      override protected function focusLost() : void
      {
         if(checkPlayKitchenwareSE())
         {
            SoundManager.stopEffectAll();
         }
      }
      
      override protected function focusGainedFinish() : void
      {
         SoundManager.stopEffectAll();
         if(checkPlayKitchenwareSE())
         {
            switch(int(kitchenwareType))
            {
               case 0:
                  SoundManager.playEffect("ChopBoard_Cooking",100,0,function(param1:*):void
                  {
                     kitchenwareSE = param1;
                  });
                  break;
               case 1:
                  SoundManager.playEffect("Pan_Cooking",100,0,function(param1:*):void
                  {
                     kitchenwareSE = param1;
                  });
                  break;
               case 2:
                  SoundManager.playEffect("Pot_Cooking",100,0,function(param1:*):void
                  {
                     kitchenwareSE = param1;
                  });
                  break;
               case 3:
                  SoundManager.playEffect("Microwave_Cooking",100,0,function(param1:*):void
                  {
                     kitchenwareSE = param1;
                  });
                  break;
               default:
                  SoundManager.playEffect("ChopBoard_Cooking",100,0,function(param1:*):void
                  {
                     kitchenwareSE = param1;
                  });
            }
         }
      }
      
      private function changeSetupKitchenwareAnime(param1:int) : void
      {
         if(currentKitchenwareAnime == param1)
         {
            return;
         }
         if(param1 == 2)
         {
            kitchenwareSpineModel.changeAnimation("cook_loop");
         }
         else
         {
            kitchenwareSpineModel.changeAnimation("start");
         }
      }
      
      private function changeKitchenwareAnime(param1:int, param2:Boolean) : void
      {
         var anime:int = param1;
         var spineAnimation:Boolean = param2;
         if(currentKitchenwareAnime == anime)
         {
            return;
         }
         SoundManager.stopEffect(kitchenwareSE);
         if(anime == 0)
         {
            kitchenwareSpineModel.changeAnimation("start");
         }
         else if(anime == 1)
         {
            var cookingSound:Function = function():void
            {
               SoundManager.stopEffectAll();
               switch(int(kitchenwareType))
               {
                  case 0:
                     SoundManager.playEffect("ChopBoard_Cooking",100,0,function(param1:*):void
                     {
                        kitchenwareSE = param1;
                     });
                     break;
                  case 1:
                     SoundManager.playEffect("Pan_Cooking",100,0,function(param1:*):void
                     {
                        kitchenwareSE = param1;
                     });
                     break;
                  case 2:
                     SoundManager.playEffect("Pot_Cooking",100,0,function(param1:*):void
                     {
                        kitchenwareSE = param1;
                     });
                     break;
                  case 3:
                     SoundManager.playEffect("Microwave_Cooking",100,0,function(param1:*):void
                     {
                        kitchenwareSE = param1;
                     });
                     break;
                  default:
                     SoundManager.playEffect("ChopBoard_Cooking",100,0,function(param1:*):void
                     {
                        kitchenwareSE = param1;
                     });
               }
            };
            if(spineAnimation)
            {
               SoundManager.playEffect("egg_jump");
               kitchenwareSpineModel.changeAnimation("cook_start",false,function():void
               {
                  kitchenwareSpineModel.changeAnimation("cook_loop");
                  cookingSound();
               });
            }
            else
            {
               kitchenwareSpineModel.changeAnimation("cook_loop");
               cookingSound();
            }
         }
         else if(anime == 2)
         {
            SoundManager.stopEffectAll();
            SoundManager.playEffect("Cook_Finish");
            kitchenwareSpineModel.changeAnimation("complete_start",true,function():void
            {
               kitchenwareSpineModel.changeAnimation("complete_loop");
            });
         }
         else if(anime == 3)
         {
            SoundManager.playEffect("Cook_Finish");
            kitchenwareSpineModel.changeAnimation("fail_start",false,function():void
            {
               kitchenwareSpineModel.changeAnimation("fail_loop");
            });
         }
         currentKitchenwareAnime = anime;
      }
      
      private function showCookedUI(param1:Boolean) : void
      {
         kitchenwareButton.touchable = true;
         cookingTimeUI.setVisible(false);
         hurryButton.visible = false;
         hurryUsefulGroup.visible = false;
         cancelButton.visible = false;
         state = 2;
         recipeNoteUI.setVisible(false);
         recipeGroup.visible = false;
         recipeUI.setVisible(false);
         confirmUI.setVisible(false);
         unlockUI.setVisible(false);
         recipeButton.visible = false;
         if(UserDataWrapper.kitchenwarePart.isCookingTooMatchTime(kitchenwareType))
         {
            changeKitchenwareAnime(3,param1);
         }
         else
         {
            changeKitchenwareAnime(2,param1);
         }
         arrowSpineModel.show();
         arrowSpineModel.changeAnimation("start_loop",true);
      }
      
      private function showRecipeNoteUI(param1:TaskQueue, param2:Boolean) : void
      {
         var queue:TaskQueue = param1;
         var recipeNoteAnimation:Boolean = param2;
         if(recipeNoteAnimation)
         {
            SoundManager.playEffect("Recipe_PageNext");
            queue.addTask(function():void
            {
               recipeNoteUI.setVisible(true);
               recipeNoteUI.startTween("show",true,function():void
               {
                  recipeNoteUI.show();
                  processTutorial();
                  queue.taskDone();
               });
            });
            if(recipeUI.isVisible())
            {
               queue.addTask(function():void
               {
                  recipeUI.startTween("hide",true,function():void
                  {
                     recipeUI.setVisible(false);
                     queue.taskDone();
                  });
               });
            }
            if(confirmUI.isVisible())
            {
               queue.addTask(function():void
               {
                  confirmUI.startTween("hide",true,function():void
                  {
                     confirmUI.setVisible(false);
                     queue.taskDone();
                  });
               });
            }
            if(recipeGroup.visible)
            {
               queue.addTask(function():void
               {
                  TweenAnimator.startItself(recipeGroup,"hide",true,function():void
                  {
                     recipeGroup.visible = false;
                     queue.taskDone();
                  });
               });
            }
         }
         else
         {
            recipeNoteUI.setVisible(true);
            recipeNoteUI.setAlpha(1);
            recipeNoteUI.show();
            recipeGroup.visible = false;
            recipeUI.setVisible(false);
            confirmUI.setVisible(false);
            unlockUI.setVisible(false);
         }
      }
      
      private function showRecipeUI(param1:TaskQueue, param2:Boolean = false) : void
      {
         var queue:TaskQueue = param1;
         var animation:Boolean = param2;
         setPageChangeEnable(false);
         queue.addTask(function():void
         {
            pageSpineModel.visible = false;
            if(animation)
            {
               var innerQueue:TaskQueue = new TaskQueue();
               SoundManager.playEffect("Recipe_PageNext");
               if(recipeNoteUI.isVisible())
               {
                  innerQueue.addTask(function():void
                  {
                     recipeNoteUI.startTween("hide",true,function():void
                     {
                        recipeNoteUI.setVisible(false);
                        innerQueue.taskDone();
                     });
                  });
               }
               RecipeNoteDef;
               if(!recipeGroup.visible)
               {
                  innerQueue.addTask(function():void
                  {
                     recipeGroup.visible = true;
                     TweenAnimator.startItself(recipeGroup,"show",true,function():void
                     {
                        processTutorial();
                        innerQueue.taskDone();
                     });
                  });
               }
               if(!recipeUI.isVisible())
               {
                  recipeUI.setVisible(true);
                  innerQueue.addTask(function():void
                  {
                     recipeUI.startTween("show",true,function():void
                     {
                        innerQueue.taskDone();
                     });
                  });
               }
               if(confirmUI.isVisible())
               {
                  innerQueue.addTask(function():void
                  {
                     confirmUI.startTween("hide",true,function():void
                     {
                        confirmUI.setVisible(false);
                        innerQueue.taskDone();
                     });
                  });
                  innerQueue.addTask(function():void
                  {
                     pageSpineModel.visible = true;
                     pageSpineModel.show();
                     pageSpineModel.changeAnimation("start2",false,function():void
                     {
                        pageSpineModel.hide();
                        innerQueue.taskDone();
                     });
                  });
               }
               if(unlockUI.isVisible())
               {
                  unlockUI.setVisible(false);
               }
               innerQueue.registerOnProgress(function(param1:Number):void
               {
                  if(param1 < 1)
                  {
                     return;
                  }
                  recipeUI.show();
                  queue.taskDone();
               });
               innerQueue.startTask();
            }
            else
            {
               TweenAnimator.startItself(recipeGroup,"show",true,function():void
               {
                  recipeNoteUI.setVisible(false);
                  recipeNoteUI.setAlpha(1);
                  recipeGroup.visible = true;
                  recipeUI.setVisible(true);
                  recipeUI.setAlpha(1);
                  recipeUI.show();
                  confirmUI.setVisible(false);
                  unlockUI.setVisible(false);
                  queue.taskDone();
               });
            }
         });
      }
      
      private function checkBackRecipe() : Boolean
      {
         var _loc1_:int = -1;
         var _loc2_:Object = null;
         var _loc3_:Object = memoryRecipeArray.pop();
         if(_loc3_)
         {
            _loc2_ = _loc3_.param;
            if(_loc2_.memoryType == 1)
            {
               return false;
            }
            _loc1_ = _loc3_.kitchenwareType;
         }
         if(_loc1_ > -1 && _loc2_)
         {
            changePageAnime(_loc1_,false,_loc2_);
            _loc1_ = -1;
            _loc2_ = null;
            return true;
         }
         return false;
      }
      
      public function setState(param1:int) : void
      {
         setVisibleState(param1);
      }
      
      private function setupAndShow(param1:Function, param2:int = -1, param3:Boolean = false, param4:Boolean = false, param5:Boolean = false) : void
      {
         var callback:Function = param1;
         var grade:int = param2;
         var recipeNoteAnimation:Boolean = param3;
         var spineAnimation:Boolean = param4;
         var navigate:Boolean = param5;
         setup(function():void
         {
            show(callback,recipeNoteAnimation,spineAnimation,navigate);
         },grade,navigate);
      }
      
      override public function advanceTime(param1:Number) : void
      {
         super.advanceTime(param1);
         if(state == 1)
         {
            if(Engine.now < nextUpdateTime)
            {
               return;
            }
            cookingTimeUI.advanceTime(param1);
            if(finishedCooking())
            {
               showCookedUI(true);
            }
            nextUpdateTime = Engine.now + 1000;
         }
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         resetMemoryRecipeArray();
         forceRecipe = false;
         Engine.broadcastEventToSceneStackWith("update_scene");
         SoundManager.stopEffectAll();
         ResidentMenuUI_Gudetama.getInstance().sendChangeState(60,function():void
         {
            Engine.hideLoading();
            backCallback();
         },false,true);
      }
      
      public function fadeOut() : void
      {
         Engine.lockTouchInput(displaySprite);
         TweenAnimator.startItself(displaySprite,"fadeOut",false,function():void
         {
            SoundManager.stopEffectAll();
            clearCache();
            Engine.unlockTouchInput(displaySprite);
            Engine.popScene(scene);
         });
      }
      
      public function loadTexture(param1:String, param2:Function) : void
      {
         TextureCollector.loadTexture(param1,param2);
         cachedRsrcNameMap[param1] = param1;
      }
      
      private function clearCache() : void
      {
         for(var _loc1_ in cachedRsrcNameMap)
         {
            TextureCollector.clearAtName(_loc1_);
         }
         cachedRsrcNameMap = {};
         kitchenwareSpineModel.finish();
         Engine.removeSpineCache(kitchenwareSpineName);
      }
      
      private function triggeredKitchenwareButton(param1:Event) : void
      {
         SoundManager.stopEffectAll();
         RouletteDialog.show(kitchenwareType,triggeredClosedCurtainInRouletteDialog,triggeredOpenedCurtainInRouletteDialog);
      }
      
      private function triggeredClosedCurtainInRouletteDialog() : void
      {
         Engine.lockTouchInput(CookingScene);
         updateScene();
         currentKitchenwareAnime = -1;
         setupAndShow(function():void
         {
            Engine.unlockTouchInput(CookingScene);
         });
      }
      
      private function triggeredOpenedCurtainInRouletteDialog() : void
      {
         AcquiredKitchenwareDialog.show(function():void
         {
            AcquiredRecipeNoteDialog.show(function():void
            {
               ResidentMenuUI_Gudetama.getInstance().checkClearedMission(function():void
               {
               });
            });
         });
      }
      
      public function setupForRecipeNoteWithAnime(param1:int = -1, param2:Function = null) : void
      {
         setupForRecipeNote(param1,true,false,param2);
      }
      
      public function setupForRecipeNoteBackKey(param1:int = -1, param2:Boolean = false, param3:Boolean = false, param4:Function = null) : void
      {
         setupForRecipeNote(param1,param2,param3,param4);
      }
      
      public function setupForRecipeNoteWithForceNavi(param1:int = -1, param2:Boolean = false, param3:Boolean = false, param4:Function = null, param5:Boolean = false) : void
      {
         navigateParam = {"forceRecipeOnetime":true};
         setupForRecipeNote(param1,param2,param3,param4,param5);
      }
      
      public function setupForRecipeNote(param1:int = -1, param2:Boolean = false, param3:Boolean = false, param4:Function = null, param5:Boolean = false) : void
      {
         var grade:int = param1;
         var recipeNoteAnimation:Boolean = param2;
         var spineAnimation:Boolean = param3;
         var callback:Function = param4;
         var navigate:Boolean = param5;
         if(checkBackRecipe())
         {
            return;
         }
         var grade:int = grade >= 0 ? grade : int(recipeNoteUI.currentGrade());
         Engine.lockTouchInput(CookingScene);
         setupAndShow(function():void
         {
            setBackButtonCallback(backButtonCallback);
            Engine.unlockTouchInput(CookingScene);
            setPageChangeEnable(true);
            if(callback)
            {
               callback();
            }
            processTutorial();
         },grade,recipeNoteAnimation,spineAnimation,navigate);
      }
      
      private function triggeredHurryButton(param1:Event) : void
      {
         var _loc2_:int = UserDataWrapper.kitchenwarePart.getGudetamaId(kitchenwareType);
         var _loc3_:Array = UserDataWrapper.wrapper.getAllHurryUsefulId(_loc2_,kitchenwareType);
         if(kitchenwareType == 4 && _loc3_ && _loc3_.length > 0)
         {
            HurryUpSelectDialog.show(kitchenwareType,refresh);
         }
         else if(checkUsefulIds(_loc3_))
         {
            HurryUpUsuallyDialog.show(kitchenwareType,_loc3_[0],refresh);
         }
         else
         {
            HurryUpMetalDialog.show(kitchenwareType,refresh);
         }
      }
      
      private function checkUsefulIds(param1:Array) : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(usefulIds && usefulIds.length == 1)
         {
            _loc2_ = usefulIds[0];
            _loc3_ = UserDataWrapper.usefulPart.getNumUseful(_loc2_);
            return _loc3_ > 0;
         }
         return false;
      }
      
      private function refresh() : void
      {
         setupAndShow(null);
      }
      
      private function triggeredCancelButton(param1:Event) : void
      {
         var event:Event = param1;
         CookingCancelDialog.show(function(param1:int):void
         {
            if(param1 == 0)
            {
               cancelCooking();
            }
         });
      }
      
      private function triggeredRecipeButton(param1:Event) : void
      {
         forceRecipe = true;
         var _loc2_:Object = {"forceRecipeOnetime":true};
         var _loc3_:int = kitchenwareType;
         changePageAnime(_loc3_,false,_loc2_);
      }
      
      private function cancelCooking() : void
      {
         SoundManager.stopEffect(kitchenwareSE);
         Engine.showLoading(CookingScene);
         var _loc1_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(134217910,kitchenwareType),function(param1:Array):void
         {
            var response:Array = param1;
            Engine.hideLoading(CookingScene);
            if(response[0] is int)
            {
               if(response[0] == 0)
               {
                  LocalMessageDialog.show(0,GameSetting.getUIText("cooking.cancel.completed.desc"),null,GameSetting.getUIText("cooking.cancel.title"));
               }
               return;
            }
            var kitchenwareData:KitchenwareData = response[0];
            var refundCost:int = response[1][0];
            UserDataWrapper.kitchenwarePart.addKitchenware(kitchenwareData);
            if(refundCost > 0)
            {
               ResidentMenuUI_Gudetama.addFreeMoney(refundCost);
            }
            ResidentMenuUI_Gudetama.getInstance().updateUserInfo();
            setupForRecipeNote(-1,false,false,function():void
            {
               LocalMessageDialog.show(0,GameSetting.getUIText("cooking.cancel.desc"),null,GameSetting.getUIText("cooking.cancel.title"));
            });
         });
      }
      
      public function setupForRecipeWithAnimeBackKey(param1:int = -1) : void
      {
         if(checkBackRecipe())
         {
            return;
         }
         setupForRecipeWithAnime(param1);
      }
      
      public function setupForRecipeWithAnime(param1:int = -1) : void
      {
         setupForRecipe(param1,true);
      }
      
      private function setupForRecipe(param1:int = -1, param2:Boolean = false) : void
      {
         var recipeNoteId:int = param1;
         var animation:Boolean = param2;
         var recipeNoteId:int = recipeNoteId >= 0 ? recipeNoteId : int(recipeUI.currentRecipeNoteId);
         Engine.lockTouchInput(CookingScene);
         var queue:TaskQueue = new TaskQueue();
         setupRecipeUI(queue,recipeNoteId);
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            showForRecipe(animation);
         });
         queue.startTask();
      }
      
      private function showForRecipe(param1:Boolean) : void
      {
         var animation:Boolean = param1;
         var queue:TaskQueue = new TaskQueue();
         showRecipeUI(queue,animation);
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            setBackButtonCallback(setupForRecipeNoteWithAnime);
            Engine.unlockTouchInput(CookingScene);
         });
         queue.startTask();
      }
      
      public function triggeredLockedRecipeNoteItemUICallback(param1:int) : void
      {
         LockedRecipeNoteDialog.show(param1);
      }
      
      public function triggeredPurchaseRecipeNoteItemUICallback(param1:int) : void
      {
         var recipeNoteId:int = param1;
         PurchaseRecipeDialog.show(recipeNoteId,function(param1:Boolean):void
         {
            var _close:Boolean = param1;
            setupForRecipeNote();
            AcquiredKitchenwareDialog.show(function():void
            {
               AcquiredRecipeNoteDialog.show();
            });
         });
      }
      
      public function setupForConfirm(param1:int, param2:int, param3:Boolean = true) : void
      {
         var gudetamaId:int = param1;
         var recipeNoteId:int = param2;
         var isCallback:Boolean = param3;
         if(isCallback)
         {
            addMemoryRecipeArray(false);
         }
         Engine.lockTouchInput(CookingScene);
         var queue:TaskQueue = new TaskQueue();
         setupConfirmUI(queue,gudetamaId,recipeNoteId);
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            showForConfirm();
         });
         queue.startTask();
      }
      
      private function showForConfirm() : void
      {
         var queue:TaskQueue = new TaskQueue();
         showConfirmUI(queue);
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            setBackButtonCallback(setupForRecipeWithAnimeBackKey);
            Engine.unlockTouchInput(CookingScene);
         });
         queue.startTask();
      }
      
      public function setupConfirmUI(param1:TaskQueue, param2:int, param3:int) : void
      {
         kitchenwareButton.touchable = false;
         cookingTimeUI.setVisible(false);
         hurryButton.visible = false;
         hurryUsefulGroup.visible = false;
         cancelButton.visible = false;
         recipeButton.visible = false;
         confirmUI.setup(param1,param2,param3,kitchenwareType);
         state = 0;
         processTutorial();
      }
      
      private function showConfirmUI(param1:TaskQueue) : void
      {
         var queue:TaskQueue = param1;
         recipeNoteUI.setVisible(false);
         recipeGroup.visible = true;
         queue.addTask(function():void
         {
            recipeUI.startTween("hide",true,function():void
            {
               recipeUI.setVisible(false);
               queue.taskDone();
            });
         });
         queue.addTask(function():void
         {
            confirmUI.setVisible(true);
            confirmUI.startTween("show",true,function():void
            {
               queue.taskDone();
            });
         });
         queue.addTask(function():void
         {
            pageSpineModel.visible = true;
            pageSpineModel.show();
            pageSpineModel.changeAnimation("start",false,function():void
            {
               pageSpineModel.hide();
               queue.taskDone();
            });
         });
      }
      
      public function setupUnlockUI(param1:TaskQueue, param2:int) : void
      {
         unlockUI.setup(param1,param2);
      }
      
      public function showUnlockUI() : void
      {
         setBackButtonCallback(null);
         unlockUI.show(function():void
         {
            setBackButtonCallback(hideUnlockUICallback);
         });
      }
      
      private function hideUnlockUICallback() : void
      {
         confirmUI.setVisible(true);
         unlockUI.setVisible(false);
         setBackButtonCallback(setupForRecipeWithAnimeBackKey);
      }
      
      public function triggeredLockedRecipeGudetamaItemUICallback(param1:int) : void
      {
         LockedRecipeDialog.show(param1);
      }
      
      public function updateScene() : void
      {
         var _loc1_:int = 0;
         var _loc2_:* = null;
         recipeUI.refresh();
         confirmUI.update();
         if(hurryButton.visible)
         {
            _loc1_ = UserDataWrapper.kitchenwarePart.getGudetamaId(kitchenwareType);
            _loc2_ = UserDataWrapper.wrapper.getHurryUsefulId(_loc1_,kitchenwareType);
            currentHurryUsefulImage = null;
            usefulIndex = 0;
            TweenAnimator.finishItself(hurryUsefulGroup);
            TweenAnimator.cancelTween(hurryUsefulGoldImage);
            TweenAnimator.cancelTween(hurryUsefulSilverImage);
            TweenAnimator.cancelTween(hurryUsefulImage);
            hurryUsefulGoldImage.visible = false;
            hurryUsefulSilverImage.visible = false;
            hurryUsefulImage.visible = false;
            hurryUsefulGroup.visible = _loc2_ && _loc2_.length > 0;
            if(hurryUsefulGroup.visible)
            {
               if(_loc2_ && _loc2_.length > 0)
               {
                  TweenAnimator.startItself(hurryUsefulGroup,"show",true);
                  checkHurryImage();
               }
            }
         }
      }
      
      public function tutorialAction(param1:int) : void
      {
         var index:int = param1;
         switch(int(index))
         {
            case 0:
               break;
            case 1:
               break;
            case 2:
               var restTimeSecs:int = UserDataWrapper.kitchenwarePart.getRestCookingTime(kitchenwareType);
               var hurryUpReduceSecs:int = GameSetting.def.rule.hurryUpReduceMinutesPerMetal * 60;
               var max:int = Math.ceil(restTimeSecs / hurryUpReduceSecs);
               var _loc3_:* = HttpConnector;
               if(gudetama.net.HttpConnector.mainConnector == null)
               {
                  gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
               }
               gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(134217911,[kitchenwareType,max - 1,!isTutorial()]),function(param1:Array):void
               {
                  if(param1[0] is int)
                  {
                     if(param1[0] == 0)
                     {
                     }
                     return;
                  }
                  var _loc2_:KitchenwareData = param1[0];
                  UserDataWrapper.kitchenwarePart.addKitchenware(_loc2_);
                  refresh();
               });
         }
      }
      
      public function getGuideArrowPos(param1:int) : Vector.<Number>
      {
         var _loc2_:* = undefined;
         switch(int(param1))
         {
            case 0:
               return recipeNoteUI.getRecipeNotePos(0);
            case 1:
               return recipeUI.getRecipePos(0);
            case 2:
               return confirmUI.getStartCookingBtnPos();
            default:
               return _loc2_;
         }
      }
      
      private function processTutorial() : Boolean
      {
         if(!isTutorial())
         {
            return false;
         }
         var _loc1_:Boolean = Engine.resumeGuideTalk(tutorialAction,getGuideArrowPos);
         if(!_loc1_)
         {
            Logger.warn("warn : failed resumeGuideTalk() in " + this);
         }
         recipeUI.setTutorial(true);
         return true;
      }
      
      private function isTutorial() : Boolean
      {
         return !UserDataWrapper.wrapper.isCompletedTutorial();
      }
      
      private function needPageChange() : Boolean
      {
         return UserDataWrapper.kitchenwarePart.hasKitchenwareTypes();
      }
      
      private function setPageChangeEnable(param1:Boolean) : void
      {
         if(param1 && needPageChange())
         {
            spPageBtn.visible = true;
            swipeGesture.enabled = true;
         }
         else
         {
            spPageBtn.visible = false;
            swipeGesture.enabled = false;
         }
      }
      
      private function gesture(param1:GestureEvent) : void
      {
         if(Engine.isTouchInputLocked())
         {
            return;
         }
         var _loc2_:SwipeGesture = param1.target as SwipeGesture;
         if(_loc2_.offsetX > 0)
         {
            backPage();
         }
         else if(_loc2_.offsetX < 0)
         {
            nextPage();
         }
      }
      
      private function nextPage() : void
      {
         var _loc1_:* = null;
         var _loc2_:int = kitchenwareType;
         while(true)
         {
            _loc2_++;
            _loc1_ = UserDataWrapper.kitchenwarePart.getKitchenwareByType(_loc2_);
            if(_loc1_ != null)
            {
               if(UserDataWrapper.kitchenwarePart.isAvailableByKitchenware(_loc1_,0,!_loc1_.isCooking()))
               {
                  break;
               }
            }
            if(_loc2_ >= 5)
            {
               _loc2_ = -1;
            }
         }
         forceRecipe = false;
         changePageAnime(_loc2_,true);
      }
      
      private function backPage() : void
      {
         var _loc1_:* = null;
         var _loc2_:int = kitchenwareType;
         while(true)
         {
            _loc2_--;
            _loc1_ = UserDataWrapper.kitchenwarePart.getKitchenwareByType(_loc2_);
            if(_loc1_ != null)
            {
               if(UserDataWrapper.kitchenwarePart.isAvailableByKitchenware(_loc1_,0,!_loc1_.isCooking()))
               {
                  break;
               }
            }
            if(_loc2_ < 0)
            {
               _loc2_ = 5;
            }
         }
         forceRecipe = false;
         changePageAnime(_loc2_,false);
      }
      
      private function showCupGachaLineup() : void
      {
         var kitchenwareDef:KitchenwareDef = GameSetting.getKitchenwareByType(kitchenwareType,recipeNoteUI.grade);
         var _loc2_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(134217977,kitchenwareDef.id#2),function(param1:Array):void
         {
            var response:Array = param1;
            if(response)
            {
               var itemMap:Object = response[0];
               var infomsg:String = GameSetting.getUIText("cuplistdialog.info.desc").replace("%1",GameSetting.getUIText("kitchenware.type.name." + kitchenwareType));
               if(itemMap)
               {
                  CupItemsListShowDialog.show(itemMap,function(param1:int):void
                  {
                     setupForRecipe(param1);
                  },infomsg);
               }
               else
               {
                  MessageDialog.show(0,GameSetting.getUIText("cooking.empty.cupgude.msg"));
               }
            }
         });
      }
      
      public function changePageAnimeWithMemory(param1:int, param2:Boolean, param3:Object = null) : void
      {
         addMemoryRecipeArray();
         changePageAnime(param1,param2,param3);
      }
      
      public function addMemoryRecipeArray(param1:Boolean = true) : void
      {
         var _loc4_:* = null;
         var _loc6_:* = null;
         var _loc2_:int = 0;
         var _loc5_:* = null;
         var _loc7_:* = null;
         var _loc3_:Boolean = false;
         var _loc8_:Boolean = false;
         if(!GameSetting.getRule().memoryCookingRecipe)
         {
            return;
         }
         if(param1)
         {
            _loc6_ = GameSetting.getKitchenwareByType(kitchenwareType,recipeNoteUI.grade);
            _loc4_ = {
               "memoryType":0,
               "kitchenwareType":_loc6_.type,
               "kitchenwareId":_loc6_.id#2
            };
            if(confirmUI.isVisible())
            {
               _loc2_ = confirmUI.getGudetamaId();
               if(_loc5_ = GameSetting.getGudetama(_loc2_))
               {
                  _loc7_ = GameSetting.getRecipeNote(_loc5_.recipeNoteId);
                  _loc3_ = UserDataWrapper.gudetamaPart.isHappening(_loc2_);
                  if(!(_loc8_ = UserDataWrapper.gudetamaPart.isFailure(_loc2_)))
                  {
                     _loc4_["recipeNoteId"] = _loc7_.id#2;
                     if(!_loc3_)
                     {
                        _loc4_["gudetamaId"] = _loc5_.id#2;
                     }
                  }
               }
            }
         }
         else
         {
            _loc4_ = {"memoryType":1};
         }
         memoryRecipeArray.push({
            "kitchenwareType":kitchenwareType,
            "param":_loc4_
         });
      }
      
      public function resetMemoryRecipeArray() : void
      {
         memoryRecipeArray.length = 0;
         memoryRecipeArray = [];
      }
      
      public function changePageAnime(param1:int, param2:Boolean, param3:Object = null) : void
      {
         var idx:int = param1;
         var toLeft:Boolean = param2;
         var navigateParam:Object = param3;
         Engine.lockTouchInput(CookingScene);
         if(toLeft)
         {
            var twName:String = "r2c";
            var openTwName:String = "c2l";
         }
         else
         {
            twName = "l2c";
            openTwName = "c2r";
         }
         spCurtain.visible = true;
         TweenAnimator.startItself(spCurtain,twName,false,function(param1:DisplayObject):void
         {
            var dObj:DisplayObject = param1;
            var startTime:uint = Engine.now;
            clearCache();
            var queue:TaskQueue = new TaskQueue();
            setupCookingScene(queue,idx,navigateParam);
            queue.registerOnProgress(function(param1:Number):void
            {
               var ratio:Number = param1;
               if(ratio < 1)
               {
                  return;
               }
               var showAndCloseCurtain:Function = function():void
               {
                  show(function():void
                  {
                     var _loc1_:* = null;
                     if(navigateParam && navigateParam.gudetamaId && !isCooking())
                     {
                        _loc1_ = GameSetting.getRecipeNote(navigateParam.recipeNoteId);
                        if(_loc1_.existsInRecipe(navigateParam.gudetamaId))
                        {
                           setupForConfirm(navigateParam.gudetamaId,navigateParam.recipeNoteId,false);
                        }
                     }
                     Engine.unlockTouchInput(CookingScene);
                  },true,false,navigateParam != null ? true : false);
                  TweenAnimator.startItself(spCurtain,openTwName,false,function(param1:DisplayObject):void
                  {
                     spCurtain.visible = false;
                     setVisibleState(94);
                  });
               };
               var pastTime:int = 300 - (Engine.now - startTime);
               if(pastTime > 0)
               {
                  scene.getSceneJuggler().delayCall(function():void
                  {
                     showAndCloseCurtain();
                  },0.001 * pastTime);
               }
               else
               {
                  showAndCloseCurtain();
               }
            });
            queue.startTask();
         });
      }
      
      private function isCooking() : Boolean
      {
         if(forceRecipe)
         {
            return false;
         }
         return UserDataWrapper.kitchenwarePart.isCooking(kitchenwareType);
      }
      
      private function finishedCooking() : Boolean
      {
         return UserDataWrapper.kitchenwarePart.finishedCooking(kitchenwareType);
      }
      
      override public function dispose() : void
      {
         kitchenwareBgImage = null;
         kitchenwareSpineModel = null;
         if(materialGroupUI)
         {
            materialGroupUI.dispose();
            materialGroupUI = null;
         }
         if(kitchenwareButton)
         {
            kitchenwareButton.removeEventListener("triggered",triggeredKitchenwareButton);
            kitchenwareButton = null;
         }
         if(cookingTimeUI)
         {
            cookingTimeUI.dispose();
            cookingTimeUI = null;
         }
         if(hurryButton)
         {
            hurryButton.removeEventListener("triggered",triggeredHurryButton);
            hurryButton = null;
         }
         hurryUsefulGroup = null;
         if(cancelButton)
         {
            cancelButton.removeEventListener("triggered",triggeredCancelButton);
            cancelButton = null;
         }
         if(recipeButton)
         {
            recipeButton.removeEventListener("triggered",triggeredRecipeButton);
            recipeButton = null;
         }
         if(recipeNoteUI)
         {
            recipeNoteUI.dispose();
            recipeNoteUI = null;
         }
         recipeGroup = null;
         if(recipeUI)
         {
            recipeUI.dispose();
            recipeUI = null;
         }
         if(confirmUI)
         {
            confirmUI.dispose();
            confirmUI = null;
         }
         if(unlockUI)
         {
            unlockUI.dispose();
            unlockUI = null;
         }
         pageSpineModel = null;
         unlockedRecipeNoteExtractor = null;
         lockedRecipeNoteExtractor = null;
         unpurchasedRecipeNoteExtractor = null;
         recipeGudetamaExtractor = null;
         materialExtractor = null;
         currentBackButtonCallback = null;
         SoundManager.stopEffect(kitchenwareSE);
         kitchenwareSE = null;
         if(swipeGesture)
         {
            swipeGesture.removeEventListener("gestureRecognized",gesture);
            swipeGesture.dispose();
            swipeGesture = null;
         }
         if(btnL)
         {
            btnL.removeEventListener("triggered",backPage);
            btnL = null;
         }
         if(btnR)
         {
            btnR.removeEventListener("triggered",nextPage);
            btnR = null;
         }
         spPageBtn = null;
         spCurtain = null;
         super.dispose();
      }
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.GudetamaDef;
import gudetama.engine.BaseScene;
import gudetama.engine.Engine;
import gudetama.scene.kitchen.CookingScene;
import gudetama.ui.UIBase;
import muku.core.TaskQueue;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

class CookingTimeUI extends UIBase
{
   
   private static const LABEL_NUM:int = 6;
   
   private static const UPDATE_LABEL_INTERVAL:int = 1000;
    
   
   private var scene:CookingScene;
   
   private var iconImage:Image;
   
   private var labelText:ColorTextField;
   
   private var timeText:ColorTextField;
   
   private var kitchenwareType:int;
   
   private var lastHour:int = -1;
   
   private var lastMinute:int = -1;
   
   private var lastSecond:int = -1;
   
   private var labelIndex:int;
   
   private var nextUpdateLabelTime:int;
   
   function CookingTimeUI(param1:Sprite, param2:BaseScene)
   {
      super(param1);
      this.scene = param2 as CookingScene;
      iconImage = param1.getChildByName("icon") as Image;
      labelText = param1.getChildByName("label") as ColorTextField;
      timeText = param1.getChildByName("time") as ColorTextField;
   }
   
   public function setup(param1:TaskQueue, param2:int) : void
   {
      var queue:TaskQueue = param1;
      var kitchenwareType:int = param2;
      this.kitchenwareType = kitchenwareType;
      var gudetamaId:int = UserDataWrapper.kitchenwarePart.getGudetamaId(kitchenwareType);
      var gudetamaDef:GudetamaDef = GameSetting.getGudetama(gudetamaId);
      iconImage.visible = false;
      if(gudetamaDef)
      {
         queue.addTask(function():void
         {
            scene.loadTexture("gudetama-" + gudetamaDef.rsrc + "-icon",function(param1:Texture):void
            {
               iconImage.texture = param1;
               iconImage.visible = true;
               queue.taskDone();
            });
         });
      }
      labelIndex = 0;
      nextUpdateLabelTime = 0;
      lastHour = -1;
      lastMinute = -1;
      lastSecond = -1;
      startTween("show");
      advanceTime();
   }
   
   public function advanceTime(param1:Number = 0) : void
   {
      updateTime(param1);
      updateLabel(param1);
   }
   
   private function updateTime(param1:Number = 0) : void
   {
      if(!UserDataWrapper.kitchenwarePart.hasKitchenwareByType(kitchenwareType))
      {
         return;
      }
      var _loc3_:int = UserDataWrapper.kitchenwarePart.getRestCookingTime(kitchenwareType);
      var _loc2_:int = _loc3_ / 3600;
      var _loc4_:int = (_loc3_ - _loc2_ * 60 * 60) / 60;
      var _loc5_:int = _loc3_ - _loc2_ * 60 * 60 - _loc4_ * 60;
      if(_loc2_ == lastHour && _loc4_ == lastMinute && _loc5_ == lastSecond)
      {
         return;
      }
      timeText.text#2 = GudetamaUtil.getRestTimeString(_loc2_,_loc4_,_loc5_);
      lastHour = _loc2_;
      lastMinute = _loc4_;
      lastSecond = _loc5_;
   }
   
   private function updateLabel(param1:Number = 0) : void
   {
      if(Engine.now < nextUpdateLabelTime)
      {
         return;
      }
      labelText.text#2 = GameSetting.getUIText("cooking.label." + labelIndex);
      labelIndex = (labelIndex + 1) % 6;
      nextUpdateLabelTime = Engine.now + 1000;
   }
   
   public function dispose() : void
   {
      iconImage = null;
      labelText = null;
      timeText = null;
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.engine.BaseScene;
import gudetama.engine.TextureCollector;
import gudetama.engine.TweenAnimator;
import gudetama.scene.kitchen.CookingScene;
import gudetama.ui.UIBase;
import gudetama.util.SpriteExtractor;
import gudetama.util.StringUtil;
import muku.core.TaskQueue;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.textures.Texture;

class RecipeNoteUI extends UIBase
{
    
   
   private var scene:CookingScene;
   
   private var titleBgImage:Image;
   
   private var kitchenwareNameText:ColorTextField;
   
   private var gradeNameText:ColorTextField;
   
   private var posSprites:Vector.<Sprite>;
   
   private var gradeButtonGroupUI:GradeButtonGroupUI;
   
   private var unlockedManager:SpriteManager;
   
   private var lockedManager:SpriteManager;
   
   private var unpurchasedManager:SpriteManager;
   
   private var screeningRecipeItemUIs:Vector.<RecipeItemUIBase>;
   
   private var randomIndices:Array;
   
   public var grade:int;
   
   function RecipeNoteUI(param1:Sprite, param2:BaseScene)
   {
      var _loc5_:int = 0;
      posSprites = new Vector.<Sprite>();
      screeningRecipeItemUIs = new Vector.<RecipeItemUIBase>();
      randomIndices = [];
      param1.visible = false;
      super(param1);
      this.scene = param2 as CookingScene;
      var _loc3_:Quad = param1.getChildByName("quad") as Quad;
      _loc3_.touchable = false;
      titleBgImage = param1.getChildByName("titleBg") as Image;
      titleBgImage.touchable = false;
      kitchenwareNameText = param1.getChildByName("name") as ColorTextField;
      gradeNameText = param1.getChildByName("grade") as ColorTextField;
      var _loc4_:Sprite = param1.getChildByName("posGroup") as Sprite;
      _loc5_ = 0;
      while(_loc5_ < _loc4_.numChildren)
      {
         posSprites.push(_loc4_.getChildAt(_loc5_));
         _loc5_++;
      }
      gradeButtonGroupUI = new GradeButtonGroupUI(param1.getChildByName("gradeGroup") as Sprite,param2);
      if(!UserDataWrapper.wrapper.isCompletedTutorial())
      {
         gradeButtonGroupUI.setTouchable(false);
         gradeButtonGroupUI.setVisible(false);
      }
   }
   
   public function setupSpriteManager(param1:SpriteExtractor, param2:SpriteExtractor, param3:SpriteExtractor) : void
   {
      unlockedManager = new SpriteManager(param1,RecipeNoteItemUI,scene);
      lockedManager = new SpriteManager(param2,LockedRecipeNoteItemUI,scene);
      unpurchasedManager = new SpriteManager(param3,PurchaseRecipeNoteItemUI,scene);
   }
   
   public function setup(param1:TaskQueue, param2:int, param3:int = -1) : void
   {
      unlockedManager.reset();
      lockedManager.reset();
      unpurchasedManager.reset();
      if(param3 != -1)
      {
         grade = param3;
      }
      for each(var _loc4_ in posSprites)
      {
         if(_loc4_.numChildren > 0)
         {
            _loc4_.removeChildAt(0);
         }
         _loc4_.visible = false;
      }
      screeningRecipeItemUIs.length = 0;
      randomIndices.length = 0;
      setupRecipe(param1,param2,param3);
   }
   
   private function setupRecipe(param1:TaskQueue, param2:int, param3:int) : void
   {
      var queue:TaskQueue = param1;
      var kitchenwareType:int = param2;
      var _grade:int = param3;
      if(_grade < 0)
      {
         setupGrade(kitchenwareType);
         var _grade:int = gradeButtonGroupUI.currentGrade();
      }
      else
      {
         setGrade(kitchenwareType,_grade);
      }
      queue.addTask(function():void
      {
         TextureCollector.loadTexture("recipe0@mat" + kitchenwareType,function(param1:Texture):void
         {
            titleBgImage.texture = param1;
            queue.taskDone();
         });
      });
      kitchenwareNameText.text#2 = StringUtil.format(GameSetting.getUIText("cooking.recipeNote.name"),GameSetting.getUIText("kitchenware.type.name." + kitchenwareType));
      gradeNameText.text#2 = StringUtil.format(GameSetting.getUIText("cooking.recipeNote.grade"),_grade + 1);
      if(_grade != -1)
      {
         grade = _grade;
      }
      var recipeNoteIds:Array = UserDataWrapper.wrapper.createPossessingRecipeNoteIds(kitchenwareType,_grade);
      var i:int = 0;
      while(i < recipeNoteIds.length)
      {
         var recipeNoteId:int = recipeNoteIds[i];
         if(!UserDataWrapper.recipeNotePart.isAvailable(recipeNoteId))
         {
            var itemUI:RecipeItemUIBase = lockedManager.pop();
            itemUI.setup(queue,[recipeNoteId],scene.triggeredLockedRecipeNoteItemUICallback);
         }
         else if(!UserDataWrapper.recipeNotePart.isPurchased(recipeNoteId))
         {
            itemUI = unpurchasedManager.pop();
            itemUI.setup(queue,[recipeNoteId],scene.triggeredPurchaseRecipeNoteItemUICallback);
         }
         else
         {
            itemUI = unlockedManager.pop();
            itemUI.setup(queue,[recipeNoteId],scene.setupForRecipeWithAnime);
         }
         screeningRecipeItemUIs.push(itemUI);
         posSprites[i].addChild(itemUI.getDisplaySprite());
         randomIndices.push(i);
         if(!UserDataWrapper.wrapper.isCompletedTutorial())
         {
            break;
         }
         i++;
      }
   }
   
   public function show() : void
   {
      showItems();
   }
   
   public function showItems() : void
   {
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc2_:int = 0;
      _loc3_ = 0;
      while(_loc3_ < randomIndices.length)
      {
         _loc1_ = Math.random() * randomIndices.length;
         _loc2_ = randomIndices[_loc1_];
         randomIndices[_loc1_] = randomIndices[_loc3_];
         randomIndices[_loc3_] = _loc2_;
         _loc3_++;
      }
      _loc3_ = 0;
      while(_loc3_ < randomIndices.length)
      {
         showItem(_loc3_);
         _loc3_++;
      }
   }
   
   private function showItem(param1:int) : void
   {
      var index:int = param1;
      var posSprite:Sprite = posSprites[randomIndices[index]];
      TweenAnimator.startItself(posSprite,"pos" + (randomIndices.length - 1),true);
      TweenAnimator.finishItself(posSprite);
      scene.getSceneJuggler().delayCall(function():void
      {
         posSprite.visible = true;
         TweenAnimator.startItself(posSprite,"show",true);
      },0.05 * index);
   }
   
   public function setupGrade(param1:int) : void
   {
      gradeButtonGroupUI.setup(param1);
   }
   
   public function currentGrade() : int
   {
      return gradeButtonGroupUI.currentGrade();
   }
   
   public function setGrade(param1:int, param2:int) : void
   {
      gradeButtonGroupUI.setGrade(param1,param2);
   }
   
   public function set touchable(param1:Boolean) : void
   {
      displaySprite.touchable = param1;
   }
   
   public function getRecipeNotePos(param1:int) : Vector.<Number>
   {
      var _loc3_:RecipeItemUIBase = screeningRecipeItemUIs[param1] as RecipeItemUIBase;
      var _loc2_:ContainerButton = _loc3_.getButton();
      return GudetamaUtil.getCenterPosAndWHOnEngine(_loc2_);
   }
   
   public function set visible(param1:*) : void
   {
      displaySprite.visible = param1;
   }
   
   public function dispose() : void
   {
      titleBgImage = null;
      kitchenwareNameText = null;
      gradeNameText = null;
      posSprites.length = 0;
      posSprites = null;
      if(gradeButtonGroupUI)
      {
         gradeButtonGroupUI.dispose();
         gradeButtonGroupUI = null;
      }
   }
}

import gudetama.data.UserDataWrapper;
import gudetama.engine.BaseScene;
import gudetama.engine.Engine;
import gudetama.net.HttpConnector;
import gudetama.net.PacketUtil;
import gudetama.scene.kitchen.CookingScene;
import gudetama.ui.UIBase;
import starling.display.Sprite;

class GradeButtonGroupUI extends UIBase
{
   
   private static const DISPLAYABLE_NUM_GRADE:int = 0;
    
   
   private var scene:CookingScene;
   
   private var gradeButtonUIs:Vector.<GradeButtonUI>;
   
   private var kitchenwareType:int;
   
   private var grades:Array;
   
   private var currentIndex:int;
   
   function GradeButtonGroupUI(param1:Sprite, param2:BaseScene)
   {
      var _loc3_:int = 0;
      gradeButtonUIs = new Vector.<GradeButtonUI>();
      super(param1);
      this.scene = param2 as CookingScene;
      _loc3_ = 0;
      while(_loc3_ < param1.numChildren)
      {
         gradeButtonUIs.push(new GradeButtonUI(param1.getChildAt(_loc3_) as Sprite,triggeredGradeButtonUICallback));
         _loc3_++;
      }
   }
   
   public function setup(param1:int) : void
   {
      this.kitchenwareType = param1;
      grades = UserDataWrapper.kitchenwarePart.getKitchenwareGrades(param1);
      currentIndex = 0;
      refresh();
   }
   
   public function refresh() : void
   {
      Engine.showLoading();
      var _loc1_:* = HttpConnector;
      if(gudetama.net.HttpConnector.mainConnector == null)
      {
         gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
      }
      gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(249,kitchenwareType),function(param1:Object):void
      {
         var _loc7_:* = null;
         var _loc6_:int = 0;
         var _loc5_:* = null;
         var _loc3_:Boolean = false;
         Engine.hideLoading();
         if(param1)
         {
            _loc7_ = param1;
         }
         var _loc4_:* = _loc7_;
         var _loc2_:int = 0;
         _loc6_ = 0;
         while(_loc6_ < grades.length && _loc6_ < gradeButtonUIs.length)
         {
            _loc5_ = gradeButtonUIs[_loc6_];
            _loc3_ = _loc4_[grades[_loc6_]] == 0 ? true : false;
            _loc5_.setVisible(_loc3_);
            if(_loc3_)
            {
               _loc2_++;
            }
            _loc5_.setup(kitchenwareType,grades[_loc6_]);
            _loc5_.select(_loc6_ == currentIndex);
            _loc6_++;
         }
         while(_loc6_ < gradeButtonUIs.length)
         {
            gradeButtonUIs[_loc6_].setVisible(false);
            _loc6_++;
         }
         startTween("pos" + (_loc2_ - 1));
         displaySprite.visible = _loc2_ > 1;
      });
   }
   
   public function currentGrade() : int
   {
      return currentIndex;
   }
   
   public function setGrade(param1:int, param2:int) : void
   {
      this.kitchenwareType = param1;
      grades = UserDataWrapper.kitchenwarePart.getKitchenwareGrades(param1);
      currentIndex = grades.indexOf(param2);
      refresh();
   }
   
   private function triggeredGradeButtonUICallback(param1:int) : void
   {
      scene.setupForRecipeNoteWithForceNavi(param1,false,false,null,true);
   }
   
   public function dispose() : void
   {
      for each(var _loc1_ in gradeButtonUIs)
      {
         _loc1_.dispose();
      }
      gradeButtonUIs.length = 0;
      gradeButtonUIs = null;
   }
}

import gudetama.data.UserDataWrapper;
import gudetama.engine.SoundManager;
import gudetama.ui.LockedKitchenwareDialog;
import gudetama.ui.UIBase;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;

class GradeButtonUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var button:ContainerButton;
   
   private var deselectImage:Image;
   
   private var selectImage:Image;
   
   private var gradeText:ColorTextField;
   
   private var lockSprite:Sprite;
   
   private var kitchenwareType:int;
   
   private var grade:int;
   
   function GradeButtonUI(param1:Sprite, param2:Function)
   {
      super(param1);
      this.callback = param2;
      button = param1.getChildByName("button") as ContainerButton;
      button.addEventListener("triggered",triggered);
      deselectImage = button.getChildByName("deselect") as Image;
      selectImage = button.getChildByName("select") as Image;
      gradeText = button.getChildByName("grade") as ColorTextField;
      lockSprite = button.getChildByName("lockGroup") as Sprite;
   }
   
   public function setup(param1:int, param2:int) : void
   {
      this.kitchenwareType = param1;
      this.grade = param2;
      gradeText.text#2 = (param2 + 1).toString();
      lockSprite.visible = !UserDataWrapper.kitchenwarePart.isAvailableGrade(param1,param2,true);
   }
   
   public function select(param1:Boolean) : void
   {
      selectImage.visible = param1;
      button.touchable = !param1;
   }
   
   private function triggered(param1:Event) : void
   {
      if(UserDataWrapper.kitchenwarePart.isAvailable(kitchenwareType,grade,true))
      {
         SoundManager.playEffect("Recipe_PageNext");
         callback(grade);
      }
      else
      {
         LockedKitchenwareDialog.show(kitchenwareType,grade);
      }
   }
   
   public function dispose() : void
   {
      callback = null;
      button.removeEventListener("triggered",triggered);
      button = null;
      deselectImage = null;
      selectImage = null;
      gradeText = null;
      lockSprite = null;
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.KitchenwareDef;
import gudetama.data.compati.RecipeNoteDef;
import gudetama.engine.BaseScene;
import gudetama.engine.TextureCollector;
import gudetama.engine.TweenAnimator;
import gudetama.scene.kitchen.CookingScene;
import gudetama.scene.kitchen.HappeningDetailDialog;
import gudetama.ui.UIBase;
import gudetama.util.SpriteExtractor;
import gudetama.util.StringUtil;
import muku.core.TaskQueue;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class RecipeUI extends UIBase
{
    
   
   private var scene:CookingScene;
   
   private var titleBgImage:Image;
   
   private var circleImage:Image;
   
   private var nameText:ColorTextField;
   
   private var posSprites:Vector.<Sprite>;
   
   private var happeningButton:ContainerButton;
   
   private var iconImage:Image;
   
   private var numGroup:Sprite;
   
   private var numText:ColorTextField;
   
   private var gudetamaManager:SpriteManager;
   
   private var lockedGudetamaManager:SpriteManager;
   
   private var randomIndices:Array;
   
   private var screeningRecipeItemUIs:Vector.<RecipeItemUIBase>;
   
   public var currentRecipeNoteId:int;
   
   private var tutorial:Boolean;
   
   function RecipeUI(param1:Sprite, param2:BaseScene)
   {
      var _loc4_:int = 0;
      posSprites = new Vector.<Sprite>();
      randomIndices = [];
      screeningRecipeItemUIs = new Vector.<RecipeItemUIBase>();
      super(param1);
      this.scene = CookingScene(param2);
      titleBgImage = param1.getChildByName("titleBg") as Image;
      circleImage = param1.getChildByName("circle") as Image;
      nameText = param1.getChildByName("name") as ColorTextField;
      var _loc3_:Sprite = param1.getChildByName("posGroup") as Sprite;
      _loc4_ = 0;
      while(_loc4_ < _loc3_.numChildren)
      {
         posSprites.push(_loc3_.getChildAt(_loc4_));
         _loc4_++;
      }
      happeningButton = param1.getChildByName("happeningButton") as ContainerButton;
      happeningButton.addEventListener("triggered",triggeredHappeningButton);
      iconImage = happeningButton.getChildByName("icon") as Image;
      numGroup = happeningButton.getChildByName("numGroup") as Sprite;
      numText = numGroup.getChildByName("text") as ColorTextField;
   }
   
   public function setupSpriteManager(param1:SpriteExtractor) : void
   {
      gudetamaManager = new SpriteManager(param1,RecipeGudetamaItemUI,scene);
      lockedGudetamaManager = new SpriteManager(param1,LockedRecipeGudetamaItemUI,scene);
   }
   
   public function setup(param1:TaskQueue, param2:int, param3:int = -1) : void
   {
      gudetamaManager.reset();
      for each(var _loc4_ in posSprites)
      {
         if(_loc4_.numChildren > 0)
         {
            _loc4_.removeChildAt(0);
         }
         _loc4_.visible = false;
      }
      randomIndices.length = 0;
      screeningRecipeItemUIs.length = 0;
      setupRecipe(param1,param2);
   }
   
   private function setupRecipe(param1:TaskQueue, param2:int) : void
   {
      var queue:TaskQueue = param1;
      var recipeNoteId:int = param2;
      var cookableGudetamaIds:Array = UserDataWrapper.gudetamaPart.getCookableGudetamaIds(recipeNoteId);
      var recipeNoteDef:RecipeNoteDef = GameSetting.getRecipeNote(recipeNoteId);
      var kitchenwareDef:KitchenwareDef = GameSetting.getKitchenware(recipeNoteDef.kitchenwareId);
      queue.addTask(function():void
      {
         TextureCollector.loadTexture("recipe0@mat" + kitchenwareDef.type,function(param1:Texture):void
         {
            titleBgImage.texture = param1;
            queue.taskDone();
         });
      });
      queue.addTask(function():void
      {
         TextureCollector.loadTexture("recipe0@circle" + (kitchenwareDef.id#2 - 1),function(param1:Texture):void
         {
            circleImage.texture = param1;
            queue.taskDone();
         });
      });
      nameText.text#2 = StringUtil.replaceAll(recipeNoteDef.name#2,"\n","");
      var i:int = 0;
      while(i < cookableGudetamaIds.length)
      {
         var gudetamaId:int = cookableGudetamaIds[i];
         if(UserDataWrapper.gudetamaPart.isAvailable(gudetamaId))
         {
            var itemUI:RecipeItemUIBase = gudetamaManager.pop();
            itemUI.setup(queue,[gudetamaId,recipeNoteId,cookableGudetamaIds.length],scene.setupForConfirm);
         }
         else
         {
            itemUI = lockedGudetamaManager.pop();
            itemUI.setup(queue,[gudetamaId,0,cookableGudetamaIds.length],scene.triggeredLockedRecipeGudetamaItemUICallback);
         }
         screeningRecipeItemUIs.push(itemUI);
         posSprites[i].addChild(itemUI.getDisplaySprite());
         randomIndices.push(i);
         if(!UserDataWrapper.wrapper.isCompletedTutorial())
         {
            break;
         }
         i++;
      }
      happeningButton.visible = !tutorial && recipeNoteDef.happeningIds && recipeNoteDef.happeningIds.length > 0;
      if(happeningButton.visible)
      {
         var happeningId:int = recipeNoteDef.happeningIds[0];
         var isCooked:Boolean = UserDataWrapper.gudetamaPart.isCooked(happeningId);
         numGroup.visible = isCooked;
         numText.text#2 = StringUtil.format(GameSetting.getUIText("mult.mark"),UserDataWrapper.gudetamaPart.getNumGudetama(happeningId));
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("gudetama-" + happeningId + "-happening" + (!!isCooked ? "" : "_b"),function(param1:Texture):void
            {
               iconImage.texture = param1;
               queue.taskDone();
            });
         });
      }
      currentRecipeNoteId = recipeNoteId;
   }
   
   public function show() : void
   {
      showItems();
   }
   
   public function showItems() : void
   {
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      var _loc2_:int = 0;
      _loc3_ = 0;
      while(_loc3_ < randomIndices.length)
      {
         _loc1_ = Math.random() * randomIndices.length;
         _loc2_ = randomIndices[_loc1_];
         randomIndices[_loc1_] = randomIndices[_loc3_];
         randomIndices[_loc3_] = _loc2_;
         _loc3_++;
      }
      _loc3_ = 0;
      while(_loc3_ < randomIndices.length)
      {
         showItem(_loc3_);
         _loc3_++;
      }
   }
   
   private function showItem(param1:int) : void
   {
      var index:int = param1;
      var posSprite:Sprite = posSprites[randomIndices[index]];
      TweenAnimator.startItself(posSprite,"pos" + (randomIndices.length - 1),true);
      TweenAnimator.finishItself(posSprite);
      scene.getSceneJuggler().delayCall(function():void
      {
         posSprite.visible = true;
         TweenAnimator.startItself(posSprite,"show",true);
      },0.05 * index);
   }
   
   public function setTutorial(param1:Boolean) : void
   {
      tutorial = param1;
      happeningButton.visible = !tutorial && happeningButton.visible;
   }
   
   private function triggeredHappeningButton(param1:Event) : void
   {
      var _loc2_:RecipeNoteDef = GameSetting.getRecipeNote(currentRecipeNoteId);
      HappeningDetailDialog.show(_loc2_.happeningIds[0]);
   }
   
   public function refresh() : void
   {
      for each(var _loc1_ in screeningRecipeItemUIs)
      {
         _loc1_.refresh();
      }
   }
   
   public function getRecipePos(param1:int) : Vector.<Number>
   {
      var _loc2_:RecipeGudetamaItemUI = screeningRecipeItemUIs[param1] as RecipeGudetamaItemUI;
      var _loc3_:DisplayObject = _loc2_.getSprite();
      return GudetamaUtil.getCenterPosAndWHOnEngine(_loc3_);
   }
   
   public function dispose() : void
   {
      scene = null;
      titleBgImage = null;
      circleImage = null;
      nameText = null;
      posSprites.length = 0;
      posSprites = null;
      if(happeningButton)
      {
         happeningButton.removeEventListener("triggered",triggeredHappeningButton);
         happeningButton = null;
      }
      numGroup = null;
      numText = null;
      if(gudetamaManager)
      {
         gudetamaManager.dispose();
         gudetamaManager = null;
      }
      if(lockedGudetamaManager)
      {
         lockedGudetamaManager.dispose();
         lockedGudetamaManager = null;
      }
      randomIndices.length = 0;
      randomIndices = null;
      screeningRecipeItemUIs.length = 0;
      screeningRecipeItemUIs = null;
   }
}

import gudetama.engine.BaseScene;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class SpriteManager
{
    
   
   private var extractor:SpriteExtractor;
   
   private var uiClass:Class;
   
   private var scene:BaseScene;
   
   private var itemUIs:Vector.<RecipeItemUIBase>;
   
   private var using:Vector.<RecipeItemUIBase>;
   
   function SpriteManager(param1:SpriteExtractor, param2:Class, param3:BaseScene)
   {
      itemUIs = new Vector.<RecipeItemUIBase>();
      using = new Vector.<RecipeItemUIBase>();
      super();
      this.extractor = param1;
      this.uiClass = param2;
      this.scene = param3;
   }
   
   public function pop() : RecipeItemUIBase
   {
      var _loc1_:RecipeItemUIBase = itemUIs.pop();
      if(!_loc1_)
      {
         _loc1_ = new uiClass(extractor.duplicateAll() as Sprite,scene);
      }
      using.push(_loc1_);
      return _loc1_;
   }
   
   public function reset() : void
   {
      var _loc2_:int = 0;
      var _loc1_:int = using.length;
      _loc2_ = 0;
      while(_loc2_ < _loc1_)
      {
         itemUIs.push(using.pop());
         _loc2_++;
      }
   }
   
   public function dispose() : void
   {
      extractor = null;
      uiClass = null;
      for each(var _loc1_ in itemUIs)
      {
         _loc1_.dispose();
      }
      itemUIs.length = 0;
      itemUIs = null;
   }
}

import gudetama.data.GameSetting;
import gudetama.data.compati.RecipeNoteDef;
import gudetama.engine.BaseScene;
import gudetama.scene.kitchen.CookingScene;
import gudetama.ui.UIBase;
import muku.core.TaskQueue;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Sprite;
import starling.events.Event;

class RecipeItemUIBase extends UIBase
{
    
   
   protected var scene:CookingScene;
   
   protected var button:ContainerButton;
   
   protected var argi:Array;
   
   protected var callback:Function;
   
   private var nameText:ColorTextField;
   
   function RecipeItemUIBase(param1:Sprite, param2:BaseScene)
   {
      super(param1);
      this.scene = param2 as CookingScene;
      button = param1.getChildByName("button") as ContainerButton;
      button.addEventListener("triggered",triggeredButton);
      nameText = button.getChildByName("name") as ColorTextField;
   }
   
   public function setup(param1:TaskQueue, param2:Array, param3:Function) : void
   {
      this.argi = param2;
      this.callback = param3;
      var _loc4_:RecipeNoteDef = GameSetting.getRecipeNote(param2[0]);
      if(nameText)
      {
         nameText.text#2 = _loc4_.name#2;
         nameText.visible = true;
      }
   }
   
   public function refresh() : void
   {
   }
   
   protected function triggeredButton(param1:Event) : void
   {
      callback(argi[0]);
   }
   
   public function getButton() : ContainerButton
   {
      return button;
   }
   
   public function dispose() : void
   {
      button.removeEventListener("triggered",triggeredButton);
      button = null;
      argi.length = 0;
      argi = null;
      callback = null;
   }
}

import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.RecipeNoteDef;
import gudetama.engine.BaseScene;
import muku.core.TaskQueue;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;

class RecipeNoteItemUI extends RecipeItemUIBase
{
    
   
   private var incompleteBgImage:Image;
   
   private var completeBgImage:Image;
   
   private var nameText:ColorTextField;
   
   private var numText:ColorTextField;
   
   private var completeImage:Image;
   
   private var newImage:Image;
   
   private var recipeNoteDef:RecipeNoteDef;
   
   function RecipeNoteItemUI(param1:Sprite, param2:BaseScene)
   {
      super(param1,param2);
      incompleteBgImage = button.getChildByName("incompleteBg") as Image;
      completeBgImage = button.getChildByName("completeBg") as Image;
      nameText = button.getChildByName("name") as ColorTextField;
      numText = button.getChildByName("num") as ColorTextField;
      completeImage = button.getChildByName("complete") as Image;
      newImage = button.getChildByName("new") as Image;
   }
   
   override public function setup(param1:TaskQueue, param2:Array, param3:Function) : void
   {
      var _loc8_:int = 0;
      var _loc6_:int = 0;
      super.setup(param1,param2,param3);
      recipeNoteDef = GameSetting.getRecipeNote(param2[0]);
      nameText.text#2 = recipeNoteDef.name#2;
      var _loc7_:Array = recipeNoteDef.defaults;
      var _loc9_:Array = recipeNoteDef.appends;
      var _loc5_:Array = recipeNoteDef.happeningIds;
      var _loc10_:Boolean = true;
      for each(var _loc4_ in _loc7_)
      {
         if(UserDataWrapper.gudetamaPart.isCooked(_loc4_))
         {
            _loc8_++;
         }
         if(UserDataWrapper.gudetamaPart.hasRecipe(_loc4_))
         {
            _loc6_++;
            if(_loc10_ && UserDataWrapper.gudetamaPart.isAvailable(_loc4_) && UserDataWrapper.gudetamaPart.isNewGudetama(_loc4_))
            {
               _loc10_ = UserDataWrapper.gudetamaPart.isCooked(_loc4_);
            }
         }
      }
      if(_loc9_)
      {
         for each(_loc4_ in _loc9_)
         {
            if(UserDataWrapper.gudetamaPart.isCooked(_loc4_))
            {
               _loc8_++;
            }
            if(UserDataWrapper.gudetamaPart.hasRecipe(_loc4_))
            {
               _loc6_++;
               if(_loc10_ && UserDataWrapper.gudetamaPart.isAvailable(_loc4_) && (UserDataWrapper.gudetamaPart.canUnlockable(_loc4_) || UserDataWrapper.gudetamaPart.isUnlocked(_loc4_)))
               {
                  _loc10_ = UserDataWrapper.gudetamaPart.isCooked(_loc4_);
               }
            }
         }
      }
      if(_loc5_)
      {
         for each(_loc4_ in _loc5_)
         {
            if(UserDataWrapper.gudetamaPart.isCooked(_loc4_))
            {
               _loc8_++;
            }
         }
         _loc6_ += _loc5_.length;
      }
      numText.text#2 = _loc8_.toString() + "/" + _loc6_.toString();
      if(_loc8_ >= _loc6_)
      {
         incompleteBgImage.visible = false;
         completeBgImage.visible = true;
         completeImage.visible = true;
      }
      else
      {
         incompleteBgImage.visible = true;
         completeBgImage.visible = false;
         completeImage.visible = false;
      }
      newImage.visible = !_loc10_;
   }
   
   override public function dispose() : void
   {
      incompleteBgImage = null;
      completeBgImage = null;
      nameText = null;
      numText = null;
      completeImage = null;
      newImage = null;
      super.dispose();
   }
}

import gudetama.engine.BaseScene;
import muku.core.TaskQueue;
import starling.display.Sprite;

class LockedRecipeNoteItemUI extends RecipeItemUIBase
{
    
   
   function LockedRecipeNoteItemUI(param1:Sprite, param2:BaseScene)
   {
      super(param1,param2);
   }
   
   override public function setup(param1:TaskQueue, param2:Array, param3:Function) : void
   {
      super.setup(param1,param2,param3);
   }
   
   override public function dispose() : void
   {
      super.dispose();
   }
}

import gudetama.data.GameSetting;
import gudetama.data.compati.KitchenwareDef;
import gudetama.data.compati.RecipeNoteDef;
import gudetama.engine.BaseScene;
import gudetama.engine.TextureCollector;
import muku.core.TaskQueue;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

class PurchaseRecipeNoteItemUI extends RecipeItemUIBase
{
    
   
   private var iconImage:Image;
   
   private var priceText:ColorTextField;
   
   function PurchaseRecipeNoteItemUI(param1:Sprite, param2:BaseScene)
   {
      super(param1,param2);
      iconImage = button.getChildByName("icon") as Image;
      priceText = button.getChildByName("price") as ColorTextField;
   }
   
   override public function setup(param1:TaskQueue, param2:Array, param3:Function) : void
   {
      var queue:TaskQueue = param1;
      var argi:Array = param2;
      var callback:Function = param3;
      super.setup(queue,argi,callback);
      var recipeNoteDef:RecipeNoteDef = GameSetting.getRecipeNote(argi[0]);
      var kitchenwareDef:KitchenwareDef = GameSetting.getKitchenware(recipeNoteDef.kitchenwareId);
      queue.addTask(function():void
      {
         TextureCollector.loadTexture("recipe0@recipebuy" + kitchenwareDef.type,function(param1:Texture):void
         {
            iconImage.texture = param1;
            queue.taskDone();
         });
      });
      priceText.text#2 = recipeNoteDef.price.toString();
   }
   
   override public function dispose() : void
   {
      priceText = null;
      super.dispose();
   }
}

import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.GudetamaData;
import gudetama.data.compati.GudetamaDef;
import gudetama.engine.BaseScene;
import gudetama.engine.Engine;
import gudetama.engine.SoundManager;
import gudetama.engine.TweenAnimator;
import gudetama.util.StringUtil;
import muku.core.TaskQueue;
import muku.text.ColorTextField;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class RecipeGudetamaItemUI extends RecipeItemUIBase
{
    
   
   private var sprite:Sprite;
   
   private var group:Sprite;
   
   protected var iconImage:Image;
   
   private var complete:Image;
   
   private var lock:Image;
   
   private var newImage:Image;
   
   private var nameText:ColorTextField;
   
   private var numBackgroundImage:Image;
   
   private var numText:ColorTextField;
   
   private var baseWidth:Number;
   
   private var baseHeight:Number;
   
   private var spUnlockable:Sprite;
   
   private var spCookable:Sprite;
   
   function RecipeGudetamaItemUI(param1:Sprite, param2:BaseScene)
   {
      super(param1,param2);
      sprite = button.getChildByName("sprite") as Sprite;
      group = sprite.getChildByName("group") as Sprite;
      iconImage = group.getChildByName("icon") as Image;
      complete = group.getChildByName("complete") as Image;
      lock = group.getChildByName("lock") as Image;
      newImage = group.getChildByName("new") as Image;
      nameText = group.getChildByName("name") as ColorTextField;
      numBackgroundImage = group.getChildByName("numBg") as Image;
      numText = group.getChildByName("num") as ColorTextField;
      spUnlockable = group.getChildByName("spUnlockable") as Sprite;
      spCookable = group.getChildByName("spCookable") as Sprite;
      baseWidth = sprite.width;
      baseHeight = sprite.height;
   }
   
   override public function setup(param1:TaskQueue, param2:Array, param3:Function) : void
   {
      var queue:TaskQueue = param1;
      var argi:Array = param2;
      var callback:Function = param3;
      super.setup(queue,argi,callback);
      var gudetamaDef:GudetamaDef = GameSetting.getGudetama(argi[0]);
      var gudetamaData:GudetamaData = UserDataWrapper.gudetamaPart.getGudetama(argi[0]);
      switch(argi[2])
      {
         case 1:
         case 2:
            TweenAnimator.startItself(button,"size0");
            break;
         default:
            TweenAnimator.startItself(button,"size2");
      }
      TweenAnimator.finishItself(button);
      queue.addTask(function():void
      {
         scene.loadTexture("gudetama-" + gudetamaDef.rsrc + "-icon",function(param1:Texture):void
         {
            iconImage.texture = param1;
            queue.taskDone();
         });
      });
      nameText.text#2 = gudetamaDef.name#2;
      refresh();
   }
   
   public function getSprite() : DisplayObject
   {
      return iconImage;
   }
   
   override public function refresh() : void
   {
      var _loc1_:GudetamaData = UserDataWrapper.gudetamaPart.getGudetama(argi[0]);
      var _loc2_:Boolean = UserDataWrapper.gudetamaPart.isCooked(argi[0]);
      iconImage.color = !!_loc1_.unlocked ? 16777215 : 8421504;
      complete.visible = _loc1_.unlocked && _loc2_;
      lock.visible = !_loc1_.unlocked && !UserDataWrapper.gudetamaPart.isUnlockable(argi[0]);
      var _loc3_:int = UserDataWrapper.gudetamaPart.getNumGudetama(argi[0]);
      numBackgroundImage.visible = _loc2_;
      numText.visible = _loc2_;
      numText.text#2 = StringUtil.format(GameSetting.getUIText("mult.mark"),_loc3_);
      spUnlockable.visible = UserDataWrapper.gudetamaPart.canUnlockable(argi[0]);
      newImage.visible = UserDataWrapper.gudetamaPart.isAvailable(argi[0]) && UserDataWrapper.gudetamaPart.isNewGudetama(argi[0]);
      spCookable.visible = !spUnlockable.visible && UserDataWrapper.gudetamaPart.isUnlocked(argi[0]) && UserDataWrapper.gudetamaPart.isAvailable(argi[0]) && !UserDataWrapper.gudetamaPart.isCooked(argi[0]) && UserDataWrapper.gudetamaPart.hasCookableGP(argi[0]);
   }
   
   override protected function triggeredButton(param1:Event) : void
   {
      var event:Event = param1;
      Engine.lockTouchInput(RecipeGudetamaItemUI);
      scene.getSceneJuggler().delayCall(function():void
      {
         Engine.unlockTouchInput(RecipeGudetamaItemUI);
         SoundManager.playEffect("Recipe_PageNext");
         callback(argi[0],argi[1]);
      },0.395);
   }
   
   override public function dispose() : void
   {
      sprite = null;
      group = null;
      iconImage = null;
      complete = null;
      lock = null;
      newImage = null;
      nameText = null;
      super.dispose();
   }
}

import gudetama.engine.BaseScene;
import gudetama.engine.Engine;
import muku.core.TaskQueue;
import starling.display.Sprite;
import starling.events.Event;

class LockedRecipeGudetamaItemUI extends RecipeGudetamaItemUI
{
    
   
   function LockedRecipeGudetamaItemUI(param1:Sprite, param2:BaseScene)
   {
      super(param1,param2);
   }
   
   override public function setup(param1:TaskQueue, param2:Array, param3:Function) : void
   {
      super.setup(param1,param2,param3);
      iconImage.color = 0;
   }
   
   override protected function triggeredButton(param1:Event) : void
   {
      var event:Event = param1;
      Engine.lockTouchInput(LockedRecipeGudetamaItemUI);
      scene.getSceneJuggler().delayCall(function():void
      {
         Engine.unlockTouchInput(LockedRecipeGudetamaItemUI);
         callback(argi[0]);
      },0.395);
   }
   
   override public function dispose() : void
   {
      super.dispose();
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.GudetamaData;
import gudetama.data.compati.GudetamaDef;
import gudetama.data.compati.ItemParam;
import gudetama.engine.BaseScene;
import gudetama.engine.Engine;
import gudetama.engine.SoundManager;
import gudetama.engine.TweenAnimator;
import gudetama.net.HttpConnector;
import gudetama.net.PacketUtil;
import gudetama.scene.collection.GudetamaDetailDialog;
import gudetama.scene.friend.FriendPresentListDialog;
import gudetama.scene.kitchen.CookingScene;
import gudetama.scene.kitchen.GudetamaShortageDialog;
import gudetama.ui.LocalMessageDialog;
import gudetama.ui.ResidentMenuUI_Gudetama;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import muku.core.TaskQueue;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.textures.Texture;

class ConfirmUI extends UIBase
{
    
   
   private var scene:CookingScene;
   
   private var iconImage:Image;
   
   private var lockImage:Image;
   
   private var numberText:ColorTextField;
   
   private var raritySprite:Sprite;
   
   private var cookingGroup:Sprite;
   
   private var possessionText:ColorTextField;
   
   private var presentButton:FeatureButtonUI;
   
   private var listButton:FeatureButtonUI;
   
   private var costText:ColorTextField;
   
   private var rewardText:ColorTextField;
   
   private var countText:ColorTextField;
   
   private var cookingButton:ContainerButton;
   
   private var cookingShortageImage:Image;
   
   private var unlockGroup:Sprite;
   
   private var requiredGudetamas:Vector.<RequiredGudetamaUI>;
   
   private var unlockButton:ContainerButton;
   
   private var unlockSprite:Sprite;
   
   private var unlockShortageImage:Image;
   
   private var nameText:ColorTextField;
   
   private var categoryText:ColorTextField;
   
   private var targetGroup:Sprite;
   
   private var successQuad:Quad;
   
   private var happeningQuad:Quad;
   
   private var gudetamaId:int;
   
   private var recipeNoteId:int;
   
   private var kitchenwareType:int;
   
   private var unlockable:Boolean;
   
   private var currentTarget:int;
   
   function ConfirmUI(param1:Sprite, param2:BaseScene)
   {
      var _loc4_:int = 0;
      requiredGudetamas = new Vector.<RequiredGudetamaUI>();
      super(param1);
      this.scene = param2 as CookingScene;
      iconImage = param1.getChildByName("icon") as Image;
      lockImage = param1.getChildByName("lock") as Image;
      var _loc3_:Sprite = param1.getChildByName("numberGroup") as Sprite;
      numberText = _loc3_.getChildByName("number") as ColorTextField;
      raritySprite = param1.getChildByName("rarity") as Sprite;
      cookingGroup = param1.getChildByName("cookingGroup") as Sprite;
      possessionText = cookingGroup.getChildByName("possession") as ColorTextField;
      presentButton = new FeatureButtonUI(cookingGroup.getChildByName("btn_present") as ContainerButton,triggeredPresentButton);
      listButton = new FeatureButtonUI(cookingGroup.getChildByName("btn_list") as ContainerButton,triggeredListButton);
      costText = cookingGroup.getChildByName("cost") as ColorTextField;
      rewardText = cookingGroup.getChildByName("reward") as ColorTextField;
      countText = cookingGroup.getChildByName("count") as ColorTextField;
      cookingButton = cookingGroup.getChildByName("btn_cooking") as ContainerButton;
      cookingButton.addEventListener("triggered",triggeredCookingButton);
      cookingShortageImage = cookingGroup.getChildByName("shortage") as Image;
      unlockGroup = param1.getChildByName("unlockGroup") as Sprite;
      var _loc5_:Sprite = unlockGroup.getChildByName("unlocks") as Sprite;
      _loc4_ = 0;
      while(_loc4_ < _loc5_.numChildren)
      {
         requiredGudetamas.push(new RequiredGudetamaUI(_loc5_.getChildAt(_loc4_) as Sprite,param2,triggeredRequiredGudetamaUI));
         _loc4_++;
      }
      unlockButton = unlockGroup.getChildByName("unlockButton") as ContainerButton;
      unlockButton.addEventListener("triggered",triggeredUnlockButton);
      unlockSprite = unlockButton.getChildByName("sprite") as Sprite;
      unlockShortageImage = unlockGroup.getChildByName("shortage") as Image;
      nameText = param1.getChildByName("name") as ColorTextField;
      categoryText = param1.getChildByName("category") as ColorTextField;
      targetGroup = cookingGroup.getChildByName("targetGroup") as Sprite;
      successQuad = targetGroup.getChildByName("successQuad") as Quad;
      successQuad.addEventListener("touch",touchSuccessQuad);
      happeningQuad = targetGroup.getChildByName("happeningQuad") as Quad;
      happeningQuad.addEventListener("touch",touchHappeningQuad);
   }
   
   public function setup(param1:TaskQueue, param2:int, param3:int, param4:int) : void
   {
      var queue:TaskQueue = param1;
      var gudetamaId:int = param2;
      var recipeNoteId:int = param3;
      var kitchenwareType:int = param4;
      this.gudetamaId = gudetamaId;
      this.recipeNoteId = recipeNoteId;
      this.kitchenwareType = kitchenwareType;
      var gudetamaDef:GudetamaDef = GameSetting.getGudetama(gudetamaId);
      var gudetamaData:GudetamaData = UserDataWrapper.gudetamaPart.getGudetama(gudetamaId);
      queue.addTask(function():void
      {
         scene.loadTexture("gudetama-" + gudetamaDef.rsrc + "-icon",function(param1:Texture):void
         {
            iconImage.texture = param1;
            queue.taskDone();
         });
      });
      if(gudetamaDef.type != 1)
      {
         var numberGroup:Sprite = displaySprite.getChildByName("numberGroup") as Sprite;
         numberGroup.visible = false;
      }
      numberText.text#2 = StringUtil.format(GameSetting.getUIText("common.number"),gudetamaDef.number);
      queue.addTask(function():void
      {
         TweenAnimator.startItself(raritySprite,"rare" + gudetamaDef.rarity,false,function():void
         {
            queue.taskDone();
         });
      });
      if(gudetamaData.unlocked)
      {
         lockImage.visible = false;
         cookingGroup.visible = true;
         costText.text#2 = GameSetting.getUIText("common.money").replace("%1",StringUtil.getNumStringCommas(gudetamaDef.cost));
         rewardText.text#2 = GameSetting.getUIText("common.money").replace("%1",StringUtil.getNumStringCommas(gudetamaDef.reward));
         if(gudetamaData.count > 0)
         {
            countText.text#2 = gudetamaData.count.toString();
         }
         else
         {
            countText.text#2 = GameSetting.getUIText("gudetama.count.none");
         }
         unlockGroup.visible = false;
         iconImage.color = 16777215;
      }
      else
      {
         unlockable = UserDataWrapper.gudetamaPart.isUnlockable(gudetamaId);
         lockImage.visible = !unlockable;
         cookingGroup.visible = false;
         unlockGroup.visible = true;
         var i:int = 0;
         while(i < requiredGudetamas.length)
         {
            if(i < gudetamaDef.requiredGudetamas.length)
            {
               requiredGudetamas[i].setVisible(true);
               requiredGudetamas[i].setup(queue,gudetamaDef.requiredGudetamas[i]);
            }
            else
            {
               requiredGudetamas[i].setVisible(false);
            }
            i++;
         }
         unlockButton.setEnableWithDrawCache(unlockable);
         unlockShortageImage.visible = !unlockable;
         if(unlockable)
         {
            TweenAnimator.startItself(unlockSprite,"show");
         }
         else
         {
            TweenAnimator.finishItself(unlockSprite);
         }
         iconImage.color = 8421504;
         scene.processNoticeTutorial(13,null,getGuideArrowPos);
      }
      nameText.text#2 = gudetamaDef.name#2;
      categoryText.text#2 = GameSetting.getUIText("gudetama.category." + gudetamaDef.category);
      if(UserDataWrapper.featurePart.existsFeature(12))
      {
         targetGroup.visible = gudetamaDef.existsHappening();
         currentTarget = gudetamaData.currentTarget;
         queue.addTask(function():void
         {
            TweenAnimator.startItself(targetGroup,currentTarget == 0 ? "success" : "happening",false,function():void
            {
               TweenAnimator.startItself(targetGroup,"show");
               queue.taskDone();
            });
         });
      }
      else
      {
         targetGroup.visible = false;
      }
      update();
   }
   
   public function update() : void
   {
      var _loc1_:GudetamaData = UserDataWrapper.gudetamaPart.getGudetama(gudetamaId);
      if(_loc1_ == null)
      {
         return;
      }
      var _loc3_:GudetamaDef = GameSetting.getGudetama(gudetamaId);
      if(_loc1_.unlocked)
      {
         if(UserDataWrapper.wrapper.hasMoney(_loc3_.cost))
         {
            cookingButton.setEnableWithDrawCache(true);
            cookingShortageImage.visible = false;
         }
         else
         {
            cookingButton.setEnableWithDrawCache(false);
            cookingShortageImage.visible = true;
         }
         possessionText.text#2 = _loc1_.num.toString();
         listButton.setVisible(!_loc3_.uncountable);
         listButton.lock = false;
         listButton.enable = !UserDataWrapper.wantedPart.exists(gudetamaId) && UserDataWrapper.gudetamaPart.hasRecipe(gudetamaId) && UserDataWrapper.gudetamaPart.isCooked(gudetamaId);
         presentButton.setVisible(!_loc3_.uncountable);
         presentButton.lock = !UserDataWrapper.featurePart.existsFeature(12);
         presentButton.enable = UserDataWrapper.gudetamaPart.hasGudetama(_loc3_.id#2,1);
      }
      var _loc2_:Sprite = displaySprite.getChildByName("numberGroup") as Sprite;
      if(_loc3_.type != 1)
      {
         _loc2_.visible = false;
      }
      else
      {
         _loc2_.visible = true;
      }
   }
   
   private function triggeredPresentButton(param1:Boolean, param2:Boolean) : void
   {
      if(!UserDataWrapper.wrapper.isCompletedTutorial())
      {
         return;
      }
      if(param1)
      {
         LocalMessageDialog.show(0,GudetamaUtil.getFriendUnlockConditionText(),null,GameSetting.getUIText("gudetamaDetail.message.present.title"),!!UserDataWrapper.wrapper.isCompletedTutorial() ? 94 : 70);
      }
      else if(!param2)
      {
         LocalMessageDialog.show(0,GameSetting.getUIText("gudetamaDetail.message.present.disabled.desc"),null,GameSetting.getUIText("gudetamaDetail.message.present.title"),!!UserDataWrapper.wrapper.isCompletedTutorial() ? 94 : 70);
      }
      else
      {
         FriendPresentListDialog.show(gudetamaId);
      }
   }
   
   private function triggeredListButton(param1:Boolean, param2:Boolean) : void
   {
      var locked:Boolean = param1;
      var enabled:Boolean = param2;
      if(!UserDataWrapper.wrapper.isCompletedTutorial())
      {
         return;
      }
      if(!enabled)
      {
         if(!UserDataWrapper.gudetamaPart.hasRecipe(gudetamaId) || !UserDataWrapper.gudetamaPart.isCooked(gudetamaId))
         {
            LocalMessageDialog.show(0,GameSetting.getUIText("gudetamaDetail.message.list.notCooked.desc"),null,GameSetting.getUIText("gudetamaDetail.message.list.title"),!!UserDataWrapper.wrapper.isCompletedTutorial() ? 94 : 70);
         }
         else if(UserDataWrapper.wantedPart.exists(gudetamaId))
         {
            LocalMessageDialog.show(0,GameSetting.getUIText("gudetamaDetail.message.list.disabled.desc"),null,GameSetting.getUIText("gudetamaDetail.message.list.title"),!!UserDataWrapper.wrapper.isCompletedTutorial() ? 94 : 70);
         }
         return;
      }
      var gudetamaDef:GudetamaDef = GameSetting.getGudetama(gudetamaId);
      GudetamaDetailDialog.addWantedGudetama(gudetamaDef,function():void
      {
         listButton.enable = !UserDataWrapper.wantedPart.exists(gudetamaId) && UserDataWrapper.gudetamaPart.hasRecipe(gudetamaId) && UserDataWrapper.gudetamaPart.isCooked(gudetamaId);
      });
   }
   
   private function triggeredCookingButton(param1:Event) : void
   {
      var event:Event = param1;
      Engine.showLoading(CookingScene);
      if(UserDataWrapper.kitchenwarePart.finishedCooking(kitchenwareType) || UserDataWrapper.kitchenwarePart.isCooking(kitchenwareType))
      {
         LocalMessageDialog.show(0,GameSetting.getUIText("cooking.start.isCooking.message"));
         return;
      }
      var _loc2_:* = HttpConnector;
      if(gudetama.net.HttpConnector.mainConnector == null)
      {
         gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
      }
      gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(134217909,[recipeNoteId,gudetamaId,currentTarget]),function(param1:*):void
      {
         var response:* = param1;
         Engine.hideLoading(CookingScene);
         scene.resetMemoryRecipeArray();
         if(response is Array)
         {
            var code:int = response[0];
            LocalMessageDialog.show(0,GameSetting.getUIText("cooking.start.warn.message." + code),function(param1:int):void
            {
               var choose:int = param1;
               Engine.lockTouchInput(CookingScene);
               scene.setupForRecipeNote(-1,true,false,function():void
               {
                  Engine.unlockTouchInput(CookingScene);
               });
            },GameSetting.getUIText("cooking.start.warn.title." + code));
            return;
         }
         var gudetamaDef:GudetamaDef = GameSetting.getGudetama(gudetamaId);
         var gudetamaData:GudetamaData = UserDataWrapper.gudetamaPart.getGudetama(gudetamaId);
         UserDataWrapper.kitchenwarePart.addKitchenware(response);
         if(gudetamaDef.cost > 0)
         {
            ResidentMenuUI_Gudetama.consumeMoney(gudetamaDef.cost);
         }
         if(!gudetamaDef.existsHappening() && currentTarget == 1)
         {
            currentTarget = 0;
         }
         gudetamaData.currentTarget = currentTarget;
         Engine.lockTouchInput(CookingScene);
         scene.resetMemoryRecipeArray();
         scene.setupForRecipeNote(-1,false,true,function():void
         {
            Engine.unlockTouchInput(CookingScene);
         });
      });
   }
   
   private function triggeredRequiredGudetamaUI(param1:int) : void
   {
      GudetamaShortageDialog.show(param1);
   }
   
   private function triggeredUnlockButton(param1:Event) : void
   {
      var event:Event = param1;
      Engine.showLoading(CookingScene);
      SoundManager.playEffect("Learning");
      var _loc2_:* = HttpConnector;
      if(gudetama.net.HttpConnector.mainConnector == null)
      {
         gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
      }
      gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(134217925,gudetamaId),function(param1:GudetamaData):void
      {
         var response:GudetamaData = param1;
         Engine.hideLoading(CookingScene);
         UserDataWrapper.wrapper.addRecipe(response);
         var gudetamaDef:GudetamaDef = GameSetting.getGudetama(gudetamaId);
         for each(requiredGudetama in gudetamaDef.requiredGudetamas)
         {
            UserDataWrapper.wrapper.useItem(requiredGudetama);
         }
         Engine.lockTouchInput(CookingScene);
         var queue:TaskQueue = new TaskQueue();
         setVisible(false);
         setup(queue,gudetamaId,recipeNoteId,kitchenwareType);
         scene.setupUnlockUI(queue,gudetamaId);
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            scene.updateScene();
            Engine.unlockTouchInput(CookingScene);
            scene.showUnlockUI();
         });
         queue.startTask();
      });
   }
   
   public function getStartCookingBtnPos() : Vector.<Number>
   {
      return GudetamaUtil.getCenterPosAndWHOnEngine(cookingButton);
   }
   
   public function getGuideArrowPos(param1:int) : Vector.<Number>
   {
      var _loc2_:* = undefined;
      switch(int(param1))
      {
         case 0:
            return GudetamaUtil.getCenterPosAndWHOnEngine(requiredGudetamas[0].getDisplaySprite());
         case 1:
            return GudetamaUtil.getCenterPosAndWHOnEngine(unlockButton);
         default:
            return _loc2_;
      }
   }
   
   private function touchSuccessQuad(param1:TouchEvent) : void
   {
      var _loc2_:Touch = param1.getTouch(successQuad);
      if(_loc2_ == null)
      {
         return;
      }
      if(_loc2_.phase == "ended")
      {
         TweenAnimator.startItself(targetGroup,"success");
         TweenAnimator.finishItself(targetGroup);
         TweenAnimator.startItself(targetGroup,"show");
         currentTarget = 0;
      }
   }
   
   private function touchHappeningQuad(param1:TouchEvent) : void
   {
      var _loc2_:Touch = param1.getTouch(happeningQuad);
      if(_loc2_ == null)
      {
         return;
      }
      if(_loc2_.phase == "ended")
      {
         TweenAnimator.startItself(targetGroup,"happening");
         TweenAnimator.finishItself(targetGroup);
         TweenAnimator.startItself(targetGroup,"show");
         currentTarget = 1;
      }
   }
   
   public function getGudetamaId() : int
   {
      return gudetamaId;
   }
   
   public function dispose() : void
   {
      iconImage = null;
      lockImage = null;
      numberText = null;
      raritySprite = null;
      cookingGroup = null;
      possessionText = null;
      if(presentButton)
      {
         presentButton.dispose();
         presentButton = null;
      }
      if(listButton)
      {
         listButton.dispose();
         listButton = null;
      }
      costText = null;
      rewardText = null;
      countText = null;
      if(cookingButton)
      {
         cookingButton.removeEventListener("triggered",triggeredCookingButton);
         cookingButton = null;
      }
      cookingShortageImage = null;
      unlockGroup = null;
      for each(var _loc1_ in requiredGudetamas)
      {
         _loc1_.dispose();
      }
      requiredGudetamas.length = 0;
      requiredGudetamas = null;
      if(unlockButton)
      {
         unlockButton.removeEventListener("triggered",triggeredUnlockButton);
         unlockButton = null;
      }
      unlockSprite = null;
      unlockShortageImage = null;
      nameText = null;
      categoryText = null;
      targetGroup = null;
      if(successQuad)
      {
         successQuad.addEventListener("touch",touchSuccessQuad);
         successQuad = null;
      }
      if(happeningQuad)
      {
         happeningQuad.addEventListener("touch",touchHappeningQuad);
         happeningQuad = null;
      }
   }
}

import gudetama.data.GameSetting;
import gudetama.data.compati.GudetamaDef;
import gudetama.engine.BaseScene;
import gudetama.engine.Engine;
import gudetama.engine.SoundManager;
import gudetama.engine.TweenAnimator;
import gudetama.scene.kitchen.CookingScene;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import muku.core.TaskQueue;
import muku.display.SpineModel;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.textures.Texture;

class UnlockUI extends UIBase
{
   
   private static const UNLOCK_SPINE_NAME:String = "efx_spine-unlock";
    
   
   private var quad:Quad;
   
   private var spineModel:SpineModel;
   
   private var sprite:Sprite;
   
   private var numberText:ColorTextField;
   
   private var iconImage:Image;
   
   private var nameText:ColorTextField;
   
   private var scene:CookingScene;
   
   private var callback:Function;
   
   private var shown:Boolean;
   
   function UnlockUI(param1:Sprite, param2:BaseScene, param3:Function)
   {
      super(param1);
      this.scene = param2 as CookingScene;
      this.callback = param3;
      quad = param1.getChildByName("quad") as Quad;
      quad.addEventListener("touch",touchQuad);
      spineModel = param1.getChildByName("spineModel") as SpineModel;
      sprite = param1.getChildByName("sprite") as Sprite;
      numberText = sprite.getChildByName("number") as ColorTextField;
      iconImage = sprite.getChildByName("icon") as Image;
      nameText = sprite.getChildByName("name") as ColorTextField;
   }
   
   public function setup(param1:TaskQueue, param2:int) : void
   {
      var queue:TaskQueue = param1;
      var gudetamaId:int = param2;
      var gudetamaDef:GudetamaDef = GameSetting.getGudetama(gudetamaId);
      queue.addTask(function():void
      {
         spineModel.load("efx_spine-unlock",function():void
         {
            queue.taskDone();
         });
      });
      numberText.text#2 = StringUtil.format(GameSetting.getUIText("gudetamaDetail.number"),gudetamaDef.number);
      queue.addTask(function():void
      {
         scene.loadTexture("gudetama-" + gudetamaDef.rsrc + "-icon",function(param1:Texture):void
         {
            iconImage.texture = param1;
            queue.taskDone();
         });
      });
      nameText.text#2 = gudetamaDef.name#2;
      shown = false;
   }
   
   public function show(param1:Function) : void
   {
      var callback:Function = param1;
      setVisible(true);
      spineModel.show();
      SoundManager.playEffect("Learning_jin");
      spineModel.changeAnimation("start",true,function():void
      {
         spineModel.changeAnimation("loop");
      });
      TweenAnimator.startItself(sprite,"show",false,function():void
      {
         var _loc1_:int = Math.random() * 3;
         switch(int(_loc1_))
         {
            case 0:
               SoundManager.playEffect("0030");
               break;
            case 1:
               SoundManager.playEffect("0031");
               break;
            case 2:
               SoundManager.playEffect("0032");
         }
         shown = true;
         callback();
      });
   }
   
   private function touchQuad(param1:TouchEvent) : void
   {
      var _loc2_:Touch = param1.getTouch(quad);
      if(_loc2_ == null)
      {
         return;
      }
      if(!shown)
      {
         return;
      }
      if(_loc2_.phase == "ended")
      {
         callback();
         spineModel.finish();
         Engine.removeSpineCache("efx_spine-unlock");
         shown = false;
      }
   }
   
   public function dispose() : void
   {
      if(quad)
      {
         quad.removeEventListener("touch",touchQuad);
         quad = null;
      }
      spineModel = null;
      sprite = null;
      numberText = null;
      iconImage = null;
      nameText = null;
      callback = null;
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.GudetamaDef;
import gudetama.data.compati.ItemParam;
import gudetama.engine.BaseScene;
import gudetama.scene.kitchen.CookingScene;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import muku.core.TaskQueue;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class RequiredGudetamaUI extends UIBase
{
    
   
   private var scene:CookingScene;
   
   private var callback:Function;
   
   private var button:ContainerButton;
   
   private var iconImage:Image;
   
   private var numberText:ColorTextField;
   
   private var nameText:ColorTextField;
   
   private var numText:ColorTextField;
   
   private var maxText:ColorTextField;
   
   private var imgHappening:Image;
   
   private var gudetamaId:int;
   
   function RequiredGudetamaUI(param1:Sprite, param2:BaseScene, param3:Function)
   {
      super(param1);
      this.scene = param2 as CookingScene;
      this.callback = param3;
      var _loc4_:Sprite;
      button = (_loc4_ = param1.getChildByName("item") as Sprite).getChildByName("button") as ContainerButton;
      button.addEventListener("triggered",triggeredButton);
      button.setDisableColor(8421504);
      iconImage = button.getChildByName("icon") as Image;
      numberText = button.getChildByName("number") as ColorTextField;
      nameText = button.getChildByName("name") as ColorTextField;
      imgHappening = _loc4_.getChildByName("imgHappening") as Image;
      numText = param1.getChildByName("num") as ColorTextField;
      maxText = param1.getChildByName("max") as ColorTextField;
   }
   
   public function setup(param1:TaskQueue, param2:ItemParam) : void
   {
      var queue:TaskQueue = param1;
      var item:ItemParam = param2;
      gudetamaId = item.id#2;
      var gudetamaDef:GudetamaDef = GameSetting.getGudetama(item.id#2);
      if(gudetamaDef.type != 1)
      {
         numberText.visible = false;
      }
      numberText.text#2 = StringUtil.format(GameSetting.getUIText("common.number"),StringUtil.decimalFormat(GameSetting.getUIText("common.number.format"),gudetamaDef.number));
      nameText.text#2 = gudetamaDef.getWrappedName();
      imgHappening.visible = gudetamaDef.cookingResultType == 1;
      var num:int = UserDataWrapper.gudetamaPart.getNumGudetama(gudetamaDef.id#2);
      var max:int = item.num;
      numText.text#2 = num.toString();
      numText.color = num >= max ? 4142380 : 16711680;
      maxText.text#2 = max.toString();
      if(queue)
      {
         queue.addTask(function():void
         {
            scene.loadTexture(GudetamaUtil.getCollectionIconName(gudetamaDef.id#2),function(param1:Texture):void
            {
               iconImage.texture = param1;
               button.touchable = num < max;
               button.enableDrawCache(true,false,num < max);
               queue.taskDone();
            });
         });
      }
      else
      {
         scene.loadTexture(GudetamaUtil.getCollectionIconName(gudetamaDef.id#2),function(param1:Texture):void
         {
            if(iconImage != null)
            {
               iconImage.texture = param1;
            }
            if(button != null)
            {
               button.touchable = num < max;
               button.enableDrawCache(true,false,num < max);
            }
         });
      }
   }
   
   private function triggeredButton(param1:Event) : void
   {
      callback(gudetamaId);
   }
   
   public function dispose() : void
   {
      callback = null;
      button.removeEventListener("triggered",triggeredButton);
      button = null;
      iconImage = null;
      numberText = null;
      nameText = null;
      numText = null;
      maxText = null;
      imgHappening = null;
   }
}

import gudetama.ui.UIBase;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;

class FeatureButtonUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var buttonImage:Image;
   
   private var lockImage:Image;
   
   private var locked:Boolean;
   
   private var enabled:Boolean;
   
   function FeatureButtonUI(param1:Sprite, param2:Function)
   {
      super(param1);
      this.callback = param2;
      param1.addEventListener("triggered",triggeredButton);
      buttonImage = param1.getChildByName("image") as Image;
      lockImage = param1.getChildByName("lock") as Image;
   }
   
   private function triggeredButton(param1:Event) : void
   {
      callback(locked,enabled);
   }
   
   public function set lock(param1:Boolean) : void
   {
      buttonImage.color = !!param1 ? 8421504 : 16777215;
      lockImage.visible = param1;
      locked = param1;
   }
   
   public function set enable(param1:Boolean) : void
   {
      if(locked)
      {
         return;
      }
      buttonImage.color = !!param1 ? 16777215 : 8421504;
      enabled = param1;
   }
   
   public function dispose() : void
   {
      displaySprite.removeEventListener("triggered",triggeredButton);
      buttonImage = null;
      lockImage = null;
   }
}

import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.GudetamaDef;
import gudetama.data.compati.KitchenwareDef;
import gudetama.engine.BaseScene;
import gudetama.scene.kitchen.CookingScene;
import gudetama.ui.UIBase;
import gudetama.util.SpriteExtractor;
import muku.core.TaskQueue;
import starling.display.Sprite;

class MaterialGroupUI extends UIBase
{
   
   private static const MATERIAL_NUM:int = 4;
    
   
   private var scene:CookingScene;
   
   private var backGroup:Sprite;
   
   private var frontGroup:Sprite;
   
   private var extractor:SpriteExtractor;
   
   private var materials:Vector.<MaterialUI>;
   
   private var types:Array;
   
   function MaterialGroupUI(param1:Sprite, param2:BaseScene)
   {
      materials = new Vector.<MaterialUI>();
      types = [];
      super(param1);
      this.scene = param2 as CookingScene;
      backGroup = param1.getChildByName("backMaterialGroup") as Sprite;
      frontGroup = param1.getChildByName("frontMaterialGroup") as Sprite;
   }
   
   public function init(param1:SpriteExtractor) : void
   {
      this.extractor = param1;
   }
   
   public function setup(param1:TaskQueue, param2:int) : void
   {
      var _loc6_:* = null;
      var _loc4_:* = null;
      var _loc5_:int = 0;
      var _loc7_:KitchenwareDef = GameSetting.getKitchenwareByType(param2,0);
      var _loc3_:int = UserDataWrapper.kitchenwarePart.getGudetamaId(param2);
      if(_loc3_ > 0)
      {
         _loc6_ = GameSetting.getGudetama(_loc3_);
         types.length = 0;
         _loc5_ = 0;
         while(_loc5_ < 9)
         {
            if((_loc6_.materials & 1 << _loc5_) != 0)
            {
               types.push(_loc5_);
               if(types.length >= 4)
               {
                  break;
               }
            }
            _loc5_++;
         }
         _loc5_ = 0;
         while(_loc5_ < types.length)
         {
            if(_loc5_ < materials.length)
            {
               _loc4_ = materials[_loc5_];
               if(_loc7_.materialLayer == 0)
               {
                  backGroup.removeChild(_loc4_.getDisplaySprite());
                  frontGroup.removeChild(_loc4_.getDisplaySprite());
                  backGroup.addChild(_loc4_.getDisplaySprite());
               }
               else
               {
                  backGroup.removeChild(_loc4_.getDisplaySprite());
                  frontGroup.removeChild(_loc4_.getDisplaySprite());
                  frontGroup.addChild(_loc4_.getDisplaySprite());
               }
            }
            else
            {
               _loc4_ = new MaterialUI(extractor.duplicateAll() as Sprite,scene);
               materials.push(_loc4_);
               if(_loc7_.materialLayer == 0)
               {
                  backGroup.addChild(_loc4_.getDisplaySprite());
               }
               else
               {
                  frontGroup.addChild(_loc4_.getDisplaySprite());
               }
            }
            _loc4_.load(param1,types[_loc5_]);
            _loc5_++;
         }
         while(_loc5_ < materials.length)
         {
            materials[_loc5_].setVisible(false);
            _loc5_++;
         }
      }
      else
      {
         types.length = 0;
         _loc5_ = 0;
         while(_loc5_ < materials.length)
         {
            materials[_loc5_].setVisible(false);
            _loc5_++;
         }
      }
   }
   
   public function show(param1:Boolean = false) : void
   {
      var _loc2_:int = 0;
      _loc2_ = 0;
      while(_loc2_ < types.length)
      {
         materials[_loc2_].startTween("pos" + _loc2_);
         materials[_loc2_].finishTween();
         _loc2_++;
      }
      if(param1)
      {
         _loc2_ = 0;
         while(_loc2_ < types.length)
         {
            playAnimation(_loc2_,_loc2_ % 2 == 0);
            _loc2_++;
         }
      }
      else
      {
         _loc2_ = 0;
         while(_loc2_ < types.length)
         {
            materials[_loc2_].show();
            _loc2_++;
         }
      }
   }
   
   private function playAnimation(param1:int, param2:Boolean) : void
   {
      var index:int = param1;
      var isLeft:Boolean = param2;
      scene.getSceneJuggler().delayCall(function():void
      {
         materials[index].show();
         materials[index].startTween(!!isLeft ? "fromLeft" : "fromRight");
      },0.2 * index);
   }
   
   public function dispose() : void
   {
      extractor = null;
      backGroup = null;
      frontGroup = null;
      if(materials)
      {
         for each(var _loc1_ in materials)
         {
            _loc1_.dispose();
         }
         materials.length = 0;
         materials = null;
      }
      if(types)
      {
         types.length = 0;
         types = null;
      }
   }
}

import gudetama.engine.BaseScene;
import gudetama.scene.kitchen.CookingScene;
import gudetama.ui.UIBase;
import muku.core.TaskQueue;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

class MaterialUI extends UIBase
{
    
   
   private var scene:CookingScene;
   
   private var image:Image;
   
   function MaterialUI(param1:Sprite, param2:BaseScene)
   {
      super(param1);
      this.scene = param2 as CookingScene;
      image = param1.getChildByName("image") as Image;
   }
   
   public function load(param1:TaskQueue, param2:int) : void
   {
      var queue:TaskQueue = param1;
      var type:int = param2;
      setVisible(false);
      queue.addTask(function():void
      {
         scene.loadTexture("material-" + type,function(param1:Texture):void
         {
            image.texture = param1;
            image.width = param1.width;
            image.height = param1.height;
            queue.taskDone();
         });
      });
   }
   
   public function show() : void
   {
      setVisible(true);
   }
   
   public function dispose() : void
   {
      image = null;
   }
}
