package feathers.dragDrop
{
   import feathers.core.PopUpManager;
   import feathers.events.DragDropEvent;
   import flash.errors.IllegalOperationError;
   import flash.events.KeyboardEvent;
   import flash.geom.Point;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   import starling.display.Stage;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   
   public class DragDropManager
   {
      
      private static const HELPER_POINT:Point = new Point();
      
      protected static var _touchPointID:int = -1;
      
      protected static var _dragSource:IDragSource;
      
      protected static var _dragData:DragData;
      
      protected static var dropTarget:IDropTarget;
      
      protected static var isAccepted:Boolean = false;
      
      protected static var avatar:DisplayObject;
      
      protected static var avatarOffsetX:Number;
      
      protected static var avatarOffsetY:Number;
      
      protected static var dropTargetLocalX:Number;
      
      protected static var dropTargetLocalY:Number;
      
      protected static var avatarOldTouchable:Boolean;
       
      
      public function DragDropManager()
      {
         super();
      }
      
      public static function get touchPointID() : int
      {
         return _touchPointID;
      }
      
      public static function get dragSource() : IDragSource
      {
         return _dragSource;
      }
      
      public static function get isDragging() : Boolean
      {
         return _dragData != null;
      }
      
      public static function get dragData() : DragData
      {
         return _dragData;
      }
      
      public static function startDrag(param1:IDragSource, param2:Touch, param3:DragData, param4:DisplayObject = null, param5:Number = 0, param6:Number = 0) : void
      {
         if(feathers.dragDrop.DragDropManager._dragData != null)
         {
            cancelDrag();
         }
         if(!param1)
         {
            throw new ArgumentError("Drag source cannot be null.");
         }
         if(!param3)
         {
            throw new ArgumentError("Drag data cannot be null.");
         }
         _dragSource = param1;
         _dragData = param3;
         _touchPointID = param2.id#2;
         avatar = param4;
         avatarOffsetX = param5;
         avatarOffsetY = param6;
         var _loc8_:Stage = DisplayObject(param1).stage;
         param2.getLocation(_loc8_,HELPER_POINT);
         if(avatar)
         {
            avatarOldTouchable = avatar.touchable;
            avatar.touchable = false;
            avatar.x = HELPER_POINT.x + avatarOffsetX;
            avatar.y = HELPER_POINT.y + avatarOffsetY;
            PopUpManager.addPopUp(avatar,false,false);
         }
         _loc8_.addEventListener("touch",stage_touchHandler);
         var _loc7_:Starling;
         (_loc7_ = _loc8_.starling).nativeStage.addEventListener("keyDown",nativeStage_keyDownHandler,false,0,true);
         _dragSource.dispatchEvent(new DragDropEvent("dragStart",param3,false));
         updateDropTarget(HELPER_POINT);
      }
      
      public static function acceptDrag(param1:IDropTarget) : void
      {
         if(dropTarget != param1)
         {
            throw new ArgumentError("Drop target cannot accept a drag at this time. Acceptance may only happen after the DragDropEvent.DRAG_ENTER event is dispatched and before the DragDropEvent.DRAG_EXIT event is dispatched.");
         }
         isAccepted = true;
      }
      
      public static function cancelDrag() : void
      {
         if(feathers.dragDrop.DragDropManager._dragData == null)
         {
            return;
         }
         completeDrag(false);
      }
      
      protected static function completeDrag(param1:Boolean) : void
      {
         if(feathers.dragDrop.DragDropManager._dragData == null)
         {
            throw new IllegalOperationError("Drag cannot be completed because none is currently active.");
         }
         if(dropTarget)
         {
            dropTarget.dispatchEvent(new DragDropEvent("dragExit",_dragData,false,dropTargetLocalX,dropTargetLocalY));
            dropTarget = null;
         }
         var _loc3_:IDragSource = _dragSource;
         var _loc2_:DragData = _dragData;
         cleanup();
         _loc3_.dispatchEvent(new DragDropEvent("dragComplete",_loc2_,param1));
      }
      
      protected static function cleanup() : void
      {
         if(avatar)
         {
            if(PopUpManager.isPopUp(avatar))
            {
               PopUpManager.removePopUp(avatar);
            }
            avatar.touchable = avatarOldTouchable;
            avatar = null;
         }
         var _loc2_:Stage = DisplayObject(_dragSource).stage;
         var _loc1_:Starling = _loc2_.starling;
         _loc2_.removeEventListener("touch",stage_touchHandler);
         _loc1_.nativeStage.removeEventListener("keyDown",nativeStage_keyDownHandler);
         _dragSource = null;
         _dragData = null;
      }
      
      protected static function updateDropTarget(param1:Point) : void
      {
         var _loc2_:Stage = DisplayObject(_dragSource).stage;
         var _loc3_:DisplayObject = _loc2_.hitTest(param1);
         while(_loc3_ && !(_loc3_ is IDropTarget))
         {
            _loc3_ = _loc3_.parent;
         }
         if(_loc3_)
         {
            _loc3_.globalToLocal(param1,param1);
         }
         if(_loc3_ != dropTarget)
         {
            if(dropTarget)
            {
               dropTarget.dispatchEvent(new DragDropEvent("dragExit",_dragData,false,dropTargetLocalX,dropTargetLocalY));
            }
            dropTarget = IDropTarget(_loc3_);
            isAccepted = false;
            if(dropTarget)
            {
               dropTargetLocalX = param1.x;
               dropTargetLocalY = param1.y;
               dropTarget.dispatchEvent(new DragDropEvent("dragEnter",_dragData,false,dropTargetLocalX,dropTargetLocalY));
            }
         }
         else if(dropTarget)
         {
            dropTargetLocalX = param1.x;
            dropTargetLocalY = param1.y;
            dropTarget.dispatchEvent(new DragDropEvent("dragMove",_dragData,false,dropTargetLocalX,dropTargetLocalY));
         }
      }
      
      protected static function nativeStage_keyDownHandler(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == 27 || param1.keyCode == 16777238)
         {
            param1.preventDefault();
            cancelDrag();
         }
      }
      
      protected static function stage_touchHandler(param1:TouchEvent) : void
      {
         var _loc4_:Boolean = false;
         var _loc2_:Stage = Stage(param1.currentTarget);
         var _loc3_:Touch = param1.getTouch(_loc2_,null,_touchPointID);
         if(!_loc3_)
         {
            return;
         }
         if(_loc3_.phase == "moved")
         {
            _loc3_.getLocation(_loc2_,HELPER_POINT);
            if(avatar)
            {
               avatar.x = HELPER_POINT.x + avatarOffsetX;
               avatar.y = HELPER_POINT.y + avatarOffsetY;
            }
            updateDropTarget(HELPER_POINT);
         }
         else if(_loc3_.phase == "ended")
         {
            _touchPointID = -1;
            _loc4_ = false;
            if(dropTarget && isAccepted)
            {
               dropTarget.dispatchEvent(new DragDropEvent("dragDrop",_dragData,true,dropTargetLocalX,dropTargetLocalY));
               _loc4_ = true;
            }
            dropTarget = null;
            completeDrag(_loc4_);
         }
      }
   }
}
