package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class StaminaData
   {
      
      public static const STAMINA_MAX:int = 9999;
       
      
      public var currentValue:int;
      
      public var maxChargeableValue:int;
      
      public var nextChargeTimeRest:int;
      
      public function StaminaData()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         currentValue = param1.readShort();
         maxChargeableValue = param1.readShort();
         nextChargeTimeRest = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeShort(currentValue);
         param1.writeShort(maxChargeableValue);
         param1.writeInt(nextChargeTimeRest);
      }
   }
}
