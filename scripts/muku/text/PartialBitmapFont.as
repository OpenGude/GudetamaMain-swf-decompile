package muku.text
{
   import flash.display.BitmapData;
   import flash.filters.GlowFilter;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.engine.ElementFormat;
   import flash.text.engine.FontDescription;
   import flash.text.engine.FontMetrics;
   import flash.utils.Dictionary;
   import muku.core.ApplicationContext;
   import muku.core.MukuGlobal;
   import starling.display.MeshBatch;
   import starling.text.BitmapChar;
   import starling.text.BitmapFont;
   import starling.text.TextField;
   import starling.text.TextFormat;
   import starling.text.TextOptions;
   import starling.textures.Texture;
   import starling.utils.MathUtil;
   
   public class PartialBitmapFont extends BitmapFont
   {
      
      private static const TEXTURE_BITMAP_WIDTH:int = 900;
      
      private static const ALPHE_NUMERIC:String = " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890-=_+[]{};\':\\\",./<>?~!@#$%^&*()";
      
      private static const NUMERIC:String = "0123456789";
      
      private static var REGISTER_BITMAP_FONT_ID:int = 0;
      
      private static var sHelperMatrix:Matrix = new Matrix();
      
      private static var sNativeTextField:flash.text.TextField = new flash.text.TextField();
      
      private static var metricDict:Dictionary = new Dictionary();
      
      private static var sUseEmbed:Boolean = true;
      
      private static var sCheckCombine:Boolean = false;
      
      private static var _forceHighQuality:Boolean = false;
      
      public static const COLOR_TABLE:Object = {
         "WHITE":4294967295,
         "RED":4292411392,
         "GREEN":4278255360,
         "BLUE":4278218201,
         "YELLOW":4293227008,
         "VIOLET":4284225509,
         "GRAY":4284900966,
         "BLACK":4283190348,
         "CLEAR":4278190080
      };
      
      private static var clearRect:Rectangle = new Rectangle(0,0,128,128);
      
      private static var bitmapCache:Vector.<BitmapData> = new Vector.<BitmapData>();
      
      private static var bitmapData:BitmapData = new BitmapData(128,128,true,0);
      
      private static var fillRect:Rectangle = new Rectangle(0,0,128,128);
      
      private static var colorTransform:ColorTransform = new ColorTransform(1,1,1,1,0,0,0,0);
      
      private static var _flashRect:Rectangle = new Rectangle();
      
      private static var _flashPointZero:Point = new Point();
      
      private static var charas:Array = [];
       
      
      private var mOnelineMode:Boolean = false;
      
      private var mLetterSpacing:int = 0;
      
      private var mOutlineAdjustment:int = 0;
      
      private var mIgnoreHeadLinefeed:Boolean = false;
      
      private const kinsoku_start:String = "、。，．,.!！)）}｝]］』」｣?？";
      
      private const kinsoku_end:String = "(（[{｛【「『［";
      
      private var codes:Vector.<String>;
      
      public function PartialBitmapFont(param1:Texture)
      {
         codes = new Vector.<String>();
         super(param1);
      }
      
      public static function get useEmbed() : Boolean
      {
         return sUseEmbed;
      }
      
      public static function set useEmbed(param1:Boolean) : void
      {
         sUseEmbed = param1;
      }
      
      public static function set checkCombine(param1:Boolean) : void
      {
         sCheckCombine = param1;
      }
      
      private static function getTopLimits(param1:String, param2:uint, param3:Number, param4:Boolean = false) : Array
      {
         var _loc13_:int = 0;
         var _loc5_:int = 0;
         var _loc11_:* = null;
         var _loc10_:* = null;
         var _loc7_:* = null;
         var _loc12_:* = null;
         var _loc8_:* = null;
         var _loc6_:* = null;
         var _loc14_:String = param1 + param2 + "_" + param3 + "_" + (!!param4 ? "h" : "l");
         var _loc9_:Array;
         if((_loc9_ = metricDict[_loc14_]) == null)
         {
            (_loc11_ = new FontDescription()).fontName = param1;
            (_loc10_ = new ElementFormat(_loc11_)).fontSize = param2;
            _loc7_ = _loc10_.getFontMetrics();
            _loc13_ = param2 + _loc7_.emBox.y - param2 * 0.09 + (param2 < 24 ? 0.5 : -0.5) + param3 * 0.2;
            if(param4)
            {
               _loc13_ -= 1;
            }
            (_loc12_ = new FontDescription()).fontLookup = "embeddedCFF";
            _loc12_.fontName = "verdana_embed";
            (_loc8_ = new ElementFormat(_loc12_)).fontSize = param2;
            _loc6_ = _loc8_.getFontMetrics();
            _loc5_ = _loc7_.emBox.y - _loc6_.emBox.y + 0.99 + _loc7_.strikethroughOffset - _loc6_.strikethroughOffset + _loc7_.emBox.height - _loc6_.emBox.height;
            _loc9_ = [_loc13_,_loc5_];
            metricDict[_loc14_] = _loc9_;
         }
         return _loc9_;
      }
      
      public static function keepBitmapData(param1:BitmapData) : void
      {
         if(param1)
         {
            clearRect.setTo(0,0,param1.width,param1.height);
            param1.fillRect(clearRect,0);
            bitmapCache.push(param1);
         }
      }
      
      public static function disposeKeepBitmapData() : void
      {
         var _loc2_:int = 0;
         var _loc1_:int = bitmapCache.length;
         _loc2_ = _loc1_ - 1;
         while(_loc2_ >= 0)
         {
            bitmapCache.removeAt(_loc2_).dispose();
            _loc2_--;
         }
      }
      
      private static function getBitmapData(param1:int, param2:int) : BitmapData
      {
         var _loc7_:int = 0;
         var _loc4_:* = null;
         var _loc6_:int = 4096;
         var _loc3_:int = 4096;
         for each(var _loc5_ in bitmapCache)
         {
            if(_loc5_.width >= param1 && _loc5_.height >= param2)
            {
               if(_loc5_.width == _loc6_ && _loc5_.height < _loc3_)
               {
                  _loc3_ = _loc5_.height;
                  _loc4_ = _loc5_;
               }
               else if(_loc5_.width < _loc6_)
               {
                  _loc6_ = _loc5_.width;
                  _loc4_ = _loc5_;
                  _loc3_ = _loc5_.height;
               }
            }
         }
         if(_loc4_ && _loc4_.width * _loc4_.height <= param1 * param2 * 4)
         {
            _loc7_ = bitmapCache.indexOf(_loc4_);
            bitmapCache.removeAt(_loc7_);
            return _loc4_;
         }
         return new BitmapData(param1,param2,true,0);
      }
      
      private static function renderOneCharacter(param1:String, param2:flash.text.TextFormat, param3:Number, param4:Rectangle, param5:Number = 1, param6:Boolean = false, param7:GlowFilter = null, param8:int = 0, param9:Number = 0, param10:Number = 3.5, param11:Boolean = false) : BitmapData
      {
         var _loc21_:* = null;
         var _loc27_:* = null;
         var _loc29_:Number = param3 * 2 * param5;
         var _loc20_:Number = param3 * 2 * param5;
         var _loc12_:* = _loc21_;
         var _loc13_:* = _loc27_;
         var _loc31_:int = param10 * 1.2 + 0.5;
         var _loc30_:int = param10 + 3;
         var _loc26_:int = !!param7 ? (_loc31_ > _loc30_ ? _loc31_ : int(_loc30_)) : 0;
         param2.kerning = false;
         param2.leading = 2;
         sNativeTextField.defaultTextFormat = param2;
         sNativeTextField.width = _loc29_;
         sNativeTextField.height = _loc20_;
         sNativeTextField.antiAliasType = !!param6 ? "advanced" : "normal";
         sNativeTextField.selectable = false;
         sNativeTextField.multiline = false;
         sNativeTextField.wordWrap = false;
         sNativeTextField.text#2 = param1;
         sNativeTextField.embedFonts = sUseEmbed;
         sNativeTextField.filters = [];
         if(param11 && (sNativeTextField.textWidth == 0 || sNativeTextField.textHeight == 0))
         {
            return null;
         }
         if(sNativeTextField.textWidth == 0 || sNativeTextField.textHeight == 0)
         {
            sNativeTextField.embedFonts = false;
         }
         var _loc24_:Number = int(Math.ceil(sNativeTextField.textWidth + (!!param7 ? _loc26_ : 0)));
         var _loc25_:Number = int(Math.ceil(sNativeTextField.textHeight + (!!param7 ? _loc26_ : 0)));
         if(_loc24_ == 0)
         {
            _loc24_ = 2 * param5;
         }
         if(isAsciiText(param1))
         {
            _loc24_++;
            _loc25_++;
         }
         if(_loc25_ == 0)
         {
            _loc25_ = 2 * param5;
         }
         var _loc18_:Number = !!param7 ? int(_loc26_ * 0.5) + 2 : 2;
         var _loc19_:Number = !!param7 ? int(_loc26_ * 0.5) + 2 : 2;
         var _loc28_:int = _loc24_ + 4 + _loc18_;
         var _loc16_:int = _loc25_ + 4 + _loc19_;
         _loc28_ = MathUtil.getNextPowerOfTwo(_loc28_);
         _loc16_ = MathUtil.getNextPowerOfTwo(_loc16_);
         if(bitmapData == null || (bitmapData.width < _loc28_ || bitmapData.height < _loc16_))
         {
            if(bitmapData)
            {
               bitmapData.dispose();
               bitmapData = null;
            }
            bitmapData = new BitmapData(_loc28_,_loc16_,true,0);
            fillRect.setTo(0,0,_loc28_,_loc16_);
         }
         else
         {
            bitmapData.fillRect(fillRect,0);
         }
         var _loc22_:int = !!param7 ? _loc18_ - 4 : Number(_loc18_);
         var _loc23_:int = !!param7 ? _loc19_ - 4 : Number(_loc19_);
         var _loc17_:Matrix = new Matrix(1,0,0,1,_loc18_ - 2,_loc19_ - 2);
         var _loc14_:Function;
         if((_loc14_ = "drawWithQuality" in bitmapData ? bitmapData["drawWithQuality"] : null) is Function)
         {
            _loc14_.call(bitmapData,sNativeTextField,_loc17_,null,null,null,false,"medium");
         }
         else
         {
            bitmapData.draw(sNativeTextField,_loc17_);
         }
         if(param7)
         {
            _flashRect.x = _flashRect.y = 0;
            _flashRect.width = _loc24_;
            _flashRect.height = _loc25_;
            bitmapData.applyFilter(bitmapData,_flashRect,_flashPointZero,param7);
         }
         sNativeTextField.text#2 = "";
         var _loc15_:Rectangle;
         (_loc15_ = bitmapData.getColorBoundsRect(4294967295,0,false)).x = Math.floor(_loc15_.x);
         _loc15_.y = Math.floor(_loc15_.y);
         _loc15_.width = Math.ceil(_loc15_.width);
         _loc15_.height = Math.ceil(_loc15_.height);
         if(_loc15_.height == 0)
         {
            _loc15_.height = 2 * param5;
         }
         param4.setTo(_loc22_ / param5,int((_loc15_.y > 0 ? _loc15_.y - 1 : Number(_loc15_.y)) / param5),int(_loc24_ / param5),int((_loc15_.y > 0 ? _loc15_.height + 2 : Number(_loc15_.height)) / param5));
         return bitmapData;
      }
      
      private static function isAsciiText(param1:String) : Boolean
      {
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         if(param1 == null || param1.length == 0)
         {
            return true;
         }
         var _loc4_:int = param1.length;
         _loc3_ = 0;
         while(_loc3_ < _loc4_)
         {
            _loc2_ = param1.charCodeAt(_loc3_);
            if(_loc2_ < 0 || _loc2_ > 127)
            {
               return false;
            }
            _loc3_++;
         }
         return true;
      }
      
      public static function createFont(param1:String, param2:uint, param3:Boolean = false, param4:Boolean = false, param5:int = 0, param6:Number = 0, param7:Number = 3.5, param8:String = " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890-=_+[]{};\':\\\",./<>?~!@#$%^&*()", param9:Boolean = false) : PartialBitmapFont
      {
         var _loc27_:* = 0;
         var _loc28_:int = 0;
         var _loc38_:int = 0;
         var _loc19_:int = 0;
         var _loc26_:* = null;
         var _loc20_:* = false;
         var _loc18_:* = null;
         var _loc41_:* = null;
         var _loc22_:* = null;
         var _loc37_:int = 0;
         var _loc34_:* = null;
         var _loc30_:* = null;
         param1 = ApplicationContext.getFontName(param1);
         if(_forceHighQuality)
         {
            param9 = true;
         }
         var _loc15_:* = 1;
         var _loc33_:flash.text.TextFormat = new flash.text.TextFormat(param1,param2 * _loc15_,16777215,param3,false,false,null,null,null);
         var _loc29_:flash.text.TextFormat = null;
         var _loc35_:Object = {};
         var _loc31_:int = 0;
         charas.length = 0;
         if(param1 == "num1")
         {
            param8 = "0123456789";
         }
         var _loc23_:Boolean;
         var _loc10_:Boolean = (_loc23_ = ApplicationContext.isNeedCheckPositionFont(param1)) || !isAsciiText(param8);
         _loc28_ = 0;
         while(_loc28_ < param8.length)
         {
            _loc27_ = int(param8.charCodeAt(_loc28_));
            _loc38_ = 0;
            if(sCheckCombine)
            {
               while(_loc28_ < param8.length - (_loc38_ + 1))
               {
                  _loc19_ = param8.charCodeAt(_loc28_ + _loc38_ + 1);
                  if(!isCombiningCharacter(_loc19_))
                  {
                     break;
                  }
                  _loc27_ += _loc19_;
                  _loc38_++;
               }
            }
            if(!(_loc27_ in _loc35_))
            {
               if(_loc38_ == 2)
               {
                  _loc35_[_loc27_] = param8.charAt(_loc28_) + param8.charAt(_loc28_ + 1) + param8.charAt(_loc28_ + 2);
               }
               else if(_loc38_ == 1)
               {
                  _loc35_[_loc27_] = param8.charAt(_loc28_) + param8.charAt(_loc28_ + 1);
               }
               else
               {
                  _loc35_[_loc27_] = param8.charAt(_loc28_);
               }
               _loc28_ += _loc38_;
               _loc31_++;
            }
            _loc28_++;
         }
         var _loc25_:GlowFilter = null;
         var _loc11_:int = 1;
         var _loc36_:int = _loc31_ * (param2 + 2) * 1.2;
         var _loc39_:int = param2 * 1.2;
         if(param4)
         {
            _loc36_ += int(_loc31_ * (param7 * 1.2 + 1));
            _loc39_ = _loc39_ + param7 * 1.2 + 1;
            if(param6 == 0)
            {
               param6 = param2 * 0.18;
            }
            _loc25_ = new GlowFilter(param5,0.85,param7,param7,param6,1,false,false);
         }
         if(_loc36_ >= 900)
         {
            _loc11_ = _loc36_ / 900 + 1;
            _loc36_ = 900 + param2 + param7 * 1.2 + 1;
         }
         _loc36_ = MathUtil.getNextPowerOfTwo(_loc36_);
         var _loc21_:int = MathUtil.getNextPowerOfTwo(_loc39_ * _loc11_);
         var _loc12_:Array = !!_loc10_ ? getTopLimits(param1,param2,!!param4 ? param7 : 0,param9) : null;
         var _loc40_:String = ApplicationContext.getDefaultFontName();
         var _loc42_:BitmapData = getBitmapData(_loc36_,_loc21_);
         var _loc16_:* = 0;
         var _loc17_:int = 0;
         var _loc24_:int = 0;
         var _loc32_:int = 0;
         for(_loc27_ in _loc35_)
         {
            _loc20_ = _loc23_;
            _loc18_ = _loc12_;
            _loc41_ = new Rectangle();
            if(!(_loc22_ = renderOneCharacter(_loc35_[_loc27_],_loc33_,param2,_loc41_,1,param9,_loc25_,param5,param6,param7,_loc40_)))
            {
               if(!_loc29_)
               {
                  _loc29_ = new flash.text.TextFormat(_loc40_,param2 * _loc15_,16777215,param3,false,false,null,null,null);
               }
               _loc22_ = renderOneCharacter(_loc35_[_loc27_],_loc29_,param2,_loc41_,1,param9,_loc25_,param5,param6,param7);
               _loc18_ = getTopLimits(_loc40_,param2,!!param4 ? param7 : 0,param9);
               _loc20_ = Boolean(ApplicationContext.isNeedCheckPositionFont(_loc40_));
            }
            if(_loc41_.x + _loc41_.width + _loc16_ + 2 >= _loc36_)
            {
               _loc16_ = 0;
               _loc32_++;
               _loc17_ = _loc39_ * _loc32_;
            }
            _loc24_ = _loc41_.x;
            _loc41_.x += _loc16_ + 2;
            _loc16_ += _loc24_ + _loc41_.width;
            _loc37_ = _loc41_.y;
            if(_loc18_ && (_loc10_ && _loc37_ < _loc18_[0] || _loc20_))
            {
               _loc37_ += _loc18_[1];
            }
            _loc26_ = {
               "id":_loc27_,
               "yOffset":_loc37_,
               "region":_loc41_
            };
            charas.push(_loc26_);
            _loc42_.copyPixels(_loc22_,new Rectangle(_loc24_,_loc41_.y,_loc41_.width,_loc41_.height),new Point(_loc41_.x,_loc17_));
            _loc41_.y = _loc17_;
         }
         var _loc13_:Texture = Texture.fromBitmapData(_loc42_);
         var _loc14_:PartialBitmapFont = new PartialBitmapFont(_loc13_);
         for each(_loc26_ in charas)
         {
            _loc34_ = Texture.fromTexture(_loc13_,_loc26_.region);
            _loc30_ = new BitmapChar(_loc26_.id,_loc34_,0,_loc26_.yOffset,_loc26_.region.width);
            _loc14_.addChar(_loc26_.id,_loc30_);
         }
         _loc14_.size = param2;
         _loc14_.lineHeight = param2;
         _loc14_.baseline = param2;
         if(param4)
         {
            _loc14_.mOutlineAdjustment = -(int((param7 + 2) * 0.5 + 1.5));
         }
         return _loc14_;
      }
      
      public static function createAndRegisterBitmapFont(param1:ColorTextField, param2:String) : PartialBitmapFont
      {
         var _loc3_:PartialBitmapFont = PartialBitmapFont.createFont(param1.basefont,param1.fontSize,param1.bold,param1.outline,param1.outlineColor,param1.outlineStrength,param1.outlineBlur,param2);
         if(++REGISTER_BITMAP_FONT_ID >= 2147483647)
         {
            REGISTER_BITMAP_FONT_ID = 0;
         }
         _loc3_.name#2 = String(REGISTER_BITMAP_FONT_ID);
         starling.text.TextField.registerCompositor(_loc3_,_loc3_.name#2);
         param1.fontName = _loc3_.name#2;
         return _loc3_;
      }
      
      public static function unregisterBitmapFont(param1:BitmapFont, param2:Boolean = false) : void
      {
         starling.text.TextField.unregisterCompositor(param1.name#2,param2);
      }
      
      private static function reviseTextButtom(param1:Vector.<CharLocationInfo>, param2:Number, param3:Number, param4:Number, param5:Number) : void
      {
         var _loc6_:* = null;
         var _loc7_:int = 0;
         _loc7_ = 0;
         while(_loc7_ < param1.length)
         {
            if((_loc6_ = param1[_loc7_]).y - param4 != param5)
            {
               _loc6_.y += (_loc6_.y - param4) * (_loc6_.scale - 1);
            }
            if(_loc6_.scale != param2)
            {
               _loc6_.y += param3 * (param2 - _loc6_.scale);
            }
            _loc7_++;
         }
      }
      
      public static function set forceHighQuality(param1:Boolean) : void
      {
         _forceHighQuality = param1;
      }
      
      public static function get forceHighQuality() : Boolean
      {
         return _forceHighQuality;
      }
      
      private static function isCombiningCharacter(param1:Number) : Boolean
      {
         if(param1 == 3633 || 3636 <= param1 && param1 <= 3642 || 3655 <= param1 && param1 <= 3662)
         {
            return true;
         }
         return false;
      }
      
      override public function dispose() : void
      {
         if(texture && texture.root && texture.root.getBitmap)
         {
            texture.getBitmapData(function(param1:BitmapData, param2:Boolean):void
            {
               keepBitmapData(param1);
            });
         }
         super.dispose();
      }
      
      public function applyMeshBatch(param1:MeshBatch, param2:Vector.<CharLocationInfo>, param3:int = -1) : void
      {
         var _loc4_:int = 0;
         var _loc5_:* = null;
         var _loc6_:* = int(param2.length);
         if(param3 >= 0 && param3 < _loc6_)
         {
            _loc6_ = param3;
         }
         param1.clear();
         param1.x = param1.y = 0;
         _loc4_ = 0;
         while(_loc4_ < _loc6_)
         {
            if((_loc5_ = param2[_loc4_]).visible)
            {
               _helperImage.texture = _loc5_.char.texture;
               _helperImage.color = _loc5_.color;
               _helperImage.readjustSize();
               _helperImage.x = _loc5_.x;
               _helperImage.y = _loc5_.y;
               _helperImage.scaleX = _helperImage.scaleY = _loc5_.scale;
               param1.addMesh(_helperImage);
            }
            _loc4_++;
         }
      }
      
      override public function fillMeshBatch(param1:MeshBatch, param2:Number, param3:Number, param4:String, param5:starling.text.TextFormat, param6:TextOptions = null) : void
      {
         var _loc8_:int = 0;
         var _loc9_:* = null;
         var _loc7_:Vector.<CharLocationInfo>;
         var _loc10_:int = (_loc7_ = layoutText(param2,param3,param4,param5,param6)).length;
         _helperImage.color = param5.color;
         _loc8_ = 0;
         while(_loc8_ < _loc10_)
         {
            _loc9_ = _loc7_[_loc8_];
            _helperImage.texture = _loc9_.char.texture;
            _helperImage.color = _loc9_.color;
            _helperImage.readjustSize();
            _helperImage.x = _loc9_.x;
            _helperImage.y = _loc9_.y;
            _helperImage.scaleX = _helperImage.scaleY = _loc9_.scale;
            param1.addMesh(_helperImage);
            _loc8_++;
         }
         CharLocationInfo.vectorInstanceToPool(_loc7_);
         CharLocationInfo.vectorToPool(_loc7_);
      }
      
      public function layoutText(param1:Number, param2:Number, param3:String, param4:starling.text.TextFormat, param5:TextOptions, param6:Number = 0) : Vector.<CharLocationInfo>
      {
         var _loc35_:* = null;
         var _loc29_:int = 0;
         var _loc46_:Number = NaN;
         var _loc59_:Number = NaN;
         var _loc41_:Number = NaN;
         var _loc11_:* = 0;
         var _loc51_:* = 0;
         var _loc61_:* = 0;
         var _loc48_:* = 0;
         var _loc17_:* = NaN;
         var _loc23_:* = 0;
         var _loc53_:int = 0;
         var _loc9_:* = 0;
         var _loc33_:* = 0;
         var _loc32_:* = NaN;
         var _loc44_:* = NaN;
         var _loc50_:* = undefined;
         var _loc30_:* = NaN;
         var _loc18_:* = NaN;
         var _loc54_:* = 0;
         var _loc12_:* = null;
         var _loc26_:* = 0;
         var _loc14_:* = 0;
         var _loc37_:* = null;
         var _loc22_:* = null;
         var _loc38_:* = null;
         var _loc21_:* = 0;
         var _loc58_:Boolean = false;
         var _loc24_:int = 0;
         var _loc34_:int = 0;
         var _loc13_:int = 0;
         var _loc63_:* = null;
         var _loc36_:* = null;
         var _loc45_:int = 0;
         var _loc60_:int = 0;
         var _loc31_:int = 0;
         var _loc55_:int = 0;
         var _loc57_:int = 0;
         var _loc42_:int = 0;
         var _loc40_:* = undefined;
         var _loc20_:int = 0;
         var _loc27_:* = null;
         var _loc56_:Number = NaN;
         var _loc52_:int = 0;
         if(param3 == null || param3.length == 0)
         {
            return CharLocationInfo.vectorFromPool();
         }
         if(param5 == null)
         {
            param5 = sDefaultOptions;
         }
         if(param4.size < 0)
         {
            param4.size *= -size;
         }
         var _loc28_:Boolean = false;
         var _loc7_:* = uint(param4.color);
         var _loc62_:uint = param4.color;
         var _loc64_:int = 0;
         var _loc16_:int = 0;
         var _loc47_:* = param6;
         var _loc10_:* = param6;
         var _loc43_:Boolean = false;
         var _loc15_:Boolean = true;
         var _loc49_:Boolean = ApplicationContext.needCheckMultiByteChar();
         codes.length = 0;
         ApplicationContext.initCode();
         param3 = ApplicationContext.replaceText(param3);
         while(!_loc28_)
         {
            sLines.length = 0;
            _loc41_ = param4.size / size;
            _loc46_ = param1 / _loc41_ - (!!mOnelineMode ? 0 : Number(param4.size / 2));
            _loc59_ = param2 / _loc41_;
            if(lineHeight <= _loc59_)
            {
               _loc23_ = -1;
               _loc53_ = -1;
               _loc9_ = -1;
               _loc33_ = -1;
               _loc32_ = 0;
               _loc44_ = 0;
               _loc50_ = CharLocationInfo.vectorFromPool();
               _loc30_ = 0;
               _loc18_ = 0;
               _loc29_ = param3.length;
               _loc17_ = _loc41_;
               _loc54_ = 0;
               while(_loc54_ < _loc29_)
               {
                  _loc12_ = param3.charAt(_loc54_);
                  _loc26_ = _loc7_;
                  if(_loc12_ == "@" && _loc54_ + 2 < _loc29_ && param3.charAt(_loc54_ + 1) == "[")
                  {
                     if((_loc14_ = int(param3.indexOf("]",_loc54_ + 1))) < 0)
                     {
                        _loc14_ = _loc54_;
                     }
                     _loc37_ = param3.substring(_loc54_ + 2,_loc14_);
                     if(!ApplicationContext.setCode(_loc37_))
                     {
                        if(_loc37_.indexOf("SPD") == 0)
                        {
                           _loc47_ = Number(parseFloat(_loc37_.substr(3)));
                        }
                        else if(_loc37_.indexOf("WAIT") == 0)
                        {
                           _loc64_ += uint(_loc37_.substr(4));
                        }
                        else if(_loc37_ in PartialBitmapFont.COLOR_TABLE)
                        {
                           _loc26_ = uint(PartialBitmapFont.COLOR_TABLE[_loc37_]);
                        }
                        else if(_loc37_.indexOf("SCALE") == 0)
                        {
                           _loc17_ = Number(_loc37_.substr(5) / 100);
                           _loc43_ = true;
                        }
                        else if(_loc37_ == "")
                        {
                           if((_loc22_ = codes.pop()).indexOf("SPD") == 0)
                           {
                              _loc47_ = _loc10_;
                           }
                           else if(_loc22_.indexOf("SCALE") == 0)
                           {
                              _loc17_ = _loc41_;
                           }
                           else if(!ApplicationContext.unsetCode(_loc22_))
                           {
                              _loc26_ = _loc62_;
                           }
                        }
                        else if(_loc37_.indexOf(",") != -1)
                        {
                           _loc38_ = _loc37_.split(",");
                           _loc11_ = uint(parseInt(_loc38_[0]));
                           _loc51_ = uint(parseInt(_loc38_[1]));
                           _loc61_ = uint(parseInt(_loc38_[2]));
                           if(_loc38_.length > 3)
                           {
                              _loc48_ = uint(parseInt(_loc38_[3]));
                           }
                           else
                           {
                              _loc48_ = uint(255);
                           }
                           _loc26_ = uint(_loc48_ << 24 | _loc11_ << 16 | _loc51_ << 8 | _loc61_);
                        }
                        else if(_loc37_.length == 6 || _loc37_.length == 8)
                        {
                           _loc21_ = uint(0);
                           if(_loc37_.length == 8)
                           {
                              _loc48_ = uint("0x" + _loc37_.substr(_loc21_,2));
                              _loc21_ += 2;
                           }
                           _loc11_ = uint("0x" + _loc37_.substr(_loc21_,2));
                           _loc51_ = uint("0x" + _loc37_.substr(_loc21_ + 2,2));
                           _loc61_ = uint("0x" + _loc37_.substr(_loc21_ + 4,2));
                           _loc26_ = uint(_loc48_ << 24 | _loc11_ << 16 | _loc51_ << 8 | _loc61_);
                        }
                        else if(!MukuGlobal.isBuilderMode())
                        {
                           throw new ArgumentError("Invalid color code in text: \'" + _loc37_ + "\'");
                        }
                     }
                     _loc54_ = _loc14_;
                     _loc7_ = _loc26_;
                     if(_loc37_.length > 0)
                     {
                        codes.push(_loc37_);
                     }
                     if(_loc54_ >= _loc29_ - 1)
                     {
                        if(_loc43_)
                        {
                           reviseTextButtom(_loc50_,_loc30_,lineHeight,_loc44_,_loc18_);
                        }
                        _loc43_ = false;
                        sLines[sLines.length] = _loc50_;
                        _loc28_ = true;
                        break;
                     }
                  }
                  else if(ApplicationContext.skipCharacter())
                  {
                     if(_loc54_ >= _loc29_ - 1)
                     {
                        sLines[sLines.length] = _loc50_;
                        _loc28_ = true;
                        break;
                     }
                  }
                  else
                  {
                     _loc58_ = false;
                     _loc24_ = param3.charCodeAt(_loc54_);
                     _loc34_ = 0;
                     if(sCheckCombine)
                     {
                        while(_loc54_ < _loc29_ - (_loc34_ + 1))
                        {
                           _loc13_ = param3.charCodeAt(_loc54_ + _loc34_ + 1);
                           if(!isCombiningCharacter(_loc13_))
                           {
                              break;
                           }
                           _loc24_ += _loc13_;
                           _loc34_++;
                        }
                        if(_loc34_ == 2)
                        {
                           _loc12_ = param3.charAt(_loc54_) + param3.charAt(_loc54_ + 1) + param3.charAt(_loc54_ + 2);
                        }
                        else if(_loc34_ == 1)
                        {
                           _loc12_ = param3.charAt(_loc54_) + param3.charAt(_loc54_ + 1);
                        }
                     }
                     _loc63_ = getChar(_loc24_);
                     _loc36_ = null;
                     if(_loc24_ == 10 || _loc24_ == 13)
                     {
                        if(mIgnoreHeadLinefeed && _loc32_ == 0)
                        {
                           if(_loc54_ + 1 < _loc29_)
                           {
                              if((_loc45_ = param3.charCodeAt(_loc54_ + 1)) == 10 || _loc45_ == 13)
                              {
                                 _loc58_ = true;
                              }
                           }
                        }
                        else
                        {
                           _loc58_ = true;
                        }
                     }
                     else if(_loc63_ == null)
                     {
                        trace("[ParticalBitmapFont] Missing character: " + _loc24_);
                     }
                     else
                     {
                        if(_loc24_ == 32 || _loc24_ == 9)
                        {
                           _loc23_ = _loc54_;
                           _loc53_ = _loc50_.length;
                        }
                        if(param4.kerning)
                        {
                           _loc32_ += _loc63_.getKerning(_loc33_);
                        }
                        (_loc35_ = CharLocationInfo.instanceFromPool(_loc63_)).x = _loc32_ + _loc63_.xOffset;
                        _loc35_.y = _loc44_ + _loc63_.yOffset;
                        _loc35_.color = _loc7_;
                        _loc35_.idx = _loc54_;
                        _loc35_.waitCount = _loc64_;
                        _loc35_.typingSpeed = _loc47_;
                        _loc35_.word = _loc12_;
                        if(!param5.autoScale)
                        {
                           if(_loc17_ != _loc41_)
                           {
                              _loc43_ = true;
                           }
                           _loc35_.scale = _loc17_;
                           _loc30_ = Number(_loc30_ < _loc35_.scale ? _loc35_.scale : Number(_loc30_));
                        }
                        else
                        {
                           _loc17_ = 1;
                           _loc30_ = 1;
                        }
                        _loc50_[_loc50_.length] = _loc35_;
                        _loc32_ += _loc63_.xAdvance * _loc17_ + mOutlineAdjustment + mLetterSpacing;
                        _loc33_ = _loc24_;
                        _loc18_ = Number(_loc18_ < _loc63_.yOffset ? _loc18_ : Number(_loc63_.yOffset));
                        if(_loc35_.x + _loc63_.width > _loc46_)
                        {
                           if(mOnelineMode)
                           {
                              if(!param5.autoScale)
                              {
                                 if(_loc43_)
                                 {
                                    reviseTextButtom(_loc50_,_loc30_,lineHeight,_loc44_,_loc18_);
                                 }
                                 _loc43_ = false;
                                 CharLocationInfo.instanceToPool(_loc50_.pop());
                                 sLines[sLines.length] = _loc50_;
                                 _loc28_ = true;
                                 break;
                              }
                              break;
                           }
                           if("、。，．,.!！)）}｝]］』」｣?？".indexOf(_loc12_) >= 0)
                           {
                              _loc16_++;
                              if(_loc16_ > 1)
                              {
                                 _loc16_ = 0;
                                 _loc54_ = int((_loc36_ = _loc50_.pop()).idx - 1);
                                 _loc58_ = true;
                                 CharLocationInfo.instanceToPool(_loc36_);
                              }
                           }
                           else
                           {
                              if(!(_loc49_ && (_loc24_ < 0 || _loc24_ >= 255)))
                              {
                                 _loc31_ = _loc53_ <= 0 ? 1 : Number(_loc50_.length - _loc53_);
                                 _loc36_ = _loc50_.pop();
                                 CharLocationInfo.instanceToPool(_loc36_);
                                 _loc55_ = 1;
                                 while(_loc55_ < _loc31_)
                                 {
                                    _loc57_ = (_loc36_ = _loc50_.pop()).char.charID;
                                    CharLocationInfo.instanceToPool(_loc36_);
                                    if("(（[{｛【「『［".indexOf(String.fromCharCode(_loc57_)) >= 0)
                                    {
                                       break;
                                    }
                                    if(_loc49_ && (_loc57_ < 0 || _loc57_ >= 255) && "、。，．,.!！)）}｝]］』」｣?？".indexOf(param3.charAt(_loc36_.idx)) < 0)
                                    {
                                       break;
                                    }
                                    _loc55_++;
                                 }
                                 if(_loc50_.length != 0)
                                 {
                                    if("(（[{｛【「『［".indexOf(String.fromCharCode(_loc50_[_loc50_.length - 1].char.charID)) >= 0)
                                    {
                                       _loc36_ = _loc50_.pop();
                                       CharLocationInfo.instanceToPool(_loc36_);
                                    }
                                    _loc54_ = int(_loc23_ == _loc36_.idx ? _loc36_.idx : _loc36_.idx - 1);
                                    _loc53_ = 0;
                                    _loc58_ = true;
                                 }
                                 break;
                              }
                              _loc60_ = 0;
                              _loc36_ = _loc50_.pop();
                              while(_loc50_.length > 0 && "(（[{｛【「『［".indexOf(String.fromCharCode(_loc50_[_loc50_.length - 1].char.charID)) >= 0)
                              {
                                 _loc36_ = _loc50_.pop();
                                 _loc60_++;
                                 if(_loc60_ > 2)
                                 {
                                    break;
                                 }
                              }
                              _loc54_ = int(_loc36_.idx - 1);
                              CharLocationInfo.instanceToPool(_loc36_);
                              _loc58_ = true;
                           }
                        }
                        else
                        {
                           _loc16_ = 0;
                        }
                        _loc9_ = _loc54_ += _loc34_;
                     }
                     if(_loc54_ == _loc29_ - 1)
                     {
                        if(_loc43_)
                        {
                           reviseTextButtom(_loc50_,_loc30_,lineHeight,_loc44_,_loc18_);
                        }
                        _loc43_ = false;
                        sLines[sLines.length] = _loc50_;
                        _loc28_ = true;
                     }
                     else if(_loc58_)
                     {
                        if(_loc43_)
                        {
                           reviseTextButtom(_loc50_,_loc30_,lineHeight,_loc44_,_loc18_);
                        }
                        _loc43_ = false;
                        sLines[sLines.length] = _loc50_;
                        if(_loc44_ + param4.leading + 2 * lineHeight > _loc59_)
                        {
                           break;
                        }
                        _loc50_ = CharLocationInfo.vectorFromPool();
                        _loc32_ = 0;
                        _loc44_ += lineHeight * _loc30_ + param4.leading;
                        _loc23_ = -1;
                        _loc53_ = 0;
                        _loc33_ = -1;
                        _loc9_ = -1;
                        _loc30_ = 0;
                        _loc18_ = 0;
                     }
                  }
                  _loc54_++;
               }
            }
            if(param5.autoScale && !_loc28_ && param4.size > 3)
            {
               param4.size -= 1;
               _loc7_ = _loc62_;
            }
            else
            {
               _loc28_ = true;
            }
         }
         var _loc19_:Vector.<CharLocationInfo> = CharLocationInfo.vectorFromPool();
         var _loc39_:int = sLines.length;
         var _loc25_:Number = _loc44_ + lineHeight;
         var _loc8_:int = 0;
         if(_loc39_ == 1 || _loc39_ == 2 && sLines[1].length == 0)
         {
            _loc15_ = true;
         }
         if(param4.verticalAlign == "bottom")
         {
            _loc8_ = _loc59_ - _loc25_;
         }
         else if(param4.verticalAlign == "center")
         {
            _loc8_ = (_loc59_ - _loc25_) / 2;
         }
         _loc42_ = 0;
         while(_loc42_ < _loc39_)
         {
            if((_loc29_ = (_loc40_ = sLines[_loc42_]).length) == 0)
            {
               CharLocationInfo.vectorToPool(_loc40_);
            }
            else
            {
               _loc20_ = 0;
               _loc56_ = (_loc27_ = _loc40_[_loc40_.length - 1]).x - _loc27_.char.xOffset + _loc27_.char.xAdvance;
               if(param4.horizontalAlign == "right")
               {
                  _loc20_ = param1 / _loc41_ - _loc56_;
               }
               else if(param4.horizontalAlign == "center")
               {
                  _loc20_ = (param1 / _loc41_ - _loc56_) / 2;
               }
               if(_loc20_ < 0 || !_loc15_)
               {
                  _loc20_ = 0;
               }
               _loc52_ = 0;
               while(_loc52_ < _loc29_)
               {
                  _loc35_ = _loc40_[_loc52_];
                  if(param5.autoScale)
                  {
                     _loc35_.x = _loc41_ * (_loc35_.x + _loc20_ + offsetX);
                     _loc35_.y = _loc41_ * (_loc35_.y + _loc8_ + offsetY);
                     _loc35_.scale = _loc41_;
                  }
                  else
                  {
                     _loc35_.x = _loc35_.x + _loc20_ + offsetX;
                     _loc35_.y = _loc35_.y + _loc8_ + offsetY;
                  }
                  if(_loc35_.char.width > 0 && _loc35_.char.height > 0)
                  {
                     _loc19_[_loc19_.length] = _loc35_;
                  }
                  _loc52_++;
               }
               CharLocationInfo.vectorToPool(_loc40_);
            }
            _loc42_++;
         }
         return _loc19_;
      }
      
      public function set name#2(param1:String) : void
      {
         _name = param1;
      }
      
      public function set onelineMode(param1:Boolean) : void
      {
         mOnelineMode = param1;
      }
      
      public function get onelineMode() : Boolean
      {
         return mOnelineMode;
      }
      
      public function set letterSpacing(param1:int) : void
      {
         mLetterSpacing = param1;
      }
      
      public function get letterSpacing() : int
      {
         return mLetterSpacing;
      }
      
      public function set ignoreHeadLinefeed(param1:Boolean) : void
      {
         mIgnoreHeadLinefeed = param1;
      }
   }
}
