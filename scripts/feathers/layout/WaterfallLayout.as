package feathers.layout
{
   import feathers.core.IValidating;
   import flash.errors.IllegalOperationError;
   import flash.geom.Point;
   import starling.display.DisplayObject;
   import starling.events.EventDispatcher;
   
   public class WaterfallLayout extends EventDispatcher implements IVariableVirtualLayout
   {
      
      public static const HORIZONTAL_ALIGN_LEFT:String = "left";
      
      public static const HORIZONTAL_ALIGN_CENTER:String = "center";
      
      public static const HORIZONTAL_ALIGN_RIGHT:String = "right";
       
      
      protected var _horizontalGap:Number = 0;
      
      protected var _verticalGap:Number = 0;
      
      protected var _paddingTop:Number = 0;
      
      protected var _paddingRight:Number = 0;
      
      protected var _paddingBottom:Number = 0;
      
      protected var _paddingLeft:Number = 0;
      
      protected var _horizontalAlign:String = "center";
      
      protected var _requestedColumnCount:int = 0;
      
      protected var _useVirtualLayout:Boolean = true;
      
      protected var _typicalItem:DisplayObject;
      
      protected var _hasVariableItemDimensions:Boolean = true;
      
      protected var _heightCache:Array;
      
      public function WaterfallLayout()
      {
         _heightCache = [];
         super();
      }
      
      public function get gap() : Number
      {
         return this._horizontalGap;
      }
      
      public function set gap(param1:Number) : void
      {
         this.horizontalGap = param1;
         this.verticalGap = param1;
      }
      
      public function get horizontalGap() : Number
      {
         return this._horizontalGap;
      }
      
      public function set horizontalGap(param1:Number) : void
      {
         if(this._horizontalGap == param1)
         {
            return;
         }
         this._horizontalGap = param1;
         this.dispatchEventWith("change");
      }
      
      public function get verticalGap() : Number
      {
         return this._verticalGap;
      }
      
      public function set verticalGap(param1:Number) : void
      {
         if(this._verticalGap == param1)
         {
            return;
         }
         this._verticalGap = param1;
         this.dispatchEventWith("change");
      }
      
      public function get padding() : Number
      {
         return this._paddingTop;
      }
      
      public function set padding(param1:Number) : void
      {
         this.paddingTop = param1;
         this.paddingRight = param1;
         this.paddingBottom = param1;
         this.paddingLeft = param1;
      }
      
      public function get paddingTop() : Number
      {
         return this._paddingTop;
      }
      
      public function set paddingTop(param1:Number) : void
      {
         if(this._paddingTop == param1)
         {
            return;
         }
         this._paddingTop = param1;
         this.dispatchEventWith("change");
      }
      
      public function get paddingRight() : Number
      {
         return this._paddingRight;
      }
      
      public function set paddingRight(param1:Number) : void
      {
         if(this._paddingRight == param1)
         {
            return;
         }
         this._paddingRight = param1;
         this.dispatchEventWith("change");
      }
      
      public function get paddingBottom() : Number
      {
         return this._paddingBottom;
      }
      
      public function set paddingBottom(param1:Number) : void
      {
         if(this._paddingBottom == param1)
         {
            return;
         }
         this._paddingBottom = param1;
         this.dispatchEventWith("change");
      }
      
      public function get paddingLeft() : Number
      {
         return this._paddingLeft;
      }
      
      public function set paddingLeft(param1:Number) : void
      {
         if(this._paddingLeft == param1)
         {
            return;
         }
         this._paddingLeft = param1;
         this.dispatchEventWith("change");
      }
      
      public function get horizontalAlign() : String
      {
         return this._horizontalAlign;
      }
      
      public function set horizontalAlign(param1:String) : void
      {
         if(this._horizontalAlign == param1)
         {
            return;
         }
         this._horizontalAlign = param1;
         this.dispatchEventWith("change");
      }
      
      public function get requestedColumnCount() : int
      {
         return this._requestedColumnCount;
      }
      
      public function set requestedColumnCount(param1:int) : void
      {
         if(param1 < 0)
         {
            throw RangeError("requestedColumnCount requires a value >= 0");
         }
         if(this._requestedColumnCount == param1)
         {
            return;
         }
         this._requestedColumnCount = param1;
         this.dispatchEventWith("change");
      }
      
      public function get useVirtualLayout() : Boolean
      {
         return this._useVirtualLayout;
      }
      
      public function set useVirtualLayout(param1:Boolean) : void
      {
         if(this._useVirtualLayout == param1)
         {
            return;
         }
         this._useVirtualLayout = param1;
         this.dispatchEventWith("change");
      }
      
      public function get typicalItem() : DisplayObject
      {
         return this._typicalItem;
      }
      
      public function set typicalItem(param1:DisplayObject) : void
      {
         if(this._typicalItem == param1)
         {
            return;
         }
         this._typicalItem = param1;
         this.dispatchEventWith("change");
      }
      
      public function get hasVariableItemDimensions() : Boolean
      {
         return this._hasVariableItemDimensions;
      }
      
      public function set hasVariableItemDimensions(param1:Boolean) : void
      {
         if(this._hasVariableItemDimensions == param1)
         {
            return;
         }
         this._hasVariableItemDimensions = param1;
         this.dispatchEventWith("change");
      }
      
      public function get requiresLayoutOnScroll() : Boolean
      {
         return this._useVirtualLayout;
      }
      
      public function layout(param1:Vector.<DisplayObject>, param2:ViewPortBounds = null, param3:LayoutBoundsResult = null) : LayoutBoundsResult
      {
         var _loc28_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc17_:* = null;
         var _loc24_:int = 0;
         var _loc13_:Number = NaN;
         var _loc9_:* = NaN;
         var _loc8_:* = null;
         var _loc23_:Number = NaN;
         var _loc26_:int = 0;
         var _loc11_:Number = NaN;
         var _loc31_:Number = !!param2 ? param2.x : 0;
         var _loc32_:Number = !!param2 ? param2.y : 0;
         var _loc25_:Number = !!param2 ? param2.minWidth : 0;
         var _loc10_:Number = !!param2 ? param2.minHeight : 0;
         var _loc16_:Number = !!param2 ? param2.maxWidth : Infinity;
         var _loc12_:Number = !!param2 ? param2.maxHeight : Infinity;
         var _loc30_:Number = !!param2 ? param2.explicitWidth : NaN;
         var _loc33_:Number = !!param2 ? param2.explicitHeight : NaN;
         var _loc20_:* = _loc30_ !== _loc30_;
         var _loc14_:* = _loc33_ !== _loc33_;
         if(this._useVirtualLayout)
         {
            if(this._typicalItem is IValidating)
            {
               IValidating(this._typicalItem).validate();
            }
            _loc28_ = !!this._typicalItem ? this._typicalItem.width : 0;
            _loc22_ = !!this._typicalItem ? this._typicalItem.height : 0;
         }
         var _loc15_:* = 0;
         if(this._useVirtualLayout)
         {
            _loc15_ = _loc28_;
         }
         else if(param1.length > 0)
         {
            if((_loc17_ = param1[0]) is IValidating)
            {
               IValidating(_loc17_).validate();
            }
            _loc15_ = Number(_loc17_.width);
         }
         var _loc18_:* = _loc30_;
         if(_loc20_)
         {
            if(_loc16_ < Infinity)
            {
               _loc18_ = _loc16_;
            }
            else if(this._requestedColumnCount > 0)
            {
               _loc18_ = Number((_loc15_ + this._horizontalGap) * this._requestedColumnCount - this._horizontalGap);
            }
            else
            {
               _loc18_ = _loc15_;
            }
            if((_loc18_ += this._paddingLeft + this._paddingRight) < _loc25_)
            {
               _loc18_ = _loc25_;
            }
            else if(_loc18_ > _loc16_)
            {
               _loc18_ = _loc16_;
            }
         }
         var _loc27_:int = (_loc18_ + this._horizontalGap - this._paddingLeft - this._paddingRight) / (_loc15_ + this._horizontalGap);
         if(this._requestedColumnCount > 0 && _loc27_ > this._requestedColumnCount)
         {
            _loc27_ = this._requestedColumnCount;
         }
         else if(_loc27_ < 1)
         {
            _loc27_ = 1;
         }
         var _loc5_:Vector.<Number> = new Vector.<Number>(0);
         _loc24_ = 0;
         while(_loc24_ < _loc27_)
         {
            _loc5_[_loc24_] = this._paddingTop;
            _loc24_++;
         }
         _loc5_.fixed = true;
         var _loc19_:* = 0;
         if(this._horizontalAlign == "right")
         {
            _loc19_ = Number(_loc18_ - this._paddingLeft - this._paddingRight - (_loc27_ * (_loc15_ + this._horizontalGap) - this._horizontalGap));
         }
         else if(this._horizontalAlign == "center")
         {
            _loc19_ = Number(Math.round((_loc18_ - this._paddingLeft - this._paddingRight - (_loc27_ * (_loc15_ + this._horizontalGap) - this._horizontalGap)) / 2));
         }
         var _loc29_:int = param1.length;
         var _loc6_:* = 0;
         var _loc21_:* = Number(_loc5_[_loc6_]);
         _loc24_ = 0;
         for(; _loc24_ < _loc29_; _loc24_++)
         {
            _loc17_ = param1[_loc24_];
            if(this._useVirtualLayout && this._hasVariableItemDimensions)
            {
               _loc13_ = this._heightCache[_loc24_];
            }
            if(this._useVirtualLayout && !_loc17_)
            {
               if(!this._hasVariableItemDimensions || _loc13_ !== _loc13_)
               {
                  _loc9_ = _loc22_;
               }
               else
               {
                  _loc9_ = _loc13_;
               }
            }
            else
            {
               if(_loc17_ is ILayoutDisplayObject)
               {
                  if(!(_loc8_ = ILayoutDisplayObject(_loc17_)).includeInLayout)
                  {
                     continue;
                  }
               }
               if(_loc17_ is IValidating)
               {
                  IValidating(_loc17_).validate();
               }
               _loc23_ = _loc15_ / _loc17_.width;
               _loc17_.width *= _loc23_;
               if(_loc17_ is IValidating)
               {
                  IValidating(_loc17_).validate();
               }
               if(this._useVirtualLayout)
               {
                  if(this._hasVariableItemDimensions)
                  {
                     if((_loc9_ = Number(_loc17_.height)) != _loc13_)
                     {
                        this._heightCache[_loc24_] = _loc9_;
                        this.dispatchEventWith("change");
                     }
                  }
                  else
                  {
                     _loc17_.height = _loc9_ = _loc22_;
                  }
               }
               else
               {
                  _loc9_ = Number(_loc17_.height);
               }
            }
            _loc21_ += _loc9_;
            _loc26_ = 0;
            while(_loc26_ < _loc27_)
            {
               if(_loc26_ !== _loc6_)
               {
                  if((_loc11_ = _loc5_[_loc26_] + _loc9_) < _loc21_)
                  {
                     _loc6_ = _loc26_;
                     _loc21_ = _loc11_;
                  }
               }
               _loc26_++;
            }
            if(_loc17_)
            {
               _loc17_.x = _loc17_.pivotX + _loc31_ + _loc19_ + this._paddingLeft + _loc6_ * (_loc15_ + this._horizontalGap);
               _loc17_.y = _loc17_.pivotY + _loc32_ + _loc21_ - _loc9_;
            }
            _loc21_ += this._verticalGap;
            _loc5_[_loc6_] = _loc21_;
         }
         var _loc4_:* = Number(_loc5_[0]);
         _loc24_ = 1;
         while(_loc24_ < _loc27_)
         {
            if((_loc11_ = _loc5_[_loc24_]) > _loc4_)
            {
               _loc4_ = _loc11_;
            }
            _loc24_++;
         }
         if((_loc4_ = Number((_loc4_ -= this._verticalGap) + this._paddingBottom)) < 0)
         {
            _loc4_ = 0;
         }
         var _loc7_:* = _loc33_;
         if(_loc14_)
         {
            if((_loc7_ = _loc4_) < _loc10_)
            {
               _loc7_ = _loc10_;
            }
            else if(_loc7_ > _loc12_)
            {
               _loc7_ = _loc12_;
            }
         }
         if(!param3)
         {
            param3 = new LayoutBoundsResult();
         }
         param3.contentX = 0;
         param3.contentWidth = _loc18_;
         param3.contentY = 0;
         param3.contentHeight = _loc4_;
         param3.viewPortWidth = _loc18_;
         param3.viewPortHeight = _loc7_;
         return param3;
      }
      
      public function measureViewPort(param1:int, param2:ViewPortBounds = null, param3:Point = null) : Point
      {
         var _loc6_:* = undefined;
         var _loc12_:int = 0;
         var _loc7_:* = 0;
         var _loc9_:* = NaN;
         var _loc11_:* = NaN;
         var _loc14_:int = 0;
         var _loc19_:Number = NaN;
         var _loc4_:* = NaN;
         if(!param3)
         {
            param3 = new Point();
         }
         if(!this._useVirtualLayout)
         {
            throw new IllegalOperationError("measureViewPort() may be called only if useVirtualLayout is true.");
         }
         var _loc17_:Number = !!param2 ? param2.explicitWidth : NaN;
         var _loc23_:Number = !!param2 ? param2.explicitHeight : NaN;
         var _loc8_:* = _loc17_ !== _loc17_;
         var _loc21_:* = _loc23_ !== _loc23_;
         if(!_loc8_ && !_loc21_)
         {
            param3.x = _loc17_;
            param3.y = _loc23_;
            return param3;
         }
         var _loc13_:Number = !!param2 ? param2.minWidth : 0;
         var _loc18_:Number = !!param2 ? param2.minHeight : 0;
         var _loc24_:Number = !!param2 ? param2.maxWidth : Infinity;
         var _loc20_:Number = !!param2 ? param2.maxHeight : Infinity;
         if(this._typicalItem is IValidating)
         {
            IValidating(this._typicalItem).validate();
         }
         var _loc16_:Number = !!this._typicalItem ? this._typicalItem.width : 0;
         var _loc10_:Number = !!this._typicalItem ? this._typicalItem.height : 0;
         var _loc22_:* = _loc16_;
         var _loc5_:* = _loc17_;
         if(_loc8_)
         {
            if(_loc24_ < Infinity)
            {
               _loc5_ = _loc24_;
            }
            else if(this._requestedColumnCount > 0)
            {
               _loc5_ = Number((_loc22_ + this._horizontalGap) * this._requestedColumnCount - this._horizontalGap);
            }
            else
            {
               _loc5_ = _loc22_;
            }
            if((_loc5_ += this._paddingLeft + this._paddingRight) < _loc13_)
            {
               _loc5_ = _loc13_;
            }
            else if(_loc5_ > _loc24_)
            {
               _loc5_ = _loc24_;
            }
         }
         var _loc15_:int = (_loc5_ + this._horizontalGap - this._paddingLeft - this._paddingRight) / (_loc22_ + this._horizontalGap);
         if(this._requestedColumnCount > 0 && _loc15_ > this._requestedColumnCount)
         {
            _loc15_ = this._requestedColumnCount;
         }
         else if(_loc15_ < 1)
         {
            _loc15_ = 1;
         }
         if(_loc8_)
         {
            param3.x = this._paddingLeft + this._paddingRight + _loc15_ * (_loc22_ + this._horizontalGap) - this._horizontalGap;
         }
         else
         {
            param3.x = _loc17_;
         }
         if(_loc21_)
         {
            if(this._hasVariableItemDimensions)
            {
               _loc6_ = new Vector.<Number>(0);
               _loc12_ = 0;
               while(_loc12_ < _loc15_)
               {
                  _loc6_[_loc12_] = this._paddingTop;
                  _loc12_++;
               }
               _loc6_.fixed = true;
               _loc7_ = 0;
               _loc9_ = Number(_loc6_[_loc7_]);
               _loc12_ = 0;
               while(_loc12_ < param1)
               {
                  if(this._hasVariableItemDimensions)
                  {
                     _loc11_ = Number(this._heightCache[_loc12_]);
                     if(_loc11_ !== _loc11_)
                     {
                        _loc11_ = _loc10_;
                     }
                  }
                  else
                  {
                     _loc11_ = _loc10_;
                  }
                  _loc9_ += _loc11_;
                  _loc14_ = 0;
                  while(_loc14_ < _loc15_)
                  {
                     if(_loc14_ !== _loc7_)
                     {
                        if((_loc19_ = _loc6_[_loc14_] + _loc11_) < _loc9_)
                        {
                           _loc7_ = _loc14_;
                           _loc9_ = _loc19_;
                        }
                     }
                     _loc14_++;
                  }
                  _loc9_ += this._verticalGap;
                  _loc6_[_loc7_] = _loc9_;
                  _loc12_++;
               }
               _loc4_ = Number(_loc6_[0]);
               _loc12_ = 1;
               while(_loc12_ < _loc15_)
               {
                  if((_loc19_ = _loc6_[_loc12_]) > _loc4_)
                  {
                     _loc4_ = _loc19_;
                  }
                  _loc12_++;
               }
               if((_loc4_ = Number((_loc4_ -= this._verticalGap) + this._paddingBottom)) < 0)
               {
                  _loc4_ = 0;
               }
               if(_loc4_ < _loc18_)
               {
                  _loc4_ = _loc18_;
               }
               else if(_loc4_ > _loc20_)
               {
                  _loc4_ = _loc20_;
               }
               param3.y = _loc4_;
            }
            else
            {
               param3.y = this._paddingTop + this._paddingBottom + Math.ceil(param1 / _loc15_) * (_loc10_ + this._verticalGap) - this._verticalGap;
            }
         }
         else
         {
            param3.y = _loc23_;
         }
         return param3;
      }
      
      public function getVisibleIndicesAtScrollPosition(param1:Number, param2:Number, param3:Number, param4:Number, param5:int, param6:Vector.<int> = null) : Vector.<int>
      {
         var _loc8_:* = undefined;
         var _loc14_:* = 0;
         var _loc10_:Number = NaN;
         var _loc9_:* = 0;
         var _loc11_:* = NaN;
         var _loc13_:* = NaN;
         var _loc16_:int = 0;
         var _loc20_:Number = NaN;
         var _loc15_:int = 0;
         if(param6)
         {
            param6.length = 0;
         }
         else
         {
            param6 = new Vector.<int>(0);
         }
         if(!this._useVirtualLayout)
         {
            throw new IllegalOperationError("getVisibleIndicesAtScrollPosition() may be called only if useVirtualLayout is true.");
         }
         if(this._typicalItem is IValidating)
         {
            IValidating(this._typicalItem).validate();
         }
         var _loc18_:Number = !!this._typicalItem ? this._typicalItem.width : 0;
         var _loc12_:Number = !!this._typicalItem ? this._typicalItem.height : 0;
         var _loc21_:* = _loc18_;
         var _loc17_:int = (param3 + this._horizontalGap - this._paddingLeft - this._paddingRight) / (_loc21_ + this._horizontalGap);
         if(this._requestedColumnCount > 0 && _loc17_ > this._requestedColumnCount)
         {
            _loc17_ = this._requestedColumnCount;
         }
         else if(_loc17_ < 1)
         {
            _loc17_ = 1;
         }
         var _loc7_:int = 0;
         if(this._hasVariableItemDimensions)
         {
            _loc8_ = new Vector.<Number>(0);
            _loc14_ = 0;
            while(_loc14_ < _loc17_)
            {
               _loc8_[_loc14_] = this._paddingTop;
               _loc14_++;
            }
            _loc8_.fixed = true;
            _loc10_ = param2 + param4;
            _loc9_ = 0;
            _loc11_ = Number(_loc8_[_loc9_]);
            _loc14_ = 0;
            while(_loc14_ < param5)
            {
               if(this._hasVariableItemDimensions)
               {
                  _loc13_ = Number(this._heightCache[_loc14_]);
                  if(_loc13_ !== _loc13_)
                  {
                     _loc13_ = _loc12_;
                  }
               }
               else
               {
                  _loc13_ = _loc12_;
               }
               _loc11_ += _loc13_;
               _loc16_ = 0;
               while(_loc16_ < _loc17_)
               {
                  if(_loc16_ !== _loc9_)
                  {
                     if((_loc20_ = _loc8_[_loc16_] + _loc13_) < _loc11_)
                     {
                        _loc9_ = _loc16_;
                        _loc11_ = _loc20_;
                     }
                  }
                  _loc16_++;
               }
               if(_loc11_ > param2 && _loc11_ - _loc13_ < _loc10_)
               {
                  param6[_loc7_] = _loc14_;
                  _loc7_++;
               }
               _loc11_ += this._verticalGap;
               _loc8_[_loc9_] = _loc11_;
               _loc14_++;
            }
            return param6;
         }
         var _loc19_:int = Math.ceil(param4 / (_loc12_ + this._verticalGap)) + 1;
         var _loc23_:int;
         if((_loc23_ = (param2 - this._paddingTop) / (_loc12_ + this._verticalGap)) < 0)
         {
            _loc23_ = 0;
         }
         var _loc22_:int;
         if((_loc22_ = _loc23_ + _loc19_) >= param5)
         {
            _loc22_ = param5 - 1;
         }
         if((_loc23_ = _loc22_ - _loc19_) < 0)
         {
            _loc23_ = 0;
         }
         _loc14_ = _loc23_;
         while(_loc14_ <= _loc22_)
         {
            _loc16_ = 0;
            while(_loc16_ < _loc17_)
            {
               if((_loc15_ = _loc14_ * _loc17_ + _loc16_) >= 0 && _loc14_ < param5)
               {
                  param6[_loc7_] = _loc15_;
               }
               else if(_loc15_ < 0)
               {
                  param6[_loc7_] = param5 + _loc15_;
               }
               else if(_loc15_ >= param5)
               {
                  param6[_loc7_] = _loc15_ - param5;
               }
               _loc7_++;
               _loc16_++;
            }
            _loc14_++;
         }
         return param6;
      }
      
      public function resetVariableVirtualCache() : void
      {
         this._heightCache.length = 0;
      }
      
      public function resetVariableVirtualCacheAtIndex(param1:int, param2:DisplayObject = null) : void
      {
         delete this._heightCache[param1];
         if(param2)
         {
            this._heightCache[param1] = param2.height;
            this.dispatchEventWith("change");
         }
      }
      
      public function addToVariableVirtualCacheAtIndex(param1:int, param2:DisplayObject = null) : void
      {
         var _loc3_:* = !!param2 ? param2.height : undefined;
         this._heightCache.insertAt(param1,_loc3_);
      }
      
      public function removeFromVariableVirtualCacheAtIndex(param1:int) : void
      {
         this._heightCache.removeAt(param1);
      }
      
      public function getNearestScrollPositionForIndex(param1:int, param2:Number, param3:Number, param4:Vector.<DisplayObject>, param5:Number, param6:Number, param7:Number, param8:Number, param9:Point = null) : Point
      {
         var _loc11_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc10_:Number = this.calculateMaxScrollYOfIndex(param1,param4,param5,param6,param7,param8);
         if(this._useVirtualLayout)
         {
            if(this._hasVariableItemDimensions)
            {
               _loc11_ = this._heightCache[param1];
               if(_loc11_ !== _loc11_)
               {
                  _loc11_ = this._typicalItem.height;
               }
            }
            else
            {
               _loc11_ = this._typicalItem.height;
            }
         }
         else
         {
            _loc11_ = param4[param1].height;
         }
         if(!param9)
         {
            param9 = new Point();
         }
         param9.x = 0;
         var _loc12_:Number = _loc10_ - (param8 - _loc11_);
         if(param3 >= _loc12_ && param3 <= _loc10_)
         {
            param9.y = param3;
         }
         else
         {
            _loc13_ = Math.abs(_loc10_ - param3);
            if((_loc14_ = Math.abs(_loc12_ - param3)) < _loc13_)
            {
               param9.y = _loc12_;
            }
            else
            {
               param9.y = _loc10_;
            }
         }
         return param9;
      }
      
      public function getScrollPositionForIndex(param1:int, param2:Vector.<DisplayObject>, param3:Number, param4:Number, param5:Number, param6:Number, param7:Point = null) : Point
      {
         var _loc9_:Number = NaN;
         var _loc8_:Number = this.calculateMaxScrollYOfIndex(param1,param2,param3,param4,param5,param6);
         if(this._useVirtualLayout)
         {
            if(this._hasVariableItemDimensions)
            {
               _loc9_ = this._heightCache[param1];
               if(_loc9_ !== _loc9_)
               {
                  _loc9_ = this._typicalItem.height;
               }
            }
            else
            {
               _loc9_ = this._typicalItem.height;
            }
         }
         else
         {
            _loc9_ = param2[param1].height;
         }
         if(!param7)
         {
            param7 = new Point();
         }
         param7.x = 0;
         param7.y = _loc8_ - Math.round((param6 - _loc9_) / 2);
         return param7;
      }
      
      protected function calculateMaxScrollYOfIndex(param1:int, param2:Vector.<DisplayObject>, param3:Number, param4:Number, param5:Number, param6:Number) : Number
      {
         var _loc19_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc8_:* = null;
         var _loc16_:int = 0;
         var _loc22_:Number = NaN;
         var _loc14_:* = NaN;
         var _loc11_:* = null;
         var _loc15_:Number = NaN;
         var _loc17_:int = 0;
         var _loc21_:Number = NaN;
         if(param2.length == 0)
         {
            return 0;
         }
         if(this._useVirtualLayout)
         {
            if(this._typicalItem is IValidating)
            {
               IValidating(this._typicalItem).validate();
            }
            _loc19_ = !!this._typicalItem ? this._typicalItem.width : 0;
            _loc13_ = !!this._typicalItem ? this._typicalItem.height : 0;
         }
         var _loc23_:* = 0;
         if(this._useVirtualLayout)
         {
            _loc23_ = _loc19_;
         }
         else if(param2.length > 0)
         {
            if((_loc8_ = param2[0]) is IValidating)
            {
               IValidating(_loc8_).validate();
            }
            _loc23_ = Number(_loc8_.width);
         }
         var _loc18_:int = (param5 + this._horizontalGap - this._paddingLeft - this._paddingRight) / (_loc23_ + this._horizontalGap);
         if(this._requestedColumnCount > 0 && _loc18_ > this._requestedColumnCount)
         {
            _loc18_ = this._requestedColumnCount;
         }
         else if(_loc18_ < 1)
         {
            _loc18_ = 1;
         }
         var _loc9_:Vector.<Number> = new Vector.<Number>(0);
         _loc16_ = 0;
         while(_loc16_ < _loc18_)
         {
            _loc9_[_loc16_] = this._paddingTop;
            _loc16_++;
         }
         _loc9_.fixed = true;
         var _loc20_:int = param2.length;
         var _loc10_:* = 0;
         var _loc12_:* = Number(_loc9_[_loc10_]);
         _loc16_ = 0;
         for(; _loc16_ < _loc20_; _loc16_++)
         {
            _loc8_ = param2[_loc16_];
            if(this._useVirtualLayout && this._hasVariableItemDimensions)
            {
               _loc22_ = this._heightCache[_loc16_];
            }
            if(this._useVirtualLayout && !_loc8_)
            {
               if(!this._hasVariableItemDimensions || _loc22_ !== _loc22_)
               {
                  _loc14_ = _loc13_;
               }
               else
               {
                  _loc14_ = _loc22_;
               }
            }
            else
            {
               if(_loc8_ is ILayoutDisplayObject)
               {
                  if(!(_loc11_ = ILayoutDisplayObject(_loc8_)).includeInLayout)
                  {
                     continue;
                  }
               }
               if(_loc8_ is IValidating)
               {
                  IValidating(_loc8_).validate();
               }
               _loc15_ = _loc23_ / _loc8_.width;
               _loc8_.width *= _loc15_;
               if(_loc8_ is IValidating)
               {
                  IValidating(_loc8_).validate();
               }
               if(this._useVirtualLayout)
               {
                  if(this._hasVariableItemDimensions)
                  {
                     if((_loc14_ = Number(_loc8_.height)) != _loc22_)
                     {
                        this._heightCache[_loc16_] = _loc14_;
                        this.dispatchEventWith("change");
                     }
                  }
                  else
                  {
                     _loc8_.height = _loc14_ = _loc13_;
                  }
               }
               else
               {
                  _loc14_ = Number(_loc8_.height);
               }
            }
            _loc12_ += _loc14_;
            _loc17_ = 0;
            while(_loc17_ < _loc18_)
            {
               if(_loc17_ !== _loc10_)
               {
                  if((_loc21_ = _loc9_[_loc17_] + _loc14_) < _loc12_)
                  {
                     _loc10_ = _loc17_;
                     _loc12_ = _loc21_;
                  }
               }
               _loc17_++;
            }
            if(_loc16_ === param1)
            {
               return _loc12_ - _loc14_;
            }
            _loc12_ += this._verticalGap;
            _loc9_[_loc10_] = _loc12_;
         }
         var _loc7_:* = Number(_loc9_[0]);
         _loc16_ = 1;
         while(_loc16_ < _loc18_)
         {
            if((_loc21_ = _loc9_[_loc16_]) > _loc7_)
            {
               _loc7_ = _loc21_;
            }
            _loc16_++;
         }
         if((_loc7_ = Number((_loc7_ = Number((_loc7_ -= this._verticalGap) + this._paddingBottom)) - param6)) < 0)
         {
            _loc7_ = 0;
         }
         return _loc7_;
      }
   }
}
