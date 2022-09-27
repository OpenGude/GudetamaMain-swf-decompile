package gudetama.scene.friend
{
   import feathers.controls.IScrollBar;
   import feathers.controls.List;
   import feathers.controls.ScrollBar;
   import feathers.controls.renderers.IListItemRenderer;
   import feathers.data.ListCollection;
   import feathers.layout.FlowLayout;
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.GudetamaDef;
   import gudetama.data.compati.UserProfileData;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.ui.LocalMessageDialog;
   import gudetama.util.SpriteExtractor;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class FriendPresentListDialog extends BaseScene
   {
       
      
      private var gudetamaId:int;
      
      private var iconImage:Image;
      
      private var numberText:ColorTextField;
      
      private var nameText:ColorTextField;
      
      private var numText:ColorTextField;
      
      private var list:List;
      
      private var listEmptyText:ColorTextField;
      
      private var closeButton:ContainerButton;
      
      private var extractor:SpriteExtractor;
      
      private var collection:ListCollection;
      
      private var profiles:Array;
      
      private var loadCount:int;
      
      private var checkDeliver:Boolean;
      
      public function FriendPresentListDialog(param1:int, param2:Boolean)
      {
         collection = new ListCollection();
         super(2);
         this.gudetamaId = param1;
         this.checkDeliver = param2;
         addEventListener("update_scene",updateScene);
      }
      
      public static function show(param1:int, param2:Boolean = false) : void
      {
         Engine.pushScene(new FriendPresentListDialog(param1,param2),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"FriendPresentListDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            iconImage = _loc2_.getChildByName("icon") as Image;
            numberText = _loc2_.getChildByName("number") as ColorTextField;
            nameText = _loc2_.getChildByName("name") as ColorTextField;
            numText = _loc2_.getChildByName("num") as ColorTextField;
            list = _loc2_.getChildByName("list") as List;
            listEmptyText = _loc2_.getChildByName("listEmptyText") as ColorTextField;
            closeButton = _loc2_.getChildByName("btn_back") as ContainerButton;
            closeButton.enableDrawCache();
            closeButton.addEventListener("triggered",triggeredCloseButton);
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         setupLayoutForTask(queue,"_FriendPresentListItem",function(param1:Object):void
         {
            extractor = SpriteExtractor.forGross(param1.object,param1);
         });
         addTask(function():void
         {
            var _loc1_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(219,gudetamaId),function(param1:Array):void
            {
               profiles = param1;
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
         var layout:FlowLayout = new FlowLayout();
         layout.horizontalAlign = "left";
         layout.horizontalGap = 10;
         layout.verticalGap = 10;
         layout.paddingTop = 5;
         layout.paddingLeft = 18;
         list.layout = layout;
         list.itemRendererFactory = function():IListItemRenderer
         {
            return new FriendPresentListItemRenderer(extractor,triggeredFriendPresentListItemUI);
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
         var gudetamaDef:GudetamaDef = GameSetting.getGudetama(gudetamaId);
         queue.addTask(function():void
         {
            TextureCollector.loadTextureRsrc(GudetamaUtil.getCollectionIconName(gudetamaDef.id#2),function(param1:Texture):void
            {
               iconImage.texture = param1;
               queue.taskDone();
            });
         });
         if(gudetamaDef.type != 1)
         {
            numberText.visible = false;
         }
         numberText.text#2 = StringUtil.format(GameSetting.getUIText("common.number"),StringUtil.decimalFormat(GameSetting.getUIText("common.number.format"),gudetamaDef.number));
         nameText.text#2 = gudetamaDef.getWrappedName();
         numText.text#2 = UserDataWrapper.gudetamaPart.getNumGudetama(gudetamaId).toString();
         for each(profile in profiles)
         {
            if(!(checkDeliver && GudetamaUtil.getDeliverPoint(profile,gudetamaId) == 0))
            {
               collection.addItem({
                  "gudetamaId":gudetamaId,
                  "profile":profile
               });
            }
         }
         listEmptyText.visible = collection.length <= 0;
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
         });
      }
      
      private function triggeredFriendPresentListItemUI(param1:UserProfileData) : void
      {
         var profile:UserProfileData = param1;
         if(!UserDataWrapper.gudetamaPart.hasGudetama(gudetamaId,1))
         {
            LocalMessageDialog.show(0,GameSetting.getUIText("gudetamaDetail.message.present.disabled.desc"),null,GameSetting.getUIText("gudetamaDetail.message.present.title"));
            return;
         }
         var deliverPoint:int = GudetamaUtil.getDeliverPoint(profile,gudetamaId);
         FriendPresentConfirmDialog.show(gudetamaId,profile.encodedUid,deliverPoint,function(param1:int):void
         {
            if(param1 == 0)
            {
               return;
            }
            FriendDetailDialog.sendPresentGude(param1,gudetamaId,profile,deliverPoint > 0,null,presentGudetFailCallback,presentGudetFailCallback,null);
         });
      }
      
      private function presentGudetFailCallback() : void
      {
         Engine.lockTouchInput(FriendPresentListDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(FriendPresentListDialog);
            Engine.popScene(scene);
            FriendPresentListDialog.show(gudetamaId);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(FriendPresentListDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(FriendPresentListDialog);
            Engine.popScene(scene);
         });
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      private function updateScene() : void
      {
         numText.text#2 = UserDataWrapper.gudetamaPart.getNumGudetama(gudetamaId).toString();
         collection.updateAll();
      }
      
      override public function dispose() : void
      {
         iconImage = null;
         numberText = null;
         nameText = null;
         numText = null;
         list = null;
         if(closeButton)
         {
            closeButton.removeEventListener("triggered",triggeredCloseButton);
            closeButton = null;
         }
         extractor = null;
         collection = null;
         super.dispose();
      }
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class FriendPresentListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var callback:Function;
   
   private var displaySprite:Sprite;
   
   private var friendPresentListItemUI:FriendPresentListItemUI;
   
   function FriendPresentListItemRenderer(param1:SpriteExtractor, param2:Function)
   {
      super();
      this.extractor = param1;
      this.callback = param2;
   }
   
   override protected function initialize() : void
   {
      if(displaySprite)
      {
         return;
      }
      displaySprite = extractor.duplicateAll() as Sprite;
      friendPresentListItemUI = new FriendPresentListItemUI(displaySprite,callback);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      friendPresentListItemUI.updateData(data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      displaySprite = null;
      friendPresentListItemUI.dispose();
      friendPresentListItemUI = null;
      super.dispose();
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.UserProfileData;
import gudetama.engine.Engine;
import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class FriendPresentListItemUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var iconImage:Image;
   
   private var imgSns:Image;
   
   private var levelText:ColorTextField;
   
   private var nameText:ColorTextField;
   
   private var areaText:ColorTextField;
   
   private var presentButton:ContainerButton;
   
   private var gudetamaId:int;
   
   private var profile:UserProfileData;
   
   function FriendPresentListItemUI(param1:Sprite, param2:Function)
   {
      super(param1);
      this.callback = param2;
      iconImage = param1.getChildByName("icon") as Image;
      imgSns = param1.getChildByName("imgSns") as Image;
      levelText = param1.getChildByName("level") as ColorTextField;
      nameText = param1.getChildByName("name") as ColorTextField;
      areaText = param1.getChildByName("area") as ColorTextField;
      presentButton = param1.getChildByName("presentButton") as ContainerButton;
      presentButton.setDisableColor(8421504);
      presentButton.addEventListener("triggered",triggeredPresentButton);
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      if(!data)
      {
         return;
      }
      gudetamaId = data.gudetamaId;
      profile = data.profile;
      nameText.text#2 = profile.playerName;
      iconImage.visible = false;
      imgSns.visible = false;
      if(profile.snsProfileImage != null)
      {
         GudetamaUtil.loadByteArray2Texture(profile.snsProfileImage,function(param1:Texture):void
         {
            iconImage.texture = param1;
            iconImage.visible = true;
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
         TextureCollector.loadTextureRsrc("avatar-" + GameSetting.getAvatar(profile.avatar).rsrc,function(param1:Texture):void
         {
            iconImage.texture = param1;
            iconImage.visible = true;
         });
      }
      levelText.text#2 = profile.playerRank.toString();
      if(Engine.getLocale() == "ja")
      {
         areaText.text#2 = StringUtil.format(GameSetting.getUIText("profile.area"),GameSetting.getUIText("profile.area." + profile.area));
      }
      else
      {
         areaText.text#2 = StringUtil.format(GameSetting.getUIText("profile.area"),GameSetting.getUIText("profile.area." + profile.area) + GameSetting.getUIText("profile.area.slash") + GameSetting.getUIText("profile.area.gudetama." + profile.area));
      }
      presentButton.enableDrawCache(true,false,!UserDataWrapper.gudetamaPart.hasGudetama(gudetamaId,1));
   }
   
   private function triggeredPresentButton(param1:Event) : void
   {
      callback(profile);
   }
   
   public function dispose() : void
   {
      callback = null;
      levelText = null;
      nameText = null;
      areaText = null;
      if(presentButton)
      {
         presentButton.removeEventListener("triggered",triggeredPresentButton);
         presentButton = null;
      }
   }
}
