package gudetama.ui
{
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import muku.display.SpineModel;
   import starling.display.Sprite;
   
   public class CupGachaAnimePanel extends BaseScene
   {
       
      
      private var animeName:String;
      
      private var startFunc:Function;
      
      private var finishFunc:Function;
      
      private var cupGudeID;
      
      private var spCupGach:Sprite;
      
      private var spineModel:SpineModel;
      
      public function CupGachaAnimePanel(param1:Boolean, param2:int, param3:Function, param4:Function)
      {
         super(2);
         this.startFunc = param3;
         this.finishFunc = param4;
         this.cupGudeID = param2;
         if(param1)
         {
            animeName = "open_shop";
         }
         else
         {
            animeName = "open_kettle";
         }
      }
      
      public static function show(param1:Boolean, param2:int, param3:Function, param4:Function) : void
      {
         Engine.showLoading(CupGachaAnimePanel);
         Engine.pushScene(new CupGachaAnimePanel(param1,param2,param3,param4),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"CupGachaAnimePanel",function(param1:Object):void
         {
            displaySprite = param1.object;
            spCupGach = displaySprite.getChildByName("sprite") as Sprite;
            spineModel = spCupGach.getChildByName("spineModel") as SpineModel;
            displaySprite.visible = false;
            addChild(displaySprite);
            queue.addTask(procAfterLayoutLoad);
         });
         queue.startTask(onProgress);
      }
      
      private function procAfterLayoutLoad() : void
      {
         var spineName:String = "cupgude-" + cupGudeID + "-spine";
         spineModel.finish();
         spineModel.load(spineName,function():void
         {
            queue.taskDone();
         });
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(CupGachaAnimePanel);
         setBackButtonCallback(null);
         setVisibleState(70);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         openAnime();
      }
      
      private function openAnime() : void
      {
         var panel:CupGachaAnimePanel = this;
         Engine.hideLoading(CupGachaAnimePanel);
         TweenAnimator.startItself(displaySprite,"fadeIn",false,function():void
         {
            Engine.unlockTouchInput(CupGachaAnimePanel);
            spineModel.show();
            spineModel.changeAnimation(animeName,false,function():void
            {
               spineAnimeEnded();
            });
         });
      }
      
      private function spineAnimeEnded() : void
      {
         spCupGach.visible = false;
         if(startFunc)
         {
            startFunc(this);
         }
         else
         {
            procClose(true);
         }
      }
      
      override public function backButtonCallback() : void
      {
         if(Engine.getGuideTalkPanel() != null)
         {
            return;
         }
      }
      
      public function procClose(param1:Boolean) : void
      {
         var useAnime:Boolean = param1;
         super.backButtonCallback();
         Engine.lockTouchInput(CupGachaAnimePanel);
         if(useAnime)
         {
            TweenAnimator.startItself(displaySprite,"fadeOut",false,function():void
            {
               _procClose();
            });
         }
         else
         {
            _procClose();
         }
      }
      
      private function _procClose() : void
      {
         Engine.unlockTouchInput(CupGachaAnimePanel);
         Engine.popScene(scene);
         if(finishFunc != null)
         {
            finishFunc();
         }
      }
      
      private function triggeredSkip() : void
      {
         spineAnimeEnded();
      }
      
      override public function dispose() : void
      {
         super.dispose();
      }
   }
}
