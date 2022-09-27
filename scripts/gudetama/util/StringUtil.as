package gudetama.util
{
   public class StringUtil
   {
      
      public static const trimRegExp:RegExp = /^\s*|\s*$/gim;
      
      public static const regExpNum:RegExp = /(\d)(?=(\d{3})+(?!\d))/g;
      
      public static const regExpUrl:RegExp = /https?:\/\/[-_.!~*'()\w;\/?:@&=+$,%#]+/gi;
       
      
      public function StringUtil()
      {
         super();
      }
      
      public static function trim(param1:String) : String
      {
         return param1.replace(trimRegExp,"");
      }
      
      public static function getNumStringCommas(param1:Number) : String
      {
         return String(param1).replace(regExpNum,"$1,");
      }
      
      public static function startsWith(param1:String, param2:String) : Boolean
      {
         return param2 == param1.substring(0,param2.length);
      }
      
      public static function endsWith(param1:String, param2:String) : Boolean
      {
         return param2 == param1.substring(param1.length - param2.length);
      }
      
      public static function searchIgnoreCase(param1:String, param2:String) : int
      {
         return param1.search(new RegExp(param2,"i"));
      }
      
      public static function replaceAll(param1:String, param2:String, param3:String) : String
      {
         return param1.split(param2).join(param3);
      }
      
      public static function removeAll(param1:String, param2:String) : String
      {
         return StringUtil.replaceAll(param1,param2,"");
      }
      
      public static function clean(param1:String) : String
      {
         return ("_" + param1).substr(1);
      }
      
      public static function format(param1:String, ... rest) : String
      {
         var _loc7_:* = null;
         var _loc6_:* = null;
         var _loc3_:* = param1;
         var _loc4_:Array = rest as Array;
         for(var _loc5_ in _loc4_)
         {
            _loc7_ = "%" + (_loc5_ + 1).toString(10);
            _loc6_ = String(_loc4_[_loc5_]);
            _loc3_ = _loc3_.split(_loc7_).join(_loc6_);
         }
         return _loc3_;
      }
      
      public static function decimalFormat(param1:String, param2:int) : String
      {
         var _loc3_:String = String(param2);
         if(_loc3_.length >= param1.length)
         {
            return _loc3_;
         }
         return param1.substr(0,param1.length - _loc3_.length) + _loc3_;
      }
      
      public static function parseBoolean(param1:String) : Boolean
      {
         return param1 == "true" || param1 == "TRUE" || param1 == "True" || param1 == "1";
      }
      
      public static function getTextNumLines(param1:String) : uint
      {
         var _loc4_:* = null;
         var _loc3_:* = 0;
         var _loc2_:uint = 0;
         _loc3_ = uint(0);
         while(_loc3_ < param1.length)
         {
            if((_loc4_ = param1.substr(_loc3_,1)) == "\r" || _loc4_ == "\n" || _loc4_ == "\r\n" || _loc4_ == " ")
            {
               _loc2_++;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      public static function branchTextOnCondition(param1:Boolean, param2:String, param3:String) : String
      {
         if(param1)
         {
            return param2;
         }
         return param3;
      }
   }
}
