package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class GuideTalkParagraphParam
   {
       
      
      public var sentences:Array;
      
      public function GuideTalkParagraphParam()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         sentences = CompatibleDataIO.read(param1) as Array;
      }
      
      public function write(param1:ByteArray) : void
      {
         CompatibleDataIO.write(param1,sentences,1);
      }
   }
}
