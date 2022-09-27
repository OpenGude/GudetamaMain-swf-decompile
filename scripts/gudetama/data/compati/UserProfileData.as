package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class UserProfileData
   {
      
      public static const FOLLOWSTATE_NONE:int = 0;
      
      public static const FOLLOWSTATE_FOLLOW:int = 1;
      
      public static const FOLLOWSTATE_FOLLOWER:int = 2;
      
      public static const FOLLOWSTATE_FOLLOW_MUTUAL:int = 3;
       
      
      public var encodedUid:int;
      
      public var playerName:String;
      
      public var playerRank:int;
      
      public var avatar:int;
      
      public var gender:int;
      
      public var area:int;
      
      public var comment:int;
      
      public var followState:int;
      
      public var followRequestSecs:int;
      
      public var snsProfileImage:ByteArray;
      
      public var lastActiveSec:int;
      
      public var snsId:String;
      
      public var snsType:int;
      
      public function UserProfileData()
      {
         super();
      }
      
      public function getComment() : int
      {
         if(comment >= 0)
         {
            return comment;
         }
         return 65536 + comment;
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         encodedUid = param1.readInt();
         playerName = param1.readUTF();
         playerRank = param1.readInt();
         avatar = param1.readInt();
         gender = param1.readInt();
         area = param1.readInt();
         comment = param1.readInt();
         followState = param1.readByte();
         followRequestSecs = param1.readInt();
         snsProfileImage = CompatibleDataIO.read(param1) as ByteArray;
         lastActiveSec = param1.readInt();
         snsId = param1.readUTF();
         snsType = param1.readByte();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(encodedUid);
         param1.writeUTF(playerName);
         param1.writeInt(playerRank);
         param1.writeInt(avatar);
         param1.writeInt(gender);
         param1.writeInt(area);
         param1.writeInt(comment);
         param1.writeByte(followState);
         param1.writeInt(followRequestSecs);
         CompatibleDataIO.write(param1,snsProfileImage,4);
         param1.writeInt(lastActiveSec);
         param1.writeUTF(snsId);
         param1.writeByte(snsType);
      }
   }
}
