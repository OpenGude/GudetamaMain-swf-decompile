package gudetama.scene.home
{
   import gudetama.common.VoiceManager;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.GudetamaDef;
   import gudetama.data.compati.VoiceDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class UnlockVoiceDialog extends BaseScene
   {
      
      private static const ROTATE_TIME:Number = 10;
      
      private static const UPDATE_INTERVAL:int = 1000;
       
      
      private var gudetamaDef:GudetamaDef;
      
      private var voiceDef:VoiceDef;
      
      private var callback:Function;
      
      private var voiceManager:VoiceManager;
      
      private var dialogSprite:Sprite;
      
      private var frameImage:Image;
      
      private var rotateImage:Image;
      
      private var iconImage:Image;
      
      private var voiceText:ColorTextField;
      
      private var underGroup:Sprite;
      
      private var playButton:ContainerButton;
      
      private var playButton2:ContainerButton;
      
      private var playButton2Glitter:Sprite;
      
      private var glitterImage0:Image;
      
      private var glitterImageDefColor0:uint;
      
      private var glitterImage1:Image;
      
      private var glitterImageDefColor1:uint;
      
      private var glitterImage2:Image;
      
      private var glitterImageDefColor2:uint;
      
      private var glitterImage3:Image;
      
      private var glitterImageDefColor3:uint;
      
      private var closeButton:ContainerButton;
      
      private var started:Boolean;
      
      private var nextUpdateTime:int;
      
      private var loadCount:int;
      
      private var passedTime:Number = 0;
      
      private var frameHeight:Number;
      
      private var rare:Boolean = false;
      
      private var titleText:ColorTextField;
      
      public function UnlockVoiceDialog(param1:int, param2:int = -1, param3:Function = null)
      {
         voiceManager = new VoiceManager();
         super(2);
         if(param2 < 0)
         {
            gudetamaDef = GameSetting.getGudetama(UserDataWrapper.wrapper.getPlacedGudetamaId());
         }
         else
         {
            gudetamaDef = GameSetting.getGudetama(param2);
         }
         if(param1 == 1)
         {
            rare = true;
         }
         voiceDef = GameSetting.getVoice(gudetamaDef.voices[param1]);
         this.callback = param3;
      }
      
      public static function show(param1:int, param2:int = -1, param3:Function = null) : void
      {
         Engine.pushScene(new UnlockVoiceDialog(param1,param2,param3),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"UnlockVoiceDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            dialogSprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            frameImage = dialogSprite.getChildByName("frame") as Image;
            frameHeight = frameImage.height;
            rotateImage = dialogSprite.getChildByName("rotate") as Image;
            iconImage = dialogSprite.getChildByName("icon") as Image;
            voiceText = dialogSprite.getChildByName("voice") as ColorTextField;
            underGroup = dialogSprite.getChildByName("underGroup") as Sprite;
            playButton = underGroup.getChildByName("playButton") as ContainerButton;
            var _loc2_:Sprite = underGroup.getChildByName("playButton2Sprite") as Sprite;
            playButton2 = _loc2_.getChildByName("playButton2") as ContainerButton;
            playButton2Glitter = _loc2_.getChildByName("glitterSprite") as Sprite;
            glitterImage0 = playButton2Glitter.getChildByName("glitter0") as Image;
            glitterImage1 = playButton2Glitter.getChildByName("glitter1") as Image;
            glitterImage2 = playButton2Glitter.getChildByName("glitter2") as Image;
            glitterImage3 = playButton2Glitter.getChildByName("glitter3") as Image;
            glitterImageDefColor0 = glitterImage0.color;
            glitterImageDefColor1 = glitterImage1.color;
            glitterImageDefColor2 = glitterImage2.color;
            glitterImageDefColor3 = glitterImage3.color;
            playButton.addEventListener("triggered",triggeredPlayButton);
            playButton2.addEventListener("triggered",triggeredPlayButton);
            if(rare)
            {
               playButton.visible = false;
            }
            else
            {
               playButton2.visible = false;
               playButton2Glitter.visible = false;
            }
            closeButton = underGroup.getChildByName("btn_back") as ContainerButton;
            closeButton.addEventListener("triggered",triggeredCloseButton);
            titleText = dialogSprite.getChildByName("titleText") as ColorTextField;
            if(rare)
            {
               titleText.text#2 = GameSetting.getUIText("unlockVoice2.title");
            }
            else
            {
               titleText.text#2 = GameSetting.getUIText("unlockVoice1.title");
            }
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         queue.registerOnProgress(function(param1:Number):void
         {
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
         queue.addTask(function():void
         {
            TextureCollector.loadTextureRsrc("gudetama-" + gudetamaDef.rsrc + "-icon",function(param1:Texture):void
            {
               iconImage.texture = param1;
               queue.taskDone();
            });
         });
         var offset:Number = -voiceText.height;
         var _loc2_:* = Engine;
         voiceText.height = gudetama.engine.Engine.designHeight;
         voiceText.text#2 = VoiceManager.getCombinedNames(voiceDef);
         voiceText.height = voiceText.fontSize * voiceText.text#2.split("\n").length;
         var offset:Number = offset + voiceText.height;
         frameImage.height = frameHeight + offset;
         underGroup.pivotY = -offset;
         dialogSprite.pivotY = 0.5 * frameImage.height;
         playButton.setEnableWithDrawCache(false);
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(UnlockVoiceDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
         if(checkNoticeTutorial())
         {
            setVisibleState(70);
         }
      }
      
      private function checkNoticeTutorial() : Boolean
      {
         var noticeFlag:int = 20;
         if(noticeFlag != -1)
         {
            processNoticeTutorial(noticeFlag,null,null,function():void
            {
               Engine.unlockTouchInput(UnlockVoiceDialog);
            });
            return true;
         }
         return false;
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            if(rare)
            {
               TweenAnimator.startItself(playButton2Glitter,"glitter");
            }
            Engine.unlockTouchInput(UnlockVoiceDialog);
            triggeredPlayButton();
            started = true;
         });
      }
      
      override public function advanceTime(param1:Number) : void
      {
         super.advanceTime(param1);
         passedTime += param1;
         rotateImage.rotation = 2 * 3.141592653589793 * passedTime / 10;
         if(!started)
         {
            return;
         }
         if(Engine.now < nextUpdateTime)
         {
            return;
         }
         if(rare)
         {
            if(!voiceManager.updateVoice() && !playButton2.enabled)
            {
               playButton2.setEnableWithDrawCache(true);
               glitterImage0.color = glitterImageDefColor0;
               glitterImage1.color = glitterImageDefColor1;
               glitterImage2.color = glitterImageDefColor2;
               glitterImage3.color = glitterImageDefColor3;
               playButton2Glitter.alpha = 1;
            }
         }
         else if(!voiceManager.updateVoice() && !playButton.enabled)
         {
            playButton.setEnableWithDrawCache(true);
         }
         nextUpdateTime = Engine.now + 1000;
      }
      
      private function triggeredPlayButton(param1:Event = null) : void
      {
         voiceManager.playVoice(voiceDef);
         if(rare)
         {
            playButton2.setEnableWithDrawCache(false);
            glitterImage0.color = 13092352;
            glitterImage1.color = 13092352;
            glitterImage2.color = 13092352;
            glitterImage3.color = 13092352;
            playButton2Glitter.alpha = 0.73;
         }
         else
         {
            playButton.setEnableWithDrawCache(false);
         }
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(UnlockVoiceDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(UnlockVoiceDialog);
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
         gudetamaDef = null;
         voiceDef = null;
         dialogSprite = null;
         frameImage = null;
         rotateImage = null;
         iconImage = null;
         voiceText = null;
         underGroup = null;
         playButton.removeEventListener("triggered",triggeredPlayButton);
         playButton = null;
         playButton2.removeEventListener("triggered",triggeredPlayButton);
         playButton2 = null;
         closeButton.removeEventListener("triggered",triggeredCloseButton);
         closeButton = null;
         if(voiceManager)
         {
            voiceManager.dispose();
            voiceManager = null;
         }
         super.dispose();
      }
   }
}
