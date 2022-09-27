package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class FeatureDef
   {
      
      public static const TYPE_COLLECTION:int = 0;
      
      public static const TYPE_AR:int = 1;
      
      public static const TYPE_MANUAL_STOP:int = 2;
      
      public static const TYPE_OVEN:int = 3;
      
      public static const TYPE_PLACE:int = 4;
      
      public static const TYPE_RARE_VOICE:int = 5;
      
      public static const TYPE_DELUSION:int = 6;
      
      public static const TYPE_ROULETTE_SPEED:int = 7;
      
      public static const TYPE_MISSION:int = 8;
      
      public static const TYPE_USEFUL:int = 9;
      
      public static const TYPE_GACHA:int = 10;
      
      public static const TYPE_MISSION_DAILY:int = 11;
      
      public static const TYPE_FRIEND:int = 12;
      
      public static const TYPE_SNS_ICON:int = 13;
      
      public static const TYPE_ROOM_DECO:int = 14;
      
      public static const TYPE_CUP_GACHA:int = 15;
      
      public static const TYPE_HOME_DECO:int = 16;
       
      
      public var paramMap:Object;
      
      public function FeatureDef()
      {
         super();
      }
      
      public function exists(param1:int) : Boolean
      {
         return paramMap[param1];
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:* = 0;
         var _loc3_:int = 0;
         _loc2_ = uint(param1.readShort());
         paramMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            paramMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
      }
      
      public function write(param1:ByteArray) : void
      {
         CompatibleDataIO.write(param1,paramMap,7);
      }
   }
}
