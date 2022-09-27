package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class CupGachaData
   {
      
      public static const SLOT_NUM:int = 4;
       
      
      public var cookIndex:int;
      
      public var cupGachaIds:Array;
      
      public var restSec:int;
      
      public var showAdNum:int;
      
      public function CupGachaData()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         cookIndex = param1.readByte();
         cupGachaIds = CompatibleDataIO.read(param1) as Array;
         restSec = param1.readInt();
         showAdNum = param1.readByte();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeByte(cookIndex);
         CompatibleDataIO.write(param1,cupGachaIds,2);
         param1.writeInt(restSec);
         param1.writeByte(showAdNum);
      }
   }
}
