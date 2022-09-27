package gudetama.ui
{
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.GudetamaData;
   import gudetama.data.compati.GudetamaDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.util.GudeActUtil;
   import muku.display.ContainerButton;
   import muku.display.GeneralGauge;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class LockedRecipeDialog extends BaseScene
   {
       
      
      private var gudetamaId:int;
      
      private var iconImage:Image;
      
      private var nameText:ColorTextField;
      
      private var conditionText:ColorTextField;
      
      private var gauge:GeneralGauge;
      
      private var gaugeBase:Image;
      
      private var slash:ColorTextField;
      
      private var numText:ColorTextField;
      
      private var maxText:ColorTextField;
      
      private var closeButton:ContainerButton;
      
      private var cookingButton:RecipeMakeButton;
      
      public function LockedRecipeDialog(param1:int)
      {
         super(2);
         this.gudetamaId = param1;
      }
      
      public static function show(param1:int) : void
      {
         Engine.pushScene(new LockedRecipeDialog(param1),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"LockedRecipeDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            iconImage = _loc2_.getChildByName("icon") as Image;
            slash = _loc2_.getChildByName("text") as ColorTextField;
            nameText = _loc2_.getChildByName("name") as ColorTextField;
            conditionText = _loc2_.getChildByName("condition") as ColorTextField;
            gauge = _loc2_.getChildByName("gauge") as GeneralGauge;
            gaugeBase = _loc2_.getChildByName("challenge0@compbar1") as Image;
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
         var gudetamaDef:GudetamaDef = GameSetting.getGudetama(gudetamaId);
         var gudetamaData:GudetamaData = UserDataWrapper.gudetamaPart.getGudetama(gudetamaId);
         var currentValue:int = !!gudetamaData ? gudetamaData.currentValue : 0;
         var targetValue:int = !!gudetamaData ? gudetamaData.targetValue : 0;
         var targetId:int = gudetamaDef.targetId;
         queue.addTask(function():void
         {
            TextureCollector.loadTextureRsrc("gudetama-" + gudetamaDef.rsrc + "-icon",function(param1:Texture):void
            {
               iconImage.texture = param1;
               queue.taskDone();
            });
         });
         nameText.text#2 = gudetamaDef.name#2;
         conditionText.text#2 = gudetamaDef.conditionDesc;
         if(targetValue > 0)
         {
            gauge.percent = Math.min(1,currentValue / targetValue);
         }
         else
         {
            gauge.percent = 0;
         }
         numText.text#2 = currentValue.toString();
         maxText.text#2 = targetValue.toString();
         if(targetId < 0)
         {
            cookingButton.visible = false;
            gauge.visible = false;
            gaugeBase.visible = false;
            slash.visible = false;
            numText.visible = false;
            maxText.visible = false;
         }
         else
         {
            cookingButton.setup(0,targetId,gudetamaDef.recipeNoteId);
         }
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(LockedRecipeDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(LockedRecipeDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(LockedRecipeDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(LockedRecipeDialog);
            Engine.popScene(scene);
         });
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         iconImage = null;
         nameText = null;
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

import gudetama.data.UserDataWrapper;
import gudetama.ui.UIBase;
import gudetama.util.GudeActUtil;
import starling.display.Sprite;
import starling.events.Event;

class FeatureButtonUI extends UIBase
{
    
   
   private var states:int;
   
   private var callback:Function;
   
   private var state:int;
   
   private var displaySprite:Sprite;
   
   function FeatureButtonUI(param1:Sprite, param2:int, param3:Function)
   {
      displaySprite = param1;
      super(displaySprite);
      this.states = param2;
      this.callback = param3;
      displaySprite.addEventListener("triggered",triggeredButton);
   }
   
   public function setup(param1:int, param2:int, param3:Boolean, param4:Boolean, param5:Boolean) : void
   {
      if(param1 == 0)
      {
         state = GudeActUtil.checkState(param2,states,param3,param4,param5);
         if((state & 2) != 0)
         {
            startTween("lock");
         }
         else if(state != 0)
         {
            startTween("disable");
         }
         else
         {
            startTween("enable");
         }
      }
      finishTween();
   }
   
   public function setupForRecipe(param1:int) : void
   {
      if(!UserDataWrapper.recipeNotePart.isAvailable(param1))
      {
         startTween("lock");
      }
      else
      {
         startTween("enable");
      }
      finishTween();
   }
   
   private function triggeredButton(param1:Event) : void
   {
      callback(state);
   }
   
   public function dispose() : void
   {
      displaySprite.removeEventListener("triggered",triggeredButton);
   }
   
   public function set visible(param1:*) : void
   {
      displaySprite.visible = param1;
   }
}
