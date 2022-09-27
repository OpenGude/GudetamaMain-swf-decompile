package gudetama.util
{
   import flash.display.BitmapData;
   import flash.filters.GlowFilter;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import muku.display.Particle;
   import starling.core.Starling;
   import starling.display.Button;
   import starling.display.DisplayObject;
   import starling.display.DisplayObjectContainer;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.display.Stage;
   import starling.rendering.Painter;
   import starling.text.TextField;
   import starling.textures.RenderTexture;
   import starling.textures.Texture;
   
   public final class ImageUtil
   {
       
      
      public function ImageUtil()
      {
         super();
      }
      
      public static function copyAsBitmapData(param1:DisplayObject, param2:int, param3:int) : BitmapData
      {
         var _loc7_:Rectangle = param1.getBounds(param1);
         var _loc8_:* = Starling;
         var _loc9_:* = Starling;
         var _loc4_:BitmapData = new BitmapData(_loc7_.width * (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent.contentScaleFactor : 1),_loc7_.height * (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent.contentScaleFactor : 1),true);
         var _loc10_:* = Starling;
         var _loc6_:Stage = starling.core.Starling.sCurrent.stage;
         var _loc11_:* = Starling;
         var _loc5_:Painter;
         (_loc5_ = starling.core.Starling.sCurrent.painter).pushState();
         _loc5_.state.renderTarget = null;
         _loc5_.state.setProjectionMatrix(_loc7_.x,_loc7_.y,_loc6_.stageWidth,_loc6_.stageHeight,_loc6_.stageWidth,_loc6_.stageHeight,_loc6_.cameraPosition);
         _loc5_.clear();
         param1.setRequiresRedraw();
         param1.render(_loc5_);
         _loc5_.finishMeshBatch();
         _loc5_.context.drawToBitmapData(_loc4_);
         _loc5_.popState();
         return _loc4_;
      }
      
      public static function renderDrawCache(param1:Painter, param2:Number, param3:Image, param4:Array) : void
      {
         var _loc7_:int = 0;
         var _loc6_:* = null;
         param3.render(param1);
         if(!param4 || param4.length <= 0)
         {
            return;
         }
         var _loc5_:int = param4.length;
         _loc7_ = 0;
         while(_loc7_ < _loc5_)
         {
            if((_loc6_ = param4[_loc7_]).obj.visible)
            {
               param1.pushState();
               param1.setStateTo(_loc6_.matrix,_loc6_.alpha * param2);
               _loc6_.obj.setRequiresRedraw();
               _loc6_.obj.render(param1);
               param1.popState();
            }
            _loc7_++;
         }
      }
      
      public static function convertToBitmapData(param1:DisplayObject, param2:int = 0, param3:int = 0, param4:Array = null) : BitmapData
      {
         var sprite:DisplayObject = param1;
         var width:int = param2;
         var height:int = param3;
         var dynamics:Array = param4;
         var _hideDynamics:* = function(param1:DisplayObject, param2:Number, param3:Array):void
         {
            var _loc8_:int = 0;
            var _loc4_:* = null;
            var _loc7_:Boolean = false;
            if(!(param1 is DisplayObjectContainer))
            {
               return;
            }
            var _loc5_:DisplayObjectContainer = param1 as DisplayObjectContainer;
            var _loc6_:Matrix = new Matrix();
            _loc8_ = 0;
            while(_loc8_ < _loc5_.numChildren)
            {
               _loc7_ = (_loc4_ = _loc5_.getChildAt(_loc8_)).visible;
               if(_loc4_.dynamic)
               {
                  _loc4_.visible = false;
                  if(param3)
                  {
                     param3.push({
                        "obj":_loc4_,
                        "preState":_loc7_,
                        "alpha":param2 * _loc4_.alpha,
                        "matrix":_loc4_.getTransformationMatrix(sprite,new Matrix())
                     });
                  }
               }
               else if(_loc4_ is Button || _loc4_ is Particle)
               {
                  _loc4_.visible = false;
                  if(param3)
                  {
                     param3.push({
                        "obj":_loc4_,
                        "preState":_loc7_,
                        "alpha":param2 * _loc4_.alpha,
                        "matrix":_loc4_.getTransformationMatrix(sprite,new Matrix())
                     });
                  }
               }
               else if(!(_loc4_ is TextField || _loc4_ is Image))
               {
                  if(_loc4_ is DisplayObjectContainer)
                  {
                     _hideDynamics(_loc4_ as DisplayObjectContainer,param2 * _loc4_.alpha,param3);
                  }
               }
               _loc8_++;
            }
         };
         var hideDynamics:* = function(param1:DisplayObject, param2:Array):DisplayObject
         {
            _hideDynamics(param1,param1.alpha,param2);
            return param1;
         };
         var _showDynamics:* = function(param1:DisplayObject):void
         {
            var _loc4_:int = 0;
            var _loc2_:* = null;
            if(!(param1 is DisplayObjectContainer))
            {
               return;
            }
            var _loc3_:DisplayObjectContainer = param1 as DisplayObjectContainer;
            _loc4_ = 0;
            while(_loc4_ < _loc3_.numChildren)
            {
               _loc2_ = _loc3_.getChildAt(_loc4_);
               if(!_loc2_.dynamic)
               {
                  if(_loc2_ is Button || _loc2_ is Particle)
                  {
                     _loc2_.visible = true;
                  }
                  else if(!(_loc2_ is Image))
                  {
                     if(_loc2_ is DisplayObjectContainer)
                     {
                        _showDynamics(_loc2_ as DisplayObjectContainer);
                     }
                  }
               }
               _loc4_++;
            }
         };
         var showDynamics:* = function(param1:DisplayObject, param2:Array):DisplayObject
         {
            var _loc3_:int = 0;
            var _loc4_:int = 0;
            if(param2)
            {
               _loc3_ = param2.length;
               _loc4_ = 0;
               while(_loc4_ < _loc3_)
               {
                  param2[_loc4_].obj.visible = param2[_loc4_].preState;
                  _loc4_++;
               }
            }
            else
            {
               _showDynamics(param1);
            }
            return param1;
         };
         var buildBitmapData:* = function(param1:DisplayObject, param2:int, param3:int, param4:Array):BitmapData
         {
            hideDynamics(param1,param4);
            var _loc5_:BitmapData = copyAsBitmapData(param1,param2,param3);
            showDynamics(param1,param4);
            return _loc5_;
         };
         if(width <= 0)
         {
            var width:int = sprite.width;
         }
         if(height <= 0)
         {
            var height:int = sprite.height;
         }
         return buildBitmapData(sprite,width,height,dynamics);
      }
      
      private static function _renderToTexture(param1:RenderTexture, param2:Array) : void
      {
         var _loc3_:* = 0;
         _loc3_ = uint(0);
         while(_loc3_ < param2.length)
         {
            param1.draw(param2[_loc3_]);
            _loc3_++;
         }
      }
      
      public static function renderToTexture(param1:int, param2:int, ... rest) : Texture
      {
         var _loc4_:RenderTexture = new RenderTexture(param1,param2);
         _renderToTexture(_loc4_,rest);
         return _loc4_;
      }
      
      public static function convertToTexture(param1:Sprite, param2:int = 0, param3:int = 0) : Sprite
      {
         var sprite:Sprite = param1;
         var width:int = param2;
         var height:int = param3;
         var _hideDynamics:* = function(param1:Sprite, param2:Array):void
         {
            var _loc4_:int = 0;
            var _loc3_:* = null;
            _loc4_ = 0;
            while(_loc4_ < param1.numChildren)
            {
               _loc3_ = param1.getChildAt(_loc4_);
               if(_loc3_.dynamic)
               {
                  _loc3_.visible = false;
                  if(param2)
                  {
                     param2.push(_loc3_);
                  }
               }
               else if(_loc3_ is Button || _loc3_ is Particle)
               {
                  _loc3_.visible = false;
                  if(param2)
                  {
                     param2.push(_loc3_);
                  }
               }
               else if(!(_loc3_ is TextField || _loc3_ is Image || (_loc3_ as Image).scale9Grid != null))
               {
                  if(_loc3_ is Sprite)
                  {
                     _hideDynamics(_loc3_ as Sprite,param2);
                  }
               }
               _loc4_++;
            }
         };
         var hideDynamics:* = function(param1:Sprite, param2:Array):Sprite
         {
            _hideDynamics(param1,param2);
            return param1;
         };
         var _showDynamics:* = function(param1:Sprite):void
         {
            var _loc3_:int = 0;
            var _loc2_:* = null;
            _loc3_ = 0;
            while(_loc3_ < param1.numChildren)
            {
               _loc2_ = param1.getChildAt(_loc3_);
               if(_loc2_.dynamic)
               {
                  _loc2_.visible = true;
               }
               else if(_loc2_ is Button || _loc2_ is Particle)
               {
                  _loc2_.visible = true;
               }
               else if(!(_loc2_ is Image))
               {
                  if(_loc2_ is Sprite)
                  {
                     _showDynamics(_loc2_ as Sprite);
                  }
               }
               _loc3_++;
            }
         };
         var showDynamics:* = function(param1:Sprite, param2:Array):Sprite
         {
            var _loc3_:int = 0;
            var _loc4_:int = 0;
            if(param2)
            {
               _loc3_ = param2.length;
               _loc4_ = 0;
               while(_loc4_ < _loc3_)
               {
                  param2[_loc4_].visible = true;
                  _loc4_++;
               }
            }
            else
            {
               _showDynamics(param1);
            }
            return param1;
         };
         var buildTexture:* = function(param1:Sprite, param2:RenderTexture, param3:Array):void
         {
            hideDynamics(param1,param3);
            param2.draw(param1);
            showDynamics(param1,param3);
         };
         if(width <= 0)
         {
            var _loc4_:* = Starling;
            var width:int = starling.core.Starling.sCurrent.stage.stageWidth;
         }
         if(height <= 0)
         {
            var _loc6_:* = Starling;
            var height:int = starling.core.Starling.sCurrent.stage.stageHeight;
         }
         var dynamics:Array = [];
         var target:RenderTexture = new RenderTexture(width,height);
         target.root.onRestore(function():void
         {
            target.clear();
            buildTexture(sprite,target,null);
         });
         buildTexture(sprite,target,dynamics);
         var targetImage:Image = new Image(target);
         var result:Sprite = new Sprite();
         result.addChild(targetImage);
         var localPoint:Point = new Point(0,0);
         var globalPoint:Point = new Point(0,0);
         for each(c in dynamics)
         {
            localPoint.x = 0;
            localPoint.y = 0;
            c.localToGlobal(localPoint,globalPoint);
            c.x = globalPoint.x;
            c.y = globalPoint.y;
            result.addChild(c);
         }
         return result;
      }
      
      public static function makeOutlineFilterBitmapData(param1:BitmapData, param2:uint, param3:Number, param4:Number, param5:Number, param6:uint = 16777215, param7:Number = 1.0, param8:Number = 8, param9:Number = 10) : BitmapData
      {
         var _loc13_:Number = param1.width;
         var _loc14_:Number = param1.height;
         var _loc10_:Point = new Point();
         var _loc12_:Rectangle = new Rectangle(0,0,_loc13_,_loc14_);
         var _loc11_:BitmapData;
         (_loc11_ = new BitmapData(_loc13_,_loc14_)).applyFilter(param1,_loc12_,_loc10_,new GlowFilter(param6,param7,param8,param8,param9));
         _loc11_.applyFilter(_loc11_,_loc12_,_loc10_,new GlowFilter(param2,param3,param4,param4,param5));
         return _loc11_;
      }
   }
}
