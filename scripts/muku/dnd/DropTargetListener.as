package muku.dnd
{
   import feathers.events.DragDropEvent;
   
   public interface DropTargetListener
   {
       
      
      function dragEnter(param1:DragDropEvent, param2:DragSourceComponent) : Boolean;
      
      function dragExit(param1:DragDropEvent, param2:DragSourceComponent) : void;
      
      function dropped(param1:DragDropEvent, param2:DragSourceComponent) : void;
   }
}
