package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class DelusionParam
   {
       
      
      public var pastMinutes:int;
      
      public function DelusionParam()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         pastMinutes = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(pastMinutes);
      }
   }
}
