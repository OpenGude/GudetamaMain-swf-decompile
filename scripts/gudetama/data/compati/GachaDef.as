package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class GachaDef
   {
      
      public static const RARITY_COMMON:int = 0;
      
      public static const RARITY_UNCOMMON:int = 1;
      
      public static const RARITY_RARE:int = 2;
       
      
      public var id#2:int;
      
      public var rsrc:int;
      
      public var sortIndex:int;
      
      public var name#2:String;
      
      public var desc:String;
      
      public var lineupDesc:String;
      
      public var prices:Array;
      
      public var numFree:int;
      
      public var numOnceMore:int;
      
      public var screeningItems:Array;
      
      public var ratesAtKind:Array;
      
      public var hasRareStamp:Boolean;
      
      public var gachaLineupPrioritizedKinds:Array;
      
      public function GachaDef()
      {
         super();
      }
      
      public function getRateAtKind(param1:int) : int
      {
         if(!ratesAtKind || param1 >= ratesAtKind.length)
         {
            return 0;
         }
         return ratesAtKind[param1];
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         id#2 = param1.readInt();
         rsrc = param1.readInt();
         sortIndex = param1.readInt();
         name#2 = param1.readUTF();
         desc = param1.readUTF();
         lineupDesc = param1.readUTF();
         prices = CompatibleDataIO.read(param1) as Array;
         numFree = param1.readInt();
         numOnceMore = param1.readInt();
         screeningItems = CompatibleDataIO.read(param1) as Array;
         ratesAtKind = CompatibleDataIO.read(param1) as Array;
         hasRareStamp = param1.readBoolean();
         gachaLineupPrioritizedKinds = CompatibleDataIO.read(param1) as Array;
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(id#2);
         param1.writeInt(rsrc);
         param1.writeInt(sortIndex);
         param1.writeUTF(name#2);
         param1.writeUTF(desc);
         param1.writeUTF(lineupDesc);
         CompatibleDataIO.write(param1,prices,1);
         param1.writeInt(numFree);
         param1.writeInt(numOnceMore);
         CompatibleDataIO.write(param1,screeningItems,1);
         CompatibleDataIO.write(param1,ratesAtKind,2);
         param1.writeBoolean(hasRareStamp);
         CompatibleDataIO.write(param1,gachaLineupPrioritizedKinds,2);
      }
   }
}
