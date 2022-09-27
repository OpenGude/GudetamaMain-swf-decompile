package gudetama.scene.kitchen
{
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.AbilityParam;
   import gudetama.data.compati.GetItemResult;
   import gudetama.data.compati.GudetamaData;
   import gudetama.data.compati.GudetamaDef;
   import gudetama.data.compati.KitchenwareData;
   import gudetama.data.compati.PossibleRouletteParam;
   import gudetama.data.compati.UsefulDef;
   import gudetama.data.compati.UserProfileData;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.Logger;
   import gudetama.engine.SoundManager;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.scene.home.GudetamaUnlockableDialog;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.ui.VideoAdConfirmDialog;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.CircleImage;
   import muku.display.ContainerButton;
   import muku.display.SpineModel;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   import starling.textures.Texture;
   
   public class RouletteDialog extends BaseScene
   {
      
      private static const STATE_NONE:int = 0;
      
      private static const STATE_ROULETTE_ACCELERATE:int = 1;
      
      private static const STATE_ROULETTE:int = 2;
      
      private static const STATE_ROULETTE_DECELERATE:int = 3;
      
      private static const STATE_RESULT:int = 4;
      
      private static const STATE_COMPLETE:int = 5;
      
      private static const ANIME_NAMES_RESULT:Array = ["01_success","02_Happening","03_Error"];
       
      
      private var kitchenwareType:int;
      
      private var closedCurtainCallback:Function;
      
      private var openedCurtainCallback:Function;
      
      private var quad:Quad;
      
      private var dialogSprite:Sprite;
      
      private var happeningBgImage:Image;
      
      private var successCompleteImage:Image;
      
      private var happeningCompleteImage:Image;
      
      private var failureCompleteImage:Image;
      
      private var rouletteGroup:Sprite;
      
      private var rouletteImage:Image;
      
      private var rouletteBlackImage:Image;
      
      private var rouletteCircles:Vector.<CircleImage>;
      
      private var targetImage:Image;
      
      private var gudetamaImage:Image;
      
      private var usefulGroup:Sprite;
      
      private var usefulButton:ContainerButton;
      
      private var cancelButton:ContainerButton;
      
      private var friendIconImage:Image;
      
      private var tooMatchTimeMessageUI:MessageUI;
      
      private var usefulMessageUI:MessageUI;
      
      private var spineModel:SpineModel;
      
      private var tapStartText:ColorTextField;
      
      private var tapStopText:ColorTextField;
      
      private var pleaseWaitText:ColorTextField;
      
      private var targetGroup:Sprite;
      
      private var roulettes:Array;
      
      private var rouletteRepairPrice:int;
      
      private var rouletteRotateRatio:int;
      
      private var rouletteAutoStopPercent:int;
      
      private var assistantMap:Object;
      
      private var loadCount:int;
      
      private var rouletteValuesMap:Object;
      
      private var rouletteTimePerRound:int;
      
      private var state:int = 0;
      
      private var time:int;
      
      private var radian:Number = 0;
      
      private var stopTime:int;
      
      private var resultRadian:Number;
      
      private var result:int;
      
      private var retryPrice:int;
      
      private var slipValue:int;
      
      private var sendResult:Boolean;
      
      private var selectedUsefulIds:Array;
      
      private var assistUsefulIds:Array;
      
      private var ratesInType:Array;
      
      private var drumRollSE;
      
      private var resultGudetamaData:GudetamaData;
      
      public function RouletteDialog(param1:int, param2:Function, param3:Function)
      {
         rouletteCircles = new Vector.<CircleImage>();
         selectedUsefulIds = [];
         assistUsefulIds = [];
         super(2);
         this.kitchenwareType = param1;
         this.closedCurtainCallback = param2;
         this.openedCurtainCallback = param3;
         addEventListener("refreshed_scene_container",refreshedSceneContainer);
      }
      
      public static function show(param1:int, param2:Function, param3:Function) : void
      {
         Engine.pushScene(new RouletteDialog(param1,param2,param3),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"RouletteDialog",function(param1:Object):void
         {
            var _loc6_:int = 0;
            var _loc5_:* = null;
            displaySprite = param1.object;
            quad = displaySprite.getChildByName("quad") as Quad;
            quad.addEventListener("touch",touchQuad);
            dialogSprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            var _loc2_:Sprite = dialogSprite.getChildByName("successSprite") as Sprite;
            successCompleteImage = _loc2_.getChildByName("complete") as Image;
            var _loc3_:Sprite = dialogSprite.getChildByName("happeningSprite") as Sprite;
            happeningBgImage = _loc3_.getChildByName("bg") as Image;
            happeningCompleteImage = _loc3_.getChildByName("complete") as Image;
            var _loc7_:Sprite;
            failureCompleteImage = (_loc7_ = dialogSprite.getChildByName("failureSprite") as Sprite).getChildByName("complete") as Image;
            rouletteGroup = dialogSprite.getChildByName("rouletteGroup") as Sprite;
            rouletteImage = rouletteGroup.getChildByName("roulette") as Image;
            rouletteBlackImage = rouletteGroup.getChildByName("rouletteBlack") as Image;
            var _loc4_:Sprite = rouletteGroup.getChildByName("rouletteSprite") as Sprite;
            _loc6_ = 0;
            while(_loc6_ < _loc4_.numChildren)
            {
               (_loc5_ = _loc4_.getChildByName("roulette" + _loc6_) as CircleImage).init();
               rouletteCircles.push(_loc5_);
               _loc6_++;
            }
            targetImage = rouletteGroup.getChildByName("target") as Image;
            gudetamaImage = rouletteGroup.getChildByName("icon") as Image;
            tooMatchTimeMessageUI = new MessageUI(dialogSprite.getChildByName("tooMatchTimeMessageGroup") as Sprite);
            usefulMessageUI = new MessageUI(dialogSprite.getChildByName("usefulMessageGroup") as Sprite);
            usefulGroup = rouletteGroup.getChildByName("usefulGroup") as Sprite;
            usefulButton = usefulGroup.getChildByName("usefulButton") as ContainerButton;
            usefulButton.addEventListener("triggered",triggeredUsefulButton);
            cancelButton = dialogSprite.getChildByName("cancelButton") as ContainerButton;
            cancelButton.addEventListener("triggered",triggeredCancelButton);
            friendIconImage = usefulButton.getChildByName("friendIcon") as Image;
            spineModel = displaySprite.getChildByName("spineModel") as SpineModel;
            tapStartText = usefulGroup.getChildByName("tapStart") as ColorTextField;
            tapStopText = rouletteGroup.getChildByName("tapStop") as ColorTextField;
            pleaseWaitText = rouletteGroup.getChildByName("pleaseWait") as ColorTextField;
            targetGroup = dialogSprite.getChildByName("targetGroup") as Sprite;
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         addTask(function():void
         {
            var _loc1_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(134217923,[kitchenwareType,!!UserDataWrapper.friendPart.isRequestedUpdateFollower() ? 1 : 0,!!UserDataWrapper.friendPart.isRequestedUpdateFollow() ? 1 : 0]),function(param1:Array):void
            {
               roulettes = param1[0];
               rouletteRepairPrice = param1[1][0];
               rouletteRotateRatio = param1[1][1];
               rouletteAutoStopPercent = param1[1][2];
               if(param1[2])
               {
                  UserDataWrapper.friendPart.setFollowerList(param1[2]);
               }
               if(param1[3])
               {
                  UserDataWrapper.friendPart.setFollowList(param1[3]);
               }
               assistantMap = param1[4];
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
         tapStartText.visible = true;
         tapStopText.visible = false;
         pleaseWaitText.visible = false;
         tooMatchTimeMessageUI.init();
         usefulMessageUI.init();
         cancelButton.visible = false;
         time = 0;
         setup();
      }
      
      private function setup() : void
      {
         var gudetamaId:int = UserDataWrapper.kitchenwarePart.getGudetamaId(kitchenwareType);
         var gudetamaDef:GudetamaDef = GameSetting.getGudetama(gudetamaId);
         happeningBgImage.color = !!gudetamaDef.existsHappening() ? 16777215 : 8421504;
         successCompleteImage.visible = UserDataWrapper.gudetamaPart.isCooked(gudetamaId);
         happeningCompleteImage.visible = gudetamaDef.existsHappening() && UserDataWrapper.wrapper.isHappeningCompleted(gudetamaDef.recipeNoteId);
         failureCompleteImage.visible = UserDataWrapper.wrapper.isFailureCompleted(gudetamaDef.recipeNoteId);
         queue.addTask(function():void
         {
            TextureCollector.loadTextureRsrc("gudetama-" + gudetamaDef.rsrc + "-icon",function(param1:Texture):void
            {
               gudetamaImage.texture = param1;
               queue.taskDone();
            });
         });
         var kitchenwareData:KitchenwareData = UserDataWrapper.kitchenwarePart.getKitchenwareByType(kitchenwareType);
         if(UserDataWrapper.featurePart.existsFeature(12))
         {
            targetGroup.visible = true;
            queue.addTask(function():void
            {
               TweenAnimator.startItself(targetGroup,kitchenwareData.target == 0 ? "success" : "happening",false,function():void
               {
                  TweenAnimator.startItself(targetGroup,"show");
                  queue.taskDone();
               });
            });
         }
         else
         {
            targetGroup.visible = false;
         }
         friendIconImage.visible = kitchenwareData.assistEncodedUids && kitchenwareData.assistEncodedUids.length > 0;
         if(kitchenwareData.assistUsefulIds)
         {
            assistUsefulIds = kitchenwareData.assistUsefulIds.slice();
         }
         update();
      }
      
      private function update() : void
      {
         var _loc1_:int = 0;
         rouletteImage.visible = rouletteRepairPrice <= 0;
         rouletteBlackImage.visible = rouletteRepairPrice > 0;
         ratesInType = createRouletteRates();
         _loc1_ = 0;
         while(_loc1_ < rouletteCircles.length)
         {
            rouletteCircles[_loc1_].setup(ratesInType[_loc1_]);
            _loc1_++;
         }
         applyAbilitiesToRouletteTimePerRound();
         usefulButton.setEnableWithDrawCache(UserDataWrapper.wrapper.isCompletedTutorial() && rouletteRepairPrice <= 0);
      }
      
      private function processTutorial() : Boolean
      {
         var _loc1_:UserDataWrapper = UserDataWrapper.wrapper;
         if(_loc1_.isCompletedTutorial())
         {
            return false;
         }
         if(!Engine.resumeGuideTalk())
         {
            Logger.warn("warn : failed resumeGuideTalk() in " + this);
         }
         return true;
      }
      
      private function createRouletteRates() : Array
      {
         var _loc5_:int = 0;
         var _loc12_:* = null;
         var _loc17_:* = null;
         var _loc10_:int = 0;
         var _loc3_:* = 0;
         var _loc6_:int = 0;
         var _loc9_:* = null;
         var _loc2_:* = null;
         var _loc14_:Number = NaN;
         var _loc1_:KitchenwareData = UserDataWrapper.kitchenwarePart.getKitchenwareByType(kitchenwareType);
         var _loc8_:int = UserDataWrapper.kitchenwarePart.getGudetamaId(kitchenwareType);
         var _loc16_:GudetamaDef = GameSetting.getGudetama(_loc8_);
         var _loc7_:Array = [];
         _loc5_ = 0;
         while(_loc5_ < rouletteCircles.length)
         {
            _loc7_.push([]);
            _loc5_++;
         }
         var _loc11_:Array = [];
         if(rouletteRepairPrice <= 0)
         {
            _loc17_ = [];
            for each(var _loc15_ in roulettes)
            {
               _loc3_ = _loc10_;
               _loc10_ += _loc15_.percent;
               _loc12_ = {
                  "type":_loc15_.type,
                  "percent":_loc15_.percent,
                  "start":_loc3_ + rouletteRotateRatio,
                  "end":_loc10_ + rouletteRotateRatio
               };
               _loc11_.push(_loc12_);
               _loc17_.push(_loc12_);
            }
            if(rouletteRotateRatio > 0)
            {
               _loc5_ = _loc17_.length - 1;
               while(_loc5_ >= 0)
               {
                  if((_loc12_ = _loc17_[_loc5_]).start >= 100 && _loc12_.end >= 100)
                  {
                     _loc11_.removeAt(_loc11_.indexOf(_loc12_));
                     _loc11_.unshift(_loc12_);
                  }
                  else if(_loc12_.start < 100 && _loc12_.end > 100)
                  {
                     _loc6_ = _loc12_.end % 100;
                     _loc9_ = {
                        "type":_loc12_.type,
                        "percent":_loc6_,
                        "start":0,
                        "end":_loc6_
                     };
                     _loc11_.unshift(_loc9_);
                     _loc12_.percent -= _loc6_;
                  }
                  _loc5_--;
               }
            }
            _loc11_ = applyAbilitiesToRouletteParams(_loc1_,515,_loc11_);
            _loc11_ = applyAbilitiesToRouletteParams(_loc1_,516,_loc11_);
         }
         else
         {
            _loc11_.push({
               "type":2,
               "percent":100
            });
         }
         var _loc4_:* = 0;
         var _loc13_:* = 0;
         for each(_loc12_ in _loc11_)
         {
            _loc4_ += _loc12_.percent;
            _loc2_ = _loc7_[_loc12_.type];
            _loc14_ = _loc4_ / 100;
            _loc2_.push([_loc13_,_loc14_]);
            _loc13_ = _loc14_;
         }
         return _loc7_;
      }
      
      private function applyAbilitiesToRouletteParams(param1:KitchenwareData, param2:int, param3:Array) : Array
      {
         var _loc16_:* = null;
         var _loc15_:* = null;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc10_:int = 0;
         var _loc6_:Number = NaN;
         var _loc8_:int = 0;
         for each(var _loc11_ in selectedUsefulIds)
         {
            if((_loc16_ = GameSetting.getUseful(_loc11_)).abilities)
            {
               _loc8_ += _loc16_.sumAbilities(param2);
            }
         }
         for each(var _loc7_ in assistUsefulIds)
         {
            if((_loc16_ = GameSetting.getUseful(_loc7_)).assistAbilities)
            {
               _loc8_ += _loc16_.sumAssistAbilities(param2);
            }
         }
         if(_loc8_ <= 0)
         {
            return param3;
         }
         var _loc14_:Array = [];
         for each(_loc15_ in param3)
         {
            _loc14_.push(_loc15_);
         }
         _loc14_.sort(ascendingPercentComparator);
         var _loc5_:Number = _loc8_;
         var _loc9_:int = 0;
         for each(_loc15_ in param3)
         {
            if(_loc15_.type == 2)
            {
               _loc9_++;
            }
         }
         for each(_loc15_ in _loc14_)
         {
            if(_loc15_.type == 2)
            {
               _loc12_ = Math.min(_loc5_,Math.min(_loc15_.percent,Math.ceil(_loc5_ / _loc9_)));
               _loc15_.percent -= _loc12_;
               _loc5_ -= _loc12_;
               _loc9_--;
            }
         }
         if(_loc5_ > 0)
         {
            _loc13_ = param2 == 515 ? 1 : 0;
            _loc9_ = 0;
            for each(_loc15_ in param3)
            {
               if(_loc15_.type == _loc13_)
               {
                  _loc9_++;
               }
            }
            for each(_loc15_ in _loc14_)
            {
               if(_loc15_.type == _loc13_)
               {
                  _loc12_ = Math.min(_loc5_,Math.min(_loc15_.percent,Math.ceil(_loc5_ / _loc9_)));
                  _loc15_.percent -= _loc12_;
                  _loc5_ -= _loc12_;
                  _loc9_--;
               }
            }
         }
         var _loc4_:Number;
         if((_loc4_ = Math.max(0,_loc8_ - _loc5_)) > 0)
         {
            _loc10_ = param2 == 515 ? 0 : 1;
            _loc9_ = 0;
            for each(_loc15_ in param3)
            {
               if(_loc15_.type == _loc10_)
               {
                  _loc9_++;
               }
            }
            if(_loc9_ <= 0)
            {
               _loc15_ = {
                  "type":_loc10_,
                  "percent":0
               };
               param3.push(_loc15_);
               _loc14_.push(_loc15_);
               _loc14_.sort(ascendingPercentComparator);
            }
            for each(_loc15_ in _loc14_)
            {
               if(_loc15_.type == _loc10_)
               {
                  _loc6_ = Math.min(_loc4_,Math.ceil(_loc4_ / _loc9_));
                  _loc15_.percent += _loc6_;
                  _loc4_ -= _loc6_;
                  _loc9_--;
               }
            }
         }
         return param3;
      }
      
      private function ascendingPercentComparator(param1:Object, param2:Object) : Number
      {
         if(param1.percent > param2.percent)
         {
            return 1;
         }
         if(param1.percent < param2.percent)
         {
            return -1;
         }
         if(param1.start > param2.start)
         {
            return 1;
         }
         if(param1.start < param2.start)
         {
            return -1;
         }
         return 0;
      }
      
      override protected function addedToContainer() : void
      {
         setBackButtonCallbackNormal();
         setVisibleState(68);
         Engine.lockTouchInput(RouletteDialog);
      }
      
      private function setBackButtonCallbackNormal() : void
      {
         setBackButtonCallback(!!UserDataWrapper.wrapper.isCompletedTutorial() ? backButtonCallback : null);
      }
      
      override protected function focusLost() : void
      {
         if(drumRollSE)
         {
            SoundManager.stopEffectAll();
         }
      }
      
      override protected function focusGainedFinish() : void
      {
         SoundManager.stopEffectAll();
         if(drumRollSE)
         {
            SoundManager.playEffect("drumroll_A",1000,0,function(param1:*):void
            {
               drumRollSE = param1;
            });
         }
      }
      
      override public function getSceneFrameRate() : Number
      {
         return 60;
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         dialogSprite.visible = false;
         TweenAnimator.startItself(dialogSprite,"start");
         spineModel.show();
         SoundManager.stopEffectAll();
         SoundManager.playEffect("curtain");
         scene.juggler.delayCall(function():void
         {
            SoundManager.playEffect("check");
         },0.5);
         spineModel.changeAnimation("workmanship_check_close",false,function():void
         {
            SoundManager.playEffect("curtain");
            dialogSprite.visible = true;
            TweenAnimator.startItself(dialogSprite,"show");
            updateMessageUI();
            spineModel.changeAnimation("workmanship_check_open",false,function():void
            {
               spineModel.finish();
               Engine.removeSpineCache("efx_spine-workmanship_start");
               TweenAnimator.startItself(tapStartText,"start");
               showCookingRepairDialog();
               if(!processTutorial())
               {
                  setVisibleState(76);
                  setBackButtonCallbackNormal();
                  Engine.unlockTouchInput(RouletteDialog);
               }
            });
         });
      }
      
      private function clearCache() : void
      {
         TextureCollector.clearAtName("roulette0");
      }
      
      private function showCookingRepairDialog(param1:Function = null) : void
      {
         var callback:Function = param1;
         if(rouletteRepairPrice > 0)
         {
            CookingRepairDialog.show(rouletteRepairPrice,function(param1:Boolean):void
            {
               var positive:Boolean = param1;
               if(!positive)
               {
                  if(callback)
                  {
                     callback();
                  }
                  return;
               }
               Engine.showLoading(RouletteDialog);
               var _loc2_:* = HttpConnector;
               if(gudetama.net.HttpConnector.mainConnector == null)
               {
                  gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
               }
               gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(134217952),function(param1:Array):void
               {
                  Engine.hideLoading(RouletteDialog);
                  ResidentMenuUI_Gudetama.consumeMetal(rouletteRepairPrice);
                  rouletteRepairPrice = 0;
                  ResidentMenuUI_Gudetama.getInstance().updateUserInfo();
                  update();
                  updateMessageUI();
               });
            });
         }
         else if(callback)
         {
            callback();
         }
      }
      
      private function updateMessageUI() : void
      {
         var _loc7_:* = null;
         var _loc8_:* = null;
         var _loc6_:int = 0;
         var _loc5_:* = null;
         var _loc3_:* = null;
         if(rouletteRepairPrice > 0)
         {
            tooMatchTimeMessageUI.show(GameSetting.getUIText("roulette.message.tooMatchTime"));
         }
         else
         {
            tooMatchTimeMessageUI.hide();
         }
         var _loc9_:String = "";
         var _loc1_:Array = [];
         for each(var _loc10_ in selectedUsefulIds)
         {
            if((_loc7_ = GameSetting.getUseful(_loc10_)).abilities)
            {
               for each(_loc8_ in _loc7_.abilities)
               {
                  _loc6_ = _loc8_.getKind();
                  if(_loc1_.indexOf(_loc6_) < 0)
                  {
                     _loc1_.push(_loc6_);
                  }
               }
            }
         }
         for each(_loc6_ in _loc1_)
         {
            if(_loc9_.length == 0)
            {
               _loc9_ = GameSetting.getUIText("roulette.message.useful." + _loc6_);
            }
            else
            {
               _loc9_ = StringUtil.format(GameSetting.getUIText("roulette.message.connect"),_loc9_,GameSetting.getUIText("roulette.message.useful." + _loc6_));
            }
         }
         var _loc2_:KitchenwareData = UserDataWrapper.kitchenwarePart.getKitchenwareByType(kitchenwareType);
         if(assistUsefulIds.length > 0)
         {
            if(assistantMap)
            {
               _loc5_ = assistantMap[_loc2_.assistEncodedUids[0]];
            }
            if(!_loc5_)
            {
               _loc5_ = UserDataWrapper.friendPart.getFriendProfile(_loc2_.assistEncodedUids[0]);
            }
            _loc3_ = [];
            for each(var _loc11_ in _loc2_.assistEncodedUids)
            {
               if(_loc3_.indexOf(_loc11_) < 0)
               {
                  _loc3_.push(_loc11_);
               }
            }
            if(_loc9_.length == 0)
            {
               _loc9_ = StringUtil.format(GameSetting.getUIText("roulette.message.assist." + (_loc3_.length >= 2 ? "more" : "one")),!!_loc5_ ? _loc5_.playerName : "");
            }
            else
            {
               _loc9_ = StringUtil.format(GameSetting.getUIText("roulette.message.connect"),_loc9_,_loc9_ = StringUtil.format(GameSetting.getUIText("roulette.message.assist." + (_loc3_.length >= 2 ? "more" : "one")),!!_loc5_ ? _loc5_.playerName : ""));
            }
            _loc1_.length = 0;
            for each(var _loc4_ in assistUsefulIds)
            {
               if((_loc7_ = GameSetting.getUseful(_loc4_)).abilities)
               {
                  for each(_loc8_ in _loc7_.abilities)
                  {
                     _loc6_ = _loc8_.getKind();
                     if(_loc1_.indexOf(_loc6_) < 0)
                     {
                        _loc1_.push(_loc6_);
                     }
                  }
               }
            }
            for each(_loc6_ in _loc1_)
            {
               _loc9_ = StringUtil.format(GameSetting.getUIText("roulette.message.connect"),_loc9_,GameSetting.getUIText("roulette.message.useful." + _loc6_));
            }
            usefulMessageUI.bg = 3;
         }
         else
         {
            usefulMessageUI.bg = 1;
         }
         if(_loc9_.length > 0)
         {
            usefulMessageUI.show(_loc9_);
         }
         else
         {
            usefulMessageUI.hide();
         }
      }
      
      override public function advanceTime(param1:Number) : void
      {
         super.advanceTime(param1);
         if(state == 1)
         {
            advanceTimeInRotateAccelerate(param1);
         }
         else if(state == 2)
         {
            if(rouletteAutoStopPercent < 0)
            {
               advanceTimeInRotate(param1);
            }
            else
            {
               advanceTimeInRotateForAuto(param1);
            }
         }
         else if(state == 3)
         {
            advanceTimeInRotateDecelerate(param1);
         }
         else if(state == 4)
         {
            advanceTimeInResult(param1);
         }
      }
      
      public function advanceTimeInRotateAccelerate(param1:Number) : void
      {
         var _loc4_:Object;
         var _loc2_:Number = (_loc4_ = rouletteValuesMap[1]).accelerate * time * time;
         time += Engine.elapsed;
         var _loc5_:Number = _loc4_.accelerate * time * time - _loc2_;
         radian += _loc5_;
         targetImage.rotation = radian;
         var _loc3_:Number = _loc4_.velocity * Engine.elapsed;
         if(_loc5_ >= _loc3_)
         {
            rotateRoulette();
         }
      }
      
      public function advanceTimeInRotate(param1:Number) : void
      {
         var _loc2_:Object = rouletteValuesMap[2];
         radian += _loc2_.velocity * Engine.elapsed;
         targetImage.rotation = radian;
      }
      
      public function advanceTimeInRotateForAuto(param1:Number) : void
      {
         var _loc3_:Object = rouletteValuesMap[2];
         time += Engine.elapsed;
         radian += _loc3_.velocity * Engine.elapsed;
         targetImage.rotation = radian;
         var _loc2_:int = time - stopTime;
         if(_loc2_ > 0)
         {
            radian -= _loc3_.velocity * _loc2_;
         }
         if(time >= stopTime)
         {
            decelerateRoulette();
         }
      }
      
      public function advanceTimeInRotateDecelerate(param1:Number) : void
      {
         var _loc4_:Object;
         var _loc2_:Number = (_loc4_ = rouletteValuesMap[3]).velocity * time + 0.5 * _loc4_.accelerate * time * time;
         time += Engine.elapsed;
         var _loc3_:Number = _loc4_.velocity * time + 0.5 * _loc4_.accelerate * time * time;
         radian += _loc3_ - _loc2_;
         targetImage.rotation = radian;
         if(time >= _loc4_.timeUntilStop)
         {
            state = 4;
         }
      }
      
      public function advanceTimeInResult(param1:Number) : void
      {
         var _loc2_:* = null;
         var _loc6_:int = 0;
         var _loc5_:* = null;
         var _loc7_:int = 0;
         var _loc4_:* = null;
         if(!sendResult)
         {
            return;
         }
         var _loc3_:Number = targetImage.rotation;
         targetImage.rotation = resultRadian + 0.06283185307179587 * slipValue;
         if(ratesInType)
         {
            _loc2_ = "";
            _loc2_ += "[";
            _loc6_ = 0;
            while(_loc6_ < ratesInType.length)
            {
               _loc5_ = ratesInType[_loc6_];
               if(_loc6_ > 0)
               {
                  _loc2_ += ",";
               }
               _loc2_ += "[";
               _loc7_ = 0;
               while(_loc7_ < _loc5_.length)
               {
                  _loc4_ = _loc5_[_loc7_];
                  if(_loc7_ > 0)
                  {
                     _loc2_ += ",";
                  }
                  _loc2_ += "[" + _loc4_ + "]";
                  _loc7_++;
               }
               _loc2_ += "]";
               _loc6_++;
            }
            _loc2_ += "]";
            Logger.info("[RouletteDialog] kitchenwareType:" + kitchenwareType + " gudetamaId:" + UserDataWrapper.kitchenwarePart.getGudetamaId(kitchenwareType) + " stoppedRadian:" + _loc3_ + " resultRadian:" + targetImage.rotation + " rouletteInfo:" + _loc2_);
         }
         else
         {
            Logger.info("[RouletteDialog] kitchenwareType:" + kitchenwareType + " gudetamaId:" + UserDataWrapper.kitchenwarePart.getGudetamaId(kitchenwareType) + " stoppedRadian:" + _loc3_ + " resultRadian:" + targetImage.rotation + " ratesInType:null");
         }
         showResultSpineModel();
         state = 5;
      }
      
      private function showResultSpineModel() : void
      {
         var queue:TaskQueue = new TaskQueue();
         queue.addTask(function():void
         {
            spineModel.load("efx_spine-workmanship_result",function():void
            {
               queue.taskDone();
            },[ANIME_NAMES_RESULT[result]]);
         });
         queue.registerOnProgress(function(param1:Number):void
         {
            var ratio:Number = param1;
            if(ratio < 1)
            {
               return;
            }
            rouletteGroup.visible = false;
            cancelButton.visible = false;
            spineModel.show();
            if(result == 0)
            {
               SoundManager.playEffect("succeed");
            }
            else if(result == 1)
            {
               SoundManager.playEffect("happening");
            }
            else
            {
               SoundManager.playEffect("failed");
            }
            spineModel.changeAnimation(ANIME_NAMES_RESULT[result],true,function():void
            {
               spineModel.finish();
               Engine.removeSpineCache("efx_spine-workmanship_result");
               tooMatchTimeMessageUI.hide();
               usefulMessageUI.hide();
               if(retryPrice != 0)
               {
                  if(retryPrice < 0)
                  {
                     showVideoAdConfirmDialog();
                  }
                  else
                  {
                     showCookingRetryDialog();
                  }
               }
               else
               {
                  showCookingResultDialog();
               }
            });
         });
         queue.startTask();
      }
      
      private function showVideoAdConfirmDialog() : void
      {
         VideoAdConfirmDialog.show("start2",GameSetting.getUIText("videoAdConfirm.title"),GameSetting.getUIText("videoAdConfirm.retry.desc"),GameSetting.getUIText("videoAdConfirm.retry.caution"),function(param1:int):void
         {
            var choose:int = param1;
            if(choose == 0)
            {
               Engine.showLoading(RouletteDialog);
               var _loc2_:* = HttpConnector;
               if(gudetama.net.HttpConnector.mainConnector == null)
               {
                  gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
               }
               gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(134217951),function(param1:Array):void
               {
                  Engine.hideLoading(RouletteDialog);
                  rouletteRotateRatio = param1[0];
                  rouletteAutoStopPercent = param1[1];
                  ResidentMenuUI_Gudetama.getInstance().updateUserInfo();
                  processCookingRetry();
               });
            }
            else
            {
               showCookingResultDialog();
            }
         },0,76);
      }
      
      private function showCookingRetryDialog() : void
      {
         CookingRetryDialog.show(retryPrice,function(param1:Boolean):void
         {
            var positive:Boolean = param1;
            if(positive)
            {
               Engine.showLoading(RouletteDialog);
               var _loc2_:* = HttpConnector;
               if(gudetama.net.HttpConnector.mainConnector == null)
               {
                  gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
               }
               gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(134217943),function(param1:Array):void
               {
                  Engine.hideLoading(RouletteDialog);
                  rouletteRotateRatio = param1[0];
                  rouletteAutoStopPercent = param1[1];
                  ResidentMenuUI_Gudetama.consumeMetal(retryPrice);
                  ResidentMenuUI_Gudetama.getInstance().updateUserInfo();
                  processCookingRetry();
               });
            }
            else
            {
               showCookingResultDialog();
            }
         });
      }
      
      private function processCookingRetry() : void
      {
         Engine.lockTouchInput(RouletteDialog);
         var queue:TaskQueue = new TaskQueue();
         queue.addTask(function():void
         {
            spineModel.load("efx_spine-workmanship_start",function():void
            {
               queue.taskDone();
            });
         });
         queue.registerOnProgress(function(param1:Number):void
         {
            var ratio:Number = param1;
            if(ratio < 1)
            {
               return;
            }
            setVisibleState(68);
            setBackButtonCallback(null);
            spineModel.show();
            SoundManager.playEffect("curtain");
            spineModel.changeAnimation("workmanship_check_close",false,function():void
            {
               state = 0;
               sendResult = false;
               targetImage.rotation = 0;
               time = 0;
               radian = 0;
               resultRadian = 0;
               rouletteGroup.visible = true;
               selectedUsefulIds.length = 0;
               var kitchenwareData:KitchenwareData = UserDataWrapper.kitchenwarePart.getKitchenwareByType(kitchenwareType);
               if(kitchenwareData.assistUsefulIds)
               {
                  assistUsefulIds = kitchenwareData.assistUsefulIds.slice();
               }
               result = 0;
               retryPrice = 0;
               stopTime = 0;
               usefulGroup.visible = true;
               TweenAnimator.startItself(tapStartText,"start");
               tapStopText.visible = false;
               pleaseWaitText.visible = false;
               cancelButton.visible = false;
               update();
               updateMessageUI();
               SoundManager.playEffect("curtain");
               spineModel.changeAnimation("workmanship_check_open",false,function():void
               {
                  spineModel.finish();
                  Engine.removeSpineCache("efx_spine-workmanship_start");
                  Engine.unlockTouchInput(RouletteDialog);
                  setVisibleState(76);
                  setBackButtonCallbackNormal();
               });
            });
         });
         queue.startTask();
      }
      
      private function showCookingResultDialog() : void
      {
         Engine.showLoading(RouletteDialog);
         var _loc1_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(134217942),function(param1:Array):void
         {
            Engine.hideLoading(RouletteDialog);
            var _loc5_:KitchenwareData = param1[0];
            var _loc9_:GudetamaData = param1[1][0];
            resultGudetamaData = param1[1][1];
            var _loc2_:int = param1[2][0];
            var _loc4_:int = param1[2][1];
            var _loc6_:int = param1[2][2];
            var _loc7_:Array = param1[3];
            var _loc8_:Array = param1[4];
            var _loc10_:GetItemResult = param1[5];
            var _loc3_:int = UserDataWrapper.wrapper.getRank();
            var _loc12_:* = !UserDataWrapper.gudetamaPart.isCooked(resultGudetamaData.id#2);
            UserDataWrapper.kitchenwarePart.addKitchenware(_loc5_);
            UserDataWrapper.wrapper.addRecipe(_loc9_);
            UserDataWrapper.wrapper.addRecipe(resultGudetamaData);
            if(_loc2_ > 0)
            {
               ResidentMenuUI_Gudetama.addFreeMoney(_loc2_);
            }
            if(_loc8_)
            {
               UserDataWrapper.wrapper.addItems(_loc7_,_loc8_);
            }
            var _loc11_:GudetamaDef = GameSetting.getGudetama(_loc9_.id#2);
            successCompleteImage.visible = UserDataWrapper.gudetamaPart.isCooked(_loc9_.id#2);
            happeningCompleteImage.visible = _loc11_.existsHappening() && UserDataWrapper.wrapper.isHappeningCompleted(_loc11_.recipeNoteId);
            failureCompleteImage.visible = UserDataWrapper.wrapper.isFailureCompleted(_loc11_.recipeNoteId);
            ResidentMenuUI_Gudetama.getInstance().updateUserInfo();
            CookingResultDialog.show(resultGudetamaData.id#2,_loc12_,result,_loc2_,_loc4_,_loc6_,_loc3_,_loc10_,_loc7_,_loc8_,finishRoulette);
         });
      }
      
      public function finishRoulette() : void
      {
         backButtonCallback();
      }
      
      override public function backButtonCallback() : void
      {
         GudetamaUnlockableDialog.show(UserDataWrapper.gudetamaPart.getUnlockableGudetamaIdsByID(!!resultGudetamaData ? resultGudetamaData.id#2 : -1),function():void
         {
            Engine.lockTouchInput(RouletteDialog);
            setBackButtonCallback(null);
            var queue:TaskQueue = new TaskQueue();
            queue.addTask(function():void
            {
               spineModel.load("efx_spine-workmanship_start",function():void
               {
                  queue.taskDone();
               });
            });
            queue.registerOnProgress(function(param1:Number):void
            {
               var ratio:Number = param1;
               if(ratio < 1)
               {
                  return;
               }
               getSceneJuggler().delayCall(function():void
               {
                  TweenAnimator.startItself(dialogSprite,"hide",true,function():void
                  {
                     if(dialogSprite)
                     {
                        dialogSprite.visible = false;
                     }
                  });
               },1.2);
               spineModel.show();
               SoundManager.playEffect("curtain");
               spineModel.changeAnimation("curtain_close",true,function():void
               {
                  superBackButtonCallback();
                  if(closedCurtainCallback)
                  {
                     closedCurtainCallback();
                  }
                  SoundManager.playEffect("curtain");
                  spineModel.changeAnimation("curtain_open",true,function():void
                  {
                     spineModel.finish();
                     Engine.removeSpineCache("efx_spine-workmanship_start");
                     Engine.unlockTouchInput(RouletteDialog);
                     Engine.popScene(scene);
                     if(openedCurtainCallback)
                     {
                        openedCurtainCallback();
                     }
                  });
               });
            });
            queue.startTask();
         });
      }
      
      private function superBackButtonCallback() : void
      {
         super.backButtonCallback();
      }
      
      private function touchQuad(param1:TouchEvent) : void
      {
         var _loc2_:Touch = param1.getTouch(quad);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_.phase == "began")
         {
            if(state == 2 && rouletteAutoStopPercent < 0)
            {
               decelerateRoulette();
            }
         }
         else if(_loc2_.phase == "ended")
         {
            if(state == 0)
            {
               accelerateRoulette();
            }
         }
      }
      
      private function accelerateRoulette() : void
      {
         Engine.showLoading(RouletteDialog);
         var _loc1_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(134217963),function(param1:Array):void
         {
            var response:Array = param1;
            Engine.hideLoading(RouletteDialog);
            slipValue = response[0];
            SoundManager.playEffect("drumroll_A",1000,0,function(param1:*):void
            {
               drumRollSE = param1;
            });
            setVisibleState(68);
            setBackButtonCallback(null);
            usefulGroup.visible = false;
            cancelButton.setEnableWithDrawCache(true);
            cancelButton.visible = UserDataWrapper.wrapper.isCompletedTutorial();
            setupRouletteValuesMap();
            state = 1;
         });
      }
      
      private function setupRouletteValuesMap() : void
      {
         rouletteValuesMap = {};
         var _loc3_:Number = 2 * 3.141592653589793 / (rouletteTimePerRound * rouletteTimePerRound);
         var _loc4_:Number = 2 * 3.141592653589793 / rouletteTimePerRound;
         rouletteValuesMap[1] = {
            "accelerate":_loc3_,
            "velocity":_loc4_
         };
         _loc4_ = 2 * 3.141592653589793 / rouletteTimePerRound;
         rouletteValuesMap[2] = {"velocity":_loc4_};
         var _loc2_:* = 1;
         if(rouletteTimePerRound >= 1000)
         {
            _loc2_ = 1;
         }
         else if(rouletteTimePerRound >= 500)
         {
            _loc2_ = 2;
         }
         else
         {
            _loc2_ = 3;
         }
         _loc4_ = 2 * 3.141592653589793 / rouletteTimePerRound;
         var _loc1_:Number = _loc2_ * 2 * 3.141592653589793;
         var _loc5_:int = (_loc2_ + 0.01 * slipValue) * 2 * rouletteTimePerRound;
         _loc3_ = -_loc4_ / _loc5_;
         rouletteValuesMap[3] = {
            "accelerate":_loc3_,
            "velocity":_loc4_,
            "distance":_loc1_,
            "timeUntilStop":_loc5_
         };
      }
      
      private function rotateRoulette() : void
      {
         var _loc1_:Number = NaN;
         state = 2;
         time = 0;
         if(rouletteAutoStopPercent < 0)
         {
            TweenAnimator.startItself(tapStopText,"start");
            tapStopText.visible = true;
         }
         else
         {
            TweenAnimator.startItself(pleaseWaitText,"start");
            pleaseWaitText.visible = true;
            _loc1_ = 2 * 3.141592653589793 * (1 + 0.01 * rouletteAutoStopPercent) - radian;
            stopTime = rouletteTimePerRound * _loc1_ / (2 * 3.141592653589793);
         }
      }
      
      private function decelerateRoulette() : void
      {
         SoundManager.stopEffect(drumRollSE);
         drumRollSE = null;
         SoundManager.playEffect("drumroll_finish_B");
         if(rouletteAutoStopPercent < 0)
         {
            tapStopText.visible = false;
            resultRadian = targetImage.rotation;
            if(resultRadian < 0)
            {
               resultRadian += 2 * 3.141592653589793;
            }
            var gudetamaId:int = UserDataWrapper.kitchenwarePart.getGudetamaId(kitchenwareType);
            var gudetamaDef:GudetamaDef = GameSetting.getGudetama(gudetamaId);
            var percent:int = 100 * resultRadian / (2 * 3.141592653589793) % 100;
         }
         else
         {
            resultRadian = 0.06283185307179587 * rouletteAutoStopPercent;
            percent = rouletteAutoStopPercent;
         }
         cancelButton.setEnableWithDrawCache(false);
         state = 3;
         time = 0;
         Engine.lockTouchInput(RouletteDialog);
         var _loc2_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(134217912,percent),function(param1:Array):void
         {
            result = param1[0];
            retryPrice = param1[1];
            for each(var _loc2_ in selectedUsefulIds)
            {
               UserDataWrapper.usefulPart.consumeUseful(_loc2_,1);
            }
            sendResult = true;
         });
      }
      
      private function triggeredUsefulButton(param1:Event) : void
      {
         var _loc2_:int = UserDataWrapper.kitchenwarePart.getGudetamaId(kitchenwareType);
         var _loc3_:GudetamaDef = GameSetting.getGudetama(_loc2_);
         CookingUsefulDialog.show(kitchenwareType,selectedUsefulIds,_loc3_.existsHappening(),assistantMap,closeCookingUsefulDialogCallback);
      }
      
      private function closeCookingUsefulDialogCallback(param1:Array) : void
      {
         var selectedUsefulIds:Array = param1;
         Engine.showLoading(RouletteDialog);
         var _loc2_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(134217924,selectedUsefulIds),function(param1:Array):void
         {
            var _loc9_:* = null;
            var _loc6_:int = 0;
            var _loc7_:int = 0;
            var _loc2_:* = null;
            var _loc5_:int = 0;
            Engine.hideLoading(RouletteDialog);
            this.selectedUsefulIds = selectedUsefulIds;
            assistUsefulIds = [];
            var _loc4_:KitchenwareData;
            if((_loc4_ = UserDataWrapper.kitchenwarePart.getKitchenwareByType(kitchenwareType)).assistUsefulIds)
            {
               assistUsefulIds = _loc4_.assistUsefulIds.slice();
            }
            for each(var _loc10_ in selectedUsefulIds)
            {
               if((_loc6_ = (_loc9_ = GameSetting.getUseful(_loc10_)).getUniqueType()) >= 0)
               {
                  _loc7_ = assistUsefulIds.length - 1;
                  while(_loc7_ >= 0)
                  {
                     _loc2_ = GameSetting.getUseful(assistUsefulIds[_loc7_]);
                     if((_loc5_ = _loc2_.getUniqueType()) >= 0 && _loc5_ != _loc6_)
                     {
                        assistUsefulIds.removeAt(_loc7_);
                     }
                     _loc7_--;
                  }
               }
            }
            var _loc3_:int = UserDataWrapper.kitchenwarePart.getGudetamaId(kitchenwareType);
            var _loc8_:GudetamaDef = GameSetting.getGudetama(_loc3_);
            ratesInType = createRouletteRates();
            _loc7_ = 0;
            while(_loc7_ < rouletteCircles.length)
            {
               rouletteCircles[_loc7_].setup(ratesInType[_loc7_]);
               _loc7_++;
            }
            applyAbilitiesToRouletteTimePerRound();
            updateMessageUI();
         });
      }
      
      private function triggeredCancelButton(param1:Event) : void
      {
         if(drumRollSE)
         {
            SoundManager.stopEffect(drumRollSE);
            drumRollSE = null;
         }
         tapStopText.visible = false;
         pleaseWaitText.visible = false;
         setVisibleState(76);
         setBackButtonCallbackNormal();
         usefulGroup.visible = true;
         cancelButton.visible = false;
         targetImage.rotation = 0;
         time = 0;
         radian = 0;
         resultRadian = 0;
         state = 0;
      }
      
      private function applyAbilitiesToRouletteTimePerRound() : void
      {
         var _loc6_:* = null;
         var _loc8_:int = 0;
         var _loc2_:KitchenwareData = UserDataWrapper.kitchenwarePart.getKitchenwareByType(kitchenwareType);
         var _loc1_:int = UserDataWrapper.kitchenwarePart.getGudetamaId(kitchenwareType);
         var _loc5_:GudetamaDef = GameSetting.getGudetama(_loc1_);
         var _loc4_:int = 0;
         for each(var _loc7_ in selectedUsefulIds)
         {
            if((_loc6_ = GameSetting.getUseful(_loc7_)).abilities)
            {
               _loc4_ += _loc6_.sumAbilities(2);
            }
         }
         for each(var _loc3_ in assistUsefulIds)
         {
            if((_loc6_ = GameSetting.getUseful(_loc3_)).assistAbilities)
            {
               _loc4_ += _loc6_.sumAssistAbilities(2);
            }
         }
         _loc4_ += UserDataWrapper.featurePart.getValue(7);
         rouletteTimePerRound = _loc5_.rouletteTimePerRound;
         if(_loc4_ > 0)
         {
            _loc8_ = Math.max(100 - _loc4_,GameSetting.getRule().lowerLimitPercentForRouletteSpeed);
            rouletteTimePerRound *= 100 / _loc8_;
         }
      }
      
      private function refreshedSceneContainer(param1:Event) : void
      {
      }
      
      override public function dispose() : void
      {
         removeEventListener("refreshed_scene_container",refreshedSceneContainer);
         quad = null;
         dialogSprite = null;
         happeningBgImage = null;
         successCompleteImage = null;
         happeningCompleteImage = null;
         failureCompleteImage = null;
         rouletteGroup = null;
         rouletteImage = null;
         rouletteBlackImage = null;
         rouletteCircles.length = 0;
         rouletteCircles = null;
         targetImage = null;
         gudetamaImage = null;
         if(tooMatchTimeMessageUI)
         {
            tooMatchTimeMessageUI.dispose();
            tooMatchTimeMessageUI = null;
         }
         if(usefulMessageUI)
         {
            usefulMessageUI.dispose();
            usefulMessageUI = null;
         }
         usefulGroup = null;
         if(usefulButton)
         {
            usefulButton.removeEventListener("triggered",triggeredUsefulButton);
            usefulButton = null;
         }
         if(cancelButton)
         {
            cancelButton.removeEventListener("triggered",triggeredCancelButton);
            cancelButton = null;
         }
         friendIconImage = null;
         spineModel = null;
         tapStartText = null;
         tapStopText = null;
         pleaseWaitText = null;
         targetGroup = null;
         rouletteValuesMap = null;
         clearCache();
         super.dispose();
      }
   }
}

import gudetama.engine.TextureCollector;
import gudetama.engine.TweenAnimator;
import gudetama.ui.UIBase;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

class MessageUI extends UIBase
{
   
   public static const BG_GREEN:int = 1;
   
   public static const BG_BROWN:int = 2;
   
   public static const BG_PINK:int = 3;
   
   private static const INTERVAL:int = 5;
    
   
   private var bgImage:Image;
   
   private var messageText:ColorTextField;
   
   private var tweenParam:Object;
   
   function MessageUI(param1:Sprite)
   {
      super(param1);
      bgImage = param1.getChildByName("bg") as Image;
      messageText = param1.getChildByName("message") as ColorTextField;
   }
   
   public function init() : void
   {
      setVisible(false);
   }
   
   public function show(param1:String) : void
   {
      setVisible(true);
      messageText.width = (messageText.fontSize + 3) * param1.length;
      messageText.text#2 = param1;
      messageText.width = messageText.textBounds.width;
      var _loc4_:Number = bgImage.width + bgImage.width;
      var _loc2_:Number = bgImage.width + messageText.width;
      var _loc3_:Number = 5 * Math.max(_loc4_,_loc2_) / _loc4_;
      clearTweenParam();
      tweenParam = {
         "fromX":bgImage.width,
         "propertiesX":-messageText.width,
         "time":_loc3_
      };
      TweenAnimator.finishTween(messageText);
      TweenAnimator.startTween(messageText,"FLOW_POS",tweenParam);
   }
   
   public function set bg(param1:int) : void
   {
      var type:int = param1;
      switch(int(type) - 1)
      {
         case 0:
            messageText.color = 2844491;
            break;
         case 1:
            messageText.color = 16777215;
            break;
         case 2:
            messageText.color = 16777215;
      }
      TextureCollector.loadTexture("roulette0@ribbon0" + type,function(param1:Texture):void
      {
         if(bgImage != null)
         {
            bgImage.texture = param1;
         }
      });
   }
   
   private function clearTweenParam() : void
   {
      if(!tweenParam)
      {
         return;
      }
      for(var _loc1_ in tweenParam)
      {
         delete tweenParam[_loc1_];
      }
      tweenParam = null;
   }
   
   public function hide() : void
   {
      setVisible(false);
   }
   
   public function dispose() : void
   {
      bgImage = null;
      messageText = null;
      clearTweenParam();
   }
}
