package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class QuestionInfo
   {
       
      
      public var encodedUid:int;
      
      public var avatar:int;
      
      public var friendName:String;
      
      public var questionId:int;
      
      public var choiceIndex:int;
      
      public var snsProfileImage:ByteArray;
      
      public var snsType:int;
      
      public function QuestionInfo()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         encodedUid = param1.readInt();
         avatar = param1.readInt();
         friendName = param1.readUTF();
         questionId = param1.readInt();
         choiceIndex = param1.readInt();
         snsProfileImage = CompatibleDataIO.read(param1) as ByteArray;
         snsType = param1.readByte();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(encodedUid);
         param1.writeInt(avatar);
         param1.writeUTF(friendName);
         param1.writeInt(questionId);
         param1.writeInt(choiceIndex);
         CompatibleDataIO.write(param1,snsProfileImage,4);
         param1.writeByte(snsType);
      }
   }
}
