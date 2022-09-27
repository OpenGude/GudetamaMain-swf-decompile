package gudetama.util
{
   import flash.utils.getTimer;
   import gudetama.data.GameSetting;
   import gudetama.engine.Engine;
   
   public class TimeZoneUtil
   {
      
      public static var OFFSET_MILLIS:Number = 1.2622716E12;
      
      public static var OFFSET_SECS:int = 1262271600;
      
      public static const MINUTE:int = 60;
      
      public static const HOUR:int = 3600;
      
      public static const DAY:int = 86400;
      
      public static const MONTH:int = 2678400;
      
      private static var timeZoneAbbreviations:Array = [{
         "abbr":"Etc/GMT+12",
         "zone":"GMT-1200"
      },{
         "abbr":"Etc/GMT+11",
         "zone":"GMT-1100"
      },{
         "abbr":"HST",
         "zone":"GMT-1000"
      },{
         "abbr":"AST",
         "zone":"GMT-0900"
      },{
         "abbr":"PST",
         "zone":"GMT-0800"
      },{
         "abbr":"MST",
         "zone":"GMT-0700"
      },{
         "abbr":"CST",
         "zone":"GMT-0600"
      },{
         "abbr":"EST",
         "zone":"GMT-0500"
      },{
         "abbr":"PRT",
         "zone":"GMT-0400"
      },{
         "abbr":"AGT",
         "zone":"GMT-0300"
      },{
         "abbr":"Etc/GMT+2",
         "zone":"GMT-0200"
      },{
         "abbr":"Etc/GMT+1",
         "zone":"GMT-0100"
      },{
         "abbr":"UTC",
         "zone":"GMT+0000"
      },{
         "abbr":"CET",
         "zone":"GMT+0100"
      },{
         "abbr":"EET",
         "zone":"GMT+0200"
      },{
         "abbr":"EAT",
         "zone":"GMT+0300"
      },{
         "abbr":"NET",
         "zone":"GMT+0400"
      },{
         "abbr":"PLT",
         "zone":"GMT+0500"
      },{
         "abbr":"BST",
         "zone":"GMT+0600"
      },{
         "abbr":"VST",
         "zone":"GMT+0700"
      },{
         "abbr":"CTT",
         "zone":"GMT+0800"
      },{
         "abbr":"JST",
         "zone":"GMT+0900"
      },{
         "abbr":"AET",
         "zone":"GMT+1000"
      },{
         "abbr":"SST",
         "zone":"GMT+1100"
      },{
         "abbr":"NST",
         "zone":"GMT+1200"
      },{
         "abbr":"MIT",
         "zone":"GMT+1300"
      }];
      
      private static var monthLabels:Array = new Array("1","2","3","4","5","6","7","8","9","10","11","12");
      
      private static const defaultYYmmDD:String = "%1/%2/%3";
      
      private static const defaultYYmmDDDoW:String = "%1-%2-%3-%4";
      
      private static const defaultHHmm:String = "%1:%2";
      
      private static const defaultMMdd:String = "%1/%2";
       
      
      public function TimeZoneUtil()
      {
         super();
      }
      
      private static function offsetSecsToTimeZoneMillis(param1:int) : Number
      {
         return (param1 + OFFSET_SECS) * 1000;
      }
      
      private static function getTwoDigitsNumber(param1:int) : String
      {
         var _loc2_:String = "";
         if(param1 < 0)
         {
            _loc2_ = "-";
            param1 = -param1;
         }
         if(param1 < 10)
         {
            return _loc2_ + "0" + param1;
         }
         return _loc2_ + param1;
      }
      
      private static function getThreeDigitsNumber(param1:int) : String
      {
         var _loc2_:String = "";
         if(param1 < 0)
         {
            _loc2_ = "-";
            param1 = -param1;
         }
         if(param1 < 10)
         {
            return _loc2_ + "00" + param1;
         }
         if(param1 < 100)
         {
            return _loc2_ + "0" + param1;
         }
         return _loc2_ + param1;
      }
      
      public static function getDateInstance(param1:int) : Date
      {
         return new Date(offsetSecsToTimeZoneMillis(param1));
      }
      
      public static function getDate(param1:int) : String
      {
         var _loc2_:Date = new Date(offsetSecsToTimeZoneMillis(param1));
         return _loc2_.fullYear + "-" + getTwoDigitsNumber(_loc2_.month + 1) + "-" + getTwoDigitsNumber(_loc2_.date);
      }
      
      public static function getDateYYmmDDDoW(param1:int, param2:String = "%1-%2-%3-%4") : String
      {
         var _loc3_:Date = new Date(offsetSecsToTimeZoneMillis(param1));
         return StringUtil.format(param2,_loc3_.fullYear,getTwoDigitsNumber(_loc3_.month + 1),getTwoDigitsNumber(_loc3_.date),_loc3_.day);
      }
      
      public static function getDateYYmmDD(param1:int, param2:String = "%1/%2/%3") : String
      {
         var _loc3_:Date = new Date(offsetSecsToTimeZoneMillis(param1));
         return StringUtil.format(param2,_loc3_.fullYear,_loc3_.month + 1,_loc3_.date);
      }
      
      public static function getDateMMdd(param1:int, param2:String = "%1/%2") : String
      {
         var _loc3_:Date = new Date(offsetSecsToTimeZoneMillis(param1));
         return StringUtil.format(param2,_loc3_.month + 1,_loc3_.date);
      }
      
      public static function getDateHHmm(param1:int, param2:String = "%1:%2") : String
      {
         var _loc3_:Date = new Date(offsetSecsToTimeZoneMillis(param1));
         return StringUtil.format(param2,getTwoDigitsNumber(_loc3_.hours),getTwoDigitsNumber(_loc3_.minutes));
      }
      
      public static function getDateTime(param1:int) : String
      {
         var _loc2_:Date = new Date(offsetSecsToTimeZoneMillis(param1));
         return _loc2_.fullYear + "-" + getTwoDigitsNumber(_loc2_.month + 1) + "-" + getTwoDigitsNumber(_loc2_.date) + " " + getTwoDigitsNumber(_loc2_.hours) + ":" + getTwoDigitsNumber(_loc2_.minutes) + ":" + getTwoDigitsNumber(_loc2_.seconds);
      }
      
      public static function getCurrentDateTime() : String
      {
         var _loc1_:Date = new Date();
         return _loc1_.fullYear + "-" + getTwoDigitsNumber(_loc1_.month + 1) + "-" + getTwoDigitsNumber(_loc1_.date) + " " + getTwoDigitsNumber(_loc1_.hours) + ":" + getTwoDigitsNumber(_loc1_.minutes) + ":" + getTwoDigitsNumber(_loc1_.seconds) + "," + getThreeDigitsNumber(_loc1_.milliseconds);
      }
      
      public static function getCurrentDateTimeHHMMSS() : String
      {
         var _loc1_:Date = new Date();
         return getTwoDigitsNumber(_loc1_.hours) + ":" + getTwoDigitsNumber(_loc1_.minutes) + ":" + getTwoDigitsNumber(_loc1_.seconds);
      }
      
      public static function getTimeZoneDateTime(param1:int) : String
      {
         var _loc2_:Date = getTimeZoneTime(param1);
         return _loc2_.fullYear + "-" + getTwoDigitsNumber(_loc2_.month + 1) + "-" + getTwoDigitsNumber(_loc2_.date) + " " + getTwoDigitsNumber(_loc2_.hours) + ":" + getTwoDigitsNumber(_loc2_.minutes) + ":" + getTwoDigitsNumber(_loc2_.seconds) + "," + getThreeDigitsNumber(_loc2_.milliseconds);
      }
      
      public static function getTimeZoneDateTimeHHMMSS(param1:int) : String
      {
         var _loc2_:Date = getTimeZoneTime(param1);
         return getTwoDigitsNumber(_loc2_.hours) + ":" + getTwoDigitsNumber(_loc2_.minutes) + ":" + getTwoDigitsNumber(_loc2_.seconds);
      }
      
      public static function getMonthLabels(param1:int) : String
      {
         return monthLabels[param1];
      }
      
      public static function getTimeZone() : String
      {
         var _loc1_:Date = new Date();
         var _loc2_:Boolean = isObservingDTS();
         var _loc3_:String = buildTimeZoneDesignation(_loc1_,_loc2_);
         return parseTimeZoneFromGMT(_loc3_);
      }
      
      public static function getTimeZoneTime(param1:int) : Date
      {
         var _loc2_:Date = new Date();
         _loc2_.setTime(_loc2_.getTime() + _loc2_.timezoneOffset * 60 * 1000 + param1);
         return _loc2_;
      }
      
      public static function getTimeZoneTimeInMillis(param1:int) : Number
      {
         return new Date().getTime() + param1;
      }
      
      public static function getRuntimeElapsedTime() : String
      {
         var _loc4_:Number;
         var _loc3_:Number = (_loc4_ = getTimer()) % 1000;
         var _loc1_:Number = (_loc4_ = (_loc4_ - _loc3_) / 1000) % 60;
         var _loc2_:Number = (_loc4_ = (_loc4_ - _loc1_) / 60) % 60;
         var _loc5_:Number;
         return (_loc5_ = (_loc4_ - _loc2_) / 60) + ":" + (_loc2_ < 10 ? "0" : "") + _loc2_ + ":" + (_loc1_ < 10 ? "0" : "") + _loc1_ + "." + (_loc3_ < 100 ? "0" : "") + (_loc3_ < 10 ? "0" : "") + _loc3_;
      }
      
      public static function epochMillisToOffsetSecs(param1:Number = 0) : int
      {
         if(param1 <= 0)
         {
            param1 = new Date().getTime();
         }
         return int((param1 - OFFSET_MILLIS) / 1000);
      }
      
      public static function offsetSecsToEpochMillis(param1:Number) : Number
      {
         return param1 * 1000 + OFFSET_MILLIS;
      }
      
      public static function isObservingDTS() : Boolean
      {
         var _loc5_:int = 0;
         var _loc1_:Date = new Date();
         var _loc3_:Number = _loc1_.getTimezoneOffset();
         _loc1_.setUTCFullYear(2015,0,1);
         _loc1_.setUTCHours(0,0,0,0);
         _loc1_.setTime(_loc1_.getTime() + _loc1_.getTimezoneOffset() * 60 * 1000);
         var _loc2_:Number = _loc1_.getTimezoneOffset();
         var _loc4_:Number = _loc1_.getTimezoneOffset();
         _loc5_ = 1;
         while(_loc5_ <= 11)
         {
            _loc1_.setMonth(_loc5_);
            if(_loc1_.getTimezoneOffset() < _loc4_)
            {
               _loc4_ = _loc1_.getTimezoneOffset();
            }
            else if(_loc1_.getTimezoneOffset() > _loc2_)
            {
               _loc2_ = _loc1_.getTimezoneOffset();
            }
            _loc5_++;
         }
         if(_loc3_ == _loc4_ && _loc3_ != _loc2_)
         {
            return true;
         }
         return false;
      }
      
      private static function parseTimeZoneFromGMT(param1:String) : String
      {
         for each(var _loc2_ in timeZoneAbbreviations)
         {
            if(_loc2_.zone == param1)
            {
               return _loc2_.abbr;
            }
         }
         return param1;
      }
      
      private static function buildTimeZoneDesignation(param1:Date, param2:Boolean) : String
      {
         if(!param1)
         {
            return "";
         }
         var _loc4_:String = "GMT";
         var _loc3_:Number = Math.floor(Math.abs(param1.getTimezoneOffset()) / 60);
         if(param1.getTimezoneOffset() < 0)
         {
            _loc3_ *= -1;
         }
         if(param2)
         {
            _loc3_ += 1;
         }
         if(_loc3_ > 0 && _loc3_ < 10)
         {
            _loc4_ += "-0" + _loc3_.toString();
         }
         else if(_loc3_ < 0 && _loc3_ > -10)
         {
            _loc4_ += "+0" + (-1 * _loc3_).toString();
         }
         else if(_loc3_ >= 10)
         {
            _loc4_ += "-" + _loc3_.toString();
         }
         else if(_loc3_ <= -10)
         {
            _loc4_ += "+" + (-1 * _loc3_).toString();
         }
         else
         {
            _loc4_ += "+00";
         }
         return _loc4_ + "00";
      }
      
      public static function getServerTimeSec() : int
      {
         return epochMillisToOffsetSecs() + Engine.serverTimeOffsetSec;
      }
      
      public static function getLastLoginTimeText(param1:int) : String
      {
         if(param1 >= 2678400)
         {
            return GameSetting.getUIText("common.before.many");
         }
         if(param1 >= 86400)
         {
            return GameSetting.getUIText("common.before.d").replace("%1",int(param1 / 86400));
         }
         if(param1 >= 3600)
         {
            return GameSetting.getUIText("common.before.h").replace("%1",int(param1 / 3600));
         }
         return GameSetting.getUIText("common.before.m").replace("%1",int(param1 / 60));
      }
      
      public static function getRestTimeText(param1:int) : String
      {
         if(param1 >= 86400)
         {
            return GameSetting.getUIText("common.rest.d").replace("%1",int(param1 / 86400));
         }
         if(param1 >= 3600)
         {
            return GameSetting.getUIText("common.rest.h").replace("%1",int(param1 / 3600));
         }
         return GameSetting.getUIText("common.rest.m").replace("%1",int(param1 / 60));
      }
   }
}
