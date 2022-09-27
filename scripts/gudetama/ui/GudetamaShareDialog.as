package gudetama.ui
{
   import flash.display.BitmapData;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import gudetama.common.BannerAdvertisingManager;
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.compati.GudetamaDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.SoundManager;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.scene.ar.SnsShareDialog;
   import muku.core.TaskQueue;
   import muku.display.ManuallySpineButton;
   import muku.text.ColorTextField;
   import muku.util.StarlingUtil;
   import starling.core.Starling;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Touch;
   import starling.rendering.Painter;
   import starling.textures.Texture;
   
   public class GudetamaShareDialog extends BaseScene
   {
       
      
      protected var gudetamaDef:GudetamaDef;
      
      protected var bg:Image;
      
      protected var gudetamaSpine:ManuallySpineButton;
      
      protected var infoSprite:Sprite;
      
      protected var infoSprite1:Sprite;
      
      private var copyRightSprite:Sprite;
      
      private var titleLogoImage:Image;
      
      private var togeImage:Image;
      
      private var itemImage:Image;
      
      private var fromGacha:Boolean;
      
      private var gotItem:Boolean;
      
      private var itemId:int;
      
      private var itemKind:int;
      
      private var name:String;
      
      private var desc:String;
      
      public function GudetamaShareDialog(param1:Array, param2:Boolean = false)
      {
         super(1);
         this.fromGacha = param2;
         if(param2)
         {
            itemId = param1[0];
            itemKind = param1[1];
            if(itemKind == 6)
            {
               gudetamaDef = GameSetting.getGudetama(param1[0]);
            }
            else
            {
               gotItem = true;
            }
         }
         else
         {
            gudetamaDef = GameSetting.getGudetama(param1[0]);
         }
         if(gudetamaDef)
         {
            name = gudetamaDef.name#2;
            desc = gudetamaDef.desc;
         }
         else
         {
            name = GudetamaUtil.getItemName(itemKind,itemId);
            desc = GudetamaUtil.getItemDesc(itemKind,itemId);
         }
         BannerAdvertisingManager.visibleBanner(false);
      }
      
      public static function show(param1:Array) : void
      {
         Engine.pushScene(new GudetamaShareDialog(param1));
      }
      
      public static function showFromGacha(param1:Array) : void
      {
         Engine.pushScene(new GudetamaShareDialog(param1,true),1);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         Engine.removeTouchStageCallback(touchedStage);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         var preQueue:TaskQueue = new TaskQueue();
         loadLayout(preQueue);
         preQueue.startTask(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            setup(onProgress);
         });
      }
      
      protected function loadLayout(param1:TaskQueue) : void
      {
         var queue:TaskQueue = param1;
         Engine.setupLayoutForTask(queue,"GudetamaShareDialogLayout",function(param1:Object):void
         {
            var layout:Object = param1;
            displaySprite = layout.object as Sprite;
            bg = displaySprite.getChildByName("bg") as Image;
            infoSprite = displaySprite.getChildByName("infoSprite") as Sprite;
            var nameText:ColorTextField = infoSprite.getChildByName("name") as ColorTextField;
            nameText.text#2 = name;
            var info:ColorTextField = infoSprite.getChildByName("info") as ColorTextField;
            info.text#2 = desc;
            infoSprite1 = displaySprite.getChildByName("infoSprite1") as Sprite;
            var nameText1:ColorTextField = infoSprite1.getChildByName("name") as ColorTextField;
            nameText1.text#2 = name;
            var info1:ColorTextField = infoSprite1.getChildByName("info") as ColorTextField;
            info1.text#2 = desc;
            gudetamaSpine = displaySprite.getChildByName("gudetama") as ManuallySpineButton;
            gudetamaSpine.touchable = false;
            copyRightSprite = displaySprite.getChildByName("copyRight") as Sprite;
            titleLogoImage = displaySprite.getChildByName("titleLogo") as Image;
            togeImage = displaySprite.getChildByName("toge") as Image;
            itemImage = displaySprite.getChildByName("item") as Image;
            if(fromGacha)
            {
               TextureCollector.loadTexture("gacha1@titlelogo",function(param1:Texture):void
               {
                  titleLogoImage.texture = param1;
               });
               TextureCollector.loadTexture("gacha1@toge",function(param1:Texture):void
               {
                  togeImage.texture = param1;
               });
               if(gotItem)
               {
                  gudetamaSpine.visible = false;
                  itemImage.visible = true;
                  TextureCollector.loadTexture(GudetamaUtil.getItemImageName(itemKind,itemId),function(param1:Texture):void
                  {
                     itemImage.texture = param1;
                  });
               }
               else
               {
                  itemImage.visible = false;
                  gudetamaSpine.visible = true;
               }
               copyRightSprite.visible = true;
               info.fontSize = 24;
               info.format.leading = 18;
               info.validate();
            }
            else
            {
               titleLogoImage.visible = false;
               togeImage.visible = false;
               itemImage.visible = false;
               copyRightSprite.visible = false;
            }
            displaySprite.visible = false;
            addChild(displaySprite);
         });
      }
      
      protected function setup(param1:Function) : void
      {
         var onProgress:Function = param1;
         SoundManager.playEffect("capture");
         if(fromGacha)
         {
            if(gotItem)
            {
               TextureCollector.loadTextureForTask(queue,"bg-background_gacha4",function(param1:Texture):void
               {
                  bg.texture = param1;
                  bg.readjustSize();
               });
            }
            else
            {
               gudetamaSpine.setup(queue,gudetamaDef.id#2);
               TextureCollector.loadTextureForTask(queue,"bg-background_gacha2",function(param1:Texture):void
               {
                  bg.texture = param1;
                  bg.readjustSize();
               });
            }
            infoSprite.visible = true;
            infoSprite1.visible = false;
         }
         else
         {
            gudetamaSpine.setup(queue,gudetamaDef.id#2);
            var randomBgIdx:int = Math.min(Math.ceil(Math.random() * 4),4);
            TextureCollector.loadTextureForTask(queue,"bg-background_share" + randomBgIdx,function(param1:Texture):void
            {
               bg.texture = param1;
               bg.readjustSize();
            });
            if(randomBgIdx == 4)
            {
               infoSprite.visible = true;
               infoSprite1.visible = false;
            }
            else
            {
               infoSprite.visible = false;
               infoSprite1.visible = true;
            }
         }
         queue.startTask(onProgress);
      }
      
      override protected function addedToContainer() : void
      {
         setBackButtonCallback(backButtonCallback);
         setVisibleState(1);
         BannerAdvertisingManager.hideAllBanner();
         displaySprite.visible = true;
         Engine.addTouchStageCallback(touchedStage);
         if(fromGacha)
         {
            TweenAnimator.startItself(displaySprite,"fromGacha");
         }
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         setBackButtonCallback(null);
         Engine.popScene(scene);
      }
      
      protected function touchedStage(param1:Touch) : void
      {
         var touch:Touch = param1;
         if(touch.phase == "ended")
         {
            Engine.removeTouchStageCallback(touchedStage);
            SnsShareDialog.show(processCapturedComposition(),getShareType(),false,function():void
            {
               backButtonCallback();
            },getShareOptionMessage(),!!gudetamaDef ? gudetamaDef.id#2 : 0);
         }
      }
      
      protected function getShareType() : int
      {
         return 4;
      }
      
      protected function getShareOptionMessage() : String
      {
         return null;
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
