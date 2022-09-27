package feathers.controls
{
   import feathers.core.FeathersControl;
   import feathers.core.IFocusDisplayObject;
   import feathers.core.ITextBaselineControl;
   import feathers.core.IValidating;
   import feathers.core.PropertyProxy;
   import feathers.core.ToggleGroup;
   import feathers.data.ListCollection;
   import feathers.layout.HorizontalLayout;
   import feathers.layout.LayoutBoundsResult;
   import feathers.layout.VerticalLayout;
   import feathers.layout.ViewPortBounds;
   import feathers.skins.IStyleProvider;
   import flash.utils.Dictionary;
   import starling.animation.Tween;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   import starling.events.Event;
   import starling.events.KeyboardEvent;
   
   public class TabBar extends FeathersControl implements IFocusDisplayObject, ITextBaselineControl
   {
      
      protected static const INVALIDATION_FLAG_TAB_FACTORY:String = "tabFactory";
      
      private static const DEFAULT_TAB_FIELDS:Vector.<String> = new <String>["upIcon","downIcon","hoverIcon","disabledIcon","defaultSelectedIcon","selectedUpIcon","selectedDownIcon","selectedHoverIcon","selectedDisabledIcon","name"];
      
      public static const DIRECTION_HORIZONTAL:String = "horizontal";
      
      public static const DIRECTION_VERTICAL:String = "vertical";
      
      public static const HORIZONTAL_ALIGN_LEFT:String = "left";
      
      public static const HORIZONTAL_ALIGN_CENTER:String = "center";
      
      public static const HORIZONTAL_ALIGN_RIGHT:String = "right";
      
      public static const HORIZONTAL_ALIGN_JUSTIFY:String = "justify";
      
      public static const VERTICAL_ALIGN_TOP:String = "top";
      
      public static const VERTICAL_ALIGN_MIDDLE:String = "middle";
      
      public static const VERTICAL_ALIGN_BOTTOM:String = "bottom";
      
      public static const VERTICAL_ALIGN_JUSTIFY:String = "justify";
      
      public static const DEFAULT_CHILD_STYLE_NAME_TAB:String = "feathers-tab-bar-tab";
      
      public static var globalStyleProvider:IStyleProvider;
       
      
      protected var tabStyleName:String = "feathers-tab-bar-tab";
      
      protected var firstTabStyleName:String = "feathers-tab-bar-tab";
      
      protected var lastTabStyleName:String = "feathers-tab-bar-tab";
      
      protected var toggleGroup:ToggleGroup;
      
      protected var activeFirstTab:ToggleButton;
      
      protected var inactiveFirstTab:ToggleButton;
      
      protected var activeLastTab:ToggleButton;
      
      protected var inactiveLastTab:ToggleButton;
      
      protected var _layoutItems:Vector.<DisplayObject>;
      
      protected var activeTabs:Vector.<ToggleButton>;
      
      protected var inactiveTabs:Vector.<ToggleButton>;
      
      protected var _tabToItem:Dictionary;
      
      protected var _dataProvider:ListCollection;
      
      protected var verticalLayout:VerticalLayout;
      
      protected var horizontalLayout:HorizontalLayout;
      
      protected var _viewPortBounds:ViewPortBounds;
      
      protected var _layoutResult:LayoutBoundsResult;
      
      protected var _direction:String = "horizontal";
      
      protected var _horizontalAlign:String = "justify";
      
      protected var _verticalAlign:String = "justify";
      
      protected var _selectionSkin:DisplayObject;
      
      protected var _selectionChangeTween:Tween;
      
      protected var _selectionChangeDuration:Number = 0.25;
      
      protected var _selectionChangeEase:Object = "easeOut";
      
      protected var _distributeTabSizes:Boolean = true;
      
      protected var _gap:Number = 0;
      
      protected var _firstGap:Number = NaN;
      
      protected var _lastGap:Number = NaN;
      
      protected var _paddingTop:Number = 0;
      
      protected var _paddingRight:Number = 0;
      
      protected var _paddingBottom:Number = 0;
      
      protected var _paddingLeft:Number = 0;
      
      protected var _tabFactory:Function;
      
      protected var _firstTabFactory:Function;
      
      protected var _lastTabFactory:Function;
      
      protected var _tabInitializer:Function;
      
      protected var _tabReleaser:Function;
      
      protected var _labelField:String = "label";
      
      protected var _labelFunction:Function;
      
      protected var _enabledField:String = "isEnabled";
      
      protected var _iconField:String = "defaultIcon";
      
      protected var _iconFunction:Function;
      
      protected var _enabledFunction:Function;
      
      protected var _ignoreSelectionChanges:Boolean = false;
      
      protected var _selectedIndex:int = -1;
      
      protected var _selectedItem:Object = null;
      
      protected var _customTabStyleName:String;
      
      protected var _customFirstTabStyleName:String;
      
      protected var _customLastTabStyleName:String;
      
      protected var _tabProperties:PropertyProxy;
      
      protected var _animateSelectionChange:Boolean = false;
      
      protected var _focusedTabIndex:int = -1;
      
      public function TabBar()
      {
         _layoutItems = new Vector.<DisplayObject>(0);
         activeTabs = new Vector.<ToggleButton>(0);
         inactiveTabs = new Vector.<ToggleButton>(0);
         _tabToItem = new Dictionary(true);
         _viewPortBounds = new ViewPortBounds();
         _layoutResult = new LayoutBoundsResult();
         _tabFactory = defaultTabFactory;
         _tabInitializer = defaultTabInitializer;
         _tabReleaser = defaultTabReleaser;
         super();
      }
      
      protected static function defaultTabFactory() : ToggleButton
      {
         return new ToggleButton();
      }
      
      override protected function get defaultStyleProvider() : IStyleProvider
      {
         return TabBar.globalStyleProvider;
      }
      
      public function get dataProvider() : ListCollection
      {
         return this._dataProvider;
      }
      
      public function set dataProvider(param1:ListCollection) : void
      {
         if(this._dataProvider == param1)
         {
            return;
         }
         var _loc3_:int = this.selectedIndex;
         var _loc2_:Object = this.selectedItem;
         if(this._dataProvider)
         {
            this._dataProvider.removeEventListener("addItem",dataProvider_addItemHandler);
            this._dataProvider.removeEventListener("removeItem",dataProvider_removeItemHandler);
            this._dataProvider.removeEventListener("removeAll",dataProvider_removeAllHandler);
            this._dataProvider.removeEventListener("replaceItem",dataProvider_replaceItemHandler);
            this._dataProvider.removeEventListener("filterChange",dataProvider_filterChangeHandler);
            this._dataProvider.removeEventListener("updateItem",dataProvider_updateItemHandler);
            this._dataProvider.removeEventListener("updateAll",dataProvider_updateAllHandler);
            this._dataProvider.removeEventListener("reset",dataProvider_resetHandler);
         }
         this._dataProvider = param1;
         if(this._dataProvider)
         {
            this._dataProvider.addEventListener("addItem",dataProvider_addItemHandler);
            this._dataProvider.addEventListener("removeItem",dataProvider_removeItemHandler);
            this._dataProvider.addEventListener("removeAll",dataProvider_removeAllHandler);
            this._dataProvider.addEventListener("replaceItem",dataProvider_replaceItemHandler);
            this._dataProvider.addEventListener("filterChange",dataProvider_filterChangeHandler);
            this._dataProvider.addEventListener("updateItem",dataProvider_updateItemHandler);
            this._dataProvider.addEventListener("updateAll",dataProvider_updateAllHandler);
            this._dataProvider.addEventListener("reset",dataProvider_resetHandler);
         }
         if(!this._dataProvider || this._dataProvider.length == 0)
         {
            this.selectedIndex = -1;
         }
         else
         {
            this.selectedIndex = 0;
         }
         if(this.selectedIndex == _loc3_ && this.selectedItem != _loc2_)
         {
            this.dispatchEventWith("change");
         }
         this.invalidate("data");
      }
      
      public function get direction() : String
      {
         return this._direction;
      }
      
      public function set direction(param1:String) : void
      {
         if(this.processStyleRestriction(arguments.callee))
         {
            return;
         }
         if(this._direction === param1)
         {
            return;
         }
         this._direction = param1;
         this.invalidate("styles");
      }
      
      public function get horizontalAlign() : String
      {
         return this._horizontalAlign;
      }
      
      public function set horizontalAlign(param1:String) : void
      {
         if(this.processStyleRestriction(arguments.callee))
         {
            return;
         }
         if(this._horizontalAlign === param1)
         {
            return;
         }
         this._horizontalAlign = param1;
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
      
      public function get selectionSkin() : DisplayObject
      {
         return this._selectionSkin;
      }
      
      public function set selectionSkin(param1:DisplayObject) : void
      {
         if(this.processStyleRestriction(arguments.callee))
         {
            if(param1 !== null)
            {
               param1.dispose();
            }
            return;
         }
         if(this._selectionSkin === param1)
         {
            return;
         }
         if(this._selectionSkin !== null && this._selectionSkin.parent === this)
         {
            this._selectionSkin.removeFromParent(false);
         }
         this._selectionSkin = param1;
         if(this._selectionSkin !== null)
         {
            this._selectionSkin.touchable = false;
            this.addChild(this._selectionSkin);
         }
         this.invalidate("styles");
      }
      
      public function get selectionChangeDuration() : Number
      {
         return this._selectionChangeDuration;
      }
      
      public function set selectionChangeDuration(param1:Number) : void
      {
         if(this.processStyleRestriction(arguments.callee))
         {
            return;
         }
         this._selectionChangeDuration = param1;
      }
      
      public function get selectionChangeEase() : Object
      {
         return this._selectionChangeEase;
      }
      
      public function set selectionChangeEase(param1:Object) : void
      {
         if(this.processStyleRestriction(arguments.callee))
         {
            return;
         }
         this._selectionChangeEase = param1;
      }
      
      public function get distributeTabSizes() : Boolean
      {
         return this._distributeTabSizes;
      }
      
      public function set distributeTabSizes(param1:Boolean) : void
      {
         if(this.processStyleRestriction(arguments.callee))
         {
            return;
         }
         if(this._distributeTabSizes === param1)
         {
            return;
         }
         this._distributeTabSizes = param1;
         this.invalidate("styles");
      }
      
      public function get gap() : Number
      {
         return this._gap;
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
      
      public function get firstGap() : Number
      {
         return this._firstGap;
      }
      
      public function set firstGap(param1:Number) : void
      {
         if(this.processStyleRestriction(arguments.callee))
         {
            return;
         }
         if(this._firstGap === param1)
         {
            return;
         }
         this._firstGap = param1;
         this.invalidate("styles");
      }
      
      public function get lastGap() : Number
      {
         return this._lastGap;
      }
      
      public function set lastGap(param1:Number) : void
      {
         if(this.processStyleRestriction(arguments.callee))
         {
            return;
         }
         if(this._lastGap === param1)
         {
            return;
         }
         this._lastGap = param1;
         this.invalidate("styles");
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
      
      public function get tabFactory() : Function
      {
         return this._tabFactory;
      }
      
      public function set tabFactory(param1:Function) : void
      {
         if(this._tabFactory == param1)
         {
            return;
         }
         this._tabFactory = param1;
         this.invalidate("tabFactory");
      }
      
      public function get firstTabFactory() : Function
      {
         return this._firstTabFactory;
      }
      
      public function set firstTabFactory(param1:Function) : void
      {
         if(this._firstTabFactory == param1)
         {
            return;
         }
         this._firstTabFactory = param1;
         this.invalidate("tabFactory");
      }
      
      public function get lastTabFactory() : Function
      {
         return this._lastTabFactory;
      }
      
      public function set lastTabFactory(param1:Function) : void
      {
         if(this._lastTabFactory == param1)
         {
            return;
         }
         this._lastTabFactory = param1;
         this.invalidate("tabFactory");
      }
      
      public function get tabInitializer() : Function
      {
         return this._tabInitializer;
      }
      
      public function set tabInitializer(param1:Function) : void
      {
         if(this._tabInitializer == param1)
         {
            return;
         }
         this._tabInitializer = param1;
         this.invalidate("data");
      }
      
      public function get tabReleaser() : Function
      {
         return this._tabReleaser;
      }
      
      public function set tabReleaser(param1:Function) : void
      {
         if(this._tabReleaser == param1)
         {
            return;
         }
         this._tabReleaser = param1;
         this.invalidate("data");
      }
      
      public function get labelField() : String
      {
         return this._labelField;
      }
      
      public function set labelField(param1:String) : void
      {
         if(this._labelField == param1)
         {
            return;
         }
         this._labelField = param1;
         this.invalidate("data");
      }
      
      public function get labelFunction() : Function
      {
         return this._labelFunction;
      }
      
      public function set labelFunction(param1:Function) : void
      {
         if(this._labelFunction == param1)
         {
            return;
         }
         this._labelFunction = param1;
         this.invalidate("data");
      }
      
      public function get enabledField() : String
      {
         return this._enabledField;
      }
      
      public function set enabledField(param1:String) : void
      {
         if(this._enabledField == param1)
         {
            return;
         }
         this._enabledField = param1;
         this.invalidate("data");
      }
      
      public function get iconField() : String
      {
         return this._iconField;
      }
      
      public function set iconField(param1:String) : void
      {
         if(this._iconField == param1)
         {
            return;
         }
         this._iconField = param1;
         this.invalidate("data");
      }
      
      public function get iconFunction() : Function
      {
         return this._iconFunction;
      }
      
      public function set iconFunction(param1:Function) : void
      {
         if(this._iconFunction == param1)
         {
            return;
         }
         this._iconFunction = param1;
         this.invalidate("data");
      }
      
      public function get enabledFunction() : Function
      {
         return this._enabledFunction;
      }
      
      public function set enabledFunction(param1:Function) : void
      {
         if(this._enabledFunction == param1)
         {
            return;
         }
         this._enabledFunction = param1;
         this.invalidate("data");
      }
      
      public function get selectedIndex() : int
      {
         return this._selectedIndex;
      }
      
      public function set selectedIndex(param1:int) : void
      {
         this._animateSelectionChange = false;
         if(this._selectedIndex === param1)
         {
            return;
         }
         this._selectedIndex = param1;
         this.refreshSelectedItem();
         this.invalidate("selected");
         this.dispatchEventWith("change");
      }
      
      public function get selectedItem() : Object
      {
         return this._selectedItem;
      }
      
      public function set selectedItem(param1:Object) : void
      {
         if(this._selectedItem === param1)
         {
            return;
         }
         if(this._dataProvider === null)
         {
            this.selectedIndex = -1;
            return;
         }
         var _loc2_:int = this._dataProvider.getItemIndex(param1);
         if(_loc2_ === -1)
         {
            this.selectedIndex = -1;
         }
         else if(this._selectedIndex !== _loc2_)
         {
            this.selectedIndex = _loc2_;
         }
         else
         {
            this._animateSelectionChange = false;
            this._selectedItem = param1;
            this.invalidate("selected");
            this.dispatchEventWith("change");
         }
      }
      
      public function get customTabStyleName() : String
      {
         return this._customTabStyleName;
      }
      
      public function set customTabStyleName(param1:String) : void
      {
         if(this.processStyleRestriction(arguments.callee))
         {
            return;
         }
         if(this._customTabStyleName === param1)
         {
            return;
         }
         this._customTabStyleName = param1;
         this.invalidate("tabFactory");
      }
      
      public function get customFirstTabStyleName() : String
      {
         return this._customFirstTabStyleName;
      }
      
      public function set customFirstTabStyleName(param1:String) : void
      {
         if(this.processStyleRestriction(arguments.callee))
         {
            return;
         }
         if(this._customFirstTabStyleName === param1)
         {
            return;
         }
         this._customFirstTabStyleName = param1;
         this.invalidate("tabFactory");
      }
      
      public function get customLastTabStyleName() : String
      {
         return this._customLastTabStyleName;
      }
      
      public function set customLastTabStyleName(param1:String) : void
      {
         if(this.processStyleRestriction(arguments.callee))
         {
            return;
         }
         if(this._customLastTabStyleName === param1)
         {
            return;
         }
         this._customLastTabStyleName = param1;
         this.invalidate("tabFactory");
      }
      
      public function get tabProperties() : Object
      {
         if(!this._tabProperties)
         {
            this._tabProperties = new PropertyProxy(childProperties_onChange);
         }
         return this._tabProperties;
      }
      
      public function set tabProperties(param1:Object) : void
      {
         var _loc2_:* = null;
         if(this._tabProperties == param1)
         {
            return;
         }
         if(!param1)
         {
            param1 = new PropertyProxy();
         }
         if(!(param1 is PropertyProxy))
         {
            _loc2_ = new PropertyProxy();
            for(var _loc3_ in param1)
            {
               _loc2_[_loc3_] = param1[_loc3_];
            }
            param1 = _loc2_;
         }
         if(this._tabProperties)
         {
            this._tabProperties.removeOnChangeCallback(childProperties_onChange);
         }
         this._tabProperties = PropertyProxy(param1);
         if(this._tabProperties)
         {
            this._tabProperties.addOnChangeCallback(childProperties_onChange);
         }
         this.invalidate("styles");
      }
      
      public function get baseline() : Number
      {
         if(!this.activeTabs || this.activeTabs.length === 0)
         {
            return this.scaledActualHeight;
         }
         var _loc1_:ToggleButton = this.activeTabs[0];
         return this.scaleY * (_loc1_.y + _loc1_.baseline);
      }
      
      override public function dispose() : void
      {
         var _loc2_:int = 0;
         var _loc1_:* = null;
         this._selectedIndex = -1;
         this._ignoreSelectionChanges = true;
         var _loc3_:int = this.activeTabs.length;
         _loc2_ = 0;
         while(_loc2_ < _loc3_)
         {
            _loc1_ = this.activeTabs.shift();
            this.destroyTab(_loc1_);
            _loc2_++;
         }
         this.dataProvider = null;
         super.dispose();
      }
      
      public function setSelectedIndexWithAnimation(param1:int) : void
      {
         if(this._selectedIndex == param1)
         {
            return;
         }
         this._selectedIndex = param1;
         this.refreshSelectedItem();
         this._animateSelectionChange = true;
         this.invalidate("selected");
         this.dispatchEventWith("change");
      }
      
      public function setSelectedItemWithAnimation(param1:Object) : void
      {
         if(this.selectedItem == param1)
         {
            return;
         }
         var _loc2_:int = -1;
         if(this._dataProvider !== null)
         {
            _loc2_ = this._dataProvider.getItemIndex(param1);
         }
         this.setSelectedIndexWithAnimation(_loc2_);
      }
      
      override protected function initialize() : void
      {
         this.toggleGroup = new ToggleGroup();
         this.toggleGroup.isSelectionRequired = true;
         this.toggleGroup.addEventListener("change",toggleGroup_changeHandler);
      }
      
      override protected function draw() : void
      {
         var _loc5_:Boolean = this.isInvalid("data");
         var _loc6_:Boolean = this.isInvalid("styles");
         var _loc3_:Boolean = this.isInvalid("state");
         var _loc4_:Boolean = this.isInvalid("selected");
         var _loc1_:Boolean = this.isInvalid("tabFactory");
         var _loc2_:Boolean = this.isInvalid("size");
         if(_loc5_ || _loc1_ || _loc3_)
         {
            this.refreshTabs(_loc1_);
         }
         if(_loc5_ || _loc1_ || _loc6_)
         {
            this.refreshTabStyles();
         }
         if(_loc5_ || _loc1_ || _loc4_)
         {
            this.commitSelection();
         }
         if(_loc5_ || _loc1_ || _loc3_)
         {
            this.commitEnabled();
         }
         if(_loc6_)
         {
            this.refreshLayoutStyles();
         }
         this.layoutTabs();
      }
      
      protected function commitSelection() : void
      {
         this.toggleGroup.selectedIndex = this._selectedIndex;
      }
      
      protected function commitEnabled() : void
      {
         for each(var _loc1_ in this.activeTabs)
         {
            _loc1_.isEnabled = _loc1_.isEnabled && this._isEnabled;
         }
      }
      
      protected function refreshTabStyles() : void
      {
         var _loc3_:* = null;
         for(var _loc2_ in this._tabProperties)
         {
            _loc3_ = this._tabProperties[_loc2_];
            for each(var _loc1_ in this.activeTabs)
            {
               _loc1_[_loc2_] = _loc3_;
            }
         }
      }
      
      protected function refreshLayoutStyles() : void
      {
         if(this._direction == "vertical")
         {
            if(this.horizontalLayout)
            {
               this.horizontalLayout = null;
            }
            if(!this.verticalLayout)
            {
               this.verticalLayout = new VerticalLayout();
               this.verticalLayout.useVirtualLayout = false;
            }
            this.verticalLayout.distributeHeights = this._distributeTabSizes;
            this.verticalLayout.horizontalAlign = this._horizontalAlign;
            this.verticalLayout.verticalAlign = this._verticalAlign == "justify" ? "top" : this._verticalAlign;
            this.verticalLayout.gap = this._gap;
            this.verticalLayout.firstGap = this._firstGap;
            this.verticalLayout.lastGap = this._lastGap;
            this.verticalLayout.paddingTop = this._paddingTop;
            this.verticalLayout.paddingRight = this._paddingRight;
            this.verticalLayout.paddingBottom = this._paddingBottom;
            this.verticalLayout.paddingLeft = this._paddingLeft;
         }
         else
         {
            if(this.verticalLayout)
            {
               this.verticalLayout = null;
            }
            if(!this.horizontalLayout)
            {
               this.horizontalLayout = new HorizontalLayout();
               this.horizontalLayout.useVirtualLayout = false;
            }
            this.horizontalLayout.distributeWidths = this._distributeTabSizes;
            this.horizontalLayout.horizontalAlign = this._horizontalAlign == "justify" ? "left" : this._horizontalAlign;
            this.horizontalLayout.verticalAlign = this._verticalAlign;
            this.horizontalLayout.gap = this._gap;
            this.horizontalLayout.firstGap = this._firstGap;
            this.horizontalLayout.lastGap = this._lastGap;
            this.horizontalLayout.paddingTop = this._paddingTop;
            this.horizontalLayout.paddingRight = this._paddingRight;
            this.horizontalLayout.paddingBottom = this._paddingBottom;
            this.horizontalLayout.paddingLeft = this._paddingLeft;
         }
      }
      
      protected function commitTabData(param1:ToggleButton, param2:Object) : void
      {
         switch(param2)
         {
            case null:
               param1.label = "";
               param1.isEnabled = this._isEnabled;
               break;
            case null:
               if(this._labelField !== null && param2 !== null && this._labelField in param2)
               {
                  param1.label = param2[this._labelField];
               }
               else if(param2 is String)
               {
                  param1.label = param2 as String;
               }
               else
               {
                  param1.label = param2.toString();
               }
               addr56:
               if(this._iconFunction !== null)
               {
                  param1.defaultIcon = this._iconFunction(param2);
               }
               else if(this._iconField !== null && param2 !== null && this._iconField in param2)
               {
                  param1.defaultIcon = param2[this._iconField] as DisplayObject;
               }
               if(this._enabledFunction !== null)
               {
                  param1.isEnabled = this._enabledFunction(param2);
               }
               else if(this._enabledField !== null && param2 !== null && this._enabledField in param2)
               {
                  param1.isEnabled = param2[this._enabledField] as Boolean;
               }
               else
               {
                  param1.isEnabled = this._isEnabled;
               }
               if(this._tabInitializer !== null)
               {
                  this._tabInitializer(param1,param2);
               }
               break;
            default:
               param1.label = this._labelFunction(param2);
               §§goto(addr56);
         }
      }
      
      protected function defaultTabInitializer(param1:ToggleButton, param2:Object) : void
      {
         if(param2 !== null)
         {
            for each(var _loc3_ in DEFAULT_TAB_FIELDS)
            {
               if(param2.hasOwnProperty(_loc3_))
               {
                  param1[_loc3_] = param2[_loc3_];
               }
            }
         }
      }
      
      protected function defaultTabReleaser(param1:ToggleButton, param2:Object) : void
      {
         for each(var _loc3_ in DEFAULT_TAB_FIELDS)
         {
            if(param2.hasOwnProperty(_loc3_))
            {
               param1[_loc3_] = null;
            }
         }
      }
      
      protected function refreshTabs(param1:Boolean) : void
      {
         var _loc5_:int = 0;
         var _loc3_:* = null;
         var _loc4_:* = null;
         var _loc6_:* = 0;
         var _loc10_:Boolean = this._ignoreSelectionChanges;
         this._ignoreSelectionChanges = true;
         var _loc7_:int = this.toggleGroup.selectedIndex;
         this.toggleGroup.removeAllItems();
         var _loc2_:Vector.<ToggleButton> = this.inactiveTabs;
         this.inactiveTabs = this.activeTabs;
         this.activeTabs = _loc2_;
         this.activeTabs.length = 0;
         this._layoutItems.length = 0;
         _loc2_ = null;
         if(param1)
         {
            this.clearInactiveTabs();
         }
         else
         {
            if(this.activeFirstTab)
            {
               this.inactiveTabs.shift();
            }
            this.inactiveFirstTab = this.activeFirstTab;
            if(this.activeLastTab)
            {
               this.inactiveTabs.pop();
            }
            this.inactiveLastTab = this.activeLastTab;
         }
         this.activeFirstTab = null;
         this.activeLastTab = null;
         var _loc9_:int = 0;
         var _loc11_:int;
         var _loc8_:int = (_loc11_ = !!this._dataProvider ? this._dataProvider.length : 0) - 1;
         _loc5_ = 0;
         while(_loc5_ < _loc11_)
         {
            _loc3_ = this._dataProvider.getItemAt(_loc5_);
            if(_loc5_ == 0)
            {
               _loc4_ = this.activeFirstTab = this.createFirstTab(_loc3_);
            }
            else if(_loc5_ == _loc8_)
            {
               _loc4_ = this.activeLastTab = this.createLastTab(_loc3_);
            }
            else
            {
               _loc4_ = this.createTab(_loc3_);
            }
            this.toggleGroup.addItem(_loc4_);
            this.activeTabs[_loc9_] = _loc4_;
            this._layoutItems[_loc9_] = _loc4_;
            _loc9_++;
            _loc5_++;
         }
         this.clearInactiveTabs();
         this._ignoreSelectionChanges = _loc10_;
         if(_loc7_ >= 0)
         {
            _loc6_ = int(this.activeTabs.length - 1);
            if(_loc7_ < _loc6_)
            {
               _loc6_ = _loc7_;
            }
            this._ignoreSelectionChanges = _loc7_ == _loc6_;
            this.toggleGroup.selectedIndex = _loc6_;
            this._ignoreSelectionChanges = _loc10_;
         }
      }
      
      protected function clearInactiveTabs() : void
      {
         var _loc2_:int = 0;
         var _loc1_:* = null;
         var _loc3_:int = this.inactiveTabs.length;
         _loc2_ = 0;
         while(_loc2_ < _loc3_)
         {
            _loc1_ = this.inactiveTabs.shift();
            this.destroyTab(_loc1_);
            _loc2_++;
         }
         if(this.inactiveFirstTab)
         {
            this.destroyTab(this.inactiveFirstTab);
            this.inactiveFirstTab = null;
         }
         if(this.inactiveLastTab)
         {
            this.destroyTab(this.inactiveLastTab);
            this.inactiveLastTab = null;
         }
      }
      
      protected function createFirstTab(param1:Object) : ToggleButton
      {
         var _loc3_:* = null;
         var _loc2_:* = null;
         var _loc4_:Boolean = false;
         if(this.inactiveFirstTab !== null)
         {
            _loc3_ = this.inactiveFirstTab;
            this.releaseTab(_loc3_);
            this.inactiveFirstTab = null;
         }
         else
         {
            _loc4_ = true;
            _loc2_ = this._firstTabFactory != null ? this._firstTabFactory : this._tabFactory;
            _loc3_ = ToggleButton(_loc2_());
            if(this._customFirstTabStyleName)
            {
               _loc3_.styleNameList.add(this._customFirstTabStyleName);
            }
            else if(this._customTabStyleName)
            {
               _loc3_.styleNameList.add(this._customTabStyleName);
            }
            else
            {
               _loc3_.styleNameList.add(this.firstTabStyleName);
            }
            _loc3_.isToggle = true;
            this.addChild(_loc3_);
         }
         this.commitTabData(_loc3_,param1);
         this._tabToItem[_loc3_] = param1;
         if(_loc4_)
         {
            _loc3_.addEventListener("triggered",tab_triggeredHandler);
         }
         return _loc3_;
      }
      
      protected function createLastTab(param1:Object) : ToggleButton
      {
         var _loc3_:* = null;
         var _loc2_:* = null;
         var _loc4_:Boolean = false;
         if(this.inactiveLastTab !== null)
         {
            _loc3_ = this.inactiveLastTab;
            this.releaseTab(_loc3_);
            this.inactiveLastTab = null;
         }
         else
         {
            _loc4_ = true;
            _loc2_ = this._lastTabFactory != null ? this._lastTabFactory : this._tabFactory;
            _loc3_ = ToggleButton(_loc2_());
            if(this._customLastTabStyleName)
            {
               _loc3_.styleNameList.add(this._customLastTabStyleName);
            }
            else if(this._customTabStyleName)
            {
               _loc3_.styleNameList.add(this._customTabStyleName);
            }
            else
            {
               _loc3_.styleNameList.add(this.lastTabStyleName);
            }
            _loc3_.isToggle = true;
            this.addChild(_loc3_);
         }
         this.commitTabData(_loc3_,param1);
         this._tabToItem[_loc3_] = param1;
         if(_loc4_)
         {
            _loc3_.addEventListener("triggered",tab_triggeredHandler);
         }
         return _loc3_;
      }
      
      protected function createTab(param1:Object) : ToggleButton
      {
         var _loc2_:* = null;
         var _loc3_:Boolean = false;
         if(this.inactiveTabs.length === 0)
         {
            _loc3_ = true;
            _loc2_ = ToggleButton(this._tabFactory());
            if(this._customTabStyleName)
            {
               _loc2_.styleNameList.add(this._customTabStyleName);
            }
            else
            {
               _loc2_.styleNameList.add(this.tabStyleName);
            }
            _loc2_.isToggle = true;
            this.addChild(_loc2_);
         }
         else
         {
            _loc2_ = this.inactiveTabs.shift();
            this.releaseTab(_loc2_);
         }
         this.commitTabData(_loc2_,param1);
         this._tabToItem[_loc2_] = param1;
         if(_loc3_)
         {
            _loc2_.addEventListener("triggered",tab_triggeredHandler);
         }
         return _loc2_;
      }
      
      protected function releaseTab(param1:ToggleButton) : void
      {
         var _loc2_:Object = this._tabToItem[param1];
         delete this._tabToItem[param1];
         if(this._labelFunction !== null || this._labelField in _loc2_)
         {
            param1.label = null;
         }
         if(this._iconFunction !== null || this._iconField in _loc2_)
         {
            param1.defaultIcon = null;
         }
         if(this._tabReleaser !== null)
         {
            if(this._tabReleaser.length === 1)
            {
               this._tabReleaser(param1);
            }
            else
            {
               this._tabReleaser(param1,_loc2_);
            }
         }
      }
      
      protected function destroyTab(param1:ToggleButton) : void
      {
         this.toggleGroup.removeItem(param1);
         this.releaseTab(param1);
         this.removeChild(param1,true);
      }
      
      protected function layoutTabs() : void
      {
         this._viewPortBounds.x = 0;
         this._viewPortBounds.y = 0;
         this._viewPortBounds.scrollX = 0;
         this._viewPortBounds.scrollY = 0;
         this._viewPortBounds.explicitWidth = this._explicitWidth;
         this._viewPortBounds.explicitHeight = this._explicitHeight;
         this._viewPortBounds.minWidth = this._explicitMinWidth;
         this._viewPortBounds.minHeight = this._explicitMinHeight;
         this._viewPortBounds.maxWidth = this._explicitMaxWidth;
         this._viewPortBounds.maxHeight = this._explicitMaxHeight;
         if(this.verticalLayout)
         {
            this.verticalLayout.layout(this._layoutItems,this._viewPortBounds,this._layoutResult);
         }
         else if(this.horizontalLayout)
         {
            this.horizontalLayout.layout(this._layoutItems,this._viewPortBounds,this._layoutResult);
         }
         var _loc1_:Number = this._layoutResult.contentWidth;
         var _loc3_:Number = this._layoutResult.contentHeight;
         this.saveMeasurements(_loc1_,_loc3_,_loc1_,_loc3_);
         for each(var _loc2_ in this.activeTabs)
         {
            _loc2_.validate();
         }
         if(this._selectionChangeTween !== null)
         {
            this.setChildIndex(this._selectionSkin,this.numChildren - 1);
            if(this._selectionChangeTween !== null)
            {
               this._selectionChangeTween.advanceTime(this._selectionChangeTween.totalTime);
            }
            if(this._selectedIndex >= 0)
            {
               this._selectionSkin.visible = true;
               _loc2_ = this.activeTabs[this._selectedIndex];
               if(this._animateSelectionChange)
               {
                  this._selectionChangeTween = new Tween(this._selectionSkin,this._selectionChangeDuration,this._selectionChangeEase);
                  if(this._direction === "vertical")
                  {
                     this._selectionChangeTween.animate("y",_loc2_.y);
                     this._selectionChangeTween.animate("height",_loc2_.height);
                  }
                  else
                  {
                     this._selectionChangeTween.animate("x",_loc2_.x);
                     this._selectionChangeTween.animate("width",_loc2_.width);
                  }
                  this._selectionChangeTween.onComplete = selectionChangeTween_onComplete;
                  var _loc6_:* = Starling;
                  (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).add(this._selectionChangeTween);
               }
               else if(this._direction === "vertical")
               {
                  this._selectionSkin.y = _loc2_.y;
                  this._selectionSkin.height = _loc2_.height;
               }
               else
               {
                  this._selectionSkin.x = _loc2_.x;
                  this._selectionSkin.width = _loc2_.width;
               }
            }
            else
            {
               this._selectionSkin.visible = false;
            }
            this._animateSelectionChange = false;
            if(this._selectionSkin is IValidating)
            {
               IValidating(this._selectionSkin).validate();
            }
         }
      }
      
      override public function showFocus() : void
      {
         if(!this._hasFocus)
         {
            return;
         }
         this._showFocus = true;
         this.showFocusedTab();
         this.invalidate("focus");
      }
      
      override public function hideFocus() : void
      {
         if(!this._hasFocus)
         {
            return;
         }
         this._showFocus = false;
         this.hideFocusedTab();
         this.invalidate("focus");
      }
      
      protected function hideFocusedTab() : void
      {
         if(this._focusedTabIndex < 0)
         {
            return;
         }
         var _loc1_:ToggleButton = this.activeTabs[this._focusedTabIndex];
         _loc1_.hideFocus();
      }
      
      protected function showFocusedTab() : void
      {
         if(!this._showFocus || this._focusedTabIndex < 0)
         {
            return;
         }
         var _loc1_:ToggleButton = this.activeTabs[this._focusedTabIndex];
         _loc1_.showFocus();
      }
      
      protected function focusedTabFocusIn() : void
      {
         if(this._focusedTabIndex < 0)
         {
            return;
         }
         var _loc1_:ToggleButton = this.activeTabs[this._focusedTabIndex];
         _loc1_.dispatchEventWith("focusIn");
      }
      
      protected function focusedTabFocusOut() : void
      {
         if(this._focusedTabIndex < 0)
         {
            return;
         }
         var _loc1_:ToggleButton = this.activeTabs[this._focusedTabIndex];
         _loc1_.dispatchEventWith("focusOut");
      }
      
      protected function refreshSelectedItem() : void
      {
         if(this._selectedIndex === -1)
         {
            this._selectedItem = null;
         }
         else
         {
            this._selectedItem = this._dataProvider.getItemAt(this._selectedIndex);
         }
      }
      
      protected function childProperties_onChange(param1:PropertyProxy, param2:String) : void
      {
         this.invalidate("styles");
      }
      
      protected function selectionChangeTween_onComplete() : void
      {
         this._selectionChangeTween = null;
      }
      
      override protected function focusInHandler(param1:Event) : void
      {
         super.focusInHandler(param1);
         this._focusedTabIndex = this._selectedIndex;
         this.focusedTabFocusIn();
         this.stage.addEventListener("keyDown",stage_keyDownHandler);
      }
      
      override protected function focusOutHandler(param1:Event) : void
      {
         super.focusOutHandler(param1);
         this.hideFocusedTab();
         this.focusedTabFocusOut();
         this.stage.removeEventListener("keyDown",stage_keyDownHandler);
      }
      
      protected function stage_keyDownHandler(param1:KeyboardEvent) : void
      {
         if(!this._isEnabled)
         {
            return;
         }
         if(!this._dataProvider || this._dataProvider.length === 0)
         {
            return;
         }
         var _loc3_:* = int(this._focusedTabIndex);
         var _loc2_:int = this._dataProvider.length - 1;
         if(param1.keyCode == 36)
         {
            this.selectedIndex = _loc3_ = int(0);
         }
         else if(param1.keyCode == 35)
         {
            this.selectedIndex = _loc3_ = _loc2_;
         }
         else if(param1.keyCode == 33)
         {
            _loc3_--;
            if(_loc3_ < 0)
            {
               _loc3_ = _loc2_;
            }
            this.selectedIndex = _loc3_;
         }
         else if(param1.keyCode == 34)
         {
            _loc3_++;
            if(_loc3_ > _loc2_)
            {
               _loc3_ = 0;
            }
            this.selectedIndex = _loc3_;
         }
         else if(param1.keyCode === 38 || param1.keyCode === 37)
         {
            _loc3_--;
            if(_loc3_ < 0)
            {
               _loc3_ = _loc2_;
            }
         }
         else if(param1.keyCode === 40 || param1.keyCode === 39)
         {
            _loc3_++;
            if(_loc3_ > _loc2_)
            {
               _loc3_ = 0;
            }
         }
         if(_loc3_ >= 0 && _loc3_ !== this._focusedTabIndex)
         {
            this.hideFocusedTab();
            this.focusedTabFocusOut();
            this._focusedTabIndex = _loc3_;
            this.focusedTabFocusIn();
            this.showFocusedTab();
         }
      }
      
      protected function tab_triggeredHandler(param1:Event) : void
      {
         if(!this._dataProvider || !this.activeTabs)
         {
            return;
         }
         var _loc3_:ToggleButton = ToggleButton(param1.currentTarget);
         var _loc4_:int = this.activeTabs.indexOf(_loc3_);
         var _loc2_:Object = this._dataProvider.getItemAt(_loc4_);
         this.dispatchEventWith("triggered",false,_loc2_);
      }
      
      protected function toggleGroup_changeHandler(param1:Event) : void
      {
         if(this._ignoreSelectionChanges)
         {
            return;
         }
         this.setSelectedIndexWithAnimation(this.toggleGroup.selectedIndex);
      }
      
      protected function dataProvider_addItemHandler(param1:Event, param2:int) : void
      {
         if(this._selectedIndex >= param2)
         {
            this.selectedIndex += 1;
            this.invalidate("selected");
         }
         this.invalidate("data");
      }
      
      protected function dataProvider_removeAllHandler(param1:Event) : void
      {
         this.selectedIndex = -1;
         this.invalidate("data");
      }
      
      protected function dataProvider_removeItemHandler(param1:Event, param2:int) : void
      {
         var _loc4_:int = 0;
         var _loc5_:* = 0;
         var _loc3_:int = 0;
         if(this._selectedIndex > param2)
         {
            this.selectedIndex -= 1;
         }
         else if(this._selectedIndex === param2)
         {
            _loc5_ = _loc4_ = this._selectedIndex;
            _loc3_ = this._dataProvider.length - 1;
            if(_loc5_ > _loc3_)
            {
               _loc5_ = _loc3_;
            }
            if(_loc4_ === _loc5_)
            {
               this.refreshSelectedItem();
               this.invalidate("selected");
               this.dispatchEventWith("change");
            }
            else
            {
               this.selectedIndex = _loc5_;
            }
         }
         this.invalidate("data");
      }
      
      protected function dataProvider_resetHandler(param1:Event) : void
      {
         if(this._dataProvider.length > 0)
         {
            if(this._selectedIndex !== 0)
            {
               this.selectedIndex = 0;
            }
            else
            {
               this.refreshSelectedItem();
               this.invalidate("selected");
               this.dispatchEventWith("change");
            }
         }
         else if(this._selectedIndex >= 0)
         {
            this.selectedIndex = -1;
         }
         this.invalidate("data");
      }
      
      protected function dataProvider_replaceItemHandler(param1:Event, param2:int) : void
      {
         if(this._selectedIndex === param2)
         {
            this.refreshSelectedItem();
            this.invalidate("selected");
            this.dispatchEventWith("change");
         }
         this.invalidate("data");
      }
      
      protected function dataProvider_filterChangeHandler(param1:Event) : void
      {
         var _loc4_:* = 0;
         var _loc2_:int = 0;
         var _loc3_:int = this._dataProvider.getItemIndex(this._selectedItem);
         if(_loc3_ === -1)
         {
            _loc4_ = int(this._selectedIndex);
            _loc2_ = this._dataProvider.length - 1;
            if(_loc4_ > _loc2_)
            {
               _loc4_ = _loc2_;
            }
            if(_loc4_ !== -1)
            {
               this.selectedItem = this._dataProvider.getItemAt(_loc4_);
            }
            else
            {
               this.selectedIndex = -1;
            }
         }
         this.invalidate("data");
      }
      
      protected function dataProvider_updateItemHandler(param1:Event, param2:int) : void
      {
         this.invalidate("data");
      }
      
      protected function dataProvider_updateAllHandler(param1:Event) : void
      {
         this.invalidate("data");
      }
   }
}
