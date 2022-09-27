package gudetama.engine
{
   import starling.display.DisplayObjectContainer;
   
   public class TransitionEffect
   {
      
      public static const TYPE_NONE:int = 0;
      
      public static const TYPE_FADE:int = 1;
      
      public static const TYPE_WIPE:int = 2;
      
      public static const TYPE_KITCHENWARE_CHANGE:int = 3;
      
      public static const TYPE_FADE_INVERT:int = 6;
      
      public static const MAX:int = 7;
       
      
      public var priority:Boolean;
      
      protected var displaySprite;
      
      public function TransitionEffect()
      {
         super();
      }
      
      public static function factory(param1:int) : TransitionEffect
      {
         switch(int(param1))
         {
            case 0:
               return new TransitionEffect();
            case 1:
               return new FadeEffect();
            case 2:
               return new WipeEffect();
            case 3:
               return new TransitionEffect();
            case 6:
               return new FadeEffect(true);
            default:
               return new FadeEffect();
         }
      }
      
      public function setup() : void
      {
      }
      
      public function finish(param1:DisplayObjectContainer) : void
      {
      }
      
      public function isManual() : Boolean
      {
         return false;
      }
      
      public function close(param1:DisplayObjectContainer, param2:Function) : void
      {
         if(param2)
         {
            param2();
         }
      }
      
      public function open(param1:DisplayObjectContainer, param2:Function = null) : void
      {
         if(param2)
         {
            param2();
         }
      }
      
      public function openWithDelay(param1:DisplayObjectContainer, param2:Number, param3:Function = null) : void
      {
         if(param3)
         {
            param3();
         }
      }
      
      public function closeManual(param1:DisplayObjectContainer, param2:Function) : void
      {
         if(param2)
         {
            param2();
         }
      }
      
      public function openManual(param1:DisplayObjectContainer, param2:Function = null) : void
      {
         if(param2)
         {
            param2();
         }
      }
      
      public function openWithDelayManual(param1:DisplayObjectContainer, param2:Number, param3:Function = null) : void
      {
         if(param3)
         {
            param3();
         }
      }
   }
}

import gudetama.engine.Engine;
import gudetama.engine.TransitionEffect;
import muku.display.TextureMaskStyle;
import starling.animation.Tween;
import starling.core.Starling;
import starling.display.DisplayObjectContainer;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;

class WipeEffect extends TransitionEffect
{
    
   
   private var scaleUpTween:Tween;
   
   private var scaleDownTween:Tween;
   
   private var maskeeImage:Image;
   
   function WipeEffect()
   {
      super();
   }
   
   override public function finish(param1:DisplayObjectContainer) : void
   {
      param1.mask = null;
      maskeeImage.touchable = false;
   }
   
   override public function setup() : void
   {
      displaySprite = new Sprite();
      displaySprite.mask = new Quad(700,1136);
      maskeeImage = new Image(Engine.assetManager.getTexture("assets-wipe"));
      maskeeImage.touchable = false;
      var _loc2_:* = Engine;
      var _loc3_:* = Engine;
      maskeeImage.x = gudetama.engine.Engine._sceneX + gudetama.engine.Engine.designWidth / 2;
      var _loc4_:* = Engine;
      var _loc5_:* = Engine;
      maskeeImage.y = gudetama.engine.Engine._sceneY + gudetama.engine.Engine.designHeight / 2;
      maskeeImage.pivotX = maskeeImage.width / 2;
      maskeeImage.pivotY = maskeeImage.height / 2 + 20;
      maskeeImage.scale = 0;
      var _loc1_:TextureMaskStyle = new TextureMaskStyle();
      maskeeImage.style = _loc1_;
      (displaySprite as Sprite).addChild(maskeeImage);
      scaleUpTween = new Tween(maskeeImage,0.7,"easeInSine");
      scaleDownTween = new Tween(maskeeImage,0.7,"easeOutSine");
   }
   
   override public function close(param1:DisplayObjectContainer, param2:Function) : void
   {
      var obj:DisplayObjectContainer = param1;
      var callback:Function = param2;
      var _loc3_:* = Starling;
      starling.core.Starling.sCurrent.skipUnchangedFrames = false;
      var _loc4_:* = Engine;
      var _loc5_:* = Engine;
      maskeeImage.x = gudetama.engine.Engine._sceneX + gudetama.engine.Engine.designWidth / 2;
      var _loc6_:* = Engine;
      var _loc7_:* = Engine;
      maskeeImage.y = gudetama.engine.Engine._sceneY + gudetama.engine.Engine.designHeight / 2;
      maskeeImage.scaleX = 25;
      maskeeImage.scaleY = 25;
      maskeeImage.touchable = true;
      obj.mask = maskeeImage;
      scaleUpTween.forceFinish();
      scaleDownTween.reset(maskeeImage,0.7,"easeOutSine");
      scaleDownTween.scaleTo(0);
      scaleDownTween.onComplete = function():void
      {
         if(callback)
         {
            callback();
         }
         scaleDownTween.onComplete = null;
      };
      Engine.tweenJuggler.add(scaleDownTween);
   }
   
