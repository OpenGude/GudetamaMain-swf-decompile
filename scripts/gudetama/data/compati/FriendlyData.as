package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class FriendlyData
   {
       
      
      public var encodedUid:int;
      
      public var friendly:int;
      
      public var friendlyLevel:int;
      
      public function FriendlyData()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         encodedUid = param1.readInt();
         friendly = param1.readInt();
         friendlyLevel = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(encodedUid);
         param1.writeInt(friendly);
         param1.writeInt(friendlyLevel);
      }
   }
}
