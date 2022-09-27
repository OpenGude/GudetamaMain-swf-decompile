package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class RankingRewardItemDef
   {
       
      
      public var sortedIndex:int;
      
      public var last:Boolean;
      
      public var argi:int;
      
      public var screeningItems:Array;
      
      public function RankingRewardItemDef()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         sortedIndex = param1.readInt();
         last = param1.readBoolean();
         argi = param1.readInt();
         screeningItems = CompatibleDataIO.read(param1) as Array;
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(sortedIndex);
         param1.writeBoolean(last);
         param1.writeInt(argi);
         CompatibleDataIO.write(param1,screeningItems,1);
      }
   }
}
