package gudetama.engine
{
   import flash.utils.Dictionary;
   import starling.display.DisplayObject;
   import starling.display.DisplayObjectContainer;
   import starling.events.Event;
   import starlingbuilder.engine.UIBuilder;
   import starlingbuilder.engine.tween.TemplateTweenBuilder;
   import starlingbuilder.engine.tween.TweenTemplate;
   
   public class TweenAnimator
   {
       
      
      public function TweenAnimator()
      {
         super();
      }
      
      public static function startTween(param1:DisplayObject, param2:String, param3:Object, param4:Function = null) : Dictionary
      {
         var _loc6_:Object;
         if(!(_loc6_ = TweenTemplate.getTween(param2,param3)))
         {
            Logger.warn("[TweenAnimator]",param2 + " not found");
            return null;
         }
         var _loc5_:Dictionary;
         (_loc5_ = new Dictionary())[param1] = {"tweenData":_loc6_};
         return TweenBuilder.start(param1,_loc5_,[],param2,param4);
      }
      
      public static function finishTween(param1:DisplayObject, param2:Array = null) : void
      {
         TweenBuilder.stopTween(param1,null,TweenBuilder.POSTPROCESS_FINISH,param2);
      }
      
      public static function stopTween(param1:DisplayObject) : void
      {
         TweenBuilder.stopTween(param1,null,2);
      }
      
      public static function cancelTween(param1:DisplayObject) : void
      {
         TweenBuilder.stopTween(param1,null,1);
      }
      
      private static function onTargetRemoved(param1:Event) : void
      {
         var _loc2_:DisplayObject = param1.target as DisplayObject;
         _loc2_.removeEventListener("removedFromStage",onTargetRemoved);
         finishTween(_loc2_);
      }
      
      public static function applyDelta(param1:DisplayObject, param2:Object, param3:Object) : void
      {
         var _loc5_:* = null;
         var _loc4_:Array = null;
         if(param2 is Array)
         {
            _loc4_ = param2 as Array;
         }
         else if(param2 is String)
         {
            _loc4_ = [param2];
         }
         for each(var _loc6_ in _loc4_)
         {
            if(_loc5_ = UIBuilder.find(param1 as DisplayObjectContainer,_loc6_))
            {
               for(_loc6_ in param3)
               {
                  if(_loc5_.hasOwnProperty(_loc6_))
                  {
                     var _loc7_:* = _loc6_;
                     var _loc8_:* = _loc5_[_loc7_] + param3[_loc6_];
                     _loc5_[_loc7_] = _loc8_;
                  }
               }
            }
            else
            {
               Logger.warn("[TweenAnimator]","sprite: " + _loc6_ + " not found");
            }
         }
      }
      
      public static function recoverInitial(param1:DisplayObject, param2:Dictionary, param3:Object = null) : void
      {
         var _loc4_:Array = null;
         if(param3 is Array)
         {
            _loc4_ = param3 as Array;
         }
         else if(param3 is String)
         {
            _loc4_ = [param3];
         }
         TweenBuilder.recoverInitial(param1,param2,_loc4_);
      }
      
      public static function start(param1:DisplayObject, param2:Object, param3:String, param4:Object, param5:Function = null) : Dictionary
      {
         var base:DisplayObject = param1;
         var target:Object = param2;
         var templateName:String = param3;
         var params:Object = param4;
         var completionCallback:Function = param5;
         var numLaunched:int = 0;
         var names:Array = null;
         if(target is Array)
         {
            names = target as Array;
         }
         else if(target is String)
         {
            names = [target];
         }
         var tweenData:Object = TweenTemplate.getTween(templateName,params);
         if(!tweenData)
         {
            Logger.warn("[TweenAnimator]",templateName + " not found");
            return null;
         }
         var proxyCallback:Function = completionCallback && names.length > 1 ? function(param1:DisplayObject):void
         {
            if(--numLaunched == 0)
            {
               completionCallback(param1);
            }
         } : completionCallback;
         var paramsDict:Dictionary = new Dictionary();
         for each(name in names)
         {
            var obj:Object = UIBuilder.find(base as DisplayObjectContainer,name);
            if(obj)
            {
               paramsDict[obj] = {"tweenData":tweenData};
            }
            else
            {
               Logger.warn("[TweenAnimator]","sprite: " + name + " not found");
            }
         }
         base.addEventListener("removedFromStage",onSpriteRemoved);
         var dic:Dictionary = TweenBuilder.start(base,paramsDict,names,templateName,proxyCallback);
         if(proxyCallback != completionCallback)
         {
            numLaunched = TweenBuilder.getNumLaunched(base,proxyCallback);
         }
         return dic;
      }
      
      private static function onSpriteRemoved(param1:Event) : void
      {
         var _loc2_:DisplayObject = param1.target as DisplayObject;
         _loc2_.removeEventListener("removedFromStage",onSpriteRemoved);
         stop(_loc2_);
      }
      
      public static function stop(param1:DisplayObject, param2:Object = null, param3:int = 0) : void
      {
         var _loc4_:Array = null;
         if(param2 is Array)
         {
            _loc4_ = param2 as Array;
         }
         else if(param2 is String)
         {
            _loc4_ = [param2];
         }
         TweenBuilder.stop(param1,_loc4_,param3);
      }
      
      public static function finish(param1:DisplayObject, param2:Object = null) : void
      {
         stop(param1,param2,TweenBuilder.POSTPROCESS_FINISH);
      }
      
      public static function cancel(param1:DisplayObject, param2:Object = null) : void
      {
         stop(param1,param2,1);
      }
      
      public static function startPrimevally(param1:DisplayObject, param2:DisplayObject, param3:Object, param4:Function = null) : Dictionary
      {
         var _loc5_:Dictionary = new Dictionary();
         if(param3 is String)
         {
            _loc5_[param2] = {"tweenData":JSON.parse(param3 as String)};
         }
         else
         {
            _loc5_[param2] = {"tweenData":param3};
         }
         stopPrimevally(param1,param2);
         param1.addEventListener("removedFromStage",onSpriteRemoved);
         return TweenBuilder.start(param1,_loc5_,[],null,param4);
      }
      
      public static function stopPrimevally(param1:DisplayObject, param2:DisplayObject) : void
      {
         TweenBuilder.stopTween(param2);
      }
      
      public static function startBuiltin(param1:DisplayObject, param2:Dictionary, param3:Array = null, param4:String = null, param5:Function = null) : void
      {
         var base:DisplayObject = param1;
         var paramsDict:Dictionary = param2;
         var names:Array = param3;
         var tweenName:String = param4;
         var completionCallback:Function = param5;
         var numLaunched:int = 0;
         var proxyCallback:Function = completionCallback && names.length > 1 ? function(param1:DisplayObject):void
         {
            if(--numLaunched == 0)
            {
               completionCallback(param1);
            }
         } : completionCallback;
         TweenBuilder.startBuiltin(base,paramsDict,names,tweenName,proxyCallback);
         if(proxyCallback != completionCallback)
         {
            numLaunched = TweenBuilder.getNumLaunched(base,proxyCallback);
         }
         base.addEventListener("removedFromStage",onSpriteRemoved);
      }
      
      public static function getTweenNameList(param1:Object, param2:Vector.<String> = null) : Vector.<String>
      {
         return TemplateTweenBuilder.getTweenNameList(param1,param2);
      }
      
      public static function hasNamedTween(param1:Object, param2:String) : Boolean
      {
         return TemplateTweenBuilder.hasNamedTween(param1,param2);
      }
      
      public static function isRunning(param1:DisplayObject, param2:String = null) : Boolean
      {
         return TweenBuilder.isRunning(param1,param2);
      }
      
      public static function startItselfWithoutFinish(param1:DisplayObject, param2:String = null, param3:Boolean = false, param4:Function = null) : Boolean
      {
         return _startItself(param1,param2,param3,param4,true);
      }
      
      public static function startItself(param1:DisplayObject, param2:String = null, param3:Boolean = false, param4:Function = null) : Boolean
      {
         return _startItself(param1,param2,param3,param4,false);
      }
      
      private static function _startItself(param1:DisplayObject, param2:String = null, param3:Boolean = false, param4:Function = null, param5:Boolean = false) : Boolean
      {
         var obj:DisplayObject = param1;
         var twname:String = param2;
         var once:Boolean = param3;
         var completionCallback:Function = param4;
         var withoutFinish:Boolean = param5;
         var numLaunched:int = 0;
         if(!withoutFinish)
         {
            if(once)
            {
               TweenBuilder.stopTween(obj,null,TweenBuilder.POSTPROCESS_FINISH);
            }
            else
            {
               TweenBuilder.stopAll(obj,TweenBuilder.POSTPROCESS_FINISH);
            }
         }
         var proxyCallback:Function = !!completionCallback ? function(param1:DisplayObject):void
         {
            if(--numLaunched == 0)
            {
               completionCallback(param1);
            }
         } : null;
         var started:Boolean = TweenBuilder.startItself(obj,twname,once,proxyCallback);
         if(completionCallback)
         {
            numLaunched = TweenBuilder.getNumLaunched(obj,proxyCallback);
         }
         return started;
      }
      
      public static function finishItself(param1:DisplayObject) : void
      {
         stop(param1,null,TweenBuilder.POSTPROCESS_FINISH);
      }
      
      public static function shake(param1:DisplayObject, param2:int, param3:Number, param4:Number, param5:Number) : void
      {
         if(TweenAnimator.isRunning(param1))
         {
            finishTween(param1);
         }
         startTween(param1,"SHAKE",{
            "repeatCount":param2,
            "deltaX":param3,
            "deltaY":param4,
            "time":param5
         });
      }
      
      public static function shakeRandom(param1:DisplayObject, param2:*, param3:int, param4:Number, param5:Number, param6:Number, param7:Number) : void
      {
         var _loc8_:Number = param3 * Math.random();
         var _loc9_:Number = param5 * Math.random();
         _loc8_ = _loc8_ > param4 ? _loc8_ : Number(param4);
         _loc9_ = _loc9_ > param6 ? _loc9_ : Number(param6);
         shake(param1,param2,_loc8_,_loc9_,param7);
      }
      
      public static function getTweenTime(param1:DisplayObject, param2:String = null, param3:Boolean = false) : Number
      {
         return TweenBuilder.getTweenTime(param1,param2,param3);
      }
   }
}

