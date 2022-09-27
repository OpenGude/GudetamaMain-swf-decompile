package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class UserAssistData
   {
       
      
      public var num:int;
      
      public function UserAssistData()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         num = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(num);
      }
   }
}
