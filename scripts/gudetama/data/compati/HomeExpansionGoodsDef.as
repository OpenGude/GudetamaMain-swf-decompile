package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class HomeExpansionGoodsDef
   {
       
      
      public var id#2:int;
      
      public var price:ItemParam;
      
      public function HomeExpansionGoodsDef()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         id#2 = param1.readShort();
         price = CompatibleDataIO.read(param1) as ItemParam;
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeShort(id#2);
         CompatibleDataIO.write(param1,price);
      }
   }
}