import flash.utils.Dictionary;
import gudetama.engine.Engine;
import gudetama.engine.Logger;
import starling.animation.Tween;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starlingbuilder.engine.UIBuilder;
import starlingbuilder.engine.tween.TweenTemplate;

class TweenBuilder
{
   
   public static const POSTPROCESS_STOP:int = 2;
   
   public static const POSTPROCESS_CANCEL:int = 1;
   
   public static const POSTPROCESS_FINISH:int = 0;
   
   private static var _saveData:Dictionary = new Dictionary();
   
   private static var _worker_array:Array = [];
    
   
   function TweenBuilder()
   {
      super();
   }
   
   public static function start(param1:DisplayObject, param2:Dictionary, param3:Array = null, param4:String = null, param5:Function = null) : Dictionary
   {
      var _loc7_:* = null;
      var _loc11_:* = null;
      var _loc10_:Dictionary = new Dictionary();
      stop(param1,param3,0);
      var _loc8_:Array = getDisplayObjectsByNames(param1,param2,param3);
      for each(var _loc9_ in _loc8_)
      {
         if(_loc11_ = (_loc7_ = param2[_loc9_]).tweenData)
         {
            if(_loc11_ is Array)
            {
               for each(var _loc6_ in _loc11_)
               {
                  createTweenFrom(_loc9_,_loc6_,param4,param5);
               }
            }
            else
            {
               createTweenFrom(_loc9_,_loc11_,param4,param5);
            }
         }
         _loc10_[_loc9_] = _saveData[_loc9_];
      }
      return _loc10_;
   }
   
