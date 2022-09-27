package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class VoiceParam
   {
       
      
      public var resources:Array;
      
      public var names:Array;
      
      public var delays:Array;
      
      public var positions:Array;
      
      public var offsets:Array;
      
      public function VoiceParam()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         resources = CompatibleDataIO.read(param1) as Array;
         names = CompatibleDataIO.read(param1) as Array;
         delays = CompatibleDataIO.read(param1) as Array;
         positions = CompatibleDataIO.read(param1) as Array;
         offsets = CompatibleDataIO.read(param1) as Array;
      }
      
      public function write(param1:ByteArray) : void
      {
         CompatibleDataIO.write(param1,resources,2);
         CompatibleDataIO.write(param1,names,1);
         CompatibleDataIO.write(param1,delays,2);
         CompatibleDataIO.write(param1,positions,2);
         CompatibleDataIO.write(param1,offsets,1);
      }
   }
}
