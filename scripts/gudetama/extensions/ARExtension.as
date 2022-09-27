package gudetama.extensions
{
   import flash.display.BitmapData;
   import flash.display3D.Context3D;
   import flash.display3D.textures.TextureBase;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.ByteArray;
   import gudetama.engine.Engine;
   import gudetama.engine.Logger;
   import muku.util.StarlingUtil;
   import starling.core.Starling;
   import starling.display.Image;
   import starling.errors.MissingContextError;
   import starling.textures.ConcreteTexture;
   import starling.textures.Texture;
   
   public class ARExtension
   {
      
      public static const PERMISSION_INDUCTION_APP_CONFIG:int = -3;
      
      public static const PERMISSION_ERROR:int = -2;
      
      public static const PERMISSION_NOT_SUPPORT:int = -1;
      
      public static const PERMISSION_REJECT:int = 0;
      
      public static const PERMISSION_ACCEPT:int = 1;
       
      
      private var aspect:Number;
      
      private var sizeWidth:Number = 700;
      
      private var sizeHeight:Number = 1136;
      
      private var DISPLAY_CAMERA_WIDTH:Number = 700;
      
      private var DISPLAY_CAMERA_HEIGHT:Number = 1001;
      
      private var extension:SmartARNativeExtension;
      
      private var cameraWidth:int;
      
      private var cameraHeight:int;
      
      private var stillWidth:int;
      
      private var stillHeight:int;
      
      private var cameraImageRot:int;
      
      private var cameraImage:Image;
      
      private var cameraTexture:Texture;
      
      private var initBuffer:ByteArray;
      
      private var started:Boolean;
      
      private var createCompleteCallback:Function;
      
      private var caputuredCompleteCallback:Function;
      
      private var savedCallback:Function;
      
      private var offsetXY:Point;
      
      private var ignorePause:Boolean;
      
      private var finishedScreenRecordingCallback:Function;
      
      public function ARExtension()
      {
         offsetXY = new Point();
         super();
         extension = new SmartARNativeExtension();
         extension.addEventListener("resume_complete_ar_event",onResumeCompleteAR);
         extension.addEventListener("pause_complete_ar_event",onPauseCompleteAR);
         extension.addEventListener("capture_complete_ar_event",onCaptureCompleteAR);
         extension.addEventListener("finished_complete_ar_event",onFinishCompleteAR);
         extension.addEventListener("save_complete_ar_event",onSaveCompleteAR);
         extension.create();
      }
      
      public static function getRectangleTextureFromByteArray(param1:ByteArray, param2:int, param3:int, param4:Boolean = false) : Texture
      {
         var _loc8_:* = Starling;
         var _loc7_:Context3D;
         if((_loc7_ = !!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent.context : null) == null)
         {
            throw new MissingContextError();
         }
         var _loc9_:* = Starling;
         if(starling.core.Starling.sCurrent.profile == "baselineConstrained" || !("createRectangleTexture" in _loc7_))
         {
            throw new Error("RectangleTexture is not supported for this Flash Player version.");
         }
         var _loc5_:TextureBase = _loc7_["createRectangleTexture"](param2,param3,"bgra",param4);
         var _loc6_:ConcreteTexture = Texture.fromTextureBase(_loc5_,param2,param3);
         _loc5_["uploadFromByteArray"](param1,0);
         _loc6_.onRestore = createOnRestore(_loc5_,_loc6_,param1);
         return _loc6_;
      }
      
      public static function uploadFromByteArrayForRectangleTexture(param1:ConcreteTexture, param2:ByteArray) : void
      {
         var _loc3_:TextureBase = param1.base;
         _loc3_["uploadFromByteArray"](param2,0);
      }
      
      private static function createOnRestore(param1:TextureBase, param2:ConcreteTexture, param3:ByteArray) : Function
      {
         var nativeTexture:TextureBase = param1;
         var concreteTexture:ConcreteTexture = param2;
         var data:ByteArray = param3;
         return function():void
         {
            concreteTexture.clear();
            nativeTexture["uploadFromByteArray"](data,0);
         };
      }
      
      public function initAR(param1:Function) : void
      {
         extension.addEventListener("ready_ar_event",onReadyAR);
         createCompleteCallback = param1;
         extension.init();
         cameraWidth = extension.cameraWidth;
         cameraHeight = extension.cameraHeight;
         stillWidth = extension.stillWidth;
         stillHeight = extension.stillHeight;
         cameraImageRot = extension.cameraDeviceRot;
         aspect = cameraWidth / cameraHeight;
         sizeWidth = sizeHeight / aspect;
         Logger.info("ARExtension initAR[cameraWidth:{}, cameraHeight:{}, stillWidth:{}, stillHeight:{}, cameraImageRot:{}]",cameraWidth,cameraHeight,stillWidth,stillHeight,cameraImageRot);
      }
      
      private function onReadyAR(param1:AREvent) : void
      {
         extension.removeEventListener("ready_ar_event",onReadyAR);
         initBuffer = new ByteArray();
         initBuffer.length = cameraWidth * cameraHeight * 4;
         cameraTexture = getRectangleTextureFromByteArray(initBuffer,cameraWidth,cameraHeight);
         createCompleteCallback();
      }
      
      public function start(param1:Image) : void
      {
         cameraImage = param1;
         cameraImage.blendMode = "none";
         cameraImage.texture = cameraTexture;
         cameraImage.readjustSize();
         adjustCameraImage(false);
         started = true;
      }
      
      private function onResumeCompleteAR(param1:AREvent) : void
      {
      }
      
      private function onPauseCompleteAR(param1:AREvent) : void
      {
      }
      
      private function onCaptureCompleteAR(param1:AREvent) : void
      {
         var _loc4_:* = null;
         var _loc3_:ByteArray = extension.getCaptureData();
         _loc3_.endian = "littleEndian";
         _loc3_.position = 0;
         var _loc2_:Rectangle = StarlingUtil.getRectangleFromPool();
         if(param1.parameters.changeWidthHeight)
         {
            _loc4_ = new BitmapData(extension.stillHeight,extension.stillWidth,false);
            _loc2_.setTo(0,0,extension.stillHeight,extension.stillWidth);
            _loc4_.setPixels(_loc2_,_loc3_);
         }
         else
         {
            _loc4_ = new BitmapData(extension.stillWidth,extension.stillHeight,false);
            _loc2_.setTo(0,0,extension.stillWidth,extension.stillHeight);
            _loc4_.setPixels(_loc2_,_loc3_);
         }
         if(caputuredCompleteCallback)
         {
            caputuredCompleteCallback(_loc4_,cameraImageRot,param1.parameters.changeWidthHeight);
            caputuredCompleteCallback = null;
         }
      }
      
      private function onFinishCompleteAR(param1:AREvent) : void
      {
      }
      
      private function onSaveCompleteAR(param1:AREvent) : void
      {
         if(savedCallback)
         {
            savedCallback();
            savedCallback = null;
         }
      }
      
      public function finish() : void
      {
         extension.finish();
         cameraImage = null;
         initBuffer.clear();
         initBuffer = null;
         caputuredCompleteCallback = null;
         if(cameraTexture)
         {
            cameraTexture.dispose();
            cameraTexture = null;
         }
      }
      
      public function pause() : void
      {
         if(!started || ignorePause)
         {
            return;
         }
         extension.pause();
      }
      
      public function resume() : void
      {
         if(!started || ignorePause)
         {
            return;
         }
         extension.resume();
      }
      
      public function update() : ARParam
      {
         if(!cameraTexture)
         {
            return null;
         }
         extension.render();
         var _loc1_:ByteArray = extension.rgbBuffer;
         _loc1_.position = 0;
         uploadFromByteArrayForRectangleTexture(cameraTexture as ConcreteTexture,_loc1_);
         return extension.getARParam();
      }
      
      public function getARParam() : ARParam
      {
         return extension.getARParam();
      }
      
      public function resetRecognizer() : void
      {
         extension.resetRecognizer();
      }
      
      public function toggleRecognizer(param1:Boolean) : void
      {
         extension.toggleRecognizer(param1);
      }
      
      public function unproject(param1:int, param2:Number, param3:Number) : void
      {
         extension.unproject(param1,param2,param3);
      }
      
      public function addTarget(param1:int) : void
      {
         extension.addtarget(param1);
      }
      
      public function removeTarget(param1:int) : void
      {
         extension.removeTarget(param1);
      }
      
      public function changeCamera(param1:Boolean) : void
      {
         extension.changeCamera();
         cameraWidth = extension.cameraWidth;
         cameraHeight = extension.cameraHeight;
         cameraImageRot = extension.cameraDeviceRot;
         stillWidth = extension.stillWidth;
         stillHeight = extension.stillHeight;
         adjustCameraImage(param1);
         Logger.info("ARExtension changeCamera[cameraWidth:{}, cameraHeight:{}, stillWidth:{}, stillHeight:{}, cameraImageRot:{}]",cameraWidth,cameraHeight,stillWidth,stillHeight,cameraImageRot);
      }
      
      public function captureRequest(param1:Function) : void
      {
         caputuredCompleteCallback = param1;
         extension.captureRequest();
      }
      
      public function getCaptureData() : ByteArray
      {
         return extension.getCaptureData();
      }
      
      public function save(param1:BitmapData, param2:Function) : void
      {
         savedCallback = param2;
         extension.saveCpaturedStillImage(param1);
      }
      
      public function openPermission() : void
      {
         extension.openPermission();
      }
      
      public function getCameraImageRot() : int
      {
         return cameraImageRot;
      }
      
      public function getCameraImageOffsetXY() : Point
      {
         return offsetXY;
      }
      
      public function requestPermissionForAR(param1:Boolean, param2:Function) : void
      {
         var firstRequest:Boolean = param1;
         var callback:Function = param2;
         extension.addEventListener("result_requested_permissions_event",function(param1:AREvent):void
         {
            extension.removeEventListener("result_requested_permissions_event",arguments.callee);
            if(param1.parameters.successed)
            {
               callback(1);
            }
            else
            {
               callback(0);
            }
         });
         extension.addEventListener("result_requested_permissions_induction_permission_event",function(param1:AREvent):void
         {
            extension.removeEventListener("result_requested_permissions_induction_permission_event",arguments.callee);
            callback(-3);
         });
         extension.requestPermissionForAR(firstRequest);
      }
      
      public function getCameraPermissionStatus() : int
      {
         return extension.getCameraPermissionStatus();
      }
      
      public function getCameraRollPermissionStatus() : int
      {
         return extension.getCameraRollPermissionStatus();
      }
      
      public function getRecordAudioPermissionStatus() : int
      {
         return extension.getRecordAudioPermissionStatus();
      }
      
      public function getPushNotificatePermissionStatus(param1:Function) : void
      {
         extension.getPushNotificatePermissionStatus(param1);
      }
      
      public function isSupportedScreenRecording() : Boolean
      {
         return extension.isSupportedScreenRecording();
      }
      
      public function startScreenRecording(param1:Function) : void
      {
         finishedScreenRecordingCallback = param1;
         extension.addEventListener("setuped_screen_recording_event",_startScreenRecording);
         extension.addEventListener("stoped_screen_recording_event",finishedScreenRecording);
         extension.addEventListener("canceled_screen_recording_event",finishedScreenRecording);
         ignorePause = true;
         var _loc2_:* = Engine;
         if(gudetama.engine.Engine.platform == 0)
         {
            extension.startScreenRecording();
         }
         else
         {
            var _loc3_:* = Engine;
            if(gudetama.engine.Engine.platform == 1)
            {
               extension.setupScreenRecording();
            }
         }
      }
      
      private function _startScreenRecording(param1:AREvent) : void
      {
         extension.removeEventListener("setuped_screen_recording_event",_startScreenRecording);
         var _loc2_:* = Engine;
         if(gudetama.engine.Engine.platform == 1)
         {
            extension.startScreenRecording();
         }
         ignorePause = false;
      }
      
      public function stopScreenRecording() : void
      {
         extension.stopScreenRecording();
      }
      
      private function finishedScreenRecording(param1:AREvent) : void
      {
         extension.removeEventListener("setuped_screen_recording_event",_startScreenRecording);
         extension.removeEventListener("stoped_screen_recording_event",finishedScreenRecording);
         extension.removeEventListener("canceled_screen_recording_event",finishedScreenRecording);
         if(finishedScreenRecordingCallback)
         {
            finishedScreenRecordingCallback(param1.parameters.fileName,param1.type == "canceled_screen_recording_event");
            finishedScreenRecordingCallback = null;
         }
      }
      
      public function shareScreenRecording(param1:String, param2:String) : void
      {
         extension.shareScreenRecording(param1,param2);
      }
      
      public function startAppearance(param1:int) : void
      {
         extension.startAppearance(param1);
      }
      
      public function isIgnorePause() : Boolean
      {
         return ignorePause;
      }
      
      public function adjustCameraImage(param1:Boolean, param2:Boolean = false) : void
      {
         cameraImage.rotation = StarlingUtil.degRad * cameraImageRot;
         cameraImage.scaleX = sizeHeight / cameraWidth;
         cameraImage.scaleY = sizeWidth / cameraHeight;
         var _loc5_:* = Engine;
         var _loc3_:Number = (cameraImage.width - (gudetama.engine.Engine.designWidth + gudetama.engine.Engine.designWidthMargin * 2)) / 2;
         var _loc4_:Number = cameraImage.height - DISPLAY_CAMERA_HEIGHT;
         offsetXY.setTo(_loc3_,_loc4_);
         if(cameraImageRot == 90)
         {
            if(param1)
            {
               cameraImage.scaleY = -sizeWidth / cameraHeight;
               cameraImage.x = -_loc3_;
               cameraImage.y = 0;
            }
            else
            {
               cameraImage.x = sizeWidth - _loc3_;
               cameraImage.y = 0;
            }
         }
         else if(cameraImageRot == 180)
         {
            cameraImage.x = sizeWidth;
            cameraImage.y = sizeHeight;
            if(param1)
            {
               cameraImage.x = sizeWidth;
               cameraImage.y = sizeHeight;
               cameraImage.scaleY = -sizeWidth / cameraHeight;
            }
            else
            {
               cameraImage.x = sizeWidth - _loc3_;
               cameraImage.y = sizeHeight;
            }
         }
         else if(cameraImageRot == 270)
         {
            if(param1)
            {
               cameraImage.x = sizeWidth - _loc3_;
               cameraImage.y = sizeHeight;
               cameraImage.scaleY = -sizeWidth / cameraHeight;
            }
            else
            {
               cameraImage.x = -_loc3_;
               cameraImage.y = sizeHeight;
            }
         }
         else
         {
            cameraImage.rotation = StarlingUtil.degRad * 90;
            if(param1)
            {
               var _loc6_:* = Engine;
               offsetXY.setTo((sizeWidth - (gudetama.engine.Engine.designWidth + gudetama.engine.Engine.designWidthMargin * 2)) / 2,_loc4_);
               var _loc7_:* = Engine;
               cameraImage.x = sizeWidth - (sizeWidth - (gudetama.engine.Engine.designWidth + gudetama.engine.Engine.designWidthMargin * 2)) / 2;
               cameraImage.y = sizeHeight;
               cameraImage.scaleX = -sizeHeight / cameraWidth;
            }
            else
            {
               var _loc8_:* = Engine;
               offsetXY.setTo((sizeWidth - (gudetama.engine.Engine.designWidth + gudetama.engine.Engine.designWidthMargin * 2)) / 2,_loc4_);
               var _loc9_:* = Engine;
               cameraImage.x = sizeWidth - (sizeWidth - (gudetama.engine.Engine.designWidth + gudetama.engine.Engine.designWidthMargin * 2)) / 2;
               cameraImage.y = 0;
            }
         }
      }
      
      public function setDebugMode(param1:Boolean) : void
      {
         extension.setDebugMode(param1);
      }
   }
}
