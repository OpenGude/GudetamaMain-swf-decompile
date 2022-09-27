package gudetama.ui
{
   import gudetama.util.SpriteExtractor;
   import starling.display.Sprite;
   
   public class AmountCacheManager
   {
      
      private static const SCREENING_MAX:int = 10;
       
      
      private var extractor:SpriteExtractor;
      
      private var group:Sprite;
      
      private var pool:Vector.<AmountUI>;
      
      private var screening:Vector.<AmountUI>;
      
      public function AmountCacheManager(param1:SpriteExtractor, param2:Sprite)
      {
         pool = new Vector.<AmountUI>();
         screening = new Vector.<AmountUI>();
         super();
         this.extractor = param1;
         this.group = param2;
      }
      
      public function show(param1:int, param2:String) : void
      {
         var _loc3_:* = null;
         if(screening && screening.length >= 10)
         {
            _loc3_ = screening.shift();
            _loc3_.cancel();
         }
         else if(!pool || pool.length == 0)
         {
            _loc3_ = new AmountUI(extractor.duplicateAll() as Sprite,hideAmountUI);
            group.addChild(_loc3_.getDisplaySprite());
         }
         else
         {
            _loc3_ = pool.pop();
            group.addChild(_loc3_.getDisplaySprite());
         }
         _loc3_.show(param1,param2);
         screening.push(_loc3_);
      }
      
      private function hideAmountUI(param1:AmountUI) : void
      {
         if(!pool)
         {
            return;
         }
         group.removeChild(param1.getDisplaySprite());
         pool.push(param1);
         screening.removeAt(screening.indexOf(param1));
      }
      
      public function dispose() : void
      {
         extractor = null;
         group = null;
         for each(var _loc1_ in pool)
         {
            _loc1_.dispose();
            _loc1_.getDisplaySprite().dispose();
         }
         pool.length = 0;
         pool = null;
      }
   }
}

import gudetama.data.GameSetting;
import gudetama.engine.TweenAnimator;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import muku.text.ColorTextField;
import starling.display.Sprite;

class AmountUI extends UIBase
{
    
   
   private var callback:Function;
   
   private var text:ColorTextField;
   
   private var canceled:Boolean;
   
   function AmountUI(param1:Sprite, param2:Function)
   {
      super(param1);
      this.callback = param2;
      text = param1.getChildByName("text") as ColorTextField;
   }
   
   public function show(param1:int, param2:String) : void
   {
      var amount:int = param1;
      var animation:String = param2;
      setVisible(true);
      if(amount >= 0)
      {
         text.text#2 = StringUtil.format(GameSetting.getUIText("add.mark"),StringUtil.getNumStringCommas(amount));
      }
      else
      {
         text.text#2 = StringUtil.format(GameSetting.getUIText("sub.mark"),StringUtil.getNumStringCommas(Math.abs(amount)));
      }
      var thisObj:AmountUI = this;
      TweenAnimator.startItself(displaySprite,animation,false,function():void
      {
         setVisible(false);
         if(!canceled)
         {
            callback(thisObj);
         }
      });
   }
   
   public function cancel() : void
   {
      canceled = true;
      TweenAnimator.finishItself(displaySprite);
   }
   
   public function dispose() : void
   {
      callback = null;
      text = null;
   }
}
