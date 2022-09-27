package gudetama.ui
{
   import gudetama.data.UserDataWrapper;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import muku.display.ContainerButton;
   import muku.display.PagedScrollContainer;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class HomeScroller extends UIBase
   {
      
      private static const NUM_PAGE:int = 2;
      
      private static const TIME_SCROLL:Number = 1;
       
      
      private var scene:BaseScene;
      
      private var isFriend:Boolean;
      
      private var scrollGroup:Sprite;
      
      private var scrollContainer:PagedScrollContainer;
      
      private var leftButton:ContainerButton;
      
      private var rightButton:ContainerButton;
      
      private var scrollCallback:Function;
      
      private var scrollToPageCallback:Function;
      
      private var throwToPageCallback:Function;
      
      private var currentPageIndex:int;
      
      private var isTutorial:Boolean;
      
      private var startScale:Number = 1;
      
      private var endScale:Number = 1;
      
      private var time:Number = 1;
      
      private var startFocusX:Number = 0;
      
      private var startFocusY:Number = 0;
      
      private var endFocusX:Number = 0;
      
      private var endFocusY:Number = 0;
      
      private var pastTime:Number;
      
      private var zoomCallback:Function;
      
      public function HomeScroller(param1:Sprite, param2:BaseScene, param3:Function, param4:Function, param5:Boolean = false)
      {
         super(param1);
         this.scene = param2;
         this.throwToPageCallback = param3;
         this.scrollCallback = param4;
         this.isFriend = param5;
         scrollGroup = param1.getChildByName("scrollGroup") as Sprite;
         scrollContainer = scrollGroup.getChildByName("scrollContainer") as PagedScrollContainer;
         scrollContainer.hasElasticEdges = false;
         scrollContainer.clipContent = false;
         scrollContainer.paddingRight = scrollContainer.width / 2;
         scrollContainer.pageWidth = scrollContainer.width / 2;
         scrollContainer.pageThrowDuration = 1;
         scrollContainer.availableTouchBlocker = false;
         scrollContainer.verticalScrollPolicy = "off";
         scrollContainer.addEventListener("scrollComplete",scrollComplete);
         scrollContainer.addEventListener("scroll",scroll);
         scrollContainer.horizontalThrowToPageCallback = horizontalThrowToPageCallback;
         var _loc6_:* = Engine;
         if(gudetama.engine.Engine.platform == 1 || gudetama.engine.Engine.platform == 0)
         {
            scrollContainer.minimumDragDistance = 0.1;
         }
         scrollContainer.pageMoveHorizonValue = scrollContainer.pageWidth / 6;
         leftButton = (param1.getChildByName("leftButton") as Sprite).getChildByName("ArrowButton") as ContainerButton;
         leftButton.addEventListener("triggered",triggeredLeftButton);
         rightButton = (param1.getChildByName("rightButton") as Sprite).getChildByName("ArrowButton") as ContainerButton;
         rightButton.addEventListener("triggered",triggeredRightButton);
         leftButton.visible = false;
         rightButton.visible = false;
      }
      
      public function resetViewPort() : void
      {
         scrollContainer.viewPort.width = scrollContainer.width;
         scrollContainer.viewPort.width -= 30;
      }
      
      public function setHorizontalScrollPolicy(param1:String) : void
      {
         scrollContainer.horizontalScrollPolicy = param1;
      }
      
      public function setTutorialFlag(param1:Boolean) : void
      {
         isTutorial = param1;
      }
      
      public function setRightButtonVisible(param1:Boolean) : void
      {
         if(isTutorial)
         {
            rightButton.visible = false;
            return;
         }
         rightButton.visible = param1;
      }
      
      public function setLeftButtonVisible(param1:Boolean) : void
      {
         if(isTutorial)
         {
            leftButton.visible = false;
            return;
         }
         leftButton.visible = param1;
      }
      
      public function throwHorizontally() : void
      {
         scrollContainer.throwHorizontally();
      }
      
      public function setupLeftAndRightButton() : void
      {
         if(UserDataWrapper.wrapper.lastHomeScrollPositionIsRight())
         {
            setLeftButtonVisible(true);
            setRightButtonVisible(false);
         }
         else
         {
            setLeftButtonVisible(false);
            setRightButtonVisible(true);
         }
      }
      
      public function setupLeft() : void
      {
         TweenAnimator.startItself(leftButton,"hide");
         setLeftButtonVisible(false);
         TweenAnimator.startItself(rightButton,"start");
         setRightButtonVisible(true);
      }
      
      private function horizontalThrowToPageCallback(param1:int) : void
      {
         var pageIndex:int = param1;
         currentPageIndex = pageIndex;
         if(pageIndex == 0)
         {
            TweenAnimator.startItself(leftButton,"hide",false,function():void
            {
               setLeftButtonVisible(false);
            });
            scene.getSceneJuggler().delayCall(function():void
            {
               if(currentPageIndex == 0)
               {
                  setRightButtonVisible(true);
                  TweenAnimator.startItself(rightButton,"start");
               }
            },0.7);
            if(!isFriend)
            {
               UserDataWrapper.wrapper.setHomeScrollPosition(1);
            }
         }
         else
         {
            scene.getSceneJuggler().delayCall(function():void
            {
               if(currentPageIndex != 0)
               {
                  setLeftButtonVisible(true);
                  TweenAnimator.startItself(leftButton,"start");
               }
            },0.7);
            TweenAnimator.startItself(rightButton,"hide",false,function():void
            {
               setRightButtonVisible(false);
            });
            if(!isFriend)
            {
               UserDataWrapper.wrapper.setHomeScrollPosition(0);
            }
         }
         if(throwToPageCallback)
         {
            throwToPageCallback(currentPageIndex);
         }
      }
      
      private function scrollComplete(param1:Event) : void
      {
         Engine.unlockTouchInput(HomeScroller);
         if(scrollToPageCallback)
         {
            scrollToPageCallback();
            scrollToPageCallback = null;
         }
      }
      
      private function scroll(param1:Event) : void
      {
         var _loc2_:Number = (scrollContainer.horizontalScrollPosition - scrollContainer.minHorizontalScrollPosition) / (scrollContainer.maxHorizontalScrollPosition - scrollContainer.minHorizontalScrollPosition);
         if(scrollCallback)
         {
            scrollCallback(_loc2_);
         }
      }
      
      private function triggeredLeftButton(param1:Event) : void
      {
         Engine.lockTouchInput(HomeScroller);
         scrollLeft();
      }
      
      public function scrollLeft() : void
      {
         scrollContainer.scrollToPageIndex(0,scrollContainer.verticalPageIndex,1);
      }
      
      private function triggeredRightButton(param1:Event) : void
      {
         Engine.lockTouchInput(HomeScroller);
         scrollRight();
      }
      
      public function scrollRight() : void
      {
         scrollContainer.scrollToPageIndex(scrollContainer.horizontalPageCount - 1,scrollContainer.verticalPageIndex,1);
      }
      
      public function scrollToPageIndex(param1:int, param2:Number = -1, param3:Function = null) : void
      {
         if(param2 < 0)
         {
            param2 = 1;
         }
         Engine.lockTouchInput(HomeScroller);
         scrollContainer.scrollToPageIndex(param1,scrollContainer.verticalPageIndex,param2);
         scrollToPageCallback = param3;
      }
      
      public function get horizontalPageCount() : int
      {
         return scrollContainer.horizontalPageCount;
      }
      
      public function zoom(param1:Number, param2:Number = 1.0, param3:Number = 0, param4:Number = 0, param5:Function = null) : void
      {
         startScale = endScale;
         endScale = param1;
         this.time = param2;
         startFocusX = endFocusX;
         var _loc6_:* = Engine;
         endFocusX = 0.5 * gudetama.engine.Engine.designWidth - param3 * endScale;
         startFocusY = endFocusY;
         var _loc7_:* = Engine;
         endFocusY = 0.5 * gudetama.engine.Engine.designHeight - param4 * endScale;
         pastTime = 0;
         zoomCallback = param5;
      }
      
      public function advanceTime(param1:Number) : void
      {
         if(startScale == endScale)
         {
            return;
         }
         if(pastTime >= time)
         {
            if(zoomCallback)
            {
               zoomCallback();
               zoomCallback = null;
            }
            return;
         }
         pastTime = Math.min(pastTime + param1,time);
         var _loc2_:Number = pastTime / time;
         scrollGroup.scale = startScale + (endScale - startScale) * _loc2_;
         var _loc5_:* = Engine;
         var _loc3_:Number = gudetama.engine.Engine.designWidth * (1 - scrollGroup.scale);
         var _loc6_:* = Engine;
         var _loc4_:Number = gudetama.engine.Engine.designHeight * (1 - scrollGroup.scale);
         scrollGroup.x = Math.max(_loc3_,Math.min(0,startFocusX + (endFocusX - startFocusX) * _loc2_));
         scrollGroup.y = Math.max(_loc4_,Math.min(0,startFocusY + (endFocusY - startFocusY) * _loc2_));
      }
      
      public function dispose() : void
      {
         scene = null;
         scrollGroup = null;
         scrollContainer.removeEventListener("scroll",scroll);
         scrollContainer.removeEventListener("scrollComplete",scrollComplete);
         scrollContainer = null;
         leftButton.removeEventListener("triggered",triggeredLeftButton);
         leftButton = null;
         rightButton.removeEventListener("triggered",triggeredRightButton);
         rightButton = null;
         scrollToPageCallback = null;
      }
   }
}
