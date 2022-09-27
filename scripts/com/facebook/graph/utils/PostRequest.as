package com.facebook.graph.utils
{
   import flash.utils.ByteArray;
   
   public class PostRequest
   {
       
      
      public var boundary:String = "-----";
      
      protected var postData:ByteArray;
      
      public function PostRequest()
      {
         super();
         createPostData();
      }
      
      public function createPostData() : void
      {
         postData = new ByteArray();
         postData.endian = "bigEndian";
      }
      
      public function writePostData(param1:String, param2:String) : void
      {
         var _loc3_:* = null;
         var _loc4_:* = NaN;
         writeBoundary();
         writeLineBreak();
         _loc3_ = "Content-Disposition: form-data; name=\"" + param1 + "\"";
         var _loc5_:uint = _loc3_.length;
         _loc4_ = 0;
         while(_loc4_ < _loc5_)
         {
            postData.writeByte(_loc3_.charCodeAt(_loc4_));
            _loc4_++;
         }
         writeLineBreak();
         writeLineBreak();
         postData.writeUTFBytes(param2);
         writeLineBreak();
      }
      
      public function writeFileData(param1:String, param2:ByteArray, param3:String) : void
      {
         var _loc4_:* = null;
         var _loc6_:int = 0;
         var _loc5_:* = 0;
         writeBoundary();
         writeLineBreak();
         _loc6_ = (_loc4_ = "Content-Disposition: form-data; name=\"" + param1 + "\"; filename=\"" + param1 + "\";").length;
         _loc5_ = uint(0);
         while(_loc5_ < _loc6_)
         {
            postData.writeByte(_loc4_.charCodeAt(_loc5_));
            _loc5_++;
         }
         postData.writeUTFBytes(param1);
         writeQuotationMark();
         writeLineBreak();
         _loc6_ = (_loc4_ = param3 || "application/octet-stream").length;
         _loc5_ = uint(0);
         while(_loc5_ < _loc6_)
         {
            postData.writeByte(_loc4_.charCodeAt(_loc5_));
            _loc5_++;
         }
         writeLineBreak();
         writeLineBreak();
         param2.position = 0;
         postData.writeBytes(param2,0,param2.length);
         writeLineBreak();
      }
      
      public function getPostData() : ByteArray
      {
         postData.position = 0;
         return postData;
      }
      
      public function close() : void
      {
         writeBoundary();
         writeDoubleDash();
      }
      
      protected function writeLineBreak() : void
      {
         postData.writeShort(3338);
      }
      
      protected function writeQuotationMark() : void
      {
         postData.writeByte(34);
      }
      
      protected function writeDoubleDash() : void
      {
         postData.writeShort(11565);
      }
      
      protected function writeBoundary() : void
      {
         var _loc1_:* = 0;
         writeDoubleDash();
         var _loc2_:uint = boundary.length;
         _loc1_ = uint(0);
         while(_loc1_ < _loc2_)
         {
            postData.writeByte(boundary.charCodeAt(_loc1_));
            _loc1_++;
         }
      }
   }
}
