package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class EventData
   {
       
      
      public var id#2:int;
      
      public var endRestTimeSecs:int;
      
      public var background:String;
      
      public var buttonImage:String;
      
      public var title:String;
      
      public var message:String;
      
      public var url#2:String;
      
      public var decorationId:int;
      
      public var endTallyRestTimeSecs:int;
      
      public var rankingId:int;
      
      public var noticeIconRsrc:int;
      
      public var gudetamaIds:Array;
      
      public var chBGM:Array;
      
      public var rentalDecorations:Array;
      
      public var noticeTextKey:String;
      
      public var attendable:Boolean;
      
      public function EventData()
      {
         super();
      }
      
      public function isRankingEvent() : Boolean
      {
         return rankingId > 0;
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         id#2 = param1.readInt();
         endRestTimeSecs = param1.readInt();
         background = param1.readUTF();
         buttonImage = param1.readUTF();
         title = param1.readUTF();
         message = param1.readUTF();
         url#2 = param1.readUTF();
         decorationId = param1.readInt();
         endTallyRestTimeSecs = param1.readInt();
         rankingId = param1.readInt();
         noticeIconRsrc = param1.readInt();
         gudetamaIds = CompatibleDataIO.read(param1) as Array;
         chBGM = CompatibleDataIO.read(param1) as Array;
         rentalDecorations = CompatibleDataIO.read(param1) as Array;
         noticeTextKey = param1.readUTF();
         attendable = param1.readBoolean();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(id#2);
         param1.writeInt(endRestTimeSecs);
         param1.writeUTF(background);
         param1.writeUTF(buttonImage);
         param1.writeUTF(title);
         param1.writeUTF(message);
         param1.writeUTF(url#2);
         param1.writeInt(decorationId);
         param1.writeInt(endTallyRestTimeSecs);
         param1.writeInt(rankingId);
         param1.writeInt(noticeIconRsrc);
         CompatibleDataIO.write(param1,gudetamaIds,2);
         CompatibleDataIO.write(param1,chBGM,1);
         CompatibleDataIO.write(param1,rentalDecorations,2);
         param1.writeUTF(noticeTextKey);
         param1.writeBoolean(attendable);
      }
   }
}
