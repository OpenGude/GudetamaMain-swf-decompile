package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class TouchEventParam
   {
       
      
      public var touchNum:int;
      
      public var event:int;
      
      public var voice:int;
      
      public var paramByte:int;
      
      public function TouchEventParam()
      {
         super();
      }
      
      public function isPlayVoice() : Boolean
      {
         return (event & 256) != 0;
      }
      
      public function isDropItem() : Boolean
      {
         return (event & 512) != 0 || (event & 1024) != 0;
      }
      
      public function isHeaven() : Boolean
      {
         return (event & 2048) != 0;
      }
      
      public function getTouchIndex() : int
      {
         return event & 255;
      }
      
      public function toString() : String
      {
         return touchNum + "," + event + "," + voice + "," + paramByte;
      }
      
      public function isPlayRamdomVoice() : Boolean
      {
         return voice == 0;
      }
      
      public function isDropItem0() : Boolean
      {
         return (event & 512) != 0;
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         touchNum = param1.readInt();
         event = param1.readInt();
         voice = param1.readInt();
         paramByte = param1.readByte();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(touchNum);
         param1.writeInt(event);
         param1.writeInt(voice);
         param1.writeByte(paramByte);
      }
   }
}
