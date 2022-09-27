package gudetama.extensions
{
   public class AppsFlyerExtensions
   {
      
      private static var appsFlyer:AppsFlyerInterface;
      
      private static var appsFlyerUid:String;
       
      
      public function AppsFlyerExtensions()
      {
         super();
      }
      
      public static function setup(param1:String, param2:String) : void
      {
         appsFlyer = new AppsFlyerInterface();
         appsFlyer.setCollectIMEI(false);
         if(param2 != null)
         {
            appsFlyer.startTracking(param1,param2);
         }
         else
         {
            appsFlyer.init(param1,null);
         }
         appsFlyer.trackAppLaunch();
         appsFlyerUid = appsFlyer.getAppsFlyerUID();
      }
      
      public static function getAppsFlyerUid() : String
      {
         return appsFlyerUid;
      }
      
      public static function trackEvent(param1:String, param2:String) : void
      {
         if(appsFlyer == null)
         {
            return;
         }
         appsFlyer.trackEvent(param1,param2);
      }
   }
}
