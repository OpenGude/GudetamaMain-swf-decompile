package gudetama.engine
{
   public class FileInfoValidationError extends Error
   {
       
      
      public var fileInfo:Object;
      
      public function FileInfoValidationError(param1:Object, param2:* = "", param3:* = 0)
      {
         super(param2,param3);
         this.fileInfo = param1;
      }
   }
}
