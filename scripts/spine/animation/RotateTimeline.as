package spine.animation
{
   import spine.Bone;
   import spine.Event;
   import spine.Skeleton;
   
   public class RotateTimeline extends CurveTimeline
   {
      
      public static const ENTRIES:int = 2;
      
      public static const PREV_TIME:int = -2;
      
      public static const PREV_ROTATION:int = -1;
      
      public static const ROTATION:int = 1;
       
      
      public var boneIndex:int;
      
      public var frames:Vector.<Number>;
      
      public function RotateTimeline(param1:int)
      {
         super(param1);
         frames = new Vector.<Number>(param1 * 2,true);
      }
      
      override public function getPropertyId() : int
      {
         return (TimelineType.rotate.ordinal << 24) + boneIndex;
      }
      
      public function setFrame(param1:int, param2:Number, param3:Number) : void
      {
         param1 <<= 1;
         frames[param1] = param2;
         frames[int(param1 + 1)] = param3;
      }
      
      override public function apply(param1:Skeleton, param2:Number, param3:Number, param4:Vector.<Event>, param5:Number, param6:Boolean, param7:Boolean) : void
      {
         var _loc12_:Number = NaN;
         var _loc8_:Vector.<Number> = this.frames;
         var _loc10_:Bone = param1.bones[boneIndex];
         if(param3 < _loc8_[0])
         {
            if(param6)
            {
               _loc10_.rotation = _loc10_.data#2.rotation;
            }
            return;
         }
         if(param3 >= _loc8_[_loc8_.length - 2])
         {
            if(param6)
            {
               _loc10_.rotation = _loc10_.data#2.rotation + _loc8_[_loc8_.length + -1] * param5;
            }
            else
            {
               _loc12_ = (_loc12_ = _loc10_.data#2.rotation + _loc8_[_loc8_.length + -1] - _loc10_.rotation) - (16384 - (int(16384.499999999996 - _loc12_ / 360))) * 360;
               _loc10_.rotation += _loc12_ * param5;
            }
            return;
         }
         var _loc14_:int = Animation.binarySearch(_loc8_,param3,2);
         var _loc13_:Number = _loc8_[_loc14_ + -1];
         var _loc9_:Number = _loc8_[_loc14_];
         var _loc11_:Number = getCurvePercent((_loc14_ >> 1) - 1,1 - (param3 - _loc9_) / (_loc8_[_loc14_ + -2] - _loc9_));
         _loc12_ = (_loc12_ = _loc8_[_loc14_ + 1] - _loc13_) - (16384 - (int(16384.499999999996 - _loc12_ / 360))) * 360;
         _loc12_ = _loc13_ + _loc12_ * _loc11_;
         if(param6)
         {
            _loc12_ -= (16384 - (int(16384.499999999996 - _loc12_ / 360))) * 360;
            _loc10_.rotation = _loc10_.data#2.rotation + _loc12_ * param5;
         }
         else
         {
            _loc12_ = (_loc12_ = _loc10_.data#2.rotation + _loc12_ - _loc10_.rotation) - (16384 - (int(16384.499999999996 - _loc12_ / 360))) * 360;
            _loc10_.rotation += _loc12_ * param5;
         }
      }
      
      override public function mult(param1:Skeleton, param2:Number, param3:Number, param4:Vector.<Event>, param5:Number, param6:Boolean, param7:Boolean, param8:Boolean) : void
      {
         var _loc9_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc10_:Vector.<Number> = this.frames;
         var _loc12_:Bone = param1.bones[boneIndex];
         if(param3 < _loc10_[0])
         {
            if(param6)
            {
               _loc12_.rotation = _loc12_.data#2.rotation;
            }
            return;
         }
         if(param3 >= _loc10_[_loc10_.length - 2])
         {
            if(param6)
            {
               _loc9_ = _loc12_.data#2.rotation + _loc10_[_loc10_.length + -1] * param5;
               if(param8)
               {
                  _loc12_.rotation += 0.5 * (_loc9_ - _loc12_.rotation);
               }
               else
               {
                  _loc12_.rotation = _loc9_;
               }
            }
            else
            {
               _loc14_ = (_loc14_ = _loc12_.data#2.rotation + _loc10_[_loc10_.length + -1] - _loc12_.rotation) - (16384 - (int(16384.499999999996 - _loc14_ / 360))) * 360;
               _loc12_.rotation += 0.5 * (_loc14_ * param5 - _loc12_.rotation);
            }
            return;
         }
         var _loc16_:int = Animation.binarySearch(_loc10_,param3,2);
         var _loc15_:Number = _loc10_[_loc16_ + -1];
         var _loc11_:Number = _loc10_[_loc16_];
         var _loc13_:Number = getCurvePercent((_loc16_ >> 1) - 1,1 - (param3 - _loc11_) / (_loc10_[_loc16_ + -2] - _loc11_));
         _loc14_ = (_loc14_ = _loc10_[_loc16_ + 1] - _loc15_) - (16384 - (int(16384.499999999996 - _loc14_ / 360))) * 360;
         _loc14_ = _loc15_ + _loc14_ * _loc13_;
         if(param6)
         {
            _loc14_ -= (16384 - (int(16384.499999999996 - _loc14_ / 360))) * 360;
            _loc9_ = _loc12_.data#2.rotation + _loc14_ * param5;
            if(param8)
            {
               _loc12_.rotation += 0.5 * (_loc9_ - _loc12_.rotation);
            }
            else
            {
               _loc12_.rotation = _loc9_;
            }
         }
         else
         {
            _loc14_ = (_loc14_ = _loc12_.data#2.rotation + _loc14_ - _loc12_.rotation) - (16384 - (int(16384.499999999996 - _loc14_ / 360))) * 360;
            _loc12_.rotation += 0.5 * (_loc14_ * param5 - _loc12_.rotation);
         }
      }
   }
}
