package com.twit.api.twitter.data.collections
{
   import com.twit.api.twitter.interfaces.IPagingCollection;
   import mx.collections.ArrayCollection;
   
   [Bindable]
   public class UsersCollection extends ArrayCollection implements IPagingCollection
   {
       
      
      private var _nextCursor:String;
      
      private var _previousCursor:String;
      
      public function UsersCollection(param1:Array = null)
      {
         super(param1);
      }
      
      public function get previousCursor() : String
      {
         return _previousCursor;
      }
      
      public function set previousCursor(param1:String) : void
      {
         _previousCursor = param1;
      }
      
      public function get nextCursor() : String
      {
         return _nextCursor;
      }
      
      public function set nextCursor(param1:String) : void
      {
         _nextCursor = param1;
      }
   }
}
