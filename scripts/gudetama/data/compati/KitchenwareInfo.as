package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class KitchenwareInfo
   {
       
      
      public var unavailableRecipeNoteIds:Array;
      
      public var unavailableGudetamaIds:Array;
      
      public function KitchenwareInfo(param1:Array = null, param2:Array = null)
      {
         super();
         unavailableRecipeNoteIds = param1;
         unavailableGudetamaIds = param2;
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         unavailableRecipeNoteIds = CompatibleDataIO.read(param1) as Array;
         unavailableGudetamaIds = CompatibleDataIO.read(param1) as Array;
      }
      
      public function write(param1:ByteArray) : void
      {
         CompatibleDataIO.write(param1,unavailableRecipeNoteIds,2);
         CompatibleDataIO.write(param1,unavailableGudetamaIds,2);
      }
   }
}
