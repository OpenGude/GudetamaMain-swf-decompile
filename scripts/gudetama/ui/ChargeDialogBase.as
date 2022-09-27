package gudetama.ui
{
   import gudetama.common.GudetamaUtil;
   import gudetama.common.NativeExtensions;
   import gudetama.data.DataStorage;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.MetalShopDef;
   import gudetama.data.compati.MetalShopItemDef;
   import gudetama.data.compati.MonthlyPremiumBonusDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   
   public class ChargeDialogBase extends BaseScene
   {
       
      
      protected var callback:Function;
      
      protected var debug:Boolean = true;
      
      protected var chargeType:int;
      
      protected var priceMap:Object;
      
      private var productIdList:Array;
      
      public function ChargeDialogBase(param1:int)
      {
         super(param1);
         debug = false;
      }
      
      protected function getPrice(param1:MetalShopItemDef, param2:String) : Array
      {
         var _loc7_:* = null;
         var _loc8_:* = null;
         var _loc6_:* = null;
         var _loc4_:* = null;
         var _loc3_:Number = param1.price;
         var _loc9_:String = null;
         if(param2 != null)
         {
            _loc8_ = ((_loc7_ = /\d+(,\d+)*(\.\d+)?/).exec(param2) as Object)[0];
            _loc6_ = (_loc8_ = GudetamaUtil.convertEuro(_loc8_)).split(",");
            _loc4_ = "";
            for each(var _loc5_ in _loc6_)
            {
               _loc4_ += _loc5_;
            }
            if((_loc9_ = param2.replace(_loc4_,"%1")).indexOf("US$") >= 0)
            {
               _loc9_ = _loc9_.replace("US","");
            }
            if(_loc9_ == "%1")
            {
               _loc9_ = null;
            }
            _loc3_ = parseFloat(_loc4_);
         }
         return [_loc3_,_loc9_];
      }
      
      public function loadPrice(param1:MetalShopDef, param2:Function) : void
      {
         var def:MetalShopDef = param1;
         var callback:Function = param2;
         var checkOverlap:* = function(param1:MetalShopItemDef):void
         {
            if(!param1.overlap)
            {
               return;
            }
            addProductIdList(param1.overlap);
            if(debug)
            {
               if(GameSetting.checkLimit(param1.overlap))
               {
                  priceMap[param1.overlap.product_id] = param1.overlap.price;
               }
            }
            checkOverlap(param1.overlap);
         };
         priceMap = {};
         productIdList = [];
         for each(item in def.items)
         {
            addProductIdList(item);
            if(debug)
            {
               if(GameSetting.checkLimit(item))
               {
                  priceMap[item.product_id] = item.price;
               }
            }
            checkOverlap(item);
         }
         var monthlyPremiumBonusMap:Object = GameSetting.getMonthlyPremiumBonusTable();
         for(key in monthlyPremiumBonusMap)
         {
            var monthly:MonthlyPremiumBonusDef = monthlyPremiumBonusMap[key] as MonthlyPremiumBonusDef;
            addProductIdList(monthly.item);
            if(debug)
            {
               if(GameSetting.checkLimit(monthly.item))
               {
                  priceMap[monthly.item.product_id] = monthly.item.price;
               }
            }
         }
         var isOneStore:Boolean = false;
         if(isOneStore)
         {
            var allItems:Vector.<String> = Vector.<String>(productIdList);
            NativeExtensions.requestOneStorePurchaseList(allItems.join(","),function(param1:Boolean, param2:String):void
            {
               var _loc3_:* = null;
               var _loc4_:int = 0;
               var _loc6_:* = null;
               if(param1)
               {
                  _loc3_ = param2.split(",");
                  _loc4_ = _loc3_.length;
                  for each(var _loc5_ in _loc3_)
                  {
                     _loc6_ = _loc5_.split(":");
                     priceMap[_loc6_[0]] = _loc6_[1];
                  }
                  if(makeList)
                  {
                     makeList();
                  }
               }
               else
               {
                  MessageDialog.show(10,GameSetting.getUIText("pricelist.error.1"),null);
               }
               callback();
            });
         }
         else if(debug)
         {
            if(makeList)
            {
               makeList();
            }
            callback();
         }
         else
         {
            var _loc8_:* = Engine;
            if(gudetama.engine.Engine.platform == 0)
            {
               var extEnabled:Boolean = NativeExtensions.requestPriceList(productIdList,function(param1:int, param2:String):void
               {
                  var _loc3_:* = null;
                  var _loc5_:* = null;
                  if(param1 >= 0)
                  {
                     param2 = param2.substring(1);
                     _loc3_ = param2.split("/");
                     for each(var _loc4_ in _loc3_)
                     {
                        _loc5_ = _loc4_.split(":");
                        priceMap[_loc5_[0]] = _loc5_[1];
                     }
                     if(makeList)
                     {
                        makeList();
                     }
                  }
                  else
                  {
                     MessageDialog.show(10,GameSetting.getUIText("pricelist.error." + Math.abs(param1)),null);
                  }
                  callback();
               });
               if(!extEnabled)
               {
                  callback();
               }
            }
            else
            {
               var _loc9_:* = Engine;
               if(gudetama.engine.Engine.platform == 1)
               {
                  var buillingEnabled:Boolean = NativeExtensions.requestPriceList(productIdList,function(param1:int, param2:Array):void
                  {
                     var _loc3_:* = null;
                     var _loc4_:int = 0;
                     var _loc5_:* = null;
                     if(param1 >= 0)
                     {
                        _loc3_ = null;
                        _loc4_ = 0;
                        while(_loc4_ < param2.length)
                        {
                           _loc3_ = param2[_loc4_];
                           if(_loc3_ != null)
                           {
                              _loc5_ = _loc3_.split(":");
                              priceMap[_loc5_[0]] = _loc5_[1];
                           }
                           _loc4_++;
                        }
                        if(makeList)
                        {
                           makeList();
                        }
                     }
                     else
                     {
                        MessageDialog.show(10,GameSetting.getUIText("pricelist.error." + Math.abs(param1)),null);
                     }
                     callback();
                  });
                  if(!buillingEnabled)
                  {
                     callback();
                  }
               }
            }
         }
      }
      
      protected function purchase(param1:MetalShopItemDef, param2:Function = null) : void
      {
         var metalShopItemDef:MetalShopItemDef = param1;
         var purchaseCallback:Function = param2;
         Engine.showLoading(scene);
         var ret:int = NativeExtensions.purchase(metalShopItemDef.product_id,function(param1:int, param2:Object, param3:String = ""):void
         {
            var code:int = param1;
            var level:Object = param2;
            var signature:String = param3;
            if(code != 0)
            {
               Engine.hideLoading(scene);
               if(purchaseCallback)
               {
                  purchaseCallback();
               }
               return;
            }
            var isOneStore:Boolean = false;
            var receipt:String = level as String;
            if(isOneStore)
            {
               DataStorage.getLocalData().addReceipt(UserDataWrapper.wrapper.getUid(),receipt);
               DataStorage.saveLocalData();
               Engine.sendReceiptAndSetupCallbackOneStore(true,function():void
               {
                  Engine.hideLoading(scene);
                  procAfterPurchseSuccess(metalShopItemDef);
               });
            }
            else
            {
               var _loc5_:* = Engine;
               if(gudetama.engine.Engine.platform == 0)
               {
                  DataStorage.getLocalData().addReceipt(UserDataWrapper.wrapper.getUid(),receipt);
                  var saveResult:Boolean = DataStorage.saveLocalData(function(param1:Boolean):void
                  {
                     var saved:Boolean = param1;
                     if(saved)
                     {
                        Engine.sendReceiptForiOS(true,function(param1:int):void
                        {
                           if(callback)
                           {
                              callback(chargeType);
                           }
                           updateMonthlyPremiumBonusTime();
                           Engine.hideLoading(scene);
                           if(purchaseCallback)
                           {
                              purchaseCallback();
                           }
                           if(param1 == 0)
                           {
                              procAfterPurchseSuccess(metalShopItemDef);
                           }
                           else if(param1 == 21005)
                           {
                              MessageDialog.show(10,GameSetting.getUIText("receipt.error.21005"),null);
                           }
                           else
                           {
                              MessageDialog.show(10,GameSetting.getUIText("receipt.error"),null);
                           }
                        });
                     }
                     else
                     {
                        processSendReceiptDirect(receipt,metalShopItemDef);
                     }
                  });
                  if(!saveResult)
                  {
                     processSendReceiptDirect(receipt,metalShopItemDef);
                  }
               }
               else
               {
                  processSendReceiptDirect(receipt,metalShopItemDef);
               }
            }
         });
         if(ret < 0)
         {
            Engine.hideLoading(scene);
            MessageDialog.show(10,GameSetting.getUIText("purchase.error." + Math.abs(ret)),null);
            if(purchaseCallback)
            {
               purchaseCallback();
            }
         }
      }
      
      private function addProductIdList(param1:MetalShopItemDef) : void
      {
         if(GameSetting.checkLimit(param1))
         {
            productIdList.push(param1.product_id);
         }
      }
      
      protected function updateMonthlyPremiumBonusTime() : void
      {
      }
      
      protected function procPurchaseSuccess(param1:MetalShopItemDef) : void
      {
      }
      
      protected function makeList() : void
      {
      }
      
      private function processSendReceiptDirect(param1:String, param2:MetalShopItemDef) : void
      {
         var receipt:String = param1;
         var metalShopItemDef:MetalShopItemDef = param2;
         Engine.sendReceiptDirect(receipt,true,function(param1:int):void
         {
            var code:int = param1;
            if(code == 21005)
            {
               Engine.hideLoading(scene);
               MessageDialog.show(2,GameSetting.getUIText("receipt.error.again"),function(param1:int):void
               {
                  if(param1 == 0)
                  {
                     Engine.showLoading(scene);
                     processSendReceiptDirect(receipt,metalShopItemDef);
                  }
                  else
                  {
                     MessageDialog.show(10,GameSetting.getUIText("receipt.error.failed"),null);
                  }
               });
               return;
            }
            if(callback)
            {
               callback(chargeType);
            }
            updateMonthlyPremiumBonusTime();
            Engine.hideLoading(scene);
            if(code == 0)
            {
               procAfterPurchseSuccess(metalShopItemDef);
            }
            else
            {
               MessageDialog.show(10,GameSetting.getUIText("receipt.error"),null);
            }
         });
      }
      
      private function procAfterPurchseSuccess(param1:MetalShopItemDef) : void
      {
         procPurchaseSuccess(param1);
         makeList();
         Engine.broadcastEventToSceneStackWith("update_scene");
      }
      
      protected function debugPurchase(param1:MetalShopItemDef, param2:Function = null) : void
      {
         var metalShopItemDef:MetalShopItemDef = param1;
         var callback:Function = param2;
         Engine.showLoading(scene);
         var _loc3_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithObject(117441497,metalShopItemDef.product_id),function(param1:Array):void
         {
            Engine.hideLoading(scene);
            procDebugPurchaseResponse(param1);
            updateMonthlyPremiumBonusTime();
            procPurchaseSuccess(metalShopItemDef);
            makeList();
            Engine.broadcastEventToSceneStackWith("update_scene");
            if(callback)
            {
               callback();
            }
         });
      }
      
      protected function procDebugPurchaseResponse(param1:Array) : void
      {
         var _loc4_:int = param1[0][0] as int;
         var _loc5_:int = param1[0][1] as int;
         var _loc6_:int = param1[0][2] as int;
         var _loc2_:int = param1[0][3] as int;
         if(_loc4_ > 0)
         {
            UserDataWrapper.wrapper.addChargeMetal(_loc4_);
         }
         if(_loc5_ > 0)
         {
            UserDataWrapper.wrapper.addFreeMetal(_loc5_);
         }
         if(_loc4_ + _loc5_ > 0)
         {
            ResidentMenuUI_Gudetama.getInstance()._updateMetal();
         }
         if(_loc6_ > 0)
         {
            UserDataWrapper.wrapper.addChargeMoney(_loc6_);
         }
         if(_loc2_ > 0)
         {
            UserDataWrapper.wrapper.addFreeMoney(_loc2_);
         }
         if(_loc6_ + _loc2_ > 0)
         {
            ResidentMenuUI_Gudetama.getInstance()._updateMoney();
         }
         var _loc3_:Array = param1[1];
         Engine.showGetPurchaseItem(_loc3_,null);
         var _loc7_:* = UserDataWrapper;
         gudetama.data.UserDataWrapper.wrapper._data.setItemBuyMap = param1[2];
         UserDataWrapper.wrapper.increaseNumPurchase(param1[3]);
      }
   }
}
