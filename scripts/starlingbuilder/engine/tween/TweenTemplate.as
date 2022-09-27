package starlingbuilder.engine.tween
{
   import muku.core.MukuGlobal;
   import starlingbuilder.engine.UIBuilder;
   
   public class TweenTemplate
   {
      
      private static var dictionary:Object = null;
       
      
      public function TweenTemplate()
      {
         super();
      }
      
      private static function setupTweenDictionary() : Object
      {
         var _loc3_:Object = {};
         MukuGlobal.isBuilderMode();
         var _loc1_:Object = MukuGlobal.assetManager.getObject("tween_template");
         for each(var _loc2_ in _loc1_.template)
         {
            _loc3_[_loc2_.name] = _loc2_.tweenData;
         }
         return _loc3_;
      }
      
      public static function setup() : void
      {
         if(dictionary == null)
         {
            dictionary = setupTweenDictionary();
         }
      }
      
      public static function needsSynchronize(param1:Object) : Boolean
      {
         var _loc2_:Object = param1["properties"];
         if(param1.hasOwnProperty("noSync") && param1.noSync)
         {
            return false;
         }
         if(_loc2_)
         {
            if(_loc2_["repeatCount"] == 0 && _loc2_["reverse"] == true)
            {
               return true;
            }
         }
         return false;
      }
      
      public static function hasHexColorDesc(param1:Object) : Boolean
      {
         var _loc2_:* = null;
         var _loc5_:* = null;
         for each(var _loc4_ in ["from","properties","delta","fromDelta"])
         {
            if(param1.hasOwnProperty(_loc4_))
            {
               _loc5_ = param1[_loc4_];
               for(var _loc3_ in _loc5_)
               {
                  if(_loc5_[_loc3_] is String && (_loc5_[_loc3_] as String).indexOf("0x") == 0)
                  {
                     return true;
                  }
               }
            }
         }
         return false;
      }
      
      private static function updateValue(param1:Object, param2:Object) : String
      {
         var _loc6_:* = null;
         var _loc4_:* = 0;
         var _loc3_:* = null;
         var _loc5_:Object;
         if((_loc5_ = param1[param2]) is String)
         {
            if((_loc6_ = _loc5_ as String).indexOf("0x") == 0)
            {
               _loc4_ = uint((_loc4_ = uint(_loc6_)) & 16777215);
               if(param2 == "rgb")
               {
                  param1["color"] = _loc4_;
                  delete param1[param2];
                  return null;
               }
               param1[param2] = _loc4_;
               return null;
            }
            param1[param2] = 0;
            return _loc6_;
         }
         if(_loc5_.hasOwnProperty("value"))
         {
            if(_loc5_.value is String)
            {
               _loc3_ = _loc5_.value as String;
               param1[param2] = 0;
               if(_loc5_.hasOwnProperty("default_value"))
               {
                  param1[param2] = _loc5_.default_value;
               }
               return _loc3_;
            }
            param1[param2] = _loc5_.value;
         }
         return null;
      }
      
      public static function updateTweenData(param1:Object, param2:Object, param3:String = null) : Object
      {
         var _loc7_:* = null;
         var _loc5_:* = null;
         var _loc9_:* = null;
         var _loc6_:* = null;
         if(param1 is Array)
         {
            for each(var _loc4_ in param1)
            {
               updateTweenData(_loc4_,param2);
            }
            return param1;
         }
         for each(var _loc8_ in ["from","properties","delta","fromDelta"])
         {
            if(param1.hasOwnProperty(_loc8_))
            {
               _loc9_ = param1[_loc8_];
               for(_loc7_ in _loc9_)
               {
                  if(_loc7_ != "transition")
                  {
                     if((_loc5_ = updateValue(_loc9_,_loc7_)) != null)
                     {
                        if(param2.hasOwnProperty(_loc5_))
                        {
                           _loc9_[_loc7_] = param2[_loc5_];
                        }
                        else if(_loc5_.charAt(0) == "-")
                        {
                           _loc6_ = _loc5_.substr(1);
                           if(param2.hasOwnProperty(_loc6_))
                           {
                              _loc9_[_loc7_] = -param2[_loc6_];
                           }
                           else if(param3)
                           {
                              trace("TweenTemplate",param3,"variable: " + _loc7_ + "=" + _loc6_ + " not found-2. default value " + _loc9_[_loc7_] + " assumed !");
                           }
                           else
                           {
                              trace("TweenTemplate","variable: " + _loc7_ + "=" + _loc6_ + " not found-2. default value " + _loc9_[_loc7_] + " assumed !");
                           }
                        }
                        else if(param3)
                        {
                           trace("TweenTemplate",param3,"variable: " + _loc7_ + "=" + _loc5_ + " not found. default value " + _loc9_[_loc7_] + " assumed !");
                        }
                        else
                        {
                           trace("TweenTemplate","variable: " + _loc7_ + "=" + _loc5_ + " not found. default value " + _loc9_[_loc7_] + " assumed !");
                        }
                     }
                  }
               }
            }
         }
         if((_loc5_ = updateValue(param1,"time")) != null)
         {
            if(param2.hasOwnProperty(_loc5_))
            {
               param1["time"] = param2[_loc5_];
            }
         }
         if(param2.hasOwnProperty("noSync"))
         {
            param1["noSync"] = param2.noSync;
         }
         return param1;
      }
      
      public static function getTween(param1:String, param2:Object = null) : Object
      {
         var _loc3_:* = null;
         if(dictionary == null)
         {
            dictionary = setupTweenDictionary();
         }
         if(dictionary.hasOwnProperty(param1))
         {
            _loc3_ = dictionary[param1];
            if(_loc3_)
            {
               _loc3_ = UIBuilder.cloneObject(_loc3_);
               if(param2)
               {
                  return updateTweenData(_loc3_,param2,param1);
               }
               return _loc3_;
            }
         }
         return null;
      }
   }
}
