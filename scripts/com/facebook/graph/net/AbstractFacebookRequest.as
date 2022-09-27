package com.facebook.graph.net
{
   import com.adobe.images.PNGEncoder;
   import com.facebook.graph.utils.PostRequest;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.FileReference;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLVariables;
   import flash.utils.ByteArray;
   
   public class AbstractFacebookRequest
   {
       
      
      protected var urlLoader:URLLoader;
      
      protected var urlRequest:URLRequest;
      
      protected var _rawResult:String;
      
      protected var _data:Object;
      
      protected var _success:Boolean;
      
      protected var _url:String;
      
      protected var _requestMethod:String;
      
      protected var _callback:Function;
      
      public function AbstractFacebookRequest()
      {
         super();
      }
      
      public function get rawResult() : String
      {
         return _rawResult;
      }
      
      public function get success() : Boolean
      {
         return _success;
      }
      
      public function get data#2() : Object
      {
         return _data;
      }
      
      public function callURL(param1:Function, param2:String = "", param3:String = null) : void
      {
         var _loc4_:* = null;
         _callback = param1;
         urlRequest = new URLRequest(!!param2.length ? param2 : _url);
         if(param3)
         {
            (_loc4_ = new URLVariables()).locale = param3;
            urlRequest.data#2 = _loc4_;
         }
         loadURLLoader();
      }
      
      public function set successCallback(param1:Function) : void
      {
         _callback = param1;
      }
      
      protected function isValueFile(param1:Object) : Boolean
      {
         return param1 is FileReference || param1 is Bitmap || param1 is BitmapData || param1 is ByteArray;
      }
      
      protected function objectToURLVariables(param1:Object) : URLVariables
      {
         var _loc2_:URLVariables = new URLVariables();
         if(param1 == null)
         {
            return _loc2_;
         }
         for(var _loc3_ in param1)
         {
            _loc2_[_loc3_] = param1[_loc3_];
         }
         return _loc2_;
      }
      
      public function close() : void
      {
         if(urlLoader != null)
         {
            urlLoader.removeEventListener("complete",handleURLLoaderComplete);
            urlLoader.removeEventListener("ioError",handleURLLoaderIOError);
            urlLoader.removeEventListener("securityError",handleURLLoaderSecurityError);
            try
            {
               urlLoader.close();
            }
            catch(e:*)
            {
            }
            urlLoader = null;
         }
      }
      
      protected function loadURLLoader() : void
      {
         urlLoader = new URLLoader();
         urlLoader.addEventListener("complete",handleURLLoaderComplete,false,0,false);
         urlLoader.addEventListener("ioError",handleURLLoaderIOError,false,0,true);
         urlLoader.addEventListener("securityError",handleURLLoaderSecurityError,false,0,true);
         urlLoader.load(urlRequest);
      }
      
      protected function handleURLLoaderComplete(param1:Event) : void
      {
         handleDataLoad(urlLoader.data#2);
      }
      
      protected function handleDataLoad(param1:Object, param2:Boolean = true) : void
      {
         _rawResult = param1 as String;
         _success = true;
         try
         {
            _data = JSON.parse(_rawResult);
         }
         catch(e:*)
         {
            _data = _rawResult;
            _success = false;
         }
         handleDataReady();
         if(param2)
         {
            dispatchComplete();
         }
      }
      
      protected function handleDataReady() : void
      {
      }
      
      protected function dispatchComplete() : void
      {
         if(_callback != null)
         {
            _callback(this);
         }
         close();
      }
      
      protected function handleURLLoaderIOError(param1:IOErrorEvent) : void
      {
         _success = false;
         _rawResult = (param1.target as URLLoader).data#2;
         if(_rawResult != "")
         {
            try
            {
               _data = JSON.parse(_rawResult);
            }
            catch(e:*)
            {
               _data = {
                  "type":"Exception",
                  "message":_rawResult
               };
            }
         }
         else
         {
            _data = param1;
         }
         dispatchComplete();
      }
      
      protected function handleURLLoaderSecurityError(param1:SecurityErrorEvent) : void
      {
         _success = false;
         _rawResult = (param1.target as URLLoader).data#2;
         try
         {
            _data = JSON.parse((param1.target as URLLoader).data#2);
         }
         catch(e:*)
         {
            _data = param1;
         }
         dispatchComplete();
      }
      
      protected function extractFileData(param1:Object) : Object
      {
         var _loc2_:* = null;
         if(param1 == null)
         {
            return null;
         }
         if(isValueFile(param1))
         {
            _loc2_ = param1;
         }
         else if(param1 != null)
         {
            for(var _loc3_ in param1)
            {
               if(isValueFile(param1[_loc3_]))
               {
                  _loc2_ = param1[_loc3_];
                  delete param1[_loc3_];
                  break;
               }
            }
         }
         return _loc2_;
      }
      
      protected function createUploadFileRequest(param1:Object, param2:Object = null) : PostRequest
      {
         var _loc5_:* = null;
         var _loc3_:PostRequest = new PostRequest();
         if(param2)
         {
            for(var _loc4_ in param2)
            {
               _loc3_.writePostData(_loc4_,param2[_loc4_]);
            }
         }
         if(param1 is Bitmap)
         {
            param1 = (param1 as Bitmap).bitmapData;
         }
         if(param1 is ByteArray)
         {
            _loc3_.writeFileData(param2.fileName,param1 as ByteArray,param2.contentType);
         }
         else if(param1 is BitmapData)
         {
            _loc5_ = PNGEncoder.encode(param1 as BitmapData);
            _loc3_.writeFileData(param2.fileName,_loc5_,"image/png");
         }
         _loc3_.close();
         urlRequest.contentType = "multipart/form-data; boundary=" + _loc3_.boundary;
         return _loc3_;
      }
      
      public function toString() : String
      {
         return urlRequest.url#2 + (urlRequest.data#2 == null ? "" : "?" + unescape(urlRequest.data#2.toString()));
      }
   }
}
