package gudetama.ui
{
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.KitchenwareDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.SoundManager;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.scene.shop.ShopScene_Gudetama;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class AcquiredKitchenwareDialog extends BaseScene
   {
      
      private static const ROTATE_TIME:Number = 10;
       
      
      private var kitchenwareId:int;
      
      private var callback:Function;
      
      private var titleText:ColorTextField;
      
      private var rotateImage:Image;
      
      private var iconImage:Image;
      
      private var descText:ColorTextField;
      
      private var closeButton:ContainerButton;
      
      private var passedTime:Number = 0;
      
      public function AcquiredKitchenwareDialog(param1:int, param2:Function)
      {
         super(2);
         this.kitchenwareId = param1;
         this.callback = param2;
      }
      
      public static function show(param1:Function = null) : void
      {
         var _loc2_:int = UserDataWrapper.kitchenwarePart.popNewlyActivatedKitchenware();
         if(_loc2_ <= 0)
         {
            if(param1)
            {
               param1();
            }
            return;
         }
         Engine.pushScene(new AcquiredKitchenwareDialog(_loc2_,param1),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"AcquiredKitchenwareDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            titleText = _loc2_.getChildByName("title") as ColorTextField;
            rotateImage = _loc2_.getChildByName("rotate") as Image;
            iconImage = _loc2_.getChildByName("icon") as Image;
            descText = _loc2_.getChildByName("desc") as ColorTextField;
            closeButton = _loc2_.getChildByName("btn_back") as ContainerButton;
            closeButton.addEventListener("triggered",triggeredCloseButton);
            displaySprite.visible = false;
            addChild(displaySprite);
            setup(queue);
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
      
      private function setup(param1:TaskQueue) : void
      {
         var queue:TaskQueue = param1;
         var kitchenwareDef:KitchenwareDef = GameSetting.getKitchenware(kitchenwareId);
         var name:String = kitchenwareDef.name#2;
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("kitchenware-" + kitchenwareId + "-icon",function(param1:Texture):void
            {
               iconImage.texture = param1;
               queue.taskDone();
            });
         });
         titleText.text#2 = StringUtil.format(GameSetting.getUIText("acquiredKitchenware.title"),name);
         descText.text#2 = StringUtil.format(GameSetting.getUIText("acquiredKitchenware.desc"),name);
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(AcquiredRecipeNoteDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         SoundManager.playEffect("MaxComboSuccess");
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            checkGuide();
            Engine.unlockTouchInput(AcquiredRecipeNoteDialog);
         });
      }
      
      private function checkGuide() : void
      {
         var _loc1_:KitchenwareDef = GameSetting.getKitchenware(kitchenwareId);
         if(_loc1_.type == 4 && UserDataWrapper.wrapper.isCanStartNoticeFlag(24))
         {
            processNoticeTutorial(24);
         }
      }
      
      override public function advanceTime(param1:Number) : void
      {
         super.advanceTime(param1);
         passedTime += param1;
         if(rotateImage != null)
         {
            rotateImage.rotation = 2 * 3.141592653589793 * passedTime / 10;
         }
      }
      
      override public function backButtonCallback() : void
      {
         if(Engine.getGuideTalkPanel() != null)
         {
            return;
         }
         kitchenwareId = UserDataWrapper.kitchenwarePart.popNewlyActivatedKitchenware();
         if(kitchenwareId <= 0)
         {
            back();
         }
         else
         {
            next();
         }
      }
      
      private function back() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(AcquiredRecipeNoteDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(AcquiredRecipeNoteDialog);
            Engine.popScene(scene);
            if(callback)
            {
               callback();
            }
         });
      }
      
      private function next() : void
      {
         Engine.lockTouchInput(AcquiredRecipeNoteDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            var queue:TaskQueue = new TaskQueue();
            setup(queue);
            queue.registerOnProgress(function(param1:Number):void
            {
               var ratio:Number = param1;
               if(ratio < 1)
               {
                  return;
               }
               TweenAnimator.startItself(displaySprite,"show",false,function():void
               {
                  checkGuide();
                  Engine.unlockTouchInput(AcquiredRecipeNoteDialog);
               });
            });
            queue.startTask();
         });
      }
      
      private function triggeredShopButton(param1:Event) : void
      {
         var event:Event = param1;
         ResidentMenuUI_Gudetama.getInstance().sendChangeState(62,function():void
         {
            Engine.switchScene(new ShopScene_Gudetama());
         });
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         titleText = null;
         rotateImage = null;
         iconImage = null;
         descText = null;
         if(closeButton)
         {
            closeButton.removeEventListener("triggered",triggeredCloseButton);
            closeButton = null;
         }
         super.dispose();
      }
   }
}
