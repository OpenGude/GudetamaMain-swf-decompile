package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class StampData
   {
      
      public static const STAMP_MAX:int = 99999;
       
      
      public var id#2:int;
      
      public var num:int;
      
      public var available:Boolean;
      
      public function StampData(param1:int = 0)
      {
         super();
         id#2 = param1;
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         id#2 = param1.readInt();
         num = param1.readInt();
         available = param1.readBoolean();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(id#2);
         param1.writeInt(num);
         param1.writeBoolean(available);
      }
   }
}
