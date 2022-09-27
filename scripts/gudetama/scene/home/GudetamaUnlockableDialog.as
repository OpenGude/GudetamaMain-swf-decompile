package gudetama.scene.home
{
   import feathers.controls.IScrollBar;
   import feathers.controls.List;
   import feathers.controls.ScrollBar;
   import feathers.controls.renderers.IListItemRenderer;
   import feathers.data.ListCollection;
   import feathers.layout.FlowLayout;
   import gudetama.data.GameSetting;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.scene.shop.ShopScene_Gudetama;
   import gudetama.ui.LocalMessageDialog;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.util.SpriteExtractor;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class GudetamaUnlockableDialog extends BaseScene
   {
       
      
      private var imgListBG:Image;
      
      private var list:List;
      
      private var closeButton:ContainerButton;
      
      private var extractor:SpriteExtractor;
      
      protected var collection:ListCollection;
      
      private var loadCount:int;
      
      private var gudetamaList:Array;
      
      private var backCallback:Function;
      
      public function GudetamaUnlockableDialog(param1:Array, param2:Function)
      {
         collection = new ListCollection();
         super(2);
         gudetamaList = param1;
         backCallback = param2;
         addEventListener("update_scene",updateScene);
      }
      
      public static function show(param1:Array, param2:Function) : void
      {
         if(!param1 || param1.length < 0)
         {
            param2();
            return;
         }
         Engine.pushScene(new GudetamaUnlockableDialog(param1,param2),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"GudetamaUnlockableDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            imgListBG = _loc2_.getChildByName("imgListBG") as Image;
            list = _loc2_.getChildByName("list") as List;
            closeButton = _loc2_.getChildByName("btn_back") as ContainerButton;
            closeButton.addEventListener("triggered",triggeredCloseButton);
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         setupLayoutForTask(queue,"_RecipeGudetamaUnlockable",function(param1:Object):void
         {
            extractor = SpriteExtractor.forGross(param1.object,param1);
         });
         queue.registerOnProgress(function(param1:Number):void
         {
         });
         queue.startTask(onProgress);
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
         var layout:FlowLayout = new FlowLayout();
         layout.horizontalAlign = "left";
         layout.horizontalGap = 10;
         layout.verticalGap = 10;
         layout.paddingTop = 5;
         layout.paddingLeft = 0;
         list.layout = layout;
         list.itemRendererFactory = function():IListItemRenderer
         {
            return new GudetamaListItemRenderer(extractor,scene,triggeredUsefulItemUI);
         };
         list.selectedIndex = -1;
         list.dataProvider = collection;
         list.verticalScrollBarFactory = function():IScrollBar
         {
            var _loc1_:ScrollBar = new ScrollBar();
            _loc1_.trackLayoutMode = "single";
            return _loc1_;
         };
         list.scrollBarDisplayMode = "fixedFloat";
         list.horizontalScrollPolicy = "off";
         list.verticalScrollPolicy = "auto";
         list.interactionMode = "touchAndScrollBars";
         setupRecipe();
      }
      
      private function setupRecipe() : void
      {
         var _loc3_:int = 0;
         var _loc1_:int = 0;
         var _loc2_:TaskQueue = new TaskQueue();
         var _loc4_:Array = gudetamaList;
         _loc3_ = 0;
         while(_loc3_ < _loc4_.length)
         {
            _loc1_ = _loc4_[_loc3_];
            collection.addItem({
               "id":_loc1_,
               "Callback":triggeredLockedRecipeGudetamaItemUICallback
            });
            _loc3_++;
         }
      }
      
      public function triggeredLockedRecipeGudetamaItemUICallback(param1:int) : void
      {
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(UsefulListDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(UsefulListDialog);
         });
      }
      
      private function triggeredUsefulItemUI(param1:int) : void
      {
      }
      
      override public function backButtonCallback() : void
      {
         back();
      }
      
      private function back() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(UsefulListDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(UsefulListDialog);
            Engine.popScene(scene);
            backCallback();
         });
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      private function triggeredGoShop() : void
      {
         LocalMessageDialog.show(1,GameSetting.getUIText("common.confirm.go.shop"),function(param1:int):void
         {
            var choose:int = param1;
            if(choose == 1)
            {
               return;
            }
            ResidentMenuUI_Gudetama.getInstance().sendChangeState(62,function():void
            {
               Engine.switchScene(new ShopScene_Gudetama(3));
            });
         });
      }
      
      private function updateScene() : void
      {
         collection.updateAll();
      }
      
      override public function dispose() : void
      {
         imgListBG = null;
         list = null;
         closeButton.removeEventListener("triggered",triggeredCloseButton);
         closeButton = null;
         extractor = null;
         collection = null;
         super.dispose();
      }
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.engine.BaseScene;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class GudetamaListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var scene:BaseScene;
   
   private var callback:Function;
   
   private var displaySprite:Sprite;
   
   private var gudetamaRecipe:RecipeGudetamaItemUI;
   
   function GudetamaListItemRenderer(param1:SpriteExtractor, param2:BaseScene, param3:Function)
   {
      super();
      this.extractor = param1;
      this.scene = param2;
      this.callback = param3;
   }
   
   override protected function initialize() : void
   {
      if(displaySprite)
      {
         return;
      }
      displaySprite = extractor.duplicateAll() as Sprite;
      gudetamaRecipe = new RecipeGudetamaItemUI(displaySprite,scene);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      gudetamaRecipe.updateData(data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      callback = null;
      displaySprite = null;
      gudetamaRecipe.dispose();
      gudetamaRecipe = null;
      super.dispose();
   }
}

import gudetama.engine.BaseScene;
import gudetama.scene.kitchen.CookingScene;
import gudetama.ui.UIBase;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Sprite;
import starling.events.Event;

class RecipeItemUIBase extends UIBase
{
    
   
   protected var scene:CookingScene;
   
   protected var button:ContainerButton;
   
   protected var gudetamaId:int;
   
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
   
   public function setup(param1:int, param2:Function, param3:Function) : void
   {
      this.gudetamaId = param1;
      this.callback = param2;
   }
   
   public function refresh() : void
   {
   }
   
   protected function triggeredButton(param1:Event) : void
   {
      callback(gudetamaId);
   }
   
   public function getButton() : ContainerButton
   {
      return button;
   }
   
   public function dispose() : void
   {
      button.removeEventListener("triggered",triggeredButton);
      button = null;
      callback = null;
   }
}

import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.GudetamaData;
import gudetama.data.compati.GudetamaDef;
import gudetama.data.compati.KitchenwareDef;
import gudetama.data.compati.RecipeNoteDef;
import gudetama.engine.BaseScene;
import gudetama.engine.Engine;
import gudetama.engine.TextureCollector;
import gudetama.engine.TweenAnimator;
import gudetama.scene.home.HomeScene;
import gudetama.scene.kitchen.CookingScene;
import gudetama.ui.MessageDialog;
import gudetama.ui.ResidentMenuUI_Gudetama;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class RecipeGudetamaItemUI extends UIBase
{
    
   
   private var sprite:Sprite;
   
   private var button:ContainerButton;
   
   private var gudetamaId:int;
   
   private var recipeNoteDef:RecipeNoteDef;
   
   private var kitchenwareDef:KitchenwareDef;
   
   private var callback:Function;
   
   private var group:Sprite;
   
   private var iconImage:Image;
   
   private var lock:Image;
   
   private var circleImage:Image;
   
   private var groupnameText:ColorTextField;
   
   private var baseWidth:Number;
   
   private var baseHeight:Number;
   
   private var spUnlockable:Sprite;
   
   private var spCookable:Sprite;
   
   protected var scene:CookingScene;
   
   function RecipeGudetamaItemUI(param1:Sprite, param2:BaseScene)
   {
      super(param1,param2);
      button = param1.getChildByName("button") as ContainerButton;
      button.addEventListener("triggered",triggeredButton);
      sprite = button.getChildByName("sprite") as Sprite;
      group = sprite.getChildByName("group") as Sprite;
      iconImage = group.getChildByName("icon") as Image;
      lock = group.getChildByName("lock") as Image;
      circleImage = group.getChildByName("circle") as Image;
      groupnameText = group.getChildByName("name") as ColorTextField;
      spUnlockable = group.getChildByName("spUnlockable") as Sprite;
      spCookable = group.getChildByName("spCookable") as Sprite;
      baseWidth = sprite.width;
      baseHeight = sprite.height;
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      if(!data)
      {
         return;
      }
      gudetamaId = data.id;
      callback = data.callback;
      var recipeid:int = GameSetting.getRecipeNotoId(gudetamaId);
      recipeNoteDef = GameSetting.getRecipeNote(recipeid);
      kitchenwareDef = !!recipeNoteDef ? GameSetting.getKitchenware(recipeNoteDef.kitchenwareId) : null;
      var gudetamaDef:GudetamaDef = GameSetting.getGudetama(gudetamaId);
      var gudetamaData:GudetamaData = UserDataWrapper.gudetamaPart.getGudetama(gudetamaId);
      TweenAnimator.finishItself(button);
      TextureCollector.loadTexture("gudetama-" + gudetamaDef.rsrc + "-icon",function(param1:Texture):void
      {
         iconImage.texture = param1;
      });
      TextureCollector.loadTexture("recipe0@circle" + (kitchenwareDef.id#2 - 1),function(param1:Texture):void
      {
         circleImage.texture = param1;
      });
      groupnameText.text#2 = gudetamaDef.name#2;
      refresh();
   }
   
   public function getSprite() : DisplayObject
   {
      return iconImage;
   }
   
   public function refresh() : void
   {
      var _loc1_:GudetamaData = UserDataWrapper.gudetamaPart.getGudetama(gudetamaId);
      var _loc2_:Boolean = UserDataWrapper.gudetamaPart.isCooked(gudetamaId);
      iconImage.color = !!_loc1_.unlocked ? 16777215 : 8421504;
      lock.visible = !_loc1_.unlocked && !UserDataWrapper.gudetamaPart.isUnlockable(gudetamaId);
      spUnlockable.visible = !UserDataWrapper.gudetamaPart.isUnlocked(gudetamaId) && UserDataWrapper.gudetamaPart.isAvailable(gudetamaId) && UserDataWrapper.gudetamaPart.hasRequiredGudetama(gudetamaId) && UserDataWrapper.gudetamaPart.isUnlockable(gudetamaId);
      spCookable.visible = !spUnlockable.visible && UserDataWrapper.gudetamaPart.isUnlocked(gudetamaId) && UserDataWrapper.gudetamaPart.isAvailable(gudetamaId) && !UserDataWrapper.gudetamaPart.isCooked(gudetamaId) && UserDataWrapper.gudetamaPart.hasCookableGP(gudetamaId);
   }
   
   protected function triggeredButton(param1:Event) : void
   {
      var event:Event = param1;
      if(!kitchenwareDef)
      {
         return;
      }
      MessageDialog.show(2,StringUtil.format(GameSetting.getUIText("gudetamaunlock.button.confirm"),groupnameText.text#2),function(param1:int):void
      {
         var choose:int = param1;
         if(choose == 1)
         {
            return;
         }
         var param:Object = {
            "kitchenwareType":kitchenwareDef.type,
            "kitchenwareId":kitchenwareDef.id#2
         };
         param["recipeNoteId"] = recipeNoteDef.id#2;
         param["gudetamaId"] = gudetamaId;
         param["forceRecipe"] = true;
         ResidentMenuUI_Gudetama.getInstance().sendChangeState(60,function():void
         {
            Engine.switchScene(new HomeScene(kitchenwareDef.type,param));
         });
      });
   }
   
   public function dispose() : void
   {
      sprite = null;
      group = null;
      iconImage = null;
      lock = null;
      groupnameText = null;
   }
}
