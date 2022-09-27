package gudetama.scene.gacha
{
   import gudetama.data.compati.ItemParam;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.SoundManager;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   
   public class GachaActionDialog extends BaseScene
   {
      
      private static const STATE_NONE:int = 0;
      
      private static const STATE_START:int = 1;
      
      private static const STATE_SHOOT:int = 2;
      
      private static const STATE_CAR:int = 3;
      
      private static const STATE_RESULT:int = 4;
       
      
      private var gachaId:int;
      
      private var items:Array;
      
      private var convertedItems:Array;
      
      private var rarities:Array;
      
      private var worthFlags:Array;
      
      private var callback:Function;
      
      private var quad:Quad;
      
      private var resultUI:ResultUI;
      
      private var carUI:CarUI;
      
      private var machineUI:MachineUI;
      
      private var skipButton:ContainerButton;
      
      private var loadCount:int;
      
      private var state:int;
      
      private var rank:int;
      
      public function GachaActionDialog(param1:int, param2:int, param3:Array, param4:Array, param5:Array, param6:Array, param7:Function)
      {
         super(1);
         this.gachaId = param1;
         this.items = param3;
         this.convertedItems = param4;
         this.rarities = param5;
         this.worthFlags = param6;
         this.callback = param7;
         this.rank = param2;
         disabledUpperButton = true;
      }
      
      public static function preload(param1:int, param2:Function) : void
      {
         var gachaId:int = param1;
         var callback:Function = param2;
         var queue:TaskQueue = new TaskQueue();
         Engine.setupLayoutForTask(queue,"GachaActionDialog",function(param1:Object):void
         {
         });
         MachineUI.preload(queue,gachaId);
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            callback();
         });
         queue.startTask();
      }
      
      public static function show(param1:int, param2:int, param3:Array, param4:Array, param5:Array, param6:Array, param7:Function) : GachaActionDialog
      {
         var _loc8_:GachaActionDialog = new GachaActionDialog(param1,param2,param3,param4,param5,param6,param7);
         Engine.pushScene(_loc8_,0,false);
         return _loc8_;
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"GachaActionDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            quad = displaySprite.getChildByName("quad") as Quad;
            quad.addEventListener("touch",touchQuad);
            resultUI = new ResultUI(displaySprite.getChildByName("resultGroup") as Sprite);
            carUI = new CarUI(displaySprite.getChildByName("carGroup") as Sprite);
            machineUI = new MachineUI(displaySprite.getChildByName("machineGroup") as Sprite);
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
         resultUI.setup();
         carUI.setup(items);
         machineUI.setup(queue,gachaId,items,rarities);
         skipButton.visible = false;
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(GachaActionDialog);
         setBackButtonCallback(null);
         setVisibleState(70);
      }
      
      override protected function transitionOpenFinished() : void
      {
         if(!items)
         {
            if(callback)
            {
               callback();
               callback = null;
            }
            return;
         }
         displaySprite.visible = true;
         machineUI.show();
         Engine.unlockTouchInput(GachaActionDialog);
      }
      
      public function startWithParam(param1:Array, param2:Array, param3:Array, param4:Array, param5:Function) : void
      {
         this.items = param1;
         this.convertedItems = param2;
         this.rarities = param3;
         this.worthFlags = param4;
         this.callback = param5;
         carUI.setup(param1);
         machineUI.setParam(param1,param3);
         displaySprite.visible = true;
         machineUI.show();
         Engine.unlockTouchInput(GachaActionDialog);
      }
      
      private function touchQuad(param1:TouchEvent) : void
      {
         var _loc2_:Touch = param1.getTouch(quad);
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_.phase == "began")
         {
            if(state == 0)
            {
               start();
            }
         }
         else if(_loc2_.phase == "ended")
         {
            if(state == 0)
            {
               state = 2;
            }
            else if(state == 1)
            {
               shoot();
            }
            else if(state == 3)
            {
               carUI.skip();
            }
            else if(state == 4)
            {
               resultUI.skip();
            }
         }
      }
      
      private function start() : void
      {
         machineUI.start(function():void
         {
            if(state == 0)
            {
               state = 1;
            }
            else if(state == 2)
            {
               shoot();
            }
         });
      }
      
      private function shoot() : void
      {
         machineUI.shoot(function():void
         {
            setVisibleState(4);
            skipButton.visible = true;
            carUI.start(function(param1:Boolean):void
            {
               if(items.length > 1)
               {
                  showMulti(param1);
               }
               else
               {
                  showItem(param1);
               }
            });
            state = 3;
         });
         state = 2;
      }
      
      private function showItem(param1:Boolean) : void
      {
         var skippedAll:Boolean = param1;
         var convertedItem:ItemParam = convertedItems[0];
         var rarity:int = rarities[0];
         var worthFlag:Boolean = worthFlags[0] != 0;
         var item:ItemParam = items[0];
         if(skippedAll)
         {
            GachaResultDialog.show(item,convertedItem,worthFlag,rank,function():void
            {
               if(carUI)
               {
                  carUI.finish();
               }
               if(resultUI)
               {
                  resultUI.finish();
               }
               finish();
            });
         }
         else
         {
            resultUI.start(rarity,function():void
            {
               GachaResultDialog.show(item,convertedItem,worthFlag,rank,function():void
               {
                  if(resultUI)
                  {
                     resultUI.finish();
                  }
                  finish();
               });
            });
         }
         state = 4;
      }
      
      private function showMulti(param1:Boolean) : void
      {
         var skippedAll:Boolean = param1;
         var rarity:int = rarities[0];
         if(skippedAll)
         {
            GachaMultiResultDialog.show(items,convertedItems,rarities,worthFlags,rank,function():void
            {
               finish();
            });
         }
         else
         {
            resultUI.start(rarity,function():void
            {
               GachaMultiResultDialog.show(items,convertedItems,rarities,worthFlags,rank,function():void
               {
                  finish();
               });
            });
         }
         state = 4;
      }
      
      private function finish() : void
      {
         backButtonCallback();
      }
      
      private function triggeredSkipButton(param1:Event) : void
      {
         SoundManager.stopEffectAll();
         if(state == 3)
         {
            carUI.skipAll();
         }
         else if(state == 4)
         {
            resultUI.skip();
         }
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(GachaActionDialog);
         setBackButtonCallback(null);
         Engine.unlockTouchInput(GachaActionDialog);
         Engine.popScene(scene);
         if(callback)
         {
            callback();
         }
      }
      
      override public function dispose() : void
      {
         items = null;
         rarities = null;
         quad.removeEventListener("touch",touchQuad);
         quad = null;
         if(resultUI)
         {
            resultUI.dispose();
            resultUI = null;
         }
         if(carUI)
         {
            carUI.dispose();
            carUI = null;
         }
         if(machineUI)
         {
            machineUI.dispose();
            machineUI = null;
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

import gudetama.ui.UIBase;
import muku.display.SpineModel;
import starling.display.Sprite;

class ResultUI extends UIBase
{
    
   
   private var spineModel:SpineModel;
   
   private var callback:Function;
   
   private var skipped:Boolean;
   
   function ResultUI(param1:Sprite)
   {
      super(param1);
      spineModel = param1.getChildByName("result") as SpineModel;
   }
   
   public function setup() : void
   {
      setVisible(false);
   }
   
   public function start(param1:int, param2:Function) : void
   {
      var rarity:int = param1;
      var callback:Function = param2;
      setVisible(true);
      this.callback = callback;
      skipped = false;
      switch(int(rarity))
      {
         case 0:
            var name:String = "normalegg";
            break;
         case 1:
            name = "silveregg";
            break;
         case 2:
            name = "goldegg";
      }
      spineModel.show();
      spineModel.changeAnimation(name,false,function():void
      {
         if(!skipped)
         {
            callback();
         }
      });
      if(skipped)
      {
         skip();
      }
   }
   
   public function finish() : void
   {
      setVisible(false);
   }
   
   public function skip() : void
   {
      callback();
      spineModel.onRemove(true);
      skipped = true;
   }
   
   public function dispose() : void
   {
      spineModel = null;
      callback = null;
   }
}

import gudetama.engine.SoundManager;
import gudetama.ui.UIBase;
import muku.display.SpineModel;
import starling.display.Sprite;

class CarUI extends UIBase
{
    
   
   private var spineModel:SpineModel;
   
   private var items:Array;
   
   private var callback:Function;
   
   private var skipped:Boolean;
   
   private var skippedAll:Boolean;
   
   function CarUI(param1:Sprite)
   {
      super(param1);
      spineModel = param1.getChildByName("car") as SpineModel;
   }
   
   public function setup(param1:Array) : void
   {
      this.items = param1;
      setVisible(false);
   }
   
   public function start(param1:Function) : void
   {
      var callback:Function = param1;
      setVisible(true);
      this.callback = callback;
      skipped = false;
      spineModel.show();
      spineModel.changeAnimation(items.length <= 1 ? "start" : "start2",false,function():void
      {
         if(!skippedAll)
         {
            SoundManager.playEffect("take_off");
            setVisible(false);
         }
         if(!skipped)
         {
            callback(skippedAll);
         }
      });
   }
   
   public function skip() : void
   {
      callback(skippedAll);
      spineModel.onRemove(true);
      skipped = true;
   }
   
   public function skipAll() : void
   {
      skippedAll = true;
      skip();
   }
   
   public function finish() : void
   {
      setVisible(false);
   }
   
   public function dispose() : void
   {
      spineModel = null;
      callback = null;
   }
}

import gudetama.data.GameSetting;
import gudetama.data.compati.GachaDef;
import gudetama.data.compati.ItemParam;
import gudetama.engine.SoundManager;
import gudetama.engine.TweenAnimator;
import gudetama.ui.UIBase;
import muku.core.TaskQueue;
import muku.display.SpineModel;
import starling.display.Sprite;

class MachineUI extends UIBase
{
    
   
   private var spineModel:SpineModel;
   
   private var posSprite:Sprite;
   
   private var eggUI:EggUI;
   
   private var gachaId:int;
   
   private var items:Array;
   
   private var rarities:Array;
   
   private var currentIndex:int;
   
   function MachineUI(param1:Sprite)
   {
      super(param1);
      spineModel = param1.getChildByName("machine") as SpineModel;
      var _loc2_:Sprite = param1.getChildByName("posGroup") as Sprite;
      posSprite = _loc2_.getChildByName("pos0") as Sprite;
      eggUI = new EggUI(posSprite.getChildByName("egg") as Sprite);
   }
   
   public static function preload(param1:TaskQueue, param2:int) : void
   {
      var queue:TaskQueue = param1;
      var gachaId:int = param2;
      var gachaDef:GachaDef = GameSetting.getGacha(gachaId);
      queue.addTask(function():void
      {
         SpineModel.preload("gacha-" + gachaDef.rsrc + "-machine_spine",function():void
         {
            queue.taskDone();
         });
      });
   }
   
   public function setup(param1:TaskQueue, param2:int, param3:Array, param4:Array) : void
   {
      var queue:TaskQueue = param1;
      var gachaId:int = param2;
      var items:Array = param3;
      var rarities:Array = param4;
      this.gachaId = gachaId;
      this.items = items;
      this.rarities = rarities;
      var gachaDef:GachaDef = GameSetting.getGacha(gachaId);
      setVisible(false);
      queue.addTask(function():void
      {
         spineModel.load("gacha-" + gachaDef.rsrc + "-machine_spine",function():void
         {
            queue.taskDone();
         });
      });
   }
   
   public function setParam(param1:Array, param2:Array) : void
   {
      this.items = param1;
      this.rarities = param2;
   }
   
   public function show() : void
   {
      setVisible(true);
      spineModel.show();
      spineModel.changeAnimation("start1_loop");
   }
   
   public function start(param1:Function) : void
   {
      var callback:Function = param1;
      spineModel.changeAnimation(items.length <= 1 ? "start4" : "start2",false,function():void
      {
         spineModel.changeAnimation("start6_loop");
         callback();
      });
   }
   
   public function shoot(param1:Function) : void
   {
      var callback:Function = param1;
      showEggs();
      spineModel.changeAnimation(items.length <= 1 ? "start5" : "start3",false,function():void
      {
         setVisible(false);
         callback();
      });
   }
   
   private function showEggs() : void
   {
      currentIndex = 0;
      showEgg();
   }
   
   private function showEgg() : void
   {
      var item:ItemParam = items[currentIndex];
      var rarity:int = rarities[currentIndex];
      SoundManager.playEffect("pon");
      eggUI.setup(rarity);
      TweenAnimator.startItself(posSprite,"pos" + currentIndex % 3);
      TweenAnimator.finishItself(posSprite);
      TweenAnimator.startItself(posSprite,"show",false,function():void
      {
         if(++currentIndex < items.length)
         {
            showEgg();
         }
      });
   }
   
   public function dispose() : void
   {
      spineModel = null;
      posSprite = null;
      if(eggUI)
      {
         eggUI.dispose();
         eggUI = null;
      }
   }
}

import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

class EggUI extends UIBase
{
    
   
   private var eggImage:Image;
   
   function EggUI(param1:Sprite)
   {
      super(param1);
      eggImage = param1.getChildByName("egg") as Image;
   }
   
   public function setup(param1:int) : void
   {
      var rarity:int = param1;
      TextureCollector.loadTexture("gacha1@egg_" + rarity,function(param1:Texture):void
      {
         if(eggImage != null)
         {
            eggImage.texture = param1;
         }
      });
   }
   
   public function dispose() : void
   {
      eggImage = null;
   }
}
