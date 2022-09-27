package feathers.utils.touch
{
   import flash.geom.Point;
   import starling.display.DisplayObject;
   import starling.display.DisplayObjectContainer;
   import starling.display.Stage;
   import starling.events.Event;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   import starling.utils.Pool;
   
   public class TouchToState
   {
       
      
      protected var _target:DisplayObject;
      
      protected var _callback:Function;
      
      protected var _currentState:String = "up";
      
      protected var _upState:String = "up";
      
      protected var _downState:String = "down";
      
      protected var _hoverState:String = "hover";
      
      protected var _touchPointID:int = -1;
      
      protected var _isEnabled:Boolean = true;
      
      protected var _customHitTest:Function;
      
      protected var _keepDownStateOnRollOut:Boolean = false;
      
      public function TouchToState(param1:DisplayObject = null, param2:Function = null)
      {
         super();
         this.target = param1;
         this.callback = param2;
      }
      
      public function get target() : DisplayObject
      {
         return this._target;
      }
      
      public function set target(param1:DisplayObject) : void
      {
         if(this._target == param1)
         {
            return;
         }
         if(this._target !== null)
         {
            this._target.removeEventListener("touch",target_touchHandler);
            this._target.removeEventListener("removedFromStage",target_removedFromStageHandler);
         }
         this._target = param1;
         if(this._target !== null)
         {
            this._touchPointID = -1;
            this._currentState = this._upState;
            this._target.addEventListener("touch",target_touchHandler);
            this._target.addEventListener("removedFromStage",target_removedFromStageHandler);
         }
      }
      
      public function get callback() : Function
      {
         return this._callback;
      }
      
      public function set callback(param1:Function) : void
      {
         if(this._callback === param1)
         {
            return;
         }
         this._callback = param1;
         if(this._callback !== null)
         {
            this._callback(this._currentState);
         }
      }
      
      public function get currentState() : String
      {
         return this._currentState;
      }
      
      public function get upState() : String
      {
         return this._upState;
      }
      
      public function set upState(param1:String) : void
      {
         this._upState = param1;
      }
      
      public function get downState() : String
      {
         return this._downState;
      }
      
      public function set downState(param1:String) : void
      {
         this._downState = param1;
      }
      
      public function get hoverState() : String
      {
         return this._hoverState;
      }
      
      public function set hoverState(param1:String) : void
      {
         this._hoverState = param1;
      }
      
      public function get isEnabled() : Boolean
      {
         return this._isEnabled;
      }
      
      public function set isEnabled(param1:Boolean) : void
      {
         if(this._isEnabled === param1)
         {
            return;
         }
         this._isEnabled = param1;
         if(!param1)
         {
            this._touchPointID = -1;
         }
      }
      
      public function get customHitTest() : Function
      {
         return this._customHitTest;
      }
      
      public function set customHitTest(param1:Function) : void
      {
         this._customHitTest = param1;
      }
      
      public function get keepDownStateOnRollOut() : Boolean
      {
         return this._keepDownStateOnRollOut;
      }
      
      public function set keepDownStateOnRollOut(param1:Boolean) : void
      {
         this._keepDownStateOnRollOut = param1;
      }
      
      protected function handleCustomHitTest(param1:Touch) : Boolean
      {
         if(this._customHitTest === null)
         {
            return true;
         }
         var _loc3_:Point = Pool.getPoint();
         param1.getLocation(DisplayObject(this._target),_loc3_);
         var _loc2_:Boolean = this._customHitTest(_loc3_);
         Pool.putPoint(_loc3_);
         return _loc2_;
      }
      
      protected function changeState(param1:String) : void
      {
         if(this._currentState === param1)
         {
            return;
         }
         this._currentState = param1;
         if(this._callback !== null)
         {
            this._callback(param1);
         }
      }
      
      protected function resetTouchState() : void
      {
         this._touchPointID = -1;
         this.changeState(this._upState);
      }
      
      protected function target_removedFromStageHandler(param1:Event) : void
      {
         this.resetTouchState();
      }
      
      protected function target_touchHandler(param1:TouchEvent) : void
      {
         var _loc4_:* = null;
         var _loc2_:* = null;
         var _loc5_:* = null;
         var _loc3_:* = false;
         if(!this._isEnabled)
         {
            this._touchPointID = -1;
            return;
         }
         if(this._touchPointID >= 0)
         {
            if(!(_loc4_ = param1.getTouch(this._target,null,this._touchPointID)))
            {
               return;
            }
            _loc2_ = this._target.stage;
            if(_loc2_ !== null)
            {
               _loc5_ = Pool.getPoint();
               _loc4_.getLocation(_loc2_,_loc5_);
               if(this._target is DisplayObjectContainer)
               {
                  _loc3_ = Boolean(DisplayObjectContainer(this._target).contains(_loc2_.hitTest(_loc5_)));
               }
               else
               {
                  _loc3_ = this._target === _loc2_.hitTest(_loc5_);
               }
               if(_loc3_)
               {
                  _loc3_ = this.handleCustomHitTest(_loc4_);
               }
               Pool.putPoint(_loc5_);
               if(_loc4_.phase === "moved")
               {
                  if(this._keepDownStateOnRollOut)
                  {
                     return;
                  }
                  if(_loc3_)
                  {
                     this.changeState(this._downState);
                     return;
                  }
                  this.changeState(this._upState);
                  return;
               }
               if(_loc4_.phase === "ended")
               {
                  this.resetTouchState();
                  return;
               }
            }
         }
         else
         {
            if((_loc4_ = param1.getTouch(this._target,"began")) !== null && this.handleCustomHitTest(_loc4_))
            {
               this.changeState(this._downState);
               this._touchPointID = _loc4_.id#2;
               return;
            }
            if((_loc4_ = param1.getTouch(this._target,"hover")) !== null && this.handleCustomHitTest(_loc4_))
            {
               this.changeState(this._hoverState);
               return;
            }
            this.changeState(this._upState);
         }
      }
   }
}
