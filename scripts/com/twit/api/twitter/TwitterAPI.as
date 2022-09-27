package com.twit.api.twitter
{
   import com.twit.api.twitter.interfaces.ITwitterOperation;
   import com.twit.api.twitter.oauth.OAuthTwitterConnection;
   import com.twit.api.twitter.utils.AsyncQueue;
   import flash.events.EventDispatcher;
   
   public class TwitterAPI extends EventDispatcher
   {
      
      public static const POST_TYPE_NORMAL:String = "normal";
      
      public static const POST_TYPE_ASYNC:String = "async";
      
      public static const POST_TYPE_ASYNC_STATIC:String = "asyncStatic";
      
      public static const PRIORITY_LOWEST:int = 1;
      
      public static const PRIORITY_LOW:int = 3;
      
      public static const PRIORITY_NORMAL:int = 5;
      
      public static const PRIORITY_HIGH:int = 7;
      
      public static const PRIORITY_HIGHEST:int = 9;
      
      protected static var staticAsyncQueue:AsyncQueue = new AsyncQueue();
       
      
      protected var _connection:OAuthTwitterConnection;
      
      protected var asyncQueue:AsyncQueue;
      
      public function TwitterAPI()
      {
         _connection = new OAuthTwitterConnection();
         asyncQueue = new AsyncQueue();
         super();
      }
      
      public function get connection() : OAuthTwitterConnection
      {
         return _connection;
      }
      
      public function post(param1:ITwitterOperation, param2:String = "normal", param3:int = 5) : ITwitterOperation
      {
         switch(param2)
         {
            case "async":
               return postAsync(param1,param3);
            case "asyncStatic":
               return postAsyncStatic(param1,param3);
            case "normal":
         }
         return postSync(param1);
      }
      
      protected function postAsyncStatic(param1:ITwitterOperation, param2:int = 5) : ITwitterOperation
      {
         if(param1.requiresAuthentication)
         {
            if(!(connection.consumer && connection.accessToken))
            {
               throw new Error("Cannot post an operation; you need to be authenticated.");
            }
            param1.setTwitterAPI(this);
            staticAsyncQueue.executeOperation(param1,param2);
         }
         else
         {
            staticAsyncQueue.executeOperation(param1,param2);
         }
         return param1;
      }
      
      protected function postAsync(param1:ITwitterOperation, param2:int = 5) : ITwitterOperation
      {
         if(param1.requiresAuthentication)
         {
            if(!(connection.consumer && connection.accessToken))
            {
               throw new Error("Cannot post an operation; you need to be authenticated.");
            }
            param1.setTwitterAPI(this);
            asyncQueue.executeOperation(param1,param2);
         }
         else
         {
            asyncQueue.executeOperation(param1,param2);
         }
         return param1;
      }
      
      protected function postSync(param1:ITwitterOperation) : ITwitterOperation
      {
         trace("TwitterAPI#postSync : " + param1.requiresAuthentication);
         if(param1.requiresAuthentication)
         {
            if(!(connection.consumer && connection.accessToken))
            {
               throw new Error("Cannot post an operation; you need to be authenticated.");
            }
            param1.setTwitterAPI(this);
            param1.execute();
         }
         else
         {
            param1.execute();
         }
         return param1;
      }
   }
}
