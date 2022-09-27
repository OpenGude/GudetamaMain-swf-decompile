package gudetama.ui
{
   import flash.filesystem.File;
   import gudetama.common.BannerAdvertisingManager;
   import gudetama.data.GameSetting;
   import gudetama.data.compati.PromotionVideoDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.RsrcManager;
   import gudetama.engine.SoundManager;
   import gudetama.engine.TweenAnimator;
   import muku.core.MukuGlobal;
   import muku.core.TaskQueue;
   import muku.display.MoviePlayer;
   import starling.display.Quad;
   import starling.display.Sprite;
   
   public class MovieDialog extends BaseScene
   {
       
      
      private var promotionVideoDef:PromotionVideoDef;
      
      private var callback:Function;
      
      private var bg:Quad;
      
      private var moviePlayer:MoviePlayer;
      
      private var timerUI:TimerUI;
      
      private var endCardUI:EndCardUI;
      
      private var loadCount:int;
      
      public function MovieDialog(param1:int, param2:Function)
      {
         super(1);
         promotionVideoDef = GameSetting.getPromotionVideo(param1);
         this.callback = param2;
      }
      
      public static function show(param1:int, param2:Function = null) : void
      {
         Engine.pushScene(new MovieDialog(param1,param2),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"MovieDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            bg = displaySprite.getChildByName("bg") as Quad;
            timerUI = new TimerUI(displaySprite.getChildByName("timer") as Sprite);
            endCardUI = new EndCardUI(displaySprite.getChildByName("endCard") as Sprite,closeEndCardUICallback);
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
         bg.visible = false;
         var path:String = MukuGlobal.makePathFromName("movie-" + promotionVideoDef.movie,".mp4");
         var appDirectory:File = File.applicationDirectory;
         var cacheDirectory:File = RsrcManager.getInstance().getCacheDirectory();
         if(!cacheDirectory.resolvePath(path).exists && !appDirectory.resolvePath(path).exists)
         {
            Engine.showLoading(MovieDialog);
            queue.addTask(function():void
            {
               RsrcManager.getInstance().download(path,function(param1:String):void
               {
                  Engine.hideLoading(MovieDialog);
                  queue.taskDone();
               });
            });
         }
         endCardUI.load(queue,promotionVideoDef);
         queue.addTask(function():void
         {
            TweenAnimator.startItself(displaySprite,!!promotionVideoDef.landscape ? "landscape" : "portrait",false,function():void
            {
               queue.taskDone();
            });
         });
      }
      
      override protected function addedToContainer() : void
      {
         Engine.showLoading(MovieDialog);
         setVisibleState(4);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         moviePlayer = new MoviePlayer(30);
         moviePlayer.setReadyCallback(function():void
         {
            Engine.hideLoading(MovieDialog);
            moviePlayer.play();
            displaySprite.addChildAt(moviePlayer,displaySprite.getChildIndex(bg) + 1);
            timerUI.start(moviePlayer.getPlayTime());
            bg.visible = true;
            setVisibleState(1);
            SoundManager.pauseInApp();
            BannerAdvertisingManager.hideAllBanner();
         });
         moviePlayer.setFinishedCallback(function():void
         {
            if(!endCardUI.show())
            {
               closeEndCardUICallback();
            }
         });
         moviePlayer.setup("movie-" + promotionVideoDef.movie);
      }
      
      private function closeEndCardUICallback() : void
      {
         displaySprite.removeChild(moviePlayer,true);
         moviePlayer = null;
         SoundManager.resumeInApp();
         BannerAdvertisingManager.showBannerAds();
         backButtonCallback();
      }
      
      override public function getSceneFrameRate() : Number
      {
         return 60;
      }
      
      override public function advanceTime(param1:Number) : void
      {
         super.advanceTime(param1);
         if(timerUI && moviePlayer)
         {
            timerUI.advanceTime(moviePlayer.getTime());
         }
         if(moviePlayer)
         {
            moviePlayer.setRequiresRedraw();
         }
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         setBackButtonCallback(null);
         Engine.popScene(scene);
         if(callback)
         {
            callback();
         }
      }
      
      override public function dispose() : void
      {
         bg = null;
         if(moviePlayer)
         {
            moviePlayer.dispose();
            moviePlayer = null;
         }
         if(timerUI)
         {
            timerUI.dispose();
            timerUI = null;
         }
         if(endCardUI)
         {
            endCardUI.dispose();
            endCardUI = null;
         }
         super.dispose();
      }
   }
}

import gudetama.ui.UIBase;
import muku.text.ColorTextField;
import starling.display.Sprite;

class TimerUI extends UIBase
{
    
   
   private var text:ColorTextField;
   
   private var time:Number;
   
   private var playing:Boolean;
   
   private var current:int = -1;
   
   function TimerUI(param1:Sprite)
   {
      super(param1);
      text = param1.getChildByName("text") as ColorTextField;
   }
   
   public function start(param1:Number) : void
   {
      this.time = param1;
      playing = true;
   }
   
   public function advanceTime(param1:Number) : void
   {
      if(!playing)
      {
         return;
      }
      var _loc2_:int = time - param1;
      if(current != _loc2_)
      {
         current = _loc2_;
         text.text#2 = "" + current;
      }
      if(_loc2_ <= 0)
      {
         playing = false;
      }
   }
   
   public function dispose() : void
   {
      text = null;
   }
}

import flash.net.URLRequest;
import flash.net.navigateToURL;
import gudetama.data.GameSetting;
import gudetama.data.compati.PromotionVideoDef;
import gudetama.engine.Engine;
import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import muku.core.TaskQueue;
import muku.display.ContainerButton;
import muku.display.SimpleImageButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class EndCardUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var upperImage:Image;
   
   private var image:Image;
   
   private var closeButton:SimpleImageButton;
   
   private var portraitLinkButton:ContainerButton;
   
   private var portraitLinkText:ColorTextField;
   
   private var landscapeLinkButton:ContainerButton;
   
   private var landscapeLinkText:ColorTextField;
   
   private var promotionVideoDef:PromotionVideoDef;
   
   function EndCardUI(param1:Sprite, param2:Function)
   {
      super(param1);
      this.callback = param2;
      upperImage = param1.getChildByName("upper") as Image;
      image = param1.getChildByName("image") as Image;
      closeButton = param1.getChildByName("closeButton") as SimpleImageButton;
      closeButton.addEventListener("triggered",triggeredCloseButton);
      portraitLinkButton = param1.getChildByName("portraitLinkButton") as ContainerButton;
      portraitLinkButton.addEventListener("triggered",triggeredLinkButton);
      portraitLinkText = portraitLinkButton.getChildByName("text") as ColorTextField;
      landscapeLinkButton = param1.getChildByName("landscapeLinkButton") as ContainerButton;
      landscapeLinkButton.addEventListener("triggered",triggeredLinkButton);
      var _loc3_:Sprite = landscapeLinkButton.getChildByName("sprite") as Sprite;
      landscapeLinkText = _loc3_.getChildByName("text") as ColorTextField;
      setVisible(false);
   }
   
   public function load(param1:TaskQueue, param2:PromotionVideoDef) : void
   {
      var queue:TaskQueue = param1;
      var promotionVideoDef:PromotionVideoDef = param2;
      if(promotionVideoDef.endcard <= 0)
      {
         return;
      }
      this.promotionVideoDef = promotionVideoDef;
      queue.addTask(function():void
      {
         TextureCollector.loadTexture("endcard-" + promotionVideoDef.endcard,function(param1:Texture):void
         {
            image.texture = param1;
            image.readjustSize();
            image.pivotX = 0.5 * image.width;
            image.pivotY = 0.5 * image.height;
            var _loc2_:* = Engine;
            image.scale = Math.min(1,gudetama.engine.Engine.designWidth / image.height);
            upperImage.pivotY = upperImage.height - (image.y - 0.5 * image.width);
            image.rotation = 0.5 * 3.141592653589793;
            queue.taskDone();
         });
      });
      var _loc3_:* = Engine;
      portraitLinkButton.visible = gudetama.engine.Engine.platform == 0 ? promotionVideoDef.urlApple : promotionVideoDef.urlGoogle;
      portraitLinkText.text#2 = !!promotionVideoDef.link ? promotionVideoDef.link : GameSetting.getUIText("movie.button.link");
      var _loc4_:* = Engine;
      landscapeLinkButton.visible = gudetama.engine.Engine.platform == 0 ? promotionVideoDef.urlApple : promotionVideoDef.urlGoogle;
      landscapeLinkText.text#2 = !!promotionVideoDef.link ? promotionVideoDef.link : GameSetting.getUIText("movie.button.link");
   }
   
   public function show() : Boolean
   {
      if(!promotionVideoDef || promotionVideoDef.endcard <= 0)
      {
         return false;
      }
      setVisible(true);
      startTween("show");
      return true;
   }
   
   private function triggeredCloseButton(param1:Event) : void
   {
      if(callback)
      {
         callback();
      }
   }
   
   private function triggeredLinkButton(param1:Event) : void
   {
      var _loc2_:* = Engine;
      navigateToURL(new URLRequest(gudetama.engine.Engine.platform == 0 ? promotionVideoDef.urlApple : promotionVideoDef.urlGoogle),"_self");
   }
   
   public function dispose() : void
   {
      if(promotionVideoDef)
      {
         TextureCollector.clearAtName("endcard-" + promotionVideoDef.endcard);
         promotionVideoDef = null;
      }
      if(closeButton)
      {
         closeButton.removeEventListener("triggered",triggeredCloseButton);
         closeButton = null;
      }
      if(portraitLinkButton)
      {
         portraitLinkButton.removeEventListener("triggered",triggeredLinkButton);
         portraitLinkButton = null;
      }
      if(landscapeLinkButton)
      {
         landscapeLinkButton.removeEventListener("triggered",triggeredLinkButton);
         landscapeLinkButton = null;
      }
   }
}
