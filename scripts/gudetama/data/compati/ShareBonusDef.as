package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class ShareBonusDef
   {
       
      
      public var id#2:int;
      
      public var item:ItemParam;
      
      public var message:String;
      
      public var alternativeMessage:String;
      
      public function ShareBonusDef()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         id#2 = param1.readInt();
         item = CompatibleDataIO.read(param1) as ItemParam;
         message = param1.readUTF();
         alternativeMessage = param1.readUTF();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(id#2);
         CompatibleDataIO.write(param1,item);
         param1.writeUTF(message);
         param1.writeUTF(alternativeMessage);
      }
   }
}
