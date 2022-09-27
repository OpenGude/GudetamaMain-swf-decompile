package feathers.controls.supportClasses
{
   import feathers.core.FeathersControl;
   import feathers.text.FontStylesSet;
   import feathers.utils.geom.matrixToRotation;
   import feathers.utils.geom.matrixToScaleX;
   import feathers.utils.geom.matrixToScaleY;
   import flash.display.Sprite;
   import flash.events.TextEvent;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.StyleSheet;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   import starling.events.Event;
   import starling.rendering.Painter;
   import starling.text.TextFormat;
   import starling.utils.MatrixUtil;
   import starling.utils.Pool;
   import starling.utils.SystemUtil;
   
   public class TextFieldViewPort extends FeathersControl implements IViewPort
   {
       
      
      private var _textFieldContainer:Sprite;
      
      private var _textField:TextField;
      
      private var _text:String = "";
      
      private var _isHTML:Boolean = false;
      
      protected var _fontStylesTextFormat:flash.text.TextFormat;
      
      protected var _fontStyles:FontStylesSet;
      
      private var _currentTextFormat:flash.text.TextFormat;
      
      private var _textFormat:flash.text.TextFormat;
      
      private var _disabledTextFormat:flash.text.TextFormat;
      
      protected var _styleSheet:StyleSheet;
      
      private var _embedFonts:Boolean = false;
      
      private var _antiAliasType:String = "advanced";
      
      private var _background:Boolean = false;
      
      private var _backgroundColor:uint = 16777215;
      
      private var _border:Boolean = false;
      
      private var _borderColor:uint = 0;
      
      private var _cacheAsBitmap:Boolean = true;
      
      private var _condenseWhite:Boolean = false;
      
      private var _displayAsPassword:Boolean = false;
      
      private var _gridFitType:String = "pixel";
      
      private var _sharpness:Number = 0;
      
      private var _thickness:Number = 0;
      
      private var _actualMinVisibleWidth:Number = 0;
      
      private var _explicitMinVisibleWidth:Number;
      
      private var _maxVisibleWidth:Number = Infinity;
      
      private var _actualVisibleWidth:Number = 0;
      
      private var _explicitVisibleWidth:Number = NaN;
      
      private var _actualMinVisibleHeight:Number = 0;
      
      private var _explicitMinVisibleHeight:Number;
      
      private var _maxVisibleHeight:Number = Infinity;
      
      private var _actualVisibleHeight:Number = 0;
      
      private var _explicitVisibleHeight:Number = NaN;
      
      private var _scrollStep:Number;
      
      private var _horizontalScrollPosition:Number = 0;
      
      private var _verticalScrollPosition:Number = 0;
      
      private var _paddingTop:Number = 0;
      
      private var _paddingRight:Number = 0;
      
      private var _paddingBottom:Number = 0;
      
      private var _paddingLeft:Number = 0;
      
      public function TextFieldViewPort()
      {
         super();
         this.addEventListener("addedToStage",addedToStageHandler);
         this.addEventListener("removedFromStage",removedFromStageHandler);
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
      
      public function get fontStyles() : FontStylesSet
      {
         return this._fontStyles;
      }
      
      public function set fontStyles(param1:FontStylesSet) : void
      {
         if(this._fontStyles === param1)
         {
            return;
         }
         if(this._fontStyles !== null)
         {
            this._fontStyles.removeEventListener("change",fontStylesSet_changeHandler);
         }
         this._fontStyles = param1;
         if(this._fontStyles !== null)
         {
            this._fontStyles.addEventListener("change",fontStylesSet_changeHandler);
         }
         this.invalidate("styles");
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
      
      public function get styleSheet() : StyleSheet
      {
         return this._styleSheet;
      }
      
      public function set styleSheet(param1:StyleSheet) : void
      {
         if(this._styleSheet == param1)
         {
            return;
         }
         this._styleSheet = param1;
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
      
      public function get cacheAsBitmap() : Boolean
      {
         return this._cacheAsBitmap;
      }
      
      public function set cacheAsBitmap(param1:Boolean) : void
      {
         if(this._cacheAsBitmap == param1)
         {
            return;
         }
         this._cacheAsBitmap = param1;
         this.invalidate("styles");
      }
      
      public function get condenseWhite() : Boolean
      {
         return this._condenseWhite;
      }
      
      public function set condenseWhite(param1:Boolean) : void
      {
         if(this._condenseWhite == param1)
         {
            return;
         }
         this._condenseWhite = param1;
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
      
      public function get minVisibleWidth() : Number
      {
         if(this._explicitMinVisibleWidth !== this._explicitMinVisibleWidth)
         {
            return this._actualMinVisibleWidth;
         }
         return this._explicitMinVisibleWidth;
      }
      
      public function set minVisibleWidth(param1:Number) : void
      {
         if(this._explicitMinVisibleWidth == param1)
         {
            return;
         }
         var _loc2_:* = param1 !== param1;
         if(_loc2_ && this._explicitMinVisibleWidth !== this._explicitMinVisibleWidth)
         {
            return;
         }
         var _loc3_:Number = this._explicitMinVisibleWidth;
         this._explicitMinVisibleWidth = param1;
         if(_loc2_)
         {
            this._actualMinVisibleWidth = 0;
            this.invalidate("size");
         }
         else
         {
            this._actualMinVisibleWidth = param1;
            if(this._explicitVisibleWidth !== this._explicitVisibleWidth && (this._actualVisibleWidth < param1 || this._actualVisibleWidth === _loc3_))
            {
               this.invalidate("size");
            }
         }
      }
      
      public function get maxVisibleWidth() : Number
      {
         return this._maxVisibleWidth;
      }
      
      public function set maxVisibleWidth(param1:Number) : void
      {
         if(this._maxVisibleWidth == param1)
         {
            return;
         }
         if(param1 !== param1)
         {
            throw new ArgumentError("maxVisibleWidth cannot be NaN");
         }
         var _loc2_:Number = this._maxVisibleWidth;
         this._maxVisibleWidth = param1;
         if(this._explicitVisibleWidth !== this._explicitVisibleWidth && (this._actualVisibleWidth > param1 || this._actualVisibleWidth === _loc2_))
         {
            this.invalidate("size");
         }
      }
      
      public function get visibleWidth() : Number
      {
         if(this._explicitVisibleWidth !== this._explicitVisibleWidth)
         {
            return this._actualVisibleWidth;
         }
         return this._explicitVisibleWidth;
      }
      
      public function set visibleWidth(param1:Number) : void
      {
         if(this._explicitVisibleWidth == param1 || param1 !== param1 && this._explicitVisibleWidth !== this._explicitVisibleWidth)
         {
            return;
         }
         this._explicitVisibleWidth = param1;
         if(this._actualVisibleWidth !== param1)
         {
            this.invalidate("size");
         }
      }
      
      public function get minVisibleHeight() : Number
      {
         if(this._explicitMinVisibleHeight !== this._explicitMinVisibleHeight)
         {
            return this._actualMinVisibleHeight;
         }
         return this._explicitMinVisibleHeight;
      }
      
      public function set minVisibleHeight(param1:Number) : void
      {
         if(this._explicitMinVisibleHeight == param1)
         {
            return;
         }
         var _loc2_:* = param1 !== param1;
         if(_loc2_ && this._explicitMinVisibleHeight !== this._explicitMinVisibleHeight)
         {
            return;
         }
         var _loc3_:Number = this._explicitMinVisibleHeight;
         this._explicitMinVisibleHeight = param1;
         if(_loc2_)
         {
            this._actualMinVisibleHeight = 0;
            this.invalidate("size");
         }
         else
         {
            this._actualMinVisibleHeight = param1;
            if(this._explicitVisibleHeight !== this._explicitVisibleHeight && (this._actualVisibleHeight < param1 || this._actualVisibleHeight === _loc3_))
            {
               this.invalidate("size");
            }
         }
      }
      
      public function get maxVisibleHeight() : Number
      {
         return this._maxVisibleHeight;
      }
      
      public function set maxVisibleHeight(param1:Number) : void
      {
         if(this._maxVisibleHeight == param1)
         {
            return;
         }
         if(param1 !== param1)
         {
            throw new ArgumentError("maxVisibleHeight cannot be NaN");
         }
         var _loc2_:Number = this._maxVisibleHeight;
         this._maxVisibleHeight = param1;
         if(this._explicitVisibleHeight !== this._explicitVisibleHeight && (this._actualVisibleHeight > param1 || this._actualVisibleHeight === _loc2_))
         {
            this.invalidate("size");
         }
      }
      
      public function get visibleHeight() : Number
      {
         if(this._explicitVisibleHeight !== this._explicitVisibleHeight)
         {
            return this._actualVisibleHeight;
         }
         return this._explicitVisibleHeight;
      }
      
      public function set visibleHeight(param1:Number) : void
      {
         if(this._explicitVisibleHeight == param1 || param1 !== param1 && this._explicitVisibleHeight !== this._explicitVisibleHeight)
         {
            return;
         }
         this._explicitVisibleHeight = param1;
         if(this._actualVisibleHeight !== param1)
         {
            this.invalidate("size");
         }
      }
      
      public function get contentX() : Number
      {
         return 0;
      }
      
      public function get contentY() : Number
      {
         return 0;
      }
      
      public function get horizontalScrollStep() : Number
      {
         return this._scrollStep;
      }
      
      public function get verticalScrollStep() : Number
      {
         return this._scrollStep;
      }
      
      public function get horizontalScrollPosition() : Number
      {
         return this._horizontalScrollPosition;
      }
      
      public function set horizontalScrollPosition(param1:Number) : void
      {
         if(this._horizontalScrollPosition == param1)
         {
            return;
         }
         this._horizontalScrollPosition = param1;
         this.invalidate("scroll");
      }
      
      public function get verticalScrollPosition() : Number
      {
         return this._verticalScrollPosition;
      }
      
      public function set verticalScrollPosition(param1:Number) : void
      {
         if(this._verticalScrollPosition == param1)
         {
            return;
         }
         this._verticalScrollPosition = param1;
         this.invalidate("scroll");
      }
      
      public function get requiresMeasurementOnScroll() : Boolean
      {
         return false;
      }
      
      public function get paddingTop() : Number
      {
         return this._paddingTop;
      }
      
      public function set paddingTop(param1:Number) : void
      {
         if(this._paddingTop == param1)
         {
            return;
         }
         this._paddingTop = param1;
         this.invalidate("styles");
      }
      
      public function get paddingRight() : Number
      {
         return this._paddingRight;
      }
      
      public function set paddingRight(param1:Number) : void
      {
         if(this._paddingRight == param1)
         {
            return;
         }
         this._paddingRight = param1;
         this.invalidate("styles");
      }
      
      public function get paddingBottom() : Number
      {
         return this._paddingBottom;
      }
      
      public function set paddingBottom(param1:Number) : void
      {
         if(this._paddingBottom == param1)
         {
            return;
         }
         this._paddingBottom = param1;
         this.invalidate("styles");
      }
      
      public function get paddingLeft() : Number
      {
         return this._paddingLeft;
      }
      
      public function set paddingLeft(param1:Number) : void
      {
         if(this._paddingLeft == param1)
         {
            return;
         }
         this._paddingLeft = param1;
         this.invalidate("styles");
      }
      
      override public function render(param1:Painter) : void
      {
         param1.excludeFromCache(this);
         var _loc8_:*;
         var _loc2_:Starling = this.stage !== null ? this.stage.starling : (_loc8_ = Starling, starling.core.Starling.sCurrent);
         var _loc3_:Rectangle = _loc2_.viewPort;
         var _loc6_:Matrix = Pool.getMatrix();
         var _loc7_:Point = Pool.getPoint();
         this.parent.getTransformationMatrix(this.stage,_loc6_);
         MatrixUtil.transformCoords(_loc6_,0,0,_loc7_);
         var _loc5_:* = 1;
         if(_loc2_.supportHighResolutions)
         {
            _loc5_ = Number(_loc2_.nativeStage.contentsScaleFactor);
         }
         var _loc4_:Number = _loc2_.contentScaleFactor / _loc5_;
         this._textFieldContainer.x = _loc3_.x + _loc7_.x * _loc4_;
         this._textFieldContainer.y = _loc3_.y + _loc7_.y * _loc4_;
         this._textFieldContainer.scaleX = matrixToScaleX(_loc6_) * _loc4_;
         this._textFieldContainer.scaleY = matrixToScaleY(_loc6_) * _loc4_;
         this._textFieldContainer.rotation = matrixToRotation(_loc6_) * 180 / 3.141592653589793;
         this._textFieldContainer.alpha = param1.state.alpha;
         Pool.putPoint(_loc7_);
         Pool.putMatrix(_loc6_);
         super.render(param1);
      }
      
      override protected function initialize() : void
      {
         this._textFieldContainer = new Sprite();
         this._textFieldContainer.visible = false;
         this._textField = new TextField();
         this._textField.autoSize = "left";
         this._textField.selectable = false;
         this._textField.mouseWheelEnabled = false;
         this._textField.wordWrap = true;
         this._textField.multiline = true;
         this._textField.addEventListener("link",textField_linkHandler);
         this._textFieldContainer.addChild(this._textField);
      }
      
      override protected function draw() : void
      {
         var _loc5_:* = null;
         var _loc7_:Boolean = this.isInvalid("data");
         var _loc2_:Boolean = this.isInvalid("size");
         var _loc10_:Boolean = this.isInvalid("scroll");
         var _loc8_:Boolean = this.isInvalid("styles");
         var _loc6_:Boolean = this.isInvalid("state");
         if(_loc8_)
         {
            this.refreshTextFormat();
            this._textField.antiAliasType = this._antiAliasType;
            this._textField.background = this._background;
            this._textField.backgroundColor = this._backgroundColor;
            this._textField.border = this._border;
            this._textField.borderColor = this._borderColor;
            this._textField.condenseWhite = this._condenseWhite;
            this._textField.displayAsPassword = this._displayAsPassword;
            this._textField.gridFitType = this._gridFitType;
            this._textField.sharpness = this._sharpness;
            this._textField.thickness = this._thickness;
            this._textField.cacheAsBitmap = this._cacheAsBitmap;
            this._textField.x = this._paddingLeft;
            this._textField.y = this._paddingTop;
         }
         var _loc11_:*;
         var _loc3_:Starling = this.stage !== null ? this.stage.starling : (_loc11_ = Starling, starling.core.Starling.sCurrent);
         if(_loc7_ || _loc8_ || _loc6_)
         {
            if(this._styleSheet !== null)
            {
               this._textField.embedFonts = this._embedFonts;
               this._textField.styleSheet = this._styleSheet;
            }
            else
            {
               if(!this._embedFonts && this._currentTextFormat === this._fontStylesTextFormat)
               {
                  this._textField.embedFonts = SystemUtil.isEmbeddedFont(this._currentTextFormat.font,this._currentTextFormat.bold,this._currentTextFormat.italic,"embedded");
               }
               else
               {
                  this._textField.embedFonts = this._embedFonts;
               }
               this._textField.styleSheet = null;
               this._textField.defaultTextFormat = this._currentTextFormat;
            }
            if(this._isHTML)
            {
               this._textField.htmlText = this._text;
            }
            else
            {
               this._textField.text#2 = this._text;
            }
            this._scrollStep = this._textField.getLineMetrics(0).height * _loc3_.contentScaleFactor;
         }
         var _loc9_:Number = this._explicitVisibleWidth;
         if(_loc9_ != _loc9_)
         {
            if(this.stage !== null)
            {
               _loc9_ = this.stage.stageWidth;
            }
            else
            {
               _loc9_ = _loc3_.stage.stageWidth;
            }
            if(_loc9_ < this._explicitMinVisibleWidth)
            {
               _loc9_ = this._explicitMinVisibleWidth;
            }
            else if(_loc9_ > this._maxVisibleWidth)
            {
               _loc9_ = this._maxVisibleWidth;
            }
         }
         this._textField.width = _loc9_ - this._paddingLeft - this._paddingRight;
         var _loc4_:Number = this._textField.height + this._paddingTop + this._paddingBottom;
         var _loc1_:* = Number(this._explicitVisibleHeight);
         if(_loc1_ != _loc1_)
         {
            _loc1_ = _loc4_;
            if(_loc1_ < this._explicitMinVisibleHeight)
            {
               _loc1_ = Number(this._explicitMinVisibleHeight);
            }
            else if(_loc1_ > this._maxVisibleHeight)
            {
               _loc1_ = Number(this._maxVisibleHeight);
            }
         }
         _loc2_ = this.saveMeasurements(_loc9_,_loc4_,_loc9_,_loc4_) || _loc2_;
         this._actualVisibleWidth = _loc9_;
         this._actualVisibleHeight = _loc1_;
         this._actualMinVisibleWidth = _loc9_;
         this._actualMinVisibleHeight = _loc1_;
         if(_loc2_ || _loc10_)
         {
            if(!(_loc5_ = this._textFieldContainer.scrollRect))
            {
               _loc5_ = new Rectangle();
            }
            _loc5_.width = _loc9_;
            _loc5_.height = _loc1_;
            _loc5_.x = this._horizontalScrollPosition;
            _loc5_.y = this._verticalScrollPosition;
            this._textFieldContainer.scrollRect = _loc5_;
         }
      }
      
      protected function refreshTextFormat() : void
      {
         if(!this._isEnabled && this._disabledTextFormat !== null)
         {
            this._currentTextFormat = this._disabledTextFormat;
         }
         else if(this._textFormat !== null)
         {
            this._currentTextFormat = this._textFormat;
         }
         else if(this._fontStyles !== null)
         {
            this._currentTextFormat = this.getTextFormatFromFontStyles();
         }
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
      
      private function addedToStageHandler(param1:Event) : void
      {
         this.stage.starling.nativeStage.addChild(this._textFieldContainer);
         this.addEventListener("enterFrame",enterFrameHandler);
      }
      
      private function removedFromStageHandler(param1:Event) : void
      {
         this.stage.starling.nativeStage.removeChild(this._textFieldContainer);
         this.removeEventListener("enterFrame",enterFrameHandler);
      }
      
      private function enterFrameHandler(param1:Event) : void
      {
         var _loc2_:DisplayObject = this;
         while(_loc2_.visible)
         {
            _loc2_ = _loc2_.parent;
            if(!_loc2_)
            {
               this._textFieldContainer.visible = true;
               return;
            }
         }
         this._textFieldContainer.visible = false;
      }
      
      protected function textField_linkHandler(param1:TextEvent) : void
      {
         this.dispatchEventWith("triggered",false,param1.text#2);
      }
      
      protected function fontStylesSet_changeHandler(param1:Event) : void
      {
         this.invalidate("styles");
      }
   }
}
