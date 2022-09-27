package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class InitDictDef
   {
       
      
      public var others:Object;
      
      public var uitext:Object;
      
      public function InitDictDef()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:* = 0;
         var _loc3_:int = 0;
         _loc2_ = uint(param1.readShort());
         others = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            others[param1.readUTF()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
         _loc2_ = uint(param1.readShort());
         uitext = {};
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            uitext[param1.readUTF()] = CompatibleDataIO.read(param1);
            _loc3_++;
         }
      }
      
      public function write(param1:ByteArray) : void
      {
         CompatibleDataIO.write(param1,others,8);
         CompatibleDataIO.write(param1,uitext,8);
      }
   }
}
