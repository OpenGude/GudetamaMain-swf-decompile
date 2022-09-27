package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class HelperCharaDef
   {
      
      public static const IDLE:String = "idle_loop";
      
      public static const TOUCH:String = "animation";
       
      
      public var id#2:int;
      
      public var rsrc:int;
      
      public var showRate:int;
      
      public var massages:Object;
      
      public var massagePosIndex:Object;
      
      public var voices:Object;
      
      public var fixHelperPosX:int;
      
      public function HelperCharaDef()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:* = 0;
         var _loc3_:int = 0;
         id#2 = param1.readInt();
         rsrc = param1.readInt();
         showRate = param1.readInt();
         _loc2_ = uint(param1.readShort());
         massages = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            massages[param1.readUTF()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         massagePosIndex = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            massagePosIndex[param1.readUTF()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         voices = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            voices[param1.readUTF()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         fixHelperPosX = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(id#2);
         param1.writeInt(rsrc);
         param1.writeInt(showRate);
         CompatibleDataIO.write(param1,massages,8);
         CompatibleDataIO.write(param1,massagePosIndex,8);
         CompatibleDataIO.write(param1,voices,8);
         param1.writeInt(fixHelperPosX);
      }
   }
}
