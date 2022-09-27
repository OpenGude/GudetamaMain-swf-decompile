package gudetama.scene.friend
{
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.GudetamaDef;
   import gudetama.data.compati.RankingDef;
   import gudetama.data.compati.RuleDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.ui.LessMetalDialog;
   import gudetama.ui.LessMoneyDialog;
   import gudetama.ui.LocalMessageDialog;
   import gudetama.ui.VideoAdConfirmDialog;
   import gudetama.util.StringUtil;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class FriendPresentConfirmDialog extends BaseScene
   {
      
      public static const RECOVER_TYPE_GP:int = 0;
      
      public static const RECOVER_TYPE_VIDEO:int = 1;
      
      public static const RESULT_NEGATIVE:int = 0;
       
      
      private var gudetamaId:int;
      
      private var friendEncodeUid:int;
      
      private var deliverPoint:int;
      
      private var callback:Function;
      
      private var restVideo:int;
      
      private var restGp:int;
      
      private var restGpGlobal;
      
      private var iconImage:Image;
      
      private var texGudetama:Texture;
      
      private var numberText:ColorTextField;
      
      private var nameText:ColorTextField;
      
      private var numText:ColorTextField;
      
      private var btnEgg:ContainerButton;
      
      private var btnVideo:ContainerButton;
      
      private var btnGp:ContainerButton;
      
      private var closeButton:ContainerButton;
      
      public function FriendPresentConfirmDialog(param1:int, param2:int, param3:int, param4:Function)
      {
         super(2);
         this.gudetamaId = param1;
         this.friendEncodeUid = param2;
         this.deliverPoint = param3;
         this.callback = param4;
      }
      
      public static function show(param1:int, param2:int, param3:int, param4:Function) : void
      {
         Engine.showLoading(FriendPresentConfirmDialog);
         Engine.pushScene(new FriendPresentConfirmDialog(param1,param2,param3,param4),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"FriendPresentConfirmDialog",function(param1:Object):void
         {
            var layout:Object = param1;
            displaySprite = layout.object;
            var dialogSprite:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            iconImage = dialogSprite.getChildByName("icon") as Image;
            numberText = dialogSprite.getChildByName("number") as ColorTextField;
            nameText = dialogSprite.getChildByName("name") as ColorTextField;
            numText = dialogSprite.getChildByName("num") as ColorTextField;
            var spDeliver:Sprite = dialogSprite.getChildByName("spDeliver") as Sprite;
            var lblDeliver:ColorTextField = spDeliver.getChildByName("lblDeliver") as ColorTextField;
            var balloon:Image = spDeliver.getChildByName("balloon") as Image;
            if(deliverPoint > 0)
            {
               var rankingIds:Array = UserDataWrapper.eventPart.getRankingIds(true);
               if(rankingIds)
               {
                  TextureCollector.loadTexture("event" + (rankingIds[0] - 1) + "@friend_item",function(param1:Texture):void
                  {
                     balloon.texture = param1;
                  });
                  var rDef:RankingDef = GameSetting.getRanking(rankingIds[0]);
                  lblDeliver.color = rDef.pointTextColor;
               }
               lblDeliver.text#2 = GameSetting.getUIText("friendlyResult.value").replace("%1",deliverPoint);
            }
            else
            {
               spDeliver.visible = false;
            }
            btnEgg = dialogSprite.getChildByName("btnEgg") as ContainerButton;
            btnEgg.addEventListener("triggered",triggeredEgg);
            btnVideo = dialogSprite.getChildByName("btnVideo") as ContainerButton;
            btnVideo.addEventListener("triggered",triggeredVideo);
            btnGp = dialogSprite.getChildByName("btnGp") as ContainerButton;
            btnGp.addEventListener("triggered",triggeredGp);
            closeButton = dialogSprite.getChildByName("btnClose") as ContainerButton;
            closeButton.enableDrawCache();
            closeButton.addEventListener("triggered",triggeredCloseButton);
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         queue.addTask(function():void
         {
            TextureCollector.loadTextureRsrc(GudetamaUtil.getCollectionIconName(gudetamaId),function(param1:Texture):void
            {
               texGudetama = param1;
               queue.taskDone();
            });
         });
         queue.addTask(function():void
         {
            var _loc1_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(GENERAL_CHECK_GUDE_PRESENT,friendEncodeUid),function(param1:*):void
            {
               restGp = param1[0];
               restVideo = param1[1];
               restGpGlobal = param1[2];
               queue.taskDone();
            });
         });
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            setup();
         });
         queue.startTask(onProgress);
      }
      
      private function setup() : void
      {
         var _loc5_:* = null;
         var _loc6_:* = null;
         var _loc3_:GudetamaDef = GameSetting.getGudetama(gudetamaId);
         iconImage.texture = texGudetama;
         if(_loc3_.type != 1)
         {
            numberText.visible = false;
         }
         numberText.text#2 = StringUtil.format(GameSetting.getUIText("common.number"),StringUtil.decimalFormat(GameSetting.getUIText("common.number.format"),_loc3_.number));
         nameText.text#2 = _loc3_.getWrappedName();
         numText.text#2 = UserDataWrapper.gudetamaPart.getNumGudetama(gudetamaId).toString();
         var _loc4_:RuleDef = GameSetting.getRule();
         var _loc1_:ColorTextField = btnEgg.getChildByName("lblNum") as ColorTextField;
         _loc1_.text#2 = StringUtil.getNumStringCommas(_loc4_.friendPresentCost);
         var _loc2_:ColorTextField = btnVideo.getChildByName("lblRest") as ColorTextField;
         _loc2_.text#2 = GameSetting.getUIText("common.rest.count").replace("%1",Math.max(0,restVideo));
         if(_loc4_.friendPresentGp > 0)
         {
            (_loc5_ = btnGp.getChildByName("lblNum") as ColorTextField).text#2 = StringUtil.getNumStringCommas(_loc4_.friendPresentGp);
            _loc6_ = btnGp.getChildByName("lblRest") as ColorTextField;
            if(restGpGlobal == 0)
            {
               _loc6_.text#2 = GameSetting.getUIText("friendPresentConfirm.rest.global").replace("%1",Math.max(0,restGpGlobal));
            }
            else
            {
               _loc6_.text#2 = GameSetting.getUIText("friendPresentConfirm.rest").replace("%1",Math.max(0,restGp));
            }
         }
         else
         {
            btnGp.visible = false;
            btnEgg.x = btnVideo.x = btnGp.x;
            btnEgg.y = 440;
            btnVideo.y = btnGp.y;
         }
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(FriendPresentListDialog);
         setVisibleState(94);
         setBackButtonCallback(backButtonCallback);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(FriendPresentListDialog);
            Engine.hideLoading(FriendPresentConfirmDialog);
         });
      }
      
      private function triggeredEgg() : void
      {
         var cost:int = GameSetting.getRule().friendPresentCost;
         var less:int = cost - UserDataWrapper.wrapper.getMetal();
         if(less > 0)
         {
            LessMetalDialog.show(less,true);
            return;
         }
         LocalMessageDialog.show(1,GameSetting.getUIText("friendPresentConfirm.desc").replace("%1",cost),function(param1:int):void
         {
            if(param1 == 1)
            {
               return;
            }
            back(168);
         });
      }
      
      private function triggeredVideo() : void
      {
         if(restVideo <= 0)
         {
            showRecoverTimeMessage(-restVideo,1);
            return;
         }
         VideoAdConfirmDialog.show("start2",GameSetting.getUIText("videoAdConfirm.title"),GameSetting.getUIText("videoAdConfirm.friendPresent.desc"),GameSetting.getUIText("videoAdConfirm.friendPresent.caution"),function(param1:int):void
         {
            if(param1 == 1)
            {
               return;
            }
            back(221);
         });
      }
      
      private function triggeredGp() : void
      {
         if(restGp <= 0 || restGpGlobal == 0)
         {
            showRecoverTimeMessage(-restGp,0);
            return;
         }
         if(!UserDataWrapper.wrapper.isEnabledFriendPresentForGPWhileEvent())
         {
            LocalMessageDialog.show(0,GameSetting.getUIText("ranking.present.gp.maximum.desc"),null,GameSetting.getUIText("ranking.present.gp.maximum.title"));
            return;
         }
         var cost:int = GameSetting.getRule().friendPresentGp;
         var less:int = cost - UserDataWrapper.wrapper.getMoney();
         if(less > 0)
         {
            LessMoneyDialog.show(less);
            return;
         }
         if(restGpGlobal > 0)
         {
            LocalMessageDialog.show(1,StringUtil.format(GameSetting.getUIText("friendPresentConfirm.gp.global"),StringUtil.getNumStringCommas(cost),restGpGlobal),function(param1:int):void
            {
               if(param1 == 1)
               {
                  return;
               }
               back(241);
            });
         }
         else
         {
            LocalMessageDialog.show(1,GameSetting.getUIText("friendPresentConfirm.gp").replace("%1",StringUtil.getNumStringCommas(cost)),function(param1:int):void
            {
               if(param1 == 1)
               {
                  return;
               }
               back(241);
            });
         }
      }
      
      private function showRecoverTimeMessage(param1:int, param2:int) : void
      {
         var _loc3_:* = null;
         if(param2 == 0)
         {
            if(restGpGlobal == 0)
            {
               _loc3_ = GameSetting.getUIText("friendPresentConfirm.recover.global").replace("%1",GameSetting.getRule().friendPresentGpGlobalCountPerDay).replace("%2",Math.max(1,param1));
            }
            else
            {
               _loc3_ = GameSetting.getUIText("friendPresentConfirm.recover.friend").replace("%1",GameSetting.getRule().friendPresentGpCountPerDay).replace("%2",Math.max(1,param1));
            }
         }
         else if(param2 == 1)
         {
            _loc3_ = GameSetting.getUIText("friendPresentConfirm.recover.video").replace("%1",GameSetting.getRule().freeFriendPresentCountPerDay).replace("%2",Math.max(1,param1));
         }
         LocalMessageDialog.show(0,_loc3_);
      }
      
      override public function backButtonCallback() : void
      {
         back();
      }
      
      private function back(param1:int = 0) : void
      {
         var choose:int = param1;
         super.backButtonCallback();
         Engine.lockTouchInput(FriendPresentConfirmDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(FriendPresentConfirmDialog);
            Engine.popScene(scene);
            callback(choose);
         });
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         iconImage = null;
         texGudetama = null;
         numberText = null;
         nameText = null;
         numText = null;
         if(btnEgg != null)
         {
            btnEgg.removeEventListener("triggered",triggeredEgg);
            btnEgg = null;
         }
         if(btnVideo != null)
         {
            btnVideo.removeEventListener("triggered",triggeredVideo);
            btnVideo = null;
         }
         if(btnGp != null)
         {
            btnGp.removeEventListener("triggered",triggeredGp);
            btnGp = null;
         }
         if(closeButton)
         {
            closeButton.addEventListener("triggered",triggeredCloseButton);
            closeButton = null;
         }
         super.dispose();
      }
   }
}
