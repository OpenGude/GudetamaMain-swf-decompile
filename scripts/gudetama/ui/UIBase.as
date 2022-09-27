package gudetama.ui
{
   import gudetama.engine.SceneControl;
   import gudetama.engine.TweenAnimator;
   import starling.display.Sprite;
   
   public class UIBase
   {
       
      
      protected var baseControl:SceneControl;
      
      protected var displaySprite:Sprite;
      
      protected var tweenLocked:Boolean;
      
      public function UIBase(param1:Sprite, param2:SceneControl = null)
      {
         super();
         displaySprite = param1;
         baseControl = param2;
      }
      
      public function getDisplaySprite() : Sprite
      {
         return displaySprite;
      }
      
      public function setTouchable(param1:Boolean) : void
      {
         displaySprite.touchable = param1;
      }
      
      public function setVisible(param1:Boolean) : void
      {
         displaySprite.visible = param1;
      }
      
      public function isVisible() : Boolean
      {
         return displaySprite.visible;
      }
      
      public function moveIn(param1:Function = null) : void
      {
         if(isVisible())
         {
            if(param1)
            {
               param1();
            }
            return;
         }
         setVisible(true);
         if(!TweenAnimator.startItselfWithoutFinish(displaySprite,"moveIn",false,param1))
         {
            TweenAnimator.startTween(displaySprite,"FADEIN_ALPHA",null,param1);
         }
      }
      
      public function moveOut(param1:Function = null) : void
      {
         var callback:Function = param1;
         var setVisibleFunc:* = function():void
         {
            setVisible(false);
            if(callback)
            {
               callback();
            }
         };
         if(!isVisible())
         {
            if(callback)
            {
               callback();
            }
            return;
         }
         if(!TweenAnimator.startItselfWithoutFinish(displaySprite,"moveOut",false,setVisibleFunc))
         {
            TweenAnimator.startTween(displaySprite,"FADEOUT_ALPHA",null,setVisibleFunc);
         }
      }
      
      public function startTweenWithoutFinish(param1:String, param2:Boolean = false, param3:Function = null) : void
      {
         if(tweenLocked)
         {
            return;
         }
         TweenAnimator.startItselfWithoutFinish(displaySprite,param1,param2,param3);
      }
      
      public function startTween(param1:String, param2:Boolean = false, param3:Function = null) : void
      {
         if(tweenLocked)
         {
            return;
         }
         TweenAnimator.startItself(displaySprite,param1,param2,param3);
      }
      
      public function finishTween() : void
      {
         if(tweenLocked)
         {
            return;
         }
         TweenAnimator.finishItself(displaySprite);
      }
      
      public function cancelTween() : void
      {
         if(tweenLocked)
         {
            return;
         }
         TweenAnimator.cancel(displaySprite);
      }
      
      public function setTweenLocked(param1:Boolean) : void
      {
         tweenLocked = param1;
      }
      
      public function setAlpha(param1:Number) : void
      {
         displaySprite.alpha = param1;
      }
   }
}
