package gudetama.engine
{
   import gudetama.data.UserDataWrapper;
   import gudetama.net.HttpConnector;
   import gudetama.util.TimeZoneUtil;
   
   public class Logger
   {
      
      public static const ERROR_RESOURCE_LIMIT:int = 3691;
      
      private static const LEVEL_ERROR:int = 0;
      
      private static const LEVEL_WARN:int = 1;
      
      private static const LEVEL_INFO:int = 2;
      
      private static const LEVEL_DEBUG:int = 3;
      
      private static const TAG_NAME:Array = ["ERROR","WARN","INFO","DEBUG"];
       
      
      public function Logger()
      {
         super();
      }
      
      public static function error(param1:String, ... rest) : void
      {
         _log(0,param1,rest);
      }
      
      public static function warn(param1:String, ... rest) : void
      {
         _log(1,param1,rest);
      }
      
      public static function info(param1:String, ... rest) : void
      {
         _log(2,param1,rest);
      }
      
      public static function debug(param1:String, ... rest) : void
      {
         _log(3,param1,rest);
      }
      
      private static function _log(param1:int, param2:String, param3:Array) : void
      {
         var _loc7_:* = 3 >= param1;
         var _loc9_:* = 2 >= param1;
         if(!_loc7_ && !_loc9_)
         {
            return;
         }
         var _loc8_:String = (_loc8_ = (_loc8_ = (_loc8_ = (_loc8_ = (_loc8_ = "") + ("[" + TimeZoneUtil.getCurrentDateTime() + "]")) + (" [" + TAG_NAME[param1] + "]")) + (" [u:" + UserDataWrapper.wrapper.getUid() + "]")) + (" [v:" + Engine.applicationVersion + "]")) + (" [p:" + Engine.platform + "]");
         var _loc5_:* = param2;
         var _loc6_:String = "{}";
         for each(var _loc4_ in param3)
         {
            if(_loc4_ is Error)
            {
               _loc4_ = (_loc4_ as Error).getStackTrace();
            }
            if(_loc5_.indexOf(_loc6_) >= 0)
            {
               _loc5_ = _loc5_.replace(_loc6_,_loc4_);
            }
            else
            {
               _loc5_ += " " + _loc4_;
            }
         }
         _loc8_ += "\t" + _loc5_;
         if(_loc7_)
         {
            trace(_loc8_);
         }
         if(_loc9_)
         {
            HttpConnector.sendTraceLog(_loc8_);
         }
      }
   }
}
