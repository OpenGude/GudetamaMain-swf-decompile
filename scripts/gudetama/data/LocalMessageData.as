package gudetama.data
{
   import flash.utils.ByteArray;
   import flash.utils.IDataInput;
   import flash.utils.IDataOutput;
   import flash.utils.IExternalizable;
   import gudetama.data.compati.CompatibleDataIO;
   import gudetama.data.compati.MessageData;
   import gudetama.util.TimeZoneUtil;
   
   public class LocalMessageData implements IExternalizable
   {
      
      private static const VERSION:int = 3;
       
      
      public var messageVersion:int;
      
      public var seq:Array;
      
      public var sender:int;
      
      public var senderName:String;
      
      public var type:int;
      
      public var message:String;
      
      public var receivedSecs:int;
      
      public var bookId:int;
      
      public var groupId:int;
      
      public var receivers:Array;
      
      public var receiverNames:Array;
      
      public function LocalMessageData(param1:MessageData = null)
      {
         super();
         if(param1)
         {
            setMessageData(param1);
         }
      }
      
      public function setMessageData(param1:MessageData) : void
      {
         messageVersion = param1.messageVersion;
         seq = param1.seq;
         sender = param1.sender;
         senderName = param1.senderName;
         type = param1.type;
         message = param1.message;
         receivedSecs = param1.receivedSecs;
         bookId = param1.bookId;
         groupId = param1.groupId;
         receivers = param1.receivers;
         receiverNames = param1.receiverNames;
      }
      
      public function checkTargetId(param1:int) : Boolean
      {
         if(type == 11 || type == 9)
         {
            return param1 == groupId;
         }
         if(type == 4)
         {
            return param1 == sender;
         }
         return false;
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeShort(3);
         CompatibleDataIO.write(param1,seq,3);
         param1.writeInt(sender);
         param1.writeUTF(senderName);
         param1.writeInt(bookId);
         param1.writeByte(type & 255);
         param1.writeUTF(message);
         param1.writeInt(receivedSecs);
         param1.writeInt(groupId);
         CompatibleDataIO.write(param1,receivers,2);
         CompatibleDataIO.write(param1,receiverNames,1);
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         messageVersion = param1.readShort();
         seq = CompatibleDataIO.read(param1) as Array;
         sender = param1.readInt();
         senderName = param1.readUTF();
         if(messageVersion >= 1)
         {
            bookId = param1.readInt();
         }
         else
         {
            bookId = 0;
         }
         type = param1.readByte() & 255;
         message = param1.readUTF();
         receivedSecs = param1.readInt();
         if(messageVersion >= 2)
         {
            groupId = param1.readInt();
            receivers = CompatibleDataIO.read(param1) as Array;
            receiverNames = CompatibleDataIO.read(param1) as Array;
         }
      }
      
      public function writeExternal(param1:IDataOutput) : void
      {
         param1.writeShort(3);
         var _loc2_:int = !!seq ? seq.length : 0;
         param1.writeByte(_loc2_);
         for each(var _loc3_ in seq)
         {
            param1.writeShort(_loc3_);
         }
         param1.writeInt(sender);
         param1.writeUTF(senderName);
         param1.writeShort(bookId);
         param1.writeByte(type & 255);
         param1.writeUTF(message);
         param1.writeInt(receivedSecs);
         param1.writeInt(groupId);
      }
      
      public function readExternal(param1:IDataInput) : void
      {
         var _loc3_:int = 0;
         messageVersion = param1.readShort();
         var _loc2_:int = param1.readByte();
         seq = new Array(_loc2_);
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            seq[_loc3_] = param1.readShort();
            _loc3_++;
         }
         sender = param1.readInt();
         senderName = param1.readUTF();
         if(messageVersion >= 1)
         {
            bookId = param1.readShort();
         }
         else
         {
            bookId = 0;
         }
         type = param1.readByte() & 255;
         message = param1.readUTF();
         receivedSecs = param1.readInt();
         if(messageVersion >= 3)
         {
            groupId = param1.readInt();
         }
      }
      
      public function toString() : String
      {
         return "" + seq + " " + TimeZoneUtil.getDateTime(receivedSecs) + " from:" + senderName + ", to=" + receiverNames + ", msg:" + message + ", type:" + type + ", group:" + groupId;
      }
   }
}
