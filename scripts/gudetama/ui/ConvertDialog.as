package gudetama.ui
{
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.compati.ConvertParam;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class ConvertDialog extends BaseScene
   {
      
      private static const ROTATE_TIME:Number = 10;
       
      
      private var items:Array;
      
      private var params:Array;
      
      private var callback:Function;
      
      private var titleText:ColorTextField;
      
      private var descText:ColorTextField;
      
      private var rotateImage:Image;
      
      private var closeButton:ContainerButton;
      
      private var loadCount:int;
      
      private var index:int = -1;
      
      private var passedTime:Number = 0;
      
      public function ConvertDialog(param1:Array, param2:Array, param3:Function)
      {
         super(2);
         this.items = param1;
         this.params = param2;
         this.callback = param3;
      }
      
      public static function show(param1:Array, param2:Array, param3:Function = null) : void
      {
         if(!existsConvertedItem(param2))
         {
            if(param3)
            {
               param3();
            }
            return;
         }
         Engine.pushScene(new ConvertDialog(param1,param2,param3),0,false);
      }
      
      public static function existsConvertedItem(param1:Array) : Boolean
      {
         for each(var _loc2_ in param1)
         {
            if(_loc2_ is ConvertParam && ConvertParam(_loc2_).convertedItem)
            {
               return true;
            }
         }
         return false;
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"ConvertDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            titleText = _loc2_.getChildByName("title") as ColorTextField;
            descText = _loc2_.getChildByName("desc") as ColorTextField;
            rotateImage = _loc2_.getChildByName("rotate") as Image;
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
         setup(getNextConvertParam());
      }
      
      private function setup(param1:ConvertParam, param2:Function = null) : void
      {
         titleText.text#2 = StringUtil.format(GameSetting.getUIText("convert.title"),GudetamaUtil.getItemParamName(param1.originalItem));
         descText.text#2 = StringUtil.format(GameSetting.getUIText("convert.desc"),GudetamaUtil.getItemParamName(param1.originalItem),GudetamaUtil.getItemParamNum(param1.originalItem),GudetamaUtil.getItemParamName(param1.convertedItem),GudetamaUtil.getItemParamNum(param1.convertedItem));
         if(param2)
         {
            param2();
         }
      }
      
      private function getNextConvertParam() : ConvertParam
      {
         var _loc1_:* = undefined;
         ++index;
         while(index < params.length)
         {
            _loc1_ = params[index];
            if(_loc1_ is ConvertParam && ConvertParam(_loc1_).convertedItem)
            {
               return _loc1_;
            }
            index++;
         }
         return null;
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(ConvertDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(ConvertDialog);
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
         var _loc1_:ConvertParam = getNextConvertParam();
         if(_loc1_)
         {
            next(_loc1_);
         }
         else
         {
            close();
         }
      }
      
      private function next(param1:ConvertParam) : void
      {
         var convert:ConvertParam = param1;
         Engine.lockTouchInput(ConvertDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            setup(convert,function():void
            {
               setBackButtonCallback(backButtonCallback);
               TweenAnimator.startItself(displaySprite,"show",false,function():void
               {
                  Engine.unlockTouchInput(ConvertDialog);
               });
            });
         });
      }
      
      private function close() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(ConvertDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(ConvertDialog);
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
         titleText = null;
         descText = null;
         rotateImage = null;
         if(closeButton)
         {
            closeButton.removeEventListener("triggered",triggeredCloseButton);
            closeButton = null;
         }
         super.dispose();
      }
   }
}
