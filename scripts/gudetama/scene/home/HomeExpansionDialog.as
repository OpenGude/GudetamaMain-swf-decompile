package gudetama.scene.home
{
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.HomeExpansionGoodsDef;
   import gudetama.data.compati.ItemParam;
   import gudetama.data.compati.Packet;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.display.SimpleImageButton;
   import muku.text.ColorTextField;
   import starling.display.DisplayObject;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class HomeExpansionDialog extends BaseScene
   {
       
      
      private var titleText:ColorTextField;
      
      private var messageText:ColorTextField;
      
      private var beforeIcon:Image;
      
      private var beforeNum:ColorTextField;
      
      private var afterIcon:Image;
      
      private var afterNum:ColorTextField;
      
      private var requiredIcon:Image;
      
      private var requiredNum:ColorTextField;
      
      private var exchangeBtn:ContainerButton;
      
      private var closeBtn:ContainerButton;
      
      private var purchaseBtn:SimpleImageButton;
      
      private var notEnoughImage:Image;
      
      private var expansionDef:HomeExpansionGoodsDef;
      
      private var enoughConsumeItem:Boolean;
      
      private var callback:Function;
      
      public function HomeExpansionDialog(param1:Function)
      {
         super(1);
         this.callback = param1;
      }
      
      public static function show(param1:Function) : void
      {
         Engine.pushScene(new HomeExpansionDialog(param1));
      }
      
      override public function dispose() : void
      {
         callback = null;
         super.dispose();
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         var preQueue:TaskQueue = new TaskQueue();
         Engine.setupLayoutForTask(preQueue,"ARPlaceExpansionDialogLayout",function(param1:Object):void
         {
            displaySprite = param1.object as Sprite;
            var _loc5_:Sprite;
            titleText = (_loc5_ = displaySprite.getChildByName("dialogSprite") as Sprite).getChildByName("title") as ColorTextField;
            messageText = _loc5_.getChildByName("message") as ColorTextField;
            var _loc3_:Sprite = _loc5_.getChildByName("modified") as Sprite;
            var _loc6_:Sprite = _loc3_.getChildByName("before") as Sprite;
            var _loc7_:Sprite = _loc3_.getChildByName("after") as Sprite;
            beforeIcon = _loc6_.getChildByName("icon") as Image;
            beforeNum = _loc6_.getChildByName("num") as ColorTextField;
            afterIcon = _loc7_.getChildByName("icon") as Image;
            afterNum = _loc7_.getChildByName("num") as ColorTextField;
            var _loc2_:Sprite = _loc5_.getChildByName("requiredContainer") as Sprite;
            var _loc4_:Sprite;
            requiredIcon = (_loc4_ = _loc2_.getChildByName("required") as Sprite).getChildByName("icon") as Image;
            requiredNum = _loc4_.getChildByName("num") as ColorTextField;
            notEnoughImage = _loc2_.getChildByName("notEnoughImage") as Image;
            notEnoughImage.visible = false;
            exchangeBtn = _loc2_.getChildByName("exchangeBtn") as ContainerButton;
            exchangeBtn.addEventListener("triggered",triggeredExchange);
            purchaseBtn = _loc5_.getChildByName("purchaseBtn") as SimpleImageButton;
            purchaseBtn.addEventListener("triggered",triggeredPurchase);
            purchaseBtn.visible = false;
            closeBtn = _loc5_.getChildByName("closeBtn") as ContainerButton;
            closeBtn.addEventListener("triggered",triggeredClose);
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         preQueue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            setup(onProgress);
         });
         preQueue.startTask();
      }
      
      private function setup(param1:Function) : void
      {
         var onProgress:Function = param1;
         var count:int = 0;
         var _loc3_:* = UserDataWrapper;
         count = gudetama.data.UserDataWrapper.wrapper._data.placeHomeStampExpansionCount;
         var iconName:String = "ar0@stamp";
         titleText.text#2 = GameSetting.getUIText("ar.stamp.expansion.title");
         messageText.text#2 = GameSetting.getUIText("ar.stamp.expansion.msg");
         beforeNum.text#2 = GameSetting.getRule().placeHomeStampNumTable[count];
         afterNum.text#2 = GameSetting.getRule().placeHomeStampNumTable[count + 1];
         TextureCollector.loadTextureForTask(queue,iconName,function(param1:Texture):void
         {
            beforeIcon.texture = param1;
            afterIcon.texture = param1;
            beforeIcon.readjustSize();
            afterIcon.readjustSize();
         });
         expansionDef = GameSetting.getHomeExpansionGoodsAtCount(count);
         var price:ItemParam = expansionDef.price;
         if(price.kind == 2 || price.kind == 1)
         {
            var priceIconName:String = "ar0@gold_s";
         }
         else if(price.kind == 0 || price.kind == 14)
         {
            priceIconName = "ar0@gp";
         }
         TextureCollector.loadTextureForTask(queue,priceIconName,function(param1:Texture):void
         {
            requiredIcon.texture = param1;
         });
         requiredNum.text#2 = !!price.hasNumber() ? StringUtil.getNumStringCommas(price.num) : price.id#2.toString();
         enoughConsumeItem = UserDataWrapper.wrapper.hasItem(expansionDef.price);
         if(!enoughConsumeItem)
         {
            purchaseBtn.visible = true;
            notEnoughImage.visible = true;
            exchangeBtn.touchable = false;
         }
         queue.startTask(onProgress);
      }
      
      override protected function addedToContainer() : void
      {
         setBackButtonCallback(backButtonCallback);
         setVisibleState(0);
         var twname:String = !!enoughConsumeItem ? "enough" : "notEnough";
         TweenAnimator.startItself(displaySprite,twname,false,function(param1:DisplayObject):void
         {
            displaySprite.visible = true;
            TweenAnimator.startItself(displaySprite,"show");
         });
         setBackButtonCallback(function():void
         {
            close(false);
         });
      }
      
      private function triggeredExchange(param1:Event) : void
      {
         var event:Event = param1;
         exchangeBtn.removeEventListener("triggered",triggeredExchange);
         var packet:Packet = PacketUtil.createWithInt(HOME_DECORATION_EXTENSION_PLACE,[expansionDef.id#2]);
         var _loc3_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(packet,function(param1:Object):void
         {
            var _loc2_:int = (param1 as Array)[0] as int;
            if(_loc2_ <= 0)
            {
               return;
            }
            var _loc3_:* = UserDataWrapper;
            gudetama.data.UserDataWrapper.wrapper._data.placeHomeStampExpansionCount = _loc2_;
            if(expansionDef.price.kind == 1 || expansionDef.price.kind == 2)
            {
               ResidentMenuUI_Gudetama.consumeMetal(expansionDef.price.num);
            }
            else if(expansionDef.price.kind == 0)
            {
               ResidentMenuUI_Gudetama.consumeMoney(expansionDef.price.num);
            }
            close(true);
         });
      }
      
      private function triggeredPurchase(param1:Event) : void
      {
         var event:Event = param1;
         ResidentMenuUI_Gudetama.getInstance().showMetalShop(function():void
         {
            var _loc1_:Boolean = UserDataWrapper.wrapper.hasItem(expansionDef.price);
            if(_loc1_ && !enoughConsumeItem)
            {
               purchaseBtn.visible = false;
               notEnoughImage.visible = false;
               exchangeBtn.touchable = true;
               TweenAnimator.startItself(displaySprite,"enough");
               enoughConsumeItem = _loc1_;
            }
         });
      }
      
      private function triggeredClose(param1:Event) : void
      {
         close(false);
      }
      
      private function close(param1:Boolean) : void
      {
         var result:Boolean = param1;
         super.backButtonCallback();
         setBackButtonCallback(null);
         callback(result);
         TweenAnimator.startItself(displaySprite,"hide",false,function(param1:DisplayObject):void
         {
            displaySprite.visible = false;
            Engine.popScene(scene);
         });
      }
   }
}
