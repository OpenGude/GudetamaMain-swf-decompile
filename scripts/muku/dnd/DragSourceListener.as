package muku.dnd
{
   import feathers.events.DragDropEvent;
   import starling.events.TouchEvent;
   
   public interface DragSourceListener
   {
       
      
      function isDraggable(param1:TouchEvent, param2:DragSourceComponent) : Boolean;
      
      function dragStarted(param1:DragDropEvent, param2:DragSourceComponent) : void;
      
      function dragCompleted(param1:DragDropEvent, param2:DragSourceComponent) : void;
   }
}
