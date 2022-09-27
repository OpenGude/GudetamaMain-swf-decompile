package com.facebook.graph.utils
{
   import flash.net.URLVariables;
   
   public class FacebookDataUtils
   {
       
      
      public function FacebookDataUtils()
      {
         super();
      }
      
      public static function stringToDate(param1:String) : Date
      {
         var _loc2_:* = null;
         if(param1 == null)
         {
            return null;
         }
         if(/[^0-9]/g.test(param1) == false)
         {
            return new Date(parseInt(param1) * 1000);
         }
         if(/(\d\d)\/(\d\d)(\/\d+)?/gi.test(param1))
         {
            _loc2_ = param1.split("/");
            if(_loc2_.length == 3)
            {
               return new Date(_loc2_[2],_loc2_[0] - 1,_loc2_[1]);
            }
            return new Date(0,_loc2_[0] - 1,_loc2_[1]);
         }
         if(/\d{4}-\d\d-\d\d[\sT]\d\d:\d\d(:\d\d)?[\.\-Z\+]?(\d{0,4})?(\:)?(\-\d\d:)?/gi.test(param1))
         {
            return iso8601ToDate(param1);
         }
         return new Date(param1);
      }
      
      protected static function iso8601ToDate(param1:String) : Date
      {
         var _loc7_:int = 0;
         var _loc3_:Number = NaN;
         var _loc4_:* = null;
         var _loc13_:Number = NaN;
         var _loc12_:Array;
         var _loc2_:Array = (_loc12_ = param1.toUpperCase().split("T"))[0].split("-");
         var _loc14_:Array = _loc12_.length <= 1 ? [] : _loc12_[1].split(":");
         var _loc5_:uint = _loc2_[0] == "" ? 0 : Number(_loc2_[0]);
         var _loc10_:uint = _loc2_[1] == "" ? 0 : Number(_loc2_[1] - 1);
         var _loc15_:uint = _loc2_[2] == "" ? 1 : Number(_loc2_[2]);
         var _loc11_:int = _loc14_[0] == "" ? 0 : Number(_loc14_[0]);
         var _loc8_:uint = _loc14_[1] == "" ? 0 : Number(_loc14_[1]);
         var _loc9_:uint = 0;
         var _loc6_:uint = 0;
         if(_loc14_[2] != null)
         {
            _loc7_ = _loc14_[2].length;
            if(_loc14_[2].indexOf("+") > -1)
            {
               _loc7_ = _loc14_[2].indexOf("+");
            }
            else if(_loc14_[2].indexOf("-") > -1)
            {
               _loc7_ = _loc14_[2].indexOf("-");
            }
            else if(_loc14_[2].indexOf("Z") > -1)
            {
               _loc7_ = _loc14_[2].indexOf("Z");
            }
            if(!isNaN(_loc7_))
            {
               _loc3_ = _loc14_[2].slice(0,_loc7_);
               _loc9_ = _loc3_ << 0;
               _loc6_ = 1000 * (_loc3_ % 1 / 1);
            }
            if(_loc7_ != _loc14_[2].length)
            {
               _loc4_ = _loc14_[2].slice(_loc7_);
               _loc13_ = new Date(_loc5_,_loc10_,_loc15_).getTimezoneOffset() / 60;
               switch(_loc4_.charAt(0))
               {
                  case "+":
                     _loc11_ -= _loc13_ + Number(_loc4_.slice(0));
                     break;
                  case "-":
                     _loc11_ -= _loc13_;
                     break;
                  case "Z":
               }
            }
         }
         return new Date(_loc5_,_loc10_,_loc15_,_loc11_,_loc8_,_loc9_,_loc6_);
      }
      
      public static function dateToUnixTimeStamp(param1:Date) : uint
      {
         return param1.time / 1000;
      }
      
      public static function flattenArray(param1:Array) : Array
      {
         if(param1 == null)
         {
            return [];
         }
         return FacebookDataUtils.internalFlattenArray(param1);
      }
      
      public static function getURLVariables(param1:String) : URLVariables
      {
         var _loc4_:String = "";
         var _loc2_:* = param1;
         if(param1.indexOf("?") != -1)
         {
            _loc4_ += param1.slice(param1.indexOf("?") + 1);
         }
         if(param1.indexOf("#") != -1)
         {
            _loc4_ += param1.slice(param1.indexOf("#") + 1);
         }
         var _loc3_:URLVariables = new URLVariables();
         _loc3_.decode(_loc4_);
         return _loc3_;
      }
      
      private static function internalFlattenArray(param1:Array, param2:Array = null) : Array
      {
         var _loc4_:* = 0;
         var _loc3_:* = null;
         if(param2 == null)
         {
            param2 = [];
         }
         var _loc5_:uint = param1.length;
         _loc4_ = uint(0);
         while(_loc4_ < _loc5_)
         {
            _loc3_ = param1[_loc4_];
            if(_loc3_ is Array)
            {
               FacebookDataUtils.internalFlattenArray(_loc3_ as Array,param2);
            }
            else
            {
               param2.push(_loc3_);
            }
            _loc4_++;
         }
         return param2;
      }
   }
}
