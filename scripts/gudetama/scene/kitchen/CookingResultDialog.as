package gudetama.scene.kitchen
{
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.GetItemResult;
   import gudetama.data.compati.GudetamaDef;
   import gudetama.data.compati.GuideTalkDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.Logger;
   import gudetama.engine.SoundManager;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.scene.home.HomeScene;
   import gudetama.scene.shop.ShopScene_Gudetama;
   import gudetama.ui.AcquiredItemDialog;
   import gudetama.ui.GudetamaShareDialog;
   import gudetama.ui.ItemGetDialog;
   import gudetama.ui.LevelUpDialog;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.util.StringUtil;
   import muku.display.ImageButton;
   import muku.display.SpineModel;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   import starling.textures.Texture;
   
   public class CookingResultDialog extends BaseScene
   {
      
      private static const ROTATE_TIME:Number = 10;
       
      
      private var gudetamaId:int;
      
      private var isNew:Boolean;
      
      private var result:int;
      
      private var reward:int;
      
      private var extraGudetama:int;
      
      private var extraRankingPoint:int;
      
      private var lastLevel:int;
      
      private var failBonusItems:Array;
      
      private var failBonusParams:Array;
      
      private var bonusResult:GetItemResult;
      
      private var callback:Function;
      
      private var quad:Quad;
      
      private var moneyText:ColorTextField;
      
      private var rotateImage:Image;
      
      private var iconImage:Image;
      
      private var newImage:Image;
      
      private var missSpineModel:SpineModel;
      
      private var shareButton:ImageButton;
      
      private var nameText:ColorTextField;
      
      private var descText:ColorTextField;
      
      private var extraGudetamaIcon:Image;
      
      private var extraGudetamaNum:ColorTextField;
      
      private var extraPointIcon:Image;
      
      private var extraPointNum:ColorTextField;
      
      private var passedTime:Number = 0;
      
      public function CookingResultDialog(param1:int, param2:Boolean, param3:int, param4:int, param5:int, param6:int, param7:int, param8:GetItemResult, param9:Array, param10:Array, param11:Function)
      {
         super(2);
         this.gudetamaId = param1;
         this.isNew = param2;
         this.result = param3;
         this.reward = param4;
         this.extraGudetama = param5;
         this.extraRankingPoint = param6;
         this.lastLevel = param7;
         this.bonusResult = param8;
         this.failBonusItems = param9;
         this.failBonusParams = param10;
         this.callback = param11;
         addEventListener("refreshed_scene_container",refreshedSceneContainer);
      }
      
      public static function show(param1:int, param2:Boolean, param3:int, param4:int, param5:int, param6:int, param7:int, param8:GetItemResult, param9:Array, param10:Array, param11:Function) : void
      {
         Engine.pushScene(new CookingResultDialog(param1,param2,param3,param4,param5,param6,param7,param8,param9,param10,param11),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"CookingResultDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            quad = displaySprite.getChildByName("quad") as Quad;
            quad.addEventListener("touch",touchQuad);
            var _loc3_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            moneyText = _loc3_.getChildByName("money") as ColorTextField;
            rotateImage = _loc3_.getChildByName("rotate") as Image;
            iconImage = _loc3_.getChildByName("icon") as Image;
            newImage = _loc3_.getChildByName("new") as Image;
            missSpineModel = _loc3_.getChildByName("missSpineModel") as SpineModel;
            shareButton = _loc3_.getChildByName("btn_share") as ImageButton;
            shareButton.addEventListener("triggered",triggeredShareBtn);
            nameText = _loc3_.getChildByName("name") as ColorTextField;
            descText = _loc3_.getChildByName("desc") as ColorTextField;
            var _loc2_:Sprite = _loc3_.getChildByName("extraGudetamaGroup") as Sprite;
            extraGudetamaIcon = _loc2_.getChildByName("icon") as Image;
            extraGudetamaNum = _loc2_.getChildByName("num") as ColorTextField;
            var _loc4_:Sprite;
            extraPointIcon = (_loc4_ = _loc3_.getChildByName("extraPointGroup") as Sprite).getChildByName("icon") as Image;
            extraPointNum = _loc4_.getChildByName("num") as ColorTextField;
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
         queue.addTask(function():void
         {
            TextureCollector.loadTextureRsrc("gudetama-" + gudetamaDef.rsrc + "-icon",function(param1:Texture):void
            {
               iconImage.texture = param1;
               queue.taskDone();
            });
         });
         moneyText.text#2 = StringUtil.getNumStringCommas(reward);
         newImage.visible = isNew;
         nameText.text#2 = gudetamaDef.name#2;
         descText.text#2 = gudetamaDef.desc;
         if(result == 2)
         {
            rotateImage.visible = false;
            missSpineModel.show();
            missSpineModel.changeAnimation("start_loop");
            SoundManager.playEffect("failed_gudetama");
         }
         else
         {
            rotateImage.visible = true;
            missSpineModel.visible = false;
            if(result == 1)
            {
               if(gudetamaDef.id#2 <= 5)
               {
                  SoundManager.playEffect("failed_gudetama");
               }
               else
               {
                  SoundManager.playEffect("discover");
               }
            }
            else
            {
               SoundManager.playEffect("discover");
            }
         }
         var doneTutorial:Boolean = UserDataWrapper.wrapper.isCompletedTutorial();
         if(!doneTutorial)
         {
            shareButton.visible = false;
         }
         var rankingIds:Array = UserDataWrapper.eventPart.getRankingIds(true);
         if(rankingIds && rankingIds.length > 0)
         {
            var rankingId:int = rankingIds[0];
         }
         if(extraGudetama > 0 && extraRankingPoint > 0)
         {
            extraGudetamaNum.text#2 = StringUtil.format(GameSetting.getUIText("add.mark"),extraGudetama);
            extraPointNum.text#2 = StringUtil.format(GameSetting.getUIText("add.mark"),extraRankingPoint);
            queue.addTask(function():void
            {
               TextureCollector.loadTextureRsrc(GudetamaUtil.getCollectionIconName(gudetamaDef.id#2),function(param1:Texture):void
               {
                  extraGudetamaIcon.texture = param1;
                  queue.taskDone();
               });
            });
            if(rankingId > 0)
            {
               queue.addTask(function():void
               {
                  TextureCollector.loadTexture("event" + rankingId + "@item",function(param1:Texture):void
                  {
                     extraPointIcon.texture = param1;
                     queue.taskDone();
                  });
               });
            }
            var pos:int = 3;
         }
         else if(extraGudetama > 0 && extraRankingPoint <= 0)
         {
            extraGudetamaNum.text#2 = StringUtil.format(GameSetting.getUIText("add.mark"),extraGudetama);
            queue.addTask(function():void
            {
               TextureCollector.loadTextureRsrc(GudetamaUtil.getCollectionIconName(gudetamaDef.id#2),function(param1:Texture):void
               {
                  extraGudetamaIcon.texture = param1;
                  queue.taskDone();
               });
            });
            pos = 1;
         }
         else if(extraGudetama <= 0 && extraRankingPoint > 0)
         {
            extraPointNum.text#2 = StringUtil.format(GameSetting.getUIText("add.mark"),extraRankingPoint);
            if(rankingId > 0)
            {
               queue.addTask(function():void
               {
                  TextureCollector.loadTexture("event" + (rankingId - 1) + "@item",function(param1:Texture):void
                  {
                     extraPointIcon.texture = param1;
                     queue.taskDone();
                  });
               });
            }
            pos = 2;
         }
         else
         {
            pos = 0;
         }
         queue.addTask(function():void
         {
            TweenAnimator.startItself(displaySprite,"pos" + pos,false,function():void
            {
               queue.taskDone();
            });
         });
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(CookingResultDialog);
         setBackButtonCallback(!!UserDataWrapper.wrapper.isCompletedTutorial() ? backButtonCallback : null);
         setVisibleState(68);
      }
      
      override public function getSceneFrameRate() : Number
      {
         return 60;
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(CookingResultDialog);
            TweenAnimator.startItself(iconImage,"idle");
            processTutorial();
         });
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
      
      override public function advanceTime(param1:Number) : void
      {
         super.advanceTime(param1);
         passedTime += param1;
         if(rotateImage)
         {
            rotateImage.rotation = 2 * 3.141592653589793 * passedTime / 10;
         }
      }
      
      override public function backButtonCallback() : void
      {
         showLevelUpDialog(lastLevel,function():void
         {
            showAcquiredItemDialog(failBonusItems,failBonusParams,function():void
            {
               showCookingPlaceConfirmDialog(gudetamaId,function():void
               {
                  showCookBonus(back);
               });
            });
         });
      }
      
      private function showLevelUpDialog(param1:int, param2:Function = null) : void
      {
         if(UserDataWrapper.wrapper.getRank() > param1)
         {
            LevelUpDialog.show(param1,param2);
         }
         else if(param2)
         {
            param2();
         }
      }
      
      private function showAcquiredItemDialog(param1:Array, param2:Array, param3:Function = null) : void
      {
         if(param1)
         {
            AcquiredItemDialog.show(param1,param2,param3,78);
         }
         else if(param3)
         {
            param3();
         }
      }
      
      private function showCookingPlaceConfirmDialog(param1:int, param2:Function = null) : void
      {
         var gudetamaId:int = param1;
         var callback:Function = param2;
         CookingPlaceConfirmDialog.show(function(param1:int):void
         {
            var choose:int = param1;
            if(choose == 0)
            {
               Engine.showLoading(CookingResultDialog);
               var _loc2_:* = HttpConnector;
               if(gudetama.net.HttpConnector.mainConnector == null)
               {
                  gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
               }
               gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(COOKING_PLACE),function(param1:Array):void
               {
                  Engine.hideLoading(CookingResultDialog);
                  UserDataWrapper.wrapper.placeGudetama(gudetamaId);
                  UserDataWrapper.wrapper.setHomeScrollPosition(0);
                  if(!UserDataWrapper.wrapper.isCompletedTutorial())
                  {
                     backHomeInTutorial();
                  }
                  else if(callback)
                  {
                     callback();
                  }
               });
            }
            else if(!UserDataWrapper.wrapper.isCompletedTutorial())
            {
               backHomeInTutorial();
            }
            else if(callback)
            {
               callback();
            }
         });
      }
      
      private function showCookBonus(param1:Function) : void
      {
         var callback:Function = param1;
         if(!bonusResult)
         {
            if(callback)
            {
               callback();
            }
            return;
         }
         ItemGetDialog.show(bonusResult,function():void
         {
            var _loc1_:UserDataWrapper = UserDataWrapper.wrapper;
            _loc1_.showCupGachaResults(_loc1_.getPlacedGudetamaId(),callback);
         },null,GameSetting.getUIText("cook.bonus.title"));
      }
      
      private function back() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(CookingResultDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(CookingResultDialog);
            if(!UserDataWrapper.wrapper.isCompletedTutorial())
            {
               backHomeInTutorial();
            }
            else
            {
               Engine.popScene(scene);
            }
            callback();
         });
      }
      
      private function backHomeInTutorial() : void
      {
         var tutorialProgress:int = UserDataWrapper.wrapper.getTutorialProgress();
         var _loc2_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(PACKET_CHECK_TUTORIAL_GUIDE,tutorialProgress),function(param1:GuideTalkDef):void
         {
            var response:GuideTalkDef = param1;
            ResidentMenuUI_Gudetama.getInstance().sendChangeState(60,function():void
            {
               Engine.switchScene(new HomeScene());
            });
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
      
      private function triggeredShareBtn(param1:Event) : void
      {
         GudetamaShareDialog.show([gudetamaId]);
      }
      
      private function touchQuad(param1:TouchEvent) : void
      {
         var _loc2_:Touch = param1.getTouch(quad);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_.phase == "ended")
         {
            quad.removeEventListener("touch",touchQuad);
            backButtonCallback();
         }
      }
      
      private function refreshedSceneContainer(param1:Event) : void
      {
      }
      
      override public function dispose() : void
      {
         removeEventListener("refreshed_scene_container",refreshedSceneContainer);
         if(quad)
         {
            quad.removeEventListener("touch",touchQuad);
            quad = null;
         }
         moneyText = null;
         rotateImage = null;
         iconImage = null;
         newImage = null;
         missSpineModel = null;
         shareButton = null;
         nameText = null;
         descText = null;
         super.dispose();
      }
   }
}
