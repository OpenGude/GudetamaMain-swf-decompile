package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class GachaPriceDef
   {
       
      
      public var num:int;
      
      public var prices:Array;
      
      public var numDaily:int;
      
      public var enabledCollect:Boolean;
      
      public function GachaPriceDef()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         num = param1.readInt();
         prices = CompatibleDataIO.read(param1) as Array;
         numDaily = param1.readInt();
         enabledCollect = param1.readBoolean();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(num);
         CompatibleDataIO.write(param1,prices,1);
         param1.writeInt(numDaily);
         param1.writeBoolean(enabledCollect);
      }
   }
}
