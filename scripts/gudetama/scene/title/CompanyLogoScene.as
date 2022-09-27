package gudetama.scene.title
{
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.scene.initial.InitialScene;
   import muku.core.TaskQueue;
   import starling.core.Starling;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class CompanyLogoScene extends BaseScene
   {
       
      
      private var loadCount:int;
      
      private var processNow:Boolean = false;
      
      private var spLogo:Sprite;
      
      private var spCaution:Sprite;
      
      private var quad4Touch:Quad;
      
      public function CompanyLogoScene()
      {
         super(0);
         addEventListener("refreshed_scene_container",refreshedSceneContainer);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"CompanyLogoLayout",function(param1:Object):void
         {
            displaySprite = param1.object;
            spLogo = displaySprite.getChildByName("logoGroup") as Sprite;
            spCaution = displaySprite.getChildByName("spCaution") as Sprite;
            quad4Touch = displaySprite.getChildByName("quad4Touch") as Quad;
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
         });
         queue.startTask(onProgress);
      }
      
      private function setupLayoutForTask(param1:TaskQueue, param2:Object, param3:Function) : void
      {
         var queue:TaskQueue = param1;
         var layoutData:Object = param2;
         var callback:Function = param3;
         loadCount++;
         Engine.setupLayoutForTask(queue,layoutData,function(param1:Object):void
         {
            loadCount--;
            callback(param1);
            checkInit();
         });
      }
      
      private function addTask(param1:Function) : void
      {
         loadCount++;
         queue.addTask(param1);
      }
      
      private function taskDone() : void
      {
         loadCount--;
         checkInit();
         queue.taskDone();
      }
      
      private function checkInit() : void
      {
         if(loadCount > 0)
         {
            return;
         }
         Engine.lockTouchInput(CompanyLogoScene);
         TweenAnimator.startItself(spLogo,"show");
         TweenAnimator.startItself(spCaution,"def");
         var _loc1_:* = Starling;
         (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).delayCall(hideLogo,3);
      }
      
      private function hideLogo() : void
      {
         TweenAnimator.startItself(spLogo,"hide",false,function():void
         {
            showCaution();
         });
      }
      
      private function showCaution() : void
      {
         TweenAnimator.startItself(spCaution,"show");
         var _loc1_:* = Starling;
         (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).delayCall(touchOn,3);
         var _loc2_:* = Starling;
         (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).delayCall(goTitle,5);
      }
      
      private function touchOn() : void
      {
         quad4Touch.addEventListener("touch",procTouch);
      }
      
      private function procTouch() : void
      {
         quad4Touch.removeEventListener("touch",procTouch);
         goTitle();
      }
      
      private function goTitle() : void
      {
         if(processNow)
         {
            return;
         }
         processNow = true;
         TweenAnimator.startItself(spCaution,"hide",false,function():void
         {
            InitialScene.switchNextScene();
         });
      }
      
      override protected function addedToContainer() : void
      {
         showResidentMenuUI(1);
         displaySprite.visible = true;
      }
      
      override protected function transitionOpenFinished() : void
      {
         Engine.unlockTouchInput(CompanyLogoScene);
      }
      
      private function refreshedSceneContainer(param1:Event) : void
      {
      }
      
      override public function dispose() : void
      {
         removeEventListener("refreshed_scene_container",refreshedSceneContainer);
         super.dispose();
      }
   }
}
