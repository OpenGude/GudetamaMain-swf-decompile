package gudetama.scene.friend
{
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.compati.FriendlyData;
   import gudetama.data.compati.FriendlyDef;
   import gudetama.data.compati.FriendlyParam;
   import gudetama.data.compati.ItemParam;
   import gudetama.data.compati.UserProfileData;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.SoundManager;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class FriendlyRewardDialog extends BaseScene
   {
       
      
      private var params:Array;
      
      private var callback:Function;
      
      private var state:int;
      
      private var itemIconImage:Image;
      
      private var itemNameText:ColorTextField;
      
      private var itemNumText:ColorTextField;
      
      private var avatarImage:Image;
      
      private var imgSns:Image;
      
      private var playerNameText:ColorTextField;
      
      private var friendlyGroup:Sprite;
      
      private var friendlyText:ColorTextField;
      
      private var maxText:ColorTextField;
      
      private var closeButton:ContainerButton;
      
      private var currentIndex:int;
      
      private var loadCount:int;
      
      public function FriendlyRewardDialog(param1:Array, param2:Function, param3:int)
      {
         super(2);
         this.params = param1;
         this.callback = param2;
         this.state = param3;
      }
      
      public static function show(param1:Array, param2:Function = null, param3:int = 94) : void
      {
         cleanup(param1);
         if(param1.length == 0)
         {
            if(param2)
            {
               param2();
            }
            return;
         }
         Engine.pushScene(new FriendlyRewardDialog(param1,param2,param3),0,false);
      }
      
      private static function cleanup(param1:Array) : void
      {
         var _loc3_:int = 0;
         var _loc2_:* = null;
         var _loc4_:int = 0;
         _loc3_ = param1.length - 1;
         while(_loc3_ >= 0)
         {
            _loc2_ = param1[_loc3_][0];
            if((_loc4_ = param1[_loc3_][1][0]) >= _loc2_.friendlyLevel)
            {
               param1.removeAt(_loc3_);
            }
            _loc3_--;
         }
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"FriendlyRewardDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            itemIconImage = _loc2_.getChildByName("itemIcon") as Image;
            itemNameText = _loc2_.getChildByName("itemName") as ColorTextField;
            itemNumText = _loc2_.getChildByName("itemNum") as ColorTextField;
            avatarImage = _loc2_.getChildByName("avatar") as Image;
            imgSns = _loc2_.getChildByName("imgSns") as Image;
            imgSns.visible = false;
            playerNameText = _loc2_.getChildByName("playerName") as ColorTextField;
            friendlyGroup = _loc2_.getChildByName("friendlyGroup") as Sprite;
            friendlyText = friendlyGroup.getChildByName("friendly") as ColorTextField;
            maxText = _loc2_.getChildByName("max") as ColorTextField;
            closeButton = _loc2_.getChildByName("btn_back") as ContainerButton;
            closeButton.addEventListener("triggered",triggeredCloseButton);
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
         setup(queue);
      }
      
      private function setup(param1:TaskQueue) : void
      {
         var queue:TaskQueue = param1;
         var param:Array = params[currentIndex];
         var profile:UserProfileData = param[2];
         var last:int = param[1][0];
         var friendlyDef:FriendlyDef = GameSetting.getFriendly();
         var friendlyParam:FriendlyParam = friendlyDef.getParam(last);
         var nextFriendlyParam:FriendlyParam = friendlyDef.getParam(last + 1);
         var item:ItemParam = friendlyParam.rewards[0];
         var itemIconName:String = GudetamaUtil.getItemIconName(item.kind,item.id#2);
         if(itemIconName && itemIconName.length > 0)
         {
            queue.addTask(function():void
            {
               TextureCollector.loadTextureRsrc(GudetamaUtil.getItemIconName(item.kind,item.id#2),function(param1:Texture):void
               {
                  itemIconImage.texture = param1;
                  queue.taskDone();
               });
            });
         }
         itemNameText.text#2 = GudetamaUtil.getItemParamName(item);
         itemNumText.text#2 = GudetamaUtil.getItemParamNum(item);
         var avatarId:int = 1;
         if(profile != null)
         {
            if(profile.snsProfileImage != null)
            {
               avatarId = 0;
               queue.addTask(function():void
               {
                  GudetamaUtil.loadByteArray2Texture(profile.snsProfileImage,function(param1:Texture):void
                  {
                     avatarImage.texture = param1;
                     queue.taskDone();
                  });
               });
               TextureCollector.loadSnsImage(profile.snsType,queue,function(param1:Texture):void
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
               avatarId = profile.avatar;
            }
         }
         if(avatarId > 0)
         {
            queue.addTask(function():void
            {
               TextureCollector.loadTextureRsrc("avatar-" + GameSetting.getAvatar(avatarId).rsrc,function(param1:Texture):void
               {
                  avatarImage.texture = param1;
                  queue.taskDone();
               });
            });
         }
         playerNameText.text#2 = !!profile ? profile.playerName : "";
         if(nextFriendlyParam)
         {
            friendlyGroup.visible = true;
            friendlyText.text#2 = friendlyParam.max.toString();
            maxText.visible = false;
         }
         else
         {
            friendlyGroup.visible = false;
            maxText.visible = true;
         }
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(FriendlyRewardDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(state);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         SoundManager.playEffect("level_up");
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(FriendlyRewardDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         if(++params[currentIndex][1][0] >= params[currentIndex][0].friendlyLevel)
         {
            currentIndex++;
         }
         if(currentIndex >= params.length)
         {
            back();
         }
         else
         {
            next();
         }
      }
      
      private function back() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(FriendlyRewardDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(FriendlyRewardDialog);
            Engine.popScene(scene);
            if(callback)
            {
               callback();
            }
         });
      }
      
      private function next() : void
      {
         Engine.lockTouchInput(FriendlyRewardDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            var queue:TaskQueue = new TaskQueue();
            setup(queue);
            queue.registerOnProgress(function(param1:Number):void
            {
               var ratio:Number = param1;
               if(ratio < 1)
               {
                  return;
               }
               TweenAnimator.startItself(displaySprite,"show",false,function():void
               {
                  Engine.unlockTouchInput(FriendlyRewardDialog);
               });
            });
            queue.startTask();
         });
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         itemIconImage = null;
         itemNameText = null;
         itemNumText = null;
         avatarImage = null;
         imgSns = null;
         playerNameText = null;
         friendlyGroup = null;
         friendlyText = null;
         maxText = null;
         if(closeButton)
         {
            closeButton.removeEventListener("triggered",triggeredCloseButton);
            closeButton = null;
         }
         super.dispose();
      }
   }
}
