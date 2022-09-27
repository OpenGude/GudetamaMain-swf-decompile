package feathers.controls.popups
{
   import feathers.core.IFeathersControl;
   import feathers.core.IValidating;
   import feathers.core.PopUpManager;
   import feathers.core.ValidationQueue;
   import feathers.display.RenderDelegate;
   import feathers.utils.display.getDisplayObjectDepthFromStage;
   import feathers.utils.display.stageToStarling;
   import flash.errors.IllegalOperationError;
   import flash.events.KeyboardEvent;
   import flash.geom.Rectangle;
   import starling.animation.Tween;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   import starling.display.DisplayObjectContainer;
   import starling.display.Quad;
   import starling.display.Stage;
   import starling.events.Event;
   import starling.events.EventDispatcher;
   import starling.events.ResizeEvent;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   import starling.utils.Pool;
   
   public class DropDownPopUpContentManager extends EventDispatcher implements IPopUpContentManager
   {
      
      public static const PRIMARY_DIRECTION_DOWN:String = "down";
      
      public static const PRIMARY_DIRECTION_UP:String = "up";
       
      
      protected var content:DisplayObject;
      
      protected var source:DisplayObject;
      
      protected var _delegate:RenderDelegate;
      
      protected var _openCloseTweenTarget:DisplayObject;
      
      protected var _openCloseTween:Tween;
      
      protected var _isModal:Boolean = false;
      
      protected var _overlayFactory:Function;
      
      protected var _gap:Number = 0;
      
      protected var _openCloseDuration:Number = 0.2;
      
      protected var _openCloseEase:Object = "easeOut";
      
      protected var _actualDirection:String;
      
      protected var _primaryDirection:String = "bottom";
      
      protected var _fitContentMinWidthToOrigin:Boolean = true;
      
      protected var _lastGlobalX:Number;
      
      protected var _lastGlobalY:Number;
      
      public function DropDownPopUpContentManager()
      {
         super();
      }
      
      public function get isOpen() : Boolean
      {
         return this.content !== null;
      }
      
      public function get isModal() : Boolean
      {
         return this._isModal;
      }
      
      public function set isModal(param1:Boolean) : void
      {
         this._isModal = param1;
      }
      
      public function get overlayFactory() : Function
      {
         return this._overlayFactory;
      }
      
      public function set overlayFactory(param1:Function) : void
      {
         this._overlayFactory = param1;
      }
      
      public function get gap() : Number
      {
         return this._gap;
      }
      
      public function set gap(param1:Number) : void
      {
         this._gap = param1;
      }
      
      public function get openCloseDuration() : Number
      {
         return this._openCloseDuration;
      }
      
      public function set openCloseDuration(param1:Number) : void
      {
         this._openCloseDuration = param1;
      }
      
      public function get openCloseEase() : Object
      {
         return this._openCloseEase;
      }
      
      public function set openCloseEase(param1:Object) : void
      {
         this._openCloseEase = param1;
      }
      
      public function get primaryDirection() : String
      {
         return this._primaryDirection;
      }
      
      public function set primaryDirection(param1:String) : void
      {
         if(param1 === "up")
         {
            param1 = "top";
         }
         else if(param1 === "down")
         {
            param1 = "bottom";
         }
         this._primaryDirection = param1;
      }
      
      public function get fitContentMinWidthToOrigin() : Boolean
      {
         return this._fitContentMinWidthToOrigin;
      }
      
      public function set fitContentMinWidthToOrigin(param1:Boolean) : void
      {
         this._fitContentMinWidthToOrigin = param1;
      }
      
      public function open(param1:DisplayObject, param2:DisplayObject) : void
      {
         var _loc5_:* = null;
         if(this.isOpen)
         {
            throw new IllegalOperationError("Pop-up content is already open. Close the previous content before opening new content.");
         }
         this.content = param1;
         this.source = param2;
         PopUpManager.addPopUp(param1,this._isModal,false,this._overlayFactory);
         if(param1 is IFeathersControl)
         {
            param1.addEventListener("resize",content_resizeHandler);
         }
         param1.addEventListener("removedFromStage",content_removedFromStageHandler);
         this.layout();
         if(this._openCloseTween !== null)
         {
            this._openCloseTween.advanceTime(this._openCloseTween.totalTime);
         }
         if(this._openCloseDuration > 0)
         {
            this._delegate = new RenderDelegate(param1);
            param1.visible = false;
            PopUpManager.addPopUp(this._delegate,false,false);
            this._delegate.x = param1.x;
            if(this._actualDirection === "top")
            {
               this._delegate.y = param1.y + param1.height;
            }
            else
            {
               this._delegate.y = param1.y - param1.height;
            }
            _loc5_ = new Quad(param1.width,param1.height,16711935);
            this._delegate.mask = _loc5_;
            _loc5_.height = 0;
            this._openCloseTween = new Tween(this._delegate,this._openCloseDuration,this._openCloseEase);
            this._openCloseTweenTarget = param1;
            this._openCloseTween.animate("y",param1.y);
            this._openCloseTween.onUpdate = openCloseTween_onUpdate;
            this._openCloseTween.onComplete = openTween_onComplete;
            var _loc6_:* = Starling;
            (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).add(this._openCloseTween);
         }
         var _loc3_:Stage = this.source.stage;
         _loc3_.addEventListener("touch",stage_touchHandler);
         _loc3_.addEventListener("resize",stage_resizeHandler);
         _loc3_.addEventListener("enterFrame",stage_enterFrameHandler);
         var _loc4_:int = -getDisplayObjectDepthFromStage(this.content);
         var _loc7_:* = Starling;
         starling.core.Starling.sCurrent.nativeStage.addEventListener("keyDown",nativeStage_keyDownHandler,false,_loc4_,true);
         this.dispatchEventWith("open");
      }
      
      public function close() : void
      {
         var _loc4_:* = null;
         if(!this.isOpen)
         {
            return;
         }
         if(this._openCloseTween !== null)
         {
            this._openCloseTween.advanceTime(this._openCloseTween.totalTime);
         }
         var _loc3_:DisplayObject = this.content;
         this.source = null;
         this.content = null;
         var _loc2_:Stage = _loc3_.stage;
         _loc2_.removeEventListener("touch",stage_touchHandler);
         _loc2_.removeEventListener("resize",stage_resizeHandler);
         _loc2_.removeEventListener("enterFrame",stage_enterFrameHandler);
         var _loc1_:Starling = stageToStarling(_loc2_);
         _loc1_.nativeStage.removeEventListener("keyDown",nativeStage_keyDownHandler);
         if(_loc3_ is IFeathersControl)
         {
            _loc3_.removeEventListener("resize",content_resizeHandler);
         }
         _loc3_.removeEventListener("removedFromStage",content_removedFromStageHandler);
         if(_loc3_.parent)
         {
            _loc3_.removeFromParent(false);
         }
         if(this._openCloseDuration > 0)
         {
            this._delegate = new RenderDelegate(_loc3_);
            PopUpManager.addPopUp(this._delegate,false,false);
            this._delegate.x = _loc3_.x;
            this._delegate.y = _loc3_.y;
            (_loc4_ = new Quad(1,1,16711935)).width = _loc3_.width;
            _loc4_.height = _loc3_.height;
            this._delegate.mask = _loc4_;
            this._openCloseTween = new Tween(this._delegate,this._openCloseDuration,this._openCloseEase);
            this._openCloseTweenTarget = _loc3_;
            if(this._actualDirection === "top")
            {
               this._openCloseTween.animate("y",_loc3_.y + _loc3_.height);
            }
            else
            {
               this._openCloseTween.animate("y",_loc3_.y - _loc3_.height);
            }
            this._openCloseTween.onUpdate = openCloseTween_onUpdate;
            this._openCloseTween.onComplete = closeTween_onComplete;
            var _loc5_:* = Starling;
            (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).add(this._openCloseTween);
         }
         else
         {
            this.dispatchEventWith("close");
         }
      }
      
      public function dispose() : void
      {
         this.openCloseDuration = 0;
         this.close();
      }
      
      protected function layout() : void
      {
         if(this.source is IValidating)
         {
            IValidating(this.source).validate();
            if(!this.isOpen)
            {
               return;
            }
         }
         var _loc7_:Number = this.source.width;
         var _loc1_:Boolean = false;
         var _loc4_:IFeathersControl = this.content as IFeathersControl;
         if(this._fitContentMinWidthToOrigin && _loc4_ && _loc4_.minWidth < _loc7_)
         {
            _loc4_.minWidth = _loc7_;
            _loc1_ = true;
         }
         if(this.content is IValidating)
         {
            _loc4_.validate();
         }
         if(!_loc1_ && this._fitContentMinWidthToOrigin && this.content.width < _loc7_)
         {
            this.content.width = _loc7_;
         }
         var _loc5_:Stage = this.source.stage;
         var _loc3_:Starling = stageToStarling(_loc5_);
         var _loc6_:ValidationQueue;
         var _loc11_:*;
         if((_loc6_ = ValidationQueue.forStarling(_loc3_)) && !(_loc11_ = _loc6_)._isValidating)
         {
            _loc6_.advanceTime(0);
         }
         var _loc2_:Rectangle = this.source.getBounds(_loc5_);
         this._lastGlobalX = _loc2_.x;
         this._lastGlobalY = _loc2_.y;
         var _loc10_:Number = _loc5_.stageHeight - this.content.height - (_loc2_.y + _loc2_.height + this._gap);
         if(this._primaryDirection == "bottom" && _loc10_ >= 0)
         {
            layoutBelow(_loc2_);
            return;
         }
         var _loc8_:Number;
         if((_loc8_ = _loc2_.y - this._gap - this.content.height) >= 0)
         {
            layoutAbove(_loc2_);
            return;
         }
         if(this._primaryDirection == "top" && _loc10_ >= 0)
         {
            layoutBelow(_loc2_);
            return;
         }
         if(_loc8_ >= _loc10_)
         {
            layoutAbove(_loc2_);
         }
         else
         {
            layoutBelow(_loc2_);
         }
         var _loc9_:Number = _loc5_.stageHeight - (_loc2_.y + _loc2_.height);
         if(_loc4_)
         {
            if(_loc4_.maxHeight > _loc9_)
            {
               _loc4_.maxHeight = _loc9_;
            }
         }
         else if(this.content.height > _loc9_)
         {
            this.content.height = _loc9_;
         }
      }
      
      protected function layoutAbove(param1:Rectangle) : void
      {
         this._actualDirection = "top";
         this.content.x = this.calculateXPosition(param1);
         this.content.y = param1.y - this.content.height - this._gap;
      }
      
      protected function layoutBelow(param1:Rectangle) : void
      {
         this._actualDirection = "bottom";
         this.content.x = this.calculateXPosition(param1);
         this.content.y = param1.y + param1.height + this._gap;
      }
      
      protected function calculateXPosition(param1:Rectangle) : Number
      {
         var _loc5_:Number;
         var _loc4_:Number = (_loc5_ = param1.x) + param1.width - this.content.width;
         var _loc3_:Number = this.source.stage.stageWidth - this.content.width;
         var _loc2_:* = _loc5_;
         if(_loc2_ > _loc3_)
         {
            if(_loc4_ >= 0)
            {
               _loc2_ = _loc4_;
            }
            else
            {
               _loc2_ = _loc3_;
            }
         }
         if(_loc2_ < 0)
         {
            _loc2_ = 0;
         }
         return _loc2_;
      }
      
      protected function openCloseTween_onUpdate() : void
      {
         var _loc1_:DisplayObject = this._delegate.mask;
         if(this._actualDirection === "top")
         {
            _loc1_.height = this._openCloseTweenTarget.height - (this._delegate.y - this._openCloseTweenTarget.y);
            _loc1_.y = 0;
         }
         else
         {
            _loc1_.height = this._openCloseTweenTarget.height - (this._openCloseTweenTarget.y - this._delegate.y);
            _loc1_.y = this._openCloseTweenTarget.height - _loc1_.height;
         }
      }
      
      protected function openCloseTween_onComplete() : void
      {
         this._openCloseTween = null;
         this._delegate.removeFromParent(true);
         this._delegate = null;
      }
      
      protected function openTween_onComplete() : void
      {
         this.openCloseTween_onComplete();
         this.content.visible = true;
      }
      
      protected function closeTween_onComplete() : void
      {
         this.openCloseTween_onComplete();
         this.dispatchEventWith("close");
      }
      
      protected function content_resizeHandler(param1:Event) : void
      {
         this.layout();
      }
      
      protected function stage_enterFrameHandler(param1:Event) : void
      {
         var _loc2_:Rectangle = Pool.getRectangle();
         this.source.getBounds(this.source.stage,_loc2_);
         if(_loc2_.x !== this._lastGlobalX || _loc2_.y !== this._lastGlobalY)
         {
            this.layout();
         }
         Pool.putRectangle(_loc2_);
      }
      
      protected function content_removedFromStageHandler(param1:Event) : void
      {
         this.close();
      }
      
      protected function nativeStage_keyDownHandler(param1:KeyboardEvent) : void
      {
         if(param1.isDefaultPrevented())
         {
            return;
         }
         if(param1.keyCode != 16777238 && param1.keyCode != 27)
         {
            return;
         }
         param1.preventDefault();
         this.close();
      }
      
      protected function stage_resizeHandler(param1:ResizeEvent) : void
      {
         this.layout();
      }
      
      protected function stage_touchHandler(param1:TouchEvent) : void
      {
         var _loc4_:DisplayObject = DisplayObject(param1.target);
         if(this.content == _loc4_ || this.content is DisplayObjectContainer && DisplayObjectContainer(this.content).contains(_loc4_))
         {
            return;
         }
         if(this.source == _loc4_ || this.source is DisplayObjectContainer && DisplayObjectContainer(this.source).contains(_loc4_))
         {
            return;
         }
         if(!PopUpManager.isTopLevelPopUp(this.content))
         {
            return;
         }
         var _loc2_:Stage = Stage(param1.currentTarget);
         var _loc3_:Touch = param1.getTouch(_loc2_,"began");
         if(!_loc3_)
         {
            return;
         }
         this.close();
      }
   }
}
