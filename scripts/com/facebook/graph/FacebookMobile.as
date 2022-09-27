package com.facebook.graph
{
   import com.facebook.graph.core.AbstractFacebook;
   import com.facebook.graph.data.Batch;
   import com.facebook.graph.data.FQLMultiQuery;
   import com.facebook.graph.data.FacebookSession;
   import com.facebook.graph.net.FacebookRequest;
   import com.facebook.graph.utils.FacebookDataUtils;
   import com.facebook.graph.utils.IResultParser;
   import com.facebook.graph.windows.DialogWindow;
   import com.facebook.graph.windows.MobileLoginWindow;
   import flash.display.Stage;
   import flash.media.StageWebView;
   import flash.net.SharedObject;
   
   public class FacebookMobile extends AbstractFacebook
   {
      
      protected static const SO_NAME:String = "com.facebook.graph.FacebookMobile";
      
      protected static var _instance:FacebookMobile;
      
      protected static var _canInit:Boolean = false;
       
      
      protected var _manageSession:Boolean = false;
      
      protected var loginWindow:MobileLoginWindow;
      
      protected var dialogWindow:DialogWindow;
      
      protected var dialogCallback:Function;
      
      protected var applicationId:String;
      
      protected var loginCallback:Function;
      
      protected var logoutCallback:Function;
      
      protected var initCallback:Function;
      
      protected var webView:StageWebView;
      
      protected var stageRef:Stage;
      
      public function FacebookMobile()
      {
         super();
         if(_canInit == false)
         {
            throw new Error("FacebookMobile is an singleton and cannot be instantiated.");
         }
      }
      
      public static function init(param1:String, param2:Function, param3:String = null) : void
      {
         getInstance().init(param1,param2,param3);
      }
      
      public static function set locale(param1:String) : void
      {
         getInstance().locale = param1;
      }
      
      public static function login(param1:Function, param2:Function, param3:Stage, param4:Array, param5:StageWebView = null, param6:String = "touch") : void
      {
         getInstance().login(param1,param2,param3,param4,param5,param6);
      }
      
      public static function clear() : void
      {
         getInstance().clear();
      }
      
      public static function set manageSession(param1:Boolean) : void
      {
         getInstance().manageSession = param1;
      }
      
      public static function logout(param1:Function = null, param2:String = null) : void
      {
         getInstance().logout(param1,param2);
      }
      
      public static function requestExtendedPermissions(param1:Function, param2:Function, param3:StageWebView, ... rest) : void
      {
         getInstance().requestExtendedPermissions(param1,param2,param3,rest);
      }
      
      public static function api(param1:String, param2:Function, param3:* = null, param4:String = "GET") : void
      {
         getInstance().api(param1,param2,param3,param4);
      }
      
      public static function dialog(param1:String, param2:Function, param3:Stage, param4:StageWebView, param5:* = null) : void
      {
         getInstance().dialog(param1,param2,param3,param4,param5);
      }
      
      public static function getRawResult(param1:Object) : Object
      {
         return getInstance().getRawResult(param1);
      }
      
      public static function hasNext(param1:Object) : Boolean
      {
         var _loc2_:Object = getInstance().getRawResult(param1);
         if(!_loc2_.paging)
         {
            return false;
         }
         return _loc2_.paging.next != null;
      }
      
      public static function hasPrevious(param1:Object) : Boolean
      {
         var _loc2_:Object = getInstance().getRawResult(param1);
         if(!_loc2_.paging)
         {
            return false;
         }
         return _loc2_.paging.previous != null;
      }
      
      public static function nextPage(param1:Object, param2:Function) : FacebookRequest
      {
         return getInstance().nextPage(param1,param2);
      }
      
      public static function previousPage(param1:Object, param2:Function) : FacebookRequest
      {
         return getInstance().previousPage(param1,param2);
      }
      
      public static function postData(param1:String, param2:Function, param3:* = null) : void
      {
         api(param1,param2,param3,"POST");
      }
      
      public static function uploadVideo(param1:String, param2:Function = null, param3:* = null) : void
      {
         getInstance().uploadVideo(param1,param2,param3);
      }
      
      public static function deleteObject(param1:String, param2:Function) : void
      {
         getInstance().deleteObject(param1,param2);
      }
      
      public static function fqlQuery(param1:String, param2:Function = null, param3:Object = null) : void
      {
         getInstance().fqlQuery(param1,param2,param3);
      }
      
      public static function fqlMultiQuery(param1:FQLMultiQuery, param2:Function = null, param3:IResultParser = null) : void
      {
         getInstance().fqlMultiQuery(param1,param2,param3);
      }
      
      public static function batchRequest(param1:Batch, param2:Function = null) : void
      {
         getInstance().batchRequest(param1,param2);
      }
      
      public static function callRestAPI(param1:String, param2:Function = null, param3:* = null, param4:String = "GET") : void
      {
         getInstance().callRestAPI(param1,param2,param3,param4);
      }
      
      public static function getImageUrl(param1:String, param2:String = null) : String
      {
         return getInstance().getImageUrl(param1,param2);
      }
      
      public static function getSession() : FacebookSession
      {
         return getInstance().session;
      }
      
      public static function get accKey() : String
      {
         return getInstance().accessToken;
      }
      
      protected static function getInstance() : FacebookMobile
      {
         if(_instance == null)
         {
            _canInit = true;
            _instance = new FacebookMobile();
            _canInit = false;
         }
         return _instance;
      }
      
      protected function dialog(param1:String, param2:Function, param3:Stage, param4:StageWebView, param5:* = null) : void
      {
         dialogCallback = param2;
         stageRef = param3;
         webView = param4;
         webView.stage = param3;
         webView.assignFocus();
         dialogWindow = new DialogWindow(handleDialog);
         dialogWindow.open(param1,applicationId,webView,param5);
      }
      
      protected function init(param1:String, param2:Function, param3:String = null) : void
      {
         var _loc4_:* = null;
         initCallback = param2;
         this.applicationId = param1;
         if(param3 != null)
         {
            session = new FacebookSession();
            session.accessToken = param3;
         }
         else if(_manageSession)
         {
            session = new FacebookSession();
            _loc4_ = SharedObject.getLocal("com.facebook.graph.FacebookMobile");
            session.accessToken = _loc4_.data#2.accessToken;
            session.expireDate = _loc4_.data#2.expireDate;
         }
         verifyAccessToken();
      }
      
      protected function verifyAccessToken() : void
      {
         api("/me",handleUserLoad);
      }
      
      protected function handleUserLoad(param1:Object, param2:Object) : void
      {
         if(param1)
         {
            session.uid = param1.id;
            session.user#2 = param1;
            if(loginCallback != null)
            {
               loginCallback(session,null);
            }
            if(initCallback != null)
            {
               initCallback(session,null);
               initCallback = null;
            }
         }
         else
         {
            if(loginCallback != null)
            {
               loginCallback(null,param2);
            }
            if(initCallback != null)
            {
               initCallback(null,param2);
               initCallback = null;
            }
            session = null;
         }
      }
      
      protected function login(param1:Function, param2:Function, param3:Stage, param4:Array, param5:StageWebView = null, param6:String = "touch") : void
      {
         this.loginCallback = param1;
         this.stageRef = param3;
         this.webView = param5;
         this.webView.assignFocus();
         if(applicationId == null)
         {
            throw new Error("FacebookMobile.init() needs to be called first.");
         }
         loginWindow = new MobileLoginWindow(handleLogin,param2);
         loginWindow.open(this.applicationId,this.webView,FacebookDataUtils.flattenArray(param4),param6);
      }
      
      protected function clear() : void
      {
         this.loginCallback = null;
      }
      
      protected function set manageSession(param1:Boolean) : void
      {
         _manageSession = param1;
      }
      
      protected function requestExtendedPermissions(param1:Function, param2:Function, param3:StageWebView, ... rest) : void
      {
         if(applicationId == null)
         {
            throw new Error("User must be logged in before asking for extended permissions.");
         }
         login(param1,param2,stageRef,rest,param3);
      }
      
      protected function handleLogin(param1:Object, param2:Object) : void
      {
         var _loc5_:* = null;
         loginWindow.loginCallback = null;
         if(param2)
         {
            loginCallback(null,param2);
            return;
         }
         if(!param1)
         {
            loginCallback(null,{"reason":"User Cancelled"});
            return;
         }
         session = new FacebookSession();
         session.accessToken = param1.access_token;
         var _loc3_:* = new Date();
         var _loc4_:* = Math.ceil(_loc3_.getTime() / 1000);
         session.expireDate = param1.expires_in == 0 ? null : FacebookDataUtils.stringToDate(_loc4_ + parseInt(param1.expires_in) + "");
         if(_manageSession)
         {
            (_loc5_ = SharedObject.getLocal("com.facebook.graph.FacebookMobile")).data#2.accessToken = session.accessToken;
            _loc5_.data#2.expireDate = session.expireDate;
            _loc5_.flush();
         }
         verifyAccessToken();
      }
      
      protected function handleDialog(param1:Object, param2:Object) : void
      {
         dialogWindow.callback = null;
         dialogCallback(param1,param2);
      }
      
      protected function logout(param1:Function = null, param2:String = null) : void
      {
         this.logoutCallback = param1;
         var _loc3_:Object = {};
         _loc3_.confirm = 1;
         _loc3_.next = param2;
         _loc3_.access_token = accessToken;
         var _loc5_:FacebookRequest = new FacebookRequest();
         openRequests[_loc5_] = handleLogout;
         _loc5_.call("https://m.facebook.com/logout.php","GET",handleRequestLoad,_loc3_);
         var _loc4_:SharedObject;
         (_loc4_ = SharedObject.getLocal("com.facebook.graph.FacebookMobile")).clear();
         _loc4_.flush();
         session = null;
      }
      
      protected function handleLogout(param1:Object, param2:Object) : void
      {
         if(logoutCallback != null)
         {
            logoutCallback(true);
            logoutCallback = null;
         }
      }
      
      protected function createWebView() : StageWebView
      {
         if(this.webView)
         {
            try
            {
               this.webView.dispose();
            }
            catch(e:*)
            {
            }
         }
         this.webView = new StageWebView();
         this.webView.stage = this.stageRef;
         return webView;
      }
   }
}
