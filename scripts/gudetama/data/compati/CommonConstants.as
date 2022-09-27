package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class CommonConstants
   {
      
      public static const PLATFORM_UNKNOWN:int = -1;
      
      public static const PLATFORM_IOS:int = 0;
      
      public static const PLATFORM_ANDROID:int = 1;
      
      public static const PLATFORM_WINDOWS:int = 2;
      
      public static const PLATFORM_OTHER:int = 3;
      
      public static const PLATFORM_ONESTORE:int = 4;
      
      public static const GENDER_MALE:int = 0;
      
      public static const GENDER_FEMALE:int = 1;
      
      public static const LOCALE_ALL:String = "all";
      
      public static const LOCALE_JA:String = "ja";
      
      public static const LOCALE_EN:String = "en";
      
      public static const LOCALE_KO:String = "ko";
      
      public static const LOCALE_CN:String = "cn";
      
      public static const LOCALE_TW:String = "tw";
      
      public static const LOCALE_PT:String = "pt";
      
      public static const LOCALE_ID:String = "id";
      
      public static const LOCALE_TH:String = "th";
      
      public static const LOCALE_VI:String = "vi";
      
      public static const COUNTRY_CODE_ALL:int = 0;
      
      public static const COUNTRY_CODE_JA:int = 1;
      
      public static const COUNTRY_CODE_US:int = 2;
       
      
      public function CommonConstants()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
      }
      
      public function write(param1:ByteArray) : void
      {
      }
   }
}
