package gudetama.scene.home
{
   import gudetama.data.GameSetting;
   import gudetama.data.compati.GetItemResult;
   import gudetama.data.compati.HideGudetamaDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.SoundManager;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.ui.ItemGetDialog;
   import muku.display.ContainerButton;
   import muku.display.SimpleImageButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.textures.Texture;
   
   public class HideGudetamaTouchDialog extends BaseScene
   {
       
      
      private var hideGudeId:int;
      
      private var result:GetItemResult;
      
      private var homeScene:HomeScene;
      
      private var callback:Function;
      
      private var imgGude:Image;
      
      private var texGude:Texture;
      
      private var imgToge:Image;
      
      private var message:ColorTextField;
      
      private var btnShare:SimpleImageButton;
      
      private var btnClose:ContainerButton;
      
      public function HideGudetamaTouchDialog(param1:int, param2:GetItemResult, param3:HomeScene, param4:Function)
      {
         super(2);
         this.hideGudeId = param1;
         this.result = param2;
         this.homeScene = param3;
         this.callback = param4;
      }
      
      public static function show(param1:int, param2:GetItemResult, param3:HomeScene, param4:Function) : void
      {
         Engine.pushScene(new HideGudetamaTouchDialog(param1,param2,param3,param4),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"HideGudetamaTouchDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc3_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            imgToge = _loc3_.getChildByName("imgToge") as Image;
            var _loc2_:HideGudetamaDef = GameSetting.def.hideGudeMap[hideGudeId];
            var _loc4_:String = _loc2_ != null ? _loc2_.name#2 : "";
            message = _loc3_.getChildByName("message") as ColorTextField;
            message.text#2 = _loc4_;
            btnShare = _loc3_.getChildByName("btnShare") as SimpleImageButton;
            btnShare.addEventListener("triggered",triggeredShare);
            btnClose = _loc3_.getChildByName("btnClose") as ContainerButton;
            btnClose.addEventListener("triggered",triggeredClose);
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         TextureCollector.loadTextureForTask(queue,"hideGude-" + hideGudeId,function(param1:Texture):void
         {
            texGude = param1;
         });
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            imgGude = new Image(texGude);
            imgGude.alignPivot();
            imgGude.x = imgToge.x;
            imgGude.y = imgToge.y;
            (displaySprite.getChildByName("dialogSprite") as Sprite).addChild(imgGude);
         });
         queue.startTask(onProgress);
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(HideGudetamaTouchDialog);
         setBackButtonCallback(triggeredClose);
         setVisibleState(94);
         if(checkNoticeTutorial())
         {
            setVisibleState(70);
         }
      }
      
      private function checkNoticeTutorial() : Boolean
      {
         return resumeNoticeTutorial(25);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         SoundManager.playEffect("MaxComboSuccess");
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(HideGudetamaTouchDialog);
            TweenAnimator.startItself(imgToge,"start");
         });
      }
      
      private function triggeredShare() : void
      {
         var dialog:HideGudetamaTouchDialog = this;
         dialog.visible = false;
         homeScene.procHideGudetamaShare(message.text#2,function():void
         {
            dialog.visible = true;
         });
      }
      
      private function triggeredClose() : void
      {
         backButtonCallback();
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(HideGudetamaTouchDialog);
         setBackButtonCallback(null);
         ItemGetDialog.show(result,callback,GameSetting.getUIText("hide.gudetama.touch.prize"),GameSetting.getUIText("hide.gudetama.touch.title2"));
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(HideGudetamaTouchDialog);
            Engine.popScene(scene);
         });
      }
      
      override public function dispose() : void
      {
         imgToge = null;
         message = null;
         imgGude = null;
         texGude = null;
         btnShare.removeEventListener("triggered",triggeredShare);
         btnShare = null;
         btnClose.removeEventListener("triggered",triggeredClose);
         btnClose = null;
         super.dispose();
      }
   }
}
