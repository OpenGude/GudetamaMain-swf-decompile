package gudetama.scene.ar
{
   import feathers.controls.IScrollBar;
   import feathers.controls.ScrollBar;
   import feathers.controls.ScrollContainer;
   import flash.display.BitmapData;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import gudetama.common.GudetamaUtil;
   import gudetama.common.NativeExtensions;
   import gudetama.data.DataStorage;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.ItemParam;
   import gudetama.data.compati.Packet;
   import gudetama.data.compati.StampDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.scene.home.HomeScene;
   import gudetama.ui.GuideTalkPanel;
   import gudetama.ui.LocalMessageDialog;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.util.SpriteExtractor;
   import muku.display.ContainerButton;
   import muku.display.SimpleImageButton;
   import muku.util.StarlingUtil;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   import starling.rendering.Painter;
   import starling.textures.Texture;
   
   public class ARCapturedDialog extends BaseScene
   {
      
      private static var uniqueCounter:uint = 0;
      
      public static var CAPTURED_IMAGE_WIDTH:Number = 405;
      
      public static var CAPTURED_IMAGE_HEIGHT:Number = 540;
       
      
      private var finalBitmapData:BitmapData;
      
      private var capturedBitmapData:BitmapData;
      
      private var capturedTexture:Texture;
      
      private var cameraImageRot:Number;
      
      private var callback:Function;
      
      private var stampExtractor:SpriteExtractor;
      
      private var stampMap:Object;
      
      private var selectedUniqueId:int;
      
      private var scrollRenderSprite:ScrollContainer;
      
      private var renderImage:Image;
      
      private var stampLayer:Sprite;
      
      private var uiLayer:Sprite;
      
      private var resetBtn:ContainerButton;
      
      private var backBtn:ContainerButton;
      
      private var homeBtn:ContainerButton;
      
      private var saveAndShareBtn:ContainerButton;
      
      private var cameraBtn:SimpleImageButton;
      
      private var stampListManager:StampListManager;
      
      private var stampListExtractor:SpriteExtractor;
      
      private var editUI:EditUI;
      
      private var shareBonusItem:ItemParam;
      
      public function ARCapturedDialog(param1:Sprite)
      {
         stampMap = {};
         super(0);
         displaySprite = param1;
         scrollRenderSprite = displaySprite.getChildByName("scrollRenderLayer") as ScrollContainer;
         setupScrollRender();
         uiLayer = displaySprite.getChildByName("uiLayer") as Sprite;
         resetBtn = uiLayer.getChildByName("resetBtn") as ContainerButton;
         resetBtn.addEventListener("triggered",triggeredResetBtn);
         saveAndShareBtn = uiLayer.getChildByName("saveAndShareBtn") as ContainerButton;
         saveAndShareBtn.addEventListener("triggered",triggeredSaveAndShareBtn);
         backBtn = uiLayer.getChildByName("backBtn") as ContainerButton;
         backBtn.addEventListener("triggered",triggeredBackToARButton);
         homeBtn = uiLayer.getChildByName("homeBtn") as ContainerButton;
         homeBtn.addEventListener("triggered",triggeredGotoHomeButton);
         stampListManager = new StampListManager(scene as ARCapturedDialog,uiLayer.getChildByName("stampListContainer") as Sprite);
         editUI = new EditUI(scene as ARCapturedDialog,stampLayer.getChildByName("editSprite") as Sprite);
         editUI.visible = false;
         displaySprite.visible = false;
         addChild(displaySprite);
      }
      
      public static function generateUniqueID() : uint
      {
         return ++uniqueCounter;
      }
      
      override public function dispose() : void
      {
         if(capturedBitmapData)
         {
            renderImage.texture.dispose();
            renderImage.texture = null;
            capturedBitmapData.dispose();
            capturedBitmapData = null;
         }
         if(capturedTexture)
         {
            capturedTexture.dispose();
            capturedTexture = null;
         }
         super.dispose();
      }
      
      public function setStampExtractor(param1:SpriteExtractor) : void
      {
         stampExtractor = param1;
      }
      
      public function setStampListExtractor(param1:SpriteExtractor) : void
      {
         stampListExtractor = param1;
      }
      
      override protected function setupProgressForPermanent(param1:Function) : void
      {
         param1(1);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         param1(1);
         scenePermanent = true;
         stampListManager.setupList(stampListExtractor);
      }
      
      override protected function addedToContainer() : void
      {
         showResidentMenuUI(0);
         displaySprite.visible = true;
         if(shareBonusItem)
         {
            SnsShareDialog.showShareBonus(shareBonusItem,GameSetting.getUIText("ar.shareBonus.msg"));
         }
         setBackButtonCallback(function():void
         {
            triggeredBackToARButton(null);
         });
      }
      
      public function show(param1:BitmapData, param2:Number, param3:Function) : void
      {
         var capturedBitmapData:BitmapData = param1;
         var cameraImageRot:Number = param2;
         var callback:Function = param3;
         this.capturedBitmapData = capturedBitmapData;
         this.cameraImageRot = cameraImageRot;
         this.callback = callback;
         uniqueCounter = 0;
         CAPTURED_IMAGE_HEIGHT = CAPTURED_IMAGE_WIDTH * capturedBitmapData.height / capturedBitmapData.width;
         capturedTexture = Texture.fromBitmapData(capturedBitmapData);
         renderImage.texture = capturedTexture;
         renderImage.readjustSize();
         renderImage.scaleX = CAPTURED_IMAGE_WIDTH / capturedTexture.width;
         renderImage.scaleY = CAPTURED_IMAGE_HEIGHT / capturedTexture.height;
         scrollRenderSprite.readjustLayout();
         Engine.lockTouchInput(SnsShareDialog);
         var packet:Packet = PacketUtil.create(218);
         var _loc5_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(268435683,[!!DataStorage.getLocalData().isARMode() ? 1 : 0]),function(param1:Array):void
         {
         });
         var _loc6_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(packet,function(param1:Object):void
         {
            Engine.unlockTouchInput(SnsShareDialog);
            shareBonusItem = !!param1 ? param1[0] as ItemParam : null;
            Engine.pushScene(scene,0,false);
         });
      }
      
      public function isShow() : Boolean
      {
         return displaySprite.visible;
      }
      
      private function triggeredResetBtn(param1:Event) : void
      {
         LocalMessageDialog.show(9,GameSetting.getUIText("ar.stamp.reset.msg"),null,GameSetting.getUIText("ar.stamp.reset.title"),68);
         resetPlacedStamp();
      }
      
      private function triggeredSaveAndShareBtn(param1:Event) : void
      {
         var event:Event = param1;
         var _loc2_:* = Engine;
         if(!(gudetama.engine.Engine.platform == 1 || gudetama.engine.Engine.platform == 0))
         {
            return;
         }
         Engine.showLoading(ARScene);
         finalBitmapData = processCapturedComposition();
         var _loc3_:* = NativeExtensions;
         gudetama.common.NativeExtensions.arExt.save(finalBitmapData,function():void
         {
            Engine.hideLoading(ARScene);
            SnsShareDialog.show(finalBitmapData,0,true);
         });
      }
      
      private function triggeredGotoHomeButton(param1:Event) : void
      {
         var event:Event = param1;
         resetPlacedStamp();
         displaySprite.visible = false;
         if(capturedBitmapData)
         {
            renderImage.texture.dispose();
            renderImage.texture = null;
            capturedBitmapData.dispose();
            capturedBitmapData = null;
         }
         if(callback)
         {
            callback(true);
            callback = null;
         }
         ResidentMenuUI_Gudetama.getInstance().sendChangeState(60,function():void
         {
            Engine.switchScene(new HomeScene());
         });
      }
      
      private function triggeredBackToARButton(param1:Event) : void
      {
         var event:Event = param1;
         Engine.showLoading(ARCapturedDialog);
         getSceneJuggler().delayCall(function():void
         {
            var _loc1_:* = null;
            resetPlacedStamp();
            if(capturedBitmapData)
            {
               renderImage.texture.dispose();
               renderImage.texture = null;
               capturedBitmapData.dispose();
               capturedBitmapData = null;
            }
            if(stampMap[selectedUniqueId])
            {
               _loc1_ = stampMap[selectedUniqueId] as StampView;
               _loc1_.hideGrid();
            }
            editUI.visible = false;
            selectedUniqueId = -1;
            Engine.hideLoading(ARCapturedDialog);
            Engine.popScene(scene,1);
            if(callback)
            {
               callback(false);
               callback = null;
            }
         },0.5);
      }
      
      private function touchedRenderImage(param1:TouchEvent) : void
      {
         var _loc2_:* = null;
         var _loc3_:Touch = param1.getTouch(renderImage,"ended");
         if(_loc3_)
         {
            if(stampMap[selectedUniqueId])
            {
               _loc2_ = stampMap[selectedUniqueId] as StampView;
               _loc2_.hideGrid();
            }
            editUI.visible = false;
            selectedUniqueId = -1;
         }
      }
      
      private function triggeredRemoveStamp(param1:Event) : void
      {
         removeStamp(selectedUniqueId);
         editUI.visible = false;
      }
      
      public function removeStamp(param1:int) : void
      {
         var _loc2_:StampView = stampMap[param1] as StampView;
         _loc2_.dispose();
         stampMap[param1] = null;
         delete stampMap[param1];
         stampListManager.notifyRemovedGudetama(_loc2_.getStampID(),false);
      }
      
      private function resetPlacedStamp() : void
      {
         var _loc1_:* = null;
         for(var _loc2_ in stampMap)
         {
            _loc1_ = stampMap[_loc2_] as StampView;
            _loc1_.dispose();
            stampMap[_loc2_] = null;
            delete stampMap[_loc2_];
            stampListManager.notifyRemovedGudetama(_loc1_.getStampID(),true);
         }
         editUI.visible = false;
      }
      
      public function setSelectedStamp(param1:int) : void
      {
         var _loc2_:* = null;
         if(selectedUniqueId == param1)
         {
            return;
         }
         if(stampMap[selectedUniqueId])
         {
            _loc2_ = stampMap[selectedUniqueId] as StampView;
            _loc2_.hideGrid();
         }
         selectedUniqueId = param1;
         _loc2_ = stampMap[selectedUniqueId] as StampView;
         _loc2_.showGrid(editUI);
         stampLayer.setChildIndex(_loc2_.getDisplayObject(),stampLayer.numChildren - 1);
      }
      
      public function createStamp(param1:int, param2:Function) : void
      {
         var stampId:int = param1;
         var callback:Function = param2;
         var uniqueId:uint = generateUniqueID();
         var stampDef:StampDef = GameSetting.getStamp(stampId);
         var view:Sprite = stampExtractor.duplicateAll() as Sprite;
         var image:Image = view.getChildAt(0) as Image;
         var stampView:StampView = new StampView(image);
         stampView.init(this,stampId,uniqueId,function():void
         {
            image.x = renderImage.width / 2;
            image.y = renderImage.height / 2;
            stampLayer.addChild(image);
            stampMap[uniqueId] = stampView;
            callback(stampView);
         });
      }
      
      private function processCapturedComposition() : BitmapData
      {
         var capturedWidth:Number = capturedTexture.width;
         var capturedHeight:Number = capturedTexture.height;
         var capturedImage:Image = new Image(capturedTexture);
         var canvas:Sprite = new Sprite();
         canvas.addChild(capturedImage);
         var map:Object = {};
         for(key in stampMap)
         {
            var view:StampView = stampMap[key] as StampView;
            var dObj:DisplayObject = view.getDisplayObject();
            dObj.userObject["key"] = key;
            map[key] = stampLayer.getChildIndex(dObj);
         }
         for(key in stampMap)
         {
            view = stampMap[key] as StampView;
            dObj = view.getDisplayObject();
            canvas.addChild(dObj);
            dObj.x = capturedWidth * view.screenPosX;
            dObj.y = capturedHeight * view.screenPosY;
            dObj.scaleX = dObj.scaleX * capturedWidth / CAPTURED_IMAGE_WIDTH;
            dObj.scaleY = dObj.scaleY * capturedHeight / CAPTURED_IMAGE_HEIGHT;
         }
         canvas.sortChildren(function(param1:DisplayObject, param2:DisplayObject):int
         {
            if(map[param1.userObject.key] > map[param2.userObject.key])
            {
               return 1;
            }
            if(map[param1.userObject.key] < map[param2.userObject.key])
            {
               return -1;
            }
            return 0;
         });
         if(stampMap[selectedUniqueId])
         {
            view = stampMap[selectedUniqueId] as StampView;
            view.hideGrid();
         }
         editUI.visible = false;
         selectedUniqueId = -1;
         var _loc6_:* = Starling;
         var _starling:Starling = starling.core.Starling.sCurrent;
         var _loc7_:* = Starling;
         var painter:Painter = !!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._painter : null;
         var viewPort:Rectangle = _starling.viewPort;
         var stageWidth:Number = viewPort.width;
         var stageHeight:Number = viewPort.height;
         var sectionResult:BitmapData = new BitmapData(stageWidth,stageHeight,true,0);
         var sectionResultRect:Rectangle = StarlingUtil.getRectangleFromPool();
         sectionResultRect.setTo(0,0,stageWidth,stageHeight);
         var result:BitmapData = new BitmapData(capturedWidth,capturedHeight,false,0);
         var point:Point = StarlingUtil.getPointFromPool();
         var i:int = 0;
         while(i < Math.ceil(capturedWidth / stageWidth))
         {
            var j:int = 0;
            while(j < Math.ceil(capturedHeight / stageHeight))
            {
               canvas.x = -i * stageWidth;
               canvas.y = -j * stageHeight;
               painter.clear();
               painter.pushState();
               painter.state.renderTarget = null;
               painter.state.setModelviewMatricesToIdentity();
               painter.setStateTo(canvas.transformationMatrix);
               painter.state.setProjectionMatrix(0,0,stageWidth,stageHeight,stageWidth,stageHeight,stage.cameraPosition);
               canvas.render(painter);
               painter.finishMeshBatch();
               painter.context.drawToBitmapData(sectionResult);
               painter.popState();
               point.setTo(i * stageWidth,j * stageHeight);
               result.copyPixels(sectionResult,sectionResultRect,point);
               j++;
            }
            i++;
         }
         sectionResult.dispose();
         sectionResult = null;
         capturedImage.removeFromParent(true);
         canvas.removeChildren();
         canvas.dispose();
         for(key in stampMap)
         {
            view = stampMap[key] as StampView;
            dObj = view.getDisplayObject();
            dObj.x = CAPTURED_IMAGE_WIDTH * view.screenPosX;
            dObj.y = CAPTURED_IMAGE_HEIGHT * view.screenPosY;
            dObj.scaleX *= CAPTURED_IMAGE_WIDTH / capturedWidth;
            dObj.scaleY *= CAPTURED_IMAGE_HEIGHT / capturedHeight;
            stampLayer.addChild(dObj);
         }
         return result;
      }
      
      private function setupScrollRender() : void
      {
         renderImage = scrollRenderSprite.getChildByName("capturedImage") as Image;
         renderImage.addEventListener("touch",touchedRenderImage);
         renderImage.touchable = true;
         stampLayer = scrollRenderSprite.getChildByName("stampLayer") as Sprite;
         scrollRenderSprite.verticalScrollBarFactory = function():IScrollBar
         {
            var _loc1_:ScrollBar = new ScrollBar();
            _loc1_.userObject["scene"] = ARScene;
            _loc1_.thumbProperties.alpha = 0.6;
            _loc1_.minimumTrackProperties.alpha = 0.6;
            return _loc1_;
         };
         scrollRenderSprite.scrollBarDisplayMode = "fixedFloat";
         scrollRenderSprite.horizontalScrollPolicy = "off";
         scrollRenderSprite.autoHideBackground = true;
         scrollRenderSprite.hasElasticEdges = false;
         scrollRenderSprite.interactionMode = "touchAndScrollBars";
      }
      
      public function changeScrollEnable(param1:Boolean) : void
      {
         scrollRenderSprite.verticalScrollPolicy = !!param1 ? "on" : "off";
      }
      
      override protected function transitionOpenFinished() : void
      {
         resumeNoticeTutorial(14,noticeTutorialAction,null);
      }
      
      public function noticeTutorialAction(param1:int) : void
      {
         var index:int = param1;
         switch(int(index))
         {
            case 0:
               if(!UserDataWrapper.wrapper.isCompletedTutorial())
               {
                  var guide:GuideTalkPanel = Engine.getGuideTalkPanel();
                  guide.setFinishCallback(function():void
                  {
                     touchable = false;
                     var progress:int = UserDataWrapper.wrapper.getTutorialProgress() + 1;
                     var _loc2_:* = HttpConnector;
                     if(gudetama.net.HttpConnector.mainConnector == null)
                     {
                        gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
                     }
                     gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(203,progress),function(param1:Object):void
                     {
                        var response:Object = param1;
                        GuideTalkPanel.showTutorial(GameSetting.def.guideTalkTable[progress],noticeTutorialAction,getGuideArrowPos,function():void
                        {
                           touchable = true;
                        });
                     });
                  });
                  break;
               }
         }
      }
      
      public function getGuideArrowPos(param1:int) : Vector.<Number>
      {
         var _loc2_:* = undefined;
         switch(int(param1) - 3)
         {
            case 0:
               _loc2_ = GudetamaUtil.getCenterPosAndWHOnEngine(homeBtn);
         }
         return _loc2_;
      }
   }
}

