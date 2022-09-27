package gudetama.common
{
   import gudetama.engine.Engine;
   import gudetama.engine.Logger;
   import muku.core.TaskQueue;
   import muku.display.EffectPlayer;
   import muku.display.EffectPlayerWrapper;
   import starling.display.Sprite;
   
   public final class EffectPlayerManager
   {
      
      private static var cacheObject:Object = {};
      
      private static var loadingObserver:LoadingObserver;
       
      
      public function EffectPlayerManager()
      {
         super();
      }
      
      public static function disposeCache() : void
      {
         var _loc2_:int = 0;
         var _loc1_:int = 0;
         var _loc4_:* = null;
         var _loc3_:* = undefined;
         for(_loc4_ in cacheObject)
         {
            _loc3_ = cacheObject[_loc4_] as Vector.<EffectPlayer>;
            _loc1_ = _loc3_.length;
            if(_loc1_ > 0)
            {
               _loc2_ = 0;
               while(_loc2_ < _loc1_)
               {
                  _loc3_[_loc2_].dispose();
                  _loc2_++;
               }
               _loc3_.length = 0;
               _loc3_ = null;
               delete cacheObject[_loc4_];
            }
         }
         cacheObject = {};
         loadingObserver.dispose();
      }
      
      public static function setup() : void
      {
         loadingObserver = new LoadingObserver();
      }
      
      public static function acquireEffectPlayer(param1:String, param2:Boolean = true, param3:Function = null) : EffectPlayer
      {
         var _loc5_:* = undefined;
         var _loc4_:* = null;
         if(cacheObject.hasOwnProperty(param1))
         {
            if((_loc5_ = cacheObject[param1] as Vector.<EffectPlayer>).length > 0)
            {
               _loc4_ = _loc5_.shift();
               if(param3)
               {
                  param3(_loc4_);
               }
               return _loc4_;
            }
         }
         Logger.debug("acquireEffectPlayer create: " + param1);
         return create(param1,param2,param3);
      }
      
      public static function acquireEffectPlayerForTask(param1:TaskQueue, param2:String, param3:Boolean = true, param4:Function = null) : EffectPlayer
      {
         var _loc6_:* = undefined;
         var _loc5_:* = null;
         if(cacheObject.hasOwnProperty(param2))
         {
            if((_loc6_ = cacheObject[param2] as Vector.<EffectPlayer>).length > 0)
            {
               _loc5_ = _loc6_.pop() as EffectPlayer;
               if(param4)
               {
                  param4(_loc5_);
               }
               return _loc5_;
            }
         }
         return create(param2,param3,param4,param1);
      }
      
      public static function prepareEffectPlayersForTask(param1:TaskQueue, param2:Array) : void
      {
         var queue:TaskQueue = param1;
         var effectNames:Array = param2;
         for each(name in effectNames)
         {
            create(name,true,function(param1:EffectPlayer):void
            {
               releaseEffectPlayer(param1);
            },queue);
         }
      }
      
      public static function releaseEffectPlayer(param1:EffectPlayer) : void
      {
         var _loc2_:* = undefined;
         while(param1 is EffectPlayerWrapper)
         {
            param1 = (param1 as EffectPlayerWrapper).wrappee;
         }
         var _loc3_:String = param1.effectName;
         if(cacheObject.hasOwnProperty(_loc3_))
         {
            _loc2_ = cacheObject[_loc3_] as Vector.<EffectPlayer>;
         }
         else
         {
            _loc2_ = new Vector.<EffectPlayer>();
            cacheObject[_loc3_] = _loc2_;
         }
         _loc2_.push(param1);
      }
      
      private static function create(param1:String, param2:Boolean, param3:Function = null, param4:TaskQueue = null) : EffectPlayer
      {
         var effectName:String = param1;
         var enableCache:Boolean = param2;
         var loadedLayoutCallback:Function = param3;
         var queue:TaskQueue = param4;
         var preloaded:Boolean = true;
         var setupFunction:Function = function(param1:Object):void
         {
            var _loc2_:Sprite = param1.object as Sprite;
            var _loc3_:EffectPlayer = _loc2_.getChildAt(0) as EffectPlayer;
            _loc3_.effectName = effectName;
            _loc3_.setup(param1.data.layout.children[0]);
            if(preloaded)
            {
               result = _loc3_;
            }
            else
            {
               (result as EffectPlayerWrapper).wrap(_loc3_);
            }
            if(loadedLayoutCallback)
            {
               loadingObserver.addObservetion(result.isLoaded,loadedLayoutCallback,result);
            }
         };
         if(queue)
         {
            Engine.setupLayoutForTask(queue,effectName,setupFunction);
         }
         else
         {
            Engine.setupLayout(effectName,setupFunction);
         }
         preloaded = false;
         if(result != null)
         {
            return result;
         }
         var result:EffectPlayer = new EffectPlayerWrapper(effectName,enableCache);
         return result;
      }
   }
}

import starling.animation.IAnimatable;
import starling.core.Starling;

class LoadingObserver implements IAnimatable
{
    
   
   private var index:int;
   
   private var count:int;
   
   private var target:Object;
   
   private var loadingList:Vector.<Object>;
   
   function LoadingObserver()
   {
      loadingList = new Vector.<Object>();
      super();
   }
   
   public function addObservetion(param1:Function, param2:Function, param3:Object) : void
   {
      loadingList.push({
         "check":param1,
         "callback":param2,
         "argument":param3
      });
      if(count <= 0)
      {
         var _loc4_:* = Starling;
         (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).add(this);
      }
      count++;
   }
   
   public function dispose() : void
   {
      var _loc1_:* = null;
      var _loc3_:int = 0;
      var _loc2_:int = loadingList.length;
      count = 0;
      _loc3_ = 0;
      while(_loc3_ < _loc2_)
      {
         _loc1_ = loadingList[_loc3_];
         for(var _loc4_ in _loc1_)
         {
            delete _loc1_[_loc4_];
         }
         loadingList[_loc3_] = null;
         _loc3_++;
      }
      loadingList.length = 0;
      target = null;
   }
   
   public function advanceTime(param1:Number) : void
   {
      if(count <= 0)
      {
         var _loc2_:* = Starling;
         (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).remove(this);
         return;
      }
      index = count - 1;
      while(index >= 0)
      {
         target = loadingList[index];
         if(target.check())
         {
            target.callback(target.argument);
            loadingList.removeAt(index);
            count--;
         }
         index--;
      }
   }
}
