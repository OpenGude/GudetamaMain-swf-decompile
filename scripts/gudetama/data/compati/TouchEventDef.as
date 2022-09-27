package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class TouchEventDef
   {
      
      public static const TAGMASK_NONE:int = 0;
      
      public static const TAGMASK_VOICE:int = 256;
      
      public static const TAGMASK_ITEM0:int = 512;
      
      public static const TAGMASK_ITEM1:int = 1024;
      
      public static const TAGMASK_HEAVEN:int = 2048;
      
      public static const EVENT_GUDETAMA:int = 0;
      
      public static const EVENT_VOICE:int = 257;
      
      public static const EVENT_REMOTE:int = 770;
      
      public static const EVENT_PHONE:int = 771;
      
      public static const EVENT_SAUCE:int = 772;
      
      public static const EVENT_SOY_SAUCE:int = 773;
      
      public static const EVENT_SOY_SAUCE_FISH:int = 1286;
      
      public static const EVENT_SOY_SAUCE_FISH_GOLD:int = 1287;
      
      public static const EVENT_HEAVEN:int = 2312;
      
      public static const VOICE_RANDOM:int = 0;
      
      public static const VOICE_GUDETAMA_0:int = -1;
      
      public static const VOICE_GUDETAMA_1:int = -2;
       
      
      public var voice:int;
      
      public function TouchEventDef()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         voice = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(voice);
      }
   }
}
