package muku.display
{
   import flash.geom.Point;
   import flash.ui.Mouse;
   import muku.core.MukuGlobal;
   import muku.util.StarlingUtil;
   import starling.animation.Tween;
   import starling.core.Starling;
   import starling.display.Button;
   import starling.display.DisplayObject;
   import starling.events.Event;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   import starling.textures.RenderTexture;
   import starling.textures.Texture;
   
   public class SimpleImageButton extends Button
   {
      
      private static const MAX_DRAG_DIST:Number = 52;
      
      private static const MAX_DRAG_DIST2:Number = 26;
      
      private static const DRAG_DRIFT:int = 13;
      
      private static const DRAG_DRIFT_SQR:int = 169;
      
      public static const HITMARGIN_VERTICAL_UPPER:int = 10;
      
      public static const HITMARGIN_VERTICAL_LOWER:int = 10;
      
      public static const HITMARGIN_HORIZONTAL:int = 3;
      
      public static const PRESSED_EXPAND_PIXELS:int = 16;
      
      public static const TYPE_SOUND_EFFECT:Array = ["","btn_normal","btn_ok","btn_cancel","btn_close","btn_push"];
      
      public static const TYPE_STRINGS:Array = ["SILENT","NORMAL","OK","CANCEL","CLOSE","PUSH"];
       
      
      private var hitmargin_X:int = 0;
      
      private var hitmargin_upper_Y:int = 0;
      
      private var hitmargin_lower_Y:int = 0;
      
      private var buttonTypeValue:int = 0;
      
      private var buttonTypeText:String;
      
      private var recentDisabled:Boolean;
      
      private var mUpState:Texture;
      
      private var actualHeight:Number = 100;
      
      private var actualWidth:Number = 100;
      
      private var pressTween:Tween;
      
      private var releaseTween:Tween;
      
      private var currTween:Tween;
      
      private var scrollStartX:Number;
      
      private var scrollStartY:Number;
      
      private var disableDown:Boolean;
      
      private var mHelperObject:Object = null;
      
      private var stopPropagate:Boolean;
      
      private var bodyColor:int = 16777215;
      
      private var disableColor:int = 12500670;
      
      public function SimpleImageButton(param1:Texture, param2:String = "")
      {
         buttonTypeText = TYPE_STRINGS[buttonTypeValue];
         super(param1,param2);
         removeEventListeners("touch");
         addEventListener("touch",onTouch);
         pressTween = new Tween(_contents,0.02,"easeOutBack");
         releaseTween = new Tween(_contents,0.02,"easeOutBack");
         currTween = null;
         addEventListener("removedFromStage",onRemoved);
         alphaWhenDisabled = 1;
         enabled = true;
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
      
      override public function dispose() : void
      {
         var _loc1_:Texture = upState;
         if(currTween)
         {
            currTween.dispatchEventWith("removeFromJuggler");
            currTween = null;
         }
         if(_loc1_ is RenderTexture)
         {
            _loc1_.root.onRestore = null;
            _loc1_.dispose();
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
      
      private function onRemoved(param1:Event) : void
      {
         if(currTween)
         {
            currTween.dispatchEventWith("removeFromJuggler");
            currTween = null;
            _contents.scaleX = 1;
            _contents.scaleY = 1;
            _contents.x = 0;
            _contents.y = 0;
         }
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
         if(_loc3_ >= -hitmargin_X && _loc3_ < actualWidth + hitmargin_X && _loc2_ >= -hitmargin_lower_Y && _loc2_ < actualHeight + hitmargin_upper_Y)
         {
            return this;
         }
         return null;
      }
      
      private function onTouch(param1:TouchEvent) : void
      {
         var _loc6_:Boolean = false;
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
            state = "up";
         }
         else if(_loc5_.phase == "hover")
         {
            state = "over";
         }
         else if(_loc5_.phase == "began" && _state != "down")
         {
            _triggerBounds = getBounds(stage,_triggerBounds);
            if(_loc2_)
            {
               scrollStartX = _loc2_.x;
               scrollStartY = _loc2_.y;
               _triggerBounds.inflate(26,26);
            }
            else
            {
               _triggerBounds.inflate(52,52);
            }
            state = "down";
         }
         else if(_loc5_.phase == "moved")
         {
            _loc6_ = _triggerBounds.contains(_loc5_.globalX,_loc5_.globalY);
            if(_loc2_ && _state == "down")
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
            else if(_state == "down" && !_loc6_)
            {
               state = "up";
            }
            else if(_state == "up" && _loc6_ && _loc2_ == null)
            {
               state = "down";
            }
         }
         else if(_loc5_.phase == "ended" && _state == "down")
         {
            state = "up";
            if(!MukuGlobal.isBuilderMode() && buttonTypeValue >= 0 && buttonTypeValue < TYPE_SOUND_EFFECT.length)
            {
               MukuGlobal.soundManager.playEffect(TYPE_SOUND_EFFECT[buttonTypeValue]);
            }
            if(!_loc5_.cancelled)
            {
               dispatchEventWith("triggered",true);
            }
         }
      }
      
      override public function set state(param1:String) : void
      {
         _state = param1;
         refreshState();
      }
      
      private function refreshState() : void
      {
         var _loc2_:Number = NaN;
         var _loc1_:Number = NaN;
         var _loc3_:Number = NaN;
         switch(_state)
         {
            case "down":
               if(disableDown)
               {
                  return;
               }
               setStateTexture(_downState);
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
               _loc2_ = (16 / scaleX + _body.width) / _body.width;
               _loc1_ = (16 / scaleY + _body.height) / _body.height;
               _loc3_ = _loc2_ > _loc1_ ? _loc1_ : Number(_loc2_);
               if(pressTween)
               {
                  pressTween.reset(_contents,0.08,"easeOutBack");
                  pressTween.animate("scaleX",_loc3_);
                  pressTween.animate("scaleY",_loc3_);
                  pressTween.animate("x",(1 - _loc3_) / 2 * _body.width);
                  pressTween.animate("y",(1 - _loc3_) / 2 * _body.height);
                  currTween = pressTween;
                  var _loc4_:* = Starling;
                  starling.core.Starling.sCurrent.juggler.add(currTween);
               }
               break;
            case "up":
               if(recentDisabled)
               {
                  recentDisabled = false;
                  if(_alphaWhenDisabled < 1)
                  {
                     if(!MukuGlobal.isBuilderMode())
                     {
                        if(!MukuGlobal.tweenAnimator.startItselfWithoutFinish(this,"enabled"))
                        {
                           _contents.alpha = 1;
                        }
                     }
                     else
                     {
                        _contents.alpha = 1;
                     }
                  }
                  else
                  {
                     _body.color = bodyColor;
                  }
               }
               setStateTexture(mUpState);
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
                  releaseTween.reset(_contents,0.05,"easeOutBack");
                  releaseTween.animate("scaleX",1);
                  releaseTween.animate("scaleY",1);
                  releaseTween.animate("x",0);
                  releaseTween.animate("y",0);
                  currTween = releaseTween;
                  var _loc5_:* = Starling;
                  starling.core.Starling.sCurrent.juggler.add(currTween);
               }
               break;
            case "over":
               break;
            case "disabled":
               setStateTexture(_disabledState);
               recentDisabled = true;
               if(_alphaWhenDisabled < 1)
               {
                  if(MukuGlobal.isBuilderMode())
                  {
                     _contents.alpha = _alphaWhenDisabled;
                  }
                  else if(!MukuGlobal.tweenAnimator.startItselfWithoutFinish(this,"disabled"))
                  {
                     _contents.alpha = _alphaWhenDisabled;
                  }
               }
               else if(!MukuGlobal.isBuilderMode())
               {
                  _body.color = disableColor;
               }
               break;
            default:
               throw new ArgumentError("Invalid button state: " + _state);
         }
      }
      
      public function disableStateDown() : void
      {
         disableDown = true;
      }
      
      public function setStopPropagation(param1:Boolean) : void
      {
         stopPropagate = param1;
      }
      
      public function setTweenDiable(param1:Boolean) : void
      {
         if(param1)
         {
            pressTween = null;
            releaseTween = null;
         }
         else
         {
            pressTween = new Tween(_contents,0.02,"easeOutBack");
            releaseTween = new Tween(_contents,0.02,"easeOutBack");
         }
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
      
      override public function get color() : uint
      {
         return bodyColor;
      }
      
      override public function set color(param1:uint) : void
      {
         _body.color = param1;
         bodyColor = param1;
      }
      
      override public function set width(param1:Number) : void
      {
         if(param1 <= 0)
         {
            return;
         }
         actualWidth = param1;
         super.width = param1;
      }
      
      override public function set height(param1:Number) : void
      {
         if(param1 <= 0)
         {
            return;
         }
         actualHeight = param1;
         super.height = param1;
      }
      
      public function get texture() : Texture
      {
         return _upState;
      }
      
      public function set texture(param1:Texture) : void
      {
         if(param1 != upState)
         {
            upState = param1;
         }
      }
      
      public function get helperObject() : Object
      {
         return mHelperObject;
      }
      
      public function set helperObject(param1:Object) : void
      {
         mHelperObject = param1;
      }
      
      public function get buttonType() : String
      {
         return buttonTypeText;
      }
      
      public function set buttonType(param1:String) : void
      {
         var _loc2_:int = TYPE_STRINGS.indexOf(param1);
         if(_loc2_ >= 0)
         {
            buttonTypeText = param1;
            buttonTypeValue = _loc2_;
         }
      }
   }
}
