package muku.core
{
   import feathers.controls.Alert;
   import feathers.controls.AutoComplete;
   import feathers.controls.Button;
   import feathers.controls.ButtonGroup;
   import feathers.controls.Callout;
   import feathers.controls.Check;
   import feathers.controls.DateTimeSpinner;
   import feathers.controls.Drawers;
   import feathers.controls.GroupedList;
   import feathers.controls.Header;
   import feathers.controls.ImageLoader;
   import feathers.controls.Label;
   import feathers.controls.LayoutGroup;
   import feathers.controls.List;
   import feathers.controls.NumericStepper;
   import feathers.controls.PageIndicator;
   import feathers.controls.Panel;
   import feathers.controls.PanelScreen;
   import feathers.controls.PickerList;
   import feathers.controls.ProgressBar;
   import feathers.controls.Radio;
   import feathers.controls.Screen;
   import feathers.controls.ScreenNavigator;
   import feathers.controls.ScreenNavigatorItem;
   import feathers.controls.ScrollBar;
   import feathers.controls.ScrollContainer;
   import feathers.controls.ScrollScreen;
   import feathers.controls.ScrollText;
   import feathers.controls.Scroller;
   import feathers.controls.SimpleScrollBar;
   import feathers.controls.Slider;
   import feathers.controls.SpinnerList;
   import feathers.controls.StackScreenNavigator;
   import feathers.controls.StackScreenNavigatorItem;
   import feathers.controls.TabBar;
   import feathers.controls.TextArea;
   import feathers.controls.TextInput;
   import feathers.controls.ToggleButton;
   import feathers.controls.ToggleSwitch;
   import feathers.controls.WebView;
   import feathers.layout.FlowLayout;
   import feathers.layout.HorizontalLayout;
   import feathers.layout.TiledColumnsLayout;
   import feathers.layout.TiledRowsLayout;
   import feathers.layout.VerticalLayout;
   import feathers.layout.VerticalSpinnerLayout;
   import feathers.layout.WaterfallLayout;
   import flash.utils.getDefinitionByName;
   import muku.display.CircleGauge;
   import muku.display.CircleImage;
   import muku.display.ContainerButton;
   import muku.display.DisplayTextInput;
   import muku.display.EffectPlayer;
   import muku.display.GeneralGauge;
   import muku.display.ImageButton;
   import muku.display.ManuallySpineButton;
   import muku.display.MaskedImage;
   import muku.display.MoviePlayer;
   import muku.display.MultidirectionalTileScroller;
   import muku.display.PagedScrollContainer;
   import muku.display.Particle;
   import muku.display.ScalableScrollContainer;
   import muku.display.SimpleImageButton;
   import muku.display.SpineModel;
   import muku.display.SpineSkitModel;
   import muku.display.SpineSkitSprite;
   import muku.display.ToggleButton;
   import muku.dnd.DragSourceComponent;
   import muku.dnd.DropTargetComponent;
   import muku.text.CharLocationInfo;
   import muku.text.ColorTextField;
   import muku.text.MaskedTextField;
   import muku.text.PartialBitmapFont;
   import muku.text.TypingTextField;
   import starling.display.Button;
   import starling.display.Image;
   import starling.display.MovieClip;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.display.Sprite3D;
   import starling.errors.AbstractClassError;
   import starling.filters.BlurFilter;
   import starling.filters.DropShadowFilter;
   import starling.filters.GlowFilter;
   import starling.text.TextField;
   import starling.utils.AssetManager;
   import starlingbuilder.engine.IAssetMediator;
   import starlingbuilder.engine.tween.TemplateTweenBuilder;
   import starlingbuilder.engine.tween.TweenTemplate;
   import starlingbuilder.extensions.filters.ColorFilter;
   
   public class MukuGlobal
   {
      
      private static var alreadyCheckedBuilderMode:Boolean = false;
      
      public static var engine:Class;
      
      public static var assetManager:AssetManager;
      
      public static var assetMediator:IAssetMediator;
      
      public static var imageUtil:Class;
      
      public static var tweenAnimator:Class;
      
      public static var soundManager:Class;
      
      public static var logger:Class;
      
      private static var _currentQueue:TaskQueue;
      
      public static const LINKERS:Array = [Image,TextField,starling.display.Button,Quad,List,Sprite,Sprite3D,Alert,AutoComplete,feathers.controls.Button,ButtonGroup,Callout,Check,DateTimeSpinner,Drawers,GroupedList,Header,ImageLoader,Label,LayoutGroup,List,MovieClip,NumericStepper,PageIndicator,Panel,PanelScreen,PickerList,ProgressBar,Radio,Screen,ScreenNavigator,ScreenNavigatorItem,ScrollBar,ScrollContainer,Scroller,ScrollScreen,ScrollText,SimpleScrollBar,Slider,SpinnerList,StackScreenNavigator,StackScreenNavigatorItem,TabBar,TextArea,TextInput,feathers.controls.ToggleButton,ToggleSwitch,WebView,HorizontalLayout,VerticalLayout,FlowLayout,TiledRowsLayout,TiledColumnsLayout,VerticalSpinnerLayout,WaterfallLayout,BlurFilter,GlowFilter,DropShadowFilter,ColorFilter,DragSourceComponent,DropTargetComponent,EaseTransitions,PartialBitmapFont,CharLocationInfo,ColorTextField,TypingTextField,MaskedTextField,TemplateTweenBuilder,TweenTemplate,ImageButton,ContainerButton,ManuallySpineButton,Particle,GeneralGauge,CircleGauge,CircleImage,EffectPlayer,SpineModel,SpineSkitModel,SpineSkitSprite,MoviePlayer,MultidirectionalTileScroller,ScalableScrollContainer,PagedScrollContainer,DisplayTextInput,muku.display.ToggleButton,MaskedImage,SimpleImageButton];
      
      private static var _uitext:Object;
      
      private static const PATH_REGEXP:RegExp = /-/g;
      
      {
         EaseTransitions.setup();
      }
      
      public function MukuGlobal()
      {
         super();
         throw new AbstractClassError();
      }
      
      public static function isBuilderMode() : Boolean
      {
         var _loc3_:* = null;
         var _loc2_:* = null;
         var _loc5_:* = null;
         var _loc6_:* = null;
         var _loc4_:* = null;
         var _loc1_:* = null;
         if(!alreadyCheckedBuilderMode)
         {
            alreadyCheckedBuilderMode = true;
            try
            {
               _loc3_ = getDefinitionByName("gudetama.engine.Engine");
            }
            catch(ex:Error)
            {
               _loc3_ = null;
            }
            if(_loc3_)
            {
               trace("[MukuGlobal]","running with application mode");
               engine = _loc3_ as Class;
               assetManager = engine.assetManager;
               assetMediator = engine.assetMediator;
               _loc2_ = getDefinitionByName("gudetama.util.ImageUtil");
               imageUtil = _loc2_ as Class;
               tweenAnimator = (_loc5_ = getDefinitionByName("gudetama.engine.TweenAnimator")) as Class;
               soundManager = (_loc6_ = getDefinitionByName("gudetama.engine.SoundManager")) as Class;
               logger = (_loc4_ = getDefinitionByName("gudetama.engine.Logger")) as Class;
            }
            else
            {
               trace("[MukuGlobal]","running with starling-builder");
               _loc1_ = getDefinitionByName("starlingbuilder.editor.UIEditorApp");
               assetManager = _loc1_.instance.assetManager;
               assetMediator = _loc1_.instance.documentManager.assetMediator;
            }
         }
         return engine == null;
      }
      
      public static function set uitext(param1:Object) : void
      {
         _uitext = param1;
      }
      
      public static function get uitext() : Object
      {
         return _uitext;
      }
      
      public static function getUIText(param1:String) : String
      {
         return !!_uitext ? _uitext[param1] : null;
      }
      
      public static function makePathFromName(param1:String, param2:String) : String
      {
         var _loc3_:* = null;
         if(param2)
         {
            _loc3_ = "rsrc/" + param1.slice(0,param1.lastIndexOf("-")).replace(PATH_REGEXP,"/") + "/";
            return _loc3_ + param1 + param2;
         }
         return null;
      }
      
      public static function makePathFromVoiceName(param1:int, param2:int) : String
      {
         return "rsrc/voice/" + param2 + ".mp3";
      }
      
      public static function setCurrentQueue(param1:TaskQueue) : void
      {
         _currentQueue = param1;
      }
      
      public static function getTaskQueue() : TaskQueue
      {
         if(_currentQueue)
         {
            if(!_currentQueue.isFinished())
            {
               return _currentQueue;
            }
            _currentQueue = null;
         }
         var _loc1_:* = TaskQueue;
         return §FilePrivateNS:TaskQueue§.ImmediateTaskQueue.SINGLETON;
      }
   }
}
