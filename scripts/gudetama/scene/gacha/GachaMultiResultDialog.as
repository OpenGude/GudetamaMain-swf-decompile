package gudetama.scene.gacha
{
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.ItemParam;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.ui.LevelUpDialog;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class GachaMultiResultDialog extends BaseScene
   {
       
      
      private var items:Array;
      
      private var convertedItems:Array;
      
      private var rarities:Array;
      
      private var worthFlags:Array;
      
      private var callback:Function;
      
      private var resultEggs:Vector.<ResultEggUI>;
      
      private var closeButton:ContainerButton;
      
      private var skipButton:ContainerButton;
      
      private var loadCount:int;
      
      private var currentIndex:int;
      
      private var rank:int = -1;
      
      public function GachaMultiResultDialog(param1:Array, param2:Array, param3:Array, param4:Array, param5:int, param6:Function)
      {
         resultEggs = new Vector.<ResultEggUI>();
         super(1);
         this.items = param1;
         this.convertedItems = param2;
         this.rarities = param3;
         this.worthFlags = param4;
         this.callback = param6;
         this.rank = param5;
      }
      
      public static function show(param1:Array, param2:Array, param3:Array, param4:Array, param5:int, param6:Function) : void
      {
         Engine.pushScene(new GachaMultiResultDialog(param1,param2,param3,param4,param5,param6),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"GachaMultiResultDialog",function(param1:Object):void
         {
            var _loc5_:int = 0;
            displaySprite = param1.object;
            var _loc3_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            var _loc2_:Sprite = _loc3_.getChildByName("eggs") as Sprite;
            var _loc4_:Sprite = _loc3_.getChildByName("rotates") as Sprite;
            _loc5_ = 0;
            while(_loc5_ < _loc2_.numChildren)
            {
               resultEggs.push(new ResultEggUI(_loc2_.getChildByName("egg" + _loc5_) as Sprite,_loc4_.getChildByName("rotate" + _loc5_) as Image));
               _loc5_++;
            }
            closeButton = _loc3_.getChildByName("btn_back") as ContainerButton;
            closeButton.addEventListener("triggered",triggeredCloseButton);
            skipButton = displaySprite.getChildByName("skipButton") as ContainerButton;
            skipButton.addEventListener("triggered",triggeredSkipButton);
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
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < items.length)
         {
            resultEggs[_loc1_].setup(queue,items[_loc1_],convertedItems[_loc1_],rarities[_loc1_],worthFlags[_loc1_] != 0);
            _loc1_++;
         }
         while(_loc1_ < resultEggs.length)
         {
            resultEggs[_loc1_].setVisible(false);
            _loc1_++;
         }
         closeButton.visible = false;
         skipButton.visible = true;
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(GachaMultiResultDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(4);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(GachaMultiResultDialog);
            showItem();
         });
      }
      
      private function showItem() : void
      {
         resultEggs[currentIndex].show(function(param1:ItemParam, param2:ItemParam, param3:int, param4:Boolean, param5:Function):void
         {
            var item:ItemParam = param1;
            var convertedItem:ItemParam = param2;
            var rarity:int = param3;
            var worthFlag:Boolean = param4;
            var callback:Function = param5;
            GachaResultDialog.show(item,convertedItem,worthFlag,-1,function():void
            {
               if(closeButton.visible)
               {
                  return;
               }
               callback();
               if(++currentIndex < items.length)
               {
                  showItem();
               }
               else
               {
                  checkLevelUp();
               }
            },triggeredSkipButton);
         });
      }
      
      private function checkLevelUp() : void
      {
         var hasGudetama:Boolean = false;
         var i:int = 0;
         while(i < items.length)
         {
            var item:ItemParam = items[i] as ItemParam;
            if(item.kind == 7)
            {
               hasGudetama = true;
               break;
            }
            i++;
         }
         if(hasGudetama && rank > 0 && rank < UserDataWrapper.wrapper.getRank())
         {
            LevelUpDialog.show(rank,function():void
            {
               finish();
            });
         }
         else
         {
            finish();
         }
      }
      
      private function finish() : void
      {
         closeButton.visible = true;
         skipButton.visible = false;
      }
      
      override public function backButtonCallback() : void
      {
         callback();
         super.backButtonCallback();
         Engine.lockTouchInput(GachaMultiResultDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(GachaMultiResultDialog);
            Engine.popScene(scene);
         });
      }
      
      override public function advanceTime(param1:Number) : void
      {
         super.advanceTime(param1);
         for each(var _loc2_ in resultEggs)
         {
            _loc2_.advanceTime(param1);
         }
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      private function triggeredSkipButton(param1:Event = null) : void
      {
         for each(var _loc2_ in resultEggs)
         {
            _loc2_.showIcon();
         }
         checkLevelUp();
      }
      
      override public function dispose() : void
      {
         items = null;
         rarities = null;
         worthFlags = null;
         for each(var _loc1_ in resultEggs)
         {
            _loc1_.dispose();
         }
         resultEggs.length = 0;
         resultEggs = null;
         if(closeButton)
         {
            closeButton.removeEventListener("triggered",triggeredCloseButton);
            closeButton = null;
         }
         if(skipButton)
         {
            skipButton.removeEventListener("triggered",triggeredSkipButton);
            skipButton = null;
         }
         super.dispose();
      }
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.compati.ItemParam;
import gudetama.engine.Engine;
import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import muku.core.TaskQueue;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.MovieClip;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class ResultEggUI extends UIBase
{
   
   private static const ROTATE_TIME:Number = 10;
    
   
   private var rotateImage:Image;
   
   private var iconImage:Image;
   
   private var duplicateImage:Image;
   
   private var eggMovieClip:MovieClip;
   
   private var item:ItemParam;
   
   private var convertedItem:ItemParam;
   
   private var rarity:int;
   
   private var worthFlag:Boolean;
   
   private var callback:Function;
   
   private var passedTime:Number = 0;
   
   private var cookedStamp:Sprite;
   
   function ResultEggUI(param1:Sprite, param2:Image)
   {
      super(param1);
      this.rotateImage = param2;
      iconImage = param1.getChildByName("icon") as Image;
      duplicateImage = param1.getChildByName("duplicate") as Image;
      eggMovieClip = param1.getChildByName("egg") as MovieClip;
      eggMovieClip.addEventListener("complete",onCompleted);
   }
   
   public function addChild(param1:DisplayObject) : void
   {
      displaySprite.addChild(param1);
   }
   
   public function setup(param1:TaskQueue, param2:ItemParam, param3:ItemParam, param4:int, param5:Boolean) : void
   {
      var queue:TaskQueue = param1;
      var item:ItemParam = param2;
      var convertedItem:ItemParam = param3;
      var rarity:int = param4;
      var worthFlag:Boolean = param5;
      this.item = item;
      this.convertedItem = convertedItem;
      this.rarity = rarity;
      this.worthFlag = worthFlag;
      setVisible(true);
      rotateImage.visible = false;
      iconImage.visible = false;
      queue.addTask(function():void
      {
         TextureCollector.loadTextureRsrc(GudetamaUtil.getItemIconName(item.kind,item.id#2),function(param1:Texture):void
         {
            iconImage.texture = param1;
            queue.taskDone();
         });
      });
      duplicateImage.visible = false;
      if(convertedItem)
      {
         queue.addTask(function():void
         {
            TextureCollector.loadTextureRsrc(GudetamaUtil.getItemIconName(convertedItem.kind,convertedItem.id#2),function(param1:Texture):void
            {
               duplicateImage.texture = param1;
               queue.taskDone();
            });
         });
      }
      eggMovieClip.visible = true;
      eggMovieClip.textureNamePrefix = "gacha1@egg_" + rarity + "_";
      queue.addTask(function():void
      {
         var innerQueue:TaskQueue = new TaskQueue();
         loadEgg(innerQueue,rarity,0);
         loadEgg(innerQueue,rarity,1);
         loadEgg(innerQueue,rarity,2);
         loadEgg(innerQueue,rarity,3);
         if(item.kind == 7)
         {
            Engine.setupLayoutForTask(innerQueue,"_CookedStamp",function(param1:Object):void
            {
               cookedStamp = param1.object;
               cookedStamp.visible = false;
               displaySprite.addChild(cookedStamp);
               innerQueue.taskDone();
            });
         }
         innerQueue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            eggMovieClip.currentTime = 0;
            queue.taskDone();
         });
         innerQueue.startTask();
      });
   }
   
   private function loadEgg(param1:TaskQueue, param2:int, param3:int) : void
   {
      var queue:TaskQueue = param1;
      var rarity:int = param2;
      var index:int = param3;
      queue.addTask(function():void
      {
         TextureCollector.loadTexture("gacha1@egg_" + rarity + "_" + index,function(param1:Texture):void
         {
            eggMovieClip.setFrameTexture(index,param1);
            queue.taskDone();
         });
      });
   }
   
   public function show(param1:Function) : void
   {
      this.callback = param1;
      var _loc2_:* = Starling;
      (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).add(eggMovieClip);
      eggMovieClip.play();
   }
   
   private function onCompleted(param1:Event) : void
   {
      eggMovieClip.pause();
      callback(item,convertedItem,rarity,worthFlag,showIcon);
   }
   
   public function showIcon() : void
   {
      rotateImage.visible = worthFlag;
      iconImage.visible = true;
      duplicateImage.visible = convertedItem;
      eggMovieClip.stop();
      eggMovieClip.dispatchEventWith("removeFromJuggler");
      eggMovieClip.visible = false;
      if(cookedStamp)
      {
         cookedStamp.visible = true;
      }
   }
   
   override public function setVisible(param1:Boolean) : void
   {
      super.setVisible(param1);
      rotateImage.visible = param1;
   }
   
   public function advanceTime(param1:Number) : void
   {
      if(rotateImage.visible)
      {
         passedTime += param1;
         rotateImage.rotation = 2 * 3.141592653589793 * passedTime / 10;
      }
   }
   
   public function dispose() : void
   {
      rotateImage = null;
      iconImage = null;
      if(eggMovieClip)
      {
         eggMovieClip.dispatchEventWith("removeFromJuggler");
         eggMovieClip.removeEventListener("complete",onCompleted);
         eggMovieClip = null;
      }
      item = null;
      callback = null;
      cookedStamp = null;
   }
}
