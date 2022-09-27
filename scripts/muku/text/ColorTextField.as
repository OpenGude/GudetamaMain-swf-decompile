package muku.text
{
   import muku.core.ApplicationContext;
   import muku.core.MukuGlobal;
   import starling.text.BitmapChar;
   import starling.text.BitmapFont;
   import starling.text.TextField;
   import starling.text.TextFormat;
   
   public class ColorTextField extends TextField
   {
      
      private static var REGISTER_BITMAP_FONT_ID:int = 0;
      
      protected static var seq:int = 0;
      
      private static var codes:Vector.<String> = new Vector.<String>();
       
      
      protected var mOutline:Boolean = false;
      
      protected var mOutlineColor:int = 0;
      
      protected var mOutlineStrength:Number = 1;
      
      protected var mOutlineBlur:Number = 3.5;
      
      protected var mRawText:String;
      
      protected var mNeedsUpdateFont:Boolean = false;
      
      protected var mNeedsArrange:Boolean = false;
      
      protected var privateBitmapFontName:String = null;
      
      protected var mBaseFontName:String = "capie";
      
      protected var mOnelineMode:Boolean = false;
      
      protected var mHighQuality:Boolean = false;
      
      protected var mLetterSpacing:int = 0;
      
      private var mIgnoreHeadLinefeed:Boolean = false;
      
      public function ColorTextField(param1:int = 100, param2:int = 32, param3:String = "", param4:String = "Verdana", param5:Number = 24, param6:uint = 0, param7:Boolean = false)
      {
         super(param1,param2,param3,new TextFormat(param4,param5,param6));
         format.bold = param7;
         touchable = MukuGlobal.isBuilderMode();
         mRawText = param3;
      }
      
      protected static function getSeqNo() : int
      {
         return ++seq;
      }
      
      protected static function isAsciiText(param1:String) : Boolean
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
      
      public static function getPlainText(param1:String) : String
      {
         var _loc7_:int = 0;
         var _loc3_:* = null;
         var _loc4_:int = 0;
         var _loc5_:* = null;
         var _loc6_:* = null;
         ApplicationContext.initCode();
         param1 = ApplicationContext.replaceText(param1);
         var _loc8_:int = param1.length;
         var _loc2_:Vector.<String> = new Vector.<String>();
         codes.length = 0;
         _loc7_ = 0;
         while(_loc7_ < _loc8_)
         {
            _loc3_ = param1.charAt(_loc7_);
            if(_loc3_ == "@" && _loc7_ + 2 < _loc8_ && param1.charAt(_loc7_ + 1) == "[")
            {
               _loc4_ = param1.indexOf("]",_loc7_ + 1);
               _loc5_ = param1.substring(_loc7_ + 2,_loc4_);
               if(!ApplicationContext.setCode(_loc5_))
               {
                  if(_loc5_ == "")
                  {
                     _loc6_ = codes.pop();
                     ApplicationContext.unsetCode(_loc6_);
                  }
               }
               if(_loc5_.length > 0)
               {
                  codes.push(_loc5_);
               }
               if(_loc4_ > 0)
               {
                  param1 = param1.substr(0,_loc7_) + param1.substr(_loc4_ + 1);
                  _loc8_ = param1.length;
                  _loc7_--;
               }
            }
            else if(ApplicationContext.skipCharacter())
            {
               param1 = param1.substr(0,_loc7_) + param1.substr(_loc7_ + 1);
               _loc8_ = param1.length;
               _loc7_--;
            }
            _loc7_++;
         }
         return param1;
      }
      
      public function updateValuesFrom(param1:ColorTextField) : void
      {
         if(mRawText == param1.mRawText)
         {
            return;
         }
         format.font = param1.format.font;
         text#2 = param1.mRawText;
      }
      
      private function disposeFont() : void
      {
         var _loc1_:* = null;
         if(privateBitmapFontName)
         {
            _loc1_ = getBitmapFont(privateBitmapFontName);
            if(_loc1_)
            {
               unregisterCompositor(privateBitmapFontName,false);
               _loc1_.dispose();
            }
            privateBitmapFontName = null;
         }
      }
      
      override public function dispose() : void
      {
         super.dispose();
         disposeFont();
      }
      
      public function flush() : void
      {
         disposeFont();
         mNeedsUpdateFont = true;
         mNeedsArrange = true;
         setRequiresRecomposition();
      }
      
      public function validate() : void
      {
         recompose();
         _requiresRecomposition = false;
      }
      
      override public function get text#2() : String
      {
         return mRawText;
      }
      
      override public function set text#2(param1:String) : void
      {
         var _loc2_:* = null;
         if(param1 == null)
         {
            param1 = "";
         }
         if(param1.length > 1 && param1.charAt(0) == "%")
         {
            _loc2_ = MukuGlobal.getUIText(param1);
            if(_loc2_ != null)
            {
               param1 = _loc2_;
            }
         }
         if(mRawText != param1)
         {
            mRawText = param1;
            mNeedsArrange = true;
         }
         super.text#2 = param1;
      }
      
      private function outlineMagic() : int
      {
         var _loc1_:int = mOutlineColor + mOutlineStrength * 255 + mOutlineBlur;
         if(_loc1_ < 0)
         {
            _loc1_ - _loc1_;
         }
         return _loc1_;
      }
      
      protected function createBitmapFont(param1:String) : PartialBitmapFont
      {
         var _loc2_:* = null;
         disposeFont();
         _loc2_ = PartialBitmapFont.createFont(mBaseFontName,fontSize,bold,mOutline,mOutlineColor,mOutlineStrength,mOutlineBlur);
         _loc2_.ignoreHeadLinefeed = mIgnoreHeadLinefeed;
         registerCompositor(_loc2_,param1);
         format.font = param1;
         return _loc2_;
      }
      
      protected function preparePartialBitmapFont(param1:String) : PartialBitmapFont
      {
         var _loc2_:* = null;
         var _loc3_:* = null;
         disposeFont();
         if(isAsciiText(param1))
         {
            fontName = mBaseFontName + "_ascii_p" + fontSize + (!!bold ? "_b" : "") + (!!mOutline ? "_o" + outlineMagic() : "");
            _loc2_ = getBitmapFont(fontName);
            if(_loc2_ == null || !(_loc2_ is PartialBitmapFont))
            {
               _loc3_ = createBitmapFont(fontName);
            }
            else
            {
               _loc3_ = _loc2_ as PartialBitmapFont;
            }
            return _loc3_;
         }
         _loc3_ = PartialBitmapFont.createFont(mBaseFontName,fontSize,bold,mOutline,mOutlineColor,mOutlineStrength,mOutlineBlur,param1,mHighQuality);
         _loc3_.ignoreHeadLinefeed = mIgnoreHeadLinefeed;
         privateBitmapFontName = mBaseFontName + "_p" + fontSize + (!!bold ? "_b" : "") + (!!mOutline ? "_o" + outlineMagic() : "") + "_" + getSeqNo();
         registerCompositor(_loc3_,privateBitmapFontName);
         format.font = privateBitmapFontName;
         return _loc3_;
      }
      
      protected function checkBitmapFont() : PartialBitmapFont
      {
         var _loc8_:* = null;
         var _loc9_:* = null;
         var _loc2_:* = null;
         var _loc1_:int = 0;
         var _loc3_:Boolean = false;
         var _loc7_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:* = null;
         var _loc6_:String = getPlainText(mRawText);
         if(mNeedsArrange && (fontName == privateBitmapFontName || fontName == "Verdana"))
         {
            fontName = "";
         }
         if(mNeedsUpdateFont && fontName != "")
         {
            if(isAsciiText(_loc6_))
            {
               _loc9_ = preparePartialBitmapFont(_loc6_);
               mNeedsUpdateFont = false;
               mNeedsArrange = false;
               _loc9_.onelineMode = mOnelineMode;
               _loc9_.letterSpacing = mLetterSpacing;
               return _loc9_;
            }
            fontName = "";
         }
         _loc8_ = getBitmapFont(fontName);
         if(fontName == "" || _loc8_ == null || !(_loc8_ is PartialBitmapFont))
         {
            _loc9_ = preparePartialBitmapFont(_loc6_);
         }
         else
         {
            _loc2_ = getPlainText(mRawText);
            _loc1_ = _loc2_.length;
            _loc3_ = false;
            _loc7_ = 0;
            while(_loc7_ < _loc1_)
            {
               _loc4_ = _loc2_.charCodeAt(_loc7_);
               if((_loc5_ = _loc8_.getChar(_loc4_)) == null)
               {
                  _loc3_ = true;
                  break;
               }
               _loc7_++;
            }
            if(_loc3_)
            {
               _loc9_ = preparePartialBitmapFont(_loc6_);
            }
            else
            {
               _loc9_ = _loc8_ as PartialBitmapFont;
            }
         }
         mNeedsUpdateFont = false;
         mNeedsArrange = false;
         _loc9_.onelineMode = mOnelineMode;
         _loc9_.letterSpacing = mLetterSpacing;
         return _loc9_;
      }
      
      override protected function recompose() : void
      {
         if(_requiresRecomposition)
         {
            checkBitmapFont();
         }
         super.recompose();
      }
      
      public function get fontName() : String
      {
         return format.font;
      }
      
      public function set fontName(param1:String) : void
      {
         if(format.font != param1)
         {
            disposeFont();
            format.font = param1;
            mNeedsArrange = true;
            mNeedsUpdateFont = false;
         }
      }
      
      public function get fontSize() : Number
      {
         return format.size;
      }
      
      public function set fontSize(param1:Number) : void
      {
         format.size = param1;
         mOutlineStrength = param1 * 0.18;
         mNeedsUpdateFont = true;
         mNeedsArrange = true;
      }
      
      public function get bold() : Boolean
      {
         return format.bold;
      }
      
      public function set bold(param1:Boolean) : void
      {
         format.bold = param1;
         mNeedsUpdateFont = true;
         mNeedsArrange = true;
      }
      
      public function get basefont() : String
      {
         return mBaseFontName;
      }
      
      public function set basefont(param1:String) : void
      {
         param1 = ApplicationContext.getFontName(param1);
         if(mBaseFontName != param1)
         {
            mBaseFontName = param1;
            setRequiresRecomposition();
            mNeedsUpdateFont = true;
            mNeedsArrange = true;
         }
      }
      
      public function get outline() : Boolean
      {
         return mOutline;
      }
      
      public function set outline(param1:Boolean) : void
      {
         if(mOutline != param1)
         {
            mOutline = param1;
            setRequiresRecomposition();
            mNeedsUpdateFont = true;
            mNeedsArrange = true;
         }
      }
      
      public function get outlineColor() : int
      {
         return mOutlineColor;
      }
      
      public function set outlineColor(param1:int) : void
      {
         if(mOutlineColor != param1)
         {
            mOutlineColor = param1;
            setRequiresRecomposition();
            mNeedsUpdateFont = true;
            mNeedsArrange = true;
         }
      }
      
      public function get outlineStrength() : Number
      {
         return mOutlineStrength;
      }
      
      public function set outlineStrength(param1:Number) : void
      {
         if(mOutlineStrength != param1)
         {
            mOutlineStrength = param1;
            if(mOutlineStrength > 255)
            {
               mOutlineStrength = 255;
            }
            setRequiresRecomposition();
            mNeedsUpdateFont = true;
            mNeedsArrange = true;
         }
      }
      
      public function get outlineBlur() : Number
      {
         return mOutlineBlur;
      }
      
      public function set outlineBlur(param1:Number) : void
      {
         if(mOutlineBlur != param1)
         {
            mOutlineBlur = param1;
            if(mOutlineBlur > 255)
            {
               mOutlineBlur = 255;
            }
            setRequiresRecomposition();
            mNeedsUpdateFont = true;
            mNeedsArrange = true;
         }
      }
      
      public function set onelineMode(param1:Boolean) : void
      {
         _requiresRecomposition = true;
         mNeedsArrange = true;
         mOnelineMode = param1;
      }
      
      public function get onelineMode() : Boolean
      {
         return mOnelineMode;
      }
      
      public function set highQuality(param1:Boolean) : void
      {
         _requiresRecomposition = true;
         mNeedsArrange = true;
         mHighQuality = param1;
      }
      
      public function get highQuality() : Boolean
      {
         return mHighQuality;
      }
      
      public function set letterSpacing(param1:int) : void
      {
         _requiresRecomposition = true;
         mNeedsArrange = true;
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
