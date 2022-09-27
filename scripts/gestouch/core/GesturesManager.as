package gestouch.core
{
   import flash.display.DisplayObject;
   import flash.display.Shape;
   import flash.display.Stage;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.IEventDispatcher;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   import gestouch.extensions.native.NativeTouchHitTester;
   import gestouch.gestures.Gesture;
   import gestouch.input.NativeInputAdapter;
   
   public class GesturesManager
   {
       
      
      protected const _frameTickerShape:Shape = new Shape();
      
      protected var _gesturesMap:Dictionary;
      
      protected var _gesturesForTouchMap:Dictionary;
      
      protected var _gesturesForTargetMap:Dictionary;
      
      protected var _dirtyGesturesCount:uint = 0;
      
      protected var _dirtyGesturesMap:Dictionary;
      
      protected var _stage:Stage;
      
      public function GesturesManager()
      {
         _gesturesMap = new Dictionary(true);
         _gesturesForTouchMap = new Dictionary();
         _gesturesForTargetMap = new Dictionary(true);
         _dirtyGesturesMap = new Dictionary(true);
         super();
      }
      
      protected function onStageAvailable(param1:Stage) : void
      {
         _stage = param1;
         Gestouch.inputAdapter = Gestouch.inputAdapter || new NativeInputAdapter(param1);
         Gestouch.addTouchHitTester(new NativeTouchHitTester(param1));
      }
      
      protected function resetDirtyGestures() : void
      {
         for(var _loc1_ in _dirtyGesturesMap)
         {
            (_loc1_ as Gesture).reset();
         }
         _dirtyGesturesCount = 0;
         _dirtyGesturesMap = new Dictionary(true);
         _frameTickerShape.removeEventListener("enterFrame",enterFrameHandler);
      }
      
      gestouch_internal function addGesture(param1:Gesture) : void
      {
         var _loc2_:* = null;
         if(!param1)
         {
            throw new ArgumentError("Argument \'gesture\' must be not null.");
         }
         var _loc4_:Object;
         if(!(_loc4_ = param1.target))
         {
            throw new IllegalOperationError("Gesture must have target.");
         }
         var _loc3_:Vector.<Gesture> = _gesturesForTargetMap[_loc4_] as Vector.<Gesture>;
         if(_loc3_)
         {
            if(_loc3_.indexOf(param1) == -1)
            {
               _loc3_.push(param1);
            }
         }
         else
         {
            _loc3_ = _gesturesForTargetMap[_loc4_] = new Vector.<Gesture>();
            _loc3_[0] = param1;
         }
         _gesturesMap[param1] = true;
         if(!_stage)
         {
            _loc2_ = _loc4_ as DisplayObject;
            if(_loc2_)
            {
               if(_loc2_.stage)
               {
                  onStageAvailable(_loc2_.stage);
               }
               else
               {
                  _loc2_.addEventListener("addedToStage",gestureTarget_addedToStageHandler,false,0,true);
               }
            }
         }
      }
      
      gestouch_internal function removeGesture(param1:Gesture) : void
      {
         var _loc2_:* = undefined;
         if(!param1)
         {
            throw new ArgumentError("Argument \'gesture\' must be not null.");
         }
         var _loc3_:Object = param1.target;
         if(_loc3_)
         {
            _loc2_ = _gesturesForTargetMap[_loc3_] as Vector.<Gesture>;
            if(_loc2_.length > 1)
            {
               _loc2_.splice(_loc2_.indexOf(param1),1);
            }
            else
            {
               delete _gesturesForTargetMap[_loc3_];
               if(_loc3_ is IEventDispatcher)
               {
                  (_loc3_ as IEventDispatcher).removeEventListener("addedToStage",gestureTarget_addedToStageHandler);
               }
            }
         }
         delete _gesturesMap[param1];
         param1.reset();
      }
      
      gestouch_internal function scheduleGestureStateReset(param1:Gesture) : void
      {
         if(!_dirtyGesturesMap[param1])
         {
            _dirtyGesturesMap[param1] = true;
            _dirtyGesturesCount++;
            _frameTickerShape.addEventListener("enterFrame",enterFrameHandler);
         }
      }
      
      gestouch_internal function onGestureRecognized(param1:Gesture) : void
      {
         var _loc2_:* = null;
         var _loc5_:* = null;
         var _loc4_:Object = param1.target;
         for(var _loc3_ in _gesturesMap)
         {
            _loc2_ = _loc3_ as Gesture;
            _loc5_ = _loc2_.target;
            if(_loc2_ != param1 && _loc4_ && _loc5_ && _loc2_.enabled && _loc2_.state == GestureState.POSSIBLE)
            {
               if(_loc5_ == _loc4_ || param1.targetAdapter.contains(_loc5_) || _loc2_.targetAdapter.contains(_loc4_))
               {
                  if(param1.canPreventGesture(_loc2_) && _loc2_.canBePreventedByGesture(param1) && (param1.gesturesShouldRecognizeSimultaneouslyCallback == null || !param1.gesturesShouldRecognizeSimultaneouslyCallback(param1,_loc2_)) && (_loc2_.gesturesShouldRecognizeSimultaneouslyCallback == null || !_loc2_.gesturesShouldRecognizeSimultaneouslyCallback(_loc2_,param1)))
                  {
                     _loc2_.setState_internal(GestureState.FAILED);
                  }
               }
            }
         }
      }
      
      gestouch_internal function onTouchBegin(param1:Touch) : void
      {
         var _loc8_:* = null;
         var _loc6_:* = 0;
         var _loc7_:* = undefined;
         var _loc3_:Vector.<Gesture> = _gesturesForTouchMap[param1] as Vector.<Gesture>;
         if(!_loc3_)
         {
            _loc3_ = new Vector.<Gesture>();
            _gesturesForTouchMap[param1] = _loc3_;
         }
         else
         {
            _loc3_.length = 0;
         }
         var _loc9_:Object = param1.target;
         var _loc4_:IDisplayListAdapter;
         if(!(_loc4_ = Gestouch.getDisplayListAdapter(_loc9_)))
         {
            throw new Error("Display list adapter not found for target of type \'" + getQualifiedClassName(_loc9_) + "\'.");
         }
         var _loc5_:Vector.<Object>;
         var _loc2_:uint = (_loc5_ = _loc4_.getHierarchy(_loc9_)).length;
         if(_loc2_ == 0)
         {
            throw new Error("No hierarchy build for target \'" + _loc9_ + "\'. Something is wrong with that IDisplayListAdapter.");
         }
         if(_stage && !(_loc5_[_loc2_ - 1] is Stage))
         {
            _loc5_[_loc2_] = _stage;
         }
         for each(_loc9_ in _loc5_)
         {
            if(_loc7_ = _gesturesForTargetMap[_loc9_] as Vector.<Gesture>)
            {
               _loc6_ = uint(_loc7_.length);
               while(_loc6_-- > 0)
               {
                  if((_loc8_ = _loc7_[_loc6_]).enabled && (_loc8_.gestureShouldReceiveTouchCallback == null || _loc8_.gestureShouldReceiveTouchCallback(_loc8_,param1)))
                  {
                     _loc3_.unshift(_loc8_);
                  }
               }
            }
         }
         _loc6_ = uint(_loc3_.length);
         while(_loc6_-- > 0)
         {
            _loc8_ = _loc3_[_loc6_];
            if(!_dirtyGesturesMap[_loc8_])
            {
               _loc8_.touchBeginHandler(param1);
            }
            else
            {
               _loc3_.splice(_loc6_,1);
            }
         }
      }
      
      gestouch_internal function onTouchMove(param1:Touch) : void
      {
         var _loc4_:* = null;
         var _loc2_:Vector.<Gesture> = _gesturesForTouchMap[param1] as Vector.<Gesture>;
         var _loc3_:uint = _loc2_.length;
         while(_loc3_-- > 0)
         {
            _loc4_ = _loc2_[_loc3_];
            if(!_dirtyGesturesMap[_loc4_] && _loc4_.isTrackingTouch(param1.id#2))
            {
               _loc4_.touchMoveHandler(param1);
            }
            else
            {
               _loc2_.splice(_loc3_,1);
            }
         }
      }
      
      gestouch_internal function onTouchEnd(param1:Touch) : void
      {
         var _loc4_:* = null;
         var _loc2_:Vector.<Gesture> = _gesturesForTouchMap[param1] as Vector.<Gesture>;
         var _loc3_:uint = _loc2_.length;
         while(_loc3_-- > 0)
         {
            _loc4_ = _loc2_[_loc3_];
            if(!_dirtyGesturesMap[_loc4_] && _loc4_.isTrackingTouch(param1.id#2))
            {
               _loc4_.touchEndHandler(param1);
            }
         }
         _loc2_.length = 0;
         delete _gesturesForTouchMap[param1];
      }
      
      gestouch_internal function onTouchCancel(param1:Touch) : void
      {
         var _loc4_:* = null;
         var _loc2_:Vector.<Gesture> = _gesturesForTouchMap[param1] as Vector.<Gesture>;
         var _loc3_:uint = _loc2_.length;
         while(_loc3_-- > 0)
         {
            _loc4_ = _loc2_[_loc3_];
            if(!_dirtyGesturesMap[_loc4_] && _loc4_.isTrackingTouch(param1.id#2))
            {
               _loc4_.touchCancelHandler(param1);
            }
         }
         _loc2_.length = 0;
         delete _gesturesForTouchMap[param1];
      }
      
      protected function gestureTarget_addedToStageHandler(param1:Event) : void
      {
         var _loc2_:DisplayObject = param1.target as DisplayObject;
         _loc2_.removeEventListener("addedToStage",gestureTarget_addedToStageHandler);
         if(!_stage)
         {
            onStageAvailable(_loc2_.stage);
         }
      }
      
      private function enterFrameHandler(param1:Event) : void
      {
         resetDirtyGestures();
      }
   }
}
