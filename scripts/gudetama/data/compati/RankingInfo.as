package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class RankingInfo
   {
       
      
      public var contentIndex:int;
      
      public var type:int;
      
      public var contentTitle:String;
      
      public var argi:int;
      
      public var showOnly:Boolean;
      
      public var guild:Boolean;
      
      public var desc:String;
      
      public var myPoint:int;
      
      public var myRoughPlace:int;
      
      public var topRecords:Array;
      
      public var rewardId:int;
      
      public var rewardPlaceAndPoint:Array;
      
      public var topRecordSizeMax:int;
      
      public var totalPoint:int;
      
      public function RankingInfo()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         contentIndex = param1.readInt();
         type = param1.readInt();
         contentTitle = param1.readUTF();
         argi = param1.readInt();
         showOnly = param1.readBoolean();
         guild = param1.readBoolean();
         desc = param1.readUTF();
         myPoint = param1.readInt();
         myRoughPlace = param1.readInt();
         topRecords = CompatibleDataIO.read(param1) as Array;
         rewardId = param1.readInt();
         rewardPlaceAndPoint = CompatibleDataIO.read(param1) as Array;
         topRecordSizeMax = param1.readInt();
         totalPoint = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(contentIndex);
         param1.writeInt(type);
         param1.writeUTF(contentTitle);
         param1.writeInt(argi);
         param1.writeBoolean(showOnly);
         param1.writeBoolean(guild);
         param1.writeUTF(desc);
         param1.writeInt(myPoint);
         param1.writeInt(myRoughPlace);
         CompatibleDataIO.write(param1,topRecords,1);
         param1.writeInt(rewardId);
         CompatibleDataIO.write(param1,rewardPlaceAndPoint,1);
         param1.writeInt(topRecordSizeMax);
         param1.writeInt(totalPoint);
      }
   }
}
