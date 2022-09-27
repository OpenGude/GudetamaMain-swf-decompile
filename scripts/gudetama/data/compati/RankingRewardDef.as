package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class RankingRewardDef
   {
       
      
      public var id#2:int;
      
      public var rewardIdTable:LinearTable;
      
      public var rankingRewards:Array;
      
      public var pointRewards:Array;
      
      public var globalRewards:Array;
      
      public function RankingRewardDef()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         id#2 = param1.readInt();
         rewardIdTable = CompatibleDataIO.read(param1) as LinearTable;
         rankingRewards = CompatibleDataIO.read(param1) as Array;
         pointRewards = CompatibleDataIO.read(param1) as Array;
         globalRewards = CompatibleDataIO.read(param1) as Array;
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(id#2);
         CompatibleDataIO.write(param1,rewardIdTable);
         CompatibleDataIO.write(param1,rankingRewards,1);
         CompatibleDataIO.write(param1,pointRewards,1);
         CompatibleDataIO.write(param1,globalRewards,1);
      }
   }
}
