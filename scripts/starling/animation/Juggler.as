package starling.animation
{
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import gudetama.util.TimeZoneUtil;
   import starling.events.Event;
   import starling.events.EventDispatcher;
   
   public class Juggler implements IAnimatable
   {
      
      private static var sCurrentObjectID:uint;
      
      private static var registrants:Dictionary = null;
       
      
      private var _objects:Vector.<IAnimatable>;
      
      private var _objectIDs:Dictionary;
      
      private var _elapsedTime:Number;
      
      private var _timeScale:Number;
      
      public function Juggler()
      {
         super();
         _elapsedTime = 0;
         _timeScale = 1;
         _objects = new Vector.<IAnimatable>(0);
         _objectIDs = new Dictionary(true);
      }
      
      private static function getNextID() : uint
      {
         return ++sCurrentObjectID;
      }
      
      public static function getDumpRegistrantTraces() : String
      {
         var _loc8_:* = null;
         var _loc5_:* = null;
         var _loc2_:* = null;
         if(!registrants)
         {
            return "[Juggler] trace disabled";
         }
         var _loc3_:uint = 0;
         var _loc4_:Object = {};
         var _loc7_:Object = {};
         for(var _loc9_ in registrants)
         {
            _loc5_ = (_loc8_ = registrants[_loc9_]).substr(0,_loc8_.lastIndexOf("["));
            _loc2_ = _loc8_.substr(_loc8_.lastIndexOf("["));
            if(!_loc7_[_loc5_])
            {
               _loc7_[_loc5_] = 1;
               _loc4_[_loc5_] += _loc2_ + ",";
            }
            else
            {
               _loc7_[_loc5_]++;
               _loc4_[_loc5_] += _loc2_ + ",";
            }
            _loc3_++;
         }
         var _loc1_:String = "";
         var _loc10_:uint = 0;
         for(var _loc6_ in _loc7_)
         {
            _loc1_ += "[Juggler] registrants No." + _loc10_ + " -> count: " + _loc7_[_loc6_] + ", param:" + _loc4_[_loc6_] + " trace: " + _loc6_ + "\n";
            _loc10_++;
         }
         return _loc1_ + ("[Juggler] registrants count: " + _loc3_);
      }
      
      public function add(param1:IAnimatable) : uint
      {
         return addWithID(param1,getNextID());
      }
      
      private function addWithID(param1:IAnimatable, param2:uint) : uint
      {
         var _loc3_:* = null;
         if(param1 && !(param1 in _objectIDs))
         {
            _loc3_ = param1 as EventDispatcher;
            if(_loc3_)
            {
               _loc3_.addEventListener("removeFromJuggler",onRemove);
            }
            _objects[_objects.length] = param1;
            _objectIDs[param1] = param2;
            return param2;
         }
         return 0;
      }
      
      public function contains(param1:IAnimatable) : Boolean
      {
         return param1 in _objectIDs;
      }
      
      public function remove(param1:IAnimatable) : uint
      {
         var _loc3_:* = null;
         var _loc2_:int = 0;
         var _loc4_:uint = 0;
         if(param1 && param1 in _objectIDs)
         {
            _loc3_ = param1 as EventDispatcher;
            if(_loc3_)
            {
               _loc3_.removeEventListener("removeFromJuggler",onRemove);
            }
            _loc2_ = _objects.indexOf(param1);
            _objects[_loc2_] = null;
            _loc4_ = _objectIDs[param1];
            delete _objectIDs[param1];
         }
         return _loc4_;
      }
      
      public function removeByID(param1:uint) : uint
      {
         var _loc2_:int = 0;
         var _loc3_:* = null;
         _loc2_ = _objects.length - 1;
         while(_loc2_ >= 0)
         {
            _loc3_ = _objects[_loc2_];
            if(_objectIDs[_loc3_] == param1)
            {
               remove(_loc3_);
               return param1;
            }
            _loc2_--;
         }
         return 0;
      }
      
      public function removeTweens(param1:Object) : void
      {
         var _loc3_:int = 0;
         var _loc2_:* = null;
         if(param1 == null)
         {
            return;
         }
         _loc3_ = _objects.length - 1;
         while(_loc3_ >= 0)
         {
            _loc2_ = _objects[_loc3_] as Tween;
            if(_loc2_ && _loc2_.target == param1)
            {
               _loc2_.removeEventListener("removeFromJuggler",onRemove);
               _objects[_loc3_] = null;
               delete _objectIDs[_loc2_];
            }
            _loc3_--;
         }
      }
      
      public function removeDelayedCalls(param1:Function) : void
      {
         var _loc2_:int = 0;
         var _loc3_:* = null;
         if(param1 == null)
         {
            return;
         }
         _loc2_ = _objects.length - 1;
         while(_loc2_ >= 0)
         {
            _loc3_ = _objects[_loc2_] as DelayedCall;
            if(_loc3_ && _loc3_.callback == param1)
            {
               _loc3_.removeEventListener("removeFromJuggler",onRemove);
               _objects[_loc2_] = null;
               delete _objectIDs[_loc3_];
            }
            _loc2_--;
         }
      }
      
      public function containsTweens(param1:Object) : Boolean
      {
         var _loc3_:int = 0;
         var _loc2_:* = null;
         if(param1)
         {
            _loc3_ = _objects.length - 1;
            while(_loc3_ >= 0)
            {
               _loc2_ = _objects[_loc3_] as Tween;
               if(_loc2_ && _loc2_.target == param1)
               {
                  return true;
               }
               _loc3_--;
            }
         }
         return false;
      }
      
      public function containsDelayedCalls(param1:Function) : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:* = null;
         if(param1 != null)
         {
            _loc2_ = _objects.length - 1;
            while(_loc2_ >= 0)
            {
               _loc3_ = _objects[_loc2_] as DelayedCall;
               if(_loc3_ && _loc3_.callback == param1)
               {
                  return true;
               }
               _loc2_--;
            }
         }
         return false;
      }
      
      public function purge() : void
      {
         var _loc1_:int = 0;
         var _loc3_:* = null;
         var _loc2_:* = null;
         _loc1_ = _objects.length - 1;
         while(_loc1_ >= 0)
         {
            _loc3_ = _objects[_loc1_];
            _loc2_ = _loc3_ as EventDispatcher;
            if(_loc2_)
            {
               _loc2_.removeEventListener("removeFromJuggler",onRemove);
            }
            _objects[_loc1_] = null;
            delete _objectIDs[_loc3_];
            _loc1_--;
         }
      }
      
      public function delayCall(param1:Function, param2:Number, ... rest) : uint
      {
         if(param1 == null)
         {
            throw new ArgumentError("call must not be null");
         }
         var _loc4_:DelayedCall;
         (_loc4_ = DelayedCall.fromPool(param1,param2,rest)).addEventListener("removeFromJuggler",onPooledDelayedCallComplete);
         return add(_loc4_);
      }
      
      public function delayCallWithoutPool(param1:Function, param2:Number, ... rest) : DelayedCall
      {
         if(param1 == null)
         {
            throw new ArgumentError("call must not be null");
         }
         var _loc4_:DelayedCall = new DelayedCall(param1,param2,rest);
         add(_loc4_);
         return _loc4_;
      }
      
      public function repeatCall(param1:Function, param2:Number, param3:int = 0, ... rest) : void
      {
         if(param1 == null)
         {
            throw new ArgumentError("call must not be null");
         }
         var _loc5_:DelayedCall;
         (_loc5_ = DelayedCall.fromPool(param1,param2,rest)).repeatCount = param3;
         _loc5_.addEventListener("removeFromJuggler",onPooledDelayedCallComplete);
         add(_loc5_);
      }
      
      public function repeatCallWithoutPool(param1:Function, param2:Number, param3:int = 0, ... rest) : DelayedCall
      {
         if(param1 == null)
         {
            throw new ArgumentError("call must not be null");
         }
         var _loc5_:DelayedCall;
         (_loc5_ = new DelayedCall(param1,param2,rest)).repeatCount = param3;
         add(_loc5_);
         return _loc5_;
      }
      
      private function onPooledDelayedCallComplete(param1:Event) : void
      {
         DelayedCall.toPool(param1.target as DelayedCall);
      }
      
      public function tween(param1:Object, param2:Number, param3:Object) : IAnimatable
      {
         var _loc6_:* = null;
         if(param1 == null)
         {
            throw new ArgumentError("target must not be null");
         }
         var _loc4_:Tween = Tween.fromPool(param1,param2);
         for(var _loc5_ in param3)
         {
            _loc6_ = param3[_loc5_];
            if(_loc4_.hasOwnProperty(_loc5_))
            {
               _loc4_[_loc5_] = _loc6_;
            }
            else
            {
               if(!param1.hasOwnProperty(Tween.getPropertyName(_loc5_)))
               {
                  throw new ArgumentError("Invalid property: " + _loc5_);
               }
               _loc4_.animate(_loc5_,_loc6_ as Number);
            }
         }
         _loc4_.addEventListener("removeFromJuggler",onPooledTweenComplete);
         add(_loc4_);
         return _loc4_;
      }
      
      private function onPooledTweenComplete(param1:Event) : void
      {
         Tween.toPool(param1.target as Tween);
      }
      
      public function advanceTime(param1:Number) : void
      {
         var _loc3_:int = 0;
         var _loc6_:* = null;
         var _loc2_:* = null;
         var _loc5_:int = _objects.length;
         var _loc4_:* = 0;
         param1 *= _timeScale;
         if(_loc5_ == 0 || param1 == 0)
         {
            return;
         }
         _elapsedTime += param1;
         _loc3_ = 0;
         while(_loc3_ < _loc5_)
         {
            if(_loc6_ = _objects[_loc3_])
            {
               if(_loc4_ != _loc3_)
               {
                  _objects[_loc4_] = _loc6_;
                  _objects[_loc3_] = null;
               }
               _loc6_.advanceTime(param1);
               if(_objects.length < _loc5_)
               {
                  _loc4_ = _loc3_;
                  break;
               }
               _loc4_++;
            }
            _loc3_++;
         }
         if(_loc4_ != _loc3_)
         {
            _loc5_ = _objects.length;
            try
            {
               while(_loc3_ < _loc5_)
               {
                  _objects[int(_loc4_++)] = _objects[int(_loc3_++)];
               }
               _objects.length = _loc4_;
            }
            catch(e:Error)
            {
               _loc2_ = getDefinitionByName("gudetama.engine.Engine") as Class;
               if(_loc2_)
               {
                  _loc2_.traceLog(e,_loc5_,_loc4_,_loc3_,_objects.length);
               }
               else
               {
                  trace(e.getStackTrace(),_loc5_,_loc4_,_loc3_,_objects.length);
               }
            }
         }
      }
      
      private function onRemove(param1:Event) : void
      {
         var _loc2_:* = null;
         var _loc3_:uint = remove(param1.target as IAnimatable);
         if(_loc3_)
         {
            _loc2_ = param1.target as Tween;
            if(_loc2_ && _loc2_.isComplete)
            {
               addWithID(_loc2_.nextTween,_loc3_);
            }
         }
      }
      
      public function get elapsedTime() : Number
      {
         return _elapsedTime;
      }
      
      public function get timeScale() : Number
      {
         return _timeScale;
      }
      
      public function set timeScale(param1:Number) : void
      {
         _timeScale = param1;
      }
      
      public function get objects() : Vector.<IAnimatable>
      {
         return _objects;
      }
      
      private function traceRegister(param1:int) : void
      {
         if(!registrants)
         {
            return;
         }
         var _loc2_:String = TimeZoneUtil.getRuntimeElapsedTime();
         registrants[param1] = new Error().getStackTrace() + "\n[time:" + _loc2_ + "]";
      }
      
      private function traceUnregister(param1:int) : void
      {
         if(!registrants)
         {
            return;
         }
         delete registrants[param1];
      }
   }
}
