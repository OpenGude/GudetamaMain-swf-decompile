package gudetama.extensions
{
   import flash.events.Event;
   
   public class QnqNativeEvent extends Event
   {
      
      public static const IAPEVENT_FAILED:String = "iap_purchaseFailed";
      
      public static const IAPEVENT_SUCCEEDED:String = "iap_purchaseSucceeded";
      
      public static const IAPEVENT_RESTORED:String = "iap_purchaseRestored";
      
      public static const IAPEVENT_DEFERRED:String = "iap_purchaseDeferred";
      
      public static const IAPEVENT_PRICELIST_SUCCEEDED:String = "iap_priceList";
      
      public static const IAPEVENT_PRICELIST_FAILED:String = "iap_priceListFailed";
      
      public static const IADEVENT_BANNERACTIONSHOULDBEGIN_NOTLEAVE:String = "iad_bannerActionShouldBegin_notLeave";
      
      public static const IADEVENT_BANNERACTIONSHOULDBEGIN_WILLLEAVE:String = "iad_bannerActionShouldBegin_willLeave";
      
      public static const IADEVENT_BANNERACTIONDIDFINISH:String = "iad_bannerActionDidFinish";
      
      public static const IADEVENT_BANNERLOADFAILED:String = "iad_bannerLoadFailed";
      
      public static const NDBEVENT_BUTTONCLICKED:String = "ndb_buttonClicked";
      
      public static const NDBEVENT_DIALOGCANCELEDBYSYSTEM:String = "ndb_dialogCanceledBySystem";
       
      
      private var _error:String = "";
      
      public function QnqNativeEvent(param1:String, param2:String, param3:Boolean = false, param4:Boolean = false)
      {
         super(param1,param3,param4);
         _error = param2;
      }
      
      public function get error() : String
      {
         return _error;
      }
   }
}