import flash.geom.Point;
import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.compati.StampDef;
import gudetama.engine.TextureCollector;
import gudetama.scene.ar.ARCapturedDialog;
import muku.core.TaskQueue;
import muku.util.StarlingUtil;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.textures.Texture;

class StampView
{
    
   
   private var stampId:int;
   
   private var uniqueId:int;
   
   private var control:ARCapturedDialog;
   
   private var view:Image;
   
   private var editUI:EditUI;
   
   private var screenPosRateX:Number;
   
   private var screenPosRateY:Number;
   
   function StampView(param1:Image)
   {
      super();
      view = param1;
   }
   
   public function dispose() : void
   {
      view.removeFromParent(true);
      control = null;
   }
   
   public function get screenPosX() : Number
   {
      return screenPosRateX;
   }
   
   public function get screenPosY() : Number
   {
      return screenPosRateY;
   }
   
   public function getDisplayObject() : DisplayObject
   {
      return view;
   }
   
   public function getStampID() : int
   {
      return stampId;
   }
   
   public function getUniqueID() : int
   {
      return uniqueId;
   }
   
   public function undo(param1:Object) : void
   {
      if(param1.hasOwnProperty("x") && param1.hasOwnProperty("y"))
      {
         view.x = param1.x;
         view.y = param1.y;
         screenPosRateX = view.x / ARCapturedDialog.CAPTURED_IMAGE_WIDTH;
         screenPosRateY = view.y / ARCapturedDialog.CAPTURED_IMAGE_HEIGHT;
      }
      if(param1.hasOwnProperty("rot"))
      {
         view.rotation = param1.rot;
      }
      if(param1.hasOwnProperty("scale"))
      {
         view.scale = param1.scale;
      }
   }
   
