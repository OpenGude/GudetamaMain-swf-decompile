package com.facebook.graph.net
{
   import flash.events.DataEvent;
   import flash.events.ErrorEvent;
   import flash.net.FileReference;
   import flash.net.URLRequest;
   
   public class FacebookRequest extends AbstractFacebookRequest
   {
       
      
      protected var fileReference:FileReference;
      
      public function FacebookRequest()
      {
         super();
      }
      
      public function call(param1:String, param2:String = "GET", param3:Function = null, param4:* = null) : void
      {
         _url = param1;
         _requestMethod = param2;
         _callback = param3;
         var _loc5_:* = param1;
         urlRequest = new URLRequest(_loc5_);
         urlRequest.method#2 = _requestMethod;
         if(param4 == null)
         {
            loadURLLoader();
            return;
         }
         var _loc6_:Object;
         if((_loc6_ = extractFileData(param4)) == null)
         {
            urlRequest.data#2 = objectToURLVariables(param4);
            loadURLLoader();
            return;
         }
         if(_loc6_ is FileReference)
         {
            urlRequest.data#2 = objectToURLVariables(param4);
            urlRequest.method#2 = "POST";
            fileReference = _loc6_ as FileReference;
            fileReference.addEventListener("uploadCompleteData",handleFileReferenceData,false,0,true);
            fileReference.addEventListener("ioError",handelFileReferenceError,false,0,false);
            fileReference.addEventListener("securityError",handelFileReferenceError,false,0,false);
            fileReference.upload(urlRequest);
            return;
         }
         urlRequest.data#2 = createUploadFileRequest(_loc6_,param4).getPostData();
         urlRequest.method#2 = "POST";
         loadURLLoader();
      }
      
      override public function close() : void
      {
         super.close();
         if(fileReference != null)
         {
            fileReference.removeEventListener("uploadCompleteData",handleFileReferenceData);
            fileReference.removeEventListener("ioError",handelFileReferenceError);
            fileReference.removeEventListener("securityError",handelFileReferenceError);
            try
            {
               fileReference.cancel();
            }
            catch(e:*)
            {
            }
            fileReference = null;
         }
      }
      
      protected function handleFileReferenceData(param1:DataEvent) : void
      {
         handleDataLoad(param1.data#2);
      }
      
      protected function handelFileReferenceError(param1:ErrorEvent) : void
      {
         _success = false;
         _data = param1;
         dispatchComplete();
      }
   }
}
