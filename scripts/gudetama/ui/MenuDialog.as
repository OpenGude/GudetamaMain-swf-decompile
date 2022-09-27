package gudetama.ui
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
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.scene.home.BlockUserListDialog;
   import gudetama.scene.home.InquiryDialog;
   import gudetama.scene.home.OptionScene;
   import gudetama.scene.linkage.LinkageScene;
   import gudetama.scene.title.TitleScene;
   import gudetama.util.SpriteExtractor;
   import muku.display.ContainerButton;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class MenuDialog extends BaseScene
   {
       
      
      private var list:List;
      
      private var closeButton:ContainerButton;
      
      private var extractor:SpriteExtractor;
      
      protected var collection:ListCollection;
      
      public function MenuDialog()
      {
         collection = new ListCollection();
         super(2);
      }
      
      public static function show() : void
      {
         Engine.pushScene(new MenuDialog(),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"MenuDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            list = _loc2_.getChildByName("list") as List;
            closeButton = _loc2_.getChildByName("btn_back") as ContainerButton;
            closeButton.addEventListener("triggered",triggeredCloseButton);
            displaySprite.visible = false;
            addChild(displaySprite);
            checkInit();
         });
         Engine.setupLayoutForTask(queue,"_MenuItem",function(param1:Object):void
         {
            extractor = SpriteExtractor.forGross(param1.object,param1);
            checkInit();
         });
         queue.registerOnProgress(function(param1:Number):void
         {
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
            return new MenuListItemRenderer(extractor,triggeredMenuItemUICallback);
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
         var _loc2_:int = 0;
         var _loc1_:Array = UserDataWrapper.wrapper.getMenuItems();
         if(!_loc1_)
         {
            _loc1_ = GameSetting.getRule().menuItems;
         }
         _loc2_ = 0;
         while(_loc2_ < _loc1_.length)
         {
            collection.addItem({"type":_loc1_[_loc2_]});
            _loc2_++;
         }
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(MenuDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(MenuDialog);
         });
      }
      
      private function triggeredMenuItemUICallback(param1:int) : void
      {
         switch(int(param1))
         {
            case 0:
               triggeredLinkage();
               break;
            case 1:
               triggeredWatchword();
               break;
            case 2:
               triggeredHelp();
               break;
            case 3:
               triggeredInquiry();
               break;
            case 4:
               triggeredOption();
               break;
            case 5:
               triggeredTitle();
               break;
            case 6:
               GudetamaUtil.showInfoPage();
               break;
            case 7:
               BlockUserListDialog.show();
         }
      }
      
      private function triggeredLinkage() : void
      {
         ResidentMenuUI_Gudetama.getInstance().sendChangeState(147,function():void
         {
            Engine.switchScene(new LinkageScene());
         });
      }
      
      private function triggeredWatchword() : void
      {
         CodeDialog.show();
      }
      
      private function triggeredHelp() : void
      {
         LocalMessageDialog.show(1,GameSetting.getUIText("menu.help.confirm.message"),function(param1:int):void
         {
            if(param1 == 1)
            {
               return;
            }
            GudetamaUtil.showHelpPage();
         },GameSetting.getInitUIText("%button.tohelp"));
      }
      
      private function triggeredInquiry() : void
      {
         InquiryDialog.show(false);
      }
      
      private function triggeredOption() : void
      {
         ResidentMenuUI_Gudetama.getInstance().sendChangeState(148,function():void
         {
            Engine.switchScene(new OptionScene());
         });
      }
      
      private function triggeredTitle() : void
      {
         checkGameSettingVersion(function():void
         {
            Engine.switchScene(new TitleScene());
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(MenuDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(MenuDialog);
            Engine.popScene(scene);
         });
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      private function checkGameSettingVersion(param1:Function) : void
      {
         var _callback:Function = param1;
         var _loc2_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.getGameSettingVersionWithoutLogin("g",0,function(param1:*):void
         {
            var response:* = param1;
            if(!response || !(response is Array) || !(response[0] is int))
            {
               _callback();
            }
            var serverGameSettingVersion:int = response[0];
            if(serverGameSettingVersion == GameSetting.def.version)
            {
               _callback();
            }
            else
            {
               GameSetting.setupForVersion(serverGameSettingVersion,function():void
               {
                  _callback();
               },true);
            }
         });
      }
      
      override public function dispose() : void
      {
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
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class MenuListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var callback:Function;
   
   private var displaySprite:Sprite;
   
   private var menuItemUI:MenuItemUI;
   
   function MenuListItemRenderer(param1:SpriteExtractor, param2:Function)
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
      menuItemUI = new MenuItemUI(displaySprite,callback);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      menuItemUI.updateData(data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      callback = null;
      displaySprite = null;
      menuItemUI.dispose();
      menuItemUI = null;
      super.dispose();
   }
}

import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import muku.display.ImageButton;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class MenuItemUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var button:ImageButton;
   
   private var type:int;
   
   function MenuItemUI(param1:Sprite, param2:Function)
   {
      super(param1);
      this.callback = param2;
      button = param1.getChildByName("button") as ImageButton;
      button.addEventListener("triggered",triggeredButton);
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      if(!data)
      {
         return;
      }
      type = data.type;
      var imageName:String = "setting0@btn" + StringUtil.decimalFormat("00",type + 1);
      TextureCollector.loadTexture(imageName,function(param1:Texture):void
      {
         if(button != null)
         {
            button.background = param1;
         }
      });
   }
   
   private function triggeredButton(param1:Event) : void
   {
      callback(type);
   }
   
   public function dispose() : void
   {
      callback = null;
      button.removeEventListener("triggered",triggeredButton);
      button = null;
   }
}
