package gudetama.ui
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
   import gudetama.util.SpriteExtractor;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Sprite;
   
   public class PresentAllResultDialog extends BaseScene
   {
       
      
      private var callback:Function;
      
      private var presentDatas:Array;
      
      private var collection:ListCollection;
      
      private var list:List;
      
      private var presentExtractor:SpriteExtractor;
      
      private var btnBack:ContainerButton;
      
      public function PresentAllResultDialog(param1:Array, param2:Function)
      {
         super(2);
         this.presentDatas = param1;
         this.callback = param2;
         collection = new ListCollection();
      }
      
      public static function show(param1:Array, param2:Function) : void
      {
         Engine.pushScene(new PresentAllResultDialog(param1,param2),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"PresentAllResultDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            var _loc3_:ColorTextField = _loc2_.getChildByName("title") as ColorTextField;
            var _loc4_:ColorTextField = _loc2_.getChildByName("message_field") as ColorTextField;
            btnBack = _loc2_.getChildByName("btn_back") as ContainerButton;
            list = _loc2_.getChildByName("list") as List;
            _loc3_.text#2 = GameSetting.getUIText("infoList.bulk.title");
            _loc4_.text#2 = GameSetting.getUIText("infoList.bulk.success.desc");
            btnBack.addEventListener("triggered",backButtonCallback);
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         Engine.setupLayoutForTask(queue,"_PresentAllResultListItem",function(param1:Object):void
         {
            presentExtractor = SpriteExtractor.forGross(param1.object,param1);
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
         Engine.lockTouchInput(PresentAllResultDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         setup();
      }
      
      private function setup() : void
      {
         refresh();
         initList();
         show();
      }
      
      private function initList() : void
      {
         var layout:FlowLayout = new FlowLayout();
         layout.horizontalAlign = "left";
         layout.horizontalGap = 10;
         layout.verticalGap = 10;
         layout.paddingTop = 5;
         list.layout = layout;
         list.itemRendererFactory = function():IListItemRenderer
         {
            return new PresentListItemRenderer(presentExtractor,callback);
         };
         list.verticalScrollBarFactory = function():IScrollBar
         {
            var _loc1_:ScrollBar = new ScrollBar();
            _loc1_.trackLayoutMode = "single";
            return _loc1_;
         };
         list.selectedIndex = -1;
         list.dataProvider = collection;
         list.scrollBarDisplayMode = "fixedFloat";
         list.horizontalScrollPolicy = "off";
         list.verticalScrollPolicy = "auto";
         list.interactionMode = "touchAndScrollBars";
      }
      
      private function refresh() : void
      {
         var _loc1_:int = 0;
         collection.removeAll();
         list.stopScrolling();
         list.scrollToPosition(0,0,0);
         _loc1_ = presentDatas.length - 1;
         while(_loc1_ >= 0)
         {
            collection.addItem(presentDatas[_loc1_]);
            _loc1_--;
         }
      }
      
      private function show() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(PresentAllResultDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(PresentAllResultDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(PresentAllResultDialog);
            Engine.popScene(scene);
            if(callback)
            {
               callback();
            }
         });
      }
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class PresentListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var callback:Function;
   
   private var displaySprite:Sprite;
   
   private var infoItemUI:PresentItemUI;
   
   function PresentListItemRenderer(param1:SpriteExtractor, param2:Function)
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
      infoItemUI = new PresentItemUI(displaySprite,callback);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      infoItemUI.updateData(index,data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      displaySprite = null;
      infoItemUI.dispose();
      infoItemUI = null;
      super.dispose();
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

class PresentItemUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var button:ContainerButton;
   
   private var nameText:ColorTextField;
   
   private var numText:ColorTextField;
   
   private var icon:Image;
   
   private var index:int;
   
   private var kind:int;
   
   private var id:int;
   
   private var num:int;
   
   function PresentItemUI(param1:Sprite, param2:Function)
   {
      super(param1);
      this.callback = param2;
      button = param1.getChildByName("button") as ContainerButton;
      nameText = button.getChildByName("name") as ColorTextField;
      numText = button.getChildByName("num") as ColorTextField;
      icon = button.getChildByName("icon") as Image;
      var _loc3_:ColorTextField = button.getChildByName("text") as ColorTextField;
      _loc3_.text#2 = GameSetting.getUIText("common.got.num");
   }
   
   public function updateData(param1:int, param2:Object) : void
   {
      if(!param2)
      {
         return;
      }
      this.index = param1;
      kind = param2.kind;
      id = param2.id;
      num = param2.num;
      refreshUI();
   }
   
   public function refreshUI() : void
   {
      var name:String = GudetamaUtil.getItemName(kind,id);
      var imageName:String = GudetamaUtil.getItemIconName(kind,id);
      nameText.text#2 = name;
      numText.text#2 = StringUtil.getNumStringCommas(num);
      if(imageName.length > 0)
      {
         TextureCollector.loadTextureRsrc(imageName,function(param1:Texture):void
         {
            icon.texture = param1;
         });
      }
   }
   
   public function dispose() : void
   {
      button = null;
      nameText = null;
      numText = null;
   }
}
