package muku.display
{
   import flash.filesystem.File;
   import gudetama.data.UserDataWrapper;
   import gudetama.engine.Logger;
   import gudetama.engine.RsrcManager;
   import muku.core.MukuGlobal;
   import starling.core.Starling;
   import starling.display.Sprite;
   
   public class MoviePlayer extends Sprite
   {
       
      
      private var forceFinishTime:Number;
      
      private var resourceName:String;
      
      private var movie:Movie;
      
      private var readyCallback:Function;
      
      private var callback:Function;
      
      public function MoviePlayer(param1:Number = 15.0)
      {
         super();
         touchable = MukuGlobal.isBuilderMode();
         this.forceFinishTime = param1;
      }
      
      public static function isSmallMovie(param1:String) : Boolean
      {
         return File.applicationDirectory.resolvePath(MukuGlobal.makePathFromName(param1 + "_s",".mp4")).exists;
      }
      
      override public function dispose() : void
      {
         if(movie)
         {
            movie.dispose();
            movie = null;
         }
         super.dispose();
         readyCallback = null;
         callback = null;
         Logger.debug("MoviePlayer dispose() uid : {} resourceName : {}",UserDataWrapper.wrapper.getUid(),resourceName);
      }
      
      public function getPlayTime() : Number
      {
         return !!movie ? movie.getPlayTime() : 0;
      }
      
      public function getTime() : Number
      {
         return !!movie ? movie.getTime() : 0;
      }
      
      public function isPlaying() : Boolean
      {
         if(!movie)
         {
            return false;
         }
         return movie.isPlaying();
      }
      
      public function setReadyCallback(param1:Function) : void
      {
         if(movie)
         {
            movie.readyCallback = param1;
         }
         else
         {
            readyCallback = param1;
         }
      }
      
      public function setFinishedCallback(param1:Function) : void
      {
         if(movie)
         {
            movie.finishedCallback = param1;
         }
         else
         {
            this.callback = param1;
         }
      }
      
      public function setup(param1:String, param2:Boolean = false) : Boolean
      {
         var _loc6_:* = null;
         var _loc5_:* = null;
         var _loc4_:* = null;
         var _loc3_:* = null;
         if(!param2)
         {
            _loc6_ = File.applicationDirectory;
            _loc5_ = RsrcManager.getInstance().getCacheDirectory();
            _loc4_ = MukuGlobal.makePathFromName(param1 + "_s",".mp4");
            _loc3_ = MukuGlobal.makePathFromName(param1,".mp4");
            if(_loc6_.resolvePath(_loc4_).exists)
            {
               resourceName = _loc4_;
               movie = new Mp4S(this,resourceName);
            }
            else if(_loc5_.resolvePath(_loc4_).exists)
            {
               resourceName = _loc5_.resolvePath(_loc4_).url#2;
               movie = new Mp4S(this,resourceName);
            }
            else if(_loc6_.resolvePath(_loc3_).exists)
            {
               resourceName = _loc3_;
               movie = new Mp4(this,resourceName);
            }
            else
            {
               if(!_loc5_.resolvePath(_loc3_).exists)
               {
                  Logger.error("not found resource video file : {} !!!",param1);
                  return false;
               }
               resourceName = _loc5_.resolvePath(_loc3_).url#2;
               movie = new Mp4(this,resourceName);
            }
            movie.connect();
         }
         else
         {
            resourceName = param1;
         }
         visible = false;
         if(!movie.readyCallback)
         {
            movie.readyCallback = readyCallback;
         }
         if(!movie.finishedCallback)
         {
            movie.finishedCallback = callback;
         }
         if(movie is Mp4)
         {
            (movie as Mp4).setForceStopCallback(forceStop,forceFinishTime);
         }
         Logger.debug("MoviePlayer setup(path) uid : {} resourceName : {}",UserDataWrapper.wrapper.getUid(),resourceName);
         return movie is Mp4S;
      }
      
      public function play(param1:Object = null) : void
      {
         if(!movie)
         {
            return;
         }
         Logger.debug("MoviePlayer play() uid : {} resourceName : {}",UserDataWrapper.wrapper.getUid(),resourceName);
         if(!resourceName)
         {
            return;
         }
         visible = true;
         alpha = 1;
         movie.play(param1);
         setRequiresRedraw();
      }
      
      public function forceStop() : void
      {
         if(!movie)
         {
            return;
         }
         Logger.debug("MoviePlayer forceStop() uid : {} resourceName : {}",UserDataWrapper.wrapper.getUid(),resourceName);
         visible = false;
         movie.stop();
         var _loc1_:* = Starling;
         if((!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).contains(movie))
         {
            var _loc2_:* = Starling;
            (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).remove(movie);
         }
      }
      
      public function debugStop() : void
      {
         visible = false;
         movie.stop();
      }
      
      public function get resource() : String
      {
         return resourceName;
      }
      
      public function set resource(param1:String) : void
      {
         if(resourceName == param1)
         {
            return;
         }
         resourceName = param1;
         if(!resourceName || resourceName == "" || resourceName == "null")
         {
            return;
         }
         if(MukuGlobal.isBuilderMode())
         {
            setup(resourceName);
         }
      }
   }
}

