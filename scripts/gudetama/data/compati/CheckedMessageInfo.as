package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class CheckedMessageInfo
   {
       
      
      public var seq:Array;
      
      public var type:int;
      
      public var target:int;
      
      public function CheckedMessageInfo(param1:Array = null, param2:int = 0, param3:int = 0)
      {
         super();
         seq = param1;
         type = param2;
         target = param3;
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         seq = CompatibleDataIO.read(param1) as Array;
         type = param1.readInt();
         target = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         CompatibleDataIO.write(param1,seq,3);
         param1.writeInt(type);
         param1.writeInt(target);
      }
   }
}
