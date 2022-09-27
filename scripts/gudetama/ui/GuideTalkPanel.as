package gudetama.ui
{
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.GuideTalkDef;
   import gudetama.data.compati.GuideTalkSentenceParam;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.Logger;
   import gudetama.engine.SoundManager;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.util.StringUtil;
   import muku.text.TypingTextField;
   import muku.util.StarlingUtil;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   import starling.display.Image;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   import starling.textures.Texture;
   
   public class GuideTalkPanel extends BaseScene
   {
      
      private static const ICON_ANIMATION_TIME:int = 300;
       
      
      private var guideTalkDef:GuideTalkDef;
      
      private var callback:Function;
      
      private var guideArrowPosCallback:Function;
      
      private var talking:Boolean;
      
      private var currentSentenceId:int;
      
      private var currentSentence:GuideTalkSentenceParam;
      
      private var currentWordId:int;
      
      private var typingTextField:TypingTextField;
      
      private var arrowIcon:Image;
      
      private var spGuideArrow:Sprite;
      
      private var guideArrow:Image;
      
      private var connectWords:Boolean;
      
      private var sentenceForceTime:uint;
      
      private var sentenceEndTime:uint;
      
      private var textDisplayTime:uint;
      
      private var textDisplay:Boolean;
      
      private var touchableField:Quad;
      
      private var windowGroup:Sprite;
      
      private var interruption:Boolean;
      
      private var defId:int = -1;
      
      private var showFinishFunc:Function;
      
      private var finishCallback:Function;
      
      private var pictureSprite:Sprite;
      
      public function GuideTalkPanel(param1:GuideTalkDef, param2:Function, param3:Function, param4:int, param5:Function, param6:int = 0)
      {
         super(3);
         defId = param4;
         guideTalkDef = param1;
         if(guideTalkDef == null)
         {
            Logger.error("GuideTalkDef is not exists. defId:" + defId + "  tutorialProgress:" + UserDataWrapper.wrapper.getTutorialProgress());
         }
         callback = param2;
         guideArrowPosCallback = param3;
         showFinishFunc = param5;
         currentSentenceId = param6;
         if(currentSentenceId > 0)
         {
            setCurrentWordId();
         }
      }
      
      public static function showTutorial(param1:GuideTalkDef, param2:Function, param3:Function = null, param4:Function = null, param5:int = 0) : void
      {
         Engine.pushScene(new GuideTalkPanel(param1,param2,param3,-1,param4,param5));
      }
      
      public static function showNoticeTutorial(param1:int, param2:GuideTalkDef, param3:Function, param4:Function = null, param5:Function = null) : void
      {
         Engine.pushScene(new GuideTalkPanel(param2,param3,param4,param1,param5,0));
      }
      
      override public function dispose() : void
      {
         super.dispose();
         guideTalkDef = null;
         callback = null;
         currentSentence = null;
         typingTextField = null;
         if(arrowIcon)
         {
            arrowIcon.dispose();
            arrowIcon = null;
         }
         if(windowGroup)
         {
            windowGroup.dispose();
            windowGroup = null;
         }
         displaySprite.removeEventListener("enterFrame",onEnterFrame);
         displaySprite.dispose();
         displaySprite = null;
         if(touchableField)
         {
            touchableField.removeEventListener("touch",onTouch);
            touchableField.dispose();
         }
         touchableField = null;
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"GuideTalkPanelLayout",function(param1:Object):void
         {
            var layout:Object = param1;
            displaySprite = layout.object;
            displaySprite.visible = false;
            typingTextField = StarlingUtil.find(displaySprite,"text") as TypingTextField;
            arrowIcon = StarlingUtil.find(displaySprite,"arrow") as Image;
            TweenAnimator.startItself(arrowIcon,"start");
            arrowIcon.visible = false;
            spGuideArrow = StarlingUtil.find(displaySprite,"spGuideArrow") as Sprite;
            guideArrow = StarlingUtil.find(displaySprite,"guideArrow") as Image;
            var touchableFieldGroup:Sprite = StarlingUtil.find(displaySprite,"touchableFieldGroup") as Sprite;
            var _loc3_:* = Starling;
            var stageWidth:int = starling.core.Starling.sCurrent.stage.stageWidth;
            var _loc4_:* = Starling;
            var stageHeight:int = starling.core.Starling.sCurrent.stage.stageHeight;
            touchableField = new Quad(stageWidth,stageHeight);
            touchableField.alpha = 0;
            touchableField.addEventListener("touch",onTouch);
            touchableFieldGroup.addChild(touchableField);
            windowGroup = StarlingUtil.find(displaySprite,"windowGroup") as Sprite;
            if(guideTalkDef && guideTalkDef.id#2 == 4 + 1000)
            {
               queue.addTask(function():void
               {
                  pictureSprite = StarlingUtil.find(displaySprite,"pictureSprite") as Sprite;
                  TextureCollector.loadTextureRsrc("guide-goldegg",function(param1:Texture):void
                  {
                     var _loc2_:Image = new Image(param1);
                     _loc2_.pivotX = _loc2_.width / 2;
                     _loc2_.pivotY = _loc2_.height / 2;
                     _loc2_.name#2 = "picture";
                     pictureSprite.visible = false;
                     pictureSprite.addChild(_loc2_);
                     queue.taskDone();
                  });
               });
            }
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            start();
         });
         queue.startTask(onProgress);
      }
      
      protected function start() : void
      {
         initTalk();
         displaySprite.visible = true;
         juggler.delayCall(function():void
         {
            Engine.unlockTouchInput(GuideTalkPanel);
            if(showFinishFunc)
            {
               showFinishFunc();
            }
            nextSentence();
         },0.3);
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(GuideTalkPanel);
         ResidentMenuUI_Gudetama.getInstance()._setTouchableMetalButton(false);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         Engine.unlockTouchInput(GuideTalkPanel);
      }
      
      private function initTalk() : void
      {
         initSentence();
      }
      
      private function initSentence() : void
      {
         talking = false;
         displaySprite.removeEventListener("enterFrame",onEnterFrame);
         sentenceEndTime = 0;
         sentenceForceTime = 0;
         textDisplayTime = 0;
      }
      
      private function nextSentence() : void
      {
         initSentence();
         currentSentence = getNextSentence();
         if(!currentSentence)
         {
            finish();
            return;
         }
         loadSentence(currentSentence);
      }
      
      private function getNextSentence() : GuideTalkSentenceParam
      {
         if(!guideTalkDef)
         {
            return null;
         }
         return guideTalkDef.paragraph.sentences[currentSentenceId++];
      }
      
      private function loadSentence(param1:GuideTalkSentenceParam) : void
      {
         var _loc2_:Object = null;
         setupSentence(param1,_loc2_);
      }
      
      private function setupSentence(param1:GuideTalkSentenceParam, param2:Object) : void
      {
         var _loc3_:int = param1.event;
         switch(int(_loc3_) - 5)
         {
            case 0:
               tween(param1);
               break;
            case 3:
               startPicture(param1.paramStr);
               break;
            case 12:
               callback(param1.paramInt);
               break;
            case 13:
               setInterruptionAndSceneMove(true);
               break;
            case 14:
               startGuideArrow(param1.paramInt,param1.paramStr);
         }
         if(!isInterruption())
         {
            startSentence(param1);
         }
      }
      
      private function getWords() : String
      {
         return GameSetting.getGuideText("guideTalk." + guideTalkDef.id#2 + "." + currentWordId++);
      }
      
      private function setCurrentWordId() : void
      {
         var _loc3_:* = 0;
         var _loc1_:* = null;
         var _loc2_:Array = guideTalkDef.paragraph.sentences;
         _loc3_ = uint(0);
         while(_loc3_ < currentSentenceId + 1)
         {
            _loc1_ = _loc2_[_loc3_] as GuideTalkSentenceParam;
            if(_loc1_.word)
            {
               currentWordId++;
            }
            _loc3_++;
         }
         if(currentWordId > 0)
         {
            currentWordId--;
         }
      }
      
      private function startSentence(param1:GuideTalkSentenceParam) : void
      {
         var sentence:GuideTalkSentenceParam = param1;
         var words:Boolean = existsWords();
         if(words)
         {
            if(windowGroup.alpha == 0 && !TweenAnimator.isRunning(windowGroup))
            {
               var textField:TypingTextField = getTextField();
               textField.text#2 = "";
               TweenAnimator.startItself(windowGroup,"show",false,function():void
               {
                  startWords();
               });
            }
            else
            {
               startWords();
            }
         }
         if(sentence.waitTime > 0)
         {
            setSentenceTime(int(sentence.waitTime * 1000));
         }
         if(sentence.forceTime > 0)
         {
            sentenceForceTime = Engine.now + int(sentence.forceTime * 1000);
         }
         displaySprite.addEventListener("enterFrame",onEnterFrame);
      }
      
      private function startWords() : void
      {
         var _loc1_:TypingTextField = getTextField();
         _loc1_.typingSpeed = 20;
         textDisplay = false;
         if(connectWords)
         {
            _loc1_.addText(getWords());
            _loc1_.restartText(0,null);
            textDisplay = true;
         }
         else
         {
            _loc1_.text#2 = getWords();
            if(canStartText())
            {
               _loc1_.startText(0,null);
               textDisplay = true;
            }
         }
         arrowIcon.visible = false;
         talking = true;
         connectWords = currentSentence.nextWordsConnect;
      }
      
      private function getTextField() : TypingTextField
      {
         return typingTextField;
      }
      
      private function setSentenceTime(param1:int) : void
      {
         sentenceEndTime = sentenceEndTime > Engine.now + param1 ? sentenceEndTime : Engine.now + param1;
      }
      
      private function canStartText() : Boolean
      {
         if(textDisplay)
         {
            return false;
         }
         if(Engine.now < textDisplayTime)
         {
            return false;
         }
         return true;
      }
      
      private function isWaiting() : Boolean
      {
         return Engine.now < sentenceEndTime;
      }
      
      private function existsWords() : Boolean
      {
         if(currentSentence == null)
         {
            return true;
         }
         return currentSentence.word;
      }
      
      private function setWaitAnimationTime() : void
      {
         textDisplayTime = Engine.now + 300;
         setSentenceTime(300);
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         var _loc2_:TypingTextField = getTextField();
         if(existsWords())
         {
            if(canStartText())
            {
               _loc2_.startText(0,null);
               textDisplay = true;
            }
            if(!_loc2_.getTyping() && !isWaiting() && textDisplay)
            {
               if(!arrowIcon.visible)
               {
                  if(currentSentence.forceWordsFinish)
                  {
                     nextSentence();
                  }
                  else
                  {
                     arrowIcon.visible = true;
                  }
               }
            }
            if(sentenceForceTime > 0 && Engine.now >= sentenceForceTime)
            {
               nextSentence();
            }
         }
         else if(!isWaiting())
         {
            nextSentence();
         }
      }
      
      private function onTouch(param1:TouchEvent) : void
      {
         if(!talking)
         {
            return;
         }
         var _loc2_:Touch = param1.getTouch(touchableField);
         if(!_loc2_ || _loc2_.phase != "ended")
         {
            return;
         }
         var _loc3_:TypingTextField = getTextField();
         if(!_loc3_.getTyping() && !isWaiting())
         {
            SoundManager.playEffect("btn_normal");
            nextSentence();
         }
         else if(_loc3_.getTyping())
         {
            _loc3_.startText(-1);
         }
      }
      
      public function setInterruptionAndSceneMove(param1:Boolean) : void
      {
         if(!param1)
         {
            spGuideArrow.visible = false;
         }
         interruption = param1;
         touchableField.touchable = !interruption;
      }
      
      public function setInterruption(param1:Boolean) : void
      {
         interruption = param1;
         if(!interruption)
         {
            startSentence(currentSentence);
         }
      }
      
      public function resumeGuideTalk(param1:Function = null, param2:Function = null) : void
      {
         if(!isInterruption())
         {
            return;
         }
         setInterruptionAndSceneMove(false);
         startSentence(currentSentence);
         if(param1 != null)
         {
            callback = param1;
         }
         if(param2 != null)
         {
            guideArrowPosCallback = param2;
         }
      }
      
      private function isInterruption() : Boolean
      {
         return interruption;
      }
      
      private function tween(param1:GuideTalkSentenceParam) : void
      {
         var _loc3_:DisplayObject = getTweenTarget(param1);
         var _loc2_:String = param1.paramStr;
         TweenAnimator.startItself(_loc3_,_loc2_,true);
      }
      
      private function getTweenTarget(param1:GuideTalkSentenceParam) : DisplayObject
      {
         switch(int(param1.paramInt) - 5)
         {
            case 0:
               return windowGroup;
            default:
               return null;
         }
      }
      
      private function startGuideArrow(param1:int, param2:String) : void
      {
         var index:int = param1;
         var str:String = param2;
         var splitedParams:Array = StringUtil.replaceAll(str," ","").split(",");
         var len:uint = splitedParams.length;
         var offset:uint = 15;
         var i:uint = 0;
         while(i < len)
         {
            var params:Array = splitedParams[i].split(":");
            switch(params[0])
            {
               case "type":
                  var isStart:Boolean = params[1] == "start" ? true : false;
                  break;
               case "dir":
                  var vec:Vector.<Number> = guideArrowPosCallback(index);
                  if(!vec)
                  {
                     return;
                  }
                  if(vec.length <= 3)
                  {
                     return;
                  }
                  spGuideArrow.x = vec[0];
                  spGuideArrow.y = vec[1];
                  var objW:Number = vec[2];
                  var objH:Number = vec[3];
                  switch(params[1])
                  {
                     case "top":
                        spGuideArrow.y -= objH / 2;
                        spGuideArrow.y -= guideArrow.height / 2;
                        spGuideArrow.y += offset;
                        spGuideArrow.rotation = 180 * StarlingUtil.degRad;
                        break;
                     case "bottom":
                        spGuideArrow.y += objH / 2;
                        spGuideArrow.y += guideArrow.height / 2;
                        spGuideArrow.y -= offset;
                        spGuideArrow.rotation = 0;
                        break;
                     case "left":
                        spGuideArrow.x -= objW / 2;
                        spGuideArrow.x -= guideArrow.width / 2;
                        spGuideArrow.x += offset;
                        spGuideArrow.rotation = 90 * StarlingUtil.degRad;
                        break;
                     case "right":
                        spGuideArrow.x += objW / 2;
                        spGuideArrow.x += guideArrow.width / 2;
                        spGuideArrow.x -= offset;
                        spGuideArrow.rotation = -90 * StarlingUtil.degRad;
                        break;
                     case "gudetama":
                        spGuideArrow.y -= objH / 2;
                        spGuideArrow.y -= guideArrow.height / 2;
                        spGuideArrow.y += -100;
                        spGuideArrow.rotation = 180 * StarlingUtil.degRad;
                  }
                  break;
            }
            if(!isStart)
            {
               break;
            }
            i++;
         }
         if(isStart)
         {
            spGuideArrow.visible = true;
            TweenAnimator.startItself(spGuideArrow,"show",false,function():void
            {
               TweenAnimator.startItself(spGuideArrow,"move");
            });
         }
         else
         {
            TweenAnimator.startItself(spGuideArrow,"hide",false,function():void
            {
               spGuideArrow.visible = false;
            });
         }
      }
      
      private function startPicture(param1:String) : void
      {
         var str:String = param1;
         var splitedParams:Array = StringUtil.replaceAll(str," ","").split(",");
         var len:uint = splitedParams.length;
         var i:uint = 0;
         while(i < len)
         {
            var params:Array = splitedParams[i].split(":");
            var _loc3_:* = params[0];
            if("type" === _loc3_)
            {
               var isStart:Boolean = params[1] == "start" ? true : false;
            }
            i++;
         }
         if(isStart)
         {
            pictureSprite.visible = true;
            TweenAnimator.start(pictureSprite,"picture","DIALOG_SHOW",null);
         }
         else
         {
            TweenAnimator.start(pictureSprite,"picture","DIALOG_HIDE",function():void
            {
               pictureSprite.dispose();
               pictureSprite = null;
            });
         }
      }
      
      public function getCurrentSentenceId() : int
      {
         return currentSentenceId;
      }
      
      public function getDef() : GuideTalkDef
      {
         return guideTalkDef;
      }
      
      public function getCallback() : Function
      {
         return callback;
      }
      
      public function getGuideArrowCallback() : Function
      {
         return guideArrowPosCallback;
      }
      
      private function doneNoticeTutorial(param1:int) : void
      {
         var noticeFlag:int = param1;
         var _loc2_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(210,noticeFlag),function(param1:*):void
         {
            var response:* = param1;
            if(finishCallback)
            {
               finishCallback();
            }
            TweenAnimator.startItself(displaySprite,"hide",false,function():void
            {
               Engine.unlockTouchInput(GuideTalkPanel);
               Engine.popScene(scene);
            });
         });
      }
      
      public function setFinishCallback(param1:Function) : void
      {
         finishCallback = param1;
      }
      
      public function finish() : void
      {
         talking = false;
         displaySprite.removeEventListener("enterFrame",onEnterFrame);
         Engine.lockTouchInput(GuideTalkPanel);
         ResidentMenuUI_Gudetama.getInstance()._setTouchableMetalButton(true);
         spGuideArrow.alpha = 0;
         if(defId != -1)
         {
            doneNoticeTutorial(defId);
         }
         else
         {
            TweenAnimator.startItself(displaySprite,"hide",false,function():void
            {
               Engine.unlockTouchInput(GuideTalkPanel);
               Engine.popScene(scene);
            });
         }
      }
   }
}
