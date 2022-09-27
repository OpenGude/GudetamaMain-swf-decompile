package gudetama.engine
{
   import gudetama.data.DataStorage;
   
   public class ApplicationSettings
   {
      
      public static const DEFAULT_RESOURCE_URL:String = "http://%1$s/gde/static/";
      
      public static const DEFAULT_SERVLET_HOST:String = "gudetama%03d.cyberstep.jp";
      
      private static var resourceUrlBase:String;
       
      
      public function ApplicationSettings()
      {
         super();
      }
      
      public static function getDefaultServletHost(param1:int = 0) : String
      {
         var _loc2_:String = DataStorage.getLastConnectedServletHost();
         if(_loc2_)
         {
            return _loc2_;
         }
         var _loc4_:int = 101 + param1;
         var _loc3_:String = (String("000" + _loc4_)).slice(-3);
         return "gudetama%03d.cyberstep.jp".replace("%03d",_loc3_);
      }
      
      public static function setResourceUrlBase(param1:String, param2:Boolean = false) : void
      {
         if(param2 && resourceUrlBase)
         {
            return;
         }
         resourceUrlBase = param1;
         Logger.debug("\tset resourceUrlBase " + resourceUrlBase);
      }
      
      public static function getResourceUrl(param1:String, param2:Boolean = false) : String
      {
         var _loc3_:* = null;
         if(resourceUrlBase == null || param2)
         {
            _loc3_ = getDefaultServletHost(0);
            if(_loc3_.indexOf(":") < 0)
            {
               _loc3_ += ":8080";
            }
            if(param2)
            {
               return "http://%1$s/gde/static/".replace("%1$s",_loc3_) + param1;
            }
            resourceUrlBase = "http://%1$s/gde/static/".replace("%1$s",_loc3_);
         }
         return resourceUrlBase + param1;
      }
   }
}
