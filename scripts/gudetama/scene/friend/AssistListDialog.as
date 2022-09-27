package gudetama.scene.friend
{
   import feathers.controls.IScrollBar;
   import feathers.controls.List;
   import feathers.controls.ScrollBar;
   import feathers.controls.renderers.IListItemRenderer;
   import feathers.data.ListCollection;
   import feathers.layout.FlowLayout;
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.AbilityParam;
   import gudetama.data.compati.KitchenwareData;
   import gudetama.data.compati.UsefulData;
   import gudetama.data.compati.UsefulDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.util.SpriteExtractor;
   import muku.display.ContainerButton;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class AssistListDialog extends BaseScene
   {
       
      
      public var kitchenwareData:KitchenwareData;
      
      private var callback:Function;
      
      private var list:List;
      
      private var closeButton:ContainerButton;
      
      private var usefulIds:Array;
      
      private var extractor:SpriteExtractor;
      
      private var collection:ListCollection;
      
      public function AssistListDialog(param1:KitchenwareData, param2:Function)
      {
         usefulIds = [];
         collection = new ListCollection();
         super(2);
         this.kitchenwareData = param1;
         this.callback = param2;
         addEventListener("update_scene",updateScene);
      }
      
      public static function show(param1:KitchenwareData, param2:Function) : AssistListDialog
      {
         var _loc3_:AssistListDialog = new AssistListDialog(param1,param2);
         Engine.pushScene(_loc3_,0,false);
         return _loc3_;
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"AssistListDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            list = _loc2_.getChildByName("list") as List;
            closeButton = _loc2_.getChildByName("btn_back") as ContainerButton;
            closeButton.addEventListener("triggered",triggeredCloseButton);
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         Engine.setupLayoutForTask(queue,"_AssistListItem",function(param1:Object):void
         {
            extractor = SpriteExtractor.forGross(param1.object,param1);
         });
         setupUsefulIds();
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
         });
         queue.startTask(onProgress);
      }
      
      private function setupUsefulIds() : void
      {
         var _loc3_:* = null;
         var _loc4_:* = null;
         var _loc1_:Object = UserDataWrapper.usefulPart.getUsefulMap();
         var _loc2_:Array = [];
         for(var _loc5_ in _loc1_)
         {
            _loc2_.push(_loc5_);
         }
         _loc2_.sort(ascendingKeyComparator);
         for each(_loc5_ in _loc2_)
         {
            _loc3_ = UserDataWrapper.usefulPart.getUseful(_loc5_);
            if((_loc4_ = GameSetting.getUseful(_loc3_.id#2)).assistAbilities)
            {
               if(kitchenwareData.target == 0)
               {
                  if(hasHappening(_loc4_.abilities))
                  {
                     continue;
                  }
               }
               else if(hasSuccess(_loc4_.abilities))
               {
                  continue;
               }
               usefulIds.push(_loc3_.id#2);
               preloadUsefulTexture(_loc3_.id#2);
            }
         }
      }
      
      private function preloadUsefulTexture(param1:int) : void
      {
         var usefulIds:int = param1;
         queue.addTask(function():void
         {
            TextureCollector.loadTexture(GudetamaUtil.getItemIconName(8,usefulIds),function(param1:Texture):void
            {
               queue.taskDone();
            });
         });
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(AssistListDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(92);
      }
      
      override protected function transitionOpenFinished() : void
      {
         setup();
      }
      
      private function setup() : void
      {
         var layout:FlowLayout = new FlowLayout();
         layout.horizontalAlign = "left";
         layout.horizontalGap = 10;
         layout.verticalGap = 10;
         layout.paddingTop = 5;
         layout.paddingLeft = 10;
         list.layout = layout;
         list.itemRendererFactory = function():IListItemRenderer
         {
            return new AssistListItemRenderer(extractor,scene,triggeredAssistItemUICallback);
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
         for each(usefulId in usefulIds)
         {
            collection.addItem({"usefulId":usefulId});
         }
         show();
      }
      
      private function hasSuccess(param1:Array) : Boolean
      {
         for each(var _loc2_ in param1)
         {
            if(_loc2_.equalsKind(3))
            {
               return true;
            }
         }
         return false;
      }
      
      private function hasHappening(param1:Array) : Boolean
      {
         for each(var _loc2_ in param1)
         {
            if(_loc2_.equalsKind(4))
            {
               return true;
            }
         }
         return false;
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
      
      private function show() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(AssistListDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(AssistListDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(AssistListDialog);
            Engine.popScene(scene);
         });
      }
      
      private function triggeredAssistItemUICallback(param1:int) : void
      {
         callback(param1);
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      public function updateScene() : void
      {
         collection.updateAll();
      }
      
      public function updateKitchenwareData(param1:KitchenwareData) : void
      {
         this.kitchenwareData = param1;
         updateScene();
      }
      
      override public function dispose() : void
      {
         list = null;
         extractor = null;
         collection = null;
         if(closeButton)
         {
            closeButton.removeEventListener("triggered",triggeredCloseButton);
            closeButton = null;
         }
         super.dispose();
      }
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.engine.BaseScene;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class AssistListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var scene:BaseScene;
   
   private var callback:Function;
   
   private var displaySprite:Sprite;
   
   private var assistItemUI:AssistItemUI;
   
   function AssistListItemRenderer(param1:SpriteExtractor, param2:BaseScene, param3:Function)
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
      assistItemUI = new AssistItemUI(displaySprite,scene,callback);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      assistItemUI.updateData(data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      callback = null;
      displaySprite = null;
      assistItemUI.dispose();
      assistItemUI = null;
      super.dispose();
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.UsefulData;
import gudetama.data.compati.UsefulDef;
import gudetama.engine.BaseScene;
import gudetama.engine.TextureCollector;
import gudetama.scene.friend.AssistListDialog;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class AssistItemUI extends UIBase
{
    
   
   private var scene:AssistListDialog;
   
   private var callback:Function;
   
   private var button:ContainerButton;
   
   private var iconImage:Image;
   
   private var nameText:ColorTextField;
   
   private var friendlyText:ColorTextField;
   
   private var numText:ColorTextField;
   
   private var disableImage:Image;
   
   private var usefulId:int;
   
   function AssistItemUI(param1:Sprite, param2:BaseScene, param3:Function)
   {
      super(param1);
      this.scene = param2 as AssistListDialog;
      this.callback = param3;
      button = param1.getChildByName("button") as ContainerButton;
      button.addEventListener("triggered",triggeredButton);
      iconImage = button.getChildByName("icon") as Image;
      nameText = button.getChildByName("name") as ColorTextField;
      var _loc4_:Sprite;
      friendlyText = (_loc4_ = button.getChildByName("friendlyGroup") as Sprite).getChildByName("friendly") as ColorTextField;
      numText = button.getChildByName("num") as ColorTextField;
      disableImage = button.getChildByName("disable") as Image;
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      if(!data)
      {
         return;
      }
      usefulId = data.usefulId;
      var usefulData:UsefulData = UserDataWrapper.usefulPart.getUseful(usefulId);
      var usefulDef:UsefulDef = GameSetting.getUseful(usefulId);
      iconImage.visible = false;
      TextureCollector.loadTexture(GudetamaUtil.getItemIconName(8,usefulData.id#2),function(param1:Texture):void
      {
         iconImage.visible = true;
         iconImage.texture = param1;
      });
      nameText.text#2 = usefulDef.name#2;
      var friendly:int = GameSetting.getRule().friendlyValueByAssist;
      if(usefulDef.friendlyValue > 0)
      {
         friendly = usefulDef.friendlyValue;
      }
      friendlyText.text#2 = StringUtil.format(GameSetting.getUIText("add.mark"),friendly);
      numText.text#2 = usefulData.num.toString();
      var enabled:Boolean = !scene.kitchenwareData.existsUsefulIdInAssist(usefulData.id#2);
      disableImage.visible = !enabled;
      button.enabled = enabled;
   }
   
   private function triggeredButton(param1:Event) : void
   {
      callback(usefulId);
   }
   
   public function dispose() : void
   {
      callback = null;
      button.removeEventListener("triggered",triggeredButton);
      button = null;
      nameText = null;
      friendlyText = null;
      numText = null;
      disableImage = null;
   }
}
