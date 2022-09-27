package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class MailPresentResult
   {
       
      
      public var items:Array;
      
      public var params#2:Array;
      
      public function MailPresentResult()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         items = CompatibleDataIO.read(param1) as Array;
         params#2 = CompatibleDataIO.read(param1) as Array;
      }
      
      public function write(param1:ByteArray) : void
      {
         CompatibleDataIO.write(param1,items,1);
         CompatibleDataIO.write(param1,params#2,1);
      }
   }
}