import flash.events.AsyncErrorEvent;
import flash.events.NetStatusEvent;
import flash.filesystem.File;
import flash.media.SoundTransform;
import flash.net.NetConnection;
import flash.net.NetStream;
import gudetama.engine.Engine;
import gudetama.engine.Logger;
import muku.display.MoviePlayer;
import starling.animation.IAnimatable;
import starling.core.Starling;
import starling.events.Event;
import starling.events.EventDispatcher;

class Movie extends EventDispatcher implements IAnimatable
{
   
   public static const SETUP_COMPETED:String = "setup_completed";
   
   public static const RECONNECT_EVENT:String = "reconnect_event";
   
   protected static const ASPECT_RATIO:Number = 1.7142857142857142;
    
   
   protected var netConnection:NetConnection;
   
   protected var netStream:NetStream;
   
   protected var duration:Number;
   
   protected var started:Boolean;
   
   protected var player:MoviePlayer;
   
   private var sound:SoundTransform;
   
   protected var resourceName:String;
   
   protected var seekPoints:Vector.<Number>;
   
   public var readyCallback:Function;
   
   public var finishedCallback:Function;
   
   protected var quickPlay:Boolean;
   
   protected var playing:Boolean;
   
   protected var forceStopCallback:Function;
   
   protected var forceFinishTime:Number;
   
   private var reconnectCounter:int;
   
   function Movie(param1:MoviePlayer, param2:String, param3:Boolean)
   {
      super();
      this.player = param1;
      this.quickPlay = param3;
      this.resourceName = param2;
      reconnectCounter = 0;
   }
   
   public function connect() : void
   {
      netConnection = new NetConnection();
      netConnection.addEventListener("netStatus",createSetupFunction);
      netConnection.connect(null);
      addEventListener("reconnect_event",reconnect);
   }
   
   public function reconnect(param1:Event) : void
   {
      reconnectCounter++;
      removeEventListener("reconnect_event",reconnect);
      Logger.debug("MoviePlayer reconnect. resourceName:{} quickPlay:{}",resourceName,quickPlay);
      if(forceStopCallback)
      {
         var _loc2_:* = Starling;
         (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).removeDelayedCalls(forceStopCallback);
      }
      dispose(true);
      connect();
      if(forceStopCallback)
      {
         setForceStopCallback(forceStopCallback,forceFinishTime);
      }
   }
   
   public function dispose(param1:Boolean = false) : void
   {
      if(netStream)
      {
         netStream.close();
         netStream.dispose();
         netStream.removeEventListener("asyncError",asyncErrorHandler);
         netStream.removeEventListener("netStatus",statusHandler);
         netStream = null;
         netConnection.close();
         netConnection.removeEventListener("netStatus",createSetupFunction);
         netConnection = null;
      }
      sound = null;
      removeEventListeners();
      started = false;
      seekPoints = null;
      if(!param1)
      {
         readyCallback = null;
         forceStopCallback = null;
      }
   }
   
   public function createSetupFunction(param1:NetStatusEvent) : void
   {
   }
   
   public function play(param1:Object = null) : void
   {
      started = true;
      var _loc2_:* = Starling;
      (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).add(this);
      var _loc3_:* = Starling;
      (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).delayCall(stop,duration + 1);
   }
   
   public function stop() : void
   {
      if(!player)
      {
         return;
      }
      player = null;
      started = false;
      var _loc1_:* = Starling;
      (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).remove(this);
      var _loc2_:* = Starling;
      (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).removeDelayedCalls(stop);
      playing = false;
      if(finishedCallback)
      {
         finishedCallback();
      }
   }
   
   public function advanceTime(param1:Number) : void
   {
      if(!update())
      {
         if(started)
         {
            stop();
         }
      }
   }
   
   protected function update() : Boolean
   {
      if(!netStream)
      {
         return false;
      }
      return netStream.time < duration && started;
   }
   
   public function getTime() : Number
   {
      if(!netStream)
      {
         return 0;
      }
      return netStream.time;
   }
   
