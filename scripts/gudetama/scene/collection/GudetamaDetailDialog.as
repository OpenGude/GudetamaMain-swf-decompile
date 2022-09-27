package gudetama.scene.collection
{
   import gestouch.events.GestureEvent;
   import gestouch.gestures.SwipeGesture;
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.GudetamaData;
   import gudetama.data.compati.GudetamaDef;
   import gudetama.data.compati.KitchenwareDef;
   import gudetama.data.compati.RecipeNoteDef;
   import gudetama.data.compati.VoiceDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.scene.friend.FriendPresentListDialog;
   import gudetama.scene.home.HomeScene;
   import gudetama.scene.home.ui.SerifUI;
   import gudetama.ui.AcquiredKitchenwareDialog;
   import gudetama.ui.AcquiredRecipeNoteDialog;
   import gudetama.ui.CookingGuideDialog;
   import gudetama.ui.GudetamaShareDialog;
   import gudetama.ui.LocalMessageDialog;
   import gudetama.ui.LockedRecipeDialog;
   import gudetama.ui.LockedRecipeNoteDialog;
   import gudetama.ui.PurchaseRecipeDialog;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.ui.WantedReplacementDialog;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.display.SimpleImageButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class GudetamaDetailDialog extends BaseScene
   {
      
      public static const BACK:int = -1;
      
      public static const NEXT:int = 1;
      
      private static var currentstate:int;
       
      
      private var gudetamas:Vector.<GudetamaDef>;
      
      private var currentIndex:int;
      
      private var fromCollection:Boolean;
      
      private var quad:Quad;
      
      private var numberText:ColorTextField;
      
      private var areaGroup:Sprite;
      
      private var areaText:ColorTextField;
      
      private var nameText:ColorTextField;
      
      private var categoryText:ColorTextField;
      
      private var rewardText:ColorTextField;
      
      private var countText:ColorTextField;
      
      private var possessionText:ColorTextField;
      
      private var costText:ColorTextField;
      
      private var descText:ColorTextField;
      
      private var yetText:ColorTextField;
      
      private var iconImage:Image;
      
      private var raritySprite:Sprite;
      
      private var rarityInvisibleText:ColorTextField;
      
      private var buttonGroup:Sprite;
      
      private var placeButton:LowerButtonUI;
      
      private var shareButton:LowerButtonUI;
      
      private var listButton:LowerButtonUI;
      
      private var presentButton:LowerButtonUI;
      
      private var cookingButton:LowerButtonUI;
      
      private var leftButton:ContainerButton;
      
      private var rightButton:ContainerButton;
      
      private var btnGuni:SimpleImageButton;
      
      private var serifUI:SerifUI;
      
      private var voiceButtonUIs:Vector.<VoiceButtonUI>;
      
      private var swipeGesture:SwipeGesture;
      
      private var imgHappening:Image;
      
      public function GudetamaDetailDialog(param1:Vector.<GudetamaDef>, param2:int, param3:Boolean)
      {
         voiceButtonUIs = new Vector.<VoiceButtonUI>();
         super(!!param3 ? 1 : 2);
         this.gudetamas = param1;
         this.currentIndex = param2;
         this.fromCollection = param3;
         addEventListener("update_scene",updateScene);
      }
      
      public static function show(param1:Vector.<GudetamaDef>, param2:int, param3:Boolean = true) : void
      {
         Engine.pushScene(new GudetamaDetailDialog(param1,param2,param3),0,false);
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
      
      public static function tryCook(param1:GudetamaDef, param2:Function) : void
      {
         var gudeDef:GudetamaDef = param1;
         var buyRecipeNoteFunc:Function = param2;
         if(gudeDef.isCup)
         {
            LocalMessageDialog.show(0,GameSetting.getUIText("gudetamaShortage.cooking.cupgacha"),null,GameSetting.getUIText("gudetamaShortage.cooking.title"));
            return;
         }
         var recipeNoteDef:RecipeNoteDef = !!gudeDef ? GameSetting.getRecipeNote(gudeDef.recipeNoteId) : null;
         var kitchenwareDef:KitchenwareDef = !!recipeNoteDef ? GameSetting.getKitchenware(recipeNoteDef.kitchenwareId) : null;
         if(!kitchenwareDef && gudeDef.kitchenwareId > 0)
         {
            kitchenwareDef = GameSetting.getKitchenware(gudeDef.kitchenwareId);
         }
         if(!recipeNoteDef && !kitchenwareDef)
         {
            LocalMessageDialog.show(0,GameSetting.getUIText("gudetamaShortage.cooking.uncountable.desc"),null,GameSetting.getUIText("gudetamaShortage.cooking.title"));
            return;
         }
         if(kitchenwareDef && !UserDataWrapper.kitchenwarePart.isAvailable(kitchenwareDef.type,kitchenwareDef.grade))
         {
            kitchenwareDef = !!recipeNoteDef ? GameSetting.getKitchenware(recipeNoteDef.kitchenwareId) : null;
            if(!kitchenwareDef && gudeDef.kitchenwareId > 0)
            {
               kitchenwareDef = GameSetting.getKitchenware(gudeDef.kitchenwareId);
            }
            LocalMessageDialog.show(0,StringUtil.format(GameSetting.getUIText("gudetamaShortage.cooking.needAvailableKitchenware.desc"),kitchenwareDef.name#2),null,GameSetting.getUIText("gudetamaShortage.cooking.title"));
            return;
         }
         if(UserDataWrapper.gudetamaPart.isFailure(gudeDef.id#2))
         {
            moveToCookingScene(gudeDef);
            return;
         }
         if(recipeNoteDef && !UserDataWrapper.eventPart.inTerm(recipeNoteDef.eventId,true))
         {
            LocalMessageDialog.show(0,GameSetting.getUIText("gudetamaShortage.cooking.outOfTerm.desc"),null,GameSetting.getUIText("gudetamaShortage.cooking.title"));
            return;
         }
         if(recipeNoteDef && !UserDataWrapper.recipeNotePart.isVisible(recipeNoteDef.id#2))
         {
            recipeNoteDef = GameSetting.getRecipeNote(gudeDef.recipeNoteId);
            if(!recipeNoteDef.premises || recipeNoteDef.premises.length == 0)
            {
               return;
            }
            var premiseRecipeNoteDef:RecipeNoteDef = GameSetting.getRecipeNote(recipeNoteDef.premises[0]);
            LocalMessageDialog.show(0,StringUtil.format(GameSetting.getUIText("gudetamaShortage.cooking.invisible.desc"),GudetamaUtil.getKitchenwareNameByRecipeNote(premiseRecipeNoteDef)),null,GameSetting.getUIText("gudetamaShortage.cooking.title"));
            return;
         }
         if(recipeNoteDef && !UserDataWrapper.recipeNotePart.isAvailable(recipeNoteDef.id#2))
         {
            LockedRecipeNoteDialog.show(gudeDef.recipeNoteId);
            return;
         }
         if(recipeNoteDef && !UserDataWrapper.recipeNotePart.isPurchased(recipeNoteDef.id#2))
         {
            currentstate = ResidentMenuUI_Gudetama.getInstance().getCurrentSate();
            chageSceneState(141,function():void
            {
               PurchaseRecipeDialog.show(gudeDef.recipeNoteId,function(param1:Boolean):void
               {
                  var _close:Boolean = param1;
                  chageSceneState(currentstate,function():void
                  {
                     AcquiredKitchenwareDialog.show(function():void
                     {
                        AcquiredRecipeNoteDialog.show();
                     });
                     if(buyRecipeNoteFunc)
                     {
                        buyRecipeNoteFunc();
                     }
                  });
               });
            });
            return;
         }
         if(UserDataWrapper.gudetamaPart.isHappening(gudeDef.id#2) || UserDataWrapper.gudetamaPart.isAvailable(gudeDef.id#2))
         {
            moveToCookingScene(gudeDef);
            return;
         }
         LockedRecipeDialog.show(gudeDef.id#2);
      }
      
      private static function chageSceneState(param1:int, param2:Function) : void
      {
         var _state:int = param1;
         var _callback:Function = param2;
         if(_state == ResidentMenuUI_Gudetama.getInstance().getCurrentSate())
         {
            _callback();
            return;
         }
         ResidentMenuUI_Gudetama.getInstance().sendChangeState(_state,function():void
         {
            _callback();
         },false);
      }
      
      private static function moveToCookingScene(param1:GudetamaDef) : void
      {
         var gudeDef:GudetamaDef = param1;
         var recipeNoteDef:RecipeNoteDef = GameSetting.getRecipeNote(gudeDef.recipeNoteId);
         gudeDef;
         var kitchenwareDef:KitchenwareDef = !!recipeNoteDef ? GameSetting.getKitchenware(recipeNoteDef.kitchenwareId) : null;
         if(!kitchenwareDef && gudeDef.kitchenwareId > 0)
         {
            kitchenwareDef = GameSetting.getKitchenware(gudeDef.kitchenwareId);
         }
         var isHappening:Boolean = UserDataWrapper.gudetamaPart.isHappening(gudeDef.id#2);
         var isFailure:Boolean = UserDataWrapper.gudetamaPart.isFailure(gudeDef.id#2);
         var param:Object = {
            "kitchenwareType":kitchenwareDef.type,
            "kitchenwareId":kitchenwareDef.id#2
         };
         if(!isFailure)
         {
            param["recipeNoteId"] = recipeNoteDef.id#2;
            if(!isHappening)
            {
               param["gudetamaId"] = gudeDef.id#2;
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
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"GudetamaDetailDialog",function(param1:Object):void
         {
            var _loc4_:int = 0;
            var _loc2_:* = null;
            displaySprite = param1.object;
            quad = displaySprite.getChildByName("quad") as Quad;
            var _loc3_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            numberText = _loc3_.getChildByName("number") as ColorTextField;
            imgHappening = _loc3_.getChildByName("imgHappening") as Image;
            areaGroup = _loc3_.getChildByName("areaGroup") as Sprite;
            areaText = areaGroup.getChildByName("area") as ColorTextField;
            nameText = _loc3_.getChildByName("name") as ColorTextField;
            categoryText = _loc3_.getChildByName("category") as ColorTextField;
            rewardText = _loc3_.getChildByName("reward") as ColorTextField;
            countText = _loc3_.getChildByName("count") as ColorTextField;
            possessionText = _loc3_.getChildByName("possession") as ColorTextField;
            costText = _loc3_.getChildByName("cost") as ColorTextField;
            descText = _loc3_.getChildByName("desc") as ColorTextField;
            if(!GudetamaUtil.isTranslateByCs(Engine.getLocale()))
            {
               descText.ignoreHeadLinefeed = true;
               descText.autoScale = true;
               Image(_loc3_.getChildByName("imgLineDot0")).visible = false;
               Image(_loc3_.getChildByName("imgLineDot1")).visible = false;
               Image(_loc3_.getChildByName("imgLineDot2")).visible = false;
            }
            yetText = _loc3_.getChildByName("yet") as ColorTextField;
            iconImage = _loc3_.getChildByName("icon") as Image;
            raritySprite = _loc3_.getChildByName("rarity") as Sprite;
            rarityInvisibleText = _loc3_.getChildByName("rarityInvisible") as ColorTextField;
            buttonGroup = _loc3_.getChildByName("buttonGroup") as Sprite;
            placeButton = new LowerButtonUI(buttonGroup.getChildByName("btn_place") as ContainerButton,triggeredPlaceButton);
            shareButton = new LowerButtonUI(buttonGroup.getChildByName("btn_share") as ContainerButton,triggeredShareButton);
            listButton = new LowerButtonUI(buttonGroup.getChildByName("btn_list") as ContainerButton,triggeredListButton);
            presentButton = new LowerButtonUI(buttonGroup.getChildByName("btn_present") as ContainerButton,triggeredPresentButton);
            cookingButton = new LowerButtonUI(buttonGroup.getChildByName("btn_cooking") as ContainerButton,triggeredCookingButton);
            leftButton = (_loc3_.getChildByName("leftButton") as Sprite).getChildByName("ArrowButton") as ContainerButton;
            leftButton.addEventListener("triggered",triggeredLeftButton);
            rightButton = (_loc3_.getChildByName("rightButton") as Sprite).getChildByName("ArrowButton") as ContainerButton;
            rightButton.addEventListener("triggered",triggeredRightButton);
            btnGuni = _loc3_.getChildByName("btnGuni") as SimpleImageButton;
            btnGuni.addEventListener("triggered",triggeredGuni);
            serifUI = new SerifUI(_loc3_.getChildByName("rightSerifGroup") as Sprite,_loc3_.getChildByName("leftSerifGroup") as Sprite);
            var _loc5_:Sprite = _loc3_.getChildByName("voiceButtonGroup") as Sprite;
            _loc4_ = 0;
            while(_loc4_ < _loc5_.numChildren)
            {
               _loc2_ = GameSetting.getVoice(gudetamas[currentIndex].voices[_loc4_]);
               voiceButtonUIs.push(new VoiceButtonUI(_loc5_.getChildByName("voiceButton" + _loc4_) as ContainerButton,_loc4_,_loc2_,playSerifUI));
               _loc4_++;
            }
            swipeGesture = new SwipeGesture(quad);
            Engine.setSwipeGestureDefaultParam(swipeGesture);
            swipeGesture.addEventListener("gestureRecognized",gesture);
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
         var gudetamaDef:GudetamaDef = gudetamas[currentIndex];
         var gudetamaData:GudetamaData = UserDataWrapper.gudetamaPart.getGudetama(gudetamaDef.id#2);
         var cooked:Boolean = UserDataWrapper.gudetamaPart.isCooked(gudetamaDef.id#2);
         if(gudetamaDef.type != 1)
         {
            numberText.visible = false;
         }
         numberText.text#2 = StringUtil.format(GameSetting.getUIText("gudetamaDetail.number"),gudetamaDef.number);
         imgHappening.visible = gudetamaDef.cookingResultType == 1;
         areaGroup.visible = gudetamaDef.country != 127 || gudetamaDef.area != 999;
         if(gudetamaDef.country != 127 && gudetamaDef.area != 999)
         {
            areaText.text#2 = StringUtil.branchTextOnCondition(cooked,StringUtil.format(GameSetting.getUIText("gudetamaDetail.discovery"),GameSetting.getUIText("common.country." + gudetamaDef.country),GameSetting.getUIText("gudetama.area." + gudetamaDef.area)),GameSetting.getUIText("common.invisible"));
         }
         else if(gudetamaDef.country != 127)
         {
            areaText.text#2 = StringUtil.branchTextOnCondition(cooked,GameSetting.getUIText("common.country." + gudetamaDef.country),GameSetting.getUIText("common.invisible"));
         }
         else if(gudetamaDef.area != 999)
         {
            areaText.text#2 = StringUtil.branchTextOnCondition(cooked,GameSetting.getUIText("gudetama.area." + gudetamaDef.area),GameSetting.getUIText("common.invisible"));
         }
         nameText.text#2 = StringUtil.branchTextOnCondition(true,gudetamaDef.name#2,GameSetting.getUIText("common.invisible"));
         categoryText.text#2 = GameSetting.getUIText("gudetamaDetail.category").replace("%1",StringUtil.branchTextOnCondition(cooked,GameSetting.getUIText("gudetama.category." + gudetamaDef.category),GameSetting.getUIText("common.invisible")));
         updateBtnGuni(gudetamaDef);
         rewardText.text#2 = StringUtil.branchTextOnCondition(cooked,StringUtil.format(GameSetting.getUIText("common.money"),StringUtil.getNumStringCommas(gudetamaDef.reward)),GameSetting.getUIText("common.invisible"));
         countText.text#2 = StringUtil.format(GameSetting.getUIText("common.count"),gudetamaData.count);
         possessionText.text#2 = gudetamaData.num.toString();
         costText.text#2 = StringUtil.branchTextOnCondition(cooked,StringUtil.format(GameSetting.getUIText("common.money"),StringUtil.getNumStringCommas(gudetamaDef.cost)),GameSetting.getUIText("common.invisible"));
         descText.text#2 = gudetamaDef.desc;
         descText.visible = cooked;
         var recipeNote:RecipeNoteDef = GameSetting.getRecipeNote(gudetamaDef.recipeNoteId);
         setYetText(cooked,gudetamaDef.id#2,recipeNote);
         var i:int = 0;
         while(i < voiceButtonUIs.length)
         {
            var voice:VoiceDef = GameSetting.getVoice(gudetamas[currentIndex].voices[i]);
            voiceButtonUIs[i].enabled(UserDataWrapper.gudetamaPart.isUnlockedVoice(gudetamaDef.id#2,i),voice);
            i++;
         }
         voiceButtonUIs[1].setVisible(UserDataWrapper.featurePart.existsFeature(5));
         serifUI.setup();
         queue.addTask(function():void
         {
            TextureCollector.loadTextureRsrc("gudetama-" + gudetamaDef.rsrc + "-icon",function(param1:Texture):void
            {
               iconImage.texture = param1;
               iconImage.color = !!cooked ? 16777215 : 5263440;
               queue.taskDone();
            });
         });
         if(cooked)
         {
            queue.addTask(function():void
            {
               TweenAnimator.startItself(raritySprite,"rare" + gudetamaDef.rarity,false,function():void
               {
                  queue.taskDone();
               });
            });
            raritySprite.visible = true;
            rarityInvisibleText.visible = false;
         }
         else
         {
            raritySprite.visible = false;
            rarityInvisibleText.visible = true;
         }
         rarityInvisibleText.text#2 = GameSetting.getUIText("common.invisible");
         leftButton.visible = gudetamas.length > 1;
         rightButton.visible = gudetamas.length > 1;
         placeButton.setVisible(cooked);
         placeButton.lock = !UserDataWrapper.featurePart.existsFeature(4);
         placeButton.enable = UserDataWrapper.wrapper.getPlacedGudetamaId() != gudetamaDef.id#2;
         shareButton.setVisible(cooked);
         shareButton.lock = false;
         shareButton.enable = true;
         listButton.setVisible(!gudetamaDef.uncountable);
         listButton.lock = false;
         listButton.enable = !UserDataWrapper.wantedPart.exists(gudetamaDef.id#2) && cooked;
         presentButton.setVisible(!gudetamaDef.uncountable);
         presentButton.lock = !UserDataWrapper.featurePart.existsFeature(12);
         presentButton.enable = UserDataWrapper.gudetamaPart.hasGudetama(gudetamaDef.id#2,1);
         cookingButton.setVisible(!gudetamaDef.uncountable);
         cookingButton.lock = false;
         updateCookingButton();
         queue.addTask(function():void
         {
            TweenAnimator.startItself(displaySprite,!!fromCollection ? "collection" : "other",false,function():void
            {
               queue.taskDone();
            });
         });
      }
      
      private function updateBtnGuni(param1:GudetamaDef) : void
      {
         btnGuni.visible = !param1.disabledSpine;
      }
      
      override protected function addedToContainer() : void
      {
         setBackButtonCallback(backButtonCallback);
         setVisibleState(!!fromCollection ? 94 : 12);
         Engine.lockTouchInput(GudetamaDetailDialog);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            resumeNoticeTutorial(3);
            Engine.unlockTouchInput(GudetamaDetailDialog);
         });
         TweenAnimator.startItself(leftButton,"start");
         TweenAnimator.startItself(rightButton,"start");
      }
      
      override public function backButtonCallback() : void
      {
         if(Engine.getGuideTalkPanel() != null)
         {
            return;
         }
         super.backButtonCallback();
         Engine.lockTouchInput(GudetamaDetailDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(GudetamaDetailDialog);
            Engine.popScene(scene);
         });
      }
      
      private function gesture(param1:GestureEvent) : void
      {
         if(Engine.isTouchInputLocked())
         {
            return;
         }
         if(!leftButton.visible || !rightButton.visible)
         {
            return;
         }
         if(swipeGesture.offsetX > 0)
         {
            triggeredLeftButton();
         }
         else if(swipeGesture.offsetX < 0)
         {
            triggeredRightButton();
         }
      }
      
      private function triggeredPlaceButton(param1:Boolean, param2:Boolean) : void
      {
         var locked:Boolean = param1;
         var enabled:Boolean = param2;
         if(locked)
         {
            UnlockPlaceDialog.show();
         }
         else if(!enabled)
         {
            LocalMessageDialog.show(0,GameSetting.getUIText("gudetamaDetail.message.place.disabled.desc"),null,GameSetting.getUIText("gudetamaDetail.message.place.title"));
         }
         else
         {
            var gudetamaDef:GudetamaDef = gudetamas[currentIndex];
            var _loc4_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(COLLECTION_PLACE,gudetamaDef.id#2),function(param1:Array):void
            {
               var response:Array = param1;
               UserDataWrapper.wrapper.placeGudetama(gudetamaDef.id#2);
               ResidentMenuUI_Gudetama.getInstance().sendChangeState(60,function():void
               {
                  Engine.switchScene(new HomeScene());
               });
            });
         }
      }
      
      private function triggeredShareButton(param1:Boolean, param2:Boolean) : void
      {
         var _loc3_:* = null;
         if(param2)
         {
            _loc3_ = gudetamas[currentIndex];
            GudetamaShareDialog.show([_loc3_.id#2]);
         }
      }
      
      private function triggeredListButton(param1:Boolean, param2:Boolean) : void
      {
         var locked:Boolean = param1;
         var enabled:Boolean = param2;
         var gudetamaDef:GudetamaDef = gudetamas[currentIndex];
         var isCooked:Boolean = UserDataWrapper.gudetamaPart.isCooked(gudetamaDef.id#2);
         if(!enabled)
         {
            if(!isCooked)
            {
               LocalMessageDialog.show(0,GameSetting.getUIText("gudetamaDetail.message.list.notCooked.desc"),null,GameSetting.getUIText("gudetamaShortage.wanted.title"));
            }
            else if(UserDataWrapper.wantedPart.exists(gudetamaDef.id#2))
            {
               LocalMessageDialog.show(0,GameSetting.getUIText("gudetamaDetail.message.list.disabled.desc"),null,GameSetting.getUIText("gudetamaShortage.wanted.title"));
            }
         }
         else
         {
            addWantedGudetama(gudetamaDef,function():void
            {
               listButton.enable = !UserDataWrapper.wantedPart.exists(gudetamaDef.id#2) && isCooked;
            });
         }
      }
      
      private function triggeredPresentButton(param1:Boolean, param2:Boolean) : void
      {
         var _loc3_:* = null;
         if(param1)
         {
            LocalMessageDialog.show(0,GudetamaUtil.getFriendUnlockConditionText(),null,GameSetting.getUIText("gudetamaDetail.message.present.title"));
         }
         else if(!param2)
         {
            showCookingGuideDialog();
         }
         else
         {
            _loc3_ = gudetamas[currentIndex];
            FriendPresentListDialog.show(_loc3_.id#2);
         }
      }
      
      private function triggeredCookingButton(param1:Boolean, param2:Boolean) : void
      {
         var locked:Boolean = param1;
         var enabled:Boolean = param2;
         var gudetamaDef:GudetamaDef = gudetamas[currentIndex];
         var buyRecipeNoteFunc:Function = function():void
         {
            cookingButton.lock = false;
            updateCookingButton();
         };
         tryCook(gudetamaDef,buyRecipeNoteFunc);
      }
      
      private function updateCookingButton() : void
      {
         var _loc2_:GudetamaDef = gudetamas[currentIndex];
         var _loc3_:RecipeNoteDef = !!_loc2_ ? GameSetting.getRecipeNote(_loc2_.recipeNoteId) : null;
         var _loc4_:KitchenwareDef;
         if(!(_loc4_ = !!_loc3_ ? GameSetting.getKitchenware(_loc3_.kitchenwareId) : null) && _loc2_.kitchenwareId > 0)
         {
            _loc4_ = GameSetting.getKitchenware(_loc2_.kitchenwareId);
         }
         var _loc1_:Boolean = UserDataWrapper.gudetamaPart.isHappening(_loc2_.id#2);
         var _loc5_:Boolean = UserDataWrapper.gudetamaPart.isFailure(_loc2_.id#2);
         cookingButton.enable = _loc4_ && UserDataWrapper.kitchenwarePart.isAvailable(_loc4_.type,_loc4_.grade) && (_loc5_ || _loc3_ && UserDataWrapper.eventPart.inTerm(_loc3_.eventId,true) && UserDataWrapper.recipeNotePart.isVisible(_loc3_.id#2) && UserDataWrapper.recipeNotePart.isAvailable(_loc3_.id#2) && UserDataWrapper.recipeNotePart.isPurchased(_loc3_.id#2) && (_loc1_ || UserDataWrapper.gudetamaPart.isAvailable(_loc2_.id#2)));
      }
      
      private function _moveToCookingScene() : void
      {
         var _loc1_:GudetamaDef = gudetamas[currentIndex];
         moveToCookingScene(_loc1_);
      }
      
      private function showCookingGuideDialog() : void
      {
         var showMessageDialog:Function = function():void
         {
            LocalMessageDialog.show(0,GameSetting.getUIText("gudetamaDetail.message.present.disabled.desc"),null,GameSetting.getUIText("gudetamaDetail.message.present.title"));
         };
         var gudetamaDef:GudetamaDef = gudetamas[currentIndex];
         if(!UserDataWrapper.gudetamaPart.isAvailable(gudetamaDef.id#2))
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
      
      private function triggeredLeftButton(param1:Event = null) : void
      {
         load(-1);
      }
      
      private function triggeredRightButton(param1:Event = null) : void
      {
         load(1);
      }
      
      private function setYetText(param1:Boolean, param2:int, param3:RecipeNoteDef) : void
      {
         yetText.visible = !param1;
         if(param1)
         {
            return;
         }
         if(UserDataWrapper.recipeNotePart.isVisible(param3.id#2))
         {
            yetText.text#2 = GameSetting.getUIText("gudetamaDetail.yetCooking").replace("%1",GudetamaUtil.getKitchenwareNameByRecipeNote(param3));
         }
         else
         {
            yetText.text#2 = GameSetting.getUIText("gudetamaDetail.yetBuyingyetCooking").replace("%1",GudetamaUtil.getKitchenwareNameByRecipeNote(param3));
         }
      }
      
      private function load(param1:int) : void
      {
         var dir:int = param1;
         Engine.showLoading(GudetamaDetailDialog);
         currentIndex += dir;
         if(currentIndex < 0)
         {
            currentIndex = gudetamas.length - 1;
         }
         currentIndex %= gudetamas.length;
         var gudetamaDef:GudetamaDef = gudetamas[currentIndex];
         var gudetamaData:GudetamaData = UserDataWrapper.gudetamaPart.getGudetama(gudetamaDef.id#2);
         var queue:TaskQueue = new TaskQueue();
         queue.addTask(function():void
         {
            TextureCollector.loadTextureRsrc("gudetama-" + gudetamaDef.rsrc + "-icon",function(param1:Texture):void
            {
               gudetamaTexture = param1;
               queue.taskDone();
            });
         });
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            update(gudetamaDef,gudetamaData,gudetamaTexture);
         });
         queue.startTask();
      }
      
      private function update(param1:GudetamaDef, param2:GudetamaData, param3:Texture) : void
      {
         var gudetamaDef:GudetamaDef = param1;
         var gudetamaData:GudetamaData = param2;
         var gudetamaTexture:Texture = param3;
         var cooked:Boolean = UserDataWrapper.gudetamaPart.isCooked(gudetamaDef.id#2);
         var queue:TaskQueue = new TaskQueue();
         if(cooked)
         {
            queue.addTask(function():void
            {
               TweenAnimator.startItself(raritySprite,"rare" + gudetamaDef.rarity,false,function():void
               {
                  queue.taskDone();
               });
            });
            raritySprite.visible = true;
            rarityInvisibleText.visible = false;
         }
         else
         {
            raritySprite.visible = false;
            rarityInvisibleText.visible = true;
         }
         queue.registerOnProgress(function(param1:Number):void
         {
            var _loc3_:int = 0;
            var _loc2_:* = null;
            if(param1 < 1)
            {
               return;
            }
            numberText.text#2 = StringUtil.format(GameSetting.getUIText("gudetamaDetail.number"),gudetamaDef.number);
            imgHappening.visible = gudetamaDef.cookingResultType == 1;
            areaGroup.visible = gudetamaDef.country != 127 || gudetamaDef.area != 999;
            if(gudetamaDef.country != 127 && gudetamaDef.area != 999)
            {
               areaText.text#2 = StringUtil.branchTextOnCondition(cooked,StringUtil.format(GameSetting.getUIText("gudetamaDetail.discovery"),GameSetting.getUIText("common.country." + gudetamaDef.country),GameSetting.getUIText("gudetama.area." + gudetamaDef.area)),GameSetting.getUIText("common.invisible"));
            }
            else if(gudetamaDef.country != 127)
            {
               areaText.text#2 = StringUtil.branchTextOnCondition(cooked,GameSetting.getUIText("common.country." + gudetamaDef.country),GameSetting.getUIText("common.invisible"));
            }
            else if(gudetamaDef.area != 999)
            {
               areaText.text#2 = StringUtil.branchTextOnCondition(cooked,GameSetting.getUIText("gudetama.area." + gudetamaDef.area),GameSetting.getUIText("common.invisible"));
            }
            nameText.text#2 = StringUtil.branchTextOnCondition(true,gudetamaDef.name#2,GameSetting.getUIText("common.invisible"));
            categoryText.text#2 = GameSetting.getUIText("gudetamaDetail.category").replace("%1",StringUtil.branchTextOnCondition(cooked,GameSetting.getUIText("gudetama.category." + gudetamaDef.category),GameSetting.getUIText("common.invisible")));
            updateBtnGuni(gudetamaDef);
            rewardText.text#2 = StringUtil.branchTextOnCondition(cooked,StringUtil.format(GameSetting.getUIText("common.money"),StringUtil.getNumStringCommas(gudetamaDef.reward)),GameSetting.getUIText("common.invisible"));
            countText.text#2 = StringUtil.format(GameSetting.getUIText("common.count"),gudetamaData.count);
            possessionText.text#2 = gudetamaData.num.toString();
            costText.text#2 = StringUtil.branchTextOnCondition(cooked,StringUtil.format(GameSetting.getUIText("common.money"),StringUtil.getNumStringCommas(gudetamaDef.cost)),GameSetting.getUIText("common.invisible"));
            descText.text#2 = gudetamaDef.desc;
            descText.visible = cooked;
            var _loc4_:RecipeNoteDef = GameSetting.getRecipeNote(gudetamaDef.recipeNoteId);
            setYetText(cooked,gudetamaDef.id#2,_loc4_);
            _loc3_ = 0;
            while(_loc3_ < voiceButtonUIs.length)
            {
               _loc2_ = GameSetting.getVoice(gudetamas[currentIndex].voices[_loc3_]);
               voiceButtonUIs[_loc3_].enabled(UserDataWrapper.gudetamaPart.isUnlockedVoice(gudetamaDef.id#2,_loc3_),_loc2_);
               _loc3_++;
            }
            iconImage.texture = gudetamaTexture;
            iconImage.color = !!cooked ? 16777215 : 5263440;
            placeButton.setVisible(cooked);
            placeButton.enable = UserDataWrapper.wrapper.getPlacedGudetamaId() != gudetamaDef.id#2;
            shareButton.setVisible(cooked);
            shareButton.lock = false;
            shareButton.enable = true;
            listButton.setVisible(!gudetamaDef.uncountable);
            listButton.enable = !UserDataWrapper.wantedPart.exists(gudetamaDef.id#2) && cooked;
            presentButton.setVisible(!gudetamaDef.uncountable);
            presentButton.enable = UserDataWrapper.gudetamaPart.hasGudetama(gudetamaDef.id#2,1);
            cookingButton.setVisible(!gudetamaDef.uncountable);
            updateCookingButton();
            Engine.hideLoading(GudetamaDetailDialog);
         });
         queue.startTask();
      }
      
      private function updateScene() : void
      {
         var _loc2_:GudetamaDef = gudetamas[currentIndex];
         var _loc1_:GudetamaData = UserDataWrapper.gudetamaPart.getGudetama(_loc2_.id#2);
         possessionText.text#2 = _loc1_.num.toString();
         presentButton.setVisible(!_loc2_.uncountable);
         presentButton.enable = UserDataWrapper.gudetamaPart.hasGudetama(_loc2_.id#2,1);
      }
      
      public function playSerifUI(param1:VoiceDef) : Boolean
      {
         if(serifUI.isPlaying())
         {
            return false;
         }
         serifUI.play(param1);
         return true;
      }
      
      private function triggeredGuni() : void
      {
         LocalMessageDialog.show(0,GameSetting.getUIText("gudetamaDetail.can.guni"));
      }
      
      override public function advanceTime(param1:Number) : void
      {
         super.advanceTime(param1);
         serifUI.advanceTime(param1);
      }
      
      override public function dispose() : void
      {
         quad = null;
         gudetamas = null;
         numberText = null;
         imgHappening = null;
         areaGroup = null;
         areaText = null;
         nameText = null;
         categoryText = null;
         rewardText = null;
         countText = null;
         possessionText = null;
         costText = null;
         descText = null;
         yetText = null;
         iconImage = null;
         raritySprite = null;
         rarityInvisibleText = null;
         buttonGroup = null;
         if(placeButton)
         {
            placeButton.dispose();
            placeButton = null;
         }
         if(shareButton)
         {
            shareButton.dispose();
            shareButton = null;
         }
         if(listButton)
         {
            listButton.dispose();
            listButton = null;
         }
         if(presentButton)
         {
            presentButton.dispose();
            presentButton = null;
         }
         if(leftButton)
         {
            leftButton.removeEventListener("triggered",triggeredLeftButton);
            leftButton = null;
         }
         if(rightButton)
         {
            rightButton.addEventListener("triggered",triggeredRightButton);
            rightButton = null;
         }
         if(btnGuni != null)
         {
            btnGuni.removeEventListener("triggered",triggeredGuni);
            btnGuni = null;
         }
         if(serifUI)
         {
            serifUI.dispose();
            serifUI = null;
         }
         for each(var _loc1_ in voiceButtonUIs)
         {
            _loc1_.dispose();
         }
         voiceButtonUIs.length = 0;
         voiceButtonUIs = null;
         swipeGesture.removeEventListener("gestureRecognized",gesture);
         swipeGesture.dispose();
         swipeGesture = null;
         super.dispose();
      }
   }
}

import gudetama.data.compati.VoiceDef;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.events.Event;

class VoiceButtonUI
{
    
   
   private var button:ContainerButton;
   
   private var text:ColorTextField;
   
   private var index:int;
   
   private var callback:Function;
   
   private var def:VoiceDef;
   
   private var defButtonColor:uint;
   
   private var defTextColor:uint;
   
   function VoiceButtonUI(param1:ContainerButton, param2:int, param3:VoiceDef, param4:Function)
   {
      super();
      this.button = param1;
      this.defButtonColor = param1.color;
      this.text = param1.getChildByName("text") as ColorTextField;
      this.defTextColor = text.color;
      this.button.setOffsetScale(-10,-10);
      this.button.setHitMarginWidth(0,15,140);
      this.index = param2;
      this.callback = param4;
      this.def = param3;
      param1.addEventListener("triggered",triggeredButton);
   }
   
   public function enabled(param1:Boolean, param2:VoiceDef) : void
   {
      enabledButton(param1);
      this.def = param2;
   }
   
   public function enabledButton(param1:Boolean) : void
   {
      button.enabled = param1;
      if(param1)
      {
         button.color = defButtonColor;
         text.color = defTextColor;
      }
      else
      {
         button.color = 9996414;
         text.color = 9996414;
      }
   }
   
   public function setVisible(param1:Boolean) : void
   {
      button.visible = param1;
   }
   
   private function triggeredButton(param1:Event) : void
   {
      callback(def);
   }
   
   public function dispose() : void
   {
      button.removeEventListener("triggered",triggeredButton);
      button = null;
   }
}

import gudetama.ui.UIBase;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;

class LowerButtonUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var buttonImage:Image;
   
   private var lockImage:Image;
   
   private var locked:Boolean;
   
   private var enabled:Boolean;
   
   function LowerButtonUI(param1:Sprite, param2:Function)
   {
      super(param1);
      this.callback = param2;
      param1.addEventListener("triggered",triggeredButton);
      buttonImage = param1.getChildByName("image") as Image;
      lockImage = param1.getChildByName("lock") as Image;
   }
   
   private function triggeredButton(param1:Event) : void
   {
      callback(locked,enabled);
   }
   
   public function set lock(param1:Boolean) : void
   {
      buttonImage.color = !!param1 ? 8421504 : 16777215;
      lockImage.visible = param1;
      locked = param1;
   }
   
   public function set enable(param1:Boolean) : void
   {
      if(locked)
      {
         return;
      }
      buttonImage.color = !!param1 ? 16777215 : 8421504;
      enabled = param1;
   }
   
   public function dispose() : void
   {
      displaySprite.removeEventListener("triggered",triggeredButton);
      buttonImage = null;
      lockImage = null;
   }
}
