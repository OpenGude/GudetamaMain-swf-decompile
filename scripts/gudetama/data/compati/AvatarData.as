package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class AvatarData
   {
       
      
      public var id#2:int;
      
      public var acquired:Boolean;
      
      public var available:Boolean;
      
      public function AvatarData()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         id#2 = param1.readInt();
         acquired = param1.readBoolean();
         available = param1.readBoolean();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(id#2);
         param1.writeBoolean(acquired);
         param1.writeBoolean(available);
      }
   }
}
