package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class FriendInfo
   {
       
      
      public var friendlyData:FriendlyData;
      
      public var wantedGudetamas:Array;
      
      public var friendPresentLogDiff:Array;
      
      public var lastFriendlyLevel:int;
      
      public function FriendInfo()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         friendlyData = CompatibleDataIO.read(param1) as FriendlyData;
         wantedGudetamas = CompatibleDataIO.read(param1) as Array;
         friendPresentLogDiff = CompatibleDataIO.read(param1) as Array;
         lastFriendlyLevel = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         CompatibleDataIO.write(param1,friendlyData);
         CompatibleDataIO.write(param1,wantedGudetamas,1);
         CompatibleDataIO.write(param1,friendPresentLogDiff,1);
         param1.writeInt(lastFriendlyLevel);
      }
   }
}
