package gudetama.data
{
   public class StorageError extends Error
   {
       
      
      public function StorageError(param1:String = "")
      {
         super(param1);
      }
      
      public function toString() : String
      {
         return "StorageError: " + message;
      }
   }
}
