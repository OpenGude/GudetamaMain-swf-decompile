package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class SetItemAlternativeParam
   {
       
      
      public var rsrc:int;
      
      public var items:Array;
      
      public function SetItemAlternativeParam()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         rsrc = param1.readInt();
         items = CompatibleDataIO.read(param1) as Array;
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(rsrc);
         CompatibleDataIO.write(param1,items,1);
      }
   }
}
