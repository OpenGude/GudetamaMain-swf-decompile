package gudetama.scene.home
{
   import feathers.controls.IScrollBar;
   import feathers.controls.List;
   import feathers.controls.ScrollBar;
   import feathers.controls.renderers.IListItemRenderer;
   import feathers.data.ListCollection;
   import feathers.layout.FlowLayout;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.UsefulDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.scene.shop.ShopScene_Gudetama;
   import gudetama.ui.LocalMessageDialog;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.ui.UsefulDetailDialog;
   import gudetama.util.SpriteExtractor;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.display.SimpleImageButton;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class UsefulListDialog extends BaseScene
   {
       
      
      private var imgListBG:Image;
      
      private var list:List;
      
      private var btnGoShop:SimpleImageButton;
      
      private var closeButton:ContainerButton;
      
      private var extractor:SpriteExtractor;
      
      protected var collection:ListCollection;
      
      private var loadCount:int;
      
      private var cachedRsrcNameMap:Object = null;
      
      private var rootClass:Class;
      
      public function UsefulListDialog(param1:Class, param2:Boolean)
      {
         collection = new ListCollection();
         super(2);
         if(param2)
         {
            cachedRsrcNameMap = {};
         }
         addEventListener("update_scene",updateScene);
         rootClass = param1;
      }
      
      public static function show(param1:Class, param2:Boolean = true) : void
      {
         Engine.pushScene(new UsefulListDialog(param1,param2),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"UsefulListDialog_1",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            imgListBG = _loc2_.getChildByName("imgListBG") as Image;
            list = _loc2_.getChildByName("list") as List;
            btnGoShop = _loc2_.getChildByName("btnGoShop") as SimpleImageButton;
            btnGoShop.addEventListener("triggered",triggeredGoShop);
            closeButton = _loc2_.getChildByName("btn_back") as ContainerButton;
            closeButton.addEventListener("triggered",triggeredCloseButton);
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         setupLayoutForTask(queue,"_UsefulListItem",function(param1:Object):void
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
            return new UsefulListItemRenderer(extractor,scene,triggeredUsefulItemUI);
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
         setup();
      }
      
      private function setup() : void
      {
         var _loc3_:* = null;
         var _loc4_:Number = NaN;
         var _loc1_:Object = UserDataWrapper.usefulPart.getUsefulMap();
         var _loc2_:Array = [];
         for(var _loc5_ in _loc1_)
         {
            _loc3_ = GameSetting.getUseful(_loc5_);
            if(!GameSetting.isPrivately(8,_loc5_))
            {
               if(_loc3_.isUsable(1))
               {
                  _loc2_.push(_loc5_);
               }
            }
         }
         _loc2_.sort(ascendingKeyComparator);
         for each(_loc5_ in _loc2_)
         {
            collection.addItem({"id":_loc5_});
         }
         if(!GameSetting.getRule().usefulShopShortcut)
         {
            btnGoShop.visible = false;
            _loc4_ = btnGoShop.y + btnGoShop.height - list.y;
            list.height = _loc4_;
            imgListBG.height = _loc4_;
         }
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
            resumeNoticeTutorial(7);
         });
      }
      
      public function loadTexture(param1:String, param2:Function) : void
      {
         TextureCollector.loadTexture(param1,param2);
         if(cachedRsrcNameMap != null)
         {
            cachedRsrcNameMap[param1] = param1;
         }
      }
      
      private function clearCache() : void
      {
         if(cachedRsrcNameMap != null)
         {
            for(var _loc1_ in cachedRsrcNameMap)
            {
               TextureCollector.clearAtName(_loc1_);
            }
            cachedRsrcNameMap = {};
         }
         TextureCollector.clearAtName("benri0");
      }
      
      private function triggeredUsefulItemUI(param1:int) : void
      {
         var id:int = param1;
         back(function():void
         {
            UsefulDetailDialog.show(id,rootClass,function():void
            {
               UsefulListDialog.show(rootClass);
            });
         });
      }
      
      override public function backButtonCallback() : void
      {
         if(Engine.getGuideTalkPanel() != null)
         {
            return;
         }
         back();
      }
      
      private function back(param1:Function = null) : void
      {
         var callback:Function = param1;
         super.backButtonCallback();
         Engine.lockTouchInput(UsefulListDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(UsefulListDialog);
            Engine.popScene(scene);
            if(callback)
            {
               callback();
            }
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
         btnGoShop.removeEventListener("triggered",triggeredGoShop);
         btnGoShop = null;
         closeButton.removeEventListener("triggered",triggeredCloseButton);
         closeButton = null;
         extractor = null;
         collection = null;
         clearCache();
         super.dispose();
      }
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.engine.BaseScene;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class UsefulListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var scene:BaseScene;
   
   private var callback:Function;
   
   private var displaySprite:Sprite;
   
   private var usefulItemUI:UsefulItemUI;
   
   function UsefulListItemRenderer(param1:SpriteExtractor, param2:BaseScene, param3:Function)
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
      usefulItemUI = new UsefulItemUI(displaySprite,scene,callback);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      usefulItemUI.updateData(data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      callback = null;
      displaySprite = null;
      usefulItemUI.dispose();
      usefulItemUI = null;
      super.dispose();
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.UserDataWrapper;
import gudetama.engine.BaseScene;
import gudetama.scene.home.UsefulListDialog;
import gudetama.ui.UIBase;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class UsefulItemUI extends UIBase
{
    
   
   private var scene:UsefulListDialog;
   
   private var callback:Function;
   
   private var button:ContainerButton;
   
   private var iconImage:Image;
   
   private var nameText:ColorTextField;
   
   private var numText:ColorTextField;
   
   private var id:int;
   
   function UsefulItemUI(param1:Sprite, param2:BaseScene, param3:Function)
   {
      super(param1);
      this.scene = param2 as UsefulListDialog;
      this.callback = param3;
      button = param1.getChildByName("button") as ContainerButton;
      button.addEventListener("triggered",triggeredButton);
      iconImage = button.getChildByName("icon") as Image;
      nameText = button.getChildByName("name") as ColorTextField;
      numText = button.getChildByName("num") as ColorTextField;
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      if(!data)
      {
         return;
      }
      id = data.id;
      iconImage.visible = false;
      scene.loadTexture(GudetamaUtil.getItemIconName(8,id),function(param1:Texture):void
      {
         iconImage.visible = true;
         iconImage.texture = param1;
      });
      nameText.text#2 = GudetamaUtil.getItemName(8,id);
      numText.text#2 = UserDataWrapper.usefulPart.getNumUseful(id).toString();
   }
   
   private function triggeredButton(param1:Event) : void
   {
      callback(id);
   }
   
   public function dispose() : void
   {
      callback = null;
      button.removeEventListener("triggered",triggeredButton);
      button = null;
      nameText = null;
      numText = null;
   }
}
