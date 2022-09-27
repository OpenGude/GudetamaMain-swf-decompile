package gudetama.extensions
{
   import com.freshplanet.ane.AirNativeShare.AirNativeShare;
   import com.freshplanet.ane.AirNativeShare.AirNativeShareCustomText;
   import com.freshplanet.ane.AirNativeShare.events.AirNativeShareEvent;
   import flash.display.BitmapData;
   import gudetama.data.GameSetting;
   import gudetama.engine.Engine;
   import gudetama.ui.LocalMessageDialog;
   import gudetama.util.PermissionRequestWrapper;
   import gudetama.util.StringUtil;
   
   public class ShareExtension
   {
       
      
      private var sharedCallback:Function;
      
      public function ShareExtension()
      {
         super();
         if(!AirNativeShare.isSupported)
         {
            trace("AirNativeShare ANE is NOT supported on this platform!");
            return;
         }
         var _loc1_:* = Engine;
         if(gudetama.engine.Engine.platform == 0)
         {
            AirNativeShare.instance.addEventListener("AirNativeShareEvent_didShare",onDidShare);
            AirNativeShare.instance.addEventListener("AirNativeShareEvent_cancelled",onShareCancelled);
         }
      }
      
      public function showShareBitmapData(param1:BitmapData, param2:String, param3:Function) : void
      {
         var bitmapData:BitmapData = param1;
         var message:String = param2;
         var permissionCallback:Function = param3;
         if(!AirNativeShare.isSupported)
         {
            return;
         }
         var _loc4_:* = Engine;
         if(gudetama.engine.Engine.platform == 1)
         {
            Engine.lockTouchInput(ShareExtension);
            PermissionRequestWrapper.requestStorage(function(param1:int):void
            {
               var _loc2_:* = null;
               if(param1 == 1)
               {
                  Engine.unlockTouchInput(ShareExtension);
                  if(permissionCallback)
                  {
                     permissionCallback();
                  }
                  if(message)
                  {
                     AirNativeShare.instance.showShare([message,bitmapData]);
                  }
                  else
                  {
                     AirNativeShare.instance.showShare([bitmapData]);
                  }
               }
               else
               {
                  Engine.unlockTouchInput(ShareExtension);
                  _loc2_ = GameSetting.getUIText("%ar.permissionRequest.reject.share");
                  var _loc3_:* = Engine;
                  _loc2_ = StringUtil.format(_loc2_,GameSetting.getUIText("%ar.permission.cameraRoll." + (!!gudetama.engine.Engine.isIosPlatform() ? "ios" : (!!gudetama.engine.Engine.isAndroidPlatform() ? "android" : "android"))));
                  LocalMessageDialog.show(2,_loc2_,null,GameSetting.getUIText("%ar.permissionRequest.title"));
               }
            },true);
         }
         else if(message)
         {
            var text:AirNativeShareCustomText = new AirNativeShareCustomText(message);
            AirNativeShare.instance.showShareWithCustomTexts(text,null,bitmapData);
         }
         else
         {
            AirNativeShare.instance.showShare([bitmapData]);
         }
      }
      
      public function showShareMessage(param1:String) : void
      {
         var _loc2_:* = null;
         if(!AirNativeShare.isSupported)
         {
            return;
         }
         var _loc3_:* = Engine;
         if(gudetama.engine.Engine.platform == 1)
         {
            AirNativeShare.instance.showShare([param1]);
         }
         else
         {
            _loc2_ = new AirNativeShareCustomText(param1);
            AirNativeShare.instance.showShareWithCustomTexts(_loc2_);
         }
      }
      
      public function setSharedCallback(param1:Function) : void
      {
         sharedCallback = param1;
      }
      
      private function onShareCancelled(param1:AirNativeShareEvent) : void
      {
         if(sharedCallback)
         {
            sharedCallback(false);
         }
         sharedCallback = null;
      }
      
      private function onDidShare(param1:AirNativeShareEvent) : void
      {
         if(sharedCallback)
         {
            sharedCallback(true);
         }
         sharedCallback = null;
      }
      
      public function set logEnabled(param1:Boolean) : void
      {
         AirNativeShare.instance.logEnabled = param1;
      }
   }
}
