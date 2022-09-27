package gudetama.scene.kitchen
{
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.GudetamaDef;
   import gudetama.data.compati.KitchenwareDef;
   import gudetama.data.compati.RecipeNoteDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.scene.home.HomeScene;
   import gudetama.ui.AcquiredKitchenwareDialog;
   import gudetama.ui.AcquiredRecipeNoteDialog;
   import gudetama.ui.LocalMessageDialog;
   import gudetama.ui.LockedRecipeDialog;
   import gudetama.ui.LockedRecipeNoteDialog;
   import gudetama.ui.PurchaseRecipeDialog;
   import gudetama.ui.RecipeMakeButton;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.ui.WantedReplacementDialog;
   import gudetama.ui.WantedShareDialog;
   import gudetama.util.GudeActUtil;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class GudetamaShortageDialog extends BaseScene
   {
       
      
      private var gudetamaId:int;
      
      private var iconImage:Image;
      
      private var kitchenwareImage:Image;
      
      private var happeningImage:Image;
      
      private var numberText:ColorTextField;
      
      private var nameText:ColorTextField;
      
      private var costText:ColorTextField;
      
      private var wantButton:FeatureButtonUI;
      
      private var cookingButton:RecipeMakeButton;
      
      private var shareButton:FeatureButtonUI;
      
      private var closeButton:ContainerButton;
      
      private var loadCount:int;
      
      public function GudetamaShortageDialog(param1:int)
      {
         super(2);
         this.gudetamaId = param1;
      }
      
      public static function show(param1:int) : void
      {
         Engine.pushScene(new GudetamaShortageDialog(param1),0,false);
      }
      
      public static function addWantedGudetama(param1:GudetamaDef, param2:Function) : void
      {
         var gudetamaDef:GudetamaDef = param1;
         var callback:Function = param2;
         var index:int = -1;
         var wantedGudetamas:Array = UserDataWrapper.wantedPart.getWantedGudetamas();
         var i:int = 0;
         while(i < wantedGudetamas.length)
         {
            if(UserDataWrapper.wantedPart.isEmpty(i))
            {
               index = i;
               break;
            }
            i++;
         }
         if(index >= 0)
         {
            Engine.showLoading(addWantedGudetama);
            var _loc4_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(GENERAL_UPDATE_WANTED,[index,gudetamaDef.id#2]),function(param1:Array):void
            {
               var response:Array = param1;
               Engine.hideLoading(addWantedGudetama);
               UserDataWrapper.wantedPart.setWantedGudetamas(response);
               LocalMessageDialog.show(0,StringUtil.format(GameSetting.getUIText("gudetamaShortage.wanted.success.desc"),gudetamaDef.name#2),function(param1:int):void
               {
                  if(callback != null)
                  {
                     callback();
                  }
               },GameSetting.getUIText("gudetamaShortage.wanted.title"));
            });
         }
         else
         {
            WantedReplacementDialog.show(gudetamaDef.id#2,callback);
         }
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"GudetamaShortageDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc3_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            iconImage = _loc3_.getChildByName("icon") as Image;
            kitchenwareImage = _loc3_.getChildByName("kitchenware") as Image;
            happeningImage = _loc3_.getChildByName("happening") as Image;
            var _loc2_:Sprite = _loc3_.getChildByName("numberGroup") as Sprite;
            numberText = _loc2_.getChildByName("number") as ColorTextField;
            nameText = _loc3_.getChildByName("name") as ColorTextField;
            costText = _loc3_.getChildByName("cost") as ColorTextField;
            wantButton = new FeatureButtonUI(_loc3_.getChildByName("wantButton") as ContainerButton,GudeActUtil.getWantCheckStates(),triggeredWantButton);
            cookingButton = new RecipeMakeButton(_loc3_.getChildByName("cookingButton") as ContainerButton,GudeActUtil.getCookCheckStates(),backButtonCallback,false);
            shareButton = new FeatureButtonUI(_loc3_.getChildByName("shareButton") as ContainerButton,GudeActUtil.getShareCheckStates(),triggeredShareButton);
            closeButton = _loc3_.getChildByName("btn_back") as ContainerButton;
            closeButton.addEventListener("triggered",triggeredCloseButton);
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
         init();
      }
      
      private function init() : void
      {
         setup();
      }
      
      private function setup() : void
      {
         var gudetamaDef:GudetamaDef = GameSetting.getGudetama(gudetamaId);
         var recipeNoteDef:RecipeNoteDef = GameSetting.getRecipeNote(gudetamaDef.recipeNoteId);
         var kitchenwareDef:KitchenwareDef = !!recipeNoteDef ? GameSetting.getKitchenware(recipeNoteDef.kitchenwareId) : null;
         var cooked:Boolean = UserDataWrapper.gudetamaPart.isCooked(gudetamaId);
         queue.addTask(function():void
         {
            TextureCollector.loadTextureRsrc("gudetama-" + gudetamaDef.rsrc + "-icon",function(param1:Texture):void
            {
               iconImage.texture = param1;
               TweenAnimator.startItself(iconImage,!!cooked ? "enabled" : "disabled");
               queue.taskDone();
            });
         });
         if(kitchenwareDef)
         {
            queue.addTask(function():void
            {
               TextureCollector.loadTexture("recipe0@circle" + (kitchenwareDef.id#2 - 1),function(param1:Texture):void
               {
                  kitchenwareImage.texture = param1;
                  kitchenwareImage.visible = true;
                  queue.taskDone();
               });
            });
         }
         else
         {
            kitchenwareImage.visible = false;
         }
         if(recipeNoteDef)
         {
            happeningImage.visible = recipeNoteDef.happeningIds && recipeNoteDef.happeningIds.indexOf(gudetamaId) >= 0;
         }
         else
         {
            happeningImage.visible = false;
         }
         if(gudetamaDef.type != 1)
         {
            numberText.visible = false;
         }
         else
         {
            numberText.visible = true;
            numberText.text#2 = StringUtil.format(GameSetting.getUIText("common.number"),gudetamaDef.number);
         }
         nameText.text#2 = gudetamaDef.name#2;
         costText.text#2 = StringUtil.getNumStringCommas(gudetamaDef.cost);
         wantButton.setup(gudetamaId,false,!UserDataWrapper.wantedPart.exists(gudetamaDef.id#2),false);
         cookingButton.setup(0,gudetamaId,gudetamaDef.recipeNoteId,false,false,true);
         shareButton.setup(gudetamaId,!UserDataWrapper.featurePart.existsFeature(12),false,false);
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(GudetamaShortageDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(GudetamaShortageDialog);
         });
      }
      
      private function triggeredWantButton(param1:int) : void
      {
         var state:int = param1;
         if((state & 1) != 0)
         {
            LocalMessageDialog.show(0,GameSetting.getUIText("gudetamaShortage.wanted.uncountable.desc"),null,GameSetting.getUIText("gudetamaShortage.wanted.title"));
         }
         else if((state & 4) != 0)
         {
            LocalMessageDialog.show(0,GameSetting.getUIText("gudetamaDetail.message.list.notCooked.desc"),null,GameSetting.getUIText("gudetamaShortage.wanted.title"));
         }
         else if((state & 8) != 0)
         {
            LocalMessageDialog.show(0,GameSetting.getUIText("gudetamaDetail.message.list.disabled.desc"),null,GameSetting.getUIText("gudetamaShortage.wanted.title"));
         }
         else
         {
            var gudetamaDef:GudetamaDef = GameSetting.getGudetama(gudetamaId);
            addWantedGudetama(gudetamaDef,function():void
            {
               wantButton.setup(gudetamaId,false,!UserDataWrapper.wantedPart.exists(gudetamaDef.id#2),false);
            });
         }
      }
      
      private function triggeredCookingButton(param1:int) : void
      {
         var state:int = param1;
         var gudetamaDef:GudetamaDef = GameSetting.getGudetama(gudetamaId);
         var recipeNoteDef:RecipeNoteDef = GameSetting.getRecipeNote(gudetamaDef.recipeNoteId);
         if((state & 1) != 0)
         {
            LocalMessageDialog.show(0,GameSetting.getUIText("gudetamaShortage.cooking.uncountable.desc"),null,GameSetting.getUIText("gudetamaShortage.cooking.title"));
         }
         else if((state & 16) != 0)
         {
            LocalMessageDialog.show(0,GameSetting.getUIText("gudetamaShortage.cooking.uncountable.desc"),null,GameSetting.getUIText("gudetamaShortage.cooking.title"));
         }
         else if((state & 32) != 0)
         {
            var kitchenwareDef:KitchenwareDef = !!recipeNoteDef ? GameSetting.getKitchenware(recipeNoteDef.kitchenwareId) : null;
            if(!kitchenwareDef && gudetamaDef.kitchenwareId > 0)
            {
               kitchenwareDef = GameSetting.getKitchenware(gudetamaDef.kitchenwareId);
            }
            LocalMessageDialog.show(0,StringUtil.format(GameSetting.getUIText("gudetamaShortage.cooking.needAvailableKitchenware.desc"),kitchenwareDef.name#2),null,GameSetting.getUIText("gudetamaShortage.cooking.title"));
         }
         else if((state & 64) != 0)
         {
            LocalMessageDialog.show(0,GameSetting.getUIText("gudetamaShortage.cooking.outOfTerm.desc"),null,GameSetting.getUIText("gudetamaShortage.cooking.title"));
         }
         else if((state & 128) != 0)
         {
            recipeNoteDef = GameSetting.getRecipeNote(gudetamaDef.recipeNoteId);
            if(!recipeNoteDef.premises || recipeNoteDef.premises.length == 0)
            {
               return;
            }
            var premiseRecipeNoteDef:RecipeNoteDef = GameSetting.getRecipeNote(recipeNoteDef.premises[0]);
            LocalMessageDialog.show(0,StringUtil.format(GameSetting.getUIText("gudetamaShortage.cooking.invisible.desc"),GudetamaUtil.getKitchenwareNameByRecipeNote(premiseRecipeNoteDef)),null,GameSetting.getUIText("gudetamaShortage.cooking.title"));
         }
         else if((state & 256) != 0)
         {
            LockedRecipeNoteDialog.show(gudetamaDef.recipeNoteId);
         }
         else if((state & 512) != 0)
         {
            PurchaseRecipeDialog.show(gudetamaDef.recipeNoteId,function(param1:Boolean):void
            {
               var _close:Boolean = param1;
               AcquiredKitchenwareDialog.show(function():void
               {
                  AcquiredRecipeNoteDialog.show();
               });
               cookingButton.setup(0,gudetamaId,gudetamaDef.recipeNoteId,false,false,true);
            });
         }
         else if((state & 1024) != 0)
         {
            LockedRecipeDialog.show(gudetamaId);
         }
         else
         {
            moveToCookingScene();
         }
      }
      
      private function moveToCookingScene() : void
      {
         var gudetamaDef:GudetamaDef = GameSetting.getGudetama(gudetamaId);
         var recipeNoteDef:RecipeNoteDef = GameSetting.getRecipeNote(gudetamaDef.recipeNoteId);
         var kitchenwareDef:KitchenwareDef = !!recipeNoteDef ? GameSetting.getKitchenware(recipeNoteDef.kitchenwareId) : null;
         if(!kitchenwareDef && gudetamaDef.kitchenwareId > 0)
         {
            kitchenwareDef = GameSetting.getKitchenware(gudetamaDef.kitchenwareId);
         }
         var isHappening:Boolean = UserDataWrapper.gudetamaPart.isHappening(gudetamaId);
         var isFailure:Boolean = UserDataWrapper.gudetamaPart.isFailure(gudetamaId);
         var param:Object = {
            "kitchenwareType":kitchenwareDef.type,
            "kitchenwareId":kitchenwareDef.id#2
         };
         if(!isFailure)
         {
            param["recipeNoteId"] = recipeNoteDef.id#2;
            if(!isHappening)
            {
               param["gudetamaId"] = gudetamaDef.id#2;
            }
         }
         if(UserDataWrapper.kitchenwarePart.isCooking(kitchenwareDef.type))
         {
            LocalMessageDialog.show(1,GameSetting.getUIText("gudetamaShortage.cooking.alreadyCooking.desc"),function(param1:int):void
            {
               var choose:int = param1;
               if(choose == 1)
               {
                  return;
               }
               ResidentMenuUI_Gudetama.getInstance().sendChangeState(60,function():void
               {
                  Engine.switchScene(new HomeScene(kitchenwareDef.type,param));
               });
            },GameSetting.getUIText("gudetamaShortage.cooking.title"));
         }
         else
         {
            ResidentMenuUI_Gudetama.getInstance().sendChangeState(60,function():void
            {
               Engine.switchScene(new HomeScene(kitchenwareDef.type,param));
            });
         }
      }
      
      private function triggeredShareButton(param1:int) : void
      {
         if((param1 & 2) != 0)
         {
            LocalMessageDialog.show(0,GudetamaUtil.getFriendUnlockConditionText(),null,GameSetting.getUIText("%gudetamaShortage.button.share"));
         }
         else if((param1 & 1) != 0)
         {
            LocalMessageDialog.show(0,GameSetting.getUIText("gudetamaShortage.share.uncountable.desc"),null,GameSetting.getUIText("%gudetamaShortage.button.share"));
         }
         else
         {
            WantedShareDialog.show([gudetamaId]);
         }
      }
      
      override public function backButtonCallback() : void
      {
         back();
      }
      
      private function back(param1:Function = null) : void
      {
         var callback:Function = param1;
         super.backButtonCallback();
         Engine.lockTouchInput(GudetamaShortageDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(GudetamaShortageDialog);
            Engine.popScene(scene);
            if(callback)
            {
               callback();
            }
         });
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         numberText = null;
         nameText = null;
         costText = null;
         if(wantButton)
         {
            wantButton.dispose();
            wantButton = null;
         }
         if(cookingButton)
         {
            cookingButton.dispose();
            cookingButton = null;
         }
         if(shareButton)
         {
            shareButton.dispose();
            shareButton = null;
         }
         if(closeButton)
         {
            closeButton.removeEventListener("triggered",triggeredCloseButton);
            closeButton = null;
         }
         super.dispose();
      }
   }
}

import gudetama.ui.UIBase;
import gudetama.util.GudeActUtil;
import starling.display.Sprite;
import starling.events.Event;

class FeatureButtonUI extends UIBase
{
    
   
   private var states:int;
   
   private var callback:Function;
   
   private var state:int;
   
   function FeatureButtonUI(param1:Sprite, param2:int, param3:Function)
   {
      super(param1);
      this.states = param2;
      this.callback = param3;
      param1.addEventListener("triggered",triggeredButton);
   }
   
   public function setup(param1:int, param2:Boolean, param3:Boolean, param4:Boolean) : void
   {
      state = GudeActUtil.checkState(param1,states,param2,param3,param4);
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
}
