package com.twit.utils
{
   public class URLUtil
   {
       
      
      public function URLUtil()
      {
         super();
      }
      
      public static function utf8Encode(param1:String) : String
      {
         var _loc2_:int = 0;
         var _loc4_:Number = NaN;
         param1 = param1.replace(/\r\n/g,"\n");
         param1 = param1.replace(/\r/g,"\n");
         var _loc3_:String = "";
         _loc2_ = 0;
         while(_loc2_ < param1.length)
         {
            if((_loc4_ = param1.charCodeAt(_loc2_)) < 128)
            {
               _loc3_ += String.fromCharCode(_loc4_);
            }
            else if(_loc4_ > 127 && _loc4_ < 2048)
            {
               _loc3_ += String.fromCharCode(_loc4_ >> 6 | 192);
               _loc3_ += String.fromCharCode(_loc4_ & 63 | 128);
            }
            else
            {
               _loc3_ += String.fromCharCode(_loc4_ >> 12 | 224);
               _loc3_ += String.fromCharCode(_loc4_ >> 6 & 63 | 128);
               _loc3_ += String.fromCharCode(_loc4_ & 63 | 128);
            }
            _loc2_++;
         }
         return _loc3_;
      }
      
      public static function urlEncode(param1:String) : String
      {
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc2_:String = "";
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            if((_loc4_ = param1.charCodeAt(_loc3_)) >= 48 && _loc4_ <= 57 || _loc4_ >= 65 && _loc4_ <= 90 || _loc4_ >= 97 && _loc4_ <= 122 || _loc4_ == 45 || _loc4_ == 95 || _loc4_ == 46 || _loc4_ == 126)
            {
               _loc2_ += String.fromCharCode(_loc4_);
            }
            else
            {
               _loc2_ += "%" + _loc4_.toString(16).toUpperCase();
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      public static function encode(param1:String) : String
      {
         return urlEncode(utf8Encode(param1));
      }
   }
}
