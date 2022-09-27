package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class MetalShopDef
   {
      
      public static const TYPE_MONEY:int = 1;
      
      public static const TYPE_METAL:int = 2;
      
      public static const TYPE_SETITEM:int = 3;
       
      
      public var id#2:int;
      
      public var name#2:String;
      
      public var items:Array;
      
      public function MetalShopDef()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         id#2 = param1.readInt();
         name#2 = param1.readUTF();
         items = CompatibleDataIO.read(param1) as Array;
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(id#2);
         param1.writeUTF(name#2);
         CompatibleDataIO.write(param1,items,1);
      }
   }
}
