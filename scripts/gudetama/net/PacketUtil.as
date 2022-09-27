package gudetama.net
{
   import gudetama.common.BannerAdvertisingManager;
   import gudetama.common.InterstitialAdvertisingManager;
   import gudetama.data.DataStorage;
   import gudetama.data.LocalData;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.Packet;
   import gudetama.data.compati.TouchEventParam;
   
   public class PacketUtil
   {
       
      
      public function PacketUtil()
      {
         super();
      }
      
      private static function _create(param1:int) : Packet
      {
         var _loc2_:Packet = new Packet();
         _loc2_.type = param1;
         return _loc2_;
      }
      
      public static function create(param1:int) : Packet
      {
         var _loc2_:Packet = _create(param1);
         setupPayloadExtra(_loc2_);
         return _loc2_;
      }
      
      public static function createWithInt(param1:int, param2:*) : Packet
      {
         var _loc3_:Packet = _create(param1);
         if(param2 is Array)
         {
            _loc3_.payloadInt = param2;
         }
         else
         {
            if(!(param2 is int))
            {
               throw new Error();
            }
            _loc3_.payloadInt = [param2];
         }
         setupPayloadExtra(_loc3_);
         return _loc3_;
      }
      
      public static function createWithObject(param1:int, param2:*) : Packet
      {
         var _loc3_:Packet = _create(param1);
         if(param2 is Array)
         {
            _loc3_.payloadObj0 = param2[0];
            _loc3_.payloadObj1 = param2[1];
         }
         else
         {
            _loc3_.payloadObj0 = param2;
         }
         setupPayloadExtra(_loc3_);
         return _loc3_;
      }
      
      public static function createWithIntAndObject(param1:int, param2:*, param3:*) : Packet
      {
         var _loc4_:Packet;
         (_loc4_ = createWithInt(param1,param2)).payloadObj0 = param3;
         return _loc4_;
      }
      
      public static function createWithIntAndArrayObject(param1:int, param2:*, param3:*) : Packet
      {
         var _loc4_:Packet = createWithInt(param1,param2);
         if(param3 is Array)
         {
            _loc4_.payloadObj0 = param3[0];
            _loc4_.payloadObj1 = param3[1];
         }
         else
         {
            _loc4_.payloadObj0 = param3;
         }
         return _loc4_;
      }
      
      private static function setupPayloadExtra(param1:Packet) : void
      {
         var _loc7_:* = null;
         var _loc12_:* = undefined;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc3_:* = null;
         var _loc9_:* = null;
         if(!UserDataWrapper.isInitialized())
         {
            return;
         }
         var _loc8_:LocalData;
         if((_loc8_ = DataStorage.getLocalData()).existsPendingNum())
         {
            if(!_loc7_)
            {
               _loc7_ = [];
            }
            _loc12_ = _loc8_.popPendingNums();
            _loc4_ = _loc8_.popPendingBonusValues();
            _loc5_ = UserDataWrapper.wrapper.sendTouchCount;
            _loc7_.push("send_touch:" + _loc12_ + "-" + _loc4_ + "-" + _loc5_ + "-" + (!!_loc8_.isTouchStarted ? 1 : 0));
         }
         if(UserDataWrapper.wrapper.existsDropItemEvent())
         {
            if(!_loc7_)
            {
               _loc7_ = [];
            }
            _loc3_ = UserDataWrapper.wrapper.getDropItemEvent();
            _loc7_.push("send_drop:" + _loc3_.toString());
         }
         if(UserDataWrapper.wrapper.existsHeavenEvent())
         {
            if(!_loc7_)
            {
               _loc7_ = [];
            }
            _loc9_ = UserDataWrapper.wrapper.getHeavenEvent();
            _loc7_.push("send_heaven:" + _loc9_.toString());
         }
         var _loc6_:uint;
         if((_loc6_ = BannerAdvertisingManager.showCyberStepNum) > 0)
         {
            if(!_loc7_)
            {
               _loc7_ = [];
            }
            _loc7_.push("send_show_csbanner:" + _loc6_);
            BannerAdvertisingManager.showCyberStepNum = 0;
         }
         var _loc10_:Object;
         if(_loc10_ = BannerAdvertisingManager.showCyberStepBannerNumMap)
         {
            if(!_loc7_)
            {
               _loc7_ = [];
            }
            for(var _loc13_ in _loc10_)
            {
               _loc7_.push("send_show_csbanner_ids:" + _loc13_ + "," + _loc10_[_loc13_]);
            }
            BannerAdvertisingManager.showCyberStepBannerNumMap = null;
         }
         var _loc2_:Object = InterstitialAdvertisingManager.showCyberstepInterMap;
         if(_loc2_)
         {
            for(var _loc11_ in _loc2_)
            {
               if(!_loc7_)
               {
                  _loc7_ = [];
               }
               _loc7_.push("send_show_csinter:" + _loc11_ + "," + _loc2_[_loc11_]);
            }
            InterstitialAdvertisingManager.showCyberstepInterMap = null;
         }
         param1.payloadExtra = _loc7_;
      }
   }
}
