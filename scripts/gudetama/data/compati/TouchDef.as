package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class TouchDef
   {
       
      
      public var voiceEvents:Array;
      
      public var itemEvents:Array;
      
      public var randomVoiceIds:Array;
      
      public function TouchDef()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         voiceEvents = CompatibleDataIO.read(param1) as Array;
         itemEvents = CompatibleDataIO.read(param1) as Array;
         randomVoiceIds = CompatibleDataIO.read(param1) as Array;
      }
      
      public function write(param1:ByteArray) : void
      {
         CompatibleDataIO.write(param1,voiceEvents,1);
         CompatibleDataIO.write(param1,itemEvents,1);
         CompatibleDataIO.write(param1,randomVoiceIds,1);
      }
   }
}
