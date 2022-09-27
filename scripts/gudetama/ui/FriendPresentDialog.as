package gudetama.ui
{
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.GudetamaDef;
   import gudetama.data.compati.SystemMailData;
   import gudetama.data.compati.UserProfileData;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.SoundManager;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.scene.friend.FriendRoomScene;
   import gudetama.scene.home.HomeScene;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class FriendPresentDialog extends BaseScene
   {
       
      
      private var systemMail:SystemMailData;
      
      private var profile:UserProfileData;
      
      private var callback:Function;
      
      private var titleText:ColorTextField;
      
      private var itemIconImage:Image;
      
      private var itemNumText:ColorTextField;
      
      private var preText:ColorTextField;
      
      private var profileGroup:Sprite;
      
      private var avatarImage:Image;
      
      private var imgSns:Image;
      
      private var nameText:ColorTextField;
      
      private var postText:ColorTextField;
      
      private var descText:ColorTextField;
      
      private var roomButton:ContainerButton;
      
      private var cancelButton:ContainerButton;
      
      private var closeButton:ContainerButton;
      
      private var loadCount:int;
      
      public function FriendPresentDialog(param1:SystemMailData, param2:UserProfileData, param3:Function)
      {
         super(2);
         this.systemMail = param1;
         this.profile = param2;
         this.callback = param3;
      }
      
      public static function show(param1:SystemMailData, param2:UserProfileData, param3:Function) : void
      {
         Engine.pushScene(new FriendPresentDialog(param1,param2,param3),0,false);
      }
      
      private function isGudetama() : Boolean
      {
         return systemMail.item.kind == 7;
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,!!isGudetama() ? "FriendPresentGudetamaDialog" : "FriendPresentMoneyDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            titleText = _loc2_.getChildByName("title") as ColorTextField;
            itemIconImage = _loc2_.getChildByName("icon") as Image;
            itemNumText = _loc2_.getChildByName("num") as ColorTextField;
            preText = _loc2_.getChildByName("pre") as ColorTextField;
            profileGroup = _loc2_.getChildByName("profileGroup") as Sprite;
            avatarImage = profileGroup.getChildByName("avatar") as Image;
            imgSns = profileGroup.getChildByName("imgSns") as Image;
            imgSns.visible = false;
            nameText = profileGroup.getChildByName("name") as ColorTextField;
            postText = _loc2_.getChildByName("post") as ColorTextField;
            descText = _loc2_.getChildByName("desc") as ColorTextField;
            roomButton = _loc2_.getChildByName("btn0") as ContainerButton;
            roomButton.addEventListener("triggered",triggeredRoomButton);
            cancelButton = _loc2_.getChildByName("btn1") as ContainerButton;
            cancelButton.addEventListener("triggered",triggeredCancelButton);
            closeButton = _loc2_.getChildByName("btn_back") as ContainerButton;
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
         titleText.text#2 = GameSetting.getUIText("friendPresent.title");
         var imageName:String = GudetamaUtil.getItemImageName(systemMail.item.kind,systemMail.item.id#2);
         if(imageName.length > 0)
         {
            queue.addTask(function():void
            {
               TextureCollector.loadTextureRsrc(imageName,function(param1:Texture):void
               {
                  itemIconImage.texture = param1;
                  queue.taskDone();
               });
            });
         }
         if(systemMail.item.kind == 7)
         {
            var gudetamaDef:GudetamaDef = GameSetting.getGudetama(systemMail.item.id#2);
            var isEventGudetama:Boolean = gudetamaDef.type != 1;
            if(isEventGudetama)
            {
               itemNumText.text#2 = gudetamaDef.name#2;
            }
            else
            {
               itemNumText.text#2 = StringUtil.format(GameSetting.getUIText("friendPresent.num.gudetama"),gudetamaDef.number,gudetamaDef.name#2);
            }
         }
         else
         {
            itemNumText.text#2 = GudetamaUtil.getItemParamNameAndNum(systemMail.item);
         }
         var splited:Array = GameSetting.getUIText("friendPresent.prefix").split("%1");
         var pre:String = splited[0];
         var post:String = splited[1];
         preText.width = displaySprite.width;
         preText.text#2 = pre;
         preText.width = preText.textBounds.width;
         if(preText.width > 0)
         {
            preText.width += 10;
         }
         profileGroup.x = preText.x + preText.width;
         var existsInFriend:Boolean = false;
         if(!profile)
         {
            profile = UserDataWrapper.friendPart.getFriendProfile(systemMail.senderEncodedUid);
            existsInFriend = profile;
         }
         if(profile)
         {
            if(profile.snsProfileImage != null)
            {
               queue.addTask(function():void
               {
                  GudetamaUtil.loadByteArray2Texture(profile.snsProfileImage,function(param1:Texture):void
                  {
                     avatarImage.texture = param1;
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
                     avatarImage.texture = param1;
                     queue.taskDone();
                  });
               });
            }
            nameText.text#2 = profile.playerName;
            if(existsInFriend)
            {
               roomButton.visible = true;
               cancelButton.visible = true;
               closeButton.visible = false;
            }
            else
            {
               roomButton.visible = false;
               cancelButton.visible = false;
               closeButton.visible = true;
            }
         }
         else
         {
            nameText.text#2 = "";
            roomButton.visible = false;
            cancelButton.visible = false;
            closeButton.visible = true;
         }
         postText.x = profileGroup.x + profileGroup.width;
         postText.width = displaySprite.width;
         postText.text#2 = post;
         postText.width = postText.textBounds.width;
         descText.text#2 = GameSetting.getUIText("friendPresent.desc." + (!!isGudetama() ? "gudetama" : "money"));
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(MailPresentDialog);
         setVisibleState(94);
         setBackButtonCallback(backButtonCallback);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         SoundManager.playEffect("MaxComboSuccess");
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(MailPresentDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(MailPresentDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(MailPresentDialog);
            Engine.popScene(scene);
            if(callback)
            {
               callback();
            }
         });
      }
      
      private function triggeredRoomButton(param1:Event) : void
      {
         var event:Event = param1;
         var profile:UserProfileData = UserDataWrapper.friendPart.getFriendProfile(systemMail.senderEncodedUid);
         ResidentMenuUI_Gudetama.getInstance().sendChangeState(63,function():void
         {
            Engine.switchScene(new FriendRoomScene(profile,function():void
            {
               ResidentMenuUI_Gudetama.getInstance().sendChangeState(60,function():void
               {
                  Engine.switchScene(new HomeScene());
               });
            }));
         });
      }
      
      private function triggeredCancelButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         systemMail = null;
         titleText = null;
         itemIconImage = null;
         itemNumText = null;
         preText = null;
         profileGroup = null;
         avatarImage = null;
         imgSns = null;
         nameText = null;
         postText = null;
         descText = null;
         if(roomButton)
         {
            roomButton.removeEventListener("triggered",triggeredRoomButton);
            roomButton = null;
         }
         if(cancelButton)
         {
            cancelButton.removeEventListener("triggered",triggeredCancelButton);
            cancelButton = null;
         }
         if(closeButton)
         {
            closeButton.removeEventListener("triggered",triggeredCloseButton);
            closeButton = null;
         }
         super.dispose();
      }
   }
}
