package feathers.events
{
   import feathers.dragDrop.DragData;
   import starling.events.Event;
   
   public class DragDropEvent extends Event
   {
      
      public static const DRAG_START:String = "dragStart";
      
      public static const DRAG_COMPLETE:String = "dragComplete";
      
      public static const DRAG_ENTER:String = "dragEnter";
      
      public static const DRAG_MOVE:String = "dragMove";
      
      public static const DRAG_EXIT:String = "dragExit";
      
      public static const DRAG_DROP:String = "dragDrop";
       
      
      public var isDropped:Boolean;
      
      public var localX:Number;
      
      public var localY:Number;
      
      public function DragDropEvent(param1:String, param2:DragData, param3:Boolean, param4:Number = NaN, param5:Number = NaN)
      {
         super(param1,false,param2);
         this.isDropped = param3;
         this.localX = param4;
         this.localY = param5;
      }
      
      public function get dragData() : DragData
      {
         return DragData(this.data#2);
      }
   }
}
