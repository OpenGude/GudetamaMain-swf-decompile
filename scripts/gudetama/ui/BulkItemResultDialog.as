package gudetama.ui
{
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.GetItemResult;
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
   import starling.textures.Texture;
   
   public class BulkItemResultDialog extends BaseScene
   {
       
      
      private var results:Array;
      
      private var callback:Function;
      
      private var message:String;
      
      private var title:String;
      
      private var dialogSprite:Sprite;
      
      private var titleText:ColorTextField;
      
      private var nameText:ColorTextField;
      
      private var messageText:ColorTextField;
      
      private var prizeImage:Image;
      
      private var togeImage:Image;
      
      private var closeButton:ContainerButton;
      
      private var textureMap:Object;
      
      private var loadCount:int;
      
      private var index:int;
      
      public function BulkItemResultDialog(param1:Array, param2:Function, param3:String, param4:String)
      {
         textureMap = {};
         super(2);
         this.results = param1;
         this.callback = param2;
         this.message = param3;
         this.title = param4;
      }
      
      public static function show(param1:Array, param2:Function, param3:String, param4:String = "") : void
      {
         for each(var _loc5_ in param1)
         {
            if(!_loc5_.toMail)
            {
               UserDataWrapper.wrapper.addItem(_loc5_.item,_loc5_.param);
            }
         }
         Engine.pushScene(new BulkItemResultDialog(param1,param2,param3,param4),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"ItemGetDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            dialogSprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            titleText = dialogSprite.getChildByName("title") as ColorTextField;
            togeImage = dialogSprite.getChildByName("imgToge") as Image;
            nameText = dialogSprite.getChildByName("text") as ColorTextField;
            messageText = dialogSprite.getChildByName("message") as ColorTextField;
            closeButton = dialogSprite.getChildByName("btnClose") as ContainerButton;
            closeButton.addEventListener("triggered",triggeredCloseButton);
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         loadIcons();
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
         });
         queue.startTask(onProgress);
      }
      
      private function loadIcons() : void
      {
         var _loc2_:int = 0;
         var _loc1_:* = null;
         _loc2_ = 0;
         while(_loc2_ < results.length)
         {
            _loc1_ = results[_loc2_];
            loadIcon(_loc2_,GudetamaUtil.getItemImageName(_loc1_.item.kind,_loc1_.item.id#2));
            _loc2_++;
         }
      }
      
      private function loadIcon(param1:int, param2:String) : void
      {
         var index:int = param1;
         var path:String = param2;
         loadCount++;
         TextureCollector.loadTextureForTask(queue,path,function(param1:Texture):void
         {
            loadCount--;
            textureMap[index] = param1;
            checkInit();
         });
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
         var _loc1_:GetItemResult = results[index];
         titleText.text#2 = GameSetting.getUIText(title);
         nameText.text#2 = GudetamaUtil.getItemParamNameAndNum(_loc1_.item);
         messageText.text#2 = StringUtil.format(GameSetting.getUIText(message),GudetamaUtil.getItemParamNameAndNum(_loc1_.item));
         if(_loc1_.toMail)
         {
            messageText.text#2 += "\n\n" + GameSetting.getUIText("common.tomail");
         }
         if(!prizeImage)
         {
            prizeImage = new Image(textureMap[index]);
            prizeImage.alignPivot();
            prizeImage.x = togeImage.x;
            prizeImage.y = togeImage.y;
            dialogSprite.addChild(prizeImage);
         }
         else
         {
            prizeImage.texture = textureMap[index];
            prizeImage.alignPivot();
            prizeImage.x = togeImage.x;
            prizeImage.y = togeImage.y;
         }
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(BulkItemResultDialog);
         setBackButtonCallback(triggeredCloseButton);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         SoundManager.playEffect("MaxComboSuccess");
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(BulkItemResultDialog);
            TweenAnimator.startItself(togeImage,"start");
         });
      }
      
      private function triggeredCloseButton() : void
      {
         backButtonCallback();
      }
      
      override public function backButtonCallback() : void
      {
         if(index + 1 < results.length)
         {
            next();
         }
         else
         {
            back();
         }
      }
      
      private function back() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(BulkItemResultDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(BulkItemResultDialog);
            Engine.popScene(scene);
            var result:GetItemResult = results[index];
            if(!result.toMail)
            {
               ConvertDialog.show([result.item],[result.param],function():void
               {
                  if(callback != null)
                  {
                     callback();
                  }
               });
            }
            else if(callback != null)
            {
               callback();
            }
         });
      }
      
      private function next() : void
      {
         Engine.lockTouchInput(BulkItemResultDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            var result:GetItemResult = results[++index];
            setup();
            SoundManager.playEffect("MaxComboSuccess");
            TweenAnimator.startItself(displaySprite,"show",false,function():void
            {
               Engine.unlockTouchInput(BulkItemResultDialog);
               TweenAnimator.startItself(togeImage,"start");
            });
         });
      }
      
      override public function dispose() : void
      {
         dialogSprite = null;
         titleText = null;
         nameText = null;
         messageText = null;
         togeImage = null;
         if(closeButton)
         {
            closeButton.removeEventListener("triggered",triggeredCloseButton);
            closeButton = null;
         }
         if(textureMap)
         {
            for(var _loc1_ in textureMap)
            {
               delete textureMap[_loc1_];
            }
            textureMap = null;
         }
         super.dispose();
      }
   }
}
