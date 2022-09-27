package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class GetItemResult
   {
       
      
      public var item:ItemParam;
      
      public var param:Object;
      
      public var toMail:Boolean;
      
      public function GetItemResult()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         item = CompatibleDataIO.read(param1) as ItemParam;
         param = CompatibleDataIO.read(param1) as Object;
         toMail = param1.readBoolean();
      }
      
      public function write(param1:ByteArray) : void
      {
         CompatibleDataIO.write(param1,item);
         CompatibleDataIO.write(param1,param);
         param1.writeBoolean(toMail);
      }
   }
}
