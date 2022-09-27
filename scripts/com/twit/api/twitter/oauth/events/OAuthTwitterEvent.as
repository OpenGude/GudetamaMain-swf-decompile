package com.twit.api.twitter.oauth.events
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import mx.events.PropertyChangeEvent;
   import starling.events.Event;
   
   public class OAuthTwitterEvent extends starling.events.Event implements IEventDispatcher
   {
      
      public static const REQUEST_TOKEN_ERROR:String = "requestTokenError";
      
      public static const REQUEST_TOKEN_RECEIVED:String = "requestTokenReceived";
      
      public static const ACCESS_TOKEN_ERROR:String = "accessTokenError";
      
      public static const AUTHORIZED:String = "authorized";
       
      
      private var outhdata#2292:Object;
      
      private var _bindingEventDispatcher:EventDispatcher;
      
      public function OAuthTwitterEvent(param1:String, param2:Object = null, param3:Boolean = false, param4:Boolean = false)
      {
         this._bindingEventDispatcher = new EventDispatcher(this);
         super(param1,param3,param4);
         outhdata#2422 = param2;
      }
      
      [Bindable]
      private function get outhdata#2422() : Object
      {
         return this.outhdata#2292;
      }
      
      private function set outhdata#2422(param1:Object) : void
      {
         var _loc2_:* = this.outhdata#2292;
         if(_loc2_ !== param1)
         {
            this.outhdata#2292 = param1;
            if(this.hasEventListener("propertyChange"))
            {
               this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"outhdata",_loc2_,param1));
            }
         }
      }
      
      public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         this._bindingEventDispatcher.addEventListener(param1,param2,param3,param4,param5);
      }
      
      public function dispatchEvent(param1:flash.events.Event) : Boolean
      {
         return this._bindingEventDispatcher.dispatchEvent(param1);
      }
      
      public function hasEventListener(param1:String) : Boolean
      {
         return this._bindingEventDispatcher.hasEventListener(param1);
      }
      
      public function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         this._bindingEventDispatcher.removeEventListener(param1,param2,param3);
      }
      
      public function willTrigger(param1:String) : Boolean
      {
         return this._bindingEventDispatcher.willTrigger(param1);
      }
   }
}