   override public function open(param1:DisplayObjectContainer, param2:Function = null) : void
   {
      var obj:DisplayObjectContainer = param1;
      var callback:Function = param2;
      var _loc3_:* = Starling;
      starling.core.Starling.sCurrent.skipUnchangedFrames = false;
      var _loc4_:* = Engine;
      var _loc5_:* = Engine;
      maskeeImage.x = gudetama.engine.Engine._sceneX + gudetama.engine.Engine.designWidth / 2;
      var _loc6_:* = Engine;
      var _loc7_:* = Engine;
      maskeeImage.y = gudetama.engine.Engine._sceneY + gudetama.engine.Engine.designHeight / 2;
      maskeeImage.scale = 0;
      maskeeImage.touchable = false;
      obj.mask = maskeeImage;
      scaleDownTween.forceFinish();
      scaleUpTween.reset(maskeeImage,0.7,"easeInSine");
      scaleUpTween.scaleTo(25);
      scaleUpTween.onComplete = function():void
      {
         obj.mask = null;
         if(callback)
         {
            callback();
         }
         scaleUpTween.onComplete = null;
      };
      Engine.tweenJuggler.add(scaleUpTween);
   }
   
   override public function openWithDelay(param1:DisplayObjectContainer, param2:Number, param3:Function = null) : void
   {
      var obj:DisplayObjectContainer = param1;
      var delay:Number = param2;
      var callback:Function = param3;
      maskeeImage.scale = 0;
      var _loc4_:* = Starling;
      (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).delayCall(function():void
      {
         scaleUpTween.reset(maskeeImage,0.7,"easeInSine");
         scaleUpTween.scaleTo(25);
         scaleUpTween.onComplete = function():void
         {
            obj.mask = null;
            if(callback)
            {
               callback();
            }
            scaleUpTween.onComplete = null;
         };
         Engine.tweenJuggler.add(scaleUpTween);
      },delay);
   }
}

import starling.display.DisplayObjectContainer;

class ManualWipeEffect extends WipeEffect
{
    
   
   private var inManual:Boolean;
   
   private var outManual:Boolean;
   
   function ManualWipeEffect(param1:Boolean, param2:Boolean)
   {
      super();
      this.inManual = param1;
      this.outManual = param2;
   }
   
   override public function isManual() : Boolean
   {
      return true;
   }
   
   override public function close(param1:DisplayObjectContainer, param2:Function) : void
   {
      if(inManual)
      {
         return;
      }
      super.close(param1,param2);
   }
   
   override public function open(param1:DisplayObjectContainer, param2:Function = null) : void
   {
      if(outManual)
      {
         return;
      }
      super.open(param1,param2);
   }
   
   override public function closeManual(param1:DisplayObjectContainer, param2:Function) : void
   {
      super.close(param1,param2);
   }
   
   override public function openManual(param1:DisplayObjectContainer, param2:Function = null) : void
   {
      super.open(param1,param2);
   }
}

import flash.system.System;
import gudetama.common.BannerAdvertisingManager;
import gudetama.engine.EmbeddedAssets;
import gudetama.engine.Engine;
import gudetama.engine.TransitionEffect;
import gudetama.engine.TweenAnimator;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Image;
import starling.display.MovieClip;
import starling.display.Quad;
import starling.display.Sprite;
import starling.display.Stage;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

class FadeEffect extends TransitionEffect
{
   
   private static const MOVIE_CLIP_NONE:int = 0;
   
   private static const MOVIE_CLIP_1:int = 1;
   
   private static const MOVIE_CLIP_2:int = 2;
    
   
   private var textImageCache:Object;
   
   private var textImage:Image;
   
   private var movieClip1:MovieClip;
   
   private var movieClip2:MovieClip;
   
   private var currentMovieClip:int = 0;
   
   private var invert:Boolean;
   
   function FadeEffect(param1:Boolean = false)
   {
      textImageCache = {};
      super();
      this.invert = param1;
   }
   
