package feathers.controls.text
{
   import feathers.core.IFeathersControl;
   import feathers.core.ITextRenderer;
   import feathers.core.IToggle;
   import feathers.skins.IStyleProvider;
   import feathers.text.BitmapFontTextFormat;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import starling.display.Image;
   import starling.display.MeshBatch;
   import starling.rendering.Painter;
   import starling.styles.MeshStyle;
   import starling.text.BitmapChar;
   import starling.text.BitmapFont;
   import starling.text.TextField;
   import starling.text.TextFormat;
   import starling.textures.Texture;
   import starling.utils.MathUtil;
   
   public class BitmapFontTextRenderer extends BaseTextRenderer implements ITextRenderer
   {
      
      private static var HELPER_IMAGE:Image;
      
      private static const HELPER_POINT:Point = new Point();
      
      private static const HELPER_RESULT:MeasureTextResult = new MeasureTextResult();
      
      private static const CHARACTER_ID_SPACE:int = 32;
      
      private static const CHARACTER_ID_TAB:int = 9;
      
      private static const CHARACTER_ID_LINE_FEED:int = 10;
      
      private static const CHARACTER_ID_CARRIAGE_RETURN:int = 13;
      
      private static var CHARACTER_BUFFER:Vector.<CharLocation>;
      
      private static var CHAR_LOCATION_POOL:Vector.<CharLocation>;
      
      private static const FUZZY_MAX_WIDTH_PADDING:Number = 1.0E-6;
      
      public static var globalStyleProvider:IStyleProvider;
       
      
      protected var _characterBatch:MeshBatch;
      
      protected var _batchX:Number = 0;
      
      protected var _textFormatChanged:Boolean = true;
      
      protected var _fontStylesTextFormat:BitmapFontTextFormat;
      
      protected var _currentVerticalAlign:String;
      
      protected var _verticalAlignOffsetY:Number = 0;
      
      protected var _currentTextFormat:BitmapFontTextFormat;
      
      protected var _numLines:int = 0;
      
      protected var _textFormatForState:Object;
      
      protected var _textFormat:BitmapFontTextFormat;
      
      protected var _disabledTextFormat:BitmapFontTextFormat;
      
      protected var _selectedTextFormat:BitmapFontTextFormat;
      
      protected var _textureSmoothing:String = "bilinear";
      
      protected var _pixelSnapping:Boolean = true;
      
      protected var _truncateToFit:Boolean = true;
      
      protected var _truncationText:String = "...";
      
      protected var _useSeparateBatch:Boolean = true;
      
      protected var _style:MeshStyle;
      
      private var _compilerWorkaround:Object;
      
      protected var _lastLayoutWidth:Number = 0;
      
      protected var _lastLayoutHeight:Number = 0;
      
      protected var _lastLayoutIsTruncated:Boolean = false;
      
      public function BitmapFontTextRenderer()
      {
         super();
         if(!CHAR_LOCATION_POOL)
         {
            CHAR_LOCATION_POOL = new Vector.<CharLocation>(0);
         }
         if(!CHARACTER_BUFFER)
         {
            CHARACTER_BUFFER = new Vector.<CharLocation>(0);
         }
         this.isQuickHitAreaEnabled = true;
      }
      
      public function get currentTextFormat() : BitmapFontTextFormat
      {
         return this._currentTextFormat;
      }
      
      override protected function get defaultStyleProvider() : IStyleProvider
      {
         return BitmapFontTextRenderer.globalStyleProvider;
      }
      
      override public function set maxWidth(param1:Number) : void
      {
         var _loc2_:Boolean = param1 > this._explicitMaxWidth && this._lastLayoutIsTruncated;
         super.maxWidth = param1;
         if(_loc2_)
         {
            this.invalidate("size");
         }
      }
      
      public function get numLines() : int
      {
         return this._numLines;
      }
      
      public function get textFormat() : BitmapFontTextFormat
      {
         return this._textFormat;
      }
      
      public function set textFormat(param1:BitmapFontTextFormat) : void
      {
         if(this._textFormat == param1)
         {
            return;
         }
         this._textFormat = param1;
         this.invalidate("styles");
      }
      
      public function get disabledTextFormat() : BitmapFontTextFormat
      {
         return this._disabledTextFormat;
      }
      
      public function set disabledTextFormat(param1:BitmapFontTextFormat) : void
      {
         if(this._disabledTextFormat == param1)
         {
            return;
         }
         this._disabledTextFormat = param1;
         this.invalidate("styles");
      }
      
      public function get selectedTextFormat() : BitmapFontTextFormat
      {
         return this._selectedTextFormat;
      }
      
      public function set selectedTextFormat(param1:BitmapFontTextFormat) : void
      {
         if(this._selectedTextFormat == param1)
         {
            return;
         }
         this._selectedTextFormat = param1;
         this.invalidate("styles");
      }
      
      public function get textureSmoothing() : String
      {
         return this._textureSmoothing;
      }
      
      public function set textureSmoothing(param1:String) : void
      {
         if(this._textureSmoothing == param1)
         {
            return;
         }
         this._textureSmoothing = param1;
         this.invalidate("styles");
      }
      
      public function get pixelSnapping() : Boolean
      {
         return _pixelSnapping;
      }
      
      public function set pixelSnapping(param1:Boolean) : void
      {
         if(this._pixelSnapping === param1)
         {
            return;
         }
         this._pixelSnapping = param1;
         this.invalidate("styles");
      }
      
      public function get truncateToFit() : Boolean
      {
         return _truncateToFit;
      }
      
      public function set truncateToFit(param1:Boolean) : void
      {
         if(this._truncateToFit == param1)
         {
            return;
         }
         this._truncateToFit = param1;
         this.invalidate("data");
      }
      
      public function get truncationText() : String
      {
         return _truncationText;
      }
      
      public function set truncationText(param1:String) : void
      {
         if(this._truncationText == param1)
         {
            return;
         }
         this._truncationText = param1;
         this.invalidate("data");
      }
      
      public function get useSeparateBatch() : Boolean
      {
         return this._useSeparateBatch;
      }
      
      public function set useSeparateBatch(param1:Boolean) : void
      {
         if(this._useSeparateBatch == param1)
         {
            return;
         }
         this._useSeparateBatch = param1;
         this.invalidate("styles");
      }
      
      public function get style() : MeshStyle
      {
         return this._style;
      }
      
      public function set style(param1:MeshStyle) : void
      {
         if(this._style == param1)
         {
            return;
         }
         this._style = param1;
         this.invalidate("styles");
      }
      
      public function get baseline() : Number
      {
         if(this._currentTextFormat === null)
         {
            return 0;
         }
         var _loc4_:BitmapFont = this._currentTextFormat.font;
         var _loc1_:Number = this._currentTextFormat.size;
         var _loc3_:* = Number(_loc1_ / _loc4_.size);
         if(_loc3_ !== _loc3_)
         {
            _loc3_ = 1;
         }
         var _loc2_:Number = _loc4_.baseline;
         this._compilerWorkaround = _loc2_;
         if(_loc2_ !== _loc2_)
         {
            return _loc4_.lineHeight * _loc3_;
         }
         return _loc2_ * _loc3_;
      }
      
      override public function render(param1:Painter) : void
      {
         this._characterBatch.x = this._batchX;
         this._characterBatch.y = this._verticalAlignOffsetY;
         super.render(param1);
      }
      
      public function measureText(param1:Point = null) : Point
      {
         var _loc18_:int = 0;
         var _loc16_:int = 0;
         var _loc24_:Number = NaN;
         var _loc9_:Boolean = false;
         var _loc26_:Boolean = false;
         var _loc10_:* = null;
         var _loc14_:Number = NaN;
         if(!param1)
         {
            param1 = new Point();
         }
         var _loc15_:* = this._explicitWidth !== this._explicitWidth;
         var _loc11_:* = this._explicitHeight !== this._explicitHeight;
         if(!_loc15_ && !_loc11_)
         {
            param1.x = this._explicitWidth;
            param1.y = this._explicitHeight;
            return param1;
         }
         if(this.isInvalid("styles") || this.isInvalid("state"))
         {
            this.refreshTextFormat();
         }
         if(!this._currentTextFormat || this._text === null)
         {
            param1.setTo(0,0);
            return param1;
         }
         var _loc28_:BitmapFont = this._currentTextFormat.font;
         var _loc19_:Number = this._currentTextFormat.size;
         var _loc21_:Number = this._currentTextFormat.letterSpacing;
         var _loc3_:Boolean = this._currentTextFormat.isKerningEnabled;
         var _loc7_:* = Number(_loc19_ / _loc28_.size);
         if(_loc7_ !== _loc7_)
         {
            _loc7_ = 1;
         }
         var _loc25_:Number = _loc28_.lineHeight * _loc7_ + this._currentTextFormat.leading;
         var _loc6_:Number = this._explicitWidth;
         if(_loc6_ !== _loc6_)
         {
            _loc6_ = this._explicitMaxWidth;
         }
         var _loc5_:* = 0;
         var _loc22_:* = 0;
         var _loc8_:* = 0;
         var _loc23_:Number = NaN;
         var _loc2_:int = this._text.length;
         var _loc13_:* = 0;
         var _loc12_:* = 0;
         var _loc20_:int = 0;
         var _loc4_:String = "";
         var _loc27_:String = "";
         var _loc17_:BitmapChar = null;
         _loc18_ = 0;
         while(_loc18_ < _loc2_)
         {
            if((_loc16_ = this._text.charCodeAt(_loc18_)) === 10 || _loc16_ === 13)
            {
               _loc22_ -= _loc21_;
               if(_loc17_ !== null)
               {
                  _loc22_ -= (_loc17_.xAdvance - _loc17_.width) * _loc7_;
               }
               if(_loc22_ < 0)
               {
                  _loc22_ = 0;
               }
               if(_loc5_ < _loc22_)
               {
                  _loc5_ = _loc22_;
               }
               _loc23_ = NaN;
               _loc22_ = 0;
               _loc8_ += _loc25_;
               _loc13_ = 0;
               _loc20_ = 0;
               _loc12_ = 0;
            }
            else if((_loc17_ = _loc28_.getChar(_loc16_)) === null)
            {
               trace("Missing character " + String.fromCharCode(_loc16_) + " in font " + _loc28_.name#2 + ".");
            }
            else
            {
               if(_loc3_ && _loc23_ === _loc23_)
               {
                  _loc22_ += _loc17_.getKerning(_loc23_) * _loc7_;
               }
               _loc24_ = _loc17_.xAdvance * _loc7_;
               if(this._wordWrap)
               {
                  _loc9_ = _loc16_ === 32 || _loc16_ === 9;
                  _loc26_ = _loc23_ === 32 || _loc23_ === 9;
                  if(_loc9_)
                  {
                     if(!_loc26_)
                     {
                        _loc10_ = _loc28_.getChar(_loc23_);
                        _loc12_ = Number(_loc21_ + (_loc10_.xAdvance - _loc10_.width) * _loc7_);
                     }
                     _loc12_ += _loc24_;
                  }
                  else if(_loc26_)
                  {
                     _loc13_ = _loc22_;
                     _loc20_++;
                     _loc4_ += _loc27_;
                     _loc27_ = "";
                  }
                  _loc14_ = _loc17_.width * _loc7_;
                  if(!_loc9_ && _loc20_ > 0 && _loc22_ + _loc14_ > _loc6_)
                  {
                     _loc12_ = Number(_loc13_ - _loc12_);
                     if(_loc5_ < _loc12_)
                     {
                        _loc5_ = _loc12_;
                     }
                     _loc23_ = NaN;
                     _loc22_ -= _loc13_;
                     _loc8_ += _loc25_;
                     _loc13_ = 0;
                     _loc12_ = 0;
                     _loc20_ = 0;
                     _loc4_ = "";
                  }
               }
               _loc22_ += _loc24_ + _loc21_;
               _loc23_ = _loc16_;
               _loc27_ += String.fromCharCode(_loc16_);
            }
            _loc18_++;
         }
         _loc22_ -= _loc21_;
         if(_loc17_ !== null)
         {
            _loc22_ -= (_loc17_.xAdvance - _loc17_.width) * _loc7_;
         }
         if(_loc22_ < 0)
         {
            _loc22_ = 0;
         }
         if(this._wordWrap)
         {
            while(_loc22_ > _loc6_ && !MathUtil.isEquivalent(_loc22_,_loc6_))
            {
               _loc22_ -= _loc6_;
               _loc8_ += _loc25_;
               if(_loc6_ === 0)
               {
                  break;
               }
            }
         }
         if(_loc5_ < _loc22_)
         {
            _loc5_ = _loc22_;
         }
         if(_loc15_)
         {
            param1.x = _loc5_;
         }
         else
         {
            param1.x = this._explicitWidth;
         }
         if(_loc11_)
         {
            param1.y = _loc8_ + _loc25_ - this._currentTextFormat.leading;
         }
         else
         {
            param1.y = this._explicitHeight;
         }
         return param1;
      }
      
      public function getTextFormatForState(param1:String) : BitmapFontTextFormat
      {
         if(this._textFormatForState === null)
         {
            return null;
         }
         return BitmapFontTextFormat(this._textFormatForState[param1]);
      }
      
      public function setTextFormatForState(param1:String, param2:BitmapFontTextFormat) : void
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
         if(!this._characterBatch)
         {
            this._characterBatch = new MeshBatch();
            this._characterBatch.touchable = false;
            this.addChild(this._characterBatch);
         }
      }
      
      override protected function draw() : void
      {
         var _loc1_:* = false;
         var _loc4_:Boolean = this.isInvalid("data");
         var _loc5_:Boolean = this.isInvalid("styles");
         var _loc3_:Boolean = this.isInvalid("state");
         if(_loc5_ || _loc3_)
         {
            this.refreshTextFormat();
         }
         if(_loc5_)
         {
            this._characterBatch.pixelSnapping = this._pixelSnapping;
            this._characterBatch.batchable = !this._useSeparateBatch;
         }
         var _loc2_:Number = this._explicitWidth;
         if(_loc2_ !== _loc2_)
         {
            _loc2_ = this._explicitMaxWidth;
         }
         if(this._wordWrap)
         {
            _loc1_ = _loc2_ !== this._lastLayoutWidth;
         }
         else
         {
            _loc1_ = _loc2_ < this._lastLayoutWidth;
            if(!_loc1_)
            {
               _loc1_ = this._lastLayoutIsTruncated && _loc2_ !== this._lastLayoutWidth;
            }
            if(!_loc1_)
            {
               _loc1_ = this._currentTextFormat.align !== "left";
            }
         }
         if(_loc4_ || _loc1_ || this._textFormatChanged)
         {
            this._textFormatChanged = false;
            this._characterBatch.clear();
            if(!this._currentTextFormat || this._text === null)
            {
               this.saveMeasurements(0,0,0,0);
               return;
            }
            this.layoutCharacters(HELPER_RESULT);
            this._lastLayoutWidth = HELPER_RESULT.width;
            this._lastLayoutHeight = HELPER_RESULT.height;
            this._lastLayoutIsTruncated = HELPER_RESULT.isTruncated;
         }
         this.saveMeasurements(this._lastLayoutWidth,this._lastLayoutHeight,this._lastLayoutWidth,this._lastLayoutHeight);
         this._verticalAlignOffsetY = this.getVerticalAlignOffsetY();
      }
      
      protected function layoutCharacters(param1:MeasureTextResult = null) : MeasureTextResult
      {
         var _loc19_:* = null;
         var _loc23_:int = 0;
         var _loc20_:int = 0;
         var _loc30_:Number = NaN;
         var _loc13_:Boolean = false;
         var _loc33_:Boolean = false;
         var _loc14_:* = null;
         var _loc18_:Number = NaN;
         var _loc31_:* = null;
         var _loc9_:* = null;
         if(!param1)
         {
            param1 = new MeasureTextResult();
         }
         this._numLines = 1;
         var _loc34_:BitmapFont = this._currentTextFormat.font;
         var _loc24_:Number = this._currentTextFormat.size;
         var _loc27_:Number = this._currentTextFormat.letterSpacing;
         var _loc3_:Boolean = this._currentTextFormat.isKerningEnabled;
         var _loc7_:* = Number(_loc24_ / _loc34_.size);
         if(_loc7_ !== _loc7_)
         {
            _loc7_ = 1;
         }
         var _loc32_:Number = _loc34_.lineHeight * _loc7_ + this._currentTextFormat.leading;
         var _loc10_:Number = _loc34_.offsetX * _loc7_;
         var _loc12_:Number = _loc34_.offsetY * _loc7_;
         var _loc11_:* = this._explicitWidth === this._explicitWidth;
         var _loc25_:* = this._currentTextFormat.align != "left";
         var _loc6_:Number = !!_loc11_ ? this._explicitWidth : Number(this._explicitMaxWidth);
         if(_loc25_ && _loc6_ == Infinity)
         {
            this.measureText(HELPER_POINT);
            _loc6_ = HELPER_POINT.x;
         }
         var _loc15_:* = this._text;
         if(this._truncateToFit)
         {
            _loc19_ = this.getTruncatedText(_loc6_);
            param1.isTruncated = _loc19_ !== _loc15_;
            _loc15_ = _loc19_;
         }
         else
         {
            param1.isTruncated = false;
         }
         CHARACTER_BUFFER.length = 0;
         var _loc5_:* = 0;
         var _loc28_:* = 0;
         var _loc8_:* = 0;
         var _loc29_:Number = NaN;
         var _loc4_:Boolean = false;
         var _loc17_:* = 0;
         var _loc16_:* = 0;
         var _loc21_:int = 0;
         var _loc26_:int = 0;
         var _loc22_:BitmapChar = null;
         var _loc2_:int = !!_loc15_ ? _loc15_.length : 0;
         _loc23_ = 0;
         while(_loc23_ < _loc2_)
         {
            _loc4_ = false;
            if((_loc20_ = _loc15_.charCodeAt(_loc23_)) === 10 || _loc20_ === 13)
            {
               _loc28_ -= _loc27_;
               if(_loc22_ !== null)
               {
                  _loc28_ -= (_loc22_.xAdvance - _loc22_.width) * _loc7_;
               }
               if(_loc28_ < 0)
               {
                  _loc28_ = 0;
               }
               if(this._wordWrap || _loc25_)
               {
                  this.alignBuffer(_loc6_,_loc28_,0);
                  this.addBufferToBatch(0);
               }
               if(_loc5_ < _loc28_)
               {
                  _loc5_ = _loc28_;
               }
               _loc29_ = NaN;
               _loc28_ = 0;
               _loc8_ += _loc32_;
               _loc17_ = 0;
               _loc16_ = 0;
               _loc21_ = 0;
               _loc26_ = 0;
               this._numLines++;
            }
            else if((_loc22_ = _loc34_.getChar(_loc20_)) === null)
            {
               trace("Missing character " + String.fromCharCode(_loc20_) + " in font " + _loc34_.name#2 + ".");
            }
            else
            {
               if(_loc3_ && _loc29_ === _loc29_)
               {
                  _loc28_ += _loc22_.getKerning(_loc29_) * _loc7_;
               }
               _loc30_ = _loc22_.xAdvance * _loc7_;
               if(this._wordWrap)
               {
                  _loc13_ = _loc20_ === 32 || _loc20_ === 9;
                  _loc33_ = _loc29_ === 32 || _loc29_ === 9;
                  if(_loc13_)
                  {
                     if(!_loc33_)
                     {
                        _loc14_ = _loc34_.getChar(_loc29_);
                        _loc16_ = Number(_loc27_ + (_loc14_.xAdvance - _loc14_.width) * _loc7_);
                     }
                     _loc16_ += _loc30_;
                  }
                  else if(_loc33_)
                  {
                     _loc17_ = _loc28_;
                     _loc21_ = 0;
                     _loc26_++;
                     _loc4_ = true;
                  }
                  if(_loc4_ && !_loc25_)
                  {
                     this.addBufferToBatch(0);
                  }
                  _loc18_ = _loc22_.width * _loc7_;
                  if(!_loc13_ && _loc26_ > 0 && _loc28_ + _loc18_ - _loc6_ > 0.000001)
                  {
                     if(_loc25_)
                     {
                        this.trimBuffer(_loc21_);
                        this.alignBuffer(_loc6_,_loc17_ - _loc16_,_loc21_);
                        this.addBufferToBatch(_loc21_);
                     }
                     this.moveBufferedCharacters(-_loc17_,_loc32_,0);
                     _loc16_ = Number(_loc17_ - _loc16_);
                     if(_loc5_ < _loc16_)
                     {
                        _loc5_ = _loc16_;
                     }
                     _loc29_ = NaN;
                     _loc28_ -= _loc17_;
                     _loc8_ += _loc32_;
                     _loc17_ = 0;
                     _loc16_ = 0;
                     _loc21_ = 0;
                     _loc4_ = false;
                     _loc26_ = 0;
                     this._numLines++;
                  }
               }
               if(this._wordWrap || _loc25_)
               {
                  (_loc31_ = CHAR_LOCATION_POOL.length > 0 ? CHAR_LOCATION_POOL.shift() : new CharLocation()).char = _loc22_;
                  _loc31_.x = _loc28_ + _loc10_ + _loc22_.xOffset * _loc7_;
                  _loc31_.y = _loc8_ + _loc12_ + _loc22_.yOffset * _loc7_;
                  _loc31_.scale = _loc7_;
                  CHARACTER_BUFFER[CHARACTER_BUFFER.length] = _loc31_;
                  _loc21_++;
               }
               else
               {
                  this.addCharacterToBatch(_loc22_,_loc28_ + _loc10_ + _loc22_.xOffset * _loc7_,_loc8_ + _loc12_ + _loc22_.yOffset * _loc7_,_loc7_);
               }
               _loc28_ += _loc30_ + _loc27_;
               _loc29_ = _loc20_;
            }
            _loc23_++;
         }
         _loc28_ -= _loc27_;
         if(_loc22_ !== null)
         {
            _loc28_ -= (_loc22_.xAdvance - _loc22_.width) * _loc7_;
         }
         if(_loc28_ < 0)
         {
            _loc28_ = 0;
         }
         if(this._wordWrap || _loc25_)
         {
            this.alignBuffer(_loc6_,_loc28_,0);
            this.addBufferToBatch(0);
         }
         if(this._wordWrap)
         {
            while(_loc28_ > _loc6_ && !MathUtil.isEquivalent(_loc28_,_loc6_))
            {
               _loc28_ -= _loc6_;
               _loc8_ += _loc32_;
               if(_loc6_ === 0)
               {
                  break;
               }
            }
         }
         if(_loc5_ < _loc28_)
         {
            _loc5_ = _loc28_;
         }
         if(_loc25_ && !_loc11_)
         {
            if((_loc9_ = this._currentTextFormat.align) == "center")
            {
               this._batchX = (_loc5_ - _loc6_) / 2;
            }
            else if(_loc9_ == "right")
            {
               this._batchX = _loc5_ - _loc6_;
            }
         }
         else
         {
            this._batchX = 0;
         }
         this._characterBatch.x = this._batchX;
         param1.width = _loc5_;
         param1.height = _loc8_ + _loc32_ - this._currentTextFormat.leading;
         return param1;
      }
      
      protected function trimBuffer(param1:int) : void
      {
         var _loc5_:int = 0;
         var _loc6_:* = null;
         var _loc7_:* = null;
         var _loc4_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = CHARACTER_BUFFER.length - param1;
         _loc5_ = _loc3_ - 1;
         while(_loc5_ >= 0)
         {
            if(!((_loc4_ = (_loc7_ = (_loc6_ = CHARACTER_BUFFER[_loc5_]).char).charID) === 32 || _loc4_ === 9))
            {
               break;
            }
            _loc2_++;
            _loc5_--;
         }
         if(_loc2_ > 0)
         {
            CHARACTER_BUFFER.splice(_loc5_ + 1,_loc2_);
         }
      }
      
      protected function alignBuffer(param1:Number, param2:Number, param3:int) : void
      {
         var _loc4_:String;
         if((_loc4_ = this._currentTextFormat.align) == "center")
         {
            this.moveBufferedCharacters(Math.round((param1 - param2) / 2),0,param3);
         }
         else if(_loc4_ == "right")
         {
            this.moveBufferedCharacters(param1 - param2,0,param3);
         }
      }
      
      protected function addBufferToBatch(param1:int) : void
      {
         var _loc3_:int = 0;
         var _loc4_:* = null;
         var _loc2_:int = CHARACTER_BUFFER.length - param1;
         var _loc5_:int = CHAR_LOCATION_POOL.length;
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            _loc4_ = CHARACTER_BUFFER.shift();
            this.addCharacterToBatch(_loc4_.char,_loc4_.x,_loc4_.y,_loc4_.scale);
            _loc4_.char = null;
            CHAR_LOCATION_POOL[_loc5_] = _loc4_;
            _loc5_++;
            _loc3_++;
         }
      }
      
      protected function moveBufferedCharacters(param1:Number, param2:Number, param3:int) : void
      {
         var _loc5_:int = 0;
         var _loc6_:* = null;
         var _loc4_:int = CHARACTER_BUFFER.length - param3;
         _loc5_ = 0;
         while(_loc5_ < _loc4_)
         {
            _loc6_.x = (_loc6_ = CHARACTER_BUFFER[_loc5_]).x + param1;
            _loc6_.y += param2;
            _loc5_++;
         }
      }
      
      protected function addCharacterToBatch(param1:BitmapChar, param2:Number, param3:Number, param4:Number, param5:Painter = null) : void
      {
         var _loc7_:Rectangle;
         var _loc6_:Texture;
         if(_loc7_ = (_loc6_ = param1.texture).frame)
         {
            if(_loc7_.width === 0 || _loc7_.height === 0)
            {
               return;
            }
         }
         else if(_loc6_.width === 0 || _loc6_.height === 0)
         {
            return;
         }
         if(!HELPER_IMAGE)
         {
            HELPER_IMAGE = new Image(_loc6_);
         }
         else
         {
            HELPER_IMAGE.texture = _loc6_;
            HELPER_IMAGE.readjustSize();
         }
         HELPER_IMAGE.scaleX = HELPER_IMAGE.scaleY = param4;
         HELPER_IMAGE.x = param2;
         HELPER_IMAGE.y = param3;
         HELPER_IMAGE.color = this._currentTextFormat.color;
         HELPER_IMAGE.textureSmoothing = this._textureSmoothing;
         HELPER_IMAGE.pixelSnapping = this._pixelSnapping;
         if(this._style !== null)
         {
            HELPER_IMAGE.style = this._style;
         }
         if(param5 !== null)
         {
            param5.pushState();
            param5.setStateTo(HELPER_IMAGE.transformationMatrix);
            param5.batchMesh(HELPER_IMAGE);
            param5.popState();
         }
         else
         {
            this._characterBatch.addMesh(HELPER_IMAGE);
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
                  _loc2_ = BitmapFontTextFormat(this._textFormatForState[_loc1_]);
               }
            }
            if(_loc2_ === null && this._disabledTextFormat !== null && this._stateContext is IFeathersControl && !IFeathersControl(this._stateContext).isEnabled)
            {
               _loc2_ = this._disabledTextFormat;
            }
            if(_loc2_ === null && this._selectedTextFormat !== null && this._stateContext is IToggle && IToggle(this._stateContext).isSelected)
            {
               _loc2_ = this._selectedTextFormat;
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
         else
         {
            this._currentVerticalAlign = "top";
         }
         if(this._currentTextFormat !== _loc2_)
         {
            this._currentTextFormat = _loc2_;
            this._textFormatChanged = true;
         }
      }
      
      protected function getTextFormatFromFontStyles() : BitmapFontTextFormat
      {
         var _loc1_:* = null;
         var _loc2_:* = null;
         if(this.isInvalid("styles") || this.isInvalid("state"))
         {
            if(this._fontStyles !== null)
            {
               _loc1_ = this._fontStyles.getTextFormatForTarget(this);
            }
            if(_loc1_ !== null)
            {
               this._fontStylesTextFormat = new BitmapFontTextFormat(_loc1_.font,_loc1_.size,_loc1_.color,_loc1_.horizontalAlign,_loc1_.leading);
               this._fontStylesTextFormat.isKerningEnabled = _loc1_.kerning;
               if("letterSpacing" in _loc1_)
               {
                  this._fontStylesTextFormat.letterSpacing = _loc1_["letterSpacing"];
               }
               this._currentVerticalAlign = _loc1_.verticalAlign;
            }
            else if(this._fontStylesTextFormat === null)
            {
               if(!TextField.getBitmapFont("mini"))
               {
                  _loc2_ = new BitmapFont();
                  TextField.registerCompositor(_loc2_,_loc2_.name#2);
               }
               this._fontStylesTextFormat = new BitmapFontTextFormat("mini",NaN,0);
               this._currentVerticalAlign = "top";
            }
         }
         return this._fontStylesTextFormat;
      }
      
      protected function getTruncatedText(param1:Number) : String
      {
         var _loc8_:* = 0;
         var _loc6_:int = 0;
         var _loc9_:* = null;
         var _loc14_:* = NaN;
         var _loc2_:Number = NaN;
         var _loc15_:Number = NaN;
         if(!this._text)
         {
            return "";
         }
         if(param1 == Infinity || this._wordWrap || this._text.indexOf(String.fromCharCode(10)) >= 0 || this._text.indexOf(String.fromCharCode(13)) >= 0)
         {
            return this._text;
         }
         var _loc16_:BitmapFont = this._currentTextFormat.font;
         var _loc10_:Number = this._currentTextFormat.size;
         var _loc11_:Number = this._currentTextFormat.letterSpacing;
         var _loc5_:Boolean = this._currentTextFormat.isKerningEnabled;
         var _loc7_:* = Number(_loc10_ / _loc16_.size);
         if(_loc7_ !== _loc7_)
         {
            _loc7_ = 1;
         }
         var _loc12_:* = 0;
         var _loc13_:Number = NaN;
         var _loc3_:int = this._text.length;
         var _loc4_:* = -1;
         _loc8_ = 0;
         while(_loc8_ < _loc3_)
         {
            _loc6_ = this._text.charCodeAt(_loc8_);
            if((_loc9_ = _loc16_.getChar(_loc6_)) !== null)
            {
               _loc14_ = 0;
               if(_loc5_ && _loc13_ === _loc13_)
               {
                  _loc14_ = Number(_loc9_.getKerning(_loc13_) * _loc7_);
               }
               _loc2_ = _loc9_.width * _loc7_;
               if((_loc12_ += _loc14_ + _loc2_) > param1)
               {
                  if((_loc15_ = Math.abs(_loc12_ - param1)) > 0.000001)
                  {
                     _loc4_ = _loc8_;
                     _loc12_ += _loc9_.xAdvance * _loc7_ - _loc2_;
                     break;
                  }
               }
               _loc12_ += _loc11_ + _loc9_.xAdvance * _loc7_ - _loc2_;
               _loc13_ = _loc6_;
            }
            _loc8_++;
         }
         if(_loc4_ >= 0)
         {
            _loc3_ = this._truncationText.length;
            _loc8_ = 0;
            while(_loc8_ < _loc3_)
            {
               _loc6_ = this._truncationText.charCodeAt(_loc8_);
               if((_loc9_ = _loc16_.getChar(_loc6_)) !== null)
               {
                  _loc14_ = 0;
                  if(_loc5_ && _loc13_ === _loc13_)
                  {
                     _loc14_ = Number(_loc9_.getKerning(_loc13_) * _loc7_);
                  }
                  _loc12_ += _loc14_ + _loc9_.xAdvance * _loc7_ + _loc11_;
                  _loc13_ = _loc6_;
               }
               _loc8_++;
            }
            _loc12_ -= _loc11_;
            if(_loc9_ !== null)
            {
               _loc12_ -= (_loc9_.xAdvance - _loc9_.width) * _loc7_;
            }
            _loc8_ = _loc4_;
            while(_loc8_ >= 0)
            {
               _loc6_ = this._text.charCodeAt(_loc8_);
               _loc13_ = _loc8_ > 0 ? this._text.charCodeAt(_loc8_ - 1) : NaN;
               if((_loc9_ = _loc16_.getChar(_loc6_)) !== null)
               {
                  _loc14_ = 0;
                  if(_loc5_ && _loc13_ === _loc13_)
                  {
                     _loc14_ = Number(_loc9_.getKerning(_loc13_) * _loc7_);
                  }
                  if((_loc12_ -= _loc14_ + _loc9_.xAdvance * _loc7_ + _loc11_) <= param1)
                  {
                     return this._text.substr(0,_loc8_) + this._truncationText;
                  }
               }
               _loc8_--;
            }
            return this._truncationText;
         }
         return this._text;
      }
      
      protected function getVerticalAlignOffsetY() : Number
      {
         var _loc5_:BitmapFont = this._currentTextFormat.font;
         var _loc3_:Number = this._currentTextFormat.size;
         var _loc2_:* = Number(_loc3_ / _loc5_.size);
         if(_loc2_ !== _loc2_)
         {
            _loc2_ = 1;
         }
         var _loc4_:Number = _loc5_.lineHeight * _loc2_ + this._currentTextFormat.leading;
         var _loc1_:Number = this._numLines * _loc4_;
         if(_loc1_ > this.actualHeight)
         {
            return 0;
         }
         if(this._currentVerticalAlign === "bottom")
         {
            return this.actualHeight - _loc1_;
         }
         if(this._currentVerticalAlign === "center")
         {
            return (this.actualHeight - _loc1_) / 2;
         }
         return 0;
      }
   }
}

import starling.text.BitmapChar;

class CharLocation
{
    
   
   public var char:BitmapChar;
   
   public var scale:Number;
   
   public var x:Number;
   
   public var y:Number;
   
   function CharLocation()
   {
      super();
   }
}
