package gudetama.engine
{
   import feathers.dragDrop.DragDropManager;
   import flash.geom.Point;
   import muku.util.ObjectUtil;
   import starling.display.Stage;
   import starling.events.Touch;
   import starling.events.TouchProcessor;
   
   public class GudetamaTouchProcessor extends TouchProcessor
   {
      
      private static var sUpdatedTouches:Vector.<Touch> = new Vector.<Touch>(0);
      
      private static var sHoveringTouchData:Vector.<Object> = new Vector.<Object>(0);
      
      private static var sHelperPoint:Point = new Point();
       
      
      private var locked:Boolean;
      
      private var _showTouchTarget:Boolean;
      
      public function GudetamaTouchProcessor(param1:Stage)
      {
         super(param1);
      }
      
      override protected function processTouches(param1:Vector.<Touch>, param2:Boolean, param3:Boolean) : void
      {
         for each(var _loc4_ in param1)
         {
            if(_loc4_.phase == "began")
            {
               TouchEffect.show(_loc4_.globalX,_loc4_.globalY);
               break;
            }
         }
         if(locked)
         {
            return;
         }
         try
         {
            super.processTouches(param1,param2,param3);
         }
         catch(error:Error)
         {
            Logger.error("processTouches : {}, trace:{}",error,error.getStackTrace());
         }
         for each(_loc4_ in param1)
         {
            if(_showTouchTarget && _loc4_.phase == "began" && _loc4_.target != null)
            {
               Logger.debug("%%% Touch target=" + _loc4_.target + ObjectUtil.getInstanceId(_loc4_.target) + (!!_loc4_.target.hasOwnProperty("name") ? ", name:" + _loc4_.target.name#2 : "") + ", X:" + _loc4_.globalX + ", Y:" + _loc4_.globalY + "] %%%");
            }
         }
      }
      
      public function lockTouchInput() : void
      {
         locked = true;
         DragDropManager.cancelDrag();
      }
      
      public function unlockTouchInput() : void
      {
         locked = false;
      }
      
      public function isTouchInputLocked() : Boolean
      {
         return locked;
      }
      
      public function set showTouchTarget(param1:Boolean) : void
      {
         _showTouchTarget = param1;
      }
      
      public function get showTouchTarget() : Boolean
      {
         return _showTouchTarget;
      }
      
      public function toggleShowTouchTarget() : Boolean
      {
         _showTouchTarget = !_showTouchTarget;
         return _showTouchTarget;
      }
   }
}
