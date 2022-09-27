package feathers.utils.touch
{
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import starling.display.DisplayObject;
   
   public class DelayedDownTouchToState extends TouchToState
   {
       
      
      protected var _delayedCurrentState:String;
      
      protected var _stateDelayTimer:Timer;
      
      protected var _delay:Number = 0.25;
      
      public function DelayedDownTouchToState(param1:DisplayObject = null, param2:Function = null)
      {
         super(param1,param2);
      }
      
      override public function set target(param1:DisplayObject) : void
      {
         super.target = param1;
         if(this._target === null && this._stateDelayTimer !== null)
         {
            if(this._stateDelayTimer.running)
            {
               this._stateDelayTimer.stop();
            }
            this._stateDelayTimer.removeEventListener("timerComplete",stateDelayTimer_timerCompleteHandler);
            this._stateDelayTimer = null;
         }
      }
      
      public function get delay() : Number
      {
         return this._delay;
      }
      
      public function set delay(param1:Number) : void
      {
         this._delay = param1;
      }
      
      override protected function changeState(param1:String) : void
      {
         if(this._stateDelayTimer && this._stateDelayTimer.running)
         {
            this._delayedCurrentState = param1;
            return;
         }
         if(param1 === "down")
         {
            if(this._currentState === param1)
            {
               return;
            }
            this._delayedCurrentState = param1;
            if(this._stateDelayTimer)
            {
               this._stateDelayTimer.reset();
            }
            else
            {
               this._stateDelayTimer = new Timer(this._delay * 1000,1);
               this._stateDelayTimer.addEventListener("timerComplete",stateDelayTimer_timerCompleteHandler);
            }
            this._stateDelayTimer.start();
            return;
         }
         super.changeState(param1);
      }
      
      protected function stateDelayTimer_timerCompleteHandler(param1:TimerEvent) : void
      {
         super.changeState(this._delayedCurrentState);
         this._delayedCurrentState = null;
      }
   }
}
