package gudetama.data
{
   import gudetama.common.GudetamaUtil;
   import gudetama.data.compati.HomeDecoData;
   import gudetama.data.compati.HomeStampSettingDef;
   import gudetama.data.compati.SubHomeStampSettingDef;
   import gudetama.engine.SoundManager;
   import gudetama.engine.TextureCollector;
   import muku.core.MukuGlobal;
   import muku.core.TaskQueue;
   import muku.util.SpineUtil;
   import spine.SkeletonData;
   import spine.animation.AnimationStateData;
   import spine.starling.SkeletonAnimation;
   import starling.display.Image;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   import starling.textures.Texture;
   
   public class HomeSkeltonAnimation
   {
       
      
      private var gudetamaSpineModel:SkeletonAnimation;
      
      private var decodata:HomeDecoData;
      
      private var image:Image;
      
      public function HomeSkeltonAnimation(param1:HomeDecoData)
      {
         super();
         decodata = param1;
         decodata.isSpain = GameSetting.getStamp(decodata.stampId).isSpine;
      }
      
      public static function startTouchAction(param1:SkeletonAnimation, param2:HomeStampSettingDef) : void
      {
         var _gudetamaSpineModel:SkeletonAnimation = param1;
         var _homeStampSetting:HomeStampSettingDef = param2;
         var touchHomeStampSetting:SubHomeStampSettingDef = _homeStampSetting.touchSetting;
         if(touchHomeStampSetting)
         {
            _gudetamaSpineModel.state.clearTracks();
            if(touchHomeStampSetting.sound && touchHomeStampSetting.sound != "")
            {
               SoundManager.playEffect(touchHomeStampSetting.sound);
            }
            if(touchHomeStampSetting.voiceId > -1)
            {
               SoundManager.playVoice(MukuGlobal.makePathFromVoiceName(0,touchHomeStampSetting.voiceId));
            }
            if(touchHomeStampSetting.music && touchHomeStampSetting.music != "")
            {
               var originalmusic:String = SoundManager.getplayingMusicName();
               SoundManager.playMusic(touchHomeStampSetting.music,1,0,function():void
               {
                  if(originalmusic)
                  {
                     SoundManager.playMusic(originalmusic,1);
                  }
               });
            }
            if(touchHomeStampSetting.animationName && touchHomeStampSetting.animationName != "")
            {
               _gudetamaSpineModel.state.setAnimationByName(0,touchHomeStampSetting.animationName,touchHomeStampSetting.loop,function():void
               {
                  if(!touchHomeStampSetting.loop && _homeStampSetting.animationName && _homeStampSetting.animationName != "")
                  {
                     _gudetamaSpineModel.state.setAnimationByName(0,_homeStampSetting.animationName,_homeStampSetting.loop);
                  }
               });
            }
         }
      }
      
      public function stamp(param1:Number, param2:Number, param3:Function) : void
      {
         var capturedWidth:Number = param1;
         var capturedHeight:Number = param2;
         var _callback:Function = param3;
         var queue:TaskQueue = new TaskQueue();
         if(decodata.isSpain)
         {
            queue.addTask(function():void
            {
               var defStampSpainPath:String = "stamp/" + decodata.stampId + "/stamp_" + decodata.stampId + "_spine";
               var extra:Boolean = SpineUtil.existSkeletonAnimationData(defStampSpainPath);
               if(!extra)
               {
                  defStampSpainPath = GameSetting.getRule().defStampSpainPath;
               }
               SpineUtil.loadSkeletonAnimation(defStampSpainPath,function(param1:SkeletonData, param2:AnimationStateData):void
               {
                  var _skeletonData:SkeletonData = param1;
                  var _stateData:AnimationStateData = param2;
                  var homeStampSetting:HomeStampSettingDef = GameSetting.getHomeStampSetting(GameSetting.getStamp(decodata.stampId).homeStampSettingId);
                  gudetamaSpineModel = new SkeletonAnimation(_skeletonData,_stateData);
                  gudetamaSpineModel.touchable = true;
                  gudetamaSpineModel.skeleton.setToSetupPose();
                  gudetamaSpineModel.state.update(0);
                  gudetamaSpineModel.state.apply(gudetamaSpineModel.skeleton);
                  gudetamaSpineModel.skeleton.updateWorldTransform();
                  if(homeStampSetting.animationName && homeStampSetting.animationName != "")
                  {
                     gudetamaSpineModel.state.setAnimationByName(0,homeStampSetting.animationName,homeStampSetting.loop);
                  }
                  gudetamaSpineModel.x = capturedWidth * decodata.screenPosRateX + 30;
                  gudetamaSpineModel.y = capturedHeight * decodata.screenPosRateY + 8;
                  gudetamaSpineModel.scaleX = decodata.scale * capturedWidth / 600;
                  gudetamaSpineModel.scaleY = decodata.scale * capturedHeight / 514;
                  gudetamaSpineModel.pivotX = gudetamaSpineModel.width * 0.5;
                  gudetamaSpineModel.pivotY = 15;
                  gudetamaSpineModel.rotation = decodata.rotation;
                  var touchHomeStampSetting:SubHomeStampSettingDef = homeStampSetting.touchSetting;
                  if(touchHomeStampSetting)
                  {
                     gudetamaSpineModel.addEventListener("touch",function(param1:TouchEvent):void
                     {
                        var _loc2_:Touch = param1.getTouch(gudetamaSpineModel,"ended");
                        if(_loc2_)
                        {
                           startTouchAction(gudetamaSpineModel,homeStampSetting);
                        }
                     });
                  }
                  if(!extra)
                  {
                     TextureCollector.loadTextureForTask(queue,GudetamaUtil.getARStampName(decodata.stampId),function(param1:Texture):void
                     {
                        SpineUtil.changeSkeletonAttachmentTexture(gudetamaSpineModel.skeleton,param1,homeStampSetting.slotName,homeStampSetting.attachmentName,null);
                        queue.taskDone();
                     });
                  }
                  else
                  {
                     queue.taskDone();
                  }
               },null,1);
            });
         }
         else
         {
            TextureCollector.loadTextureForTask(queue,GudetamaUtil.getARStampName(decodata.stampId),function(param1:Texture):void
            {
               image = new Image(param1);
               image.readjustSize();
               image.pivotX = param1.width * 0.5;
               image.pivotY = param1.height * 0.5;
               image.x = capturedWidth * decodata.screenPosRateX + 30;
               image.y = capturedHeight * decodata.screenPosRateY + 8;
               image.scaleX = decodata.scale * capturedWidth / 600;
               image.scaleY = decodata.scale * capturedHeight / 514;
               image.rotation = decodata.rotation;
               queue.taskDone();
            });
         }
         queue.startTask(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            _callback();
         });
      }
      
      public function getSkeletonAnimation() : SkeletonAnimation
      {
         return gudetamaSpineModel;
      }
      
      public function getImage() : Image
      {
         return image;
      }
      
      public function isSpine() : Boolean
      {
         return decodata.isSpain;
      }
   }
}
