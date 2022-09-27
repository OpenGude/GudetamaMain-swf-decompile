package gudetama.data
{
   import flash.utils.IDataInput;
   import flash.utils.IDataOutput;
   import flash.utils.IExternalizable;
   
   public class LocalSentMailData implements IExternalizable
   {
      
      private static const VERSION:uint = 0;
       
      
      public var destinationEncodedUid:int;
      
      public var destinationPlayerName:String;
      
      public var message:String;
      
      public var sentTime:Number;
      
      public var receivedMailUKey:int;
      
      public function LocalSentMailData()
      {
         super();
      }
      
      public function setMailData(param1:int, param2:String, param3:String, param4:int) : void
      {
         destinationEncodedUid = param1;
         destinationPlayerName = param2;
         message = param3;
         receivedMailUKey = param4;
      }
      
      public function writeExternal(param1:IDataOutput) : void
      {
         param1.writeByte(0);
         param1.writeInt(destinationEncodedUid);
         param1.writeUTF(destinationPlayerName);
         param1.writeUTF(message);
         param1.writeDouble(sentTime);
         param1.writeInt(receivedMailUKey);
      }
      
      public function readExternal(param1:IDataInput) : void
      {
         var _loc2_:uint = param1.readByte();
         destinationEncodedUid = param1.readInt();
         destinationPlayerName = param1.readUTF();
         message = param1.readUTF();
         sentTime = param1.readDouble();
         receivedMailUKey = param1.readInt();
      }
   }
}
