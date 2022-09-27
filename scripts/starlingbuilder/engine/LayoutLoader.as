package starlingbuilder.engine
{
   import flash.utils.Dictionary;
   import flash.utils.describeType;
   
   public class LayoutLoader
   {
       
      
      private var _embeddedCls:Class;
      
      private var _layoutCls:Class;
      
      private var _preload:Boolean;
      
      private var _layoutMapper:Dictionary;
      
      public function LayoutLoader(param1:Class, param2:Class, param3:Boolean = true)
      {
         super();
         _embeddedCls = param1;
         _layoutCls = param2;
         _preload = param3;
         if(_preload)
         {
            preloadLayouts();
         }
      }
      
      public function load(param1:String) : Object
      {
         if(!(param1 in _layoutCls))
         {
            throw new Error("Layout class has no property " + param1);
         }
         if(_layoutCls[param1] == null)
         {
            if(!(param1 in _embeddedCls))
            {
               throw new Error("Embedded class has no property " + param1);
            }
            _layoutCls[param1] = JSON.parse(new _embeddedCls[param1]());
         }
         return _layoutCls[param1];
      }
      
      private function preloadLayouts() : void
      {
         var _loc2_:* = null;
         var _loc3_:XML = describeType(_embeddedCls);
         var _loc4_:XMLList = _loc3_..constant;
         for each(var _loc1_ in _loc4_)
         {
            _loc2_ = _loc1_.@name;
            _layoutCls[_loc2_] = JSON.parse(new _embeddedCls[_loc2_]());
         }
      }
      
      public function loadByClass(param1:Class) : Object
      {
         var _loc3_:* = null;
         if(_layoutMapper == null)
         {
            mapLayout();
         }
         var _loc2_:* = _layoutMapper[param1];
         if(_loc2_ == null)
         {
            throw new Error("Layout data cannot be null!");
         }
         if(_loc2_ is String)
         {
            _loc3_ = _loc2_ as String;
            if(_layoutCls[_loc3_] == null)
            {
               _layoutCls[_loc3_] = JSON.parse(new _embeddedCls[_loc3_]());
            }
            _layoutMapper[param1] = _layoutCls[_loc3_];
         }
         return _layoutMapper[param1];
      }
      
      private function mapLayout() : void
      {
         var _loc2_:* = null;
         _layoutMapper = new Dictionary();
         var _loc3_:XML = describeType(_embeddedCls);
         var _loc4_:XMLList = _loc3_..constant;
         for each(var _loc1_ in _loc4_)
         {
            _loc2_ = _loc1_.@name;
            _layoutMapper[_embeddedCls[_loc2_]] = _loc2_;
         }
      }
   }
}
