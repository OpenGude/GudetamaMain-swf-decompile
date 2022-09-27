package gudetama.extensions
{
   import com.milkmangames.nativeextensions.android.AndroidIAB;
   import com.milkmangames.nativeextensions.android.AndroidItemDetails;
   import com.milkmangames.nativeextensions.android.AndroidPurchase;
   import com.milkmangames.nativeextensions.android.events.AndroidBillingErrorEvent;
   import com.milkmangames.nativeextensions.android.events.AndroidBillingEvent;
   import gudetama.engine.Engine;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   
   public class AndroidBillingExtensions
   {
       
      
      private var purchaseCallback:Function;
      
      private var consumeCallback:Function;
      
      private var itemDetailCallback:Function;
      
      private var inventoryCallback:Function;
      
      private var myPurchases:Vector.<AndroidPurchase>;
      
      private var items:Object;
      
      private var created:Boolean = false;
      
      public function AndroidBillingExtensions()
      {
         super();
         createAndroidIAB();
      }
      
      public function createAndroidIAB() : void
      {
         if(!AndroidIAB.isSupported())
         {
            pretrace("Android Billing is not supported on this platform.");
            return;
         }
         pretrace("initializing Android billing..");
         AndroidIAB.create();
         pretrace("AndroidIAB Initialized.");
         AndroidIAB.androidIAB.addEventListener("iabBillingServiceReady",onServiceReady);
         AndroidIAB.androidIAB.addEventListener("iabBillingServiceNotSupported",onServiceUnsupported);
         AndroidIAB.androidIAB.addEventListener("iabPurchaseSucceeded",onPurchaseSuccess);
         AndroidIAB.androidIAB.addEventListener("iabPurchaseFailed",onPurchaseFailed);
         AndroidIAB.androidIAB.addEventListener("CONSUME_SUCCEEDED",onConsumed);
         AndroidIAB.androidIAB.addEventListener("CONSUME_FAILED",onConsumeFailed);
         AndroidIAB.androidIAB.addEventListener("ITEM_DETAILS_LOADED",onItemDetails);
         AndroidIAB.androidIAB.addEventListener("ITEM_DETAILS_FAILED",onDetailsFailed);
         AndroidIAB.androidIAB.addEventListener("INVENTORY_LOADED",onInventoryLoaded);
         AndroidIAB.androidIAB.addEventListener("INVENTORY_FAILED",onInventoryFailed);
         pretrace("starting billing service...");
         var _loc1_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(114),function(param1:Array):void
         {
            if(param1 != null)
            {
               AndroidIAB.androidIAB.startBillingService(param1[0]);
               return;
            }
         });
         created = true;
         pretrace("Waiting for biling response...");
      }
      
      private function setupBillingService() : void
      {
         var _loc1_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(114),function(param1:Array):void
         {
            if(param1 != null)
            {
               AndroidIAB.androidIAB.startBillingService(param1[0]);
               return;
            }
         });
      }
      
      public function setupPurchaseCallback(param1:Function) : void
      {
         this.purchaseCallback = param1;
      }
      
      public function setupConsumeCallback(param1:Function) : void
      {
         this.consumeCallback = param1;
      }
      
      public function setupItemDetailCallback(param1:Function) : void
      {
         this.itemDetailCallback = param1;
      }
      
      public function setupInventoryCallback(param1:Function) : void
      {
         try
         {
            if(!AndroidIAB.isSupported())
            {
               param1(null);
               return;
            }
            this.inventoryCallback = param1;
            AndroidIAB.androidIAB.loadPlayerInventory();
         }
         catch(error:Error)
         {
            Engine.traceLog(error);
            if(created)
            {
               setupBillingService();
            }
            else
            {
               createAndroidIAB();
            }
         }
      }
      
      private function onServiceReady(param1:AndroidBillingEvent) : void
      {
         pretrace("Service ready. Loading inventory...");
         AndroidIAB.androidIAB.loadPlayerInventory();
      }
      
      private function onServiceUnsupported(param1:AndroidBillingEvent) : void
      {
      }
      
      private function onPurchaseSuccess(param1:AndroidBillingEvent) : void
      {
         purchaseCallback("iap_purchaseSucceeded",param1.jsonData,param1.signature);
      }
      
      private function onPurchaseFailed(param1:AndroidBillingErrorEvent) : void
      {
         pretrace("Failure purchasing \'" + param1.itemId + "\', reason:" + param1.text#2 + " ," + param1.type);
         consumeItem(param1.itemId);
         purchaseCallback("iap_purchaseFailed",null);
      }
      
      private function onConsumed(param1:AndroidBillingEvent) : void
      {
         try
         {
            pretrace("Did consume item:" + param1.itemId);
            AndroidIAB.androidIAB.loadPlayerInventory();
         }
         catch(error:Error)
         {
            Engine.traceLog(error);
            if(created)
            {
               setupBillingService();
            }
            else
            {
               createAndroidIAB();
            }
         }
      }
      
      private function onConsumeFailed(param1:AndroidBillingErrorEvent) : void
      {
         pretrace("Consume failed : " + param1.errorID + "/" + param1.text#2);
      }
      
      private function onItemDetails(param1:AndroidBillingEvent) : void
      {
         var _loc3_:Array = [];
         items = {};
         for each(var _loc2_ in param1.itemDetails)
         {
            _loc3_.push(_loc2_.itemId + ":" + _loc2_.price);
            items[_loc2_.itemId] = _loc2_.price;
         }
         itemDetailCallback(param1.itemDetails.length,_loc3_);
      }
      
      private function onDetailsFailed(param1:AndroidBillingErrorEvent) : void
      {
         pretrace("Error loading details: " + param1.errorID + "/" + param1.text#2);
      }
      
      public function beginAppPurchase(param1:String) : Boolean
      {
         if(AndroidIAB.isSupported())
         {
            pretrace("AndroidBillingExtensions#beginAppPurchase :" + param1);
            AndroidIAB.androidIAB.purchaseItem(param1);
            return true;
         }
         return false;
      }
      
      public function consumeItem(param1:String) : Boolean
      {
         if(AndroidIAB.isSupported())
         {
            AndroidIAB.androidIAB.consumeItem(param1);
            return true;
         }
         return false;
      }
      
      public function loadItemDetails(param1:Array) : void
      {
         var _loc2_:* = undefined;
         if(AndroidIAB.isSupported())
         {
            _loc2_ = Vector.<String>(param1);
            pretrace("Loading item details for " + _loc2_.join(","));
            AndroidIAB.androidIAB.loadItemDetails(_loc2_);
            pretrace("Waiting for item details...");
         }
      }
      
      private function onInventoryLoaded(param1:AndroidBillingEvent) : void
      {
         pretrace("Inventory updated.");
         this.myPurchases = param1.purchases;
         updateInventory();
      }
      
      private function onInventoryFailed(param1:AndroidBillingErrorEvent) : void
      {
         pretrace("Failed loading inventory: " + param1.errorID + "/" + param1.text#2);
         if(inventoryCallback)
         {
            inventoryCallback(null);
         }
      }
      
      public function updateInventory() : void
      {
         var _loc4_:Vector.<String> = new Vector.<String>();
         if(myPurchases == null)
         {
            if(inventoryCallback)
            {
               inventoryCallback(null);
            }
            return;
         }
         var _loc2_:Array = [];
         var _loc1_:Array = [];
         for each(var _loc3_ in myPurchases)
         {
            pretrace("You own the item:" + _loc3_.jsonData);
            _loc2_.push(_loc3_.jsonData);
            _loc1_.push(_loc3_.signature);
         }
         if(inventoryCallback)
         {
            inventoryCallback(_loc2_,_loc1_);
         }
      }
      
      private function pretrace(param1:String) : void
      {
      }
      
      private function dummy(param1:int) : void
      {
      }
   }
}
