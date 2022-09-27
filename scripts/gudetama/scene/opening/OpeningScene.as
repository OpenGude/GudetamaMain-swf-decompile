package gudetama.scene.opening
{
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.scene.home.HomeScene;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import muku.util.StarlingUtil;
   import starling.display.Quad;
   
   public class OpeningScene extends BaseScene
   {
      
      public static const OPENING_PHASE_TERMS_OF_SERVICE:uint = 0;
      
      public static const PROGRESS_GENDER_AND_NAME:uint = 1;
       
      
      private var currentPhase:int = -1;
      
      private var areaIds:Array;
      
      private var filter:Quad;
      
      public function OpeningScene(param1:uint, param2:Array)
      {
         super(0);
         currentPhase = param1;
         this.areaIds = param2;
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"OpeningLayout",function(param1:Object):void
         {
            displaySprite = param1.object;
            filter = StarlingUtil.find(displaySprite,"filter2") as Quad;
            filter.visible = false;
            addChild(displaySprite);
         });
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            changePhase();
         });
         queue.startTask(onProgress);
      }
      
      private function changePhase(param1:int = -1) : void
      {
         var nextPhase:int = param1;
         if(nextPhase > 0)
         {
            currentPhase = nextPhase;
         }
         Engine.unlockTouchInput(OpeningScene);
         switch(int(currentPhase))
         {
            case 0:
               agreeTosPhase.show(function():void
               {
                  changePhase(1);
               });
               break;
            case 1:
               InputGenderAndPlayerNamePhase.show(areaIds,function():void
               {
                  ResidentMenuUI_Gudetama.getInstance().sendChangeState(60,function():void
                  {
                     Engine.switchScene(new HomeScene());
                  });
               });
         }
      }
      
      override protected function addedToContainer() : void
      {
         showResidentMenuUI(4);
         setBackButtonCallback(null);
      }
      
      override public function dispose() : void
      {
         super.dispose();
      }
   }
}

import gudetama.data.GameSetting;
import gudetama.engine.BaseScene;
import gudetama.engine.Engine;
import gudetama.engine.TweenAnimator;
import gudetama.net.HttpConnector;
import gudetama.net.PacketUtil;
import gudetama.scene.title.TitleScene;
import gudetama.ui.WebViewDialog;
import muku.display.ContainerButton;
import starling.display.Sprite;
import starling.events.Event;

class agreeTosPhase extends BaseScene
{
    
   
   private var callback:Function;
   
   private var closeButton:ContainerButton;
   
   private var decideButton:ContainerButton;
   
   private var tosButton:ContainerButton;
   
   private var ppButton:ContainerButton;
   
   function agreeTosPhase(param1:Function)
   {
      super(2);
      callback = param1;
   }
   
   public static function show(param1:Function) : void
   {
      Engine.pushScene(new agreeTosPhase(param1),1,true);
   }
   
