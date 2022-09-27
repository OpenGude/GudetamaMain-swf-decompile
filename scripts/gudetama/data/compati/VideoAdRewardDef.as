package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class VideoAdRewardDef
   {
       
      
      public var items:Array;
      
      public function VideoAdRewardDef()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         items = CompatibleDataIO.read(param1) as Array;
      }
      
      public function write(param1:ByteArray) : void
      {
         CompatibleDataIO.write(param1,items,1);
      }
   }
}
