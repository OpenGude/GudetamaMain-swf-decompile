package gudetama.engine
{
   import muku.core.TaskQueue;
   import muku.display.SpineModel;
   import muku.util.SpineUtil;
   import spine.SkeletonData;
   import spine.animation.AnimationStateData;
   import spine.animation.TrackEntry;
   import spine.starling.SkeletonAnimation;
   import starling.core.Starling;
   
   public final class TouchEffect
   {
      
      private static var sEffectPool:Vector.<SkeletonAnimation> = new Vector.<SkeletonAnimation>(0);
       
      
      public function TouchEffect()
      {
         super();
      }
      
      public static function init(param1:TaskQueue) : void
      {
         var queue:TaskQueue = param1;
         var i:int = 0;
         while(i < 10)
         {
            var effect:SpineModel = new SpineModel();
            queue.addTask(function():void
            {
               SpineUtil.loadSkeletonAnimation("efx_spine-tap_spine",function(param1:SkeletonData, param2:AnimationStateData):void
               {
                  var _loc3_:SkeletonAnimation = new SkeletonAnimation(param1,param2);
                  _loc3_.touchable = false;
                  _loc3_.skeleton.setToSetupPose();
                  _loc3_.state.update(0);
                  _loc3_.state.apply(_loc3_.skeleton);
                  _loc3_.skeleton.updateWorldTransform();
                  toPool(_loc3_);
                  queue.taskDone();
               },null,1);
            });
            i++;
         }
      }
      
      public static function show(param1:Number, param2:Number) : void
      {
         var x:Number = param1;
         var y:Number = param2;
         var effect:SkeletonAnimation = fromPool();
         if(!effect)
         {
            return;
         }
         effect.x = x;
         effect.y = y;
         var trackEntry:TrackEntry = effect.state.setAnimationByName(0,"start",false);
         trackEntry.onComplete.add(function(param1:TrackEntry):void
         {
            toPool(effect);
            effect.dispatchEventWith("removeFromJuggler");
            var _loc2_:* = Starling;
            starling.core.Starling.sCurrent.stage.removeChild(effect);
         });
         var _loc4_:* = Starling;
         (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).add(effect);
         var _loc5_:* = Starling;
         starling.core.Starling.sCurrent.stage.addChild(effect);
      }
      
      private static function fromPool() : SkeletonAnimation
      {
         if(sEffectPool.length)
         {
            return sEffectPool.pop();
         }
         return null;
      }
      
      private static function toPool(param1:SkeletonAnimation) : void
      {
         sEffectPool.push(param1);
      }
   }
}
