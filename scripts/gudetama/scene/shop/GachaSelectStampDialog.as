package gudetama.scene.shop
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
   import gudetama.data.compati.GachaDef;
   import gudetama.data.compati.GachaPriceDef;
   import gudetama.data.compati.ItemParam;
   import gudetama.data.compati.StampDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.ui.LocalMessageDialog;
   import gudetama.util.SpriteExtractor;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class GachaSelectStampDialog extends BaseScene
   {
       
      
      private var id:int;
      
      private var index:int;
      
      private var callback:Function;
      
      private var numPerPlay:int;
      
      private var dialogSprite:Sprite;
      
      private var closeButton:ContainerButton;
      
      private var list:List;
      
      private var gachaPlayButtonUI:GachaPlayButtonUI;
      
      private var numText:ColorTextField;
      
      private var maxText:ColorTextField;
      
      private var listEmptyText:ColorTextField;
      
      private var extractor:SpriteExtractor;
      
      private var collection:ListCollection;
      
      private var loadCount:int;
      
      private var selectedNum:int;
      
      private var homeDecoStapmMap:Object;
      
      public function GachaSelectStampDialog(param1:int, param2:int, param3:Function)
      {
         collection = new ListCollection();
         super(1);
         this.id = param1;
         this.index = param2;
         this.callback = param3;
         var _loc6_:GachaDef;
         var _loc4_:GachaPriceDef = (_loc6_ = GameSetting.getGacha(param1)).prices[param2];
         var _loc5_:ItemParam;
         numPerPlay = (_loc5_ = GachaScene_Gudetama.getPrice(_loc6_,param2)).num;
         homeDecoStapmMap = UserDataWrapper.wrapper.getHomeDecoStampNumsMap();
      }
      
      public static function show(param1:int, param2:int, param3:Function) : void
      {
         Engine.pushScene(new GachaSelectStampDialog(param1,param2,param3),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"GachaSelectStampDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            dialogSprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            closeButton = dialogSprite.getChildByName("btn_back") as ContainerButton;
            closeButton.addEventListener("triggered",triggeredCloseButton);
            list = dialogSprite.getChildByName("list") as List;
            gachaPlayButtonUI = new GachaPlayButtonUI(dialogSprite.getChildByName("gachaButton") as Sprite,triggeredConfirmCallback);
            numText = dialogSprite.getChildByName("num") as ColorTextField;
            maxText = dialogSprite.getChildByName("max") as ColorTextField;
            listEmptyText = dialogSprite.getChildByName("listEmptyText") as ColorTextField;
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         setupLayoutForTask(queue,"_SelectStampItem",function(param1:Object):void
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
         preloadIcons();
         queue.startTask(onProgress);
      }
      
      private function preloadIcons() : void
      {
         var _loc1_:* = null;
         var _loc2_:Object = UserDataWrapper.stampPart.getStampMap();
         for(var _loc3_ in _loc2_)
         {
            _loc1_ = GameSetting.getStamp(_loc3_);
            if(!(!_loc1_ || !_loc1_.isRare()))
            {
               preloadIcon(GudetamaUtil.getItemIconName(11,_loc3_));
            }
         }
      }
      
      private function preloadIcon(param1:String) : void
      {
         var path:String = param1;
         loadCount++;
         queue.addTask(function():void
         {
            TextureCollector.loadTexture(path,function(param1:Texture):void
            {
               loadCount--;
               checkInit();
               queue.taskDone();
            });
         });
      }
      
      private function setupLayoutForTask(param1:TaskQueue, param2:Object, param3:Function) : void
      {
         var queue:TaskQueue = param1;
         var layoutData:Object = param2;
         var callback:Function = param3;
         loadCount++;
         Engine.setupLayoutForTask(queue,layoutData,function(param1:Object):void
         {
            loadCount--;
            callback(param1);
            checkInit();
         });
      }
      
      private function addTask(param1:Function) : void
      {
         loadCount++;
         queue.addTask(param1);
      }
      
      private function taskDone() : void
      {
         loadCount--;
         checkInit();
         queue.taskDone();
      }
      
      private function checkInit() : void
      {
         if(loadCount > 0)
         {
            return;
         }
         init();
      }
      
      private function init() : void
      {
         var layout:FlowLayout = new FlowLayout();
         layout.horizontalAlign = "left";
         layout.horizontalGap = 14;
         layout.verticalGap = 10;
         layout.paddingTop = 10;
         layout.paddingLeft = 13.5;
         list.layout = layout;
         list.itemRendererFactory = function():IListItemRenderer
         {
            return new SelectStampItemRenderer(extractor,selectStampCallback);
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
         var _loc7_:* = 0;
         var _loc2_:* = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Boolean = false;
         gachaPlayButtonUI.setupSelectStamp(GameSetting.getGacha(id),index);
         gachaPlayButtonUI.getDisplaySprite().x = 0.5 * dialogSprite.width - 0.5 * gachaPlayButtonUI.width;
         var _loc1_:Array = [];
         var _loc6_:Object = UserDataWrapper.stampPart.getStampMap();
         for(_loc7_ in _loc6_)
         {
            _loc2_ = GameSetting.getStamp(_loc7_);
            if(!(!_loc2_ || !_loc2_.isRare()))
            {
               _loc1_.push(_loc7_);
            }
         }
         _loc1_.sort(ascendingSortFunc);
         for each(_loc7_ in _loc1_)
         {
            _loc3_ = UserDataWrapper.stampPart.getNumStamp(_loc7_);
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               _loc5_ = checkHomeStampNum(_loc7_);
               collection.addItem({
                  "id":_loc7_,
                  "useHomeDeco":_loc5_
               });
               _loc4_++;
            }
         }
         maxText.text#2 = String(numPerPlay * 10);
         listEmptyText.visible = collection.length <= 0;
         update();
      }
      
      private function ascendingSortFunc(param1:int, param2:int) : Number
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
      
      private function checkHomeStampNum(param1:int) : Boolean
      {
         var _loc3_:int = 0;
         if(!homeDecoStapmMap)
         {
            return false;
         }
         for(var _loc2_ in homeDecoStapmMap)
         {
            if(_loc2_ == param1)
            {
               _loc3_ = homeDecoStapmMap[_loc2_];
               if(_loc3_ > 0)
               {
                  homeDecoStapmMap[_loc2_] = _loc3_ - 1;
                  return true;
               }
               return false;
            }
         }
         return false;
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(GachaSelectStampDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(GachaSelectStampDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         back();
      }
      
      private function back(param1:Function = null) : void
      {
         var callback:Function = param1;
         super.backButtonCallback();
         Engine.lockTouchInput(GachaSelectStampDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(GachaSelectStampDialog);
            Engine.popScene(scene);
            if(callback)
            {
               callback();
            }
         });
      }
      
      private function selectStampCallback(param1:int) : void
      {
         update();
      }
      
      private function update() : void
      {
         var _loc2_:* = null;
         var _loc3_:int = 0;
         selectedNum = 0;
         _loc3_ = 0;
         while(_loc3_ < collection.length)
         {
            _loc2_ = collection.getItemAt(_loc3_);
            if(_loc2_.check)
            {
               selectedNum++;
            }
            _loc3_++;
         }
         var _loc1_:* = selectedNum >= numPerPlay * 10;
         numText.text#2 = String(selectedNum);
         TweenAnimator.startItself(numText,!_loc1_ ? "normal" : "max");
         TweenAnimator.finishItself(numText);
         _loc3_ = 0;
         while(_loc3_ < collection.length)
         {
            _loc2_ = collection.getItemAt(_loc3_);
            _loc2_["disable"] = _loc1_;
            collection.updateItemAt(_loc3_);
            _loc3_++;
         }
         gachaPlayButtonUI.updateSelectStamp(Math.ceil(selectedNum / numPerPlay));
      }
      
      private function triggeredConfirmCallback(param1:int, param2:int = 0, param3:Boolean = false) : void
      {
         var id:int = param1;
         var index:int = param2;
         var playAll:Boolean = param3;
         if(selectedNum % numPerPlay != 0)
         {
            LocalMessageDialog.show(0,StringUtil.format(GameSetting.getUIText("gachaSelectStamp.dialog.desc.less"),Math.ceil(selectedNum / numPerPlay),numPerPlay - selectedNum % numPerPlay),null,GameSetting.getUIText("gachaSelectStamp.dialog.title"));
            return;
         }
         LocalMessageDialog.show(1,StringUtil.format(GameSetting.getUIText("gachaSelectStamp.dialog.desc.confirm"),selectedNum,selectedNum / numPerPlay),function(param1:Boolean):void
         {
            var choose:Boolean = param1;
            if(choose != 0)
            {
               return;
            }
            var stampIds:Array = [];
            var i:int = 0;
            while(i < collection.length)
            {
               var data:Object = collection.getItemAt(i);
               if(data.check)
               {
                  stampIds.push(data.id);
               }
               i++;
            }
            stampIds.sort(ascendingSortFunc);
            var stamps:Array = [];
            var currentId:int = 0;
            var num:int = 0;
            for each(stampId in stampIds)
            {
               if(currentId == 0)
               {
                  currentId = stampId;
                  num++;
                  stamps.push(currentId);
               }
               else if(stampId != currentId)
               {
                  stamps.push(num);
                  num = 0;
                  currentId = stampId;
                  num++;
                  stamps.push(currentId);
               }
               else
               {
                  num++;
               }
            }
            stamps.push(num);
            back(function():void
            {
               callback(stamps);
            });
         },GameSetting.getUIText("gachaSelectStamp.dialog.title"));
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         list = null;
         dialogSprite = null;
         closeButton.removeEventListener("triggered",triggeredCloseButton);
         closeButton = null;
         if(gachaPlayButtonUI)
         {
            gachaPlayButtonUI.dispose();
            gachaPlayButtonUI = null;
         }
         numText = null;
         maxText = null;
         collection = null;
         extractor = null;
         super.dispose();
      }
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class SelectStampItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var callback:Function;
   
   private var displaySprite:Sprite;
   
   private var selectStampItem:SelectStampItem;
   
   function SelectStampItemRenderer(param1:SpriteExtractor, param2:Function)
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
      selectStampItem = new SelectStampItem(displaySprite,callback);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      selectStampItem.updateData(data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      displaySprite = null;
      if(selectStampItem)
      {
         selectStampItem.dispose();
         selectStampItem = null;
      }
      super.dispose();
   }
}

import flash.geom.Point;
import flash.geom.Rectangle;
import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.engine.TextureCollector;
import gudetama.ui.MessageDialog;
import gudetama.ui.UIBase;
import muku.util.StarlingUtil;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.textures.Texture;

class SelectStampItem extends UIBase
{
    
   
   private var callback:Function;
   
   private var iconImage:Image;
   
   private var disableImage:Image;
   
   private var checkImage:Image;
   
   private var data:Object;
   
   private var bounds:Rectangle;
   
   private var usingHomeDeco:Boolean = false;
   
   function SelectStampItem(param1:Sprite, param2:Function)
   {
      bounds = new Rectangle();
      super(param1);
      this.callback = param2;
      iconImage = param1.getChildByName("icon") as Image;
      iconImage.addEventListener("touch",touchQuad);
      disableImage = param1.getChildByName("disable") as Image;
      checkImage = param1.getChildByName("check") as Image;
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      if(!data)
      {
         return;
      }
      this.data = data;
      TextureCollector.loadTexture(GudetamaUtil.getItemIconName(11,data.id),function(param1:Texture):void
      {
         iconImage.texture = param1;
      });
      if(!data.initialized)
      {
         data["check"] = false;
         data["initialized"] = true;
      }
      checkImage.visible = disableImage.visible = data.check;
      iconImage.touchable = true;
      if(!data.check && data.disable)
      {
         disableImage.visible = true;
         iconImage.touchable = false;
      }
      if(data.useHomeDeco)
      {
         disableImage.visible = true;
      }
   }
   
   private function touchQuad(param1:TouchEvent) : void
   {
      var event:TouchEvent = param1;
      var touch:Touch = event.getTouch(iconImage);
      if(touch == null)
      {
         return;
      }
      if(touch.phase == "began")
      {
         var point:Point = StarlingUtil.getPointFromPool();
         point.setTo(displaySprite.x,displaySprite.y);
         displaySprite.localToGlobal(point,point);
         bounds.setTo(point.x,point.y,displaySprite.width,displaySprite.height);
      }
      else if(touch.phase == "moved")
      {
         if(!touch.cancelled && !bounds.contains(touch.globalX,touch.globalY))
         {
            touch.cancelled = true;
         }
      }
      else if(touch.phase == "ended")
      {
         if(data.useHomeDeco)
         {
            MessageDialog.show(1,GameSetting.getUIText("gachaSelectStamp.dialog.desc.limitover"),function(param1:int):void
            {
            });
         }
         else if(!touch.cancelled)
         {
            checkImage.visible = disableImage.visible = data["check"] = !data.check;
            callback(data.id);
         }
      }
   }
   
   public function dispose() : void
   {
      if(iconImage)
      {
         iconImage.removeEventListener("touch",touchQuad);
      }
      disableImage = null;
      checkImage = null;
   }
}
