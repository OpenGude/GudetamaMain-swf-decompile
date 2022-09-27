package gudetama.scene.friend
{
   import flash.geom.Rectangle;
   import gudetama.common.HomeDecoUtil;
   import gudetama.data.DataStorage;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.FriendAssistResult;
   import gudetama.data.compati.GudetamaDef;
   import gudetama.data.compati.KitchenwareData;
   import gudetama.data.compati.QuestionDef;
   import gudetama.data.compati.UsefulDef;
   import gudetama.data.compati.UserProfileData;
   import gudetama.data.compati.UserRoomInfo;
   import gudetama.data.compati.VoiceDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.SoundManager;
   import gudetama.engine.TextureCollector;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.scene.home.HomeScene;
   import gudetama.scene.home.ui.EventButton;
   import gudetama.scene.home.ui.TouchTextGroup;
   import gudetama.ui.HomeScroller;
   import gudetama.ui.LocalMessageDialog;
   import gudetama.ui.PresentMoneyAndFriendlyDialog;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.util.SpriteExtractor;
   import muku.core.MukuGlobal;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.display.ManuallySpineButton;
   import muku.display.PagedScrollContainer;
   import muku.display.SpineModel;
   import starling.display.Image;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.events.TouchEvent;
   import starling.textures.Texture;
   
   public class FriendRoomScene extends BaseScene
   {
      
      private static const UPDATE_INTERVAL:int = 1000;
       
      
      private var profile:UserProfileData;
      
      private var backFromRoomFunc:Function;
      
      private var homeScroller:HomeScroller;
      
      private var weatherSpineModel:SpineModel;
      
      private var mountainImage:Image;
      
      private var roomImage:Image;
      
      private var dishImage:Image;
      
      private var gudetamaGroup:Sprite;
      
      private var gudetamaButton:ManuallySpineButton;
      
      private var kitchenwares:Vector.<KitchenwareButton>;
      
      private var profileUI:ProfileUI;
      
      private var touchTextGroup:TouchTextGroup;
      
      private var goBackButton:ContainerButton;
      
      private var questionUI:QuestionUI;
      
      private var presentMoneyUI:PresentMoneyUI;
      
      private var assistUI:AssistUI;
      
      private var prevRoomButton:ContainerButton;
      
      private var nextRoomButton:ContainerButton;
      
      private var assistButtonUI:AssistButtonUI;
      
      private var gudetamaQuad:Quad;
      
      private var touchTextItemExtractor:SpriteExtractor;
      
      private var amountExtractor:SpriteExtractor;
      
      public var userRoomInfo:UserRoomInfo;
      
      private var nextUpdateTime:int;
      
      private var finishGudetamaQuadTime:uint;
      
      private var loadCount:int;
      
      private var scrollPageIndex:int;
      
      private var visibleGudetamaQuad:Boolean;
      
      private var stampLayer:Sprite;
      
      private var eventButton:EventButton;
      
      public function FriendRoomScene(param1:UserProfileData, param2:Function = null)
      {
         kitchenwares = new Vector.<KitchenwareButton>();
         super(0);
         this.profile = param1;
         this.backFromRoomFunc = param2;
         addEventListener("refreshed_scene_container",refreshedSceneContainer);
         addEventListener("update_scene",updateScene);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"FriendRoomLayout",function(param1:Object):void
         {
            var _loc4_:int = 0;
            var _loc3_:* = null;
            displaySprite = param1.object;
            var _loc6_:Sprite;
            var _loc7_:PagedScrollContainer = (_loc6_ = displaySprite.getChildByName("scrollGroup") as Sprite).getChildByName("scrollContainer") as PagedScrollContainer;
            homeScroller = new HomeScroller(displaySprite,scene,horizontalThrowToPageCallback,horizontalScrollCallback,true);
            homeScroller.scrollToPageIndex(homeScroller.horizontalPageCount,0);
            weatherSpineModel = _loc7_.getChildByName("weatherSpineModel") as SpineModel;
            mountainImage = _loc7_.getChildByName("mountain") as Image;
            stampLayer = _loc7_.getChildByName("stampLayer") as Sprite;
            roomImage = _loc7_.getChildByName("room") as Image;
            dishImage = _loc7_.getChildByName("dish") as Image;
            gudetamaGroup = _loc7_.getChildByName("gudetamaGroup") as Sprite;
            var _loc2_:Sprite = gudetamaGroup.getChildByName("origin") as Sprite;
            gudetamaButton = gudetamaGroup.getChildByName("gudetamaButton") as ManuallySpineButton;
            gudetamaButton.addEventListener("triggered",triggeredGudetamaButton);
            gudetamaButton.setOrigin(_loc2_.x,_loc2_.y);
            gudetamaButton.setTouchBeganCallback(gudetamaButtonTouchBeganCallback);
            gudetamaButton.setTouchEndedCallback(gudetamaButtonTouchEndedCallback);
            gudetamaButton.setReleaseBeganCallback(gudetamaButtonReleaseBeganCallback);
            gudetamaButton.setRubCallback(gudetamaButtonRubCallback);
            var _loc5_:Sprite = _loc7_.getChildByName("kitchenwareGroup") as Sprite;
            _loc4_ = 0;
            while(_loc4_ < 5)
            {
               _loc3_ = _loc5_.getChildByName("kitchenware" + _loc4_) as Sprite;
               kitchenwares.push(new KitchenwareButton(_loc3_,_loc4_,triggeredKitchenwareButtonCallback));
               _loc4_++;
            }
            profileUI = new ProfileUI(displaySprite.getChildByName("titleGroup") as Sprite);
            touchTextGroup = new TouchTextGroup(_loc7_.getChildByName("touchTextGroup") as Sprite);
            goBackButton = displaySprite.getChildByName("goBackButton") as ContainerButton;
            goBackButton.addEventListener("triggered",triggeredGoBackButton);
            questionUI = new QuestionUI(_loc7_.getChildByName("questionGroup") as Sprite);
            questionUI.setVisible(false);
            presentMoneyUI = new PresentMoneyUI(displaySprite.getChildByName("presentMoneyGroup") as Sprite);
            assistUI = new AssistUI(displaySprite.getChildByName("assistGroup") as Sprite,scene);
            prevRoomButton = displaySprite.getChildByName("prevRoomButton") as ContainerButton;
            prevRoomButton.addEventListener("triggered",triggeredPrevRoomButton);
            nextRoomButton = displaySprite.getChildByName("nextRoomButton") as ContainerButton;
            nextRoomButton.addEventListener("triggered",triggeredNextRoomButton);
            assistButtonUI = new AssistButtonUI(_loc7_.getChildByName("assistButton") as ContainerButton,triggeredAssistButtonCallback);
            gudetamaQuad = displaySprite.getChildByName("gudetamaQuad") as Quad;
            gudetamaQuad.addEventListener("touch",onTouchGudetamaQuad);
            eventButton = new EventButton(_loc7_.getChildByName("eventButton") as ContainerButton);
            eventButton.getDisplaySprite().touchable = false;
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         setupLayoutForTask(queue,"_TouchText",function(param1:Object):void
         {
            touchTextItemExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         setupLayoutForTask(queue,"_CounterAmount",function(param1:Object):void
         {
            amountExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         addTask(function():void
         {
            var _loc1_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(FRIEND_ENTER_ROOM,profile.encodedUid),function(param1:UserRoomInfo):void
            {
               userRoomInfo = param1;
               UserDataWrapper.wrapper.updateFriendlyData(userRoomInfo.friendlyData);
               UserDataWrapper.wrapper.updateFriendPresentMoneyParam(profile.encodedUid,userRoomInfo.friendPresentMoneyParam);
               taskDone();
            });
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
         load();
      }
      
      private function load() : void
      {
         queue.addTask(function():void
         {
            var innerQueue:TaskQueue = new TaskQueue();
            var gudetamaDef:GudetamaDef = GameSetting.getGudetama(userRoomInfo.placedGudetamaId);
            gudetamaButton.setup(innerQueue,userRoomInfo.placedGudetamaId,true);
            gudetamaButton.setDispatcher(gudetamaQuad);
            eventButton.setup();
            setRoomTexture(innerQueue);
            if(userRoomInfo.questionId > 0)
            {
               innerQueue.addTask(function():void
               {
                  var questionDef:QuestionDef = GameSetting.getQuestion(userRoomInfo.questionId);
                  var voiceDef:VoiceDef = GameSetting.getVoice(questionDef.questionVoiceId);
                  var path:String = MukuGlobal.makePathFromVoiceName(voiceDef.id#2,voiceDef.rsrc);
                  SoundManager.loadVoice(SoundManager.getVoiceId(path),path,function(param1:int):void
                  {
                     innerQueue.taskDone();
                  });
               });
            }
            innerQueue.registerOnProgress(function(param1:Number):void
            {
               if(param1 < 1)
               {
                  return;
               }
               profileUI.setup(queue,profile,userRoomInfo);
               for each(var _loc2_ in kitchenwares)
               {
                  _loc2_.setup(userRoomInfo.kitchenwareMap[_loc2_.type]);
               }
               dishImage.visible = gudetamaDef.dish;
               var _loc3_:Rectangle = new Rectangle(gudetamaGroup.x - gudetamaGroup.pivotX - 0.5 * gudetamaButton.width - (gudetamaButton.pivotX - 0.5 * gudetamaButton.width),gudetamaGroup.y - gudetamaGroup.pivotY - 0.5 * gudetamaButton.height - (gudetamaButton.pivotY - 0.5 * gudetamaButton.height),gudetamaButton.width,gudetamaButton.height);
               touchTextGroup.setup(queue,userRoomInfo.placedGudetamaId,touchTextItemExtractor,_loc3_);
               questionUI.setup(userRoomInfo.questionId);
               presentMoneyUI.setup(profile,amountExtractor);
               assistUI.update();
               setup();
               queue.taskDone();
            });
            innerQueue.startTask();
         });
         var backgroundName:String = UserDataWrapper.eventPart.getBackgroundName();
         if(backgroundName)
         {
            queue.addTask(function():void
            {
               TextureCollector.loadTextureRsrc(backgroundName,function(param1:Texture):void
               {
                  mountainImage.texture = param1;
                  queue.taskDone();
               });
            });
         }
      }
      
      private function setRoomTexture(param1:TaskQueue) : void
      {
         var _queue:TaskQueue = param1;
         var decorationId:int = userRoomInfo.decorationId;
         if(decorationId <= 0)
         {
            decorationId = 1;
         }
         _queue.addTask(function():void
         {
            TextureCollector.loadTexture("room-" + decorationId + "-bg",function(param1:Texture):void
            {
               roomImage.texture = param1;
               if(userRoomInfo.homeDecoDataList)
               {
                  HomeDecoUtil.setDecoData(userRoomInfo.homeDecoDataList,roomImage,stampLayer,_queue);
                  _queue.taskDone();
               }
               else
               {
                  _queue.taskDone();
               }
               _queue.taskDone();
            });
         });
      }
      
      private function setup() : void
      {
         homeScroller.resetViewPort();
         weatherSpineModel.show();
         weatherSpineModel.changeAnimation("start_loop");
         visibleGudetamaQuad = false;
         updateGudetamaQuad();
         if(UserDataWrapper.friendPart.getNumFriends() > 1)
         {
            prevRoomButton.visible = true;
            nextRoomButton.visible = true;
         }
         else
         {
            prevRoomButton.visible = false;
            nextRoomButton.visible = false;
         }
         var _loc1_:int = !!userRoomInfo.assistData ? userRoomInfo.assistData.num : 0;
         var _loc2_:* = _loc1_ < GameSetting.getRule().maxAssistPerDay;
         var _loc3_:int = getNumAssistable();
         if(_loc2_ && _loc3_ > 0)
         {
            assistButtonUI.setVisible(true);
            assistButtonUI.setup(_loc3_);
         }
         else
         {
            assistButtonUI.setVisible(false);
         }
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(FriendRoomScene);
         setBackButtonCallback(backButtonCallback);
         showResidentMenuUI(68);
         var _loc2_:* = interruptFunctionAtSwitchScene;
         var _loc1_:* = Engine;
         gudetama.engine.Engine.singleton._interruptFunctionAtSwitchScene = _loc2_;
         displaySprite.visible = true;
      }
      
      private function noticeTutorialAction(param1:int) : void
      {
         switch(int(param1))
         {
            case 0:
               homeScroller.scrollLeft();
               break;
            case 1:
               homeScroller.scrollRight();
               break;
            case 2:
               questionUI.show();
         }
      }
      
      override protected function transitionOpenFinished() : void
      {
         Engine.unlockTouchInput(FriendRoomScene);
         profileUI.updateWithAnimation();
         FriendlyRewardDialog.show([[UserDataWrapper.wrapper.getFriendlyData(profile.encodedUid),[userRoomInfo.lastFriendlyLevel],profile]],function():void
         {
            var _loc1_:Boolean = processNoticeTutorial(12,noticeTutorialAction);
            if(!_loc1_)
            {
               questionUI.show();
            }
         });
      }
      
      private function horizontalThrowToPageCallback(param1:int) : void
      {
         setScrollPageIndex(param1);
      }
      
      private function horizontalScrollCallback(param1:Number) : void
      {
         var _loc3_:Number = Math.max(0,(param1 - 0.5) / 0.5);
         presentMoneyUI.alpha = _loc3_;
         assistButtonUI.alpha = _loc3_;
         var _loc2_:Number = Math.max(0,(1 - param1 - 0.5) / 0.5);
         assistUI.alpha = _loc2_;
      }
      
      public function setScrollPageIndex(param1:int) : void
      {
         scrollPageIndex = param1;
         updateGudetamaQuad();
         profileUI.setVisible(param1 == 1);
      }
      
      public function updateGudetamaQuad() : void
      {
         gudetamaQuad.visible = scrollPageIndex == 1 && visibleGudetamaQuad;
      }
      
      private function backButtonCallback() : void
      {
         if(Engine.getGuideTalkPanel() != null)
         {
            return;
         }
         ResidentMenuUI_Gudetama.getInstance().sendChangeState(60,function():void
         {
            UserDataWrapper.kitchenwarePart.resetUpdateRestTimeMapOnetime();
            Engine.switchScene(new HomeScene());
         });
      }
      
      public function addMoneyByIndex(param1:int) : void
      {
         var _loc3_:int = profile.playerRank * GameSetting.getRule().maxFriendPresentMoneyPerRank;
         if(!UserDataWrapper.wrapper.isEnabledPresentMoneyToFriend(profile.encodedUid,_loc3_))
         {
            return;
         }
         var _loc2_:int = profile.playerRank;
         _loc2_ = UserDataWrapper.wrapper.presentMoneyToFriend(profile.encodedUid,_loc2_,_loc3_);
         presentMoneyUI.add(_loc2_);
         DataStorage.getLocalData().incrementPendingFriendTouchEventCount(profile.encodedUid,_loc2_);
      }
      
      private function triggeredGudetamaButton(param1:Event) : void
      {
         if(!Engine.isTopScene(scene))
         {
            return;
         }
         addMoneyByIndex(0);
         touchTextGroup.show();
      }
      
      private function gudetamaButtonRubCallback() : void
      {
         if(!Engine.isTopScene(scene))
         {
            return;
         }
         addMoneyByIndex(0);
         touchTextGroup.show(true);
         var _loc1_:Number = Math.random();
         if(_loc1_ > 0.5)
         {
            SoundManager.playEffect("put_egg");
         }
         else
         {
            SoundManager.playEffect("tap_nisetama");
         }
      }
      
      private function gudetamaButtonTouchBeganCallback() : void
      {
         homeScroller.setHorizontalScrollPolicy("off");
      }
      
      private function gudetamaButtonTouchEndedCallback() : void
      {
         homeScroller.setHorizontalScrollPolicy("auto");
      }
      
      private function gudetamaButtonReleaseBeganCallback() : void
      {
         if(Math.random() > 0.5)
         {
            SoundManager.playEffect("put_egg");
         }
         else
         {
            SoundManager.playEffect("tap_nisetama");
         }
         visibleGudetamaQuad = true;
         updateGudetamaQuad();
         finishGudetamaQuadTime = Engine.now + gudetamaButton.releaseTweenTime * 1000;
      }
      
      private function getNumAssistable() : int
      {
         var _loc2_:int = 0;
         for each(var _loc1_ in userRoomInfo.kitchenwareMap)
         {
            if(!(!UserDataWrapper.kitchenwarePart.isCookingByKitchenware(_loc1_) || UserDataWrapper.kitchenwarePart.finishedCookingByKitchenwareOneTime(_loc1_)))
            {
               for each(var _loc3_ in GameSetting.getUsefulMap())
               {
                  if(_loc3_.assistAbilities)
                  {
                     if(!_loc1_.existsUsefulIdInAssist(_loc3_.id#2))
                     {
                        if(UserDataWrapper.usefulPart.hasUseful(_loc3_.id#2))
                        {
                           if(_loc1_.target == 0)
                           {
                              if(_loc3_.hasHappeningInAssistAbilities())
                              {
                                 continue;
                              }
                           }
                           else if(_loc3_.hasSuccessInAssistAbilities())
                           {
                              continue;
                           }
                           _loc2_++;
                           break;
                        }
                     }
                  }
               }
            }
         }
         return _loc2_;
      }
      
      private function onTouchGudetamaQuad(param1:TouchEvent) : void
      {
         gudetamaButton.dispatchEvent(param1);
      }
      
      private function triggeredKitchenwareButtonCallback(param1:KitchenwareData) : void
      {
         var kitchenwareData:KitchenwareData = param1;
         var assistListDialog:AssistListDialog = AssistListDialog.show(kitchenwareData,function(param1:int):void
         {
            var usefulId:int = param1;
            var num:int = !!userRoomInfo.assistData ? userRoomInfo.assistData.num : 0;
            var max:int = GameSetting.getRule().maxAssistPerDay;
            if(num >= max)
            {
               LocalMessageDialog.show(0,GameSetting.getUIText("friendRoom.assist.over.desc"),null,GameSetting.getUIText("friendRoom.assist.over.title"),92);
               return;
            }
            AssistConfirmDialog.show(usefulId,function():void
            {
               Engine.showLoading(FriendRoomScene);
               var _loc1_:* = HttpConnector;
               if(gudetama.net.HttpConnector.mainConnector == null)
               {
                  gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
               }
               gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(FRIEND_ASSIST,[profile.encodedUid,kitchenwareData.type,usefulId]),function(param1:*):void
               {
                  var response:* = param1;
                  Engine.hideLoading(FriendRoomScene);
                  if(!(response is FriendAssistResult))
                  {
                     var result:int = response[0][0];
                     userRoomInfo = response[1];
                     LocalMessageDialog.show(0,GameSetting.getUIText("friendRoom.warning." + Math.abs(result)));
                     for each(kitchenware in kitchenwares)
                     {
                        kitchenware.setup(userRoomInfo.kitchenwareMap[kitchenware.type]);
                     }
                     assistListDialog.updateKitchenwareData(userRoomInfo.kitchenwareMap[kitchenwareData.type]);
                     return;
                  }
                  var friendAssistResult:FriendAssistResult = response;
                  userRoomInfo = friendAssistResult.userRoomInfo;
                  UserDataWrapper.wrapper.updateFriendlyData(userRoomInfo.friendlyData);
                  for each(kitchenware in kitchenwares)
                  {
                     kitchenware.setup(userRoomInfo.kitchenwareMap[kitchenware.type]);
                  }
                  UserDataWrapper.usefulPart.consumeUseful(usefulId,1);
                  kitchenwares[kitchenwareData.type].showShortenTime(usefulId);
                  assistListDialog.updateKitchenwareData(userRoomInfo.kitchenwareMap[kitchenwareData.type]);
                  var numAssisted:int = !!userRoomInfo.assistData ? userRoomInfo.assistData.num : 0;
                  var assistable:Boolean = numAssisted < GameSetting.getRule().maxAssistPerDay;
                  var numAssistable:int = getNumAssistable();
                  if(assistable && numAssistable > 0)
                  {
                     assistButtonUI.setVisible(true);
                     assistButtonUI.setup(numAssistable);
                  }
                  else
                  {
                     assistButtonUI.setVisible(false);
                  }
                  if(friendAssistResult.lastFriendly != UserDataWrapper.wrapper.getFriendly(profile.encodedUid))
                  {
                     FriendlyResultDialog.show(GameSetting.getUIText("friendlyResult.title"),GameSetting.getUIText("friendlyResult.assist.desc"),friendAssistResult.addFriendly,function():void
                     {
                        FriendlyRewardDialog.show([[UserDataWrapper.wrapper.getFriendlyData(profile.encodedUid),[friendAssistResult.lastFriendlyLevel],profile]],function():void
                        {
                           ResidentMenuUI_Gudetama.getInstance().checkClearedMission(function():void
                           {
                           });
                        },92);
                     },92);
                  }
                  else
                  {
                     LocalMessageDialog.show(0,GameSetting.getUIText("friendlyResult.full.assist.desc"),function(param1:int):void
                     {
                        var choose:int = param1;
                        ResidentMenuUI_Gudetama.getInstance().checkClearedMission(function():void
                        {
                        });
                     },GameSetting.getUIText("friendlyResult.full.assist.title"));
                  }
                  Engine.broadcastEventToSceneStackWith("update_scene");
               });
            });
         });
      }
      
      private function triggeredGoBackButton(param1:Event) : void
      {
         var event:Event = param1;
         if(backFromRoomFunc)
         {
            backFromRoomFunc();
         }
         else
         {
            ResidentMenuUI_Gudetama.getInstance().sendChangeState(63,function():void
            {
               Engine.switchScene(new FriendScene_Gudetama());
            });
         }
      }
      
      private function triggeredPrevRoomButton(param1:Event) : void
      {
         var _loc2_:UserProfileData = UserDataWrapper.friendPart.getPrevFriend(profile);
         if(_loc2_)
         {
            Engine.switchScene(new FriendRoomScene(_loc2_,backFromRoomFunc));
         }
      }
      
      private function triggeredNextRoomButton(param1:Event) : void
      {
         var _loc2_:UserProfileData = UserDataWrapper.friendPart.getNextFriend(profile);
         if(_loc2_)
         {
            Engine.switchScene(new FriendRoomScene(_loc2_,backFromRoomFunc));
         }
      }
      
      private function triggeredAssistButtonCallback() : void
      {
         homeScroller.scrollToPageIndex(0,-1,function():void
         {
         });
      }
      
      override public function advanceTime(param1:Number) : void
      {
         super.advanceTime(param1);
         if(visibleGudetamaQuad && Engine.now > finishGudetamaQuadTime)
         {
            visibleGudetamaQuad = false;
            updateGudetamaQuad();
         }
         presentMoneyUI.advanceTime(param1);
         profileUI.advanceTime(param1);
         if(Engine.now < nextUpdateTime)
         {
            return;
         }
         for each(var _loc2_ in kitchenwares)
         {
            _loc2_.advanceTime(param1);
         }
         nextUpdateTime = Engine.now + 1000;
      }
      
      private function refreshedSceneContainer(param1:Event) : void
      {
      }
      
      private function updateScene() : void
      {
         profileUI.update();
         assistUI.update();
         eventButton.setup();
      }
      
      private function interruptFunctionAtSwitchScene(param1:Function) : void
      {
         PresentMoneyAndFriendlyDialog.show(param1);
      }
      
      override public function dispose() : void
      {
         profile = null;
         removeEventListener("refreshed_scene_container",refreshedSceneContainer);
         removeEventListener("update_scene",updateScene);
         homeScroller.dispose();
         homeScroller = null;
         weatherSpineModel = null;
         mountainImage = null;
         dishImage = null;
         gudetamaButton.dispose();
         gudetamaButton = null;
         for each(var _loc1_ in kitchenwares)
         {
            _loc1_.dispose();
         }
         kitchenwares.length = 0;
         _loc1_ = null;
         if(profileUI)
         {
            profileUI.dispose();
            profileUI = null;
         }
         userRoomInfo = null;
         goBackButton.removeEventListener("triggered",triggeredGoBackButton);
         goBackButton = null;
         questionUI.dispose();
         questionUI = null;
         if(presentMoneyUI)
         {
            presentMoneyUI.dispose();
            presentMoneyUI = null;
         }
         if(assistUI)
         {
            assistUI.dispose();
            assistUI = null;
         }
         if(prevRoomButton)
         {
            prevRoomButton.removeEventListener("triggered",triggeredPrevRoomButton);
            prevRoomButton = null;
         }
         if(nextRoomButton)
         {
            nextRoomButton.removeEventListener("triggered",triggeredNextRoomButton);
            nextRoomButton = null;
         }
         if(assistButtonUI)
         {
            assistButtonUI.dispose();
            assistButtonUI = null;
         }
         gudetamaQuad.removeEventListener("touch",onTouchGudetamaQuad);
         gudetamaQuad = null;
         touchTextItemExtractor = null;
         amountExtractor = null;
         super.dispose();
      }
   }
}

import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.KitchenwareData;
import gudetama.data.compati.UsefulDef;
import gudetama.engine.TextureCollector;
import gudetama.engine.TweenAnimator;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class KitchenwareButton extends UIBase
{
    
   
   public var type:int;
   
   private var callback:Function;
   
   private var button:ContainerButton;
   
   private var image:Image;
   
   private var stateSprite:Sprite;
   
   private var friendlyText:ColorTextField;
   
   private var kitchenwareData:KitchenwareData;
   
   private var lastHour:int = -1;
   
   private var lastMinute:int = -1;
   
   private var lastSecond:int = -1;
   
   private var state:int = -1;
   
   function KitchenwareButton(param1:Sprite, param2:int, param3:Function)
   {
      super(param1);
      this.type = param2;
      this.callback = param3;
      button = param1.getChildByName("button") as ContainerButton;
      button.addEventListener("triggered",triggered);
      image = button.getChildByName("image") as Image;
      stateSprite = param1.getChildByName("stateSprite") as Sprite;
      var _loc4_:Sprite;
      friendlyText = (_loc4_ = param1.getChildByName("popupGroup") as Sprite).getChildByName("friendly") as ColorTextField;
      friendlyText.visible = false;
   }
   
   public function setup(param1:KitchenwareData) : void
   {
      this.kitchenwareData = param1;
      refresh();
   }
   
   public function refresh() : void
   {
      var cookingNow:Boolean = kitchenwareData != null ? kitchenwareData.isCooking() : false;
      if(UserDataWrapper.kitchenwarePart.isAvailableByKitchenware(kitchenwareData,0,!cookingNow))
      {
         setVisible(true);
         var kitchenwareId:int = UserDataWrapper.kitchenwarePart.getHighestGradeKitchenwareIdByKitchenware(kitchenwareData);
         TextureCollector.loadTexture("kitchen0@image" + kitchenwareId,function(param1:Texture):void
         {
            image.texture = param1;
         });
         if(UserDataWrapper.kitchenwarePart.finishedCookingByKitchenwareOneTime(kitchenwareData))
         {
            button.touchable = false;
            stateSprite.visible = false;
            state = 2;
         }
         else if(cookingNow)
         {
            var assistable:Boolean = isAssistable();
            button.touchable = assistable;
            stateSprite.visible = assistable;
            state = 1;
         }
         else
         {
            button.touchable = false;
            stateSprite.visible = false;
            state = 0;
         }
         advanceTime();
      }
      else
      {
         setVisible(false);
      }
   }
   
   public function isAssistable() : Boolean
   {
      var _loc3_:int = 0;
      var _loc2_:* = GameSetting.getUsefulMap();
      while(true)
      {
         for each(var _loc1_ in _loc2_)
         {
            if(_loc1_.assistAbilities)
            {
               if(!kitchenwareData.existsUsefulIdInAssist(_loc1_.id#2))
               {
                  if(kitchenwareData.target == 0)
                  {
                     if(!_loc1_.hasHappeningInAssistAbilities())
                     {
                        break;
                     }
                  }
                  else if(!_loc1_.hasSuccessInAssistAbilities())
                  {
                     break;
                  }
               }
            }
         }
         return false;
      }
      return true;
   }
   
   public function advanceTime(param1:Number = 0) : void
   {
      if(state == 1)
      {
         if(UserDataWrapper.kitchenwarePart.finishedCookingByKitchenwareOneTime(kitchenwareData))
         {
            refresh();
         }
      }
   }
   
   public function showShortenTime(param1:int) : void
   {
      var usefulId:int = param1;
      var friendly:int = GameSetting.getRule().friendlyValueByAssist;
      var usefulDef:UsefulDef = GameSetting.getUseful(usefulId);
      if(usefulDef.friendlyValue > 0)
      {
         friendly = usefulDef.friendlyValue;
      }
      if(friendly > 0)
      {
         friendlyText.text#2 = StringUtil.format(GameSetting.getUIText("friendRoom.popup.friendly"),friendly);
      }
      friendlyText.visible = true;
      TweenAnimator.startItself(friendlyText,"start",false,function():void
      {
         friendlyText.visible = false;
      });
   }
   
   private function triggered(param1:Event) : void
   {
      if(state != 1)
      {
         return;
      }
      callback(kitchenwareData);
   }
   
   public function dispose() : void
   {
      button.removeEventListener("triggered",triggered);
      button = null;
      image = null;
      stateSprite = null;
      friendlyText = null;
      kitchenwareData = null;
   }
}

import gudetama.data.GameSetting;
import gudetama.data.compati.QuestionDef;
import gudetama.data.compati.VoiceDef;
import gudetama.engine.Engine;
import gudetama.engine.SoundManager;
import gudetama.engine.TweenAnimator;
import gudetama.net.HttpConnector;
import gudetama.net.PacketUtil;
import gudetama.scene.friend.FriendRoomScene;
import gudetama.ui.UIBase;
import muku.core.MukuGlobal;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Sprite;

class QuestionUI extends UIBase
{
    
   
   private var questionText:ColorTextField;
   
   private var buttonGroup:Sprite;
   
   private var choiceButtons:Vector.<ChoiceButtonUI>;
   
   private var questionId:int;
   
   private var questionVoiceDef:VoiceDef;
   
   function QuestionUI(param1:Sprite)
   {
      var _loc3_:int = 0;
      var _loc2_:* = null;
      choiceButtons = new Vector.<ChoiceButtonUI>();
      super(param1);
      questionText = param1.getChildByName("question") as ColorTextField;
      buttonGroup = param1.getChildByName("buttonGroup") as Sprite;
      _loc3_ = 0;
      while(_loc3_ < buttonGroup.numChildren)
      {
         _loc2_ = new ChoiceButtonUI(buttonGroup.getChildByName("choiceButton" + _loc3_) as ContainerButton,_loc3_);
         _loc2_.setCallback(triggeredChoiceButtonUI);
         choiceButtons.push(_loc2_);
         _loc3_++;
      }
   }
   
   public function setup(param1:int) : void
   {
      var _loc3_:int = 0;
      this.questionId = param1;
      setVisible(false);
      if(param1 <= 0)
      {
         return;
      }
      var _loc2_:QuestionDef = GameSetting.getQuestion(param1);
      questionText.text#2 = _loc2_.question;
      questionVoiceDef = GameSetting.getVoice(_loc2_.questionVoiceId);
      _loc3_ = 0;
      while(_loc3_ < _loc2_.params#2.length)
      {
         choiceButtons[_loc3_].setup(_loc2_.params#2[_loc3_]);
         _loc3_++;
      }
      var _loc4_:* = Engine;
      if(gudetama.engine.Engine.isIosPlatform() || true)
      {
         TweenAnimator.startItself(buttonGroup,"ios");
      }
      else
      {
         TweenAnimator.startItself(buttonGroup,"android");
      }
   }
   
   public function show() : void
   {
      if(questionId <= 0)
      {
         return;
      }
      setVisible(true);
      startTween("show");
      SoundManager.playVoice(MukuGlobal.makePathFromVoiceName(questionVoiceDef.id#2,questionVoiceDef.rsrc),true,0,0);
   }
   
   private function hide() : void
   {
      startTween("hide",false,function():void
      {
         setVisible(false);
      });
   }
   
   private function triggeredChoiceButtonUI(param1:int) : void
   {
      var index:int = param1;
      for each(choiceButton in choiceButtons)
      {
         choiceButton.setCallback(null);
      }
      Engine.showLoading(FriendRoomScene);
      var _loc5_:* = HttpConnector;
      if(gudetama.net.HttpConnector.mainConnector == null)
      {
         gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
      }
      gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(FRIEND_ANSWER_QUESTION,index),function(param1:Array):void
      {
         Engine.hideLoading(FriendRoomScene);
         hide();
      });
   }
   
   public function dispose() : void
   {
      questionText = null;
      buttonGroup = null;
      for each(var _loc1_ in choiceButtons)
      {
         _loc1_.dispose();
      }
      choiceButtons.length = 0;
      choiceButtons = null;
   }
}

import gudetama.data.compati.QuestionParam;
import gudetama.ui.UIBase;
import muku.text.ColorTextField;
import starling.display.Sprite;
import starling.events.Event;

class ChoiceButtonUI extends UIBase
{
    
   
   private var index:int;
   
   private var callback:Function;
   
   private var text:ColorTextField;
   
   function ChoiceButtonUI(param1:Sprite, param2:int)
   {
      super(param1);
      this.index = param2;
      param1.addEventListener("triggered",triggered);
      text = param1.getChildByName("text") as ColorTextField;
   }
   
   public function setup(param1:QuestionParam) : void
   {
      text.text#2 = param1.choice;
   }
   
   public function setCallback(param1:Function) : void
   {
      this.callback = param1;
   }
   
   private function triggered(param1:Event) : void
   {
      if(callback)
      {
         callback(index);
      }
   }
   
   public function dispose() : void
   {
      callback = null;
      displaySprite.removeEventListener("triggered",triggered);
      text = null;
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.FriendlyDef;
import gudetama.data.compati.UserProfileData;
import gudetama.data.compati.UserRoomInfo;
import gudetama.engine.Engine;
import gudetama.engine.TextureCollector;
import gudetama.net.HttpConnector;
import gudetama.net.PacketUtil;
import gudetama.scene.friend.FriendDetailDialog;
import gudetama.scene.friend.FriendScene_Gudetama;
import gudetama.scene.friend.HeartGaugeGroup;
import gudetama.scene.profile.ProfileScene;
import gudetama.ui.ResidentMenuUI_Gudetama;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import muku.core.TaskQueue;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class ProfileUI extends UIBase
{
    
   
   private var iconImage:Image;
   
   private var imgSns:Image;
   
   private var levelText:ColorTextField;
   
   private var nameText:ColorTextField;
   
   private var heartGaugeGroup:HeartGaugeGroup;
   
   private var friendlyText:ColorTextField;
   
   private var detailButton:ContainerButton;
   
   private var nameWidth:Number;
   
   private var nameFontSize:Number;
   
   private var profile:UserProfileData;
   
   private var userRoomInfo:UserRoomInfo;
   
   function ProfileUI(param1:Sprite)
   {
      super(param1);
      iconImage = param1.getChildByName("icon") as Image;
      imgSns = param1.getChildByName("imgSns") as Image;
      imgSns.visible = false;
      levelText = param1.getChildByName("level") as ColorTextField;
      nameText = param1.getChildByName("name") as ColorTextField;
      nameWidth = nameText.width;
      nameFontSize = nameText.fontSize;
      heartGaugeGroup = new HeartGaugeGroup(param1.getChildByName("heartGroup") as Sprite);
      friendlyText = param1.getChildByName("friendly") as ColorTextField;
      detailButton = param1.getChildByName("detailButton") as ContainerButton;
      detailButton.addEventListener("triggered",triggeredDetailButton);
   }
   
   public function setup(param1:TaskQueue, param2:UserProfileData, param3:UserRoomInfo) : void
   {
      var queue:TaskQueue = param1;
      var profile:UserProfileData = param2;
      var userRoomInfo:UserRoomInfo = param3;
      this.profile = profile;
      this.userRoomInfo = userRoomInfo;
      if(profile.snsProfileImage != null)
      {
         queue.addTask(function():void
         {
            GudetamaUtil.loadByteArray2Texture(profile.snsProfileImage,function(param1:Texture):void
            {
               iconImage.texture = param1;
               queue.taskDone();
            });
         });
         TextureCollector.loadSnsImage(profile.snsType,queue,function(param1:Texture):void
         {
            if(param1 != null)
            {
               imgSns.texture = param1;
               imgSns.visible = true;
            }
         });
      }
      else
      {
         queue.addTask(function():void
         {
            TextureCollector.loadTextureRsrc("avatar-" + GameSetting.getAvatar(profile.avatar).rsrc,function(param1:Texture):void
            {
               iconImage.texture = param1;
               queue.taskDone();
            });
         });
      }
      levelText.text#2 = profile.playerRank.toString();
      var _loc4_:* = Engine;
      nameText.width = gudetama.engine.Engine.designWidth;
      nameText.text#2 = StringUtil.format(GameSetting.getUIText("friendRoom.room.name"),profile.playerName);
      var width:Number = nameText.textBounds.width;
      if(width > nameWidth - nameFontSize)
      {
         nameText.fontSize = Math.floor(nameFontSize * (nameWidth - nameFontSize) / width);
      }
      else
      {
         nameText.fontSize = nameFontSize;
      }
      nameText.width = nameWidth;
      var friendlyDef:FriendlyDef = GameSetting.getFriendly();
      var heartBorders:Array = friendlyDef.heartBorders;
      heartGaugeGroup.setup(heartBorders);
      update(false);
   }
   
   public function update(param1:Boolean = true) : void
   {
      var _loc4_:int = UserDataWrapper.wrapper.getFriendly(profile.encodedUid);
      var _loc5_:int = UserDataWrapper.wrapper.getFriendlyLevel(profile.encodedUid);
      var _loc6_:FriendlyDef;
      var _loc3_:Array = (_loc6_ = GameSetting.getFriendly()).heartBorders;
      var _loc2_:int = _loc3_[_loc3_.length - 1];
      friendlyText.text#2 = StringUtil.format(GameSetting.getUIText("friendDetail.friendly"),_loc4_,_loc2_);
      if(param1)
      {
         updateWithAnimation();
      }
   }
   
   public function updateWithAnimation() : void
   {
      var _loc1_:int = UserDataWrapper.wrapper.getFriendly(profile.encodedUid);
      heartGaugeGroup.value = _loc1_;
   }
   
   private function triggeredDetailButton(param1:Event) : void
   {
      var event:Event = param1;
      FriendDetailDialog.show({
         "profile":profile,
         "removeFunc":function():void
         {
            Engine.showLoading(ProfileScene);
            var _loc1_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(GENERAL_FRIEND_REMOVE_FOLLOW,profile.encodedUid),function(param1:Array):void
            {
               var response:Array = param1;
               Engine.hideLoading(ProfileScene);
               profile.followState = 0;
               UserDataWrapper.friendPart.removeFollow(profile);
               UserDataWrapper.friendPart.removeFollower(profile);
               UserDataWrapper.friendPart.removeFriend(profile);
               ResidentMenuUI_Gudetama.getInstance().sendChangeState(63,function():void
               {
                  Engine.switchScene(new FriendScene_Gudetama());
               });
            });
         },
         "disabledRoomButton":true
      },92);
   }
   
   public function advanceTime(param1:Number) : void
   {
      heartGaugeGroup.advanceTime();
   }
   
   public function dispose() : void
   {
      iconImage = null;
      levelText = null;
      nameText = null;
      if(heartGaugeGroup)
      {
         heartGaugeGroup.dispose();
         heartGaugeGroup = null;
      }
      friendlyText = null;
      if(detailButton)
      {
         detailButton.removeEventListener("triggered",triggeredDetailButton);
         detailButton = null;
      }
      profile = null;
   }
}

import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.UserProfileData;
import gudetama.ui.AmountCacheManager;
import gudetama.ui.UIBase;
import gudetama.util.SpriteExtractor;
import gudetama.util.StringUtil;
import muku.text.ColorTextField;
import starling.display.Sprite;

class PresentMoneyUI extends UIBase
{
   
   private static const INTERVAL:Number = 0.1;
    
   
   private var enableGroup:Sprite;
   
   private var maxText:ColorTextField;
   
   private var numText:ColorTextField;
   
   private var amountGroup:Sprite;
   
   private var disableGroup:Sprite;
   
   private var amountCache:AmountCacheManager;
   
   private var profile:UserProfileData;
   
   private var max:int;
   
   private var before:int;
   
   private var after:int;
   
   private var current:int;
   
   private var amount:int;
   
   private var time:Number;
   
   private var visible:Boolean = true;
   
   function PresentMoneyUI(param1:Sprite)
   {
      super(param1);
      enableGroup = param1.getChildByName("enableGroup") as Sprite;
      maxText = enableGroup.getChildByName("max") as ColorTextField;
      numText = enableGroup.getChildByName("num") as ColorTextField;
      amountGroup = param1.getChildByName("amountGroup") as Sprite;
      disableGroup = param1.getChildByName("disableGroup") as Sprite;
   }
   
   public function setup(param1:UserProfileData, param2:SpriteExtractor) : void
   {
      this.profile = param1;
      amountCache = new AmountCacheManager(param2,amountGroup);
      var _loc3_:int = UserDataWrapper.wrapper.currentFriendPresentMoney(param1.encodedUid);
      max = Math.max(UserDataWrapper.wrapper.getMaxPresentMoneyToFriend(param1.encodedUid,param1.playerRank * GameSetting.getRule().maxFriendPresentMoneyPerRank) - _loc3_,0);
      if(max > 0)
      {
         enableGroup.visible = true;
         maxText.text#2 = StringUtil.format(GameSetting.getUIText("friendRoom.friendPresent.max"),StringUtil.getNumStringCommas(max));
         numText.text#2 = StringUtil.getNumStringCommas(current);
         disableGroup.visible = false;
      }
      else
      {
         enableGroup.visible = false;
         disableGroup.visible = true;
      }
   }
   
   public function add(param1:int) : void
   {
      this.amount = param1;
      before = current = after;
      after += param1;
      time = 0;
      amountCache.show(param1,"start");
   }
   
   public function advanceTime(param1:Number) : void
   {
      var _loc2_:int = 0;
      if(current != after)
      {
         time += param1;
         _loc2_ = current;
         current = before + Math.min(amount,amount * time / 0.1);
         if(_loc2_ != current)
         {
            numText.text#2 = StringUtil.getNumStringCommas(current);
         }
      }
      else if(current >= max && !disableGroup.visible)
      {
         enableGroup.visible = false;
         disableGroup.visible = true;
      }
   }
   
   override public function setVisible(param1:Boolean) : void
   {
      visible = param1;
      alpha = displaySprite.alpha;
   }
   
   public function set alpha(param1:Number) : void
   {
      setAlpha(param1);
      displaySprite.visible = visible && param1 > 0;
   }
   
   public function dispose() : void
   {
      enableGroup = null;
      maxText = null;
      numText = null;
      amountGroup = null;
      disableGroup = null;
      if(amountCache)
      {
         amountCache.dispose();
         amountCache = null;
      }
   }
}

import gudetama.data.GameSetting;
import gudetama.engine.BaseScene;
import gudetama.scene.friend.FriendRoomScene;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import muku.text.ColorTextField;
import starling.display.Sprite;

class AssistUI extends UIBase
{
    
   
   private var scene:FriendRoomScene;
   
   private var enableGroup:Sprite;
   
   private var numText:ColorTextField;
   
   private var disableGroup:Sprite;
   
   private var visible:Boolean = true;
   
   function AssistUI(param1:Sprite, param2:BaseScene)
   {
      super(param1);
      this.scene = param2 as FriendRoomScene;
      enableGroup = param1.getChildByName("enableGroup") as Sprite;
      numText = enableGroup.getChildByName("num") as ColorTextField;
      disableGroup = param1.getChildByName("disableGroup") as Sprite;
   }
   
   public function update() : void
   {
      var _loc2_:int = !!scene.userRoomInfo.assistData ? scene.userRoomInfo.assistData.num : 0;
      var _loc1_:int = GameSetting.getRule().maxAssistPerDay;
      if(_loc2_ < _loc1_)
      {
         enableGroup.visible = true;
         numText.text#2 = StringUtil.format(GameSetting.getUIText("friendRoom.assist.num"),_loc2_,_loc1_);
         disableGroup.visible = false;
      }
      else
      {
         enableGroup.visible = false;
         disableGroup.visible = true;
      }
   }
   
   override public function setVisible(param1:Boolean) : void
   {
      visible = param1;
      alpha = displaySprite.alpha;
   }
   
   public function set alpha(param1:Number) : void
   {
      setAlpha(param1);
      displaySprite.visible = visible && param1 > 0;
   }
   
   public function dispose() : void
   {
      enableGroup = null;
      numText = null;
      disableGroup = null;
   }
}

import gudetama.ui.UIBase;
import muku.text.ColorTextField;
import starling.display.Sprite;
import starling.events.Event;

class AssistButtonUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var numText:ColorTextField;
   
   private var currentNum:int = -1;
   
   private var visible:Boolean = true;
   
   function AssistButtonUI(param1:Sprite, param2:Function)
   {
      super(param1);
      this.callback = param2;
      param1.addEventListener("triggered",triggeredButton);
      numText = param1.getChildByName("num") as ColorTextField;
   }
   
   public function setup(param1:int) : void
   {
      if(currentNum == param1)
      {
         return;
      }
      numText.text#2 = param1.toString();
      setVisible(param1 > 0);
      currentNum = param1;
      startTween("show");
   }
   
   public function set touchable(param1:Boolean) : void
   {
      displaySprite.touchable = param1;
   }
   
   override public function setVisible(param1:Boolean) : void
   {
      visible = param1;
      alpha = displaySprite.alpha;
   }
   
   public function set alpha(param1:Number) : void
   {
      setAlpha(param1);
      displaySprite.visible = visible && param1 > 0;
   }
   
   private function triggeredButton(param1:Event) : void
   {
      callback();
   }
   
   public function dispose() : void
   {
      callback = null;
      displaySprite.removeEventListener("triggered",triggeredButton);
      displaySprite = null;
      numText = null;
   }
}
