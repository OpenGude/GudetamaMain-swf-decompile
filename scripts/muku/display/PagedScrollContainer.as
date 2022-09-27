package muku.display
{
   import feathers.controls.ScrollContainer;
   import starling.display.Quad;
   import starling.utils.MathUtil;
   
   public class PagedScrollContainer extends ScrollContainer
   {
       
      
      private var currentHorizontalPageIndex:int;
      
      private var currentVerticalPageIndex:int;
      
      private var _horizontalThrowToPageCallback:Function;
      
      private var _verticalThrowToPageCallback:Function;
      
      private var _availableTouchBlocker:Boolean = true;
      
      public function PagedScrollContainer()
      {
         super();
         snapToPages = true;
      }
      
      public function set horizontalThrowToPageCallback(param1:Function) : void
      {
         _horizontalThrowToPageCallback = param1;
      }
      
      public function set verticalThrowToPageCallback(param1:Function) : void
      {
         _verticalThrowToPageCallback = param1;
      }
      
      public function set availableTouchBlocker(param1:Boolean) : void
      {
         _availableTouchBlocker = param1;
         if(this._interactionMode == "touch" || this._interactionMode == "touchAndScrollBars")
         {
            if(_availableTouchBlocker)
            {
               if(!this._touchBlocker)
               {
                  this._touchBlocker = new Quad(100,100,16711935);
                  this._touchBlocker.alpha = 0;
               }
            }
            else if(this._touchBlocker)
            {
               this.removeRawChildInternal(this._touchBlocker,true);
               this._touchBlocker = null;
            }
         }
         else if(this._touchBlocker)
         {
            this.removeRawChildInternal(this._touchBlocker,true);
            this._touchBlocker = null;
         }
      }
      
      override protected function throwToPage(param1:int, param2:int, param3:Number = 0.5) : void
      {
         if(currentHorizontalPageIndex != param1)
         {
            currentHorizontalPageIndex = param1;
            if(_horizontalThrowToPageCallback)
            {
               _horizontalThrowToPageCallback(currentHorizontalPageIndex);
            }
         }
         if(currentVerticalPageIndex != param2)
         {
            currentVerticalPageIndex = param2;
            if(_verticalThrowToPageCallback)
            {
               _verticalThrowToPageCallback(currentVerticalPageIndex);
            }
         }
         super.throwToPage(param1,param2,param3);
      }
      
      override protected function refreshInteractionModeEvents() : void
      {
         if(this._interactionMode == "touch" || this._interactionMode == "touchAndScrollBars")
         {
            this.addEventListener("touch",scroller_touchHandler);
            if(_availableTouchBlocker)
            {
               if(!this._touchBlocker)
               {
                  this._touchBlocker = new Quad(100,100,16711935);
                  this._touchBlocker.alpha = 0;
               }
            }
            else if(this._touchBlocker)
            {
               this.removeRawChildInternal(this._touchBlocker,true);
               this._touchBlocker = null;
            }
         }
         else
         {
            this.removeEventListener("touch",scroller_touchHandler);
            if(this._touchBlocker)
            {
               this.removeRawChildInternal(this._touchBlocker,true);
               this._touchBlocker = null;
            }
         }
         if((this._interactionMode == "mouse" || this._interactionMode == "touchAndScrollBars") && this._scrollBarDisplayMode == "float")
         {
            if(this.horizontalScrollBar)
            {
               this.horizontalScrollBar.addEventListener("touch",horizontalScrollBar_touchHandler);
            }
            if(this.verticalScrollBar)
            {
               this.verticalScrollBar.addEventListener("touch",verticalScrollBar_touchHandler);
            }
         }
         else
         {
            if(this.horizontalScrollBar)
            {
               this.horizontalScrollBar.removeEventListener("touch",horizontalScrollBar_touchHandler);
            }
            if(this.verticalScrollBar)
            {
               this.verticalScrollBar.removeEventListener("touch",verticalScrollBar_touchHandler);
            }
         }
      }
      
      override protected function refreshPageIndices() : void
      {
         var _loc3_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc1_:int = 0;
         var _loc4_:Number = NaN;
         if(!this._horizontalAutoScrollTween && !this.hasPendingHorizontalPageIndex)
         {
            if(this._snapToPages)
            {
               if(!isPageMoveByDragDir())
               {
                  if(this._horizontalScrollPosition == this._maxHorizontalScrollPosition)
                  {
                     this._horizontalPageIndex = this._maxHorizontalPageIndex;
                  }
                  else if(this._horizontalScrollPosition == this._minHorizontalScrollPosition)
                  {
                     this._horizontalPageIndex = this._minHorizontalPageIndex;
                  }
                  else
                  {
                     if(this._minHorizontalScrollPosition == -Infinity && this._horizontalScrollPosition < 0)
                     {
                        _loc3_ = this._horizontalScrollPosition / this.actualPageWidth;
                     }
                     else if(this._maxHorizontalScrollPosition == Infinity && this._horizontalScrollPosition >= 0)
                     {
                        _loc3_ = this._horizontalScrollPosition / this.actualPageWidth;
                     }
                     else
                     {
                        _loc2_ = this._horizontalScrollPosition - this._minHorizontalScrollPosition;
                        _loc3_ = _loc2_ / this.actualPageWidth;
                     }
                     _loc1_ = Math.round(_loc3_);
                     this._horizontalPageIndex = _loc1_;
                  }
               }
            }
            else
            {
               this._horizontalPageIndex = this._minHorizontalPageIndex;
            }
            if(this._horizontalPageIndex < this._minHorizontalPageIndex)
            {
               this._horizontalPageIndex = this._minHorizontalPageIndex;
            }
            if(this._horizontalPageIndex > this._maxHorizontalPageIndex)
            {
               this._horizontalPageIndex = this._maxHorizontalPageIndex;
            }
         }
         if(!this._verticalAutoScrollTween && !this.hasPendingVerticalPageIndex)
         {
            if(this._snapToPages)
            {
               if(this._verticalScrollPosition == this._maxVerticalScrollPosition)
               {
                  this._verticalPageIndex = this._maxVerticalPageIndex;
               }
               else if(this._verticalScrollPosition == this._minVerticalScrollPosition)
               {
                  this._verticalPageIndex = this._minVerticalPageIndex;
               }
               else
               {
                  if(this._minVerticalScrollPosition == -Infinity && this._verticalScrollPosition < 0)
                  {
                     _loc3_ = this._verticalScrollPosition / this.actualPageHeight;
                  }
                  else if(this._maxVerticalScrollPosition == Infinity && this._verticalScrollPosition >= 0)
                  {
                     _loc3_ = this._verticalScrollPosition / this.actualPageHeight;
                  }
                  else
                  {
                     _loc3_ = (_loc4_ = this._verticalScrollPosition - this._minVerticalScrollPosition) / this.actualPageHeight;
                  }
                  _loc1_ = Math.round(_loc3_);
                  if(_loc3_ !== _loc1_ && MathUtil.isEquivalent(_loc3_,_loc1_,0.01))
                  {
                     this._verticalPageIndex = _loc1_;
                  }
                  else
                  {
                     this._verticalPageIndex = Math.floor(_loc3_);
                  }
               }
            }
            else
            {
               this._verticalPageIndex = this._minVerticalScrollPosition;
            }
            if(this._verticalPageIndex < this._minVerticalScrollPosition)
            {
               this._verticalPageIndex = this._minVerticalScrollPosition;
            }
            if(this._verticalPageIndex > this._maxVerticalPageIndex)
            {
               this._verticalPageIndex = this._maxVerticalPageIndex;
            }
         }
      }
      
      public function throwHorizontally() : void
      {
         var _loc4_:int = 0;
         var _loc5_:Number = NaN;
         var _loc2_:* = 2.33;
         var _loc7_:Vector.<Number> = new <Number>[1,1.33,1.66,2];
         var _loc6_:Number = this._velocityX * _loc2_;
         var _loc1_:int = this._previousVelocityX.length;
         var _loc3_:* = _loc2_;
         _loc4_ = 0;
         while(_loc4_ < _loc1_)
         {
            _loc5_ = _loc7_[_loc4_];
            _loc6_ += this._previousVelocityX.shift() * _loc5_;
            _loc3_ += _loc5_;
            _loc4_++;
         }
         super.throwHorizontally(_loc6_ / _loc3_);
      }
      
      override public function dispose() : void
      {
         _horizontalThrowToPageCallback = null;
         _verticalThrowToPageCallback = null;
         super.dispose();
      }
   }
}
