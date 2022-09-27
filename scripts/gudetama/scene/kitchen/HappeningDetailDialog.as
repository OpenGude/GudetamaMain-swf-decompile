package gudetama.scene.kitchen
{
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.GudetamaData;
   import gudetama.data.compati.GudetamaDef;
   import gudetama.data.compati.KitchenwareDef;
   import gudetama.data.compati.RecipeNoteDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.scene.friend.FriendPresentListDialog;
   import gudetama.scene.home.HomeScene;
   import gudetama.ui.CookingGuideDialog;
   import gudetama.ui.LocalMessageDialog;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.ui.WantedReplacementDialog;
   import gudetama.util.GudeActUtil;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class HappeningDetailDialog extends BaseScene
   {
       
      
      private var id:int;
      
      private var iconImage:Image;
      
      private var numberGroup:Sprite;
      
      private var numberText:ColorTextField;
      
      private var nameText:ColorTextField;
      
      private var categoryText:ColorTextField;
      
      private var possessionText:ColorTextField;
      
      private var countText:ColorTextField;
      
      private var presentButton:FeatureButtonUI;
      
      private var listButton:FeatureButtonUI;
      
      private var closeButton:ContainerButton;
      
      private var loadCount:int;
      
      public function HappeningDetailDialog(param1:int)
      {
         super(1);
         this.id = param1;
      }
      
      public static function show(param1:int) : void
      {
         Engine.pushScene(new HappeningDetailDialog(param1),0,false);
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
         setupLayoutForTask(queue,"HappeningDetailDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            iconImage = _loc2_.getChildByName("icon") as Image;
            numberGroup = _loc2_.getChildByName("numberGroup") as Sprite;
            numberText = numberGroup.getChildByName("number") as ColorTextField;
            nameText = _loc2_.getChildByName("name") as ColorTextField;
            categoryText = _loc2_.getChildByName("category") as ColorTextField;
            possessionText = _loc2_.getChildByName("num") as ColorTextField;
            countText = _loc2_.getChildByName("count") as ColorTextField;
            presentButton = new FeatureButtonUI(_loc2_.getChildByName("btn_present") as ContainerButton,GudeActUtil.getPresentCheckStates(),triggeredPresentButton);
            listButton = new FeatureButtonUI(_loc2_.getChildByName("btn_list") as ContainerButton,GudeActUtil.getWantCheckStates(),triggeredListButton);
            closeButton = _loc2_.getChildByName("btn_back") as ContainerButton;
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
         var gudetamaDef:GudetamaDef = GameSetting.getGudetama(id);
         var gudetamaData:GudetamaData = UserDataWrapper.gudetamaPart.getGudetama(id);
         var cooked:Boolean = UserDataWrapper.gudetamaPart.isCooked(id);
         queue.addTask(function():void
         {
            TextureCollector.loadTextureRsrc("gudetama-" + gudetamaDef.rsrc + "-icon",function(param1:Texture):void
            {
               iconImage.texture = param1;
               TweenAnimator.startItself(iconImage,!!cooked ? "enabled" : "disabled");
               queue.taskDone();
            });
         });
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
         categoryText.text#2 = GameSetting.getUIText("gudetama.category." + gudetamaDef.category);
         possessionText.text#2 = StringUtil.getNumStringCommas(!!gudetamaData ? gudetamaData.num : 0);
         countText.text#2 = StringUtil.getNumStringCommas(!!gudetamaData ? gudetamaData.count : 0);
         presentButton.setup(id,!UserDataWrapper.featurePart.existsFeature(12),UserDataWrapper.gudetamaPart.hasGudetama(gudetamaDef.id#2,1));
         listButton.setup(id,false,!UserDataWrapper.wantedPart.exists(gudetamaDef.id#2));
      }
      
      override protected function addedToContainer() : void
      {
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
         Engine.lockTouchInput(HappeningDetailDialog);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(HappeningDetailDialog);
         });
      }
      
      private function triggeredPresentButton(param1:int) : void
      {
         if((param1 & 2) != 0)
         {
            LocalMessageDialog.show(0,GudetamaUtil.getFriendUnlockConditionText(),null,GameSetting.getUIText("gudetamaDetail.message.present.title"));
         }
         else if((param1 & 1) != 0)
         {
            LocalMessageDialog.show(0,GameSetting.getUIText("gudetamaDetail.message.present.uncountable.desc"),null,GameSetting.getUIText("gudetamaDetail.message.present.title"));
         }
         else if((param1 & 8) != 0)
         {
            showCookingGuideDialog();
         }
         else
         {
            FriendPresentListDialog.show(id);
         }
      }
      
      private function showCookingGuideDialog() : void
      {
         var showMessageDialog:Function = function():void
         {
            LocalMessageDialog.show(0,GameSetting.getUIText("gudetamaDetail.message.present.disabled.desc"),null,GameSetting.getUIText("gudetamaDetail.message.present.title"));
         };
         var gudetamaDef:GudetamaDef = GameSetting.getGudetama(id);
         if(!UserDataWrapper.gudetamaPart.isAvailable(id))
         {
            showMessageDialog();
            return;
         }
         if(!UserDataWrapper.recipeNotePart.isPurchased(gudetamaDef.recipeNoteId))
         {
            showMessageDialog();
            return;
         }
         var recipeNoteDef:RecipeNoteDef = GameSetting.getRecipeNote(gudetamaDef.recipeNoteId);
         if(!recipeNoteDef)
         {
            showMessageDialog();
            return;
         }
         var kitchenwareDef:KitchenwareDef = GameSetting.getKitchenware(recipeNoteDef.kitchenwareId);
         if(!kitchenwareDef)
         {
            showMessageDialog();
            return;
         }
         var param:Object = {
            "kitchenwareType":kitchenwareDef.type,
            "kitchenwareId":kitchenwareDef.id#2,
            "recipeNoteId":recipeNoteDef.id#2,
            "gudetamaId":gudetamaDef.id#2
         };
         CookingGuideDialog.show(function():void
         {
            ResidentMenuUI_Gudetama.getInstance().sendChangeState(60,function():void
            {
               Engine.switchScene(new HomeScene(param.kitchenwareType,param));
            });
         });
      }
      
      private function triggeredListButton(param1:int) : void
      {
         var state:int = param1;
         if((state & 1) != 0)
         {
            LocalMessageDialog.show(0,GameSetting.getUIText("gudetamaDetail.message.list.uncountable.desc"),null,GameSetting.getUIText("gudetamaDetail.message.list.title"));
         }
         else if((state & 4) != 0)
         {
            LocalMessageDialog.show(0,GameSetting.getUIText("gudetamaDetail.message.list.notCooked.desc"),null,GameSetting.getUIText("gudetamaDetail.message.list.title"));
         }
         else if((state & 8) != 0)
         {
            LocalMessageDialog.show(0,GameSetting.getUIText("gudetamaDetail.message.list.disabled.desc"),null,GameSetting.getUIText("gudetamaDetail.message.list.title"));
         }
         else
         {
            var gudetamaDef:GudetamaDef = GameSetting.getGudetama(id);
            addWantedGudetama(gudetamaDef,function():void
            {
               listButton.setup(id,false,!UserDataWrapper.wantedPart.exists(gudetamaDef.id#2));
            });
         }
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(HappeningDetailDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(HappeningDetailDialog);
            Engine.popScene(scene);
         });
      }
      
      override public function dispose() : void
      {
         numberGroup = null;
         numberText = null;
         nameText = null;
         categoryText = null;
         possessionText = null;
         countText = null;
         if(presentButton)
         {
            presentButton.dispose();
            presentButton = null;
         }
         if(listButton)
         {
            listButton.dispose();
            listButton = null;
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
   
   public function setup(param1:int, param2:Boolean, param3:Boolean) : void
   {
      state = GudeActUtil.checkState(param1,states,param2,param3,false);
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
