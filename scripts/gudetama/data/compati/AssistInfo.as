package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class AssistInfo
   {
       
      
      public var aid:Number;
      
      public var encodedUid:int;
      
      public var playerName:String;
      
      public var playerRank:int;
      
      public var kitchenwareType:int;
      
      public var gudetamaId:int;
      
      public var finishTimeSecs:int;
      
      public var usefulId:int;
      
      public var assistTimeSecs:int;
      
      public var avatar:int;
      
      public var snsProfileImage:ByteArray;
      
      public var snsType:int;
      
      public function AssistInfo()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         aid = param1.readDouble();
         encodedUid = param1.readInt();
         playerName = param1.readUTF();
         playerRank = param1.readInt();
         kitchenwareType = param1.readInt();
         gudetamaId = param1.readInt();
         finishTimeSecs = param1.readInt();
         usefulId = param1.readInt();
         assistTimeSecs = param1.readInt();
         avatar = param1.readInt();
         snsProfileImage = CompatibleDataIO.read(param1) as ByteArray;
         snsType = param1.readByte();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeDouble(aid);
         param1.writeInt(encodedUid);
         param1.writeUTF(playerName);
         param1.writeInt(playerRank);
         param1.writeInt(kitchenwareType);
         param1.writeInt(gudetamaId);
         param1.writeInt(finishTimeSecs);
         param1.writeInt(usefulId);
         param1.writeInt(assistTimeSecs);
         param1.writeInt(avatar);
         CompatibleDataIO.write(param1,snsProfileImage,4);
         param1.writeByte(snsType);
      }
   }
}