   public static function startBuiltin(param1:DisplayObject, param2:Dictionary, param3:Array = null, param4:String = null, param5:Function = null) : Dictionary
   {
      var _loc7_:* = null;
      var _loc11_:* = null;
      var _loc10_:Dictionary = new Dictionary();
      stop(param1,param3,0);
      var _loc8_:Array = getDisplayObjectsByNames(param1,param2,param3);
      for each(var _loc9_ in _loc8_)
      {
         if(_loc11_ = (_loc7_ = param2[_loc9_]).tweenData)
         {
            if(_loc11_ is Array)
            {
               for each(var _loc6_ in _loc11_)
               {
                  createBuiltinTweenFrom(_loc9_,_loc6_,param4,param5);
               }
            }
            else
            {
               createBuiltinTweenFrom(_loc9_,_loc11_,param4,param5);
            }
         }
         _loc10_[_loc9_] = _saveData[_loc9_];
      }
      return _loc10_;
   }
   
   public static function startItself(param1:DisplayObject, param2:String = null, param3:Boolean = false, param4:Function = null) : Boolean
   {
      var _loc5_:* = null;
      var _loc7_:int = 0;
      var _loc8_:Boolean = false;
      var _loc9_:Object;
      if(_loc9_ = param1.userObject.tweenData)
      {
         if(_loc9_ is Array)
         {
            for each(var _loc6_ in _loc9_)
            {
               _loc8_ = createBuiltinTweenFrom(param1,_loc6_,param2,param4) || _loc8_;
            }
         }
         else
         {
            _loc8_ = createBuiltinTweenFrom(param1,_loc9_,param2,param4) || _loc8_;
         }
      }
      if(!param3)
      {
         if(_loc5_ = param1 as DisplayObjectContainer)
         {
            _loc7_ = 0;
            while(_loc7_ < _loc5_.numChildren)
            {
               _loc8_ = startItself(_loc5_.getChildAt(_loc7_),param2,param3,param4) || _loc8_;
               _loc7_++;
            }
         }
      }
      return _loc8_;
   }
   
