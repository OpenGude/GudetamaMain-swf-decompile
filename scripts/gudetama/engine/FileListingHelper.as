package gudetama.engine
{
   import flash.filesystem.File;
   
   public class FileListingHelper
   {
       
      
      public function FileListingHelper()
      {
         super();
      }
      
      public static function getFileList(param1:File, param2:String, param3:Array = null) : Array
      {
         var _loc4_:Array = [];
         var _loc6_:File = param1.resolvePath(param2);
         if(!param1.exists)
         {
            return _loc4_;
         }
         var _loc7_:Array = _loc6_.getDirectoryListing();
         for each(var _loc5_ in _loc7_)
         {
            if(_loc5_.name#2.charAt(0) != ".")
            {
               if(!(param3 && param3.indexOf(getPostfix(_loc5_.name#2).toLowerCase()) == -1))
               {
                  _loc4_.push(stripPostfix(_loc5_.name#2));
               }
            }
         }
         return _loc4_;
      }
      
      public static function stripPostfix(param1:String) : String
      {
         var _loc2_:int = param1.indexOf(".");
         if(_loc2_ != -1)
         {
            return param1.substring(0,_loc2_);
         }
         return param1;
      }
      
      private static function getPostfix(param1:String) : String
      {
         var _loc2_:int = param1.lastIndexOf(".");
         if(_loc2_ == -1)
         {
            return null;
         }
         return param1.substring(_loc2_ + 1);
      }
   }
}
