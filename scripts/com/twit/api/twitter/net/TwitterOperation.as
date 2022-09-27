package com.twit.api.twitter.net
{
   import com.adobe.protocols.dict.events.ErrorEvent;
   import com.twit.api.HttpOperation;
   import com.twit.api.twitter.TwitterAPI;
   import com.twit.api.twitter.data.TwitterUser;
   import com.twit.api.twitter.events.TwitterEvent;
   import com.twit.api.twitter.interfaces.ITwitterOperation;
   import com.twit.api.twitter.twitter_internal;
   import flash.events.Event;
   import flash.net.URLRequestHeader;
   import mx.events.PropertyChangeEvent;
   import mx.rpc.Fault;
   import mx.rpc.events.FaultEvent;
   
   use namespace twitter_internal;
   
   public class TwitterOperation extends HttpOperation implements ITwitterOperation
   {
       
      
      protected var twitterAPI:TwitterAPI;
      
      private var data#2292:Object;
      
      protected var _requiresAuthentication:Boolean = true;
      
      protected var _apiRateLimited:Boolean = true;
      
      public function TwitterOperation(param1:String, param2:Boolean = true, param3:Object = null, param4:String = "xml")
      {
         super(param1,param3,param4);
         this._requiresAuthentication = param2;
      }
      
      protected static function convertToParameters(param1:Object) : Object
      {
         var _loc2_:Object = {};
         for(var _loc3_ in param1)
         {
            trace("Parameter: " + _loc3_ + " Value: " + param1[_loc3_]);
            if(param1[_loc3_] is String && param1[_loc3_] != null || param1[_loc3_] is int && param1[_loc3_] != -1 || param1[_loc3_] is Boolean)
            {
               _loc2_[_loc3_] = param1[_loc3_];
            }
         }
         return _loc2_;
      }
      
      protected static function getScreenName(param1:Object) : String
      {
         var _loc2_:* = null;
         if(param1 is TwitterUser)
         {
            _loc2_ = TwitterUser(param1).screenName#2;
         }
         else
         {
            _loc2_ = param1.toString();
         }
         return _loc2_;
      }
      
      [Bindable]
      public function get data#2() : Object
      {
         return this.data#2292;
      }
      
      public function set data#2(param1:Object) : void
      {
         var _loc2_:* = this.data#2292;
         if(_loc2_ !== param1)
         {
            this.data#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"data",_loc2_,param1));
            }
         }
      }
      
      public function get requiresAuthentication() : Boolean
      {
         return _requiresAuthentication;
      }
      
      public function get apiRateLimited() : Boolean
      {
         return _apiRateLimited;
      }
      
      override public function execute() : void
      {
         initOperation();
         super.execute();
      }
      
      override public function result(param1:Object) : void
      {
         dispatchEvent(new TwitterEvent("complete",param1,true));
      }
      
      override public function fault(param1:Object) : void
      {
         var _loc2_:* = null;
         if(param1 is Fault)
         {
            _loc2_ = Fault(param1).faultString;
         }
         else if(param1)
         {
            _loc2_ = param1.toString();
         }
         dispatchEvent(new TwitterEvent("complete",_loc2_,false));
      }
      
      public function setTwitterAPI(param1:TwitterAPI) : void
      {
         twitterAPI = param1;
      }
      
      protected function initOperation() : void
      {
         var _loc4_:* = null;
         var _loc2_:* = null;
         var _loc9_:* = null;
         var _loc8_:* = null;
         var _loc5_:int = 0;
         var _loc7_:* = null;
         var _loc1_:* = null;
         var _loc6_:* = null;
         var _loc10_:* = null;
         var _loc3_:* = null;
         if(requiresAuthentication && twitterAPI.connection != null)
         {
            _loc4_ = params#2;
            _loc2_ = url#2;
            if(params#2 == null && _loc2_.indexOf("?") != -1)
            {
               _loc4_ = {};
               _loc2_ = (_loc9_ = url#2.split("?"))[0].toString();
               if(_loc9_.length > 1)
               {
                  _loc8_ = _loc9_[1].toString().split("&");
                  _loc5_ = 0;
                  while(_loc5_ < _loc8_.length)
                  {
                     _loc7_ = _loc8_[_loc5_].toString().split("=");
                     _loc4_[_loc7_[0].toString()] = _loc7_[1].toString();
                     _loc5_++;
                  }
               }
            }
            _loc1_ = {};
            for(var _loc11_ in _loc4_)
            {
               _loc1_[_loc11_] = _loc4_[_loc11_];
            }
            if(_loc6_ = twitterAPI.connection.createOAuthHeader(method#2,_loc2_,_loc1_))
            {
               _loc10_ = _loc6_.name#2;
               _loc3_ = _loc6_.value;
               trace("TwitterOperation hName : " + _loc10_ + " , hValue " + _loc3_);
               headers#2[_loc10_] = _loc3_;
            }
         }
      }
      
      protected function set parameters(param1:Object) : void
      {
         params#2 = convertToParameters(param1);
      }
      
      protected function get parameters() : Object
      {
         return params#2;
      }
      
      override protected function handleResult(param1:Event) : void
      {
         var _loc2_:* = null;
         if(resultFormat#2 == "xml")
         {
            _loc2_ = getXML();
            if(_loc2_.name() == "hash" && _loc2_.contains("error"))
            {
               fault(_loc2_.error);
            }
            else
            {
               result(data#2);
            }
         }
         else if(resultFormat#2 == "json")
         {
            result(data#2);
         }
      }
      
      override protected function handleFault(param1:Event) : void
      {
         var _loc3_:* = null;
         var _loc2_:* = null;
         if(param1 is ErrorEvent)
         {
            fault(ErrorEvent(param1).message);
         }
         else if(param1 is FaultEvent)
         {
            _loc3_ = "Check your Internet connection";
            if(FaultEvent(param1).fault.rootCause)
            {
               try
               {
                  _loc2_ = new XML(FaultEvent(param1).fault.rootCause);
                  if(_loc2_.name() == "hash" && _loc2_.error)
                  {
                     _loc3_ = _loc2_.error.toString();
                  }
                  if(_loc2_.name() == "errors" && _loc2_.error)
                  {
                     _loc3_ = _loc2_.error.toString();
                  }
               }
               catch(error:Error)
               {
               }
            }
            fault(_loc3_ + param1.toString());
         }
         else
         {
            fault("Check your Internet connection : " + param1.toString());
         }
      }
   }
}