   protected function playNetStream() : void
   {
      var _loc1_:* = null;
      netStream.addEventListener("asyncError",asyncErrorHandler);
      netStream.addEventListener("netStatus",statusHandler);
      var _loc2_:* = Engine;
      if(gudetama.engine.Engine.platform == 1 || gudetama.engine.Engine.platform == 0)
      {
         Logger.debug("MoviePlayer playNetStream. resourceName:{} quickPlay:{}",resourceName,quickPlay);
         netStream.play(resourceName);
      }
      else
      {
         if(resourceName.charAt(0) != "/")
         {
            _loc1_ = File.applicationDirectory.resolvePath(resourceName);
         }
         else
         {
            _loc1_ = File(resourceName);
         }
         netStream.play(_loc1_.url#2);
      }
   }
   
   protected function changeVolume(param1:Number) : void
   {
      sound = netStream.soundTransform;
      sound.volume = param1;
      netStream.soundTransform = sound;
   }
   
   protected function seek(param1:Number) : void
   {
      var _loc2_:* = Engine;
      if(gudetama.engine.Engine.platform == 0)
      {
         netStream.seek(param1);
      }
      else
      {
         netStream.seek(seekPoints[param1]);
      }
   }
   
   public function isPlaying() : Boolean
   {
      return playing;
   }
   
   public function getPlayTime() : Number
   {
      return duration;
   }
   
   public function onXMPData(param1:Object) : void
   {
   }
   
   public function onMetaData(param1:Object) : void
   {
      onSeekPoint(param1.seekpoints);
      duration = param1.duration;
   }
   
   public function onPlayStatus(param1:Object) : void
   {
   }
   
   public function onSeekPoint(param1:Array) : void
   {
   }
   
   protected function asyncErrorHandler(param1:AsyncErrorEvent) : void
   {
      Logger.warn("!!! asyncErrorHandler !!! {} {}",param1.errorID,param1.error.message);
   }
   
   protected function statusHandler(param1:NetStatusEvent) : void
   {
      switch(param1.info.code)
      {
         case "NetStream.Play.Start":
            Logger.debug(param1.info.code);
            playing = true;
            break;
         case "NetStream.Play.Stop":
            if(started)
            {
               stop();
            }
            Logger.debug(param1.info.code);
            playing = false;
            break;
         case "NetStream.Buffer.Full":
            Logger.debug(param1.info.code);
            break;
         default:
            Logger.debug(param1.info.code);
      }
   }
   
   public function setForceStopCallback(param1:Function, param2:int) : void
   {
      forceStopCallback = param1;
      forceFinishTime = param2;
      var _loc3_:* = Starling;
      (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).delayCall(forceStopCallback,forceFinishTime);
   }
}

import flash.events.NetStatusEvent;
import flash.net.NetStream;
import gudetama.engine.Engine;
import gudetama.engine.Logger;
import muku.display.MoviePlayer;
import starling.core.Starling;
import starling.display.Image;
import starling.textures.Texture;

class Mp4 extends Movie
{
    
   
   private var image:Image;
   
   private var texture:Texture;
   
   private var trimData:Object;
   
   function Mp4(param1:MoviePlayer, param2:String, param3:Boolean = false)
   {
      super(param1,param2,param3);
   }
   
   override public function dispose(param1:Boolean = false) : void
   {
      super.dispose(param1);
      if(texture)
      {
         texture.dispose();
         texture = null;
      }
      if(image)
      {
         image.removeFromParent(true);
         image = null;
      }
      seekPoints = null;
      trimData = null;
   }
   
   override public function createSetupFunction(param1:NetStatusEvent) : void
   {
      var event:NetStatusEvent = param1;
      if(event.info.code != "NetConnection.Connect.Success")
      {
         return;
      }
      var _this:Mp4 = this;
      netStream = new NetStream(netConnection);
      netStream.client = _this;
      changeVolume(0);
      var _loc3_:* = Starling;
      starling.core.Starling.sCurrent.juggler.delayCall(function():void
      {
         if(!image)
         {
            dispatchEventWith("reconnect_event");
         }
         else
         {
            removeEventListener("reconnect_event",reconnect);
         }
      },1.5);
      texture = Texture.fromNetStream(netStream,1,function():void
      {
         image = new Image(texture);
         image.touchable = false;
         image.blendMode = "none";
         image.rotation = 3.141592653589793 * 0.5;
         image.readjustSize();
         player.addChild(image);
         var _loc1_:* = Engine;
         image.scale = gudetama.engine.Engine.designHeight / image.height;
         var _loc2_:* = Engine;
         player.x = 0.5 * gudetama.engine.Engine.designWidth + 0.5 * image.width;
         var _loc3_:* = Engine;
         player.y = 0.5 * gudetama.engine.Engine.designHeight - 0.5 * image.height;
         Logger.debug("MoviePlayer Mp4 NetConnection.Connect.Success && Texture.fromNetStream success. resourceName:{} quickPlay:{}",resourceName,quickPlay);
         if(!quickPlay)
         {
            changeVolume(0);
            Logger.debug("MoviePlayer netStream playing1 : {}",playing);
            netStream.pause();
         }
         else
         {
            play();
         }
         if(forceStopCallback)
         {
            var _loc4_:* = Starling;
            (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).removeDelayedCalls(forceStopCallback);
         }
         if(readyCallback)
         {
            readyCallback();
         }
      });
      changeVolume(0);
      playNetStream();
      changeVolume(0);
   }
   