   override protected function setupProgress(param1:Function) : void
   {
      var onProgress:Function = param1;
      Engine.setupLayoutForTask(queue,"TosDialog",function(param1:Object):void
      {
         displaySprite = param1.object;
         var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
         closeButton = _loc2_.getChildByName("btn_no") as ContainerButton;
         closeButton.addEventListener("triggered",triggeredCloseButton);
         decideButton = _loc2_.getChildByName("btn_yes") as ContainerButton;
         decideButton.addEventListener("triggered",triggeredDecideButton);
         var _loc3_:* = Engine;
         if(gudetama.engine.Engine.isIosPlatform() || true)
         {
            TweenAnimator.startItself(closeButton,"ios");
            TweenAnimator.startItself(decideButton,"ios");
         }
         else
         {
            TweenAnimator.startItself(closeButton,"android");
            TweenAnimator.startItself(decideButton,"android");
         }
         tosButton = _loc2_.getChildByName("btnTOS") as ContainerButton;
         tosButton.addEventListener("triggered",triggeredTosButton);
         ppButton = _loc2_.getChildByName("btnPP") as ContainerButton;
         ppButton.addEventListener("triggered",triggeredPpButton);
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
   
   override protected function addedToContainer() : void
   {
      Engine.lockTouchInput(agreeTosPhase);
      setBackButtonCallback(backButtonCallback);
   }
   
   override protected function transitionOpenFinished() : void
   {
      displaySprite.visible = true;
      TweenAnimator.startItself(displaySprite,"show",false,function():void
      {
         Engine.unlockTouchInput(agreeTosPhase);
      });
   }
   
   override public function backButtonCallback() : void
   {
      super.backButtonCallback();
      Engine.lockTouchInput(agreeTosPhase);
      setBackButtonCallback(null);
      TweenAnimator.startItself(displaySprite,"hide",false,function():void
      {
         Engine.unlockTouchInput(agreeTosPhase);
         Engine.switchScene(new TitleScene());
      });
   }
   
   private function triggeredDecideButton(param1:Event) : void
   {
      var event:Event = param1;
      TweenAnimator.startItself(displaySprite,"hide",false,function():void
      {
         var _loc1_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(PACKET_CHECKED_TERMS_OF_SERVICE),function(param1:Array):void
         {
            callback();
         });
      });
   }
   
   private function triggeredCloseButton(param1:Event) : void
   {
      backButtonCallback();
   }
   
   private function triggeredTosButton(param1:Event) : void
   {
      var event:Event = param1;
      WebViewDialog.show(GameSetting.getOtherText("url.tos"),function():void
      {
      });
   }
   
   private function triggeredPpButton(param1:Event) : void
   {
      var event:Event = param1;
      WebViewDialog.show(GameSetting.getOtherText("url.pp"),function():void
      {
      });
   }
   
   override public function dispose() : void
   {
      closeButton.removeEventListener("triggered",triggeredCloseButton);
      closeButton = null;
      decideButton.removeEventListener("triggered",triggeredDecideButton);
      decideButton = null;
      tosButton.removeEventListener("triggered",triggeredTosButton);
      tosButton = null;
      ppButton.removeEventListener("triggered",triggeredPpButton);
      ppButton = null;
      callback = null;
      super.dispose();
   }
}

import gudetama.data.DataStorage;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.FirstLoginInfo;
import gudetama.data.compati.UserData;
import gudetama.engine.BaseScene;
import gudetama.engine.Engine;
import gudetama.engine.TweenAnimator;
import gudetama.net.HttpConnector;
import gudetama.net.PacketUtil;
import gudetama.scene.opening.OpeningScene;
import gudetama.scene.profile.CommentSelectDialog;
import gudetama.scene.profile.NameInputDialog;
import gudetama.ui.MessageDialog;
import gudetama.util.TimeZoneUtil;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import muku.util.StarlingUtil;
import starling.display.Sprite;
import starling.events.Event;

class InputGenderAndPlayerNamePhase extends BaseScene
{
    
   
   private var areaIds:Array;
   
   private var callback:Function;
   
   private var manSprite:Sprite;
   
   private var manButton:ContainerButton;
   
   private var womanSprite:Sprite;
   
   private var womanButton:ContainerButton;
   
   private var noneSprite:Sprite;
   
   private var noneButton:ContainerButton;
   
   private var genderButton:ContainerButton;
   
   private var commentButton:ContainerButton;
   
   private var nameInputButton:ContainerButton;
   
   private var areaButton:ContainerButton;
   
   private var selectArea:int = -1;
   
   private var selectComment:int = -1;
   
   private var playerName:String;
   
   private var selectAvatar:int = -1;
   
   private var okButton:ContainerButton;
   
   function InputGenderAndPlayerNamePhase(param1:Array, param2:Function)
   {
      super(1);
      this.areaIds = param1;
      callback = param2;
   }
   
   public static function show(param1:Array, param2:Function) : void
   {
      Engine.pushScene(new InputGenderAndPlayerNamePhase(param1,param2),1,true);
   }
   
   override public function dispose() : void
   {
      super.dispose();
      callback = null;
   }
   
   override protected function setupProgress(param1:Function) : void
   {
      var onProgress:Function = param1;
      Engine.setupLayoutForTask(queue,"_TitleProfileSettingDialog",function(param1:Object):void
      {
         var layout:Object = param1;
         displaySprite = layout.object;
         manSprite = StarlingUtil.find(displaySprite,"man") as Sprite;
         manButton = StarlingUtil.find(manSprite,"btn") as ContainerButton;
         manButton.addEventListener("triggered",function(param1:Event):void
         {
            switchAvatar(0);
         });
         TweenAnimator.startItself(manSprite,"off");
         womanSprite = StarlingUtil.find(displaySprite,"woman") as Sprite;
         womanButton = StarlingUtil.find(womanSprite,"btn") as ContainerButton;
         womanButton.addEventListener("triggered",function(param1:Event):void
         {
            switchAvatar(1);
         });
         TweenAnimator.startItself(womanSprite,"off");
         noneSprite = StarlingUtil.find(displaySprite,"none") as Sprite;
         noneButton = StarlingUtil.find(noneSprite,"btn") as ContainerButton;
         noneButton.addEventListener("triggered",function(param1:Event):void
         {
            switchAvatar(2);
         });
         TweenAnimator.startItself(noneSprite,"off");
         okButton = StarlingUtil.find(displaySprite,"btn_ok") as ContainerButton;
         okButton.addEventListener("triggered",triggeredOKButton);
         commentButton = StarlingUtil.find(displaySprite,"btnComment") as ContainerButton;
         var txtComment:ColorTextField = commentButton.getChildByName("txtComment") as ColorTextField;
         selectComment = UserDataWrapper.wrapper.getComment();
         txtComment.text#2 = GameSetting.getComment(selectComment);
         commentButton.addEventListener("triggered",function(param1:Event):void
         {
            CommentSelectDialog.show(updatePlayerComment,true);
         });
         nameInputButton = StarlingUtil.find(displaySprite,"btnName") as ContainerButton;
         nameInputButton.addEventListener("triggered",function(param1:Event):void
         {
            NameInputDialog.show(playerName,updatePlayerName,true);
         });
         areaButton = StarlingUtil.find(displaySprite,"btnArea") as ContainerButton;
         areaButton.addEventListener("triggered",function(param1:Event):void
         {
            AreaSelectDialog.show(areaIds,updatePlayerArea);
         });
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
   
   override protected function addedToContainer() : void
   {
      setVisibleState(4);
      Engine.addSequentialCallback(function():void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show");
      });
   }
   
   private function switchAvatar(param1:int) : void
   {
      if(selectAvatar == param1)
      {
         return;
      }
      if(param1 == 0)
      {
         TweenAnimator.startItself(manSprite,"on");
         TweenAnimator.startItself(womanSprite,"off");
         TweenAnimator.startItself(noneSprite,"off");
      }
      else if(param1 == 1)
      {
         TweenAnimator.startItself(manSprite,"off");
         TweenAnimator.startItself(womanSprite,"on");
         TweenAnimator.startItself(noneSprite,"off");
      }
      else
      {
         TweenAnimator.startItself(manSprite,"off");
         TweenAnimator.startItself(womanSprite,"off");
         TweenAnimator.startItself(noneSprite,"on");
      }
      selectAvatar = param1;
   }
   
   private function triggeredOKButton(param1:Event) : void
   {
      var event:Event = param1;
      okButton.setEnableWithDrawCache(false);
      var caution:String = "";
      if(!checkPlayerNameLength())
      {
         var caution:String = caution + GameSetting.getUIText("openingScene.caution.name");
      }
      if(selectArea < 0)
      {
         if(caution.length > 0)
         {
            caution += "\n";
         }
         caution += GameSetting.getUIText("openingScene.caution.area");
      }
      if(selectAvatar < 0)
      {
         if(caution.length > 0)
         {
            caution += "\n";
         }
         caution += GameSetting.getUIText("openingScene.caution.avatar");
      }
      if(caution.length > 0)
      {
         MessageDialog.show(1,caution,function():void
         {
            okButton.setEnableWithDrawCache(true);
         },GameSetting.getUIText("openingScene.caution.title"),0,null,true);
         return;
      }
      checkFirstLoginInfo(function(param1:int):void
      {
         var result:int = param1;
         if(result == 0)
         {
            TweenAnimator.startItself(displaySprite,"hide",false,function():void
            {
               callback();
            });
         }
         else
         {
            okButton.setEnableWithDrawCache(true);
         }
      });
   }
   
   private function checkFirstLoginInfo(param1:Function) : void
   {
      var callback:Function = param1;
      var gudeName:String = GameSetting.getUIText("profile.area.gudetama." + selectArea);
      MessageDialog.show(2,GameSetting.getUIText("%openingScene.confirm.name") + playerName + "\n" + GameSetting.getUIText("%openingScene.confirm.area") + GameSetting.getUIText("profile.area." + selectArea) + " " + gudeName + "\n" + GameSetting.getUIText("%openingScene.confirm.message"),function(param1:int):void
      {
         var choose:int = param1;
         if(choose == 1)
         {
            callback(-1);
         }
         else
         {
            Engine.lockTouchInput(OpeningScene);
            var info:FirstLoginInfo = new FirstLoginInfo();
            info.name#2 = playerName;
            info.area = selectArea;
            info.comment = selectComment;
            info.timeZone#2 = TimeZoneUtil.getTimeZone();
            info.locale = Engine.getLocale();
            info.deckIndex = -1;
            info.avatar = selectAvatar;
            var _loc3_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithObject(PACKET_SET_FIRSTLOGIN_INFO,info),function(param1:Array):void
            {
               var result:Array = param1;
               if(result)
               {
                  var userData:UserData = result[0] as UserData;
                  UserDataWrapper.init(userData);
                  var _loc3_:* = UserDataWrapper;
                  gudetama.data.UserDataWrapper.wrapper._data.timeZoneOffset = userData.timeZoneOffset;
                  var _loc4_:* = UserDataWrapper;
                  DataStorage.getLocalData().playerName = gudetama.data.UserDataWrapper.wrapper._data.playerName = playerName;
                  DataStorage.saveLocalData();
                  callback(0);
               }
               else
               {
                  MessageDialog.show(0,GameSetting.getUIText("%openingScene.wrong.playerName"),function():void
                  {
                     callback(-1);
                  },null,0,null,true);
               }
            });
         }
      },null,0,null,true);
   }
   
   private function updatePlayerArea(param1:int) : void
   {
      selectArea = param1;
      var _loc2_:ColorTextField = areaButton.getChildByName("txtArea") as ColorTextField;
      _loc2_.text#2 = GameSetting.getUIText("profile.area." + selectArea) + "  " + GameSetting.getUIText("profile.area.gudetama." + selectArea);
   }
   
   private function updatePlayerComment(param1:int) : void
   {
      selectComment = param1;
      var _loc2_:ColorTextField = commentButton.getChildByName("txtComment") as ColorTextField;
      _loc2_.text#2 = GameSetting.getComment(selectComment);
   }
   
   private function updatePlayerName(param1:String) : void
   {
      playerName = param1;
      var _loc2_:ColorTextField = nameInputButton.getChildByName("txtName") as ColorTextField;
      _loc2_.text#2 = param1;
   }
   
   private function checkPlayerNameLength() : Boolean
   {
      if(playerName == null)
      {
         return false;
      }
      var _loc1_:int = playerName.length;
      if(_loc1_ <= 0)
      {
         return false;
      }
      if(_loc1_ < 2 || _loc1_ > 8)
      {
         return false;
      }
      return true;
   }
}

import feathers.controls.IScrollBar;
import feathers.controls.List;
import feathers.controls.ScrollBar;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.FlowLayout;
import gudetama.data.GameSetting;
import gudetama.engine.BaseScene;
import gudetama.engine.Engine;
import gudetama.engine.TweenAnimator;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class AreaSelectDialog extends BaseScene
{
    
   
   private var areaIds:Array;
   
   private var callback:Function;
   
   private var list:List;
   
   private var extractor:SpriteExtractor;
   
   private var collection:ListCollection;
   
   private var selectAreaId:int;
   
   function AreaSelectDialog(param1:Array, param2:Function)
   {
      collection = new ListCollection();
      super(2);
      this.areaIds = param1;
      this.callback = param2;
   }
   
   public static function show(param1:Array, param2:Function) : void
   {
      Engine.pushScene(new AreaSelectDialog(param1,param2),0,false);
   }
   
   override protected function setupProgress(param1:Function) : void
   {
      var onProgress:Function = param1;
      Engine.setupLayoutForTask(queue,"_OpeningSelectAreaDialog",function(param1:Object):void
      {
         displaySprite = param1.object;
         var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
         list = _loc2_.getChildByName("list") as List;
         displaySprite.visible = false;
         addChild(displaySprite);
      });
      Engine.setupLayoutForTask(queue,"_AreaItem",function(param1:Object):void
      {
         extractor = SpriteExtractor.forGross(param1.object,param1);
      });
      queue.startTask(onProgress);
      queue.registerOnProgress(function(param1:Number):void
      {
         if(param1 < 1)
         {
            return;
         }
         procRegisterOnProgress();
      });
   }
   
   protected function procRegisterOnProgress() : void
   {
      var layout:FlowLayout = new FlowLayout();
      layout.horizontalAlign = "left";
      layout.horizontalGap = 14;
      layout.verticalGap = 14;
      layout.paddingTop = 14;
      list.layout = layout;
      list.itemRendererFactory = function():IListItemRenderer
      {
         return new AreaListItemRenderer(extractor,triggeredAreaItemUICallback);
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
      var _loc1_:* = null;
      var _loc2_:int = 0;
      var _loc3_:int = 0;
      _loc3_ = 0;
      if(areaIds != null)
      {
         _loc1_ = areaIds;
      }
      else
      {
         _loc1_ = [];
         _loc2_ = GameSetting.def.rule.gudetamaTeamIds.length;
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            _loc1_.push(_loc3_);
            _loc3_++;
         }
      }
      collection.removeAll();
      _loc3_ = 0;
      while(_loc3_ < _loc1_.length)
      {
         collection.addItem({"id":_loc1_[_loc3_]});
         _loc3_++;
      }
   }
   
   override protected function addedToContainer() : void
   {
      Engine.lockTouchInput(AreaSelectDialog);
      setBackButtonCallback(backButtonCallback);
      setVisibleState(4);
   }
   
   override public function backButtonCallback() : void
   {
      super.backButtonCallback();
      Engine.lockTouchInput(AreaSelectDialog);
      setBackButtonCallback(null);
      TweenAnimator.startItself(displaySprite,"hide",false,function():void
      {
         Engine.unlockTouchInput(AreaSelectDialog);
         Engine.popScene(scene);
      });
   }
   
   override protected function transitionOpenFinished() : void
   {
      displaySprite.visible = true;
      TweenAnimator.startItself(displaySprite,"show",false,function():void
      {
         Engine.unlockTouchInput(AreaSelectDialog);
      });
   }
   
   private function triggeredAreaItemUICallback(param1:int) : void
   {
      callback(param1);
      backButtonCallback();
   }
   
   override public function dispose() : void
   {
      list = null;
      extractor = null;
      collection = null;
      super.dispose();
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class AreaListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var callback:Function;
   
   private var displaySprite:Sprite;
   
   private var areaItemUI:AreaItemUI;
   
   function AreaListItemRenderer(param1:SpriteExtractor, param2:Function)
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
      super.initialize();
      displaySprite = extractor.duplicateAll() as Sprite;
      areaItemUI = new AreaItemUI(displaySprite,callback);
      addChild(displaySprite);
   }
   
   override public function set data#2(param1:Object) : void
   {
      super.data#2 = param1;
      if(param1 == null)
      {
         return;
      }
      areaItemUI.init(_data.id);
   }
   
   override protected function commitData() : void
   {
      areaItemUI.updateData(data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      callback = null;
      displaySprite = null;
      areaItemUI.dispose();
      areaItemUI = null;
      super.dispose();
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class AreaItemUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var button:ContainerButton;
   
   private var area:ColorTextField;
   
   private var gudeName:ColorTextField;
   
   private var imgGudetama:Image;
   
   private var id:int;
   
   function AreaItemUI(param1:Sprite, param2:Function)
   {
      super(param1);
      this.callback = param2;
      button = param1.getChildByName("button") as ContainerButton;
      button.addEventListener("triggered",triggeredButton);
      area = button.getChildByName("area") as ColorTextField;
      imgGudetama = button.getChildByName("imgGudetama") as Image;
      gudeName = button.getChildByName("gudeName") as ColorTextField;
   }
   
   public function init(param1:int) : void
   {
      var _id:int = param1;
      area.text#2 = GameSetting.getUIText("profile.area." + _id);
      gudeName.text#2 = GameSetting.getUIText("profile.area.gudetama." + _id);
      var gudeId:int = GameSetting.getRule().gudetamaTeamIds[_id];
      imgGudetama.visible = false;
      TextureCollector.loadTextureRsrc(GudetamaUtil.getGudetamaRsrcIconName(gudeId),function(param1:Texture):void
      {
         imgGudetama.texture = param1;
         imgGudetama.visible = true;
      });
   }
   
   public function updateData(param1:Object) : void
   {
      if(!param1)
      {
         return;
      }
      id = param1.id;
      button.helperObject = {"renderer":this};
   }
   
   private function triggeredButton(param1:Event) : void
   {
      callback(id);
   }
   
   public function dispose() : void
   {
      callback = null;
      button.removeEventListener("triggered",triggeredButton);
      button = null;
   }
}

import gudetama.engine.BaseScene;
import gudetama.engine.Engine;
import gudetama.engine.TweenAnimator;
import muku.display.ContainerButton;
import starling.display.Sprite;

class GenderSelectDialog extends BaseScene
{
    
   
   private var callback:Function;
   
   private var btnMan:ContainerButton;
   
   private var btnWoman:ContainerButton;
   
   private var btnNone:ContainerButton;
   
   private var selectGenderId:int;
   
   function GenderSelectDialog(param1:Function)
   {
      super(2);
      this.callback = param1;
   }
   
   public static function show(param1:Function) : void
   {
      Engine.pushScene(new GenderSelectDialog(param1),0,false);
   }
   
   override protected function setupProgress(param1:Function) : void
   {
      var onProgress:Function = param1;
      Engine.setupLayoutForTask(queue,"_OpeningSelectGenderDialog",function(param1:Object):void
      {
         displaySprite = param1.object;
         var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
         btnMan = _loc2_.getChildByName("btnMan") as ContainerButton;
         btnMan.addEventListener("triggered",triggeredButtonMan);
         btnWoman = _loc2_.getChildByName("btnWoman") as ContainerButton;
         btnWoman.addEventListener("triggered",triggeredButtonWoman);
         btnNone = _loc2_.getChildByName("btnNone") as ContainerButton;
         btnNone.addEventListener("triggered",triggeredButtonNone);
         displaySprite.visible = false;
         addChild(displaySprite);
      });
      queue.startTask(onProgress);
      queue.registerOnProgress(function(param1:Number):void
      {
         if(param1 < 1)
         {
            return;
         }
      });
   }
   
   override protected function addedToContainer() : void
   {
      Engine.lockTouchInput(GenderSelectDialog);
      setBackButtonCallback(backButtonCallback);
   }
   
   override public function backButtonCallback() : void
   {
      super.backButtonCallback();
      Engine.lockTouchInput(GenderSelectDialog);
      setBackButtonCallback(null);
      TweenAnimator.startItself(displaySprite,"hide",false,function():void
      {
         Engine.unlockTouchInput(GenderSelectDialog);
         Engine.popScene(scene);
      });
   }
   
   override protected function transitionOpenFinished() : void
   {
      displaySprite.visible = true;
      TweenAnimator.startItself(displaySprite,"show",false,function():void
      {
         Engine.unlockTouchInput(GenderSelectDialog);
      });
   }
   
   private function triggeredButtonMan() : void
   {
      selectGenderId = 0;
      triggeredGenderItemUICallback(selectGenderId);
   }
   
   private function triggeredButtonWoman() : void
   {
      selectGenderId = 1;
      triggeredGenderItemUICallback(selectGenderId);
   }
   
   private function triggeredButtonNone() : void
   {
      selectGenderId = 2;
      triggeredGenderItemUICallback(selectGenderId);
   }
   
   private function triggeredGenderItemUICallback(param1:int) : void
   {
      callback(param1);
      backButtonCallback();
   }
   
   override public function dispose() : void
   {
      super.dispose();
   }
}
