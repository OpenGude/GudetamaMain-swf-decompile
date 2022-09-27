package gudetama.ui
{
   import feathers.controls.IScrollBar;
   import feathers.controls.List;
   import feathers.controls.ScrollBar;
   import feathers.controls.renderers.IListItemRenderer;
   import feathers.data.ListCollection;
   import feathers.layout.FlowLayout;
   import gudetama.data.compati.GetItemResult;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.util.SpriteExtractor;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Sprite;
   
   public class ItemsGetDialog extends BaseScene
   {
       
      
      private var getItemResults:Array;
      
      private var callback:Function;
      
      private var msg:String;
      
      private var title:String;
      
      private var collection:ListCollection;
      
      private var list:List;
      
      private var extractor:SpriteExtractor;
      
      private var btnBack:ContainerButton;
      
      public function ItemsGetDialog(param1:Array, param2:Function, param3:String, param4:String)
      {
         super(2);
         this.getItemResults = param1;
         this.callback = param2;
         this.msg = param3;
         this.title = param4;
         collection = new ListCollection();
      }
      
      public static function show(param1:Array, param2:Function, param3:String, param4:String) : void
      {
         Engine.pushScene(new ItemsGetDialog(param1,param2,param3,param4),0,false);
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
            _loc3_.text#2 = title;
            _loc4_.text#2 = msg;
            btnBack.addEventListener("triggered",backButtonCallback);
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         Engine.setupLayoutForTask(queue,"_GetItemListItem",function(param1:Object):void
         {
            extractor = SpriteExtractor.forGross(param1.object,param1);
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
         Engine.lockTouchInput(ItemsGetDialog);
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
            return new GetItemListItemRenderer(extractor);
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
         _loc1_ = 0;
         while(_loc1_ < getItemResults.length)
         {
            collection.addItem(getItemResults[_loc1_]);
            _loc1_++;
         }
      }
      
      private function show() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(ItemsGetDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(ItemsGetDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(ItemsGetDialog);
            Engine.popScene(scene);
            var items:Array = [];
            var params:Array = [];
            var i:int = 0;
            while(i < getItemResults.length)
            {
               var result:GetItemResult = getItemResults[i];
               if(!result.toMail)
               {
                  items.push(result.item);
                  params.push(result.param);
               }
               i++;
            }
            if(items.length == 0)
            {
               if(callback != null)
               {
                  callback();
               }
            }
            else
            {
               ConvertDialog.show(items,params,function():void
               {
                  if(callback != null)
                  {
                     callback();
                  }
               });
            }
         });
      }
   }
}

import gudetama.ui.ListItemRendererBase;
import gudetama.util.SpriteExtractor;

class GetItemListItemRenderer extends ListItemRendererBase
{
    
   
   private var itemUI:GetItemUI;
   
   function GetItemListItemRenderer(param1:SpriteExtractor)
   {
      super(param1,null);
   }
   
   override protected function createItemUI() : void
   {
      itemUI = new GetItemUI(displaySprite);
   }
   
   override protected function commitData() : void
   {
      itemUI.updateData(data#2);
   }
   
   override protected function disposeItemUI() : void
   {
      itemUI.dispose();
      itemUI = null;
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.compati.GetItemResult;
import gudetama.data.compati.ItemParam;
import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

class GetItemUI extends UIBase
{
    
   
   private var lblName:ColorTextField;
   
   private var lblToMail:ColorTextField;
   
   private var lblNum:ColorTextField;
   
   private var icon:Image;
   
   function GetItemUI(param1:Sprite)
   {
      super(param1);
      lblName = param1.getChildByName("lblName") as ColorTextField;
      lblToMail = param1.getChildByName("lblToMail") as ColorTextField;
      lblToMail.text#2 = GameSetting.getUIText("common.tomail2");
      lblNum = param1.getChildByName("lblNum") as ColorTextField;
      icon = param1.getChildByName("icon") as Image;
      var _loc2_:ColorTextField = param1.getChildByName("lblGet") as ColorTextField;
      _loc2_.text#2 = GameSetting.getUIText("common.got.num");
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      if(!data)
      {
         return;
      }
      var getItem:GetItemResult = data as GetItemResult;
      var item:ItemParam = getItem.item;
      lblName.text#2 = GudetamaUtil.getItemName(item.kind,item.id#2);
      lblNum.text#2 = StringUtil.getNumStringCommas(item.num);
      TextureCollector.loadTextureRsrc(GudetamaUtil.getItemIconName(item.kind,item.id#2),function(param1:Texture):void
      {
         if(icon != null)
         {
            icon.texture = param1;
         }
      });
      lblToMail.visible = getItem.toMail;
   }
   
   public function dispose() : void
   {
      lblName = null;
      lblToMail = null;
      lblNum = null;
      icon = null;
   }
}
