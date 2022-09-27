package muku.text
{
   import flash.utils.getTimer;
   import muku.core.ApplicationContext;
   import muku.core.MukuGlobal;
   import starling.events.Event;
   import starling.text.TextOptions;
   
   public class TypingTextField extends ColorTextField
   {
       
      
      private var charLocations:Vector.<CharLocationInfo>;
      
      private var isTyping:Boolean = false;
      
      private var mTypingSpeedInSec:Number = 4;
      
      private var mTypingSpeed:Number;
      
      private var numShowChars:int = 0;
      
      private var charCounter:int = 0;
      
      private var waitCount:int = 0;
      
      private var startedTick:uint = 0;
      
      private var lastCountTick:uint = 0;
      
      private var typingCallBack:Function = null;
      
      private var updateOnlyQuad:Boolean = false;
      
      private var soundEffectName:String;
      
      public function TypingTextField(param1:int = 100, param2:int = 32, param3:String = "", param4:String = "Verdana", param5:Number = 24, param6:uint = 0, param7:Boolean = false)
      {
         super(param1,param2,param3,param4,param5,param6,param7);
      }
      
      override public function updateValuesFrom(param1:ColorTextField) : void
      {
         super.updateValuesFrom(param1);
         if(param1 is TypingTextField)
         {
            numShowChars = (param1 as TypingTextField).numShowChars;
         }
      }
      
      public function startText(param1:Number = 0, param2:Function = null) : void
      {
         mTypingSpeed = param1 == 0 ? mTypingSpeedInSec * 0.001 : Number(param1 * 0.001);
         typingCallBack = param2;
         isTyping = true;
         startedTick = !!MukuGlobal.engine ? MukuGlobal.engine.now : getTimer();
         lastCountTick = !!MukuGlobal.engine ? MukuGlobal.engine.now : getTimer();
         charCounter = 0;
         numShowChars = 0;
         waitCount = 0;
         addEventListener("enterFrame",onEnterFrame);
      }
      
      public function restartText(param1:Number = 0, param2:Function = null) : void
      {
         mTypingSpeed = param1 == 0 ? mTypingSpeedInSec * 0.001 : Number(param1 * 0.001);
         typingCallBack = param2;
         isTyping = true;
         startedTick = !!MukuGlobal.engine ? MukuGlobal.engine.now : getTimer();
         lastCountTick = !!MukuGlobal.engine ? MukuGlobal.engine.now : getTimer();
         waitCount = 0;
         addEventListener("enterFrame",onEnterFrame);
      }
      
      public function stopText() : void
      {
         isTyping = false;
      }
      
      public function setSoundEffectName(param1:String) : void
      {
         soundEffectName = param1;
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         var _loc3_:int = 0;
         if(startedTick == 0)
         {
            return;
         }
         var _loc4_:int;
         var _loc2_:int = (_loc4_ = !!MukuGlobal.engine ? MukuGlobal.engine.now : getTimer()) - lastCountTick;
         if(!isTyping)
         {
            if(typingCallBack)
            {
               typingCallBack();
            }
            typingCallBack = null;
            startedTick = 0;
            return;
         }
         if(mTypingSpeed >= 0)
         {
            _loc3_ = mTypingSpeed < 0 ? mRawText.length : mTypingSpeed * _loc2_;
            if(_loc3_ > 0)
            {
               charCounter += _loc3_;
               lastCountTick = !!MukuGlobal.engine ? MukuGlobal.engine.now : getTimer();
               if(waitCount + numShowChars <= charCounter)
               {
                  numShowChars = charCounter - waitCount;
                  setRequiresRecomposition();
                  if(charLocations)
                  {
                     updateOnlyQuad = true;
                  }
               }
            }
         }
         else if(charLocations && charLocations.length > charCounter)
         {
            charCounter = charLocations.length;
            if(waitCount + numShowChars <= charCounter)
            {
               numShowChars = charCounter - waitCount;
               charCounter += charLocations[charLocations.length - 1].waitCount;
               setRequiresRecomposition();
               if(charLocations)
               {
                  updateOnlyQuad = true;
               }
            }
         }
      }
      
      private function disposeCharLocation() : void
      {
         if(charLocations)
         {
            CharLocationInfo.vectorInstanceToPool(charLocations);
            CharLocationInfo.vectorToPool(charLocations);
         }
      }
      
      private function createComposedContents2(param1:PartialBitmapFont) : void
      {
         var _loc2_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:* = null;
         var _loc3_:Number = NaN;
         if(_requiresRecomposition || mNeedsArrange || charLocations == null)
         {
            _loc2_ = _hitArea.width;
            _loc4_ = _hitArea.height;
            mNeedsArrange = false;
            disposeCharLocation();
            _loc5_ = new TextOptions(true,autoScale);
            charLocations = param1.layoutText(_loc2_,_loc4_,mRawText,format,_loc5_,typingSpeed);
         }
         if(_meshBatch == null)
         {
            _meshBatch = new _meshBatch();
            _meshBatch.touchable = false;
            addChild(_meshBatch);
         }
         else
         {
            _meshBatch.clear();
         }
         param1.applyMeshBatch(_meshBatch,charLocations,numShowChars);
         _meshBatch.batchable = false;
         _textBounds = null;
         if(numShowChars >= charLocations.length)
         {
            isTyping = false;
         }
         if(charLocations.length > numShowChars)
         {
            waitCount = charLocations[numShowChars].waitCount;
            _loc3_ = charLocations[numShowChars].typingSpeed;
            if(_loc3_ != 0 && typingSpeed != _loc3_)
            {
               typingSpeed = _loc3_;
            }
         }
      }
      
      private function updateQuad() : void
      {
         var _loc2_:Number = NaN;
         if(_meshBatch == null)
         {
            _meshBatch = new _meshBatch();
            _meshBatch.touchable = false;
            addChild(_meshBatch);
         }
         else
         {
            _meshBatch.clear();
         }
         var _loc1_:PartialBitmapFont = getBitmapFont(fontName) as PartialBitmapFont;
         if(!_loc1_)
         {
            return;
         }
         _loc1_.applyMeshBatch(_meshBatch,charLocations,numShowChars);
         _meshBatch.batchable = false;
         _textBounds = null;
         if(numShowChars >= charLocations.length)
         {
            isTyping = false;
         }
         if(charLocations.length > numShowChars)
         {
            waitCount = charLocations[numShowChars].waitCount;
            _loc2_ = charLocations[numShowChars].typingSpeed;
            if(_loc2_ != 0 && typingSpeed != _loc2_)
            {
               typingSpeed = _loc2_;
            }
         }
         if(soundEffectName && soundEffectName.length > 0)
         {
            ApplicationContext.playSound(soundEffectName);
         }
      }
      
      override protected function recompose() : void
      {
         if(_requiresRecomposition)
         {
            if(MukuGlobal.isBuilderMode())
            {
               numShowChars = mRawText.length;
            }
            if(updateOnlyQuad)
            {
               updateOnlyQuad = false;
               updateQuad();
            }
            else
            {
               createComposedContents2(checkBitmapFont());
            }
            updateBorder();
            _requiresRecomposition = false;
         }
      }
      
      override public function dispose() : void
      {
         super.dispose();
         if(charLocations)
         {
            disposeCharLocation();
            charLocations = null;
         }
         updateOnlyQuad = false;
      }
      
      public function get typingSpeed() : Number
      {
         return mTypingSpeedInSec;
      }
      
      public function set typingSpeed(param1:Number) : void
      {
         mTypingSpeedInSec = param1;
         mTypingSpeed = param1 * 0.001;
      }
      
      override public function set text#2(param1:String) : void
      {
         isTyping = false;
         if(charLocations)
         {
            disposeCharLocation();
            charLocations = null;
         }
         updateOnlyQuad = false;
         charCounter = 0;
         numShowChars = 0;
         waitCount = 0;
         super.text#2 = param1;
         setRequiresRecomposition();
      }
      
      public function addText(param1:String) : void
      {
         isTyping = false;
         if(charLocations)
         {
            disposeCharLocation();
            charLocations = null;
         }
         updateOnlyQuad = false;
         super.text#2 = text#2 + param1;
         setRequiresRecomposition();
      }
      
      public function setTyping(param1:Boolean) : void
      {
         isTyping = param1;
      }
      
      public function getTyping() : Boolean
      {
         return isTyping;
      }
      
      public function getTypingWord() : String
      {
         if(numShowChars == 0)
         {
            return "";
         }
         if(!charLocations)
         {
            return "";
         }
         if(isTyping == false || numShowChars - 1 >= charLocations.length)
         {
            return null;
         }
         return charLocations[numShowChars - 1].word;
      }
      
      public function getTypingWaitCount() : int
      {
         if(isTyping == false)
         {
            return 0;
         }
         if(!charLocations)
         {
            return 0;
         }
         if(numShowChars == 0 || numShowChars >= charLocations.length)
         {
            return 0;
         }
         return charLocations[numShowChars].waitCount - charLocations[numShowChars - 1].waitCount;
      }
      
      override public function set autoSize(param1:String) : void
      {
      }
      
      override public function set batchable(param1:Boolean) : void
      {
      }
   }
}
