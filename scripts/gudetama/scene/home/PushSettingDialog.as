package gudetama.scene.home
{
   import feathers.controls.IScrollBar;
   import feathers.controls.List;
   import feathers.controls.ScrollBar;
   import feathers.controls.renderers.IListItemRenderer;
   import feathers.data.ListCollection;
   import feathers.layout.VerticalLayout;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.ui.LocalMessageDialog;
   import gudetama.util.SpriteExtractor;
   import muku.display.ContainerButton;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class PushSettingDialog extends BaseScene
   {
       
      
      private var list:List;
      
      private var collection:ListCollection;
      
      private var closeButton:ContainerButton;
      
      private var itemExtractor:SpriteExtractor;
      
      private var orgPushFlags:int;
      
      public var currentBit:int;
      
      public function PushSettingDialog()
      {
         collection = new ListCollection();
         super(2);
         var _loc1_:* = UserDataWrapper;
         currentBit = orgPushFlags = gudetama.data.UserDataWrapper.wrapper._data.pushFlags;
         collection.addItem([1,GameSetting.getUIText("push.setting.info")]);
         collection.addItem([2,GameSetting.getUIText("push.setting.cook")]);
         collection.addItem([4,GameSetting.getUIText("push.setting.prs.gude")]);
         collection.addItem([8,GameSetting.getUIText("push.setting.prs.gp")]);
         collection.addItem([16,GameSetting.getUIText("push.setting.delusion")]);
         collection.addItem([32,GameSetting.getUIText("push.setting.cupgacha")]);
      }
      
      public static function show() : void
      {
         Engine.pushScene(new PushSettingDialog(),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"PushSettingDialog",function(param1:Object):void
         {
            var layout:Object = param1;
            displaySprite = layout.object;
            var dialogSprite:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            list = dialogSprite.getChildByName("list") as List;
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
            var listLayout:VerticalLayout = new VerticalLayout();
            listLayout.padding = 15;
            listLayout.paddingTop = 20;
            listLayout.gap = 40;
            listLayout.lastGap = 40;
            list.layout = listLayout;
            closeButton = dialogSprite.getChildByName("btn_close") as ContainerButton;
            closeButton.addEventListener("triggered",triggeredCloseButton);
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         Engine.setupLayoutForTask(queue,"_PushSettingItem",function(param1:Object):void
         {
            itemExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         var dialog:PushSettingDialog = this;
         queue.registerOnProgress(function(param1:Number):void
         {
            var ratio:Number = param1;
            if(ratio < 1)
            {
               return;
            }
            list.itemRendererFactory = function():IListItemRenderer
            {
               return new PushSettingItemRenderer(itemExtractor,dialog);
            };
            list.dataProvider = collection;
         });
         queue.startTask(onProgress);
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(PushSettingDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(PushSettingDialog);
         });
      }
      
      public function changePushBit(param1:int, param2:Boolean) : void
      {
         if(param2)
         {
            currentBit |= param1;
         }
         else
         {
            currentBit &= ~param1;
         }
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(PushSettingDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(PushSettingDialog);
            Engine.popScene(scene);
         });
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         var event:Event = param1;
         if(currentBit != orgPushFlags)
         {
            LocalMessageDialog.show(1,GameSetting.getUIText("common.confirm.setting"),function(param1:int):void
            {
               var choose:int = param1;
               if(choose == 1)
               {
                  backButtonCallback();
                  return;
               }
               var _loc2_:* = HttpConnector;
               if(gudetama.net.HttpConnector.mainConnector == null)
               {
                  gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
               }
               gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(38,currentBit),function(param1:int):void
               {
                  var _loc2_:* = UserDataWrapper;
                  gudetama.data.UserDataWrapper.wrapper._data.pushFlags = param1;
                  backButtonCallback();
               });
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
         super.dispose();
      }
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.scene.home.PushSettingDialog;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class PushSettingItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var dialog:PushSettingDialog;
   
   private var displaySprite:Sprite;
   
   private var itemUI:PushSettingItemUI;
   
   function PushSettingItemRenderer(param1:SpriteExtractor, param2:PushSettingDialog)
   {
      super();
      this.extractor = param1;
      this.dialog = param2;
   }
   
   override protected function initialize() : void
   {
      if(displaySprite)
      {
         return;
      }
      displaySprite = extractor.duplicateAll() as Sprite;
      itemUI = new PushSettingItemUI(displaySprite,dialog);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      itemUI.updateData(data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      dialog = null;
      displaySprite = null;
      itemUI.dispose();
      itemUI = null;
      super.dispose();
   }
}

import gudetama.engine.SoundManager;
import gudetama.scene.home.PushSettingDialog;
import gudetama.ui.UIBase;
import muku.display.ToggleButton;
import muku.text.ColorTextField;
import starling.display.Sprite;

class PushSettingItemUI extends UIBase
{
    
   
   private var bitFlag:int;
   
   private var dialog:PushSettingDialog;
   
   private var txtName:ColorTextField;
   
   private var btn:ToggleButton;
   
   function PushSettingItemUI(param1:Sprite, param2:PushSettingDialog)
   {
      super(param1);
      this.dialog = param2;
      txtName = param1.getChildByName("text") as ColorTextField;
      btn = param1.getChildByName("btn") as ToggleButton;
      btn.addEventListener("triggered",triggered);
   }
   
   public function updateData(param1:Object) : void
   {
      if(param1 == null)
      {
         return;
      }
      bitFlag = param1[0];
      txtName.text#2 = param1[1];
      btn.isSelected = (bitFlag & dialog.currentBit) > 0;
   }
   
   private function triggered() : void
   {
      SoundManager.playEffect("btn_normal");
      dialog.changePushBit(bitFlag,!btn.isSelected);
   }
   
   public function dispose() : void
   {
      dialog = null;
      txtName = null;
      btn.removeEventListener("triggered",triggered);
      btn = null;
   }
}