   public function init(param1:ARCapturedDialog, param2:int, param3:int, param4:Function) : void
   {
      var control:ARCapturedDialog = param1;
      var sid:int = param2;
      var uid:int = param3;
      var callback:Function = param4;
      this.control = control;
      stampId = sid;
      uniqueId = uid;
      view.touchable = true;
      view.addEventListener("touch",onTouchTranslate);
      var stampDef:StampDef = GameSetting.getStamp(stampId);
      var queue:TaskQueue = new TaskQueue();
      TextureCollector.loadTextureForTask(queue,GudetamaUtil.getARStampName(stampDef.id#2),function(param1:Texture):void
      {
         view.texture = param1;
         view.readjustSize();
         view.pivotX = param1.width * 0.5;
         view.pivotY = param1.height * 0.5;
      });
      queue.startTask(function(param1:Number):void
      {
         if(param1 < 1)
         {
            return;
         }
         callback();
         control.setSelectedStamp(uniqueId);
      });
   }
   
   public function showGrid(param1:EditUI) : void
   {
      editUI = param1;
      editUI.visible = true;
      editUI.setView(this);
   }
   
   public function hideGrid() : void
   {
      editUI = null;
   }
   
   private function onTouchTranslate(param1:TouchEvent) : void
   {
      var _loc2_:* = null;
      var _loc4_:* = null;
      var _loc3_:Touch = param1.getTouch(view,"began");
      if(_loc3_)
      {
         control.setSelectedStamp(uniqueId);
         control.changeScrollEnable(false);
      }
      _loc3_ = param1.getTouch(view,"moved");
      if(_loc3_)
      {
         _loc2_ = StarlingUtil.getPointFromPool();
         _loc4_ = StarlingUtil.getPointFromPool();
         _loc3_.getLocation(view.parent,_loc2_);
         _loc3_.getPreviousLocation(view.parent,_loc4_);
         view.x += _loc2_.x - _loc4_.x;
         view.y += _loc2_.y - _loc4_.y;
         control.setSelectedStamp(uniqueId);
      }
      _loc3_ = param1.getTouch(view,"ended");
      if(_loc3_)
      {
         screenPosRateX = view.x / ARCapturedDialog.CAPTURED_IMAGE_WIDTH;
         screenPosRateY = view.y / ARCapturedDialog.CAPTURED_IMAGE_HEIGHT;
         control.changeScrollEnable(true);
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
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.StampData;
import gudetama.scene.ar.ARCapturedDialog;
import gudetama.scene.ar.ARExpansionDialog;
import gudetama.scene.ar.ARScene;
import gudetama.scene.ar.ui.ARGudetamaStampItemRenderer;
import gudetama.ui.LocalMessageDialog;
import gudetama.util.SpriteExtractor;
import muku.display.SimpleImageButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;

class StampListManager
{
    
   
   private var control:ARCapturedDialog;
   
   private var ListContainer:Sprite;
   
   private var list:List;
   
   private var collection:ListCollection;
   
   private var plusBtn:SimpleImageButton;
   
   private var placedStampNumText:ColorTextField;
   
   private var currentPlaceNum:int;
   
   private var placeCountMap:Object;
   
   function StampListManager(param1:ARCapturedDialog, param2:Sprite)
   {
      super();
      this.control = param1;
      this.ListContainer = param2;
      list = ListContainer.getChildByName("list") as List;
      (ListContainer.getChildByName("bg_mat") as Image).touchable = true;
      (ListContainer.getChildByName("bar_mat") as Image).touchable = true;
      var _loc3_:Sprite = ListContainer.getChildByName("plusContainer") as Sprite;
      plusBtn = _loc3_.getChildByName("plusBtn") as SimpleImageButton;
      plusBtn.addEventListener("triggered",triggeredGudetamaPlus);
      placedStampNumText = _loc3_.getChildByName("numText") as ColorTextField;
      collection = new ListCollection();
      currentPlaceNum = 0;
      placeCountMap = {};
      updatePlaceNum();
   }
   
   public function setupList(param1:SpriteExtractor) : void
   {
      var extractor:SpriteExtractor = param1;
      var map:Object = UserDataWrapper.stampPart.getStampMap();
      for(key in map)
      {
         var stampData:StampData = map[key] as StampData;
         if(stampData.num > 0)
         {
            placeCountMap[key] = stampData.num;
            collection.push({
               "stampId":key,
               "countMap":placeCountMap
            });
         }
      }
      (collection.data#2 as Array).sort(function(param1:Object, param2:Object):int
      {
         return param1.stampId - param2.stampId;
      });
      var layout:TiledRowsLayout = new TiledRowsLayout();
      layout.verticalAlign = "center";
      layout.horizontalAlign = "left";
      layout.useSquareTiles = false;
      layout.requestedColumnCount = 6;
      layout.horizontalGap = 15;
      layout.verticalGap = 5;
      list.layout = layout;
      list.hasElasticEdges = false;
      list.autoHideBackground = true;
      list.itemRendererFactory = function():IListItemRenderer
      {
         var _loc1_:ARGudetamaStampItemRenderer = new ARGudetamaStampItemRenderer(extractor);
         _loc1_.addEventListener("triggered",triggeredStampItemEvent);
         return _loc1_;
      };
      list.verticalScrollBarFactory = function():IScrollBar
      {
         var _loc1_:ScrollBar = new ScrollBar();
         _loc1_.userObject["scene"] = ARScene;
         return _loc1_;
      };
      list.scrollBarDisplayMode = "fixed";
      list.horizontalScrollPolicy = "off";
      list.interactionMode = "touchAndScrollBars";
      list.dataProvider = collection;
      list.validate();
   }
   
   private function triggeredStampItemEvent(param1:Event) : void
   {
      var event:Event = param1;
      var data:Object = event.data#2;
      if(!data || isAlreadyPlaceMax() || placeCountMap[data.stampId] <= 0)
      {
         return;
      }
      notifyAddedStamp(data.stampId);
      control.createStamp(data.stampId,function(param1:StampView):void
      {
      });
   }
   
   public function notifyAddedStamp(param1:int) : void
   {
      currentPlaceNum++;
      updatePlaceNum();
      placeCountMap[param1]--;
      collection.updateAll();
   }
   
   public function notifyRemovedGudetama(param1:int, param2:Boolean) : void
   {
      if(currentPlaceNum > 0)
      {
         currentPlaceNum--;
      }
      updatePlaceNum();
      placeCountMap[param1]++;
      if(param2)
      {
         if(currentPlaceNum <= 0)
         {
            collection.updateAll();
         }
      }
      else
      {
         collection.updateAll();
      }
   }
   
   private function triggeredGudetamaPlus(param1:Event) : void
   {
      var event:Event = param1;
      var _loc2_:* = UserDataWrapper;
      var maxPlace:int = GameSetting.getRule().placeArStampNumTable[gudetama.data.UserDataWrapper.wrapper._data.placeStampExpansionCount];
      var _loc4_:* = UserDataWrapper;
      if(GameSetting.getRule().placeArStampNumTable.length - 1 <= gudetama.data.UserDataWrapper.wrapper._data.placeStampExpansionCount)
      {
         LocalMessageDialog.show(2,GameSetting.getUIText("ar.stamp.expansion.fullMsg"),null,GameSetting.getUIText("ar.stamp.expansion.title"),68);
         return;
      }
      ARExpansionDialog.show(1,function(param1:Boolean):void
      {
         if(!param1)
         {
            return;
         }
         updatePlaceNum();
      });
   }
   
   private function updatePlaceNum() : void
   {
      var _loc2_:* = UserDataWrapper;
      var _loc1_:int = GameSetting.getRule().placeArStampNumTable[gudetama.data.UserDataWrapper.wrapper._data.placeStampExpansionCount];
      placedStampNumText.text#2 = currentPlaceNum.toString() + "/" + _loc1_.toString();
   }
   
   private function isAlreadyPlaceMax() : Boolean
   {
      var _loc2_:* = UserDataWrapper;
      var _loc1_:int = GameSetting.getRule().placeArStampNumTable[gudetama.data.UserDataWrapper.wrapper._data.placeStampExpansionCount];
      return currentPlaceNum >= _loc1_;
   }
}

import flash.geom.Point;
import gudetama.scene.ar.ARCapturedDialog;
import muku.display.SimpleImageButton;
import muku.util.StarlingUtil;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.utils.MathUtil;

class EditUI
{
    
   
   private var control:ARCapturedDialog;
   
   private var displaySprite:Sprite;
   
   private var frame:Image;
   
   private var removeBtn:SimpleImageButton;
   
   private var ctrlLeftTopBtn:Quad;
   
   private var ctrlLeftBottomBtn:Quad;
   
   private var ctrlRightBottomBtn:Quad;
   
   private var view:StampView;
   
   function EditUI(param1:ARCapturedDialog, param2:Sprite)
   {
      super();
      this.control = param1;
      displaySprite = param2;
      frame = displaySprite.getChildByName("frame") as Image;
      removeBtn = displaySprite.getChildByName("removeBtn") as SimpleImageButton;
      removeBtn.setStopPropagation(true);
      removeBtn.addEventListener("triggered",triggeredRemoveBtn);
      ctrlLeftTopBtn = displaySprite.getChildByName("ctrlLeftTopBtn") as Quad;
      ctrlLeftTopBtn.touchable = true;
      ctrlLeftTopBtn.addEventListener("touch",touchedCtrlBtn);
      ctrlLeftBottomBtn = displaySprite.getChildByName("ctrlLeftBottomBtn") as Quad;
      ctrlLeftBottomBtn.touchable = true;
      ctrlLeftBottomBtn.addEventListener("touch",touchedCtrlBtn);
      ctrlRightBottomBtn = displaySprite.getChildByName("ctrlRightBottomBtn") as Quad;
      ctrlRightBottomBtn.touchable = true;
      ctrlRightBottomBtn.addEventListener("touch",touchedCtrlBtn);
      displaySprite.addEventListener("enterFrame",update);
   }
   
   public function set visible(param1:Boolean) : void
   {
      displaySprite.visible = param1;
   }
   
   public function setView(param1:StampView) : void
   {
      view = param1;
   }
   
   public function update() : void
   {
      if(!displaySprite.visible)
      {
         return;
      }
      var _loc2_:DisplayObject = view.getDisplayObject();
      var _loc1_:Number = _loc2_.width;
      var _loc3_:Number = _loc2_.height;
      frame.width = _loc1_ + 60;
      frame.height = _loc3_ + 60;
      removeBtn.x = _loc1_ + 40;
      removeBtn.y = 20;
      ctrlLeftTopBtn.x = 30;
      ctrlLeftTopBtn.y = 30;
      ctrlLeftBottomBtn.x = 30;
      ctrlLeftBottomBtn.y = _loc3_ + 30;
      ctrlRightBottomBtn.x = _loc1_ + 30;
      ctrlRightBottomBtn.y = _loc3_ + 30;
      displaySprite.x = _loc2_.x;
      displaySprite.y = _loc2_.y;
      displaySprite.pivotX = frame.width * 0.5;
      displaySprite.pivotY = frame.height * 0.5;
      displaySprite.rotation = _loc2_.rotation;
   }
   
   private function triggeredRemoveBtn(param1:Event) : void
   {
      control.removeStamp(view.getUniqueID());
      visible = false;
   }
   
   private function touchedCtrlBtn(param1:TouchEvent) : void
   {
      var _loc8_:* = null;
      var _loc11_:* = null;
      var _loc10_:* = null;
      var _loc4_:* = null;
      var _loc6_:* = null;
      var _loc9_:Number = NaN;
      var _loc5_:* = null;
      var _loc3_:Number = NaN;
      var _loc7_:Number = NaN;
      param1.stopPropagation();
      var _loc2_:Quad = param1.target as Quad;
      if(_loc8_ = param1.getTouch(_loc2_,"began"))
      {
         control.changeScrollEnable(false);
      }
      if(_loc8_ = param1.getTouch(_loc2_,"moved"))
      {
         _loc11_ = view.getDisplayObject();
         (_loc10_ = StarlingUtil.getPointFromPool()).setTo(_loc11_.x,_loc11_.y);
         _loc4_ = StarlingUtil.getPointFromPool();
         _loc8_.getLocation(_loc11_.parent,_loc4_);
         _loc6_ = _loc4_.subtract(_loc10_);
         _loc9_ = Math.atan2(_loc6_.y,_loc6_.x);
         _loc5_ = StarlingUtil.getPointFromPool();
         _loc8_.getPreviousLocation(_loc11_.parent,_loc5_);
         _loc6_ = _loc5_.subtract(_loc10_);
         _loc9_ -= Math.atan2(_loc6_.y,_loc6_.x);
         _loc11_.rotation += _loc9_;
         _loc3_ = StarlingUtil.distance(_loc10_.x,_loc10_.y,_loc4_.x,_loc4_.y);
         _loc7_ = StarlingUtil.distance(_loc10_.x,_loc10_.y,_loc5_.x,_loc5_.y);
         _loc11_.scale = MathUtil.clamp(_loc11_.scale + (_loc3_ - _loc7_) * 0.01,0.2,3);
         control.setSelectedStamp(view.getUniqueID());
      }
      if(_loc8_ = param1.getTouch(_loc2_,"ended"))
      {
         control.changeScrollEnable(true);
      }
   }
}
