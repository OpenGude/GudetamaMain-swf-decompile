package feathers.layout
{
   import feathers.core.IValidating;
   import flash.errors.IllegalOperationError;
   import flash.geom.Point;
   import starling.display.DisplayObject;
   import starling.events.EventDispatcher;
   
   public class TiledRowsLayout extends EventDispatcher implements IVirtualLayout
   {
      
      public static const VERTICAL_ALIGN_TOP:String = "top";
      
      public static const VERTICAL_ALIGN_MIDDLE:String = "middle";
      
      public static const VERTICAL_ALIGN_BOTTOM:String = "bottom";
      
      public static const HORIZONTAL_ALIGN_LEFT:String = "left";
      
      public static const HORIZONTAL_ALIGN_CENTER:String = "center";
      
      public static const HORIZONTAL_ALIGN_RIGHT:String = "right";
      
      public static const TILE_VERTICAL_ALIGN_TOP:String = "top";
      
      public static const TILE_VERTICAL_ALIGN_MIDDLE:String = "middle";
      
      public static const TILE_VERTICAL_ALIGN_BOTTOM:String = "bottom";
      
      public static const TILE_VERTICAL_ALIGN_JUSTIFY:String = "justify";
      
      public static const TILE_HORIZONTAL_ALIGN_LEFT:String = "left";
      
      public static const TILE_HORIZONTAL_ALIGN_CENTER:String = "center";
      
      public static const TILE_HORIZONTAL_ALIGN_RIGHT:String = "right";
      
      public static const TILE_HORIZONTAL_ALIGN_JUSTIFY:String = "justify";
      
      public static const PAGING_HORIZONTAL:String = "horizontal";
      
      public static const PAGING_VERTICAL:String = "vertical";
      
      public static const PAGING_NONE:String = "none";
       
      
      protected var _discoveredItemsCache:Vector.<DisplayObject>;
      
      protected var _horizontalGap:Number = 0;
      
      protected var _verticalGap:Number = 0;
      
      protected var _paddingTop:Number = 0;
      
      protected var _paddingRight:Number = 0;
      
      protected var _paddingBottom:Number = 0;
      
      protected var _paddingLeft:Number = 0;
      
      protected var _requestedColumnCount:int = 0;
      
      protected var _requestedRowCount:int = 0;
      
      protected var _verticalAlign:String = "top";
      
      protected var _horizontalAlign:String = "center";
      
      protected var _tileVerticalAlign:String = "middle";
      
      protected var _tileHorizontalAlign:String = "center";
      
      protected var _paging:String = "none";
      
      protected var _useSquareTiles:Boolean = true;
      
      protected var _distributeWidths:Boolean = false;
      
      protected var _distributeHeights:Boolean = false;
      
      protected var _useVirtualLayout:Boolean = true;
      
      protected var _typicalItem:DisplayObject;
      
      protected var _resetTypicalItemDimensionsOnMeasure:Boolean = false;
      
      protected var _typicalItemWidth:Number = NaN;
      
      protected var _typicalItemHeight:Number = NaN;
      
      public function TiledRowsLayout()
      {
         _discoveredItemsCache = new Vector.<DisplayObject>(0);
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
      
      public function get requestedRowCount() : int
      {
         return this._requestedRowCount;
      }
      
      public function set requestedRowCount(param1:int) : void
      {
         if(param1 < 0)
         {
            throw RangeError("requestedRowCount requires a value >= 0");
         }
         if(this._requestedRowCount == param1)
         {
            return;
         }
         this._requestedRowCount = param1;
         this.dispatchEventWith("change");
      }
      
      public function get verticalAlign() : String
      {
         return this._verticalAlign;
      }
      
      public function set verticalAlign(param1:String) : void
      {
         if(this._verticalAlign == param1)
         {
            return;
         }
         this._verticalAlign = param1;
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
      
      public function get tileVerticalAlign() : String
      {
         return this._tileVerticalAlign;
      }
      
      public function set tileVerticalAlign(param1:String) : void
      {
         if(this._tileVerticalAlign == param1)
         {
            return;
         }
         this._tileVerticalAlign = param1;
         this.dispatchEventWith("change");
      }
      
      public function get tileHorizontalAlign() : String
      {
         return this._tileHorizontalAlign;
      }
      
      public function set tileHorizontalAlign(param1:String) : void
      {
         if(this._tileHorizontalAlign == param1)
         {
            return;
         }
         this._tileHorizontalAlign = param1;
         this.dispatchEventWith("change");
      }
      
      public function get paging() : String
      {
         return this._paging;
      }
      
      public function set paging(param1:String) : void
      {
         if(this._paging == param1)
         {
            return;
         }
         this._paging = param1;
         this.dispatchEventWith("change");
      }
      
      public function get useSquareTiles() : Boolean
      {
         return this._useSquareTiles;
      }
      
      public function set useSquareTiles(param1:Boolean) : void
      {
         if(this._useSquareTiles == param1)
         {
            return;
         }
         this._useSquareTiles = param1;
         this.dispatchEventWith("change");
      }
      
      public function get distributeWidths() : Boolean
      {
         return this._distributeWidths;
      }
      
      public function set distributeWidths(param1:Boolean) : void
      {
         if(this._distributeWidths === param1)
         {
            return;
         }
         this._distributeWidths = param1;
         this.dispatchEventWith("change");
      }
      
      public function get distributeHeights() : Boolean
      {
         return this._distributeHeights;
      }
      
      public function set distributeHeights(param1:Boolean) : void
      {
         if(this._distributeHeights === param1)
         {
            return;
         }
         this._distributeHeights = param1;
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
      
      public function get resetTypicalItemDimensionsOnMeasure() : Boolean
      {
         return this._resetTypicalItemDimensionsOnMeasure;
      }
      
      public function set resetTypicalItemDimensionsOnMeasure(param1:Boolean) : void
      {
         if(this._resetTypicalItemDimensionsOnMeasure == param1)
         {
            return;
         }
         this._resetTypicalItemDimensionsOnMeasure = param1;
         this.dispatchEventWith("change");
      }
      
      public function get typicalItemWidth() : Number
      {
         return this._typicalItemWidth;
      }
      
      public function set typicalItemWidth(param1:Number) : void
      {
         if(this._typicalItemWidth == param1)
         {
            return;
         }
         this._typicalItemWidth = param1;
         this.dispatchEventWith("change");
      }
      
      public function get typicalItemHeight() : Number
      {
         return this._typicalItemHeight;
      }
      
      public function set typicalItemHeight(param1:Number) : void
      {
         if(this._typicalItemHeight == param1)
         {
            return;
         }
         this._typicalItemHeight = param1;
         this.dispatchEventWith("change");
      }
      
      public function get requiresLayoutOnScroll() : Boolean
      {
         return this._useVirtualLayout;
      }
      
      public function layout(param1:Vector.<DisplayObject>, param2:ViewPortBounds = null, param3:LayoutBoundsResult = null) : LayoutBoundsResult
      {
         var _loc28_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc25_:int = 0;
         var _loc21_:* = null;
         var _loc17_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc23_:* = NaN;
         var _loc6_:* = NaN;
         var _loc22_:* = undefined;
         var _loc7_:int = 0;
         var _loc9_:int = 0;
         var _loc18_:* = NaN;
         var _loc4_:* = NaN;
         if(!param3)
         {
            param3 = new LayoutBoundsResult();
         }
         if(param1.length === 0)
         {
            param3.contentX = 0;
            param3.contentY = 0;
            param3.contentWidth = this._paddingLeft + this._paddingRight;
            param3.contentHeight = this._paddingTop + this._paddingBottom;
            param3.viewPortWidth = param3.contentWidth;
            param3.viewPortHeight = param3.contentHeight;
            return param3;
         }
         var _loc42_:Number = !!param2 ? param2.scrollX : 0;
         var _loc37_:Number = !!param2 ? param2.scrollY : 0;
         var _loc32_:Number = !!param2 ? param2.x : 0;
         var _loc34_:Number = !!param2 ? param2.y : 0;
         var _loc26_:Number = !!param2 ? param2.minWidth : 0;
         var _loc11_:Number = !!param2 ? param2.minHeight : 0;
         var _loc19_:Number = !!param2 ? param2.maxWidth : Infinity;
         var _loc14_:Number = !!param2 ? param2.maxHeight : Infinity;
         var _loc31_:Number = !!param2 ? param2.explicitWidth : NaN;
         var _loc38_:Number = !!param2 ? param2.explicitHeight : NaN;
         if(this._useVirtualLayout)
         {
            this.prepareTypicalItem();
            _loc28_ = !!this._typicalItem ? this._typicalItem.width : 0;
            _loc24_ = !!this._typicalItem ? this._typicalItem.height : 0;
         }
         this.validateItems(param1);
         this._discoveredItemsCache.length = 0;
         var _loc29_:int = param1.length;
         var _loc27_:* = 0;
         var _loc43_:* = 0;
         if(this._useVirtualLayout)
         {
            _loc27_ = _loc28_;
            _loc43_ = _loc24_;
         }
         else
         {
            _loc25_ = 0;
            while(_loc25_ < _loc29_)
            {
               if(_loc21_ = param1[_loc25_])
               {
                  if(!(_loc21_ is ILayoutDisplayObject && !ILayoutDisplayObject(_loc21_).includeInLayout))
                  {
                     _loc17_ = _loc21_.width;
                     _loc8_ = _loc21_.height;
                     if(_loc17_ > _loc27_)
                     {
                        _loc27_ = _loc17_;
                     }
                     if(_loc8_ > _loc43_)
                     {
                        _loc43_ = _loc8_;
                     }
                  }
               }
               _loc25_++;
            }
         }
         if(_loc27_ < 0)
         {
            _loc27_ = 0;
         }
         if(_loc43_ < 0)
         {
            _loc43_ = 0;
         }
         if(this._useSquareTiles)
         {
            if(_loc27_ > _loc43_)
            {
               _loc43_ = _loc27_;
            }
            else if(_loc43_ > _loc27_)
            {
               _loc27_ = _loc43_;
            }
         }
         var _loc36_:int = this.calculateHorizontalTileCount(_loc27_,_loc31_,_loc19_,this._paddingLeft + this._paddingRight,this._horizontalGap,this._requestedColumnCount,_loc29_);
         if(_loc31_ === _loc31_)
         {
            _loc23_ = _loc31_;
         }
         else if((_loc23_ = Number(this._paddingLeft + this._paddingRight + (_loc27_ + this._horizontalGap) * _loc36_ - this._horizontalGap)) < _loc26_)
         {
            _loc23_ = _loc26_;
         }
         else if(_loc23_ > _loc19_)
         {
            _loc23_ = _loc19_;
         }
         if(this._distributeWidths)
         {
            _loc27_ = Number((_loc23_ - this._paddingLeft - this._paddingRight - _loc36_ * this._horizontalGap + this._horizontalGap) / _loc36_);
            if(this._useSquareTiles)
            {
               _loc43_ = _loc27_;
            }
         }
         var _loc40_:int = this.calculateVerticalTileCount(_loc43_,_loc38_,_loc14_,this._paddingTop + this._paddingBottom,this._verticalGap,this._requestedRowCount,_loc29_,_loc36_,this._distributeHeights && !this._useSquareTiles);
         if(_loc38_ === _loc38_)
         {
            _loc6_ = _loc38_;
         }
         else if((_loc6_ = Number(this._paddingTop + this._paddingBottom + (_loc43_ + this._verticalGap) * _loc40_ - this._verticalGap)) < _loc11_)
         {
            _loc6_ = _loc11_;
         }
         else if(_loc6_ > _loc14_)
         {
            _loc6_ = _loc14_;
         }
         if(this._distributeHeights && !this._useSquareTiles)
         {
            _loc43_ = Number((_loc6_ - this._paddingTop - this._paddingBottom - _loc40_ * this._verticalGap + this._verticalGap) / _loc40_);
         }
         var _loc12_:Number = _loc36_ * (_loc27_ + this._horizontalGap) - this._horizontalGap + this._paddingLeft + this._paddingRight;
         var _loc5_:Number = _loc40_ * (_loc43_ + this._verticalGap) - this._verticalGap + this._paddingTop + this._paddingBottom;
         var _loc41_:Number = _loc32_ + this._paddingLeft;
         var _loc39_:Number = _loc34_ + this._paddingTop;
         var _loc33_:int = _loc36_ * _loc40_;
         var _loc35_:int = 0;
         var _loc30_:* = _loc33_;
         var _loc15_:* = _loc41_;
         var _loc10_:* = _loc41_;
         var _loc13_:* = _loc39_;
         var _loc16_:int = 0;
         var _loc20_:int = 0;
         _loc25_ = 0;
         while(_loc25_ < _loc29_)
         {
            if(!((_loc21_ = param1[_loc25_]) is ILayoutDisplayObject && !ILayoutDisplayObject(_loc21_).includeInLayout))
            {
               if(_loc16_ != 0 && _loc16_ % _loc36_ == 0)
               {
                  _loc10_ = _loc15_;
                  _loc13_ += _loc43_ + this._verticalGap;
               }
               if(_loc16_ == _loc30_)
               {
                  if(this._paging !== "none")
                  {
                     _loc22_ = !!this._useVirtualLayout ? this._discoveredItemsCache : param1;
                     _loc7_ = !!this._useVirtualLayout ? 0 : Number(_loc16_ - _loc33_);
                     _loc9_ = !!this._useVirtualLayout ? this._discoveredItemsCache.length - 1 : Number(_loc16_ - 1);
                     this.applyHorizontalAlign(_loc22_,_loc7_,_loc9_,_loc12_,_loc23_);
                     this.applyVerticalAlign(_loc22_,_loc7_,_loc9_,_loc5_,_loc6_);
                     this._discoveredItemsCache.length = 0;
                     _loc20_ = 0;
                  }
                  _loc35_++;
                  _loc30_ += _loc33_;
                  if(this._paging === "horizontal")
                  {
                     _loc10_ = Number(_loc15_ = Number(_loc41_ + _loc23_ * _loc35_));
                     _loc13_ = _loc39_;
                  }
                  else if(this._paging === "vertical")
                  {
                     _loc13_ = Number(_loc39_ + _loc6_ * _loc35_);
                  }
               }
               if(_loc21_)
               {
                  switch(this._tileHorizontalAlign)
                  {
                     case "justify":
                        _loc21_.x = _loc21_.pivotX + _loc10_;
                        _loc21_.width = _loc27_;
                        break;
                     case "left":
                        _loc21_.x = _loc21_.pivotX + _loc10_;
                        break;
                     case "right":
                        _loc21_.x = _loc21_.pivotX + _loc10_ + _loc27_ - _loc21_.width;
                        break;
                     default:
                        _loc21_.x = _loc21_.pivotX + _loc10_ + Math.round((_loc27_ - _loc21_.width) / 2);
                  }
                  switch(this._tileVerticalAlign)
                  {
                     case "justify":
                        _loc21_.y = _loc21_.pivotY + _loc13_;
                        _loc21_.height = _loc43_;
                        break;
                     case "top":
                        _loc21_.y = _loc21_.pivotY + _loc13_;
                        break;
                     case "bottom":
                        _loc21_.y = _loc21_.pivotY + _loc13_ + _loc43_ - _loc21_.height;
                        break;
                     default:
                        _loc21_.y = _loc21_.pivotY + _loc13_ + Math.round((_loc43_ - _loc21_.height) / 2);
                  }
                  if(this._useVirtualLayout)
                  {
                     this._discoveredItemsCache[_loc20_] = _loc21_;
                     _loc20_++;
                  }
               }
               _loc10_ += _loc27_ + this._horizontalGap;
               _loc16_++;
            }
            _loc25_++;
         }
         if(this._paging !== "none")
         {
            _loc22_ = !!this._useVirtualLayout ? this._discoveredItemsCache : param1;
            _loc7_ = !!this._useVirtualLayout ? 0 : Number(_loc30_ - _loc33_);
            _loc9_ = !!this._useVirtualLayout ? _loc22_.length - 1 : Number(_loc25_ - 1);
            this.applyHorizontalAlign(_loc22_,_loc7_,_loc9_,_loc12_,_loc23_);
            this.applyVerticalAlign(_loc22_,_loc7_,_loc9_,_loc5_,_loc6_);
         }
         if(this._paging === "horizontal")
         {
            _loc18_ = Number(Math.ceil(_loc29_ / _loc33_) * _loc23_);
         }
         else
         {
            _loc18_ = _loc12_;
         }
         if(this._paging === "horizontal")
         {
            _loc4_ = _loc6_;
         }
         else if(this._paging === "vertical")
         {
            _loc4_ = Number(Math.ceil(_loc29_ / _loc33_) * _loc6_);
         }
         else if((_loc4_ = Number(_loc13_ + _loc43_ + this._paddingBottom)) < _loc5_)
         {
            _loc4_ = _loc5_;
         }
         if(this._paging === "none")
         {
            _loc9_ = (_loc22_ = !!this._useVirtualLayout ? this._discoveredItemsCache : param1).length - 1;
            this.applyHorizontalAlign(_loc22_,0,_loc9_,_loc18_,_loc23_);
            this.applyVerticalAlign(_loc22_,0,_loc9_,_loc4_,_loc6_);
         }
         this._discoveredItemsCache.length = 0;
         param3.contentX = 0;
         param3.contentY = 0;
         param3.contentWidth = _loc18_;
         param3.contentHeight = _loc4_;
         param3.viewPortWidth = _loc23_;
         param3.viewPortHeight = _loc6_;
         return param3;
      }
      
      public function measureViewPort(param1:int, param2:ViewPortBounds = null, param3:Point = null) : Point
      {
         var _loc16_:* = NaN;
         var _loc6_:* = NaN;
         var _loc19_:int = 0;
         var _loc14_:* = NaN;
         var _loc4_:* = NaN;
         var _loc25_:* = NaN;
         var _loc31_:* = NaN;
         if(!param3)
         {
            param3 = new Point();
         }
         if(!this._useVirtualLayout)
         {
            throw new IllegalOperationError("measureViewPort() may be called only if useVirtualLayout is true.");
         }
         var _loc24_:Number = !!param2 ? param2.explicitWidth : NaN;
         var _loc32_:Number = !!param2 ? param2.explicitHeight : NaN;
         var _loc17_:* = _loc24_ !== _loc24_;
         var _loc13_:* = _loc32_ !== _loc32_;
         if(!_loc17_ && !_loc13_)
         {
            param3.x = _loc24_;
            param3.y = _loc32_;
            return param3;
         }
         var _loc26_:Number = !!param2 ? param2.x : 0;
         var _loc28_:Number = !!param2 ? param2.y : 0;
         var _loc20_:Number = !!param2 ? param2.minWidth : 0;
         var _loc8_:Number = !!param2 ? param2.minHeight : 0;
         var _loc15_:Number = !!param2 ? param2.maxWidth : Infinity;
         var _loc11_:Number = !!param2 ? param2.maxHeight : Infinity;
         this.prepareTypicalItem();
         var _loc22_:Number = !!this._typicalItem ? this._typicalItem.width : 0;
         var _loc18_:Number = !!this._typicalItem ? this._typicalItem.height : 0;
         var _loc21_:* = _loc22_;
         var _loc36_:* = _loc18_;
         if(_loc21_ < 0)
         {
            _loc21_ = 0;
         }
         if(_loc36_ < 0)
         {
            _loc36_ = 0;
         }
         if(this._useSquareTiles)
         {
            if(_loc21_ > _loc36_)
            {
               _loc36_ = _loc21_;
            }
            else if(_loc36_ > _loc21_)
            {
               _loc21_ = _loc36_;
            }
         }
         var _loc30_:int = this.calculateHorizontalTileCount(_loc21_,_loc24_,_loc15_,this._paddingLeft + this._paddingRight,this._horizontalGap,this._requestedColumnCount,param1);
         var _loc34_:int = this.calculateVerticalTileCount(_loc36_,_loc32_,_loc11_,this._paddingTop + this._paddingBottom,this._verticalGap,this._requestedRowCount,param1,_loc30_,this._distributeHeights && !this._useSquareTiles);
         if(_loc24_ === _loc24_)
         {
            _loc16_ = _loc24_;
         }
         else if((_loc16_ = Number(this._paddingLeft + this._paddingRight + (_loc21_ + this._horizontalGap) * _loc30_ - this._horizontalGap)) < _loc20_)
         {
            _loc16_ = _loc20_;
         }
         else if(_loc16_ > _loc15_)
         {
            _loc16_ = _loc15_;
         }
         if(_loc32_ === _loc32_)
         {
            _loc6_ = _loc32_;
         }
         else if((_loc6_ = Number(this._paddingTop + this._paddingBottom + (_loc36_ + this._verticalGap) * _loc34_ - this._verticalGap)) < _loc8_)
         {
            _loc6_ = _loc8_;
         }
         else if(_loc6_ > _loc11_)
         {
            _loc6_ = _loc11_;
         }
         var _loc9_:Number = _loc30_ * (_loc21_ + this._horizontalGap) - this._horizontalGap + this._paddingLeft + this._paddingRight;
         var _loc5_:Number = _loc34_ * (_loc36_ + this._verticalGap) - this._verticalGap + this._paddingTop + this._paddingBottom;
         var _loc35_:Number = _loc26_ + this._paddingLeft;
         var _loc33_:Number = _loc28_ + this._paddingTop;
         var _loc27_:int = _loc30_ * _loc34_;
         var _loc29_:int = 0;
         var _loc23_:* = _loc27_;
         var _loc12_:* = _loc35_;
         var _loc7_:* = _loc35_;
         var _loc10_:* = _loc33_;
         _loc19_ = 0;
         while(_loc19_ < param1)
         {
            if(_loc19_ != 0 && _loc19_ % _loc30_ == 0)
            {
               _loc7_ = _loc12_;
               _loc10_ += _loc36_ + this._verticalGap;
            }
            if(_loc19_ == _loc23_)
            {
               _loc29_++;
               _loc23_ += _loc27_;
               if(this._paging === "horizontal")
               {
                  _loc7_ = Number(_loc12_ = Number(_loc35_ + _loc16_ * _loc29_));
                  _loc10_ = _loc33_;
               }
               else if(this._paging === "vertical")
               {
                  _loc10_ = Number(_loc33_ + _loc6_ * _loc29_);
               }
            }
            _loc19_++;
         }
         if(this._paging === "horizontal")
         {
            _loc14_ = Number(Math.ceil(param1 / _loc27_) * _loc16_);
         }
         else
         {
            _loc14_ = _loc9_;
         }
         if(this._paging === "horizontal")
         {
            _loc4_ = _loc6_;
         }
         else if(this._paging === "vertical")
         {
            _loc4_ = Number(Math.ceil(param1 / _loc27_) * _loc6_);
         }
         else if((_loc4_ = Number(_loc10_ + _loc36_ + this._paddingBottom)) < _loc5_)
         {
            _loc4_ = _loc5_;
         }
         if(_loc17_)
         {
            if((_loc25_ = _loc14_) < _loc20_)
            {
               _loc25_ = _loc20_;
            }
            else if(_loc25_ > _loc15_)
            {
               _loc25_ = _loc15_;
            }
            param3.x = _loc25_;
         }
         else
         {
            param3.x = _loc24_;
         }
         if(_loc13_)
         {
            if((_loc31_ = _loc4_) < _loc8_)
            {
               _loc31_ = _loc8_;
            }
            else if(_loc31_ > _loc11_)
            {
               _loc31_ = _loc11_;
            }
            param3.y = _loc31_;
         }
         else
         {
            param3.y = _loc32_;
         }
         return param3;
      }
      
      public function getVisibleIndicesAtScrollPosition(param1:Number, param2:Number, param3:Number, param4:Number, param5:int, param6:Vector.<int> = null) : Vector.<int>
      {
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
         if(this._paging === "horizontal")
         {
            this.getVisibleIndicesAtScrollPositionWithHorizontalPaging(param1,param2,param3,param4,param5,param6);
         }
         else if(this._paging === "vertical")
         {
            this.getVisibleIndicesAtScrollPositionWithVerticalPaging(param1,param2,param3,param4,param5,param6);
         }
         else
         {
            this.getVisibleIndicesAtScrollPositionWithoutPaging(param1,param2,param3,param4,param5,param6);
         }
         return param6;
      }
      
      public function getNearestScrollPositionForIndex(param1:int, param2:Number, param3:Number, param4:Vector.<DisplayObject>, param5:Number, param6:Number, param7:Number, param8:Number, param9:Point = null) : Point
      {
         return this.calculateScrollPositionForIndex(param1,param4,param5,param6,param7,param8,param9,true,param2,param3);
      }
      
      public function getScrollPositionForIndex(param1:int, param2:Vector.<DisplayObject>, param3:Number, param4:Number, param5:Number, param6:Number, param7:Point = null) : Point
      {
         return this.calculateScrollPositionForIndex(param1,param2,param3,param4,param5,param6,param7,false);
      }
      
      protected function applyHorizontalAlign(param1:Vector.<DisplayObject>, param2:int, param3:int, param4:Number, param5:Number) : void
      {
         var _loc8_:* = 0;
         var _loc6_:* = null;
         if(param4 >= param5)
         {
            return;
         }
         var _loc7_:* = 0;
         if(this._horizontalAlign === "right")
         {
            _loc7_ = Number(param5 - param4);
         }
         else if(this._horizontalAlign !== "left")
         {
            _loc7_ = Number(Math.round((param5 - param4) / 2));
         }
         if(_loc7_ !== 0)
         {
            _loc8_ = param2;
            while(_loc8_ <= param3)
            {
               if(!((_loc6_ = param1[_loc8_]) is ILayoutDisplayObject && !ILayoutDisplayObject(_loc6_).includeInLayout))
               {
                  _loc6_.x += _loc7_;
               }
               _loc8_++;
            }
         }
      }
      
      protected function applyVerticalAlign(param1:Vector.<DisplayObject>, param2:int, param3:int, param4:Number, param5:Number) : void
      {
         var _loc7_:* = 0;
         var _loc6_:* = null;
         if(param4 >= param5)
         {
            return;
         }
         var _loc8_:* = 0;
         if(this._verticalAlign === "bottom")
         {
            _loc8_ = Number(param5 - param4);
         }
         else if(this._verticalAlign === "middle")
         {
            _loc8_ = Number(Math.round((param5 - param4) / 2));
         }
         if(_loc8_ !== 0)
         {
            _loc7_ = param2;
            while(_loc7_ <= param3)
            {
               if(!((_loc6_ = param1[_loc7_]) is ILayoutDisplayObject && !ILayoutDisplayObject(_loc6_).includeInLayout))
               {
                  _loc6_.y += _loc8_;
               }
               _loc7_++;
            }
         }
      }
      
      protected function getVisibleIndicesAtScrollPositionWithHorizontalPaging(param1:Number, param2:Number, param3:Number, param4:Number, param5:int, param6:Vector.<int>) : void
      {
         var _loc10_:int = 0;
         var _loc17_:* = 0;
         var _loc22_:int = 0;
         var _loc14_:int = 0;
         var _loc13_:int = 0;
         var _loc24_:int = 0;
         this.prepareTypicalItem();
         var _loc19_:Number = !!this._typicalItem ? this._typicalItem.width : 0;
         var _loc16_:Number = !!this._typicalItem ? this._typicalItem.height : 0;
         var _loc18_:* = _loc19_;
         var _loc26_:* = _loc16_;
         if(_loc18_ < 0)
         {
            _loc18_ = 0;
         }
         if(_loc26_ < 0)
         {
            _loc26_ = 0;
         }
         if(this._useSquareTiles)
         {
            if(_loc18_ > _loc26_)
            {
               _loc26_ = _loc18_;
            }
            else if(_loc26_ > _loc18_)
            {
               _loc18_ = _loc26_;
            }
         }
         var _loc21_:int = this.calculateHorizontalTileCount(_loc18_,param3,param3,this._paddingLeft + this._paddingRight,this._horizontalGap,this._requestedColumnCount,param5);
         if(this._distributeWidths)
         {
            _loc18_ = Number((param3 - this._paddingLeft - this._paddingRight - _loc21_ * this._horizontalGap + this._horizontalGap) / _loc21_);
            if(this._useSquareTiles)
            {
               _loc26_ = _loc18_;
            }
         }
         var _loc23_:int = this.calculateVerticalTileCount(_loc26_,param4,param4,this._paddingTop + this._paddingBottom,this._verticalGap,this._requestedRowCount,param5,_loc21_,this._distributeHeights && !this._useSquareTiles);
         if(this._distributeHeights && !this._useSquareTiles)
         {
            _loc26_ = Number((param4 - this._paddingTop - this._paddingBottom - _loc23_ * this._verticalGap + this._verticalGap) / _loc23_);
         }
         var _loc11_:*;
         var _loc20_:int;
         if((_loc11_ = int((_loc20_ = _loc21_ * _loc23_) + 2 * _loc23_)) > param5)
         {
            _loc11_ = param5;
         }
         var _loc12_:int;
         var _loc25_:int = (_loc12_ = Math.round(param1 / param3)) * _loc20_;
         var _loc9_:Number = _loc21_ * (_loc18_ + this._horizontalGap) - this._horizontalGap;
         var _loc8_:* = 0;
         var _loc27_:* = 0;
         if(_loc9_ < param3)
         {
            if(this._horizontalAlign === "right")
            {
               _loc8_ = Number(param3 - this._paddingLeft - this._paddingRight - _loc9_);
               _loc27_ = 0;
            }
            else if(this._horizontalAlign === "center")
            {
               _loc8_ = Number(_loc27_ = Number(Math.round((param3 - this._paddingLeft - this._paddingRight - _loc9_) / 2)));
            }
            else
            {
               _loc8_ = 0;
               _loc27_ = Number(param3 - this._paddingLeft - this._paddingRight - _loc9_);
            }
         }
         var _loc7_:int = 0;
         var _loc28_:Number = _loc12_ * param3;
         var _loc15_:*;
         if((_loc15_ = Number(param1 - _loc28_)) < 0)
         {
            if((_loc15_ = Number(-_loc15_ - this._paddingRight - _loc27_)) < 0)
            {
               _loc15_ = 0;
            }
            _loc7_ = -Math.floor(_loc15_ / (_loc18_ + this._horizontalGap)) - 1;
            _loc25_ += -_loc20_ + _loc21_ + _loc7_;
         }
         else if(_loc15_ > 0)
         {
            if((_loc15_ = Number(_loc15_ - this._paddingLeft - _loc8_)) < 0)
            {
               _loc15_ = 0;
            }
            _loc7_ = Math.floor(_loc15_ / (_loc18_ + this._horizontalGap));
            _loc25_ += _loc7_;
         }
         if(_loc25_ < 0)
         {
            _loc25_ = 0;
            _loc7_ = 0;
         }
         if(_loc25_ + _loc11_ >= param5)
         {
            _loc10_ = param6.length;
            _loc17_ = _loc25_ = param5 - _loc11_;
            while(_loc17_ < param5)
            {
               param6[_loc10_] = _loc17_;
               _loc10_++;
               _loc17_++;
            }
         }
         else
         {
            _loc22_ = 0;
            _loc14_ = (_loc21_ + _loc7_) % _loc21_;
            _loc13_ = int(_loc25_ / _loc20_) * _loc20_;
            _loc17_ = _loc25_;
            _loc24_ = 0;
            do
            {
               if(_loc17_ < param5)
               {
                  param6[_loc24_] = _loc17_;
                  _loc24_++;
               }
               _loc22_++;
               if(_loc22_ === _loc23_)
               {
                  _loc22_ = 0;
                  _loc14_++;
                  if(_loc14_ === _loc21_)
                  {
                     _loc14_ = 0;
                     _loc13_ += _loc20_;
                  }
                  _loc17_ = int(_loc13_ + _loc14_ - _loc21_);
               }
               _loc17_ += _loc21_;
            }
            while(_loc24_ < _loc11_ && _loc13_ < param5);
            
         }
      }
      
      protected function getVisibleIndicesAtScrollPositionWithVerticalPaging(param1:Number, param2:Number, param3:Number, param4:Number, param5:int, param6:Vector.<int>) : void
      {
         var _loc15_:* = 0;
         this.prepareTypicalItem();
         var _loc17_:Number = !!this._typicalItem ? this._typicalItem.width : 0;
         var _loc14_:Number = !!this._typicalItem ? this._typicalItem.height : 0;
         var _loc16_:* = _loc17_;
         var _loc24_:* = _loc14_;
         if(_loc16_ < 0)
         {
            _loc16_ = 0;
         }
         if(_loc24_ < 0)
         {
            _loc24_ = 0;
         }
         if(this._useSquareTiles)
         {
            if(_loc16_ > _loc24_)
            {
               _loc24_ = _loc16_;
            }
            else if(_loc24_ > _loc16_)
            {
               _loc16_ = _loc24_;
            }
         }
         var _loc20_:int = this.calculateHorizontalTileCount(_loc16_,param3,param3,this._paddingLeft + this._paddingRight,this._horizontalGap,this._requestedColumnCount,param5);
         if(this._distributeWidths)
         {
            _loc16_ = Number((param3 - this._paddingLeft - this._paddingRight - _loc20_ * this._horizontalGap + this._horizontalGap) / _loc20_);
            if(this._useSquareTiles)
            {
               _loc24_ = _loc16_;
            }
         }
         var _loc22_:int = this.calculateVerticalTileCount(_loc24_,param4,param4,this._paddingTop + this._paddingBottom,this._verticalGap,this._requestedRowCount,param5,_loc20_,this._distributeHeights && !this._useSquareTiles);
         if(this._distributeHeights && !this._useSquareTiles)
         {
            _loc24_ = Number((param4 - this._paddingTop - this._paddingBottom - _loc22_ * this._verticalGap + this._verticalGap) / _loc22_);
         }
         var _loc11_:*;
         var _loc19_:int;
         if((_loc11_ = int((_loc19_ = _loc20_ * _loc22_) + 2 * _loc20_)) > param5)
         {
            _loc11_ = param5;
         }
         var _loc12_:int;
         var _loc23_:int = (_loc12_ = Math.round(param2 / param4)) * _loc19_;
         var _loc8_:Number = _loc22_ * (_loc24_ + this._verticalGap) - this._verticalGap;
         var _loc7_:* = 0;
         var _loc9_:* = 0;
         if(_loc8_ < param4)
         {
            if(this._verticalAlign === "bottom")
            {
               _loc7_ = Number(param4 - this._paddingTop - this._paddingBottom - _loc8_);
               _loc9_ = 0;
            }
            else if(this._verticalAlign === "middle")
            {
               _loc7_ = Number(_loc9_ = Number(Math.round((param4 - this._paddingTop - this._paddingBottom - _loc8_) / 2)));
            }
            else
            {
               _loc7_ = 0;
               _loc9_ = Number(param4 - this._paddingTop - this._paddingBottom - _loc8_);
            }
         }
         var _loc18_:int = 0;
         var _loc25_:Number = _loc12_ * param4;
         var _loc13_:*;
         if((_loc13_ = Number(param2 - _loc25_)) < 0)
         {
            if((_loc13_ = Number(-_loc13_ - this._paddingBottom - _loc9_)) < 0)
            {
               _loc13_ = 0;
            }
            _loc18_ = -Math.floor(_loc13_ / (_loc24_ + this._verticalGap)) - 1;
            _loc23_ += _loc20_ * _loc18_;
         }
         else if(_loc13_ > 0)
         {
            if((_loc13_ = Number(_loc13_ - this._paddingTop - _loc7_)) < 0)
            {
               _loc13_ = 0;
            }
            _loc18_ = Math.floor(_loc13_ / (_loc24_ + this._verticalGap));
            _loc23_ += _loc20_ * _loc18_;
         }
         if(_loc23_ < 0)
         {
            _loc23_ = 0;
            _loc18_ = 0;
         }
         var _loc21_:*;
         if((_loc21_ = int(_loc23_ + _loc11_)) > param5)
         {
            _loc21_ = param5;
         }
         _loc23_ = _loc21_ - _loc11_;
         var _loc10_:int = param6.length;
         _loc15_ = _loc23_;
         while(_loc15_ < _loc21_)
         {
            param6[_loc10_] = _loc15_;
            _loc10_++;
            _loc15_++;
         }
      }
      
      protected function getVisibleIndicesAtScrollPositionWithoutPaging(param1:Number, param2:Number, param3:Number, param4:Number, param5:int, param6:Vector.<int>) : void
      {
         var _loc17_:int = 0;
         var _loc8_:* = 0;
         this.prepareTypicalItem();
         var _loc11_:Number = !!this._typicalItem ? this._typicalItem.width : 0;
         var _loc7_:Number = !!this._typicalItem ? this._typicalItem.height : 0;
         var _loc9_:* = _loc11_;
         var _loc19_:* = _loc7_;
         if(_loc9_ < 0)
         {
            _loc9_ = 0;
         }
         if(_loc19_ < 0)
         {
            _loc19_ = 0;
         }
         if(this._useSquareTiles)
         {
            if(_loc9_ > _loc19_)
            {
               _loc19_ = _loc9_;
            }
            else if(_loc19_ > _loc9_)
            {
               _loc9_ = _loc19_;
            }
         }
         var _loc14_:int = this.calculateHorizontalTileCount(_loc9_,param3,param3,this._paddingLeft + this._paddingRight,this._horizontalGap,this._requestedColumnCount,param5);
         if(this._distributeWidths)
         {
            _loc9_ = Number((param3 - this._paddingLeft - this._paddingRight - _loc14_ * this._horizontalGap + this._horizontalGap) / _loc14_);
            if(this._useSquareTiles)
            {
               _loc19_ = _loc9_;
            }
         }
         if(this._distributeHeights && !this._useSquareTiles)
         {
            _loc17_ = this.calculateVerticalTileCount(_loc19_,param4,param4,this._paddingTop + this._paddingBottom,this._verticalGap,this._requestedRowCount,param5,_loc14_,this._distributeHeights && !this._useSquareTiles);
            _loc19_ = Number((param4 - this._paddingTop - this._paddingBottom - _loc17_ * this._verticalGap + this._verticalGap) / _loc17_);
         }
         var _loc13_:*;
         if((_loc13_ = int((_loc17_ = Math.ceil((param4 + this._verticalGap) / (_loc19_ + this._verticalGap)) + 1) * _loc14_)) > param5)
         {
            _loc13_ = param5;
         }
         var _loc10_:int = 0;
         var _loc20_:Number;
         if((_loc20_ = Math.ceil(param5 / _loc14_) * (_loc19_ + this._verticalGap) - this._verticalGap) < param4)
         {
            if(this._verticalAlign === "bottom")
            {
               _loc10_ = Math.ceil((param4 - _loc20_) / (_loc19_ + this._verticalGap));
            }
            else if(this._verticalAlign === "middle")
            {
               _loc10_ = Math.ceil((param4 - _loc20_) / (_loc19_ + this._verticalGap) / 2);
            }
         }
         var _loc18_:int;
         var _loc16_:int;
         if((_loc18_ = (_loc16_ = -_loc10_ + Math.floor((param2 - this._paddingTop + this._verticalGap) / (_loc19_ + this._verticalGap))) * _loc14_) < 0)
         {
            _loc18_ = 0;
         }
         var _loc15_:*;
         if((_loc15_ = int(_loc18_ + _loc13_)) > param5)
         {
            _loc15_ = param5;
         }
         _loc18_ = _loc15_ - _loc13_;
         var _loc12_:int = param6.length;
         _loc8_ = _loc18_;
         while(_loc8_ < _loc15_)
         {
            param6[_loc12_] = _loc8_;
            _loc12_++;
            _loc8_++;
         }
      }
      
      protected function validateItems(param1:Vector.<DisplayObject>) : void
      {
         var _loc3_:int = 0;
         var _loc2_:* = null;
         var _loc4_:int = param1.length;
         _loc3_ = 0;
         while(_loc3_ < _loc4_)
         {
            _loc2_ = param1[_loc3_];
            if(!(_loc2_ is ILayoutDisplayObject && !ILayoutDisplayObject(_loc2_).includeInLayout))
            {
               if(_loc2_ is IValidating)
               {
                  IValidating(_loc2_).validate();
               }
            }
            _loc3_++;
         }
      }
      
      protected function prepareTypicalItem() : void
      {
         if(!this._typicalItem)
         {
            return;
         }
         if(this._resetTypicalItemDimensionsOnMeasure)
         {
            this._typicalItem.width = this._typicalItemWidth;
            this._typicalItem.height = this._typicalItemHeight;
         }
         if(this._typicalItem is IValidating)
         {
            IValidating(this._typicalItem).validate();
         }
      }
      
      public function calculateScrollPositionForIndex(param1:int, param2:Vector.<DisplayObject>, param3:Number, param4:Number, param5:Number, param6:Number, param7:Point = null, param8:Boolean = false, param9:Number = 0, param10:Number = 0) : Point
      {
         var _loc19_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:int = 0;
         var _loc15_:* = null;
         var _loc13_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc26_:int = 0;
         var _loc21_:Number = NaN;
         var _loc22_:int = 0;
         var _loc24_:* = NaN;
         var _loc12_:Number = NaN;
         var _loc25_:Number = NaN;
         var _loc14_:Number = NaN;
         if(!param7)
         {
            param7 = new Point();
         }
         if(this._useVirtualLayout)
         {
            this.prepareTypicalItem();
            _loc19_ = !!this._typicalItem ? this._typicalItem.width : 0;
            _loc16_ = !!this._typicalItem ? this._typicalItem.height : 0;
         }
         var _loc20_:int = param2.length;
         var _loc18_:* = Number(!!this._useVirtualLayout ? _loc19_ : 0);
         var _loc27_:* = Number(!!this._useVirtualLayout ? _loc16_ : 0);
         if(!this._useVirtualLayout)
         {
            _loc17_ = 0;
            while(_loc17_ < _loc20_)
            {
               if(_loc15_ = param2[_loc17_])
               {
                  if(!(_loc15_ is ILayoutDisplayObject && !ILayoutDisplayObject(_loc15_).includeInLayout))
                  {
                     _loc13_ = _loc15_.width;
                     _loc11_ = _loc15_.height;
                     if(_loc13_ > _loc18_)
                     {
                        _loc18_ = _loc13_;
                     }
                     if(_loc11_ > _loc27_)
                     {
                        _loc27_ = _loc11_;
                     }
                  }
               }
               _loc17_++;
            }
         }
         if(_loc18_ < 0)
         {
            _loc18_ = 0;
         }
         if(_loc27_ < 0)
         {
            _loc27_ = 0;
         }
         if(this._useSquareTiles)
         {
            if(_loc18_ > _loc27_)
            {
               _loc27_ = _loc18_;
            }
            else if(_loc27_ > _loc18_)
            {
               _loc18_ = _loc27_;
            }
         }
         var _loc23_:int;
         if((_loc23_ = (param5 - this._paddingLeft - this._paddingRight + this._horizontalGap) / (_loc18_ + this._horizontalGap)) < 1)
         {
            _loc23_ = 1;
         }
         else if(this._requestedColumnCount > 0 && _loc23_ > this._requestedColumnCount)
         {
            _loc23_ = this._requestedColumnCount;
         }
         if(this._paging !== "none")
         {
            if((_loc26_ = (param6 - this._paddingTop - this._paddingBottom + this._verticalGap) / (_loc27_ + this._verticalGap)) < 1)
            {
               _loc26_ = 1;
            }
            _loc21_ = _loc23_ * _loc26_;
            _loc22_ = param1 / _loc21_;
            if(this._paging === "horizontal")
            {
               param7.x = _loc22_ * param5;
               param7.y = 0;
            }
            else
            {
               param7.x = 0;
               param7.y = _loc22_ * param6;
            }
         }
         else
         {
            _loc24_ = Number(this._paddingTop + (_loc27_ + this._verticalGap) * (int(param1 / _loc23_)));
            if(param8)
            {
               _loc12_ = _loc24_ - (param6 - _loc27_);
               if(param10 >= _loc12_ && param10 <= _loc24_)
               {
                  _loc24_ = param10;
               }
               else
               {
                  _loc25_ = Math.abs(_loc24_ - param10);
                  if((_loc14_ = Math.abs(_loc12_ - param10)) < _loc25_)
                  {
                     _loc24_ = _loc12_;
                  }
               }
            }
            else
            {
               _loc24_ -= Math.round((param6 - _loc27_) / 2);
            }
            param7.x = 0;
            param7.y = _loc24_;
         }
         return param7;
      }
      
      protected function calculateHorizontalTileCount(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:int, param7:int) : int
      {
         var _loc9_:* = 0;
         if(param6 > 0 && this._distributeWidths)
         {
            return param6;
         }
         if(param2 === param2)
         {
            _loc9_ = int((param2 - param4 + param5) / (param1 + param5));
            if(param6 > 0 && _loc9_ > param6)
            {
               return param6;
            }
            if(_loc9_ > param7)
            {
               _loc9_ = param7;
            }
            if(_loc9_ < 1)
            {
               _loc9_ = 1;
            }
            return _loc9_;
         }
         if(param6 > 0)
         {
            _loc9_ = param6;
         }
         else
         {
            _loc9_ = param7;
         }
         var _loc8_:int = 2147483647;
         if(param3 === param3 && param3 < Infinity)
         {
            if((_loc8_ = (param3 - param4 + param5) / (param1 + param5)) < 1)
            {
               _loc8_ = 1;
            }
         }
         if(_loc9_ > _loc8_)
         {
            _loc9_ = _loc8_;
         }
         if(_loc9_ < 1)
         {
            _loc9_ = 1;
         }
         return _loc9_;
      }
      
      protected function calculateVerticalTileCount(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:int, param7:int, param8:int, param9:Boolean) : int
      {
         var _loc12_:* = 0;
         var _loc11_:int = Math.ceil(param7 / param8);
         if(param9)
         {
            if(param6 > 0 && _loc11_ > param6)
            {
               return param6;
            }
            return _loc11_;
         }
         if(param2 === param2)
         {
            _loc12_ = int((param2 - param4 + param5) / (param1 + param5));
            if(param6 > 0 && _loc12_ > param6)
            {
               return param6;
            }
            if(_loc12_ > _loc11_)
            {
               _loc12_ = _loc11_;
            }
            if(_loc12_ < 1)
            {
               _loc12_ = 1;
            }
            return _loc12_;
         }
         if(param6 > 0)
         {
            _loc12_ = param6;
         }
         else
         {
            _loc12_ = _loc11_;
         }
         var _loc10_:int = 2147483647;
         if(param3 === param3 && param3 < Infinity)
         {
            if((_loc10_ = (param3 - param4 + param5) / (param1 + param5)) < 1)
            {
               _loc10_ = 1;
            }
         }
         if(_loc12_ > _loc10_)
         {
            _loc12_ = _loc10_;
         }
         if(_loc12_ < 1)
         {
            _loc12_ = 1;
         }
         return _loc12_;
      }
   }
}
