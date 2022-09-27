package gudetama.scene.linkage
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
   import gudetama.scene.home.HomeScene;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.util.SpriteExtractor;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class LinkageScene extends BaseScene
   {
       
      
      private var list:List;
      
      private var extractor:SpriteExtractor;
      
      private var collection:ListCollection;
      
      public function LinkageScene()
      {
         collection = new ListCollection();
         super(0);
         addEventListener("refreshed_scene_container",refreshedSceneContainer);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"LinkageLayout",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            list = _loc2_.getChildByName("list") as List;
            displaySprite.visible = false;
            addChild(displaySprite);
            checkInit();
         });
         Engine.setupLayoutForTask(queue,"_LinkageItem",function(param1:Object):void
         {
            extractor = SpriteExtractor.forGross(param1.object,param1);
            checkInit();
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
      
      private function checkInit() : void
      {
         if(queue.numRest > 1)
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
         list.layout = layout;
         list.itemRendererFactory = function():IListItemRenderer
         {
            return new LinkageListItemRenderer(extractor,triggeredLinkageItemUICallback);
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
         var _loc2_:Object = GameSetting.getLinkageMap();
         var _loc1_:Array = [];
         for(var _loc3_ in _loc2_)
         {
            _loc1_.push(_loc3_);
         }
         _loc1_.sort(ascendingKeyComparator);
         for each(_loc3_ in _loc1_)
         {
            collection.addItem({"id":_loc3_});
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
         setBackButtonCallback(backButtonCallback);
         showResidentMenuUI(94);
         displaySprite.visible = true;
      }
      
      private function triggeredLinkageItemUICallback(param1:int) : void
      {
         LinkageDetailDialog.show(param1);
      }
      
      private function backButtonCallback() : void
      {
         ResidentMenuUI_Gudetama.getInstance().sendChangeState(60,function():void
         {
            Engine.switchScene(new HomeScene());
         });
      }
      
      private function refreshedSceneContainer(param1:Event) : void
      {
      }
      
      override public function dispose() : void
      {
         removeEventListener("refreshed_scene_container",refreshedSceneContainer);
         list = null;
         extractor = null;
         collection = null;
         super.dispose();
      }
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class LinkageListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var callback:Function;
   
   private var displaySprite:Sprite;
   
   private var linkageItemUI:LinkageItemUI;
   
   function LinkageListItemRenderer(param1:SpriteExtractor, param2:Function)
   {
      super();
      this.extractor = param1;
      this.callback = param2;
   }
   
   override protected function initialize() : void
   {
      if(displaySprite)
      {
         return;
      }
      displaySprite = extractor.duplicateAll() as Sprite;
      linkageItemUI = new LinkageItemUI(displaySprite,callback);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      linkageItemUI.updateData(data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      callback = null;
      displaySprite = null;
      linkageItemUI.dispose();
      linkageItemUI = null;
      super.dispose();
   }
}

import gudetama.data.UserDataWrapper;
import gudetama.ui.UIBase;
import muku.display.ContainerButton;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;

class LinkageItemUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var button:ContainerButton;
   
   private var bannerImage:Image;
   
   private var lockImage:Image;
   
   private var id:int;
   
   function LinkageItemUI(param1:Sprite, param2:Function)
   {
      super(param1);
      this.callback = param2;
      button = param1.getChildByName("button") as ContainerButton;
      button.addEventListener("triggered",triggeredButton);
      bannerImage = button.getChildByName("banner") as Image;
      lockImage = button.getChildByName("lock") as Image;
   }
   
   public function updateData(param1:Object) : void
   {
      if(!param1)
      {
         return;
      }
      id = param1.id;
      if(UserDataWrapper.linkagePart.exists(id))
      {
         bannerImage.color = 16777215;
         lockImage.visible = false;
      }
      else
      {
         bannerImage.color = 8421504;
         lockImage.visible = true;
      }
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
      bannerImage = null;
      lockImage = null;
   }
}
