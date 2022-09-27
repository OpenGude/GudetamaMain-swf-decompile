package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class QuestionParam
   {
       
      
      public var choice:String;
      
      public var message:String;
      
      public var messageVoiceId:int;
      
      public function QuestionParam()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         choice = param1.readUTF();
         message = param1.readUTF();
         messageVoiceId = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeUTF(choice);
         param1.writeUTF(message);
         param1.writeInt(messageVoiceId);
      }
   }
}
