package com.twit.api
{
   import com.twit.api.delegates.HTTPServiceDelegate;
   import com.twit.api.delegates.IServiceDelegate;
   import com.twit.api.delegates.URLLoaderDelegate;
   import flash.events.Event;
   import mx.events.PropertyChangeEvent;
   import mx.rpc.events.FaultEvent;
   import mx.rpc.events.ResultEvent;
   
   public class HttpOperation extends Operation
   {
      
      public static const METHOD_GET:String = "GET";
      
      public static const METHOD_POST:String = "POST";
      
      public static const METHOD_HEAD:String = "HEAD";
      
      public static const METHOD_OPTIONS:String = "OPTIONS";
      
      public static const METHOD_PUT:String = "PUT";
      
      public static const METHOD_TRACE:String = "TRACE";
      
      public static const METHOD_DELETE:String = "DELETE";
       
      
      protected var serviceDelegate:IServiceDelegate;
      
      private var url#2292:String;
      
      private var params#2292:Object;
      
      private var method#2292:String;
      
      private var headers#2292:Object;
      
      private var resultFormat#2292:String;
      
      public function HttpOperation(param1:String, param2:Object = null, param3:String = "xml")
      {
         headers#2292 = {};
         resultFormat#2292 = "xml";
         super();
         this.params#2 = param2;
         this.url#2 = param1;
         this.resultFormat#2 = param3;
      }
      
      [Bindable]
      public function get url#2() : String
      {
         return this.url#2292;
      }
      
      public function set url#2(param1:String) : void
      {
         var _loc2_:* = this.url#2292;
         if(_loc2_ !== param1)
         {
            this.url#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"url",_loc2_,param1));
            }
         }
      }
      
      [Bindable]
      public function get params#2() : Object
      {
         return this.params#2292;
      }
      
      public function set params#2(param1:Object) : void
      {
         var _loc2_:* = this.params#2292;
         if(_loc2_ !== param1)
         {
            this.params#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"params",_loc2_,param1));
            }
         }
      }
      
      [Bindable]
      public function get method#2() : String
      {
         return this.method#2292;
      }
      
      public function set method#2(param1:String) : void
      {
         var _loc2_:* = this.method#2292;
         if(_loc2_ !== param1)
         {
            this.method#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"method",_loc2_,param1));
            }
         }
      }
      
      [Bindable]
      public function get headers#2() : Object
      {
         return this.headers#2292;
      }
      
      public function set headers#2(param1:Object) : void
      {
         var _loc2_:* = this.headers#2292;
         if(_loc2_ !== param1)
         {
            this.headers#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"headers",_loc2_,param1));
            }
         }
      }
      
      [Bindable]
      public function get resultFormat#2() : String
      {
         return this.resultFormat#2292;
      }
      
      public function set resultFormat#2(param1:String) : void
      {
         var _loc2_:* = this.resultFormat#2292;
         if(_loc2_ !== param1)
         {
            this.resultFormat#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"resultFormat",_loc2_,param1));
            }
         }
      }
      
      override public function execute() : void
      {
         if(!method#2 || method#2 == "GET" || method#2 == "POST")
         {
            serviceDelegate = new HTTPServiceDelegate();
         }
         else
         {
            serviceDelegate = new URLLoaderDelegate();
         }
         serviceDelegate.headers = headers#2;
         serviceDelegate.method = method#2;
         serviceDelegate.params = params#2;
         serviceDelegate.resultFormat = resultFormat#2;
         serviceDelegate.url = url#2;
         serviceDelegate.addEventListener("result",handleResult);
         serviceDelegate.addEventListener("fault",handleFault);
         serviceDelegate.send();
      }
      
      protected function handleResult(param1:Event) : void
      {
         var _loc2_:* = null;
         if(param1 is ResultEvent)
         {
            _loc2_ = ResultEvent(param1).result;
         }
         result(_loc2_);
      }
      
      protected function handleFault(param1:Event) : void
      {
         var _loc2_:* = null;
         if(param1 is FaultEvent)
         {
            _loc2_ = FaultEvent(param1).fault.faultString;
         }
         fault(_loc2_);
      }
      
      public function getResult() : Object
      {
         if(serviceDelegate)
         {
            return serviceDelegate.lastResult;
         }
         return null;
      }
      
      public function getXML() : XML
      {
         var _loc1_:* = null;
         if(resultFormat#2 == "xml")
         {
            _loc1_ = getResult();
            if(!_loc1_)
            {
               return null;
            }
            if(_loc1_ is XML)
            {
               return _loc1_ as XML;
            }
            return new XML(_loc1_.toString());
         }
         return null;
      }
      
      public function getJSON() : Object
      {
         if(resultFormat#2 == "json")
         {
            try
            {
               trace("HttpOperation#getJSON : " + getResult().toString());
               return JSON.parse(getResult().toString());
            }
            catch(error:Error)
            {
               trace("HTTPOperation: Error Parsing JSON");
            }
         }
         return null;
      }
   }
}
