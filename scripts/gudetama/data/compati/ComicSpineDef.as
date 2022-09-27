package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class ComicSpineDef
   {
       
      
      public var id#2:int;
      
      public var spainMap:Object;
      
      public var spainAnimeMap:Object;
      
      public var spainScaleMap:Object;
      
      public var spainDelayMap:Object;
      
      public function ComicSpineDef()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:* = 0;
         var _loc3_:int = 0;
         id#2 = param1.readInt();
         _loc2_ = uint(param1.readShort());
         spainMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            spainMap[param1.readUTF()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         spainAnimeMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            spainAnimeMap[param1.readUTF()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         spainScaleMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            spainScaleMap[param1.readUTF()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         spainDelayMap = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            spainDelayMap[param1.readUTF()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(id#2);
         CompatibleDataIO.write(param1,spainMap,8);
         CompatibleDataIO.write(param1,spainAnimeMap,8);
         CompatibleDataIO.write(param1,spainScaleMap,8);
         CompatibleDataIO.write(param1,spainDelayMap,8);
      }
   }
}
