package muku.dnd
{
   import feathers.controls.LayoutGroup;
   import feathers.controls.Scroller;
   import feathers.dragDrop.DragData;
   import feathers.dragDrop.DragDropManager;
   import feathers.dragDrop.IDropTarget;
   import feathers.events.DragDropEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import muku.core.MukuGlobal;
   import starling.display.DisplayObject;
   import starling.display.DisplayObjectContainer;
   import starling.display.Image;
   import starling.display.Quad;
   import starling.events.Event;
   import starling.rendering.Painter;
   import starling.textures.Texture;
   
   public class DragDropComponent extends LayoutGroup implements IDropTarget
   {
      
      protected static const ACCEPTING_COLOR:uint = 16777215;
      
      protected static var empty_texture:Texture;
      
      private static var mAvatarOffset:Point;
      
      protected static var _point:Point = new Point();
       
      
      protected var mDragFormat:String = "aikotoba";
      
      protected var mAcceptDrop:Boolean;
      
      protected var dropTargetListener:DropTargetListener;
      
      protected var parentTarget:DragDropComponent;
      
      protected var acceptingSign:DisplayObject;
      
      protected var signQuad:Quad;
      
      private var mDragEnteredSkin:DisplayObject;
      
      private var scroller:Scroller;
      
      protected var mAlphaWhenDisabled:Number = 0.5;
      
      public var documentData:Object;
      
      public function DragDropComponent()
      {
         super();
         dynamic = true;
         addEventListener("dragEnter",dragEnterHandler);
         addEventListener("dragExit",dragExitHandler);
         addEventListener("dragDrop",dragDropHandler);
         addEventListener("creationComplete",creationComplete);
      }
      
      public static function setEmptyTexture(param1:Image) : void
      {
         if(empty_texture == null)
         {
            empty_texture = Texture.empty(10,10,true,false);
         }
         param1.texture = empty_texture;
      }
      
      public static function hasEmptyTexture(param1:Image) : Boolean
      {
         if(empty_texture == null)
         {
            empty_texture = Texture.empty(10,10,true,false);
            return false;
         }
         return param1.texture == empty_texture;
      }
      
      override public function dispose() : void
      {
         dropTargetListener = null;
         parentTarget = null;
         acceptingSign = null;
         if(signQuad)
         {
            signQuad.dispose();
            signQuad = null;
         }
         mDragEnteredSkin = null;
         scroller = null;
         super.dispose();
      }
      
      private function creationComplete(param1:Event) : void
      {
         var _loc2_:* = null;
         if(explicitWidth !== explicitWidth || explicitHeight !== explicitHeight)
         {
            _loc2_ = null;
            if(parent.parent && parent.parent is Scroller)
            {
               scroller = parent.parent as Scroller;
               _loc2_ = parent;
            }
            else if(parent.parent && parent.parent.parent && parent.parent.parent is Scroller)
            {
               scroller = parent.parent.parent as Scroller;
               _loc2_ = parent.parent;
            }
            if(width == 0 || height == 0)
            {
               if(_loc2_)
               {
                  signQuad = new Quad(_loc2_.width,_loc2_.height,16777215);
               }
               else
               {
                  actualWidth = 1;
                  actualHeight = 1;
                  scaledActualWidth = 1;
                  scaledActualHeight = 1;
                  signQuad = new Quad(100,100,16777215);
               }
            }
            else
            {
               signQuad = new Quad(width,height,16777215);
            }
         }
         else
         {
            signQuad = new Quad(explicitWidth,explicitHeight,16777215);
         }
         signQuad.alpha = 0.5;
      }
      
      override protected function initialize() : void
      {
         parentTarget = parent as DragDropComponent;
         mAvatarOffset = new Point(0,0);
      }
      
      override public function getBounds(param1:DisplayObject, param2:Rectangle = null) : Rectangle
      {
         var _loc3_:Rectangle = super.getBounds(param1,param2);
         if(_loc3_.width == 0)
         {
            _loc3_.width = 1;
            actualWidth = 1;
            scaledActualWidth = actualWidth * Math.abs(scaleX);
         }
         if(_loc3_.height == 0)
         {
            _loc3_.height = 1;
            actualHeight = 1;
            scaledActualHeight = actualHeight * Math.abs(scaleY);
         }
         return _loc3_;
      }
      
      override public function hitTest(param1:Point) : DisplayObject
      {
         var _loc4_:Number = param1.x;
         var _loc3_:Number = param1.y;
         var _loc2_:DisplayObject = super.hitTest(param1);
         if(_loc2_)
         {
            if(!this._isEnabled)
            {
               return this;
            }
            return _loc2_;
         }
         if(!this.visible || !this.touchable)
         {
            return null;
         }
         if(this._hitArea.contains(_loc4_,_loc3_))
         {
            return this;
         }
         return null;
      }
      
      override public function render(param1:Painter) : void
      {
         super.render(param1);
         if(acceptingSign)
         {
            param1.pushState();
            param1.setStateTo(acceptingSign.transformationMatrix,acceptingSign.alpha,acceptingSign.blendMode);
            acceptingSign.render(param1);
            param1.popState();
         }
      }
      
      protected function isInScroller() : Boolean
      {
         return scroller != null || parentTarget && parentTarget.scroller != null;
      }
      
      protected function stopScrolling() : void
      {
         if(scroller && scroller.isScrolling)
         {
            scroller.stopScrolling();
         }
         else if(parentTarget)
         {
            parentTarget.stopScrolling();
         }
      }
      
      public function canDropTo(param1:DragDropComponent) : Boolean
      {
         if(param1 == null || !param1.isEnabled)
         {
            return false;
         }
         if(this == param1)
         {
            return false;
         }
         if(!mAcceptDrop)
         {
            if(parentTarget == param1)
            {
               return false;
            }
            if(!param1.mAcceptDrop && parentTarget == param1.parentTarget)
            {
               return false;
            }
         }
         return true;
      }
      
      public function setDropTargetListener(param1:DropTargetListener) : void
      {
         dropTargetListener = param1;
      }
      
      protected function dragEnterHandler(param1:DragDropEvent, param2:DragData) : void
      {
         var _loc3_:* = null;
         if(!_isEnabled)
         {
            return;
         }
         if(!param2.hasDataForFormat(mDragFormat))
         {
            return;
         }
         if(mAcceptDrop)
         {
            if(dropTargetListener)
            {
               _loc3_ = DragSourceComponent(param2.getDataForFormat(mDragFormat));
               if(dropTargetListener.dragEnter(param1,_loc3_))
               {
                  DragDropManager.acceptDrag(param1.target as DragDropComponent);
                  if(!MukuGlobal.isBuilderMode())
                  {
                     if(!MukuGlobal.tweenAnimator.startItselfWithoutFinish(this,"enter_drop"))
                     {
                        acceptingSign = !!mDragEnteredSkin ? mDragEnteredSkin : signQuad;
                     }
                  }
                  else
                  {
                     acceptingSign = !!mDragEnteredSkin ? mDragEnteredSkin : signQuad;
                  }
               }
            }
            else
            {
               DragDropManager.acceptDrag(param1.target as DragDropComponent);
               if(!MukuGlobal.isBuilderMode())
               {
                  if(!MukuGlobal.tweenAnimator.startItselfWithoutFinish(this,"enter_drop"))
                  {
                     acceptingSign = !!mDragEnteredSkin ? mDragEnteredSkin : signQuad;
                  }
               }
               else
               {
                  acceptingSign = !!mDragEnteredSkin ? mDragEnteredSkin : signQuad;
               }
            }
         }
         else if(parentTarget)
         {
            parentTarget.dragEnterHandler(param1,param2);
         }
         setRequiresRedraw();
      }
      
      protected function dragExitHandler(param1:DragDropEvent, param2:DragData) : void
      {
         var _loc3_:* = null;
         if(!_isEnabled)
         {
            return;
         }
         if(mAcceptDrop)
         {
            if(dropTargetListener)
            {
               _loc3_ = DragSourceComponent(param2.getDataForFormat(mDragFormat));
               dropTargetListener.dragExit(param1,_loc3_);
            }
            if(!MukuGlobal.isBuilderMode())
            {
               if(!MukuGlobal.tweenAnimator.startItselfWithoutFinish(this,"exit_drop"))
               {
                  acceptingSign = null;
               }
            }
            else
            {
               acceptingSign = null;
            }
         }
         else if(parentTarget)
         {
            parentTarget.dragExitHandler(param1,param2);
         }
         setRequiresRedraw();
      }
      
      protected function dragDropHandler(param1:DragDropEvent, param2:DragData) : void
      {
         var _loc3_:* = null;
         if(!_isEnabled)
         {
            return;
         }
         if(mAcceptDrop)
         {
            if(dropTargetListener)
            {
               _loc3_ = DragSourceComponent(param2.getDataForFormat(mDragFormat));
               dropTargetListener.dropped(param1,_loc3_);
            }
            if(!MukuGlobal.isBuilderMode())
            {
               if(!MukuGlobal.tweenAnimator.startItselfWithoutFinish(this,"exit_drop"))
               {
                  acceptingSign = null;
               }
            }
            else
            {
               acceptingSign = null;
            }
         }
         else if(parentTarget)
         {
            parentTarget.dragDropHandler(param1,param2);
         }
      }
      
      public function isEmpty() : Boolean
      {
         return documentData == null;
      }
      
      public function clearData() : void
      {
         documentData = null;
      }
      
      public function get avatarOffsetX() : int
      {
         return mAvatarOffset.x;
      }
      
      public function set avatarOffsetX(param1:int) : void
      {
         mAvatarOffset.x = param1;
      }
      
      public function get avatarOffsetY() : int
      {
         return mAvatarOffset.y;
      }
      
      public function set avatarOffsetY(param1:int) : void
      {
         mAvatarOffset.y = param1;
      }
      
      public function get dragFormat() : String
      {
         return mDragFormat;
      }
      
      public function set dragFormat(param1:String) : void
      {
         mDragFormat = param1;
      }
      
      public function get acceptDrop() : Boolean
      {
         return mAcceptDrop;
      }
      
      public function set acceptDrop(param1:Boolean) : void
      {
         mAcceptDrop = param1;
      }
      
      public function get dragEnteredSkin() : DisplayObject
      {
         return mDragEnteredSkin;
      }
      
      public function set dragEnteredSkin(param1:DisplayObject) : void
      {
         mDragEnteredSkin = param1;
      }
      
      public function get alphaWhenDisabled() : Number
      {
         return mAlphaWhenDisabled;
      }
      
      public function set alphaWhenDisabled(param1:Number) : void
      {
         mAlphaWhenDisabled = param1;
      }
      
      public function get enabled() : Boolean
      {
         return _isEnabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         isEnabled = param1;
      }
   }
}
