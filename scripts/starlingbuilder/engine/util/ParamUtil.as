package starlingbuilder.engine.util
{
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   import starlingbuilder.engine.UIBuilder;
   
   public class ParamUtil
   {
       
      
      public function ParamUtil()
      {
         super();
      }
      
      public static function getParams(param1:Object, param2:Object) : Array
      {
         var _loc3_:String = getClassName(param2);
         return getParamByClassName(param1,_loc3_);
      }
      
      public static function getParamByClassName(param1:Object, param2:String) : Array
      {
         var _loc5_:* = null;
         if(getFlag(param1,param2,"tag") == "ignore_default")
         {
            _loc5_ = [];
         }
         else
         {
            _loc5_ = param1.default_component.params.concat();
         }
         if(getFlag(param1,param2,"tag") == "feathers")
         {
            _loc5_ = _loc5_.concat(param1.default_feathers_component.params);
         }
         for each(var _loc3_ in param1.supported_components)
         {
            if(_loc3_.cls == param2)
            {
               for each(var _loc4_ in _loc3_.params)
               {
                  _loc5_.push(_loc4_);
               }
               break;
            }
         }
         return _loc5_;
      }
      
      public static function getClassName(param1:Object) : String
      {
         if(param1 == null)
         {
            return "";
         }
         return getQualifiedClassName(param1).replace(/::/g,".");
      }
      
      public static function getClassNames(param1:Array) : Array
      {
         var _loc2_:Array = [];
         for each(var _loc3_ in param1)
         {
            _loc2_.push(getClassName(_loc3_));
         }
         return _loc2_;
      }
      
      public static function getCustomParams(param1:Object) : Array
      {
         return param1.default_component.customParams as Array;
      }
      
      public static function getTweenParams(param1:Object) : Array
      {
         return param1.default_component.tweenParams as Array;
      }
      
      public static function getEffectParams(param1:Object) : Array
      {
         return param1.default_component.effectParams as Array;
      }
      
      public static function getConstructorParams(param1:Object, param2:String) : Array
      {
         for each(var _loc3_ in param1.supported_components)
         {
            if(_loc3_.cls == param2)
            {
               return UIBuilder.cloneObject(_loc3_.constructorParams) as Array;
            }
         }
         return null;
      }
      
      public static function getCreateComponentClass(param1:Object, param2:String) : Class
      {
         for each(var _loc3_ in param1.supported_components)
         {
            if(_loc3_.cls == param2 && _loc3_.createComponentClass)
            {
               return getDefinitionByName(_loc3_.createComponentClass) as Class;
            }
         }
         return null;
      }
      
      public static function hasFlag(param1:Object, param2:String, param3:String) : Boolean
      {
         for each(var _loc4_ in param1.supported_components)
         {
            if(_loc4_.cls == param2)
            {
               if(_loc4_.hasOwnProperty(param3))
               {
                  return true;
               }
               return false;
            }
         }
         return false;
      }
      
      public static function getFlag(param1:Object, param2:String, param3:String) : String
      {
         for each(var _loc4_ in param1.supported_components)
         {
            if(_loc4_.cls == param2)
            {
               if(_loc4_.hasOwnProperty(param3))
               {
                  return _loc4_[param3];
               }
               return null;
            }
         }
         return null;
      }
      
      public static function getDisplayObjectName(param1:String) : String
      {
         var _loc2_:int = param1.lastIndexOf(".") + 1;
         return param1.substr(_loc2_,1).toLocaleLowerCase() + param1.substr(_loc2_ + 1);
      }
      
      public static function createButton(param1:Object, param2:String) : Boolean
      {
         return hasFlag(param1,param2,"createButton");
      }
      
      public static function scale3Data(param1:Object, param2:String) : Boolean
      {
         return hasFlag(param1,param2,"scale3Data");
      }
      
      public static function scale9Data(param1:Object, param2:String) : Boolean
      {
         return hasFlag(param1,param2,"scale9Data");
      }
      
      public static function isContainer(param1:Object, param2:String) : Boolean
      {
         return hasFlag(param1,param2,"container");
      }
   }
}
