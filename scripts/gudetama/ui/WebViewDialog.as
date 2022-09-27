package gudetama.ui
{
   import flash.events.ErrorEvent;
   import flash.events.LocationChangeEvent;
   import flash.filesystem.File;
   import flash.geom.Rectangle;
   import flash.media.StageWebView;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import gudetama.data.GameSetting;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.Logger;
   import gudetama.engine.RsrcManager;
   import gudetama.engine.SoundManager;
   import muku.display.SimpleImageButton;
   import muku.util.StarlingUtil;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class WebViewDialog extends BaseScene
   {
      
      private static var singleton:WebViewDialog;
       
      
      private var shown:Boolean;
      
      private var callback:Function;
      
      private var webView:StageWebView;
      
      private var displaySprite:Sprite;
      
      private var topImage:Image;
      
      public function WebViewDialog()
      {
         super(1);
         Engine.setupLayout(Engine.assetManager.getObject("WebViewDialogLayout"),function(param1:Object):void
         {
            var layout:Object = param1;
            displaySprite = layout.object;
            topImage = StarlingUtil.find(displaySprite,"topImage") as Image;
            var backButton:SimpleImageButton = StarlingUtil.find(displaySprite,"back") as SimpleImageButton;
            backButton.addEventListener("triggered",function(param1:Event):void
            {
               pageBack();
            });
            var closeButton:SimpleImageButton = StarlingUtil.find(displaySprite,"close") as SimpleImageButton;
            closeButton.addEventListener("triggered",function(param1:Event):void
            {
               close(0);
            });
            addChild(displaySprite);
         },1);
      }
      
      public static function createSingleton() : void
      {
         if(singleton)
         {
            return;
         }
         singleton = new WebViewDialog();
      }
      
      public static function show(param1:String, param2:Function = null) : void
      {
         if(singleton.shown)
         {
            return;
         }
         singleton.setup(param1,param2);
         singleton.addPopup(singleton,singleton.pageBack);
      }
      
      public static function hide() : void
      {
         if(!singleton.shown)
         {
            return;
         }
         singleton.close(0);
      }
      
      public static function showMaintenance(param1:Function = null) : void
      {
         hide();
         var _loc2_:String = RsrcManager.getRsrcLocale(Engine.getLocale());
         show("rsrc/html/maintenance_" + _loc2_ + ".html",param1);
      }
      
      private function close(param1:int) : void
      {
         SoundManager.resumeInApp();
         if(callback)
         {
            callback(param1);
         }
         removePopup(singleton,false);
         callback = null;
         shown = false;
         webView.dispose();
         webView = null;
      }
      
      override public function dispose() : void
      {
         super.dispose();
      }
      
      public function setup(param1:String, param2:Function) : void
      {
         var pathOrUrl:String = param1;
         var _callback:Function = param2;
         callback = _callback;
         if(pathOrUrl.indexOf(":/") < 0)
         {
            var _loc3_:* = Engine;
            if(gudetama.engine.Engine.platform == 1)
            {
               var pathOrUrl:String = "file:///android_asset/" + pathOrUrl;
            }
            else
            {
               pathOrUrl = "file://" + File.applicationDirectory.resolvePath(pathOrUrl).nativePath;
            }
         }
         webView = new StageWebView();
         webView.stage = Engine.stage2D;
         var stageWidth:Number = Engine.stage2D.stageWidth;
         var stageHeight:Number = Engine.stage2D.stageHeight;
         var _loc5_:* = Engine;
         var screenScaleX:Number = stageWidth / gudetama.engine.Engine.designWidth;
         var _loc6_:* = Engine;
         var screenScaleY:Number = stageHeight / gudetama.engine.Engine.designHeight;
         if(screenScaleX > screenScaleY)
         {
            var screenScale:Number = screenScaleY;
            var _loc7_:* = Engine;
            var sceneWidth:Number = gudetama.engine.Engine.designWidth + gudetama.engine.Engine.designWidthMargin * 2;
         }
         else
         {
            screenScale = screenScaleX;
            var _loc8_:* = Engine;
            sceneWidth = gudetama.engine.Engine.designWidth;
         }
         var width:Number = sceneWidth * screenScale;
         var _loc9_:* = Engine;
         var _loc10_:* = Engine;
         webView.viewPort = new Rectangle(Math.max(0,0.5 * (stageWidth - width)),(gudetama.engine.Engine._sceneY + topImage.height) * screenScale,width,(gudetama.engine.Engine.designHeight - 132 - topImage.height) * screenScale);
         webView.loadURL(pathOrUrl);
         shown = true;
         webView.addEventListener("error",function(param1:ErrorEvent):void
         {
            var _loc4_:* = null;
            var _loc3_:* = null;
            var _loc2_:Array = param1.text#2.match("[a-z]*://.*");
            if(_loc2_ && _loc2_.length > 0)
            {
               _loc4_ = _loc2_[0];
               _loc3_ = GameSetting.getOtherText("url.official.app");
               if(_loc4_.indexOf(_loc3_) >= 0)
               {
                  webView.loadURL(_loc4_);
               }
               else
               {
                  navigateToURL(new URLRequest(_loc4_));
                  close(1);
               }
            }
            else
            {
               Logger.error("[WebView] not found path or url:",pathOrUrl + " " + param1.currentTarget + " " + param1.target + " " + param1.text#2);
               close(1);
            }
         });
         webView.addEventListener("locationChanging",function(param1:LocationChangeEvent):void
         {
            param1.preventDefault();
            var _loc2_:String = GameSetting.getOtherText("url.official.app");
            if(param1.location#2.indexOf(_loc2_) >= 0)
            {
               webView.loadURL(param1.location#2);
            }
            else
            {
               navigateToURL(new URLRequest(param1.location#2));
               close(1);
            }
         });
         SoundManager.pauseInApp();
      }
      
      private function pageBack() : void
      {
         if(!webView.isHistoryBackEnabled)
         {
            close(0);
            return;
         }
         webView.historyBack();
      }
   }
}
