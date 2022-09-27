package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class DictDef
   {
       
      
      public var uitext:Object;
      
      public var message:Object;
      
      public var textplain:Object;
      
      public var others:Object;
      
      public var voice:Object;
      
      public var guide:Object;
      
      public var inviteRewardRobos:Array;
      
      public var guideLocalizeImages:Array;
      
      public var noticeLocalizeImages:Array;
      
      public var notice:Array;
      
      public var hintNum:int;
      
      public function DictDef()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:* = 0;
         var _loc3_:int = 0;
         _loc2_ = uint(param1.readShort());
         uitext = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            uitext[param1.readUTF()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         message = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            message[param1.readUTF()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         textplain = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            textplain[param1.readUTF()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         others = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            others[param1.readUTF()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         voice = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            voice[param1.readUTF()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         guide = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            guide[param1.readUTF()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         inviteRewardRobos = CompatibleDataIO.read(param1) as Array;
         guideLocalizeImages = CompatibleDataIO.read(param1) as Array;
         noticeLocalizeImages = CompatibleDataIO.read(param1) as Array;
         notice = CompatibleDataIO.read(param1) as Array;
         hintNum = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         CompatibleDataIO.write(param1,uitext,8);
         CompatibleDataIO.write(param1,message,8);
         CompatibleDataIO.write(param1,textplain,8);
         CompatibleDataIO.write(param1,others,8);
         CompatibleDataIO.write(param1,voice,8);
         CompatibleDataIO.write(param1,guide,8);
         CompatibleDataIO.write(param1,inviteRewardRobos,2);
         CompatibleDataIO.write(param1,guideLocalizeImages,2);
         CompatibleDataIO.write(param1,noticeLocalizeImages,2);
         CompatibleDataIO.write(param1,notice,1);
         param1.writeInt(hintNum);
      }
   }
}
