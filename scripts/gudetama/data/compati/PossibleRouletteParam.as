package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class PossibleRouletteParam
   {
       
      
      public var type:int;
      
      public var percent:int;
      
      public function PossibleRouletteParam()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         type = param1.readByte();
         percent = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeByte(type);
         param1.writeInt(percent);
      }
   }
}
