package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class ARExpansionGoodsDef
   {
      
      public static const TYPE_PLACE_GUDETAMA:int = 0;
      
      public static const TYPE_PLACE_STAMP:int = 1;
      
      public static const GUDETAMA_OFFSET:int = 10;
      
      public static const STAMP_OFFSET:int = 100;
       
      
      public var id#2:int;
      
      public var type:int;
      
      public var price:ItemParam;
      
      public function ARExpansionGoodsDef()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         id#2 = param1.readShort();
         type = param1.readShort();
         price = CompatibleDataIO.read(param1) as ItemParam;
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeShort(id#2);
         param1.writeShort(type);
         CompatibleDataIO.write(param1,price);
      }
   }
}
