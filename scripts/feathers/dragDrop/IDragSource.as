package feathers.dragDrop
{
   import starling.events.Event;
   
   public interface IDragSource
   {
       
      
      function dispatchEvent(param1:Event) : void;
      
      function dispatchEventWith(param1:String, param2:Boolean = false, param3:Object = null) : void;
   }
}
