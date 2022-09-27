package feathers.controls
{
   import feathers.core.FeathersControl;
   import feathers.core.IFeathersControl;
   import feathers.core.IMeasureDisplayObject;
   import feathers.core.ITextRenderer;
   import feathers.core.IValidating;
   import feathers.core.PropertyProxy;
   import feathers.layout.HorizontalLayout;
   import feathers.layout.LayoutBoundsResult;
   import feathers.layout.ViewPortBounds;
   import feathers.skins.IStyleProvider;
   import feathers.system.DeviceCapabilities;
   import feathers.text.FontStylesSet;
   import feathers.utils.display.ScreenDensityScaleCalculator;
   import feathers.utils.skins.resetFluidChildDimensionsForMeasurement;
   import flash.display.Stage;
   import flash.events.FullScreenEvent;
   import flash.geom.Point;
   import flash.system.Capabilities;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   import starling.events.Event;
   import starling.text.TextFormat;
   import starling.utils.Pool;
   
   public class Header extends FeathersControl
   {
      
      protected static const INVALIDATION_FLAG_LEFT_CONTENT:String = "leftContent";
      
      protected static const INVALIDATION_FLAG_RIGHT_CONTENT:String = "rightContent";
      
      protected static const INVALIDATION_FLAG_CENTER_CONTENT:String = "centerContent";
      
      protected static const IOS_STATUS_BAR_HEIGHT:Number = 20;
      
      protected static var iOSStatusBarScaledHeight:Number;
      
      protected static const IOS_NAME_PREFIX:String = "iOS ";
      
      protected static const OLD_IOS_NAME_PREFIX:String = "iPhone OS ";
      
      protected static const STATUS_BAR_MIN_IOS_VERSION:int = 7;
      
      public static var globalStyleProvider:IStyleProvider;
      
      public static const TITLE_ALIGN_CENTER:String = "center";
      
      public static const TITLE_ALIGN_PREFER_LEFT:String = "preferLeft";
      
      public static const TITLE_ALIGN_PREFER_RIGHT:String = "preferRight";
      
      public static const VERTICAL_ALIGN_TOP:String = "top";
      
      public static const VERTICAL_ALIGN_MIDDLE:String = "middle";
      
      public static const VERTICAL_ALIGN_BOTTOM:String = "bottom";
      
      public static const DEFAULT_CHILD_STYLE_NAME_ITEM:String = "feathers-header-item";
      
      public static const DEFAULT_CHILD_STYLE_NAME_TITLE:String = "feathers-header-title";
      
      private static const HELPER_BOUNDS:ViewPortBounds = new ViewPortBounds();
      
      private static const HELPER_LAYOUT_RESULT:LayoutBoundsResult = new LayoutBoundsResult();
       
      
      protected var titleTextRenderer:ITextRenderer;
      
      protected var titleStyleName:String = "feathers-header-title";
      
      protected var itemStyleName:String = "feathers-header-item";
      
      protected var leftItemsWidth:Number = 0;
      
      protected var rightItemsWidth:Number = 0;
      
      protected var _layout:HorizontalLayout;
      
      protected var _title:String = null;
      
      protected var _titleFactory:Function;
      
      protected var _disposeItems:Boolean = true;
      
      protected var _ignoreItemResizing:Boolean = false;
      
      protected var _leftItems:Vector.<DisplayObject>;
      
      protected var _centerItems:Vector.<DisplayObject>;
      
      protected var _rightItems:Vector.<DisplayObject>;
      
      protected var _paddingTop:Number = 0;
      
      protected var _paddingRight:Number = 0;
      
      protected var _paddingBottom:Number = 0;
      
      protected var _paddingLeft:Number = 0;
      
      protected var _gap:Number = 0;
      
      protected var _titleGap:Number = NaN;
      
      protected var _useExtraPaddingForOSStatusBar:Boolean = false;
      
      protected var _verticalAlign:String = "middle";
      
      protected var currentBackgroundSkin:DisplayObject;
      
      protected var _explicitBackgroundWidth:Number;
      
      protected var _explicitBackgroundHeight:Number;
      
      protected var _explicitBackgroundMinWidth:Number;
      
      protected var _explicitBackgroundMinHeight:Number;
      
      protected var _explicitBackgroundMaxWidth:Number;
      
      protected var _explicitBackgroundMaxHeight:Number;
      
      protected var _backgroundSkin:DisplayObject;
      
      protected var _backgroundDisabledSkin:DisplayObject;
      
      protected var _fontStylesSet:FontStylesSet;
      
      protected var _wordWrap:Boolean = false;
      
      protected var _customTitleStyleName:String;
      
      protected var _titleProperties:PropertyProxy;
      
      protected var _titleAlign:String = "center";
      
      public function Header()
      {
         super();
         if(this._fontStylesSet === null)
         {
            this._fontStylesSet = new FontStylesSet();
            this._fontStylesSet.addEventListener("change",fontStyles_changeHandler);
         }
         this.addEventListener("addedToStage",header_addedToStageHandler);
         this.addEventListener("removedFromStage",header_removedFromStageHandler);
      }
      
      override protected function get defaultStyleProvider() : IStyleProvider
      {
         return Header.globalStyleProvider;
      }
      
      public function get title() : String
      {
         return this._title;
      }
      
      public function set title(param1:String) : void
      {
         if(this._title === param1)
         {
            return;
         }
         this._title = param1;
         this.invalidate("data");
      }
      
      public function get titleFactory() : Function
      {
         return this._titleFactory;
      }
      
      public function set titleFactory(param1:Function) : void
      {
         if(this._titleFactory == param1)
         {
            return;
         }
         this._titleFactory = param1;
         this.invalidate("textRenderer");
      }
      
      public function get disposeItems() : Boolean
      {
         return this._disposeItems;
      }
      
      public function set disposeItems(param1:Boolean) : void
      {
         this._disposeItems = param1;
      }
      
      public function get leftItems() : Vector.<DisplayObject>
      {
         return this._leftItems;
      }
      
      public function set leftItems(param1:Vector.<DisplayObject>) : void
      {
         if(this._leftItems == param1)
         {
            return;
         }
         if(this._leftItems)
         {
            for each(var _loc2_ in this._leftItems)
            {
               if(_loc2_ is IFeathersControl)
               {
                  IFeathersControl(_loc2_).styleNameList.remove(this.itemStyleName);
                  _loc2_.removeEventListener("resize",item_resizeHandler);
               }
               _loc2_.removeFromParent();
            }
         }
         this._leftItems = param1;
         if(this._leftItems)
         {
            for each(_loc2_ in this._leftItems)
            {
               if(_loc2_ is IFeathersControl)
               {
                  _loc2_.addEventListener("resize",item_resizeHandler);
               }
            }
         }
         this.invalidate("leftContent");
      }
      
      public function get centerItems() : Vector.<DisplayObject>
      {
         return this._centerItems;
      }
      
      public function set centerItems(param1:Vector.<DisplayObject>) : void
      {
         if(this._centerItems == param1)
         {
            return;
         }
         if(this._centerItems)
         {
            for each(var _loc2_ in this._centerItems)
            {
               if(_loc2_ is IFeathersControl)
               {
                  IFeathersControl(_loc2_).styleNameList.remove(this.itemStyleName);
                  _loc2_.removeEventListener("resize",item_resizeHandler);
               }
               _loc2_.removeFromParent();
            }
         }
         this._centerItems = param1;
         if(this._centerItems)
         {
            for each(_loc2_ in this._centerItems)
            {
               if(_loc2_ is IFeathersControl)
               {
                  _loc2_.addEventListener("resize",item_resizeHandler);
               }
            }
         }
         this.invalidate("centerContent");
      }
      
      public function get rightItems() : Vector.<DisplayObject>
      {
         return this._rightItems;
      }
      
      public function set rightItems(param1:Vector.<DisplayObject>) : void
      {
         if(this._rightItems == param1)
         {
            return;
         }
         if(this._rightItems)
         {
            for each(var _loc2_ in this._rightItems)
            {
               if(_loc2_ is IFeathersControl)
               {
                  IFeathersControl(_loc2_).styleNameList.remove(this.itemStyleName);
                  _loc2_.removeEventListener("resize",item_resizeHandler);
               }
               _loc2_.removeFromParent();
            }
         }
         this._rightItems = param1;
         if(this._rightItems)
         {
            for each(_loc2_ in this._rightItems)
            {
               if(_loc2_ is IFeathersControl)
               {
                  _loc2_.addEventListener("resize",item_resizeHandler);
               }
            }
         }
         this.invalidate("rightContent");
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
         if(this.processStyleRestriction(arguments.callee))
         {
            return;
         }
         if(this._paddingTop === param1)
         {
            return;
         }
         this._paddingTop = param1;
         this.invalidate("styles");
      }
      
      public function get paddingRight() : Number
      {
         return this._paddingRight;
      }
      
      public function set paddingRight(param1:Number) : void
      {
         if(this.processStyleRestriction(arguments.callee))
         {
            return;
         }
         if(this._paddingRight === param1)
         {
            return;
         }
         this._paddingRight = param1;
         this.invalidate("styles");
      }
      
      public function get paddingBottom() : Number
      {
         return this._paddingBottom;
      }
      
      public function set paddingBottom(param1:Number) : void
      {
         if(this.processStyleRestriction(arguments.callee))
         {
            return;
         }
         if(this._paddingBottom === param1)
         {
            return;
         }
         this._paddingBottom = param1;
         this.invalidate("styles");
      }
      
      public function get paddingLeft() : Number
      {
         return this._paddingLeft;
      }
      
      public function set paddingLeft(param1:Number) : void
      {
         if(this.processStyleRestriction(arguments.callee))
         {
            return;
         }
         if(this._paddingLeft === param1)
         {
            return;
         }
         this._paddingLeft = param1;
         this.invalidate("styles");
      }
      
      public function get gap() : Number
      {
         return _gap;
      }
      
      public function set gap(param1:Number) : void
      {
         if(this.processStyleRestriction(arguments.callee))
         {
            return;
         }
         if(this._gap === param1)
         {
            return;
         }
         this._gap = param1;
         this.invalidate("styles");
      }
      
      public function get titleGap() : Number
      {
         return _titleGap;
      }
      
      public function set titleGap(param1:Number) : void
      {
         if(this.processStyleRestriction(arguments.callee))
         {
            return;
         }
         if(this._titleGap === param1)
         {
            return;
         }
         this._titleGap = param1;
         this.invalidate("styles");
      }
      
      public function get useExtraPaddingForOSStatusBar() : Boolean
      {
         return this._useExtraPaddingForOSStatusBar;
      }
      
      public function set useExtraPaddingForOSStatusBar(param1:Boolean) : void
      {
         if(this.processStyleRestriction(arguments.callee))
         {
            return;
         }
         if(this._useExtraPaddingForOSStatusBar === param1)
         {
            return;
         }
         this._useExtraPaddingForOSStatusBar = param1;
         this.invalidate("styles");
      }
      
      public function get verticalAlign() : String
      {
         return this._verticalAlign;
      }
      
      public function set verticalAlign(param1:String) : void
      {
         if(this.processStyleRestriction(arguments.callee))
         {
            return;
         }
         if(this._verticalAlign === param1)
         {
            return;
         }
         this._verticalAlign = param1;
         this.invalidate("styles");
      }
      
      public function get backgroundSkin() : DisplayObject
      {
         return this._backgroundSkin;
      }
      
      public function set backgroundSkin(param1:DisplayObject) : void
      {
         if(this.processStyleRestriction(arguments.callee))
         {
            if(param1 !== null)
            {
               param1.dispose();
            }
            return;
         }
         if(this._backgroundSkin === param1)
         {
            return;
         }
         if(this._backgroundSkin !== null && this.currentBackgroundSkin === this._backgroundSkin)
         {
            this.removeCurrentBackgroundSkin(this._backgroundSkin);
            this.currentBackgroundSkin = null;
         }
         this._backgroundSkin = param1;
         this.invalidate("styles");
      }
      
      public function get backgroundDisabledSkin() : DisplayObject
      {
         return this._backgroundDisabledSkin;
      }
      
      public function set backgroundDisabledSkin(param1:DisplayObject) : void
      {
         if(this.processStyleRestriction(arguments.callee))
         {
            if(param1 !== null)
            {
               param1.dispose();
            }
            return;
         }
         if(this._backgroundDisabledSkin === param1)
         {
            return;
         }
         if(this._backgroundDisabledSkin !== null && this.currentBackgroundSkin === this._backgroundDisabledSkin)
         {
            this.removeCurrentBackgroundSkin(this._backgroundDisabledSkin);
            this.currentBackgroundSkin = null;
         }
         this._backgroundDisabledSkin = param1;
         this.invalidate("styles");
      }
      
      public function get fontStyles() : TextFormat
      {
         return this._fontStylesSet.format;
      }
      
      public function set fontStyles(param1:TextFormat) : void
      {
         if(this.processStyleRestriction(arguments.callee))
         {
            return;
         }
         this._fontStylesSet.format = param1;
      }
      
      public function get disabledFontStyles() : TextFormat
      {
         return this._fontStylesSet.disabledFormat;
      }
      
      public function set disabledFontStyles(param1:TextFormat) : void
      {
         if(this.processStyleRestriction(arguments.callee))
         {
            return;
         }
         this._fontStylesSet.disabledFormat = param1;
      }
      
      public function get wordWrap() : Boolean
      {
         return this._wordWrap;
      }
      
      public function set wordWrap(param1:Boolean) : void
      {
         if(this.processStyleRestriction(arguments.callee))
         {
            return;
         }
         if(this._wordWrap === param1)
         {
            return;
         }
         this._wordWrap = param1;
         this.invalidate("styles");
      }
      
      public function get customTitleStyleName() : String
      {
         return this._customTitleStyleName;
      }
      
      public function set customTitleStyleName(param1:String) : void
      {
         if(this.processStyleRestriction(arguments.callee))
         {
            return;
         }
         if(this._customTitleStyleName === param1)
         {
            return;
         }
         this._customTitleStyleName = param1;
         this.invalidate("textRenderer");
      }
      
      public function get titleProperties() : Object
      {
         if(!this._titleProperties)
         {
            this._titleProperties = new PropertyProxy(titleProperties_onChange);
         }
         return this._titleProperties;
      }
      
      public function set titleProperties(param1:Object) : void
      {
         if(this._titleProperties == param1)
         {
            return;
         }
         if(param1 && !(param1 is PropertyProxy))
         {
            param1 = PropertyProxy.fromObject(param1);
         }
         if(this._titleProperties)
         {
            this._titleProperties.removeOnChangeCallback(titleProperties_onChange);
         }
         this._titleProperties = PropertyProxy(param1);
         if(this._titleProperties)
         {
            this._titleProperties.addOnChangeCallback(titleProperties_onChange);
         }
         this.invalidate("styles");
      }
      
      public function get titleAlign() : String
      {
         return this._titleAlign;
      }
      
      public function set titleAlign(param1:String) : void
      {
         if(param1 === "preferLeft")
         {
            param1 = "left";
         }
         else if(param1 === "preferRight")
         {
            param1 = "right";
         }
         if(this.processStyleRestriction(arguments.callee))
         {
            return;
         }
         if(this._titleAlign === param1)
         {
            return;
         }
         this._titleAlign = param1;
         this.invalidate("styles");
      }
      
      public function get numLines() : int
      {
         if(this.titleTextRenderer === null)
         {
            return 0;
         }
         return this.titleTextRenderer.numLines;
      }
      
      override public function dispose() : void
      {
         if(this._backgroundSkin !== null && this._backgroundSkin.parent !== this)
         {
            this._backgroundSkin.dispose();
         }
         if(this._backgroundDisabledSkin !== null && this._backgroundDisabledSkin.parent !== this)
         {
            this._backgroundDisabledSkin.dispose();
         }
         if(this._disposeItems)
         {
            for each(var _loc1_ in this._leftItems)
            {
               _loc1_.dispose();
            }
            for each(_loc1_ in this._centerItems)
            {
               _loc1_.dispose();
            }
            for each(_loc1_ in this._rightItems)
            {
               _loc1_.dispose();
            }
         }
         this.leftItems = null;
         this.rightItems = null;
         this.centerItems = null;
         super.dispose();
      }
      
      override protected function initialize() : void
      {
         var _loc1_:* = null;
         if(this._layout === null)
         {
            _loc1_ = new HorizontalLayout();
            _loc1_.useVirtualLayout = false;
            _loc1_.verticalAlign = "middle";
            this._layout = _loc1_;
         }
      }
      
      override protected function draw() : void
      {
         var _loc1_:Boolean = this.isInvalid("size");
         var _loc8_:Boolean = this.isInvalid("data");
         var _loc9_:Boolean = this.isInvalid("styles");
         var _loc3_:Boolean = this.isInvalid("state");
         var _loc10_:Boolean = this.isInvalid("leftContent");
         var _loc4_:Boolean = this.isInvalid("rightContent");
         var _loc7_:Boolean = this.isInvalid("centerContent");
         var _loc5_:Boolean;
         if(_loc5_ = this.isInvalid("textRenderer"))
         {
            this.createTitle();
         }
         if(_loc5_ || _loc8_)
         {
            this.titleTextRenderer.text = this._title;
         }
         if(_loc3_ || _loc9_)
         {
            this.refreshBackground();
         }
         if(_loc5_ || _loc9_ || _loc1_)
         {
            this.refreshLayout();
         }
         if(_loc5_ || _loc9_)
         {
            this.refreshTitleStyles();
         }
         var _loc6_:Boolean = this._ignoreItemResizing;
         this._ignoreItemResizing = true;
         if(_loc10_)
         {
            if(this._leftItems)
            {
               for each(var _loc2_ in this._leftItems)
               {
                  if(_loc2_ is IFeathersControl)
                  {
                     IFeathersControl(_loc2_).styleNameList.add(this.itemStyleName);
                  }
                  this.addChild(_loc2_);
               }
            }
         }
         if(_loc4_)
         {
            if(this._rightItems)
            {
               for each(_loc2_ in this._rightItems)
               {
                  if(_loc2_ is IFeathersControl)
                  {
                     IFeathersControl(_loc2_).styleNameList.add(this.itemStyleName);
                  }
                  this.addChild(_loc2_);
               }
            }
         }
         if(_loc7_)
         {
            if(this._centerItems)
            {
               for each(_loc2_ in this._centerItems)
               {
                  if(_loc2_ is IFeathersControl)
                  {
                     IFeathersControl(_loc2_).styleNameList.add(this.itemStyleName);
                  }
                  this.addChild(_loc2_);
               }
            }
         }
         this._ignoreItemResizing = _loc6_;
         if(_loc3_ || _loc5_)
         {
            this.refreshEnabled();
         }
         _loc1_ = this.autoSizeIfNeeded() || _loc1_;
         this.layoutBackground();
         if(_loc1_ || _loc10_ || _loc4_ || _loc7_ || _loc9_)
         {
            this.leftItemsWidth = 0;
            this.rightItemsWidth = 0;
            if(this._leftItems)
            {
               this.layoutLeftItems();
            }
            if(this._rightItems)
            {
               this.layoutRightItems();
            }
            if(this._centerItems)
            {
               this.layoutCenterItems();
            }
         }
         if(_loc5_ || _loc1_ || _loc9_ || _loc8_ || _loc10_ || _loc4_ || _loc7_)
         {
            this.layoutTitle();
         }
      }
      
      protected function autoSizeIfNeeded() : Boolean
      {
         var _loc21_:int = 0;
         var _loc18_:int = 0;
         var _loc12_:* = null;
         var _loc8_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc17_:* = NaN;
         var _loc4_:* = null;
         var _loc24_:* = NaN;
         var _loc1_:Number = NaN;
         var _loc15_:* = this._explicitWidth !== this._explicitWidth;
         var _loc7_:* = this._explicitHeight !== this._explicitHeight;
         var _loc23_:* = this._explicitMinWidth !== this._explicitMinWidth;
         var _loc11_:* = this._explicitMinHeight !== this._explicitMinHeight;
         if(!_loc15_ && !_loc7_ && !_loc23_ && !_loc11_)
         {
            return false;
         }
         resetFluidChildDimensionsForMeasurement(this.currentBackgroundSkin,this._explicitWidth,this._explicitHeight,this._explicitMinWidth,this._explicitMinHeight,this._explicitMaxWidth,this._explicitMaxHeight,this._explicitBackgroundWidth,this._explicitBackgroundHeight,this._explicitBackgroundMinWidth,this._explicitBackgroundMinHeight,this._explicitBackgroundMaxWidth,this._explicitBackgroundMaxHeight);
         var _loc9_:IMeasureDisplayObject = this.currentBackgroundSkin as IMeasureDisplayObject;
         if(this.currentBackgroundSkin is IValidating)
         {
            IValidating(this.currentBackgroundSkin).validate();
         }
         var _loc19_:Number = this.calculateExtraOSStatusBarPadding();
         var _loc20_:* = 0;
         var _loc26_:* = 0;
         var _loc10_:Boolean = this._leftItems !== null && this._leftItems.length > 0;
         var _loc5_:Boolean = this._rightItems !== null && this._rightItems.length > 0;
         var _loc6_:Boolean = this._centerItems !== null && this._centerItems.length > 0;
         var _loc16_:Boolean = this._ignoreItemResizing;
         this._ignoreItemResizing = true;
         if(_loc10_)
         {
            _loc21_ = this._leftItems.length;
            _loc18_ = 0;
            while(_loc18_ < _loc21_)
            {
               if((_loc12_ = this._leftItems[_loc18_]) is IValidating)
               {
                  IValidating(_loc12_).validate();
               }
               _loc8_ = _loc12_.width;
               if(_loc8_ === _loc8_)
               {
                  _loc20_ += _loc8_;
                  if(_loc18_ > 0)
                  {
                     _loc20_ += this._gap;
                  }
               }
               _loc3_ = _loc12_.height;
               if(_loc3_ === _loc3_ && _loc3_ > _loc26_)
               {
                  _loc26_ = _loc3_;
               }
               _loc18_++;
            }
         }
         if(_loc6_)
         {
            _loc21_ = this._centerItems.length;
            _loc18_ = 0;
            while(_loc18_ < _loc21_)
            {
               if((_loc12_ = this._centerItems[_loc18_]) is IValidating)
               {
                  IValidating(_loc12_).validate();
               }
               _loc8_ = _loc12_.width;
               if(_loc8_ === _loc8_)
               {
                  _loc20_ += _loc8_;
                  if(_loc18_ > 0)
                  {
                     _loc20_ += this._gap;
                  }
               }
               _loc3_ = _loc12_.height;
               if(_loc3_ === _loc3_ && _loc3_ > _loc26_)
               {
                  _loc26_ = _loc3_;
               }
               _loc18_++;
            }
         }
         if(_loc5_)
         {
            _loc21_ = this._rightItems.length;
            _loc18_ = 0;
            while(_loc18_ < _loc21_)
            {
               if((_loc12_ = this._rightItems[_loc18_]) is IValidating)
               {
                  IValidating(_loc12_).validate();
               }
               _loc8_ = _loc12_.width;
               if(_loc8_ === _loc8_)
               {
                  _loc20_ += _loc8_;
                  if(_loc18_ > 0)
                  {
                     _loc20_ += this._gap;
                  }
               }
               _loc3_ = _loc12_.height;
               if(_loc3_ === _loc3_ && _loc3_ > _loc26_)
               {
                  _loc26_ = _loc3_;
               }
               _loc18_++;
            }
         }
         this._ignoreItemResizing = _loc16_;
         if(this._titleAlign === "center" && _loc6_)
         {
            if(_loc10_)
            {
               _loc20_ += this._gap;
            }
            if(_loc5_)
            {
               _loc20_ += this._gap;
            }
         }
         else
         {
            switch(_loc13_)
            {
               default:
                  _loc13_ = this._gap;
               case _loc13_:
                  _loc17_ = Number(this._explicitWidth);
                  if(_loc15_)
                  {
                     _loc17_ = Number(this._explicitMaxWidth);
                  }
                  _loc17_ -= _loc20_;
                  if(_loc10_)
                  {
                     _loc17_ -= _loc13_;
                  }
                  if(_loc6_)
                  {
                     _loc17_ -= _loc13_;
                  }
                  if(_loc5_)
                  {
                     _loc17_ -= _loc13_;
                  }
                  if(_loc17_ < 0)
                  {
                     _loc17_ = 0;
                  }
                  this.titleTextRenderer.maxWidth = _loc17_;
                  _loc4_ = Pool.getPoint();
                  this.titleTextRenderer.measureText(_loc4_);
                  _loc24_ = Number(_loc4_.x);
                  _loc1_ = _loc4_.y;
                  Pool.putPoint(_loc4_);
                  if(_loc24_ === _loc24_)
                  {
                     if(_loc10_)
                     {
                        _loc24_ += _loc13_;
                     }
                     if(_loc5_)
                     {
                        _loc24_ += _loc13_;
                     }
                  }
                  else
                  {
                     _loc24_ = 0;
                  }
                  _loc20_ += _loc24_;
                  if(_loc1_ === _loc1_ && _loc1_ > _loc26_)
                  {
                     _loc26_ = _loc1_;
                     break;
                  }
                  break;
               case null:
            }
         }
         var _loc14_:Number = this._explicitWidth;
         if(_loc15_)
         {
            _loc14_ = _loc20_ + this._paddingLeft + this._paddingRight;
            if(this.currentBackgroundSkin !== null && this.currentBackgroundSkin.width > _loc14_)
            {
               _loc14_ = this.currentBackgroundSkin.width;
            }
         }
         var _loc2_:* = Number(this._explicitHeight);
         if(_loc7_)
         {
            _loc2_ = _loc26_;
            _loc2_ += this._paddingTop + this._paddingBottom;
            if(this.currentBackgroundSkin !== null && this.currentBackgroundSkin.height > _loc2_)
            {
               _loc2_ = Number(this.currentBackgroundSkin.height);
            }
            if(_loc19_ > 0)
            {
               if(_loc2_ < this._explicitMinHeight)
               {
                  _loc2_ = Number(this._explicitMinHeight);
               }
               _loc2_ += _loc19_;
            }
         }
         var _loc22_:Number = this._explicitMinWidth;
         if(_loc23_)
         {
            _loc22_ = _loc20_ + this._paddingLeft + this._paddingRight;
            switch(_loc9_)
            {
               default:
                  if(_loc9_.minWidth > _loc22_)
                  {
                     _loc22_ = _loc9_.minWidth;
                  }
                  break;
               case null:
                  if(this._explicitBackgroundMinWidth > _loc22_)
                  {
                     _loc22_ = this._explicitBackgroundMinWidth;
                     break;
                  }
                  break;
               case null:
            }
         }
         var _loc25_:* = Number(this._explicitMinHeight);
         if(_loc11_)
         {
            _loc25_ = Number((_loc25_ = _loc26_) + (this._paddingTop + this._paddingBottom));
            switch(_loc9_)
            {
               default:
                  if(_loc9_.minHeight > _loc25_)
                  {
                     _loc25_ = Number(_loc9_.minHeight);
                  }
                  break;
               case null:
                  if(this._explicitBackgroundMinHeight > _loc25_)
                  {
                     _loc25_ = Number(this._explicitBackgroundMinHeight);
                     break;
                  }
                  break;
               case null:
            }
            if(_loc19_ > 0)
            {
               _loc25_ += _loc19_;
            }
         }
         return this.saveMeasurements(_loc14_,_loc2_,_loc22_,_loc25_);
      }
      
      protected function createTitle() : void
      {
         if(this.titleTextRenderer)
         {
            this.removeChild(DisplayObject(this.titleTextRenderer),true);
            this.titleTextRenderer = null;
         }
         var _loc1_:Function = this._titleFactory != null ? this._titleFactory : FeathersControl.defaultTextRendererFactory;
         this.titleTextRenderer = ITextRenderer(_loc1_());
         var _loc2_:IFeathersControl = IFeathersControl(this.titleTextRenderer);
         var _loc3_:String = this._customTitleStyleName != null ? this._customTitleStyleName : this.titleStyleName;
         _loc2_.styleNameList.add(_loc3_);
         this.addChild(DisplayObject(_loc2_));
      }
      
      protected function refreshBackground() : void
      {
         var _loc2_:* = null;
         var _loc1_:DisplayObject = this.currentBackgroundSkin;
         this.currentBackgroundSkin = this._backgroundSkin;
         if(!this._isEnabled && this._backgroundDisabledSkin !== null)
         {
            this.currentBackgroundSkin = this._backgroundDisabledSkin;
         }
         switch(_loc1_)
         {
            default:
               if(this.currentBackgroundSkin is IFeathersControl)
               {
                  IFeathersControl(this.currentBackgroundSkin).initializeNow();
               }
               if(this.currentBackgroundSkin is IMeasureDisplayObject)
               {
                  _loc2_ = IMeasureDisplayObject(this.currentBackgroundSkin);
                  this._explicitBackgroundWidth = _loc2_.explicitWidth;
                  this._explicitBackgroundHeight = _loc2_.explicitHeight;
                  this._explicitBackgroundMinWidth = _loc2_.explicitMinWidth;
                  this._explicitBackgroundMinHeight = _loc2_.explicitMinHeight;
                  this._explicitBackgroundMaxWidth = _loc2_.explicitMaxWidth;
                  this._explicitBackgroundMaxHeight = _loc2_.explicitMaxHeight;
               }
               else
               {
                  this._explicitBackgroundWidth = this.currentBackgroundSkin.width;
                  this._explicitBackgroundHeight = this.currentBackgroundSkin.height;
                  this._explicitBackgroundMinWidth = this._explicitBackgroundWidth;
                  this._explicitBackgroundMinHeight = this._explicitBackgroundHeight;
                  this._explicitBackgroundMaxWidth = this._explicitBackgroundWidth;
                  this._explicitBackgroundMaxHeight = this._explicitBackgroundHeight;
               }
               this.addChildAt(this.currentBackgroundSkin,0);
               break;
            case this.currentBackgroundSkin:
            case this.currentBackgroundSkin:
         }
      }
      
      protected function removeCurrentBackgroundSkin(param1:DisplayObject) : void
      {
         var _loc2_:* = null;
         if(param1 === null)
         {
            return;
         }
         if(param1.parent === this)
         {
            param1.width = this._explicitBackgroundWidth;
            param1.height = this._explicitBackgroundHeight;
            if(param1 is IMeasureDisplayObject)
            {
               _loc2_ = IMeasureDisplayObject(param1);
               _loc2_.minWidth = this._explicitBackgroundMinWidth;
               _loc2_.minHeight = this._explicitBackgroundMinHeight;
               _loc2_.maxWidth = this._explicitBackgroundMaxWidth;
               _loc2_.maxHeight = this._explicitBackgroundMaxHeight;
            }
            param1.removeFromParent(false);
         }
      }
      
      protected function refreshLayout() : void
      {
         this._layout.gap = this._gap;
         this._layout.paddingTop = this._paddingTop + this.calculateExtraOSStatusBarPadding();
         this._layout.paddingBottom = this._paddingBottom;
         this._layout.verticalAlign = this._verticalAlign;
      }
      
      protected function refreshEnabled() : void
      {
         this.titleTextRenderer.isEnabled = this._isEnabled;
      }
      
      protected function refreshTitleStyles() : void
      {
         var _loc2_:* = null;
         this.titleTextRenderer.fontStyles = this._fontStylesSet;
         this.titleTextRenderer.wordWrap = this._wordWrap;
         for(var _loc1_ in this._titleProperties)
         {
            _loc2_ = this._titleProperties[_loc1_];
            this.titleTextRenderer[_loc1_] = _loc2_;
         }
      }
      
      protected function calculateExtraOSStatusBarPadding() : Number
      {
         var _loc4_:* = null;
         if(!this._useExtraPaddingForOSStatusBar)
         {
            return 0;
         }
         var _loc3_:String = Capabilities.os;
         if(_loc3_.indexOf("iOS ") !== -1)
         {
            _loc3_ = _loc3_.substring("iOS ".length,_loc3_.indexOf("."));
         }
         else
         {
            if(_loc3_.indexOf("iPhone OS ") === -1)
            {
               return 0;
            }
            _loc3_ = _loc3_.substring("iPhone OS ".length,_loc3_.indexOf("."));
         }
         if(parseInt(_loc3_,10) < 7)
         {
            return 0;
         }
         var _loc5_:*;
         var _loc1_:Starling = this.stage !== null ? this.stage.starling : (_loc5_ = Starling, starling.core.Starling.sCurrent);
         var _loc2_:Stage = _loc1_.nativeStage;
         if(_loc2_.displayState !== "normal")
         {
            return 0;
         }
         if(iOSStatusBarScaledHeight !== iOSStatusBarScaledHeight)
         {
            (_loc4_ = new ScreenDensityScaleCalculator()).addScaleForDensity(168,1);
            _loc4_.addScaleForDensity(326,2);
            _loc4_.addScaleForDensity(401,3);
            iOSStatusBarScaledHeight = 20 * _loc4_.getScale(DeviceCapabilities.dpi);
         }
         return iOSStatusBarScaledHeight / _loc1_.contentScaleFactor;
      }
      
      protected function layoutBackground() : void
      {
         if(!this.currentBackgroundSkin)
         {
            return;
         }
         this.currentBackgroundSkin.width = this.actualWidth;
         this.currentBackgroundSkin.height = this.actualHeight;
      }
      
      protected function layoutLeftItems() : void
      {
         for each(var _loc1_ in this._leftItems)
         {
            if(_loc1_ is IValidating)
            {
               IValidating(_loc1_).validate();
            }
         }
         HELPER_BOUNDS.x = HELPER_BOUNDS.y = 0;
         HELPER_BOUNDS.scrollX = HELPER_BOUNDS.scrollY = 0;
         HELPER_BOUNDS.explicitWidth = this.actualWidth;
         HELPER_BOUNDS.explicitHeight = this.actualHeight;
         this._layout.horizontalAlign = "left";
         this._layout.paddingRight = 0;
         this._layout.paddingLeft = this._paddingLeft;
         this._layout.layout(this._leftItems,HELPER_BOUNDS,HELPER_LAYOUT_RESULT);
         this.leftItemsWidth = HELPER_LAYOUT_RESULT.contentWidth;
         if(this.leftItemsWidth !== this.leftItemsWidth)
         {
            this.leftItemsWidth = 0;
         }
      }
      
      protected function layoutRightItems() : void
      {
         for each(var _loc1_ in this._rightItems)
         {
            if(_loc1_ is IValidating)
            {
               IValidating(_loc1_).validate();
            }
         }
         HELPER_BOUNDS.x = HELPER_BOUNDS.y = 0;
         HELPER_BOUNDS.scrollX = HELPER_BOUNDS.scrollY = 0;
         HELPER_BOUNDS.explicitWidth = this.actualWidth;
         HELPER_BOUNDS.explicitHeight = this.actualHeight;
         this._layout.horizontalAlign = "right";
         this._layout.paddingRight = this._paddingRight;
         this._layout.paddingLeft = 0;
         this._layout.layout(this._rightItems,HELPER_BOUNDS,HELPER_LAYOUT_RESULT);
         this.rightItemsWidth = HELPER_LAYOUT_RESULT.contentWidth;
         if(this.rightItemsWidth !== this.rightItemsWidth)
         {
            this.rightItemsWidth = 0;
         }
      }
      
      protected function layoutCenterItems() : void
      {
         for each(var _loc1_ in this._centerItems)
         {
            if(_loc1_ is IValidating)
            {
               IValidating(_loc1_).validate();
            }
         }
         HELPER_BOUNDS.x = HELPER_BOUNDS.y = 0;
         HELPER_BOUNDS.scrollX = HELPER_BOUNDS.scrollY = 0;
         HELPER_BOUNDS.explicitWidth = this.actualWidth;
         HELPER_BOUNDS.explicitHeight = this.actualHeight;
         this._layout.horizontalAlign = "center";
         this._layout.paddingRight = this._paddingRight;
         this._layout.paddingLeft = this._paddingLeft;
         this._layout.layout(this._centerItems,HELPER_BOUNDS,HELPER_LAYOUT_RESULT);
      }
      
      protected function layoutTitle() : void
      {
         var _loc7_:* = NaN;
         var _loc8_:* = NaN;
         var _loc11_:* = NaN;
         var _loc6_:Number = NaN;
         var _loc10_:Boolean = this._leftItems !== null && this._leftItems.length > 0;
         var _loc1_:Boolean = this._rightItems !== null && this._rightItems.length > 0;
         var _loc4_:Boolean = this._centerItems !== null && this._centerItems.length > 0;
         if(this._titleAlign === "center" && _loc4_)
         {
            this.titleTextRenderer.visible = false;
            return;
         }
         if(this._titleAlign === "left" && _loc10_ && _loc4_)
         {
            this.titleTextRenderer.visible = false;
            return;
         }
         if(this._titleAlign === "right" && _loc1_ && _loc4_)
         {
            this.titleTextRenderer.visible = false;
            return;
         }
         this.titleTextRenderer.visible = true;
         var _loc2_:Number = this._titleGap;
         if(_loc2_ !== _loc2_)
         {
            _loc2_ = this._gap;
         }
         var _loc5_:Number = this._paddingLeft;
         if(_loc10_)
         {
            _loc5_ = this.leftItemsWidth + _loc2_;
         }
         var _loc3_:Number = this._paddingRight;
         if(_loc1_)
         {
            _loc3_ = this.rightItemsWidth + _loc2_;
         }
         if(this._titleAlign === "left")
         {
            if((_loc7_ = Number(this.actualWidth - _loc5_ - _loc3_)) < 0)
            {
               _loc7_ = 0;
            }
            this.titleTextRenderer.maxWidth = _loc7_;
            this.titleTextRenderer.validate();
            this.titleTextRenderer.x = _loc5_;
         }
         else if(this._titleAlign === "right")
         {
            if((_loc7_ = Number(this.actualWidth - _loc5_ - _loc3_)) < 0)
            {
               _loc7_ = 0;
            }
            this.titleTextRenderer.maxWidth = _loc7_;
            this.titleTextRenderer.validate();
            this.titleTextRenderer.x = this.actualWidth - this.titleTextRenderer.width - _loc3_;
         }
         else
         {
            if((_loc8_ = Number(this.actualWidth - this._paddingLeft - this._paddingRight)) < 0)
            {
               _loc8_ = 0;
            }
            if((_loc11_ = Number(this.actualWidth - _loc5_ - _loc3_)) < 0)
            {
               _loc11_ = 0;
            }
            this.titleTextRenderer.maxWidth = _loc11_;
            this.titleTextRenderer.validate();
            _loc6_ = this._paddingLeft + Math.round((_loc8_ - this.titleTextRenderer.width) / 2);
            if(_loc5_ > _loc6_ || _loc6_ + this.titleTextRenderer.width > this.actualWidth - _loc3_)
            {
               this.titleTextRenderer.x = _loc5_ + Math.round((_loc11_ - this.titleTextRenderer.width) / 2);
            }
            else
            {
               this.titleTextRenderer.x = _loc6_;
            }
         }
         var _loc9_:Number = this._paddingTop + this.calculateExtraOSStatusBarPadding();
         switch(this._verticalAlign)
         {
            case "top":
               this.titleTextRenderer.y = _loc9_;
               break;
            case "bottom":
               this.titleTextRenderer.y = this.actualHeight - this._paddingBottom - this.titleTextRenderer.height;
               break;
            default:
               this.titleTextRenderer.y = _loc9_ + Math.round((this.actualHeight - _loc9_ - this._paddingBottom - this.titleTextRenderer.height) / 2);
         }
      }
      
      protected function header_addedToStageHandler(param1:Event) : void
      {
         var _loc3_:*;
         var _loc2_:Starling = this.stage !== null ? this.stage.starling : (_loc3_ = Starling, starling.core.Starling.sCurrent);
         _loc2_.nativeStage.addEventListener("fullScreen",nativeStage_fullScreenHandler);
      }
      
      protected function header_removedFromStageHandler(param1:Event) : void
      {
         var _loc3_:*;
         var _loc2_:Starling = this.stage !== null ? this.stage.starling : (_loc3_ = Starling, starling.core.Starling.sCurrent);
         _loc2_.nativeStage.removeEventListener("fullScreen",nativeStage_fullScreenHandler);
      }
      
      protected function nativeStage_fullScreenHandler(param1:FullScreenEvent) : void
      {
         this.invalidate("size");
      }
      
      protected function fontStyles_changeHandler(param1:Event) : void
      {
         this.invalidate("styles");
      }
      
      protected function titleProperties_onChange(param1:PropertyProxy, param2:String) : void
      {
         this.invalidate("styles");
      }
      
      protected function item_resizeHandler(param1:Event) : void
      {
         if(this._ignoreItemResizing)
         {
            return;
         }
         this.invalidate("size");
      }
   }
}
