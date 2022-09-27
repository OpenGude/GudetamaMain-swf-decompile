package gudetama.ui
{
   import gudetama.common.GudetamaUtil;
   import gudetama.data.DataStorage;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.GudetamaDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.SoundManager;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.scene.home.HomeScene;
   import muku.display.ContainerButton;
   import muku.display.GeneralGauge;
   import muku.display.SpineModel;
   import muku.text.ColorTextField;
   import starling.display.Sprite;
   import starling.textures.Texture;
   
   public class DownloadFirstRsrcDialog extends BaseScene
   {
       
      
      private var isTutorial:Boolean;
      
      private var callback:Function;
      
      private var lblDesc:ColorTextField;
      
      private var gauge:GeneralGauge;
      
      private var closeButton:ContainerButton;
      
      public function DownloadFirstRsrcDialog(param1:Boolean, param2:Function)
      {
         super(2);
         this.isTutorial = param1;
         this.callback = param2;
      }
      
      public static function show(param1:Boolean, param2:Function) : void
      {
         Engine.pushScene(new DownloadFirstRsrcDialog(param1,param2),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"DownloadFirstRsrcDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            lblDesc = _loc2_.getChildByName("lblDesc") as ColorTextField;
            lblDesc.text#2 = GameSetting.getUIText("first.part.rsrc.dl");
            gauge = _loc2_.getChildByName("gauge") as GeneralGauge;
            gauge.percent = 0;
            closeButton = _loc2_.getChildByName("btnClose") as ContainerButton;
            closeButton.alphaWhenDisabled = 0.5;
            closeButton.enabled = false;
            closeButton.addEventListener("triggered",backButtonCallback);
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
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(DownloadFirstRsrcDialog);
         setBackButtonCallback(null);
         setVisibleState(4);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(DownloadFirstRsrcDialog);
            startDownload();
         });
      }
      
      private function startDownload() : void
      {
         Engine.showLoading(DownloadFirstRsrcDialog);
         loadTexture("ar0@ar_help");
         loadTexture("benri0@mat_number");
         loadTexture("challenge0@bg01");
         loadTexture("common1@700_229");
         loadTexture("friend1@arrow");
         loadTexture("friendroom0@back");
         loadTexture("gacha1@atari");
         loadTexture("home1@balloon1");
         loadTexture("picturebook0@balloon");
         loadTexture("present0@btn");
         loadTexture("profile0@balloon");
         loadTexture("recipe0@balloon_cook00");
         loadTexture("roulette0@arrow");
         loadTexture("setting0@bell");
         loadTexture("shop0@balloon01");
         loadSpine("efx_spine-arrow");
         loadSpine("efx_spine-carnavi");
         loadSpine("efx_spine-delusion_spine");
         loadSpine("efx_spine-level_up");
         loadSpine("efx_spine-luckey_spine");
         loadSpine("efx_spine-miss_spine");
         loadSpine("efx_spine-recipe_page");
         loadSpine("efx_spine-retry_chance");
         loadSpine("efx_spine-unlock");
         loadSpine("efx_spine-weather_spine");
         loadSpine("efx_spine-workmanship_result");
         loadSpine("efx_spine-workmanship_start");
         var gudeIds:Array = [UserDataWrapper.wrapper.getPlacedGudetamaId()];
         if(isTutorial && gudeIds.indexOf(6) == -1)
         {
            gudeIds.push(6);
         }
         var voicePaths:Array = HomeScene.getVoicePaths(gudeIds);
         var i:int = 0;
         while(i < voicePaths.length)
         {
            loadVoice(voicePaths[i]);
            i++;
         }
         if(isTutorial)
         {
            i = 0;
            while(i < HomeScene.TUTORIAL_GUDETAMA_LIST.length)
            {
               var gudeId:int = HomeScene.TUTORIAL_GUDETAMA_LIST[i];
               if(gudeIds.indexOf(gudeId) == -1)
               {
                  gudeIds.push(gudeId);
               }
               i++;
            }
         }
         loadGudetamaRsrc(gudeIds);
         if(isTutorial)
         {
            Engine.setupLayoutForTask(queue,"_TitleProfileSettingDialog",function(param1:Object):void
            {
            });
         }
         Engine.setupLayoutForTask(queue,"HomeLayout_1",function(param1:Object):void
         {
         });
         Engine.setupLayoutForTask(queue,"_HeavenItem",function(param1:Object):void
         {
         });
         Engine.setupLayoutForTask(queue,"_DelusionItem",function(param1:Object):void
         {
         });
         var carnaviIds:Array = GameSetting.getRule().carnaviIds;
         i = 0;
         while(i < carnaviIds.length)
         {
            loadTexture("carnavi-" + carnaviIds[i]);
            i++;
         }
         if(isTutorial)
         {
            loadTexture("bg-tutorial");
            var kwType:int = 0;
            loadTexture("bg-background_kitchenware" + kwType);
            loadTexture("cooking-" + kwType);
            var kwRsrc:int = GameSetting.getKitchenware(1).rsrc;
            loadTexture("kitchenware-" + kwRsrc + "-bg");
            loadSpine("kitchenware-" + kwRsrc + "-bg_spine2");
            loadTexture("bg-background_workmanship");
         }
         queue.registerOnProgress(function(param1:Number):void
         {
            gauge.percent = param1;
            if(param1 < 1)
            {
               return;
            }
            Engine.hideLoading(DownloadFirstRsrcDialog);
            DataStorage.getLocalData().setNeedDownloadFirstRsrc(false);
            DataStorage.saveLocalData();
            lblDesc.text#2 = GameSetting.getUIText("first.part.rsrc.dl.end");
            closeButton.enabled = true;
            setBackButtonCallback(backButtonCallback);
         });
      }
      
      private function loadTexture(param1:String) : void
      {
         var textureName:String = param1;
         TextureCollector.loadTextureForTask(queue,textureName,function(param1:Texture):void
         {
         });
      }
      
      private function loadSpine(param1:String) : void
      {
         var spineName:String = param1;
         queue.addTask(function():void
         {
            SpineModel.preload(spineName,function(param1:Object):void
            {
               queue.taskDone();
            });
         });
      }
      
      private function loadVoice(param1:String) : void
      {
         var path:String = param1;
         queue.addTask(function():void
         {
            SoundManager.loadVoice(SoundManager.getVoiceId(path),path,function(param1:int):void
            {
               queue.taskDone();
            });
         });
      }
      
      private function loadGudetamaRsrc(param1:Array) : void
      {
         var gudeIds:Array = param1;
         var i:int = 0;
         while(i < gudeIds.length)
         {
            var gudeDef:GudetamaDef = GameSetting.getGudetama(gudeIds[i]);
            if(gudeDef != null)
            {
               if(gudeDef.disabledSpine)
               {
                  TextureCollector.loadTextureForTask(queue,"gudetama-" + gudeDef.rsrc + "-image",function(param1:Texture):void
                  {
                  });
               }
               else
               {
                  loadSpine(GudetamaUtil.getSpineName(gudeDef.id#2));
               }
            }
            i++;
         }
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.popScene(scene);
            TextureCollector.clearAll();
            callback();
         });
      }
      
      override public function dispose() : void
      {
         lblDesc = null;
         gauge = null;
         closeButton.removeEventListener("triggered",backButtonCallback);
         closeButton = null;
         super.dispose();
      }
   }
}
