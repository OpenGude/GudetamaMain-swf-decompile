package gudetama.scene.home
{
   import feathers.controls.IScrollBar;
   import feathers.controls.List;
   import feathers.controls.ScrollBar;
   import feathers.controls.renderers.IListItemRenderer;
   import feathers.data.ListCollection;
   import feathers.layout.FlowLayout;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import gudetama.common.NativeExtensions;
   import gudetama.data.GameSetting;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.ui.CacheCheckSelectDialog;
   import gudetama.ui.LocalMessageDialog;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.util.PermissionRequestWrapper;
   import gudetama.util.SpriteExtractor;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class OptionScene extends BaseScene
   {
      
      private static const OPTION_VOLUME:int = 0;
      
      private static const OPTION_PUSH:int = 1;
      
      private static const OPTION_CACHE:int = 2;
      
      private static const OPTION_OFFICIAL:int = 3;
      
      private static const OPTION_CONTRACT:int = 4;
      
      private static const OPTION_LICENSE:int = 5;
      
      private static const OPTIONS:Array = [[0,6],[1,1],[2,2],[3,3],[4,4],[5,5]];
       
      
      private var list:List;
      
      private var extractor:SpriteExtractor;
      
      private var collection:ListCollection;
      
      public function OptionScene()
      {
         collection = new ListCollection();
         super(0);
         addEventListener("refreshed_scene_container",refreshedSceneContainer);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"OptionLayout",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            list = _loc2_.getChildByName("list") as List;
            displaySprite.visible = false;
            addChild(displaySprite);
            checkInit();
         });
         Engine.setupLayoutForTask(queue,"_OptionItem",function(param1:Object):void
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
            return new OptionListItemRenderer(extractor,triggeredOptionItemUICallback);
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
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < OPTIONS.length)
         {
            collection.addItem({
               "type":OPTIONS[_loc1_][0],
               "image":OPTIONS[_loc1_][1]
            });
            _loc1_++;
         }
      }
      
      override protected function addedToContainer() : void
      {
         setBackButtonCallback(backButtonCallback);
         showResidentMenuUI(94);
         displaySprite.visible = true;
      }
      
      private function triggeredOptionItemUICallback(param1:int) : void
      {
         switch(int(param1))
         {
            case 0:
               triggeredVolume();
               break;
            case 1:
               triggeredPush();
               break;
            case 2:
               triggeredCache();
               break;
            case 3:
               triggeredOfficial();
               break;
            case 4:
               triggeredContract();
               break;
            case 5:
               triggeredLicense();
         }
      }
      
      private function triggeredVolume() : void
      {
         SettingDialog.show();
      }
      
      private function triggeredCache() : void
      {
         CacheCheckSelectDialog.show(false);
      }
      
      private function triggeredOfficial() : void
      {
         LocalMessageDialog.show(1,GameSetting.getUIText("option.confirm.official.desc"),function(param1:int):void
         {
            if(param1 == 1)
            {
               return;
            }
            navigateToURL(new URLRequest(GameSetting.getOtherText("url.official")),"_self");
         },GameSetting.getUIText("option.confirm.official.title"));
      }
      
      private function triggeredContract() : void
      {
         ContractDialog.show();
      }
      
      private function triggeredLicense() : void
      {
         LicenseDialog.show();
      }
      
      private function triggeredPush() : void
      {
         NativeExtensions.checkPushEnableByOs(function(param1:Boolean):void
         {
            if(param1)
            {
               PushSettingDialog.show();
            }
            else
            {
               PermissionRequestWrapper.showInductionAppConfigDialog(GameSetting.getUIText("push.caution.os.off"));
            }
         });
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
         super.dispose();
      }
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class OptionListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var callback:Function;
   
   private var displaySprite:Sprite;
   
   private var optionItemUI:OptionItemUI;
   
   function OptionListItemRenderer(param1:SpriteExtractor, param2:Function)
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
      optionItemUI = new OptionItemUI(displaySprite,callback);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      optionItemUI.updateData(data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      callback = null;
      displaySprite = null;
      optionItemUI.dispose();
      optionItemUI = null;
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

class OptionItemUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var button:ImageButton;
   
   private var type:int;
   
   function OptionItemUI(param1:Sprite, param2:Function)
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
      var imageName:String = "setting0@btn" + StringUtil.decimalFormat("00",data.image) + "_o";
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
