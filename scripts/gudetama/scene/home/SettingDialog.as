package gudetama.scene.home
{
   import feathers.controls.Slider;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.SoundManager;
   import gudetama.engine.TweenAnimator;
   import muku.display.ContainerButton;
   import starling.display.Sprite;
   
   public class SettingDialog extends BaseScene
   {
      
      private static const PARAM_EFFECT:String = "EFFECT";
      
      private static const PARAM_VOICE:String = "VOICE";
       
      
      private var sliders:Vector.<SoundConfigSlider>;
      
      private var closeButton:ContainerButton;
      
      private var soundParamMap:Object;
      
      public function SettingDialog()
      {
         sliders = new Vector.<SoundConfigSlider>();
         soundParamMap = {};
         super(2);
      }
      
      public static function show() : void
      {
         Engine.pushScene(new SettingDialog(),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"SettingDialog",function(param1:Object):void
         {
            var _loc4_:int = 0;
            var _loc2_:* = null;
            displaySprite = param1.object;
            var _loc3_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            _loc4_ = 0;
            while(_loc4_ < 3)
            {
               _loc2_ = new SoundConfigSlider(_loc3_.getChildByName("slider" + _loc4_) as Slider,_loc4_);
               _loc2_.setup();
               sliders.push(_loc2_);
               _loc4_++;
            }
            closeButton = _loc3_.getChildByName("btn_back") as ContainerButton;
            closeButton.addEventListener("triggered",backButtonCallback);
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         queue.registerOnProgress(function(param1:Number):void
         {
         });
         queue.startTask(onProgress);
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(SettingDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(SettingDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(SettingDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(SettingDialog);
            Engine.popScene(scene);
         });
      }
      
      override public function dispose() : void
      {
         for each(var _loc1_ in sliders)
         {
            _loc1_.dispose();
         }
         sliders.length = 0;
         sliders = null;
         SoundManager.stopEffect(soundParamMap["EFFECT"]);
         SoundManager.stopVoice(soundParamMap["VOICE"]);
         delete soundParamMap["EFFECT"];
         delete soundParamMap["VOICE"];
         super.dispose();
      }
   }
}

import feathers.controls.Slider;
import gudetama.data.DataStorage;
import gudetama.data.LocalData;
import gudetama.engine.SoundManager;
import starling.events.Event;

class SoundConfigSlider
{
   
   public static const TYPE_MUSIC:int = 0;
   
   public static const TYPE_EFFECT:int = 1;
   
   public static const TYPE_VOICE:int = 2;
    
   
   private var slider:Slider;
   
   private var type:int;
   
   function SoundConfigSlider(param1:Slider, param2:int)
   {
      super();
      this.slider = param1;
      this.type = param2;
   }
   
   public function setup() : void
   {
      switch(int(type))
      {
         case 0:
            var _loc1_:* = SoundManager;
            slider.value = gudetama.engine.SoundManager.volumeOfMusic;
            break;
         case 1:
            var _loc2_:* = SoundManager;
            slider.value = gudetama.engine.SoundManager.volumeOfEffect;
            break;
         case 2:
            var _loc3_:* = SoundManager;
            slider.value = gudetama.engine.SoundManager.volumeOfVoice;
      }
      slider.addEventListener("change",onChange);
   }
   
   private function onChange(param1:Event) : void
   {
      var _loc2_:Number = (param1.target as Slider).value;
      setVolume(_loc2_);
   }
   
   public function changeStepVolume(param1:Boolean) : void
   {
      if(param1 && slider.value <= 0)
      {
         return;
      }
      if(!param1 && slider.value >= 1)
      {
         return;
      }
      slider.value += slider.step * (!!param1 ? -1 : 1);
      setVolume(slider.value);
   }
   
   private function setVolume(param1:Number) : void
   {
      var _loc2_:LocalData = DataStorage.getLocalData();
      switch(int(type))
      {
         case 0:
            var _loc5_:* = param1;
            var _loc3_:* = SoundManager;
            gudetama.engine.SoundManager.volumeOfMusic = Math.min(_loc5_,1);
            gudetama.engine.SoundManager.transformMusicVolume();
            _loc2_.musicVolume = param1;
            break;
         case 1:
            var _loc6_:* = param1;
            var _loc4_:* = SoundManager;
            gudetama.engine.SoundManager.volumeOfEffect = Math.min(_loc6_,1);
            _loc2_.effectVolume = param1;
            break;
         case 2:
            SoundManager.voiceVolume = param1;
            _loc2_.voiceVolume = param1;
      }
      DataStorage.saveLocalData();
   }
   
   public function dispose() : void
   {
      slider.removeEventListener("change",onChange);
      slider = null;
   }
}
