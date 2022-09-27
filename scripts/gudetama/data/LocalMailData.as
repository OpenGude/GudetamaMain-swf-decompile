package gudetama.data
{
   import flash.utils.IDataInput;
   import flash.utils.IDataOutput;
   import flash.utils.IExternalizable;
   
   public class LocalMailData implements IExternalizable
   {
      
      private static const VERSION:uint = 0;
       
      
      public var uniqueKey:int;
      
      public var sender:int;
      
      public var playerName:String;
      
      public var message:String;
      
      public var receivedTime:Number;
      
      public var alreadyReturn:Boolean = false;
      
      public function LocalMailData()
      {
         super();
      }
      
      public function setMailData(param1:int, param2:int, param3:String, param4:String, param5:Number) : void
      {
         uniqueKey = param1;
         sender = param2;
         playerName = param3;
         message = param4;
         receivedTime = param5;
      }
      
      public function send() : void
      {
         alreadyReturn = true;
      }
      
      public function writeExternal(param1:IDataOutput) : void
      {
         param1.writeByte(0);
         param1.writeInt(uniqueKey);
         param1.writeInt(sender);
         param1.writeUTF(playerName);
         param1.writeUTF(message);
         param1.writeDouble(receivedTime);
         param1.writeBoolean(alreadyReturn);
      }
      
      public function readExternal(param1:IDataInput) : void
      {
         var _loc2_:uint = param1.readByte();
         uniqueKey = param1.readInt();
         sender = param1.readInt();
         playerName = param1.readUTF();
         message = param1.readUTF();
         receivedTime = param1.readDouble();
         alreadyReturn = param1.readBoolean();
      }
   }
}
