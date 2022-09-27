package gestouch.gestures
{
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.system.Capabilities;
   import flash.utils.Timer;
   import gestouch.core.GestureState;
   import gestouch.core.Touch;
   
   public class SwipeGesture extends AbstractDiscreteGesture
   {
      
      private static const ANGLE:Number = 0.6981317007977318;
      
      private static const MAX_DURATION:uint = 500;
      
      private static const MIN_OFFSET:Number = Capabilities.screenDPI / 6;
      
      private static const MIN_VELOCITY:Number = 2 * MIN_OFFSET / 500;
       
      
      public var slop:Number;
      
      public var numTouchesRequired:uint = 1;
      
      public var direction:uint = 15;
      
      public var maxDuration:uint = 500;
      
      public var minOffset:Number;
      
      public var minVelocity:Number;
      
      protected var _offset:Point;
      
      protected var _startTime:int;
      
      protected var _noDirection:Boolean;
      
      protected var _avrgVel:Point;
      
      protected var _timer:Timer;
      
      public function SwipeGesture(param1:Object = null)
      {
         slop = Gesture.DEFAULT_SLOP;
         minOffset = MIN_OFFSET;
         minVelocity = MIN_VELOCITY;
         _offset = new Point();
         _avrgVel = new Point();
         super(param1);
      }
      
      public function get offsetX() : Number
      {
         return _offset.x;
      }
      
      public function get offsetY() : Number
      {
         return _offset.y;
      }
      
      override public function reflect() : Class
      {
         return SwipeGesture;
      }
      
      override public function reset() : void
      {
         _startTime = 0;
         _offset.x = 0;
         _offset.y = 0;
         _timer.reset();
         super.reset();
      }
      
      override protected function preinit() : void
      {
         super.preinit();
         _timer = new Timer(maxDuration,1);
         _timer.addEventListener("timerComplete",timer_timerCompleteHandler);
      }
      
      override protected function onTouchBegin(param1:Touch) : void
      {
         if(touchesCount > numTouchesRequired)
         {
            failOrIgnoreTouch(param1);
            return;
         }
         if(touchesCount == 1)
         {
            _startTime = param1.time;
            _timer.reset();
            _timer.delay = maxDuration;
            _timer.start();
         }
         if(touchesCount == numTouchesRequired)
         {
            updateLocation();
            _avrgVel.x = _avrgVel.y = 0;
            _noDirection = (15 & direction) == 0;
         }
      }
      
      override protected function onTouchMove(param1:Touch) : void
      {
         var _loc11_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc12_:Number = NaN;
         if(touchesCount < numTouchesRequired)
         {
            return;
         }
         var _loc2_:int = param1.time - _startTime;
         if(_loc2_ == 0)
         {
            return;
         }
         var _loc3_:Number = _centralPoint.x;
         var _loc4_:Number = _centralPoint.y;
         updateCentralPoint();
         _offset.x = _centralPoint.x - _location.x;
         _offset.y = _centralPoint.y - _location.y;
         var _loc7_:Number = _offset.length;
         _avrgVel.x = _offset.x / _loc2_;
         _avrgVel.y = _offset.y / _loc2_;
         var _loc10_:Number = _avrgVel.length;
         if(_noDirection)
         {
            if((_loc7_ > slop || slop != slop) && (_loc10_ >= minVelocity || _loc7_ >= minOffset))
            {
               setState(GestureState.RECOGNIZED);
            }
         }
         else
         {
            _loc11_ = _centralPoint.x - _loc3_;
            _loc9_ = _centralPoint.y - _loc4_;
            _loc6_ = _avrgVel.x > 0 ? _avrgVel.x : Number(-_avrgVel.x);
            _loc8_ = _avrgVel.y > 0 ? _avrgVel.y : Number(-_avrgVel.y);
            if(_loc6_ > _loc8_)
            {
               if((_loc5_ = _offset.x > 0 ? _offset.x : Number(-_offset.x)) > slop || slop != slop)
               {
                  if(_loc11_ < 0 && (direction & 2) == 0 || _loc11_ > 0 && (direction & 1) == 0 || Math.abs(Math.atan(_offset.y / _offset.x)) > 0.6981317007977318)
                  {
                     setState(GestureState.FAILED);
                  }
                  else if(_loc6_ >= minVelocity || _loc5_ >= minOffset)
                  {
                     _offset.y = 0;
                     setState(GestureState.RECOGNIZED);
                  }
               }
            }
            else if(_loc8_ > _loc6_)
            {
               if((_loc12_ = _offset.y > 0 ? _offset.y : Number(-_offset.y)) > slop || slop != slop)
               {
                  if(_loc9_ < 0 && (direction & 4) == 0 || _loc9_ > 0 && (direction & 8) == 0 || Math.abs(Math.atan(_offset.x / _offset.y)) > 0.6981317007977318)
                  {
                     setState(GestureState.FAILED);
                  }
                  else if(_loc8_ >= minVelocity || _loc12_ >= minOffset)
                  {
                     _offset.x = 0;
                     setState(GestureState.RECOGNIZED);
                  }
               }
            }
            else if(_loc7_ > slop || slop != slop)
            {
               setState(GestureState.FAILED);
            }
         }
      }
      
      override protected function onTouchEnd(param1:Touch) : void
      {
         if(touchesCount < numTouchesRequired)
         {
            setState(GestureState.FAILED);
         }
      }
      
      override protected function resetNotificationProperties() : void
      {
         super.resetNotificationProperties();
         _offset.x = _offset.y = 0;
      }
      
      protected function timer_timerCompleteHandler(param1:TimerEvent) : void
      {
         if(state == GestureState.POSSIBLE)
         {
            setState(GestureState.FAILED);
         }
      }
   }
}
