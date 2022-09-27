package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class FriendPresentResult
   {
       
      
      public var friendlyData:FriendlyData;
      
      public var consumedGudetama:GudetamaData;
      
      public var lastFriendly:int;
      
      public var addFriendly:int;
      
      public var friendPresentLogDiff:Array;
      
      public var lastFriendlyLevel:int;
      
      public var deliveredEventIds:Array;
      
      public function FriendPresentResult()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         friendlyData = CompatibleDataIO.read(param1) as FriendlyData;
         consumedGudetama = CompatibleDataIO.read(param1) as GudetamaData;
         lastFriendly = param1.readInt();
         addFriendly = param1.readInt();
         friendPresentLogDiff = CompatibleDataIO.read(param1) as Array;
         lastFriendlyLevel = param1.readInt();
         deliveredEventIds = CompatibleDataIO.read(param1) as Array;
      }
      
      public function write(param1:ByteArray) : void
      {
         CompatibleDataIO.write(param1,friendlyData);
         CompatibleDataIO.write(param1,consumedGudetama);
         param1.writeInt(lastFriendly);
         param1.writeInt(addFriendly);
         CompatibleDataIO.write(param1,friendPresentLogDiff,1);
         param1.writeInt(lastFriendlyLevel);
         CompatibleDataIO.write(param1,deliveredEventIds,2);
      }
   }
}
