package feathers.controls
{
   import feathers.core.FeathersControl;
   import feathers.utils.display.stageToStarling;
   import feathers.utils.geom.matrixToScaleX;
   import feathers.utils.geom.matrixToScaleY;
   import flash.errors.IllegalOperationError;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.getDefinitionByName;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   import starling.events.Event;
   import starling.rendering.Painter;
   import starling.utils.MatrixUtil;
   import starling.utils.Pool;
   
   public class WebView extends FeathersControl
   {
      
      protected static const STAGE_WEB_VIEW_NOT_SUPPORTED_ERROR:String = "Feathers WebView is only supported in Adobe AIR. It cannot be used in Adobe Flash Player.";
      
      protected static const USE_NATIVE_ERROR:String = "The useNative property may only be set before the WebView component validates for the first time.";
      
      protected static const DEFAULT_SIZE:Number = 320;
      
      protected static const DEFAULT_MIN_SIZE:Number = 50;
      
      protected static const STAGE_WEB_VIEW_FULLY_QUALIFIED_CLASS_NAME:String = "flash.media.StageWebView";
      
      protected static var STAGE_WEB_VIEW_CLASS:Class;
       
      
      protected var stageWebView:Object;
      
      protected var _useNative:Boolean = false;
      
      public function WebView()
      {
         super();
         this.addEventListener("addedToStage",webView_addedToStageHandler);
         this.addEventListener("removedFromStage",webView_removedFromStageHandler);
      }
      
      public static function get isSupported() : Boolean
      {
         if(!STAGE_WEB_VIEW_CLASS)
         {
            try
            {
               STAGE_WEB_VIEW_CLASS = Class(getDefinitionByName("flash.media.StageWebView"));
            }
            catch(error:Error)
            {
               return false;
            }
         }
         return STAGE_WEB_VIEW_CLASS.isSupported;
      }
      
      public function get useNative() : Boolean
      {
         return this._useNative;
      }
      
      public function set useNative(param1:Boolean) : void
      {
         if(this.isCreated)
         {
            throw new IllegalOperationError("The useNative property may only be set before the WebView component validates for the first time.");
         }
         this._useNative = param1;
      }
      
      public function get location#2() : String
      {
         if(this.stageWebView)
         {
            return this.stageWebView.location;
         }
         return null;
      }
      
      public function get title() : String
      {
         if(this.stageWebView)
         {
            return this.stageWebView.title;
         }
         return null;
      }
      
      public function get isHistoryBackEnabled() : Boolean
      {
         if(this.stageWebView)
         {
            return this.stageWebView.isHistoryBackEnabled;
         }
         return false;
      }
      
      public function get isHistoryForwardEnabled() : Boolean
      {
         if(this.stageWebView)
         {
            return this.stageWebView.isHistoryForwardEnabled;
         }
         return false;
      }
      
      override public function dispose() : void
      {
         if(this.stageWebView)
         {
            this.stageWebView.stage = null;
            this.stageWebView.dispose();
            this.stageWebView = null;
         }
         super.dispose();
      }
      
      override public function render(param1:Painter) : void
      {
         this.refreshViewPort();
         super.render(param1);
      }
      
      public function loadURL(param1:String) : void
      {
         this.validate();
         this.stageWebView.loadURL(param1);
      }
      
      public function loadString(param1:String, param2:String = "text/html") : void
      {
         this.validate();
         this.stageWebView.loadString(param1,param2);
      }
      
      public function stop() : void
      {
         this.validate();
         this.stageWebView.stop();
      }
      
      public function reload() : void
      {
         this.validate();
         this.stageWebView.reload();
      }
      
      public function historyBack() : void
      {
         this.validate();
         this.stageWebView.historyBack();
      }
      
      public function historyForward() : void
      {
         this.validate();
         this.stageWebView.historyForward();
      }
      
      override protected function initialize() : void
      {
         this.createStageWebView();
      }
      
      override protected function draw() : void
      {
         var _loc2_:Boolean = this.isInvalid("data");
         var _loc1_:Boolean = this.isInvalid("size");
         _loc1_ = this.autoSizeIfNeeded() || _loc1_;
         if(_loc1_)
         {
            this.refreshViewPort();
         }
      }
      
      protected function autoSizeIfNeeded() : Boolean
      {
         var _loc3_:* = this._explicitWidth !== this._explicitWidth;
         var _loc7_:* = this._explicitHeight !== this._explicitHeight;
         var _loc4_:* = this._explicitMinWidth !== this._explicitMinWidth;
         var _loc8_:* = this._explicitMinHeight !== this._explicitMinHeight;
         if(!_loc3_ && !_loc7_ && !_loc4_ && !_loc8_)
         {
            return false;
         }
         var _loc2_:Number = this._explicitWidth;
         if(_loc3_)
         {
            _loc2_ = 320;
         }
         var _loc5_:Number = this._explicitWidth;
         if(_loc7_)
         {
            _loc5_ = 320;
         }
         var _loc1_:* = Number(this._explicitMinWidth);
         if(_loc4_)
         {
            _loc1_ = 50;
         }
         var _loc6_:* = Number(this._explicitMinHeight);
         if(_loc8_)
         {
            _loc6_ = 50;
         }
         return this.saveMeasurements(_loc2_,_loc5_,_loc1_,_loc6_);
      }
      
      protected function createStageWebView() : void
      {
         if(isSupported)
         {
            this.stageWebView = new STAGE_WEB_VIEW_CLASS(this._useNative);
            this.stageWebView.addEventListener("error",stageWebView_errorHandler);
            this.stageWebView.addEventListener("locationChange",stageWebView_locationChangeHandler);
            this.stageWebView.addEventListener("locationChanging",stageWebView_locationChangingHandler);
            this.stageWebView.addEventListener("complete",stageWebView_completeHandler);
            return;
         }
         throw new IllegalOperationError("Feathers WebView is only supported in Adobe AIR. It cannot be used in Adobe Flash Player.");
      }
      
      protected function refreshViewPort() : void
      {
         var _loc12_:*;
         var _loc2_:Starling = this.stage !== null ? this.stage.starling : (_loc12_ = Starling, starling.core.Starling.sCurrent);
         var _loc4_:Rectangle = _loc2_.viewPort;
         var _loc1_:Rectangle = this.stageWebView.viewPort;
         if(!_loc1_)
         {
            _loc1_ = new Rectangle();
         }
         var _loc10_:Point = Pool.getPoint();
         var _loc9_:Matrix = Pool.getMatrix();
         this.getTransformationMatrix(this.stage,_loc9_);
         var _loc3_:Number = matrixToScaleX(_loc9_);
         var _loc5_:Number = matrixToScaleY(_loc9_);
         MatrixUtil.transformCoords(_loc9_,0,0,_loc10_);
         var _loc8_:* = 1;
         if(_loc2_.supportHighResolutions)
         {
            _loc8_ = Number(_loc2_.nativeStage.contentsScaleFactor);
         }
         var _loc6_:Number = _loc2_.contentScaleFactor / _loc8_;
         _loc1_.x = Math.round(_loc4_.x + _loc10_.x * _loc6_);
         _loc1_.y = Math.round(_loc4_.y + _loc10_.y * _loc6_);
         var _loc7_:*;
         if((_loc7_ = Number(Math.round(this.actualWidth * _loc6_ * _loc3_))) < 1 || _loc7_ !== _loc7_)
         {
            _loc7_ = 1;
         }
         var _loc11_:*;
         if((_loc11_ = Number(Math.round(this.actualHeight * _loc6_ * _loc5_))) < 1 || _loc11_ !== _loc11_)
         {
            _loc11_ = 1;
         }
         _loc1_.width = _loc7_;
         _loc1_.height = _loc11_;
         this.stageWebView.viewPort = _loc1_;
         Pool.putPoint(_loc10_);
         Pool.putMatrix(_loc9_);
      }
      
      protected function webView_addedToStageHandler(param1:starling.events.Event) : void
      {
         var _loc2_:Starling = stageToStarling(this.stage);
         this.stageWebView.stage = _loc2_.nativeStage;
         this.addEventListener("enterFrame",webView_enterFrameHandler);
      }
      
      protected function webView_removedFromStageHandler(param1:starling.events.Event) : void
      {
         if(this.stageWebView)
         {
            this.stageWebView.stage = null;
         }
         this.removeEventListener("enterFrame",webView_enterFrameHandler);
      }
      
      protected function webView_enterFrameHandler(param1:starling.events.Event) : void
      {
         var _loc3_:DisplayObject = this;
         while(_loc3_.visible)
         {
            _loc3_ = _loc3_.parent;
            if(!_loc3_)
            {
               var _loc2_:Starling = stageToStarling(this.stage);
               this.stageWebView.stage = _loc2_.nativeStage;
               return;
            }
         }
         this.stageWebView.stage = null;
      }
      
      protected function stageWebView_errorHandler(param1:ErrorEvent) : void
      {
         this.dispatchEventWith("error",false,param1);
      }
      
      protected function stageWebView_locationChangeHandler(param1:flash.events.Event) : void
      {
         this.dispatchEventWith("locationChange");
      }
      
      protected function stageWebView_locationChangingHandler(param1:flash.events.Event) : void
      {
         this.dispatchEventWith("locationChanging",false,param1);
      }
      
      protected function stageWebView_completeHandler(param1:flash.events.Event) : void
      {
         this.dispatchEventWith("complete");
      }
   }
}