   private function getTextImage() : Image
   {
      var _loc1_:String = Engine.getLocale();
      if(textImageCache[_loc1_])
      {
         return textImageCache[_loc1_];
      }
      switch(_loc1_)
      {
         case "ja":
            textImageCache[_loc1_] = new Image(Texture.fromBitmap(new EmbeddedAssets.Loading_png()));
            break;
         case "ko":
            textImageCache[_loc1_] = new Image(Texture.fromBitmap(new EmbeddedAssets.LoadingKo_png()));
            break;
         case "cn":
            textImageCache[_loc1_] = new Image(Texture.fromBitmap(new EmbeddedAssets.LoadingCn_png()));
            break;
         case "tw":
            textImageCache[_loc1_] = new Image(Texture.fromBitmap(new EmbeddedAssets.LoadingTw_png()));
            break;
         case "en":
         default:
            textImageCache[_loc1_] = new Image(Texture.fromBitmap(new EmbeddedAssets.LoadingEn_png()));
      }
      return textImageCache[_loc1_];
   }
   
   override public function finish(param1:DisplayObjectContainer) : void
   {
      displaySprite.removeChild(textImage);
      movieClip1.stop();
      movieClip2.stop();
      var _loc2_:* = Starling;
      (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).remove(movieClip1);
      var _loc3_:* = Starling;
      (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).remove(movieClip2);
      currentMovieClip = 0;
      param1.removeChild(displaySprite);
   }
   
   override public function setup() : void
   {
      var _loc8_:* = Engine;
      var _loc4_:int = gudetama.engine.Engine.designWidth;
      var _loc9_:* = Engine;
      var _loc2_:int = gudetama.engine.Engine.designHeight;
      displaySprite = new Sprite();
      var _loc10_:* = Engine;
      var _loc11_:* = Engine;
      var _loc12_:* = Engine;
      displaySprite.addChild(new Quad(gudetama.engine.Engine.designWidth + gudetama.engine.Engine.designWidthMargin * 2,gudetama.engine.Engine.designHeight,16491369));
      displaySprite.alpha = 0;
      var _loc3_:XML = XML(new EmbeddedAssets.Loading1_xml());
      var _loc5_:TextureAtlas = new TextureAtlas(Texture.fromBitmap(new EmbeddedAssets.Loading1_png()),_loc3_);
      movieClip1 = new MovieClip(_loc5_.getTextures("loading_"),7);
      movieClip1.x = 0.5 * (_loc4_ - movieClip1.width);
      movieClip1.y = 0.5 * (_loc2_ - movieClip1.height);
      displaySprite.addChild(movieClip1);
      _loc3_ = XML(new EmbeddedAssets.Loading2_xml());
      _loc5_ = new TextureAtlas(Texture.fromBitmap(new EmbeddedAssets.Loading2_png()),_loc3_);
      movieClip2 = new MovieClip(_loc5_.getTextures("loading_"),7);
      movieClip2.x = 0.5 * (_loc4_ - movieClip2.width);
      movieClip2.y = 0.5 * (_loc2_ - movieClip2.height);
      displaySprite.addChild(movieClip2);
      var _loc13_:* = Starling;
      var _loc1_:Stage = starling.core.Starling.sCurrent.stage;
      var _loc6_:Number = _loc1_.stageWidth / _loc4_;
      var _loc7_:Number = _loc1_.stageHeight / _loc2_;
      if(_loc6_ != _loc7_)
      {
         if(_loc6_ < _loc7_)
         {
            var _loc14_:* = Engine;
            var _loc15_:* = Engine;
            if(gudetama.engine.Engine._sceneY > gudetama.engine.Engine.designHeightMargin)
            {
               var _loc16_:* = Engine;
               displaySprite.x = gudetama.engine.Engine._sceneX;
               var _loc17_:* = Engine;
               var _loc18_:* = Engine;
               displaySprite.y = gudetama.engine.Engine._sceneY - gudetama.engine.Engine.designHeightMargin;
            }
         }
         else
         {
            var _loc19_:* = Engine;
            var _loc20_:* = Engine;
            if(gudetama.engine.Engine._sceneX > gudetama.engine.Engine.designWidthMargin)
            {
               var _loc21_:* = Engine;
               var _loc22_:* = Engine;
               displaySprite.x = gudetama.engine.Engine._sceneX - gudetama.engine.Engine.designWidthMargin;
               var _loc23_:* = Engine;
               displaySprite.y = gudetama.engine.Engine._sceneY;
            }
         }
      }
   }
   
