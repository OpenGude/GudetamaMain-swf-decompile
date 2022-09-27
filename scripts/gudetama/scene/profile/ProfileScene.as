package gudetama.scene.profile
{
   import feathers.controls.IScrollBar;
   import feathers.controls.List;
   import feathers.controls.ScrollBar;
   import feathers.controls.renderers.IListItemRenderer;
   import feathers.data.ListCollection;
   import feathers.layout.FlowLayout;
   import flash.desktop.Clipboard;
   import gudetama.common.GudetamaUtil;
   import gudetama.data.DataStorage;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.GudetamaDef;
   import gudetama.data.compati.UserProfileData;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.scene.friend.FriendDetailDialog;
   import gudetama.scene.friend.FriendScene_Gudetama;
   import gudetama.scene.home.HomeScene;
   import gudetama.ui.InventoryScene;
   import gudetama.ui.LocalMessageDialog;
   import gudetama.ui.PresentLogListItemRenderer;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.ui.WantedListDialog;
   import gudetama.ui.WantedShareDialog;
   import gudetama.util.SpriteExtractor;
   import gudetama.util.StringUtil;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   import starling.textures.Texture;
   
   public class ProfileScene extends BaseScene
   {
       
      
      private var levelText:ColorTextField;
      
      private var areaText:ColorTextField;
      
      private var wantGudetamaButtons:Vector.<WantGudetamaButton>;
      
      private var shareButton:ContainerButton;
      
      private var list:List;
      
      private var topExtractor:SpriteExtractor;
      
      private var itemExtractor:SpriteExtractor;
      
      private var moreExtractor:SpriteExtractor;
      
      private var avatarButton:ContainerButton;
      
      private var imgSns:Image;
      
      private var nameInputButton:ContainerButton;
      
      private var nameText:ColorTextField;
      
      private var commentButton:ContainerButton;
      
      private var commentText:ColorTextField;
      
      private var copyToClipboardQuad:Quad;
      
      private var idText:ColorTextField;
      
      private var friendButton:ContainerButton;
      
      private var listEmptyText:ColorTextField;
      
      protected var collection:ListCollection;
      
      public function ProfileScene()
      {
         wantGudetamaButtons = new Vector.<WantGudetamaButton>();
         collection = new ListCollection();
         super(0);
         addEventListener("refreshed_scene_container",refreshedSceneContainer);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"ProfileLayout",function(param1:Object):void
         {
            var layout:Object = param1;
            displaySprite = layout.object;
            var dialogSprite:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            levelText = dialogSprite.getChildByName("level") as ColorTextField;
            areaText = dialogSprite.getChildByName("area") as ColorTextField;
            var inventoryBtn:ContainerButton = dialogSprite.getChildByName("inventoryButton") as ContainerButton;
            inventoryBtn.addEventListener("triggered",triggeredInventoryButton);
            avatarButton = dialogSprite.getChildByName("avatarButton") as ContainerButton;
            avatarButton.addEventListener("triggered",triggeredAvatarButton);
            imgSns = avatarButton.getChildByName("imgSns") as Image;
            imgSns.visible = false;
            if(UserDataWrapper.wrapper.isExtraAvatar())
            {
               var snsType:int = UserDataWrapper.wrapper.getCurrentExtraAvatar();
               if(DataStorage.getLocalData().getSnsImageTexture(snsType))
               {
                  avatarButton.background = DataStorage.getLocalData().getSnsImageTexture(snsType);
                  TextureCollector.loadSnsImage(snsType,queue,loadedSnsImage);
               }
            }
            else
            {
               queue.addTask(function():void
               {
                  TextureCollector.loadTextureRsrc("avatar-" + GameSetting.getAvatar(UserDataWrapper.wrapper.getCurrentAvatar()).rsrc,function(param1:Texture):void
                  {
                     avatarButton.background = param1;
                     queue.taskDone();
                  });
               });
            }
            nameInputButton = dialogSprite.getChildByName("btnName") as ContainerButton;
            nameInputButton.addEventListener("triggered",triggeredNameInputButton);
            nameText = nameInputButton.getChildByName("name") as ColorTextField;
            commentButton = dialogSprite.getChildByName("btnComment") as ContainerButton;
            commentButton.addEventListener("triggered",triggeredCommentButton);
            commentText = commentButton.getChildByName("comment") as ColorTextField;
            var wantGroup:Sprite = dialogSprite.getChildByName("wantedGroup") as Sprite;
            var i:int = 0;
            while(i < wantGroup.numChildren)
            {
               wantGudetamaButtons.push(new WantGudetamaButton(wantGroup.getChildByName("wanted" + i) as Sprite,i,triggeredWantGudetamaButtonCallback));
               i++;
            }
            shareButton = dialogSprite.getChildByName("shareButton") as ContainerButton;
            shareButton.enableDrawCache();
            shareButton.addEventListener("triggered",triggeredShareButton);
            list = dialogSprite.getChildByName("list") as List;
            copyToClipboardQuad = dialogSprite.getChildByName("copyToClipboard") as Quad;
            copyToClipboardQuad.addEventListener("touch",onTouchCopyToClipboardQuad);
            idText = dialogSprite.getChildByName("id") as ColorTextField;
            friendButton = dialogSprite.getChildByName("friendButton") as ContainerButton;
            friendButton.enableDrawCache();
            friendButton.addEventListener("triggered",triggeredFriendButton);
            listEmptyText = dialogSprite.getChildByName("listEmptyText") as ColorTextField;
            if(UserDataWrapper.featurePart.existsFeature(12))
            {
               Image(nameInputButton.getChildByName("imgLock")).visible = false;
               Image(commentButton.getChildByName("imgLock")).visible = false;
               Image(avatarButton.getChildByName("imgLock")).visible = false;
               Image(dialogSprite.getChildByName("imgWantLock")).visible = false;
               Image(dialogSprite.getChildByName("imgFriendLock")).visible = false;
            }
            else
            {
               Image(commentButton.getChildByName("imgEdit")).color = 8421504;
               Image(nameInputButton.getChildByName("imgEdit")).color = 8421504;
               Image(avatarButton.getChildByName("imgEdit")).color = 8421504;
               friendButton.color = 8421504;
               shareButton.color = 8421504;
            }
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         Engine.setupLayoutForTask(queue,"_TopPresentLogItem",function(param1:Object):void
         {
            topExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         Engine.setupLayoutForTask(queue,"_PresentLogItem",function(param1:Object):void
         {
            itemExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         Engine.setupLayoutForTask(queue,"_MorePresentLogItem",function(param1:Object):void
         {
            moreExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         queue.addTask(function():void
         {
            var _loc1_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(PROFILE_INIT,[!!UserDataWrapper.friendPart.isRequestedUpdateFollower() ? 1 : 0,!!UserDataWrapper.friendPart.isRequestedUpdateFollow() ? 1 : 0]),function(param1:Array):void
            {
               UserDataWrapper.wrapper.addPresentLogs(param1[0]);
               if(param1[1])
               {
                  UserDataWrapper.friendPart.setFollowerList(param1[1]);
               }
               if(param1[2])
               {
                  UserDataWrapper.friendPart.setFollowList(param1[2]);
               }
               queue.taskDone();
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
      
      override protected function addedToContainer() : void
      {
         init();
      }
      
      private function init() : void
      {
         var layout:FlowLayout = new FlowLayout();
         layout.horizontalAlign = "left";
         layout.horizontalGap = 2;
         layout.verticalGap = 10;
         layout.paddingTop = 5;
         layout.paddingLeft = 19.5;
         list.layout = layout;
         list.setItemRendererFactoryWithID("top",function():IListItemRenderer
         {
            return new TopUIListItemRenderer(topExtractor);
         });
         list.setItemRendererFactoryWithID("item",function():IListItemRenderer
         {
            return new PresentLogListItemRenderer(itemExtractor,true,triggeredDetailButton);
         });
         list.setItemRendererFactoryWithID("more",function():IListItemRenderer
         {
            return new MorePresentLogListItemRenderer(moreExtractor);
         });
         list.factoryIDFunction = function(param1:Object):String
         {
            return param1.label;
         };
         list.selectedIndex = -1;
         list.dataProvider = collection;
         list.verticalScrollBarFactory = function():IScrollBar
         {
            var _loc1_:ScrollBar = new ScrollBar();
            _loc1_.trackLayoutMode = "single";
            return _loc1_;
         };
         list.scrollBarDisplayMode = "fixedFloat";
         list.horizontalScrollPolicy = "off";
         list.verticalScrollPolicy = "auto";
         list.interactionMode = "touchAndScrollBars";
         setup();
      }
      
      private function setup() : void
      {
         var _loc3_:int = 0;
         levelText.text#2 = UserDataWrapper.wrapper.getRank().toString();
         nameText.text#2 = UserDataWrapper.wrapper.getPlayerName();
         commentText.text#2 = GameSetting.getComment(UserDataWrapper.wrapper.getComment());
         areaText.text#2 = StringUtil.format(GameSetting.getUIText("profile.area"),GameSetting.getUIText("profile.area." + UserDataWrapper.wrapper.getArea()) + GameSetting.getUIText("profile.area.slash") + GameSetting.getUIText("profile.area.gudetama." + UserDataWrapper.wrapper.getArea()));
         update();
         idText.text#2 = UserDataWrapper.wrapper.getFriendKey();
         var _loc2_:int = GameSetting.getRule().numScreeningPresentLogs;
         var _loc1_:Array = UserDataWrapper.wrapper.getPresentLogs();
         collection.addItem({"label":"top"});
         _loc3_ = _loc1_.length - 1;
         while(_loc3_ >= 0)
         {
            if(UserDataWrapper.friendPart.existsInFriend(_loc1_[_loc3_].encodedUid))
            {
               _loc2_--;
               if(_loc2_ < 0)
               {
                  break;
               }
               collection.addItem({
                  "label":"item",
                  "encodedUid":_loc1_[_loc3_].encodedUid,
                  "name":UserDataWrapper.wrapper.getPlayerName(),
                  "presentLog":_loc1_[_loc3_]
               });
            }
            _loc3_--;
         }
         if(collection.length > GameSetting.getRule().numScreeningPresentLogs)
         {
            collection.addItem({"label":"more"});
         }
         listEmptyText.visible = _loc1_.length <= 0;
         start();
      }
      
      private function start() : void
      {
         setBackButtonCallback(backButtonCallback);
         showResidentMenuUI(94);
         displaySprite.visible = true;
         processNoticeTutorial(1,noticeTutorialAction);
      }
      
      private function noticeTutorialAction(param1:int) : void
      {
      }
      
      private function triggeredWantGudetamaButtonCallback(param1:int) : void
      {
         processSetWandGudetama(param1);
      }
      
      private function processSetWandGudetama(param1:int) : void
      {
         var index:int = param1;
         WantedListDialog.show(function(param1:GudetamaDef):void
         {
            var gudetamaDef:GudetamaDef = param1;
            var id:int = !!gudetamaDef ? gudetamaDef.id#2 : 0;
            if(UserDataWrapper.wantedPart.equals(index,id))
            {
               return;
            }
            var _loc3_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(GENERAL_UPDATE_WANTED,[index,id]),function(param1:Array):void
            {
               UserDataWrapper.wantedPart.setWantedGudetamas(param1);
               update();
            });
         });
      }
      
      private function triggeredInventoryButton() : void
      {
         Engine.switchScene(new InventoryScene());
      }
      
      private function triggeredAvatarButton() : void
      {
         if(!checkFriendUnlock(true))
         {
            return;
         }
         AvatarSelectDialog.show(updateAvatarImage);
      }
      
      private function updateAvatarImage(param1:*) : void
      {
         var avatar:* = param1;
         if(avatar is Texture)
         {
            avatarButton.background = avatar;
            TextureCollector.loadSnsImage(UserDataWrapper.wrapper.getCurrentExtraAvatar(),null,loadedSnsImage);
         }
         else
         {
            TextureCollector.loadTextureRsrc("avatar-" + avatar,function(param1:Texture):void
            {
               if(avatarButton != null)
               {
                  avatarButton.background = param1;
               }
            });
            imgSns.visible = false;
         }
      }
      
      private function loadedSnsImage(param1:Texture) : void
      {
         if(imgSns == null)
         {
            return;
         }
         if(param1 != null)
         {
            imgSns.texture = param1;
            imgSns.visible = true;
         }
         else
         {
            imgSns.visible = false;
         }
      }
      
      private function triggeredNameInputButton() : void
      {
         if(!checkFriendUnlock(true))
         {
            return;
         }
         NameInputDialog.show(UserDataWrapper.wrapper.getPlayerName(),updatePlayerName);
      }
      
      private function updatePlayerName(param1:String) : void
      {
         nameText.text#2 = param1;
      }
      
      private function onTouchCopyToClipboardQuad(param1:TouchEvent) : void
      {
         var _loc2_:Touch = param1.getTouch(copyToClipboardQuad);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_.phase == "ended")
         {
            Clipboard.generalClipboard.setData("air:text",UserDataWrapper.wrapper.getFriendKey());
            LocalMessageDialog.show(0,GameSetting.getUIText("profile.message.clipboard.desc"),null,GameSetting.getUIText("profile.message.clipboard.title"));
         }
      }
      
      private function checkFriendUnlock(param1:Boolean) : Boolean
      {
         var _loc2_:* = null;
         if(UserDataWrapper.featurePart.existsFeature(12))
         {
            return true;
         }
         if(param1)
         {
            _loc2_ = GameSetting.getUIText("common.unlock.edit.level").replace("%1",GameSetting.getInitOtherInt("friend.unlock.lv"));
         }
         else
         {
            _loc2_ = GudetamaUtil.getFriendUnlockConditionText();
         }
         LocalMessageDialog.show(0,_loc2_);
         return false;
      }
      
      private function triggeredFriendButton(param1:Event) : void
      {
         var event:Event = param1;
         if(!checkFriendUnlock(false))
         {
            return;
         }
         GudetamaUtil.playFriendSE();
         ResidentMenuUI_Gudetama.getInstance().sendChangeState(63,function():void
         {
            if(UserDataWrapper.wrapper.isCanStartNoticeFlag(5))
            {
               Engine.switchScene(new FriendScene_Gudetama(),1,0.5,true);
            }
            else
            {
               Engine.switchScene(new FriendScene_Gudetama());
            }
         });
      }
      
      private function triggeredDetailButton(param1:int) : void
      {
         var encodedUid:int = param1;
         var profile:UserProfileData = UserDataWrapper.friendPart.getFriendProfile(encodedUid);
         if(!profile)
         {
            return;
         }
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
               gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(GENERAL_FRIEND_REMOVE_FOLLOW,encodedUid),function(param1:Array):void
               {
                  var response:Array = param1;
                  Engine.hideLoading(ProfileScene);
                  profile.followState = 0;
                  UserDataWrapper.friendPart.removeFollow(profile);
                  UserDataWrapper.friendPart.removeFollower(profile);
                  UserDataWrapper.friendPart.removeFriend(profile);
                  ResidentMenuUI_Gudetama.getInstance().sendChangeState(145,function():void
                  {
                     Engine.switchScene(new ProfileScene());
                  });
               });
            },
            "backFromRoomFunc":function():void
            {
               ResidentMenuUI_Gudetama.getInstance().sendChangeState(145,function():void
               {
                  Engine.switchScene(new ProfileScene());
               });
            }
         });
      }
      
      private function triggeredCommentButton() : void
      {
         if(!checkFriendUnlock(true))
         {
            return;
         }
         CommentSelectDialog.show(updatePlayerComment);
      }
      
      private function triggeredShareButton() : void
      {
         if(!checkFriendUnlock(false))
         {
            return;
         }
         var _loc1_:Array = UserDataWrapper.wantedPart.getAllWantedIds();
         if(_loc1_.length == 0)
         {
            LocalMessageDialog.show(0,GameSetting.getUIText("profile.caution.0want"));
            return;
         }
         WantedShareDialog.show(_loc1_);
      }
      
      private function updatePlayerComment(param1:int) : void
      {
         commentText.text#2 = GameSetting.getComment(param1);
      }
      
      private function backButtonCallback() : void
      {
         if(Engine.getGuideTalkPanel() != null)
         {
            return;
         }
         ResidentMenuUI_Gudetama.getInstance().sendChangeState(60,function():void
         {
            Engine.switchScene(new HomeScene());
         });
      }
      
      private function refreshedSceneContainer(param1:Event) : void
      {
      }
      
      private function update() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < wantGudetamaButtons.length)
         {
            wantGudetamaButtons[_loc1_].setup(_loc1_);
            _loc1_++;
         }
      }
      
      override public function dispose() : void
      {
         removeEventListener("refreshed_scene_container",refreshedSceneContainer);
         levelText = null;
         nameText = null;
         nameInputButton = null;
         commentText = null;
         commentButton = null;
         avatarButton = null;
         imgSns = null;
         areaText = null;
         if(wantGudetamaButtons)
         {
            for each(var _loc1_ in wantGudetamaButtons)
            {
               _loc1_.dispose();
            }
            wantGudetamaButtons.length = 0;
            wantGudetamaButtons = null;
         }
         if(shareButton)
         {
            shareButton.removeEventListener("triggered",triggeredShareButton);
            shareButton = null;
         }
         list = null;
         itemExtractor = null;
         collection = null;
         if(copyToClipboardQuad)
         {
            copyToClipboardQuad.removeEventListener("touch",onTouchCopyToClipboardQuad);
            copyToClipboardQuad = null;
         }
         idText = null;
         if(friendButton)
         {
            friendButton.removeEventListener("triggered",triggeredFriendButton);
            friendButton = null;
         }
         super.dispose();
      }
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.GudetamaDef;
import gudetama.data.compati.UserWantedData;
import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class WantGudetamaButton extends UIBase
{
    
   
   private var index:int;
   
   private var callback:Function;
   
   private var button:ContainerButton;
   
   private var iconImage:Image;
   
   private var numberText:ColorTextField;
   
   private var nameText:ColorTextField;
   
   private var numText:ColorTextField;
   
   private var emptyGroup:Sprite;
   
   function WantGudetamaButton(param1:Sprite, param2:int, param3:Function)
   {
      super(param1);
      this.index = param2;
      this.callback = param3;
      button = param1.getChildByName("button") as ContainerButton;
      button.addEventListener("triggered",triggeredButton);
      iconImage = button.getChildByName("icon") as Image;
      numberText = button.getChildByName("number") as ColorTextField;
      numberText.visible = false;
      nameText = button.getChildByName("name") as ColorTextField;
      numText = button.getChildByName("num") as ColorTextField;
      emptyGroup = button.getChildByName("emptyGroup") as Sprite;
   }
   
   public function setup(param1:int) : void
   {
      var index:int = param1;
      if(!UserDataWrapper.wantedPart.isEmpty(index))
      {
         var userWantedData:UserWantedData = UserDataWrapper.wantedPart.getUserWantedData(index);
         var gudetamaDef:GudetamaDef = GameSetting.getGudetama(userWantedData.id#2);
         numberText.text#2 = gudetamaDef.number.toString();
         numberText.visible = false;
         numText.text#2 = UserDataWrapper.gudetamaPart.getNumGudetama(gudetamaDef.id#2).toString();
         numText.visible = false;
         emptyGroup.visible = false;
         TextureCollector.loadTextureRsrc(GudetamaUtil.getCollectionIconName(gudetamaDef.id#2),function(param1:Texture):void
         {
            if(iconImage != null)
            {
               iconImage.texture = param1;
            }
         });
      }
      else
      {
         emptyGroup.visible = true;
      }
   }
   
   private function triggeredButton(param1:Event) : void
   {
      callback(index);
   }
   
   public function dispose() : void
   {
      button.removeEventListener("triggered",triggeredButton);
      button = null;
      iconImage = null;
      numberText = null;
      nameText = null;
      numText = null;
      emptyGroup = null;
      callback = null;
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class MorePresentLogListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var displaySprite:Sprite;
   
   private var morePresentLogUI:MorePresentLogUI;
   
   function MorePresentLogListItemRenderer(param1:SpriteExtractor)
   {
      super();
      this.extractor = param1;
   }
   
   override protected function initialize() : void
   {
      if(displaySprite)
      {
         return;
      }
      displaySprite = extractor.duplicateAll() as Sprite;
      morePresentLogUI = new MorePresentLogUI(displaySprite);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      morePresentLogUI.updateData(data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      displaySprite = null;
      morePresentLogUI.dispose();
      morePresentLogUI = null;
      super.dispose();
   }
}

import gudetama.scene.profile.MorePresentLogDialog;
import gudetama.ui.UIBase;
import muku.display.ContainerButton;
import starling.display.Sprite;
import starling.events.Event;

class MorePresentLogUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var button:ContainerButton;
   
   function MorePresentLogUI(param1:Sprite)
   {
      super(param1);
      this.callback = callback;
      button = param1.getChildByName("button") as ContainerButton;
      button.addEventListener("triggered",triggeredButton);
   }
   
   public function updateData(param1:Object) : void
   {
      if(!param1)
      {
         return;
      }
   }
   
   private function triggeredButton(param1:Event) : void
   {
      MorePresentLogDialog.show();
   }
   
   public function dispose() : void
   {
      if(button)
      {
         button.removeEventListener("triggered",triggeredButton);
         button = null;
      }
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class TopUIListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var displaySprite:Sprite;
   
   private var topUI:TopUI;
   
   function TopUIListItemRenderer(param1:SpriteExtractor)
   {
      super();
      this.extractor = param1;
   }
   
   override protected function initialize() : void
   {
      if(displaySprite)
      {
         return;
      }
      displaySprite = extractor.duplicateAll() as Sprite;
      topUI = new TopUI(displaySprite);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      topUI.updateData(data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      displaySprite = null;
      topUI.dispose();
      topUI = null;
      super.dispose();
   }
}

import gudetama.ui.UIBase;
import starling.display.Sprite;

class TopUI extends UIBase
{
    
   
   function TopUI(param1:Sprite)
   {
      super(param1);
   }
   
   public function updateData(param1:Object) : void
   {
      if(!param1)
      {
         return;
      }
   }
   
   public function dispose() : void
   {
   }
}
