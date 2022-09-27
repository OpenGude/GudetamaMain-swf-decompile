package gudetama.scene.opening
{
   import feathers.controls.IScrollBar;
   import feathers.controls.List;
   import feathers.controls.ScrollBar;
   import feathers.controls.renderers.IListItemRenderer;
   import feathers.data.ListCollection;
   import feathers.layout.VerticalLayout;
   import gudetama.data.GameSetting;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.ui.MessageDialog;
   import gudetama.util.SpriteExtractor;
   import muku.display.ContainerButton;
   import starling.display.Sprite;
   
   public class LanguageSelectDialog extends BaseScene
   {
       
      
      private var callback:Function;
      
      private var needCancel:Boolean;
      
      private var list:List;
      
      private var btnCancel:ContainerButton;
      
      private var extractor:SpriteExtractor;
      
      private var collection:ListCollection;
      
      private var selectLang:String;
      
      public function LanguageSelectDialog(param1:Function, param2:Boolean)
      {
         collection = new ListCollection();
         super(2);
         this.callback = param1;
         this.needCancel = param2;
      }
      
      public static function show(param1:Function, param2:Boolean) : void
      {
         Engine.pushScene(new LanguageSelectDialog(param1,param2),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"LanguageSelectDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            list = _loc2_.getChildByName("list") as List;
            btnCancel = _loc2_.getChildByName("btnCancel") as ContainerButton;
            btnCancel.visible = needCancel;
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         Engine.setupLayoutForTask(queue,"_LanguageItem",function(param1:Object):void
         {
            extractor = SpriteExtractor.forGross(param1.object,param1);
         });
         queue.startTask(onProgress);
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            setup();
         });
      }
      
      private function setup() : void
      {
         var layout:VerticalLayout = new VerticalLayout();
         layout.gap = 20;
         layout.paddingTop = 20;
         layout.paddingLeft = 30;
         layout.paddingBottom = 20;
         list.layout = layout;
         list.itemRendererFactory = function():IListItemRenderer
         {
            return new LanguageListItemRenderer(extractor,triggeredLanguageUICallback);
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
         collection.removeAll();
         var langs:Array = GameSetting.getInitOtherText("langs").split(",");
         var i:int = 0;
         while(i < langs.length)
         {
            var lang:String = langs[i];
            collection.addItem([lang,GameSetting.getInitUIText("lang." + lang)]);
            i++;
         }
         btnCancel.addEventListener("triggered",triggeredCancel);
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(LanguageSelectDialog);
         if(needCancel)
         {
            setBackButtonCallback(triggeredCancel);
         }
         else
         {
            setBackButtonCallback(null);
         }
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(LanguageSelectDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(LanguageSelectDialog);
            Engine.popScene(scene);
            callback(selectLang);
         });
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(LanguageSelectDialog);
         });
      }
      
      private function triggeredLanguageUICallback(param1:String) : void
      {
         var lang:String = param1;
         var msg:String = GameSetting.getInitUIText("lang.select.confirm").replace("%1",GameSetting.getInitUIText("lang." + lang));
         MessageDialog.show(23,msg,function(param1:int):void
         {
            if(param1 == 1)
            {
               return;
            }
            selectLang = lang;
            backButtonCallback();
         });
      }
      
      private function triggeredCancel() : void
      {
         selectLang = null;
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
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

class LanguageListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var callback:Function;
   
   private var displaySprite:Sprite;
   
   private var langItemUI:LauguageItemUI;
   
   function LanguageListItemRenderer(param1:SpriteExtractor, param2:Function)
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
      super.initialize();
      displaySprite = extractor.duplicateAll() as Sprite;
      langItemUI = new LauguageItemUI(displaySprite,callback);
      addChild(displaySprite);
   }
   
   override public function set data#2(param1:Object) : void
   {
      super.data#2 = param1;
      if(param1 == null)
      {
         return;
      }
      langItemUI.init(_data);
   }
   
   override protected function commitData() : void
   {
      langItemUI.updateData(_data);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      callback = null;
      displaySprite = null;
      langItemUI.dispose();
      langItemUI = null;
      super.dispose();
   }
}

import gudetama.ui.UIBase;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Sprite;
import starling.events.Event;

class LauguageItemUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var button:ContainerButton;
   
   private var name:ColorTextField;
   
   private var lang:String;
   
   function LauguageItemUI(param1:Sprite, param2:Function)
   {
      super(param1);
      this.callback = param2;
      button = param1.getChildByName("button") as ContainerButton;
      button.addEventListener("triggered",triggeredButton);
      name = button.getChildByName("name") as ColorTextField;
   }
   
   public function init(param1:*) : void
   {
      lang = param1[0];
      name.text#2 = param1[1];
   }
   
   public function updateData(param1:*) : void
   {
      if(!param1)
      {
         return;
      }
      init(param1);
   }
   
   private function triggeredButton(param1:Event) : void
   {
      callback(lang);
   }
   
   public function dispose() : void
   {
      callback = null;
      button.removeEventListener("triggered",triggeredButton);
      button = null;
   }
}
