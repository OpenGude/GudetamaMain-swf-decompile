package gudetama.ui
{
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.KitchenwareDef;
   import gudetama.data.compati.RecipeNoteData;
   import gudetama.data.compati.RecipeNoteDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.util.GudeActUtil;
   import gudetama.util.StringUtil;
   import muku.display.ContainerButton;
   import muku.display.GeneralGauge;
   import muku.text.ColorTextField;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class LockedRecipeNoteDialog extends BaseScene
   {
       
      
      private var recipeNoteId:int;
      
      private var priceText:ColorTextField;
      
      private var descText:ColorTextField;
      
      private var conditionText:ColorTextField;
      
      private var gauge:GeneralGauge;
      
      private var numText:ColorTextField;
      
      private var maxText:ColorTextField;
      
      private var closeButton:ContainerButton;
      
      private var cookingButton:RecipeMakeButton;
      
      private var targetType:int;
      
      private var targetId:int;
      
      public function LockedRecipeNoteDialog(param1:int)
      {
         super(2);
         this.recipeNoteId = param1;
      }
      
      public static function show(param1:int) : void
      {
         Engine.pushScene(new LockedRecipeNoteDialog(param1),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"LockedRecipeNoteDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            priceText = _loc2_.getChildByName("price") as ColorTextField;
            descText = _loc2_.getChildByName("desc") as ColorTextField;
            conditionText = _loc2_.getChildByName("condition") as ColorTextField;
            gauge = _loc2_.getChildByName("gauge") as GeneralGauge;
            numText = _loc2_.getChildByName("num") as ColorTextField;
            maxText = _loc2_.getChildByName("max") as ColorTextField;
            closeButton = _loc2_.getChildByName("btn_back") as ContainerButton;
            closeButton.addEventListener("triggered",triggeredCloseButton);
            cookingButton = new RecipeMakeButton(_loc2_.getChildByName("cookingButton") as ContainerButton,GudeActUtil.getCookCheckStates(),backButtonCallback,true);
            displaySprite.visible = false;
            addChild(displaySprite);
            setup();
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
      
      private function setup() : void
      {
         var _loc3_:RecipeNoteDef = GameSetting.getRecipeNote(recipeNoteId);
         var _loc1_:RecipeNoteData = UserDataWrapper.recipeNotePart.getRecipeNote(recipeNoteId);
         var _loc4_:KitchenwareDef = GameSetting.getKitchenware(_loc3_.kitchenwareId);
         var _loc5_:int = !!_loc1_ ? _loc1_.currentValue : 0;
         var _loc2_:int = !!_loc1_ ? _loc1_.targetValue : 0;
         targetType = _loc3_.targetType;
         targetId = _loc3_.targetId;
         priceText.text#2 = _loc3_.price.toString();
         descText.text#2 = StringUtil.format(GameSetting.getUIText("lockedRecipeNote.desc"),_loc4_.name#2,StringUtil.replaceAll(_loc3_.name#2,"\n",""));
         conditionText.text#2 = _loc3_.conditionDesc;
         if(_loc2_ > 0)
         {
            gauge.percent = Math.min(1,_loc5_ / _loc2_);
         }
         else
         {
            gauge.percent = 0;
         }
         numText.text#2 = _loc5_.toString();
         maxText.text#2 = _loc2_.toString();
         if(targetId > 0)
         {
            cookingButton.setup(targetType,targetId,recipeNoteId,false,false,true);
         }
         else
         {
            cookingButton.visible = false;
         }
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(LockedKitchenwareDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(LockedKitchenwareDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(LockedKitchenwareDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(LockedKitchenwareDialog);
            Engine.popScene(scene);
         });
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         priceText = null;
         descText = null;
         conditionText = null;
         gauge = null;
         numText = null;
         maxText = null;
         closeButton.removeEventListener("triggered",triggeredCloseButton);
         closeButton = null;
         super.dispose();
      }
   }
}
