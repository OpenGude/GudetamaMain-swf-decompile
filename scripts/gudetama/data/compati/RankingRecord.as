package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class RankingRecord
   {
       
      
      public var point:int;
      
      public var encodeUid:int;
      
      public var playerName:String;
      
      public var avatar:int;
      
      public var snsType:int;
      
      public var snsProfileImage:ByteArray;
      
      public function RankingRecord()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         point = param1.readInt();
         encodeUid = param1.readInt();
         playerName = param1.readUTF();
         avatar = param1.readInt();
         snsType = param1.readInt();
         snsProfileImage = CompatibleDataIO.read(param1) as ByteArray;
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(point);
         param1.writeInt(encodeUid);
         param1.writeUTF(playerName);
         param1.writeInt(avatar);
         param1.writeInt(snsType);
         CompatibleDataIO.write(param1,snsProfileImage,4);
      }
   }
}
