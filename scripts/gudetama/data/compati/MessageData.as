package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class MessageData
   {
      
      public static const TYPE_UNKNOWN:int = 0;
      
      public static const TYPE_UNKNOWNS:int = 1;
      
      public static const TYPE_SOMEONE:int = 2;
      
      public static const TYPE_SOMEPEOPLE:int = 3;
      
      public static const TYPE_FRIEND:int = 4;
      
      public static const TYPE_FRIENDS:int = 5;
      
      public static const TYPE_CHANNEL_MEMBERS:int = 9;
      
      public static const TYPE_GUILD_MEMBERS:int = 11;
      
      public static const TYPE_IMPORTANT_SOMEPEOPLE:int = 15;
      
      public static const TYPE_BROADCAST:int = 17;
      
      public static const TYPE_IMPORTANT_BROADCAST:int = 19;
      
      public static const TYPE_HALT_SOMEPEOPLE:int = 20;
      
      public static const TYPE_HALT_BROADCAST:int = 21;
      
      public static const TYPE_ALL:int = 66;
      
      public static const OPERATOR_ID:int = 0;
       
      
      public var messageVersion:int;
      
      public var seq:Array;
      
      public var type:int;
      
      public var bookId:int;
      
      public var groupId:int;
      
      public var receivers:Array;
      
      public var receiverNames:Array;
      
      public var sender:int;
      
      public var senderName:String;
      
      public var uniqueKey:int;
      
      public var message:String;
      
      public var receivedSecs:int;
      
      public function MessageData()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         messageVersion = param1.readShort();
         seq = CompatibleDataIO.read(param1) as Array;
         type = param1.readByte();
         bookId = param1.readShort();
         groupId = param1.readInt();
         receivers = CompatibleDataIO.read(param1) as Array;
         receiverNames = CompatibleDataIO.read(param1) as Array;
         sender = param1.readInt();
         senderName = param1.readUTF();
         uniqueKey = param1.readInt();
         message = param1.readUTF();
         receivedSecs = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeShort(messageVersion);
         CompatibleDataIO.write(param1,seq,3);
         param1.writeByte(type);
         param1.writeShort(bookId);
         param1.writeInt(groupId);
         CompatibleDataIO.write(param1,receivers,2);
         CompatibleDataIO.write(param1,receiverNames,1);
         param1.writeInt(sender);
         param1.writeUTF(senderName);
         param1.writeInt(uniqueKey);
         param1.writeUTF(message);
         param1.writeInt(receivedSecs);
      }
   }
}
