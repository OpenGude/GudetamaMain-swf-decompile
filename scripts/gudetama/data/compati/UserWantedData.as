package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class UserWantedData
   {
       
      
      public var id#2:int;
      
      public var updateTime:int;
      
      public function UserWantedData()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         id#2 = param1.readInt();
         updateTime = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(id#2);
         param1.writeInt(updateTime);
      }
   }
}
