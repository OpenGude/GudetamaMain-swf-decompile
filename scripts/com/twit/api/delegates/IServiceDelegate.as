package com.twit.api.delegates
{
   import flash.events.IEventDispatcher;
   
   public interface IServiceDelegate extends IEventDispatcher
   {
       
      
      function get url() : String;
      
      function set url(param1:String) : void;
      
      function get headers() : Object;
      
      function set headers(param1:Object) : void;
      
      function get method() : String;
      
      function set method(param1:String) : void;
      
      function get params() : Object;
      
      function set params(param1:Object) : void;
      
      function get resultFormat() : String;
      
      function set resultFormat(param1:String) : void;
      
      function get lastResult() : Object;
      
      function send() : void;
   }
}
