package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class FirstLoginInfo
   {
       
      
      public var name#2:String;
      
      public var gender:int;
      
      public var area:int;
      
      public var timeZone#2:String;
      
      public var locale:String;
      
      public var deckIndex:int;
      
      public var comment:int;
      
      public var avatar:int;
      
      public function FirstLoginInfo()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         name#2 = param1.readUTF();
         gender = param1.readInt();
         area = param1.readInt();
         timeZone#2 = param1.readUTF();
         locale = param1.readUTF();
         deckIndex = param1.readInt();
         comment = param1.readInt();
         avatar = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeUTF(name#2);
         param1.writeInt(gender);
         param1.writeInt(area);
         param1.writeUTF(timeZone#2);
         param1.writeUTF(locale);
         param1.writeInt(deckIndex);
         param1.writeInt(comment);
         param1.writeInt(avatar);
      }
   }
}
