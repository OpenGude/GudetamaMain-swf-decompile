package com.twit.api.delegates
{
   import flash.events.EventDispatcher;
   import mx.rpc.Fault;
   import mx.rpc.events.FaultEvent;
   import mx.rpc.events.ResultEvent;
   import mx.rpc.http.HTTPService;
   
   public class HTTPServiceDelegate extends EventDispatcher implements IServiceDelegate
   {
       
      
      protected var httpService:HTTPService;
      
      private var _headers:Object;
      
      private var _method:String;
      
      private var _url:String;
      
      private var _params:Object;
      
      private var _resultFormat:String;
      
      public function HTTPServiceDelegate()
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
         if(httpService)
         {
            return httpService.lastResult;
         }
         return null;
      }
      
      public function send() : void
      {
         httpService = new HTTPService();
         httpService.addEventListener("result",handleResult);
         httpService.addEventListener("fault",handleFault);
         httpService.url#2 = url#2;
         if(headers#2)
         {
            for(var _loc1_ in headers#2)
            {
               httpService.headers#2[_loc1_] = headers#2[_loc1_];
            }
         }
         if(method#2)
         {
            httpService.method#2 = method#2;
         }
         switch(resultFormat#2)
         {
            case "json":
               httpService.resultFormat#2 = "text";
               break;
            case "xml":
            default:
               httpService.resultFormat#2 = "e4x";
         }
         httpService.send(params#2);
      }
      
      protected function handleResult(param1:ResultEvent) : void
      {
         dispatchEvent(new ResultEvent("result",false,true,param1.result));
      }
      
      protected function handleFault(param1:FaultEvent) : void
      {
         var _loc2_:Fault = new Fault(param1.fault.faultCode,param1.fault.faultString,param1.fault.faultDetail);
         dispatchEvent(new FaultEvent("fault",false,true,_loc2_));
      }
   }
}
