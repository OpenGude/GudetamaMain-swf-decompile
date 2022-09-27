package gudetama.scene.kitchen
{
   import feathers.controls.IScrollBar;
   import feathers.controls.List;
   import feathers.controls.ScrollBar;
   import feathers.controls.renderers.IListItemRenderer;
   import feathers.data.ListCollection;
   import feathers.layout.FlowLayout;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.KitchenwareData;
   import gudetama.data.compati.UsefulDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.util.SpriteExtractor;
   import muku.display.ContainerButton;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class CookingUsefulDialog extends BaseScene
   {
      
      private static const ABILITY_KINDS:Array = [3,4,2];
       
      
      private var kitchenwareType:int;
      
      private var selectedUsefulIds:Array;
      
      private var existsHappening:Boolean;
      
      public var assistantMap:Object;
      
      private var callback:Function;
      
      private var toggleUIGroup:ToggleUIGroup;
      
      private var list:List;
      
      private var closeButton:ContainerButton;
      
      private var extractor:SpriteExtractor;
      
      private var collection:ListCollection;
      
      private var usefulIds:Array;
      
      private var assistUsefulIds:Array;
      
      public function CookingUsefulDialog(param1:int, param2:Array, param3:Boolean, param4:Object, param5:Function)
      {
         collection = new ListCollection();
         usefulIds = [];
         assistUsefulIds = [];
         super(2);
         this.kitchenwareType = param1;
         this.selectedUsefulIds = param2;
         this.existsHappening = param3;
         this.assistantMap = param4;
         this.callback = param5;
      }
      
      public static function show(param1:int, param2:Array, param3:Boolean, param4:Object, param5:Function) : void
      {
         Engine.pushScene(new CookingUsefulDialog(param1,param2,param3,param4,param5),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"CookingUsefulDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            toggleUIGroup = new ToggleUIGroup(_loc2_.getChildByName("tabGroup") as Sprite,triggeredToggleButtonCallback);
            list = _loc2_.getChildByName("list") as List;
            closeButton = _loc2_.getChildByName("btn_back") as ContainerButton;
            closeButton.addEventListener("triggered",triggeredCloseButton);
            displaySprite.visible = false;
            addChild(displaySprite);
            checkInit();
         });
         Engine.setupLayoutForTask(queue,"_CookingUsefulItem",function(param1:Object):void
         {
            extractor = SpriteExtractor.forGross(param1.object,param1);
            checkInit();
         });
         queue.registerOnProgress(function(param1:Number):void
         {
         });
         queue.startTask(onProgress);
      }
      
      private function checkInit() : void
      {
         if(queue.numRest > 1)
         {
            return;
         }
         init();
      }
      
      private function init() : void
      {
         var layout:FlowLayout = new FlowLayout();
         layout.horizontalAlign = "left";
         layout.horizontalGap = 2;
         layout.verticalGap = 4;
         layout.paddingLeft = 12;
         layout.paddingTop = 5;
         list.layout = layout;
         list.itemRendererFactory = function():IListItemRenderer
         {
            return new CookingUsefulListItemRenderer(extractor,scene);
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
         setupUsefuls(0);
         toggleUIGroup.setEnabled(1,existsHappening);
         updateAssistUsefulIds();
         updateToggles();
      }
      
      private function updateAssistUsefulIds() : void
      {
         var _loc6_:* = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc1_:* = null;
         var _loc3_:int = 0;
         var _loc2_:KitchenwareData = UserDataWrapper.kitchenwarePart.getKitchenwareByType(kitchenwareType);
         if(!_loc2_.assistUsefulIds)
         {
            return;
         }
         assistUsefulIds = _loc2_.assistUsefulIds.slice();
         for each(var _loc7_ in selectedUsefulIds)
         {
            if((_loc4_ = (_loc6_ = GameSetting.getUseful(_loc7_)).getUniqueType()) >= 0)
            {
               _loc5_ = assistUsefulIds.length - 1;
               while(_loc5_ >= 0)
               {
                  _loc1_ = GameSetting.getUseful(assistUsefulIds[_loc5_]);
                  _loc3_ = _loc1_.getUniqueType();
                  if(_loc3_ >= 0 && _loc3_ != _loc4_)
                  {
                     assistUsefulIds.removeAt(_loc5_);
                  }
                  _loc5_--;
               }
            }
         }
      }
      
      public function isAssisted(param1:int) : Boolean
      {
         var _loc2_:KitchenwareData = UserDataWrapper.kitchenwarePart.getKitchenwareByType(kitchenwareType);
         if(!_loc2_.assistUsefulIds)
         {
            return false;
         }
         return _loc2_.assistUsefulIds.indexOf(param1) >= 0;
      }
      
      public function getAssistEncodedUid(param1:int) : int
      {
         var _loc2_:KitchenwareData = UserDataWrapper.kitchenwarePart.getKitchenwareByType(kitchenwareType);
         if(!_loc2_.assistUsefulIds)
         {
            return 0;
         }
         return _loc2_.assistEncodedUids[_loc2_.assistUsefulIds.indexOf(param1)];
      }
      
      private function setupUsefuls(param1:int) : void
      {
         var _loc4_:* = null;
         var _loc5_:int = ABILITY_KINDS[param1];
         var _loc2_:Object = GameSetting.getUsefulMap();
         usefulIds.length = 0;
         for(var _loc3_ in _loc2_)
         {
            if((_loc4_ = GameSetting.getUseful(_loc3_)).existsAbilityKind(_loc5_))
            {
               usefulIds.push(_loc3_);
            }
         }
         usefulIds.sort(ascendingKeyComparator);
         collection.removeAll();
         for each(_loc3_ in usefulIds)
         {
            collection.addItem({"id":_loc3_});
         }
      }
      
      private function updateToggles() : void
      {
         var _loc3_:int = 0;
         var _loc7_:int = 0;
         var _loc4_:Boolean = false;
         var _loc5_:* = null;
         var _loc2_:Boolean = false;
         var _loc1_:Object = GameSetting.getUsefulMap();
         _loc3_ = 0;
         while(_loc3_ < ABILITY_KINDS.length)
         {
            _loc7_ = ABILITY_KINDS[_loc3_];
            _loc4_ = false;
            for(var _loc6_ in _loc1_)
            {
               if((_loc5_ = GameSetting.getUseful(_loc6_)).existsAbilityKind(_loc7_))
               {
                  if(isSelected(_loc6_))
                  {
                     _loc4_ = true;
                     break;
                  }
               }
            }
            _loc2_ = false;
            for each(_loc6_ in assistUsefulIds)
            {
               if((_loc5_ = GameSetting.getUseful(_loc6_)).existsAbilityKind(_loc7_))
               {
                  _loc2_ = true;
                  break;
               }
            }
            toggleUIGroup.check(_loc3_,_loc4_,_loc2_);
            _loc3_++;
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
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(CookingUsefulDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(76);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(CookingUsefulDialog);
         });
      }
      
      private function triggeredToggleButtonCallback(param1:int) : void
      {
         setupUsefuls(param1);
      }
      
      public function triggeredCookingUsefulItemUICallback(param1:int) : void
      {
         var _loc4_:* = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc5_:* = null;
         var _loc6_:int = 0;
         var _loc7_:*;
         if(_loc7_ = !isSelected(param1))
         {
            if(!isAssisted(param1))
            {
               selectedUsefulIds.push(param1);
            }
            _loc2_ = (_loc4_ = GameSetting.getUseful(param1)).getUniqueType();
            if(_loc2_ >= 0)
            {
               _loc3_ = selectedUsefulIds.length - 1;
               while(_loc3_ >= 0)
               {
                  if((_loc6_ = (_loc5_ = GameSetting.getUseful(selectedUsefulIds[_loc3_])).getUniqueType()) >= 0 && _loc6_ != _loc2_)
                  {
                     selectedUsefulIds.removeAt(_loc3_);
                  }
                  _loc3_--;
               }
            }
         }
         else if(!isAssisted(param1))
         {
            selectedUsefulIds.removeAt(selectedUsefulIds.indexOf(param1));
         }
         updateAssistUsefulIds();
         updateToggles();
      }
      
      public function isSelected(param1:int) : Boolean
      {
         return selectedUsefulIds.indexOf(param1) >= 0;
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(CookingUsefulDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(CookingUsefulDialog);
            Engine.popScene(scene);
            callback(selectedUsefulIds);
         });
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         toggleUIGroup.dispose();
         toggleUIGroup = null;
         list = null;
         closeButton.removeEventListener("triggered",triggeredCloseButton);
         closeButton = null;
         extractor = null;
         collection = null;
         super.dispose();
      }
   }
}

