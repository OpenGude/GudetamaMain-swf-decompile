package com.hurlant.crypto.symmetric
{
   import com.hurlant.crypto.prng.Random;
   import com.hurlant.util.Memory;
   import flash.utils.ByteArray;
   
   public class XTeaKey implements ISymmetricKey
   {
       
      
      private var k:Array;
      
      public const NUM_ROUNDS:uint = 64;
      
      public function XTeaKey(param1:ByteArray)
      {
         super();
         param1.position = 0;
         k = [param1.readUnsignedInt(),param1.readUnsignedInt(),param1.readUnsignedInt(),param1.readUnsignedInt()];
      }
      
      public static function parseKey(param1:String) : XTeaKey
      {
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeUnsignedInt(parseInt(param1.substr(0,8),16));
         _loc2_.writeUnsignedInt(parseInt(param1.substr(8,8),16));
         _loc2_.writeUnsignedInt(parseInt(param1.substr(16,8),16));
         _loc2_.writeUnsignedInt(parseInt(param1.substr(24,8),16));
         _loc2_.position = 0;
         return new XTeaKey(_loc2_);
      }
      
      public function encrypt(param1:ByteArray, param2:uint = 0) : void
      {
         var _loc5_:uint = 0;
         param1.position = param2;
         var _loc3_:uint = param1.readUnsignedInt();
         var _loc4_:uint = param1.readUnsignedInt();
         var _loc6_:uint = 0;
         var _loc7_:uint = 2654435769;
         _loc5_ = 0;
         while(_loc5_ < NUM_ROUNDS)
         {
            _loc3_ += (_loc4_ << 4 ^ _loc4_ >> 5) + _loc4_ ^ _loc6_ + k[_loc6_ & 3];
            _loc6_ += _loc7_;
            _loc4_ += (_loc3_ << 4 ^ _loc3_ >> 5) + _loc3_ ^ _loc6_ + k[_loc6_ >> 11 & 3];
            _loc5_++;
         }
         param1.position -= 8;
         param1.writeUnsignedInt(_loc3_);
         param1.writeUnsignedInt(_loc4_);
      }
      
      public function decrypt(param1:ByteArray, param2:uint = 0) : void
      {
         var _loc5_:uint = 0;
         param1.position = param2;
         var _loc3_:uint = param1.readUnsignedInt();
         var _loc4_:uint = param1.readUnsignedInt();
         var _loc6_:uint;
         var _loc7_:uint = (_loc6_ = 2654435769) * NUM_ROUNDS;
         _loc5_ = 0;
         while(_loc5_ < NUM_ROUNDS)
         {
            _loc4_ -= (_loc3_ << 4 ^ _loc3_ >> 5) + _loc3_ ^ _loc7_ + k[_loc7_ >> 11 & 3];
            _loc7_ -= _loc6_;
            _loc3_ -= (_loc4_ << 4 ^ _loc4_ >> 5) + _loc4_ ^ _loc7_ + k[_loc7_ & 3];
            _loc5_++;
         }
         param1.position -= 8;
         param1.writeUnsignedInt(_loc3_);
         param1.writeUnsignedInt(_loc4_);
      }
      
      public function getBlockSize() : uint
      {
         return 8;
      }
      
      public function toString() : String
      {
         return "xtea";
      }
      
      public function dispose() : void
      {
         var _loc1_:Random = new Random();
         var _loc2_:uint = 0;
         while(_loc2_ < k.length)
         {
            k[_loc2_] = _loc1_.nextByte();
            delete k[_loc2_];
            _loc2_++;
         }
         k = null;
         Memory.gc();
      }
   }
}
