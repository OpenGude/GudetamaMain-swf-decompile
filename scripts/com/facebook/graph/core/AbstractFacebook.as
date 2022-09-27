package com.facebook.graph.core
{
   import com.facebook.graph.data.Batch;
   import com.facebook.graph.data.FQLMultiQuery;
   import com.facebook.graph.data.FacebookAuthResponse;
   import com.facebook.graph.data.FacebookSession;
   import com.facebook.graph.net.FacebookBatchRequest;
   import com.facebook.graph.net.FacebookRequest;
   import com.facebook.graph.utils.FQLMultiQueryParser;
   import com.facebook.graph.utils.IResultParser;
   import flash.utils.Dictionary;
   
   public class AbstractFacebook
   {
       
      
      protected var session:FacebookSession;
      
      protected var authResponse:FacebookAuthResponse;
      
      protected var oauth2:Boolean;
      
      protected var openRequests:Dictionary;
      
      protected var resultHash:Dictionary;
      
      protected var locale:String;
      
      protected var parserHash:Dictionary;
      
      public function AbstractFacebook()
      {
         super();
         openRequests = new Dictionary();
         resultHash = new Dictionary(true);
         parserHash = new Dictionary();
      }
      
      protected function get accessToken() : String
      {
         var _loc1_:* = null;
         if(oauth2 && authResponse != null || session != null)
         {
            if(oauth2)
            {
               _loc1_ = authResponse.accessToken;
            }
            else
            {
               try
               {
                  _loc1_ = session.accessToken;
               }
               catch(e:*)
               {
                  _loc1_ = null;
               }
            }
         }
         return _loc1_;
      }
      
      protected function api(param1:String, param2:Function = null, param3:* = null, param4:String = "GET") : void
      {
         param1 = param1.indexOf("/") != 0 ? "/" + param1 : param1;
         if(accessToken)
         {
            if(param3 == null)
            {
               param3 = {};
            }
            if(param3.access_token == null)
            {
               param3.access_token = accessToken;
            }
         }
         var _loc5_:FacebookRequest = new FacebookRequest();
         if(locale)
         {
            param3.locale = locale;
         }
         openRequests[_loc5_] = param2;
         _loc5_.call(FacebookURLDefaults.GRAPH_URL + param1,param4,handleRequestLoad,param3);
      }
      
      protected function uploadVideo(param1:String, param2:Function = null, param3:* = null) : void
      {
         param1 = param1.indexOf("/") != 0 ? "/" + param1 : param1;
         if(accessToken)
         {
            if(param3 == null)
            {
               param3 = {};
            }
            if(param3.access_token == null)
            {
               param3.access_token = accessToken;
            }
         }
         var _loc4_:FacebookRequest = new FacebookRequest();
         if(locale)
         {
            param3.locale = locale;
         }
         openRequests[_loc4_] = param2;
         _loc4_.call(FacebookURLDefaults.VIDEO_URL + param1,"POST",handleRequestLoad,param3);
      }
      
      protected function pagingCall(param1:String, param2:Function) : FacebookRequest
      {
         var _loc3_:FacebookRequest = new FacebookRequest();
         openRequests[_loc3_] = param2;
         _loc3_.callURL(handleRequestLoad,param1,locale);
         return _loc3_;
      }
      
      protected function getRawResult(param1:Object) : Object
      {
         return resultHash[param1];
      }
      
      protected function nextPage(param1:Object, param2:Function = null) : FacebookRequest
      {
         var _loc4_:FacebookRequest = null;
         var _loc3_:Object = getRawResult(param1);
         if(_loc3_ && _loc3_.paging && _loc3_.paging.next)
         {
            _loc4_ = pagingCall(_loc3_.paging.next,param2);
         }
         else if(param2 != null)
         {
            param2(null,"no page");
         }
         return _loc4_;
      }
      
      protected function previousPage(param1:Object, param2:Function = null) : FacebookRequest
      {
         var _loc4_:FacebookRequest = null;
         var _loc3_:Object = getRawResult(param1);
         if(_loc3_ && _loc3_.paging && _loc3_.paging.previous)
         {
            _loc4_ = pagingCall(_loc3_.paging.previous,param2);
         }
         else if(param2 != null)
         {
            param2(null,"no page");
         }
         return _loc4_;
      }
      
      protected function handleRequestLoad(param1:FacebookRequest) : void
      {
         var _loc3_:* = null;
         var _loc2_:* = null;
         var _loc4_:Function;
         if((_loc4_ = openRequests[param1]) === null)
         {
            delete openRequests[param1];
         }
         if(param1.success)
         {
            _loc3_ = "data" in param1.data#2 ? param1.data#2.data : param1.data#2;
            resultHash[_loc3_] = param1.data#2;
            if(_loc3_.hasOwnProperty("error_code"))
            {
               _loc4_(null,_loc3_);
            }
            else
            {
               if(parserHash[param1] is IResultParser)
               {
                  _loc2_ = parserHash[param1] as IResultParser;
                  _loc3_ = _loc2_.parse(_loc3_);
                  parserHash[param1] = null;
                  delete parserHash[param1];
               }
               _loc4_(_loc3_,null);
            }
         }
         else
         {
            _loc4_(null,param1.data#2);
         }
         delete openRequests[param1];
      }
      
      protected function callRestAPI(param1:String, param2:Function = null, param3:* = null, param4:String = "GET") : void
      {
         var _loc5_:* = null;
         if(param3 == null)
         {
            param3 = {};
         }
         param3.format = "json";
         if(accessToken)
         {
            param3.access_token = accessToken;
         }
         if(locale)
         {
            param3.locale = locale;
         }
         var _loc6_:FacebookRequest = new FacebookRequest();
         openRequests[_loc6_] = param2;
         if(parserHash[param3["queries"]] is IResultParser)
         {
            _loc5_ = parserHash[param3["queries"]] as IResultParser;
            parserHash[param3["queries"]] = null;
            delete parserHash[param3["queries"]];
            parserHash[_loc6_] = _loc5_;
         }
         _loc6_.call(FacebookURLDefaults.API_URL + "/method/" + param1,param4,handleRequestLoad,param3);
      }
      
      protected function fqlQuery(param1:String, param2:Function = null, param3:Object = null) : void
      {
         for(var _loc4_ in param3)
         {
            param1 = param1.replace(new RegExp("\\{" + _loc4_ + "\\}","g"),param3[_loc4_]);
         }
         callRestAPI("fql.query",param2,{"query":param1});
      }
      
      protected function fqlMultiQuery(param1:FQLMultiQuery, param2:Function = null, param3:IResultParser = null) : void
      {
         parserHash[param1.toString()] = param3 != null ? param3 : new FQLMultiQueryParser();
         callRestAPI("fql.multiquery",param2,{"queries":param1.toString()});
      }
      
      protected function batchRequest(param1:Batch, param2:Function = null) : void
      {
         var _loc3_:* = null;
         if(accessToken)
         {
            _loc3_ = new FacebookBatchRequest(param1,param2);
            resultHash[_loc3_] = true;
            _loc3_.call(accessToken);
         }
      }
      
      protected function deleteObject(param1:String, param2:Function = null) : void
      {
         var _loc3_:Object = {"method":"delete"};
         api(param1,param2,_loc3_,"POST");
      }
      
      protected function getImageUrl(param1:String, param2:String = null) : String
      {
         return FacebookURLDefaults.GRAPH_URL + "/" + param1 + "/picture" + (param2 != null ? "?type=" + param2 : "");
      }
   }
}
