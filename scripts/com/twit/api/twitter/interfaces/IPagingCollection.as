package com.twit.api.twitter.interfaces
{
   public interface IPagingCollection
   {
       
      
      function get nextCursor() : String;
      
      function set nextCursor(param1:String) : void;
      
      function get previousCursor() : String;
      
      function set previousCursor(param1:String) : void;
   }
}
