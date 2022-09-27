package gestouch.gestures
{
   import flash.errors.IllegalOperationError;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import flash.system.Capabilities;
   import flash.utils.Dictionary;
   import gestouch.core.Gestouch;
   import gestouch.core.GestureState;
   import gestouch.core.GesturesManager;
   import gestouch.core.IGestureTargetAdapter;
   import gestouch.core.Touch;
   import gestouch.core.gestouch_internal;
   import gestouch.events.GestureEvent;
   
   use namespace gestouch_internal;
   
   public class Gesture extends EventDispatcher
   {
      
      public static var DEFAULT_SLOP:uint = Math.round(0.07936507936507936 * Capabilities.screenDPI);
       
      
      public var gestureShouldReceiveTouchCallback:Function;
      
      public var gestureShouldBeginCallback:Function;
      
      public var gesturesShouldRecognizeSimultaneouslyCallback:Function;
      
      protected const _gesturesManager:GesturesManager = gestouch.core.Gestouch._gesturesManager || (gestouch.core.Gestouch._gesturesManager = new gestouch.core.GesturesManager());
      
      protected var _touchesMap:Object;
      
      protected var _centralPoint:Point;
      
      protected var _gesturesToFail:Dictionary;
      
      protected var _pendingRecognizedState:GestureState;
      
      protected var _targetAdapter:IGestureTargetAdapter;
      
      protected var _enabled:Boolean = true;
      
      protected var _state:GestureState;
      
      protected var _idle:Boolean = true;
      
      protected var _touchesCount:uint = 0;
      
      protected var _location:Point;
      
      public function Gesture(param1:Object = null)
      {
         var _loc2_:* = Gestouch;
         _touchesMap = {};
         _centralPoint = new Point();
         _gesturesToFail = new Dictionary(true);
         _state = GestureState.POSSIBLE;
         _location = new Point();
         super();
         preinit();
         this.target = param1;
      }
      
      gestouch_internal function get targetAdapter() : IGestureTargetAdapter
      {
         return _targetAdapter;
      }
      
      protected function get targetAdapter() : IGestureTargetAdapter
      {
         return _targetAdapter;
      }
      
      public function get target() : Object
      {
         return !!_targetAdapter ? _targetAdapter.target : null;
      }
      
      public function set target(param1:Object) : void
      {
         var _loc2_:Object = this.target;
         if(_loc2_ == param1)
         {
            return;
         }
         uninstallTarget(_loc2_);
         _targetAdapter = !!param1 ? Gestouch.createGestureTargetAdapter(param1) : null;
         installTarget(param1);
      }
      
      public function get enabled() : Boolean
      {
         return _enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         if(_enabled == param1)
         {
            return;
         }
         _enabled = param1;
         if(!_enabled)
         {
            if(state == GestureState.POSSIBLE)
            {
               setState(GestureState.FAILED);
            }
            else if(state == GestureState.BEGAN || state == GestureState.CHANGED)
            {
               setState(GestureState.CANCELLED);
            }
         }
      }
      
      public function get state() : GestureState
      {
         return _state;
      }
      
      gestouch_internal function get idle() : Boolean
      {
         return _idle;
      }
      
      public function get touchesCount() : uint
      {
         return _touchesCount;
      }
      
      public function get location#2() : Point
      {
         return _location.clone();
      }
      
      public function reflect() : Class
      {
         throw Error("reflect() is abstract method and must be overridden.");
      }
      
      public function isTrackingTouch(param1:uint) : Boolean
      {
         return _touchesMap[param1] != undefined;
      }
      
      public function reset() : void
      {
         var _loc1_:* = null;
         if(gestouch_internal::idle)
         {
            return;
         }
         var _loc2_:GestureState = this.state;
         _location.x = 0;
         _location.y = 0;
         _touchesMap = {};
         _touchesCount = 0;
         _idle = true;
         for(var _loc3_ in _gesturesToFail)
         {
            _loc1_ = _loc3_ as Gesture;
            _loc1_.removeEventListener("gestureStateChange",gestureToFail_stateChangeHandler);
         }
         _pendingRecognizedState = null;
         if(_loc2_ == GestureState.POSSIBLE)
         {
            setState(GestureState.FAILED);
         }
         else if(_loc2_ == GestureState.BEGAN || _loc2_ == GestureState.CHANGED)
         {
            setState(GestureState.CANCELLED);
         }
         else
         {
            setState(GestureState.POSSIBLE);
         }
      }
      
      public function dispose() : void
      {
         reset();
         target = null;
         gestureShouldReceiveTouchCallback = null;
         gestureShouldBeginCallback = null;
         gesturesShouldRecognizeSimultaneouslyCallback = null;
         _gesturesToFail = null;
      }
      
      gestouch_internal function canBePreventedByGesture(param1:Gesture) : Boolean
      {
         return true;
      }
      
      gestouch_internal function canPreventGesture(param1:Gesture) : Boolean
      {
         return true;
      }
      
      public function requireGestureToFail(param1:Gesture) : void
      {
         if(!param1)
         {
            throw new ArgumentError();
         }
         _gesturesToFail[param1] = true;
      }
      
      protected function preinit() : void
      {
      }
      
      protected function installTarget(param1:Object) : void
      {
         if(param1)
         {
            _gesturesManager.addGesture(this);
         }
      }
      
      protected function uninstallTarget(param1:Object) : void
      {
         if(param1)
         {
            _gesturesManager.removeGesture(this);
         }
      }
      
      protected function ignoreTouch(param1:Touch) : void
      {
         if(param1.id#2 in _touchesMap)
         {
            delete _touchesMap[param1.id#2];
            _touchesCount--;
         }
      }
      
      protected function failOrIgnoreTouch(param1:Touch) : void
      {
         if(state == GestureState.POSSIBLE)
         {
            setState(GestureState.FAILED);
         }
         else
         {
            ignoreTouch(param1);
         }
      }
      
      protected function onTouchBegin(param1:Touch) : void
      {
      }
      
      protected function onTouchMove(param1:Touch) : void
      {
      }
      
      protected function onTouchEnd(param1:Touch) : void
      {
      }
      
      protected function onTouchCancel(param1:Touch) : void
      {
      }
      
      protected function setState(param1:GestureState) : Boolean
      {
         var _loc3_:* = null;
         var _loc4_:* = undefined;
         if(_state == param1 && _state == GestureState.CHANGED)
         {
            if(hasEventListener("gestureStateChange"))
            {
               dispatchEvent(new GestureEvent("gestureStateChange",_state,_state));
            }
            if(hasEventListener("gestureChanged"))
            {
               dispatchEvent(new GestureEvent("gestureChanged",_state,_state));
            }
            resetNotificationProperties();
            return true;
         }
         if(!_state.canTransitionTo(param1))
         {
            throw new IllegalOperationError("You cannot change from state " + _state + " to state " + param1 + ".");
         }
         if(param1 != GestureState.POSSIBLE)
         {
            _idle = false;
         }
         if(param1 == GestureState.BEGAN || param1 == GestureState.RECOGNIZED)
         {
            for(_loc4_ in _gesturesToFail)
            {
               _loc3_ = _loc4_ as Gesture;
               if(!_loc3_.idle && _loc3_.state != GestureState.POSSIBLE && _loc3_.state != GestureState.FAILED)
               {
                  setState(GestureState.FAILED);
                  return false;
               }
            }
            for(_loc4_ in _gesturesToFail)
            {
               _loc3_ = _loc4_ as Gesture;
               if(_loc3_.state == GestureState.POSSIBLE)
               {
                  _pendingRecognizedState = param1;
                  for(_loc4_ in _gesturesToFail)
                  {
                     _loc3_ = _loc4_ as Gesture;
                     _loc3_.addEventListener("gestureStateChange",gestureToFail_stateChangeHandler,false,0,true);
                  }
                  return false;
               }
            }
            if(gestureShouldBeginCallback != null && !gestureShouldBeginCallback(this))
            {
               setState(GestureState.FAILED);
               return false;
            }
         }
         var _loc2_:GestureState = _state;
         _state = param1;
         var _loc11_:*;
         if((_loc11_ = _state)._isEndState)
         {
            _gesturesManager.scheduleGestureStateReset(this);
         }
         if(hasEventListener("gestureStateChange"))
         {
            dispatchEvent(new GestureEvent("gestureStateChange",_state,_loc2_));
         }
         if(hasEventListener(_state.toEventType()))
         {
            dispatchEvent(new GestureEvent(_state.toEventType(),_state,_loc2_));
         }
         resetNotificationProperties();
         if(_state == GestureState.BEGAN || _state == GestureState.RECOGNIZED)
         {
            _gesturesManager.onGestureRecognized(this);
         }
         return true;
      }
      
      gestouch_internal function setState_internal(param1:GestureState) : void
      {
         setState(param1);
      }
      
      protected function updateCentralPoint() : void
      {
         var _loc4_:* = null;
         var _loc2_:* = 0;
         var _loc3_:* = 0;
         for(var _loc1_ in _touchesMap)
         {
            _loc4_ = (_touchesMap[int(_loc1_)] as Touch).location#2;
            _loc2_ += _loc4_.x;
            _loc3_ += _loc4_.y;
         }
         _centralPoint.x = _loc2_ / _touchesCount;
         _centralPoint.y = _loc3_ / _touchesCount;
      }
      
      protected function updateLocation() : void
      {
         updateCentralPoint();
         _location.x = _centralPoint.x;
         _location.y = _centralPoint.y;
      }
      
      protected function resetNotificationProperties() : void
      {
      }
      
      gestouch_internal function touchBeginHandler(param1:Touch) : void
      {
         _touchesMap[param1.id#2] = param1;
         _touchesCount++;
         onTouchBegin(param1);
         if(_touchesCount == 1 && state == GestureState.POSSIBLE)
         {
            _idle = false;
         }
      }
      
      gestouch_internal function touchMoveHandler(param1:Touch) : void
      {
         _touchesMap[param1.id#2] = param1;
         onTouchMove(param1);
      }
      
      gestouch_internal function touchEndHandler(param1:Touch) : void
      {
         delete _touchesMap[param1.id#2];
         _touchesCount--;
         onTouchEnd(param1);
      }
      
      gestouch_internal function touchCancelHandler(param1:Touch) : void
      {
         delete _touchesMap[param1.id#2];
         _touchesCount--;
         onTouchCancel(param1);
         var _loc2_:* = state;
         if(!_loc2_._isEndState)
         {
            if(state == GestureState.BEGAN || state == GestureState.CHANGED)
            {
               setState(GestureState.CANCELLED);
            }
            else
            {
               setState(GestureState.FAILED);
            }
         }
      }
      
      protected function gestureToFail_stateChangeHandler(param1:GestureEvent) : void
      {
         var _loc2_:* = null;
         if(!_pendingRecognizedState || state != GestureState.POSSIBLE)
         {
            return;
         }
         if(param1.newState == GestureState.FAILED)
         {
            for(var _loc3_ in _gesturesToFail)
            {
               _loc2_ = _loc3_ as Gesture;
               if(_loc2_.state == GestureState.POSSIBLE)
               {
                  return;
               }
            }
            setState(_pendingRecognizedState);
         }
         else if(param1.newState != GestureState.POSSIBLE)
         {
            setState(GestureState.FAILED);
         }
      }
   }
}
