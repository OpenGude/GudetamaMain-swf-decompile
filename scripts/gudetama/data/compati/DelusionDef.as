package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class DelusionDef
   {
       
      
      public var param:Array;
      
      public function DelusionDef()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         param = CompatibleDataIO.read(param1) as Array;
      }
      
      public function write(param1:ByteArray) : void
      {
         CompatibleDataIO.write(param1,param,1);
      }
   }
}
