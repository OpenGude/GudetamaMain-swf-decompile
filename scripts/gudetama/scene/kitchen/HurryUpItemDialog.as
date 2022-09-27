package gudetama.scene.kitchen
{
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.KitchenwareData;
   import gudetama.data.compati.UsefulData;
   import gudetama.data.compati.UsefulDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.scene.shop.ShopScene_Gudetama;
   import gudetama.ui.LocalMessageDialog;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class HurryUpItemDialog extends BaseScene
   {
       
      
      private var kitchenwareType:int;
      
      private var usefulId:int;
      
      private var refreshFunc:Function;
      
      private var titleText:ColorTextField;
      
      private var iconImage:Image;
      
      private var numText:ColorTextField;
      
      private var useButton:ContainerButton;
      
      private var shopButton:ContainerButton;
      
      private var descText:ColorTextField;
      
      private var closeButton:ContainerButton;
      
      private var loadCount:int;
      
      public function HurryUpItemDialog(param1:int, param2:int, param3:Function)
      {
         super(2);
         this.kitchenwareType = param1;
         this.usefulId = param2;
         this.refreshFunc = param3;
      }
      
      public static function show(param1:int, param2:int, param3:Function) : void
      {
         Engine.pushScene(new HurryUpItemDialog(param1,param2,param3),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"HurryUpItemDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc3_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            titleText = _loc3_.getChildByName("title") as ColorTextField;
            iconImage = _loc3_.getChildByName("icon") as Image;
            numText = _loc3_.getChildByName("num") as ColorTextField;
            useButton = _loc3_.getChildByName("useButton") as ContainerButton;
            useButton.addEventListener("triggered",triggeredUsefulUseButton);
            shopButton = _loc3_.getChildByName("shopButton") as ContainerButton;
            shopButton.enableDrawCache();
            shopButton.addEventListener("triggered",triggeredShopButton);
            var _loc2_:Sprite = _loc3_.getChildByName("descGroup") as Sprite;
            descText = _loc2_.getChildByName("desc") as ColorTextField;
            closeButton = _loc3_.getChildByName("closeButton") as ContainerButton;
            closeButton.enableDrawCache();
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
         var gudetamaId:int = UserDataWrapper.kitchenwarePart.getGudetamaId(kitchenwareType);
         var usefulDef:UsefulDef = GameSetting.getUseful(usefulId);
         var num:int = UserDataWrapper.usefulPart.getNumUseful(usefulId);
         titleText.text#2 = StringUtil.format(GameSetting.getUIText("hurryUpConfirm.item.title"),usefulDef.name#2);
         queue.addTask(function():void
         {
            TextureCollector.loadTexture(GudetamaUtil.getItemIconName(8,usefulId),function(param1:Texture):void
            {
               iconImage.texture = param1;
               queue.taskDone();
            });
         });
         numText.text#2 = String(num);
         descText.text#2 = usefulDef.desc;
         useButton.setEnableWithDrawCache(num > 0);
         TweenAnimator.startItself(displaySprite,"pos" + (!!usefulDef.price ? "1" : "0"));
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(HurryUpConfirmDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(HurryUpConfirmDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(HurryUpConfirmDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(HurryUpConfirmDialog);
            Engine.popScene(scene);
         });
      }
      
      private function triggeredUsefulUseButton(param1:Event) : void
      {
         var event:Event = param1;
         Engine.showLoading(HurryUpConfirmDialog);
         var _loc2_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(134217971,[kitchenwareType,usefulId]),function(param1:Array):void
         {
            var response:Array = param1;
            Engine.hideLoading(HurryUpConfirmDialog);
            if(response[0] is int)
            {
               if(response[0] == 0)
               {
                  LocalMessageDialog.show(0,GameSetting.getUIText("cooking.cancel.completed.desc"),null,GameSetting.getUIText("%hurryUpConfirm.title"));
               }
               else if(response[0] == 1)
               {
                  LocalMessageDialog.show(0,GameSetting.getUIText("hurryUpConfirm.useful.outOfTerm"),function(param1:int):void
                  {
                     Engine.broadcastEventToSceneStackWith("update_scene");
                  },GameSetting.getUIText("%hurryUpConfirm.title"));
               }
               return;
            }
            var kitchenwareData:KitchenwareData = response[0];
            var usefulData:UsefulData = response[1];
            UserDataWrapper.kitchenwarePart.addKitchenware(kitchenwareData);
            UserDataWrapper.usefulPart.updateUseful(usefulData);
            ResidentMenuUI_Gudetama.getInstance().updateUserInfo();
            if(refreshFunc)
            {
               refreshFunc();
            }
            backButtonCallback();
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
         refreshFunc = null;
         titleText = null;
         numText = null;
         if(useButton)
         {
            useButton.removeEventListener("triggered",triggeredUsefulUseButton);
            useButton = null;
         }
         closeButton.removeEventListener("triggered",triggeredCloseButton);
         closeButton = null;
         super.dispose();
      }
   }
}
