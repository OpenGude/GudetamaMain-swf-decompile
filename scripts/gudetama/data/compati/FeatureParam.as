package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class FeatureParam
   {
       
      
      public var type:int;
      
      public var value:int;
      
      public function FeatureParam()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         type = param1.readInt();
         value = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(type);
         param1.writeInt(value);
      }
   }
}
