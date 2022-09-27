package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class SetItemDef
   {
      
      public static const VIEW_NONE:int = 0;
      
      public static const VIEW_SHOP_USEFUL:int = 1;
       
      
      public var id#2:int;
      
      public var viewType:int;
      
      public var items:Array;
      
      public var startTimeSec:int;
      
      public var endTimeSec:int;
      
      public var chargeItem:MetalShopItemDef;
      
      public var buyableCount:int;
      
      public var rsrc:int;
      
      public var alternativeParam:SetItemAlternativeParam;
      
      public function SetItemDef()
      {
         super();
      }
      
      public function inTerm(param1:int) : Boolean
      {
         if(param1 < startTimeSec)
         {
            return false;
         }
         return endTimeSec == 0 || param1 < endTimeSec;
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         id#2 = param1.readInt();
         viewType = param1.readByte();
         items = CompatibleDataIO.read(param1) as Array;
         startTimeSec = param1.readInt();
         endTimeSec = param1.readInt();
         chargeItem = CompatibleDataIO.read(param1) as MetalShopItemDef;
         buyableCount = param1.readShort();
         rsrc = param1.readInt();
         alternativeParam = CompatibleDataIO.read(param1) as SetItemAlternativeParam;
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(id#2);
         param1.writeByte(viewType);
         CompatibleDataIO.write(param1,items,1);
         param1.writeInt(startTimeSec);
         param1.writeInt(endTimeSec);
         CompatibleDataIO.write(param1,chargeItem);
         param1.writeShort(buyableCount);
         param1.writeInt(rsrc);
         CompatibleDataIO.write(param1,alternativeParam);
      }
   }
}
