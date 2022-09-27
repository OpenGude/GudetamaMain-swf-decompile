package gudetama.scene.decoration
{
   import feathers.controls.List;
   import feathers.controls.renderers.IListItemRenderer;
   import feathers.data.ListCollection;
   import feathers.layout.FlowLayout;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.DecorationDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.scene.home.HomeScene;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.util.SpriteExtractor;
   import muku.text.ColorTextField;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class DecorationScene extends BaseScene
   {
       
      
      private var list:List;
      
      private var currentNameText:ColorTextField;
      
      private var extractor:SpriteExtractor;
      
      private var collection:ListCollection;
      
      public function DecorationScene()
      {
         collection = new ListCollection();
         super(0);
         addEventListener("refreshed_scene_container",refreshedSceneContainer);
         addEventListener("update_scene",updateScene);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"DecorationLayout",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc3_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            list = _loc3_.getChildByName("list") as List;
            var _loc2_:Sprite = displaySprite.getChildByName("currentSprite") as Sprite;
            currentNameText = _loc2_.getChildByName("name") as ColorTextField;
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         Engine.setupLayoutForTask(queue,"_DecorationItem",function(param1:Object):void
         {
            extractor = SpriteExtractor.forGross(param1.object,param1);
         });
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            init();
         });
         queue.startTask(onProgress);
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
            return new DecorationListItemRenderer(extractor,triggeredDecorationItemUICallback);
         };
         list.selectedIndex = -1;
         list.dataProvider = collection;
         setup();
      }
      
      private function setup() : void
      {
         refresh();
         start();
      }
      
      private function refresh() : void
      {
         var _loc3_:int = UserDataWrapper.decorationPart.getCurrentDecorationId();
         var _loc4_:DecorationDef = GameSetting.getDecoration(_loc3_);
         currentNameText.text#2 = _loc4_.name#2;
         var _loc1_:Object = UserDataWrapper.decorationPart.getDecorationMap();
         var _loc2_:Array = [];
         for(var _loc5_ in _loc1_)
         {
            _loc2_.push(_loc5_);
         }
         _loc2_.sort(ascendingKeyComparator);
         collection.removeAll();
         for each(_loc5_ in _loc2_)
         {
            collection.addItem({"id":_loc5_});
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
      
      private function start() : void
      {
         setBackButtonCallback(backButtonCallback);
         showResidentMenuUI(94);
         displaySprite.visible = true;
         processNoticeTutorial(6,noticeTutorialAction);
      }
      
      override protected function addedToContainer() : void
      {
      }
      
      private function triggeredDecorationItemUICallback(param1:int) : void
      {
         DecorationDetailDialog.show(param1);
      }
      
      private function backButtonCallback() : void
      {
         if(Engine.getGuideTalkPanel() != null)
         {
            return;
         }
         ResidentMenuUI_Gudetama.getInstance().sendChangeState(60,function():void
         {
            Engine.switchScene(new HomeScene());
         });
      }
      
      private function refreshedSceneContainer(param1:Event) : void
      {
      }
      
      private function updateScene() : void
      {
         refresh();
      }
      
      private function noticeTutorialAction(param1:int) : void
      {
      }
      
      override public function dispose() : void
      {
         removeEventListener("refreshed_scene_container",refreshedSceneContainer);
         list = null;
         currentNameText = null;
         extractor = null;
         collection = null;
         super.dispose();
      }
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class DecorationListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var callback:Function;
   
   private var displaySprite:Sprite;
   
   private var decorationItemUI:DecorationItemUI;
   
   function DecorationListItemRenderer(param1:SpriteExtractor, param2:Function)
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
      decorationItemUI = new DecorationItemUI(displaySprite,callback);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      decorationItemUI.updateData(data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      callback = null;
      displaySprite = null;
      decorationItemUI.dispose();
      decorationItemUI = null;
      super.dispose();
   }
}

import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.DecorationDef;
import gudetama.ui.UIBase;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Sprite;
import starling.events.Event;

class DecorationItemUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var button:ContainerButton;
   
   private var nameText:ColorTextField;
   
   private var getSprite:Sprite;
   
   private var lockSprite:Sprite;
   
   private var notSprite:Sprite;
   
   private var selectedSprite:Sprite;
   
   private var id:int;
   
   function DecorationItemUI(param1:Sprite, param2:Function)
   {
      super(param1);
      this.callback = param2;
      button = param1.getChildByName("button") as ContainerButton;
      button.addEventListener("triggered",triggeredButton);
      nameText = button.getChildByName("name") as ColorTextField;
      getSprite = button.getChildByName("getSprite") as Sprite;
      lockSprite = button.getChildByName("lockSprite") as Sprite;
      notSprite = button.getChildByName("notSprite") as Sprite;
      selectedSprite = button.getChildByName("selectedSprite") as Sprite;
   }
   
   public function updateData(param1:Object) : void
   {
      if(!param1)
      {
         return;
      }
      id = param1.id;
      var _loc2_:DecorationDef = GameSetting.getDecoration(id);
      nameText.text#2 = _loc2_.name#2;
      if(UserDataWrapper.decorationPart.hasDecoration(id))
      {
         getSprite.visible = true;
         lockSprite.visible = false;
         notSprite.visible = false;
      }
      else if(UserDataWrapper.decorationPart.isAvailable(id))
      {
         getSprite.visible = false;
         lockSprite.visible = false;
         notSprite.visible = true;
      }
      else
      {
         getSprite.visible = false;
         lockSprite.visible = true;
         notSprite.visible = false;
      }
      if(id == UserDataWrapper.decorationPart.getCurrentDecorationId())
      {
         button.touchable = false;
         selectedSprite.visible = true;
      }
      else
      {
         button.touchable = true;
         selectedSprite.visible = false;
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
      nameText = null;
      getSprite = null;
      lockSprite = null;
      notSprite = null;
      selectedSprite = null;
   }
}
