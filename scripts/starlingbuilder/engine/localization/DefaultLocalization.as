package starlingbuilder.engine.localization
{
   public class DefaultLocalization implements ILocalization
   {
       
      
      private var _data:Object;
      
      private var _locale:String;
      
      private var _keys:Array;
      
      public function DefaultLocalization(param1:Object, param2:String = null)
      {
         super();
         _data = param1;
         _locale = param2;
      }
      
      public function getLocalizedText(param1:String) : String
      {
         if(_locale && _data.hasOwnProperty(param1) && _data[param1].hasOwnProperty(_locale))
         {
            return _data[param1][_locale];
         }
         return null;
      }
      
      public function getLocales() : Array
      {
         var _loc2_:* = null;
         var _loc1_:Array = [];
         var _loc8_:int = 0;
         var _loc7_:* = _data;
         for(var _loc4_ in _loc7_)
         {
            _loc2_ = _data[_loc4_];
            for(var _loc3_ in _loc2_)
            {
               _loc1_.push(_loc3_);
            }
         }
         return _loc1_;
      }
      
      public function getKeys() : Array
      {
         if(!_keys)
         {
            _keys = [];
            for(var _loc1_ in _data)
            {
               _keys.push(_loc1_);
            }
            _keys.sort();
         }
         return _keys;
      }
      
      public function get locale() : String
      {
         return _locale;
      }
      
      public function set locale(param1:String) : void
      {
         _locale = param1;
      }
   }
}
