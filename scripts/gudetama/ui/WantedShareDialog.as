package gudetama.ui
{
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.GudetamaDef;
   import gudetama.engine.Engine;
   import gudetama.engine.SoundManager;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ManuallySpineButton;
   import muku.text.ColorTextField;
   import starling.display.DisplayObject;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.textures.Texture;
   
   public class WantedShareDialog extends GudetamaShareDialog
   {
       
      
      private var GP_COLOR1:int = 4335381;
      
      private var GP_COLOR2:int = 5521976;
      
      private var gudeNum:int;
      
      private var gudeDef1:GudetamaDef;
      
      private var gudeDef2:GudetamaDef;
      
      private var txtGp:ColorTextField;
      
      private var txtNumber0:ColorTextField;
      
      private var txtGude0:ColorTextField;
      
      private var gude1:ManuallySpineButton;
      
      private var txtNumber1:ColorTextField;
      
      private var txtGude1:ColorTextField;
      
      private var gude2:ManuallySpineButton;
      
      private var txtNumber2:ColorTextField;
      
      private var txtGude2:ColorTextField;
      
      private var patternName:String;
      
      public function WantedShareDialog(param1:Array)
      {
         super(param1);
         gudeNum = param1.length;
         if(gudeNum > 1)
         {
            gudeDef1 = GameSetting.getGudetama(param1[1]);
         }
         if(gudeNum > 2)
         {
            gudeDef2 = GameSetting.getGudetama(param1[2]);
         }
      }
      
      public static function show(param1:Array) : void
      {
         Engine.pushScene(new WantedShareDialog(param1));
      }
      
      override public function dispose() : void
      {
         super.dispose();
         Engine.removeTouchStageCallback(touchedStage);
      }
      
      override protected function loadLayout(param1:TaskQueue) : void
      {
         var queue:TaskQueue = param1;
         Engine.setupLayoutForTask(queue,"WantedShareDialog",function(param1:Object):void
         {
            displaySprite = param1.object as Sprite;
            bg = displaySprite.getChildByName("bg") as Image;
            gude2 = displaySprite.getChildByName("gude2") as ManuallySpineButton;
            gude2.visible = false;
            gude2.touchable = false;
            txtNumber2 = displaySprite.getChildByName("number2") as ColorTextField;
            txtNumber2.visible = false;
            txtGude2 = displaySprite.getChildByName("name2") as ColorTextField;
            txtGude2.visible = false;
            gude1 = displaySprite.getChildByName("gude1") as ManuallySpineButton;
            gude1.visible = false;
            gude1.touchable = false;
            txtNumber1 = displaySprite.getChildByName("number1") as ColorTextField;
            txtNumber1.visible = false;
            txtGude1 = displaySprite.getChildByName("name1") as ColorTextField;
            txtGude1.visible = false;
            gudetamaSpine = displaySprite.getChildByName("gude0") as ManuallySpineButton;
            gudetamaSpine.visible = false;
            gudetamaSpine.touchable = false;
            txtNumber0 = displaySprite.getChildByName("number0") as ColorTextField;
            txtNumber0.visible = false;
            txtGude0 = displaySprite.getChildByName("name0") as ColorTextField;
            txtGude0.visible = false;
            txtGp = displaySprite.getChildByName("gp") as ColorTextField;
            txtGp.visible = false;
            var _loc2_:int = int(Math.random() * 2) + 1;
            patternName = _loc2_ + "_" + gudeNum;
            txtNumber0.text#2 = getGudeNumberText(gudetamaDef);
            txtGude0.text#2 = gudetamaDef.name#2;
            if(gudeNum == 1)
            {
               txtGp.color = _loc2_ == 1 ? GP_COLOR1 : int(GP_COLOR2);
               txtGp.text#2 = StringUtil.getNumStringCommas(gudetamaDef.reward);
            }
            else
            {
               txtNumber1.text#2 = getGudeNumberText(gudeDef1);
               txtGude1.text#2 = gudeDef1.name#2;
               if(gudeNum == 3)
               {
                  txtNumber2.text#2 = getGudeNumberText(gudeDef2);
                  txtGude2.text#2 = gudeDef2.name#2;
                  if(_loc2_ == 1)
                  {
                     txtNumber0.format.horizontalAlign = "right";
                     txtNumber2.format.horizontalAlign = "right";
                  }
                  else if(_loc2_ == 2)
                  {
                     txtNumber1.format.horizontalAlign = "right";
                  }
               }
            }
            displaySprite.visible = false;
            addChild(displaySprite);
         });
      }
      
      private function getGudeNumberText(param1:GudetamaDef) : String
      {
         if(param1.type != 1)
         {
            return "";
         }
         return StringUtil.format(GameSetting.getUIText("gudetamaDetail.number"),param1.number);
      }
      
      override protected function setup(param1:Function) : void
      {
         var onProgress:Function = param1;
         SoundManager.playEffect("capture");
         gudetamaSpine.setup(queue,gudetamaDef.id#2);
         if(gudeNum >= 2)
         {
            gude1.setup(queue,gudeDef1.id#2);
         }
         if(gudeNum >= 3)
         {
            gude2.setup(queue,gudeDef2.id#2);
         }
         var bgName:String = "bg-background_wanted" + patternName;
         TextureCollector.loadTextureForTask(queue,bgName,function(param1:Texture):void
         {
            bg.texture = param1;
            bg.readjustSize();
         });
         queue.startTask(onProgress);
      }
      
      override protected function addedToContainer() : void
      {
         var _loc1_:* = NaN;
         super.addedToContainer();
         initTween(gudetamaSpine,patternName);
         initTween(txtNumber0,patternName);
         initTween(txtGude0,patternName);
         if(gudeNum == 1)
         {
            initTween(txtGp,patternName);
         }
         if(gudeNum >= 2)
         {
            initTween(gude1,patternName);
            initTween(txtNumber1,patternName);
            initTween(txtGude1,patternName);
            if(gudeNum >= 3)
            {
               initTween(gude2,patternName);
               initTween(txtNumber2,patternName);
               initTween(txtGude2,patternName);
               _loc1_ = 0.6;
               gudetamaSpine.scale = _loc1_;
               gude1.scale = _loc1_;
               gude2.scale = _loc1_;
            }
         }
      }
      
      private function initTween(param1:DisplayObject, param2:String) : void
      {
         var obj:DisplayObject = param1;
         var twName:String = param2;
         TweenAnimator.startItself(obj,twName,true,function(param1:DisplayObject):void
         {
            obj.visible = true;
         });
      }
      
      override protected function getShareType() : int
      {
         return 3;
      }
      
      override protected function getShareOptionMessage() : String
      {
         var _loc1_:* = UserDataWrapper;
         return String(gudetama.data.UserDataWrapper.wrapper._data.encodedUid);
      }
   }
}
