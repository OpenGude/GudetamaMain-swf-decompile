package com.adobe.protocols.dict
{
   public class Database
   {
       
      
      private var _name:String;
      
      private var _description:String;
      
      public function Database(param1:String, param2:String)
      {
         super();
         this._name = param1;
         this._description = param2;
      }
      
      public function set name#2(param1:String) : void
      {
         this._name = param1;
      }
      
      public function set description#2(param1:String) : void
      {
         this._description = param1;
      }
      
      public function get name#2() : String
      {
         return this._name;
      }
      
      public function get description#2() : String
      {
         return this._description;
      }
   }
}
