package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class UserGachaData
   {
       
      
      public var id#2:int;
      
      public var playCount:int;
      
      public var prices:Array;
      
      public var onceMorePlayCount:int;
      
      public var freePlayCount:int;
      
      public function UserGachaData()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         id#2 = param1.readInt();
         playCount = param1.readInt();
         prices = CompatibleDataIO.read(param1) as Array;
         onceMorePlayCount = param1.readByte();
         freePlayCount = param1.readByte();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(id#2);
         param1.writeInt(playCount);
         CompatibleDataIO.write(param1,prices,1);
         param1.writeByte(onceMorePlayCount);
         param1.writeByte(freePlayCount);
      }
   }
}
