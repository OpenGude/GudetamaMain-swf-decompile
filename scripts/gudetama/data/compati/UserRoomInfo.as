package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class UserRoomInfo
   {
       
      
      public var placedGudetamaId:int;
      
      public var questionId:int;
      
      public var kitchenwareMap:Object;
      
      public var friendlyData:FriendlyData;
      
      public var lastFriendlyLevel:int;
      
      public var friendPresentMoneyParam:Array;
      
      public var assistData:UserAssistData;
      
      public var decorationId:int;
      
      public var homeDecoDataList:Array;
      
      public function UserRoomInfo()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:* = 0;
         var _loc3_:int = 0;
         placedGudetamaId = param1.readInt();
         questionId = param1.readInt();
         _loc2_ = uint(param1.readShort());
         kitchenwareMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            kitchenwareMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         friendlyData = CompatibleDataIO.read(param1) as FriendlyData;
         lastFriendlyLevel = param1.readInt();
         friendPresentMoneyParam = CompatibleDataIO.read(param1) as Array;
         assistData = CompatibleDataIO.read(param1) as UserAssistData;
         decorationId = param1.readInt();
         _loc2_ = uint(param1.readShort());
         homeDecoDataList = new Array(_loc2_);
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            homeDecoDataList[_loc3_] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(placedGudetamaId);
         param1.writeInt(questionId);
         CompatibleDataIO.write(param1,kitchenwareMap,7);
         CompatibleDataIO.write(param1,friendlyData);
         param1.writeInt(lastFriendlyLevel);
         CompatibleDataIO.write(param1,friendPresentMoneyParam,2);
         CompatibleDataIO.write(param1,assistData);
         param1.writeInt(decorationId);
         CompatibleDataIO.write(param1,homeDecoDataList,9);
      }
   }
}
