package gudetama.ui
{
   import gudetama.data.GameSetting;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.display.ImageButton;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class InterstitialUI extends BaseScene
   {
       
      
      private var closeBtn:ContainerButton;
      
      private var closeCallback:Function;
      
      private var loadCount:int;
      
      private var interButton:ImageButton;
      
      private var interManager:InterstitialManager;
      
      private var infocallback:Function;
      
      public function InterstitialUI(param1:Function, param2:Function)
      {
         super(2);
         infocallback = param2;
      }
      
      public static function show(param1:Function, param2:Function) : void
      {
         Engine.pushScene(new InterstitialUI(param1,param2),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"InterstitialDialogLayout",function(param1:Object):void
         {
            displaySprite = param1.object;
            closeBtn = displaySprite.getChildByName("closeBtn") as ContainerButton;
            closeBtn.addEventListener("triggered",triggeredCloseBtn);
            var _loc2_:Sprite = displaySprite.getChildByName("sprite") as Sprite;
            interButton = _loc2_.getChildByName("inter") as ImageButton;
            interManager = new InterstitialManager(interButton,GameSetting.def.interTable,close,queue);
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
         interManager.start();
         displaySprite.visible = true;
         if(interManager.getCurrnetInterSetting())
         {
            infocallback(interManager.getCurrnetInterSetting().id#2);
         }
      }
      
      private function triggeredCloseBtn(param1:Event) : void
      {
         if(closeCallback)
         {
            closeCallback();
         }
         close();
      }
      
      private function close() : void
      {
         displaySprite.visible = false;
         Engine.removePopUp(this,false);
         Engine.popScene(scene);
      }
      
      override public function dispose() : void
      {
         if(interManager)
         {
            interManager.dispose();
            interManager = null;
         }
         super.dispose();
      }
   }
}
