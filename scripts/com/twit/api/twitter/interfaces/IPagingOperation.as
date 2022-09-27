package com.twit.api.twitter.interfaces
{
   import com.twit.api.interfaces.IOperation;
   
   public interface IPagingOperation extends IOperation
   {
       
      
      function get cursor() : String;
      
      function set cursor(param1:String) : void;
   }
}
