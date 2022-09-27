package muku.display
{
   import gudetama.engine.RsrcManager;
   import muku.core.MukuGlobal;
   import muku.core.TaskQueue;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   import starling.display.DisplayObjectContainer;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.extensions.ColorArgb;
   import starling.textures.Texture;
   import starling.utils.StringUtil;
   import starlingbuilder.engine.IAssetMediator;
   
   public class Particle extends Sprite
   {
      
      private static const TARGET_SPACE_SELF:String = "self";
      
      private static const TARGET_SPACE_PARENT:String = "parent";
      
      private static const TARGET_SPACE_EXTRA:String = "extra";
       
      
      private var mName:String;
      
      private var mTexName:String;
      
      private var mPs:ParticleSystem = null;
      
      private var mPsRunning:ParticleSystem = null;
      
      private var mAssetMediator:IAssetMediator;
      
      private var mPsConfig:XML = null;
      
      private var mPsTexture:Texture = null;
      
      private var mAutoStart:Boolean = false;
      
      private var mClearParticle:Boolean = false;
      
      private var mTargetSpace:DisplayObjectContainer;
      
      private var mEmitterObject:DisplayObject;
      
      private var mRemoveCallback:Function;
      
      private var mShowCallback:Function;
      
      private var mLoaded:Boolean;
      
      private var mChangeColor:Boolean;
      
      private var mStartColor:ColorArgb;
      
      private var mEndColor:ColorArgb;
      
      private var mTargetSpaceMode:String = "self";
      
      public function Particle()
      {
         mStartColor = new ColorArgb(1,1,1,1);
         mEndColor = new ColorArgb(1,1,1,1);
         super();
         mName = "";
         mPs = null;
         if(MukuGlobal.isBuilderMode())
         {
            trace("[Particle]",name#2);
         }
         else
         {
            touchable = false;
         }
         mAssetMediator = MukuGlobal.assetMediator;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         mPsRunning = null;
         mPs.dispose();
         mTargetSpace = null;
         mEmitterObject = null;
         mRemoveCallback = null;
         mShowCallback = null;
         mPsConfig = null;
      }
      
      public function isLoaded() : Boolean
      {
         return mLoaded;
      }
      
      public function show() : void
      {
         if(!mLoaded)
         {
            mShowCallback = show;
            return;
         }
         if(!mPsRunning)
         {
            if(mPs == null)
            {
               if(mPsConfig && mPsTexture)
               {
                  mPs = new ParticleSystem(mPsConfig,mPsTexture,mName);
               }
            }
            if(!mPs)
            {
               trace("[Particle]","data not loaded");
               return;
            }
            if(mChangeColor)
            {
               mPs.startColor = mStartColor;
               mPs.endColor = mEndColor;
            }
            if(MukuGlobal.isBuilderMode())
            {
               switch(mTargetSpaceMode)
               {
                  case "self":
                     mTargetSpace = null;
                     break;
                  case "parent":
                     if(parent is EffectPlayer)
                     {
                        mTargetSpace = parent.parent;
                     }
                     else if(MukuGlobal.isBuilderMode())
                     {
                        mTargetSpace = parent;
                     }
                     break;
                  case "extra":
               }
            }
            mEmitterObject = this;
            mPs.emitterObject = mEmitterObject;
            mPs.targetSpace = mTargetSpace;
            mPsRunning = mPs;
            if(mTargetSpace)
            {
               mTargetSpace.addChild(mPsRunning);
            }
            else
            {
               addChild(mPsRunning);
            }
            var _loc2_:* = Starling;
            (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).add(mPsRunning);
            mPsRunning.addEventListener("complete",onRemove);
            mPsRunning.start();
         }
      }
      
      public function hide() : void
      {
         if(mPsRunning)
         {
            mPsRunning.stop(mClearParticle);
            if(mClearParticle)
            {
               onRemove(null);
            }
         }
      }
      
      public function onRemove(param1:Event) : void
      {
         if(mPsRunning)
         {
            mPsRunning.emitterObject = null;
            mPsRunning.targetSpace = null;
            mPsRunning.removeEventListener("complete",onRemove);
            mPsRunning.dispatchEventWith("removeFromJuggler");
            if(mTargetSpace)
            {
               mTargetSpace.removeChild(mPsRunning);
            }
            else
            {
               removeChild(mPsRunning);
            }
         }
         mPsRunning = null;
         mTargetSpace = null;
         mEmitterObject = null;
         if(mRemoveCallback)
         {
            mRemoveCallback();
            mRemoveCallback = null;
         }
      }
      
      public function setRemoveCallback(param1:Function) : void
      {
         mRemoveCallback = param1;
      }
      
      public function isTargetSpaceExtra() : Boolean
      {
         return mTargetSpaceMode == "extra";
      }
      
      public function isTargetSpaceParent() : Boolean
      {
         return mTargetSpaceMode == "parent";
      }
      
      public function get clearParticle() : Boolean
      {
         return mClearParticle;
      }
      
      public function set clearParticle(param1:Boolean) : void
      {
         mClearParticle = param1;
      }
      
      public function get emitterObject() : DisplayObject
      {
         return mEmitterObject;
      }
      
      public function set emitterObject(param1:DisplayObject) : void
      {
         mEmitterObject = param1;
      }
      
      public function get targetSpace() : DisplayObjectContainer
      {
         return mTargetSpace;
      }
      
      public function set targetSpace(param1:DisplayObjectContainer) : void
      {
         mTargetSpace = param1;
      }
      
      public function get autoStart() : Boolean
      {
         return mAutoStart;
      }
      
      public function set autoStart(param1:Boolean) : void
      {
         mAutoStart = param1;
         if(mAutoStart)
         {
            show();
         }
         else
         {
            hide();
         }
      }
      
      public function get particleName() : String
      {
         return mName;
      }
      
      public function set particleName(param1:String) : void
      {
         var name:String = param1;
         mName = name;
         if(mPsRunning)
         {
            hide();
         }
         if(mName && mName != "")
         {
            var getTextureName:* = function(param1:XMLList):String
            {
               return StringUtil.clean(param1.attribute("name")).replace(".png","");
            };
            if(MukuGlobal.isBuilderMode())
            {
               mPsConfig = mAssetMediator.getXml(mName);
               mPsTexture = mAssetMediator.getTexture(getTextureName(mPsConfig.texture));
               if(mPsConfig && mPsTexture)
               {
                  mPs = new ParticleSystem(mPsConfig,mPsTexture,mName);
               }
               else
               {
                  trace("[Particle]","loading data failed : " + mName);
               }
               if(mAutoStart)
               {
                  show();
               }
            }
            else
            {
               mPsConfig = mAssetMediator.getXml(mName);
               mPsTexture = mAssetMediator.getTexture(getTextureName(mPsConfig.texture));
               if(mPsConfig && mPsTexture)
               {
                  mPs = new ParticleSystem(mPsConfig,mPsTexture,mName);
                  mLoaded = true;
                  if(mAutoStart)
                  {
                     show();
                  }
               }
               else
               {
                  var queue:TaskQueue = MukuGlobal.getTaskQueue();
                  RsrcManager.getInstance().loadParticle(mName + ".pex",function(param1:XML, param2:Texture):void
                  {
                     mPsConfig = param1;
                     mPsTexture = param2;
                     if(mPsConfig && mPsTexture)
                     {
                        mPs = new ParticleSystem(mPsConfig,mPsTexture,mName);
                     }
                     else
                     {
                        trace("[Particle]","loading data failed : " + mName);
                     }
                     mLoaded = true;
                     if(mAutoStart)
                     {
                        show();
                     }
                     else if(mShowCallback)
                     {
                        mShowCallback();
                        mShowCallback = null;
                     }
                     queue.taskDone();
                  });
               }
            }
         }
      }
      
      public function get textureName() : String
      {
         return mTexName;
      }
      
      public function set textureName(param1:String) : void
      {
         mTexName = param1;
      }
      
      public function get targetSpaceMode() : String
      {
         return mTargetSpaceMode;
      }
      
      public function set targetSpaceMode(param1:String) : void
      {
         mTargetSpaceMode = param1;
      }
      
      public function get changeColor() : Boolean
      {
         return mChangeColor;
      }
      
      public function set changeColor(param1:Boolean) : void
      {
         mChangeColor = param1;
      }
      
      public function get startColor() : uint
      {
         return mStartColor.toRgb();
      }
      
      public function set startColor(param1:uint) : void
      {
         mStartColor.fromRgb(param1);
         if(!changeColor)
         {
            return;
         }
         setColor();
      }
      
      public function get startAlpha() : Number
      {
         return mStartColor.alpha;
      }
      
      public function set startAlpha(param1:Number) : void
      {
         mStartColor.alpha = param1;
         if(!changeColor)
         {
            return;
         }
         setColor();
      }
      
      public function get endColor() : uint
      {
         return mEndColor.toRgb();
      }
      
      public function set endColor(param1:uint) : void
      {
         mEndColor.fromRgb(param1);
         if(!changeColor)
         {
            return;
         }
         setColor();
      }
      
      public function get endAlpha() : Number
      {
         return mEndColor.alpha;
      }
      
      public function set endAlpha(param1:Number) : void
      {
         mEndColor.alpha = param1;
         if(!changeColor)
         {
            return;
         }
         setColor();
      }
      
      private function setColor() : void
      {
         if(mPsRunning)
         {
            mPsRunning.startColor = mStartColor;
         }
         else if(mPs)
         {
            mPs.startColor = mStartColor;
         }
      }
   }
}
