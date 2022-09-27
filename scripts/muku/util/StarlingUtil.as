package muku.util
{
   import feathers.controls.Scroller;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import muku.core.MukuGlobal;
   import starling.display.DisplayObject;
   import starling.display.DisplayObjectContainer;
   
   public final class StarlingUtil
   {
      
      public static var radDeg:Number = 57.29577951308232;
      
      public static var degRad:Number = 0.017453292519943295;
      
      private static const POINT_POOL_MAX:int = 25;
      
      private static const RECTANGLE_POOL_MAX:int = 15;
      
      private static var pointPool:Vector.<Point> = new Vector.<Point>(25,true);
      
      private static var pointIndex:int;
      
      private static var rectanglePool:Vector.<Rectangle> = new Vector.<Rectangle>(15,true);
      
      private static var rectangleIndex:int;
      
      {
         staticInit();
      }
      
      public function StarlingUtil()
      {
         super();
      }
      
      public static function find(param1:DisplayObjectContainer, param2:String) : DisplayObject
      {
         var _loc5_:* = null;
         var _loc4_:int = 0;
         var _loc3_:* = null;
         var _loc6_:int = param1.numChildren;
         _loc4_ = 0;
         while(_loc4_ < _loc6_)
         {
            if((_loc5_ = param1.getChildAt(_loc4_)).name#2 == param2)
            {
               return _loc5_;
            }
            if(_loc5_ is DisplayObjectContainer)
            {
               _loc3_ = find(_loc5_ as DisplayObjectContainer,param2);
               if(_loc3_)
               {
                  return _loc3_;
               }
            }
            _loc4_++;
         }
         return null;
      }
      
      public static function moveChildToFront(param1:DisplayObject) : void
      {
         var _loc2_:DisplayObjectContainer = param1.parent;
         _loc2_.setChildIndex(param1,_loc2_.numChildren - 1);
      }
      
      private static function staticInit() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < 25)
         {
            pointPool[_loc1_] = new Point();
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < 15)
         {
            rectanglePool[_loc1_] = new Rectangle();
            _loc1_++;
         }
      }
      
      public static function getPointFromPool() : Point
      {
         var _loc1_:Point = pointPool[pointIndex];
         pointIndex = (pointIndex + 1) % pointPool.length;
         return _loc1_;
      }
      
      public static function getRectangleFromPool() : Rectangle
      {
         var _loc1_:Rectangle = rectanglePool[rectangleIndex];
         rectangleIndex = (rectangleIndex + 1) % rectanglePool.length;
         return _loc1_;
      }
      
      public static function getCoordGlobal(param1:DisplayObject, param2:int = 0, param3:int = 0) : Point
      {
         var _loc4_:Point;
         (_loc4_ = getPointFromPool()).setTo(param2,param3);
         return param1.localToGlobal(_loc4_,getPointFromPool());
      }
      
      public static function getCoordLocal(param1:DisplayObject, param2:int = 0, param3:int = 0) : Point
      {
         var _loc4_:Point;
         (_loc4_ = getPointFromPool()).setTo(param2,param3);
         return param1.globalToLocal(_loc4_,getPointFromPool());
      }
      
      public static function getBounds(param1:DisplayObject, param2:DisplayObject) : Rectangle
      {
         var _loc3_:Rectangle = getRectangleFromPool();
         return param1.getBounds(param2,_loc3_);
      }
      
      public static function getCenter(param1:DisplayObject, param2:DisplayObject) : Point
      {
         var _loc3_:Rectangle = getBounds(param1,param2);
         var _loc4_:Point;
         (_loc4_ = getPointFromPool()).setTo(_loc3_.x + _loc3_.width / 2,_loc3_.y + _loc3_.height / 2);
         return _loc4_;
      }
      
      public static function reviseInBounds(param1:DisplayObject, param2:DisplayObject = null) : void
      {
         var _loc7_:* = null;
         var _loc5_:* = null;
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         if(param2 != null)
         {
            _loc5_ = getBounds(param2,param2.root);
            _loc7_ = getBounds(param1,param2);
         }
         else
         {
            _loc5_ = MukuGlobal.engine.getSceneBounds();
            _loc7_ = getBounds(param1,param1.root);
         }
         var _loc6_:int;
         if((_loc6_ = _loc5_.left - _loc7_.left) > 0)
         {
            param1.x += _loc6_;
         }
         else if((_loc4_ = _loc5_.right - _loc7_.right) < 0)
         {
            param1.x += _loc4_;
         }
         var _loc8_:int;
         if((_loc8_ = _loc5_.top - _loc7_.top) > 0)
         {
            param1.y += _loc8_;
         }
         else
         {
            _loc3_ = _loc5_.bottom - _loc7_.bottom;
            if(_loc3_ < 0)
            {
               param1.y += _loc3_;
            }
         }
      }
      
      public static function countChildren(param1:DisplayObject) : int
      {
         var _loc3_:int = 0;
         var _loc5_:int = 0;
         var _loc4_:int = 1;
         var _loc2_:DisplayObjectContainer = param1 as DisplayObjectContainer;
         if(_loc2_)
         {
            _loc3_ = _loc2_.numChildren;
            _loc5_ = 0;
            while(_loc5_ < _loc3_)
            {
               _loc4_ += countChildren(_loc2_.getChildAt(_loc5_));
               _loc5_++;
            }
         }
         return _loc4_;
      }
      
      public static function absForInt(param1:int) : int
      {
         return (param1 ^ param1 >> 31) - (param1 >> 31);
      }
      
      public static function bitCount(param1:int) : int
      {
         param1 -= param1 >>> 1 & 1431655765;
         param1 = int((param1 & 858993459) + (param1 >>> 2 & 858993459));
         param1 = param1 + (param1 >>> 4) & 252645135;
         param1 += param1 >>> 8;
         param1 += param1 >>> 16;
         return param1 & 63;
      }
      
      public static function safeDispose(param1:DisplayObject) : Boolean
      {
         if(!param1)
         {
            return false;
         }
         param1.dispose();
         return true;
      }
      
      public static function findParentScroller(param1:DisplayObject) : DisplayObject
      {
         while(param1)
         {
            if(param1 is Scroller)
            {
               return param1;
            }
            param1 = param1.parent;
         }
         return null;
      }
      
      public static function compareSeq(param1:Array, param2:Array) : int
      {
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         if(param1 == null || param1.length == 0)
         {
            if(param2 == null || param2.length == 0)
            {
               return 0;
            }
            return -1;
         }
         if(param2 == null || param2.length == 0)
         {
            return 1;
         }
         var _loc5_:int = param1.length - 4;
         var _loc6_:int = param2.length - 4;
         while(_loc5_ < param1.length)
         {
            if(_loc5_ < 0)
            {
               if(_loc6_ >= 0 && param2[_loc6_] != 0)
               {
                  return -1;
               }
            }
            else if(_loc6_ < 0)
            {
               if(_loc5_ >= 0 && param1[_loc5_] != 0)
               {
                  return 1;
               }
            }
            else
            {
               if((_loc4_ = param1[_loc5_]) < 0)
               {
                  _loc4_ += 65536;
               }
               _loc3_ = param2[_loc6_];
               if(_loc3_ < 0)
               {
                  _loc3_ += 65536;
               }
               if(_loc4_ < _loc3_)
               {
                  return -1;
               }
               if(_loc4_ > _loc3_)
               {
                  return 1;
               }
            }
            _loc5_++;
            _loc6_++;
         }
         return 0;
      }
      
      public static function toObjectKeyString(param1:Object) : String
      {
         var _loc2_:String = "";
         for(var _loc3_ in param1)
         {
            _loc2_ += _loc3_ + ",";
         }
         return _loc2_;
      }
      
      public static function distance2(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         return (param1 - param3) * (param1 - param3) + (param2 - param4) * (param2 - param4);
      }
      
      public static function distance(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         return Math.sqrt(distance2(param1,param2,param3,param4));
      }
      
      public static function gridDistance(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         return Math.abs(param1 - param3) + Math.abs(param2 - param4);
      }
      
      public static function vectorLength(param1:Point) : Number
      {
         return Math.pow(param1.x * param1.x + param1.y * param1.y,0.5);
      }
      
      public static function dotProduct(param1:Point, param2:Point) : Number
      {
         return param1.x * param2.x + param1.y * param2.y;
      }
      
      public static function AngleOf2Vector(param1:Point, param2:Point) : Number
      {
         var _loc4_:Number = vectorLength(param1);
         var _loc3_:Number = vectorLength(param2);
         var _loc5_:Number = dotProduct(param1,param2) / (_loc4_ * _loc3_);
         return Number(Math.acos(_loc5_));
      }
      
      public static function cross(param1:Point, param2:Point) : Number
      {
         return param1.x * param2.y - param1.y * param2.x;
      }
   }
}
