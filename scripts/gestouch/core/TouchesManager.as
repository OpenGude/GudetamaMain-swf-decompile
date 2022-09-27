package gestouch.core
{
   import flash.display.Stage;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   use namespace gestouch_internal;
   
   public class TouchesManager
   {
       
      
      protected var _gesturesManager:GesturesManager;
      
      protected var _touchesMap:Object;
      
      protected var _hitTesters:Vector.<ITouchHitTester>;
      
      protected var _hitTesterPrioritiesMap:Dictionary;
      
      protected var _activeTouchesCount:uint;
      
      public function TouchesManager(param1:GesturesManager)
      {
         _touchesMap = {};
         _hitTesters = new Vector.<ITouchHitTester>();
         _hitTesterPrioritiesMap = new Dictionary(true);
         super();
         _gesturesManager = param1;
      }
      
      public function get activeTouchesCount() : uint
      {
         return _activeTouchesCount;
      }
      
      public function getTouches(param1:Object = null) : Array
      {
         var _loc3_:* = 0;
         var _loc2_:Array = [];
         if(!param1 || param1 is Stage)
         {
            _loc3_ = uint(0);
            for each(var _loc4_ in _touchesMap)
            {
               _loc2_[_loc3_++] = _loc4_;
            }
         }
         return _loc2_;
      }
      
      gestouch_internal function addTouchHitTester(param1:ITouchHitTester, param2:int = 0) : void
      {
         if(!param1)
         {
            throw new ArgumentError("Argument must be non null.");
         }
         if(_hitTesters.indexOf(param1) == -1)
         {
            _hitTesters.push(param1);
         }
         _hitTesterPrioritiesMap[param1] = param2;
         _hitTesters.sort(hitTestersSorter);
      }
      
      gestouch_internal function removeInputAdapter(param1:ITouchHitTester) : void
      {
         if(!param1)
         {
            throw new ArgumentError("Argument must be non null.");
         }
         var _loc2_:int = _hitTesters.indexOf(param1);
         if(_loc2_ == -1)
         {
            throw new Error("This touchHitTester is not registered.");
         }
         _hitTesters.splice(_loc2_,1);
         delete _hitTesterPrioritiesMap[param1];
      }
      
      gestouch_internal function onTouchBegin(param1:uint, param2:Number, param3:Number, param4:Object = null) : Boolean
      {
         var _loc10_:* = null;
         var _loc7_:* = null;
         if(param1 in _touchesMap)
         {
            return false;
         }
         var _loc8_:Point = new Point(param2,param3);
         for each(var _loc9_ in _touchesMap)
         {
            if(Point.distance(_loc9_.location#2,_loc8_) < 2)
            {
               return false;
            }
         }
         var _loc6_:Touch;
         (_loc6_ = createTouch()).id#2 = param1;
         for each(var _loc5_ in _hitTesters)
         {
            if(_loc10_ = _loc5_.hitTest(_loc8_,param4))
            {
               if(!(_loc10_ is Stage))
               {
                  break;
               }
               _loc7_ = _loc10_;
            }
         }
         if(!_loc10_ && !_loc7_)
         {
            return false;
         }
         _loc6_.target = _loc10_ || _loc7_;
         _loc6_.setLocation(param2,param3,getTimer());
         _touchesMap[param1] = _loc6_;
         _activeTouchesCount++;
         _gesturesManager.onTouchBegin(_loc6_);
         return true;
      }
      
      gestouch_internal function onTouchMove(param1:uint, param2:Number, param3:Number) : void
      {
         var _loc4_:Touch;
         if(!(_loc4_ = _touchesMap[param1] as Touch))
         {
            return;
         }
         if(_loc4_.updateLocation(param2,param3,getTimer()))
         {
            _gesturesManager.onTouchMove(_loc4_);
         }
      }
      
      gestouch_internal function onTouchEnd(param1:uint, param2:Number, param3:Number) : void
      {
         var _loc4_:Touch;
         if(!(_loc4_ = _touchesMap[param1] as Touch))
         {
            return;
         }
         _loc4_.updateLocation(param2,param3,getTimer());
         delete _touchesMap[param1];
         _activeTouchesCount--;
         _gesturesManager.onTouchEnd(_loc4_);
         _loc4_.target = null;
      }
      
      gestouch_internal function onTouchCancel(param1:uint, param2:Number, param3:Number) : void
      {
         var _loc4_:Touch;
         if(!(_loc4_ = _touchesMap[param1] as Touch))
         {
            return;
         }
         _loc4_.updateLocation(param2,param3,getTimer());
         delete _touchesMap[param1];
         _activeTouchesCount--;
         _gesturesManager.onTouchCancel(_loc4_);
         _loc4_.target = null;
      }
      
      protected function createTouch() : Touch
      {
         return new Touch();
      }
      
      protected function hitTestersSorter(param1:ITouchHitTester, param2:ITouchHitTester) : Number
      {
         var _loc3_:int = int(_hitTesterPrioritiesMap[param1]) - int(_hitTesterPrioritiesMap[param2]);
         if(_loc3_ > 0)
         {
            return -1;
         }
         if(_loc3_ < 0)
         {
            return 1;
         }
         return _hitTesters.indexOf(param1) > _hitTesters.indexOf(param2) ? 1 : -1;
      }
   }
}
