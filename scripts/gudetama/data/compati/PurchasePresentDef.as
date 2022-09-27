package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class PurchasePresentDef
   {
       
      
      public var id#2:int;
      
      public var presents:Array;
      
      public var message:String;
      
      public function PurchasePresentDef()
      {
         super();
      }
      
      public function getItem(param1:int) : PurchasePresentItemDef
      {
         var _loc3_:* = null;
         for each(var _loc2_ in presents)
         {
            if(_loc2_.price == param1)
            {
               return _loc2_;
            }
            if(_loc2_.price == 0)
            {
               _loc3_ = _loc2_;
            }
         }
         return _loc3_;
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         id#2 = param1.readInt();
         presents = CompatibleDataIO.read(param1) as Array;
         message = param1.readUTF();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(id#2);
         CompatibleDataIO.write(param1,presents,1);
         param1.writeUTF(message);
      }
   }
}
