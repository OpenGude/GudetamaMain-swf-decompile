package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class ScreeningDef
   {
      
      public static const FLAG_TEXTURE_TRACE_ENABLED:int = 0;
      
      public static const FLAG_FOR_APPLE_REVIEW:int = 1;
      
      public static const FLAG_DECORATION_ENABLED:int = 2;
      
      public static const FLAG_CANCEL_LOADING_DISABLED:int = 3;
      
      public static const FLAG_CHECK_OS_PUSH:int = 4;
      
      public static const FLAG_CHECK_INIT_BANNER:int = 5;
      
      public static const FLAG_FIRST_PART_DL:int = 6;
      
      public static const FLAG_NOTICE_PREMIUM:int = 7;
      
      public static const FLAG_PRESENT_WITHOUT_TERM:int = 8;
      
      public static const FLAG_CONVERT_GACHA_ITEM:int = 9;
      
      public static const FLAG_COLLECT_GACHA_TICKET:int = 10;
      
      public static const FLAG_DISABLE_SELECT_LOCALE:int = 11;
      
      public static const FLAG_CUP_GACHA_ENABLE:int = 12;
      
      public static const FLAG_CUP_GACHA_RATE_ENABLE:int = 13;
      
      public static const FLAG_HOMEDECO_ENABLE:int = 14;
      
      public static const FLAG_HOMEHELPER_ENABLE:int = 15;
       
      
      public var flags:ByteArray;
      
      public function ScreeningDef()
      {
         super();
      }
      
      public function getFlagValue(param1:int) : int
      {
         if(flags.length <= param1)
         {
            return 0;
         }
         return flags[param1];
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         flags = CompatibleDataIO.read(param1) as ByteArray;
      }
      
      public function write(param1:ByteArray) : void
      {
         CompatibleDataIO.write(param1,flags,4);
      }
   }
}