   private static function getDisplayObjectsByNames(param1:DisplayObject, param2:Dictionary, param3:Array) : Array
   {
      var _loc4_:Array = [];
      if(param3 && param3.length > 0)
      {
         for each(var _loc6_ in param3)
         {
            _loc4_.push(UIBuilder.find(param1 as DisplayObjectContainer,_loc6_));
         }
      }
      else
      {
         for(var _loc5_ in param2)
         {
            if(param2[_loc5_].hasOwnProperty("tweenData"))
            {
               _loc4_.push(_loc5_);
            }
         }
      }
      return _loc4_;
   }
   
   private static function synchronizeTween(param1:Tween, param2:String) : void
   {
      var _loc4_:* = null;
      for each(var _loc3_ in _saveData)
      {
         for each(var _loc5_ in _loc3_)
         {
            if(_loc5_["template"] == param2)
            {
               _loc4_ = _loc5_["tween"] as Tween;
               if(param1.totalTime == _loc4_.totalTime)
               {
                  param1.synchronize(_loc4_);
                  return;
               }
            }
         }
      }
   }
   
   private static function createTweenFrom(param1:DisplayObject, param2:Object, param3:String = null, param4:Function = null) : void
   {
      var obj:DisplayObject = param1;
      var data:Object = param2;
      var templateName:String = param3;
      var completionCallback:Function = param4;
      if(!data.hasOwnProperty("time"))
      {
         Logger.warn("Missing tween param: time");
         return;
      }
      var initData:Object = saveInitData(obj,data.properties,data.delta,data.from,data.fromDelta);
      var properties:Object = createProperties(obj,data,initData);
      var tween:Tween = Engine.tweenJuggler.tween(obj,data.time,properties) as Tween;
      tween.onComplete = function():void
      {
         stopTween(obj,tween as Tween);
      };
      if(!_saveData[obj])
      {
         _saveData[obj] = [];
      }
      if(templateName && TweenTemplate.needsSynchronize(data))
      {
         synchronizeTween(tween as Tween,templateName);
         _saveData[obj].push({
            "tween":tween,
            "init":initData,
            "template":templateName,
            "completionCallback":completionCallback
         });
      }
      else
      {
         _saveData[obj].push({
            "tween":tween,
            "init":initData,
            "completionCallback":completionCallback
         });
      }
   }
   
