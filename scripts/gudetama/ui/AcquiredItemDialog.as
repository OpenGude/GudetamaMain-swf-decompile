package gudetama.ui
{
   import gudetama.data.compati.ConvertParam;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.SoundManager;
   import muku.core.TaskQueue;
   import starling.display.Sprite;
   
   public class AcquiredItemDialog extends BaseScene
   {
       
      
      private var items:Array;
      
      private var params:Array;
      
      private var callback:Function;
      
      private var visibleState:int;
      
      private var acquiredItemDialog:_AcquiredItemDialog;
      
      private var convertDialog:_ConvertDialog;
      
      private var dialog:DialogBase;
      
      private var loadCount:int;
      
      private var currentIndex:int;
      
      public function AcquiredItemDialog(param1:Array, param2:Array, param3:Function, param4:int)
      {
         super(2);
         this.items = param1;
         this.params = param2;
         this.callback = param3;
         this.visibleState = param4;
      }
      
      public static function show(param1:Array, param2:Array, param3:Function = null, param4:int = 94) : void
      {
         Engine.pushScene(new AcquiredItemDialog(param1,param2,param3,param4),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"AcquiredItemDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            acquiredItemDialog = new _AcquiredItemDialog(displaySprite.getChildByName("AcquiredItemDialog") as Sprite,closeAcquiredItemDialogCallback);
            convertDialog = new _ConvertDialog(displaySprite.getChildByName("ConvertDialog") as Sprite,closeConvertDialogCallback);
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
         acquiredItemDialog.init();
         convertDialog.init();
         setup();
      }
      
      private function setup() : void
      {
         dialog = acquiredItemDialog;
         dialog.setup(queue,items[currentIndex],params[currentIndex]);
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(AcquiredItemDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(visibleState);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         SoundManager.playEffect("get_item");
         dialog.show(function():void
         {
            Engine.unlockTouchInput(AcquiredItemDialog);
         });
      }
      
      override public function advanceTime(param1:Number) : void
      {
         super.advanceTime(param1);
         dialog.advanceTime(param1);
      }
      
      override public function backButtonCallback() : void
      {
         dialog.hide();
      }
      
      private function next() : void
      {
         if(++currentIndex < items.length)
         {
            dialog = acquiredItemDialog;
            showDialog();
         }
         else
         {
            back();
         }
      }
      
      private function back() : void
      {
         super.backButtonCallback();
         setBackButtonCallback(null);
         Engine.popScene(scene);
         if(callback)
         {
            callback();
         }
      }
      
      private function showDialog() : void
      {
         Engine.lockTouchInput(AcquiredItemDialog);
         var queue:TaskQueue = new TaskQueue();
         dialog.setup(queue,items[currentIndex],params[currentIndex]);
         queue.registerOnProgress(function(param1:Number):void
         {
            var ratio:Number = param1;
            if(ratio < 1)
            {
               return;
            }
            dialog.show(function():void
            {
               Engine.unlockTouchInput(AcquiredItemDialog);
            });
         });
         queue.startTask();
      }
      
      private function closeAcquiredItemDialogCallback() : void
      {
         var _loc1_:* = params[currentIndex];
         if(_loc1_ is ConvertParam && ConvertParam(_loc1_).convertedItem)
         {
            dialog = convertDialog;
            showDialog();
         }
         else
         {
            next();
         }
      }
      
      private function closeConvertDialogCallback() : void
      {
         next();
      }
      
      override public function dispose() : void
      {
         items = null;
         params = null;
         if(acquiredItemDialog)
         {
            acquiredItemDialog.dispose();
            acquiredItemDialog = null;
         }
         if(convertDialog)
         {
            convertDialog.dispose();
            convertDialog = null;
         }
         dialog = null;
         super.dispose();
      }
   }
}

import gudetama.data.compati.ItemParam;
import gudetama.engine.Engine;
import gudetama.ui.UIBase;
import muku.core.TaskQueue;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;

class DialogBase extends UIBase
{
   
   private static const ROTATE_TIME:Number = 10;
    
   
   private var callback:Function;
   
   private var rotateImage:Image;
   
   protected var descText:ColorTextField;
   
   private var closeButton:ContainerButton;
   
   private var passedTime:Number = 0;
   
   function DialogBase(param1:Sprite, param2:Function)
   {
      super(param1);
      this.callback = param2;
      var _loc3_:Sprite = param1.getChildByName("dialogSprite") as Sprite;
      rotateImage = _loc3_.getChildByName("rotate") as Image;
      descText = _loc3_.getChildByName("desc") as ColorTextField;
      closeButton = _loc3_.getChildByName("btn_back") as ContainerButton;
      closeButton.addEventListener("triggered",triggeredCloseButton);
   }
   
   public function init() : void
   {
      setVisible(false);
   }
   
   public function setup(param1:TaskQueue, param2:ItemParam, param3:*) : void
   {
   }
   
   public function show(param1:Function) : void
   {
      var callback:Function = param1;
      setVisible(true);
      startTween("show",false,function():void
      {
         callback();
      });
   }
   
   public function advanceTime(param1:Number) : void
   {
      passedTime += param1;
      rotateImage.rotation = 2 * 3.141592653589793 * passedTime / 10;
   }
   
   private function triggeredCloseButton(param1:Event) : void
   {
      hide();
   }
   
   public function hide() : void
   {
      Engine.lockTouchInput(DialogBase);
      startTween("hide",false,function():void
      {
         Engine.unlockTouchInput(DialogBase);
         setVisible(false);
         if(callback)
         {
            callback();
         }
      });
   }
   
   public function dispose() : void
   {
      callback = null;
      rotateImage = null;
      descText = null;
      if(closeButton)
      {
         closeButton.removeEventListener("triggered",triggeredCloseButton);
         closeButton = null;
      }
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.compati.ItemParam;
import gudetama.engine.TextureCollector;
import gudetama.util.StringUtil;
import muku.core.TaskQueue;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

class _AcquiredItemDialog extends DialogBase
{
    
   
   private var iconImage:Image;
   
   function _AcquiredItemDialog(param1:Sprite, param2:Function)
   {
      super(param1,param2);
      var _loc3_:Sprite = param1.getChildByName("dialogSprite") as Sprite;
      iconImage = _loc3_.getChildByName("icon") as Image;
   }
   
   override public function setup(param1:TaskQueue, param2:ItemParam, param3:*) : void
   {
      var queue:TaskQueue = param1;
      var item:ItemParam = param2;
      var param:* = param3;
      super.setup(queue,item,param);
      var imageName:String = GudetamaUtil.getItemImageName(item.kind,item.id#2);
      if(imageName.length > 0)
      {
         queue.addTask(function():void
         {
            TextureCollector.loadTextureRsrc(imageName,function(param1:Texture):void
            {
               iconImage.texture = param1;
               queue.taskDone();
            });
         });
      }
      descText.text#2 = StringUtil.format(GameSetting.getUIText("acquiredItem.desc"),GudetamaUtil.getItemParamName(item),GudetamaUtil.getItemParamNum(item));
   }
   
   override public function dispose() : void
   {
      iconImage = null;
      super.dispose();
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.compati.ItemParam;
import gudetama.util.StringUtil;
import muku.core.TaskQueue;
import muku.text.ColorTextField;
import starling.display.Sprite;

class _ConvertDialog extends DialogBase
{
    
   
   private var titleText:ColorTextField;
   
   function _ConvertDialog(param1:Sprite, param2:Function)
   {
      super(param1,param2);
      var _loc3_:Sprite = param1.getChildByName("dialogSprite") as Sprite;
      titleText = _loc3_.getChildByName("title") as ColorTextField;
   }
   
   override public function setup(param1:TaskQueue, param2:ItemParam, param3:*) : void
   {
      super.setup(param1,param2,param3);
      titleText.text#2 = StringUtil.format(GameSetting.getUIText("convert.title"),GudetamaUtil.getItemParamName(param3.originalItem));
      descText.text#2 = StringUtil.format(GameSetting.getUIText("convert.desc"),GudetamaUtil.getItemParamName(param3.originalItem),GudetamaUtil.getItemParamNum(param3.originalItem),GudetamaUtil.getItemParamName(param3.convertedItem),GudetamaUtil.getItemParamNum(param3.convertedItem));
   }
   
   override public function dispose() : void
   {
      titleText = null;
      super.dispose();
   }
}
