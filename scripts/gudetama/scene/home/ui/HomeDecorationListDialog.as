package gudetama.scene.home.ui
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
   import gudetama.data.compati.DecorationDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.scene.decoration.DecorationDetailDialog;
   import gudetama.scene.home.HomeDecoScene;
   import gudetama.ui.MessageDialog;
   import gudetama.util.SpriteExtractor;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.display.SimpleImageButton;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class HomeDecorationListDialog extends BaseScene
   {
      
      private static const TAB_DECORATION:int = 0;
       
      
      private var list:List;
      
      private var btnGoShop:SimpleImageButton;
      
      private var closeButton:ContainerButton;
      
      private var decorationExtractor:SpriteExtractor;
      
      protected var collection:ListCollection;
      
      private var loadCount:int;
      
      private var cachedRsrcNameMap:Object = null;
      
      private var rentalDecorationIds:Array;
      
      private var homeDecoScene:HomeDecoScene;
      
      public function HomeDecorationListDialog(param1:HomeDecoScene)
      {
         collection = new ListCollection();
         super(2);
         homeDecoScene = param1;
         cachedRsrcNameMap = {};
         addEventListener("update_scene",updateScene);
      }
      
      public static function show(param1:HomeDecoScene) : void
      {
         Engine.pushScene(new HomeDecorationListDialog(param1),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"HomeDecorationListDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            list = _loc2_.getChildByName("list") as List;
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         setupLayoutForTask(queue,"_DecorationListItem",function(param1:Object):void
         {
            decorationExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         preloadDecorationImageTextures();
         queue.registerOnProgress(function(param1:Number):void
         {
         });
         queue.startTask(onProgress);
      }
      
      private function _preloadUsefulIconTexture(param1:int) : void
      {
         var id:int = param1;
         loadCount++;
         queue.addTask(function():void
         {
            loadTexture(GudetamaUtil.getItemIconName(8,id),function(param1:Texture):void
            {
               loadCount--;
               checkInit();
               queue.taskDone();
            });
         });
      }
      
      private function preloadDecorationImageTextures() : void
      {
         var _loc3_:* = null;
         var _loc2_:Object = UserDataWrapper.decorationPart.getAcquiredDecorationMap();
         var _loc1_:Object = {};
         for(var _loc5_ in _loc2_)
         {
            _loc3_ = GameSetting.getDecoration(_loc5_);
            if(!GameSetting.isPrivately(9,_loc5_))
            {
               _loc1_[_loc5_] = _loc5_;
            }
         }
         rentalDecorationIds = UserDataWrapper.eventPart.getRentalDecorationIds();
         for each(var _loc4_ in rentalDecorationIds)
         {
            _loc1_[_loc4_] = _loc4_;
         }
         for(_loc5_ in _loc1_)
         {
            _preloadDecorationImageTexture(_loc5_);
         }
      }
      
      private function _preloadDecorationImageTexture(param1:int) : void
      {
         var id:int = param1;
         loadCount++;
         queue.addTask(function():void
         {
            loadTexture(GudetamaUtil.getItemImageName(9,id),function(param1:Texture):void
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
         layout.horizontalGap = 8;
         layout.verticalGap = 10;
         layout.paddingTop = 5;
         layout.paddingLeft = 0;
         list.layout = layout;
         list.setItemRendererFactoryWithID("0",function():IListItemRenderer
         {
            return new DecorationListItemRenderer(decorationExtractor,scene,triggeredDecorationItemUI);
         });
         list.factoryIDFunction = function(param1:Object):String
         {
            return String(param1.type);
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
         setupDecoration();
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
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(HomeDecorationListDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(HomeDecorationListDialog);
         });
      }
      
      public function loadTexture(param1:String, param2:Function) : void
      {
         TextureCollector.loadTexture(param1,param2);
         if(cachedRsrcNameMap != null)
         {
            cachedRsrcNameMap[param1] = param1;
         }
      }
      
      private function clearCache() : void
      {
         if(cachedRsrcNameMap != null)
         {
            for(var _loc1_ in cachedRsrcNameMap)
            {
               TextureCollector.clearAtName(_loc1_);
            }
            cachedRsrcNameMap = {};
         }
      }
      
      private function triggeredDecorationItemUI(param1:int) : void
      {
         DecorationDetailDialog.show(param1,rentalDecorationIds.indexOf(param1) >= 0 && !UserDataWrapper.decorationPart.hasDecoration(param1),1,decorationCallback);
      }
      
      private function setupDecoration() : void
      {
         var _loc4_:* = null;
         var _loc1_:Object = UserDataWrapper.decorationPart.getAcquiredDecorationMap();
         var _loc2_:Array = [];
         for(var _loc6_ in _loc1_)
         {
            _loc4_ = GameSetting.getDecoration(_loc6_);
            if(!GameSetting.isPrivately(9,_loc6_))
            {
               _loc2_.push(_loc6_);
            }
         }
         _loc2_.sort(ascendingKeyComparator);
         collection.removeAll();
         list.stopScrolling();
         list.scrollToPosition(0,0,0);
         var _loc3_:Array = UserDataWrapper.eventPart.getRentalDecorationIds();
         for each(var _loc5_ in _loc3_)
         {
            if(_loc2_.indexOf(_loc5_) < 0)
            {
               collection.addItem({
                  "type":0,
                  "id":_loc5_,
                  "rental":true
               });
            }
         }
         for each(_loc6_ in _loc2_)
         {
            collection.addItem({
               "type":0,
               "id":_loc6_,
               "rental":false
            });
         }
      }
      
      override public function backButtonCallback() : void
      {
         if(Engine.getGuideTalkPanel() != null)
         {
            return;
         }
         back();
      }
      
      private function back(param1:Function = null) : void
      {
         var callback:Function = param1;
         super.backButtonCallback();
         Engine.lockTouchInput(HomeDecorationListDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(HomeDecorationListDialog);
            Engine.popScene(scene);
            if(callback)
            {
               callback();
            }
         });
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      private function updateScene() : void
      {
         collection.updateAll();
      }
      
      private function decorationCallback(param1:int) : void
      {
         var _id:int = param1;
         var currentlist:Array = homeDecoScene.getCurrentDecoDataList();
         if(currentlist && GameSetting.getRule().useHomeDecoEachType)
         {
            MessageDialog.show(2,GameSetting.getUIText("homedeco.btn.reflect.confirmation"),function(param1:int):void
            {
               if(param1 == 0)
               {
                  var _loc2_:* = UserDataWrapper;
                  UserDataWrapper.wrapper.setHomeDecoData(gudetama.data.UserDataWrapper.wrapper._data.decorationId,currentlist);
               }
               processSetRoomTexture();
            });
         }
         else
         {
            processSetRoomTexture();
         }
      }
      
      private function processSetRoomTexture() : void
      {
         Engine.showLoading(this);
         var innerQueue:TaskQueue = new TaskQueue();
         homeDecoScene.setRoomTexture(innerQueue,false);
         innerQueue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            Engine.hideLoadingForce();
            Engine.unlockTouchInputForce();
            setBackButtonCallback(backButtonCallback);
         });
         innerQueue.startTask();
         updateScene();
      }
      
      override public function dispose() : void
      {
         list = null;
         decorationExtractor = null;
         collection = null;
         clearCache();
         super.dispose();
      }
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.engine.BaseScene;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class DecorationListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var scene:BaseScene;
   
   private var callback:Function;
   
   private var displaySprite:Sprite;
   
   private var decorationItemUI:DecorationItemUI;
   
   function DecorationListItemRenderer(param1:SpriteExtractor, param2:BaseScene, param3:Function)
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
      decorationItemUI = new DecorationItemUI(displaySprite,scene,callback);
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
      if(decorationItemUI)
      {
         decorationItemUI.dispose();
         decorationItemUI = null;
      }
      super.dispose();
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.DecorationDef;
import gudetama.engine.BaseScene;
import gudetama.scene.home.ui.HomeDecorationListDialog;
import gudetama.ui.UIBase;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class DecorationItemUI extends UIBase
{
    
   
   private var scene:HomeDecorationListDialog;
   
   private var callback:Function;
   
   private var button:ContainerButton;
   
   private var nameText:ColorTextField;
   
   private var iconImage:Image;
   
   private var rentalImage:Image;
   
   private var disabled:Sprite;
   
   private var id:int;
   
   function DecorationItemUI(param1:Sprite, param2:BaseScene, param3:Function)
   {
      super(param1);
      this.scene = param2 as HomeDecorationListDialog;
      this.callback = param3;
      button = param1.getChildByName("button") as ContainerButton;
      button.addEventListener("triggered",triggeredButton);
      nameText = button.getChildByName("name") as ColorTextField;
      iconImage = button.getChildByName("icon") as Image;
      rentalImage = button.getChildByName("rental") as Image;
      disabled = button.getChildByName("disabled") as Sprite;
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      if(!data)
      {
         return;
      }
      id = data.id;
      var decorationDef:DecorationDef = GameSetting.getDecoration(id);
      nameText.text#2 = decorationDef.name#2;
      scene.loadTexture(GudetamaUtil.getItemImageName(9,id),function(param1:Texture):void
      {
         iconImage.texture = param1;
      });
      rentalImage.visible = data.rental;
      var currentId:int = UserDataWrapper.decorationPart.getCurrentDecorationId();
      if(currentId != id)
      {
         button.touchable = true;
         disabled.visible = false;
      }
      else
      {
         button.touchable = false;
         disabled.visible = true;
      }
   }
   
   private function triggeredButton(param1:Event) : void
   {
      callback(id);
   }
   
   public function dispose() : void
   {
      if(button)
      {
         button.removeEventListener("triggered",triggeredButton);
         button = null;
      }
      nameText = null;
   }
}
