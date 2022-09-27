package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class SubHomeStampSettingDef
   {
       
      
      public var animationName:String;
      
      public var loop:Boolean;
      
      public var music:String;
      
      public var sound:String;
      
      public var voiceId:int;
      
      public function SubHomeStampSettingDef()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         animationName = param1.readUTF();
         loop = param1.readBoolean();
         music = param1.readUTF();
         sound = param1.readUTF();
         voiceId = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeUTF(animationName);
         param1.writeBoolean(loop);
         param1.writeUTF(music);
         param1.writeUTF(sound);
         param1.writeInt(voiceId);
      }
   }
}
