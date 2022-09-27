package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class FileInfoDef
   {
       
      
      public var path:String;
      
      public var size:int;
      
      public var hash:int;
      
      public var hasLocale:Boolean;
      
      public function FileInfoDef()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         path = param1.readUTF();
         size = param1.readInt();
         hash = param1.readInt();
         hasLocale = param1.readBoolean();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeUTF(path);
         param1.writeInt(size);
         param1.writeInt(hash);
         param1.writeBoolean(hasLocale);
      }
   }
}
