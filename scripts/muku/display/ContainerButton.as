package muku.display
{
   import flash.display.BitmapData;
   import flash.events.ErrorEvent;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.ui.Mouse;
   import muku.core.MukuGlobal;
   import muku.text.ColorTextField;
   import muku.util.StarlingUtil;
   import starling.animation.Tween;
   import starling.core.Starling;
   import starling.display.Button;
   import starling.display.DisplayObject;
   import starling.display.DisplayObjectContainer;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   import starling.filters.FragmentFilter;
   import starling.rendering.Painter;
   import starling.text.TextField;
   import starling.textures.Texture;
   import starling.utils.MatrixUtil;
   
   public class ContainerButton extends Sprite
   {
      
      private static const MAX_DRAG_DIST:Number = 52;
      
      private static const MAX_DRAG_DIST2:Number = 26;
      
      private static const DRAG_DRIFT:int = 13;
      
      private static const DRAG_DRIFT_SQR:int = 169;
      
      private static var sHelperMatrix:Matrix = new Matrix();
      
      private static var sHelperPoint:Point = new Point();
       
      
      private var buttonTypeValue:int = 0;
      
      private var buttonTypeText:String;
      
      protected var mState:String;
      
      private var mEnabled:Boolean;
      
      private var recentDisabled:Boolean;
      
      private var mTriggerBounds:Rectangle;
      
      private var mUpState:Texture;
      
      private var back:Image;
      
      protected var mAlphaWhenDisabled:Number;
      
      private var mBackColor:uint = 16777215;
      
      private var actualHeight:Number = 100;
      
      private var actualWidth:Number = 100;
      
      private var pressTween:Tween;
      
      private var releaseTween:Tween;
      
      private var currTween:Tween;
      
      private var origX:Number;
      
      private var origY:Number;
      
      private var drawCache:Image = null;
      
      private var drawCacheObjects:Array;
      
      private var scrollStartX:Number;
      
      private var scrollStartY:Number;
      
      private var mHelperObject:Object = null;
      
      private var stopPropagate:Boolean;
      
      private var hitmargin_X:int = 0;
      
      private var hitmargin_Width:int = 0;
      
      private var hitmargin_upper_Y:int = 0;
      
      private var hitmargin_lower_Y:int = 0;
      
      private var disableColor:int = 12500670;
      
      private var mindex:int;
      
      private var movedCancel:Boolean;
      
      private var offsetScaleX:Number = 0;
      
      private var offsetScaleY:Number = 0;
      
      public function ContainerButton(param1:Texture)
      {
         buttonTypeText = ImageButton.TYPE_STRINGS[buttonTypeValue];
         drawCacheObjects = [];
         super();
         actualWidth = param1.width;
         actualHeight = param1.height;
         back = new Image(param1);
         pressTween = new Tween(this,0.02,"easeOutBack");
         releaseTween = new Tween(this,0.02,"easeOutBack");
         currTween = null;
         mAlphaWhenDisabled = 1;
         mTriggerBounds = new Rectangle();
         mEnabled = true;
         addEventListener("touch",onTouch);
         addEventListener("removedFromStage",onRemoved);
         x = 0;
         y = 0;
         dynamic = true;
         if(!MukuGlobal.isBuilderMode())
         {
            if(MukuGlobal.engine.isMobilePlatform())
            {
               hitmargin_X = 3;
               hitmargin_upper_Y = 10;
               hitmargin_lower_Y = 10;
            }
         }
      }
      
      private function onRemoved(param1:Event) : void
      {
         if(currTween)
         {
            currTween.dispatchEventWith("removeFromJuggler");
            currTween = null;
            scaleX = 1;
            scaleY = 1;
            x = origX;
            y = origY;
         }
      }
      
      override public function getBounds(param1:DisplayObject, param2:Rectangle = null) : Rectangle
      {
         if(param2 == null)
         {
            param2 = new Rectangle();
         }
         getTransformationMatrix(param1,sHelperMatrix);
         MatrixUtil.transformCoords(sHelperMatrix,0,0,sHelperPoint);
         param2.setTo(sHelperPoint.x,sHelperPoint.y,back.width * scaleX,back.height * scaleY);
         return param2;
      }
      
      override public function hitTest(param1:Point) : DisplayObject
      {
         if(!visible || !touchable)
         {
            return null;
         }
         if(!hitTestMask(param1))
         {
            return null;
         }
         var _loc3_:Number = param1.x;
         var _loc2_:Number = param1.y;
         var _loc4_:DisplayObject;
         if(_loc4_ = super.hitTest(param1))
         {
            return _loc4_;
         }
         if(_loc3_ >= -hitmargin_X && _loc3_ < back.width + hitmargin_X + hitmargin_Width && _loc2_ >= -hitmargin_lower_Y && _loc2_ < back.height + hitmargin_upper_Y)
         {
            return this;
         }
         return null;
      }
      
      private function _disposeRsrc(param1:DisplayObjectContainer) : void
      {
         var _loc3_:int = 0;
         var _loc4_:* = null;
         var _loc2_:int = param1.numChildren;
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            if((_loc4_ = param1.getChildAt(_loc3_)) is ColorTextField && !_loc4_.dynamic)
            {
               (_loc4_ as ColorTextField).flush();
            }
            else if(!(_loc4_ is Button || _loc4_ is Particle))
            {
               if(!(_loc4_ is TextField || _loc4_ is Image))
               {
                  if(_loc4_ is Sprite)
                  {
                     _disposeRsrc(_loc4_ as DisplayObjectContainer);
                  }
               }
            }
            _loc3_++;
         }
      }
      
      public function setTouchMovedCancel(param1:Boolean) : void
      {
         movedCancel = param1;
      }
      
      public function setTweenDisable() : void
      {
         pressTween = null;
         releaseTween = null;
      }
      
      public function setEnableWithDrawCache(param1:Boolean, param2:Boolean = false, param3:Boolean = false) : void
      {
         enableDrawCache(!param1,param2,param3);
         enabled = param1;
      }
      
      public function enableDrawCache(param1:Boolean = true, param2:Boolean = false, param3:Boolean = false) : void
      {
         var _loc5_:* = null;
         var _loc4_:* = null;
         if(MukuGlobal.isBuilderMode())
         {
            return;
         }
         disposeDrawcache();
         if(param1)
         {
            drawCacheObjects.length = 0;
            _loc5_ = MukuGlobal.imageUtil.convertToBitmapData(this,back.width,back.height,drawCacheObjects);
            var _loc6_:* = Starling;
            _loc4_ = Texture.fromBitmapData(_loc5_,false,false,!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent.contentScaleFactor : 1,"bgra",false);
            drawCache = new Image(_loc4_);
            if(mState == "disabled" || param3)
            {
               drawCache.color = disableColor;
               setRequiresRedraw();
            }
            if(param2)
            {
               _disposeRsrc(this);
            }
         }
         setRequiresRedraw();
      }
      
      private function errorHander(param1:ErrorEvent, param2:BitmapData) : void
      {
         MukuGlobal.logger.error("enableDrawCache async error : {}",param1.toString());
         var _loc3_:* = Starling;
         drawCache = new Image(Texture.fromBitmapData(param2,false,false,!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent.contentScaleFactor : 1));
      }
      
      private function disposeDrawcache() : void
      {
         if(!drawCache)
         {
            return;
         }
         drawCache.texture.dispose();
         drawCache.dispose();
         drawCache = null;
      }
      
      private function _render(param1:Painter) : void
      {
         var _loc3_:String = param1.state.blendMode;
         var _loc2_:FragmentFilter = back.filter;
         var _loc4_:DisplayObject = back.mask;
         param1.pushState();
         param1.setStateTo(back.transformationMatrix,this.alpha,back.blendMode);
         if(_loc4_)
         {
            param1.drawMask(_loc4_);
         }
         if(_loc2_)
         {
            _loc2_.render(param1);
         }
         else
         {
            back.render(param1);
         }
         if(_loc4_)
         {
            param1.eraseMask(_loc4_);
         }
         param1.popState();
         super.render(param1);
      }
      
      override public function render(param1:Painter) : void
      {
         if(drawCache)
         {
            MukuGlobal.imageUtil.renderDrawCache(param1,alpha,drawCache,drawCacheObjects);
         }
         else
         {
            _render(param1);
         }
      }
      
      private function refreshState() : void
      {
         var _loc2_:Number = NaN;
         var _loc1_:Number = NaN;
         var _loc3_:Number = NaN;
         switch(mState)
         {
            case "down":
               if(currTween)
               {
                  if(currTween == pressTween)
                  {
                     break;
                  }
                  currTween.dispatchEventWith("removeFromJuggler");
                  currTween = null;
               }
               if(!MukuGlobal.isBuilderMode())
               {
                  if(!MukuGlobal.tweenAnimator.startItselfWithoutFinish(this,"pressed"))
                  {
                     MukuGlobal.tweenAnimator.finishTween(this);
                  }
                  break;
               }
               if(pressTween)
               {
                  _loc2_ = (16 + offsetScaleX + width) / width;
                  _loc1_ = (16 + offsetScaleY + height) / height;
                  _loc3_ = _loc2_ > _loc1_ ? _loc1_ : Number(_loc2_);
                  pressTween.reset(this,0.08,"easeOutBack");
                  pressTween.animate("scaleX",_loc3_);
                  pressTween.animate("scaleY",_loc3_);
                  pressTween.animate("x",origX + (1 - _loc3_) / 2 * actualWidth);
                  pressTween.animate("y",origY + (1 - _loc3_) / 2 * actualHeight);
                  pressTween.onComplete = createTweenCompleteFunction();
                  currTween = pressTween;
                  var _loc4_:* = Starling;
                  starling.core.Starling.sCurrent.juggler.add(currTween);
               }
               break;
            case "up":
               if(recentDisabled)
               {
                  recentDisabled = false;
                  if(!MukuGlobal.isBuilderMode())
                  {
                     if(!MukuGlobal.tweenAnimator.startItselfWithoutFinish(this,"enabled"))
                     {
                        if(mAlphaWhenDisabled < 1)
                        {
                           alpha = 1;
                        }
                     }
                  }
                  else
                  {
                     alpha = 1;
                  }
               }
               if(currTween)
               {
                  if(currTween == releaseTween)
                  {
                     break;
                  }
                  currTween.dispatchEventWith("removeFromJuggler");
                  currTween = null;
               }
               if(!MukuGlobal.isBuilderMode())
               {
                  if(!MukuGlobal.tweenAnimator.startItselfWithoutFinish(this,"released"))
                  {
                     MukuGlobal.tweenAnimator.finishTween(this);
                  }
                  break;
               }
               if(releaseTween)
               {
                  releaseTween.reset(this,0.05,"easeOutBack");
                  releaseTween.animate("scaleX",1);
                  releaseTween.animate("scaleY",1);
                  releaseTween.animate("x",origX);
                  releaseTween.animate("y",origY);
                  releaseTween.onComplete = createTweenCompleteFunction();
                  currTween = releaseTween;
                  var _loc5_:* = Starling;
                  starling.core.Starling.sCurrent.juggler.add(currTween);
               }
               break;
            case "over":
               break;
            case "disabled":
               recentDisabled = true;
               if(MukuGlobal.isBuilderMode())
               {
                  alpha = mAlphaWhenDisabled;
               }
               else if(!MukuGlobal.tweenAnimator.startItselfWithoutFinish(this,"disabled"))
               {
                  if(mAlphaWhenDisabled < 1)
                  {
                     alpha = mAlphaWhenDisabled;
                  }
               }
               break;
            default:
               throw new ArgumentError("Invalid button state: " + mState);
         }
      }
      
      private function createTweenCompleteFunction() : Function
      {
         return function():void
         {
            currTween = null;
         };
      }
      
      public function get state() : String
      {
         return mState;
      }
      
      public function set state(param1:String) : void
      {
         mState = param1;
         refreshState();
      }
      
      public function get index() : int
      {
         return mindex;
      }
      
      public function set index(param1:int) : void
      {
         mindex = param1;
      }
      
      protected function onTouch(param1:TouchEvent) : void
      {
         var _loc6_:Boolean = false;
         var _loc7_:* = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         Mouse.cursor = enabled && param1.interactsWith(this) ? "button" : "auto";
         var _loc5_:Touch = param1.getTouch(this);
         var _loc2_:DisplayObject = StarlingUtil.findParentScroller(parent);
         if(stopPropagate)
         {
            param1.stopPropagation();
         }
         if(!enabled)
         {
            return;
         }
         if(_loc5_ == null)
         {
            if(mState == "down")
            {
               state = "up";
            }
         }
         else if(_loc5_.phase == "moved" && movedCancel)
         {
            _loc7_ = StarlingUtil.getPointFromPool();
            _loc5_.getMovement(parent,_loc7_);
            if(_loc7_.x > 4 || _loc7_.x < -4)
            {
               _loc5_.cancelled = true;
            }
            if(_loc7_.y > 4 || _loc7_.y < -4)
            {
               _loc5_.cancelled = true;
            }
         }
         else if(_loc5_.phase == "hover")
         {
            state = "over";
         }
         else if(_loc5_.phase == "began" && mState != "down")
         {
            mTriggerBounds = getBounds(stage,mTriggerBounds);
            if(_loc2_)
            {
               scrollStartX = _loc2_.x;
               scrollStartY = _loc2_.y;
               mTriggerBounds.inflate(26,26);
            }
            else
            {
               mTriggerBounds.inflate(52,52);
            }
            state = "down";
         }
         else if(_loc5_.phase == "moved")
         {
            _loc6_ = mTriggerBounds.contains(_loc5_.globalX,_loc5_.globalY);
            if(_loc2_ && mState == "down")
            {
               if(!_loc6_)
               {
                  state = "up";
               }
               else
               {
                  _loc3_ = scrollStartX - _loc2_.x;
                  _loc4_ = scrollStartY - _loc2_.y;
                  if(_loc3_ * _loc3_ + _loc4_ * _loc4_ > 169)
                  {
                     state = "up";
                  }
               }
            }
            else if(mState == "down" && !_loc6_)
            {
               state = "up";
            }
            else if(mState == "up" && _loc6_ && _loc2_ == null)
            {
               state = "down";
            }
         }
         else if(_loc5_.phase == "ended" && mState == "down")
         {
            state = "up";
            if(!MukuGlobal.isBuilderMode() && buttonTypeValue >= 0 && buttonTypeValue < ImageButton.TYPE_SOUND_EFFECT.length)
            {
               MukuGlobal.soundManager.playEffect(ImageButton.TYPE_SOUND_EFFECT[buttonTypeValue]);
            }
            if(!_loc5_.cancelled)
            {
               dispatchEventWith("triggered",true);
            }
         }
      }
      
      override public function set x(param1:Number) : void
      {
         super.x = param1;
         if(currTween == null)
         {
            origX = x;
         }
      }
      
      override public function set y(param1:Number) : void
      {
         super.y = param1;
         if(currTween == null)
         {
            origY = y;
         }
      }
      
      public function setStopPropagation(param1:Boolean) : void
      {
         stopPropagate = param1;
      }
      
      public function setHitMargin(param1:int, param2:int) : void
      {
         if(!MukuGlobal.isBuilderMode())
         {
            if(MukuGlobal.engine.isMobilePlatform())
            {
               hitmargin_X = param1;
               hitmargin_upper_Y = hitmargin_lower_Y = param2;
            }
         }
      }
      
      public function setHitMarginForce(param1:int, param2:int) : void
      {
         if(!MukuGlobal.isBuilderMode())
         {
            hitmargin_X = param1;
            hitmargin_upper_Y = hitmargin_lower_Y = param2;
         }
      }
      
      public function setHitMarginWidth(param1:int, param2:int, param3:int) : void
      {
         if(!MukuGlobal.isBuilderMode())
         {
            hitmargin_X = param1;
            hitmargin_upper_Y = hitmargin_lower_Y = param2;
            hitmargin_Width = param3;
         }
      }
      
      override public function set width(param1:Number) : void
      {
         if(param1 <= 0)
         {
            return;
         }
         actualWidth = param1;
         back.width = actualWidth;
         back.readjustSize();
         super.width = param1;
      }
      
      override public function set height(param1:Number) : void
      {
         if(param1 <= 0)
         {
            return;
         }
         actualHeight = param1;
         back.height = actualHeight;
         back.readjustSize();
         super.height = param1;
      }
      
      public function setOffsetScale(param1:int, param2:int) : void
      {
         offsetScaleX = param1;
         offsetScaleY = param2;
      }
      
      override public function dispose() : void
      {
         if(currTween)
         {
            currTween.dispatchEventWith("removeFromJuggler");
            currTween = null;
         }
         if(drawCache)
         {
            drawCache.texture.dispose();
            drawCache.dispose();
            drawCache = null;
         }
         if(pressTween)
         {
            pressTween.dispatchEventWith("removeFromJuggler");
            pressTween.reset(null,0);
            pressTween = null;
         }
         if(releaseTween)
         {
            releaseTween.dispatchEventWith("removeFromJuggler");
            releaseTween.reset(null,0);
            releaseTween = null;
         }
         super.dispose();
      }
      
      public function get alphaWhenDisabled() : Number
      {
         return mAlphaWhenDisabled;
      }
      
      public function set alphaWhenDisabled(param1:Number) : void
      {
         mAlphaWhenDisabled = param1;
         if(mState == "disabled")
         {
            refreshState();
         }
      }
      
      public function get enabled() : Boolean
      {
         return mEnabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         if(mEnabled != param1)
         {
            mEnabled = param1;
            if(drawCache)
            {
               drawCache.color = !!mEnabled ? mBackColor : disableColor;
            }
            state = !!param1 ? "up" : "disabled";
            setRequiresRedraw();
         }
      }
      
      public function disable(param1:Boolean) : void
      {
         if(drawCache)
         {
            drawCache.color = !!param1 ? disableColor : mBackColor;
            setRequiresRedraw();
         }
      }
      
      public function get background() : Texture
      {
         return back.texture;
      }
      
      public function setDisableColor(param1:int) : void
      {
         disableColor = param1;
      }
      
      public function set background(param1:Texture) : void
      {
         if(MukuGlobal.isBuilderMode())
         {
            if(back.texture)
            {
               back.texture.dispose();
            }
         }
         back.texture = param1;
         back.readjustSize();
         back.width = actualWidth;
         back.height = actualHeight;
      }
      
      public function get helperObject() : Object
      {
         return mHelperObject;
      }
      
      public function set helperObject(param1:Object) : void
      {
         mHelperObject = param1;
      }
      
      public function get color() : uint
      {
         return mBackColor;
      }
      
      public function set color(param1:uint) : void
      {
         if(drawCache)
         {
            drawCache.color = param1;
         }
         else
         {
            mBackColor = param1;
            back.color = mBackColor;
         }
      }
      
      public function get buttonType() : String
      {
         return buttonTypeText;
      }
      
      public function set buttonType(param1:String) : void
      {
         var _loc2_:int = ImageButton.TYPE_STRINGS.indexOf(param1);
         if(_loc2_ >= 0)
         {
            buttonTypeText = param1;
            buttonTypeValue = _loc2_;
         }
      }
      
      public function get scale9Grid() : Rectangle
      {
         return back.scale9Grid;
      }
      
      public function set scale9Grid(param1:Rectangle) : void
      {
         back.scale9Grid = param1;
      }
   }
}
