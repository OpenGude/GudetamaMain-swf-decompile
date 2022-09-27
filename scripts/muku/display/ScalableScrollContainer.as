package muku.display
{
   import feathers.controls.LayoutGroup;
   import feathers.controls.ScrollContainer;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import starling.animation.IAnimatable;
   import starling.core.Starling;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   
   public class ScalableScrollContainer extends ScrollContainer implements IAnimatable
   {
      
      private static const STATE_DISABEL:int = -1;
      
      private static const STATE_NONE:int = 0;
      
      private static const STATE_MOVE:int = 1;
      
      private static const STATE_SCALE:int = 2;
       
      
      private var state:int = 0;
      
      private var target:Sprite;
      
      private var deltaMovePoint:Point;
      
      private var dtVec:Point;
      
      private var targetPaddingLeft:Number;
      
      private var targetPaddingRight:Number;
      
      private var targetPaddingTop:Number;
      
      private var targetPaddingBottom:Number;
      
      private var targetBounds:Rectangle;
      
      public var useSwipe:Boolean = true;
      
      public function ScalableScrollContainer()
      {
         dtVec = new Point();
         super();
         state = 0;
         var _loc1_:* = Starling;
         (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).add(this);
         this.addEventListener("touch",scroller_touchHandler);
      }
      
      override public function dispose() : void
      {
         var _loc1_:* = Starling;
         (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).remove(this);
         super.dispose();
      }
      
      public function setTargetPadding(param1:Number, param2:Number, param3:Number, param4:Number) : void
      {
         targetPaddingLeft = param1;
         targetPaddingRight = param2;
         targetPaddingTop = param3;
         targetPaddingBottom = param4;
         reviseInTarget();
      }
      
      public function setup(param1:Sprite) : void
      {
         target = param1;
         horizontalScrollPolicy = "off";
         verticalScrollPolicy = "off";
         hasElasticEdges = false;
         readjustLayout();
         validate();
         updateViewPort();
         var _loc2_:LayoutGroup = viewPort as LayoutGroup;
         _loc2_.x = width / 2;
         _loc2_.y = height / 2;
         _loc2_.alignPivot();
         var _loc3_:Quad = _loc2_.mask as Quad;
         _loc3_ = new Quad(1,1,1044735);
         _loc2_.mask = _loc3_;
         _loc3_.x = _loc2_.pivotX - _loc2_.x;
         _loc3_.y = _loc2_.pivotY - _loc2_.y;
         _loc3_.width = width;
         _loc3_.height = height;
         target.x = _loc2_.width / 2;
         target.y = _loc2_.height / 2;
         target.alignPivot();
         targetBounds = target.bounds;
      }
      
      public function reviseInTarget() : void
      {
         if(!targetBounds)
         {
            return;
         }
         if(targetBounds.x + viewPort.x - viewPort.pivotX >= targetPaddingLeft)
         {
            viewPort.x = viewPort.pivotX - targetBounds.x + targetPaddingLeft;
         }
         else if(Math.abs(targetBounds.x + viewPort.x - viewPort.pivotX - actualWidth) >= targetBounds.width + targetPaddingRight)
         {
            viewPort.x = viewPort.pivotX - targetBounds.right + actualWidth - targetPaddingRight;
         }
         if(targetBounds.y + viewPort.y - viewPort.pivotY >= targetPaddingTop)
         {
            viewPort.y = viewPort.pivotY - targetBounds.y + targetPaddingTop;
         }
         else if(Math.abs(targetBounds.y + viewPort.y - viewPort.pivotY - actualHeight) >= targetBounds.height + targetPaddingBottom)
         {
            viewPort.y = viewPort.pivotY - targetBounds.bottom + actualHeight - targetPaddingBottom;
         }
         var _loc1_:Quad = viewPort.mask as Quad;
         _loc1_.x = viewPort.pivotX - viewPort.x;
         _loc1_.y = viewPort.pivotY - viewPort.y;
      }
      
      public function advanceTime(param1:Number) : void
      {
         reviseInTarget();
         if(state == 0 || state == -1)
         {
            return;
         }
         if(state == 1 && deltaMovePoint)
         {
            if(dtVec.x < 0.03 && dtVec.y < 0.03)
            {
               return;
            }
            viewPort.x += deltaMovePoint.x * dtVec.x;
            viewPort.y += deltaMovePoint.y * dtVec.y;
            dtVec.x -= dtVec.x * 0.04;
            dtVec.y -= dtVec.y * 0.04;
            if(dtVec.x < 0.03 && dtVec.y < 0.03)
            {
               finishTouch();
            }
         }
      }
      
      override protected function scroller_touchHandler(param1:TouchEvent) : void
      {
         var _loc9_:* = undefined;
         var _loc6_:* = null;
         var _loc4_:* = null;
         var _loc10_:* = null;
         var _loc12_:* = null;
         var _loc13_:* = null;
         var _loc8_:* = null;
         var _loc3_:* = null;
         var _loc2_:* = null;
         var _loc5_:* = null;
         var _loc15_:* = null;
         var _loc11_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc7_:* = NaN;
         var _loc14_:Number = NaN;
         if(state == -1)
         {
            return;
         }
         if((_loc9_ = param1.getTouches(this,"ended")).length > 0)
         {
            if(state == 2)
            {
               finishTouch();
            }
            else
            {
               dispatchEventWith("triggered",false,param1.target);
            }
         }
         if((_loc9_ = param1.getTouches(this,"began")).length == 1 && state != 1)
         {
            state = 1;
         }
         if((_loc9_ = param1.getTouches(this,"moved")).length == 1 && state == 1)
         {
            state = 1;
            deltaMovePoint = _loc9_[0].getMovement(viewPort as LayoutGroup,deltaMovePoint);
            if(deltaMovePoint.x > 0)
            {
               deltaMovePoint.x = Math.min(deltaMovePoint.x,25);
            }
            else
            {
               deltaMovePoint.x = Math.max(deltaMovePoint.x,-25);
            }
            if(deltaMovePoint.y > 0)
            {
               deltaMovePoint.y = Math.min(deltaMovePoint.y,25);
            }
            else
            {
               deltaMovePoint.y = Math.max(deltaMovePoint.y,-25);
            }
            dtVec.setTo(1,1);
         }
         else if(useSwipe && _loc9_.length == 2)
         {
            _loc6_ = _loc9_[0];
            _loc4_ = _loc9_[1];
            _loc10_ = _loc6_.getLocation(viewPort as LayoutGroup);
            _loc12_ = _loc4_.getLocation(viewPort as LayoutGroup);
            _loc13_ = _loc6_.getPreviousLocation(target);
            _loc8_ = _loc4_.getPreviousLocation(target);
            if(state != 2)
            {
               state = 2;
               target.pivotX = (_loc13_.x + _loc8_.x) * 0.5;
               target.pivotY = (_loc13_.y + _loc8_.y) * 0.5;
               target.x = (_loc10_.x + _loc12_.x) * 0.5;
               target.y = (_loc10_.y + _loc12_.y) * 0.5;
            }
            _loc3_ = _loc6_.getPreviousLocation(viewPort as LayoutGroup);
            _loc2_ = _loc4_.getPreviousLocation(viewPort as LayoutGroup);
            _loc5_ = _loc10_.subtract(_loc12_);
            _loc15_ = _loc3_.subtract(_loc2_);
            _loc11_ = _loc5_.length / _loc15_.length;
            _loc16_ = target.scaleX;
            _loc7_ = Number(target.scaleX * _loc11_);
            if(_loc16_ > _loc7_)
            {
               target.scaleX = _loc7_;
               if(target.width <= actualWidth - (targetPaddingLeft + targetPaddingRight))
               {
                  target.width = actualWidth - (targetPaddingLeft + targetPaddingRight);
               }
            }
            else
            {
               if(_loc7_ <= 1)
               {
                  target.scaleX = _loc7_;
               }
               if(target.scaleX > 1)
               {
                  target.scaleX = 1;
               }
            }
            _loc16_ = target.scaleY;
            _loc7_ = Number(target.scaleY * _loc11_);
            if(_loc16_ > _loc7_)
            {
               target.scaleY = _loc7_;
               if(target.height <= actualHeight - (targetPaddingTop * 2 + targetPaddingBottom * 2) / 2)
               {
                  target.height = actualHeight - (targetPaddingTop * 2 + targetPaddingBottom * 2) / 2;
               }
            }
            else
            {
               if(_loc7_ <= 1)
               {
                  target.scaleY = _loc7_;
               }
               if(target.scaleY > 1)
               {
                  target.scaleY = 1;
               }
            }
            targetBounds = target.bounds;
            if((_loc14_ = targetBounds.x + viewPort.x - viewPort.pivotX) >= targetPaddingLeft)
            {
               viewPort.x = viewPort.pivotX - targetBounds.x + targetPaddingLeft;
               viewPort.mask.x = viewPort.pivotX - viewPort.x;
            }
            else if(Math.abs(_loc14_ - actualWidth) >= targetBounds.width + targetPaddingRight)
            {
               viewPort.x = viewPort.pivotX - targetBounds.right + actualWidth - targetPaddingRight;
               viewPort.mask.x = viewPort.pivotX - viewPort.x;
            }
            if((_loc14_ = targetBounds.y + viewPort.y - viewPort.pivotY) >= targetPaddingTop)
            {
               viewPort.y = viewPort.pivotY - targetBounds.y + targetPaddingTop;
               viewPort.mask.y = viewPort.pivotY - viewPort.y;
            }
            else if(Math.abs(_loc14_ - actualHeight) >= targetBounds.height + targetPaddingBottom)
            {
               viewPort.y = viewPort.pivotY - targetBounds.bottom + actualHeight - targetPaddingBottom;
               viewPort.mask.y = viewPort.pivotY - viewPort.y;
            }
            if(_loc7_ > 1)
            {
               _loc7_ = 1;
            }
         }
      }
      
      public function manualScalable(param1:Number) : void
      {
         viewPort.x += (param1 - target.scaleX) / target.scaleX * (viewPort.x - pivotX);
         viewPort.y += (param1 - target.scaleY) / target.scaleY * (viewPort.y - pivotY);
         target.scaleX = param1;
         target.scaleY = param1;
         if(target.bounds.width > width || target.bounds.height > height)
         {
            targetBounds = target.bounds;
         }
         var _loc2_:Number = targetBounds.x + viewPort.x - viewPort.pivotX;
         if(_loc2_ >= targetPaddingLeft)
         {
            viewPort.x = viewPort.pivotX - targetBounds.x + targetPaddingLeft;
            viewPort.mask.x = viewPort.pivotX - viewPort.x;
         }
         else if(Math.abs(_loc2_ - actualWidth) >= targetBounds.width + targetPaddingRight)
         {
            viewPort.x = viewPort.pivotX - targetBounds.right + actualWidth - targetPaddingRight;
            viewPort.mask.x = viewPort.pivotX - viewPort.x;
         }
         _loc2_ = targetBounds.y + viewPort.y - viewPort.pivotY;
         if(_loc2_ >= targetPaddingTop)
         {
            viewPort.y = viewPort.pivotY - targetBounds.y + targetPaddingTop;
            viewPort.mask.y = viewPort.pivotY - viewPort.y;
         }
         else if(Math.abs(_loc2_ - actualHeight) >= targetBounds.height + targetPaddingBottom)
         {
            viewPort.y = viewPort.pivotY - targetBounds.bottom + actualHeight - targetPaddingBottom;
            viewPort.mask.y = viewPort.pivotY - viewPort.y;
         }
      }
      
      public function updateViewPort() : void
      {
         super.refreshViewPort(true);
      }
      
      public function finishTouch() : void
      {
         if(state != -1)
         {
            state = 0;
         }
      }
      
      public function disable(param1:Boolean) : void
      {
         if(param1)
         {
            state = -1;
         }
         else
         {
            state = 0;
         }
      }
      
      override public function get isScrolling() : Boolean
      {
         if(state == 1 && deltaMovePoint)
         {
            return (dtVec.x > 0.5 || dtVec.y > 0.5) && (deltaMovePoint.x > 5 || deltaMovePoint.y > 5);
         }
         return false;
      }
      
      override protected function refreshMask() : void
      {
      }
      
      override protected function refreshViewPort(param1:Boolean) : void
      {
      }
      
      override protected function draw() : void
      {
      }
   }
}
