package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class UtensilInfo
   {
       
      
      public var updateUtensils:Array;
      
      public var removeUtensilIds:Array;
      
      public function UtensilInfo()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         updateUtensils = CompatibleDataIO.read(param1) as Array;
         removeUtensilIds = CompatibleDataIO.read(param1) as Array;
      }
      
      public function write(param1:ByteArray) : void
      {
         CompatibleDataIO.write(param1,updateUtensils,1);
         CompatibleDataIO.write(param1,removeUtensilIds,2);
      }
   }
}
