package gudetama.ui
{
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.CupGachaResult;
   import gudetama.data.compati.GetItemResult;
   import gudetama.data.compati.ItemParam;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.SoundManager;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.scene.home.HomeScene;
   import gudetama.scene.kitchen.CookingPlaceConfirmDialog;
   import muku.display.ContainerButton;
   import muku.display.SimpleImageButton;
   import muku.display.SpineModel;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.textures.Texture;
   
   public class CupGachaResultDialog extends BaseScene
   {
       
      
      private var animePanel:CupGachaAnimePanel;
      
      private var cupGachaResult:CupGachaResult;
      
      private var placeGudeId:int;
      
      private var callback:Function;
      
      private var imgRotate:Image;
      
      private var imgIcon:Image;
      
      private var spineSmoke:SpineModel;
      
      private var btnShare:SimpleImageButton;
      
      private var lblName:ColorTextField;
      
      private var lblDesc:ColorTextField;
      
      private var btnOk:ContainerButton;
      
      private var lblOk:ColorTextField;
      
      private var passedTime:Number = 0;
      
      public function CupGachaResultDialog(param1:CupGachaAnimePanel, param2:CupGachaResult, param3:int, param4:Function)
      {
         super(2);
         this.animePanel = param1;
         this.cupGachaResult = param2;
         this.placeGudeId = param3;
         this.callback = param4;
      }
      
      public static function show(param1:CupGachaAnimePanel, param2:CupGachaResult, param3:int, param4:Function) : void
      {
         Engine.showLoading(CupGachaResultDialog);
         Engine.pushScene(new CupGachaResultDialog(param1,param2,param3,param4),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"CupGachaResultDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            imgRotate = _loc2_.getChildByName("imgRotate") as Image;
            imgIcon = _loc2_.getChildByName("icon") as Image;
            spineSmoke = _loc2_.getChildByName("spineSmoke") as SpineModel;
            spineSmoke.visible = false;
            btnShare = _loc2_.getChildByName("btnShare") as SimpleImageButton;
            btnShare.addEventListener("triggered",triggeredShare);
            lblName = _loc2_.getChildByName("lblName") as ColorTextField;
            lblDesc = _loc2_.getChildByName("lblDesc") as ColorTextField;
            btnOk = _loc2_.getChildByName("btnOk") as ContainerButton;
            btnOk.addEventListener("triggered",backButtonCallback);
            lblOk = btnOk.getChildByName("text") as ColorTextField;
            displaySprite.visible = false;
            addChild(displaySprite);
            queue.addTask(procAfterLayoutLoad);
         });
         queue.startTask(onProgress);
      }
      
      private function procAfterLayoutLoad() : void
      {
         var result:GetItemResult = getCurrentResult();
         var item:ItemParam = result.item;
         var imageName:String = GudetamaUtil.getItemImageName(item.kind,item.id#2);
         TextureCollector.loadTextureForTask(queue,imageName,function(param1:Texture):void
         {
            imgIcon.texture = param1;
         });
         btnShare.visible = item.kind == 7;
         lblName.text#2 = GudetamaUtil.getItemParamName(item);
         lblDesc.text#2 = GudetamaUtil.getItemDesc(item.kind,item.id#2);
         if(result.toMail)
         {
            lblDesc.text#2 += "\n\n" + GameSetting.getUIText("common.tomail");
         }
         if(cupGachaResult.results.length == 1)
         {
            lblOk.text#2 = GameSetting.getInitUIText("%dialog.button.ok");
         }
         else
         {
            lblOk.text#2 = GameSetting.getUIText("%ranking.next.reward");
         }
         queue.taskDone();
      }
      
      private function getCurrentResult() : GetItemResult
      {
         return cupGachaResult.results[0];
      }
      
      private function triggeredShare() : void
      {
         GudetamaShareDialog.show([getCurrentResult().item.id#2]);
      }
      
      override public function advanceTime(param1:Number) : void
      {
         super.advanceTime(param1);
         passedTime += param1;
         imgRotate.rotation = 2 * 3.141592653589793 * passedTime / 10;
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(CupGachaResultDialog);
         setVisibleState(78);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         openAnime();
      }
      
      private function openAnime() : void
      {
         Engine.hideLoading(CupGachaResultDialog);
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(CupGachaResultDialog);
            SoundManager.playEffect("discover");
            setBackButtonCallback(backButtonCallback);
            var _loc1_:int = 27;
            if(UserDataWrapper.wrapper.isCanStartNoticeFlag(_loc1_))
            {
               resumeNoticeTutorial(_loc1_);
            }
         });
      }
      
      override public function backButtonCallback() : void
      {
         if(Engine.getGuideTalkPanel() != null)
         {
            return;
         }
         setBackButtonCallback(null);
         var result:GetItemResult = getCurrentResult();
         if(result.toMail)
         {
            checkNext();
            return;
         }
         ConvertDialog.show([result.item],[result.param],function():void
         {
            var item:ItemParam = result.item;
            var func:Function = function():void
            {
               checkPrizeIsGudetama(item,checkNext);
            };
            var udWrapper:UserDataWrapper = UserDataWrapper.wrapper;
            var rank:int = udWrapper.getRank();
            udWrapper.addItem(result.item,result.param);
            if(rank < udWrapper.getRank())
            {
               LevelUpDialog.show(rank,func);
               ResidentMenuUI_Gudetama.getInstance().updateUserInfo();
               return;
            }
            func();
         });
      }
      
      private function checkPrizeIsGudetama(param1:ItemParam, param2:Function) : void
      {
         var item:ItemParam = param1;
         var callback:Function = param2;
         if(item.kind != 7)
         {
            callback();
            return;
         }
         var gudeId:int = item.id#2;
         if(UserDataWrapper.wrapper.getPlacedGudetamaId() == gudeId)
         {
            callback();
            return;
         }
         CookingPlaceConfirmDialog.show(function(param1:int):void
         {
            var choose:int = param1;
            if(choose == 1)
            {
               callback();
               return;
            }
            Engine.showLoading(checkPrizeIsGudetama);
            var _loc2_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(1,gudeId),function(param1:*):void
            {
               Engine.hideLoading(checkPrizeIsGudetama);
               UserDataWrapper.wrapper.placeGudetama(gudeId);
               UserDataWrapper.wrapper.setHomeScrollPosition(0);
               callback();
            });
         });
      }
      
      private function checkNext() : void
      {
         cupGachaResult.results.shift();
         if(cupGachaResult.results.length == 0)
         {
            var newPlaceId:int = UserDataWrapper.wrapper.getPlacedGudetamaId();
            if(placeGudeId > 0 && placeGudeId != newPlaceId)
            {
               if(ResidentMenuUI_Gudetama.isHomeState())
               {
                  var home:HomeScene = HomeScene(Engine.getSceneFromStack(HomeScene));
                  home.waitChangeGudetama(newPlaceId,procClose);
                  return;
               }
            }
            procClose();
            return;
         }
         Engine.showLoading(CupGachaResultDialog);
         Engine.lockTouchInput(CupGachaResultDialog);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            queue.addTask(procAfterLayoutLoad);
            queue.registerOnProgress(function(param1:Number):void
            {
               if(param1 < 1)
               {
                  return;
               }
               openAnime();
            });
         });
      }
      
      private function procClose() : void
      {
         animePanel.procClose(false);
         super.backButtonCallback();
         Engine.lockTouchInput(CupGachaResultDialog);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(CupGachaResultDialog);
            Engine.popScene(scene);
            if(callback != null)
            {
               callback();
            }
         });
      }
      
      override public function dispose() : void
      {
         btnOk.removeEventListener("triggered",backButtonCallback);
         btnOk = null;
         btnShare.removeEventListener("triggered",triggeredShare);
         btnShare = null;
         super.dispose();
      }
   }
}
