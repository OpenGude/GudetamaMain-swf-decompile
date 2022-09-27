package gudetama.scene.linkage
{
   import flash.desktop.Clipboard;
   import gudetama.common.DialogSystemMailChecker;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.LinkageData;
   import gudetama.data.compati.LinkageDef;
   import gudetama.data.compati.SystemMailData;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.ui.MessageDialog;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class LinkageDetailDialog extends BaseScene
   {
       
      
      private var id:int;
      
      private var titleText:ColorTextField;
      
      private var descUpperText:ColorTextField;
      
      private var descLowerText:ColorTextField;
      
      private var codeSprite:Sprite;
      
      private var codeText:ColorTextField;
      
      private var copyButton:ContainerButton;
      
      private var lockSprite:Sprite;
      
      private var conditionText:ColorTextField;
      
      private var getButton:ContainerButton;
      
      private var closeButton:ContainerButton;
      
      public function LinkageDetailDialog(param1:int)
      {
         super(2);
         this.id = param1;
      }
      
      public static function show(param1:int) : void
      {
         Engine.pushScene(new LinkageDetailDialog(param1),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"LinkageDetailDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            titleText = _loc2_.getChildByName("title") as ColorTextField;
            descUpperText = _loc2_.getChildByName("descUpper") as ColorTextField;
            descLowerText = _loc2_.getChildByName("descLower") as ColorTextField;
            codeSprite = _loc2_.getChildByName("codeSprite") as Sprite;
            codeText = codeSprite.getChildByName("code") as ColorTextField;
            copyButton = codeSprite.getChildByName("copyButton") as ContainerButton;
            copyButton.addEventListener("triggered",triggeredCopyButton);
            lockSprite = _loc2_.getChildByName("lockSprite") as Sprite;
            conditionText = lockSprite.getChildByName("condition") as ColorTextField;
            getButton = _loc2_.getChildByName("getButton") as ContainerButton;
            getButton.addEventListener("triggered",triggeredGetButton);
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
            setup();
         });
         queue.startTask(onProgress);
      }
      
      private function setup() : void
      {
         var queue:TaskQueue = new TaskQueue();
         var linkageDef:LinkageDef = GameSetting.getLinkage(id);
         titleText.text#2 = linkageDef.title;
         descUpperText.text#2 = StringUtil.format(GameSetting.getUIText("linkageDetail.desc.upper"),linkageDef.name#2);
         descLowerText.text#2 = StringUtil.format(GameSetting.getUIText("linkageDetail.desc.lower"),linkageDef.name#2);
         var linkageData:LinkageData = UserDataWrapper.linkagePart.getLinkage(id);
         if(linkageData)
         {
            codeSprite.visible = true;
            codeText.text#2 = !!linkageData.code ? linkageData.code : "";
            lockSprite.visible = false;
         }
         else
         {
            codeSprite.visible = false;
            lockSprite.visible = true;
            conditionText.text#2 = linkageDef.conditionDesc;
         }
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            start();
         });
         queue.startTask();
      }
      
      private function start() : void
      {
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(LinkageDetailDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(LinkageDetailDialog);
         });
      }
      
      private function triggeredCopyButton(param1:Event) : void
      {
         var _loc2_:LinkageData = UserDataWrapper.linkagePart.getLinkage(id);
         if(!_loc2_ || !_loc2_.code)
         {
            return;
         }
         var _loc3_:Clipboard = Clipboard.generalClipboard;
         _loc3_.setData("air:text",_loc2_.code);
      }
      
      private function triggeredGetButton(param1:Event) : void
      {
         var event:Event = param1;
         var linkageDef:LinkageDef = GameSetting.getLinkage(id);
         var mail:SystemMailData = new SystemMailData();
         mail.type = 10;
         mail.title = linkageDef.linkTitle;
         mail.message = linkageDef.linkMessage;
         mail.url#2 = linkageDef.getUrl(Engine.platform);
         if(mail.url#2.indexOf("direct!") >= 0 && mail.url#2.indexOf("navigate!") >= 0)
         {
            MessageDialog.show(2,GameSetting.getUIText("linkageDetail.toURL.confirm.desc"),function(param1:int):void
            {
               if(param1 == 1)
               {
                  return;
               }
               DialogSystemMailChecker.processDialogMail(mail);
            });
         }
         else
         {
            DialogSystemMailChecker.processDialogMail(mail);
         }
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(LinkageDetailDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(LinkageDetailDialog);
            Engine.popScene(scene);
         });
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         titleText = null;
         descUpperText = null;
         descLowerText = null;
         codeSprite = null;
         codeText = null;
         copyButton.removeEventListener("triggered",triggeredCopyButton);
         copyButton = null;
         lockSprite = null;
         conditionText = null;
         getButton.removeEventListener("triggered",triggeredGetButton);
         getButton = null;
         closeButton.removeEventListener("triggered",triggeredCloseButton);
         closeButton = null;
         super.dispose();
      }
   }
}
