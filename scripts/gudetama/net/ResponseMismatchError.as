package gudetama.net
{
   public class ResponseMismatchError extends Error
   {
       
      
      public function ResponseMismatchError(param1:String = "")
      {
         super(param1);
      }
      
      public function toString() : String
      {
         return "ResponseMismatchError: " + message;
      }
   }
}
