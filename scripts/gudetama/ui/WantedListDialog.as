package gudetama.ui
{
   import feathers.controls.IScrollBar;
   import feathers.controls.List;
   import feathers.controls.ScrollBar;
   import feathers.controls.renderers.IListItemRenderer;
   import feathers.data.ListCollection;
   import feathers.layout.FlowLayout;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.GudetamaDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.util.SpriteExtractor;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   
   public class WantedListDialog extends BaseScene
   {
       
      
      private var callback:Function;
      
      private var quad:Quad;
      
      private var list:List;
      
      private var wantedExtractor:SpriteExtractor;
      
      private var noneExtractor:SpriteExtractor;
      
      private var collection:ListCollection;
      
      public function WantedListDialog(param1:Function)
      {
         collection = new ListCollection();
         super(2);
         this.callback = param1;
      }
      
      public static function show(param1:Function) : void
      {
         Engine.pushScene(new WantedListDialog(param1),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"WantedListDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            quad = displaySprite.getChildByName("quad") as Quad;
            quad.addEventListener("touch",touchQuad);
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            list = _loc2_.getChildByName("list") as List;
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         Engine.setupLayoutForTask(queue,"_WantedGudetamaListIcon",function(param1:Object):void
         {
            wantedExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         Engine.setupLayoutForTask(queue,"_WantedNoneIcon",function(param1:Object):void
         {
            noneExtractor = SpriteExtractor.forGross(param1.object,param1);
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
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(WantedListDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         setup();
      }
      
      private function setup() : void
      {
         var layout:FlowLayout = new FlowLayout();
         layout.horizontalAlign = "left";
         layout.horizontalGap = 4;
         layout.verticalGap = 8;
         layout.paddingTop = 8;
         layout.paddingLeft = 20;
         list.layout = layout;
         list.setItemRendererFactoryWithID("wanted",function():IListItemRenderer
         {
            return new WantedListItemRenderer(wantedExtractor,triggeredWantIconUICallback);
         });
         list.setItemRendererFactoryWithID("none",function():IListItemRenderer
         {
            return new NoneListItemRenderer(noneExtractor,triggeredWantIconUICallback);
         });
         list.factoryIDFunction = function(param1:Object):String
         {
            if(param1 is GudetamaDef)
            {
               return "wanted";
            }
            return "none";
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
         var gudetamaMap:Object = UserDataWrapper.gudetamaPart.getGudetamaMap();
         var gudetamaDefs:Array = [];
         for(id in gudetamaMap)
         {
            var gudetamaDef:GudetamaDef = GameSetting.getGudetama(id);
            if(!gudetamaDef.uncountable)
            {
               if(UserDataWrapper.gudetamaPart.hasRecipe(id))
               {
                  if(UserDataWrapper.gudetamaPart.isCooked(id))
                  {
                     gudetamaDefs.push(GameSetting.getGudetama(id));
                  }
               }
            }
         }
         gudetamaDefs.sort(ascendingIdComparator);
         collection.addItem({});
         for each(gudetamaDef in gudetamaDefs)
         {
            collection.addItem(gudetamaDef);
         }
         show();
      }
      
      private function ascendingIdComparator(param1:GudetamaDef, param2:GudetamaDef) : Number
      {
         if(param1.number > param2.number)
         {
            return 1;
         }
         if(param1.number < param2.number)
         {
            return -1;
         }
         if(param1.id#2 > param2.id#2)
         {
            return 1;
         }
         if(param1.id#2 < param2.id#2)
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
            Engine.unlockTouchInput(WantedListDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(WantedListDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(WantedListDialog);
            Engine.popScene(scene);
         });
      }
      
      private function triggeredWantIconUICallback(param1:GudetamaDef) : void
      {
         var gudetamaDef:GudetamaDef = param1;
         Engine.lockTouchInput(WantedListDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(WantedListDialog);
            Engine.popScene(scene);
            callback(gudetamaDef);
         });
      }
      
      private function touchQuad(param1:TouchEvent) : void
      {
         var _loc2_:Touch = param1.getTouch(quad);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_.phase == "ended")
         {
            backButtonCallback();
         }
      }
      
      override public function dispose() : void
      {
         quad.removeEventListener("touch",touchQuad);
         quad = null;
         list = null;
         wantedExtractor = null;
         noneExtractor = null;
         collection = null;
         super.dispose();
      }
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class WantedListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var callback:Function;
   
   private var displaySprite:Sprite;
   
   private var wantedIconUI:WantedIconUI;
   
   function WantedListItemRenderer(param1:SpriteExtractor, param2:Function)
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
      wantedIconUI = new WantedIconUI(displaySprite,callback);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      wantedIconUI.updateData(data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      callback = null;
      displaySprite = null;
      wantedIconUI.dispose();
      wantedIconUI = null;
      super.dispose();
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.GudetamaDef;
import gudetama.data.compati.UserWantedData;
import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class WantedIconUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var button:ContainerButton;
   
   private var iconImage:Image;
   
   private var numberText:ColorTextField;
   
   private var nameText:ColorTextField;
   
   private var numText:ColorTextField;
   
   private var gudetamaDef:GudetamaDef;
   
   private var usedGroup:Sprite;
   
   function WantedIconUI(param1:Sprite, param2:Function)
   {
      super(param1);
      this.callback = param2;
      button = param1.getChildByName("button") as ContainerButton;
      button.addEventListener("triggered",triggeredButton);
      iconImage = button.getChildByName("icon") as Image;
      numberText = button.getChildByName("number") as ColorTextField;
      nameText = button.getChildByName("name") as ColorTextField;
      numText = button.getChildByName("num") as ColorTextField;
      usedGroup = button.getChildByName("usedGroup") as Sprite;
      usedGroup.visible = false;
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      if(!data)
      {
         return;
      }
      gudetamaDef = data as GudetamaDef;
      if(gudetamaDef.type != 1)
      {
         numberText.visible = false;
      }
      numberText.text#2 = StringUtil.format(GameSetting.getUIText("common.number"),StringUtil.decimalFormat(GameSetting.getUIText("common.number.format"),gudetamaDef.number));
      nameText.text#2 = gudetamaDef.getWrappedName();
      iconImage.visible = false;
      usedGroup.visible = false;
      TextureCollector.loadTextureRsrc(GudetamaUtil.getCollectionIconName(gudetamaDef.id#2),function(param1:Texture):void
      {
         var _loc3_:* = 0;
         var _loc4_:* = null;
         iconImage.texture = param1;
         iconImage.visible = true;
         var _loc2_:uint = 3;
         _loc3_ = uint(0);
         while(_loc3_ < _loc2_)
         {
            if(!UserDataWrapper.wantedPart.isEmpty(_loc3_))
            {
               if((_loc4_ = UserDataWrapper.wantedPart.getUserWantedData(_loc3_)).id#2 == data.id)
               {
                  usedGroup.visible = true;
                  break;
               }
            }
            _loc3_++;
         }
      });
      numText.text#2 = StringUtil.format(GameSetting.getUIText("mult.mark"),UserDataWrapper.gudetamaPart.getNumGudetama(gudetamaDef.id#2));
   }
   
   private function triggeredButton(param1:Event) : void
   {
      callback(gudetamaDef);
   }
   
   public function dispose() : void
   {
      callback = null;
      button.removeEventListener("triggered",triggeredButton);
      button = null;
      numberText = null;
      nameText = null;
      numText = null;
      gudetamaDef = null;
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class NoneListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var callback:Function;
   
   private var displaySprite:Sprite;
   
   private var noneIconUI:NoneIconUI;
   
   function NoneListItemRenderer(param1:SpriteExtractor, param2:Function)
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
      noneIconUI = new NoneIconUI(displaySprite,callback);
      addChild(displaySprite);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      callback = null;
      displaySprite = null;
      noneIconUI.dispose();
      noneIconUI = null;
      super.dispose();
   }
}

import gudetama.ui.UIBase;
import muku.display.ContainerButton;
import starling.display.Sprite;
import starling.events.Event;

class NoneIconUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var button:ContainerButton;
   
   function NoneIconUI(param1:Sprite, param2:Function)
   {
      super(param1);
      this.callback = param2;
      button = param1.getChildByName("button") as ContainerButton;
      button.addEventListener("triggered",triggeredButton);
   }
   
   private function triggeredButton(param1:Event) : void
   {
      callback(null);
   }
   
   public function dispose() : void
   {
      callback = null;
      button.removeEventListener("triggered",triggeredButton);
      button = null;
   }
}
