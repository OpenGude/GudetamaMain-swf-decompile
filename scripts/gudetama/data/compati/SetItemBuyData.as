package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class SetItemBuyData
   {
       
      
      public var count:int;
      
      public function SetItemBuyData()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         count = param1.readShort();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeShort(count);
      }
   }
}
