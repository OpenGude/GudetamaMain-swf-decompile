package muku.display
{
   import flash.display.BitmapData;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import gudetama.engine.SoundManager;
   import muku.core.MukuGlobal;
   import muku.core.TaskQueue;
   import muku.util.SpineUtil;
   import spine.Bone;
   import spine.Event;
   import spine.SkeletonData;
   import spine.Slot;
   import spine.animation.Animation;
   import spine.animation.AnimationState;
   import spine.animation.AnimationStateData;
   import spine.animation.TrackEntry;
   import spine.attachments.Attachment;
   import spine.attachments.MeshAttachment;
   import spine.attachments.RegionAttachment;
   import spine.starling.SkeletonAnimation;
   import starling.core.Starling;
   import starling.display.Sprite;
   import starling.display.Stage;
   import starling.events.Touch;
   import starling.events.TouchEvent;
   import starling.rendering.Painter;
   import starling.textures.Texture;
   import starling.utils.Color;
   
   public class SpineModel extends Sprite
   {
       
      
      protected var mSkeletonAnimation:SkeletonAnimation;
      
      protected var mSkeletonData:SkeletonData;
      
      protected var mAnimationState:AnimationStateData;
      
      protected var mCurrentState:String;
      
      protected var mCurrentSkin:String;
      
      protected var mLoaded:Boolean;
      
      protected var mShowed:Boolean;
      
      protected var mResourceName:String;
      
      protected var mColor:int = 16777215;
      
      protected var mColorVec:Vector.<Number>;
      
      protected var mCallbackLoadComplete:Function;
      
      private var mOriginalSkeleton:SkeletonAnimation;
      
      private var changingSkeleton:Boolean;
      
      private var mAnimeDuration:Number = 0;
      
      private var stateName:String;
      
      public function SpineModel()
      {
         mColorVec = new <Number>[1,1,1,1];
         super();
         mLoaded = false;
         mShowed = false;
         mCurrentState = "";
         if(MukuGlobal.isBuilderMode())
         {
            trace("[SpineModel]",mResourceName);
         }
         else
         {
            touchable = false;
         }
      }
      
      public static function preload(param1:String, param2:Function, param3:Array = null) : void
      {
         var name:String = param1;
         var callback:Function = param2;
         var animationNames:Array = param3;
         SpineUtil.loadSkeletonAnimation(name,function(param1:SkeletonData, param2:AnimationStateData):void
         {
            callback({
               "skeleton":param1,
               "state":param2
            });
         },animationNames);
      }
      
      override public function dispose() : void
      {
         if(mSkeletonAnimation)
         {
            mSkeletonAnimation.dispatchEventWith("removeFromJuggler");
            mSkeletonAnimation.state.clearTracks();
            mSkeletonAnimation.dispose();
            mSkeletonAnimation = null;
         }
         mSkeletonData = null;
         mAnimationState = null;
         mOriginalSkeleton = null;
         mCallbackLoadComplete = null;
         super.dispose();
      }
      
      public function addTouchEvent(param1:Function) : void
      {
         touchable = true;
         addEventListener("touch",onTouch);
         addEventListener("triggered",param1);
      }
      
      private function onTouch(param1:TouchEvent) : void
      {
         var _loc2_:Touch = param1.getTouch(this);
         if(!_loc2_)
         {
            return;
         }
         if(_loc2_.phase == "began")
         {
            if(!_loc2_.cancelled)
            {
               dispatchEventWith("triggered",true);
            }
         }
      }
      
      public function isLoaded() : Boolean
      {
         return mLoaded;
      }
      
      public function isShown() : Boolean
      {
         return mShowed;
      }
      
      protected function setVisible(param1:Boolean) : void
      {
         visible = param1;
         mShowed = param1;
      }
      
      public function load(param1:String, param2:Function, param3:Array = null) : void
      {
         var name:String = param1;
         var _callback:Function = param2;
         var animationNames:Array = param3;
         mResourceName = name;
         SpineUtil.loadSkeletonAnimation(name,function(param1:SkeletonData, param2:AnimationStateData):void
         {
            mSkeletonData = param1;
            mAnimationState = param2;
            mSkeletonAnimation = new SkeletonAnimation(param1,param2);
            mOriginalSkeleton = mSkeletonAnimation;
            mLoaded = true;
            addChild(mSkeletonAnimation);
            _callback();
         },animationNames);
      }
      
      public function setup(param1:String, param2:Object) : void
      {
         mResourceName = param1;
         var _loc4_:SkeletonData = param2["skeleton"];
         var _loc3_:AnimationStateData = param2["state"];
         mSkeletonData = _loc4_;
         mAnimationState = _loc3_;
         mSkeletonAnimation = new SkeletonAnimation(_loc4_,_loc3_);
         mOriginalSkeleton = mSkeletonAnimation;
         mLoaded = true;
         addChild(mSkeletonAnimation);
      }
      
      public function show() : void
      {
         if(mSkeletonAnimation)
         {
            if(MukuGlobal.isBuilderMode())
            {
               addChild(mSkeletonAnimation);
            }
            var _loc1_:* = Starling;
            starling.core.Starling.sCurrent.juggler.add(mSkeletonAnimation);
         }
         else
         {
            mCallbackLoadComplete = show;
         }
      }
      
      public function setManuallyTime(param1:Number) : void
      {
         mSkeletonAnimation.setManuallyTime(mAnimeDuration * param1);
      }
      
      public function getManuallyTrackTime() : Number
      {
         return mSkeletonAnimation.getManuallyTrackTime(mAnimeDuration);
      }
      
      public function hide(param1:int = -1) : void
      {
         mSkeletonAnimation.dispatchEventWith("removeFromJuggler");
         setVisible(false);
      }
      
      public function finish(param1:Boolean = false) : void
      {
         onRemove(param1);
         setVisible(false);
      }
      
      public function onRemove(param1:Boolean = false) : void
      {
         if(mSkeletonAnimation)
         {
            mSkeletonAnimation.dispatchEventWith("removeFromJuggler");
            if(!param1)
            {
               mSkeletonAnimation.state.clearTracks();
               removeChild(mSkeletonAnimation,true);
               mSkeletonData = null;
               mAnimationState = null;
               mOriginalSkeleton = null;
               mCallbackLoadComplete = null;
            }
         }
      }
      
      public function setChangedAnimation(param1:String) : void
      {
         stateName = param1;
      }
      
      public function changeSkeleton(param1:SkeletonAnimation = null) : void
      {
         if(param1)
         {
            changingSkeleton = true;
            mSkeletonAnimation.dispatchEventWith("removeFromJuggler");
            mSkeletonAnimation.visible = false;
            var _loc2_:* = Starling;
            starling.core.Starling.sCurrent.juggler.add(param1);
            addChild(param1);
            mSkeletonAnimation = param1;
         }
         else if(changingSkeleton)
         {
            changingSkeleton = false;
            removeChild(mSkeletonAnimation);
            mSkeletonAnimation.dispatchEventWith("removeFromJuggler");
            mSkeletonAnimation = mOriginalSkeleton;
            var _loc3_:* = Starling;
            starling.core.Starling.sCurrent.juggler.add(mSkeletonAnimation);
            mSkeletonAnimation.visible = true;
         }
         setRequiresRedraw();
      }
      
      public function changeAnimation(param1:String, param2:Boolean = false, param3:Function = null) : void
      {
         var state:String = param1;
         var setup:Boolean = param2;
         var completeCallback:Function = param3;
         if(!state || state == "" || !mSkeletonAnimation)
         {
            return;
         }
         mCurrentState = state;
         var trackEntry:TrackEntry = mSkeletonAnimation.state.setAnimationByName(0,mCurrentState,mCurrentState.indexOf("loop") >= 0);
         if(setup)
         {
            mSkeletonAnimation.skeleton.setToSetupPose();
         }
         if(trackEntry)
         {
            trackEntry.onEvent.add(updateEvent);
         }
         if(completeCallback)
         {
            trackEntry.onComplete.add(function(param1:TrackEntry):void
            {
               completeCallback();
            });
         }
         mSkeletonAnimation.state.update(0);
         mSkeletonAnimation.state.apply(mSkeletonAnimation.skeleton);
         mSkeletonAnimation.skeleton.updateWorldTransform();
         setVisible(true);
      }
      
      public function appendAnimation(param1:String, param2:int = 0, param3:Number = 0, param4:Function = null) : void
      {
         var state:String = param1;
         var trackIndex:int = param2;
         var delay:Number = param3;
         var completeCallback:Function = param4;
         if(!state || state == "" || !mSkeletonAnimation)
         {
            return;
         }
         mCurrentState = state;
         var trackEntry:TrackEntry = mSkeletonAnimation.state.addAnimationByName(trackIndex,mCurrentState,mCurrentState.indexOf("loop") >= 0,delay);
         if(trackEntry)
         {
            trackEntry.onEvent.add(updateEvent);
            if(completeCallback)
            {
               trackEntry.onComplete.add(function(param1:TrackEntry):void
               {
                  completeCallback();
               });
            }
         }
         setVisible(true);
      }
      
      public function changeSkin(param1:String) : void
      {
         if(!param1 || param1 == "" || !mSkeletonAnimation)
         {
            return;
         }
         mSkeletonAnimation.skeleton.skinName = param1;
         mSkeletonAnimation.skeleton.setSlotsToSetupPose();
      }
      
      public function changeColor(param1:int) : void
      {
         if(!mSkeletonAnimation)
         {
            return;
         }
         mColor = param1;
         Color.toVector(mColor | -16777216,mColorVec);
         if(mSkeletonAnimation)
         {
            mSkeletonAnimation.skeleton.r = mColorVec[0];
            mSkeletonAnimation.skeleton.g = mColorVec[1];
            mSkeletonAnimation.skeleton.b = mColorVec[2];
         }
      }
      
      public function changeTimeScale(param1:Number) : void
      {
         if(!state || state == "" || !mSkeletonAnimation)
         {
            return;
         }
         mSkeletonAnimation.state.timeScale = param1;
      }
      
      public function setManuallyAnimation(param1:String) : void
      {
         var _loc2_:Animation = mSkeletonAnimation.state.data#2.skeletonData.findAnimation(param1);
         if(_loc2_ == null)
         {
            throw new ArgumentError("manually animation cannot be null.");
         }
         mSkeletonAnimation.state.setManuallyAnimation(_loc2_);
         mSkeletonAnimation.skeleton.updateWorldTransform();
         mAnimeDuration = _loc2_.duration;
      }
      
      public function setMixAniamtion(param1:String, param2:String, param3:Number) : void
      {
         mAnimationState.setMixByName(param1,param2,param3);
      }
      
      protected function updateEvent(param1:int, param2:Event) : void
      {
         var _loc3_:String = param2.data#2.name#2;
         var _loc4_:Object = SpineUtil.parsEventString(param2.stringValue);
         processUpdateEvent(_loc3_,_loc4_);
      }
      
      protected function processUpdateEvent(param1:String, param2:Object) : void
      {
         var _loc3_:* = null;
         if(param1.indexOf("sound_") == 0)
         {
            _loc3_ = param1.replace("sound_","");
            SoundManager.playEffect(_loc3_);
         }
      }
      
      public function containsAnimation(param1:String) : Boolean
      {
         return mSkeletonData.findAnimation(param1) != null;
      }
      
      public function changeTexture(param1:Texture, param2:String, param3:String = null, param4:String = null) : void
      {
         SpineUtil.changeSkeletonAttachmentTexture(mSkeletonAnimation.skeleton,param1,param2,param3,param4);
      }
      
      public function getBonePositionAtName(param1:String, param2:Point = null) : Point
      {
         if(!param2)
         {
            param2 = new Point();
         }
         var _loc3_:Bone = mSkeletonAnimation.skeleton.findBone(param1);
         param2.setTo(_loc3_.worldX + x,_loc3_.worldY + y);
         return param2;
      }
      
      public function getBoneAtName(param1:String) : Bone
      {
         return mSkeletonAnimation.skeleton.findBone(param1);
      }
      
      public function existsBoneAtName(param1:String) : Boolean
      {
         return mSkeletonAnimation.skeleton.findBone(param1);
      }
      
      public function getAniamtionStates() : Vector.<String>
      {
         var _loc2_:int = 0;
         var _loc3_:* = null;
         if(!mSkeletonAnimation)
         {
            return null;
         }
         var _loc1_:Vector.<String> = new Vector.<String>();
         _loc2_ = 0;
         while(_loc2_ < mSkeletonData.animations.length)
         {
            _loc3_ = mSkeletonData.animations[_loc2_];
            _loc1_.push(_loc3_.name#2);
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function getModelHeight() : Number
      {
         var _loc4_:int = 0;
         var _loc7_:int = 0;
         var _loc6_:* = null;
         var _loc11_:* = null;
         var _loc5_:int = 0;
         var _loc13_:* = null;
         var _loc14_:* = null;
         var _loc1_:int = 0;
         var _loc12_:Number = NaN;
         var _loc2_:* = NaN;
         if(!mSkeletonAnimation)
         {
            return 0;
         }
         var _loc10_:* = 1.7976931348623157e+308;
         var _loc3_:* = -1.7976931348623157e+308;
         var _loc9_:Vector.<Slot> = mSkeletonAnimation.skeleton.slots;
         var _loc15_:Vector.<Number> = mSkeletonAnimation.tempVertices;
         var _loc8_:Boolean = true;
         _loc4_ = 0;
         _loc7_ = _loc9_.length;
         for(; _loc4_ < _loc7_; _loc4_++)
         {
            if(_loc11_ = (_loc6_ = _loc9_[_loc4_]).attachment)
            {
               if(_loc11_ is RegionAttachment)
               {
                  _loc13_ = RegionAttachment(_loc6_.attachment);
                  _loc5_ = 8;
                  _loc13_.computeWorldVertices(0,0,_loc6_.bone,_loc15_);
               }
               else
               {
                  if(!(_loc11_ is MeshAttachment))
                  {
                     continue;
                  }
                  _loc5_ = (_loc14_ = MeshAttachment(_loc11_)).worldVerticesLength;
                  if(_loc15_.length < _loc5_)
                  {
                     _loc15_.length = _loc5_;
                  }
                  _loc14_.computeWorldVertices(_loc6_,_loc15_);
               }
               if(_loc5_ != 0)
               {
                  _loc8_ = false;
               }
               _loc1_ = 0;
               while(_loc1_ < _loc5_)
               {
                  _loc12_ = _loc15_[_loc1_ + 1];
                  _loc10_ = Number(_loc10_ < _loc12_ ? _loc10_ : Number(_loc12_));
                  _loc3_ = Number(_loc3_ > _loc12_ ? _loc3_ : Number(_loc12_));
                  _loc1_ += 2;
               }
            }
         }
         if(_loc8_)
         {
            return 0;
         }
         if(_loc3_ < _loc10_)
         {
            _loc2_ = _loc3_;
            _loc3_ = _loc10_;
            _loc10_ = _loc2_;
         }
         return _loc3_ - _loc10_;
      }
      
      public function getModelBounds(param1:Rectangle = null) : Rectangle
      {
         var _loc6_:int = 0;
         var _loc9_:int = 0;
         var _loc8_:* = null;
         var _loc13_:* = null;
         var _loc7_:int = 0;
         var _loc17_:* = null;
         var _loc18_:* = null;
         var _loc2_:int = 0;
         var _loc15_:Number = NaN;
         var _loc3_:* = NaN;
         if(!param1)
         {
            param1 = new Rectangle();
         }
         if(!mSkeletonAnimation)
         {
            return param1;
         }
         var _loc14_:* = 1.7976931348623157e+308;
         var _loc5_:* = -1.7976931348623157e+308;
         var _loc12_:* = 1.7976931348623157e+308;
         var _loc4_:* = -1.7976931348623157e+308;
         var _loc11_:Vector.<Slot> = mSkeletonAnimation.skeleton.slots;
         var _loc19_:Vector.<Number> = mSkeletonAnimation.tempVertices;
         var _loc10_:Boolean = true;
         _loc6_ = 0;
         _loc9_ = _loc11_.length;
         for(; _loc6_ < _loc9_; _loc6_++)
         {
            if(_loc13_ = (_loc8_ = _loc11_[_loc6_]).attachment)
            {
               if(_loc13_ is RegionAttachment)
               {
                  _loc17_ = RegionAttachment(_loc8_.attachment);
                  _loc7_ = 8;
                  _loc17_.computeWorldVertices(0,0,_loc8_.bone,_loc19_);
               }
               else
               {
                  if(!(_loc13_ is MeshAttachment))
                  {
                     continue;
                  }
                  _loc7_ = (_loc18_ = MeshAttachment(_loc13_)).worldVerticesLength;
                  if(_loc19_.length < _loc7_)
                  {
                     _loc19_.length = _loc7_;
                  }
                  _loc18_.computeWorldVertices(_loc8_,_loc19_);
               }
               if(_loc7_ != 0)
               {
                  _loc10_ = false;
               }
               _loc2_ = 0;
               while(_loc2_ < _loc7_)
               {
                  _loc15_ = _loc19_[_loc2_];
                  var _loc16_:Number = _loc19_[_loc2_ + 1];
                  _loc14_ = Number(_loc14_ < _loc15_ ? _loc14_ : Number(_loc15_));
                  _loc12_ = Number(_loc12_ < _loc16_ ? _loc12_ : Number(_loc16_));
                  _loc5_ = Number(_loc5_ > _loc15_ ? _loc5_ : Number(_loc15_));
                  _loc4_ = Number(_loc4_ > _loc16_ ? _loc4_ : Number(_loc16_));
                  _loc2_ += 2;
               }
            }
         }
         if(_loc10_)
         {
            return param1;
         }
         if(_loc5_ < _loc14_)
         {
            _loc3_ = _loc5_;
            _loc5_ = _loc14_;
            _loc14_ = _loc3_;
         }
         if(_loc4_ < _loc12_)
         {
            _loc3_ = _loc4_;
            _loc4_ = _loc12_;
            _loc12_ = _loc3_;
         }
         param1.setTo(_loc14_,_loc12_,_loc5_ - _loc14_,_loc4_ - _loc12_);
         return param1;
      }
      
      override public function drawToBitmapData(param1:BitmapData = null) : BitmapData
      {
         var _loc12_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc10_:* = null;
         var _loc13_:* = Starling;
         var _loc2_:Painter = !!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._painter : null;
         var _loc14_:* = Starling;
         var _loc7_:Stage = starling.core.Starling.sCurrent.stage;
         var _loc15_:* = Starling;
         var _loc6_:Rectangle = starling.core.Starling.sCurrent.viewPort;
         var _loc3_:Number = _loc7_.stageWidth;
         var _loc9_:Number = _loc7_.stageHeight;
         var _loc4_:Number = _loc6_.width / _loc3_;
         var _loc5_:Number = _loc6_.height / _loc9_;
         var _loc8_:Number = _loc2_.backBufferScaleFactor;
         _loc11_ = (_loc10_ = getModelBounds()).x;
         _loc12_ = _loc10_.y;
         if(!param1)
         {
            param1 = new BitmapData(Math.ceil(_loc10_.width * _loc4_ * _loc8_),Math.ceil(_loc10_.height * _loc5_ * _loc8_));
         }
         _loc2_.clear();
         _loc2_.pushState();
         _loc2_.state.renderTarget = null;
         _loc2_.state.setModelviewMatricesToIdentity();
         _loc2_.setStateTo(transformationMatrix);
         _loc2_.state.setProjectionMatrix(_loc11_,_loc12_,_loc2_.backBufferWidth / _loc4_,_loc2_.backBufferHeight / _loc5_,_loc3_,_loc9_,_loc7_.cameraPosition);
         render(_loc2_);
         _loc2_.finishMeshBatch();
         _loc2_.context.drawToBitmapData(param1);
         _loc2_.popState();
         return param1;
      }
      
      public function get state() : String
      {
         return mCurrentState;
      }
      
      public function set state(param1:String) : void
      {
         mCurrentState = param1;
         if(MukuGlobal.isBuilderMode())
         {
            if(mCurrentState && mCurrentState != "")
            {
               changeAnimation(mCurrentState,true);
               if(mSkeletonAnimation)
               {
                  mSkeletonAnimation.advanceTime(0);
               }
            }
         }
      }
      
      public function get color() : int
      {
         return mColor;
      }
      
      public function set color(param1:int) : void
      {
         mColor = param1;
         changeColor(mColor);
      }
      
      public function get skin() : String
      {
         return mCurrentSkin;
      }
      
      public function set skin(param1:String) : void
      {
         mCurrentSkin = param1;
         if(MukuGlobal.isBuilderMode())
         {
            if(mCurrentSkin && mCurrentSkin != "")
            {
               changeSkin(mCurrentSkin);
               if(mSkeletonAnimation)
               {
                  mSkeletonAnimation.advanceTime(0);
               }
            }
         }
      }
      
      public function get resourceName() : String
      {
         return mResourceName;
      }
      
      public function set resourceName(param1:String) : void
      {
         var value:String = param1;
         if(mResourceName == value)
         {
            return;
         }
         mResourceName = value;
         if(!mResourceName || mResourceName == "")
         {
            finish();
            return;
         }
         if(mSkeletonAnimation)
         {
            onRemove();
         }
         if(!MukuGlobal.isBuilderMode())
         {
            var queue:TaskQueue = MukuGlobal.getTaskQueue();
            queue.addTask(function():void
            {
               SpineUtil.loadSkeletonAnimation(mResourceName,function(param1:SkeletonData, param2:AnimationStateData):void
               {
                  var _loc3_:* = null;
                  mSkeletonData = param1;
                  mAnimationState = param2;
                  mSkeletonAnimation = new SkeletonAnimation(param1,param2);
                  mOriginalSkeleton = mSkeletonAnimation;
                  if(mCurrentState && mCurrentState != "")
                  {
                     _loc3_ = mSkeletonAnimation.state;
                     _loc3_.setAnimationByName(0,mCurrentState,false);
                     _loc3_.apply(mSkeletonAnimation.skeleton);
                  }
                  changeColor(mColor);
                  mLoaded = true;
                  addChild(mSkeletonAnimation);
                  if(mCallbackLoadComplete)
                  {
                     mCallbackLoadComplete();
                  }
                  if(stateName)
                  {
                     changeAnimation(stateName);
                     stateName = null;
                  }
                  queue.taskDone();
               });
            });
         }
      }
   }
}
