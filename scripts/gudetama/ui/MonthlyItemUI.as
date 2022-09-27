package gudetama.ui
{
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.ItemParam;
   import gudetama.data.compati.MonthlyPremiumBonusDef;
   import gudetama.engine.TextureCollector;
   import gudetama.util.StringUtil;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class MonthlyItemUI extends UIBase
   {
       
      
      private var callback:Function;
      
      private var bannerImage:Image;
      
      private var buyBtn:ContainerButton;
      
      private var detailBtn:ContainerButton;
      
      private var maxText:ColorTextField;
      
      private var priceText:ColorTextField;
      
      private var labelText:ColorTextField;
      
      private var monthlyPremiumBonus:MonthlyPremiumBonusDef;
      
      public function MonthlyItemUI(param1:Sprite, param2:Function)
      {
         super(param1);
         this.callback = param2;
         bannerImage = param1.getChildByName("banner") as Image;
         buyBtn = param1.getChildByName("buyBtn") as ContainerButton;
         buyBtn.addEventListener("triggered",triggeredBuyBtn);
         detailBtn = param1.getChildByName("detailBtn") as ContainerButton;
         detailBtn.addEventListener("triggered",triggeredDetailBtn);
         maxText = param1.getChildByName("max") as ColorTextField;
         priceText = param1.getChildByName("price") as ColorTextField;
         var _loc3_:Sprite = param1.getChildByName("bonusSprite") as Sprite;
         labelText = _loc3_.getChildByName("label") as ColorTextField;
         if(!UserDataWrapper.wrapper.isPurchasableMonthlyPremiumBonus())
         {
            buyBtn.enableDrawCache(true,false,true);
            buyBtn.touchable = false;
         }
      }
      
      private function triggeredBuyBtn(param1:Event) : void
      {
         if(UserDataWrapper.wrapper.isPurchasableMonthlyPremiumBonus())
         {
            callback(monthlyPremiumBonus);
         }
         else
         {
            LocalMessageDialog.show(0,StringUtil.format(GameSetting.getUIText("%shop.metal.monthly.yetNotBuyable.msg"),UserDataWrapper.wrapper.getRemainingMonthlyPremiumBonusDate()),null,StringUtil.format(GameSetting.getUIText("%shop.metal.monthly.yetNotBuyable.title"),monthlyPremiumBonus.validDays));
         }
      }
      
      private function triggeredDetailBtn(param1:Event) : void
      {
         if(!monthlyPremiumBonus)
         {
            return;
         }
         MonthlyPremiumBonusDetailDialog.show(monthlyPremiumBonus);
      }
      
      public function updateData(param1:Object) : void
      {
         var data:Object = param1;
         if(!data)
         {
            return;
         }
         monthlyPremiumBonus = data.monthlyPremiumBonus as MonthlyPremiumBonusDef;
         TextureCollector.loadTexture("shop0@banner" + monthlyPremiumBonus.item.rsrc,function(param1:Texture):void
         {
            if(bannerImage != null)
            {
               bannerImage.texture = param1;
            }
         });
         var max:int = monthlyPremiumBonus.item.value;
         var numBonus:int = 0;
         var i:int = 0;
         while(i < monthlyPremiumBonus.bonusItems.length)
         {
            var bonusItem:ItemParam = monthlyPremiumBonus.bonusItems[i];
            if(bonusItem.kind == 1 || bonusItem.kind == 2)
            {
               var numBonus:int = numBonus + bonusItem.num * monthlyPremiumBonus.validDays;
               var max:int = max + numBonus;
            }
            i++;
         }
         maxText.text#2 = StringUtil.format(GameSetting.getUIText("%shop.metal.monthly.max"),max);
         if(data.mark)
         {
            priceText.text#2 = StringUtil.format(data.mark,StringUtil.getNumStringCommas(data.price));
         }
         else
         {
            var isOneStore:Boolean = false;
            priceText.text#2 = StringUtil.format(GameSetting.getUIText(!!isOneStore ? "realmoney.mark.kr" : "realmoney.mark"),StringUtil.getNumStringCommas(data.price));
         }
         if(UserDataWrapper.wrapper.isPurchasableMonthlyPremiumBonus())
         {
            labelText.text#2 = StringUtil.format(GameSetting.getUIText("%shop.metal.monthly.balloon.info"),numBonus);
            buyBtn.enableDrawCache(true,false,false);
            buyBtn.touchable = true;
         }
         else
         {
            labelText.text#2 = StringUtil.format(GameSetting.getUIText("%shop.metal.monthly.balloon.yetNotBuyable"),UserDataWrapper.wrapper.getRemainingMonthlyPremiumBonusDate());
            if(buyBtn.touchable)
            {
               buyBtn.enableDrawCache(true,false,true);
               buyBtn.touchable = false;
            }
            else
            {
               buyBtn.enabled = false;
               buyBtn.touchable = false;
            }
         }
      }
      
      public function dispose() : void
      {
         if(buyBtn)
         {
            buyBtn.removeEventListener("triggered",triggeredBuyBtn);
            buyBtn = null;
         }
         if(detailBtn)
         {
            detailBtn.removeEventListener("triggered",triggeredDetailBtn);
            detailBtn = null;
         }
      }
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.compati.MonthlyPremiumBonusDef;
import gudetama.engine.BaseScene;
import gudetama.engine.Engine;
import gudetama.engine.TweenAnimator;
import gudetama.util.StringUtil;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.DisplayObject;
import starling.display.Sprite;
import starling.events.Event;

class MonthlyPremiumBonusDetailDialog extends BaseScene
{
    
   
   private var def:MonthlyPremiumBonusDef;
   
   private var titleText:ColorTextField;
   
   private var messageText:ColorTextField;
   
   private var infoText:ColorTextField;
   
   private var closeBtn:ContainerButton;
   
   function MonthlyPremiumBonusDetailDialog(param1:MonthlyPremiumBonusDef)
   {
      super(1);
      this.def = param1;
   }
   
   public static function show(param1:MonthlyPremiumBonusDef) : void
   {
      Engine.pushScene(new MonthlyPremiumBonusDetailDialog(param1));
   }
   
   override protected function setupProgress(param1:Function) : void
   {
      var onProgress:Function = param1;
      Engine.setupLayoutForTask(queue,"MonthlyPremiumBonusDetailDialogLayout",function(param1:Object):void
      {
         displaySprite = param1.object;
         var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
         titleText = _loc2_.getChildByName("title") as ColorTextField;
         titleText.text#2 = StringUtil.format(GameSetting.getUIText("%shop.metal.monthly.detail.title"),def.validDays);
         messageText = _loc2_.getChildByName("message") as ColorTextField;
         messageText.text#2 = StringUtil.format(GameSetting.getUIText("%shop.metal.monthly.detail.msg"),def.validDays,def.item.value,def.validDays,GudetamaUtil.getItemParamName(def.bonusItems[0]),GudetamaUtil.getItemParamNum(def.bonusItems[0]));
         infoText = _loc2_.getChildByName("info") as ColorTextField;
         infoText.text#2 = StringUtil.format(GameSetting.getUIText("%shop.metal.monthly.detail.info"),def.validDays);
         closeBtn = _loc2_.getChildByName("closeBtn") as ContainerButton;
         closeBtn.addEventListener("triggered",triggeredCloseBtn);
         displaySprite.visible = false;
         addChild(displaySprite);
      });
      queue.startTask(onProgress);
   }
   
   override protected function addedToContainer() : void
   {
      setBackButtonCallback(backButtonCallback);
      displaySprite.visible = true;
      TweenAnimator.startItself(displaySprite,"show");
   }
   
   override public function backButtonCallback() : void
   {
      triggeredCloseBtn(null);
   }
   
   private function triggeredCloseBtn(param1:Event) : void
   {
      var event:Event = param1;
      TweenAnimator.startItself(displaySprite,"hide",false,function(param1:DisplayObject):void
      {
         Engine.popScene(scene);
      });
   }
   
   override public function dispose() : void
   {
      titleText = null;
      messageText = null;
      infoText = null;
      if(closeBtn)
      {
         closeBtn.removeEventListener("triggered",triggeredCloseBtn);
         closeBtn = null;
      }
      super.dispose();
   }
}
