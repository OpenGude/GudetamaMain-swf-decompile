package gestouch.core
{
   import flash.display.DisplayObject;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   import gestouch.extensions.native.NativeDisplayListAdapter;
   
   use namespace gestouch_internal;
   
   public final class Gestouch
   {
      
      private static const _displayListAdaptersMap:Dictionary = new Dictionary();
      
      private static var _inputAdapter:IInputAdapter;
      
      private static var _touchesManager:TouchesManager;
      
      private static var _gesturesManager:GesturesManager;
       
      
      public function Gestouch()
      {
         super();
      }
      
      public static function get inputAdapter() : IInputAdapter
      {
         return _inputAdapter;
      }
      
      public static function set inputAdapter(param1:IInputAdapter) : void
      {
         if(_inputAdapter == param1)
         {
            return;
         }
         _inputAdapter = param1;
         if(gestouch.core.Gestouch._inputAdapter)
         {
            gestouch.core.Gestouch._inputAdapter.touchesManager = gestouch.core.Gestouch._touchesManager || (gestouch.core.Gestouch._touchesManager = new gestouch.core.TouchesManager(gestouch.core.Gestouch.gesturesManager));
            gestouch.core.Gestouch._inputAdapter.init();
         }
      }
      
      public static function get touchesManager() : TouchesManager
      {
         return _touchesManager || (_touchesManager = new TouchesManager(gestouch.core.Gestouch._gesturesManager || (gestouch.core.Gestouch._gesturesManager = new gestouch.core.GesturesManager())));
      }
      
      public static function get gesturesManager() : GesturesManager
      {
         return _gesturesManager || (_gesturesManager = new GesturesManager());
      }
      
      public static function addDisplayListAdapter(param1:Class, param2:IDisplayListAdapter) : void
      {
         if(!param1 || !param2)
         {
            throw new Error("Argument error: both arguments required.");
         }
         _displayListAdaptersMap[param1] = param2;
      }
      
      public static function addTouchHitTester(param1:ITouchHitTester, param2:int = 0) : void
      {
         (gestouch.core.Gestouch._touchesManager || (gestouch.core.Gestouch._touchesManager = new gestouch.core.TouchesManager(gestouch.core.Gestouch.gesturesManager))).addTouchHitTester(param1,param2);
      }
      
      public static function removeTouchHitTester(param1:ITouchHitTester) : void
      {
         (gestouch.core.Gestouch._touchesManager || (gestouch.core.Gestouch._touchesManager = new gestouch.core.TouchesManager(gestouch.core.Gestouch.gesturesManager))).removeInputAdapter(param1);
      }
      
      gestouch_internal static function createGestureTargetAdapter(param1:Object) : IDisplayListAdapter
      {
         var _loc2_:IDisplayListAdapter = Gestouch.getDisplayListAdapter(param1);
         if(!_loc2_ && param1 is DisplayObject)
         {
            _loc2_ = new NativeDisplayListAdapter();
            Gestouch.addDisplayListAdapter(DisplayObject,_loc2_);
         }
         if(_loc2_)
         {
            return new _loc2_.reflect()(param1);
         }
         throw new Error("Cannot create adapter for target " + param1 + " of type " + getQualifiedClassName(param1) + ".");
      }
      
      gestouch_internal static function getDisplayListAdapter(param1:Object) : IDisplayListAdapter
      {
         var _loc2_:* = null;
         for(var _loc3_ in _displayListAdaptersMap)
         {
            _loc2_ = _loc3_ as Class;
            if(param1 is _loc2_)
            {
               return _displayListAdaptersMap[_loc3_] as IDisplayListAdapter;
            }
         }
         return null;
      }
   }
}
