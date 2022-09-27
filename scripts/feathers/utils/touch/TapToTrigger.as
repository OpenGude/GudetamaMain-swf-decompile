package feathers.utils.touch
{
   import flash.geom.Point;
   import starling.display.DisplayObject;
   import starling.display.DisplayObjectContainer;
   import starling.display.Stage;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   import starling.utils.Pool;
   
   public class TapToTrigger
   {
       
      
      protected var _target:DisplayObject;
      
      protected var _touchPointID:int = -1;
      
      protected var _isEnabled:Boolean = true;
      
      protected var _customHitTest:Function;
      
      public function TapToTrigger(param1:DisplayObject = null)
      {
         super();
         this.target = param1;
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
         if(this._target)
         {
            this._target.removeEventListener("touch",target_touchHandler);
         }
         this._target = param1;
         if(this._target)
         {
            this._touchPointID = -1;
            this._target.addEventListener("touch",target_touchHandler);
         }
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
            if(_loc4_.phase == "ended")
            {
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
                  Pool.putPoint(_loc5_);
                  if(_loc3_)
                  {
                     this._target.dispatchEventWith("triggered");
                  }
               }
               this._touchPointID = -1;
            }
            return;
         }
         if(!(_loc4_ = param1.getTouch(DisplayObject(this._target),"began")))
         {
            return;
         }
         if(this._customHitTest !== null)
         {
            _loc5_ = Pool.getPoint();
            _loc4_.getLocation(DisplayObject(this._target),_loc5_);
            _loc3_ = Boolean(this._customHitTest(_loc5_));
            Pool.putPoint(_loc5_);
            if(!_loc3_)
            {
               return;
            }
         }
         this._touchPointID = _loc4_.id#2;
      }
   }
}
