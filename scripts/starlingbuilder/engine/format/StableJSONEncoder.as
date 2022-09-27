package starlingbuilder.engine.format
{
   import flash.utils.describeType;
   
   public class StableJSONEncoder
   {
       
      
      private var jsonString:String;
      
      private var space:int;
      
      public function StableJSONEncoder(param1:*, param2:int = 2)
      {
         super();
         this.space = param2;
         jsonString = convertToString(param1,0);
      }
      
      public static function stringify(param1:Object, param2:int = 2) : String
      {
         return new StableJSONEncoder(param1,param2).getString();
      }
      
      public function getString() : String
      {
         return jsonString;
      }
      
      private function convertToString(param1:*, param2:int) : String
      {
         if(param1 is String)
         {
            return escapeString(param1 as String);
         }
         if(param1 is Number)
         {
            return !!isFinite(param1 as Number) ? param1.toString() : "null";
         }
         if(param1 is Boolean)
         {
            return !!param1 ? "true" : "false";
         }
         if(param1 is Array)
         {
            return arrayToString(param1 as Array,param2);
         }
         if(param1 is Object && param1 != null)
         {
            return objectToString(param1,param2);
         }
         return "null";
      }
      
      private function escapeString(param1:String) : String
      {
         var _loc6_:* = null;
         var _loc7_:int = 0;
         var _loc5_:* = null;
         var _loc2_:* = null;
         var _loc3_:String = "";
         var _loc4_:Number = param1.length;
         _loc7_ = 0;
         while(_loc7_ < _loc4_)
         {
            switch(_loc6_ = param1.charAt(_loc7_))
            {
               case "\"":
                  _loc3_ += "\\\"";
                  break;
               case "\\":
                  _loc3_ += "\\\\";
                  break;
               case "\b":
                  _loc3_ += "\\b";
                  break;
               case "\f":
                  _loc3_ += "\\f";
                  break;
               case "\n":
                  _loc3_ += "\\n";
                  break;
               case "\r":
                  _loc3_ += "\\r";
                  break;
               case "\t":
                  _loc3_ += "\\t";
                  break;
               default:
                  if(_loc6_ < " ")
                  {
                     _loc2_ = (_loc5_ = _loc6_.charCodeAt(0).toString(16)).length == 2 ? "00" : "000";
                     _loc3_ += "\\u" + _loc2_ + _loc5_;
                  }
                  else
                  {
                     _loc3_ += _loc6_;
                  }
            }
            _loc7_++;
         }
         return "\"" + _loc3_ + "\"";
      }
      
      private function arrayToString(param1:Array, param2:int) : String
      {
         var _loc5_:int = 0;
         param2++;
         var _loc3_:String = "";
         var _loc4_:int = param1.length;
         _loc5_ = 0;
         while(_loc5_ < _loc4_)
         {
            if(_loc3_.length > 0)
            {
               _loc3_ += "," + returnString(param2);
            }
            _loc3_ += convertToString(param1[_loc5_],param2);
            _loc5_++;
         }
         param2--;
         if(_loc3_ == "")
         {
            return "[]";
         }
         return "[" + returnString(param2 + 1) + _loc3_ + returnString(param2) + "]";
      }
      
      private function objectToString(param1:Object, param2:int) : String
      {
         var _loc7_:* = null;
         var _loc5_:* = null;
         param2++;
         var _loc4_:String = "";
         var _loc3_:XML = describeType(param1);
         if(_loc3_.@name.toString() == "Object")
         {
            _loc5_ = getSortedKeys(param1);
            for each(var _loc8_ in _loc5_)
            {
               if(!((_loc7_ = param1[_loc8_]) is Function))
               {
                  if(_loc4_.length > 0)
                  {
                     _loc4_ += "," + returnString(param2);
                  }
                  _loc4_ += escapeString(_loc8_) + ":" + convertToString(_loc7_,param2);
               }
            }
         }
         else
         {
            for each(var _loc6_ in _loc3_..*.(name() == "variable" || name() == "accessor" && attribute("access").charAt(0) == "r"))
            {
               if(!(_loc6_.metadata && _loc6_.metadata.(@name == "Transient").length() > 0))
               {
                  if(_loc4_.length > 0)
                  {
                     _loc4_ += "," + returnString(param2);
                  }
                  _loc4_ += escapeString(_loc6_.@name.toString()) + ":" + convertToString(param1[_loc6_.@name],param2);
               }
            }
         }
         param2--;
         if(_loc4_ == "")
         {
            return "{}";
         }
         return "{" + returnString(param2 + 1) + _loc4_ + returnString(param2) + "}";
      }
      
      private function getSortedKeys(param1:Object) : Array
      {
         var _loc2_:Array = [];
         for(var _loc3_ in param1)
         {
            _loc2_.push(_loc3_);
         }
         _loc2_.sort();
         return _loc2_;
      }
      
      private function returnString(param1:int) : String
      {
         var _loc2_:* = null;
         var _loc3_:int = 0;
         if(space > 0)
         {
            _loc2_ = "\n";
            _loc3_ = 0;
            while(_loc3_ < param1 * space)
            {
               _loc2_ += " ";
               _loc3_++;
            }
            return _loc2_;
         }
         return "";
      }
   }
}