   override protected function update() : Boolean
   {
      if(!netStream)
      {
         return false;
      }
      if(trimData && trimData.cutTime <= netStream.time)
      {
         netStream.togglePause();
         var _loc1_:* = Engine;
         if(gudetama.engine.Engine.platform == 0)
         {
            netStream.seek(trimData.seekTime);
         }
         else
         {
            netStream.seek(seekPoints[trimData.seekTime * 10]);
         }
         netStream.togglePause();
         trimData = null;
      }
      return netStream.time < duration && started;
   }
   
   override public function play(param1:Object = null) : void
   {
      super.play();
      this.trimData = param1;
      changeVolume(1);
      if(!quickPlay)
      {
         netStream.resume();
      }
   }
   
   override public function onSeekPoint(param1:Array) : void
   {
      var _loc2_:* = null;
      if(param1 && !seekPoints)
      {
         seekPoints = new Vector.<Number>();
         for each(_loc2_ in param1)
         {
            seekPoints.push(_loc2_.time);
         }
      }
   }
}

import flash.events.NetStatusEvent;
import flash.net.NetStream;
import gudetama.engine.Engine;
import gudetama.engine.Logger;
import muku.display.MoviePlayer;
import starling.core.Starling;
import starling.display.Image;
import starling.textures.Texture;

class Mp4S extends Movie
{
    
   
   private var image:Image;
   
   private var texture:Texture;
   
   function Mp4S(param1:MoviePlayer, param2:String, param3:Boolean = false)
   {
      super(param1,param2,param3);
   }
   
   override public function dispose(param1:Boolean = false) : void
   {
      super.dispose(param1);
      if(texture)
      {
         texture.dispose();
         texture = null;
      }
      if(image)
      {
         image.removeFromParent(true);
         image = null;
      }
   }
   
   override public function onSeekPoint(param1:Array) : void
   {
      var _loc2_:* = null;
      if(param1 && !seekPoints)
      {
         seekPoints = new Vector.<Number>();
         for each(_loc2_ in param1)
         {
            seekPoints.push(_loc2_.time);
         }
      }
   }
   
   override public function createSetupFunction(param1:NetStatusEvent) : void
   {
      var event:NetStatusEvent = param1;
      var _this:Mp4S = this;
      if(event.info.code != "NetConnection.Connect.Success")
      {
         return;
      }
      netStream = new NetStream(netConnection);
      netStream.client = _this;
      var _loc3_:* = Starling;
      starling.core.Starling.sCurrent.juggler.delayCall(function():void
      {
         if(!image)
         {
            dispatchEventWith("reconnect_event");
         }
         else
         {
            removeEventListener("reconnect_event",reconnect);
         }
      },1.5);
      texture = Texture.fromNetStream(netStream,1,function():void
      {
         if(player == null)
         {
            return;
         }
         image = new Image(texture);
         image.touchable = false;
         image.blendMode = "auto";
         image.readjustSize();
         player.addChild(image);
         var _loc1_:* = Engine;
         player.x = -gudetama.engine.Engine.designWidthMargin + image.width / 2;
         player.y = 200 + image.height / 2;
         player.pivotX = image.width / 2;
         player.pivotY = image.height / 2;
         Logger.debug("MoviePlayer Mp4S NetConnection.Connect.Success && Texture.fromNetStream success. resourceName:{} quickPlay:{}",resourceName,quickPlay);
         dispatchEventWith("setup_completed");
         if(!quickPlay)
         {
            changeVolume(0);
            netStream.pause();
         }
         else
         {
            play();
         }
         if(readyCallback)
         {
            readyCallback();
         }
      });
      changeVolume(0);
      playNetStream();
      changeVolume(0);
   }
   
   override public function play(param1:Object = null) : void
   {
      super.play();
      changeVolume(1);
      if(!quickPlay)
      {
         netStream.resume();
      }
   }
   
   override public function stop() : void
   {
      if(finishedCallback)
      {
         finishedCallback();
      }
      started = false;
      var _loc1_:* = Starling;
      (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).remove(this);
      var _loc2_:* = Starling;
      (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).removeDelayedCalls(stop);
      player = null;
   }
}
