package spine.starling
{
   import spine.SkeletonData;
   import spine.animation.AnimationState;
   import spine.animation.AnimationStateData;
   import starling.animation.IAnimatable;
   
   public class SkeletonAnimation extends SkeletonSprite implements IAnimatable
   {
       
      
      public var state:AnimationState;
      
      public var timeScale:Number = 1;
      
      public function SkeletonAnimation(param1:SkeletonData, param2:AnimationStateData = null)
      {
         super(param1);
         state = new AnimationState(!!param2 ? param2 : new AnimationStateData(param1));
      }
      
      public function advanceTime(param1:Number) : void
      {
         param1 *= timeScale;
         skeleton.update(param1);
         state.update(param1);
         state.apply(skeleton);
         skeleton.updateWorldTransform();
         this.setRequiresRedraw();
      }
      
      public function setManuallyTime(param1:Number) : void
      {
         state.setManuallyTime(param1);
         state.apply(skeleton);
         skeleton.updateWorldTransform();
         this.setRequiresRedraw();
      }
      
      public function getManuallyTrackTime(param1:Number) : Number
      {
         return state.getManuallyTrackTime(param1);
      }
   }
}
