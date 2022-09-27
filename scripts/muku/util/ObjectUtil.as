package muku.util
{
   import flash.utils.ByteArray;
   
   public class ObjectUtil
   {
       
      
      public function ObjectUtil()
      {
         super();
      }
      
      public static function getInstanceId(param1:Object) : String
      {
         if(param1 == null)
         {
            return null;
         }
         if(param1 is String)
         {
            return "String:" + param1;
         }
         try
         {
            ByteArray(param1);
         }
         catch(e:Error)
         {
            return String(e).replace(/.*([@|\$].*?) to .*$/gi,"$1");
         }
         return "Unknown";
      }
      
      public static function concatString(param1:Object) : String
      {
         var _loc2_:String = "";
         for each(var _loc3_ in param1)
         {
            _loc2_ += "{" + _loc3_ + "},";
         }
         return _loc2_;
      }
      
      public static function dumpObject(param1:Object, param2:String = "") : void
      {
         trace(param2 + "dump:",getInstanceId(param1));
         var _loc3_:int = 0;
         for(var _loc4_ in param1)
         {
            trace(param2 + _loc3_ + ":",_loc4_,param1[_loc4_]);
            if(isDynamic(param1[_loc4_]))
            {
               dumpObject(param1[_loc4_],param2 + "\t");
            }
            _loc3_++;
         }
      }
      
      public static function isDynamic(param1:Object) : Boolean
      {
         var _loc4_:int = 0;
         var _loc3_:* = param1;
         for(var _loc2_ in _loc3_)
         {
            return true;
         }
         return false;
      }
      
      public static function hashCode(param1:String) : int
      {
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         var _loc2_:int = param1.length;
         _loc4_ = 0;
         while(_loc4_ < _loc2_)
         {
            _loc3_ = 31 * _loc3_ + param1.charCodeAt(_loc4_);
            _loc4_++;
         }
         return _loc3_;
      }
      
      public static function samplingHash(param1:ByteArray, param2:int) : int
      {
         var _loc4_:int = 0;
         var _loc6_:int = 0;
         var _loc3_:* = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc5_:int = 0;
         var _loc9_:String = param1.endian;
         if(param2 * 4 > param1.length)
         {
            param2 = param1.length / 4;
         }
         if(param2 < 1)
         {
            param2 = 2;
         }
         var _loc10_:int = int((_loc10_ = param1.length / (param2 - 1)) / 4) * 4;
         param1.position = 0;
         param1.endian = "bigEndian";
         if(param1.length >= 4)
         {
            _loc4_ = param2 - 1;
            _loc6_ = 0;
            while(_loc6_ < _loc4_)
            {
               param1.position = _loc6_ * _loc10_;
               _loc3_ = uint(param1.readInt());
               _loc5_ = 31 * _loc5_ + _loc3_;
               _loc6_++;
            }
            param1.position = param1.length - 4;
            _loc7_ = 0;
            while(_loc7_ < 4)
            {
               _loc5_ = 31 * _loc5_ + param1.readUnsignedByte();
               _loc7_++;
            }
         }
         else
         {
            _loc8_ = 0;
            while(_loc8_ < param1.length)
            {
               _loc5_ = 31 * _loc5_ + (param1[_loc8_] & 255);
               _loc8_++;
            }
         }
         param1.position = 0;
         param1.endian = _loc9_;
         return _loc5_;
      }
      
      public static function hashValueExt(param1:ByteArray) : int
      {
         var _loc5_:* = 0;
         var _loc2_:* = 0;
         if(param1 == null)
         {
            return 0;
         }
         if(param1.length > 51200)
         {
            return samplingHash(param1,4000);
         }
         var _loc6_:String = param1.endian;
         var _loc4_:int = param1.length;
         var _loc3_:int = 0;
         while(param1.length % 4 != 0)
         {
            param1[param1.length] = 0;
         }
         param1.position = 0;
         param1.endian = "bigEndian";
         _loc5_ = uint(0);
         while(_loc5_ < param1.length)
         {
            _loc2_ = uint(param1.readInt());
            _loc3_ = 31 * _loc3_ + _loc2_;
            _loc5_ += 4;
         }
         param1.position = 0;
         param1.endian = _loc6_;
         param1.length = _loc4_;
         return _loc3_;
      }
      
      public static function binarySearch(param1:Array, param2:int) : int
      {
         return binarySearch0(param1,0,param1.length,param2);
      }
      
      private static function binarySearch0(param1:Array, param2:int, param3:int, param4:int) : int
      {
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc6_:* = param2;
         var _loc5_:int = param3 - 1;
         while(_loc6_ <= _loc5_)
         {
            _loc7_ = _loc6_ + _loc5_ >>> 1;
            if((_loc8_ = param1[_loc7_]) < param4)
            {
               _loc6_ = int(_loc7_ + 1);
            }
            else
            {
               if(_loc8_ <= param4)
               {
                  return _loc7_;
               }
               _loc5_ = _loc7_ - 1;
            }
         }
         return -(_loc6_ + 1);
      }
   }
}
