package starlingbuilder.engine.util
{
   public class ObjectLocaterUtil
   {
       
      
      public function ObjectLocaterUtil()
      {
         super();
      }
      
      public static function set(param1:Object, param2:String, param3:Object) : void
      {
         var _loc6_:Array;
         var _loc4_:Object = (_loc6_ = param2.split(".")).pop();
         var _loc5_:* = param1;
         for each(var _loc7_ in _loc6_)
         {
            _loc5_ = _loc5_[_loc7_];
         }
         _loc5_[_loc4_] = param3;
      }
      
      public static function get(param1:Object, param2:String) : Object
      {
         var _loc4_:Array = param2.split(".");
         var _loc3_:* = param1;
         for each(var _loc5_ in _loc4_)
         {
            _loc3_ = _loc3_[_loc5_];
         }
         return _loc3_;
      }
      
      public static function del(param1:Object, param2:String) : void
      {
         var _loc5_:Array;
         var _loc3_:Object = (_loc5_ = param2.split(".")).pop();
         var _loc4_:* = param1;
         for each(var _loc6_ in _loc5_)
         {
            _loc4_ = _loc4_[_loc6_];
         }
         delete _loc4_[_loc3_];
      }
      
      public static function hasProperty(param1:Object, param2:String) : Boolean
      {
         var _loc4_:Array = param2.split(".");
         var _loc3_:* = param1;
         for each(var _loc5_ in _loc4_)
         {
            if(!_loc3_.hasOwnProperty(_loc5_))
            {
               return false;
            }
            _loc3_ = _loc3_[_loc5_];
         }
         return true;
      }
   }
}
