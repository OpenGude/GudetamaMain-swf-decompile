package gudetama.scene.profile
{
   import feathers.controls.IScrollBar;
   import feathers.controls.List;
   import feathers.controls.ScrollBar;
   import feathers.controls.renderers.IListItemRenderer;
   import feathers.controls.supportClasses.ListDataViewPort;
   import feathers.data.ListCollection;
   import feathers.layout.FlowLayout;
   import gudetama.data.DataStorage;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.AvatarData;
   import gudetama.data.compati.AvatarDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.scene.friend.SnsFriendListDialog;
   import gudetama.util.SpriteExtractor;
   import muku.display.ContainerButton;
   import muku.display.SimpleImageButton;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class AvatarSelectDialog extends BaseScene
   {
       
      
      private var callback:Function;
      
      private var list:List;
      
      private var closeButton:ContainerButton;
      
      private var decideButton:ContainerButton;
      
      private var btnLinkSns:SimpleImageButton;
      
      private var extractor:SpriteExtractor;
      
      private var collection:ListCollection;
      
      private var selectAvatarId:int;
      
      private var snsType:int = -1;
      
      private var forceCallback:Boolean;
      
      public function AvatarSelectDialog(param1:Function)
      {
         collection = new ListCollection();
         super(2);
         this.callback = param1;
      }
      
      public static function show(param1:Function) : void
      {
         Engine.pushScene(new AvatarSelectDialog(param1),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"AvatarDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            closeButton = _loc2_.getChildByName("btn_back") as ContainerButton;
            closeButton.addEventListener("triggered",triggeredCloseButton);
            decideButton = _loc2_.getChildByName("btn_decide") as ContainerButton;
            decideButton.addEventListener("triggered",triggeredDecideButton);
            btnLinkSns = _loc2_.getChildByName("btnLinkSns") as SimpleImageButton;
            btnLinkSns.addEventListener("triggered",triggeredLinkSns);
            btnLinkSns.visible = false;
            list = _loc2_.getChildByName("list") as List;
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         Engine.setupLayoutForTask(queue,"_AvatarItem",function(param1:Object):void
         {
            extractor = SpriteExtractor.forGross(param1.object,param1);
         });
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            procRegisterOnProgress();
         });
         queue.startTask(onProgress);
      }
      
      protected function procRegisterOnProgress() : void
      {
         var dialog:AvatarSelectDialog = this;
         var layout:FlowLayout = new FlowLayout();
         layout.horizontalAlign = "left";
         layout.paddingLeft = 7;
         layout.horizontalGap = 8;
         layout.verticalGap = 10;
         layout.paddingTop = 5;
         list.layout = layout;
         list.itemRendererFactory = function():IListItemRenderer
         {
            return new AvatarListItemRenderer(dialog,extractor,triggeredAvatarItemUICallback);
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
         list.addEventListener("triggered",selectAvatar);
         if(UserDataWrapper.useSnsLinkBanner())
         {
            btnLinkSns.visible = true;
         }
         else
         {
            TweenAnimator.startItself(decideButton,"nolink");
            TweenAnimator.startItself(closeButton,"nolink");
         }
         setup();
      }
      
      private function setup() : void
      {
         var _loc1_:int = UserDataWrapper.wrapper.getCurrentAvatar();
         var _loc2_:AvatarDef = GameSetting.getAvatar(_loc1_);
         updateIconList();
         var _loc3_:* = UserDataWrapper;
         snsType = gudetama.data.UserDataWrapper.wrapper._data.snsInterlockType;
         selectAvatarId = UserDataWrapper.wrapper.getCurrentAvatar();
      }
      
      private function updateIconList() : void
      {
         var _loc1_:* = null;
         var _loc6_:Boolean = false;
         collection.removeAll();
         if(UserDataWrapper.featurePart.existsFeature(13))
         {
            _loc1_ = DataStorage.getLocalData().getAllSnsImageTexture();
            if(_loc1_)
            {
               _loc6_ = false;
               for(var _loc2_ in _loc1_)
               {
                  if(_loc2_ == 0 && gudetama.data.UserDataWrapper.wrapper._data.snsTwitterUid || _loc2_ == 1 && gudetama.data.UserDataWrapper.wrapper._data.snsFacebookUid)
                  {
                     collection.addItem({
                        "texture":_loc1_[_loc2_],
                        "snskey":_loc2_
                     });
                     if(snsType == _loc2_)
                     {
                        _loc6_ = true;
                     }
                  }
               }
               if(snsType > -1 && !_loc6_)
               {
                  snsType = -1;
                  forceCallback = true;
               }
            }
         }
         var _loc3_:Object = UserDataWrapper.wrapper.getAvatarMap();
         var _loc4_:Array = [];
         for each(var _loc5_ in _loc3_)
         {
            if(_loc5_.acquired)
            {
               _loc4_.push(_loc5_.id#2);
            }
         }
         _loc4_.sort(ascendingKeyComparator);
         for each(_loc2_ in _loc4_)
         {
            collection.addItem({"id":_loc2_});
         }
      }
      
      private function ascendingKeyComparator(param1:int, param2:int) : Number
      {
         if(param1 > param2)
         {
            return 1;
         }
         if(param1 < param2)
         {
            return -1;
         }
         return 0;
      }
      
      private function selectAvatar(param1:Event) : void
      {
         var _loc9_:* = null;
         var _loc8_:* = null;
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:* = null;
         var _loc6_:int = 0;
         var _loc7_:* = null;
         if(param1.target is ContainerButton)
         {
            _loc5_ = (_loc8_ = (_loc9_ = param1.target as ContainerButton).helperObject.renderer).getAvatarId();
            _loc4_ = _loc8_.getSnsType();
            _loc2_ = UserDataWrapper.wrapper.getCurrentExtraAvatar();
            if(_loc2_ != -1 || _loc4_ != -1)
            {
               if(_loc4_ == _loc2_)
               {
                  return;
               }
            }
            else
            {
               if(getSelectedAvatarId() == _loc5_)
               {
                  return;
               }
               if(UserDataWrapper.wrapper.getCurrentAvatar() == _loc5_)
               {
                  return;
               }
            }
            _loc3_ = list.getChildAt(0) as ListDataViewPort;
            _loc6_ = 0;
            while(_loc6_ < _loc3_.numChildren)
            {
               (_loc7_ = AvatarListItemRenderer(_loc3_.getChildAt(_loc6_)).getAvatarUI()).setSelected(false);
               _loc6_++;
            }
            _loc8_.setSelected(true);
            snsType = _loc4_;
            selectAvatarId = _loc5_;
         }
      }
      
      public function getSelectedAvatarId() : int
      {
         return selectAvatarId;
      }
      
      public function getSelectedSnsType() : int
      {
         return snsType;
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(AvatarSelectDialog);
         setVisibleState(94);
         setBackButtonCallback(backButtonCallback);
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(AvatarSelectDialog);
         setBackButtonCallback(null);
         if(forceCallback)
         {
            procCallback();
         }
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(AvatarSelectDialog);
            Engine.popScene(scene);
         });
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(AvatarSelectDialog);
         });
      }
      
      private function triggeredDecideButton(param1:Event) : void
      {
         var event:Event = param1;
         if(UserDataWrapper.wrapper.getCurrentAvatar() != selectAvatarId || gudetama.data.UserDataWrapper.wrapper._data.snsInterlockType != snsType)
         {
            forceCallback = false;
            var _loc3_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithIntAndObject(201326791,new Array(selectAvatarId,snsType),DataStorage.getLocalData().getSnsImageByteArray(snsType)),function(param1:Array):void
            {
               UserDataWrapper.wrapper.setAvatar(selectAvatarId,snsType);
               procCallback();
            });
         }
         backButtonCallback();
      }
      
      private function procCallback() : void
      {
         if(snsType != -1)
         {
            var _loc1_:* = UserDataWrapper;
            callback(DataStorage.getLocalData().getSnsImageTexture(gudetama.data.UserDataWrapper.wrapper._data.snsInterlockType));
         }
         else
         {
            callback(GameSetting.getAvatar(selectAvatarId).rsrc);
         }
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      private function triggeredAvatarItemUICallback(param1:int) : void
      {
      }
      
      private function triggeredLinkSns() : void
      {
         SnsFriendListDialog.show(null,updateIconList);
      }
      
      override public function dispose() : void
      {
         list = null;
         closeButton.removeEventListener("triggered",triggeredCloseButton);
         closeButton = null;
         decideButton.removeEventListener("triggered",triggeredDecideButton);
         decideButton = null;
         btnLinkSns.removeEventListener("triggered",triggeredLinkSns);
         btnLinkSns = null;
         list = null;
         extractor = null;
         collection = null;
         super.dispose();
      }
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.scene.profile.AvatarSelectDialog;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class AvatarListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var dialog:AvatarSelectDialog;
   
   private var extractor:SpriteExtractor;
   
   private var callback:Function;
   
   private var displaySprite:Sprite;
   
   private var avatarItemUI:AvatarItemUI;
   
   function AvatarListItemRenderer(param1:AvatarSelectDialog, param2:SpriteExtractor, param3:Function)
   {
      super();
      this.dialog = param1;
      this.extractor = param2;
      this.callback = param3;
   }
   
   override protected function initialize() : void
   {
      if(displaySprite)
      {
         return;
      }
      super.initialize();
      displaySprite = extractor.duplicateAll() as Sprite;
      avatarItemUI = new AvatarItemUI(dialog,displaySprite,callback);
      addChild(displaySprite);
   }
   
   override public function set data#2(param1:Object) : void
   {
      super.data#2 = param1;
      if(param1 == null)
      {
         return;
      }
      if(_data.id)
      {
         avatarItemUI.setAvatarImage(_data.id);
      }
      else if(_data.texture)
      {
         avatarItemUI.setAvatarTexture(_data.texture,_data.snskey);
      }
   }
   
   override protected function commitData() : void
   {
      avatarItemUI.updateData(data#2);
   }
   
   public function setSelected(param1:Boolean) : void
   {
      avatarItemUI.setSelected(param1);
   }
   
   public function getAvatarUI() : AvatarItemUI
   {
      return avatarItemUI;
   }
   
   override public function dispose() : void
   {
      extractor = null;
      callback = null;
      displaySprite = null;
      avatarItemUI.dispose();
      avatarItemUI = null;
      super.dispose();
   }
}

import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.engine.TextureCollector;
import gudetama.scene.profile.AvatarSelectDialog;
import gudetama.ui.UIBase;
import muku.display.ContainerButton;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class AvatarItemUI extends UIBase
{
    
   
   private var dialog:AvatarSelectDialog;
   
   private var callback:Function;
   
   private var button:ContainerButton;
   
   private var currentAvatarSprite:Sprite;
   
   private var selectedAvatarSprite:Sprite;
   
   private var id:int;
   
   private var snsid:int = -1;
   
   function AvatarItemUI(param1:AvatarSelectDialog, param2:Sprite, param3:Function)
   {
      super(param2);
      this.dialog = param1;
      this.callback = param3;
      button = param2.getChildByName("button") as ContainerButton;
      button.addEventListener("triggered",triggeredButton);
      currentAvatarSprite = button.getChildByName("currentAvatarSprite") as Sprite;
      selectedAvatarSprite = button.getChildByName("selectedAvatarSprite") as Sprite;
   }
   
   public function setAvatarImage(param1:int) : void
   {
      var _id:int = param1;
      snsid = -1;
      var avatarIcon:Image = button.getChildByName("icon") as Image;
      avatarIcon.visible = false;
      TextureCollector.loadTextureRsrc("avatar-" + GameSetting.getAvatar(_id).rsrc,function(param1:Texture):void
      {
         avatarIcon.texture = param1;
         avatarIcon.visible = true;
      });
      Image(button.getChildByName("imgSns")).visible = false;
      currentAvatarSprite.visible = false;
      selectedAvatarSprite.visible = false;
   }
   
   public function setAvatarTexture(param1:Texture, param2:int) : void
   {
      var _texture:Texture = param1;
      var _snsid:int = param2;
      snsid = _snsid;
      var avatarIcon:Image = button.getChildByName("icon") as Image;
      avatarIcon.texture = _texture;
      var imgSns:Image = button.getChildByName("imgSns") as Image;
      imgSns.visible = false;
      TextureCollector.loadSnsImage(_snsid,null,function(param1:Texture):void
      {
         if(param1 != null)
         {
            imgSns.texture = param1;
            imgSns.visible = true;
         }
      });
      currentAvatarSprite.visible = false;
      selectedAvatarSprite.visible = false;
   }
   
   public function updateData(param1:Object) : void
   {
      if(!param1)
      {
         return;
      }
      if(snsid == -1)
      {
         id = param1.id;
      }
      else
      {
         id = UserDataWrapper.wrapper.getCurrentAvatar();
      }
      updateIcon();
      button.helperObject = {"renderer":this};
   }
   
   private function triggeredButton(param1:Event) : void
   {
      callback(id);
   }
   
   private function updateIcon() : void
   {
      if(UserDataWrapper.wrapper.isCurrentAvatar(id,snsid))
      {
         currentAvatarSprite.visible = true;
         selectedAvatarSprite.visible = false;
      }
      else if(dialog.getSelectedSnsType() == snsid && dialog.getSelectedAvatarId() == id)
      {
         currentAvatarSprite.visible = false;
         selectedAvatarSprite.visible = true;
      }
      else
      {
         currentAvatarSprite.visible = false;
         selectedAvatarSprite.visible = false;
      }
   }
   
   public function getAvatarId() : int
   {
      return id;
   }
   
   public function getSnsType() : int
   {
      return snsid;
   }
   
   public function setSelected(param1:Boolean) : void
   {
      if(UserDataWrapper.wrapper.isCurrentAvatar(id,snsid))
      {
         return;
      }
      if(param1)
      {
         currentAvatarSprite.visible = false;
         selectedAvatarSprite.visible = true;
      }
      else
      {
         currentAvatarSprite.visible = false;
         selectedAvatarSprite.visible = false;
      }
   }
   
   public function getId() : int
   {
      return id;
   }
   
   public function dispose() : void
   {
      callback = null;
      button.removeEventListener("triggered",triggeredButton);
      button = null;
      currentAvatarSprite = null;
      selectedAvatarSprite = null;
   }
}
