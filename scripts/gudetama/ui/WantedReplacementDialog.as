package gudetama.ui
{
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.util.StringUtil;
   import muku.display.ContainerButton;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class WantedReplacementDialog extends BaseScene
   {
       
      
      private var gudetamaId:int;
      
      private var callback:Function;
      
      private var gudetamaUIs:Vector.<GudetamaUI>;
      
      private var closeButton:ContainerButton;
      
      public function WantedReplacementDialog(param1:int, param2:Function)
      {
         gudetamaUIs = new Vector.<GudetamaUI>();
         super(2);
         this.gudetamaId = param1;
         this.callback = param2;
      }
      
      public static function show(param1:int, param2:Function = null) : void
      {
         Engine.pushScene(new WantedReplacementDialog(param1,param2),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"WantedReplacementDialog",function(param1:Object):void
         {
            var _loc4_:int = 0;
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            var _loc3_:Sprite = _loc2_.getChildByName("gudetamas") as Sprite;
            _loc4_ = 0;
            while(_loc4_ < _loc3_.numChildren)
            {
               gudetamaUIs.push(new GudetamaUI(_loc3_.getChildByName("gudetama" + _loc4_) as Sprite,triggeredGudetamaUI));
               _loc4_++;
            }
            closeButton = _loc2_.getChildByName("btn_back") as ContainerButton;
            closeButton.addEventListener("triggered",triggeredCloseButton);
            displaySprite.visible = false;
            addChild(displaySprite);
            setup();
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
      
      private function setup() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < gudetamaUIs.length)
         {
            gudetamaUIs[_loc1_].setup(queue,_loc1_);
            _loc1_++;
         }
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(WantedReplacementDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(WantedReplacementDialog);
         });
      }
      
      private function triggeredGudetamaUI(param1:int) : void
      {
         var index:int = param1;
         var _loc2_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(166,[index,gudetamaId]),function(param1:Array):void
         {
            var response:Array = param1;
            UserDataWrapper.wantedPart.setWantedGudetamas(response);
            back(function():void
            {
               LocalMessageDialog.show(0,StringUtil.format(GameSetting.getUIText("gudetamaShortage.wanted.success.desc"),GameSetting.getGudetama(gudetamaId).name#2),function(param1:int):void
               {
                  if(callback)
                  {
                     callback();
                  }
               },GameSetting.getUIText("gudetamaShortage.wanted.title"));
            });
         });
      }
      
      override public function backButtonCallback() : void
      {
         back();
      }
      
      private function back(param1:Function = null) : void
      {
         var callback:Function = param1;
         super.backButtonCallback();
         Engine.lockTouchInput(WantedReplacementDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(WantedReplacementDialog);
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
         for each(var _loc1_ in gudetamaUIs)
         {
            _loc1_.dispose();
         }
         gudetamaUIs.length = 0;
         gudetamaUIs = null;
         closeButton.removeEventListener("triggered",triggeredCloseButton);
         closeButton = null;
         super.dispose();
      }
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.GudetamaDef;
import gudetama.data.compati.UserWantedData;
import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import muku.core.TaskQueue;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class GudetamaUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var button:ContainerButton;
   
   private var iconImage:Image;
   
   private var numberText:ColorTextField;
   
   private var nameText:ColorTextField;
   
   private var index:int;
   
   function GudetamaUI(param1:Sprite, param2:Function)
   {
      super(param1);
      this.callback = param2;
      button = param1.getChildByName("button") as ContainerButton;
      button.addEventListener("triggered",triggeredButton);
      iconImage = button.getChildByName("icon") as Image;
      numberText = button.getChildByName("number") as ColorTextField;
      nameText = button.getChildByName("name") as ColorTextField;
      var _loc3_:Image = param1.getChildByName("imgHappening") as Image;
      _loc3_.visible = false;
   }
   
   public function setup(param1:TaskQueue, param2:int) : void
   {
      var queue:TaskQueue = param1;
      var index:int = param2;
      this.index = index;
      var userWantedData:UserWantedData = UserDataWrapper.wantedPart.getUserWantedData(index);
      var gudetamaDef:GudetamaDef = GameSetting.getGudetama(userWantedData.id#2);
      queue.addTask(function():void
      {
         TextureCollector.loadTextureRsrc(GudetamaUtil.getCollectionIconName(gudetamaDef.id#2),function(param1:Texture):void
         {
            iconImage.texture = param1;
            queue.taskDone();
         });
      });
      if(gudetamaDef.type != 1)
      {
         numberText.visible = false;
      }
      numberText.text#2 = StringUtil.format(GameSetting.getUIText("common.number"),StringUtil.decimalFormat(GameSetting.getUIText("common.number.format"),gudetamaDef.number));
      nameText.text#2 = gudetamaDef.getWrappedName();
   }
   
   private function triggeredButton(param1:Event) : void
   {
      callback(index);
   }
   
   public function dispose() : void
   {
      callback = null;
      button.removeEventListener("triggered",triggeredButton);
      button = null;
      iconImage = null;
      numberText = null;
      nameText = null;
   }
}
