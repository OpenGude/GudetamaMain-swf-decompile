package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class RankingDef
   {
      
      public static const TYPE_DELIVER:int = 5;
      
      public static const GROUP_NONE:int = 0;
      
      public static const GROUP_AREA:int = 1;
       
      
      public var id#2:int;
      
      public var title:String;
      
      public var desc:String;
      
      public var storyComicId:int;
      
      public var howtoComicId:int;
      
      public var content:Array;
      
      public var groupType:int;
      
      public var groupIdIndexMap:Object;
      
      public var hasDefaultGroupContent:Boolean;
      
      public var rankTextColor:int;
      
      public var pointTextColor:int;
      
      public var balloonTextColor:int;
      
      public var rewardTextColor:int;
      
      public var rankingTitleTextColor:int;
      
      public var topRecordMatColor:int;
      
      public var rankingRewardMatColor:int;
      
      public var pointRewardMatColor:int;
      
      public var levelRewardMatColor:int;
      
      public var topRecordBgMatColor:int;
      
      public var rankingRewardBgMatColor:int;
      
      public var pointRewardBgMatColor:int;
      
      public var levelRewardBgMatColor:int;
      
      public var recordMatColor:int;
      
      public var rankingRewardLineColor:int;
      
      public var pointRewardLineColor:int;
      
      public var levelRewardLineColor:int;
      
      public function RankingDef()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:* = 0;
         var _loc3_:int = 0;
         id#2 = param1.readInt();
         title = param1.readUTF();
         desc = param1.readUTF();
         storyComicId = param1.readInt();
         howtoComicId = param1.readInt();
         content = CompatibleDataIO.read(param1) as Array;
         groupType = param1.readInt();
         _loc2_ = uint(param1.readShort());
         groupIdIndexMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            groupIdIndexMap[param1.readInt()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         hasDefaultGroupContent = param1.readBoolean();
         rankTextColor = param1.readInt();
         pointTextColor = param1.readInt();
         balloonTextColor = param1.readInt();
         rewardTextColor = param1.readInt();
         rankingTitleTextColor = param1.readInt();
         topRecordMatColor = param1.readInt();
         rankingRewardMatColor = param1.readInt();
         pointRewardMatColor = param1.readInt();
         levelRewardMatColor = param1.readInt();
         topRecordBgMatColor = param1.readInt();
         rankingRewardBgMatColor = param1.readInt();
         pointRewardBgMatColor = param1.readInt();
         levelRewardBgMatColor = param1.readInt();
         recordMatColor = param1.readInt();
         rankingRewardLineColor = param1.readInt();
         pointRewardLineColor = param1.readInt();
         levelRewardLineColor = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(id#2);
         param1.writeUTF(title);
         param1.writeUTF(desc);
         param1.writeInt(storyComicId);
         param1.writeInt(howtoComicId);
         CompatibleDataIO.write(param1,content,1);
         param1.writeInt(groupType);
         CompatibleDataIO.write(param1,groupIdIndexMap,7);
         param1.writeBoolean(hasDefaultGroupContent);
         param1.writeInt(rankTextColor);
         param1.writeInt(pointTextColor);
         param1.writeInt(balloonTextColor);
         param1.writeInt(rewardTextColor);
         param1.writeInt(rankingTitleTextColor);
         param1.writeInt(topRecordMatColor);
         param1.writeInt(rankingRewardMatColor);
         param1.writeInt(pointRewardMatColor);
         param1.writeInt(levelRewardMatColor);
         param1.writeInt(topRecordBgMatColor);
         param1.writeInt(rankingRewardBgMatColor);
         param1.writeInt(pointRewardBgMatColor);
         param1.writeInt(levelRewardBgMatColor);
         param1.writeInt(recordMatColor);
         param1.writeInt(rankingRewardLineColor);
         param1.writeInt(pointRewardLineColor);
         param1.writeInt(levelRewardLineColor);
      }
   }
}
