package gudetama.ui
{
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.compati.GudetamaDef;
   import gudetama.data.compati.SystemMailData;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.SoundManager;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class MailPresentDialog extends BaseScene
   {
      
      private static const ROTATE_TIME:Number = 10;
       
      
      private var systemMail:SystemMailData;
      
      private var callback:Function;
      
      private var titleText:ColorTextField;
      
      private var rotateImage:Image;
      
      private var itemIconImage:Image;
      
      private var itemNumText:ColorTextField;
      
      private var descText:ColorTextField;
      
      private var closeButton:ContainerButton;
      
      private var loadCount:int;
      
      private var passedTime:Number = 0;
      
      public function MailPresentDialog(param1:SystemMailData, param2:Function)
      {
         super(2);
         this.systemMail = param1;
         this.callback = param2;
      }
      
      public static function show(param1:SystemMailData, param2:Function) : void
      {
         Engine.pushScene(new MailPresentDialog(param1,param2),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"MailPresentDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            titleText = _loc2_.getChildByName("title") as ColorTextField;
            rotateImage = _loc2_.getChildByName("rotate") as Image;
            itemIconImage = _loc2_.getChildByName("icon") as Image;
            itemNumText = _loc2_.getChildByName("num") as ColorTextField;
            descText = _loc2_.getChildByName("desc") as ColorTextField;
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
         setup();
      }
      
      private function setup() : void
      {
         titleText.text#2 = systemMail.title;
         var imageName:String = GudetamaUtil.getItemImageName(systemMail.item.kind,systemMail.item.id#2);
         if(imageName.length > 0)
         {
            queue.addTask(function():void
            {
               TextureCollector.loadTextureRsrc(imageName,function(param1:Texture):void
               {
                  itemIconImage.texture = param1;
                  queue.taskDone();
               });
            });
         }
         if(systemMail.item.kind == 6)
         {
            var gudetamaDef:GudetamaDef = GameSetting.getGudetama(systemMail.item.id#2);
            var isEventGudetama:Boolean = gudetamaDef.type != 1;
            if(isEventGudetama)
            {
               itemNumText.text#2 = gudetamaDef.name#2;
            }
            else
            {
               itemNumText.text#2 = StringUtil.format(GameSetting.getUIText("friendPresent.num.gudetama"),gudetamaDef.number,gudetamaDef.name#2);
            }
         }
         else
         {
            itemNumText.text#2 = GudetamaUtil.getItemParamNameAndNum(systemMail.item);
         }
         descText.text#2 = GudetamaUtil.getSystemMailMessage(systemMail);
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(MailPresentDialog);
         setVisibleState(94);
         setBackButtonCallback(backButtonCallback);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         SoundManager.playEffect("MaxComboSuccess");
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(MailPresentDialog);
         });
      }
      
      override public function advanceTime(param1:Number) : void
      {
         super.advanceTime(param1);
         passedTime += param1;
         rotateImage.rotation = 2 * 3.141592653589793 * passedTime / 10;
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(MailPresentDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(MailPresentDialog);
            Engine.popScene(scene);
            if(callback)
            {
               callback();
            }
         });
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         currentBackButtonCallback();
      }
      
      override public function dispose() : void
      {
         systemMail = null;
         titleText = null;
         rotateImage = null;
         itemIconImage = null;
         itemNumText = null;
         descText = null;
         if(closeButton)
         {
            closeButton.removeEventListener("triggered",triggeredCloseButton);
            closeButton = null;
         }
         super.dispose();
      }
   }
}
