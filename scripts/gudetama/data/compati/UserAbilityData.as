package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class UserAbilityData
   {
       
      
      public var ability:AbilityParam;
      
      public var restTimeSecs:int;
      
      public function UserAbilityData()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         ability = CompatibleDataIO.read(param1) as AbilityParam;
         restTimeSecs = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         CompatibleDataIO.write(param1,ability);
         param1.writeInt(restTimeSecs);
      }
   }
}
