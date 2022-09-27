package com.twit.api.twitter.interfaces
{
   import com.twit.api.interfaces.IOperation;
   import com.twit.api.twitter.TwitterAPI;
   
   public interface ITwitterOperation extends IOperation
   {
       
      
      function get requiresAuthentication() : Boolean;
      
      function get apiRateLimited() : Boolean;
      
      function setTwitterAPI(param1:TwitterAPI) : void;
   }
}
