package feathers.controls
{
   import feathers.controls.text.ITextEditorViewPort;
   import feathers.controls.text.TextFieldTextEditorViewPort;
   import feathers.core.IAdvancedNativeFocusOwner;
   import feathers.core.IFeathersControl;
   import feathers.core.IMeasureDisplayObject;
   import feathers.core.INativeFocusOwner;
   import feathers.core.IStateContext;
   import feathers.core.IStateObserver;
   import feathers.core.PopUpManager;
   import feathers.core.PropertyProxy;
   import feathers.skins.IStyleProvider;
   import feathers.text.FontStylesSet;
   import flash.geom.Point;
   import flash.ui.Mouse;
   import starling.display.DisplayObject;
   import starling.events.Event;
   import starling.events.KeyboardEvent;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   import starling.text.TextFormat;
   import starling.utils.Pool;
   
   public class TextArea extends Scroller implements IAdvancedNativeFocusOwner, IStateContext
   {
      
      public static const SCROLL_POLICY_AUTO:String = "auto";
      
      public static const SCROLL_POLICY_ON:String = "on";
      
      public static const SCROLL_POLICY_OFF:String = "off";
      
      public static const SCROLL_BAR_DISPLAY_MODE_FLOAT:String = "float";
      
      public static const SCROLL_BAR_DISPLAY_MODE_FIXED:String = "fixed";
      
      public static const SCROLL_BAR_DISPLAY_MODE_FIXED_FLOAT:String = "fixedFloat";
      
      public static const SCROLL_BAR_DISPLAY_MODE_NONE:String = "none";
      
      public static const VERTICAL_SCROLL_BAR_POSITION_RIGHT:String = "right";
      
      public static const VERTICAL_SCROLL_BAR_POSITION_LEFT:String = "left";
      
      public static const INTERACTION_MODE_TOUCH:String = "touch";
      
      public static const INTERACTION_MODE_MOUSE:String = "mouse";
      
      public static const INTERACTION_MODE_TOUCH_AND_SCROLL_BARS:String = "touchAndScrollBars";
      
      public static const MOUSE_WHEEL_SCROLL_DIRECTION_VERTICAL:String = "vertical";
      
      public static const MOUSE_WHEEL_SCROLL_DIRECTION_HORIZONTAL:String = "horizontal";
      
      public static const DECELERATION_RATE_NORMAL:Number = 0.998;
      
      public static const DECELERATION_RATE_FAST:Number = 0.99;
      
      public static const STATE_ENABLED:String = "enabled";
      
      public static const STATE_DISABLED:String = "disabled";
      
      public static const STATE_FOCUSED:String = "focused";
      
      public static const DEFAULT_CHILD_STYLE_NAME_TEXT_EDITOR:String = "feathers-text-area-text-editor";
      
      public static const DEFAULT_CHILD_STYLE_NAME_ERROR_CALLOUT:String = "feathers-text-area-error-callout";
      
      protected static const INVALIDATION_FLAG_ERROR_CALLOUT_FACTORY:String = "errorCalloutFactory";
      
      public static var globalStyleProvider:IStyleProvider;
       
      
      protected var textEditorViewPort:ITextEditorViewPort;
      
      protected var callout:TextCallout;
      
      protected var textEditorStyleName:String = "feathers-text-area-text-editor";
      
      protected var errorCalloutStyleName:String = "feathers-text-area-error-callout";
      
      protected var _textEditorHasFocus:Boolean = false;
      
      protected var _isWaitingToSetFocus:Boolean = false;
      
      protected var _pendingSelectionBeginIndex:int = -1;
      
      protected var _pendingSelectionEndIndex:int = -1;
      
      protected var _textAreaTouchPointID:int = -1;
      
      protected var _oldMouseCursor:String = null;
      
      protected var _ignoreTextChanges:Boolean = false;
      
      protected var _currentState:String = "enabled";
      
      protected var _text:String = "";
      
      protected var _maxChars:int = 0;
      
      protected var _restrict:String;
      
      protected var _isEditable:Boolean = true;
      
      protected var _errorString:String = null;
      
      protected var _stateToSkin:Object;
      
      protected var _stateToSkinFunction:Function;
      
      protected var _fontStylesSet:FontStylesSet;
      
      protected var _textEditorFactory:Function;
      
      protected var _customTextEditorStyleName:String;
      
      protected var _textEditorProperties:PropertyProxy;
      
      protected var _customErrorCalloutStyleName:String;
      
      public function TextArea()
      {
         _stateToSkin = {};
         super();
         if(this._fontStylesSet === null)
         {
            this._fontStylesSet = new FontStylesSet();
            this._fontStylesSet.addEventListener("change",fontStyles_changeHandler);
         }
         this._measureViewPort = false;
         this.addEventListener("touch",textArea_touchHandler);
         this.addEventListener("removedFromStage",textArea_removedFromStageHandler);
      }
      
      public function get nativeFocus() : Object
      {
         if(this.textEditorViewPort is INativeFocusOwner)
         {
            return INativeFocusOwner(this.textEditorViewPort).nativeFocus;
         }
         return null;
      }
      
      override protected function get defaultStyleProvider() : IStyleProvider
      {
         return TextArea.globalStyleProvider;
      }
      
      override public function get isFocusEnabled() : Boolean
      {
         if(this._isEditable)
         {
            return this._isEnabled && this._isFocusEnabled;
         }
         return super.isFocusEnabled;
      }
      
      public function get hasFocus() : Boolean
      {
         if(!this._focusManager)
         {
            return this._textEditorHasFocus;
         }
         return this._hasFocus;
      }
      
      override public function set isEnabled(param1:Boolean) : void
      {
         super.isEnabled = param1;
         this.refreshState();
      }
      
      public function get currentState() : String
      {
         return this._currentState;
      }
      
      public function get text#2() : String
      {
         return this._text;
      }
      
      public function set text#2(param1:String) : void
      {
         if(!param1)
         {
            param1 = "";
         }
         if(this._text == param1)
         {
            return;
         }
         this._text = param1;
         this.invalidate("data");
         this.dispatchEventWith("change");
      }
      
      public function get maxChars() : int
      {
         return this._maxChars;
      }
      
      public function set maxChars(param1:int) : void
      {
         if(this._maxChars == param1)
         {
            return;
         }
         this._maxChars = param1;
         this.invalidate("styles");
      }
      
      public function get restrict() : String
      {
         return this._restrict;
      }
      
      public function set restrict(param1:String) : void
      {
         if(this._restrict == param1)
         {
            return;
         }
         this._restrict = param1;
         this.invalidate("styles");
      }
      
      public function get isEditable() : Boolean
      {
         return this._isEditable;
      }
      
      public function set isEditable(param1:Boolean) : void
      {
         if(this._isEditable == param1)
         {
            return;
         }
         this._isEditable = param1;
         this.invalidate("styles");
      }
      
      public function get errorString() : String
      {
         return this._errorString;
      }
      
      public function set errorString(param1:String) : void
      {
         if(this._errorString === param1)
         {
            return;
         }
         this._errorString = param1;
         this.refreshState();
         this.invalidate("styles");
      }
      
      override public function get backgroundDisabledSkin() : DisplayObject
      {
         return this.getSkinForState("disabled");
      }
      
      override public function set backgroundDisabledSkin(param1:DisplayObject) : void
      {
         this.setSkinForState("disabled",param1);
      }
      
      public function get backgroundFocusedSkin() : DisplayObject
      {
         return this.getSkinForState("focused");
      }
      
      public function set backgroundFocusedSkin(param1:DisplayObject) : void
      {
         this.setSkinForState("focused",param1);
      }
      
      public function get backgroundErrorSkin() : DisplayObject
      {
         return this.getSkinForState("error");
      }
      
      public function set backgroundErrorSkin(param1:DisplayObject) : void
      {
         this.setSkinForState("error",param1);
      }
      
      public function get stateToSkinFunction() : Function
      {
         return this._stateToSkinFunction;
      }
      
      public function set stateToSkinFunction(param1:Function) : void
      {
         if(this._stateToSkinFunction == param1)
         {
            return;
         }
         this._stateToSkinFunction = param1;
         this.invalidate("skin");
      }
      
      public function get fontStyles() : TextFormat
      {
         return this._fontStylesSet.format;
      }
      
      public function set fontStyles(param1:TextFormat) : void
      {
         if(this.processStyleRestriction(arguments.callee))
         {
            return;
         }
         this._fontStylesSet.format = param1;
      }
      
      public function get disabledFontStyles() : TextFormat
      {
         return this._fontStylesSet.disabledFormat;
      }
      
      public function set disabledFontStyles(param1:TextFormat) : void
      {
         if(this.processStyleRestriction(arguments.callee))
         {
            return;
         }
         this._fontStylesSet.disabledFormat = param1;
      }
      
      public function get textEditorFactory() : Function
      {
         return this._textEditorFactory;
      }
      
      public function set textEditorFactory(param1:Function) : void
      {
         if(this._textEditorFactory == param1)
         {
            return;
         }
         this._textEditorFactory = param1;
         this.invalidate("textEditor");
      }
      
      public function get customTextEditorStyleName() : String
      {
         return this._customTextEditorStyleName;
      }
      
      public function set customTextEditorStyleName(param1:String) : void
      {
         if(this.processStyleRestriction(arguments.callee))
         {
            return;
         }
         if(this._customTextEditorStyleName === param1)
         {
            return;
         }
         this._customTextEditorStyleName = param1;
         this.invalidate("textRenderer");
      }
      
      public function get textEditorProperties() : Object
      {
         if(!this._textEditorProperties)
         {
            this._textEditorProperties = new PropertyProxy(childProperties_onChange);
         }
         return this._textEditorProperties;
      }
      
      public function set textEditorProperties(param1:Object) : void
      {
         var _loc2_:* = null;
         if(this._textEditorProperties == param1)
         {
            return;
         }
         if(!param1)
         {
            param1 = new PropertyProxy();
         }
         if(!(param1 is PropertyProxy))
         {
            _loc2_ = new PropertyProxy();
            for(var _loc3_ in param1)
            {
               _loc2_[_loc3_] = param1[_loc3_];
            }
            param1 = _loc2_;
         }
         if(this._textEditorProperties)
         {
            this._textEditorProperties.removeOnChangeCallback(childProperties_onChange);
         }
         this._textEditorProperties = PropertyProxy(param1);
         if(this._textEditorProperties)
         {
            this._textEditorProperties.addOnChangeCallback(childProperties_onChange);
         }
         this.invalidate("styles");
      }
      
      public function get customErrorCalloutStyleName() : String
      {
         return this._customErrorCalloutStyleName;
      }
      
      public function set customErrorCalloutStyleName(param1:String) : void
      {
         if(this.processStyleRestriction(arguments.callee))
         {
            return;
         }
         if(this._customErrorCalloutStyleName === param1)
         {
            return;
         }
         this._customErrorCalloutStyleName = param1;
         this.invalidate("errorCalloutFactory");
      }
      
      public function get selectionBeginIndex() : int
      {
         if(this._pendingSelectionBeginIndex >= 0)
         {
            return this._pendingSelectionBeginIndex;
         }
         if(this.textEditorViewPort)
         {
            return this.textEditorViewPort.selectionBeginIndex;
         }
         return 0;
      }
      
      public function get selectionEndIndex() : int
      {
         if(this._pendingSelectionEndIndex >= 0)
         {
            return this._pendingSelectionEndIndex;
         }
         if(this.textEditorViewPort)
         {
            return this.textEditorViewPort.selectionEndIndex;
         }
         return 0;
      }
      
      public function setFocus() : void
      {
         if(this._textEditorHasFocus)
         {
            return;
         }
         if(this.textEditorViewPort)
         {
            this._isWaitingToSetFocus = false;
            this.textEditorViewPort.setFocus();
         }
         else
         {
            this._isWaitingToSetFocus = true;
            this.invalidate("selected");
         }
      }
      
      public function clearFocus() : void
      {
         this._isWaitingToSetFocus = false;
         if(!this.textEditorViewPort || !this._textEditorHasFocus)
         {
            return;
         }
         this.textEditorViewPort.clearFocus();
      }
      
      public function selectRange(param1:int, param2:int = -1) : void
      {
         if(param2 < 0)
         {
            param2 = param1;
         }
         if(param1 < 0)
         {
            throw new RangeError("Expected begin index greater than or equal to 0. Received " + param1 + ".");
         }
         if(param2 > this._text.length)
         {
            throw new RangeError("Expected begin index less than " + this._text.length + ". Received " + param2 + ".");
         }
         if(this.textEditorViewPort !== null && (this._isValidating || !this.isInvalid()))
         {
            this._pendingSelectionBeginIndex = -1;
            this._pendingSelectionEndIndex = -1;
            this.textEditorViewPort.selectRange(param1,param2);
         }
         else
         {
            this._pendingSelectionBeginIndex = param1;
            this._pendingSelectionEndIndex = param2;
            this.invalidate("selected");
         }
      }
      
      override public function dispose() : void
      {
         var _loc1_:* = null;
         for(var _loc2_ in this._stateToSkin)
         {
            _loc1_ = this._stateToSkin[_loc2_] as DisplayObject;
            if(_loc1_ !== null && _loc1_.parent !== this)
            {
               _loc1_.dispose();
            }
         }
         super.dispose();
      }
      
      public function getFontStylesForState(param1:String) : TextFormat
      {
         if(this._fontStylesSet === null)
         {
            return null;
         }
         return this._fontStylesSet.getFormatForState(param1);
      }
      
      public function setFontStylesForState(param1:String, param2:TextFormat) : void
      {
         var _loc3_:String = "setFontStylesForState--" + param1;
         if(this.processStyleRestriction(_loc3_))
         {
            return;
         }
         this._fontStylesSet.setFormatForState(param1,param2);
      }
      
      public function getSkinForState(param1:String) : DisplayObject
      {
         return this._stateToSkin[param1] as DisplayObject;
      }
      
      public function setSkinForState(param1:String, param2:DisplayObject) : void
      {
         var _loc3_:String = "setSkinForState--" + param1;
         if(this.processStyleRestriction(_loc3_))
         {
            if(param2 !== null)
            {
               param2.dispose();
            }
            return;
         }
         if(param2 !== null)
         {
            this._stateToSkin[param1] = param2;
         }
         else
         {
            delete this._stateToSkin[param1];
         }
         this.invalidate("styles");
      }
      
      override protected function draw() : void
      {
         var _loc1_:Boolean = false;
         var _loc5_:Boolean = this.isInvalid("textEditor");
         var _loc3_:Boolean = this.isInvalid("data");
         var _loc4_:Boolean = this.isInvalid("styles");
         var _loc2_:Boolean = this.isInvalid("state");
         if(_loc5_)
         {
            this.createTextEditor();
         }
         if(_loc5_ || _loc4_)
         {
            this.refreshTextEditorProperties();
         }
         if(_loc5_ || _loc3_)
         {
            _loc1_ = this._ignoreTextChanges;
            this._ignoreTextChanges = true;
            this.textEditorViewPort.text = this._text;
            this._ignoreTextChanges = _loc1_;
         }
         if(_loc5_ || _loc2_)
         {
            this.textEditorViewPort.isEnabled = this._isEnabled;
            if(!this._isEnabled && Mouse.supportsNativeCursor && this._oldMouseCursor)
            {
               Mouse.cursor = this._oldMouseCursor;
               this._oldMouseCursor = null;
            }
         }
         super.draw();
         if(_loc2_ || _loc4_)
         {
            this.refreshErrorCallout();
         }
         this.doPendingActions();
      }
      
      protected function createTextEditor() : void
      {
         if(this.textEditorViewPort)
         {
            this.textEditorViewPort.removeEventListener("change",textEditor_changeHandler);
            this.textEditorViewPort.removeEventListener("focusIn",textEditor_focusInHandler);
            this.textEditorViewPort.removeEventListener("focusOut",textEditor_focusOutHandler);
            this.textEditorViewPort = null;
         }
         if(this._textEditorFactory != null)
         {
            this.textEditorViewPort = ITextEditorViewPort(this._textEditorFactory());
         }
         else
         {
            this.textEditorViewPort = new TextFieldTextEditorViewPort();
         }
         var _loc1_:String = this._customTextEditorStyleName != null ? this._customTextEditorStyleName : this.textEditorStyleName;
         this.textEditorViewPort.styleNameList.add(_loc1_);
         if(this.textEditorViewPort is IStateObserver)
         {
            IStateObserver(this.textEditorViewPort).stateContext = this;
         }
         this.textEditorViewPort.addEventListener("change",textEditor_changeHandler);
         this.textEditorViewPort.addEventListener("focusIn",textEditor_focusInHandler);
         this.textEditorViewPort.addEventListener("focusOut",textEditor_focusOutHandler);
         var _loc2_:ITextEditorViewPort = ITextEditorViewPort(this._viewPort);
         this.viewPort = this.textEditorViewPort;
         if(_loc2_)
         {
            _loc2_.dispose();
         }
      }
      
      protected function createErrorCallout() : void
      {
         if(this.callout !== null)
         {
            this.callout.removeFromParent(true);
            this.callout = null;
         }
         if(this._errorString === null)
         {
            return;
         }
         this.callout = new TextCallout();
         var _loc1_:String = this._customErrorCalloutStyleName != null ? this._customErrorCalloutStyleName : this.errorCalloutStyleName;
         this.callout.styleNameList.add(_loc1_);
         this.callout.closeOnKeys = null;
         this.callout.closeOnTouchBeganOutside = false;
         this.callout.closeOnTouchEndedOutside = false;
         this.callout.touchable = false;
         this.callout.origin = this;
         PopUpManager.addPopUp(this.callout,false,false);
      }
      
      protected function changeState(param1:String) : void
      {
         if(this._currentState === param1)
         {
            return;
         }
         this._currentState = param1;
         this.invalidate("state");
         this.dispatchEventWith("stageChange");
      }
      
      protected function doPendingActions() : void
      {
         var _loc2_:int = 0;
         var _loc1_:int = 0;
         if(this._isWaitingToSetFocus || this._focusManager && this._focusManager.focus == this)
         {
            this._isWaitingToSetFocus = false;
            if(!this._textEditorHasFocus)
            {
               this.textEditorViewPort.setFocus();
            }
         }
         if(this._pendingSelectionBeginIndex >= 0)
         {
            _loc2_ = this._pendingSelectionBeginIndex;
            _loc1_ = this._pendingSelectionEndIndex;
            this._pendingSelectionBeginIndex = -1;
            this._pendingSelectionEndIndex = -1;
            this.selectRange(_loc2_,_loc1_);
         }
      }
      
      protected function refreshTextEditorProperties() : void
      {
         var _loc2_:* = null;
         this.textEditorViewPort.fontStyles = this._fontStylesSet;
         this.textEditorViewPort.maxChars = this._maxChars;
         this.textEditorViewPort.restrict = this._restrict;
         this.textEditorViewPort.isEditable = this._isEditable;
         for(var _loc1_ in this._textEditorProperties)
         {
            _loc2_ = this._textEditorProperties[_loc1_];
            this.textEditorViewPort[_loc1_] = _loc2_;
         }
      }
      
      override protected function refreshBackgroundSkin() : void
      {
         var _loc2_:* = null;
         var _loc1_:DisplayObject = this.currentBackgroundSkin;
         this.currentBackgroundSkin = this.getCurrentSkin();
         switch(_loc1_)
         {
            default:
               if(_loc1_ is IStateObserver)
               {
                  IStateObserver(_loc1_).stateContext = null;
               }
               this.removeChild(_loc1_,false);
            case null:
               if(this.currentBackgroundSkin !== null)
               {
                  if(this.currentBackgroundSkin is IStateObserver)
                  {
                     IStateObserver(this.currentBackgroundSkin).stateContext = this;
                  }
                  this.addChildAt(this.currentBackgroundSkin,0);
                  if(this.currentBackgroundSkin is IFeathersControl)
                  {
                     IFeathersControl(this.currentBackgroundSkin).initializeNow();
                  }
                  if(this.currentBackgroundSkin is IMeasureDisplayObject)
                  {
                     _loc2_ = IMeasureDisplayObject(this.currentBackgroundSkin);
                     this._explicitBackgroundWidth = _loc2_.explicitWidth;
                     this._explicitBackgroundHeight = _loc2_.explicitHeight;
                     this._explicitBackgroundMinWidth = _loc2_.explicitMinWidth;
                     this._explicitBackgroundMinHeight = _loc2_.explicitMinHeight;
                     break;
                  }
                  this._explicitBackgroundWidth = this.currentBackgroundSkin.width;
                  this._explicitBackgroundHeight = this.currentBackgroundSkin.height;
                  this._explicitBackgroundMinWidth = this._explicitBackgroundWidth;
                  this._explicitBackgroundMinHeight = this._explicitBackgroundHeight;
                  break;
               }
               break;
            case this.currentBackgroundSkin:
         }
      }
      
      protected function getCurrentSkin() : DisplayObject
      {
         if(this._stateToSkinFunction != null)
         {
            return DisplayObject(this._stateToSkinFunction(this,this._currentState,this.currentBackgroundSkin));
         }
         var _loc1_:DisplayObject = this._stateToSkin[this._currentState] as DisplayObject;
         if(_loc1_ !== null)
         {
            return _loc1_;
         }
         return this._backgroundSkin;
      }
      
      protected function refreshState() : void
      {
         if(this._isEnabled)
         {
            if(this._textEditorHasFocus)
            {
               this.changeState("focused");
            }
            else if(this._errorString !== null)
            {
               this.changeState("error");
            }
            else
            {
               this.changeState("enabled");
            }
         }
         else
         {
            this.changeState("disabled");
         }
      }
      
      protected function refreshErrorCallout() : void
      {
         if(this._textEditorHasFocus && this.callout === null && this._errorString !== null && this._errorString.length > 0)
         {
            this.createErrorCallout();
         }
         else if(this.callout !== null && (!this._textEditorHasFocus || this._errorString === null || this._errorString.length === 0))
         {
            this.callout.removeFromParent(true);
            this.callout = null;
         }
         if(this.callout !== null)
         {
            this.callout.text#2 = this._errorString;
         }
      }
      
      protected function setFocusOnTextEditorWithTouch(param1:Touch) : void
      {
         if(!this.isFocusEnabled)
         {
            return;
         }
         var _loc3_:Point = Pool.getPoint();
         param1.getLocation(this.stage,_loc3_);
         var _loc2_:Boolean = this.contains(this.stage.hitTest(_loc3_));
         if(!this._textEditorHasFocus && _loc2_)
         {
            this.globalToLocal(_loc3_,_loc3_);
            _loc3_.x -= this._paddingLeft;
            _loc3_.y -= this._paddingTop;
            this._isWaitingToSetFocus = false;
            this.textEditorViewPort.setFocus(_loc3_);
         }
         Pool.putPoint(_loc3_);
      }
      
      protected function textArea_touchHandler(param1:TouchEvent) : void
      {
         var _loc3_:* = null;
         if(!this._isEnabled)
         {
            this._textAreaTouchPointID = -1;
            return;
         }
         var _loc2_:DisplayObject = DisplayObject(this.horizontalScrollBar);
         var _loc4_:DisplayObject = DisplayObject(this.verticalScrollBar);
         if(this._textAreaTouchPointID >= 0)
         {
            _loc3_ = param1.getTouch(this,"ended",this._textAreaTouchPointID);
            if(!_loc3_ || _loc3_.isTouching(_loc4_) || _loc3_.isTouching(_loc2_))
            {
               return;
            }
            this.removeEventListener("scroll",textArea_scrollHandler);
            this._textAreaTouchPointID = -1;
            if(this.textEditorViewPort.setTouchFocusOnEndedPhase)
            {
               this.setFocusOnTextEditorWithTouch(_loc3_);
            }
         }
         else
         {
            _loc3_ = param1.getTouch(this,"began");
            if(_loc3_)
            {
               if(_loc3_.isTouching(_loc4_) || _loc3_.isTouching(_loc2_))
               {
                  return;
               }
               this._textAreaTouchPointID = _loc3_.id#2;
               if(!this.textEditorViewPort.setTouchFocusOnEndedPhase)
               {
                  this.setFocusOnTextEditorWithTouch(_loc3_);
               }
               this.addEventListener("scroll",textArea_scrollHandler);
               return;
            }
            _loc3_ = param1.getTouch(this,"hover");
            if(_loc3_)
            {
               if(_loc3_.isTouching(_loc4_) || _loc3_.isTouching(_loc2_))
               {
                  return;
               }
               if(Mouse.supportsNativeCursor && !this._oldMouseCursor)
               {
                  this._oldMouseCursor = Mouse.cursor;
                  Mouse.cursor = "ibeam";
               }
               return;
            }
            if(Mouse.supportsNativeCursor && this._oldMouseCursor)
            {
               Mouse.cursor = this._oldMouseCursor;
               this._oldMouseCursor = null;
            }
         }
      }
      
      protected function textArea_scrollHandler(param1:Event) : void
      {
         this.removeEventListener("scroll",textArea_scrollHandler);
         this._textAreaTouchPointID = -1;
      }
      
      protected function textArea_removedFromStageHandler(param1:Event) : void
      {
         if(!this._focusManager && this._textEditorHasFocus)
         {
            this.clearFocus();
         }
         this._isWaitingToSetFocus = false;
         this._textEditorHasFocus = false;
         this._textAreaTouchPointID = -1;
         this.removeEventListener("scroll",textArea_scrollHandler);
         if(Mouse.supportsNativeCursor && this._oldMouseCursor)
         {
            Mouse.cursor = this._oldMouseCursor;
            this._oldMouseCursor = null;
         }
      }
      
      override protected function focusInHandler(param1:Event) : void
      {
         if(!this._focusManager)
         {
            return;
         }
         super.focusInHandler(param1);
         this.setFocus();
      }
      
      override protected function focusOutHandler(param1:Event) : void
      {
         if(!this._focusManager)
         {
            return;
         }
         super.focusOutHandler(param1);
         this.textEditorViewPort.clearFocus();
         this.invalidate("state");
      }
      
      override protected function stage_keyDownHandler(param1:KeyboardEvent) : void
      {
         if(this._isEditable)
         {
            return;
         }
         super.stage_keyDownHandler(param1);
      }
      
      protected function textEditor_changeHandler(param1:Event) : void
      {
         if(this._ignoreTextChanges)
         {
            return;
         }
         this.text#2 = this.textEditorViewPort.text;
      }
      
      protected function textEditor_focusInHandler(param1:Event) : void
      {
         this._textEditorHasFocus = true;
         this.refreshState();
         this.refreshErrorCallout();
         this._touchPointID = -1;
         this.invalidate("state");
         if(this._focusManager && this.isFocusEnabled && this._focusManager.focus !== this)
         {
            this._focusManager.focus = this;
         }
         else if(!this._focusManager)
         {
            this.dispatchEventWith("focusIn");
         }
      }
      
      protected function textEditor_focusOutHandler(param1:Event) : void
      {
         this._textEditorHasFocus = false;
         this.refreshState();
         this.refreshErrorCallout();
         this.invalidate("state");
         if(this._focusManager && this._focusManager.focus === this)
         {
            this._focusManager.focus = null;
         }
         else if(!this._focusManager)
         {
            this.dispatchEventWith("focusOut");
         }
      }
      
      protected function fontStyles_changeHandler(param1:Event) : void
      {
         this.invalidate("styles");
      }
   }
}
