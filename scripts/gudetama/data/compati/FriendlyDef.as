package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class FriendlyDef
   {
       
      
      public var params#2:Array;
      
      public var heartBorders:Array;
      
      public function FriendlyDef()
      {
         super();
      }
      
      public function getParam(param1:int) : FriendlyParam
      {
         if(param1 >= params#2.length)
         {
            return null;
         }
         return params#2[param1];
      }
      
      public function getLastParam() : FriendlyParam
      {
         return params#2[params#2.length - 1];
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         params#2 = CompatibleDataIO.read(param1) as Array;
         heartBorders = CompatibleDataIO.read(param1) as Array;
      }
      
      public function write(param1:ByteArray) : void
      {
         CompatibleDataIO.write(param1,params#2,1);
         CompatibleDataIO.write(param1,heartBorders,2);
      }
   }
}
