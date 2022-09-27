package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class MetalShopItemDef
   {
      
      public static const TYPE_WIN:int = 1;
      
      public static const TYPE_IOS:int = 2;
      
      public static const TYPE_ANDROID:int = 4;
      
      public static const TYPE_ONESTORE:int = 8;
      
      public static const TYPE_ALL:int = 15;
       
      
      public var key:int;
      
      public var rsrc:int;
      
      public var value:int;
      
      public var bonus:int;
      
      public var campaign:int;
      
      public var price:int;
      
      public var product_id:String;
      
      public var items:Array;
      
      public var limit:int;
      
      public var overlap:MetalShopItemDef;
      
      public var ranklimit:int;
      
      public var applimit:int;
      
      public var info:int;
      
      public function MetalShopItemDef()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         key = param1.readInt();
         rsrc = param1.readByte();
         value = param1.readInt();
         bonus = param1.readInt();
         campaign = param1.readInt();
         price = param1.readInt();
         product_id = param1.readUTF();
         items = CompatibleDataIO.read(param1) as Array;
         limit = param1.readInt();
         overlap = CompatibleDataIO.read(param1) as MetalShopItemDef;
         ranklimit = param1.readInt();
         applimit = param1.readInt();
         info = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(key);
         param1.writeByte(rsrc);
         param1.writeInt(value);
         param1.writeInt(bonus);
         param1.writeInt(campaign);
         param1.writeInt(price);
         param1.writeUTF(product_id);
         CompatibleDataIO.write(param1,items,1);
         param1.writeInt(limit);
         CompatibleDataIO.write(param1,overlap);
         param1.writeInt(ranklimit);
         param1.writeInt(applimit);
         param1.writeInt(info);
      }
   }
}
