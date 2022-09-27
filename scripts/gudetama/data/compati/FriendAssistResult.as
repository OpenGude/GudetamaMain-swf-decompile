package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class FriendAssistResult
   {
       
      
      public var userRoomInfo:UserRoomInfo;
      
      public var lastFriendly:int;
      
      public var addFriendly:int;
      
      public var lastFriendlyLevel:int;
      
      public function FriendAssistResult()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         userRoomInfo = CompatibleDataIO.read(param1) as UserRoomInfo;
         lastFriendly = param1.readInt();
         addFriendly = param1.readInt();
         lastFriendlyLevel = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         CompatibleDataIO.write(param1,userRoomInfo);
         param1.writeInt(lastFriendly);
         param1.writeInt(addFriendly);
         param1.writeInt(lastFriendlyLevel);
      }
   }
}
