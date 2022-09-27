package muku.display
{
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import muku.core.MukuGlobal;
   import spine.Bone;
   import starling.animation.IAnimatable;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   import starling.events.Event;
   
   public class SpineSkitModel extends SpineModel implements IAnimatable
   {
      
      public static const FINISHED_EVENT:String = "finished";
      
      private static const SPINE_EVENT_TYPE_EFFECT:String = "effect";
      
      private static const SPINE_EVENT_TYPE_FINISH:String = "finish";
      
      private static const SPINE_EVENT_TYPE_SHAKE:String = "shake";
       
      
      private var mUpdateCacheList:Vector.<Object>;
      
      public function SpineSkitModel()
      {
         super();
         mUpdateCacheList = new Vector.<Object>();
      }
      
      override public function dispose() : void
      {
         dispatchEventWith("removeFromJuggler");
         super.dispose();
      }
      
      override public function isLoaded() : Boolean
      {
         var _loc1_:* = null;
         var _loc3_:int = 0;
         var _loc2_:int = numChildren;
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            _loc1_ = getChildAt(_loc3_);
            if(_loc1_ is EffectPlayer)
            {
               if(!(_loc1_ as EffectPlayer).isLoaded())
               {
                  return false;
               }
            }
            else if(_loc1_ is SpineModel)
            {
               if(!(_loc1_ as SpineModel).isLoaded())
               {
                  return false;
               }
            }
            _loc3_++;
         }
         return super.isLoaded();
      }
      
      public function advanceTime(param1:Number) : void
      {
         var _loc5_:* = null;
         var _loc2_:* = null;
         var _loc4_:* = null;
         var _loc3_:int = mUpdateCacheList.length;
         for each(_loc5_ in mUpdateCacheList)
         {
            _loc2_ = _loc5_.actor;
            _loc4_ = _loc5_.bone as Bone;
            if(_loc2_ && _loc4_ && !_loc5_.fixed)
            {
               _loc2_.x = _loc4_.worldX;
               _loc2_.y = _loc4_.worldY;
            }
         }
      }
      
      override public function show() : void
      {
         super.show();
         if(mSkeletonAnimation)
         {
            var _loc1_:* = Starling;
            starling.core.Starling.sCurrent.juggler.add(this);
         }
      }
      
      override public function hide(param1:int = -1) : void
      {
         super.hide(param1);
         if(mSkeletonAnimation)
         {
            dispatchEventWith("removeFromJuggler");
         }
      }
      
      override public function finish(param1:Boolean = false) : void
      {
         var _loc3_:int = 0;
         var _loc2_:* = null;
         _loc3_ = numChildren - 1;
         while(_loc3_ >= 0)
         {
            _loc2_ = getChildAt(_loc3_);
            if(_loc2_ is EffectPlayer)
            {
               (_loc2_ as EffectPlayer).finishAll();
            }
            else if(_loc2_ is SpineModel)
            {
               (_loc2_ as SpineModel).finish();
            }
            _loc3_--;
         }
         onRemove();
         mUpdateCacheList.splice(0,mUpdateCacheList.length);
         removeFromParent(true);
         mShowed = false;
      }
      
      override public function onRemove(param1:Boolean = false) : void
      {
         if(mSkeletonAnimation)
         {
            dispatchEventWith("removeFromJuggler");
         }
         super.onRemove();
      }
      
      override protected function processUpdateEvent(param1:String, param2:Object) : void
      {
         if(param1 == "finish")
         {
            if(!hasEventListener("finished"))
            {
               finish();
            }
            if(!MukuGlobal.isBuilderMode())
            {
               dispatchEvent(new Event("finished"));
            }
         }
         else if(param1 == "shake")
         {
            TweenAnimator.shake(Engine.getSceneContainer(),param2.repeat,param2.x,param2.y,param2.time);
         }
         else if(param1.indexOf("effect") >= 0)
         {
            processEffectEvent(param2);
         }
      }
      
      private function processEffectEvent(param1:Object) : void
      {
         if(!param1.hasOwnProperty("effect"))
         {
            return;
         }
         var _loc3_:DisplayObject = getChildByName(param1.effect);
         var _loc4_:String;
         var _loc2_:Bone = !!(_loc4_ = param1.bone) ? mSkeletonAnimation.skeleton.findBone(_loc4_) : null;
         if(_loc2_ && _loc3_)
         {
            _loc3_.x = _loc2_.worldX;
            _loc3_.y = _loc2_.worldY;
            if(param1.hasOwnProperty("x"))
            {
               _loc3_.x += param1.x;
            }
            if(param1.hasOwnProperty("y"))
            {
               _loc3_.y += param1.y;
            }
         }
         if(_loc3_ is EffectPlayer)
         {
            (_loc3_ as EffectPlayer).init(this);
            (_loc3_ as EffectPlayer).start();
         }
         else
         {
            if(!(_loc3_ is SpineModel))
            {
               return;
            }
            (_loc3_ as SpineModel).show();
         }
         if(param1.fix as Boolean)
         {
            return;
         }
         mUpdateCacheList.push({
            "actor":_loc3_,
            "bone":_loc2_,
            "offsetX":(!!param1.hasOwnProperty("x") ? param1.x : 0),
            "offsetY":(!!param1.hasOwnProperty("y") ? param1.y : 0)
         });
      }
   }
}
