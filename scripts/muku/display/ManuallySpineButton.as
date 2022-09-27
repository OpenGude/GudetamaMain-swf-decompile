package muku.display
{
   import flash.display.BitmapData;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.ui.Mouse;
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.compati.GudetamaDef;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import muku.core.MukuGlobal;
   import muku.core.TaskQueue;
   import muku.text.ColorTextField;
   import muku.util.StarlingUtil;
   import starling.core.Starling;
   import starling.display.Button;
   import starling.display.DisplayObject;
   import starling.display.DisplayObjectContainer;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   import starling.filters.FragmentFilter;
   import starling.rendering.Painter;
   import starling.text.TextField;
   import starling.textures.Texture;
   import starling.utils.MatrixUtil;
   
   public class ManuallySpineButton extends Sprite
   {
      
      private static const TWEEN_PRESSED:String = "pressed";
      
      private static const TWEEN_RELEASE:String = "released";
      
      public static const TWEEN_ITEM_0:String = "item0";
      
      public static const TWEEN_ITEM_1:String = "item1";
      
      public static const TWEEN_FEVER:String = "fever";
      
      public static const TWEEN_SHOOT:String = "shoot";
      
      private static const MAX_DRAG_DIST:Number = 52;
      
      private static const MAX_DRAG_DIST2:Number = 26;
      
      private static const DRAG_DRIFT:int = 13;
      
      private static const DRAG_DRIFT_SQR:int = 169;
      
      private static var sHelperMatrix:Matrix = new Matrix();
      
      private static var sHelperPoint:Point = new Point();
      
      private static const MANUALLY_THRESHOLD:int = 200;
      
      private static const SWING_NONE:int = 0;
      
      private static const SWING_LEFT:int = 1;
      
      private static const SWING_RIGHT:int = 2;
      
      private static const SWING_TIME:int = 3000;
      
      private static const RUB_THRESHOLD:Number = 100;
      
      private static const DIR_LEFT:int = 0;
      
      private static const DIR_RIGHT:int = 1;
       
      
      private var actualWidth:Number = 100;
      
      private var actualHeight:Number = 100;
      
      private var back:Image;
      
      protected var mAlphaWhenDisabled:Number;
      
      private var mTriggerBounds:Rectangle;
      
      private var mEnabled:Boolean;
      
      private var movedCancel:Boolean;
      
      private var drawCache:Image = null;
      
      private var drawCacheObjects:Array;
      
      protected var mState:String;
      
      private var disableColor:int = 12500670;
      
      private var recentDisabled:Boolean;
      
      private var stopPropagate:Boolean;
      
      private var scrollStartX:Number;
      
      private var scrollStartY:Number;
      
      private var buttonTypeValue:int = 0;
      
      private var mBackColor:uint = 16777215;
      
      private var mHelperObject:Object = null;
      
      private var buttonTypeText:String;
      
      private var dispatcher:DisplayObject;
      
      private var releaseBeganCallback:Function;
      
      public var releaseTweenTime:Number;
      
      private var currentTween:String;
      
      private var currentTweenTime:uint;
      
      private var spineModel:SpineModel;
      
      private var imageGroup:Sprite;
      
      private var image:Image;
      
      private var mOrigin:Point;
      
      private var touchBeganCallback:Function;
      
      private var touchEndedCallback:Function;
      
      private var touchStartTime:int;
      
      private var lastOrientationRate:Number = 0;
      
      private var spineBitmapData:BitmapData;
      
      private var spineImage:Image;
      
      private var swingDir:int = 0;
      
      private var swingTime:int;
      
      private var lastSwingTime:int;
      
      private var rubX:Number;
      
      private var rubCount:int;
      
      private var rubDir:int;
      
      private var doneRub:Boolean;
      
      private var firstRub:Boolean;
      
      private var rubCallback:Function;
      
      private var disabledSpine:Boolean;
      
      private var currentImageName:String;
      
      public function ManuallySpineButton(param1:Texture)
      {
         drawCacheObjects = [];
         buttonTypeText = ImageButton.TYPE_STRINGS[buttonTypeValue];
         super();
         actualWidth = param1.width;
         actualHeight = param1.height;
         back = new Image(param1);
         mAlphaWhenDisabled = 1;
         mTriggerBounds = new Rectangle();
         mEnabled = true;
         addEventListener("touch",onTouch);
         x = 0;
         y = 0;
         dynamic = true;
      }
      
      public function setup(param1:TaskQueue, param2:int, param3:Boolean = false, param4:Function = null) : void
      {
         var queue:TaskQueue = param1;
         var id:int = param2;
         var offset:Boolean = param3;
         var callback:Function = param4;
         var gudetamaDef:GudetamaDef = GameSetting.getGudetama(id);
         disabledSpine = gudetamaDef.disabledSpine;
         if(!spineModel)
         {
            spineModel = getChildByName("spineModel") as SpineModel;
         }
         if(!imageGroup)
         {
            imageGroup = getChildByName("imageGroup") as Sprite;
         }
         if(!image)
         {
            image = imageGroup.getChildByName("image") as Image;
         }
         spineModel.finish();
         if(!disabledSpine)
         {
            image.visible = false;
            queue.addTask(function():void
            {
               spineModel.finish();
               spineModel.load(GudetamaUtil.getSpineName(id),function():void
               {
                  spineModel.show();
                  spineModel.changeAnimation("idle_loop",true);
                  spineModel.setManuallyAnimation("animation");
                  spineModel.setManuallyTime(0.5);
                  lastOrientationRate = 0.5;
                  setupBounds();
                  if(callback)
                  {
                     callback();
                  }
                  queue.taskDone();
               });
            });
         }
         else
         {
            image.visible = true;
            queue.addTask(function():void
            {
               TextureCollector.loadTexture("gudetama-" + gudetamaDef.rsrc + "-image",function(param1:Texture):void
               {
                  image.texture = param1;
                  setupImageBounds(!!offset ? gudetamaDef.imageOffsX : 0,!!offset ? gudetamaDef.imageOffsY : 0);
                  TweenAnimator.startItself(image,"idle");
                  if(callback)
                  {
                     callback();
                  }
                  queue.taskDone();
               });
            });
         }
         releaseTweenTime = MukuGlobal.tweenAnimator.getTweenTime(this,"released",false);
      }
      
      public function change(param1:int, param2:Object) : void
      {
         var id:int = param1;
         var param:Object = param2;
         var gudetamaDef:GudetamaDef = GameSetting.getGudetama(id);
         disabledSpine = gudetamaDef.disabledSpine;
         spineModel.finish();
         if(!disabledSpine)
         {
            image.visible = false;
            spineModel.setup(GudetamaUtil.getSpineName(id),param);
            spineModel.show();
            spineModel.changeAnimation("idle_loop",true);
            spineModel.setManuallyAnimation("animation");
            spineModel.setManuallyTime(0.5);
            lastOrientationRate = 0.5;
            setupBounds();
            startTween("released",true);
         }
         else
         {
            image.visible = true;
            TextureCollector.loadTexture("gudetama-" + gudetamaDef.rsrc + "-image",function(param1:Texture):void
            {
               image.texture = param1;
               setupImageBounds(gudetamaDef.imageOffsX,gudetamaDef.imageOffsY);
               TweenAnimator.startItself(image,"idle");
               startTween("released",true);
            });
         }
      }
      
      public function finish() : void
      {
         spineModel.finish();
         image.visible = false;
      }
      
      private function setupBounds() : void
      {
         var _loc5_:Number = spineModel.y;
         var _loc2_:Number = height - spineModel.y;
         var _loc1_:Point = spineModel.getBonePositionAtName("left_top");
         var _loc4_:Point = spineModel.getBonePositionAtName("right_bottom");
         var _loc3_:Point = new Point(spineModel.x - _loc1_.x,spineModel.y - _loc1_.y);
         spineModel.x -= _loc1_.x;
         spineModel.y -= _loc1_.y;
         width = _loc4_.x - _loc1_.x;
         height = _loc4_.y - _loc1_.y;
         pivotX = 0.5 * width;
         pivotY = 0.5 * height;
         if(mOrigin)
         {
            y = mOrigin.y - (_loc3_.y - 0.5 * height);
         }
      }
      
      public function getSpineBounds(param1:Rectangle = null) : Rectangle
      {
         var _loc2_:* = null;
         var _loc3_:* = null;
         if(!param1)
         {
            param1 = new Rectangle();
         }
         if(!disabledSpine)
         {
            _loc2_ = spineModel.getBonePositionAtName("left_top");
            _loc3_ = spineModel.getBonePositionAtName("right_bottom");
            param1.setTo(0,0,_loc3_.x - _loc2_.x,_loc3_.y - _loc2_.y);
         }
         else
         {
            param1.setTo(0,0,image.width,image.height);
         }
         return param1;
      }
      
      private function setupImageBounds(param1:Number, param2:Number) : void
      {
         image.readjustSize();
         var _loc3_:Number = image.texture.width;
         var _loc4_:Number = image.texture.height;
         image.pivotX = 0.5 * _loc3_;
         image.pivotY = 0.5 * _loc4_;
         imageGroup.x = 0.5 * _loc3_;
         imageGroup.y = _loc4_;
         imageGroup.pivotY = 0.5 * _loc4_;
         width = _loc3_;
         height = _loc4_;
         pivotX = 0.5 * _loc3_ - param1;
         pivotY = 0.5 * _loc4_ - param2;
      }
      
      public function setManuallySpineTime(param1:Number) : void
      {
         if(disabledSpine)
         {
            return;
         }
         spineModel.setManuallyTime(param1);
      }
      
      public function setOrigin(param1:Number, param2:Number) : void
      {
         mOrigin = new Point(param1,param2);
      }
      
      public function setTouchBeganCallback(param1:Function) : void
      {
         touchBeganCallback = param1;
      }
      
      public function setTouchEndedCallback(param1:Function) : void
      {
         touchEndedCallback = param1;
      }
      
      public function setReleaseBeganCallback(param1:Function) : void
      {
         releaseBeganCallback = param1;
      }
      
      public function setRubCallback(param1:Function) : void
      {
         rubCallback = param1;
      }
      
      public function setDispatcher(param1:DisplayObject) : void
      {
         dispatcher = param1;
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
      
      public function getSpineDisplayObject() : DisplayObject
      {
         return !disabledSpine ? spineModel : image;
      }
      
      public function getGuideArrowPosOffsX() : Number
      {
         return !disabledSpine ? 0 : Number(0.5 * image.width);
      }
      
      public function getGuideArrowPosOffsY() : Number
      {
         return !disabledSpine ? 0 : Number(image.height);
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
         if(_loc3_ >= 0 && _loc3_ < back.width && _loc2_ >= 0 && _loc2_ < back.height)
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
      
      private function getPriority(param1:String) : int
      {
         if(!param1)
         {
            return -1;
         }
         switch(param1)
         {
            case "shoot":
               return 5;
            case "fever":
               return 4;
            case "item1":
               return 3;
            case "item0":
               return 2;
            case "released":
               return 1;
            case "pressed":
               return 0;
            default:
               return -1;
         }
      }
      
      public function startTween(param1:String, param2:Boolean = false, param3:Function = null) : Boolean
      {
         var twname:String = param1;
         var once:Boolean = param2;
         var completionCallback:Function = param3;
         var priority:int = getPriority(twname);
         var currentPriority:int = getPriority(currentTween);
         if(priority < currentPriority)
         {
            return true;
         }
         var time:uint = Engine.now;
         currentTween = twname;
         currentTweenTime = time;
         return MukuGlobal.tweenAnimator.startItself(!disabledSpine ? spineModel : imageGroup,twname,once,function(param1:DisplayObject):void
         {
            if(currentTween == twname && currentTweenTime == time)
            {
               currentTween = null;
            }
            if(completionCallback)
            {
               completionCallback(param1);
            }
         });
      }
      
      private function refreshState() : void
      {
         switch(mState)
         {
            case "down":
               if(!MukuGlobal.isBuilderMode())
               {
                  if(startTween("pressed",true))
                  {
                  }
                  break;
               }
               break;
            case "up":
               if(recentDisabled)
               {
                  recentDisabled = false;
                  if(!MukuGlobal.isBuilderMode())
                  {
                     if(mAlphaWhenDisabled < 1)
                     {
                        alpha = 1;
                     }
                  }
                  else
                  {
                     alpha = 1;
                  }
               }
               if(!MukuGlobal.isBuilderMode())
               {
                  if(releaseBeganCallback)
                  {
                     releaseBeganCallback();
                  }
                  if(startTween("released",true))
                  {
                  }
                  break;
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
               else if(mAlphaWhenDisabled < 1)
               {
                  alpha = mAlphaWhenDisabled;
               }
               break;
            default:
               throw new ArgumentError("Invalid button state: " + mState);
         }
      }
      
      public function isTweening() : Boolean
      {
         if(!currentTween)
         {
            return false;
         }
         return currentTween != "pressed";
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
      
      private function onTouch(param1:TouchEvent) : void
      {
         var _loc8_:Boolean = false;
         var _loc10_:* = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc2_:* = false;
         var _loc9_:* = false;
         var _loc3_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc11_:Number = NaN;
         Mouse.cursor = enabled && param1.interactsWith(this) ? "button" : "auto";
         if(stopPropagate)
         {
            param1.stopPropagation();
         }
         var _loc7_:Touch;
         if(!(_loc7_ = param1.getTouch(this)) && dispatcher)
         {
            onTouchDispatcher(param1);
            return;
         }
         var _loc4_:DisplayObject = StarlingUtil.findParentScroller(parent);
         if(!enabled)
         {
            return;
         }
         if(_loc7_ == null)
         {
            if(mState == "down")
            {
               state = "up";
            }
         }
         else if(_loc7_.phase == "moved" && movedCancel)
         {
            _loc10_ = StarlingUtil.getPointFromPool();
            _loc7_.getMovement(parent,_loc10_);
            if(_loc10_.x > 4 || _loc10_.x < -4)
            {
               _loc7_.cancelled = true;
            }
            if(_loc10_.y > 4 || _loc10_.y < -4)
            {
               _loc7_.cancelled = true;
            }
         }
         else if(_loc7_.phase == "hover")
         {
            state = "over";
         }
         else if(_loc7_.phase == "began")
         {
            if(mState != "down")
            {
               mTriggerBounds = getBounds(stage,mTriggerBounds);
               if(_loc4_)
               {
                  scrollStartX = _loc4_.x;
                  scrollStartY = _loc4_.y;
                  mTriggerBounds.inflate(26,26);
               }
               else
               {
                  mTriggerBounds.inflate(52,52);
               }
               state = "down";
            }
            touchStartTime = Engine.now;
            if(touchBeganCallback)
            {
               touchBeganCallback();
            }
            rubX = _loc7_.globalX;
            rubCount = 0;
            doneRub = false;
            firstRub = false;
         }
         else if(_loc7_.phase == "moved")
         {
            _loc8_ = mTriggerBounds.contains(_loc7_.globalX,_loc7_.globalY);
            if(_loc4_ && mState == "down")
            {
               if(_loc8_)
               {
                  _loc5_ = scrollStartX - _loc4_.x;
                  _loc6_ = scrollStartY - _loc4_.y;
                  if(_loc5_ * _loc5_ + _loc6_ * _loc6_ > 169)
                  {
                     state = "up";
                  }
               }
            }
            else if(mState == "down" && !_loc8_)
            {
               state = "up";
            }
            else if(mState == "up" && _loc8_ && _loc4_ == null)
            {
               state = "down";
            }
            if(Engine.now - touchStartTime >= 200)
            {
               _loc2_ = _loc7_.globalX - _loc7_.previousGlobalX > 0;
               _loc9_ = _loc7_.globalX - _loc7_.previousGlobalX < 0;
               if(rubDir == 0 && _loc2_ || rubDir == 1 && _loc9_)
               {
                  rubX = _loc7_.previousGlobalX;
                  rubDir = rubDir != 1 ? 1 : 0;
                  doneRub = false;
               }
               if(!disabledSpine && spineModel)
               {
                  _loc3_ = _loc7_.globalX - _loc7_.previousGlobalX;
                  _loc3_ *= 2;
                  var _loc13_:* = Engine;
                  lastOrientationRate = Math.max(0,Math.min(1,lastOrientationRate + _loc3_ / (0.5 * gudetama.engine.Engine.designWidth)));
                  spineModel.setManuallyTime(lastOrientationRate);
               }
               _loc12_ = Math.abs(_loc7_.globalX - rubX);
               _loc11_ = !firstRub ? 0.5 * 100 : 100;
               if(!doneRub && _loc12_ >= _loc11_)
               {
                  if(++rubCount % 2 == 0 && rubCallback)
                  {
                     rubCallback();
                  }
                  doneRub = true;
                  firstRub = true;
               }
            }
         }
         else if(_loc7_.phase == "ended")
         {
            if(mState == "down")
            {
               state = "up";
               if(!MukuGlobal.isBuilderMode() && buttonTypeValue >= 0 && buttonTypeValue < ImageButton.TYPE_SOUND_EFFECT.length)
               {
                  MukuGlobal.soundManager.playEffect(ImageButton.TYPE_SOUND_EFFECT[buttonTypeValue]);
               }
               if(!_loc7_.cancelled)
               {
                  dispatchEventWith("triggered",true);
               }
            }
            if(touchEndedCallback)
            {
               touchEndedCallback();
            }
         }
      }
      
      private function onTouchDispatcher(param1:TouchEvent) : void
      {
         var _loc8_:Boolean = false;
         var _loc10_:* = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc2_:* = false;
         var _loc9_:* = false;
         var _loc3_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc7_:Touch = param1.getTouch(dispatcher);
         var _loc4_:DisplayObject = StarlingUtil.findParentScroller(parent);
         if(!enabled)
         {
            return;
         }
         if(_loc7_ == null)
         {
            if(mState == "down")
            {
               state = "up";
            }
         }
         else if(_loc7_.phase == "moved" && movedCancel)
         {
            _loc10_ = StarlingUtil.getPointFromPool();
            _loc7_.getMovement(parent,_loc10_);
            if(_loc10_.x > 4 || _loc10_.x < -4)
            {
               _loc7_.cancelled = true;
            }
            if(_loc10_.y > 4 || _loc10_.y < -4)
            {
               _loc7_.cancelled = true;
            }
         }
         else if(_loc7_.phase == "hover")
         {
            state = "over";
         }
         else if(_loc7_.phase == "began")
         {
            if(mState != "down")
            {
               mTriggerBounds = getBounds(stage,mTriggerBounds);
               if(_loc4_)
               {
                  scrollStartX = _loc4_.x;
                  scrollStartY = _loc4_.y;
                  mTriggerBounds.inflate(26,26);
               }
               else
               {
                  mTriggerBounds.inflate(52,52);
               }
               state = "down";
            }
            touchStartTime = Engine.now;
            rubX = _loc7_.globalX;
            rubCount = 0;
            doneRub = false;
            firstRub = false;
         }
         else if(_loc7_.phase == "moved")
         {
            _loc8_ = mTriggerBounds.contains(_loc7_.globalX,_loc7_.globalY);
            if(_loc4_ && mState == "down")
            {
               if(_loc8_)
               {
                  _loc5_ = scrollStartX - _loc4_.x;
                  _loc6_ = scrollStartY - _loc4_.y;
                  if(_loc5_ * _loc5_ + _loc6_ * _loc6_ > 169)
                  {
                     state = "up";
                  }
               }
            }
            else if(mState == "down" && !_loc8_)
            {
               state = "up";
            }
            else if(mState == "up" && _loc8_ && _loc4_ == null)
            {
               state = "down";
            }
            if(Engine.now - touchStartTime >= 200)
            {
               _loc2_ = _loc7_.globalX - _loc7_.previousGlobalX > 0;
               _loc9_ = _loc7_.globalX - _loc7_.previousGlobalX < 0;
               if(rubDir == 0 && _loc2_ || rubDir == 1 && _loc9_)
               {
                  rubX = _loc7_.previousGlobalX;
                  rubDir = rubDir != 1 ? 1 : 0;
                  doneRub = false;
                  firstRub = true;
               }
               if(!disabledSpine && spineModel)
               {
                  _loc3_ = _loc7_.globalX - _loc7_.previousGlobalX;
                  _loc3_ *= 2;
                  var _loc13_:* = Engine;
                  lastOrientationRate = Math.max(0,Math.min(1,lastOrientationRate + _loc3_ / (0.5 * gudetama.engine.Engine.designWidth)));
                  spineModel.setManuallyTime(lastOrientationRate);
               }
               _loc12_ = Math.abs(_loc7_.globalX - rubX);
               _loc11_ = !firstRub ? 0.5 * 100 : 100;
               if(!doneRub && _loc12_ >= _loc11_)
               {
                  if(++rubCount % 2 == 0 && rubCallback)
                  {
                     rubCallback();
                  }
                  doneRub = true;
                  firstRub = true;
               }
            }
         }
         else if(_loc7_.phase == "ended")
         {
            if(mState == "down")
            {
               state = "up";
               if(!MukuGlobal.isBuilderMode() && buttonTypeValue >= 0 && buttonTypeValue < ImageButton.TYPE_SOUND_EFFECT.length)
               {
                  MukuGlobal.soundManager.playEffect(ImageButton.TYPE_SOUND_EFFECT[buttonTypeValue]);
               }
               if(!_loc7_.cancelled)
               {
                  dispatchEventWith("triggered",true);
               }
            }
         }
      }
      
      public function startSwingAnime(param1:Number, param2:Function = null) : void
      {
         var time:Number = param1;
         var callback:Function = param2;
         if(disabledSpine)
         {
            if(callback)
            {
               callback();
            }
            return;
         }
         swingDir = Math.random() > 0.5 ? 1 : 2;
         swingTime = Math.asin(spineModel.getManuallyTrackTime() * 2 - 1) / (2 * 3.141592653589793) * 3000;
         lastSwingTime = Engine.now;
         var _loc3_:* = Starling;
         (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).delayCall(function():void
         {
            swingDir = 0;
            if(spineModel)
            {
               lastOrientationRate = spineModel.getManuallyTrackTime();
            }
            if(callback)
            {
               callback();
            }
         },time);
      }
      
      public function advanceTime(param1:Number) : void
      {
         if(!isPlayingSwingAnime())
         {
            return;
         }
         if(swingDir == 1)
         {
            swingTime -= Engine.now - lastSwingTime;
            if(swingTime < 0)
            {
               swingTime += 3000;
            }
         }
         else
         {
            swingTime += Engine.now - lastSwingTime;
         }
         var _loc2_:Number = swingTime % 3000 / 3000;
         spineModel.setManuallyTime(0.5 * (1 + Math.sin(2 * 3.141592653589793 * _loc2_)));
         lastSwingTime = Engine.now;
      }
      
      private function isPlayingSwingAnime() : Boolean
      {
         return swingDir != 0;
      }
      
      public function setStopPropagation(param1:Boolean) : void
      {
         stopPropagate = param1;
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
      
      public function removeTouchEvent() : void
      {
         removeEventListener("touch",onTouch);
      }
      
      override public function dispose() : void
      {
         removeEventListener("touch",onTouch);
         if(back)
         {
            back.texture.dispose();
            back.dispose();
            back = null;
         }
         mTriggerBounds = null;
         if(drawCache)
         {
            drawCache.texture.dispose();
            drawCache.dispose();
            drawCache = null;
         }
         mHelperObject = null;
         spineModel = null;
         touchBeganCallback = null;
         touchEndedCallback = null;
         if(spineBitmapData)
         {
            spineBitmapData.dispose();
            spineBitmapData = null;
         }
         if(spineImage)
         {
            spineImage.texture.dispose();
            spineImage.texture = null;
         }
         super.dispose();
      }
   }
}
