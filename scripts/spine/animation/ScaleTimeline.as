package spine.animation
{
   import spine.Bone;
   import spine.Event;
   import spine.MathUtils;
   import spine.Skeleton;
   
   public class ScaleTimeline extends TranslateTimeline
   {
       
      
      public function ScaleTimeline(param1:int)
      {
         super(param1);
      }
      
      override public function getPropertyId() : int
      {
         return (TimelineType.scale.ordinal << 24) + boneIndex;
      }
      
      override public function apply(param1:Skeleton, param2:Number, param3:Number, param4:Vector.<Event>, param5:Number, param6:Boolean, param7:Boolean) : void
      {
         var _loc15_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc16_:int = 0;
         var _loc9_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc8_:Vector.<Number> = this.frames;
         var _loc10_:Bone = param1.bones[boneIndex];
         if(param3 < _loc8_[0])
         {
            if(param6)
            {
               _loc10_.scaleX = _loc10_.data#2.scaleX;
               _loc10_.scaleY = _loc10_.data#2.scaleY;
            }
            return;
         }
         if(param3 >= _loc8_[_loc8_.length - 3])
         {
            _loc14_ = _loc8_[_loc8_.length + -2] * _loc10_.data#2.scaleX;
            _loc15_ = _loc8_[_loc8_.length + -1] * _loc10_.data#2.scaleY;
         }
         else
         {
            _loc16_ = Animation.binarySearch(_loc8_,param3,3);
            _loc14_ = _loc8_[_loc16_ + -2];
            _loc15_ = _loc8_[_loc16_ + -1];
            _loc9_ = _loc8_[_loc16_];
            _loc11_ = getCurvePercent(_loc16_ / 3 - 1,1 - (param3 - _loc9_) / (_loc8_[_loc16_ + -3] - _loc9_));
            _loc14_ = (_loc14_ + (_loc8_[_loc16_ + 1] - _loc14_) * _loc11_) * _loc10_.data#2.scaleX;
            _loc15_ = (_loc15_ + (_loc8_[_loc16_ + 2] - _loc15_) * _loc11_) * _loc10_.data#2.scaleY;
         }
         if(param5 == 1)
         {
            _loc10_.scaleX = _loc14_;
            _loc10_.scaleY = _loc15_;
         }
         else
         {
            if(param6)
            {
               _loc12_ = _loc10_.data#2.scaleX;
               _loc13_ = _loc10_.data#2.scaleY;
            }
            else
            {
               _loc12_ = _loc10_.scaleX;
               _loc13_ = _loc10_.scaleY;
            }
            if(param7)
            {
               _loc14_ = Math.abs(_loc14_) * MathUtils.signum(_loc12_);
               _loc15_ = Math.abs(_loc15_) * MathUtils.signum(_loc13_);
            }
            else
            {
               _loc12_ = Math.abs(_loc12_) * MathUtils.signum(_loc14_);
               _loc13_ = Math.abs(_loc13_) * MathUtils.signum(_loc15_);
            }
            _loc10_.scaleX = _loc12_ + (_loc14_ - _loc12_) * param5;
            _loc10_.scaleY = _loc13_ + (_loc15_ - _loc13_) * param5;
         }
      }
      
      override public function mult(param1:Skeleton, param2:Number, param3:Number, param4:Vector.<Event>, param5:Number, param6:Boolean, param7:Boolean, param8:Boolean) : void
      {
         var _loc16_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc17_:int = 0;
         var _loc10_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc9_:Vector.<Number> = this.frames;
         var _loc11_:Bone = param1.bones[boneIndex];
         if(param3 < _loc9_[0])
         {
            if(param6)
            {
               if(param8)
               {
                  _loc11_.scaleX += 0.5 * (_loc11_.data#2.scaleX - _loc11_.scaleX);
                  _loc11_.scaleY += 0.5 * (_loc11_.data#2.scaleY - _loc11_.scaleY);
               }
               else
               {
                  _loc11_.scaleX = _loc11_.data#2.scaleX;
                  _loc11_.scaleY = _loc11_.data#2.scaleY;
               }
            }
            return;
         }
         if(param3 >= _loc9_[_loc9_.length - 3])
         {
            _loc15_ = _loc9_[_loc9_.length + -2] * _loc11_.data#2.scaleX;
            _loc16_ = _loc9_[_loc9_.length + -1] * _loc11_.data#2.scaleY;
         }
         else
         {
            _loc17_ = Animation.binarySearch(_loc9_,param3,3);
            _loc15_ = _loc9_[_loc17_ + -2];
            _loc16_ = _loc9_[_loc17_ + -1];
            _loc10_ = _loc9_[_loc17_];
            _loc12_ = getCurvePercent(_loc17_ / 3 - 1,1 - (param3 - _loc10_) / (_loc9_[_loc17_ + -3] - _loc10_));
            _loc15_ = (_loc15_ + (_loc9_[_loc17_ + 1] - _loc15_) * _loc12_) * _loc11_.data#2.scaleX;
            _loc16_ = (_loc16_ + (_loc9_[_loc17_ + 2] - _loc16_) * _loc12_) * _loc11_.data#2.scaleY;
         }
         if(param5 == 1)
         {
            if(param8)
            {
               _loc11_.scaleX += 0.5 * (_loc15_ - _loc11_.scaleX);
               _loc11_.scaleY += 0.5 * (_loc16_ - _loc11_.scaleY);
            }
            else
            {
               _loc11_.scaleX = _loc15_;
               _loc11_.scaleY = _loc16_;
            }
         }
         else
         {
            if(param6)
            {
               _loc13_ = _loc11_.data#2.scaleX;
               _loc14_ = _loc11_.data#2.scaleY;
            }
            else
            {
               _loc13_ = _loc11_.scaleX;
               _loc14_ = _loc11_.scaleY;
            }
            if(param7)
            {
               _loc15_ = Math.abs(_loc15_) * MathUtils.signum(_loc13_);
               _loc16_ = Math.abs(_loc16_) * MathUtils.signum(_loc14_);
            }
            else
            {
               _loc13_ = Math.abs(_loc13_) * MathUtils.signum(_loc15_);
               _loc14_ = Math.abs(_loc14_) * MathUtils.signum(_loc16_);
            }
            point.setTo(_loc13_ + (_loc15_ - _loc13_) * param5,_loc14_ + (_loc16_ - _loc14_) * param5);
            if(param8)
            {
               _loc11_.scaleX += 0.5 * (point.x - _loc11_.scaleX);
               _loc11_.scaleY += 0.5 * (point.y - _loc11_.scaleY);
            }
            else
            {
               _loc11_.scaleX = point.x;
               _loc11_.scaleY = point.y;
            }
         }
      }
   }
}
