package gudetama.scene.home.ui
{
   import flash.display.BitmapData;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import gudetama.common.BannerAdvertisingManager;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.GudetamaDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.scene.ar.SnsShareDialog;
   import gudetama.util.SpriteExtractor;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.display.ManuallySpineButton;
   import muku.util.StarlingUtil;
   import starling.core.Starling;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   import starling.rendering.Painter;
   import starling.textures.Texture;
   
   public class HomeDecoShareDialog extends BaseScene
   {
       
      
      private var gudetamaDef:GudetamaDef;
      
      private var loadCount:int;
      
      private var captureLayer:Sprite;
      
      private var bg:Sprite;
      
      private var bgTexture:Texture;
      
      private var frameImage:Image;
      
      private var frameTexture:Texture;
      
      private var titleLogoImage:Image;
      
      private var gudetamaGroup:Sprite;
      
      protected var gudetamaSpine:ManuallySpineButton;
      
      private var frameBtn:ContainerButton;
      
      private var freamListManager:framepListManager;
      
      private var frameListExtractor:SpriteExtractor;
      
      private var freamListDefPosX:Number;
      
      private var frameVisible:Boolean = false;
      
      public function HomeDecoShareDialog(param1:BitmapData)
      {
         super(1);
         bgTexture = Texture.fromBitmapData(param1);
         BannerAdvertisingManager.visibleBanner(false);
      }
      
      public static function show(param1:BitmapData) : void
      {
         Engine.pushScene(new HomeDecoShareDialog(param1));
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"HomeDecoShareLayout",function(param1:Object):void
         {
            var layout:Object = param1;
            displaySprite = layout.object;
            displaySprite.visible = false;
            captureLayer = displaySprite.getChildByName("captureLayer") as Sprite;
            bg = captureLayer.getChildByName("bg") as Sprite;
            bg.addChild(new Image(bgTexture));
            frameImage = captureLayer.getChildByName("frame") as Image;
            gudetamaGroup = captureLayer.getChildByName("gudetamaGroup") as Sprite;
            var origin:Sprite = gudetamaGroup.getChildByName("origin") as Sprite;
            gudetamaSpine = gudetamaGroup.getChildByName("gudetamaButton") as ManuallySpineButton;
            gudetamaSpine.setOrigin(origin.x,origin.y);
            gudetamaSpine.touchable = false;
            titleLogoImage = captureLayer.getChildByName("titleLogo") as Image;
            TextureCollector.loadTexture("gacha1@titlelogo",function(param1:Texture):void
            {
               titleLogoImage.texture = param1;
            });
            frameBtn = displaySprite.getChildByName("frameBtn") as ContainerButton;
            frameBtn.addEventListener("triggered",triggeredVisibleUI);
            var frameListSprite:Sprite = displaySprite.getChildByName("frameListContainer") as Sprite;
            if(existFrame())
            {
               freamListManager = new framepListManager(scene as HomeDecoShareDialog,frameListSprite);
               freamListDefPosX = freamListManager.x;
            }
            else
            {
               frameBtn.touchable = false;
               frameBtn.visible = false;
               frameListSprite.touchable = false;
               frameListSprite.visible = false;
            }
         });
         setupLayoutForTask(queue,"_HomeFrameListItem",function(param1:Object):void
         {
            setFrameListExtractor(SpriteExtractor.forGross(param1.object,param1));
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
         load();
      }
      
      private function load() : void
      {
         if(existFrame())
         {
            freamListManager.setupList(frameListExtractor);
         }
         var innerQueue:TaskQueue = new TaskQueue();
         gudetamaDef = GameSetting.getGudetama(UserDataWrapper.wrapper.getPlacedGudetamaId());
         gudetamaSpine.setup(innerQueue,gudetamaDef.id#2,true);
         if(frameTexture)
         {
            setFrameTexture(frameTexture);
         }
         innerQueue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            addChild(displaySprite);
         });
         innerQueue.startTask();
      }
      
      public function setFrameListExtractor(param1:SpriteExtractor) : void
      {
         frameListExtractor = param1;
      }
      
      private function loadFrame(param1:TaskQueue) : void
      {
         var _queue:TaskQueue = param1;
         _queue.addTask(function():void
         {
            TextureCollector.loadTextureForTask(queue,"bg-fream_2",function(param1:Texture):void
            {
               frameTexture = param1;
               _queue.taskDone();
            });
         });
      }
      
      public function setFrameTexture(param1:Texture) : void
      {
         frameImage.alpha = 1;
         frameImage.texture = param1;
         frameImage.readjustSize();
      }
      
      override protected function addedToContainer() : void
      {
         setBackButtonCallback(backButtonCallback);
         setVisibleState(1);
         BannerAdvertisingManager.hideAllBanner();
         displaySprite.visible = true;
         captureLayer.addEventListener("touch",onTouch);
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         setBackButtonCallback(null);
         Engine.popScene(scene);
      }
      
      private function onTouch(param1:TouchEvent) : void
      {
         var event:TouchEvent = param1;
         var touch:Touch = event.getTouch(captureLayer);
         if(!touch)
         {
            return;
         }
         if(touch.phase == "ended")
         {
            if(frameVisible)
            {
               triggeredVisibleUI();
            }
            else
            {
               captureLayer.removeEventListener("touch",onTouch);
               SnsShareDialog.show(processCapturedComposition(),6,false,function():void
               {
                  backButtonCallback();
               },null,!!gudetamaDef ? gudetamaDef.id#2 : 0);
            }
         }
      }
      
      private function triggeredVisibleUI() : void
      {
         frameVisible = !frameVisible;
         freamListManager.x = freamListDefPosX;
         if(frameVisible)
         {
            TweenAnimator.startTween(freamListManager.base,"FADEIN_MOVE_X",{
               "time":0.25,
               "deltaX":-freamListManager.base.width
            },function():void
            {
               freamListManager.x = freamListDefPosX;
               Engine.unlockTouchInput(freamListManager.base);
               freamListManager.base.touchable = true;
            });
         }
         else
         {
            TweenAnimator.startTween(freamListManager.base,"FADEOUT_MOVE_X",{
               "time":0.25,
               "deltaX":freamListManager.base.width
            },function():void
            {
               freamListManager.x = freamListDefPosX;
               freamListManager.base.touchable = false;
            });
         }
      }
      
      public function existFrame() : Boolean
      {
         var _loc1_:Array = GameSetting.getRule().frameIds;
         if(_loc1_ && _loc1_.length > 0)
         {
            return true;
         }
         return false;
      }
      
      private function processCapturedComposition() : BitmapData
      {
         var _loc8_:Number = 640;
         var _loc5_:Number = 1136;
         var _loc12_:* = Starling;
         var _loc7_:Starling = starling.core.Starling.sCurrent;
         var _loc13_:* = Starling;
         var _loc1_:Painter = !!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._painter : null;
         var _loc4_:Rectangle;
         var _loc2_:Number = (_loc4_ = _loc7_.viewPort).width;
         var _loc6_:Number = _loc4_.height;
         var _loc9_:BitmapData = new BitmapData(_loc2_,_loc6_,true,0);
         var _loc11_:Rectangle;
         (_loc11_ = StarlingUtil.getRectangleFromPool()).setTo(0,0,_loc2_,_loc6_);
         var _loc3_:BitmapData = new BitmapData(_loc8_,_loc5_,false,0);
         var _loc10_:Point;
         (_loc10_ = StarlingUtil.getPointFromPool()).setTo(0,0);
         _loc1_.clear();
         _loc1_.pushState();
         _loc1_.state.renderTarget = null;
         _loc1_.state.setModelviewMatricesToIdentity();
         _loc1_.setStateTo(displaySprite.transformationMatrix);
         _loc1_.state.setProjectionMatrix(0,0,_loc2_,_loc6_,_loc2_,_loc6_,stage.cameraPosition);
         displaySprite.render(_loc1_);
         _loc1_.finishMeshBatch();
         _loc1_.context.drawToBitmapData(_loc9_);
         _loc1_.popState();
         _loc3_.copyPixels(_loc9_,_loc11_,_loc10_);
         _loc9_.dispose();
         _loc9_ = null;
         return _loc3_;
      }
   }
}

import feathers.controls.IScrollBar;
import feathers.controls.List;
import feathers.controls.ScrollBar;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.TiledRowsLayout;
import gudetama.data.GameSetting;
import gudetama.scene.home.ui.HomeDecoShareDialog;
import gudetama.scene.home.ui.HomeFrameItemRenderer;
import gudetama.util.SpriteExtractor;
import muku.display.SimpleImageButton;
import muku.text.ColorTextField;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class framepListManager
{
    
   
   private var control:HomeDecoShareDialog;
   
   private var baseSprite:Sprite;
   
   private var list:List;
   
   private var collection:ListCollection;
   
   private var plusBtn:SimpleImageButton;
   
   private var placedStampNumText:ColorTextField;
   
   private var currentPlaceNum:int;
   
   function framepListManager(param1:HomeDecoShareDialog, param2:Sprite)
   {
      super();
      this.control = param1;
      this.baseSprite = param2;
      baseSprite.alpha = 0;
      baseSprite.touchable = false;
      list = baseSprite.getChildByName("list") as List;
      (baseSprite.getChildByName("bg_mat") as Image).touchable = true;
      collection = new ListCollection();
      currentPlaceNum = 0;
   }
   
   public function setupList(param1:SpriteExtractor) : void
   {
      var extractor:SpriteExtractor = param1;
      var profferStampIds:Array = GameSetting.getRule().frameIds;
      collection.push({"id":-1});
      var i:int = 0;
      while(i < profferStampIds.length)
      {
         collection.push({"id":profferStampIds[i]});
         i++;
      }
      var framearray:Array = collection.data#2 as Array;
      framearray.sort(function(param1:Object, param2:Object):int
      {
         return param1.id - param2.id;
      });
      var layout:TiledRowsLayout = new TiledRowsLayout();
      layout.verticalAlign = "center";
      layout.horizontalAlign = "left";
      layout.useSquareTiles = false;
      layout.requestedColumnCount = 2;
      layout.horizontalGap = 15;
      layout.verticalGap = 5;
      list.layout = layout;
      list.hasElasticEdges = false;
      list.autoHideBackground = true;
      list.itemRendererFactory = function():IListItemRenderer
      {
         var _loc1_:HomeFrameItemRenderer = new HomeFrameItemRenderer(extractor);
         _loc1_.addEventListener("triggered",triggeredStampItemEvent);
         return _loc1_;
      };
      list.verticalScrollBarFactory = function():IScrollBar
      {
         var _loc1_:ScrollBar = new ScrollBar();
         _loc1_.userObject["scene"] = HomeDecoShareDialog;
         return _loc1_;
      };
      list.scrollBarDisplayMode = "fixed";
      list.horizontalScrollPolicy = "off";
      list.interactionMode = "touchAndScrollBars";
      list.dataProvider = collection;
      list.validate();
   }
   
   public function get x() : Number
   {
      return baseSprite.x;
   }
   
   public function set x(param1:Number) : void
   {
      baseSprite.x = param1;
   }
   
   public function get base() : DisplayObject
   {
      return baseSprite;
   }
   
   private function triggeredStampItemEvent(param1:Event) : void
   {
      var _loc2_:Texture = param1.data#2 as Texture;
      if(!_loc2_)
      {
         return;
      }
      control.setFrameTexture(_loc2_);
   }
}
