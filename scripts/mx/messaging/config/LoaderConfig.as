package mx.messaging.config
{
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class LoaderConfig
   {
      
      mx_internal static var _url:String = null;
      
      mx_internal static const VERSION:String = "3.0.0.0";
      
      mx_internal static var _parameters:Object;
       
      
      public function LoaderConfig()
      {
         super();
      }
      
      public static function get url#2() : String
      {
         return mx_internal::_url;
      }
      
      public static function get parameters() : Object
      {
         return mx_internal::_parameters;
      }
   }
}
