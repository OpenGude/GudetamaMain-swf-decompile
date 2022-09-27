package muku.core
{
   import gudetama.engine.Engine;
   import muku.text.ApplicationTextControl;
   import muku.text.PartialBitmapFont;
   
   public final class ApplicationContext
   {
      
      private static var control:ApplicationTextControl;
       
      
      public function ApplicationContext()
      {
         super();
      }
      
      public static function setApplicationTextControl(param1:ApplicationTextControl) : void
      {
         control = param1;
      }
      
      public static function replaceText(param1:String) : String
      {
         if(!control)
         {
            return param1;
         }
         return control.replaceText(param1);
      }
      
      public static function initCode() : void
      {
         if(!control)
         {
            return;
         }
         control.initCode();
      }
      
      public static function setCode(param1:String) : Boolean
      {
         if(!control)
         {
            return false;
         }
         return control.setCode(param1);
      }
      
      public static function unsetCode(param1:String) : Boolean
      {
         if(!control)
         {
            return false;
         }
         return control.unsetCode(param1);
      }
      
      public static function skipCharacter() : Boolean
      {
         if(!control)
         {
            return false;
         }
         return control.skipCharacter();
      }
      
      public static function playSound(param1:String) : void
      {
         if(!control)
         {
            return;
         }
         control.playSound(param1);
      }
      
      public static function getDefaultFontName() : String
      {
         if(!control)
         {
            return null;
         }
         return control.getDefaultFontName();
      }
      
      public static function getFontName(param1:String) : String
      {
         if(!control)
         {
            return param1;
         }
         return control.convertFontName(param1);
      }
      
      public static function isNeedCheckPositionFont(param1:String) : Boolean
      {
         var _loc2_:* = PartialBitmapFont;
         if(!muku.text.PartialBitmapFont.sUseEmbed)
         {
            return true;
         }
         switch(param1)
         {
            case "waku":
            case "ko_capie":
            case "ko_capie_bold":
            case "cn_capie":
            case "cn_capie_bold":
            case "cn_yuru":
            case "vi_capie":
               break;
            case "vi_capie_bold":
               break;
            case "capie":
            case "capie_bold":
            case "yuru":
               return Engine.getLocale() == "pt";
            default:
               return false;
         }
         return true;
      }
      
      public static function needCheckMultiByteChar() : Boolean
      {
         switch(Engine.getLocale())
         {
            case "ja":
            case "ko":
            case "cn":
               break;
            case "tw":
               break;
            default:
               return false;
         }
         return true;
      }
   }
}
