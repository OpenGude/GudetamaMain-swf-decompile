package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class AbilityParam
   {
      
      public static const KIND_HEAVEN:int = 0;
      
      public static const KIND_TOUCH:int = 1;
      
      public static const KIND_ROULETTE_SPEED:int = 2;
      
      public static const KIND_SUCCESS_PROB:int = 3;
      
      public static const KIND_HAPPENING_PROB:int = 4;
      
      public static const KIND_VOICE_PROB:int = 5;
      
      public static const KIND_HIDDEN_PROB:int = 6;
      
      public static const KIND_HURRY:int = 7;
      
      public static const KIND_GET_PTS_COOK:int = 8;
      
      public static const KIND_REVIVAL_HELPCHARA:int = 9;
      
      public static const FLAGMASK_TOUCH_INFO:int = 256;
      
      public static const FLAGMASK_UNIQUE:int = 512;
      
      public static const FLAGMASK_OVERWRITE:int = 1024;
      
      public static const TYPE_HEAVEN:int = 256;
      
      public static const TYPE_TOUCH:int = 257;
      
      public static const TYPE_ROULETTE_SPEED:int = 2;
      
      public static const TYPE_SUCCESS_PROB:int = 515;
      
      public static const TYPE_HAPPENING_PROB:int = 516;
      
      public static const TYPE_VOICE_PROB:int = 261;
      
      public static const TYPE_HIDDEN_PROB:int = 6;
      
      public static const TYPE_HURRY:int = 7;
      
      public static const TYPE_GET_PTS_COOK:int = 1032;
      
      public static const TYPE_REVIVAL_HELPCHARA:int = 521;
       
      
      public var type:int;
      
      public var values:Array;
      
      public var secs:int;
      
      public function AbilityParam()
      {
         super();
      }
      
      public function existsFlags(param1:int) : Boolean
      {
         return (type & param1) != 0;
      }
      
      public function equalsKind(param1:int) : Boolean
      {
         return (type & 255) == param1;
      }
      
      public function getValue(param1:int) : int
      {
         if(param1 >= values.length)
         {
            return 0;
         }
         return values[param1];
      }
      
      public function getKind() : int
      {
         return type & 255;
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         type = param1.readInt();
         values = CompatibleDataIO.read(param1) as Array;
         secs = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(type);
         CompatibleDataIO.write(param1,values,2);
         param1.writeInt(secs);
      }
   }
}
