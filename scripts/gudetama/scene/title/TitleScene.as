package gudetama.scene.title
{
   import feathers.controls.TextInput;
   import gudetama.common.BannerAdvertisingManager;
   import gudetama.common.GudetamaUtil;
   import gudetama.common.NativeExtensions;
   import gudetama.data.DataStorage;
   import gudetama.data.GameSetting;
   import gudetama.data.LocalData;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.FriendlyData;
   import gudetama.data.compati.UserData;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.LoadingDialog;
   import gudetama.engine.RsrcManager;
   import gudetama.engine.SoundManager;
   import gudetama.engine.TextureCollector;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.scene.home.HomeScene;
   import gudetama.scene.home.InquiryDialog;
   import gudetama.scene.initial.InitialScene;
   import gudetama.scene.opening.OpeningScene;
   import gudetama.ui.CacheCheckSelectDialog;
   import gudetama.ui.DownloadFirstRsrcDialog;
   import gudetama.ui.LocalMessageDialog;
   import gudetama.ui.MessageDialog;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.util.TimeZoneUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.display.SpineModel;
   import muku.text.ColorTextField;
   import muku.text.PartialBitmapFont;
   import starling.display.Image;
   import starling.display.Quad;
   import starling.events.Event;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   import starling.textures.Texture;
   
   public class TitleScene extends BaseScene
   {
      
      private static const PHASE_NONE:int = 0;
      
      private static const PHASE_PRESSED:int = 1;
      
      private static const PHASE_RELEASE:int = 2;
       
      
      private var phase:int = 0;
      
      private var bg:Image;
      
      private var starSpineModel:SpineModel;
      
      private var titleSpineModel:SpineModel;
      
      private var gudetamaSpineModel:SpineModel;
      
      private var versionText:ColorTextField;
      
      private var debugUiidInput:TextInput;
      
      private var debugNameInput:TextInput;
      
      private var startTouchableField:Quad;
      
      private var imgTap:Image;
      
      private var texTap:Texture;
      
      private var takeoverBtn:ContainerButton;
      
      private var infoButton:ContainerButton;
      
      private var cacheButton:ContainerButton;
      
      private var localeButton:ContainerButton;
      
      private var serverSettingVersion:int;
      
      private var doneSpineAnime:Boolean;
      
      private var loadCount:int;
      
      public function TitleScene()
      {
         super(0);
         var _loc2_:Boolean = true;
         var _loc1_:* = PartialBitmapFont;
         muku.text.PartialBitmapFont._forceHighQuality = _loc2_;
         BannerAdvertisingManager.showBannerAds();
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         RsrcManager.applicationStandUpDone = true;
         setupLayoutForTask(queue,"TitleLayout_Gudetama",function(param1:Object):void
         {
            var layout:Object = param1;
            displaySprite = layout.object;
            bg = displaySprite.getChildByName("bg") as Image;
            starSpineModel = displaySprite.getChildByName("starSpineModel") as SpineModel;
            starSpineModel.visible = false;
            titleSpineModel = displaySprite.getChildByName("titleSpineModel") as SpineModel;
            titleSpineModel.visible = false;
            gudetamaSpineModel = displaySprite.getChildByName("gudetamaSpineModel") as SpineModel;
            gudetamaSpineModel.visible = false;
            imgTap = displaySprite.getChildByName("imgTap") as Image;
            versionText = displaySprite.getChildByName("version") as ColorTextField;
            versionText.text#2 = GameSetting.getInitUIText("title.version").replace("%1",Engine.applicationVersion);
            takeoverBtn = displaySprite.getChildByName("btnTakeover") as ContainerButton;
            takeoverBtn.addEventListener("triggered",triggeredTakeoverButton);
            infoButton = displaySprite.getChildByName("btnInfo") as ContainerButton;
            infoButton.addEventListener("triggered",triggeredInfoButton);
            cacheButton = displaySprite.getChildByName("btnCache") as ContainerButton;
            cacheButton.addEventListener("triggered",triggeredCacheButton);
            localeButton = displaySprite.getChildByName("btnLocale") as ContainerButton;
            localeButton.addEventListener("triggered",triggeredLocaleButton);
            localeButton.visible = GudetamaUtil.isMultiLang();
            var _loc2_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            if(!gudetama.net.HttpConnector.mainConnector.isLastRequestSuccessed())
            {
               takeoverBtn.enabled = false;
               cacheButton.enabled = false;
            }
            startTouchableField = displaySprite.getChildByName("quad") as Quad;
            startTouchableField.addEventListener("touch",onTouch);
            startTouchableField.touchable = true;
            debugUiidInput = displaySprite.getChildByName("debugUiid") as TextInput;
            debugUiidInput.visible = false;
            debugNameInput = displaySprite.getChildByName("debugName") as TextInput;
            debugNameInput.visible = false;
            var titleImageName:String = GameSetting.getRule().titleName;
            var titleImageNameCountry:String = GameSetting.getRule().titleNameCountry[Engine.getCountryCode()];
            if(titleImageNameCountry && titleImageNameCountry != "")
            {
               titleImageName = titleImageNameCountry;
            }
            if(titleImageName && titleImageName != "")
            {
               TextureCollector.loadTexture(titleImageName,function(param1:Texture):void
               {
                  bg.texture = param1;
                  addChild(displaySprite);
               });
            }
            else
            {
               addChild(displaySprite);
            }
         });
         var locale:String = RsrcManager.getRsrcLocale(Engine.getLocale());
         if(locale != "ja")
         {
            addTask(function():void
            {
               TextureCollector.loadTexture("title1@text_" + locale,function(param1:Texture):void
               {
                  texTap = param1;
                  taskDone();
               });
            });
         }
         ResidentMenuUI_Gudetama.createAndSetup(queue);
         NativeExtensions.setKeepScreenFlag(true);
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            ResidentMenuUI_Gudetama.getInstance().completeAdUI();
            start();
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
         load();
      }
      
      private function load() : void
      {
         var spineName:String = "title-title_spine";
         var titleSpineName:String = GameSetting.getRule().titleSpineName;
         if(titleSpineName && titleSpineName != "")
         {
            spineName = titleSpineName;
         }
         var titleSpineNameCountry:String = GameSetting.getRule().titleSpineNameCountry[Engine.getCountryCode()];
         if(titleSpineNameCountry && titleSpineNameCountry != "")
         {
            spineName = titleSpineNameCountry;
         }
         var locale:String = Engine.getLocale();
         locale = RsrcManager.getRsrcLocale(locale);
         if(locale != "ja")
         {
            var spineName:String = spineName + ("_" + locale);
         }
         queue.addTask(function():void
         {
            titleSpineModel.load(spineName,function():void
            {
               queue.taskDone();
            });
         });
         queue.addTask(function():void
         {
            var gudetamaSpineName:String = "title-gude" + (Math.random() >= 0.5 ? 0 : 1) + "_spine";
            var titleGudetamaSpineName:String = GameSetting.getRule().titleGudetamaSpineName;
            if(titleGudetamaSpineName && titleGudetamaSpineName != "")
            {
               gudetamaSpineName = titleGudetamaSpineName;
            }
            var titleGudetamaSpineNameCountry:String = GameSetting.getRule().titleGudetamaSpineNameCountry[Engine.getCountryCode()];
            if(titleGudetamaSpineNameCountry && titleGudetamaSpineNameCountry != "")
            {
               gudetamaSpineName = titleGudetamaSpineNameCountry;
            }
            gudetamaSpineModel.load(gudetamaSpineName,function():void
            {
               queue.taskDone();
            });
         });
         if(texTap != null)
         {
            imgTap.texture = texTap;
            imgTap.width = texTap.width;
         }
      }
      
      private function start() : void
      {
         var _loc2_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         if(gudetama.net.HttpConnector.mainConnector.isLastRequestSuccessed())
         {
            takeoverBtn.enabled = true;
            cacheButton.enabled = true;
         }
         var _loc1_:LocalData = DataStorage.getLocalData();
         var _loc5_:* = _loc1_.musicVolume;
         var _loc3_:* = SoundManager;
         gudetama.engine.SoundManager.volumeOfMusic = Math.min(_loc5_,1);
         gudetama.engine.SoundManager.transformMusicVolume();
         var _loc6_:* = _loc1_.effectVolume;
         var _loc4_:* = SoundManager;
         gudetama.engine.SoundManager.volumeOfEffect = Math.min(_loc6_,1);
         SoundManager.voiceVolume = _loc1_.voiceVolume;
         SoundManager.playMusic("Title_home",-1);
      }
      
      override protected function addedToContainer() : void
      {
         showResidentMenuUI(4);
         setBackButtonCallback(GudetamaUtil.confirmGameExit);
         starSpineModel.changeAnimation("start_loop");
         starSpineModel.show();
         gudetamaSpineModel.changeAnimation("idle_loop");
         gudetamaSpineModel.show();
      }
      
      override protected function removedPushedSceneFromContainer(param1:Event) : void
      {
         super.removedPushedSceneFromContainer(param1);
      }
      
      override protected function transitionOpenFinished() : void
      {
         SoundManager.playEffect("title_call");
         titleSpineModel.changeAnimation("start",false,function():void
         {
            titleSpineModel.changeAnimation("idol_loop");
            doneSpineAnime = true;
         });
         titleSpineModel.show();
      }
      
      private function onTouch(param1:TouchEvent) : void
      {
         var event:TouchEvent = param1;
         var touch:Touch = event.getTouch(startTouchableField);
         if(touch == null)
         {
            return;
         }
         if(touch.phase == "began")
         {
            displaySprite.touchable = false;
            gudetamaSpineModel.changeAnimation("tap_start",false,function():void
            {
               if(phase == 2)
               {
                  gudetamaSpineModel.changeAnimation("release_start");
                  checkTutorialProgressAndLogin();
                  SoundManager.playEffect("title_soy");
                  if(doneSpineAnime)
                  {
                     SoundManager.playEffect("TopGudetama_koke");
                  }
                  displaySprite.touchable = true;
               }
               else
               {
                  phase = 1;
               }
            });
         }
         else if(touch.phase == "ended")
         {
            if(phase == 1)
            {
               gudetamaSpineModel.changeAnimation("release_start");
               checkTutorialProgressAndLogin();
               SoundManager.playEffect("title_soy");
               if(doneSpineAnime)
               {
                  SoundManager.playEffect("TopGudetama_koke");
               }
               displaySprite.touchable = true;
            }
            phase = 2;
         }
      }
      
      private function processLogin(param1:Function, param2:Boolean = false) : void
      {
         var callback:Function = param1;
         var byTakeoverSuccess:Boolean = param2;
         Engine.showLoading();
         NativeExtensions.getNativeIdfv(function(param1:String):void
         {
            var idfv:String = param1;
            DataStorage.getLocalData().tempIdfv = idfv;
            var _loc2_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.login(function(param1:int):void
            {
               var version:int = param1;
               serverSettingVersion = version;
               var settingSetupCompleted:Function = function():void
               {
                  var _loc1_:* = HttpConnector;
                  if(gudetama.net.HttpConnector.mainConnector == null)
                  {
                     gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
                  }
                  gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithIntAndArrayObject(10,TimeZoneUtil.epochMillisToOffsetSecs(),Engine.getLocale()),function(param1:Array):void
                  {
                     var response:Array = param1;
                     UserDataWrapper.init(response[0] as UserData);
                     UserDataWrapper.friendPart.setupList(response[1]);
                     var intArray:Array = response[2];
                     Engine.serverTimeOffsetSec = intArray[0];
                     UserDataWrapper.wrapper.hasPresentLimitSoon = intArray[1] != 0;
                     UserDataWrapper.friendPart.setNumFollowers(response[3][0]);
                     UserDataWrapper.friendPart.setNumFriends(response[3][1]);
                     var friendlyList:Array = response[4];
                     for each(friendlyData in friendlyList)
                     {
                        UserDataWrapper.wrapper.updateFriendlyData(friendlyData);
                     }
                     DataStorage.getLocalData().friendKey = UserDataWrapper.wrapper.getFriendKey();
                     var _loc5_:* = UserDataWrapper;
                     if(gudetama.data.UserDataWrapper.wrapper._data.playerName.length > 0)
                     {
                        var _loc6_:* = UserDataWrapper;
                        DataStorage.getLocalData().playerName = gudetama.data.UserDataWrapper.wrapper._data.playerName;
                        var _loc7_:* = UserDataWrapper;
                        DataStorage.getLocalData().gender = gudetama.data.UserDataWrapper.wrapper._data.gender;
                     }
                     DataStorage.saveLocalData();
                     setupAndroidBillingNativeExtensions();
                     if(UserDataWrapper.wrapper.isCompletedTutorial())
                     {
                        Engine.checkPushToken();
                     }
                     Engine.procAppsFlyer();
                     ResidentMenuUI_Gudetama.getInstance().updateUserInfo();
                     ResidentMenuUI_Gudetama.initUpperPart();
                     NativeExtensions.setupAppPurchase(function(param1:int, param2:Object):void
                     {
                        var _loc3_:* = null;
                        if(param1 == 0)
                        {
                           _loc3_ = param2 as String;
                           DataStorage.getLocalData().addReceipt(UserDataWrapper.wrapper.getUid(),_loc3_);
                           DataStorage.saveLocalData();
                        }
                     });
                     callback();
                  });
               };
               if(serverSettingVersion == GameSetting.def.version)
               {
                  settingSetupCompleted();
               }
               else
               {
                  Engine.showLoading();
                  GameSetting.setupForVersion(serverSettingVersion,settingSetupCompleted);
               }
            },idfv);
         });
      }
      
      private function debugName(param1:Function) : void
      {
         if(!(false && UserDataWrapper.wrapper.getPlayerName().length == 0))
         {
            param1();
         }
      }
      
      private function triggeredTakeoverButton(param1:Event) : void
      {
         var event:Event = param1;
         LocalMessageDialog.show(5,GameSetting.getInitUIText("takeover.about.desc"),function(param1:int):void
         {
            if(param1 == 1)
            {
               return;
            }
            TakeoverSelectDialog.show(processLogin);
         },GameSetting.getInitUIText("takeover.about.title"),12);
      }
      
      private function triggeredInfoButton(param1:Event) : void
      {
         GudetamaUtil.showInfoPage();
      }
      
      private function triggeredCacheButton(param1:Event) : void
      {
         CacheCheckSelectDialog.show(true);
      }
      
      private function triggeredInquiryButton(param1:Event) : void
      {
         InquiryDialog.show(true);
      }
      
      private function triggeredDebugButton(param1:Event) : void
      {
      }
      
      private function triggeredFullButton(param1:Event) : void
      {
      }
      
      private function triggeredSetLevelTestButton(param1:Event) : void
      {
      }
      
      private function checkTutorialProgressAndLogin() : void
      {
         processLogin(function():void
         {
            var _loc1_:* = UserDataWrapper;
            if(!gudetama.data.UserDataWrapper.wrapper._data.doneFirstLogin)
            {
               if(checkNeedDownloadFirstRsrc())
               {
                  DownloadFirstRsrcDialog.show(true,goOpeningScene);
               }
               else
               {
                  goOpeningScene();
               }
            }
            else if(checkNeedDownloadFirstRsrc())
            {
               DownloadFirstRsrcDialog.show(false,goHomeScene);
            }
            else
            {
               goHomeScene();
            }
         });
      }
      
      private function checkNeedDownloadFirstRsrc() : Boolean
      {
         if(!DataStorage.getLocalData().isNeedDownloadFirstRsrc())
         {
            return false;
         }
         if(GameSetting.hasScreeningFlag(6))
         {
            return true;
         }
         DataStorage.getLocalData().setNeedDownloadFirstRsrc(false);
         DataStorage.saveLocalData();
         return false;
      }
      
      private function goOpeningScene() : void
      {
         var _loc1_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(77),function(param1:*):void
         {
            var _loc3_:* = 0;
            var _loc2_:Array = param1;
            if(UserDataWrapper.wrapper.equalsTutorialProgress(0))
            {
               _loc3_ = uint(0);
            }
            else if(UserDataWrapper.wrapper.equalsTutorialProgress(1))
            {
               _loc3_ = uint(1);
            }
            Engine.switchScene(new OpeningScene(_loc3_,_loc2_),0,0);
         });
      }
      
      private function goHomeScene() : void
      {
         ResidentMenuUI_Gudetama.getInstance().sendChangeState(60,function():void
         {
            Engine.switchScene(new HomeScene());
         });
      }
      
      private function debugLogin(param1:Boolean = false) : void
      {
         var full:Boolean = param1;
         processDebugLogin(function():void
         {
            goHomeScene();
         },!!full ? 1 : 0);
      }
      
      private function debugLoginWithRank(param1:int) : void
      {
         var rank:int = param1;
         processDebugLogin(function():void
         {
            goHomeScene();
         },rank);
      }
      
      private function processDebugLogin(param1:Function, param2:int) : void
      {
         var callback:Function = param1;
         var rank:int = param2;
         Engine.showLoading();
         NativeExtensions.getNativeIdfv(function(param1:String):void
         {
            var idfv:String = param1;
            DataStorage.getLocalData().tempIdfv = idfv;
            var _loc2_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.login(function(param1:int):void
            {
               var version:int = param1;
               serverSettingVersion = version;
               var settingSetupCompleted:Function = function():void
               {
                  var _loc1_:* = HttpConnector;
                  if(gudetama.net.HttpConnector.mainConnector == null)
                  {
                     gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
                  }
                  gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithIntAndArrayObject(10,TimeZoneUtil.epochMillisToOffsetSecs(),Engine.getLocale()),function(param1:Array):void
                  {
                     var response:Array = param1;
                     UserDataWrapper.init(response[0] as UserData);
                     var followProfiles:Array = response[1];
                     UserDataWrapper.friendPart.setupList(followProfiles);
                     var intArray:Array = response[2];
                     Engine.serverTimeOffsetSec = intArray[0];
                     var hasPresentLimitSoon:Boolean = intArray[1] != 0;
                     var numFollowers:int = response[3][0];
                     var numFriends:int = response[3][1];
                     var friendlyList:Array = response[4];
                     for each(friendlyData in friendlyList)
                     {
                        UserDataWrapper.wrapper.updateFriendlyData(friendlyData);
                     }
                     DataStorage.getLocalData().friendKey = UserDataWrapper.wrapper.getFriendKey();
                     var _loc5_:* = UserDataWrapper;
                     if(gudetama.data.UserDataWrapper.wrapper._data.playerName.length > 0)
                     {
                        var _loc6_:* = UserDataWrapper;
                        DataStorage.getLocalData().playerName = gudetama.data.UserDataWrapper.wrapper._data.playerName;
                        var _loc7_:* = UserDataWrapper;
                        DataStorage.getLocalData().gender = gudetama.data.UserDataWrapper.wrapper._data.gender;
                     }
                     DataStorage.saveLocalData();
                     setupAndroidBillingNativeExtensions();
                     Engine.procAppsFlyer();
                     ResidentMenuUI_Gudetama.getInstance().updateUserInfo();
                     ResidentMenuUI_Gudetama.initUpperPart();
                     NativeExtensions.setupAppPurchase(function(param1:int, param2:Object):void
                     {
                        var _loc3_:* = null;
                        if(param1 == 0)
                        {
                           _loc3_ = param2 as String;
                           DataStorage.getLocalData().addReceipt(UserDataWrapper.wrapper.getUid(),_loc3_);
                           DataStorage.saveLocalData();
                        }
                     });
                     var _loc8_:* = HttpConnector;
                     if(gudetama.net.HttpConnector.mainConnector == null)
                     {
                        gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
                     }
                     gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(117441511,rank),function(param1:UserData):void
                     {
                        var response:UserData = param1;
                        UserDataWrapper.init(response);
                        UserDataWrapper.friendPart.setupList(followProfiles);
                        UserDataWrapper.friendPart.setNumFollowers(numFollowers);
                        UserDataWrapper.friendPart.setNumFriends(numFriends);
                        UserDataWrapper.wrapper.hasPresentLimitSoon = hasPresentLimitSoon;
                        Engine.checkPushToken();
                        debugName(function():void
                        {
                           ResidentMenuUI_Gudetama.getInstance().updateUserInfo();
                           ResidentMenuUI_Gudetama.initUpperPart();
                           callback();
                        });
                     });
                  });
               };
               if(serverSettingVersion == GameSetting.def.version)
               {
                  settingSetupCompleted();
               }
               else
               {
                  Engine.showLoading();
                  GameSetting.setupForVersion(serverSettingVersion,settingSetupCompleted);
               }
            },idfv);
         });
      }
      
      private function setupAndroidBillingNativeExtensions() : void
      {
         NativeExtensions.prepareAndroidBilling();
      }
      
      private function triggeredLocaleButton() : void
      {
         var orgLocale:String = Engine.getLocale();
         InitialScene.showLocaleSelect(function():void
         {
            var locale:String = Engine.getLocale();
            if(orgLocale == locale)
            {
               return;
            }
            DataStorage.getLocalData().setNeedDownloadFirstRsrc(locale != "ja");
            Engine.clearCache();
            TextureCollector.clearAll(1);
            RsrcManager.clearFileCache();
            RsrcManager.getInstance().setupFileCheckMap(null);
            LoadingDialog.resetLoadingText();
            GudetamaUtil.initFont(function():void
            {
               if(GameSetting.def.version != -1)
               {
                  GameSetting.setupForVersion(GameSetting.def.version,function():void
                  {
                     ResidentMenuUI_Gudetama.clearInstance();
                     MessageDialog.clearSingleton();
                     MessageDialog.createSingleton();
                     InitialScene.switchNextScene();
                  });
                  return;
               }
               GameSetting.setup(function():void
               {
                  GameSetting.def.version = -1;
                  ResidentMenuUI_Gudetama.clearInstance();
                  MessageDialog.clearSingleton();
                  MessageDialog.createSingleton();
                  InitialScene.switchNextScene();
               });
            });
         },true);
      }
      
      private function updateHostLabel(param1:String) : void
      {
      }
      
      private function triggerdHostReset() : void
      {
      }
      
      private function triggeredCheckFont() : void
      {
      }
      
      override public function dispose() : void
      {
         titleSpineModel = null;
         debugUiidInput = null;
         startTouchableField.removeEventListener("touch",onTouch);
         startTouchableField = null;
         takeoverBtn.removeEventListener("triggered",triggeredTakeoverButton);
         takeoverBtn = null;
         infoButton.removeEventListener("triggered",triggeredInfoButton);
         infoButton = null;
         cacheButton.removeEventListener("triggered",triggeredCacheButton);
         cacheButton = null;
         localeButton.removeEventListener("triggered",triggeredLocaleButton);
         localeButton = null;
         super.dispose();
      }
   }
}
