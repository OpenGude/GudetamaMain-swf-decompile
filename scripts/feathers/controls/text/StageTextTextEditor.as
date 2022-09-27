package feathers.controls.text
{
   import feathers.core.BaseTextEditor;
   import feathers.core.FocusManager;
   import feathers.core.IMultilineTextEditor;
   import feathers.core.INativeFocusOwner;
   import feathers.skins.IStyleProvider;
   import feathers.text.StageTextField;
   import feathers.utils.display.stageToStarling;
   import feathers.utils.geom.matrixToScaleX;
   import feathers.utils.geom.matrixToScaleY;
   import flash.display.BitmapData;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.SoftKeyboardEvent;
   import flash.geom.Matrix;
   import flash.geom.Matrix3D;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import flash.system.Capabilities;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.getDefinitionByName;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   import starling.display.Image;
   import starling.events.Event;
   import starling.rendering.Painter;
   import starling.text.TextFormat;
   import starling.textures.ConcreteTexture;
   import starling.textures.Texture;
   import starling.utils.MatrixUtil;
   import starling.utils.Pool;
   import starling.utils.SystemUtil;
   
   public class StageTextTextEditor extends BaseTextEditor implements IMultilineTextEditor, INativeFocusOwner
   {
      
      public static var globalStyleProvider:IStyleProvider;
      
      protected static const MIN_VIEW_PORT_POSITION:Number = -8192;
      
      protected static const MAX_VIEW_PORT_POSITION:Number = 8191;
       
      
      protected var stageText:Object;
      
      protected var textSnapshot:Image;
      
      protected var _needsNewTexture:Boolean = false;
      
      protected var _ignoreStageTextChanges:Boolean = false;
      
      protected var _measureTextField:TextField;
      
      protected var _stageTextIsTextField:Boolean = false;
      
      protected var _stageTextHasFocus:Boolean = false;
      
      protected var _isWaitingToSetFocus:Boolean = false;
      
      protected var _pendingSelectionBeginIndex:int = -1;
      
      protected var _pendingSelectionEndIndex:int = -1;
      
      protected var _stageTextIsComplete:Boolean = false;
      
      protected var _autoCapitalize:String = "none";
      
      protected var _autoCorrect:Boolean = false;
      
      protected var _color:uint = 4294967295;
      
      protected var _disabledColor:uint = 4294967295;
      
      protected var _displayAsPassword:Boolean = false;
      
      protected var _isEditable:Boolean = true;
      
      protected var _isSelectable:Boolean = true;
      
      protected var _fontFamily:String = null;
      
      protected var _fontPosture:String;
      
      protected var _fontSize:int = 0;
      
      protected var _fontWeight:String = null;
      
      protected var _locale:String = "en";
      
      protected var _maxChars:int = 0;
      
      protected var _multiline:Boolean = false;
      
      protected var _restrict:String;
      
      protected var _returnKeyLabel:String = "default";
      
      protected var _softKeyboardType:String = "default";
      
      protected var _textAlign:String;
      
      protected var _maintainTouchFocus:Boolean = false;
      
      protected var _lastGlobalScaleX:Number = 0;
      
      protected var _lastGlobalScaleY:Number = 0;
      
      protected var _updateSnapshotOnScaleChange:Boolean = false;
      
      protected var _clearButtonMode:String = "whileEditing";
      
      public function StageTextTextEditor()
      {
         super();
         this._stageTextIsTextField = /^(Windows|Mac OS|Linux) .*/.exec(Capabilities.os) || Capabilities.playerType === "Desktop" && Capabilities.isDebugger;
         this.isQuickHitAreaEnabled = true;
         this.addEventListener("removedFromStage",textEditor_removedFromStageHandler);
      }
      
      override protected function get defaultStyleProvider() : IStyleProvider
      {
         return globalStyleProvider;
      }
      
      public function get nativeFocus() : Object
      {
         if(!this._isEditable)
         {
            return null;
         }
         return this.stageText;
      }
      
      public function get selectionBeginIndex() : int
      {
         if(this._pendingSelectionBeginIndex >= 0)
         {
            return this._pendingSelectionBeginIndex;
         }
         if(this.stageText)
         {
            return this.stageText.selectionAnchorIndex;
         }
         return 0;
      }
      
      public function get selectionEndIndex() : int
      {
         if(this._pendingSelectionEndIndex >= 0)
         {
            return this._pendingSelectionEndIndex;
         }
         if(this.stageText)
         {
            return this.stageText.selectionActiveIndex;
         }
         return 0;
      }
      
      public function get baseline() : Number
      {
         if(!this._measureTextField)
         {
            return 0;
         }
         return this._measureTextField.getLineMetrics(0).ascent;
      }
      
      public function get autoCapitalize() : String
      {
         return this._autoCapitalize;
      }
      
      public function set autoCapitalize(param1:String) : void
      {
         if(this._autoCapitalize == param1)
         {
            return;
         }
         this._autoCapitalize = param1;
         this.invalidate("styles");
      }
      
      public function get autoCorrect() : Boolean
      {
         return this._autoCorrect;
      }
      
      public function set autoCorrect(param1:Boolean) : void
      {
         if(this._autoCorrect == param1)
         {
            return;
         }
         this._autoCorrect = param1;
         this.invalidate("styles");
      }
      
      public function get color() : uint
      {
         return this._color;
      }
      
      public function set color(param1:uint) : void
      {
         if(this._color == param1)
         {
            return;
         }
         this._color = param1;
         this.invalidate("styles");
      }
      
      public function get disabledColor() : uint
      {
         return this._disabledColor;
      }
      
      public function set disabledColor(param1:uint) : void
      {
         if(this._disabledColor == param1)
         {
            return;
         }
         this._disabledColor = param1;
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
      
      public function get setTouchFocusOnEndedPhase() : Boolean
      {
         return true;
      }
      
      public function get fontFamily() : String
      {
         return this._fontFamily;
      }
      
      public function set fontFamily(param1:String) : void
      {
         if(this._fontFamily == param1)
         {
            return;
         }
         this._fontFamily = param1;
         this.invalidate("styles");
      }
      
      public function get fontPosture() : String
      {
         return this._fontPosture;
      }
      
      public function set fontPosture(param1:String) : void
      {
         if(this._fontPosture == param1)
         {
            return;
         }
         this._fontPosture = param1;
         this.invalidate("styles");
      }
      
      public function get fontSize() : int
      {
         return this._fontSize;
      }
      
      public function set fontSize(param1:int) : void
      {
         if(this._fontSize == param1)
         {
            return;
         }
         this._fontSize = param1;
         this.invalidate("styles");
      }
      
      public function get fontWeight() : String
      {
         return this._fontWeight;
      }
      
      public function set fontWeight(param1:String) : void
      {
         if(this._fontWeight == param1)
         {
            return;
         }
         this._fontWeight = param1;
         this.invalidate("styles");
      }
      
      public function get locale() : String
      {
         return this._locale;
      }
      
      public function set locale(param1:String) : void
      {
         if(this._locale == param1)
         {
            return;
         }
         this._locale = param1;
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
      
      public function get returnKeyLabel() : String
      {
         return this._returnKeyLabel;
      }
      
      public function set returnKeyLabel(param1:String) : void
      {
         if(this._returnKeyLabel == param1)
         {
            return;
         }
         this._returnKeyLabel = param1;
         this.invalidate("styles");
      }
      
      public function get softKeyboardType() : String
      {
         return this._softKeyboardType;
      }
      
      public function set softKeyboardType(param1:String) : void
      {
         if(this._softKeyboardType == param1)
         {
            return;
         }
         this._softKeyboardType = param1;
         this.invalidate("styles");
      }
      
      public function get textAlign() : String
      {
         return this._textAlign;
      }
      
      public function set textAlign(param1:String) : void
      {
         if(this._textAlign == param1)
         {
            return;
         }
         this._textAlign = param1;
         this.invalidate("styles");
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
      
      public function get clearButtonMode() : String
      {
         return this._clearButtonMode;
      }
      
      public function set clearButtonMode(param1:String) : void
      {
         if(this._clearButtonMode == param1)
         {
            return;
         }
         this._clearButtonMode = param1;
         this.invalidate("styles");
      }
      
      override public function dispose() : void
      {
         var _loc1_:* = null;
         if(this.stage !== null)
         {
            var _loc2_:*;
            _loc1_ = this.stage !== null ? this.stage.starling : (_loc2_ = Starling, starling.core.Starling.sCurrent);
            _loc1_.nativeStage.removeChild(this._measureTextField);
            this._measureTextField = null;
         }
         if(this.stageText)
         {
            this.disposeStageText();
         }
         if(this.textSnapshot)
         {
            this.textSnapshot.texture.dispose();
            this.removeChild(this.textSnapshot,true);
            this.textSnapshot = null;
         }
         super.dispose();
      }
      
      override public function render(param1:Painter) : void
      {
         var _loc2_:* = null;
         if(this._stageTextHasFocus)
         {
            param1.excludeFromCache(this);
         }
         if(this.textSnapshot && this._updateSnapshotOnScaleChange)
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
         if(this.stageText && this.stageText.visible)
         {
            this.refreshViewPortAndFontSize();
         }
         if(this.textSnapshot)
         {
            this.positionSnapshot();
         }
         super.render(param1);
      }
      
      public function setFocus(param1:Point = null) : void
      {
         var _loc3_:* = null;
         var _loc7_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc5_:int = 0;
         var _loc6_:* = null;
         var _loc4_:Number = NaN;
         if(!this._isEditable && starling.utils.SystemUtil.sPlatform === "AND")
         {
            return;
         }
         if(!this._isEditable && !this._isSelectable)
         {
            return;
         }
         if(this.stage !== null && this.stageText.stage === null)
         {
            var _loc9_:*;
            _loc3_ = this.stage !== null ? this.stage.starling : (_loc9_ = Starling, starling.core.Starling.sCurrent);
            this.stageText.stage = _loc3_.nativeStage;
         }
         if(this.stageText && this._stageTextIsComplete)
         {
            if(param1)
            {
               _loc7_ = param1.x + 2;
               _loc2_ = param1.y + 2;
               if(_loc7_ < 0)
               {
                  this._pendingSelectionBeginIndex = this._pendingSelectionEndIndex = 0;
               }
               else
               {
                  this._pendingSelectionBeginIndex = this._measureTextField.getCharIndexAtPoint(_loc7_,_loc2_);
                  if(this._pendingSelectionBeginIndex < 0)
                  {
                     if(this._multiline)
                     {
                        _loc5_ = _loc2_ / this._measureTextField.getLineMetrics(0).height;
                        try
                        {
                           this._pendingSelectionBeginIndex = this._measureTextField.getLineOffset(_loc5_) + this._measureTextField.getLineLength(_loc5_);
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
                        this._pendingSelectionBeginIndex = this._measureTextField.getCharIndexAtPoint(_loc7_,this._measureTextField.getLineMetrics(0).ascent / 2);
                        if(this._pendingSelectionBeginIndex < 0)
                        {
                           this._pendingSelectionBeginIndex = this._text.length;
                        }
                     }
                  }
                  else
                  {
                     _loc4_ = (_loc6_ = this._measureTextField.getCharBoundaries(this._pendingSelectionBeginIndex)).x;
                     if(_loc6_ && _loc4_ + _loc6_.width - _loc7_ < _loc7_ - _loc4_)
                     {
                        this._pendingSelectionBeginIndex++;
                     }
                  }
                  this._pendingSelectionEndIndex = this._pendingSelectionBeginIndex;
               }
            }
            else
            {
               this._pendingSelectionBeginIndex = this._pendingSelectionEndIndex = -1;
            }
            this.stageText.visible = true;
            if(!this._isEditable)
            {
               this.stageText.editable = true;
            }
            if(!this._stageTextHasFocus)
            {
               this.stageText.assignFocus();
            }
         }
         else
         {
            this._isWaitingToSetFocus = true;
         }
      }
      
      public function clearFocus() : void
      {
         if(!this._stageTextHasFocus)
         {
            return;
         }
         var _loc2_:*;
         var _loc1_:Starling = this.stage !== null ? this.stage.starling : (_loc2_ = Starling, starling.core.Starling.sCurrent);
         _loc1_.nativeStage.focus = null;
      }
      
      public function selectRange(param1:int, param2:int) : void
      {
         if(this._stageTextIsComplete && this.stageText)
         {
            this._pendingSelectionBeginIndex = -1;
            this._pendingSelectionEndIndex = -1;
            this.stageText.selectRange(param1,param2);
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
         var _loc4_:Boolean = this.isInvalid("styles");
         var _loc5_:Boolean = this.isInvalid("data");
         if(_loc4_ || _loc5_)
         {
            this.refreshMeasureProperties();
         }
         return this.measure(param1);
      }
      
      override protected function initialize() : void
      {
         var _loc2_:*;
         var _loc1_:Starling = this.stage !== null ? this.stage.starling : (_loc2_ = Starling, starling.core.Starling.sCurrent);
         if(this._measureTextField !== null && this._measureTextField.parent === null)
         {
            _loc1_.nativeStage.addChild(this._measureTextField);
         }
         else if(!this._measureTextField)
         {
            this._measureTextField = new TextField();
            this._measureTextField.visible = false;
            this._measureTextField.mouseEnabled = this._measureTextField.mouseWheelEnabled = false;
            this._measureTextField.autoSize = "left";
            this._measureTextField.multiline = false;
            this._measureTextField.wordWrap = false;
            this._measureTextField.embedFonts = false;
            this._measureTextField.defaultTextFormat = new flash.text.TextFormat(null,11,0,false,false,false);
            _loc1_.nativeStage.addChild(this._measureTextField);
         }
         this.createStageText();
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
         var _loc1_:Boolean = this.isInvalid("state");
         var _loc2_:Boolean = this.isInvalid("styles");
         var _loc3_:Boolean = this.isInvalid("data");
         if(_loc2_ || _loc3_)
         {
            this.refreshMeasureProperties();
         }
         var _loc4_:Boolean = this._ignoreStageTextChanges;
         this._ignoreStageTextChanges = true;
         if(_loc1_ || _loc2_)
         {
            this.refreshStageTextProperties();
         }
         if(_loc3_)
         {
            if(this.stageText.text != this._text)
            {
               if(this._pendingSelectionBeginIndex < 0)
               {
                  this._pendingSelectionBeginIndex = this.stageText.selectionActiveIndex;
                  this._pendingSelectionEndIndex = this.stageText.selectionAnchorIndex;
               }
               this.stageText.text = this._text;
            }
         }
         this._ignoreStageTextChanges = _loc4_;
         if(_loc2_ || _loc1_)
         {
            this.stageText.editable = this._isEditable && this._isEnabled;
         }
      }
      
      protected function measure(param1:Point = null) : Point
      {
         if(!param1)
         {
            param1 = new Point();
         }
         var _loc3_:* = this._explicitWidth !== this._explicitWidth;
         var _loc5_:* = this._explicitHeight !== this._explicitHeight;
         this._measureTextField.autoSize = "left";
         var _loc2_:Number = this._explicitWidth;
         if(_loc3_)
         {
            _loc2_ = this._measureTextField.textWidth;
            if(_loc2_ < this._explicitMinWidth)
            {
               _loc2_ = this._explicitMinWidth;
            }
            else if(_loc2_ > this._explicitMaxWidth)
            {
               _loc2_ = this._explicitMaxWidth;
            }
         }
         this._measureTextField.width = _loc2_ + 4;
         var _loc4_:Number = this._explicitHeight;
         if(_loc5_)
         {
            if(this._stageTextIsTextField)
            {
               _loc4_ = this._measureTextField.textHeight;
            }
            else
            {
               _loc4_ = this._measureTextField.height;
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
         this._measureTextField.autoSize = "none";
         this._measureTextField.width = this.actualWidth + 4;
         this._measureTextField.height = this.actualHeight;
         param1.x = _loc2_;
         param1.y = _loc4_;
         return param1;
      }
      
      protected function layout(param1:Boolean) : void
      {
         var _loc2_:* = null;
         var _loc4_:* = null;
         var _loc5_:* = null;
         var _loc9_:* = false;
         var _loc6_:Boolean = this.isInvalid("state");
         var _loc7_:Boolean = this.isInvalid("styles");
         var _loc8_:Boolean = this.isInvalid("data");
         var _loc3_:Boolean = this.isInvalid("skin");
         if(param1 || _loc7_ || _loc3_ || _loc6_)
         {
            var _loc10_:*;
            _loc2_ = this.stage !== null ? this.stage.starling : (_loc10_ = Starling, starling.core.Starling.sCurrent);
            this.refreshViewPortAndFontSize();
            this.refreshMeasureTextFieldDimensions();
            _loc4_ = this.stageText.viewPort;
            _loc5_ = !!this.textSnapshot ? this.textSnapshot.texture.root : null;
            this._needsNewTexture = this._needsNewTexture || !this.textSnapshot || _loc5_ !== null && (_loc5_.scale !== _loc2_.contentScaleFactor || _loc4_.width !== _loc5_.nativeWidth || _loc4_.height !== _loc5_.nativeHeight);
         }
         if(!this._stageTextHasFocus && (_loc6_ || _loc7_ || _loc8_ || param1 || this._needsNewTexture))
         {
            if(_loc9_ = this._text.length > 0)
            {
               this.refreshSnapshot();
            }
            if(this.textSnapshot)
            {
               this.textSnapshot.visible = !this._stageTextHasFocus;
               this.textSnapshot.alpha = !!_loc9_ ? 1 : 0;
            }
            this.stageText.visible = false;
         }
         this.doPendingActions();
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
      
      protected function refreshMeasureProperties() : void
      {
         var _loc2_:* = null;
         this._measureTextField.displayAsPassword = this._displayAsPassword;
         this._measureTextField.maxChars = this._maxChars;
         this._measureTextField.restrict = this._restrict;
         this._measureTextField.multiline = this._multiline;
         this._measureTextField.wordWrap = this._multiline;
         var _loc1_:flash.text.TextFormat = this._measureTextField.defaultTextFormat;
         if(this._fontStyles !== null)
         {
            _loc2_ = this._fontStyles.getTextFormatForTarget(this);
         }
         if(this._fontFamily !== null)
         {
            _loc1_.font = this._fontFamily;
         }
         else if(_loc2_ !== null)
         {
            _loc1_.font = _loc2_.font;
         }
         else
         {
            _loc1_.font = null;
         }
         if(this._fontSize > 0)
         {
            _loc1_.size = this._fontSize;
         }
         else if(_loc2_ !== null)
         {
            _loc1_.size = _loc2_.size;
         }
         else
         {
            _loc1_.size = 12;
         }
         if(this._fontWeight !== null)
         {
            _loc1_.bold = this._fontWeight === "bold";
         }
         else if(_loc2_ !== null)
         {
            _loc1_.bold = _loc2_.bold;
         }
         else
         {
            _loc1_.bold = false;
         }
         if(this._fontPosture !== null)
         {
            _loc1_.italic = this._fontPosture === "italic";
         }
         else if(_loc2_ !== null)
         {
            _loc1_.italic = _loc2_.italic;
         }
         else
         {
            _loc1_.italic = false;
         }
         this._measureTextField.defaultTextFormat = _loc1_;
         this._measureTextField.setTextFormat(_loc1_);
         if(this._text.length == 0)
         {
            this._measureTextField.text#2 = " ";
         }
         else
         {
            this._measureTextField.text#2 = this._text;
         }
      }
      
      protected function refreshStageTextProperties() : void
      {
         var _loc5_:* = null;
         if(this.stageText.multiline != this._multiline)
         {
            if(this.stageText)
            {
               this.disposeStageText();
            }
            this.createStageText();
         }
         if(this._fontStyles !== null)
         {
            _loc5_ = this._fontStyles.getTextFormatForTarget(this);
         }
         this.stageText.autoCapitalize = this._autoCapitalize;
         this.stageText.autoCorrect = this._autoCorrect;
         if(this._isEnabled)
         {
            if(this._color === 4294967295)
            {
               if(_loc5_ !== null)
               {
                  this.stageText.color = _loc5_.color;
               }
               else
               {
                  this.stageText.color = 0;
               }
            }
            else
            {
               this.stageText.color = this._color;
            }
         }
         else if(this._disabledColor === 4294967295)
         {
            if(this._color === 4294967295)
            {
               if(_loc5_ !== null)
               {
                  this.stageText.color = _loc5_.color;
               }
               else
               {
                  this.stageText.color = 0;
               }
            }
            else
            {
               this.stageText.color = this._color;
            }
         }
         else
         {
            this.stageText.color = this._disabledColor;
         }
         this.stageText.displayAsPassword = this._displayAsPassword;
         var _loc1_:String = this._fontFamily;
         if(_loc1_ === null && _loc5_ !== null)
         {
            _loc1_ = _loc5_.font;
         }
         this.stageText.fontFamily = _loc1_;
         var _loc3_:String = this._fontPosture;
         if(_loc3_ === null)
         {
            if(_loc5_ !== null && _loc5_.italic)
            {
               _loc3_ = "italic";
            }
            else
            {
               _loc3_ = "normal";
            }
         }
         this.stageText.fontPosture = _loc3_;
         var _loc4_:String;
         if((_loc4_ = this._fontWeight) === null)
         {
            if(_loc5_ !== null && _loc5_.bold)
            {
               _loc4_ = "bold";
            }
            else
            {
               _loc4_ = "normal";
            }
         }
         this.stageText.fontWeight = _loc4_;
         this.stageText.locale = this._locale;
         this.stageText.maxChars = this._maxChars;
         this.stageText.restrict = this._restrict;
         this.stageText.returnKeyLabel = this._returnKeyLabel;
         this.stageText.softKeyboardType = this._softKeyboardType;
         var _loc2_:String = this._textAlign;
         if(_loc2_ === null)
         {
            if(_loc5_ !== null && _loc5_.horizontalAlign)
            {
               _loc2_ = _loc5_.horizontalAlign;
            }
            else
            {
               _loc2_ = "start";
            }
         }
         this.stageText.textAlign = _loc2_;
         if("clearButtonMode" in this.stageText)
         {
            this.stageText.clearButtonMode = this._clearButtonMode;
         }
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
            _loc2_ = this._pendingSelectionEndIndex < 0 ? this._pendingSelectionBeginIndex : int(this._pendingSelectionEndIndex);
            this._pendingSelectionBeginIndex = -1;
            this._pendingSelectionEndIndex = -1;
            if(this.stageText.selectionAnchorIndex != _loc1_ || this.stageText.selectionActiveIndex != _loc2_)
            {
               this.selectRange(_loc1_,_loc2_);
            }
         }
      }
      
      protected function texture_onRestore() : void
      {
         var _loc2_:*;
         var _loc1_:Starling = this.stage !== null ? this.stage.starling : (_loc2_ = Starling, starling.core.Starling.sCurrent);
         if(this.textSnapshot.texture.scale != _loc1_.contentScaleFactor)
         {
            this.invalidate("size");
         }
         else
         {
            this.refreshSnapshot();
            if(this.textSnapshot)
            {
               this.textSnapshot.visible = !this._stageTextHasFocus;
               this.textSnapshot.alpha = this._text.length > 0 ? 1 : 0;
            }
            if(!this._stageTextHasFocus)
            {
               this.stageText.visible = false;
            }
         }
      }
      
      protected function refreshSnapshot() : void
      {
         var _loc4_:* = null;
         var _loc9_:* = null;
         var _loc5_:Number = NaN;
         var _loc7_:* = null;
         var _loc11_:*;
         var _loc1_:Starling = this.stage !== null ? this.stage.starling : (_loc11_ = Starling, starling.core.Starling.sCurrent);
         if(this.stage !== null && this.stageText.stage === null)
         {
            this.stageText.stage = _loc1_.nativeStage;
         }
         if(this.stageText.stage === null)
         {
            this.invalidate("data");
            return;
         }
         var _loc2_:Rectangle = this.stageText.viewPort;
         if(_loc2_.width == 0 || _loc2_.height == 0)
         {
            return;
         }
         var _loc8_:* = 1;
         if(_loc1_.supportHighResolutions)
         {
            _loc8_ = Number(_loc1_.nativeStage.contentsScaleFactor);
         }
         try
         {
            _loc4_ = new BitmapData(_loc2_.width * _loc8_,_loc2_.height * _loc8_,true,16711935);
            this.stageText.drawViewPortToBitmapData(_loc4_);
         }
         catch(error:Error)
         {
            _loc4_.dispose();
            _loc4_ = new BitmapData(_loc2_.width,_loc2_.height,true,16711935);
            this.stageText.drawViewPortToBitmapData(_loc4_);
         }
         if(!this.textSnapshot || this._needsNewTexture)
         {
            _loc5_ = _loc1_.contentScaleFactor;
            (_loc9_ = Texture.empty(_loc4_.width / _loc5_,_loc4_.height / _loc5_,true,false,false,_loc5_)).root.uploadBitmapData(_loc4_);
            _loc9_.root.onRestore = texture_onRestore;
         }
         if(!this.textSnapshot)
         {
            this.textSnapshot = new Image(_loc9_);
            this.textSnapshot.pixelSnapping = true;
            this.addChild(this.textSnapshot);
         }
         else if(this._needsNewTexture)
         {
            this.textSnapshot.texture.dispose();
            this.textSnapshot.texture = _loc9_;
            this.textSnapshot.readjustSize();
         }
         else
         {
            (_loc7_ = this.textSnapshot.texture).root.uploadBitmapData(_loc4_);
            this.textSnapshot.setRequiresRedraw();
         }
         var _loc10_:Matrix = Pool.getMatrix();
         this.getTransformationMatrix(this.stage,_loc10_);
         var _loc3_:Number = matrixToScaleX(_loc10_);
         var _loc6_:Number = matrixToScaleY(_loc10_);
         Pool.putMatrix(_loc10_);
         if(this._updateSnapshotOnScaleChange)
         {
            this.textSnapshot.scaleX = 1 / _loc3_;
            this.textSnapshot.scaleY = 1 / _loc6_;
            this._lastGlobalScaleX = _loc3_;
            this._lastGlobalScaleY = _loc6_;
         }
         else
         {
            this.textSnapshot.scaleX = 1;
            this.textSnapshot.scaleY = 1;
         }
         if(_loc8_ > 1 && _loc4_.width == _loc2_.width)
         {
            this.textSnapshot.scaleX *= _loc8_;
            this.textSnapshot.scaleY *= _loc8_;
         }
         _loc4_.dispose();
         this._needsNewTexture = false;
      }
      
      protected function refreshViewPortAndFontSize() : void
      {
         var _loc2_:* = NaN;
         var _loc6_:* = NaN;
         var _loc13_:* = NaN;
         var _loc14_:* = null;
         var _loc21_:* = null;
         var _loc11_:* = null;
         var _loc9_:Matrix = Pool.getMatrix();
         var _loc10_:Point = Pool.getPoint();
         var _loc3_:* = 0;
         var _loc5_:* = 0;
         if(this._stageTextIsTextField)
         {
            _loc3_ = 2;
            _loc5_ = 4;
         }
         this.getTransformationMatrix(this.stage,_loc9_);
         if(this._stageTextHasFocus || this._updateSnapshotOnScaleChange)
         {
            _loc2_ = Number(matrixToScaleX(_loc9_));
            _loc6_ = Number(matrixToScaleY(_loc9_));
            _loc13_ = _loc2_;
            if(_loc6_ < _loc13_)
            {
               _loc13_ = _loc6_;
            }
         }
         else
         {
            _loc2_ = 1;
            _loc6_ = 1;
            _loc13_ = 1;
         }
         var _loc18_:Number = this.getVerticalAlignmentOffsetY();
         if(this.is3D)
         {
            _loc14_ = Pool.getMatrix3D();
            _loc21_ = Pool.getPoint3D();
            this.getTransformationMatrix3D(this.stage,_loc14_);
            MatrixUtil.transformCoords3D(_loc14_,-_loc3_,-_loc3_ + _loc18_,0,_loc21_);
            _loc10_.setTo(_loc21_.x,_loc21_.y);
            Pool.putPoint3D(_loc21_);
            Pool.putMatrix3D(_loc14_);
         }
         else
         {
            MatrixUtil.transformCoords(_loc9_,-_loc3_,-_loc3_ + _loc18_,_loc10_);
         }
         var _loc23_:*;
         var _loc12_:Starling = this.stage !== null ? this.stage.starling : (_loc23_ = Starling, starling.core.Starling.sCurrent);
         var _loc8_:* = 1;
         if(_loc12_.supportHighResolutions)
         {
            _loc8_ = Number(_loc12_.nativeStage.contentsScaleFactor);
         }
         var _loc7_:Number = _loc12_.contentScaleFactor / _loc8_;
         var _loc4_:Rectangle = _loc12_.viewPort;
         var _loc20_:Rectangle;
         if(!(_loc20_ = this.stageText.viewPort))
         {
            _loc20_ = new Rectangle();
         }
         var _loc15_:*;
         if((_loc15_ = Number(Math.round((this.actualWidth + _loc5_) * _loc7_ * _loc2_))) < 1 || _loc15_ !== _loc15_)
         {
            _loc15_ = 1;
         }
         var _loc22_:*;
         if((_loc22_ = Number(Math.round((this.actualHeight + _loc5_) * _loc7_ * _loc6_))) < 1 || _loc22_ !== _loc22_)
         {
            _loc22_ = 1;
         }
         _loc20_.width = _loc15_;
         _loc20_.height = _loc22_;
         var _loc16_:Number;
         if((_loc16_ = Math.round(_loc4_.x + _loc10_.x * _loc7_)) + _loc15_ > 8191)
         {
            _loc16_ = 8191 - _loc15_;
         }
         else if(_loc16_ < -8192)
         {
            _loc16_ = -8192;
         }
         var _loc19_:Number;
         if((_loc19_ = Math.round(_loc4_.y + _loc10_.y * _loc7_)) + _loc22_ > 8191)
         {
            _loc19_ = 8191 - _loc22_;
         }
         else if(_loc19_ < -8192)
         {
            _loc19_ = -8192;
         }
         _loc20_.x = _loc16_;
         _loc20_.y = _loc19_;
         this.stageText.viewPort = _loc20_;
         var _loc17_:int = 12;
         if(this._fontSize > 0)
         {
            _loc17_ = this._fontSize;
         }
         else if((_loc11_ = this._fontStyles.getTextFormatForTarget(this)) !== null)
         {
            if((_loc11_ = this._fontStyles.getTextFormatForTarget(this)) !== null)
            {
               _loc17_ = _loc11_.size;
            }
         }
         var _loc1_:int = _loc17_ * _loc7_ * _loc13_;
         if(this.stageText.fontSize != _loc1_)
         {
            this.stageText.fontSize = _loc1_;
         }
         Pool.putPoint(_loc10_);
         Pool.putMatrix(_loc9_);
      }
      
      protected function refreshMeasureTextFieldDimensions() : void
      {
         this._measureTextField.width = this.actualWidth + 4;
         this._measureTextField.height = this.actualHeight;
      }
      
      protected function positionSnapshot() : void
      {
         var _loc2_:Matrix = Pool.getMatrix();
         this.getTransformationMatrix(this.stage,_loc2_);
         var _loc1_:* = 0;
         if(this._stageTextIsTextField)
         {
            _loc1_ = 2;
         }
         this.textSnapshot.x = Math.round(_loc2_.tx) - _loc2_.tx - _loc1_;
         this.textSnapshot.y = Math.round(_loc2_.ty) - _loc2_.ty - _loc1_ + this.getVerticalAlignmentOffsetY();
         Pool.putMatrix(_loc2_);
      }
      
      protected function disposeStageText() : void
      {
         if(!this.stageText)
         {
            return;
         }
         this.stageText.removeEventListener("change",stageText_changeHandler);
         this.stageText.removeEventListener("keyDown",stageText_keyDownHandler);
         this.stageText.removeEventListener("keyUp",stageText_keyUpHandler);
         this.stageText.removeEventListener("focusIn",stageText_focusInHandler);
         this.stageText.removeEventListener("focusOut",stageText_focusOutHandler);
         this.stageText.removeEventListener("complete",stageText_completeHandler);
         this.stageText.removeEventListener("softKeyboardActivate",stageText_softKeyboardActivateHandler);
         this.stageText.removeEventListener("softKeyboardActivating",stageText_softKeyboardActivatingHandler);
         this.stageText.removeEventListener("softKeyboardDeactivate",stageText_softKeyboardDeactivateHandler);
         this.stageText.stage = null;
         this.stageText.dispose();
         this.stageText = null;
      }
      
      protected function createStageText() : void
      {
         var _loc1_:* = null;
         var _loc3_:* = null;
         var _loc2_:* = null;
         this._stageTextIsComplete = false;
         try
         {
            _loc1_ = Class(getDefinitionByName("flash.text.StageText"));
            _loc2_ = Class(getDefinitionByName("flash.text.StageTextInitOptions"));
            _loc3_ = new _loc2_(this._multiline);
         }
         catch(error:Error)
         {
            _loc1_ = StageTextField;
            _loc3_ = {"multiline":this._multiline};
         }
         this.stageText = new _loc1_(_loc3_);
         this.stageText.visible = false;
         this.stageText.addEventListener("change",stageText_changeHandler);
         this.stageText.addEventListener("keyDown",stageText_keyDownHandler);
         this.stageText.addEventListener("keyUp",stageText_keyUpHandler);
         this.stageText.addEventListener("focusIn",stageText_focusInHandler);
         this.stageText.addEventListener("focusOut",stageText_focusOutHandler);
         this.stageText.addEventListener("softKeyboardActivate",stageText_softKeyboardActivateHandler);
         this.stageText.addEventListener("softKeyboardActivating",stageText_softKeyboardActivatingHandler);
         this.stageText.addEventListener("softKeyboardDeactivate",stageText_softKeyboardDeactivateHandler);
         this.stageText.addEventListener("complete",stageText_completeHandler);
         this.stageText.addEventListener("mouseFocusChange",stageText_mouseFocusChangeHandler);
         this.invalidate();
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
         var _loc1_:String = this.getVerticalAlignment();
         if(this._measureTextField.textHeight > this.actualHeight)
         {
            return 0;
         }
         if(_loc1_ === "bottom")
         {
            return this.actualHeight - this._measureTextField.textHeight;
         }
         if(_loc1_ === "center")
         {
            return (this.actualHeight - this._measureTextField.textHeight) / 2;
         }
         return 0;
      }
      
      protected function dispatchKeyFocusChangeEvent(param1:KeyboardEvent) : void
      {
         var _loc2_:Starling = stageToStarling(this.stage);
         var _loc3_:FocusEvent = new FocusEvent("keyFocusChange",true,false,null,param1.shiftKey,param1.keyCode);
         _loc2_.nativeStage.dispatchEvent(_loc3_);
      }
      
      protected function textEditor_removedFromStageHandler(param1:starling.events.Event) : void
      {
         this.stageText.stage = null;
      }
      
      protected function stageText_changeHandler(param1:flash.events.Event) : void
      {
         if(this._ignoreStageTextChanges)
         {
            return;
         }
         this.text#2 = this.stageText.text;
      }
      
      protected function stageText_completeHandler(param1:flash.events.Event) : void
      {
         this.stageText.removeEventListener("complete",stageText_completeHandler);
         this.invalidate();
         this._stageTextIsComplete = true;
      }
      
      protected function stageText_focusInHandler(param1:FocusEvent) : void
      {
         this._stageTextHasFocus = true;
         if(!this._isEditable)
         {
            this.stageText.editable = false;
         }
         this.addEventListener("enterFrame",hasFocus_enterFrameHandler);
         if(this.textSnapshot)
         {
            this.textSnapshot.visible = false;
         }
         this.invalidate("skin");
         this.dispatchEventWith("focusIn");
      }
      
      protected function stageText_focusOutHandler(param1:FocusEvent) : void
      {
         this._stageTextHasFocus = false;
         this.stageText.selectRange(1,1);
         this.invalidate("data");
         this.invalidate("skin");
         this.dispatchEventWith("focusOut");
      }
      
      protected function hasFocus_enterFrameHandler(param1:starling.events.Event) : void
      {
         var _loc2_:* = null;
         if(this._stageTextHasFocus)
         {
            _loc2_ = this;
            do
            {
               if(!_loc2_.visible)
               {
                  this.stageText.stage.focus = null;
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
      
      protected function stageText_mouseFocusChangeHandler(param1:FocusEvent) : void
      {
         if(!this._maintainTouchFocus)
         {
            return;
         }
         param1.preventDefault();
      }
      
      protected function stageText_keyDownHandler(param1:KeyboardEvent) : void
      {
         var _loc2_:* = null;
         if(!this._multiline && (param1.keyCode == 13 || param1.keyCode == 16777230))
         {
            param1.preventDefault();
            this.dispatchEventWith("enter");
         }
         else if(param1.keyCode == 16777238)
         {
            param1.preventDefault();
            var _loc3_:*;
            _loc2_ = this.stage !== null ? this.stage.starling : (_loc3_ = Starling, starling.core.Starling.sCurrent);
            _loc2_.nativeStage.focus = _loc2_.nativeStage;
         }
         if(param1.keyCode === 9 && FocusManager.isEnabledForStage(this.stage))
         {
            param1.preventDefault();
            this.dispatchKeyFocusChangeEvent(param1);
         }
      }
      
      protected function stageText_keyUpHandler(param1:KeyboardEvent) : void
      {
         if(!this._multiline && (param1.keyCode == 13 || param1.keyCode == 16777230))
         {
            param1.preventDefault();
         }
         if(param1.keyCode === 9 && FocusManager.isEnabledForStage(this.stage))
         {
            param1.preventDefault();
         }
      }
      
      protected function stageText_softKeyboardActivateHandler(param1:SoftKeyboardEvent) : void
      {
         this.dispatchEventWith("softKeyboardActivate",true);
      }
      
      protected function stageText_softKeyboardActivatingHandler(param1:SoftKeyboardEvent) : void
      {
         this.dispatchEventWith("softKeyboardActivating",true);
      }
      
      protected function stageText_softKeyboardDeactivateHandler(param1:SoftKeyboardEvent) : void
      {
         this.dispatchEventWith("softKeyboardDeactivate",true);
      }
   }
}
