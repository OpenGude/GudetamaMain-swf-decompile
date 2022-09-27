package gudetama.scene.world
{
   import feathers.controls.IScrollBar;
   import feathers.controls.List;
   import feathers.controls.ScrollBar;
   import feathers.controls.renderers.IListItemRenderer;
   import feathers.data.ListCollection;
   import feathers.layout.FlowLayout;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.UserPresentMoneyData;
   import gudetama.data.compati.UserProfileData;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.scene.friend.FriendDetailDialog;
   import gudetama.scene.home.HomeScene;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.util.SpriteExtractor;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class AssistNoticeDialog extends BaseScene
   {
       
      
      private var callback:Function;
      
      private var tabGroup:TabGroup;
      
      private var list:List;
      
      private var closeButton:ContainerButton;
      
      private var extractor:SpriteExtractor;
      
      private var loadCount:int;
      
      private var collection:ListCollection;
      
      private var assists:Array;
      
      private var presents:Array;
      
      public function AssistNoticeDialog(param1:Function)
      {
         collection = new ListCollection();
         super(2);
         this.callback = param1;
      }
      
      public static function show(param1:Function = null) : void
      {
         var _loc2_:int = UserDataWrapper.wrapper.getNumAssistFromFriend() + UserDataWrapper.wrapper.getNumPresentMoneyFromFriend();
         if(_loc2_ <= 0)
         {
            if(param1)
            {
               param1();
            }
            return;
         }
         Engine.pushScene(new AssistNoticeDialog(param1),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"AssistNoticeDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            tabGroup = new TabGroup(_loc2_,triggeredTabUI);
            list = _loc2_.getChildByName("list") as List;
            closeButton = _loc2_.getChildByName("closeButton") as ContainerButton;
            closeButton.addEventListener("triggered",triggeredCloseButton);
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         setupLayoutForTask(queue,"_AssistNoticeItem",function(param1:Object):void
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
            gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(16777446),function(param1:Array):void
            {
               assists = !!param1[0] ? param1[0] : [];
               presents = !!param1[1] ? param1[1] : [];
               UserDataWrapper.wrapper.setNumAssistFromFriend(0);
               UserDataWrapper.wrapper.setNumPresentMoneyFromFriend(0);
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
         list.setItemRendererFactoryWithID("present",function():IListItemRenderer
         {
            return new PresentNoticeListItemRenderer(extractor,triggeredDetailButton);
         });
         list.setItemRendererFactoryWithID("assist",function():IListItemRenderer
         {
            return new AssistNoticeListItemRenderer(extractor,triggeredDetailButton);
         });
         list.factoryIDFunction = function(param1:Object):String
         {
            if(param1 is UserPresentMoneyData)
            {
               return "present";
            }
            return "assist";
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
         tabGroup.setup([assists.length,presents.length]);
         if(assists.length > 0)
         {
            tabGroup.triggeredTabUI(TabGroup.TYPE_ASSIST);
         }
         else
         {
            tabGroup.triggeredTabUI(1);
         }
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(AssistNoticeDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         Engine.broadcastEventToSceneStackWith("update_scene");
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(AssistNoticeDialog);
         });
      }
      
      private function triggeredTabUI(param1:int) : void
      {
         if(param1 == TabGroup.TYPE_ASSIST)
         {
            setupAssist();
         }
         else
         {
            setupPresent();
         }
      }
      
      private function setupAssist() : void
      {
         var _loc1_:int = 0;
         collection.removeAll();
         _loc1_ = assists.length - 1;
         while(_loc1_ >= 0)
         {
            collection.addItem(assists[_loc1_]);
            _loc1_--;
         }
      }
      
      private function setupPresent() : void
      {
         var _loc1_:int = 0;
         collection.removeAll();
         _loc1_ = presents.length - 1;
         while(_loc1_ >= 0)
         {
            collection.addItem(presents[_loc1_]);
            _loc1_--;
         }
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
               Engine.showLoading(AssistNoticeDialog);
               var _loc1_:* = HttpConnector;
               if(gudetama.net.HttpConnector.mainConnector == null)
               {
                  gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
               }
               gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(163,encodedUid),function(param1:Array):void
               {
                  Engine.hideLoading(AssistNoticeDialog);
                  profile.followState = 0;
                  UserDataWrapper.friendPart.removeFollow(profile);
                  UserDataWrapper.friendPart.removeFollower(profile);
                  UserDataWrapper.friendPart.removeFriend(profile);
                  collection.updateAll();
               });
            },
            "backFromRoomFunc":function():void
            {
               ResidentMenuUI_Gudetama.getInstance().sendChangeState(60,function():void
               {
                  Engine.switchScene(new HomeScene());
               });
            }
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(AssistNoticeDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(AssistNoticeDialog);
            Engine.popScene(scene);
            if(callback)
            {
               callback();
            }
         });
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         if(tabGroup)
         {
            tabGroup.dispose();
            tabGroup = null;
         }
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

import starling.display.Sprite;

class TabGroup
{
   
   public static const TYPE_ASSIST:int = 0;
   
   public static const TYPE_PRESENT:int = 1;
   
   public static const TYPE_NUM:int = 2;
    
   
   private var callback:Function;
   
   private var tabUIs:Vector.<TabUI>;
   
   function TabGroup(param1:Sprite, param2:Function)
   {
      var _loc5_:int = 0;
      tabUIs = new Vector.<TabUI>();
      super();
      this.callback = param2;
      var _loc4_:Sprite = param1.getChildByName("bgGroup") as Sprite;
      var _loc3_:Sprite = param1.getChildByName("touchFieldGroup") as Sprite;
      _loc5_ = 0;
      while(_loc5_ < 2)
      {
         tabUIs.push(new TabUI(_loc4_.getChildByName("bg" + _loc5_) as Sprite,_loc3_.getChildByName("touchField" + _loc5_) as Sprite,_loc5_,triggeredTabUI));
         _loc5_++;
      }
   }
   
   public function setup(param1:Array) : void
   {
      var _loc2_:int = 0;
      _loc2_ = 0;
      while(_loc2_ < tabUIs.length)
      {
         tabUIs[_loc2_].setup(param1[_loc2_]);
         _loc2_++;
      }
   }
   
   public function triggeredTabUI(param1:int) : void
   {
      var _loc2_:int = 0;
      _loc2_ = 0;
      while(_loc2_ < tabUIs.length)
      {
         tabUIs[_loc2_].setVisible(_loc2_ == param1);
         _loc2_++;
      }
      callback(param1);
   }
   
   public function dispose() : void
   {
      callback = null;
      for each(var _loc1_ in tabUIs)
      {
         _loc1_.dispose();
      }
      tabUIs.length = 0;
      tabUIs = null;
   }
}

import flash.geom.Point;
import gudetama.engine.SoundManager;
import gudetama.ui.UIBase;
import muku.text.ColorTextField;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Touch;
import starling.events.TouchEvent;

class TabUI extends UIBase
{
    
   
   private var touchFieldGroup:Sprite;
   
   private var type:int;
   
   private var callback:Function;
   
   private var quad:Quad;
   
   private var labelText:ColorTextField;
   
   private var noticeGroup:Sprite;
   
   private var numText:ColorTextField;
   
   private var localPoint:Point;
   
   function TabUI(param1:Sprite, param2:Sprite, param3:int, param4:Function)
   {
      localPoint = new Point();
      super(param1);
      this.touchFieldGroup = param2;
      this.type = param3;
      this.callback = param4;
      quad = param2.getChildByName("quad") as Quad;
      quad.addEventListener("touch",onTouch);
      labelText = param2.getChildByName("text") as ColorTextField;
      noticeGroup = param2.getChildByName("noticeGroup") as Sprite;
      numText = noticeGroup.getChildByName("num") as ColorTextField;
   }
   
   public function setup(param1:int) : void
   {
      noticeGroup.visible = param1 > 0;
      numText.text#2 = param1.toString();
   }
   
   override public function setVisible(param1:Boolean) : void
   {
      super.setVisible(param1);
      quad.touchable = !param1;
      labelText.color = !!param1 ? 5521974 : 16777215;
   }
   
   private function onTouch(param1:TouchEvent) : void
   {
      var _loc2_:Touch = param1.getTouch(quad);
      if(_loc2_ == null)
      {
         return;
      }
      if(_loc2_.phase == "ended")
      {
         SoundManager.playEffect("btn_normal");
         localPoint.setTo(_loc2_.globalX,_loc2_.globalY);
         touchFieldGroup.globalToLocal(localPoint,localPoint);
         if(touchFieldGroup.hitTest(localPoint))
         {
            callback(type);
         }
      }
   }
   
   public function dispose() : void
   {
      touchFieldGroup = null;
      callback = null;
      if(quad)
      {
         quad.removeEventListener("touch",onTouch);
         quad = null;
      }
      labelText = null;
      noticeGroup = null;
      numText = null;
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class AssistNoticeListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var callback:Function;
   
   private var displaySprite:Sprite;
   
   private var assistNoticeUI:AssistNoticeUI;
   
   function AssistNoticeListItemRenderer(param1:SpriteExtractor, param2:Function)
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
      assistNoticeUI = new AssistNoticeUI(displaySprite,callback);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      assistNoticeUI.updateData(data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      displaySprite = null;
      assistNoticeUI.dispose();
      assistNoticeUI = null;
      super.dispose();
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.AssistInfo;
import gudetama.data.compati.GudetamaDef;
import gudetama.data.compati.UsefulDef;
import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import gudetama.util.TimeZoneUtil;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class AssistNoticeUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var iconImage:Image;
   
   private var imgSns:Image;
   
   private var nameText:ColorTextField;
   
   private var levelText:ColorTextField;
   
   private var descText:ColorTextField;
   
   private var timeText:ColorTextField;
   
   private var lineImage:Image;
   
   private var detailButton:ContainerButton;
   
   private var assist:AssistInfo;
   
   function AssistNoticeUI(param1:Sprite, param2:Function)
   {
      super(param1);
      this.callback = param2;
      iconImage = param1.getChildByName("icon") as Image;
      imgSns = param1.getChildByName("imgSns") as Image;
      nameText = param1.getChildByName("name") as ColorTextField;
      levelText = param1.getChildByName("level") as ColorTextField;
      descText = param1.getChildByName("desc") as ColorTextField;
      timeText = param1.getChildByName("time") as ColorTextField;
      lineImage = param1.getChildByName("line") as Image;
      detailButton = param1.getChildByName("detailButton") as ContainerButton;
      detailButton.addEventListener("triggered",triggeredDetailButton);
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      if(!data)
      {
         return;
      }
      assist = data as AssistInfo;
      var gudetamaDef:GudetamaDef = GameSetting.getGudetama(assist.gudetamaId);
      var usefulDef:UsefulDef = GameSetting.getUseful(assist.usefulId);
      iconImage.visible = false;
      imgSns.visible = false;
      if(assist.snsProfileImage != null)
      {
         GudetamaUtil.loadByteArray2Texture(assist.snsProfileImage,function(param1:Texture):void
         {
            iconImage.texture = param1;
            iconImage.visible = true;
         });
         TextureCollector.loadSnsImage(assist.snsType,null,function(param1:Texture):void
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
         iconImage.visible = false;
         TextureCollector.loadTextureRsrc("avatar-" + GameSetting.getAvatar(assist.avatar).rsrc,function(param1:Texture):void
         {
            iconImage.texture = param1;
            iconImage.visible = true;
         });
      }
      nameText.text#2 = assist.playerName;
      levelText.text#2 = assist.playerRank.toString();
      descText.text#2 = StringUtil.format(GameSetting.getUIText("assistNotice.item.assist.desc"),usefulDef.name#2);
      var date:Date = new Date();
      date.setTime(TimeZoneUtil.offsetSecsToEpochMillis(assist.assistTimeSecs));
      timeText.text#2 = StringUtil.format(GameSetting.getUIText("assistNotice.item.time"),date.getFullYear(),StringUtil.decimalFormat("00",date.getMonth() + 1),StringUtil.decimalFormat("00",date.getDate()),StringUtil.decimalFormat("00",date.getHours()),StringUtil.decimalFormat("00",date.getMinutes()));
      lineImage.visible = false;
      TextureCollector.loadTexture("home1@line_orange",function(param1:Texture):void
      {
         if(lineImage == null)
         {
            return;
         }
         lineImage.texture = param1;
         lineImage.visible = true;
      });
      detailButton.visible = UserDataWrapper.friendPart.getFriendProfile(assist.encodedUid);
   }
   
   private function triggeredDetailButton(param1:Event) : void
   {
      if(callback)
      {
         callback(assist.encodedUid);
      }
   }
   
   public function dispose() : void
   {
      callback = null;
      nameText = null;
      levelText = null;
      descText = null;
      timeText = null;
      lineImage = null;
      if(detailButton)
      {
         detailButton.removeEventListener("triggered",triggeredDetailButton);
         detailButton = null;
      }
      assist = null;
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class PresentNoticeListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var callback:Function;
   
   private var displaySprite:Sprite;
   
   private var presentNoticeUI:PresentNoticeUI;
   
   function PresentNoticeListItemRenderer(param1:SpriteExtractor, param2:Function)
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
      presentNoticeUI = new PresentNoticeUI(displaySprite,callback);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      presentNoticeUI.updateData(data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      displaySprite = null;
      presentNoticeUI.dispose();
      presentNoticeUI = null;
      super.dispose();
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.UserPresentMoneyData;
import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import gudetama.util.TimeZoneUtil;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class PresentNoticeUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var iconImage:Image;
   
   private var imgSns:Image;
   
   private var nameText:ColorTextField;
   
   private var levelText:ColorTextField;
   
   private var descText:ColorTextField;
   
   private var timeText:ColorTextField;
   
   private var lineImage:Image;
   
   private var detailButton:ContainerButton;
   
   private var present:UserPresentMoneyData;
   
   function PresentNoticeUI(param1:Sprite, param2:Function)
   {
      super(param1);
      this.callback = param2;
      iconImage = param1.getChildByName("icon") as Image;
      imgSns = param1.getChildByName("imgSns") as Image;
      nameText = param1.getChildByName("name") as ColorTextField;
      levelText = param1.getChildByName("level") as ColorTextField;
      descText = param1.getChildByName("desc") as ColorTextField;
      timeText = param1.getChildByName("time") as ColorTextField;
      lineImage = param1.getChildByName("line") as Image;
      detailButton = param1.getChildByName("detailButton") as ContainerButton;
      detailButton.addEventListener("triggered",triggeredDetailButton);
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      if(!data)
      {
         return;
      }
      present = data as UserPresentMoneyData;
      iconImage.visible = false;
      imgSns.visible = false;
      if(present.snsProfileImage != null)
      {
         GudetamaUtil.loadByteArray2Texture(present.snsProfileImage,function(param1:Texture):void
         {
            iconImage.texture = param1;
            iconImage.visible = true;
         });
         TextureCollector.loadSnsImage(present.snsType,null,function(param1:Texture):void
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
         iconImage.visible = false;
         TextureCollector.loadTextureRsrc("avatar-" + GameSetting.getAvatar(present.avatar).rsrc,function(param1:Texture):void
         {
            iconImage.texture = param1;
            iconImage.visible = true;
         });
      }
      nameText.text#2 = present.playerName;
      levelText.text#2 = present.playerRank.toString();
      descText.text#2 = StringUtil.format(GameSetting.getUIText("assistNotice.item.present.desc"),StringUtil.getNumStringCommas(present.money));
      var date:Date = new Date();
      date.setTime(TimeZoneUtil.offsetSecsToEpochMillis(present.presentTimeSecs));
      timeText.text#2 = StringUtil.format(GameSetting.getUIText("assistNotice.item.time"),date.getFullYear(),StringUtil.decimalFormat("00",date.getMonth() + 1),StringUtil.decimalFormat("00",date.getDate()),StringUtil.decimalFormat("00",date.getHours()),StringUtil.decimalFormat("00",date.getMinutes()));
      lineImage.visible = false;
      TextureCollector.loadTexture("home1@line_yellow",function(param1:Texture):void
      {
         if(lineImage == null)
         {
            return;
         }
         lineImage.texture = param1;
         lineImage.visible = true;
      });
      detailButton.visible = UserDataWrapper.friendPart.getFriendProfile(present.encodedUid);
   }
   
   private function triggeredDetailButton(param1:Event) : void
   {
      if(callback)
      {
         callback(present.encodedUid);
      }
   }
   
   public function dispose() : void
   {
      callback = null;
      nameText = null;
      levelText = null;
      descText = null;
      timeText = null;
      lineImage = null;
      if(detailButton)
      {
         detailButton.removeEventListener("triggered",triggeredDetailButton);
         detailButton = null;
      }
   }
}
