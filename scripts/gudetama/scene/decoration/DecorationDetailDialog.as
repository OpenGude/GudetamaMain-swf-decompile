package gudetama.scene.decoration
{
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.DecorationDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.scene.home.HomeScene;
   import gudetama.ui.LocalMessageDialog;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class DecorationDetailDialog extends BaseScene
   {
      
      public static const TYPE_HOME:int = 0;
      
      public static const TYPE_HOME_DECO:int = 1;
       
      
      private var id:int;
      
      private var rental:Boolean;
      
      private var type:int = 0;
      
      private var iconImage:Image;
      
      private var nameText:ColorTextField;
      
      private var descText:ColorTextField;
      
      private var applyButton:ContainerButton;
      
      private var closeButton:ContainerButton;
      
      private var loadCount:int;
      
      private var callback:Function;
      
      public function DecorationDetailDialog(param1:int, param2:Boolean, param3:int, param4:Function)
      {
         super(2);
         this.id = param1;
         this.rental = param2;
         this.type = param3;
         this.callback = param4;
      }
      
      public static function show(param1:int, param2:Boolean = false, param3:int = 0, param4:Function = null) : void
      {
         Engine.pushScene(new DecorationDetailDialog(param1,param2,param3,param4),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"DecorationDetailDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            iconImage = _loc2_.getChildByName("icon") as Image;
            nameText = _loc2_.getChildByName("title") as ColorTextField;
            descText = _loc2_.getChildByName("desc") as ColorTextField;
            applyButton = _loc2_.getChildByName("changeButton") as ContainerButton;
            applyButton.addEventListener("triggered",triggeredApplyButton);
            closeButton = _loc2_.getChildByName("btn_back") as ContainerButton;
            closeButton.addEventListener("triggered",triggeredCloseButton);
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
         var decorationDef:DecorationDef = GameSetting.getDecoration(id);
         nameText.text#2 = decorationDef.name#2;
         descText.text#2 = decorationDef.desc;
         queue.addTask(function():void
         {
            TextureCollector.loadTexture(GudetamaUtil.getItemImageName(9,id),function(param1:Texture):void
            {
               iconImage.texture = param1;
               queue.taskDone();
            });
         });
         TweenAnimator.startItself(displaySprite,!!rental ? "rental" : "default");
         TweenAnimator.finishItself(displaySprite);
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(DecorationDetailDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(DecorationDetailDialog);
         });
      }
      
      private function triggeredApplyButton(param1:Event) : void
      {
         var event:Event = param1;
         var _loc2_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(HOME_DECORATION_CHANGE,id),function(param1:*):void
         {
            var response:* = param1;
            if(response is Array)
            {
               LocalMessageDialog.show(0,GameSetting.getUIText("decorationDetail.warn.desc." + Math.abs(response[0])),function(param1:int):void
               {
                  Engine.switchScene(new HomeScene());
               },GameSetting.getUIText("decorationDetail.warn.title"));
               return;
            }
            UserDataWrapper.decorationPart.setDecorationId(id);
            if(type == 0)
            {
               ResidentMenuUI_Gudetama.getInstance().sendChangeState(60,function():void
               {
                  Engine.switchScene(new HomeScene());
               });
            }
            else
            {
               if(callback)
               {
                  callback(id);
               }
               backButtonCallback();
            }
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(DecorationDetailDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(DecorationDetailDialog);
            Engine.popScene(scene);
         });
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         nameText = null;
         descText = null;
         if(applyButton)
         {
            applyButton.removeEventListener("triggered",triggeredApplyButton);
            applyButton = null;
         }
         if(closeButton)
         {
            closeButton.removeEventListener("triggered",triggeredCloseButton);
            closeButton = null;
         }
         super.dispose();
      }
   }
}
