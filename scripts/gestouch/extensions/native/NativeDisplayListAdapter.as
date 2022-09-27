package gestouch.extensions.native
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Stage;
   import flash.utils.Dictionary;
   import gestouch.core.IDisplayListAdapter;
   
   public final class NativeDisplayListAdapter implements IDisplayListAdapter
   {
       
      
      private var _targetWeekStorage:Dictionary;
      
      public function NativeDisplayListAdapter(param1:DisplayObject = null)
      {
         super();
         if(param1)
         {
            _targetWeekStorage = new Dictionary(true);
            _targetWeekStorage[param1] = true;
         }
      }
      
      public function get target() : Object
      {
         var _loc3_:int = 0;
         var _loc2_:* = _targetWeekStorage;
         for(var _loc1_ in _loc2_)
         {
            return _loc1_;
         }
         return null;
      }
      
      public function contains(param1:Object) : Boolean
      {
         var _loc4_:* = this;
         var _loc6_:int = 0;
         var _loc5_:* = _loc4_._targetWeekStorage;
         var _loc7_:Object;
         var _loc3_:DisplayObjectContainer = (!(§§hasnext(_loc5_,_loc6_)) ? null : (_loc7_ = §§nextname(_loc6_,_loc5_), _loc7_)) as DisplayObjectContainer;
         if(_loc3_ is Stage)
         {
            return true;
         }
         var _loc2_:DisplayObject = param1 as DisplayObject;
         if(_loc2_)
         {
            return _loc3_ && _loc3_.contains(_loc2_);
         }
         return false;
      }
      
      public function getHierarchy(param1:Object) : Vector.<Object>
      {
         var _loc3_:Vector.<Object> = new Vector.<Object>();
         var _loc2_:uint = 0;
         var _loc4_:DisplayObject = param1 as DisplayObject;
         while(_loc4_)
         {
            _loc3_[_loc2_] = _loc4_;
            _loc4_ = _loc4_.parent;
            _loc2_++;
         }
         return _loc3_;
      }
      
      public function reflect() : Class
      {
         return NativeDisplayListAdapter;
      }
   }
}
