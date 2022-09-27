package gudetama.scene.home
{
   import feathers.controls.IScrollBar;
   import feathers.controls.ScrollBar;
   import feathers.controls.ScrollContainer;
   import flash.geom.Rectangle;
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.ui.WebViewDialog;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class InquiryDialog extends BaseScene
   {
       
      
      private var fromTitle:Boolean;
      
      private var helpButton:ContainerButton;
      
      private var inquiryButton:ContainerButton;
      
      private var closeButton:ContainerButton;
      
      private var scroll:ScrollContainer;
      
      public function InquiryDialog(param1:Boolean)
      {
         super(2);
         this.fromTitle = param1;
      }
      
      public static function show(param1:Boolean) : void
      {
         Engine.pushScene(new InquiryDialog(param1),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"InquiryDialog",function(param1:Object):void
         {
            var layout:Object = param1;
            displaySprite = layout.object;
            var dialogSprite:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            scroll = dialogSprite.getChildByName("scroll") as ScrollContainer;
            scroll.verticalScrollBarFactory = function():IScrollBar
            {
               var _loc1_:ScrollBar = new ScrollBar();
               _loc1_.trackLayoutMode = "single";
               return _loc1_;
            };
            scroll.scrollBarDisplayMode = "fixedFloat";
            scroll.horizontalScrollPolicy = "off";
            scroll.verticalScrollPolicy = "auto";
            scroll.interactionMode = "touchAndScrollBars";
            var msg:ColorTextField = scroll.getChildByName("message") as ColorTextField;
            msg.height = 9999;
            var rect:Rectangle = msg.textBounds;
            var _h:Number = rect.height + msg.fontSize;
            msg.height = _h;
            helpButton = dialogSprite.getChildByName("btn_help") as ContainerButton;
            helpButton.addEventListener("triggered",triggeredHelpButton);
            inquiryButton = dialogSprite.getChildByName("btn_inquiry") as ContainerButton;
            inquiryButton.addEventListener("triggered",triggeredInquiryButton);
            closeButton = dialogSprite.getChildByName("btn_close") as ContainerButton;
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
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(InquiryDialog);
         if(fromTitle)
         {
            setVisibleState(68);
         }
         else
         {
            setBackButtonCallback(backButtonCallback);
            setVisibleState(94);
         }
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(InquiryDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(InquiryDialog);
         if(!fromTitle)
         {
            setBackButtonCallback(null);
         }
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(InquiryDialog);
            Engine.popScene(scene);
         });
      }
      
      private function triggeredHelpButton(param1:Event) : void
      {
         GudetamaUtil.showHelpPage();
      }
      
      private function triggeredInquiryButton(param1:Event) : void
      {
         WebViewDialog.show(GameSetting.getOtherText("url.contact").replace("%1",UserDataWrapper.wrapper.getFriendKey()));
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         helpButton.removeEventListener("triggered",triggeredHelpButton);
         helpButton = null;
         inquiryButton.removeEventListener("triggered",triggeredInquiryButton);
         inquiryButton = null;
         closeButton.removeEventListener("triggered",triggeredCloseButton);
         closeButton = null;
         super.dispose();
      }
   }
}
