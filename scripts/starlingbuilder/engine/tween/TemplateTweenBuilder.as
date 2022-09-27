package starlingbuilder.engine.tween
{
   import flash.utils.Dictionary;
   import starling.animation.Tween;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   import starling.display.DisplayObjectContainer;
   import starling.events.Event;
   import starlingbuilder.engine.UIBuilder;
   
   public class TemplateTweenBuilder implements ITweenBuilder
   {
      
      public static const STD:String = "std";
      
      public static const TWNAME:String = "twname";
       
      
      private var _saveData:Dictionary;
      
      public function TemplateTweenBuilder()
      {
         super();
         _saveData = new Dictionary();
      }
      
      public static function getTweenNameList(param1:Object, param2:Vector.<String> = null) : Vector.<String>
      {
         var tween:Object = param1;
         var results:Vector.<String> = param2;
         var addName:* = function(param1:String):void
         {
            if(results == null)
            {
               results = new Vector.<String>();
            }
            for each(var _loc2_ in results)
            {
               if(param1 == _loc2_)
               {
                  return;
               }
            }
            results.push(param1);
         };
         if(tween == null)
         {
            return null;
         }
         if(tween is String)
         {
            var tween:Object = JSON.parse(tween as String);
         }
         if(tween.hasOwnProperty("tweenData"))
         {
            tween = tween.tweenData;
         }
         if(tween is Array)
         {
            for each(tw in tween)
            {
               if(tw.hasOwnProperty("twname"))
               {
                  addName(tw.twname);
               }
            }
         }
         else if(tween.hasOwnProperty("twname"))
         {
            addName(tween.twname);
         }
         return results;
      }
      
      public static function hasNamedTween(param1:Object, param2:String) : Boolean
      {
         if(param1 == null)
         {
            return false;
         }
         if(param1 is String)
         {
            param1 = JSON.parse(param1 as String);
         }
         if(param1.hasOwnProperty("tweenData"))
         {
            param1 = param1.tweenData;
         }
         if(param1 is Array)
         {
            for each(var _loc3_ in param1)
            {
               if(_loc3_.hasOwnProperty("twname"))
               {
                  if(param2 == _loc3_.twname)
                  {
                     return true;
                  }
               }
            }
         }
         else if(param1.hasOwnProperty("twname"))
         {
            if(param2 == param1.twname)
            {
               return true;
            }
         }
         return false;
      }
      
      public static function getNamedTween(param1:Object, param2:String) : Object
      {
         var _loc7_:* = null;
         var _loc6_:* = null;
         var _loc3_:* = null;
         var _loc4_:Array = null;
         if(param1 == null)
         {
            return null;
         }
         if(param1 is String)
         {
            param1 = JSON.parse(param1 as String);
         }
         if(param1.hasOwnProperty("tweenData"))
         {
            param1 = param1.tweenData;
         }
         if(param1 is Array)
         {
            for each(var _loc5_ in param1)
            {
               if(_loc5_.hasOwnProperty("twname"))
               {
                  if(param2 == _loc5_.twname)
                  {
                     delete (_loc7_ = UIBuilder.cloneObject(_loc5_))["twname"];
                     if(_loc3_)
                     {
                        if(_loc4_)
                        {
                           _loc4_[_loc4_.length] = _loc7_;
                        }
                        else
                        {
                           _loc4_ = [_loc3_,_loc7_];
                        }
                     }
                     else
                     {
                        _loc3_ = _loc7_;
                     }
                  }
               }
            }
         }
         else if(param1.hasOwnProperty("twname"))
         {
            if(param2 == param1.twname)
            {
               delete (_loc6_ = UIBuilder.cloneObject(param1))["twname"];
               return _loc6_;
            }
         }
         return !!_loc4_ ? _loc4_ : _loc3_;
      }
      
      public function start(param1:DisplayObject, param2:Dictionary, param3:Array = null) : void
      {
         var _loc5_:* = null;
         var _loc8_:* = null;
         _stop(param1,param2,param3,false);
         var _loc6_:Array = getDisplayObjectsByNames(param1,param2,param3);
         for each(var _loc7_ in _loc6_)
         {
            if(_loc8_ = (_loc5_ = param2[_loc7_]).tweenData)
            {
               if(_loc8_ is Array)
               {
                  for each(var _loc4_ in _loc8_)
                  {
                     createTweenFrom(_loc7_,_loc4_);
                  }
               }
               else
               {
                  createTweenFrom(_loc7_,_loc8_);
               }
            }
         }
         param1.addEventListener("removedFromStage",onSpriteRemoved);
      }
      
      private function onSpriteRemoved(param1:Event) : void
      {
         var _loc2_:DisplayObjectContainer = param1.target as DisplayObjectContainer;
         _loc2_.removeEventListener("removedFromStage",onSpriteRemoved);
         stop(_loc2_);
         trace("[TemplateTweenBuilder]","onSpriteRemoved:" + _loc2_);
      }
      
      private function getDisplayObjectsByNames(param1:DisplayObject, param2:Dictionary, param3:Array) : Array
      {
         var _loc4_:Array = [];
         if(param3)
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
      
      private function synchronizeTween(param1:Tween, param2:String) : void
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
                     trace("Tween:",param2,"synchronized");
                     return;
                  }
               }
            }
         }
      }
      
      private function createTweenFrom(param1:DisplayObject, param2:Object, param3:String = null) : void
      {
         if(param2.hasOwnProperty("twname"))
         {
            return;
         }
         if(param2.hasOwnProperty("std"))
         {
            param3 = param2["std"];
            param2 = TweenTemplate.getTween(param3,param2);
            if(param2 == null)
            {
               trace("[TemplateTweenBuilder]","Missing std name:",param3);
               return;
            }
            if(param2 is Array)
            {
               for each(var _loc4_ in param2)
               {
                  createTweenFrom(param1,_loc4_,param3);
               }
               return;
            }
         }
         else if(TweenTemplate.hasHexColorDesc(param2))
         {
            param2 = UIBuilder.cloneObject(param2);
            param2 = TweenTemplate.updateTweenData(param2,{});
         }
         if(!param2.hasOwnProperty("time"))
         {
            trace("[TemplateTweenBuilder]","Missing tween param: time");
            return;
         }
         var _loc6_:Object = saveInitData(param1,param2.properties,param2.delta,param2.from,param2.fromDelta);
         var _loc7_:Object = createProperties(param1,param2,_loc6_);
         var _loc10_:* = Starling;
         var _loc5_:Object = starling.core.Starling.sCurrent.juggler.tween(param1,param2.time,_loc7_);
         if(!_saveData[param1])
         {
            _saveData[param1] = [];
         }
         if(param3 && TweenTemplate.needsSynchronize(param2))
         {
            synchronizeTween(_loc5_ as Tween,param3);
            _saveData[param1].push({
               "tween":_loc5_,
               "init":_loc6_,
               "template":param3
            });
         }
         else
         {
            _saveData[param1].push({
               "tween":_loc5_,
               "init":_loc6_
            });
         }
      }
      
      function _stop(param1:DisplayObject, param2:Dictionary = null, param3:Array = null, param4:Boolean = true) : void
      {
         var _loc5_:* = null;
         if(param2 == null || param3 == null)
         {
            stopAll(param1,param4);
         }
         else
         {
            _loc5_ = getDisplayObjectsByNames(param1,param2,param3);
            for each(var _loc6_ in _loc5_)
            {
               stopTween(_loc6_,param4);
            }
         }
      }
      
      public function stop(param1:DisplayObject, param2:Dictionary = null, param3:Array = null) : void
      {
         _stop(param1,param2,param3);
      }
      
      private function stopTween(param1:DisplayObject, param2:Boolean = true) : void
      {
         var _loc4_:* = null;
         var _loc3_:* = null;
         var _loc6_:Array;
         if(_loc6_ = _saveData[param1])
         {
            for each(var _loc5_ in _loc6_)
            {
               _loc4_ = _loc5_.init;
               if(param2)
               {
                  recoverInitData(param1,_loc4_);
               }
               _loc3_ = _loc5_.tween;
               if(_loc3_ is Tween)
               {
                  var _loc7_:* = Starling;
                  starling.core.Starling.sCurrent.juggler.remove(_loc3_ as Tween);
               }
               else
               {
                  var _loc8_:* = Starling;
                  starling.core.Starling.sCurrent.juggler["removeByID"](_loc3_ as uint);
               }
            }
         }
         delete _saveData[param1];
      }
      
      private function createProperties(param1:Object, param2:Object, param3:Object) : Object
      {
         var _loc6_:* = null;
         var _loc8_:* = null;
         var _loc4_:* = null;
         var _loc10_:* = null;
         var _loc5_:* = null;
         var _loc7_:* = null;
         var _loc9_:Object = {};
         if(param2.hasOwnProperty("from"))
         {
            _loc8_ = param2.from;
            for(_loc6_ in _loc8_)
            {
               if(param1.hasOwnProperty(_loc6_))
               {
                  param1[_loc6_] = _loc8_[_loc6_];
                  _loc9_[_loc6_] = param3[_loc6_];
               }
            }
         }
         if(param2.hasOwnProperty("fromDelta"))
         {
            _loc4_ = param2.fromDelta;
            for(_loc6_ in _loc4_)
            {
               if(param1.hasOwnProperty(_loc6_))
               {
                  var _loc12_:* = _loc6_;
                  var _loc11_:* = param1[_loc12_] + _loc4_[_loc6_];
                  param1[_loc12_] = _loc11_;
                  _loc9_[_loc6_] = param3[_loc6_];
               }
            }
         }
         if(param2.hasOwnProperty("properties"))
         {
            _loc10_ = UIBuilder.cloneObject(param2.properties);
            if(param2.properties.hasOwnProperty("onComplete"))
            {
               _loc5_ = param2.properties.onComplete;
               _loc10_["onComplete"] = _loc5_;
            }
         }
         else
         {
            _loc10_ = {};
         }
         if(param2.hasOwnProperty("delta"))
         {
            _loc7_ = param2.delta;
            for(_loc6_ in _loc7_)
            {
               if(param1.hasOwnProperty(_loc6_))
               {
                  _loc10_[_loc6_] = param1[_loc6_] + _loc7_[_loc6_];
               }
            }
         }
         for(_loc6_ in _loc9_)
         {
            if(!_loc10_.hasOwnProperty(_loc6_))
            {
               _loc10_[_loc6_] = _loc9_[_loc6_];
            }
         }
         return _loc10_;
      }
      
      private function recoverInitData(param1:Object, param2:Object) : void
      {
         for(var _loc3_ in param2)
         {
            param1[_loc3_] = param2[_loc3_];
         }
      }
      
      private function saveInitData(param1:Object, param2:Object, param3:Object, param4:Object, param5:Object) : Object
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
      
      private function stopAll(param1:DisplayObject, param2:Boolean = true) : void
      {
         var _loc3_:DisplayObjectContainer = param1 as DisplayObjectContainer;
         for(var _loc4_ in _saveData)
         {
            if(param1 === _loc4_ || _loc3_ && _loc3_.contains(_loc4_ as DisplayObject))
            {
               stopTween(_loc4_ as DisplayObject,param2);
            }
         }
      }
   }
}
