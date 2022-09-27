package muku.display
{
   import flash.geom.Point;
   import gudetama.common.EffectPlayerManager;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import muku.core.MukuGlobal;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   import starling.display.DisplayObjectContainer;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class EffectPlayer extends Sprite
   {
      
      public static const EFFECT_FINISH_EVENT:String = "effect_finish";
      
      public static const EFFECT_COMPLETED:String = "effect_completed";
       
      
      private var mEffects:Vector.<Effect>;
      
      private var mEnableCache:Boolean;
      
      private var mEffectName:String;
      
      private var mInLayout:Boolean;
      
      public function EffectPlayer(param1:String = null, param2:Boolean = false)
      {
         mEffects = new Vector.<Effect>();
         super();
         touchable = MukuGlobal.isBuilderMode();
         mEnableCache = param2;
         mEffectName = param1;
         addEventListener("removedFromStage",finishAll);
      }
      
      private static function _isLoaded(param1:EffectPlayer) : Boolean
      {
         var _loc2_:* = null;
         var _loc3_:* = null;
         var _loc4_:Vector.<Effect> = param1.mEffects;
         for each(_loc2_ in _loc4_)
         {
            _loc3_ = _loc2_.getObject();
            if(_loc3_ is EffectPlayer)
            {
               if(!_isLoaded(_loc3_ as EffectPlayer))
               {
                  return false;
               }
            }
            if(!_loc2_.isLoaded())
            {
               return false;
            }
         }
         return true;
      }
      
      public function isLoaded() : Boolean
      {
         return _isLoaded(this);
      }
      
      override public function dispose() : void
      {
         var _loc1_:* = null;
         super.dispose();
         if(!mEffects || mEffects.length <= 0)
         {
            return;
         }
         for each(_loc1_ in mEffects)
         {
            _loc1_.dispose();
         }
         mEffects.length = 0;
      }
      
      public function setup(param1:Object) : void
      {
         _setup(param1,this);
      }
      
      private function _setup(param1:Object, param2:Sprite = null) : void
      {
         var _loc4_:* = null;
         var _loc3_:Array = param1.children;
         for each(var _loc5_ in _loc3_)
         {
            if(_loc5_.cls == "muku.display.EffectPlayer")
            {
               (_loc4_ = param2.getChildByName(_loc5_.params.name) as EffectPlayer).setup(_loc5_);
               mEffects.push(new Effect(_loc4_,_loc5_,mEnableCache));
            }
            else
            {
               if(_loc5_.hasOwnProperty("children"))
               {
                  _setup(_loc5_);
               }
               if(param2)
               {
                  mEffects.push(new Effect(param2.getChildByName(_loc5_.params.name),_loc5_,mEnableCache));
               }
            }
         }
      }
      
      override public function addChildAt(param1:DisplayObject, param2:int) : DisplayObject
      {
         if(mInLayout)
         {
            mEffects.push(new Effect(param1,param1.userObject,mEnableCache));
         }
         return super.addChildAt(param1,param2);
      }
      
      public function init(param1:DisplayObjectContainer, param2:DisplayObjectContainer = null) : void
      {
         param1.addChild(this);
         setTargetSpace(param2);
      }
      
      public function setTargetSpace(param1:DisplayObjectContainer = null) : void
      {
         var _loc2_:* = null;
         var _loc3_:* = null;
         for each(_loc2_ in mEffects)
         {
            if(_loc2_.getObject() is Particle)
            {
               _loc3_ = _loc2_.getObject() as Particle;
               if(_loc3_.isTargetSpaceExtra())
               {
                  _loc3_.targetSpace = param1;
               }
               else if(_loc3_.isTargetSpaceParent())
               {
                  _loc3_.targetSpace = parent;
               }
               else
               {
                  _loc3_.targetSpace = null;
               }
            }
         }
      }
      
      public function start() : void
      {
         var base:EffectPlayer = this;
         var delayCallback:Function = function():void
         {
            var checkLoaded:Function = function(param1:EffectPlayer):Boolean
            {
               var _loc2_:* = null;
               list = param1.mEffects;
               for each(effect in list)
               {
                  _loc2_ = effect.getObject() as EffectPlayer;
                  if(_loc2_ && !checkLoaded(_loc2_))
                  {
                     return false;
                  }
                  if(!effect.isLoaded())
                  {
                     Engine.addSequentialCallback(delayCallback);
                     return false;
                  }
               }
               return true;
            };
            if(!checkLoaded(base))
            {
               return;
            }
            var startFunc:Function = function(param1:EffectPlayer):void
            {
               var _loc2_:* = null;
               list = param1.mEffects;
               for each(effect in list)
               {
                  _loc2_ = effect.getObject() as EffectPlayer;
                  if(_loc2_)
                  {
                     startFunc(_loc2_);
                  }
                  else
                  {
                     effect.reset();
                     var _loc3_:* = Starling;
                     (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).add(effect);
                     effect.addEventListener("effect_finish",finish);
                  }
               }
            };
            startFunc(base);
         };
         delayCallback();
      }
      
      public function finishAll() : void
      {
         var _loc1_:* = null;
         if(!mEnableCache)
         {
            removeEventListener("removedFromStage",finishAll);
         }
         for each(_loc1_ in mEffects)
         {
            _loc1_.finish();
         }
      }
      
      public function finish(param1:Event = null) : void
      {
         var _loc3_:* = null;
         var _loc2_:* = null;
         if(param1)
         {
            param1.target.removeEventListener("effect_finish",finish);
            _loc3_ = param1.target as Effect;
            if(!_loc3_.isFinished())
            {
               _loc3_.finish();
            }
         }
         for each(_loc2_ in mEffects)
         {
            if(!_loc2_.isFinished())
            {
               return;
            }
         }
         dispatchEventWith("effect_completed");
         if(mEnableCache)
         {
            EffectPlayerManager.releaseEffectPlayer(this);
         }
         if(!inLayout)
         {
            removeFromParent(!mEnableCache);
         }
      }
      
      public function movePos(param1:Point, param2:Point, param3:Number, param4:String = "MOVE_POS") : void
      {
         x = param1.x;
         y = param1.y;
         param2.x -= param1.x;
         param2.y -= param1.y;
         TweenAnimator.startTween(this,param4,{
            "deltaX":param2.x,
            "deltaY":param2.y,
            "time":param3
         });
      }
      
      public function changeColor(param1:uint) : void
      {
         var _loc2_:* = null;
         for each(_loc2_ in mEffects)
         {
            if(_loc2_.isFinished())
            {
               return;
            }
            _loc2_.changeColor(param1);
         }
      }
      
      public function get effectName() : String
      {
         return mEffectName;
      }
      
      public function set effectName(param1:String) : void
      {
         mEffectName = param1;
      }
      
      public function get cacheEnabled() : Boolean
      {
         return mEnableCache;
      }
      
      public function set cacheEnabled(param1:Boolean) : void
      {
         mEnableCache = param1;
      }
      
      public function get inLayout() : Boolean
      {
         return mInLayout;
      }
      
      public function set inLayout(param1:Boolean) : void
      {
         mInLayout = param1;
      }
   }
}

