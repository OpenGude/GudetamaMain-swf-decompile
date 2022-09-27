package starlingbuilder.engine.tween
{
   import flash.utils.Dictionary;
   import starling.display.DisplayObject;
   
   public interface ITweenBuilder
   {
       
      
      function start(param1:DisplayObject, param2:Dictionary, param3:Array = null) : void;
      
      function stop(param1:DisplayObject, param2:Dictionary = null, param3:Array = null) : void;
   }
}
