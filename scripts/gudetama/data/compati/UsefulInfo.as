package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class UsefulInfo
   {
       
      
      public var updateUsefuls:Array;
      
      public var removeUsefulIds:Array;
      
      public function UsefulInfo()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         updateUsefuls = CompatibleDataIO.read(param1) as Array;
         removeUsefulIds = CompatibleDataIO.read(param1) as Array;
      }
      
      public function write(param1:ByteArray) : void
      {
         CompatibleDataIO.write(param1,updateUsefuls,1);
         CompatibleDataIO.write(param1,removeUsefulIds,2);
      }
   }
}
