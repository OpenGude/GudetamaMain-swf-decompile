package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class LinkageDef
   {
       
      
      public var id#2:int;
      
      public var rsrc:int;
      
      public var title:String;
      
      public var name#2:String;
      
      public var linkTitle:String;
      
      public var linkMessage:String;
      
      public var linkUrl:Array;
      
      public var conditionDesc:String;
      
      public function LinkageDef()
      {
         super();
      }
      
      public function getUrl(param1:int) : String
      {
         if(!linkUrl)
         {
            return "";
         }
         var _loc2_:int = Math.min(param1,linkUrl.length - 1);
         return linkUrl[_loc2_];
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         id#2 = param1.readInt();
         rsrc = param1.readInt();
         title = param1.readUTF();
         name#2 = param1.readUTF();
         linkTitle = param1.readUTF();
         linkMessage = param1.readUTF();
         linkUrl = CompatibleDataIO.read(param1) as Array;
         conditionDesc = param1.readUTF();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(id#2);
         param1.writeInt(rsrc);
         param1.writeUTF(title);
         param1.writeUTF(name#2);
         param1.writeUTF(linkTitle);
         param1.writeUTF(linkMessage);
         CompatibleDataIO.write(param1,linkUrl,1);
         param1.writeUTF(conditionDesc);
      }
   }
}
