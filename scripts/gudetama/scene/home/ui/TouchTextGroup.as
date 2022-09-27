package gudetama.scene.home.ui
{
   import flash.geom.Rectangle;
   import gudetama.data.GameSetting;
   import gudetama.data.compati.GudetamaDef;
   import gudetama.engine.TextureCollector;
   import gudetama.util.SpriteExtractor;
   import muku.core.TaskQueue;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.textures.Texture;
   
   public class TouchTextGroup
   {
      
      private static const MARGIN:int = 100;
       
      
      private var displaySprite:Sprite;
      
      private var extractor:SpriteExtractor;
      
      private var quad:Quad;
      
      private var exclusiveQuad:Quad;
      
      private var touchTextParams:Array;
      
      private var rubTextParams:Array;
      
      private var pool:Vector.<TouchTextUI>;
      
      private var using:Vector.<TouchTextUI>;
      
      private var exclusiveBounds:Rectangle;
      
      private var exclusiveCenterX:Number;
      
      private var exclusiveCenterY:Number;
      
      private var exclusiveCircleLength:Number;
      
      private var displayCount:int = 0;
      
      public function TouchTextGroup(param1:Sprite)
      {
         pool = new Vector.<TouchTextUI>(0);
         using = new Vector.<TouchTextUI>(0);
         super();
         this.displaySprite = param1;
         this.extractor = extractor;
         quad = param1.getChildByName("quad") as Quad;
         exclusiveQuad = param1.getChildByName("exclusive") as Quad;
      }
      
      public function setup(param1:TaskQueue, param2:int, param3:SpriteExtractor, param4:Rectangle) : void
      {
         var _loc7_:int = 0;
         this.extractor = param3;
         var _loc6_:GudetamaDef;
         if((_loc6_ = GameSetting.getGudetama(param2)).touchTextParams)
         {
            for each(var _loc5_ in _loc6_.touchTextParams)
            {
               for each(_loc7_ in _loc5_)
               {
                  preloadTexture(param1,"home1@touch0_" + _loc7_);
               }
            }
            touchTextParams = _loc6_.touchTextParams;
         }
         if(_loc6_.rubTextParams)
         {
            for each(var _loc8_ in _loc6_.rubTextParams)
            {
               for each(_loc7_ in _loc8_)
               {
                  preloadTexture(param1,"home1@touch0_" + _loc7_);
               }
            }
            rubTextParams = _loc6_.rubTextParams;
         }
         updateRect(param4);
      }
      
      private function preloadTexture(param1:TaskQueue, param2:String) : void
      {
         var queue:TaskQueue = param1;
         var name:String = param2;
         TextureCollector.loadTextureForTask(queue,name,function(param1:Texture):void
         {
         });
      }
      
      public function updateRect(param1:Rectangle) : void
      {
         displaySprite.y = param1.y - 100;
         quad.height = param1.height + 100;
         exclusiveQuad.y = displaySprite.height;
         exclusiveBounds = exclusiveQuad.bounds;
         exclusiveCenterX = exclusiveBounds.x + 0.5 * exclusiveBounds.width;
         exclusiveCenterY = exclusiveBounds.y + 0.5 * exclusiveBounds.height;
         exclusiveCircleLength = Math.sqrt(Math.pow(exclusiveCenterY - exclusiveBounds.y,2) + Math.pow(exclusiveCenterX - exclusiveBounds.x,2));
      }
      
      public function show(param1:Boolean = false) : void
      {
         var isRub:Boolean = param1;
         if(pool.length)
         {
            var ui:TouchTextUI = pool.pop();
         }
         else
         {
            ui = new TouchTextUI(extractor.duplicateAll() as Sprite);
         }
         using.push(ui);
         if(!isRub)
         {
            if(touchTextParams)
            {
               var touchTextParam:Array = touchTextParams[0];
               var name:String = "home1@touch0_" + touchTextParam[int(Math.random() * touchTextParam.length)];
            }
         }
         else if(rubTextParams)
         {
            var rubTextParam:Array = rubTextParams[0];
            name = "home1@touch0_" + rubTextParam[int(Math.random() * rubTextParam.length)];
         }
         var x:Number = quad.width * Math.random();
         var y:Number = quad.height * Math.random();
         if(exclusiveBounds.contains(x,y))
         {
            var radian:Number = Math.atan2(y - exclusiveCenterY,x - exclusiveCenterX);
            var length:Number = Math.sqrt(Math.pow(exclusiveCenterY - y,2) + Math.pow(exclusiveCenterX - x,2));
            var x:Number = x + (exclusiveCircleLength - length) * Math.cos(radian);
            var y:Number = y + (exclusiveCircleLength - length) * Math.sin(radian);
         }
         displayCount++;
         ui.show(name,x,y,function():void
         {
            pool.push(ui);
            using.removeAt(using.indexOf(ui));
            displaySprite.removeChild(ui.getDisplaySprite());
            displayCount--;
         });
         displaySprite.addChild(ui.getDisplaySprite());
      }
      
      public function isShow() : Boolean
      {
         return displayCount > 0;
      }
      
      public function setScale(param1:Number) : void
      {
         displaySprite.scale = param1;
      }
      
      public function dispose() : void
      {
         var _loc1_:* = null;
         displaySprite = null;
         extractor = null;
         quad = null;
         exclusiveQuad = null;
         for each(_loc1_ in pool)
         {
            _loc1_.dispose();
         }
         pool.length = 0;
         pool = null;
         for each(_loc1_ in using)
         {
            _loc1_.dispose();
         }
         using.length = 0;
         using = null;
      }
   }
}

import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

class TouchTextUI extends UIBase
{
    
   
   private var image:Image;
   
   function TouchTextUI(param1:Sprite)
   {
      super(param1);
      image = param1.getChildByName("image") as Image;
   }
   
   public function show(param1:String, param2:Number, param3:Number, param4:Function) : void
   {
      var name:String = param1;
      var x:Number = param2;
      var y:Number = param3;
      var callback:Function = param4;
      displaySprite.x = x;
      displaySprite.y = y;
      displaySprite.rotation = 0.6 * Math.random() - 0.3;
      if(name)
      {
         TextureCollector.loadTexture(name,function(param1:Texture):void
         {
            if(image != null)
            {
               image.texture = param1;
            }
         });
      }
      startTween("show",false,function():void
      {
         callback();
      });
   }
   
   public function dispose() : void
   {
      image = null;
   }
}
