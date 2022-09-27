package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class HomeStampSettingDef
   {
       
      
      public var id#2:int;
      
      public var animationName:String;
      
      public var slotName:String;
      
      public var attachmentName:String;
      
      public var loop:Boolean;
      
      public var touchSetting:SubHomeStampSettingDef;
      
      public var music:String;
      
      public var sound:String;
      
      public function HomeStampSettingDef()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         id#2 = param1.readInt();
         animationName = param1.readUTF();
         slotName = param1.readUTF();
         attachmentName = param1.readUTF();
         loop = param1.readBoolean();
         touchSetting = CompatibleDataIO.read(param1) as SubHomeStampSettingDef;
         music = param1.readUTF();
         sound = param1.readUTF();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(id#2);
         param1.writeUTF(animationName);
         param1.writeUTF(slotName);
         param1.writeUTF(attachmentName);
         param1.writeBoolean(loop);
         CompatibleDataIO.write(param1,touchSetting);
         param1.writeUTF(music);
         param1.writeUTF(sound);
      }
   }
}
