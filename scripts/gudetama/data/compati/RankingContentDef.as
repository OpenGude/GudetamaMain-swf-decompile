package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class RankingContentDef
   {
       
      
      public var type:int;
      
      public var argi:int;
      
      public var rewardId:int;
      
      public var daily:Boolean;
      
      public var guild:Boolean;
      
      public var deliverTableId:int;
      
      public var deliverPtsPercentMap:Object;
      
      public function RankingContentDef()
      {
         super();
      }
      
      public function getDeliverPtsPercent(param1:int) : int
      {
         if(!deliverPtsPercentMap || !deliverPtsPercentMap[param1])
         {
            return 0;
         }
         return deliverPtsPercentMap[param1][0];
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:* = 0;
         var _loc3_:int = 0;
         type = param1.readInt();
         argi = param1.readInt();
         rewardId = param1.readInt();
         daily = param1.readBoolean();
         guild = param1.readBoolean();
         deliverTableId = param1.readInt();
         _loc2_ = uint(param1.readShort());
         deliverPtsPercentMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            deliverPtsPercentMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(type);
         param1.writeInt(argi);
         param1.writeInt(rewardId);
         param1.writeBoolean(daily);
         param1.writeBoolean(guild);
         param1.writeInt(deliverTableId);
         CompatibleDataIO.write(param1,deliverPtsPercentMap,7);
      }
   }
}
