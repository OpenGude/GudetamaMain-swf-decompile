package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class ScreeningGachaItemParam
   {
       
      
      public var item:ItemParam;
      
      public var newFlag:Boolean;
      
      public var pickupFlag:Boolean;
      
      public var rate:int;
      
      public function ScreeningGachaItemParam()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         item = CompatibleDataIO.read(param1) as ItemParam;
         newFlag = param1.readBoolean();
         pickupFlag = param1.readBoolean();
         rate = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         CompatibleDataIO.write(param1,item);
         param1.writeBoolean(newFlag);
         param1.writeBoolean(pickupFlag);
         param1.writeInt(rate);
      }
   }
}
