package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class IdentifiedPresentDef
   {
       
      
      public var id#2:int;
      
      public var limit:int;
      
      public var url#2:String;
      
      public function IdentifiedPresentDef()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         id#2 = param1.readInt();
         limit = param1.readInt();
         url#2 = param1.readUTF();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(id#2);
         param1.writeInt(limit);
         param1.writeUTF(url#2);
      }
   }
}