import gudetama.engine.TweenAnimator;
import muku.display.EffectPlayer;
import muku.display.Particle;
import muku.display.SpineModel;
import starling.animation.IAnimatable;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.MovieClip;
import starling.display.Sprite;
import starling.events.EventDispatcher;

class Effect extends EventDispatcher implements IAnimatable
{
   
   private static const STATE_NONE:int = 0;
   
   private static const STATE_SHOW:int = 1;
   
   private static const STATE_HIDE:int = 2;
    
   
   private var mObject:DisplayObject;
   
   private var mAppearTime:Number;
   
   private var mDisappearTime:Number;
   
   private var mLoop:Boolean;
   
   private var mCurrentTime:Number;
   
   private var mState:int;
   
   private var mSaveCustomParams:Object;
   
   private var mCustomParams:Object;
   
   private var mHasStartTween:Boolean;
   
   private var mHasFinishTween:Boolean;
   
   private var mHasLoopTween:Boolean;
   
   private var cache:Boolean;
   
   private var finished:Boolean;
   
   function Effect(param1:DisplayObject, param2:Object, param3:Boolean)
   {
      var obj:DisplayObject = param1;
      var data:Object = param2;
      var cacheEnable:Boolean = param3;
      super();
      mObject = obj;
      cache = cacheEnable;
      var effectData:Object = data.effectData;
      mAppearTime = effectData.appearTime;
      mDisappearTime = effectData.disappearTime;
      mLoop = effectData.loop as Boolean;
      if(data.hasOwnProperty("tweenData"))
      {
         var tweenNames:Vector.<String> = TweenAnimator.getTweenNameList(data.tweenData);
         for each(tw in tweenNames)
         {
            if(!mHasStartTween)
            {
               mHasStartTween = "start" == tw;
            }
            if(!mHasFinishTween)
            {
               mHasFinishTween = "finish" == tw;
            }
            if(!mHasLoopTween)
            {
               mHasLoopTween = "loop" == tw;
            }
         }
      }
      if(effectData.hasOwnProperty("customParams") && effectData.customParams)
      {
         if(mObject is SpineModel)
         {
            var pushStateData:* = function(param1:Number, param2:String):void
            {
               list.push({
                  "time":param1,
                  "state":param2,
                  "loop":param2.lastIndexOf("loop") >= 0
               });
            };
            var list:Vector.<Object> = new Vector.<Object>();
            var params:Object = effectData.customParams;
            if(params is Array)
            {
               for each(param in params)
               {
                  pushStateData(param.state.time,param.state.name);
               }
            }
            else
            {
               var stateData:Object = effectData.customParams.state;
               pushStateData(stateData.time,stateData.name);
            }
            list.sort(function(param1:Object, param2:Object):Number
            {
               return param1.time - param2.time;
            });
            mCustomParams = list;
            if(mLoop || cache)
            {
               mSaveCustomParams = list.slice();
            }
         }
      }
      reset();
   }
   
   public function getObject() : DisplayObject
   {
      return mObject;
   }
   
