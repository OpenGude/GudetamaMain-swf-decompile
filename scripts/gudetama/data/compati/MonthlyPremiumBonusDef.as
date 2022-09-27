package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class MonthlyPremiumBonusDef
   {
       
      
      public var id#2:int;
      
      public var validDays:int;
      
      public var item:MetalShopItemDef;
      
      public var bonusItems:Array;
      
      public function MonthlyPremiumBonusDef()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         id#2 = param1.readShort();
         validDays = param1.readShort();
         item = CompatibleDataIO.read(param1) as MetalShopItemDef;
         bonusItems = CompatibleDataIO.read(param1) as Array;
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeShort(id#2);
         param1.writeShort(validDays);
         CompatibleDataIO.write(param1,item);
         CompatibleDataIO.write(param1,bonusItems,1);
      }
   }
}
