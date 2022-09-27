package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class GachaResult
   {
       
      
      public var userGachaData:UserGachaData;
      
      public var items:Array;
      
      public var params#2:Array;
      
      public var convertedItems:Array;
      
      public var rarities:Array;
      
      public var worthFlags:Array;
      
      public var onceMore:Boolean;
      
      public var useItem:ItemParam;
      
      public function GachaResult()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         userGachaData = CompatibleDataIO.read(param1) as UserGachaData;
         items = CompatibleDataIO.read(param1) as Array;
         params#2 = CompatibleDataIO.read(param1) as Array;
         convertedItems = CompatibleDataIO.read(param1) as Array;
         rarities = CompatibleDataIO.read(param1) as Array;
         worthFlags = CompatibleDataIO.read(param1) as Array;
         onceMore = param1.readBoolean();
         useItem = CompatibleDataIO.read(param1) as ItemParam;
      }
      
      public function write(param1:ByteArray) : void
      {
         CompatibleDataIO.write(param1,userGachaData);
         CompatibleDataIO.write(param1,items,1);
         CompatibleDataIO.write(param1,params#2,1);
         CompatibleDataIO.write(param1,convertedItems,1);
         CompatibleDataIO.write(param1,rarities,2);
         CompatibleDataIO.write(param1,worthFlags,2);
         param1.writeBoolean(onceMore);
         CompatibleDataIO.write(param1,useItem);
      }
   }
}
