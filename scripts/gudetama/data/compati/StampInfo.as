package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class StampInfo
   {
       
      
      public var updateStamps:Array;
      
      public var removeStampIds:Array;
      
      public function StampInfo()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         updateStamps = CompatibleDataIO.read(param1) as Array;
         removeStampIds = CompatibleDataIO.read(param1) as Array;
      }
      
      public function write(param1:ByteArray) : void
      {
         CompatibleDataIO.write(param1,updateStamps,1);
         CompatibleDataIO.write(param1,removeStampIds,2);
      }
   }
}