   private static function createBuiltinTweenFrom(param1:DisplayObject, param2:Object, param3:String = null, param4:Function = null) : Boolean
   {
      var _loc6_:* = null;
      _loc6_ = "std";
      var _loc8_:* = null;
      _loc8_ = "twname";
      var _loc7_:String = null;
      if(param2.hasOwnProperty("twname"))
      {
         if(param3 == null || param3 != param2.twname)
         {
            return false;
         }
      }
      else if(param3)
      {
         return false;
      }
      if(param2.hasOwnProperty("std"))
      {
         _loc7_ = param2["std"];
         param2 = TweenTemplate.getTween(_loc7_,param2);
         if(param2 == null)
         {
            Logger.warn("[TemplateTweenBuilder] Missing std name:{} {}",_loc7_,param4);
            return false;
         }
         if(param2 is Array)
         {
            for each(var _loc5_ in param2)
            {
               createTweenFrom(param1,_loc5_,_loc7_,param4);
            }
            return true;
         }
      }
      else
      {
         param2 = TweenTemplate.updateTweenData(param2,{});
      }
      createTweenFrom(param1,param2,_loc7_,param4);
      return true;
   }
   
   public static function recoverInitial(param1:DisplayObject, param2:Dictionary, param3:Array = null) : void
   {
      var _loc4_:* = null;
      if(param3 == null)
      {
         recoverAll(param1,param2);
      }
      else
      {
         _loc4_ = getDisplayObjectsByNames(param1,null,param3);
         for each(var _loc5_ in _loc4_)
         {
            _recoverInitial(_loc5_,param2);
         }
      }
   }
   
   private static function recoverAll(param1:DisplayObject, param2:Dictionary) : void
   {
      var _loc3_:DisplayObjectContainer = param1 as DisplayObjectContainer;
      for(var _loc4_ in _saveData)
      {
         if(param1 === _loc4_ || _loc3_ && _loc3_.contains(_loc4_))
         {
            _recoverInitial(_loc4_,param2);
         }
      }
   }
   
   private static function _recoverInitial(param1:DisplayObject, param2:Dictionary) : void
   {
      var _loc3_:* = null;
      var _loc5_:Array;
      if(_loc5_ = param2[param1])
      {
         for each(var _loc4_ in _loc5_)
         {
            _loc3_ = _loc4_.init;
            recoverInitData(param1,_loc3_);
         }
      }
   }
   
   public static function getNumLaunched(param1:DisplayObject, param2:Function) : int
   {
      var _loc7_:* = null;
      var _loc10_:Boolean = false;
      var _loc5_:* = null;
      var _loc4_:* = null;
      var _loc9_:int = 0;
      var _loc3_:DisplayObjectContainer = param1 as DisplayObjectContainer;
      for(var _loc8_ in _saveData)
      {
         if(param1 === _loc8_ || _loc3_ && _loc3_.contains(_loc8_))
         {
            _loc7_ = _saveData[_loc8_];
            _loc10_ = false;
            for each(var _loc6_ in _loc7_)
            {
               if(_loc6_.completionCallback == param2)
               {
                  if((_loc4_ = (_loc5_ = _loc6_.tween) as Tween) && _loc4_.repeatCount != 0)
                  {
                     _loc10_ = true;
                     break;
                  }
               }
            }
            if(_loc10_)
            {
               _loc9_++;
            }
         }
      }
      return _loc9_;
   }
   
   public static function stop(param1:DisplayObject, param2:Array = null, param3:int = 0) : void
   {
      var _loc4_:* = null;
      if(param2 == null)
      {
         stopAll(param1,param3);
      }
      else
      {
         _loc4_ = getDisplayObjectsByNames(param1,null,param2);
         for each(var _loc5_ in _loc4_)
         {
            stopTween(_loc5_,null,param3);
         }
      }
   }
   