import feathers.core.ToggleGroup;
import gudetama.engine.TweenAnimator;
import starling.display.Sprite;

class ToggleUIGroup
{
    
   
   private var displaySprite:Sprite;
   
   private var callback:Function;
   
   private var toggleGroup:ToggleGroup;
   
   private var toggleUIList:Vector.<ToggleUI>;
   
   function ToggleUIGroup(param1:Sprite, param2:Function)
   {
      var _loc3_:int = 0;
      toggleUIList = new Vector.<ToggleUI>();
      super();
      this.displaySprite = param1;
      this.callback = param2;
      toggleGroup = new ToggleGroup();
      _loc3_ = 0;
      while(_loc3_ < param1.numChildren)
      {
         toggleUIList.push(new ToggleUI(param1.getChildByName("btn_tab" + _loc3_) as Sprite,triggeredButtonCallback,_loc3_,toggleGroup));
         _loc3_++;
      }
   }
   
   public function setVisible(param1:int, param2:Boolean) : void
   {
      toggleUIList[param1].setVisible(param2);
   }
   
   public function setEnabled(param1:int, param2:Boolean) : void
   {
      toggleUIList[param1].setEnabled(param2);
   }
   
   public function startTween(param1:*, param2:Boolean = false, param3:Function = null) : void
   {
      TweenAnimator.startItself(displaySprite,param1,param2,param3);
   }
   
