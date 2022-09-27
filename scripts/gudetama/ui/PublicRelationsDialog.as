package gudetama.ui
{
   import flash.display.BitmapData;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import muku.core.TaskQueue;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   import starling.textures.Texture;
   
   public class PublicRelationsDialog extends BaseScene
   {
       
      
      private var message:String;
      
      private var imagePath:String;
      
      private var identifiedPresentId:int;
      
      private var callback:Function;
      
      private var bgQuad:Quad;
      
      private var image:Image;
      
      private var messageGroup:Sprite;
      
      private var messageText:ColorTextField;
      
      private var loadCount:int;
      
      private var bitmapData:BitmapData;
      
      public function PublicRelationsDialog(param1:String, param2:String, param3:int, param4:Function)
      {
         super(1);
         this.message = param1;
         this.imagePath = param2;
         this.identifiedPresentId = param3;
         this.callback = param4;
      }
      
      public static function show(param1:String, param2:String, param3:int, param4:Function) : void
      {
         Engine.pushScene(new PublicRelationsDialog(param1,param2,param3,param4),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"PublicRelationsDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            bgQuad = displaySprite.getChildByName("bg") as Quad;
            bgQuad.addEventListener("touch",touchQuad);
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            image = _loc2_.getChildByName("image") as Image;
            messageGroup = _loc2_.getChildByName("messageGroup") as Sprite;
            messageText = messageGroup.getChildByName("message") as ColorTextField;
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
         messageText.text#2 = message;
         queue.addTask(function():void
         {
            TextureCollector.loadTexture(imagePath,function(param1:Texture, param2:BitmapData = null):void
            {
               image.texture = param1;
               image.readjustSize();
               image.pivotX = 0.5 * image.width;
               image.pivotY = 0.5 * image.height;
               bitmapData = param2;
               queue.taskDone();
            });
         });
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(PublicRelationsDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(4);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(PublicRelationsDialog);
         });
      }
      
      private function touchQuad(param1:TouchEvent) : void
      {
         var event:TouchEvent = param1;
         var touch:Touch = event.getTouch(bgQuad);
         if(touch == null)
         {
            return;
         }
         if(touch.phase == "ended")
         {
            PRShareDialog.show(identifiedPresentId,bitmapData,function():void
            {
               backButtonCallback();
            });
            bgQuad.touchable = false;
         }
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(PublicRelationsDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(PublicRelationsDialog);
            Engine.popScene(scene);
            if(callback)
            {
               callback();
            }
         });
      }
      
      override public function dispose() : void
      {
         TextureCollector.clearAtName(imagePath);
         if(bgQuad)
         {
            bgQuad.removeEventListener("touch",touchQuad);
            bgQuad = null;
         }
         messageGroup = null;
         messageText = null;
         super.dispose();
      }
   }
}
