package com.hurlant.crypto.symmetric
{
   import com.hurlant.crypto.prng.Random;
   import com.hurlant.util.Memory;
   import flash.utils.ByteArray;
   
   public class IVMode
   {
       
      
      protected var lastIV:ByteArray;
      
      protected var iv:ByteArray;
      
      protected var blockSize:uint;
      
      protected var padding:IPad;
      
      protected var prng:Random;
      
      protected var key:ISymmetricKey;
      
      public function IVMode(param1:ISymmetricKey, param2:IPad = null)
      {
         super();
         this.key = param1;
         blockSize = param1.getBlockSize();
         if(param2 == null)
         {
            param2 = new PKCS5(blockSize);
         }
         else
         {
            param2.setBlockSize(blockSize);
         }
         this.padding = param2;
         prng = new Random();
         iv = null;
         lastIV = new ByteArray();
      }
      
      public function set IV(param1:ByteArray) : void
      {
         iv = param1;
         lastIV.length = 0;
         lastIV.writeBytes(iv);
      }
      
      protected function getIV4d() : ByteArray
      {
         var _loc1_:ByteArray = new ByteArray();
         if(iv)
         {
            _loc1_.writeBytes(iv);
            return _loc1_;
         }
         throw new Error("an IV must be set before calling decrypt()");
      }
      
      protected function getIV4e() : ByteArray
      {
         var _loc1_:ByteArray = new ByteArray();
         if(iv)
         {
            _loc1_.writeBytes(iv);
         }
         else
         {
            prng.nextBytes(_loc1_,blockSize);
         }
         lastIV.length = 0;
         lastIV.writeBytes(_loc1_);
         return _loc1_;
      }
      
      public function get IV() : ByteArray
      {
         return lastIV;
      }
      
      public function dispose() : void
      {
         var _loc1_:uint = 0;
         if(iv != null)
         {
            _loc1_ = 0;
            while(_loc1_ < iv.length)
            {
               iv[_loc1_] = prng.nextByte();
               _loc1_++;
            }
            iv.length = 0;
            iv = null;
         }
         if(lastIV != null)
         {
            _loc1_ = 0;
            while(_loc1_ < iv.length)
            {
               lastIV[_loc1_] = prng.nextByte();
               _loc1_++;
            }
            lastIV.length = 0;
            lastIV = null;
         }
         key.dispose();
         key = null;
         padding = null;
         prng.dispose();
         prng = null;
         Memory.gc();
      }
      
      public function getBlockSize() : uint
      {
         return key.getBlockSize();
      }
   }
}
