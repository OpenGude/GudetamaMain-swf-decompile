package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class UserPresentMoneyData
   {
       
      
      public var pid:Number;
      
      public var encodedUid:int;
      
      public var playerName:String;
      
      public var playerRank:int;
      
      public var money:int;
      
      public var presentTimeSecs:int;
      
      public var avatar:int;
      
      public var snsProfileImage:ByteArray;
      
      public var snsType:int;
      
      public function UserPresentMoneyData()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         pid = param1.readDouble();
         encodedUid = param1.readInt();
         playerName = param1.readUTF();
         playerRank = param1.readInt();
         money = param1.readInt();
         presentTimeSecs = param1.readInt();
         avatar = param1.readInt();
         snsProfileImage = CompatibleDataIO.read(param1) as ByteArray;
         snsType = param1.readByte();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeDouble(pid);
         param1.writeInt(encodedUid);
         param1.writeUTF(playerName);
         param1.writeInt(playerRank);
         param1.writeInt(money);
         param1.writeInt(presentTimeSecs);
         param1.writeInt(avatar);
         CompatibleDataIO.write(param1,snsProfileImage,4);
         param1.writeByte(snsType);
      }
   }
}