   override public function close(param1:DisplayObjectContainer, param2:Function) : void
   {
      var obj:DisplayObjectContainer = param1;
      var callback:Function = param2;
      BannerAdvertisingManager.visibleBanner(false);
      setupDisplaySprite();
      obj.addChild(displaySprite);
      if(invert)
      {
         TweenAnimator.stopTween(displaySprite);
         TweenAnimator.startTween(displaySprite,"FADEOUT_CURRENT_ALPHA",{"time":0.4},function(param1:DisplayObject):void
         {
            System.pauseForGCIfCollectionImminent(0);
            if(callback)
            {
               callback();
            }
         });
      }
      else
      {
         TweenAnimator.stopTween(displaySprite);
         TweenAnimator.startTween(displaySprite,"FADEIN_CURRENT_ALPHA",{"time":0.3},function(param1:DisplayObject):void
         {
            System.pauseForGCIfCollectionImminent(0);
            if(callback)
            {
               callback();
            }
         });
      }
   }
   
   override public function open(param1:DisplayObjectContainer, param2:Function = null) : void
   {
      var obj:DisplayObjectContainer = param1;
      var callback:Function = param2;
      setupDisplaySprite();
      obj.addChild(displaySprite);
      if(invert)
      {
         TweenAnimator.stopTween(displaySprite);
         TweenAnimator.startTween(displaySprite,"FADEIN_CURRENT_ALPHA",{"time":0.3},function(param1:DisplayObject):void
         {
            finish(obj);
            if(callback)
            {
               callback();
            }
            BannerAdvertisingManager.visibleBanner(true);
         });
      }
      else
      {
         TweenAnimator.stopTween(displaySprite);
         TweenAnimator.startTween(displaySprite,"FADEOUT_CURRENT_ALPHA",{"time":0.4},function(param1:DisplayObject):void
         {
            finish(obj);
            if(callback)
            {
               callback();
            }
            BannerAdvertisingManager.visibleBanner(true);
         });
      }
   }
   
   private function setupDisplaySprite() : void
   {
      textImage = getTextImage();
      var _loc1_:* = Engine;
      textImage.x = 0.5 * (gudetama.engine.Engine.designWidth - textImage.width);
      textImage.y = 280;
      displaySprite.addChild(textImage);
      if(currentMovieClip == 0)
      {
         if(Math.random() < 0.5)
         {
            movieClip1.visible = true;
            movieClip2.visible = false;
            movieClip1.play();
            var _loc2_:* = Starling;
            (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).add(movieClip1);
            currentMovieClip = 1;
         }
         else
         {
            movieClip1.visible = false;
            movieClip2.visible = true;
            movieClip2.play();
            var _loc3_:* = Starling;
            (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).add(movieClip2);
            currentMovieClip = 2;
         }
      }
      else if(currentMovieClip == 1)
      {
         movieClip1.visible = true;
         movieClip2.visible = false;
         movieClip1.play();
         var _loc4_:* = Starling;
         (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).add(movieClip1);
      }
      else
      {
         movieClip1.visible = false;
         movieClip2.visible = true;
         movieClip2.play();
         var _loc5_:* = Starling;
         (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).add(movieClip2);
      }
   }
   
   override public function closeManual(param1:DisplayObjectContainer, param2:Function) : void
   {
      close(param1,param2);
   }
   
   override public function openManual(param1:DisplayObjectContainer, param2:Function = null) : void
   {
      open(param1,param2);
   }
}

import starling.display.DisplayObjectContainer;

class ManualFadeEffect extends FadeEffect
{
    
   
   private var inManual:Boolean;
   
   private var outManual:Boolean;
   
   function ManualFadeEffect(param1:Boolean, param2:Boolean, param3:Boolean = false)
   {
      super(param3);
      this.inManual = param1;
      this.outManual = param2;
   }
   
   override public function isManual() : Boolean
   {
      return true;
   }
   
   override public function close(param1:DisplayObjectContainer, param2:Function) : void
   {
      if(inManual)
      {
         return;
      }
      super.close(param1,param2);
   }
   
   override public function open(param1:DisplayObjectContainer, param2:Function = null) : void
   {
      if(outManual)
      {
         return;
      }
      super.open(param1,param2);
   }
   
   override public function closeManual(param1:DisplayObjectContainer, param2:Function) : void
   {
      super.close(param1,param2);
   }
   
   override public function openManual(param1:DisplayObjectContainer, param2:Function = null) : void
   {
      super.open(param1,param2);
   }
}
