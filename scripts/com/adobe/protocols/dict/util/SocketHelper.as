package com.adobe.protocols.dict.util
{
   import com.adobe.net.proxies.RFC2817Socket;
   import flash.events.ProgressEvent;
   
   public class SocketHelper extends RFC2817Socket
   {
      
      public static var COMPLETE_RESPONSE:String = "completeResponse";
       
      
      private var buffer:String;
      
      private var terminator:String = "\r\n.\r\n";
      
      public function SocketHelper()
      {
         super();
         buffer = new String();
         addEventListener(ProgressEvent.SOCKET_DATA,incomingData);
      }
      
      private function throwResponseEvent(param1:String) : void
      {
         var _loc2_:CompleteResponseEvent = new CompleteResponseEvent();
         _loc2_.response = param1;
         dispatchEvent(_loc2_);
      }
      
      private function incomingData(param1:ProgressEvent) : void
      {
         var _loc3_:uint = 0;
         var _loc4_:String = null;
         buffer += readUTFBytes(bytesAvailable);
         buffer = buffer.replace(/250[^\r\n]+\r\n/,"");
         var _loc2_:String = buffer.substring(0,3);
         if(!isNaN(parseInt(_loc2_)))
         {
            _loc3_ = uint(_loc2_);
            if(_loc3_ == 150 || _loc3_ >= 200)
            {
               buffer = buffer.replace("\r\n",this.terminator);
            }
         }
         while(buffer.indexOf(this.terminator) != -1)
         {
            _loc4_ = buffer.substring(0,buffer.indexOf(this.terminator));
            buffer = buffer.substring(_loc4_.length + this.terminator.length,buffer.length);
            throwResponseEvent(_loc4_);
         }
      }
   }
}
