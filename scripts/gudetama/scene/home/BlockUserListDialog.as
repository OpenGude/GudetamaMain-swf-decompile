package gudetama.scene.home
{
   import feathers.controls.IScrollBar;
   import feathers.controls.List;
   import feathers.controls.ScrollBar;
   import feathers.controls.renderers.IListItemRenderer;
   import feathers.data.ListCollection;
   import feathers.layout.VerticalLayout;
   import gudetama.data.DataStorage;
   import gudetama.data.GameSetting;
   import gudetama.data.LocalUserBlockData;
   import gudetama.data.compati.UserProfileData;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.ui.LocalMessageDialog;
   import gudetama.util.SpriteExtractor;
   import muku.display.ContainerButton;
   import starling.display.Sprite;
   
   public class BlockUserListDialog extends BaseScene
   {
       
      
      private var blockData:LocalUserBlockData;
      
      private var list:List;
      
      private var btnClose:ContainerButton;
      
      private var itemExtractor:SpriteExtractor;
      
      public function BlockUserListDialog(param1:LocalUserBlockData)
      {
         super(2);
         this.blockData = param1;
      }
      
      public static function show() : void
      {
         var _loc1_:LocalUserBlockData = DataStorage.loadUserBlockData();
         if(_loc1_.profiles.length == 0)
         {
            LocalMessageDialog.show(0,GameSetting.getUIText("block.none"));
            return;
         }
         Engine.pushScene(new BlockUserListDialog(_loc1_),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"BlockUserListDialog",function(param1:Object):void
         {
            var layout:Object = param1;
            displaySprite = layout.object;
            var dialogSprite:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            list = dialogSprite.getChildByName("list") as List;
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
            listLayout.padding = 10;
            listLayout.paddingTop = 20;
            listLayout.gap = 20;
            listLayout.lastGap = 20;
            list.layout = listLayout;
            btnClose = dialogSprite.getChildByName("btnClose") as ContainerButton;
            btnClose.addEventListener("triggered",backButtonCallback);
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         Engine.setupLayoutForTask(queue,"_BlockUserListItem",function(param1:Object):void
         {
            itemExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         queue.registerOnProgress(function(param1:Number):void
         {
            var ratio:Number = param1;
            if(ratio < 1)
            {
               return;
            }
            list.itemRendererFactory = function():IListItemRenderer
            {
               return new BlockUserItemRenderer(itemExtractor,removeBlock);
            };
            list.dataProvider = new ListCollection(blockData.profiles);
         });
         queue.startTask(onProgress);
      }
      
      public function removeBlock(param1:UserProfileData) : void
      {
         var prof:UserProfileData = param1;
         LocalMessageDialog.show(1,GameSetting.getUIText("block.cancel.confirm"),function(param1:int):void
         {
            if(param1 == 1)
            {
               return;
            }
            blockData.removeBlock(prof);
            list.dataProvider = new ListCollection(blockData.profiles);
         });
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(BlockUserListDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(BlockUserListDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(BlockUserListDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(BlockUserListDialog);
            Engine.popScene(scene);
         });
      }
      
      override public function dispose() : void
      {
         blockData = null;
         list = null;
         btnClose.removeEventListener("triggered",backButtonCallback);
         btnClose = null;
         super.dispose();
      }
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class BlockUserItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var callback:Function;
   
   private var displaySprite:Sprite;
   
   private var itemUI:BlockUserItemUI;
   
   function BlockUserItemRenderer(param1:SpriteExtractor, param2:Function)
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
      itemUI = new BlockUserItemUI(displaySprite,callback);
      addChild(displaySprite);
   }
   
   override protected function commitData() : void
   {
      itemUI.updateData(data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      callback = null;
      displaySprite = null;
      itemUI.dispose();
      itemUI = null;
      super.dispose();
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.compati.UserProfileData;
import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

class BlockUserItemUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var txtName:ColorTextField;
   
   private var imgIcon:Image;
   
   private var imgSns:Image;
   
   private var txtLv:ColorTextField;
   
   private var txtArea:ColorTextField;
   
   private var txtComment:ColorTextField;
   
   private var btn:ContainerButton;
   
   private var prof:UserProfileData;
   
   function BlockUserItemUI(param1:Sprite, param2:Function)
   {
      super(param1);
      this.callback = param2;
      txtName = param1.getChildByName("name") as ColorTextField;
      imgIcon = param1.getChildByName("icon") as Image;
      imgSns = param1.getChildByName("imgSns") as Image;
      txtLv = param1.getChildByName("level") as ColorTextField;
      txtArea = param1.getChildByName("area") as ColorTextField;
      txtComment = param1.getChildByName("comment") as ColorTextField;
      btn = param1.getChildByName("btnCancel") as ContainerButton;
      btn.addEventListener("triggered",triggered);
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      if(data == null)
      {
         return;
      }
      prof = data as UserProfileData;
      txtName.text#2 = prof.playerName;
      imgIcon.visible = false;
      imgSns.visible = false;
      if(prof.snsProfileImage != null)
      {
         GudetamaUtil.loadByteArray2Texture(prof.snsProfileImage,function(param1:Texture):void
         {
            if(imgIcon == null)
            {
               return;
            }
            imgIcon.texture = param1;
            imgIcon.visible = true;
         });
         TextureCollector.loadSnsImage(prof.snsType,null,function(param1:Texture):void
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
         TextureCollector.loadTextureRsrc("avatar-" + GameSetting.getAvatar(prof.avatar).rsrc,function(param1:Texture):void
         {
            if(imgIcon == null)
            {
               return;
            }
            imgIcon.texture = param1;
            imgIcon.visible = true;
         });
      }
      txtLv.text#2 = prof.playerRank.toString();
      txtArea.text#2 = StringUtil.format(GameSetting.getUIText("profile.area"),GameSetting.getUIText("profile.area." + prof.area));
      txtComment.text#2 = GameSetting.getComment(prof.getComment());
   }
   
   private function triggered() : void
   {
      callback(prof);
   }
   
   public function dispose() : void
   {
      callback = null;
      txtName = null;
      imgIcon = null;
      imgSns = null;
      txtLv = null;
      txtArea = null;
      txtComment = null;
      btn.removeEventListener("triggered",triggered);
      btn = null;
      prof = null;
   }
}
