package gudetama.scene.profile
{
   import feathers.controls.IScrollBar;
   import feathers.controls.List;
   import feathers.controls.ScrollBar;
   import feathers.controls.renderers.IListItemRenderer;
   import feathers.controls.supportClasses.ListDataViewPort;
   import feathers.data.ListCollection;
   import feathers.layout.FlowLayout;
   import gudetama.data.UserDataWrapper;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.util.SpriteExtractor;
   import muku.display.ContainerButton;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class CommentSelectDialog extends BaseScene
   {
       
      
      private var callback:Function;
      
      private var list:List;
      
      private var closeButton:ContainerButton;
      
      private var decideButton:ContainerButton;
      
      private var extractor:SpriteExtractor;
      
      private var collection:ListCollection;
      
      private var selectCommentId:int;
      
      private var selectedObj:CommentItemUI;
      
      private var isOpening:Boolean;
      
      public function CommentSelectDialog(param1:Function, param2:Boolean = false)
      {
         collection = new ListCollection();
         super(2);
         this.callback = param1;
         this.isOpening = param2;
      }
      
      public static function show(param1:Function, param2:Boolean = false) : void
      {
         Engine.pushScene(new CommentSelectDialog(param1,param2),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"CommentSelectDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            closeButton = _loc2_.getChildByName("btn_back") as ContainerButton;
            closeButton.addEventListener("triggered",triggeredCloseButton);
            decideButton = _loc2_.getChildByName("btn_decide") as ContainerButton;
            decideButton.addEventListener("triggered",triggeredDecideButton);
            list = _loc2_.getChildByName("list") as List;
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         Engine.setupLayoutForTask(queue,"_CommentItem",function(param1:Object):void
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
         var layout:FlowLayout = new FlowLayout();
         layout.horizontalAlign = "left";
         layout.horizontalGap = 10;
         layout.verticalGap = 10;
         layout.paddingTop = 5;
         list.layout = layout;
         list.itemRendererFactory = function():IListItemRenderer
         {
            return new CommentListItemRenderer(extractor,triggeredCommentItemUICallback,getSelectedCommentId);
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
         list.addEventListener("triggered",selectComment);
         setup();
      }
      
      private function setup() : void
      {
         var _loc3_:int = 0;
         var _loc4_:* = UserDataWrapper;
         var _loc2_:Array = gudetama.data.UserDataWrapper.wrapper._data.commentList;
         _loc2_.sort(ascendingKeyComparator);
         collection.removeAll();
         var _loc1_:int = _loc2_.length;
         _loc3_ = 0;
         while(_loc3_ < _loc1_)
         {
            collection.addItem({"id":_loc2_[_loc3_]});
            _loc3_++;
         }
         selectCommentId = UserDataWrapper.wrapper.getComment();
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
      
      private function selectComment(param1:Event) : void
      {
         var _loc7_:* = null;
         var _loc6_:* = null;
         var _loc3_:int = 0;
         var _loc2_:* = null;
         var _loc4_:* = null;
         var _loc5_:int = 0;
         if(param1.target is ContainerButton)
         {
            _loc3_ = (_loc6_ = (_loc7_ = param1.target as ContainerButton).helperObject.renderer).getCommentId();
            if(getSelectedCommentId() == _loc3_)
            {
               return;
            }
            if(UserDataWrapper.wrapper.getComment() == _loc3_)
            {
               return;
            }
            if(selectedObj != null)
            {
               selectedObj.setSelected(false);
               _loc2_ = list.getChildAt(0) as ListDataViewPort;
               while(_loc5_ < _loc2_.numChildren)
               {
                  if((_loc4_ = _loc2_.getChildAt(_loc5_) as CommentListItemRenderer).setSelected(false))
                  {
                     break;
                  }
                  _loc5_++;
               }
            }
            _loc6_.setSelected(true);
            selectCommentId = _loc3_;
            selectedObj = _loc6_;
         }
      }
      
      public function getSelectedCommentId() : int
      {
         return selectCommentId;
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(CommentSelectDialog);
         setBackButtonCallback(backButtonCallback);
         if(!isOpening)
         {
            setVisibleState(94);
         }
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(CommentSelectDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(CommentSelectDialog);
            Engine.popScene(scene);
         });
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(CommentSelectDialog);
         });
      }
      
      private function triggeredDecideButton(param1:Event) : void
      {
         var event:Event = param1;
         if(UserDataWrapper.wrapper.isCurrentComment(selectCommentId))
         {
            return;
         }
         if(isOpening)
         {
            setComment();
            backButtonCallback();
            return;
         }
         var _loc2_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(201326793,selectCommentId),function(param1:Array):void
         {
            setComment();
         });
         backButtonCallback();
      }
      
      private function setComment() : void
      {
         UserDataWrapper.wrapper.setComment(selectCommentId);
         callback(selectCommentId);
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      private function triggeredCommentItemUICallback(param1:int) : void
      {
      }
      
      override public function dispose() : void
      {
         list = null;
         closeButton.removeEventListener("triggered",triggeredCloseButton);
         closeButton = null;
         decideButton.removeEventListener("triggered",triggeredDecideButton);
         decideButton = null;
         list = null;
         extractor = null;
         collection = null;
         selectedObj = null;
         super.dispose();
      }
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class CommentListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var callback:Function;
   
   private var displaySprite:Sprite;
   
   private var getSelectedCommentIdCallback:Function;
   
   private var commentItemUI:CommentItemUI;
   
   function CommentListItemRenderer(param1:SpriteExtractor, param2:Function, param3:Function)
   {
      super();
      this.extractor = param1;
      this.callback = param2;
      this.getSelectedCommentIdCallback = param3;
   }
   
   override protected function initialize() : void
   {
      if(displaySprite)
      {
         return;
      }
      super.initialize();
      displaySprite = extractor.duplicateAll() as Sprite;
      commentItemUI = new CommentItemUI(displaySprite,callback,getSelectedCommentIdCallback);
      addChild(displaySprite);
   }
   
   override public function set data#2(param1:Object) : void
   {
      super.data#2 = param1;
      if(param1 == null)
      {
         return;
      }
      commentItemUI.init(_data.id);
   }
   
   override protected function commitData() : void
   {
      commentItemUI.updateData(data#2);
   }
   
   public function setSelected(param1:Boolean) : Boolean
   {
      return commentItemUI.setSelected(param1);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      callback = null;
      displaySprite = null;
      commentItemUI.dispose();
      commentItemUI = null;
      super.dispose();
   }
}

import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.ui.UIBase;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Sprite;
import starling.events.Event;

class CommentItemUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var button:ContainerButton;
   
   private var currentSprite:Sprite;
   
   private var selectedSprite:Sprite;
   
   private var comment:ColorTextField;
   
   private var id:int;
   
   private var getSelectedCommentIdCallback:Function;
   
   function CommentItemUI(param1:Sprite, param2:Function, param3:Function)
   {
      super(param1);
      this.callback = param2;
      this.getSelectedCommentIdCallback = param3;
      button = param1.getChildByName("button") as ContainerButton;
      button.addEventListener("triggered",triggeredButton);
      currentSprite = button.getChildByName("currentSprite") as Sprite;
      selectedSprite = button.getChildByName("selectedSprite") as Sprite;
      comment = button.getChildByName("comment") as ColorTextField;
   }
   
   public function init(param1:int) : void
   {
      currentSprite.visible = false;
      selectedSprite.visible = false;
      comment.text#2 = GameSetting.getComment(param1);
   }
   
   public function updateData(param1:Object) : void
   {
      if(!param1)
      {
         return;
      }
      id = param1.id;
      updateIcon();
      button.helperObject = {"renderer":this};
      setSelected(getSelectedCommentIdCallback() == param1.id);
   }
   
   private function triggeredButton(param1:Event) : void
   {
      callback(id);
   }
   
   private function updateIcon() : void
   {
      selectedSprite.visible = false;
      if(UserDataWrapper.wrapper.isCurrentComment(id))
      {
         currentSprite.visible = true;
      }
      else
      {
         currentSprite.visible = false;
      }
   }
   
   public function getCommentId() : int
   {
      return id;
   }
   
   public function setSelected(param1:Boolean) : Boolean
   {
      if(UserDataWrapper.wrapper.isCurrentComment(id))
      {
         return false;
      }
      if(param1)
      {
         currentSprite.visible = false;
         selectedSprite.visible = true;
         return true;
      }
      currentSprite.visible = false;
      selectedSprite.visible = false;
      return false;
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
   }
}
