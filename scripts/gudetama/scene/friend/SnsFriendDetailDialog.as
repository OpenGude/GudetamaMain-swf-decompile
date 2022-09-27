package gudetama.scene.friend
{
   import gudetama.common.GudetamaUtil;
   import gudetama.data.DataStorage;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.UserProfileData;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.ui.LocalMessageDialog;
   import gudetama.util.StringUtil;
   import gudetama.util.TimeZoneUtil;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class SnsFriendDetailDialog extends BaseScene
   {
       
      
      private var prof:UserProfileData;
      
      private var snsType:int;
      
      private var snsDialog:SnsFriendListDialog;
      
      private var friendScene:FriendScene_Gudetama;
      
      private var imgAvatar:Image;
      
      private var texAvatar:Texture;
      
      private var imgSnsProf:Image;
      
      private var texSnsProf:Texture;
      
      private var imgSns:Image;
      
      private var texSns:Texture;
      
      private var btnApply:ContainerButton;
      
      private var btnCancel:ContainerButton;
      
      public function SnsFriendDetailDialog(param1:UserProfileData, param2:int, param3:FriendScene_Gudetama, param4:SnsFriendListDialog)
      {
         super(2);
         this.prof = param1;
         this.snsType = param2;
         this.friendScene = param3;
         this.snsDialog = param4;
      }
      
      public static function show(param1:UserProfileData, param2:int, param3:FriendScene_Gudetama, param4:SnsFriendListDialog) : void
      {
         Engine.pushScene(new SnsFriendDetailDialog(param1,param2,param3,param4),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         var isTwitter:Boolean = snsType == 0;
         Engine.setupLayoutForTask(queue,"SnsFriendDetailDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc6_:Sprite;
            imgAvatar = (_loc6_ = displaySprite.getChildByName("dialogSprite") as Sprite).getChildByName("imgAvatar") as Image;
            var _loc3_:Sprite = _loc6_.getChildByName("spLv") as Sprite;
            var _loc2_:ColorTextField = _loc3_.getChildByName("level") as ColorTextField;
            _loc2_.text#2 = prof.playerRank.toString();
            var _loc4_:ColorTextField;
            (_loc4_ = _loc6_.getChildByName("name") as ColorTextField).text#2 = prof.playerName;
            imgSnsProf = _loc6_.getChildByName("imgSnsProf") as Image;
            var _loc5_:ColorTextField = _loc6_.getChildByName("snsName") as ColorTextField;
            imgSns = _loc6_.getChildByName("imgSns") as Image;
            var _loc7_:ColorTextField = _loc6_.getChildByName("snsDesc") as ColorTextField;
            if(isTwitter)
            {
               _loc5_.text#2 = DataStorage.getLocalData().getTwitterName(prof.snsId);
               _loc7_.text#2 = GameSetting.getUIText("%sns.link.twitter.friend");
            }
            else
            {
               _loc5_.text#2 = DataStorage.getLocalData().getFacebookName(prof.snsId);
               _loc7_.text#2 = GameSetting.getUIText("%sns.link.facebook.friend");
            }
            btnApply = _loc6_.getChildByName("btnApply") as ContainerButton;
            btnApply.addEventListener("triggered",triggeredApply);
            btnCancel = _loc6_.getChildByName("btnCancel") as ContainerButton;
            btnCancel.addEventListener("triggered",triggeredCloseButton);
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         if(isTwitter)
         {
            TextureCollector.loadTextureForTask(queue,"friend1@btn_tw_off",function(param1:Texture):void
            {
               texSns = param1;
            });
         }
         TextureCollector.loadTextureForTask(queue,"avatar-" + GameSetting.getAvatar(prof.avatar).rsrc,function(param1:Texture):void
         {
            texAvatar = param1;
         });
         if(prof.snsProfileImage != null)
         {
            queue.addTask(function():void
            {
               GudetamaUtil.loadByteArray2Texture(prof.snsProfileImage,function(param1:Texture):void
               {
                  texSnsProf = param1;
                  queue.taskDone();
               });
            });
         }
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            if(isTwitter)
            {
               imgSns.texture = texSns;
            }
            imgAvatar.texture = texAvatar;
            if(texSnsProf != null)
            {
               imgSnsProf.texture = texSnsProf;
            }
         });
         queue.startTask(onProgress);
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(SnsFriendDetailDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(SnsFriendDetailDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(SnsFriendDetailDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(SnsFriendDetailDialog);
            Engine.popScene(scene);
         });
      }
      
      private function triggeredApply(param1:Event) : void
      {
         var event:Event = param1;
         if(friendScene is FriendScene_Gudetama)
         {
            friendScene.processRecommended(3,prof,function(param1:int):void
            {
               applyCallback(param1);
            });
         }
         else
         {
            requestFollow(prof);
         }
      }
      
      private function requestFollow(param1:UserProfileData) : void
      {
         var prof:UserProfileData = param1;
         Engine.showLoading(SnsFriendDetailDialog);
         var _loc2_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(162,prof.encodedUid),function(param1:Array):void
         {
            var response:Array = param1;
            Engine.hideLoading(SnsFriendDetailDialog);
            var result:int = response[0];
            if(result >= 0)
            {
               if(result == 0)
               {
                  prof.followRequestSecs = TimeZoneUtil.epochMillisToOffsetSecs();
                  prof.followState = 1;
                  UserDataWrapper.friendPart.addFollow(prof);
               }
               else
               {
                  prof.followState = 3;
                  UserDataWrapper.friendPart.addFriend(prof);
               }
               LocalMessageDialog.show(0,StringUtil.format(GameSetting.getUIText(result == 0 ? "friend.message.follow.apply.desc" : "friend.message.follower.approve.desc"),prof.playerName),function():void
               {
                  applyCallback(result);
               },GameSetting.getUIText("friend.message.follow.apply.title"));
            }
            else
            {
               LocalMessageDialog.show(0,StringUtil.format(GameSetting.getUIText("friend.warning." + Math.abs(result)),prof.playerName),function():void
               {
                  applyCallback(result);
               });
            }
         });
      }
      
      private function applyCallback(param1:int) : void
      {
         if(param1 >= 0 || param1 == -2)
         {
            snsDialog.toggleSns(null);
            backButtonCallback();
         }
         else
         {
            backButtonCallback();
         }
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         imgAvatar = null;
         texAvatar = null;
         imgSnsProf = null;
         texSnsProf = null;
         imgSns = null;
         texSns = null;
         btnApply.removeEventListener("triggered",triggeredApply);
         btnApply = null;
         btnCancel.removeEventListener("triggered",triggeredCloseButton);
         btnCancel = null;
         super.dispose();
      }
   }
}
