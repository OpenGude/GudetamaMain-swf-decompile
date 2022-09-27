package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class PresentLogData
   {
       
      
      public var encodedUid:int;
      
      public var playerRank:int;
      
      public var playerName:String;
      
      public var avatar:int;
      
      public var itemId:int;
      
      public var itemNum:int;
      
      public var time:int;
      
      public var snsProfileImage:ByteArray;
      
      public var snsType:int;
      
      public function PresentLogData()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         encodedUid = param1.readInt();
         playerRank = param1.readInt();
         playerName = param1.readUTF();
         avatar = param1.readInt();
         itemId = param1.readInt();
         itemNum = param1.readInt();
         time = param1.readInt();
         snsProfileImage = CompatibleDataIO.read(param1) as ByteArray;
         snsType = param1.readByte();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(encodedUid);
         param1.writeInt(playerRank);
         param1.writeUTF(playerName);
         param1.writeInt(avatar);
         param1.writeInt(itemId);
         param1.writeInt(itemNum);
         param1.writeInt(time);
         CompatibleDataIO.write(param1,snsProfileImage,4);
         param1.writeByte(snsType);
      }
   }
}
