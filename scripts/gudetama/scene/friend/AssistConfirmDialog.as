package gudetama.scene.friend
{
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.UsefulData;
   import gudetama.data.compati.UsefulDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.scene.shop.ShopScene_Gudetama;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class AssistConfirmDialog extends BaseScene
   {
       
      
      private var id:int;
      
      private var callback:Function;
      
      private var titleText:ColorTextField;
      
      private var iconImage:Image;
      
      private var numText:ColorTextField;
      
      private var shopButton:ContainerButton;
      
      private var useButton:ContainerButton;
      
      private var lessImage:Image;
      
      private var descText:ColorTextField;
      
      private var closeButton:ContainerButton;
      
      private var loadCount:int;
      
      public function AssistConfirmDialog(param1:int, param2:Function)
      {
         super(2);
         this.id = param1;
         this.callback = param2;
      }
      
      public static function show(param1:int, param2:Function) : void
      {
         Engine.pushScene(new AssistConfirmDialog(param1,param2),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"AssistConfirmDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            titleText = _loc2_.getChildByName("title") as ColorTextField;
            iconImage = _loc2_.getChildByName("icon") as Image;
            numText = _loc2_.getChildByName("num") as ColorTextField;
            shopButton = _loc2_.getChildByName("shopButton") as ContainerButton;
            shopButton.addEventListener("triggered",triggeredShopButton);
            useButton = _loc2_.getChildByName("useButton") as ContainerButton;
            useButton.addEventListener("triggered",triggeredUseButton);
            lessImage = _loc2_.getChildByName("less") as Image;
            descText = _loc2_.getChildByName("desc") as ColorTextField;
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
         setup();
      }
      
      private function setup() : void
      {
         var usefulDef:UsefulDef = GameSetting.getUseful(id);
         var usefulData:UsefulData = UserDataWrapper.usefulPart.getUseful(id);
         var num:int = !!usefulData ? usefulData.num : 0;
         titleText.text#2 = usefulDef.name#2;
         queue.addTask(function():void
         {
            TextureCollector.loadTexture(GudetamaUtil.getItemIconName(8,id),function(param1:Texture):void
            {
               iconImage.texture = param1;
               queue.taskDone();
            });
         });
         numText.text#2 = StringUtil.getNumStringCommas(num);
         descText.text#2 = usefulDef.desc;
         if(usefulDef.price)
         {
            shopButton.visible = true;
            TweenAnimator.startItself(useButton,"num1");
            TweenAnimator.startItself(lessImage,"num1");
         }
         else
         {
            shopButton.visible = false;
            TweenAnimator.startItself(useButton,"num0");
            TweenAnimator.startItself(lessImage,"num0");
         }
         useButton.setEnableWithDrawCache(num > 0);
         lessImage.visible = num <= 0;
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(AssistConfirmDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(92);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(AssistConfirmDialog);
         });
      }
      
      private function triggeredShopButton(param1:Event) : void
      {
         var event:Event = param1;
         ResidentMenuUI_Gudetama.getInstance().sendChangeState(62,function():void
         {
            Engine.switchScene(new ShopScene_Gudetama());
         });
      }
      
      private function triggeredUseButton(param1:Event) : void
      {
         back(callback);
      }
      
      override public function backButtonCallback() : void
      {
         back();
      }
      
      private function back(param1:Function = null) : void
      {
         var callback:Function = param1;
         super.backButtonCallback();
         Engine.lockTouchInput(AssistConfirmDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(AssistConfirmDialog);
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
         iconImage = null;
         numText = null;
         shopButton.removeEventListener("triggered",triggeredShopButton);
         shopButton = null;
         useButton.removeEventListener("triggered",triggeredUseButton);
         useButton = null;
         lessImage = null;
         descText = null;
         closeButton.removeEventListener("triggered",triggeredCloseButton);
         closeButton = null;
         super.dispose();
      }
   }
}
