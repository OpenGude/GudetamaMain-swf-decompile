package starling.textures
{
   import flash.display.BitmapData;
   import flash.display3D.textures.RectangleTexture;
   import flash.display3D.textures.TextureBase;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.utils.setTimeout;
   import starling.core.Starling;
   import starling.utils.execute;
   
   class ConcreteRectangleTexture extends ConcreteTexture
   {
      
      private static var sAsyncSupported:Boolean = true;
       
      
      private var _textureReadyCallback:Function;
      
      function ConcreteRectangleTexture(param1:RectangleTexture, param2:String, param3:int, param4:int, param5:Boolean, param6:Boolean = false, param7:Number = 1)
      {
         super(param1,param2,param3,param4,false,param5,param6,param7);
      }
      
      override public function uploadBitmapData(param1:BitmapData, param2:* = null) : void
      {
         if(param2 is Function)
         {
            _textureReadyCallback = param2 as Function;
         }
         upload(param1,param2 != null);
         setDataUploaded();
      }
      
      override protected function createBase() : TextureBase
      {
         var _loc1_:* = Starling;
         return (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent.context : null).createRectangleTexture(nativeWidth,nativeHeight,format,optimizedForRenderTexture);
      }
      
      private function get rectBase() : RectangleTexture
      {
         return base as RectangleTexture;
      }
      
      private function upload(param1:BitmapData, param2:Boolean) : void
      {
         if(param2)
         {
            uploadAsync(param1);
            base.addEventListener("textureReady",onTextureReady);
            base.addEventListener("error",onTextureReady);
         }
         else
         {
            try
            {
               rectBase.uploadFromBitmapData(param1);
            }
            catch(e:Error)
            {
               trace(e.getStackTrace());
               if(registrants)
               {
                  trace(this,registrants[this]);
               }
            }
         }
      }
      
      private function uploadAsync(param1:BitmapData) : void
      {
         if(sAsyncSupported)
         {
            try
            {
               base["uploadFromBitmapDataAsync"](param1);
            }
            catch(error:Error)
            {
               if(!(error.errorID == 3708 || error.errorID == 1069))
               {
                  throw error;
               }
               sAsyncSupported = false;
            }
         }
         if(!sAsyncSupported)
         {
            setTimeout(base.dispatchEvent,1,new Event("textureReady"));
            rectBase.uploadFromBitmapData(param1);
         }
      }
      
      private function onTextureReady(param1:Event) : void
      {
         base.removeEventListener("textureReady",onTextureReady);
         base.removeEventListener("error",onTextureReady);
         execute(_textureReadyCallback,this,param1 as ErrorEvent);
         _textureReadyCallback = null;
      }
   }
}
