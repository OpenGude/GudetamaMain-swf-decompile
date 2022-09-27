package com.facebook.graph.net
{
   import com.adobe.images.PNGEncoder;
   import com.facebook.graph.core.FacebookURLDefaults;
   import com.facebook.graph.data.Batch;
   import com.facebook.graph.data.BatchItem;
   import com.facebook.graph.utils.PostRequest;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.net.URLRequest;
   import flash.net.URLVariables;
   import flash.utils.ByteArray;
   
   public class FacebookBatchRequest extends AbstractFacebookRequest
   {
       
      
      protected var _params:Object;
      
      protected var _relativeURL:String;
      
      protected var _fileData:Object;
      
      protected var _accessToken:String;
      
      protected var _batch:Batch;
      
      public function FacebookBatchRequest(param1:Batch, param2:Function = null)
      {
         super();
         _batch = param1;
         _callback = param2;
      }
      
      public function call(param1:String) : void
      {
         var _loc9_:* = 0;
         var _loc2_:* = null;
         var _loc6_:* = null;
         var _loc12_:* = null;
         var _loc7_:* = null;
         var _loc5_:* = null;
         _accessToken = param1;
         urlRequest = new URLRequest(FacebookURLDefaults.GRAPH_URL);
         urlRequest.method#2 = "POST";
         var _loc4_:Array = [];
         var _loc8_:Array = [];
         var _loc3_:Boolean = false;
         var _loc10_:Array;
         var _loc11_:uint = (_loc10_ = _batch.requests).length;
         _loc9_ = uint(0);
         while(_loc9_ < _loc11_)
         {
            _loc2_ = _loc10_[_loc9_];
            _loc6_ = this.extractFileData(_loc2_.params#2);
            _loc12_ = {
               "method":_loc2_.requestMethod,
               "relative_url":_loc2_.relativeURL
            };
            if(_loc2_.params#2)
            {
               if(_loc2_.params#2["contentType"] != undefined)
               {
                  _loc12_.contentType = _loc2_.params#2["contentType"];
               }
               _loc7_ = this.objectToURLVariables(_loc2_.params#2).toString();
               if(_loc2_.requestMethod == "GET" || _loc2_.requestMethod.toUpperCase() == "DELETE")
               {
                  _loc12_.relative_url += "?" + _loc7_;
               }
               else
               {
                  _loc12_.body = _loc7_;
               }
            }
            _loc4_.push(_loc12_);
            if(_loc6_)
            {
               _loc8_.push(_loc6_);
               _loc12_.attached_files = _loc2_.params#2.fileName == null ? "file" + _loc9_ : _loc2_.params#2.fileName;
               _loc3_ = true;
            }
            else
            {
               _loc8_.push(null);
            }
            _loc9_++;
         }
         if(!_loc3_)
         {
            (_loc5_ = new URLVariables()).access_token = param1;
            _loc5_.batch = JSON.stringify(_loc4_);
            urlRequest.data#2 = _loc5_;
            loadURLLoader();
         }
         else
         {
            sendPostRequest(_loc4_,_loc8_);
         }
      }
      
      protected function sendPostRequest(param1:Array, param2:Array) : void
      {
         var _loc6_:* = 0;
         var _loc4_:* = null;
         var _loc5_:* = null;
         var _loc8_:* = null;
         var _loc3_:PostRequest = new PostRequest();
         _loc3_.writePostData("access_token",_accessToken);
         _loc3_.writePostData("batch",JSON.stringify(param1));
         var _loc7_:uint = param1.length;
         _loc6_ = uint(0);
         while(_loc6_ < _loc7_)
         {
            _loc4_ = param1[_loc6_];
            if(_loc5_ = param2[_loc6_])
            {
               if(_loc5_ is Bitmap)
               {
                  _loc5_ = (_loc5_ as Bitmap).bitmapData;
               }
               if(_loc5_ is ByteArray)
               {
                  _loc3_.writeFileData(_loc4_.attached_files,_loc5_ as ByteArray,_loc4_.contentType);
               }
               else if(_loc5_ is BitmapData)
               {
                  _loc8_ = PNGEncoder.encode(_loc5_ as BitmapData);
                  _loc3_.writeFileData(_loc4_.attached_files,_loc8_,"image/png");
               }
            }
            _loc6_++;
         }
         _loc3_.close();
         urlRequest.contentType = "multipart/form-data; boundary=" + _loc3_.boundary;
         urlRequest.data#2 = _loc3_.getPostData();
         loadURLLoader();
      }
      
      override protected function handleDataReady() : void
      {
         var _loc1_:* = 0;
         var _loc3_:* = null;
         var _loc4_:Array;
         var _loc2_:uint = (_loc4_ = _data as Array).length;
         _loc1_ = uint(0);
         while(_loc1_ < _loc2_)
         {
            _loc3_ = JSON.parse(_data[_loc1_].body);
            _data[_loc1_].body = _loc3_;
            if((_batch.requests[_loc1_] as BatchItem).callback != null)
            {
               (_batch.requests[_loc1_] as BatchItem).callback(_data[_loc1_]);
            }
            _loc1_++;
         }
      }
   }
}
