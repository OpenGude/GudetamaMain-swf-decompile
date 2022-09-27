package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class LinearTable
   {
       
      
      public var offset:Number;
      
      public var rate:Number;
      
      public var indexOffset:int;
      
      public var indexes:Array;
      
      public var values:Array;
      
      public function LinearTable()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         offset = param1.readFloat();
         rate = param1.readFloat();
         indexOffset = param1.readInt();
         indexes = CompatibleDataIO.read(param1) as Array;
         values = CompatibleDataIO.read(param1) as Array;
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeFloat(offset);
         param1.writeFloat(rate);
         param1.writeInt(indexOffset);
         CompatibleDataIO.write(param1,indexes,2);
         CompatibleDataIO.write(param1,values,5);
      }
   }
}
