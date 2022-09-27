package gudetama.net
{
   import com.hurlant.crypto.Crypto;
   import com.hurlant.crypto.symmetric.CBCMode;
   import com.hurlant.crypto.symmetric.IPad;
   import com.hurlant.crypto.symmetric.PKCS5;
   import com.hurlant.util.Base64;
   import com.hurlant.util.Hex;
   import flash.utils.ByteArray;
   
   public class AESEncryptor
   {
      
      public static const KEY_LENGTH:uint = 16;
      
      private static var chars:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
       
      
      private var keyBytes:ByteArray;
      
      private var cipher:CBCMode;
      
      private var pkcs5:IPad;
      
      public function AESEncryptor()
      {
         pkcs5 = new PKCS5();
         super();
      }
      
      public static function generateRandomBytes(param1:uint) : ByteArray
      {
         var _loc3_:* = 0;
         var _loc2_:ByteArray = new ByteArray();
         _loc3_ = uint(0);
         while(_loc3_ < param1)
         {
            _loc2_[_loc3_] = uint(Math.random() * 255);
            _loc3_++;
         }
         return _loc2_;
      }
      
      public static function generateRandomString(param1:uint) : String
      {
         var _loc3_:* = 0;
         var _loc4_:Number = chars.length - 1;
         var _loc2_:String = "";
         _loc3_ = uint(0);
         while(_loc3_ < param1)
         {
            _loc2_ += chars.charAt(Math.floor(Math.random() * _loc4_));
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function setKey(param1:String) : void
      {
         setKeyBytes(Hex.toArray(Hex.fromString(param1)));
      }
      
      public function setKeyBytes(param1:ByteArray) : void
      {
         if(param1.length != 16)
         {
            throw new Error("key length must be 16 : " + param1);
         }
         keyBytes = param1;
         cipher = Crypto.getCipher("aes-cbc",keyBytes,pkcs5) as CBCMode;
         pkcs5.setBlockSize(cipher.getBlockSize());
      }
      
      public function encryptStringForBase64(param1:String) : String
      {
         var _loc2_:ByteArray = Hex.toArray(Hex.fromString(param1));
         return encryptForBase64(_loc2_);
      }
      
      public function encryptForBase64(param1:ByteArray) : String
      {
         var _loc2_:ByteArray = generateRandomBytes(16);
         cipher.IV = _loc2_;
         cipher.encrypt(param1);
         param1.position = param1.length;
         param1.writeBytes(_loc2_);
         return Base64.encodeByteArray(param1);
      }
      
      public function decryptStringFromBase64(param1:String) : String
      {
         var _loc2_:ByteArray = Base64.decodeToByteArray(param1);
         decrypt(_loc2_);
         return Hex.toString(Hex.fromArray(_loc2_));
      }
      
      public function decrypt(param1:ByteArray, param2:ByteArray = null) : void
      {
         var _loc3_:int = 0;
         var _loc4_:* = 0;
         if(param2 == null)
         {
            param2 = new ByteArray();
            _loc3_ = param1.position;
            _loc4_ = uint(param1.length - 16);
            param1.position = _loc4_;
            param1.readBytes(param2,0,16);
            param1.length = _loc4_;
            param1.position = _loc3_;
            cipher.IV = param2;
         }
         cipher.decrypt(param1);
      }
   }
}
