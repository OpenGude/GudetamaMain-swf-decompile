package gudetama.engine
{
   import com.cyberstep.ane.SoundPoolExt;
   import flash.errors.IOError;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.filesystem.File;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundMixer;
   import flash.media.SoundTransform;
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import gudetama.data.DataStorage;
   import gudetama.data.LocalData;
   import muku.core.TaskQueue;
   import starling.utils.AssetManager;
   
   public final class SoundManager
   {
      
      public static const BaseVolumeOfMusic:Number = 0.85;
      
      public static const BaseVolumeOfVoice:Number = 1.0;
      
      public static const BaseVolumeOfEffect:Number = 1.0;
      
      private static var volumeOfMusic:Number = 1.0;
      
      private static var volumeOfVoice:Number = 1.0;
      
      private static var volumeOfEffect:Number = 1.0;
      
      public static const DefaultVolumeOfMusic:Number = 1.0;
      
      public static const DefaultVolumeOfVoice:Number = 1.0;
      
      public static const DefaultVolumeOfEffect:Number = 1.0;
      
      public static const AdjustedMusicVolumeInPlayingVoice:Number = 0.2;
      
      public static const FadeTimeOfMusicInPlayingVoice:Number = 0.2;
      
      private static var _enableMusic:Boolean = true;
      
      private static var _enableVoice:Boolean = true;
      
      private static var _enableEffect:Boolean = true;
      
      private static var _fadeOutTimerOfMusic:Number = 0;
      
      private static var _fadeOutTotalOfMusic:Number = 0;
      
      private static var _fadeInTimerOfMusic:Number = 0;
      
      private static var _fadeInTotalOfMusic:Number = 0;
      
      private static var _volumeAdjustOfMusic:Number = 1.0;
      
      private static const PHASE_NONE:int = 0;
      
      private static const PHASE_FADE_OUT:int = 1;
      
      private static const PHASE_FADE_IN:int = 2;
      
      private static var _adjustedMusicPhaseInPlayingVoice:int = 0;
      
      private static var _fadeOutTimerOfMusicInPlayingVoice:Number = 0;
      
      private static var _fadeOutTotalOfMusicInPlayingVoice:Number = 0;
      
      private static var _fadeInTimerOfMusicInPlayingVoice:Number = 0;
      
      private static var _fadeInTotalOfMusicInPlayingVoice:Number = 0;
      
      private static var _volumeAdjustOfMusicInPlayingVoice:Number = 1.0;
      
      private static var paused:Boolean;
      
      private static var pausedInApp:Boolean;
      
      private static var musicSound:Sound;
      
      private static var musicChannel:SoundChannel;
      
      private static var musicName:String;
      
      private static var pausedMusicName:String;
      
      private static var musicLoops:int;
      
      private static var pausedMusicPosition:Number;
      
      private static var pausedTransform:SoundTransform;
      
      private static var voicePlayingList:Dictionary = new Dictionary();
      
      private static var effectPlayingList:Dictionary = new Dictionary();
      
      private static var effect_setting:Object = {};
      
      private static var assetManager:AssetManager;
      
      private static var voiceCache:Object = {};
      
      private static var soundEffectCache:Object = {};
      
      private static const emptyByteArray:ByteArray = new ByteArray();
      
      private static var voiceSoundPoolIds:Object = {};
      
      private static var effectSoundPoolIds:Object = {};
      
      private static var musicFinishedCallback:Function;
      
      private static var androidSoundPoolAvailable:int = 0;
       
      
      public function SoundManager()
      {
         super();
         throw new Error("can not create Instance !");
      }
      
      public static function init(param1:AssetManager) : void
      {
         assetManager = param1;
         var _loc3_:Object = assetManager.getObject("effect_setting");
         if(_loc3_)
         {
            for each(var _loc2_ in _loc3_.effect)
            {
               effect_setting[_loc2_.name] = _loc2_.volume;
            }
         }
      }
      
      public static function unloadAllVoice() : void
      {
         if(isAndroidSoundPoolAvailable())
         {
            for each(var _loc1_ in voiceSoundPoolIds)
            {
               SoundPoolExt.instance.unload(_loc1_);
            }
            voiceSoundPoolIds = {};
         }
         voiceCache = {};
      }
      
      public static function unloadAllEffect() : void
      {
         if(isAndroidSoundPoolAvailable())
         {
            for each(var _loc1_ in effectSoundPoolIds)
            {
               SoundPoolExt.instance.unload(_loc1_);
            }
            effectSoundPoolIds = {};
         }
         soundEffectCache = {};
      }
      
      private static function _preloadSound(param1:String, param2:String, param3:Object, param4:Object, param5:Function, param6:Boolean = true) : void
      {
         var name:String = param1;
         var path:String = param2;
         var soundPoolIds:Object = param3;
         var soundCache:Object = param4;
         var callback:Function = param5;
         var useSoundPool:Boolean = param6;
         if(soundCache.hasOwnProperty(name))
         {
            if(callback)
            {
               callback(1);
            }
            return;
         }
         var soundFileCached:File = RsrcManager.getInstance().getCacheDirectory().resolvePath(path);
         var soundFile:File = File.applicationDirectory.resolvePath(path);
         if(useSoundPool && isAndroidSoundPoolAvailable())
         {
            if(soundPoolIds.hasOwnProperty(name))
            {
               if(callback)
               {
                  callback(soundPoolIds[name]);
               }
               return;
            }
            if(soundFileCached.exists)
            {
               if(RsrcManager.getInstance().isValidFileSize(path,soundFileCached.size))
               {
                  soundFile = soundFileCached;
               }
               else
               {
                  try
                  {
                     soundFileCached.deleteFile();
                  }
                  catch(e:Error)
                  {
                  }
               }
            }
            if(soundFile.exists)
            {
               soundFile = copyToCacheDirectory(soundFile,path,function(param1:int):void
               {
                  var ccode:int = param1;
                  if(ccode != 0)
                  {
                     soundPoolIds[name] = -1;
                     if(callback)
                     {
                        callback(-1);
                     }
                     return;
                  }
                  var soundId:int = SoundPoolExt.instance.load(soundFile,function(param1:int):void
                  {
                     soundPoolIds[name] = param1;
                     if(callback)
                     {
                        callback(param1);
                     }
                  });
                  if(soundId <= 0)
                  {
                     soundPoolIds[name] = soundId;
                     if(callback)
                     {
                        callback(soundId);
                     }
                  }
               });
               return;
            }
            RsrcManager.getInstance().download(path,function(param1:String):void
            {
               var url:String = param1;
               var sndFile:File = RsrcManager.getInstance().getCacheDirectory().resolvePath(path);
               if(!sndFile.exists)
               {
                  soundPoolIds[name] = -1;
                  if(callback)
                  {
                     callback(-1);
                  }
               }
               sndFile = copyToCacheDirectory(sndFile,path,function(param1:int):void
               {
                  var ccode:int = param1;
                  if(ccode != 0)
                  {
                     soundPoolIds[name] = -1;
                     if(callback)
                     {
                        callback(-1);
                     }
                     return;
                  }
                  var sndId:int = SoundPoolExt.instance.load(sndFile,function(param1:int):void
                  {
                     soundPoolIds[name] = param1;
                     if(callback)
                     {
                        callback(param1);
                     }
                  });
                  if(sndId <= 0)
                  {
                     soundPoolIds[name] = sndId;
                     if(callback)
                     {
                        callback(sndId);
                     }
                  }
               });
            });
         }
         else
         {
            soundCache[name] = null;
            RsrcManager.getInstance().loadByteArray(path,function(param1:ByteArray):void
            {
               if(param1 == null)
               {
                  if(callback)
                  {
                     callback(-1);
                  }
                  return;
               }
               var _loc2_:Sound = new Sound();
               _loc2_.loadCompressedDataFromByteArray(param1,param1.length);
               soundCache[name] = _loc2_;
               if(callback)
               {
                  callback(1);
               }
            });
         }
      }
      
      private static function getSoundFilePath(param1:String, param2:Function) : void
      {
         var _loc3_:File = RsrcManager.getInstance().getCacheDirectory().resolvePath(param1);
         var _loc4_:File = File.applicationDirectory.resolvePath(param1);
         if(_loc3_.exists)
         {
            if(RsrcManager.getInstance().isValidFileSize(param1,_loc3_.size))
            {
               param2("file://" + _loc3_.nativePath);
               return;
            }
            try
            {
               _loc3_.deleteFile();
            }
            catch(e:Error)
            {
            }
         }
         if(_loc4_.exists)
         {
            param2(param1);
         }
         else
         {
            RsrcManager.getInstance().download(param1,param2);
         }
      }
      
      public static function playMusic(param1:String, param2:int = 0, param3:Number = 0, param4:Function = null) : void
      {
         var name:String = param1;
         var loops:int = param2;
         var startTime:Number = param3;
         var finishCallback:Function = param4;
         if(!gudetama.engine.SoundManager._enableMusic)
         {
            return;
         }
         if(paused || pausedInApp)
         {
            pausedMusicName = name;
            musicLoops = loops;
            pausedMusicPosition = startTime;
            musicName = null;
            return;
         }
         if(name == musicName)
         {
            return;
         }
         if(loops < 0)
         {
            var loops:int = 2147483647;
         }
         musicFinishedCallback = finishCallback;
         var path:String = "rsrc/music/" + name + ".mp3";
         getSoundFilePath(path,function(param1:String):void
         {
            var _loc2_:* = null;
            stopMusic();
            musicSound = new Sound();
            musicSound.load(new URLRequest(param1));
            musicChannel = musicSound.play(startTime,loops);
            musicLoops = loops;
            if(musicChannel)
            {
               musicChannel.addEventListener("soundComplete",onMusicComplete);
               _loc2_ = musicChannel.soundTransform;
               _loc2_.volume = volumeOfMusic * 0.85;
               musicChannel.soundTransform = _loc2_;
               musicName = name;
               _volumeAdjustOfMusic = 1;
               _volumeAdjustOfMusicInPlayingVoice = 1;
            }
            else
            {
               try
               {
                  musicSound.close();
               }
               catch(error:IOError)
               {
               }
            }
         });
      }
      
      private static function onMusicComplete(param1:Event) : void
      {
         if(musicChannel && musicChannel == param1.target as SoundChannel)
         {
            musicChannel = null;
            musicName = null;
            if(musicSound)
            {
               try
               {
                  musicSound.close();
               }
               catch(error:IOError)
               {
               }
               musicSound = null;
            }
            if(musicFinishedCallback)
            {
               musicFinishedCallback();
            }
         }
      }
      
      public static function playMusicId(param1:int, param2:int = 0, param3:Number = 0) : void
      {
         playMusic(param1.toString(),param2,param3);
      }
      
      public static function fadeInMusic(param1:String, param2:Number, param3:int = 0, param4:Number = 0) : void
      {
         _fadeInTimerOfMusicInPlayingVoice = 0;
         _fadeOutTimerOfMusicInPlayingVoice = 0;
         _adjustedMusicPhaseInPlayingVoice = 0;
         _fadeOutTimerOfMusic = 0;
         _fadeInTimerOfMusic = param2;
         _fadeInTotalOfMusic = _fadeInTimerOfMusic;
         playMusic(param1,param3,param4);
      }
      
      public static function fadeOutMusic(param1:Number) : void
      {
         _fadeInTimerOfMusicInPlayingVoice = 0;
         _fadeOutTimerOfMusicInPlayingVoice = 0;
         _adjustedMusicPhaseInPlayingVoice = 0;
         _fadeInTimerOfMusic = 0;
         _fadeOutTimerOfMusic = param1;
         _fadeOutTotalOfMusic = _fadeOutTimerOfMusic;
      }
      
      public static function pauseInApp() : void
      {
         if(paused || pausedInApp)
         {
            return;
         }
         pausedInApp = true;
         var _loc1_:String = musicName;
         pausedMusicName = null;
         pausedMusicPosition = 0;
         if(musicChannel)
         {
            pausedMusicPosition = musicChannel.position;
            pausedTransform = musicChannel.soundTransform;
            try
            {
               musicChannel.stop();
            }
            catch(error:IOError)
            {
               Logger.warn("Couldn\'t close stream_2 ",error.message);
            }
            musicChannel = null;
            pausedMusicName = _loc1_;
         }
         stopVoiceAll();
         stopEffectAll();
         SoundMixer.stopAll();
      }
      
      public static function resumeInApp() : void
      {
         pausedInApp = false;
         if(!paused && pausedMusicName)
         {
            replayMusic(pausedMusicName,musicLoops);
         }
      }
      
      public static function pause() : void
      {
         if(paused || pausedInApp)
         {
            return;
         }
         paused = true;
         var _loc1_:String = musicName;
         pausedMusicName = null;
         pausedMusicPosition = 0;
         if(musicChannel)
         {
            pausedMusicPosition = musicChannel.position;
            pausedTransform = musicChannel.soundTransform;
            try
            {
               musicChannel.stop();
            }
            catch(error:IOError)
            {
               Logger.warn("Couldn\'t close stream_2 ",error.message);
            }
            musicChannel = null;
            pausedMusicName = _loc1_;
         }
         stopVoiceAll();
         stopEffectAll();
         SoundMixer.stopAll();
      }
      
      public static function resume() : void
      {
         paused = false;
         if(!pausedInApp && pausedMusicName)
         {
            replayMusic(pausedMusicName,musicLoops);
         }
      }
      
      public static function stopMusic() : Boolean
      {
         var _loc1_:Boolean = false;
         musicName = null;
         if(musicSound)
         {
            try
            {
               musicSound.close();
            }
            catch(error:IOError)
            {
            }
            musicSound = null;
         }
         if(musicChannel)
         {
            try
            {
               musicChannel.stop();
            }
            catch(error:IOError)
            {
               Logger.warn("Couldn\'t close stream_2 ",error.message);
            }
            musicChannel = null;
            return true;
         }
         return false;
      }
      
      public static function replayMusic(param1:String, param2:int) : void
      {
         var name:String = param1;
         var loops:int = param2;
         var clearPauseParam:Function = function():void
         {
            pausedMusicName = null;
            pausedMusicPosition = 0;
            pausedTransform = null;
         };
         var completionCallback:Function = function(param1:Event):void
         {
            onMusicComplete(param1);
            playMusic(name,loops);
         };
         if(!musicSound)
         {
            playMusic(pausedMusicName,musicLoops);
            clearPauseParam();
            return;
         }
         musicChannel = musicSound.play(pausedMusicPosition,0,pausedTransform);
         if(musicChannel)
         {
            musicChannel.addEventListener("soundComplete",completionCallback);
         }
         clearPauseParam();
         transformMusicVolume();
      }
      
      public static function loadVoice(param1:String, param2:String, param3:Function = null) : void
      {
         _preloadSound(param1,param2,voiceSoundPoolIds,voiceCache,param3,false);
      }
      
      public static function getVoiceId(param1:String) : String
      {
         return param1.substring(param1.lastIndexOf("voice/") + 6,param1.lastIndexOf(".mp3"));
      }
      
      public static function playVoiceQuickly(param1:String, param2:String, param3:int = 0, param4:Number = 0, param5:Function = null) : void
      {
         var id:String = param1;
         var path:String = param2;
         var loops:int = param3;
         var startTime:Number = param4;
         var callback:Function = param5;
         if(paused || pausedInApp || !gudetama.engine.SoundManager._enableVoice)
         {
            return;
         }
         if(loops < 0)
         {
            var loops:int = 0;
         }
         loadVoice(id,path,function(param1:int):void
         {
            var _loc2_:* = null;
            var _loc4_:* = null;
            var _loc3_:* = null;
            if(param1 > 0)
            {
               _loc2_ = voiceCache[id];
               if(_loc2_)
               {
                  if(_loc4_ = _loc2_.play(startTime,loops))
                  {
                     _loc3_ = _loc4_.soundTransform;
                     _loc3_.volume = volumeOfVoice * 1;
                     _loc4_.soundTransform = _loc3_;
                     _loc4_.addEventListener("soundComplete",onVoiceComplete);
                     voicePlayingList[_loc4_] = {
                        "name":id,
                        "subvolume":1
                     };
                     if(callback)
                     {
                        callback(_loc4_);
                     }
                  }
               }
               else if(callback)
               {
                  callback(null);
               }
            }
            else if(callback)
            {
               callback(null);
            }
         });
      }
      
      public static function playVoice(param1:String, param2:Boolean = true, param3:int = 0, param4:Number = 0, param5:Function = null) : void
      {
         var path:String = param1;
         var quickly:Boolean = param2;
         var loops:int = param3;
         var startTime:Number = param4;
         var callback:Function = param5;
         if(paused || pausedInApp || !gudetama.engine.SoundManager._enableVoice)
         {
            return;
         }
         var id:String = getVoiceId(path);
         if(quickly)
         {
            playVoiceQuickly(id,path,loops,startTime,callback);
            return;
         }
         if(loops < 0)
         {
            var loops:int = 0;
         }
         getSoundFilePath(path,function(param1:String):void
         {
            var _loc4_:* = null;
            var _loc3_:Sound = new Sound();
            _loc3_.load(new URLRequest(param1));
            var _loc2_:SoundChannel = _loc3_.play(startTime,loops);
            if(_loc2_)
            {
               _loc2_.addEventListener("soundComplete",onVoiceComplete);
               (_loc4_ = _loc2_.soundTransform).volume = volumeOfVoice * 1;
               _loc2_.soundTransform = _loc4_;
               voicePlayingList[_loc2_] = {"id":id};
               if(callback)
               {
                  callback(_loc2_);
               }
            }
            else
            {
               try
               {
                  _loc3_.close();
               }
               catch(error:IOError)
               {
               }
            }
         });
      }
      
      public static function stopVoiceAll() : void
      {
         var _loc1_:* = undefined;
         for(_loc1_ in voicePlayingList)
         {
            if(_loc1_)
            {
               stopVoice(_loc1_);
            }
         }
      }
      
      public static function stopVoice(param1:*) : void
      {
         var _loc3_:* = null;
         var _loc2_:int = 0;
         if(!param1)
         {
            return;
         }
         if(param1 is SoundChannel)
         {
            _loc3_ = param1 as SoundChannel;
            _loc3_.stop();
            delete voicePlayingList[param1];
         }
         else if(param1 is int)
         {
            _loc2_ = param1 as int;
            SoundPoolExt.instance.stop(_loc2_);
         }
      }
      
      public static function isPlayingVoice(param1:*) : Boolean
      {
         if(!param1)
         {
            return false;
         }
         if(param1 is SoundChannel)
         {
            return voicePlayingList[param1];
         }
         if(param1 is int)
         {
            return false;
         }
         return false;
      }
      
      public static function isPlayingLoudVoice(param1:*) : Boolean
      {
         if(!param1)
         {
            return false;
         }
         if(param1 is SoundChannel)
         {
            return param1.leftPeak + param1.rightPeak > 0.01;
         }
         if(param1 is int)
         {
            return false;
         }
         return false;
      }
      
      public static function hasVoicePlayingList() : Boolean
      {
         var _loc3_:int = 0;
         var _loc2_:* = voicePlayingList;
         for(var _loc1_ in _loc2_)
         {
            return true;
         }
         return false;
      }
      
      private static function onVoiceComplete(param1:Event) : void
      {
         if(param1.target as SoundChannel in voicePlayingList)
         {
            delete voicePlayingList[param1.target];
         }
      }
      
      public static function loadEffect(param1:String, param2:Function = null) : void
      {
         var _loc3_:String = "rsrc/sound/" + param1 + ".mp3";
         _preloadSound(param1,_loc3_,effectSoundPoolIds,soundEffectCache,param2);
      }
      
      public static function loadEffectForTask(param1:TaskQueue, param2:String, param3:Function = null) : void
      {
         var queue:TaskQueue = param1;
         var name:String = param2;
         var callback:Function = param3;
         queue.addTask(function():void
         {
            var path:String = "rsrc/sound/" + name + ".mp3";
            _preloadSound(name,path,effectSoundPoolIds,soundEffectCache,function(param1:int):void
            {
               queue.taskDone();
               if(callback)
               {
                  callback(param1);
               }
            });
         });
      }
      
      public static function playEffect(param1:String, param2:int = 0, param3:Number = 0, param4:Function = null, param5:Number = 1) : void
      {
         if(paused || pausedInApp || !gudetama.engine.SoundManager._enableEffect)
         {
            return;
         }
         if(param1 == null || param1 == "")
         {
            return;
         }
         if(param2 < 0)
         {
            param2 = 0;
         }
         if(isAndroidSoundPoolAvailable())
         {
            playEffectAndroid(param1,param2,param4,param5);
         }
         else
         {
            playEffectOther(param1,param2,param3,param4,param5);
         }
      }
      
      private static function playEffectAndroid(param1:String, param2:int, param3:Function, param4:Number) : void
      {
         var name:String = param1;
         var loops:int = param2;
         var callback:Function = param3;
         var volumeRate:Number = param4;
         var subvol:Number = 1;
         if(name in effect_setting)
         {
            subvol = effect_setting[name];
         }
         var vol:Number = volumeOfEffect * 1 * subvol * volumeRate;
         if(effectSoundPoolIds.hasOwnProperty(name))
         {
            var soundId:int = effectSoundPoolIds[name];
            if(soundId > 0)
            {
               var streamId:int = SoundPoolExt.instance.play(soundId,vol,vol,loops);
               effectPlayingList[streamId] = streamId;
               if(callback)
               {
                  callback(streamId);
               }
            }
         }
         else
         {
            loadEffect(name,function(param1:int):void
            {
               var _loc2_:int = 0;
               if(param1 > 0)
               {
                  _loc2_ = SoundPoolExt.instance.play(param1,vol,vol,loops);
                  effectPlayingList[_loc2_] = _loc2_;
                  if(callback)
                  {
                     callback(_loc2_);
                  }
               }
            });
         }
      }
      
      private static function playEffectOther(param1:String, param2:int, param3:int, param4:Function, param5:Number) : void
      {
         var name:String = param1;
         var loops:int = param2;
         var startTime:int = param3;
         var callback:Function = param4;
         var volumeRate:Number = param5;
         loadEffect(name,function(param1:int):void
         {
            var _loc2_:* = null;
            var _loc4_:* = null;
            var _loc3_:* = null;
            var _loc5_:* = NaN;
            if(param1 > 0)
            {
               _loc2_ = soundEffectCache[name];
               if(_loc2_)
               {
                  if(_loc4_ = _loc2_.play(startTime,loops))
                  {
                     _loc3_ = _loc4_.soundTransform;
                     _loc5_ = 1;
                     if(name in effect_setting)
                     {
                        _loc5_ = Number(effect_setting[name]);
                     }
                     _loc3_.volume = volumeOfEffect * 1 * _loc5_ * volumeRate;
                     _loc4_.soundTransform = _loc3_;
                     _loc4_.addEventListener("soundComplete",onEffectComplete);
                     effectPlayingList[_loc4_] = {
                        "name":name,
                        "subvolume":_loc5_,
                        "soundObj":_loc4_
                     };
                     if(callback)
                     {
                        callback(_loc4_);
                     }
                  }
               }
            }
         });
      }
      
      private static function onEffectComplete(param1:Event) : void
      {
         if(param1.target as SoundChannel in effectPlayingList)
         {
            delete effectPlayingList[param1.target];
         }
      }
      
      public static function stopEffectAll() : void
      {
         var _loc1_:* = undefined;
         for(_loc1_ in effectPlayingList)
         {
            if(_loc1_)
            {
               stopEffect(_loc1_);
            }
         }
      }
      
      public static function stopEffect(param1:*) : void
      {
         var _loc3_:* = null;
         var _loc2_:int = 0;
         if(!param1)
         {
            return;
         }
         if(param1 is SoundChannel)
         {
            _loc3_ = param1 as SoundChannel;
            _loc3_.stop();
            delete effectPlayingList[param1];
         }
         else if(param1 is int)
         {
            _loc2_ = param1 as int;
            SoundPoolExt.instance.stop(_loc2_);
         }
         else if(param1.soundObj is SoundChannel)
         {
            _loc3_ = param1.soundObj as SoundChannel;
            _loc3_.stop();
            delete effectPlayingList[param1.soundObj];
         }
      }
      
      private static function copyToCacheDirectory(param1:File, param2:String, param3:Function = null) : File
      {
         var file:File = param1;
         var path:String = param2;
         var callback:Function = param3;
         var onComplete:* = function(param1:Event):void
         {
            if(callback)
            {
               callback(0);
            }
         };
         var onError:* = function(param1:IOErrorEvent):void
         {
            if(callback)
            {
               callback(param1.errorID);
            }
         };
         if(file.nativePath == "")
         {
            var newFile:File = RsrcManager.getInstance().getCacheDirectory().resolvePath(path);
            if(!newFile.exists)
            {
               file.addEventListener("complete",onComplete);
               file.addEventListener("ioError",onError);
               file.copyToAsync(newFile,true);
            }
            return newFile;
         }
         if(callback)
         {
            callback(0);
         }
         return file;
      }
      
      private static function isAndroidSoundPoolAvailable() : Boolean
      {
         var _loc1_:* = null;
         switch(int(androidSoundPoolAvailable))
         {
            case 0:
               var _loc2_:* = Engine;
               if(gudetama.engine.Engine.platform == 1)
               {
                  _loc1_ = DataStorage.getLocalData();
                  if(_loc1_ && !_loc1_.isUseSoundPool())
                  {
                     androidSoundPoolAvailable = 2;
                     return false;
                  }
                  SoundPoolExt.instance;
                  androidSoundPoolAvailable = !!SoundPoolExt.isUsable() ? 1 : 2;
                  return androidSoundPoolAvailable == 1;
               }
               androidSoundPoolAvailable = 2;
               return false;
               break;
            case 1:
               return true;
            case 2:
               return false;
            default:
               return false;
         }
      }
      
      public static function get musicVolume() : Number
      {
         return volumeOfMusic;
      }
      
      public static function set musicVolume(param1:Number) : void
      {
         volumeOfMusic = Math.min(param1,1);
         transformMusicVolume();
      }
      
      public static function getplayingMusicName() : String
      {
         return musicName;
      }
      
      private static function transformMusicVolume() : void
      {
         var _loc1_:* = null;
         if(musicChannel)
         {
            _loc1_ = musicChannel.soundTransform;
            _loc1_.volume = volumeOfMusic * 0.85 * _volumeAdjustOfMusic * _volumeAdjustOfMusicInPlayingVoice;
            musicChannel.soundTransform = _loc1_;
         }
      }
      
      public static function get voiceVolume() : Number
      {
         return volumeOfVoice;
      }
      
      public static function set voiceVolume(param1:Number) : void
      {
         var _loc4_:* = null;
         var _loc5_:* = NaN;
         var _loc3_:* = null;
         volumeOfVoice = Math.min(param1,1);
         for(var _loc2_ in voicePlayingList)
         {
            _loc4_ = _loc2_.soundTransform;
            _loc5_ = 1;
            _loc3_ = voicePlayingList[_loc2_];
            if(_loc3_.hasOwnProperty("subvolume"))
            {
               _loc5_ = Number(Math.min(_loc3_.subvolume,1));
            }
            _loc4_.volume = volumeOfVoice * 1 * _loc5_;
            _loc2_.soundTransform = _loc4_;
         }
      }
      
      public static function get enableMusic() : Boolean
      {
         return _enableMusic;
      }
      
      public static function set enableMusic(param1:Boolean) : void
      {
         _enableMusic = param1;
      }
      
      public static function get enableEffect() : Boolean
      {
         return _enableEffect;
      }
      
      public static function set enableEffect(param1:Boolean) : void
      {
         _enableEffect = param1;
      }
      
      public static function get enableVoice() : Boolean
      {
         return _enableVoice;
      }
      
      public static function set enableVoice(param1:Boolean) : void
      {
         _enableVoice = param1;
      }
      
      public static function get effectVolume() : Number
      {
         return volumeOfEffect;
      }
      
      public static function set effectVolume(param1:Number) : void
      {
         volumeOfEffect = Math.min(param1,1);
      }
      
      public static function advanceTime(param1:Number) : void
      {
         var _loc2_:Number = NaN;
         if(hasVoicePlayingList() && _adjustedMusicPhaseInPlayingVoice == 0)
         {
            _fadeInTimerOfMusic = 0;
            _fadeOutTimerOfMusic = 0;
            _fadeInTimerOfMusicInPlayingVoice = 0;
            _fadeOutTimerOfMusicInPlayingVoice = 0.2;
            _fadeOutTotalOfMusicInPlayingVoice = _fadeOutTimerOfMusicInPlayingVoice;
            _adjustedMusicPhaseInPlayingVoice = 1;
         }
         else if(!hasVoicePlayingList() && _adjustedMusicPhaseInPlayingVoice == 1)
         {
            _fadeInTimerOfMusic = 0;
            _fadeOutTimerOfMusic = 0;
            _fadeOutTimerOfMusicInPlayingVoice = 0;
            _fadeInTimerOfMusicInPlayingVoice = 0.2;
            _fadeInTotalOfMusicInPlayingVoice = _fadeInTimerOfMusicInPlayingVoice;
            _adjustedMusicPhaseInPlayingVoice = 2;
         }
         if(_fadeOutTimerOfMusicInPlayingVoice > 0)
         {
            _fadeOutTimerOfMusicInPlayingVoice -= param1;
            _loc2_ = Math.max(0,_fadeOutTimerOfMusicInPlayingVoice / _fadeOutTotalOfMusicInPlayingVoice);
            _volumeAdjustOfMusicInPlayingVoice = 0.2 + (1 - 0.2) * _loc2_;
            transformMusicVolume();
         }
         else if(_fadeInTimerOfMusicInPlayingVoice > 0)
         {
            _fadeInTimerOfMusicInPlayingVoice -= param1;
            if(_fadeInTimerOfMusicInPlayingVoice <= 0)
            {
               _adjustedMusicPhaseInPlayingVoice = 0;
            }
            _loc2_ = 1 - Math.max(0,_fadeInTimerOfMusicInPlayingVoice / _fadeInTotalOfMusicInPlayingVoice);
            _volumeAdjustOfMusicInPlayingVoice = 0.2 + (1 - 0.2) * _loc2_;
            transformMusicVolume();
         }
         else if(_fadeOutTimerOfMusic > 0)
         {
            _fadeOutTimerOfMusic -= param1;
            if(_fadeOutTimerOfMusic <= 0)
            {
               stopMusic();
            }
            _volumeAdjustOfMusic = Math.max(0,_fadeOutTimerOfMusic / _fadeOutTotalOfMusic);
            transformMusicVolume();
         }
         else if(_fadeInTimerOfMusic > 0)
         {
            _fadeInTimerOfMusic -= param1;
            _volumeAdjustOfMusic = 1 - Math.max(0,_fadeInTimerOfMusic / _fadeInTotalOfMusic);
            transformMusicVolume();
         }
      }
   }
}
