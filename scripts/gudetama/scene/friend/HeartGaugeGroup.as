package gudetama.scene.friend
{
   import gudetama.engine.Engine;
   import gudetama.ui.UIBase;
   import starling.display.Image;
   import starling.display.Sprite;
   
   public class HeartGaugeGroup extends UIBase
   {
      
      private static const ANIMATION_TIME:int = 1000;
       
      
      private var backgrounds:Vector.<Image>;
      
      private var hearts:Vector.<HeartGaugeUI>;
      
      private var length:int;
      
      private var to:int;
      
      private var from:int;
      
      private var current:int;
      
      private var time:int;
      
      private var lastTime:int;
      
      public function HeartGaugeGroup(param1:Sprite)
      {
         var _loc4_:int = 0;
         backgrounds = new Vector.<Image>();
         hearts = new Vector.<HeartGaugeUI>();
         super(param1);
         var _loc2_:Sprite = param1.getChildByName("backgrounds") as Sprite;
         _loc4_ = 0;
         while(_loc4_ < _loc2_.numChildren)
         {
            backgrounds.push(_loc2_.getChildByName("background" + _loc4_) as Image);
            _loc4_++;
         }
         var _loc3_:Sprite = param1.getChildByName("hearts") as Sprite;
         _loc4_ = 0;
         while(_loc4_ < _loc3_.numChildren)
         {
            hearts.push(new HeartGaugeUI(_loc3_.getChildByName("heart" + _loc4_) as Sprite));
            _loc4_++;
         }
      }
      
      public function setup(param1:Array) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         _loc3_ = 0;
         while(_loc3_ < hearts.length && _loc3_ < param1.length)
         {
            backgrounds[_loc3_].visible = true;
            hearts[_loc3_].setup(param1[_loc3_] - _loc2_);
            _loc2_ = param1[_loc3_];
            _loc3_++;
         }
         length = _loc3_;
         while(_loc3_ < hearts.length)
         {
            backgrounds[_loc3_].visible = false;
            hearts[_loc3_].setVisible(false);
            _loc3_++;
         }
      }
      
      public function set value(param1:int) : void
      {
         from = current = to;
         to = param1;
         time = 0;
         lastTime = Engine.now;
         update(0);
      }
      
      public function advanceTime() : void
      {
         if(time >= 1000)
         {
            return;
         }
         var _loc1_:int = Engine.now - lastTime;
         update(_loc1_);
         lastTime = Engine.now;
      }
      
      private function update(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:* = null;
         time += param1;
         current = from + (to - from) * Math.min(1000,time) / 1000;
         var _loc4_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < length)
         {
            _loc3_ = hearts[_loc2_];
            _loc3_.value = current - _loc4_;
            _loc4_ += _loc3_.maxValue;
            _loc2_++;
         }
      }
      
      public function skip() : void
      {
         update(1000);
      }
      
      public function dispose() : void
      {
         if(backgrounds)
         {
            backgrounds.length = 0;
            backgrounds = null;
         }
         if(hearts)
         {
            for each(var _loc1_ in hearts)
            {
               _loc1_.dispose();
            }
            hearts.length = 0;
            hearts = null;
         }
      }
   }
}

import gudetama.ui.UIBase;
import muku.display.GeneralGauge;
import starling.display.Sprite;

class HeartGaugeUI extends UIBase
{
   
   private static const TWEEN_NONE:int = 0;
   
   private static const TWEEN_ON:int = 1;
   
   private static const TWEEN_OFF:int = 2;
    
   
   public var gauge:GeneralGauge;
   
   public var maxValue:int;
   
   private var tweenState:int;
   
   function HeartGaugeUI(param1:Sprite)
   {
      super(param1);
      gauge = param1 as GeneralGauge;
   }
   
   public function setup(param1:int) : void
   {
      this.maxValue = param1;
      setVisible(true);
   }
   
   public function set value(param1:int) : void
   {
      var _loc2_:int = 0;
      gauge.percent = Math.max(0,Math.min(maxValue,param1)) / maxValue;
      if(param1 >= maxValue)
      {
         _loc2_ = 1;
      }
      else
      {
         _loc2_ = 2;
      }
      if(_loc2_ != tweenState)
      {
         if(_loc2_ == 1)
         {
            startTween("heart");
         }
         else if(_loc2_ == 2)
         {
            finishTween();
         }
         tweenState = _loc2_;
      }
   }
   
   public function dispose() : void
   {
      gauge = null;
   }
}
