package feathers.controls.popups
{
   import feathers.core.IFeathersEventDispatcher;
   import starling.display.DisplayObject;
   
   public interface IPopUpContentManager extends IFeathersEventDispatcher
   {
       
      
      function get isOpen() : Boolean;
      
      function open(param1:DisplayObject, param2:DisplayObject) : void;
      
      function close() : void;
      
      function dispose() : void;
   }
}
