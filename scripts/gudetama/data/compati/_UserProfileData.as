package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class _UserProfileData
   {
      
      public static const FOLLOWSTATE_NONE:int = 0;
      
      public static const FOLLOWSTATE_FOLLOW:int = 1;
      
      public static const FOLLOWSTATE_FOLLOWER:int = 2;
      
      public static const FOLLOWSTATE_FOLLOW_MUTUAL:int = 3;
      
      public static const CANCEL_FOLLOW:int = 4;
      
      public static const REJECT_FOLLOWER:int = 5;
       
      
      public var encodedUid:int;
      
      public var playerName:String;
      
      public var job:int;
      
      public var comment:String;
      
      public var lastPlaySecs:int;
      
      public var followRequestSecs:int;
      
      public var leaderBookId:int;
      
      public var deckBookIds:Array;
      
      public var leaderBookLevel:int;
      
      public var highestRatingGenreIndex:int;
      
      public var followState:int;
      
      public var playerRanks:Array;
      
      public var numPenddings:int;
      
      public var deckLevel:int;
      
      public var deckHp:int;
      
      public var deckAtk:int;
      
      public var deckDef:int;
      
      public var deckMnd:int;
      
      public var guildID:int;
      
      public var guildPosition:int;
      
      public var guildDropoutSecs:int;
      
      public var guildPoint:int;
      
      public var guildName:String;
      
      public var guildIconInfo:int;
      
      public var gender:int;
      
      public var quizRating:int;
      
      public var friendBoardDisclosure:int;
      
      public var accumulatedQPoint:int;
      
      public var monthlyQPoint:int;
      
      public function _UserProfileData()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         encodedUid = param1.readInt();
         playerName = param1.readUTF();
         job = param1.readInt();
         comment = param1.readUTF();
         lastPlaySecs = param1.readInt();
         followRequestSecs = param1.readInt();
         leaderBookId = param1.readInt();
         deckBookIds = CompatibleDataIO.read(param1) as Array;
         leaderBookLevel = param1.readShort();
         highestRatingGenreIndex = param1.readInt();
         followState = param1.readByte();
         playerRanks = CompatibleDataIO.read(param1) as Array;
         numPenddings = param1.readShort();
         deckLevel = param1.readShort();
         deckHp = param1.readShort();
         deckAtk = param1.readShort();
         deckDef = param1.readShort();
         deckMnd = param1.readShort();
         guildID = param1.readInt();
         guildPosition = param1.readInt();
         guildDropoutSecs = param1.readInt();
         guildPoint = param1.readInt();
         guildName = param1.readUTF();
         guildIconInfo = param1.readInt();
         gender = param1.readInt();
         quizRating = param1.readInt();
         friendBoardDisclosure = param1.readByte();
         accumulatedQPoint = param1.readInt();
         monthlyQPoint = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(encodedUid);
         param1.writeUTF(playerName);
         param1.writeInt(job);
         param1.writeUTF(comment);
         param1.writeInt(lastPlaySecs);
         param1.writeInt(followRequestSecs);
         param1.writeInt(leaderBookId);
         CompatibleDataIO.write(param1,deckBookIds,2);
         param1.writeShort(leaderBookLevel);
         param1.writeInt(highestRatingGenreIndex);
         param1.writeByte(followState);
         CompatibleDataIO.write(param1,playerRanks,3);
         param1.writeShort(numPenddings);
         param1.writeShort(deckLevel);
         param1.writeShort(deckHp);
         param1.writeShort(deckAtk);
         param1.writeShort(deckDef);
         param1.writeShort(deckMnd);
         param1.writeInt(guildID);
         param1.writeInt(guildPosition);
         param1.writeInt(guildDropoutSecs);
         param1.writeInt(guildPoint);
         param1.writeUTF(guildName);
         param1.writeInt(guildIconInfo);
         param1.writeInt(gender);
         param1.writeInt(quizRating);
         param1.writeByte(friendBoardDisclosure);
         param1.writeInt(accumulatedQPoint);
         param1.writeInt(monthlyQPoint);
      }
   }
}
