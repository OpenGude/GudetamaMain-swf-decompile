package gudetama.ui
{
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.KitchenwareDef;
   import gudetama.data.compati.RecipeNoteData;
   import gudetama.data.compati.RecipeNoteDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.SoundManager;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.scene.shop.ShopScene_Gudetama;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class AcquiredRecipeNoteDialog extends BaseScene
   {
      
      private static const ROTATE_TIME:Number = 10;
       
      
      private var recipeNoteDef:RecipeNoteDef;
      
      private var kwType:int;
      
      private var callback:Function;
      
      private var rotateImage:Image;
      
      private var iconImage:Image;
      
      private var descText:ColorTextField;
      
      private var closeButton:ContainerButton;
      
      private var passedTime:Number = 0;
      
      public function AcquiredRecipeNoteDialog(param1:RecipeNoteDef, param2:int, param3:Function)
      {
         super(2);
         this.recipeNoteDef = param1;
         this.kwType = param2;
         this.callback = param3;
      }
      
      public static function show(param1:Function = null) : void
      {
         var _loc2_:Array = getNextRecipeNoteInfo();
         if(!_loc2_)
         {
            if(param1)
            {
               param1();
            }
            return;
         }
         Engine.pushScene(new AcquiredRecipeNoteDialog(_loc2_[0],_loc2_[1],param1),0,false);
      }
      
      private static function getNextRecipeNoteInfo() : Array
      {
         var _loc2_:RecipeNoteData = UserDataWrapper.recipeNotePart.popNewlyActivatedRecipeNote();
         if(_loc2_ == null)
         {
            return null;
         }
         var _loc3_:RecipeNoteDef = GameSetting.getRecipeNote(_loc2_.id#2);
         if(_loc3_ == null)
         {
            return getNextRecipeNoteInfo();
         }
         var _loc1_:KitchenwareDef = GameSetting.getKitchenware(_loc3_.kitchenwareId);
         if(_loc1_ == null || _loc1_.type == 4)
         {
            return getNextRecipeNoteInfo();
         }
         return [_loc3_,_loc1_.type];
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"AcquiredRecipeNoteDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
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
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("recipe0@recipe" + kwType,function(param1:Texture):void
            {
               iconImage.texture = param1;
               queue.taskDone();
            });
         });
         descText.text#2 = recipeNoteDef.desc;
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
            Engine.unlockTouchInput(AcquiredRecipeNoteDialog);
         });
      }
      
      override public function advanceTime(param1:Number) : void
      {
         super.advanceTime(param1);
         passedTime += param1;
         rotateImage.rotation = 2 * 3.141592653589793 * passedTime / 10;
      }
      
      override public function backButtonCallback() : void
      {
         var _loc1_:Array = getNextRecipeNoteInfo();
         if(!_loc1_)
         {
            back();
         }
         else
         {
            recipeNoteDef = _loc1_[0];
            kwType = _loc1_[1];
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
         recipeNoteDef = null;
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