   public static function stopTween(param1:DisplayObject, param2:Tween = null, param3:int = 0, param4:Array = null) : void
   {
      var obj:DisplayObject = param1;
      var aTween:Tween = param2;
      var postProcessType:int = param3;
      var exceptionTemplate:Array = param4;
      var keepCallbacks:* = function(param1:Function):void
      {
         if(param1 == null)
         {
            return;
         }
         if(completionCallback == param1)
         {
            return;
         }
         if(completionCallback == null)
         {
            completionCallback = param1;
         }
         else if(callbackArray)
         {
            if(callbackArray.indexOf(param1) < 0)
            {
               callbackArray[callbackArray.length] = param1;
            }
         }
         else if(completionCallback != param1)
         {
            callbackArray = _worker_array;
            callbackArray.length = 0;
            callbackArray[0] = completionCallback;
            callbackArray[1] = param1;
         }
      };
      var removeCallback:* = function(param1:Function):int
      {
         if(completionCallback == param1)
         {
            completionCallback = null;
         }
         if(callbackArray == null)
         {
            return !!completionCallback ? 1 : 0;
         }
         var _loc2_:int = callbackArray.indexOf(param1);
         if(_loc2_ >= 0)
         {
            callbackArray.removeAt(_loc2_);
         }
         return callbackArray.length;
      };
      var validateCallbacks:* = function():Boolean
      {
         var _loc2_:* = null;
         for each(var _loc1_ in array)
         {
            _loc2_ = _loc1_.completionCallback;
            if(_loc2_ != null)
            {
               if(_loc1_.tween && _loc1_.tween.repeatCount != 0)
               {
                  removeCallback(_loc2_);
               }
            }
         }
         return completionCallback || callbackArray && callbackArray.length > 0;
      };
      var invokeCallbacks:* = function():void
      {
         if(callbackArray && callbackArray.length > 0)
         {
            for each(var _loc1_ in callbackArray)
            {
               _loc1_(obj);
            }
         }
         else if(completionCallback)
         {
            completionCallback(obj);
         }
      };
      var checkException:* = function(param1:Object, param2:Array):Boolean
      {
         if(!(param1.template is String))
         {
            return false;
         }
         if(!param2)
         {
            return false;
         }
         for each(var _loc3_ in param2)
         {
            if(param1.template == _loc3_)
            {
               return true;
            }
         }
         return false;
      };
      var array:Array = _saveData[obj];
      var keep:Boolean = false;
      var needsCall:Boolean = true;
      var completionCallback:Function = null;
      var callbackArray:Array = null;
      if(array)
      {
         for each(data in array)
         {
            var initData:Object = data.init;
            var tw:Object = data.tween;
            if(tw != null)
            {
               if(tw is Tween)
               {
                  var tween:Tween = tw as Tween;
                  if(checkException(data,exceptionTemplate))
                  {
                     keep = true;
                     if(tween.repeatCount != 0)
                     {
                        needsCall = false;
                     }
                  }
                  else if(aTween == null || aTween == tween)
                  {
                     if(postProcessType == 0)
                     {
                        tween.forceFinish();
                        Engine.tweenJuggler.remove(tween);
                     }
                     else
                     {
                        tween.dispatchEventWith("removeFromJuggler");
                     }
                     if(postProcessType != 1 && data.completionCallback)
                     {
                        keepCallbacks(data.completionCallback);
                     }
                     data.tween = null;
                     data.completionCallback = null;
                  }
                  else if(aTween)
                  {
                     keep = true;
                     if(tween.repeatCount != 0)
                     {
                        needsCall = false;
                     }
                  }
               }
               else
               {
                  Engine.tweenJuggler["removeByID"](tw as uint);
               }
            }
         }
      }
      if(!keep)
      {
         delete _saveData[obj];
      }
      if(postProcessType != 1 && validateCallbacks())
      {
         invokeCallbacks();
      }
      if(callbackArray)
      {
         callbackArray.length = 0;
      }
   }
   