   public function reset() : void
   {
      mState = 0;
      mCurrentTime = 0;
      finished = false;
      if(cache)
      {
         if(mSaveCustomParams is Vector.<Object>)
         {
            mCustomParams = mSaveCustomParams.slice();
         }
      }
   }
   
   public function isLoaded() : Boolean
   {
      var _loc2_:* = null;
      var _loc4_:* = undefined;
      var _loc3_:int = 0;
      var _loc1_:* = null;
      if(mObject is Particle)
      {
         return (mObject as Particle).isLoaded();
      }
      if(mObject is MovieClip)
      {
         return true;
      }
      if(mObject is SpineModel)
      {
         _loc2_ = mObject as SpineModel;
         if(_loc2_.isLoaded())
         {
            _loc4_ = mCustomParams as Vector.<Object>;
            _loc3_ = 0;
            while(_loc3_ < _loc4_.length)
            {
               _loc1_ = _loc4_[_loc3_];
               if(_loc3_ == 0)
               {
                  _loc2_.changeAnimation(_loc1_.state);
               }
               else
               {
                  _loc2_.appendAnimation(_loc1_.state,0,_loc1_.time);
               }
               _loc3_++;
            }
            return true;
         }
      }
      else if(mObject is Image || mObject is EffectPlayer || mObject is Sprite)
      {
         return true;
      }
      return false;
   }
   
   public function advanceTime(param1:Number) : void
   {
      if(mState == 0 && mCurrentTime >= mAppearTime)
      {
         show();
         if(mHasStartTween)
         {
            TweenAnimator.startItself(mObject,"start");
         }
      }
      if(mState == 1 && mDisappearTime > 0 && mCurrentTime >= mDisappearTime)
      {
         mState = 2;
         if(mHasFinishTween)
         {
            TweenAnimator.startItself(mObject,"finish",false,hide);
         }
         else
         {
            hide();
         }
      }
      mCurrentTime += param1;
   }
   
   private function show() : void
   {
      var _loc2_:* = null;
      var _loc1_:* = null;
      mState = 1;
      if(mObject is Particle)
      {
         _loc2_ = mObject as Particle;
         _loc2_.show();
      }
      else if(mObject is MovieClip)
      {
         var _loc3_:* = Starling;
         (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).add(mObject as MovieClip);
         (mObject as MovieClip).play();
      }
      else if(mObject is Image)
      {
         _loc1_ = mObject as Image;
         _loc1_.visible = true;
      }
      else if(mObject is SpineModel)
      {
         (mObject as SpineModel).show();
      }
   }
   
   private function hide(param1:DisplayObject = null) : void
   {
      var dObj:DisplayObject = param1;
      if(mLoop)
      {
         reset();
         if(mObject is SpineModel)
         {
            mCustomParams = (mSaveCustomParams as Vector.<Object>).slice();
         }
         return;
      }
      if(mObject is Particle)
      {
         var particle:Particle = mObject as Particle;
         particle.setRemoveCallback(function():void
         {
            dispatchEventWith("effect_finish");
         });
         particle.hide();
      }
      else if(mObject is MovieClip)
      {
         (mObject as MovieClip).stop();
         (mObject as MovieClip).dispatchEventWith("removeFromJuggler");
         dispatchEventWith("effect_finish");
      }
      else if(mObject is Image)
      {
         var image:Image = mObject as Image;
         image.visible = false;
         dispatchEventWith("effect_finish");
      }
      else if(mObject is SpineModel)
      {
         (mObject as SpineModel).hide();
         dispatchEventWith("effect_finish");
      }
      else
      {
         dispatchEventWith("effect_finish");
      }
      dispatchEventWith("removeFromJuggler");
   }
   
   public function changeColor(param1:uint) : void
   {
      var _loc2_:* = null;
      if(mObject is Image)
      {
         _loc2_ = mObject as Image;
         _loc2_.color = param1;
      }
   }
   
   public function finish() : void
   {
      var _loc1_:* = null;
      if(mObject is Particle)
      {
         _loc1_ = mObject as Particle;
         _loc1_.hide();
         _loc1_.onRemove(null);
      }
      else if(mObject is MovieClip)
      {
         (mObject as MovieClip).stop();
         (mObject as MovieClip).dispatchEventWith("removeFromJuggler");
      }
      else if(mObject is SpineModel)
      {
         (mObject as SpineModel).finish(cache);
      }
      finished = true;
      dispatchEventWith("effect_finish");
      dispatchEventWith("removeFromJuggler");
   }
   
   public function isFinished() : Boolean
   {
      return finished;
   }
   
   public function dispose() : void
   {
      var _loc1_:* = null;
      if(mObject is Particle)
      {
         _loc1_ = mObject as Particle;
         _loc1_.onRemove(null);
      }
      else if(mObject is MovieClip)
      {
         (mObject as MovieClip).stop();
         (mObject as MovieClip).dispatchEventWith("removeFromJuggler");
      }
      else if(mObject is SpineModel)
      {
         (mObject as SpineModel).onRemove();
      }
      dispatchEventWith("removeFromJuggler");
      removeEventListeners();
      mObject = null;
   }
}
