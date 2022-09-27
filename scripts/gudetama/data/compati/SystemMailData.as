package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class SystemMailData
   {
      
      public static const TYPE_PRESENT:int = 0;
      
      public static const TYPE_INFO:int = 1;
      
      public static const TYPE_PRESENT_TO_FRIEND:int = 2;
      
      public static const TYPE_DIALOG_MESSAGE:int = 10;
      
      public static const TYPE_DIALOG_WITH_PRESENT:int = 11;
      
      public static const TYPE_DIALOG_WITH_INFO:int = 12;
      
      public static const TYPE_DIALOG_SYSTEMINFO:int = 13;
      
      public static const TYPE_CHAT_OP_MESSAGE:int = 14;
      
      public static const TYPE_CHAT_OP_GUILD_MESSAGE:int = 15;
      
      public static const TYPE_DIALOG_BILLING_INFO:int = 16;
      
      public static const KIND_INFO:int = 0;
      
      public static const KIND_UPDATE:int = 1;
      
      public static const KIND_MAINTENANCE:int = 2;
      
      public static const KIND_BUG:int = 3;
      
      public static const MSG_PREFIX_USER_PRESENT:String = "#UP";
      
      public static const MAIL_KEEP_NOLIMIT:int = -1;
      
      public static const MAIL_KEEP_DEFAULT:int = 0;
       
      
      public var type:int;
      
      public var kind:int;
      
      public var senderEncodedUid:int;
      
      public var item:ItemParam;
      
      public var title:String;
      
      public var url#2:String;
      
      public var urlAndroid:String;
      
      public var alreadyRead:Boolean;
      
      public var noticeIconId:int;
      
      public var deleteSec:int;
      
      public var manualDeletion:Boolean;
      
      public var uniqueKey:int;
      
      public var message:String;
      
      public var receivedSecs:int;
      
      public function SystemMailData()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         type = param1.readByte();
         kind = param1.readByte();
         senderEncodedUid = param1.readInt();
         item = CompatibleDataIO.read(param1) as ItemParam;
         title = param1.readUTF();
         url#2 = param1.readUTF();
         urlAndroid = param1.readUTF();
         alreadyRead = param1.readBoolean();
         noticeIconId = param1.readInt();
         deleteSec = param1.readInt();
         manualDeletion = param1.readBoolean();
         uniqueKey = param1.readInt();
         message = param1.readUTF();
         receivedSecs = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeByte(type);
         param1.writeByte(kind);
         param1.writeInt(senderEncodedUid);
         CompatibleDataIO.write(param1,item);
         param1.writeUTF(title);
         param1.writeUTF(url#2);
         param1.writeUTF(urlAndroid);
         param1.writeBoolean(alreadyRead);
         param1.writeInt(noticeIconId);
         param1.writeInt(deleteSec);
         param1.writeBoolean(manualDeletion);
         param1.writeInt(uniqueKey);
         param1.writeUTF(message);
         param1.writeInt(receivedSecs);
      }
   }
}
