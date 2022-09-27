package com.twit.api.delegates
{
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestHeader;
   import flash.net.URLVariables;
   import mx.rpc.Fault;
   import mx.rpc.events.FaultEvent;
   import mx.rpc.events.ResultEvent;
   
   public class URLLoaderDelegate extends EventDispatcher implements IServiceDelegate
   {
       
      
      protected var urlLoader:URLLoader;
      
      protected var urlRequest:URLRequest;
      
      private var _headers:Object;
      
      private var _method:String;
      
      private var _url:String;
      
      private var _params:Object;
      
      private var _resultFormat:String;
      
      public function URLLoaderDelegate()
      {
         super();
      }
      
      public function get resultFormat#2() : String
      {
         return _resultFormat;
      }
      
      public function set resultFormat#2(param1:String) : void
      {
         _resultFormat = param1;
      }
      
      public function get params#2() : Object
      {
         return _params;
      }
      
      public function set params#2(param1:Object) : void
      {
         _params = param1;
      }
      
      public function get method#2() : String
      {
         return _method;
      }
      
      public function set method#2(param1:String) : void
      {
         _method = param1;
      }
      
      public function get headers#2() : Object
      {
         return _headers;
      }
      
      public function set headers#2(param1:Object) : void
      {
         _headers = param1;
      }
      
      public function get url#2() : String
      {
         return _url;
      }
      
      public function set url#2(param1:String) : void
      {
         _url = param1;
      }
      
      public function get lastResult() : Object
      {
         if(urlLoader)
         {
            return urlLoader.data#2;
         }
         return null;
      }
      
      public function send() : void
      {
         var _loc1_:* = null;
         var _loc2_:* = null;
         urlLoader = new URLLoader();
         urlLoader.addEventListener("complete",handleResult);
         urlLoader.addEventListener("securityError",handleFault);
         urlLoader.addEventListener("ioError",handleFault);
         urlRequest = new URLRequest(url#2);
         if(headers#2)
         {
            _loc1_ = [];
            for(var _loc4_ in headers#2)
            {
               _loc1_.push(new URLRequestHeader(_loc4_,headers#2[_loc4_]));
            }
            urlRequest.requestHeaders = _loc1_;
         }
         if(method#2)
         {
            urlRequest.method#2 = method#2;
         }
         if(params#2)
         {
            _loc2_ = new URLVariables();
            for(var _loc3_ in params#2)
            {
               _loc2_[_loc3_] = params#2[_loc3_];
            }
            urlRequest.data#2 = _loc2_;
         }
         urlLoader.load(urlRequest);
      }
      
      protected function handleResult(param1:Event) : void
      {
         dispatchEvent(new ResultEvent("result",false,true,lastResult));
      }
      
      protected function handleFault(param1:ErrorEvent) : void
      {
         var _loc2_:Fault = new Fault(param1.text#2,param1.text#2);
         dispatchEvent(new FaultEvent("fault",false,true,_loc2_));
      }
   }
}
