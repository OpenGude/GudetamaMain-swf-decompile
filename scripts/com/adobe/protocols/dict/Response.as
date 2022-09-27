package com.adobe.protocols.dict
{
   public class Response
   {
       
      
      private var _body:String;
      
      private var _code:uint;
      
      private var _headerText:String;
      
      public function Response()
      {
         super();
      }
      
      public function set body(param1:String) : void
      {
         this._body = param1;
      }
      
      public function set code(param1:uint) : void
      {
         this._code = param1;
      }
      
      public function get code() : uint
      {
         return this._code;
      }
      
      public function get body() : String
      {
         return this._body;
      }
      
      public function set headerText(param1:String) : void
      {
         this._headerText = param1;
      }
      
      public function get headerText() : String
      {
         return this._headerText;
      }
   }
}