   public function check(param1:int, param2:Boolean, param3:Boolean) : void
   {
      toggleUIList[param1].check(param2,param3);
   }
   
   public function get selectedIndex() : int
   {
      return toggleGroup.selectedIndex;
   }
   
   private function triggeredButtonCallback(param1:int) : void
   {
      if(toggleGroup.selectedIndex != param1)
      {
         toggleGroup.selectedIndex = param1;
      }
      if(callback)
      {
         callback(param1);
      }
   }
   
   public function dispose() : void
   {
      displaySprite = null;
      callback = null;
      toggleGroup.removeAllItems();
      toggleGroup = null;
      for each(var _loc1_ in toggleUIList)
      {
         _loc1_.dispose();
      }
      toggleUIList.length = 0;
      toggleUIList = null;
   }
}

import feathers.core.ToggleGroup;
import gudetama.ui.UIBase;
import muku.display.ToggleButton;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;

class ToggleUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var index:int;
   
   private var button:ToggleButton;
   
   private var checkImage:Image;
   
   private var friendIconImage:Image;
   
   private var disableImage:Image;
   
   private var enabled:Boolean = true;
   
   function ToggleUI(param1:Sprite, param2:Function, param3:int, param4:ToggleGroup)
   {
      super(param1);
      this.callback = param2;
      this.index = param3;
      button = param1.getChildByName("toggle_btn") as ToggleButton;
      button.toggleGroup = param4;
      button.addEventListener("triggered",triggered);
      checkImage = param1.getChildByName("check") as Image;
      friendIconImage = param1.getChildByName("friendIcon") as Image;
      disableImage = param1.getChildByName("disable") as Image;
      disableImage.visible = false;
   }
   
   public function check(param1:Boolean, param2:Boolean) : void
   {
      checkImage.visible = enabled && param1 && !param2;
      friendIconImage.visible = enabled && param2;
   }
   
   public function setEnabled(param1:Boolean) : void
   {
      button.touchable = param1;
      checkImage.visible = param1 && checkImage.visible;
      friendIconImage.visible = param1 && friendIconImage.visible;
      disableImage.visible = !param1;
      enabled = param1;
   }
   
   private function triggered(param1:Event) : void
   {
      if(callback)
      {
         callback(index);
      }
   }
   
   public function dispose() : void
   {
      callback = null;
      button.removeEventListener("triggered",triggered);
      button = null;
      checkImage = null;
      friendIconImage = null;
      disableImage = null;
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.engine.BaseScene;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class CookingUsefulListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var scene:BaseScene;
   
   private var displaySprite:Sprite;
   
   private var cookingUsefulItemUI:CookingUsefulItemUI;
   
   function CookingUsefulListItemRenderer(param1:SpriteExtractor, param2:BaseScene)
   {
      super();
      this.extractor = param1;
      this.scene = param2;
   }
   
   override protected function initialize() : void
   {
      if(displaySprite)
      {
         return;
      }
      displaySprite = extractor.duplicateAll() as Sprite;
      cookingUsefulItemUI = new CookingUsefulItemUI(displaySprite,scene);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      cookingUsefulItemUI.updateData(data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      scene = null;
      displaySprite = null;
      cookingUsefulItemUI.dispose();
      cookingUsefulItemUI = null;
      super.dispose();
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.UsefulDef;
import gudetama.data.compati.UserProfileData;
import gudetama.engine.BaseScene;
import gudetama.engine.TextureCollector;
import gudetama.scene.kitchen.CookingUsefulDialog;
import gudetama.ui.UIBase;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class CookingUsefulItemUI extends UIBase
{
    
   
   private var scene:CookingUsefulDialog;
   
   private var button:ContainerButton;
   
   private var iconImage:Image;
   
   private var nameText:ColorTextField;
   
   private var numText:ColorTextField;
   
   private var checkGroup:Sprite;
   
   private var checkImage:Image;
   
   private var friendGroup:Sprite;
   
   private var friendAvatarImage:Image;
   
   private var imgSns:Image;
   
   private var friendNameText:ColorTextField;
   
   private var id:int;
   
   function CookingUsefulItemUI(param1:Sprite, param2:BaseScene)
   {
      super(param1);
      this.scene = CookingUsefulDialog(param2);
      button = param1.getChildByName("button") as ContainerButton;
      button.addEventListener("triggered",triggeredButton);
      iconImage = button.getChildByName("icon") as Image;
      nameText = button.getChildByName("name") as ColorTextField;
      numText = button.getChildByName("num") as ColorTextField;
      checkGroup = button.getChildByName("checkGroup") as Sprite;
      checkImage = checkGroup.getChildByName("check") as Image;
      friendGroup = button.getChildByName("friendGroup") as Sprite;
      friendAvatarImage = friendGroup.getChildByName("avatar") as Image;
      imgSns = friendGroup.getChildByName("imgSns") as Image;
      friendNameText = friendGroup.getChildByName("name") as ColorTextField;
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      if(!data)
      {
         return;
      }
      id = data.id;
      var usefulDef:UsefulDef = GameSetting.getUseful(id);
      var num:int = UserDataWrapper.usefulPart.getNumUseful(id);
      iconImage.visible = false;
      TextureCollector.loadTexture(GudetamaUtil.getItemIconName(8,id),function(param1:Texture):void
      {
         iconImage.visible = true;
         iconImage.texture = param1;
      });
      nameText.text#2 = usefulDef.name#2;
      numText.text#2 = num.toString();
      if(scene.isAssisted(id))
      {
         checkGroup.visible = false;
         friendGroup.visible = true;
         if(scene.assistantMap)
         {
            var profile:UserProfileData = scene.assistantMap[scene.getAssistEncodedUid(id)];
         }
         if(!profile)
         {
            profile = UserDataWrapper.friendPart.getFriendProfile(scene.getAssistEncodedUid(id));
         }
         if(profile)
         {
            friendNameText.text#2 = profile.playerName;
            if(profile.snsProfileImage)
            {
               friendAvatarImage.visible = false;
               GudetamaUtil.loadByteArray2Texture(profile.snsProfileImage,function(param1:Texture):void
               {
                  if(friendAvatarImage == null)
                  {
                     return;
                  }
                  friendAvatarImage.texture = param1;
                  friendAvatarImage.visible = true;
               });
               imgSns.visible = false;
               TextureCollector.loadSnsImage(profile.snsType,null,function(param1:Texture):void
               {
                  if(param1 != null && imgSns != null)
                  {
                     imgSns.texture = param1;
                     imgSns.visible = true;
                  }
               });
            }
            else
            {
               friendAvatarImage.visible = false;
               TextureCollector.loadTextureRsrc("avatar-" + GameSetting.getAvatar(profile.avatar).rsrc,function(param1:Texture):void
               {
                  if(friendAvatarImage == null)
                  {
                     return;
                  }
                  friendAvatarImage.texture = param1;
                  friendAvatarImage.visible = true;
               });
               imgSns.visible = false;
            }
         }
         else
         {
            friendNameText.text#2 = "";
         }
      }
      else
      {
         checkGroup.visible = true;
         friendGroup.visible = false;
         checkImage.visible = scene.isSelected(id);
      }
      button.setEnableWithDrawCache(num > 0);
   }
   
   private function triggeredButton(param1:Event) : void
   {
      scene.triggeredCookingUsefulItemUICallback(id);
      checkImage.visible = scene.isSelected(id);
   }
   
   public function dispose() : void
   {
      button = null;
      nameText = null;
      numText = null;
      checkGroup = null;
      checkImage = null;
      friendGroup = null;
      friendAvatarImage = null;
      imgSns = null;
      friendNameText = null;
   }
}
