package gudetama.scene.home.ui
{
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.engine.BaseScene;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.scene.home.HomeScene;
   import gudetama.ui.CupGachaSlotDialog;
   import gudetama.ui.LocalMessageDialog;
   import gudetama.ui.UIBase;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.textures.Texture;
   
   public class CupGachaButton extends UIBase
   {
       
      
      private var scene:HomeScene;
      
      private var button:ContainerButton;
      
      private var imgKettle:Image;
      
      private var imgClose:Image;
      
      private var imgOpen:Image;
      
      private var stateSprite:Sprite;
      
      private var timeText:ColorTextField;
      
      private var btnMini:ContainerButton;
      
      private var imgBalloon4Mini:Image;
      
      private var spFinish4Mini:Sprite;
      
      private var imgClose4Mini:Image;
      
      private var imgOpen4Mini:Image;
      
      private var currentCupImageId:int = -1;
      
      private var currentCupState:int = -1;
      
      private var lastHour:int = -1;
      
      private var lastMinute:int = -1;
      
      private var lastSecond:int = -1;
      
      private var state:int = -1;
      
      public function CupGachaButton(param1:Sprite, param2:ContainerButton = null, param3:BaseScene = null)
      {
         super(param1);
         this.scene = HomeScene(param3);
         this.btnMini = param2;
         button = param1.getChildByName("button") as ContainerButton;
         button.setStopPropagation(true);
         button.addEventListener("triggered",triggered);
         imgKettle = button.getChildByName("imgKettle") as Image;
         imgClose = button.getChildByName("imgClose") as Image;
         imgOpen = button.getChildByName("imgOpen") as Image;
         stateSprite = param1.getChildByName("stateSprite") as Sprite;
         var _loc4_:Sprite;
         timeText = (_loc4_ = stateSprite.getChildByName("making") as Sprite).getChildByName("time") as ColorTextField;
         if(param2)
         {
            param2.addEventListener("triggered",triggeredMini);
            imgBalloon4Mini = param2.getChildByName("imgBalloon") as Image;
            spFinish4Mini = param2.getChildByName("spFinish") as Sprite;
            imgClose4Mini = spFinish4Mini.getChildByName("imgCooking") as Image;
            imgOpen4Mini = param2.getChildByName("imgNoCook") as Image;
         }
      }
      
      public function setup(param1:int = -1) : void
      {
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         var _loc5_:int = 0;
         var _loc2_:UserDataWrapper = UserDataWrapper.wrapper;
         if(_loc2_.isCooking4CupGacha())
         {
            _loc4_ = _loc2_.getCookIndex4CupGacha();
            _loc3_ = _loc2_.getCupGachaIdAt(_loc4_);
            changeCupImage(_loc3_,false);
            imgKettle.visible = false;
            if(param1 == -1)
            {
               param1 = _loc2_.getRestSec4CupGacha();
            }
            if(param1 <= 0)
            {
               if(state != 2)
               {
                  TweenAnimator.startItself(stateSprite,"state2");
                  TweenAnimator.finishItself(stateSprite);
                  if(btnMini)
                  {
                     TweenAnimator.startItself(imgBalloon4Mini,"show");
                     TweenAnimator.startItself(spFinish4Mini,"show");
                  }
               }
               state = 2;
               if(btnMini)
               {
                  spFinish4Mini.visible = true;
                  btnMini.visible = true;
               }
            }
            else
            {
               if(state != 1)
               {
                  TweenAnimator.startItself(stateSprite,"state1");
                  TweenAnimator.finishItself(stateSprite);
               }
               state = 1;
               if(btnMini)
               {
                  btnMini.visible = false;
               }
            }
         }
         else
         {
            _loc5_ = _loc2_.getCupGachaIdAt(_loc2_.getCupGachaIndexNoEmpty());
            if(state != 0)
            {
               TweenAnimator.startItself(stateSprite,"state0");
               TweenAnimator.finishItself(stateSprite);
            }
            state = 0;
            if(_loc5_ > 0)
            {
               changeCupImage(_loc5_,true);
               imgKettle.visible = false;
               if(btnMini)
               {
                  TweenAnimator.startItself(imgBalloon4Mini,"show");
                  spFinish4Mini.visible = false;
                  btnMini.visible = true;
               }
            }
            else
            {
               currentCupImageId = -1;
               currentCupState = -1;
               imgKettle.visible = true;
               imgOpen.visible = false;
               imgClose.visible = false;
               if(btnMini)
               {
                  btnMini.visible = false;
               }
            }
         }
         displaySprite.visible = true;
         TweenAnimator.startItself(stateSprite,"show");
         advanceTime();
      }
      
      private function changeCupImage(param1:int, param2:Boolean) : void
      {
         var id:int = param1;
         var isOpen:Boolean = param2;
         var imgId:int = GameSetting.getCupGacha(id).rsrc;
         if(currentCupImageId == imgId && currentCupState > -1 && currentCupState == isOpen)
         {
            return;
         }
         currentCupImageId = imgId;
         if(isOpen)
         {
            currentCupState = 1;
            imgClose.visible = false;
            if(btnMini)
            {
               imgClose4Mini.visible = false;
            }
            TextureCollector.loadTexture("cupgude-" + imgId + "_open",function(param1:Texture):void
            {
               if(imgOpen == null)
               {
                  return;
               }
               imgOpen.texture = param1;
               imgOpen.width = param1.width;
               imgOpen.height = param1.height;
               imgOpen.visible = true;
            });
            TextureCollector.loadTexture("cupgude-" + imgId + "_open_s",function(param1:Texture):void
            {
               if(imgOpen4Mini == null)
               {
                  return;
               }
               imgOpen4Mini.texture = param1;
               imgOpen4Mini.width = param1.width;
               imgOpen4Mini.height = param1.height;
               imgOpen4Mini.visible = true;
            });
         }
         else
         {
            currentCupState = 0;
            imgOpen.visible = false;
            if(btnMini)
            {
               imgOpen4Mini.visible = false;
            }
            TextureCollector.loadTexture("cupgude-" + imgId + "_close",function(param1:Texture):void
            {
               if(imgClose == null)
               {
                  return;
               }
               imgClose.texture = param1;
               imgClose.width = param1.width;
               imgClose.height = param1.height;
               imgClose.visible = true;
            });
            TextureCollector.loadTexture("cupgude-" + imgId + "_close_s",function(param1:Texture):void
            {
               if(imgClose4Mini == null)
               {
                  return;
               }
               imgClose4Mini.texture = param1;
               imgClose4Mini.width = param1.width;
               imgClose4Mini.height = param1.height;
               imgClose4Mini.visible = true;
            });
         }
      }
      
      override public function setVisible(param1:Boolean) : void
      {
         super.setVisible(param1);
         btnMini.visible = param1;
      }
      
      public function setDisable() : void
      {
         setTouchable(false);
         displaySprite.visible = false;
      }
      
      public function advanceTime(param1:Number = 0) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         if(state == 1)
         {
            _loc4_ = Math.max(0,UserDataWrapper.wrapper.getRestSec4CupGacha());
            _loc5_ = 3600;
            _loc2_ = 60;
            _loc3_ = _loc4_ / _loc5_;
            _loc6_ = (_loc4_ - _loc3_ * _loc5_) / _loc2_;
            if((_loc7_ = _loc4_ - _loc3_ * _loc5_ - _loc6_ * _loc2_) != lastSecond || _loc6_ != lastMinute || _loc3_ != lastHour)
            {
               timeText.text#2 = GudetamaUtil.getRestTimeString(_loc3_,_loc6_,_loc7_);
               lastHour = _loc3_;
               lastMinute = _loc6_;
               lastSecond = _loc7_;
            }
            if(_loc4_ == 0)
            {
               setup(0);
            }
         }
      }
      
      public function triggered() : void
      {
         triggerdFunc();
      }
      
      public function triggeredMini() : void
      {
         scene.pushCupButtonMini(0,-1,triggerdFunc);
      }
      
      public function triggerdFunc() : void
      {
         if(UserDataWrapper.wrapper.getCupGachaIndexNoEmpty() >= 0)
         {
            CupGachaSlotDialog.show(scene,setup);
         }
         else
         {
            LocalMessageDialog.show(0,GameSetting.getUIText("cupgacha.warn.empty"));
         }
      }
      
      public function dispose() : void
      {
         button.removeEventListener("triggered",triggered);
         button = null;
         if(btnMini)
         {
            btnMini.removeEventListener("triggered",triggered);
            btnMini = null;
         }
         imgKettle = null;
         imgClose = null;
         imgOpen = null;
         stateSprite = null;
         timeText = null;
         imgBalloon4Mini = null;
         spFinish4Mini = null;
         imgOpen4Mini = null;
         imgClose4Mini = null;
      }
   }
}
