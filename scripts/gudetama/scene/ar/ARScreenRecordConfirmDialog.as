package gudetama.scene.ar
{
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import starling.display.DisplayObject;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class ARScreenRecordConfirmDialog extends BaseScene
   {
       
      
      private var recordBtn:ContainerButton;
      
      private var closeBtn:ContainerButton;
      
      private var messageImage:Image;
      
      private var messageTexture:Texture;
      
      private var callabck:Function;
      
      public function ARScreenRecordConfirmDialog(param1:Function)
      {
         super(2);
         this.callabck = param1;
      }
      
      public static function show(param1:Function) : void
      {
         Engine.pushScene(new ARScreenRecordConfirmDialog(param1));
      }
      
      override public function dispose() : void
      {
         super.dispose();
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         var preQueue:TaskQueue = new TaskQueue();
         TextureCollector.loadTextureForTask(preQueue,"dialog-002",function(param1:Texture):void
         {
            messageTexture = param1;
         });
         preQueue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            setupLayout(onProgress);
         });
         preQueue.startTask();
      }
      
      private function setupLayout(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"ScreenRecordConfirmDialogLayout",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc3_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            messageImage = _loc3_.getChildByName("messageImage") as Image;
            messageImage.texture = messageTexture;
            var _loc2_:Sprite = _loc3_.getChildByName("buttonSprite") as Sprite;
            var _loc4_:ContainerButton;
            (_loc4_ = _loc2_.getChildByName("btn0") as ContainerButton).addEventListener("triggered",triggeredRecordBtn);
            (_loc4_ = _loc2_.getChildByName("btn1") as ContainerButton).addEventListener("triggered",triggeredCloseBtn);
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         queue.startTask(onProgress);
      }
      
      override protected function addedToContainer() : void
      {
         setBackButtonCallback(backButtonCallback);
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show");
      }
      
      private function triggeredRecordBtn(param1:Event) : void
      {
         close(true);
      }
      
      private function triggeredCloseBtn(param1:Event) : void
      {
         close(false);
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         close(false);
      }
      
      private function close(param1:Boolean) : void
      {
         var result:Boolean = param1;
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function(param1:DisplayObject):void
         {
            Engine.popScene(scene);
            if(callabck)
            {
               callabck(result);
            }
            callabck = null;
         });
      }
   }
}
