package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class PurchasePresentItemDef
   {
       
      
      public var price:int;
      
      public var message:String;
      
      public var items:Array;
      
      public function PurchasePresentItemDef()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         price = param1.readInt();
         message = param1.readUTF();
         items = CompatibleDataIO.read(param1) as Array;
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(price);
         param1.writeUTF(message);
         CompatibleDataIO.write(param1,items,1);
      }
   }
}
