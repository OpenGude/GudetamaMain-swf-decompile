package gudetama.scene.shop
{
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.GachaDef;
   import gudetama.data.compati.GachaPriceDef;
   import gudetama.data.compati.ItemParam;
   import gudetama.engine.TextureCollector;
   import gudetama.ui.UIBase;
   import gudetama.util.StringUtil;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class GachaPlayButtonUI extends UIBase
   {
       
      
      private var playGachaCallback:Function;
      
      private var playFreeGachaCallback:Function;
      
      private var playStampGachaCallback:Function;
      
      private var button:ContainerButton;
      
      private var labelText:ColorTextField;
      
      private var priceText:ColorTextField;
      
      private var ticketImage:Image;
      
      private var balloonSprite:Sprite;
      
      private var balloonText:ColorTextField;
      
      public var disabledBalloon:Boolean;
      
      private var id:int;
      
      private var index:int;
      
      private var playAll:Boolean;
      
      public function GachaPlayButtonUI(param1:Sprite, param2:Function, param3:Function = null, param4:Function = null)
      {
         super(param1);
         this.playGachaCallback = param2;
         if(param3)
         {
            this.playFreeGachaCallback = param3;
         }
         else
         {
            this.playFreeGachaCallback = param2;
         }
         if(param4)
         {
            this.playStampGachaCallback = param4;
         }
         else
         {
            this.playStampGachaCallback = param2;
         }
         button = param1.getChildByName("button") as ContainerButton;
         labelText = button.getChildByName("label") as ColorTextField;
         priceText = button.getChildByName("price") as ColorTextField;
         ticketImage = button.getChildByName("ticket") as Image;
         balloonSprite = param1.getChildByName("balloon") as Sprite;
         balloonText = balloonSprite.getChildByName("message") as ColorTextField;
      }
      
      public function get width() : Number
      {
         return button.width;
      }
      
      public function setup(param1:GachaDef, param2:int, param3:Boolean = false) : void
      {
         var _loc4_:ItemParam;
         if((_loc4_ = GachaScene_Gudetama.getLastPrice(param1,param2)).kind == 0 || _loc4_.kind == 14)
         {
            setupMoney(param1,param2,param3);
         }
         else
         {
            setupMetal(param1,param2,param3);
         }
         button.removeEventListeners("triggered");
         button.addEventListener("triggered",triggeredPlayButton);
         id = param1.id#2;
         index = param2;
         playAll = false;
      }
      
      private function setupMetal(param1:GachaDef, param2:int, param3:Boolean = false) : void
      {
         var gachaDef:GachaDef = param1;
         var priceIndex:int = param2;
         var confirmDialog:Boolean = param3;
         var gachaPriceDef:GachaPriceDef = gachaDef.prices[priceIndex];
         var price:ItemParam = GachaScene_Gudetama.getPrice(gachaDef,priceIndex);
         startTween("metal");
         finishTween();
         if(price.kind == 1 || price.kind == 2)
         {
            priceText.text#2 = StringUtil.getNumStringCommas(price.num);
            priceText.format.horizontalAlign = "right";
            startTween(gachaPriceDef.num == 1 ? "single" : "multi");
            finishTween();
            startTween("metal_multi");
            finishTween();
         }
         else
         {
            startTween("single");
            startTween("ticket");
            finishTween();
            TextureCollector.loadTexture("gacha1@ticket" + price.id#2,function(param1:Texture):void
            {
               if(ticketImage != null)
               {
                  ticketImage.texture = param1;
               }
            });
            if(confirmDialog)
            {
               priceText.text#2 = StringUtil.format(GameSetting.getUIText("gacha.playButton.ticket.collect"),1);
            }
            else
            {
               priceText.text#2 = GameSetting.getUIText("%gacha.playButton.ticket");
            }
            priceText.format.horizontalAlign = "center";
            balloonText.text#2 = StringUtil.format(GameSetting.getUIText("gacha.playButton.ticket"),UserDataWrapper.wrapper.getNumItem(price.kind,price.id#2));
         }
         var restCountAtDaily:int = UserDataWrapper.gachaPart.getRestCountAtDaily(gachaDef.id#2,priceIndex);
         if(gachaPriceDef.numDaily > 0 && (price.kind == 1 || price.kind == 2))
         {
            balloonText.text#2 = StringUtil.format(GameSetting.getUIText("gacha.playButton.daily"),restCountAtDaily);
            startTween("limit");
            finishTween();
         }
         if(disabledBalloon)
         {
            balloonSprite.visible = false;
         }
         if(gachaPriceDef.numDaily > 0 && restCountAtDaily == 0 && GachaScene_Gudetama.isLastPrice(gachaDef,priceIndex))
         {
            button.setEnableWithDrawCache(false);
         }
         else
         {
            button.setEnableWithDrawCache(true);
         }
      }
      
      private function setupMoney(param1:GachaDef, param2:int, param3:Boolean = false) : void
      {
         var gachaDef:GachaDef = param1;
         var priceIndex:int = param2;
         var confirmDialog:Boolean = param3;
         var gachaPriceDef:GachaPriceDef = gachaDef.prices[priceIndex];
         var price:ItemParam = GachaScene_Gudetama.getPrice(gachaDef,priceIndex);
         startTween("money");
         finishTween();
         if(price.kind == 0 || price.kind == 14)
         {
            priceText.text#2 = StringUtil.getNumStringCommas(price.num);
            priceText.format.horizontalAlign = "right";
            if(gachaPriceDef.num == 1)
            {
               startTween("single");
            }
            else
            {
               startTween("multi");
               labelText.text#2 = StringUtil.format(GameSetting.getUIText("gacha.playButton.money.multi.label"),gachaPriceDef.num);
            }
            finishTween();
         }
         else
         {
            startTween("single");
            finishTween();
            startTween("ticket");
            finishTween();
            TextureCollector.loadTexture("gacha1@ticket" + price.id#2,function(param1:Texture):void
            {
               if(ticketImage != null)
               {
                  ticketImage.texture = param1;
               }
            });
            if(confirmDialog)
            {
               priceText.text#2 = StringUtil.format(GameSetting.getUIText("gacha.playButton.ticket.collect"),1);
            }
            else
            {
               priceText.text#2 = GameSetting.getUIText("%gacha.playButton.ticket");
            }
            priceText.format.horizontalAlign = "center";
            balloonText.text#2 = StringUtil.format(GameSetting.getUIText("gacha.playButton.ticket"),UserDataWrapper.wrapper.getNumItem(price.kind,price.id#2));
         }
         var restCountAtDaily:int = UserDataWrapper.gachaPart.getRestCountAtDaily(gachaDef.id#2,priceIndex);
         if(gachaPriceDef.numDaily > 0 && (price.kind == 0 || price.kind == 14))
         {
            balloonText.text#2 = StringUtil.format(GameSetting.getUIText("gacha.playButton.daily"),restCountAtDaily);
            startTween("limit");
            finishTween();
         }
         if(disabledBalloon)
         {
            balloonSprite.visible = false;
         }
         if(gachaPriceDef.numDaily > 0 && restCountAtDaily == 0 && GachaScene_Gudetama.isLastPrice(gachaDef,priceIndex))
         {
            balloonSprite.visible = false;
            button.setEnableWithDrawCache(false);
         }
         else
         {
            button.setEnableWithDrawCache(true);
         }
      }
      
      public function setupMoneyAll(param1:GachaDef, param2:int) : void
      {
         var _loc3_:GachaPriceDef = param1.prices[param2];
         var _loc5_:ItemParam = GachaScene_Gudetama.getPrice(param1,param2);
         var _loc4_:int = UserDataWrapper.wrapper.getMoney();
         var _loc7_:int = UserDataWrapper.gachaPart.getRestCountAtDaily(param1.id#2,param2);
         var _loc6_:int = Math.min(_loc7_,_loc4_ / _loc5_.num);
         priceText.text#2 = StringUtil.getNumStringCommas(_loc5_.num * _loc6_);
         priceText.format.horizontalAlign = "right";
         labelText.text#2 = StringUtil.format(GameSetting.getUIText("gacha.playButton.money.multi.label"),_loc6_);
         startTween("money");
         finishTween();
         startTween("multi");
         finishTween();
         if(_loc3_.numDaily > 0 && (_loc5_.kind == 0 || _loc5_.kind == 14))
         {
            balloonText.text#2 = StringUtil.format(GameSetting.getUIText("gacha.playButton.daily"),_loc7_);
            startTween("limit");
            finishTween();
         }
         if(disabledBalloon)
         {
            balloonSprite.visible = false;
         }
         button.setEnableWithDrawCache(_loc6_ > 0);
         button.removeEventListeners("triggered");
         button.addEventListener("triggered",triggeredPlayButton);
         id = param1.id#2;
         index = param2;
         playAll = true;
      }
      
      public function setupMetalTicketAll(param1:GachaDef, param2:int) : void
      {
         var gachaDef:GachaDef = param1;
         var priceIndex:int = param2;
         var gachaPriceDef:GachaPriceDef = gachaDef.prices[priceIndex];
         var price:ItemParam = GachaScene_Gudetama.getPrice(gachaDef,priceIndex);
         var num:int = Math.min(10,UserDataWrapper.wrapper.getNumItem(price.kind,price.id#2));
         TextureCollector.loadTexture("gacha1@ticket" + price.id#2,function(param1:Texture):void
         {
            if(ticketImage != null)
            {
               ticketImage.texture = param1;
            }
         });
         priceText.text#2 = StringUtil.format(GameSetting.getUIText("gacha.playButton.ticket.collect"),num);
         priceText.format.horizontalAlign = "center";
         labelText.text#2 = StringUtil.format(GameSetting.getUIText("gacha.playButton.money.multi.label"),num);
         startTween("metal");
         finishTween();
         startTween("multi");
         finishTween();
         startTween("ticket");
         finishTween();
         balloonSprite.visible = false;
         button.setEnableWithDrawCache(num > 0);
         button.removeEventListeners("triggered");
         button.addEventListener("triggered",triggeredPlayButton);
         id = gachaDef.id#2;
         index = priceIndex;
         playAll = true;
      }
      
      public function setupMoneyTicketAll(param1:GachaDef, param2:int) : void
      {
         var gachaDef:GachaDef = param1;
         var priceIndex:int = param2;
         var gachaPriceDef:GachaPriceDef = gachaDef.prices[priceIndex];
         var price:ItemParam = GachaScene_Gudetama.getPrice(gachaDef,priceIndex);
         var num:int = Math.min(10,UserDataWrapper.wrapper.getNumItem(price.kind,price.id#2));
         TextureCollector.loadTexture("gacha1@ticket" + price.id#2,function(param1:Texture):void
         {
            if(ticketImage != null)
            {
               ticketImage.texture = param1;
            }
         });
         priceText.text#2 = StringUtil.format(GameSetting.getUIText("gacha.playButton.ticket.collect"),num);
         priceText.format.horizontalAlign = "center";
         labelText.text#2 = StringUtil.format(GameSetting.getUIText("gacha.playButton.money.multi.label"),num);
         startTween("money");
         finishTween();
         startTween("multi");
         finishTween();
         startTween("ticket");
         finishTween();
         balloonSprite.visible = false;
         button.setEnableWithDrawCache(num > 0);
         button.removeEventListeners("triggered");
         button.addEventListener("triggered",triggeredPlayButton);
         id = gachaDef.id#2;
         index = priceIndex;
         playAll = true;
      }
      
      public function setupFree(param1:GachaDef) : void
      {
         startTween("free");
         finishTween();
         balloonText.text#2 = StringUtil.format(GameSetting.getUIText("gacha.playButton.free"),UserDataWrapper.gachaPart.getRestCountAtFree(param1.id#2));
         if(disabledBalloon)
         {
            balloonSprite.visible = false;
         }
         button.setEnableWithDrawCache(true);
         button.removeEventListeners("triggered");
         button.addEventListener("triggered",triggeredFreePlayButton);
         id = param1.id#2;
         playAll = false;
      }
      
      public function setupStamp(param1:GachaDef, param2:int, param3:Boolean = false) : void
      {
         var gachaDef:GachaDef = param1;
         var priceIndex:int = param2;
         var confirmDialog:Boolean = param3;
         var gachaPriceDef:GachaPriceDef = gachaDef.prices[priceIndex];
         var price:ItemParam = GachaScene_Gudetama.getPrice(gachaDef,priceIndex);
         startTween("AR");
         finishTween();
         priceText.format.horizontalAlign = "center";
         if(price.kind == 11)
         {
            priceText.text#2 = GameSetting.getUIText("gacha.playButton.label.stamp");
            balloonText.text#2 = StringUtil.format(GameSetting.getUIText("gacha.playButton.balloon.stamp"),price.num);
         }
         else
         {
            startTween("ticket");
            finishTween();
            TextureCollector.loadTexture("gacha1@ticket" + price.id#2,function(param1:Texture):void
            {
               if(ticketImage != null)
               {
                  ticketImage.texture = param1;
               }
            });
            if(confirmDialog)
            {
               priceText.text#2 = StringUtil.format(GameSetting.getUIText("gacha.playButton.ticket.collect"),1);
            }
            else
            {
               priceText.text#2 = GameSetting.getUIText("%gacha.playButton.ticket");
            }
            balloonText.text#2 = StringUtil.format(GameSetting.getUIText("gacha.playButton.ticket"),UserDataWrapper.wrapper.getNumItem(price.kind,price.id#2));
         }
         var restCountAtDaily:int = UserDataWrapper.gachaPart.getRestCountAtDaily(gachaDef.id#2,priceIndex);
         if(gachaPriceDef.numDaily > 0 && (price.kind == 0 || price.kind == 14))
         {
            balloonText.text#2 = StringUtil.format(GameSetting.getUIText("gacha.playButton.daily"),restCountAtDaily);
            startTween("limit");
            finishTween();
         }
         if(disabledBalloon)
         {
            balloonSprite.visible = false;
         }
         if(gachaPriceDef.numDaily > 0 && restCountAtDaily == 0 && GachaScene_Gudetama.isLastPrice(gachaDef,priceIndex))
         {
            balloonSprite.visible = false;
            button.setEnableWithDrawCache(false);
         }
         else
         {
            button.setEnableWithDrawCache(true);
         }
         button.removeEventListeners("triggered");
         button.addEventListener("triggered",triggeredStampPlayButton);
         id = gachaDef.id#2;
         index = priceIndex;
         playAll = false;
      }
      
      public function setupSelectStamp(param1:GachaDef, param2:int) : void
      {
         var _loc3_:GachaPriceDef = param1.prices[param2];
         var _loc4_:ItemParam = GachaScene_Gudetama.getPrice(param1,param2);
         startTween("AR");
         finishTween();
         startTween("ARSelect");
         finishTween();
         priceText.format.horizontalAlign = "center";
         priceText.text#2 = GameSetting.getUIText("gacha.playButton.label.stamp");
         balloonText.text#2 = StringUtil.format(GameSetting.getUIText("gacha.playButton.balloon.stamp"),_loc4_.num);
         labelText.text#2 = StringUtil.format(GameSetting.getUIText("gacha.playButton.money.multi.label"),1);
         if(disabledBalloon)
         {
            balloonSprite.visible = false;
         }
         button.setEnableWithDrawCache(false);
         button.removeEventListeners("triggered");
         button.addEventListener("triggered",triggeredPlayButton);
      }
      
      public function updateSelectStamp(param1:int) : void
      {
         var _loc2_:int = Math.max(1,param1);
         if(_loc2_ > 1)
         {
            labelText.text#2 = StringUtil.format(GameSetting.getUIText("gacha.playButton.money.multi.label"),_loc2_);
         }
         else
         {
            labelText.text#2 = GameSetting.getUIText("gachaSelectStamp.pon");
         }
         button.setEnableWithDrawCache(param1 > 0);
      }
      
      private function triggeredPlayButton(param1:Event) : void
      {
         playGachaCallback(id,index,playAll);
      }
      
      private function triggeredFreePlayButton(param1:Event) : void
      {
         playFreeGachaCallback(id);
      }
      
      private function triggeredStampPlayButton(param1:Event) : void
      {
         playStampGachaCallback(id,index);
      }
      
      public function existsBalloon() : Boolean
      {
         return isVisible() && balloonSprite.visible;
      }
      
      public function dispose() : void
      {
         playGachaCallback = null;
         playFreeGachaCallback = null;
         playStampGachaCallback = null;
         if(button)
         {
            button.removeEventListeners("triggered");
            button = null;
         }
         labelText = null;
         priceText = null;
         balloonSprite = null;
         balloonText = null;
      }
   }
}
