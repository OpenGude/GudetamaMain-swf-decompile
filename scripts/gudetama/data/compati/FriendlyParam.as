package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class FriendlyParam
   {
       
      
      public var index:int;
      
      public var max:int;
      
      public var rewards:Array;
      
      public function FriendlyParam()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         index = param1.readInt();
         max = param1.readInt();
         rewards = CompatibleDataIO.read(param1) as Array;
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(index);
         param1.writeInt(max);
         CompatibleDataIO.write(param1,rewards,1);
      }
   }
}
