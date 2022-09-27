package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class DecorationInfo
   {
       
      
      public var updateDecorations:Array;
      
      public var removeDecorationIds:Array;
      
      public function DecorationInfo()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         updateDecorations = CompatibleDataIO.read(param1) as Array;
         removeDecorationIds = CompatibleDataIO.read(param1) as Array;
      }
      
      public function write(param1:ByteArray) : void
      {
         CompatibleDataIO.write(param1,updateDecorations,1);
         CompatibleDataIO.write(param1,removeDecorationIds,2);
      }
   }
}
