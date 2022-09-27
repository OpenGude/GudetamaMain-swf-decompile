package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class GuideTalkSentenceParam
   {
       
      
      public var word:Boolean;
      
      public var event:int;
      
      public var paramInt:int;
      
      public var paramStr:String;
      
      public var waitTime:Number;
      
      public var forceTime:Number;
      
      public var nextWordsConnect:Boolean;
      
      public var forceWordsFinish:Boolean;
      
      public function GuideTalkSentenceParam()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         word = param1.readBoolean();
         event = param1.readByte();
         paramInt = param1.readInt();
         paramStr = param1.readUTF();
         waitTime = param1.readFloat();
         forceTime = param1.readFloat();
         nextWordsConnect = param1.readBoolean();
         forceWordsFinish = param1.readBoolean();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeBoolean(word);
         param1.writeByte(event);
         param1.writeInt(paramInt);
         param1.writeUTF(paramStr);
         param1.writeFloat(waitTime);
         param1.writeFloat(forceTime);
         param1.writeBoolean(nextWordsConnect);
         param1.writeBoolean(forceWordsFinish);
      }
   }
}
