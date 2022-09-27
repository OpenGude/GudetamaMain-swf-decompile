package gudetama.scene.friend
{
   import feathers.controls.IScrollBar;
   import feathers.controls.List;
   import feathers.controls.Radio;
   import feathers.controls.ScrollBar;
   import feathers.controls.renderers.IListItemRenderer;
   import feathers.core.ToggleGroup;
   import feathers.data.ListCollection;
   import feathers.layout.VerticalLayout;
   import gudetama.common.FacebookManager;
   import gudetama.common.TwitterManager;
   import gudetama.data.DataStorage;
   import gudetama.data.GameSetting;
   import gudetama.data.compati.UserProfileData;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.ui.MessageDialog;
   import gudetama.util.SpriteExtractor;
   import muku.display.ContainerButton;
   import muku.display.SimpleImageButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class SnsFriendListDialog extends BaseScene
   {
      
      public static const TWITTER_COLOR:int = 2063304;
      
      public static const FACEBOOK_COLOR:int = 3557020;
       
      
      private var friendScene:FriendScene_Gudetama;
      
      private var callback:Function;
      
      private var btnTw:SimpleImageButton;
      
      private var radioTw:Radio;
      
      private var texTwOn:Texture;
      
      private var texTwOff:Texture;
      
      private var btnFb:SimpleImageButton;
      
      private var radioFb:Radio;
      
      private var texFbOn:Texture;
      
      private var texFbOff:Texture;
      
      private var group:ToggleGroup;
      
      private var list:List;
      
      private var collection:ListCollection;
      
      private var desc:ColorTextField;
      
      private var btnClose:ContainerButton;
      
      private var itemExtractor:SpriteExtractor;
      
      private var snsTitleExtractor:SpriteExtractor;
      
      public var currentSnsType:int;
      
      private var useSnsTwitter:Boolean = true;
      
      private var useSnsFacebook:Boolean = true;
      
      public function SnsFriendListDialog(param1:FriendScene_Gudetama, param2:Function)
      {
         collection = new ListCollection();
         super(2);
         this.friendScene = param1;
         this.callback = param2;
         this.useSnsTwitter = GameSetting.def.rule.useSnsTwitter;
         this.useSnsFacebook = GameSetting.def.rule.useSnsFacebook;
      }
      
      public static function show(param1:FriendScene_Gudetama, param2:Function = null) : void
      {
         Engine.pushScene(new SnsFriendListDialog(param1,param2),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         var dialog:SnsFriendListDialog = this;
         Engine.setupLayoutForTask(queue,"SnsFriendListDialog",function(param1:Object):void
         {
            var layout:Object = param1;
            displaySprite = layout.object;
            var dialogSprite:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            btnTw = dialogSprite.getChildByName("btnTw") as SimpleImageButton;
            btnTw.visible = false;
            radioTw = dialogSprite.getChildByName("radioTw") as Radio;
            btnFb = dialogSprite.getChildByName("btnFb") as SimpleImageButton;
            btnFb.visible = false;
            radioFb = dialogSprite.getChildByName("radioFb") as Radio;
            checkBtnPostion();
            group = new ToggleGroup();
            if(useSnsTwitter)
            {
               group.addItem(radioTw);
            }
            if(useSnsFacebook)
            {
               group.addItem(radioFb);
            }
            group.addEventListener("change",toggleSns);
            list = dialogSprite.getChildByName("list") as List;
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
            var listLayout:VerticalLayout = new VerticalLayout();
            listLayout.padding = 5;
            listLayout.gap = 20;
            listLayout.firstGap = -20;
            list.layout = listLayout;
            desc = dialogSprite.getChildByName("desc") as ColorTextField;
            desc.text#2 = GameSetting.getUIText("sns.link.desc");
            btnClose = dialogSprite.getChildByName("btn_close") as ContainerButton;
            btnClose.addEventListener("triggered",triggeredCloseButton);
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         Engine.setupLayoutForTask(queue,"_SnsFriendListItem",function(param1:Object):void
         {
            itemExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         Engine.setupLayoutForTask(queue,"_SnsLinkTitle",function(param1:Object):void
         {
            snsTitleExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         TextureCollector.loadTextureForTask(queue,"friend1@btn_tw_on",function(param1:Texture):void
         {
            texTwOn = param1;
         });
         TextureCollector.loadTextureForTask(queue,"friend1@btn_tw_off",function(param1:Texture):void
         {
            texTwOff = param1;
         });
         TextureCollector.loadTextureForTask(queue,"friend1@btn_fb_on",function(param1:Texture):void
         {
            texFbOn = param1;
         });
         TextureCollector.loadTextureForTask(queue,"friend1@btn_fb_off",function(param1:Texture):void
         {
            texFbOff = param1;
         });
         queue.registerOnProgress(function(param1:Number):void
         {
            var ratio:Number = param1;
            if(ratio < 1)
            {
               return;
            }
            radioTw.defaultSkin = new Image(texTwOff);
            radioTw.defaultSelectedSkin = new Image(texTwOn);
            radioFb.defaultSkin = new Image(texFbOff);
            radioFb.defaultSelectedSkin = new Image(texFbOn);
            list.typicalItem = {"key":"item"};
            list.setItemRendererFactoryWithID("tw",function():IListItemRenderer
            {
               return new SNSLinkTitleRenderer(snsTitleExtractor,0,dialog);
            });
            list.setItemRendererFactoryWithID("fb",function():IListItemRenderer
            {
               return new SNSLinkTitleRenderer(snsTitleExtractor,1,dialog);
            });
            list.setItemRendererFactoryWithID("item",function():IListItemRenderer
            {
               return new SnsFriendListItemRenderer(itemExtractor,friendScene,dialog);
            });
            list.factoryIDFunction = function(param1:Object):String
            {
               return param1.key;
            };
            toggleSns(null);
         });
         queue.startTask(onProgress);
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(SnsFriendListDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(SnsFriendListDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(SnsFriendListDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(SnsFriendListDialog);
            Engine.popScene(scene);
            if(callback != null)
            {
               callback();
            }
         });
      }
      
      public function toggleSns(param1:Event) : void
      {
         collection.removeAll();
         switch(group.selectedItem)
         {
            case radioTw:
               currentSnsType = 0;
               collection.addItem({"key":"tw"});
               if(TwitterManager.isLinked())
               {
                  TwitterManager.load(getSnsFriend,true);
               }
               else
               {
                  descNoLink();
               }
               break;
            case radioFb:
               currentSnsType = 1;
               collection.addItem({"key":"fb"});
               if(FacebookManager.isLinked())
               {
                  FacebookManager.load(getSnsFriend,true);
               }
               else
               {
                  descNoLink();
               }
         }
      }
      
      public function procLink(param1:int) : void
      {
         switch(int(param1))
         {
            case 0:
               TwitterManager.load(getSnsFriend,false,snsLinkResult);
               break;
            case 1:
               FacebookManager.load(getSnsFriend,false,snsLinkResult);
         }
      }
      
      public function procLinkUpdate(param1:int) : void
      {
         switch(int(param1))
         {
            case 0:
               TwitterManager.load(getSnsFriend,false,snsLinkResult);
               break;
            case 1:
               FacebookManager.load(getSnsFriend,false,snsLinkResult);
         }
      }
      
      public function procLinkDissolve(param1:int) : void
      {
         var _type:int = param1;
         var key:String = _type == 0 ? "sns.link.twitter.confirm.unlink" : "sns.link.facebook.confirm.unlink";
         MessageDialog.show(2,GameSetting.getUIText(key),function(param1:int):void
         {
            if(param1 == 1)
            {
               return;
            }
            switch(int(_type))
            {
               case 0:
                  TwitterManager.unlink(snsLinkResult);
                  break;
               case 1:
                  FacebookManager.unlink(snsLinkResult);
            }
         });
      }
      
      private function snsLinkResult(param1:int, param2:int) : void
      {
         switch(int(param2) - -1)
         {
            case 0:
            case 1:
               descNoLink();
               collection.removeAll();
               if(param1 == 0)
               {
                  collection.addItem({"key":"tw"});
                  break;
               }
               if(param1 == 1)
               {
                  collection.addItem({"key":"fb"});
                  break;
               }
               break;
         }
      }
      
      public function getSnsFriend(param1:int, param2:Array) : void
      {
         var _type:int = param1;
         var _ids:Array = param2;
         var searchIdsString:String = null;
         var isTwitter:Boolean = _type == 0;
         if(_ids != null && _ids.length > 0)
         {
            searchIdsString = _ids.toString();
            var _loc4_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithIntAndObject(GENERAL_SEARCH_SNS_PROFILE,_type,searchIdsString),function(param1:Array):void
            {
               var _loc5_:* = null;
               var _loc2_:* = null;
               var _loc3_:int = 0;
               var _loc4_:int = 0;
               var _loc6_:* = null;
               Engine.hideLoading();
               if(param1 != null)
               {
                  _loc5_ = param1;
                  _loc2_ = [];
                  _loc3_ = _loc5_.length;
                  _loc4_ = 0;
                  while(_loc4_ < _loc3_)
                  {
                     _loc6_ = _loc5_[_loc4_];
                     collection.addItem({
                        "key":"item",
                        "profile":_loc6_
                     });
                     _loc2_.push(UserProfileData(_loc5_[_loc4_]).snsId);
                     _loc4_++;
                  }
                  if(isTwitter)
                  {
                     DataStorage.getLocalData().setSnsTwitterUids(_loc2_);
                  }
                  else
                  {
                     DataStorage.getLocalData().setSnsFacebookUids(_loc2_);
                  }
                  DataStorage.saveLocalData();
                  if(_loc3_ > 0)
                  {
                     desc.visible = false;
                  }
                  else
                  {
                     descBlank();
                  }
               }
               else
               {
                  descBlank();
               }
            });
         }
         else
         {
            Engine.hideLoading();
            var linking:Boolean = !!isTwitter ? TwitterManager.isLinked() : Boolean(FacebookManager.isLinked());
            if(linking)
            {
               descBlank();
            }
            else
            {
               descNoLink();
            }
         }
      }
      
      private function rePushableSnsBtn() : void
      {
         if(useSnsTwitter)
         {
            btnTw.enabled = true;
         }
         if(useSnsFacebook)
         {
            btnFb.enabled = true;
         }
      }
      
      private function descBlank() : void
      {
         desc.text#2 = GameSetting.getUIText("sns.link.noplayer");
         desc.visible = true;
      }
      
      private function descNoLink() : void
      {
         desc.text#2 = GameSetting.getUIText("sns.link.desc");
         desc.visible = true;
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      private function checkBtnPostion() : void
      {
         if(useSnsTwitter && useSnsFacebook)
         {
            return;
         }
         if(useSnsTwitter && !useSnsFacebook)
         {
            radioFb.visible = false;
            radioTw.x = 215;
            return;
         }
         if(!useSnsTwitter && useSnsFacebook)
         {
            radioTw.visible = false;
            radioFb.x = 215;
            return;
         }
      }
      
      override public function dispose() : void
      {
         radioTw = null;
         radioFb = null;
         group.removeEventListener("change",toggleSns);
         group = null;
         btnClose.removeEventListener("triggered",triggeredCloseButton);
         btnClose = null;
         super.dispose();
      }
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.scene.friend.FriendScene_Gudetama;
import gudetama.scene.friend.SnsFriendListDialog;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class SnsFriendListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var scene:FriendScene_Gudetama;
   
   private var dialog:SnsFriendListDialog;
   
   private var displaySprite:Sprite;
   
   private var listItemUI:SnsFriendListItemUI;
   
   function SnsFriendListItemRenderer(param1:SpriteExtractor, param2:FriendScene_Gudetama, param3:SnsFriendListDialog)
   {
      super();
      this.extractor = param1;
      this.scene = param2;
      this.dialog = param3;
   }
   
   override protected function initialize() : void
   {
      if(displaySprite)
      {
         return;
      }
      displaySprite = extractor.duplicateAll() as Sprite;
      listItemUI = new SnsFriendListItemUI(displaySprite,scene,dialog);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      listItemUI.updateData(data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      scene = null;
      displaySprite = null;
      listItemUI.dispose();
      listItemUI = null;
      super.dispose();
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.compati.UserProfileData;
import gudetama.engine.TextureCollector;
import gudetama.scene.friend.FriendScene_Gudetama;
import gudetama.scene.friend.SnsFriendDetailDialog;
import gudetama.scene.friend.SnsFriendListDialog;
import gudetama.ui.UIBase;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class SnsFriendListItemUI extends UIBase
{
    
   
   private var scene:FriendScene_Gudetama;
   
   private var dialog:SnsFriendListDialog;
   
   private var icon:Image;
   
   private var imgSns:Image;
   
   private var txtName:ColorTextField;
   
   private var btnDetail:ContainerButton;
   
   private var profile:UserProfileData;
   
   function SnsFriendListItemUI(param1:Sprite, param2:FriendScene_Gudetama, param3:SnsFriendListDialog)
   {
      super(param1);
      this.scene = param2;
      this.dialog = param3;
      icon = param1.getChildByName("icon") as Image;
      imgSns = param1.getChildByName("imgSns") as Image;
      txtName = param1.getChildByName("name") as ColorTextField;
      btnDetail = param1.getChildByName("btnDetail") as ContainerButton;
      btnDetail.addEventListener("triggered",triggeredDetailButton);
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      if(!data)
      {
         return;
      }
      profile = data.profile;
      if(profile == null)
      {
         return;
      }
      txtName.text#2 = profile.playerName;
      icon.visible = false;
      imgSns.visible = false;
      if(profile.snsProfileImage != null)
      {
         GudetamaUtil.loadByteArray2Texture(profile.snsProfileImage,function(param1:Texture):void
         {
            icon.texture = param1;
            icon.visible = true;
         });
         TextureCollector.loadSnsImage(profile.snsType,null,function(param1:Texture):void
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
         if(profile.avatar == 0)
         {
            profile.avatar = 1;
         }
         TextureCollector.loadTextureRsrc("avatar-" + GameSetting.getAvatar(profile.avatar).rsrc,function(param1:Texture):void
         {
            icon.texture = param1;
            icon.visible = true;
         });
      }
   }
   
   private function triggeredDetailButton(param1:Event) : void
   {
      SnsFriendDetailDialog.show(profile,dialog.currentSnsType,scene,dialog);
   }
   
   public function dispose() : void
   {
      scene = null;
      txtName = null;
      btnDetail.removeEventListener("triggered",triggeredDetailButton);
      btnDetail = null;
      profile = null;
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.scene.friend.SnsFriendListDialog;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class SNSLinkTitleRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var type:int;
   
   private var dialog:SnsFriendListDialog;
   
   private var displaySprite:Sprite;
   
   private var snsItemUI:SNSLinkTitleUI;
   
   function SNSLinkTitleRenderer(param1:SpriteExtractor, param2:int, param3:SnsFriendListDialog)
   {
      super();
      this.extractor = param1;
      this.type = param2;
      this.dialog = param3;
   }
   
   override protected function initialize() : void
   {
      if(displaySprite)
      {
         return;
      }
      displaySprite = extractor.duplicateAll() as Sprite;
      snsItemUI = new SNSLinkTitleUI(displaySprite,type,dialog);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      snsItemUI.updateData(data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      displaySprite = null;
      snsItemUI.dispose();
      snsItemUI = null;
      super.dispose();
   }
}

import gudetama.common.FacebookManager;
import gudetama.common.TwitterManager;
import gudetama.data.GameSetting;
import gudetama.engine.Engine;
import gudetama.engine.TweenAnimator;
import gudetama.scene.friend.SnsFriendListDialog;
import gudetama.ui.UIBase;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;

class SNSLinkTitleUI extends UIBase
{
    
   
   private var type:int;
   
   private var dialog:SnsFriendListDialog;
   
   private var spNoLink:Sprite;
   
   private var btnLink:ContainerButton;
   
   private var spLink:Sprite;
   
   private var btnUpdate:ContainerButton;
   
   private var btnDissolve:ContainerButton;
   
   function SNSLinkTitleUI(param1:Sprite, param2:int, param3:SnsFriendListDialog)
   {
      super(param1);
      this.type = param2;
      this.dialog = param3;
      var _loc4_:Image = param1.getChildByName("imgMat") as Image;
      var _loc6_:ColorTextField = param1.getChildByName("title") as ColorTextField;
      spNoLink = param1.getChildByName("spNoLink") as Sprite;
      btnLink = spNoLink.getChildByName("btnLink") as ContainerButton;
      btnLink.addEventListener("triggered",triggeredLink);
      spLink = param1.getChildByName("spLink") as Sprite;
      var _loc5_:ColorTextField = spLink.getChildByName("text") as ColorTextField;
      btnUpdate = spLink.getChildByName("btnUpdate") as ContainerButton;
      btnUpdate.addEventListener("triggered",triggeredUpdate);
      btnDissolve = spLink.getChildByName("btnDissolve") as ContainerButton;
      btnDissolve.addEventListener("triggered",triggeredDissolve);
      var _loc7_:* = Engine;
      if(gudetama.engine.Engine.isIosPlatform() || true)
      {
         TweenAnimator.startItself(btnUpdate,"ios");
         TweenAnimator.startItself(btnDissolve,"ios");
      }
      else
      {
         TweenAnimator.startItself(btnUpdate,"android");
         TweenAnimator.startItself(btnDissolve,"android");
      }
      if(isTwitter())
      {
         _loc4_.color = 2063304;
         _loc6_.text#2 = GameSetting.getUIText("%sns.link.twitter.follower");
         _loc5_.color = 2063304;
      }
      else
      {
         _loc4_.color = 3557020;
         _loc6_.text#2 = GameSetting.getUIText("%sns.link.facebook.follower");
         _loc5_.color = 3557020;
      }
   }
   
   public function updateData(param1:Object) : void
   {
      if(param1 == null)
      {
         return;
      }
      var _loc2_:Boolean = !!isTwitter() ? TwitterManager.isLinked() : Boolean(FacebookManager.isLinked());
      if(_loc2_)
      {
         spNoLink.visible = false;
         spLink.visible = true;
      }
      else
      {
         spNoLink.visible = true;
         spLink.visible = false;
      }
   }
   
   private function isTwitter() : Boolean
   {
      return type == 0;
   }
   
   private function triggeredLink(param1:Event) : void
   {
      dialog.procLink(type);
   }
   
   private function triggeredUpdate(param1:Event) : void
   {
      dialog.procLinkUpdate(type);
   }
   
   private function triggeredDissolve(param1:Event) : void
   {
      dialog.procLinkDissolve(type);
   }
   
   public function dispose() : void
   {
      btnLink.removeEventListener("triggered",triggeredLink);
      btnLink = null;
      spNoLink = null;
      btnUpdate.removeEventListener("triggered",triggeredUpdate);
      btnUpdate = null;
      btnDissolve.removeEventListener("triggered",triggeredDissolve);
      btnDissolve = null;
      spLink = null;
   }
}