   private static function createProperties(param1:Object, param2:Object, param3:Object) : Object
   {
      var _loc5_:* = null;
      var _loc7_:* = null;
      var _loc4_:* = null;
      var _loc10_:* = null;
      var _loc8_:* = null;
      var _loc6_:* = null;
      var _loc9_:Object = {};
      if(param2.hasOwnProperty("from"))
      {
         _loc7_ = param2.from;
         for(_loc5_ in _loc7_)
         {
            if(param1.hasOwnProperty(_loc5_))
            {
               param1[_loc5_] = _loc7_[_loc5_];
               _loc9_[_loc5_] = param3[_loc5_];
            }
         }
      }
      if(param2.hasOwnProperty("fromDelta"))
      {
         _loc4_ = param2.fromDelta;
         for(_loc5_ in _loc4_)
         {
            if(param1.hasOwnProperty(_loc5_))
            {
               var _loc12_:* = _loc5_;
               var _loc11_:* = param1[_loc12_] + _loc4_[_loc5_];
               param1[_loc12_] = _loc11_;
               _loc9_[_loc5_] = param3[_loc5_];
            }
         }
      }
      if(param2.hasOwnProperty("properties"))
      {
         _loc10_ = {};
         _loc8_ = param2.properties;
         for(_loc5_ in _loc8_)
         {
            _loc10_[_loc5_] = _loc8_[_loc5_];
         }
      }
      else
      {
         _loc10_ = {};
      }
      if(param2.hasOwnProperty("delta"))
      {
         _loc6_ = param2.delta;
         for(_loc5_ in _loc6_)
         {
            if(param1.hasOwnProperty(_loc5_))
            {
               _loc10_[_loc5_] = param1[_loc5_] + _loc6_[_loc5_];
            }
         }
      }
      for(_loc5_ in _loc9_)
      {
         if(!_loc10_.hasOwnProperty(_loc5_))
         {
            _loc10_[_loc5_] = _loc9_[_loc5_];
         }
      }
      return _loc10_;
   }
   
   private static function recoverInitData(param1:Object, param2:Object) : void
   {
      for(var _loc3_ in param2)
      {
         param1[_loc3_] = param2[_loc3_];
      }
   }
   
   private static function saveInitData(param1:Object, param2:Object, param3:Object, param4:Object, param5:Object) : Object
   {
      var _loc7_:* = null;
      var _loc6_:Object = {};
      for(_loc7_ in param2)
      {
         if(param1.hasOwnProperty(_loc7_))
         {
            _loc6_[_loc7_] = param1[_loc7_];
         }
      }
      for(_loc7_ in param3)
      {
         if(param1.hasOwnProperty(_loc7_))
         {
            _loc6_[_loc7_] = param1[_loc7_];
         }
      }
      for(_loc7_ in param4)
      {
         if(param1.hasOwnProperty(_loc7_))
         {
            _loc6_[_loc7_] = param1[_loc7_];
         }
      }
      for(_loc7_ in param5)
      {
         if(param1.hasOwnProperty(_loc7_))
         {
            _loc6_[_loc7_] = param1[_loc7_];
         }
      }
      return _loc6_;
   }
   
   public static function stopAll(param1:DisplayObject, param2:int = 0) : void
   {
      var _loc3_:DisplayObjectContainer = param1 as DisplayObjectContainer;
      for(var _loc4_ in _saveData)
      {
         if(!_loc4_.userObject.hasOwnProperty("noStopAll"))
         {
            if(param1 === _loc4_ || _loc3_ && _loc3_.contains(_loc4_ as DisplayObject))
            {
               stopTween(_loc4_ as DisplayObject,null,param2);
            }
         }
      }
   }
   
   public static function isRunning(param1:DisplayObject, param2:String) : Boolean
   {
      var _loc3_:* = null;
      if(param2)
      {
         _loc3_ = UIBuilder.find(param1 as DisplayObjectContainer,param2) as DisplayObject;
         if(_saveData[_loc3_])
         {
            return true;
         }
      }
      else if(_saveData[param1])
      {
         return true;
      }
      return false;
   }
   
