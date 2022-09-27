package feathers.controls.text
{
   import feathers.core.BaseTextEditor;
   import feathers.core.FocusManager;
   import feathers.core.IFeathersControl;
   import feathers.core.INativeFocusOwner;
   import feathers.core.ITextEditor;
   import feathers.skins.IStyleProvider;
   import feathers.utils.geom.matrixToRotation;
   import feathers.utils.geom.matrixToScaleX;
   import feathers.utils.geom.matrixToScaleY;
   import flash.display.BitmapData;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.SoftKeyboardEvent;
   import flash.geom.Matrix;
   import flash.geom.Matrix3D;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   import starling.display.Image;
   import starling.events.Event;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   import starling.rendering.Painter;
   import starling.text.TextFormat;
   import starling.textures.ConcreteTexture;
   import starling.textures.Texture;
   import starling.utils.MathUtil;
   import starling.utils.MatrixUtil;
   import starling.utils.Pool;
   import starling.utils.SystemUtil;
   
   public class TextFieldTextEditor extends BaseTextEditor implements ITextEditor, INativeFocusOwner
   {
      
      public static var globalStyleProvider:IStyleProvider;
       
      
      protected var textField:TextField;
      
      protected var textSnapshot:Image;
      
      protected var measureTextField:TextField;
      
      protected var _snapshotWidth:int = 0;
      
      protected var _snapshotHeight:int = 0;
      
      protected var _textFieldSnapshotClipRect:Rectangle;
      
      protected var _textFieldOffsetX:Number = 0;
      
      protected var _textFieldOffsetY:Number = 0;
      
      protected var _lastGlobalScaleX:Number = 0;
      
      protected var _lastGlobalScaleY:Number = 0;
      
      protected var _needsNewTexture:Boolean = false;
      
      protected var _previousTextFormat:flash.text.TextFormat;
      
      protected var _currentTextFormat:flash.text.TextFormat;
      
      protected var _textFormatForState:Object;
      
      protected var _fontStylesTextFormat:flash.text.TextFormat;
      
      protected var _textFormat:flash.text.TextFormat;
      
      protected var _disabledTextFormat:flash.text.TextFormat;
      
      protected var _embedFonts:Boolean = false;
      
      protected var _wordWrap:Boolean = false;
      
      protected var _multiline:Boolean = false;
      
      protected var _isHTML:Boolean = false;
      
      protected var _alwaysShowSelection:Boolean = false;
      
      protected var _displayAsPassword:Boolean = false;
      
      protected var _maxChars:int = 0;
      
      protected var _restrict:String;
      
      protected var _isEditable:Boolean = true;
      
      protected var _isSelectable:Boolean = true;
      
      private var _antiAliasType:String = "advanced";
      
      private var _gridFitType:String = "pixel";
      
      private var _sharpness:Number = 0;
      
      private var _thickness:Number = 0;
      
      private var _background:Boolean = false;
      
      private var _backgroundColor:uint = 16777215;
      
      private var _border:Boolean = false;
      
      private var _borderColor:uint = 0;
      
      protected var _useGutter:Boolean = false;
      
      protected var _textFieldHasFocus:Boolean = false;
      
      protected var _isWaitingToSetFocus:Boolean = false;
      
      protected var _pendingSelectionBeginIndex:int = -1;
      
      protected var _pendingSelectionEndIndex:int = -1;
      
      protected var _maintainTouchFocus:Boolean = false;
      
      protected var _updateSnapshotOnScaleChange:Boolean = false;
      
      protected var _useSnapshotDelayWorkaround:Boolean = false;
      
      protected var resetScrollOnFocusOut:Boolean = true;
      
      public function TextFieldTextEditor()
      {
         _textFieldSnapshotClipRect = new Rectangle();
         super();
         this.isQuickHitAreaEnabled = true;
         this.addEventListener("addedToStage",textEditor_addedToStageHandler);
         this.addEventListener("removedFromStage",textEditor_removedFromStageHandler);
      }
      
      override protected function get defaultStyleProvider() : IStyleProvider
      {
         return globalStyleProvider;
      }
      
      public function get nativeFocus() : Object
      {
         return this.textField;
      }
      
      public function get baseline() : Number
      {
         if(!this.textField)
         {
            return 0;
         }
         var _loc1_:* = 0;
         if(this._useGutter)
         {
            _loc1_ = 2;
         }
         return _loc1_ + this.textField.getLineMetrics(0).ascent;
      }
      
      public function get currentTextFormat() : flash.text.TextFormat
      {
         return this._currentTextFormat;
      }
      
      public function get textFormat() : flash.text.TextFormat
      {
         return this._textFormat;
      }
      
      public function set textFormat(param1:flash.text.TextFormat) : void
      {
         if(this._textFormat == param1)
         {
            return;
         }
         this._textFormat = param1;
         this._previousTextFormat = null;
         this.invalidate("styles");
      }
      
      public function get disabledTextFormat() : flash.text.TextFormat
      {
         return this._disabledTextFormat;
      }
      
      public function set disabledTextFormat(param1:flash.text.TextFormat) : void
      {
         if(this._disabledTextFormat == param1)
         {
            return;
         }
         this._disabledTextFormat = param1;
         this.invalidate("styles");
      }
      
      public function get embedFonts() : Boolean
      {
         return this._embedFonts;
      }
      
      public function set embedFonts(param1:Boolean) : void
      {
         if(this._embedFonts == param1)
         {
            return;
         }
         this._embedFonts = param1;
         this.invalidate("styles");
      }
      
      public function get wordWrap() : Boolean
      {
         return this._wordWrap;
      }
      
      public function set wordWrap(param1:Boolean) : void
      {
         if(this._wordWrap == param1)
         {
            return;
         }
         this._wordWrap = param1;
         this.invalidate("styles");
      }
      
      public function get multiline() : Boolean
      {
         return this._multiline;
      }
      
      public function set multiline(param1:Boolean) : void
      {
         if(this._multiline == param1)
         {
            return;
         }
         this._multiline = param1;
         this.invalidate("styles");
      }
      
      public function get isHTML() : Boolean
      {
         return this._isHTML;
      }
      
      public function set isHTML(param1:Boolean) : void
      {
         if(this._isHTML == param1)
         {
            return;
         }
         this._isHTML = param1;
         this.invalidate("data");
      }
      
      public function get alwaysShowSelection() : Boolean
      {
         return this._alwaysShowSelection;
      }
      
      public function set alwaysShowSelection(param1:Boolean) : void
      {
         if(this._alwaysShowSelection == param1)
         {
            return;
         }
         this._alwaysShowSelection = param1;
         this.invalidate("styles");
      }
      
      public function get displayAsPassword() : Boolean
      {
         return this._displayAsPassword;
      }
      
      public function set displayAsPassword(param1:Boolean) : void
      {
         if(this._displayAsPassword == param1)
         {
            return;
         }
         this._displayAsPassword = param1;
         this.invalidate("styles");
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
      
      public function get isSelectable() : Boolean
      {
         return this._isSelectable;
      }
      
      public function set isSelectable(param1:Boolean) : void
      {
         if(this._isSelectable == param1)
         {
            return;
         }
         this._isSelectable = param1;
         this.invalidate("styles");
      }
      
      public function get antiAliasType() : String
      {
         return this._antiAliasType;
      }
      
      public function set antiAliasType(param1:String) : void
      {
         if(this._antiAliasType == param1)
         {
            return;
         }
         this._antiAliasType = param1;
         this.invalidate("styles");
      }
      
      public function get gridFitType() : String
      {
         return this._gridFitType;
      }
      
      public function set gridFitType(param1:String) : void
      {
         if(this._gridFitType == param1)
         {
            return;
         }
         this._gridFitType = param1;
         this.invalidate("styles");
      }
      
      public function get sharpness() : Number
      {
         return this._sharpness;
      }
      
      public function set sharpness(param1:Number) : void
      {
         if(this._sharpness == param1)
         {
            return;
         }
         this._sharpness = param1;
         this.invalidate("data");
      }
      
      public function get thickness() : Number
      {
         return this._thickness;
      }
      
      public function set thickness(param1:Number) : void
      {
         if(this._thickness == param1)
         {
            return;
         }
         this._thickness = param1;
         this.invalidate("data");
      }
      
      public function get background() : Boolean
      {
         return this._background;
      }
      
      public function set background(param1:Boolean) : void
      {
         if(this._background == param1)
         {
            return;
         }
         this._background = param1;
         this.invalidate("styles");
      }
      
      public function get backgroundColor() : uint
      {
         return this._backgroundColor;
      }
      
      public function set backgroundColor(param1:uint) : void
      {
         if(this._backgroundColor == param1)
         {
            return;
         }
         this._backgroundColor = param1;
         this.invalidate("styles");
      }
      
      public function get border() : Boolean
      {
         return this._border;
      }
      
      public function set border(param1:Boolean) : void
      {
         if(this._border == param1)
         {
            return;
         }
         this._border = param1;
         this.invalidate("styles");
      }
      
      public function get borderColor() : uint
      {
         return this._borderColor;
      }
      
      public function set borderColor(param1:uint) : void
      {
         if(this._borderColor == param1)
         {
            return;
         }
         this._borderColor = param1;
         this.invalidate("styles");
      }
      
      public function get useGutter() : Boolean
      {
         return this._useGutter;
      }
      
      public function set useGutter(param1:Boolean) : void
      {
         if(this._useGutter == param1)
         {
            return;
         }
         this._useGutter = param1;
         this.invalidate("styles");
      }
      
      public function get setTouchFocusOnEndedPhase() : Boolean
      {
         return false;
      }
      
      public function get selectionBeginIndex() : int
      {
         if(this._pendingSelectionBeginIndex >= 0)
         {
            return this._pendingSelectionBeginIndex;
         }
         if(this.textField)
         {
            return this.textField.selectionBeginIndex;
         }
         return 0;
      }
      
      public function get selectionEndIndex() : int
      {
         if(this._pendingSelectionEndIndex >= 0)
         {
            return this._pendingSelectionEndIndex;
         }
         if(this.textField)
         {
            return this.textField.selectionEndIndex;
         }
         return 0;
      }
      
      public function get maintainTouchFocus() : Boolean
      {
         return this._maintainTouchFocus;
      }
      
      public function set maintainTouchFocus(param1:Boolean) : void
      {
         this._maintainTouchFocus = param1;
      }
      
      public function get updateSnapshotOnScaleChange() : Boolean
      {
         return this._updateSnapshotOnScaleChange;
      }
      
      public function set updateSnapshotOnScaleChange(param1:Boolean) : void
      {
         if(this._updateSnapshotOnScaleChange == param1)
         {
            return;
         }
         this._updateSnapshotOnScaleChange = param1;
         this.invalidate("data");
      }
      
      public function get useSnapshotDelayWorkaround() : Boolean
      {
         return this._useSnapshotDelayWorkaround;
      }
      
      public function set useSnapshotDelayWorkaround(param1:Boolean) : void
      {
         if(this._useSnapshotDelayWorkaround == param1)
         {
            return;
         }
         this._useSnapshotDelayWorkaround = param1;
         this.invalidate("data");
      }
      
      override public function dispose() : void
      {
         if(this.textSnapshot)
         {
            this.textSnapshot.texture.dispose();
            this.removeChild(this.textSnapshot,true);
            this.textSnapshot = null;
         }
         if(this.textField)
         {
            if(this.textField.parent)
            {
               this.textField.parent.removeChild(this.textField);
            }
            this.textField.removeEventListener("change",textField_changeHandler);
            this.textField.removeEventListener("focusIn",textField_focusInHandler);
            this.textField.removeEventListener("focusOut",textField_focusOutHandler);
            this.textField.removeEventListener("keyDown",textField_keyDownHandler);
            this.textField.removeEventListener("softKeyboardActivating",textField_softKeyboardActivatingHandler);
            this.textField.removeEventListener("softKeyboardActivate",textField_softKeyboardActivateHandler);
            this.textField.removeEventListener("softKeyboardDeactivate",textField_softKeyboardDeactivateHandler);
         }
         this.textField = null;
         this.measureTextField = null;
         this.stateContext = null;
         super.dispose();
      }
      
      override public function render(param1:Painter) : void
      {
         var _loc2_:* = null;
         if(this.textSnapshot)
         {
            if(this._updateSnapshotOnScaleChange)
            {
               _loc2_ = Pool.getMatrix();
               this.getTransformationMatrix(this.stage,_loc2_);
               if(matrixToScaleX(_loc2_) !== this._lastGlobalScaleX || matrixToScaleY(_loc2_) !== this._lastGlobalScaleY)
               {
                  this.invalidate("size");
                  this.validate();
               }
               Pool.putMatrix(_loc2_);
            }
            this.positionSnapshot();
         }
         if(this.textField && this.textField.visible)
         {
            this.transformTextField();
         }
         super.render(param1);
      }
      
      public function setFocus(param1:Point = null) : void
      {
         var _loc10_:* = null;
         var _loc6_:* = NaN;
         var _loc4_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc13_:* = NaN;
         var _loc7_:* = NaN;
         var _loc9_:* = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc5_:int = 0;
         var _loc14_:* = null;
         var _loc12_:Number = NaN;
         if(this.stage !== null)
         {
            var _loc15_:*;
            _loc10_ = this.stage !== null ? this.stage.starling : (_loc15_ = Starling, starling.core.Starling.sCurrent);
            if(this.textField.parent === null)
            {
               _loc10_.nativeStage.addChild(this.textField);
            }
            if(param1 !== null)
            {
               _loc6_ = 1;
               if(_loc10_.supportHighResolutions)
               {
                  _loc6_ = Number(_loc10_.nativeStage.contentsScaleFactor);
               }
               _loc4_ = _loc10_.contentScaleFactor / _loc6_;
               _loc8_ = this.textField.scaleX;
               _loc11_ = this.textField.scaleY;
               _loc13_ = 2;
               if(this._useGutter)
               {
                  _loc13_ = 0;
               }
               _loc7_ = Number(param1.x + _loc13_);
               _loc9_ = Number(param1.y + _loc13_);
               if(_loc7_ < _loc13_)
               {
                  _loc7_ = _loc13_;
               }
               else
               {
                  _loc2_ = this.textField.width / _loc8_ - _loc13_;
                  if(_loc7_ > _loc2_)
                  {
                     _loc7_ = _loc2_;
                  }
               }
               if(_loc9_ < _loc13_)
               {
                  _loc9_ = _loc13_;
               }
               else
               {
                  _loc3_ = this.textField.height / _loc11_ - _loc13_;
                  if(_loc9_ > _loc3_)
                  {
                     _loc9_ = _loc3_;
                  }
               }
               this._pendingSelectionBeginIndex = this.getSelectionIndexAtPoint(_loc7_,_loc9_);
               if(this._pendingSelectionBeginIndex < 0)
               {
                  if(this._multiline)
                  {
                     _loc5_ = this.textField.getLineIndexAtPoint(this.textField.width / 2 / _loc8_,_loc9_);
                     try
                     {
                        this._pendingSelectionBeginIndex = this.textField.getLineOffset(_loc5_) + this.textField.getLineLength(_loc5_);
                        if(this._pendingSelectionBeginIndex != this._text.length)
                        {
                           this._pendingSelectionBeginIndex--;
                        }
                     }
                     catch(error:Error)
                     {
                        this._pendingSelectionBeginIndex = this._text.length;
                     }
                  }
                  else
                  {
                     this._pendingSelectionBeginIndex = this.getSelectionIndexAtPoint(_loc7_,this.textField.getLineMetrics(0).ascent / 2);
                     if(this._pendingSelectionBeginIndex < 0)
                     {
                        this._pendingSelectionBeginIndex = this._text.length;
                     }
                  }
               }
               else if(_loc14_ = this.textField.getCharBoundaries(this._pendingSelectionBeginIndex))
               {
                  _loc12_ = _loc14_.x;
                  if(_loc14_ && _loc12_ + _loc14_.width - _loc7_ < _loc7_ - _loc12_)
                  {
                     this._pendingSelectionBeginIndex++;
                  }
               }
               this._pendingSelectionEndIndex = this._pendingSelectionBeginIndex;
            }
            else
            {
               this._pendingSelectionBeginIndex = this._pendingSelectionEndIndex = -1;
            }
            if(!FocusManager.isEnabledForStage(this.stage))
            {
               _loc10_.nativeStage.focus = this.textField;
            }
            this.textField.requestSoftKeyboard();
            if(this._textFieldHasFocus)
            {
               this.invalidate("selected");
            }
         }
         else
         {
            this._isWaitingToSetFocus = true;
         }
      }
      
      public function clearFocus() : void
      {
         if(!this._textFieldHasFocus)
         {
            return;
         }
         var _loc3_:*;
         var _loc1_:Starling = this.stage !== null ? this.stage.starling : (_loc3_ = Starling, starling.core.Starling.sCurrent);
         var _loc2_:Stage = _loc1_.nativeStage;
         if(_loc2_.focus === this.textField)
         {
            _loc2_.focus = null;
         }
      }
      
      public function selectRange(param1:int, param2:int) : void
      {
         if(!this._isEditable && !this._isSelectable)
         {
            return;
         }
         if(this.textField)
         {
            if(!this._isValidating)
            {
               this.validate();
            }
            this.textField.setSelection(param1,param2);
         }
         else
         {
            this._pendingSelectionBeginIndex = param1;
            this._pendingSelectionEndIndex = param2;
         }
      }
      
      public function measureText(param1:Point = null) : Point
      {
         if(!param1)
         {
            param1 = new Point();
         }
         var _loc2_:* = this._explicitWidth !== this._explicitWidth;
         var _loc3_:* = this._explicitHeight !== this._explicitHeight;
         if(!_loc2_ && !_loc3_)
         {
            param1.x = this._explicitWidth;
            param1.y = this._explicitHeight;
            return param1;
         }
         if(!this._isInitialized)
         {
            this.initializeNow();
         }
         this.commit();
         return this.measure(param1);
      }
      
      public function getTextFormatForState(param1:String) : flash.text.TextFormat
      {
         if(this._textFormatForState === null)
         {
            return null;
         }
         return flash.text.TextFormat(this._textFormatForState[param1]);
      }
      
      public function setTextFormatForState(param1:String, param2:flash.text.TextFormat) : void
      {
         if(param2)
         {
            if(!this._textFormatForState)
            {
               this._textFormatForState = {};
            }
            this._textFormatForState[param1] = param2;
         }
         else
         {
            delete this._textFormatForState[param1];
         }
         if(this._stateContext && this._stateContext.currentState === param1)
         {
            this.invalidate("state");
         }
      }
      
      override protected function initialize() : void
      {
         this.textField = new TextField();
         this.textField.tabEnabled = false;
         this.textField.visible = false;
         this.textField.needsSoftKeyboard = true;
         this.textField.addEventListener("change",textField_changeHandler);
         this.textField.addEventListener("focusIn",textField_focusInHandler);
         this.textField.addEventListener("focusOut",textField_focusOutHandler);
         this.textField.addEventListener("mouseFocusChange",textField_mouseFocusChangeHandler);
         this.textField.addEventListener("keyDown",textField_keyDownHandler);
         this.textField.addEventListener("softKeyboardActivating",textField_softKeyboardActivatingHandler);
         this.textField.addEventListener("softKeyboardActivate",textField_softKeyboardActivateHandler);
         this.textField.addEventListener("softKeyboardDeactivate",textField_softKeyboardDeactivateHandler);
         this.measureTextField = new TextField();
         this.measureTextField.autoSize = "left";
         this.measureTextField.selectable = false;
         this.measureTextField.tabEnabled = false;
         this.measureTextField.mouseWheelEnabled = false;
         this.measureTextField.mouseEnabled = false;
      }
      
      override protected function draw() : void
      {
         var _loc1_:Boolean = this.isInvalid("size");
         this.commit();
         _loc1_ = this.autoSizeIfNeeded() || _loc1_;
         this.layout(_loc1_);
      }
      
      protected function commit() : void
      {
         var _loc2_:Boolean = this.isInvalid("styles");
         var _loc3_:Boolean = this.isInvalid("data");
         var _loc1_:Boolean = this.isInvalid("state");
         if(_loc3_ || _loc2_ || _loc1_)
         {
            this.refreshTextFormat();
            this.commitStylesAndData(this.textField);
         }
      }
      
      protected function autoSizeIfNeeded() : Boolean
      {
         var _loc2_:* = this._explicitWidth !== this._explicitWidth;
         var _loc4_:* = this._explicitHeight !== this._explicitHeight;
         var _loc3_:* = this._explicitMinWidth !== this._explicitMinWidth;
         var _loc6_:* = this._explicitMinHeight !== this._explicitMinHeight;
         if(!_loc2_ && !_loc4_ && !_loc3_ && !_loc6_)
         {
            return false;
         }
         var _loc5_:Point = Pool.getPoint();
         this.measure(_loc5_);
         var _loc1_:Boolean = this.saveMeasurements(_loc5_.x,_loc5_.y,_loc5_.x,_loc5_.y);
         Pool.putPoint(_loc5_);
         return _loc1_;
      }
      
      protected function measure(param1:Point = null) : Point
      {
         if(!param1)
         {
            param1 = new Point();
         }
         var _loc3_:* = this._explicitWidth !== this._explicitWidth;
         var _loc5_:* = this._explicitHeight !== this._explicitHeight;
         if(!_loc3_ && !_loc5_)
         {
            param1.x = this._explicitWidth;
            param1.y = this._explicitHeight;
            return param1;
         }
         this.commitStylesAndData(this.measureTextField);
         var _loc6_:* = 4;
         if(this._useGutter)
         {
            _loc6_ = 0;
         }
         var _loc2_:Number = this._explicitWidth;
         if(_loc3_)
         {
            this.measureTextField.wordWrap = false;
            _loc2_ = this.measureTextField.width - _loc6_;
            if(_loc2_ < this._explicitMinWidth)
            {
               _loc2_ = this._explicitMinWidth;
            }
            else if(_loc2_ > this._explicitMaxWidth)
            {
               _loc2_ = this._explicitMaxWidth;
            }
         }
         var _loc4_:Number = this._explicitHeight;
         if(_loc5_)
         {
            this.measureTextField.wordWrap = this._wordWrap;
            this.measureTextField.width = _loc2_ + _loc6_;
            _loc4_ = this.measureTextField.height - _loc6_;
            if(this._useGutter)
            {
               _loc4_ += 4;
            }
            if(_loc4_ < this._explicitMinHeight)
            {
               _loc4_ = this._explicitMinHeight;
            }
            else if(_loc4_ > this._explicitMaxHeight)
            {
               _loc4_ = this._explicitMaxHeight;
            }
         }
         param1.x = _loc2_;
         param1.y = _loc4_;
         return param1;
      }
      
      protected function commitStylesAndData(param1:TextField) : void
      {
         var _loc2_:* = false;
         param1.antiAliasType = this._antiAliasType;
         param1.background = this._background;
         param1.backgroundColor = this._backgroundColor;
         param1.border = this._border;
         param1.borderColor = this._borderColor;
         param1.gridFitType = this._gridFitType;
         param1.sharpness = this._sharpness;
         param1.thickness = this._thickness;
         param1.maxChars = this._maxChars;
         param1.restrict = this._restrict;
         param1.alwaysShowSelection = this._alwaysShowSelection;
         param1.displayAsPassword = this._displayAsPassword;
         param1.wordWrap = this._wordWrap;
         param1.multiline = this._multiline;
         if(!this._embedFonts && this._currentTextFormat === this._fontStylesTextFormat)
         {
            this.textField.embedFonts = SystemUtil.isEmbeddedFont(this._currentTextFormat.font,this._currentTextFormat.bold,this._currentTextFormat.italic,"embedded");
         }
         else
         {
            this.textField.embedFonts = this._embedFonts;
         }
         param1.type = !!this._isEditable ? "input" : "dynamic";
         param1.selectable = this._isEnabled && (this._isEditable || this._isSelectable);
         if(param1 === this.textField)
         {
            _loc2_ = this._previousTextFormat != this._currentTextFormat;
            this._previousTextFormat = this._currentTextFormat;
         }
         param1.defaultTextFormat = this._currentTextFormat;
         if(this._isHTML)
         {
            if(_loc2_ || param1.htmlText != this._text)
            {
               if(param1 == this.textField && this._pendingSelectionBeginIndex < 0)
               {
                  this._pendingSelectionBeginIndex = this.textField.selectionBeginIndex;
                  this._pendingSelectionEndIndex = this.textField.selectionEndIndex;
               }
               param1.htmlText = this._text;
            }
         }
         else if(_loc2_ || param1.text#2 != this._text)
         {
            if(param1 == this.textField && this._pendingSelectionBeginIndex < 0)
            {
               this._pendingSelectionBeginIndex = this.textField.selectionBeginIndex;
               this._pendingSelectionEndIndex = this.textField.selectionEndIndex;
            }
            param1.text#2 = this._text;
         }
      }
      
      protected function refreshTextFormat() : void
      {
         var _loc2_:* = null;
         var _loc1_:* = null;
         if(this._textFormatForState !== null)
         {
            if(this._textFormatForState !== null)
            {
               _loc1_ = this._stateContext.currentState;
               if(_loc1_ in this._textFormatForState)
               {
                  _loc2_ = flash.text.TextFormat(this._textFormatForState[_loc1_]);
               }
            }
            if(_loc2_ === null && this._disabledTextFormat !== null && this._stateContext is IFeathersControl && !IFeathersControl(this._stateContext).isEnabled)
            {
               _loc2_ = this._disabledTextFormat;
            }
         }
         else if(!this._isEnabled && this._disabledTextFormat !== null)
         {
            _loc2_ = this._disabledTextFormat;
         }
         if(_loc2_ === null)
         {
            _loc2_ = this._textFormat;
         }
         if(_loc2_ === null)
         {
            _loc2_ = this.getTextFormatFromFontStyles();
         }
         this._currentTextFormat = _loc2_;
      }
      
      protected function getTextFormatFromFontStyles() : flash.text.TextFormat
      {
         var _loc1_:* = null;
         if(this.isInvalid("styles") || this.isInvalid("state"))
         {
            if(this._fontStyles !== null)
            {
               _loc1_ = this._fontStyles.getTextFormatForTarget(this);
            }
            if(_loc1_ !== null)
            {
               this._fontStylesTextFormat = _loc1_.toNativeFormat(this._fontStylesTextFormat);
            }
            else if(this._fontStylesTextFormat === null)
            {
               this._fontStylesTextFormat = new flash.text.TextFormat();
            }
         }
         return this._fontStylesTextFormat;
      }
      
      protected function getVerticalAlignment() : String
      {
         var _loc2_:* = null;
         var _loc1_:String = null;
         switch(_loc2_)
         {
            default:
               _loc1_ = _loc2_.verticalAlign;
               break;
            case null:
            case null:
         }
         if(_loc1_ === null)
         {
            _loc1_ = "top";
         }
         return _loc1_;
      }
      
      protected function getVerticalAlignmentOffsetY() : Number
      {
         var _loc2_:String = this.getVerticalAlignment();
         var _loc1_:Number = this.textField.textHeight;
         if(_loc1_ > this.actualHeight)
         {
            return 0;
         }
         if(_loc2_ === "bottom")
         {
            return this.actualHeight - _loc1_;
         }
         if(_loc2_ === "center")
         {
            return (this.actualHeight - _loc1_) / 2;
         }
         return 0;
      }
      
      protected function layout(param1:Boolean) : void
      {
         var _loc3_:Boolean = this.isInvalid("styles");
         var _loc4_:Boolean = this.isInvalid("data");
         var _loc2_:Boolean = this.isInvalid("state");
         if(param1)
         {
            this.refreshSnapshotParameters();
            this.refreshTextFieldSize();
            this.transformTextField();
            this.positionSnapshot();
         }
         this.checkIfNewSnapshotIsNeeded();
         if(!this._textFieldHasFocus && (param1 || _loc3_ || _loc4_ || _loc2_ || this._needsNewTexture))
         {
            if(this._useSnapshotDelayWorkaround)
            {
               this.addEventListener("enterFrame",refreshSnapshot_enterFrameHandler);
            }
            else
            {
               this.refreshSnapshot();
            }
         }
         this.doPendingActions();
      }
      
      protected function getSelectionIndexAtPoint(param1:Number, param2:Number) : int
      {
         return this.textField.getCharIndexAtPoint(param1,param2);
      }
      
      protected function refreshTextFieldSize() : void
      {
         var _loc1_:* = 4;
         if(this._useGutter)
         {
            _loc1_ = 0;
         }
         this.textField.width = this.actualWidth + _loc1_;
         this.textField.height = this.actualHeight + _loc1_;
      }
      
      protected function refreshSnapshotParameters() : void
      {
         var _loc4_:* = null;
         this._textFieldOffsetX = 0;
         this._textFieldOffsetY = 0;
         this._textFieldSnapshotClipRect.x = 0;
         this._textFieldSnapshotClipRect.y = 0;
         var _loc6_:*;
         var _loc1_:Starling = this.stage !== null ? this.stage.starling : (_loc6_ = Starling, starling.core.Starling.sCurrent);
         var _loc2_:Number = _loc1_.contentScaleFactor;
         var _loc3_:* = Number(this.actualWidth * _loc2_);
         if(this._updateSnapshotOnScaleChange)
         {
            _loc4_ = Pool.getMatrix();
            this.getTransformationMatrix(this.stage,_loc4_);
            _loc3_ *= matrixToScaleX(_loc4_);
         }
         if(_loc3_ < 0)
         {
            _loc3_ = 0;
         }
         var _loc5_:* = Number(this.actualHeight * _loc2_);
         if(this._updateSnapshotOnScaleChange)
         {
            _loc5_ *= matrixToScaleY(_loc4_);
            Pool.putMatrix(_loc4_);
         }
         if(_loc5_ < 0)
         {
            _loc5_ = 0;
         }
         this._textFieldSnapshotClipRect.width = _loc3_;
         this._textFieldSnapshotClipRect.height = _loc5_;
      }
      
      protected function transformTextField() : void
      {
         var _loc10_:* = null;
         var _loc13_:* = null;
         var _loc6_:Matrix = Pool.getMatrix();
         var _loc7_:Point = Pool.getPoint();
         this.getTransformationMatrix(this.stage,_loc6_);
         var _loc1_:Number = matrixToScaleX(_loc6_);
         var _loc3_:Number = matrixToScaleY(_loc6_);
         var _loc9_:* = _loc1_;
         if(_loc3_ < _loc9_)
         {
            _loc9_ = _loc3_;
         }
         var _loc14_:*;
         var _loc8_:Starling = this.stage !== null ? this.stage.starling : (_loc14_ = Starling, starling.core.Starling.sCurrent);
         var _loc5_:* = 1;
         if(_loc8_.supportHighResolutions)
         {
            _loc5_ = Number(_loc8_.nativeStage.contentsScaleFactor);
         }
         var _loc4_:Number = _loc8_.contentScaleFactor / _loc5_;
         var _loc11_:* = 0;
         if(!this._useGutter)
         {
            _loc11_ = Number(2 * _loc9_);
         }
         var _loc12_:Number = this.getVerticalAlignmentOffsetY();
         if(this.is3D)
         {
            _loc10_ = Pool.getMatrix3D();
            _loc13_ = Pool.getPoint3D();
            this.getTransformationMatrix3D(this.stage,_loc10_);
            MatrixUtil.transformCoords3D(_loc10_,-_loc11_,-_loc11_ + _loc12_,0,_loc13_);
            _loc7_.setTo(_loc13_.x,_loc13_.y);
            Pool.putPoint3D(_loc13_);
            Pool.putMatrix3D(_loc10_);
         }
         else
         {
            MatrixUtil.transformCoords(_loc6_,-_loc11_,-_loc11_ + _loc12_,_loc7_);
         }
         var _loc2_:Rectangle = _loc8_.viewPort;
         this.textField.x = Math.round(_loc2_.x + _loc7_.x * _loc4_);
         this.textField.y = Math.round(_loc2_.y + _loc7_.y * _loc4_);
         this.textField.rotation = matrixToRotation(_loc6_) * 180 / 3.141592653589793;
         this.textField.scaleX = matrixToScaleX(_loc6_) * _loc4_;
         this.textField.scaleY = matrixToScaleY(_loc6_) * _loc4_;
         Pool.putPoint(_loc7_);
         Pool.putMatrix(_loc6_);
      }
      
      protected function positionSnapshot() : void
      {
         if(!this.textSnapshot)
         {
            return;
         }
         var _loc1_:Matrix = Pool.getMatrix();
         this.getTransformationMatrix(this.stage,_loc1_);
         this.textSnapshot.x = Math.round(_loc1_.tx) - _loc1_.tx;
         this.textSnapshot.y = Math.round(_loc1_.ty) - _loc1_.ty;
         this.textSnapshot.y += this.getVerticalAlignmentOffsetY();
         Pool.putMatrix(_loc1_);
      }
      
      protected function checkIfNewSnapshotIsNeeded() : void
      {
         var _loc4_:*;
         var _loc1_:Starling = this.stage !== null ? this.stage.starling : (_loc4_ = Starling, starling.core.Starling.sCurrent);
         var _loc2_:* = _loc1_.profile !== "baselineConstrained";
         if(_loc2_)
         {
            this._snapshotWidth = this._textFieldSnapshotClipRect.width;
            this._snapshotHeight = this._textFieldSnapshotClipRect.height;
         }
         else
         {
            this._snapshotWidth = MathUtil.getNextPowerOfTwo(this._textFieldSnapshotClipRect.width);
            this._snapshotHeight = MathUtil.getNextPowerOfTwo(this._textFieldSnapshotClipRect.height);
         }
         var _loc3_:ConcreteTexture = !!this.textSnapshot ? this.textSnapshot.texture.root : null;
         this._needsNewTexture = this._needsNewTexture || !this.textSnapshot || _loc3_ !== null && (_loc3_.scale !== _loc1_.contentScaleFactor || this._snapshotWidth !== _loc3_.nativeWidth || this._snapshotHeight !== _loc3_.nativeHeight);
      }
      
      protected function doPendingActions() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(this._isWaitingToSetFocus)
         {
            this._isWaitingToSetFocus = false;
            this.setFocus();
         }
         if(this._pendingSelectionBeginIndex >= 0)
         {
            _loc1_ = this._pendingSelectionBeginIndex;
            _loc2_ = this._pendingSelectionEndIndex;
            this._pendingSelectionBeginIndex = -1;
            this._pendingSelectionEndIndex = -1;
            this.selectRange(_loc1_,_loc2_);
         }
      }
      
      protected function texture_onRestore() : void
      {
         var _loc2_:*;
         var _loc1_:Starling = this.stage !== null ? this.stage.starling : (_loc2_ = Starling, starling.core.Starling.sCurrent);
         if(this.textSnapshot && this.textSnapshot.texture && this.textSnapshot.texture.scale != _loc1_.contentScaleFactor)
         {
            this.invalidate("size");
         }
         else
         {
            this.refreshSnapshot();
         }
      }
      
      protected function refreshSnapshot() : void
      {
         var _loc2_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc8_:* = null;
         var _loc7_:* = null;
         if(this._snapshotWidth <= 0 || this._snapshotHeight <= 0)
         {
            return;
         }
         var _loc6_:* = 2;
         if(this._useGutter)
         {
            _loc6_ = 0;
         }
         var _loc10_:*;
         var _loc1_:Starling = this.stage !== null ? this.stage.starling : (_loc10_ = Starling, starling.core.Starling.sCurrent);
         var _loc4_:Number = _loc1_.contentScaleFactor;
         var _loc9_:Matrix = Pool.getMatrix();
         if(this._updateSnapshotOnScaleChange)
         {
            this.getTransformationMatrix(this.stage,_loc9_);
            _loc2_ = matrixToScaleX(_loc9_);
            _loc5_ = matrixToScaleY(_loc9_);
         }
         _loc9_.identity();
         _loc9_.translate(this._textFieldOffsetX - _loc6_,this._textFieldOffsetY - _loc6_);
         _loc9_.scale(_loc4_,_loc4_);
         if(this._updateSnapshotOnScaleChange)
         {
            _loc9_.scale(_loc2_,_loc5_);
         }
         var _loc3_:BitmapData = new BitmapData(this._snapshotWidth,this._snapshotHeight,true,16711935);
         _loc3_.draw(this.textField,_loc9_,null,null,this._textFieldSnapshotClipRect);
         Pool.putMatrix(_loc9_);
         if(!this.textSnapshot || this._needsNewTexture)
         {
            (_loc8_ = Texture.empty(_loc3_.width / _loc4_,_loc3_.height / _loc4_,true,false,false,_loc4_)).root.uploadBitmapData(_loc3_);
            _loc8_.root.onRestore = texture_onRestore;
         }
         if(!this.textSnapshot)
         {
            this.textSnapshot = new Image(_loc8_);
            this.textSnapshot.pixelSnapping = true;
            this.addChild(this.textSnapshot);
         }
         else if(this._needsNewTexture)
         {
            this.textSnapshot.texture.dispose();
            this.textSnapshot.texture = _loc8_;
            this.textSnapshot.readjustSize();
         }
         else
         {
            (_loc7_ = this.textSnapshot.texture).root.uploadBitmapData(_loc3_);
            this.textSnapshot.setRequiresRedraw();
         }
         if(this._updateSnapshotOnScaleChange)
         {
            this.textSnapshot.scaleX = 1 / _loc2_;
            this.textSnapshot.scaleY = 1 / _loc5_;
            this._lastGlobalScaleX = _loc2_;
            this._lastGlobalScaleY = _loc5_;
         }
         this.textSnapshot.alpha = this._text.length > 0 ? 1 : 0;
         _loc3_.dispose();
         this._needsNewTexture = false;
      }
      
      protected function textEditor_addedToStageHandler(param1:starling.events.Event) : void
      {
         var _loc2_:* = null;
         if(this.textField.parent === null)
         {
            var _loc3_:*;
            _loc2_ = this.stage !== null ? this.stage.starling : (_loc3_ = Starling, starling.core.Starling.sCurrent);
            _loc2_.nativeStage.addChild(this.textField);
         }
      }
      
      protected function textEditor_removedFromStageHandler(param1:starling.events.Event) : void
      {
         if(this.textField.parent)
         {
            this.textField.parent.removeChild(this.textField);
         }
      }
      
      protected function hasFocus_enterFrameHandler(param1:starling.events.Event) : void
      {
         var _loc2_:* = null;
         if(this.textSnapshot)
         {
            this.textSnapshot.visible = !this._textFieldHasFocus;
         }
         this.textField.visible = this._textFieldHasFocus;
         if(this._textFieldHasFocus)
         {
            _loc2_ = this;
            do
            {
               if(!_loc2_.visible)
               {
                  this.clearFocus();
                  break;
               }
               _loc2_ = _loc2_.parent;
            }
            while(_loc2_);
            
         }
         else
         {
            this.removeEventListener("enterFrame",hasFocus_enterFrameHandler);
         }
      }
      
      protected function refreshSnapshot_enterFrameHandler(param1:starling.events.Event) : void
      {
         this.removeEventListener("enterFrame",refreshSnapshot_enterFrameHandler);
         this.refreshSnapshot();
      }
      
      protected function stage_touchHandler(param1:TouchEvent) : void
      {
         if(this._maintainTouchFocus)
         {
            return;
         }
         var _loc3_:Touch = param1.getTouch(this.stage,"began");
         if(!_loc3_)
         {
            return;
         }
         var _loc4_:Point = Pool.getPoint();
         _loc3_.getLocation(this.stage,_loc4_);
         var _loc2_:Boolean = this.contains(this.stage.hitTest(_loc4_));
         Pool.putPoint(_loc4_);
         if(_loc2_)
         {
            return;
         }
         this.clearFocus();
      }
      
      protected function textField_changeHandler(param1:flash.events.Event) : void
      {
         if(this._isHTML)
         {
            this.text#2 = this.textField.htmlText;
         }
         else
         {
            this.text#2 = this.textField.text#2;
         }
      }
      
      protected function textField_focusInHandler(param1:FocusEvent) : void
      {
         this._textFieldHasFocus = true;
         this.stage.addEventListener("touch",stage_touchHandler);
         this.addEventListener("enterFrame",hasFocus_enterFrameHandler);
         this.dispatchEventWith("focusIn");
      }
      
      protected function textField_focusOutHandler(param1:FocusEvent) : void
      {
         this._textFieldHasFocus = false;
         this.stage.removeEventListener("touch",stage_touchHandler);
         if(this.resetScrollOnFocusOut)
         {
            this.textField.scrollH = this.textField.scrollV = 0;
         }
         this.invalidate("data");
         this.dispatchEventWith("focusOut");
      }
      
      protected function textField_mouseFocusChangeHandler(param1:FocusEvent) : void
      {
         if(!this._maintainTouchFocus)
         {
            return;
         }
         param1.preventDefault();
      }
      
      protected function textField_keyDownHandler(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == 13)
         {
            this.dispatchEventWith("enter");
         }
         else if(!FocusManager.isEnabledForStage(this.stage) && param1.keyCode == 9)
         {
            this.clearFocus();
         }
      }
      
      protected function textField_softKeyboardActivateHandler(param1:SoftKeyboardEvent) : void
      {
         this.dispatchEventWith("softKeyboardActivate",true);
      }
      
      protected function textField_softKeyboardActivatingHandler(param1:SoftKeyboardEvent) : void
      {
         this.dispatchEventWith("softKeyboardActivating",true);
      }
      
      protected function textField_softKeyboardDeactivateHandler(param1:SoftKeyboardEvent) : void
      {
         this.dispatchEventWith("softKeyboardDeactivate",true);
      }
   }
}
