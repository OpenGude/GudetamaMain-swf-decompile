package muku.dnd
{
   import feathers.dragDrop.DragData;
   import feathers.dragDrop.DragDropManager;
   import feathers.dragDrop.IDragSource;
   import feathers.events.DragDropEvent;
   import flash.geom.Point;
   import starling.display.Image;
   import starling.events.Event;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   import starling.textures.RenderTexture;
   
   public class DragSourceComponent extends DragDropComponent implements IDragSource
   {
       
      
      private var dragSourceListener:DragSourceListener;
      
      private var touchID:int = -1;
      
      private var avatarTexture:RenderTexture;
      
      private var offsetCenter:Boolean;
      
      private var avatar:Image;
      
      public function DragSourceComponent()
      {
         super();
         addEventListener("touch",touchHandler);
         addEventListener("dragStart",dragStartHandler);
         addEventListener("dragComplete",dragCompleteHandler);
         addEventListener("removedFromStage",onSpriteRemoved);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         dragSourceListener = null;
      }
      
      public function setDragSourceListener(param1:DragSourceListener) : void
      {
         dragSourceListener = param1;
      }
      
      private function onSpriteRemoved(param1:Event) : void
      {
         if(avatarTexture)
         {
            avatarTexture.dispose();
            avatarTexture = null;
            offsetCenter = false;
            avatarOffsetX = avatarOffsetY = 0;
         }
         if(avatar)
         {
            avatar.dispose();
            avatar = null;
         }
      }
      
      private function touchHandler(param1:TouchEvent) : void
      {
         var _loc4_:* = null;
         var _loc8_:* = null;
         var _loc5_:* = null;
         var _loc3_:* = null;
         var _loc7_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc2_:* = null;
         if(!_isEnabled)
         {
            return;
         }
         var _loc9_:* = DragDropManager;
         if(feathers.dragDrop.DragDropManager._dragData != null)
         {
            if(isInScroller())
            {
               if(_loc4_ = param1.getTouch(this,"moved"))
               {
                  _loc8_ = _loc4_.getLocation(this,_point);
                  if(!_hitArea.contains(_loc8_.x,_loc8_.y))
                  {
                     stopScrolling();
                  }
               }
            }
            return;
         }
         if(touchID >= 0)
         {
            if((_loc5_ = param1.getTouch(this,null,touchID)).phase == "moved")
            {
               _loc3_ = _loc5_.getLocation(this,_point);
               touchID = -1;
               _loc7_ = x;
               _loc6_ = y;
               x = y = 0;
               setRequiresRedraw();
               if(!avatarTexture)
               {
                  avatarTexture = new RenderTexture(width,height);
                  avatarTexture.draw(this);
               }
               if(avatar)
               {
                  avatar.dispose();
                  avatar = null;
               }
               avatar = new Image(avatarTexture);
               x = _loc7_;
               y = _loc6_;
               if(offsetCenter)
               {
                  avatarOffsetX = (_point.x - avatarTexture.width / 2) * -1;
                  avatarOffsetY = (_point.y - avatarTexture.height / 2) * -1;
               }
               _loc2_ = new DragData();
               _loc2_.setDataForFormat(mDragFormat,this);
               DragDropManager.startDrag(this,_loc5_,_loc2_,avatar,-_loc3_.x - avatarOffsetX,-_loc3_.y - avatarOffsetY);
            }
            else if(_loc5_.phase == "ended")
            {
               touchID = -1;
            }
         }
         else if(_loc5_ = param1.getTouch(this,"began"))
         {
            if(dragSourceListener == null || dragSourceListener.isDraggable(param1,this))
            {
               touchID = _loc5_.id#2;
            }
         }
      }
      
      private function dragStartHandler(param1:DragDropEvent, param2:DragData) : void
      {
         if(!_isEnabled)
         {
            return;
         }
         if(dragSourceListener)
         {
            dragSourceListener.dragStarted(param1,this);
         }
      }
      
      private function dragCompleteHandler(param1:DragDropEvent, param2:DragData) : void
      {
         if(avatarTexture)
         {
            avatarTexture.dispose();
            avatarTexture = null;
            offsetCenter = false;
            avatarOffsetX = avatarOffsetY = 0;
         }
         if(!_isEnabled)
         {
            return;
         }
         if(dragSourceListener)
         {
            dragSourceListener.dragCompleted(param1,this);
         }
      }
      
      public function setAvatarTexture(param1:Image) : void
      {
         if(avatarTexture)
         {
            avatarTexture.dispose();
            avatarTexture = null;
         }
         avatarTexture = new RenderTexture(param1.width,param1.height);
         avatarTexture.draw(param1);
      }
      
      public function setAvatarOffsetCenter() : void
      {
         offsetCenter = true;
      }
      
      public function getAvatar() : Image
      {
         return avatar;
      }
      
      override public function set enabled(param1:Boolean) : void
      {
         super.enabled = param1;
         touchID = -1;
      }
   }
}
