package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class QuestionDef
   {
      
      public static const POSITIVE:int = 0;
      
      public static const NEGATIVE:int = 1;
       
      
      public var id#2:int;
      
      public var question:String;
      
      public var questionVoiceId:int;
      
      public var params#2:Array;
      
      public function QuestionDef()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         id#2 = param1.readInt();
         question = param1.readUTF();
         questionVoiceId = param1.readInt();
         params#2 = CompatibleDataIO.read(param1) as Array;
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(id#2);
         param1.writeUTF(question);
         param1.writeInt(questionVoiceId);
         CompatibleDataIO.write(param1,params#2,1);
      }
   }
}
