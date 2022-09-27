package gudetama.util
{
   import flash.events.PermissionEvent;
   import flash.media.Camera;
   import flash.media.CameraRoll;
   import gudetama.common.NativeExtensions;
   import gudetama.data.DataStorage;
   import gudetama.data.GameSetting;
   import gudetama.data.LocalData;
   import gudetama.engine.Engine;
   import gudetama.ui.LocalMessageDialog;
   
   public class PermissionRequestWrapper
   {
      
      public static const PERMISSION_INDUCTION_APP_CONFIG:int = -3;
      
      public static const PERMISSION_ERROR:int = -2;
      
      public static const PERMISSION_NOT_SUPPORT:int = -1;
      
      public static const PERMISSION_REJECT:int = 0;
      
      public static const PERMISSION_ACCEPT:int = 1;
      
      public static const AuthorizationStatusAuthorized:int = 0;
      
      public static const AuthorizationStatusRestricted:int = 1;
      
      public static const AuthorizationStatusNotDetermined:int = 2;
      
      public static const AuthorizationStatusDenied:int = 3;
      
      public static const AuthorizationStatusNotCheck:int = 4;
      
      private static var camera:Camera;
      
      private static var cameraRoll:CameraRoll;
      
      private static var count:int;
      
      private static var callback:Function;
      
      private static var cameraPermission:int;
      
      private static var cameraRollPermission:int;
      
      private static var recordAudioPermission:int;
      
      private static var firstCameraPermission:Boolean;
      
      private static var firstStoragePermission:Boolean;
      
      private static var requestStorageForShare:Boolean;
       
      
      public function PermissionRequestWrapper()
      {
         super();
      }
      
      public static function requestAR(param1:Function) : void
      {
         var _callback:Function = param1;
         callback = _callback;
         if(!Camera.isSupported)
         {
            processCallback(-1);
            return;
         }
         var _loc2_:* = NativeExtensions;
         cameraPermission = gudetama.common.NativeExtensions.arExt.getCameraPermissionStatus();
         var _loc3_:* = NativeExtensions;
         cameraRollPermission = gudetama.common.NativeExtensions.arExt.getCameraRollPermissionStatus();
         var _loc4_:* = Engine;
         if(gudetama.engine.Engine.platform == 0)
         {
            checkIos(cameraPermission,cameraRollPermission);
         }
         else
         {
            var _loc5_:* = Engine;
            if(gudetama.engine.Engine.platform == 1)
            {
               requestAndroidAR();
            }
            else
            {
               var msg:String = GameSetting.getUIText("%ar.permissionRequest");
               var _loc7_:* = Engine;
               msg = StringUtil.format(msg,GameSetting.getUIText("%ar.permission.cameraRoll." + (!!gudetama.engine.Engine.isIosPlatform() ? "ios" : (!!gudetama.engine.Engine.isAndroidPlatform() ? "android" : "android"))));
               LocalMessageDialog.show(2,msg,function(param1:int):void
               {
                  if(param1 == 0)
                  {
                     processCallback(1);
                  }
                  else
                  {
                     processCallback(0);
                  }
               });
            }
         }
      }
      
      public static function requestStorage(param1:Function, param2:Boolean = false) : void
      {
         callback = param1;
         requestStorageForShare = param2;
         cameraPermission = 0;
         var _loc3_:* = NativeExtensions;
         cameraRollPermission = gudetama.common.NativeExtensions.arExt.getCameraRollPermissionStatus();
         var _loc4_:* = Engine;
         if(gudetama.engine.Engine.platform == 0)
         {
            checkIos(cameraPermission,cameraRollPermission);
         }
         else
         {
            var _loc5_:* = Engine;
            if(gudetama.engine.Engine.platform == 1)
            {
               checkAndroidStorage(cameraRollPermission);
            }
            else
            {
               processCallback(1);
            }
         }
      }
      
      private static function requestAndroidAR() : void
      {
         var firstRequestedAR:Boolean = DataStorage.getLocalData().isRequestedFirstARPermissions();
         var _loc2_:* = NativeExtensions;
         recordAudioPermission = gudetama.common.NativeExtensions.arExt.getRecordAudioPermissionStatus();
         if(firstRequestedAR)
         {
            if(cameraPermission == 0 && cameraRollPermission == 0 && recordAudioPermission == 0)
            {
               processCallback(1);
               return;
            }
         }
         var msg:String = GameSetting.getUIText("%ar.permissionRequest.android");
         LocalMessageDialog.show(1,msg,function(param1:int):void
         {
            var result:int = param1;
            if(result == 0)
            {
               try
               {
                  var _loc3_:* = NativeExtensions;
                  gudetama.common.NativeExtensions.arExt.requestPermissionForAR(firstRequestedAR,function(param1:int):void
                  {
                     processCallback(param1);
                     var _loc2_:LocalData = DataStorage.getLocalData();
                     if(!_loc2_.isRequestedFirstStoragePermission())
                     {
                        _loc2_.setRequestedStoragePermission(true);
                     }
                     if(!_loc2_.isRequestedFirstARPermissions())
                     {
                        _loc2_.setRequestedARPermissions(true);
                     }
                     DataStorage.saveLocalData();
                  });
               }
               catch(e:Error)
               {
                  processCallback(-2);
               }
            }
            else
            {
               processCallback(0);
            }
         });
      }
      
      private static function processCallback(param1:int) : void
      {
         if(callback)
         {
            callback(param1);
            callback = null;
         }
         if(camera)
         {
            camera.removeEventListener("permissionStatus",cameraPermissionEvent);
            camera = null;
         }
         if(cameraRoll)
         {
            cameraRoll.removeEventListener("permissionStatus",cameraRollPermissionEvent);
            cameraRoll = null;
         }
         requestStorageForShare = false;
      }
      
      private static function checkIos(param1:int, param2:int) : void
      {
         var cameraPermission:int = param1;
         var cameraRollPermission:int = param2;
         if(cameraPermission == 0 && cameraRollPermission == 0)
         {
            processCallback(1);
         }
         else if(cameraPermission == 2 || cameraRollPermission == 2)
         {
            count = 0;
            var msg:String = null;
            if(cameraPermission == 2)
            {
               count++;
               camera = Camera.getCamera();
               camera.addEventListener("permissionStatus",cameraPermissionEvent);
               msg = GameSetting.getUIText("%ar.permissionRequest.camera");
            }
            if(cameraRollPermission == 2)
            {
               count++;
               cameraRoll = new CameraRoll();
               cameraRoll.addEventListener("permissionStatus",cameraRollPermissionEvent);
               if(msg)
               {
                  msg = GameSetting.getUIText("%ar.permissionRequest");
                  var _loc4_:* = Engine;
                  msg = StringUtil.format(msg,GameSetting.getUIText("%ar.permission.cameraRoll." + (!!gudetama.engine.Engine.isIosPlatform() ? "ios" : (!!gudetama.engine.Engine.isAndroidPlatform() ? "android" : "android"))));
               }
               else
               {
                  msg = GameSetting.getUIText("%ar.permissionRequest.cameraRoll");
                  var _loc5_:* = Engine;
                  msg = StringUtil.format(msg,GameSetting.getUIText("%ar.permission.cameraRoll." + (!!gudetama.engine.Engine.isIosPlatform() ? "ios" : (!!gudetama.engine.Engine.isAndroidPlatform() ? "android" : "android"))));
               }
            }
            LocalMessageDialog.show(1,msg,function(param1:int):void
            {
               if(param1 == 0)
               {
                  try
                  {
                     if(cameraPermission == 2 || cameraPermission == 3)
                     {
                        camera.requestPermission();
                     }
                     else if(cameraRollPermission == 2 || cameraRollPermission == 3)
                     {
                        cameraRoll.requestPermission();
                     }
                  }
                  catch(e:Error)
                  {
                     processCallback(-2);
                  }
               }
               else
               {
                  processCallback(0);
               }
            });
         }
         else
         {
            processCallback(-3);
         }
      }
      
      private static function checkAndroidStorage(param1:int) : void
      {
         var cameraRollPermission:int = param1;
         var localData:LocalData = DataStorage.getLocalData();
         firstStoragePermission = cameraRollPermission == 4 && !localData.isRequestedFirstStoragePermission();
         if(cameraRollPermission == 0)
         {
            processCallback(1);
         }
         else if(firstStoragePermission || cameraRollPermission == 3)
         {
            count = 0;
            var msg:String = null;
            if(firstStoragePermission || cameraRollPermission == 3)
            {
               count++;
               cameraRoll = new CameraRoll();
               cameraRoll.addEventListener("permissionStatus",cameraRollPermissionEvent);
               msg = GameSetting.getUIText(!!requestStorageForShare ? "%ar.permissionRequest.share" : "%ar.permissionRequest.cameraRoll");
               var _loc3_:* = Engine;
               msg = StringUtil.format(msg,GameSetting.getUIText("%ar.permission.cameraRoll." + (!!gudetama.engine.Engine.isIosPlatform() ? "ios" : (!!gudetama.engine.Engine.isAndroidPlatform() ? "android" : "android"))));
            }
            LocalMessageDialog.show(1,msg,function(param1:int):void
            {
               if(param1 == 0)
               {
                  try
                  {
                     if(firstStoragePermission || cameraRollPermission == 3)
                     {
                        cameraRoll.requestPermission();
                     }
                  }
                  catch(e:Error)
                  {
                     processCallback(-2);
                  }
               }
               else
               {
                  processCallback(0);
               }
            });
         }
         else
         {
            processCallback(-3);
         }
      }
      
      private static function cameraPermissionEvent(param1:PermissionEvent) : void
      {
         count--;
         camera.removeEventListener("permissionStatus",cameraPermissionEvent);
         if(param1.status#2 == "granted")
         {
            cameraPermission = 0;
            if(count <= 0)
            {
               if(cameraRollPermission == 0)
               {
                  processCallback(1);
               }
               else
               {
                  processCallback(-3);
               }
            }
            else
            {
               cameraRoll.requestPermission();
            }
         }
         else
         {
            processCallback(0);
         }
      }
      
      private static function cameraRollPermissionEvent(param1:PermissionEvent) : void
      {
         var _loc2_:LocalData = DataStorage.getLocalData();
         if(!_loc2_.isRequestedFirstStoragePermission())
         {
            _loc2_.setRequestedStoragePermission(true);
            DataStorage.saveLocalData();
         }
         count--;
         cameraRoll.removeEventListener("permissionStatus",cameraRollPermissionEvent);
         if(param1.status#2 == "granted")
         {
            cameraRollPermission = 0;
            if(count <= 0)
            {
               if(cameraPermission == 0)
               {
                  processCallback(1);
               }
               else
               {
                  processCallback(-3);
               }
            }
            else
            {
               camera.requestPermission();
            }
         }
         else
         {
            processCallback(0);
            if(_loc2_.isRequestedFirstARPermissions())
            {
               _loc2_.setRequestedARPermissions(true);
               DataStorage.saveLocalData();
            }
         }
      }
      
      public static function showInductionAppConfigDialog(param1:String) : void
      {
         var message:String = param1;
         LocalMessageDialog.show(3,message,function(param1:int):void
         {
            if(param1 == 0)
            {
               var _loc2_:* = NativeExtensions;
               gudetama.common.NativeExtensions.arExt.openPermission();
            }
            else
            {
               processCallback(0);
            }
         },GameSetting.getUIText("%ar.permissionRequest.title"));
      }
   }
}
