package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class DeliverPointTableDef
   {
       
      
      public var id#2:int;
      
      public var gudePointMap:Object;
      
      public function DeliverPointTableDef()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:* = 0;
         var _loc3_:int = 0;
         id#2 = param1.readInt();
         _loc2_ = uint(param1.readShort());
         gudePointMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            gudePointMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(id#2);
         CompatibleDataIO.write(param1,gudePointMap,7);
      }
   }
}
