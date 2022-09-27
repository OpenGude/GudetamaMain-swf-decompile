package spine.animation
{
   import flash.geom.Point;
   import spine.Bone;
   import spine.Event;
   import spine.Skeleton;
   
   public class TranslateTimeline extends CurveTimeline
   {
      
      public static const ENTRIES:int = 3;
      
      static const PREV_TIME:int = -3;
      
      static const PREV_X:int = -2;
      
      static const PREV_Y:int = -1;
      
      static const X:int = 1;
      
      static const Y:int = 2;
       
      
      public var boneIndex:int;
      
      public var frames:Vector.<Number>;
      
      public var point:Point;
      
      public function TranslateTimeline(param1:int)
      {
         super(param1);
         frames = new Vector.<Number>(param1 * 3,true);
         point = new Point();
      }
      
      override public function getPropertyId() : int
      {
         return (TimelineType.translate.ordinal << 24) + boneIndex;
      }
      
      public function setFrame(param1:int, param2:Number, param3:Number, param4:Number) : void
      {
         param1 *= 3;
         frames[param1] = param2;
         frames[int(param1 + 1)] = param3;
         frames[int(param1 + 2)] = param4;
      }
      
      override public function apply(param1:Skeleton, param2:Number, param3:Number, param4:Vector.<Event>, param5:Number, param6:Boolean, param7:Boolean) : void
      {
         var _loc13_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc14_:int = 0;
         var _loc9_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc8_:Vector.<Number> = this.frames;
         var _loc10_:Bone = param1.bones[boneIndex];
         if(param3 < _loc8_[0])
         {
            if(param6)
            {
               _loc10_.x = _loc10_.data#2.x;
               _loc10_.y = _loc10_.data#2.y;
            }
            return;
         }
         if(param3 >= _loc8_[_loc8_.length - 3])
         {
            _loc12_ = _loc8_[_loc8_.length + -2];
            _loc13_ = _loc8_[_loc8_.length + -1];
         }
         else
         {
            _loc14_ = Animation.binarySearch(_loc8_,param3,3);
            _loc12_ = _loc8_[_loc14_ + -2];
            _loc13_ = _loc8_[_loc14_ + -1];
            _loc9_ = _loc8_[_loc14_];
            _loc11_ = getCurvePercent(_loc14_ / 3 - 1,1 - (param3 - _loc9_) / (_loc8_[_loc14_ + -3] - _loc9_));
            _loc12_ += (_loc8_[_loc14_ + 1] - _loc12_) * _loc11_;
            _loc13_ += (_loc8_[_loc14_ + 2] - _loc13_) * _loc11_;
         }
         if(param6)
         {
            _loc10_.x = _loc10_.data#2.x + _loc12_ * param5;
            _loc10_.y = _loc10_.data#2.y + _loc13_ * param5;
         }
         else
         {
            _loc10_.x += (_loc10_.data#2.x + _loc12_ - _loc10_.x) * param5;
            _loc10_.y += (_loc10_.data#2.y + _loc13_ - _loc10_.y) * param5;
         }
      }
      
      override public function mult(param1:Skeleton, param2:Number, param3:Number, param4:Vector.<Event>, param5:Number, param6:Boolean, param7:Boolean, param8:Boolean) : void
      {
         var _loc14_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc15_:int = 0;
         var _loc10_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc9_:Vector.<Number> = this.frames;
         var _loc11_:Bone = param1.bones[boneIndex];
         if(param3 < _loc9_[0])
         {
            if(param6)
            {
               if(param8)
               {
                  _loc11_.x += 0.5 * (_loc11_.data#2.x - _loc11_.x);
                  _loc11_.y += 0.5 * (_loc11_.data#2.y - _loc11_.y);
               }
               else
               {
                  _loc11_.x = _loc11_.data#2.x;
                  _loc11_.y = _loc11_.data#2.y;
               }
            }
            return;
         }
         if(param3 >= _loc9_[_loc9_.length - 3])
         {
            _loc13_ = _loc9_[_loc9_.length + -2];
            _loc14_ = _loc9_[_loc9_.length + -1];
         }
         else
         {
            _loc15_ = Animation.binarySearch(_loc9_,param3,3);
            _loc13_ = _loc9_[_loc15_ + -2];
            _loc14_ = _loc9_[_loc15_ + -1];
            _loc10_ = _loc9_[_loc15_];
            _loc12_ = getCurvePercent(_loc15_ / 3 - 1,1 - (param3 - _loc10_) / (_loc9_[_loc15_ + -3] - _loc10_));
            _loc13_ += (_loc9_[_loc15_ + 1] - _loc13_) * _loc12_;
            _loc14_ += (_loc9_[_loc15_ + 2] - _loc14_) * _loc12_;
         }
         if(param6)
         {
            point.setTo(_loc11_.data#2.x + _loc13_ * param5,_loc11_.data#2.y + _loc14_ * param5);
            if(param8)
            {
               _loc11_.x += 0.5 * (point.x - _loc11_.x);
               _loc11_.y += 0.5 * (point.y - _loc11_.y);
            }
            else
            {
               _loc11_.x = point.x;
               _loc11_.y = point.y;
            }
         }
         else
         {
            point.setTo((_loc11_.data#2.x + _loc13_ - _loc11_.x) * param5,(_loc11_.data#2.y + _loc14_ - _loc11_.y) * param5);
            if(param8)
            {
               _loc11_.x += 0.5 * (point.x - _loc11_.x);
               _loc11_.y += 0.5 * (point.y - _loc11_.y);
            }
            else
            {
               _loc11_.x = point.x;
               _loc11_.y = point.y;
            }
         }
      }
   }
}
