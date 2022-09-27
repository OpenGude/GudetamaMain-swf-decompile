package gudetama.scene.profile
{
   import feathers.controls.IScrollBar;
   import feathers.controls.List;
   import feathers.controls.ScrollBar;
   import feathers.controls.renderers.IListItemRenderer;
   import feathers.data.ListCollection;
   import feathers.layout.FlowLayout;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.UserProfileData;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.scene.friend.FriendDetailDialog;
   import gudetama.ui.PresentLogListItemRenderer;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.util.SpriteExtractor;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class MorePresentLogDialog extends BaseScene
   {
       
      
      private var list:List;
      
      private var closeButton:ContainerButton;
      
      private var extractor:SpriteExtractor;
      
      private var collection:ListCollection;
      
      private var loadCount:int;
      
      public function MorePresentLogDialog()
      {
         collection = new ListCollection();
         super(1);
      }
      
      public static function show() : void
      {
         Engine.pushScene(new MorePresentLogDialog(),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"MorePresentLogDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            list = _loc2_.getChildByName("list") as List;
            closeButton = _loc2_.getChildByName("closeButton") as ContainerButton;
            closeButton.addEventListener("triggered",triggeredCloseButton);
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         setupLayoutForTask(queue,"_PresentLogItem",function(param1:Object):void
         {
            extractor = SpriteExtractor.forGross(param1.object,param1);
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
         layout.horizontalGap = 2;
         layout.verticalGap = 10;
         layout.paddingTop = 5;
         layout.paddingLeft = 19.5;
         list.layout = layout;
         list.itemRendererFactory = function():IListItemRenderer
         {
            return new PresentLogListItemRenderer(extractor,true,triggeredDetailButton);
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
         var _loc2_:int = 0;
         var _loc1_:Array = UserDataWrapper.wrapper.getPresentLogs();
         _loc2_ = _loc1_.length - 1;
         while(_loc2_ >= 0)
         {
            if(UserDataWrapper.friendPart.existsInFriend(_loc1_[_loc2_].encodedUid))
            {
               collection.addItem({
                  "encodedUid":_loc1_[_loc2_].encodedUid,
                  "name":UserDataWrapper.wrapper.getPlayerName(),
                  "presentLog":_loc1_[_loc2_]
               });
            }
            _loc2_--;
         }
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(MorePresentLogDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(MorePresentLogDialog);
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
               Engine.showLoading(MorePresentLogDialog);
               var _loc1_:* = HttpConnector;
               if(gudetama.net.HttpConnector.mainConnector == null)
               {
                  gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
               }
               gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(163,encodedUid),function(param1:Array):void
               {
                  var response:Array = param1;
                  Engine.hideLoading(MorePresentLogDialog);
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
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(MorePresentLogDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(MorePresentLogDialog);
            Engine.popScene(scene);
         });
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         list = null;
         closeButton.removeEventListener("triggered",triggeredCloseButton);
         closeButton = null;
         extractor = null;
         collection = null;
         super.dispose();
      }
   }
}