   public static function getTweenTime(param1:DisplayObject, param2:String = null, param3:Boolean = false, param4:Vector.<Tween> = null) : Number
   {
      var _loc6_:* = null;
      var _loc5_:* = null;
      var _loc8_:int = 0;
      if(!param4)
      {
         param4 = new Vector.<Tween>();
      }
      var _loc10_:Object;
      if(_loc10_ = param1.userObject.tweenData)
      {
         if(_loc10_ is Array)
         {
            for each(var _loc7_ in _loc10_)
            {
               if(_loc6_ = getTestTween(param1,_loc7_,param2))
               {
                  param4.push(_loc6_);
               }
            }
         }
         else if(_loc6_ = getTestTween(param1,_loc10_,param2))
         {
            param4.push(_loc6_);
         }
      }
      if(!param3)
      {
         if(_loc5_ = param1 as DisplayObjectContainer)
         {
            _loc8_ = 0;
            while(_loc8_ < _loc5_.numChildren)
            {
               getTweenTime(_loc5_.getChildAt(_loc8_),param2,param3,param4);
               _loc8_++;
            }
         }
      }
      var _loc9_:* = 0;
      for each(_loc6_ in param4)
      {
         _loc9_ = Number(Math.max(_loc9_,_loc6_.totalTime + _loc6_.delay));
      }
      return _loc9_;
   }
   
   private static function getTestTween(param1:DisplayObject, param2:Object, param3:String = null) : Tween
   {
      var _loc4_:* = null;
      _loc4_ = "twname";
      if(param2.hasOwnProperty("twname"))
      {
         if(param3 == null || param3 != param2.twname)
         {
            return null;
         }
      }
      else if(param3)
      {
         return null;
      }
      param2 = TweenTemplate.updateTweenData(param2,{});
      return createTestTween(param1,param2);
   }
   
   public static function createTestTween(param1:DisplayObject, param2:Object) : Tween
   {
      var _loc6_:* = null;
      var _loc4_:Object = saveInitData(param1,param2.properties,param2.delta,param2.from,param2.fromDelta);
      var _loc7_:Object = createTestProperties(param1,param2,_loc4_);
      var _loc3_:Tween = Tween.fromPool(param1,param2.time);
      for(var _loc5_ in _loc7_)
      {
         _loc6_ = _loc7_[_loc5_];
         if(_loc3_.hasOwnProperty(_loc5_))
         {
            _loc3_[_loc5_] = _loc6_;
         }
      }
      return _loc3_;
   }
   
   private static function createTestProperties(param1:Object, param2:Object, param3:Object) : Object
   {
      var _loc5_:* = null;
      var _loc7_:* = null;
      var _loc4_:* = null;
      var _loc10_:* = null;
      var _loc8_:* = null;
      var _loc6_:* = null;
      var _loc9_:Object = {};
      if(param2.hasOwnProperty("from"))
      {
         _loc7_ = param2.from;
         for(_loc5_ in _loc7_)
         {
            if(param1.hasOwnProperty(_loc5_))
            {
               _loc9_[_loc5_] = param3[_loc5_];
            }
         }
      }
      if(param2.hasOwnProperty("fromDelta"))
      {
         _loc4_ = param2.fromDelta;
         for(_loc5_ in _loc4_)
         {
            if(param1.hasOwnProperty(_loc5_))
            {
               _loc9_[_loc5_] = param3[_loc5_];
            }
         }
      }
      if(param2.hasOwnProperty("properties"))
      {
         _loc10_ = {};
         _loc8_ = param2.properties;
         for(_loc5_ in _loc8_)
         {
            _loc10_[_loc5_] = _loc8_[_loc5_];
         }
      }
      else
      {
         _loc10_ = {};
      }
      if(param2.hasOwnProperty("delta"))
      {
         _loc6_ = param2.delta;
         for(_loc5_ in _loc6_)
         {
            if(param1.hasOwnProperty(_loc5_))
            {
               _loc10_[_loc5_] = param1[_loc5_] + _loc6_[_loc5_];
            }
         }
      }
      for(_loc5_ in _loc9_)
      {
         if(!_loc10_.hasOwnProperty(_loc5_))
         {
            _loc10_[_loc5_] = _loc9_[_loc5_];
         }
      }
      return _loc10_;
   }
}
