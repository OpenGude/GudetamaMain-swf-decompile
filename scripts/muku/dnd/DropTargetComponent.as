package muku.dnd
{
   public class DropTargetComponent extends DragDropComponent
   {
       
      
      private var mNumContents:int;
      
      private var mCapacity:int;
      
      public function DropTargetComponent()
      {
         super();
         mAcceptDrop = true;
      }
      
      public function get numContents() : int
      {
         return mNumContents;
      }
      
      public function get capacity() : int
      {
         return mCapacity;
      }
      
      public function set capacity(param1:int) : void
      {
         mCapacity = param1;
      }
   }
}
