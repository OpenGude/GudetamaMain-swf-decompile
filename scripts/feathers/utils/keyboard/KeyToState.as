package feathers.utils.keyboard
{
   import feathers.core.IFocusDisplayObject;
   import starling.display.Stage;
   import starling.events.Event;
   import starling.events.KeyboardEvent;
   
   public class KeyToState
   {
       
      
      protected var _stage:Stage;
      
      protected var _target:IFocusDisplayObject;
      
      protected var _callback:Function;
      
      protected var _keyCode:uint = 32;
      
      protected var _cancelKeyCode:uint = 27;
      
      protected var _isEnabled:Boolean = true;
      
      protected var _currentState:String = "up";
      
      protected var _upState:String = "up";
      
      protected var _downState:String = "down";
      
      public function KeyToState(param1:IFocusDisplayObject = null, param2:Function = null)
      {
         super();
         this.target = param1;
         this.callback = param2;
      }
      
      public function get target() : IFocusDisplayObject
      {
         return this._target;
      }
      
      public function set target(param1:IFocusDisplayObject) : void
      {
         if(this._target === param1)
         {
            return;
         }
         if(param1 !== null && !(param1 is IFocusDisplayObject))
         {
            throw new ArgumentError("Target of KeyToState must implement IFocusDisplayObject");
         }
         if(this._stage !== null)
         {
            this._stage.removeEventListener("keyDown",stage_keyDownHandler);
            this._stage.removeEventListener("keyUp",stage_keyUpHandler);
            this._stage = null;
         }
         if(this._target !== null)
         {
            this._target.removeEventListener("focusIn",target_focusInHandler);
            this._target.removeEventListener("focusOut",target_focusOutHandler);
            this._target.removeEventListener("removedFromStage",target_removedFromStageHandler);
         }
         this._target = param1;
         if(this._target !== null)
         {
            this._currentState = this._upState;
            this._target.addEventListener("focusIn",target_focusInHandler);
            this._target.addEventListener("focusOut",target_focusOutHandler);
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
      
      public function get keyCode() : uint
      {
         return this._keyCode;
      }
      
      public function set keyCode(param1:uint) : void
      {
         this._keyCode = param1;
      }
      
      public function get cancelKeyCode() : uint
      {
         return this._cancelKeyCode;
      }
      
      public function set cancelKeyCode(param1:uint) : void
      {
         this._cancelKeyCode = param1;
      }
      
      public function get isEnabled() : Boolean
      {
         return this._isEnabled;
      }
      
      public function set isEnabled(param1:Boolean) : void
      {
         this._isEnabled = param1;
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
      
      protected function resetState() : void
      {
         this.changeState(this._upState);
      }
      
      protected function target_focusInHandler(param1:Event) : void
      {
         this._stage = this._target.stage;
         this._stage.addEventListener("keyDown",stage_keyDownHandler);
      }
      
      protected function target_focusOutHandler(param1:Event) : void
      {
         if(this._stage !== null)
         {
            this._stage.removeEventListener("keyDown",stage_keyDownHandler);
            this._stage.removeEventListener("keyUp",stage_keyUpHandler);
            this._stage = null;
         }
         this.resetState();
      }
      
      protected function target_removedFromStageHandler(param1:Event) : void
      {
         if(this._stage !== null)
         {
            this._stage.removeEventListener("keyDown",stage_keyDownHandler);
            this._stage.removeEventListener("keyUp",stage_keyUpHandler);
            this._stage = null;
         }
         this.resetState();
      }
      
      protected function stage_keyDownHandler(param1:KeyboardEvent) : void
      {
         if(!this._isEnabled)
         {
            return;
         }
         if(param1.keyCode === this._cancelKeyCode)
         {
            this._stage.removeEventListener("keyUp",stage_keyUpHandler);
            this.resetState();
         }
         else if(param1.keyCode === this._keyCode)
         {
            this._stage.addEventListener("keyUp",stage_keyUpHandler);
            this.changeState(this._downState);
         }
      }
      
      protected function stage_keyUpHandler(param1:KeyboardEvent) : void
      {
         if(!this._isEnabled)
         {
            return;
         }
         if(param1.keyCode !== this._keyCode)
         {
            return;
         }
         var _loc2_:Stage = Stage(param1.currentTarget);
         _loc2_.removeEventListener("keyUp",stage_keyUpHandler);
         if(this._stage !== _loc2_)
         {
            return;
         }
         this.resetState();
      }
   }
}
