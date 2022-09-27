package gudetama.common
{
   import com.facebook.graph.FacebookMobile;
   import flash.display.BitmapData;
   import flash.display.PNGEncoderOptions;
   import flash.events.HTTPStatusEvent;
   import flash.events.IOErrorEvent;
   import flash.geom.Rectangle;
   import flash.media.StageWebView;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   import gudetama.data.DataStorage;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.RsrcManager;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.ui.MessageDialog;
   import muku.display.SimpleImageButton;
   import muku.util.StarlingUtil;
   import starling.display.Image;
   import starling.display.Sprite;
   
   public class FacebookManager extends BaseScene
   {
      
      private static var _instance:FacebookManager;
      
      protected static const APP_ID:String = GameSetting.def.rule.facebook_Key;
       
      
      private var frinedcallback:Function;
      
      private var force:Boolean = false;
      
      private var shown:Boolean;
      
      private var callback:Function;
      
      private var webView:StageWebView;
      
      private var displaySprite:Sprite;
      
      private var topImage:Image;
      
      protected var extendedPermissions:Array;
      
      private var myfacebookid:String;
      
      public function FacebookManager()
      {
         extendedPermissions = ["user_friends"];
         super(1);
      }
      
      public static function getInstance() : FacebookManager
      {
         if(!FacebookManager._instance)
         {
            FacebookManager._instance = new FacebookManager();
         }
         return FacebookManager._instance;
      }
      
      public static function load(param1:Function = null, param2:Boolean = false, param3:Function = null) : void
      {
         Engine.showLoading();
         getInstance().frinedcallback = param1;
         getInstance().force = param2;
         getInstance().callback = param3;
         FacebookMobile.init(APP_ID,getInstance().onHandleInit,null);
      }
      
      public static function hide() : void
      {
         if(!getInstance().shown)
         {
            return;
         }
         getInstance().close(0);
      }
      
      public static function isLinked() : Boolean
      {
         var _loc1_:* = UserDataWrapper;
         return gudetama.data.UserDataWrapper.wrapper._data.snsFacebookUid != null;
      }
      
      public static function loadProfileImage(param1:String, param2:Function = null) : void
      {
         var _id:String = param1;
         var _callback:Function = param2;
         if(!_id)
         {
            return;
         }
         if(getInstance() && !getInstance().myfacebookid)
         {
            getInstance().myfacebookid = _id;
         }
         var url:String = "https://graph.facebook.com/" + _id + "/picture";
         var path:String = "facebook/" + _id + ".png";
         checkFaceBookApi(url,function(param1:HTTPStatusEvent):void
         {
            var e:HTTPStatusEvent = param1;
            if(200 <= e.status#2 && e.status#2 < 300 || e.status#2 == 304)
            {
               RsrcManager.loadImageDirectly(url,path,function(param1:BitmapData):void
               {
                  var _loc2_:ByteArray = new ByteArray();
                  param1.encode(param1.rect,new PNGEncoderOptions(),_loc2_);
                  DataStorage.getLocalData().setSnsImageByteArray(1,_loc2_,true,_callback);
               });
            }
         });
      }
      
      private static function checkFaceBookApi(param1:String, param2:Function) : void
      {
         var _loc3_:URLRequest = new URLRequest(param1);
         var _loc4_:URLLoader;
         (_loc4_ = new URLLoader()).addEventListener("ioError",ioErrorHandler);
         _loc4_.addEventListener("httpStatus",param2);
         _loc4_.load(_loc3_);
      }
      
      private static function ioErrorHandler(param1:IOErrorEvent) : void
      {
         trace("ioErrorHandler: " + param1);
      }
      
      public static function unlink(param1:Function = null) : void
      {
         getInstance().callback = param1;
         getInstance().unlinkFunction();
      }
      
      private function initAuthWebViewDialog() : void
      {
         this.visible = false;
         Engine.setupLayout(Engine.assetManager.getObject("WebViewDialogLayout"),function(param1:Object):void
         {
            var layout:Object = param1;
            displaySprite = layout.object;
            topImage = StarlingUtil.find(displaySprite,"topImage") as Image;
            var backButton:SimpleImageButton = StarlingUtil.find(displaySprite,"back") as SimpleImageButton;
            backButton.visible = false;
            var closeButton:SimpleImageButton = StarlingUtil.find(displaySprite,"close") as SimpleImageButton;
            closeButton.addEventListener("triggered",function():void
            {
               close(1);
            });
            webView = new StageWebView();
            var stageWidth:Number = Engine.stage2D.stageWidth;
            var stageHeight:Number = Engine.stage2D.stageHeight;
            var _loc3_:* = Engine;
            var sceneHeight:Number = gudetama.engine.Engine.designHeight;
            var _loc4_:* = Engine;
            var sceneY:Number = gudetama.engine.Engine._sceneY;
            var _loc5_:* = Engine;
            var screenScaleY:Number = stageHeight / gudetama.engine.Engine.designHeight;
            var offsetY:Number = (sceneY + topImage.height) * screenScaleY;
            webView.viewPort = new Rectangle(0,offsetY,stageWidth,sceneHeight * screenScaleY - offsetY);
            webView.addEventListener("error",function():void
            {
               close(1);
            });
            addChild(displaySprite);
            loginUser();
            Engine.addPopUp(getInstance());
         },1);
      }
      
      protected function onHandleInit(param1:Object, param2:Object) : void
      {
         var response:Object = param1;
         var fail:Object = param2;
         if(response)
         {
            var _loc3_:* = UserDataWrapper;
            if(gudetama.data.UserDataWrapper.wrapper._data.snsFacebookUid)
            {
               if(force)
               {
                  if(frinedcallback)
                  {
                     var localfacebookids:Array = DataStorage.getLocalData().getSnsFacebookUids();
                     if(localfacebookids != null && localfacebookids.length > 0)
                     {
                        close(0);
                        frinedcallback(1,localfacebookids);
                     }
                     else
                     {
                        getFrinedsInfo();
                     }
                  }
                  else
                  {
                     close(0);
                  }
               }
               else
               {
                  checkReloadFacebookInfo(function(param1:int):void
                  {
                     if(param1 == 0)
                     {
                        getFrinedsInfo();
                     }
                     else
                     {
                        close(2);
                     }
                  });
               }
            }
            else
            {
               MessageDialog.show(2,GameSetting.getUIText("sns.link.facebook"),function(param1:int):void
               {
                  if(param1 == 0)
                  {
                     updateView(response.uid,response);
                  }
                  else
                  {
                     close(1);
                  }
               });
            }
         }
         else if(force)
         {
            var _loc5_:* = UserDataWrapper;
            if(gudetama.data.UserDataWrapper.wrapper._data.snsFacebookUid)
            {
               localfacebookids = DataStorage.getLocalData().getSnsFacebookUids();
               if(localfacebookids != null && localfacebookids.length > 0)
               {
                  close(0);
                  frinedcallback(1,localfacebookids);
               }
               else
               {
                  webView = new StageWebView();
                  loginUser();
               }
            }
            else
            {
               close(1);
            }
         }
         else
         {
            initAuthWebViewDialog();
         }
      }
      
      protected function updateView(param1:String, param2:*) : void
      {
         var id:String = param1;
         var data:* = param2;
         if(!myfacebookid)
         {
            myfacebookid = id;
            var url:String = "https://graph.facebook.com/" + id + "/picture";
            var path:String = "facebook/" + id + ".png";
            GudetamaUtil.registerSnsId(id,1,url,path,function():void
            {
               if(frinedcallback)
               {
                  getFrinedsInfo();
               }
               else
               {
                  close(0);
               }
            });
         }
      }
      
      protected function loginUser() : void
      {
         FacebookMobile.login(handleLogin,showWebFunction,Engine.stage2D,extendedPermissions,webView);
      }
      
      private function showWebFunction(param1:Boolean) : void
      {
         var _b:Boolean = param1;
         if(!shown)
         {
            Engine.hideLoading();
            MessageDialog.show(2,GameSetting.getUIText("sns.link.facebook"),function(param1:int):void
            {
               if(param1 == 0)
               {
                  shown = true;
                  webView.stage = Engine.stage2D;
                  visible = true;
               }
               else
               {
                  close(1);
               }
            });
         }
      }
      
      protected function handleLogin(param1:Object, param2:Object) : void
      {
         var response:Object = param1;
         var fail:Object = param2;
         if(fail)
         {
            close(1);
         }
         else
         {
            var _loc3_:* = UserDataWrapper;
            if(gudetama.data.UserDataWrapper.wrapper._data.snsFacebookUid)
            {
               if(force)
               {
                  if(frinedcallback)
                  {
                     var ids:Array = DataStorage.getLocalData().getSnsFacebookUids();
                     if(ids != null && ids.length > 0)
                     {
                        close(0);
                        frinedcallback(1,ids);
                     }
                     else
                     {
                        FacebookMobile.api("/me",handleUserInfo);
                     }
                  }
                  else
                  {
                     close(0);
                  }
               }
               else
               {
                  checkReloadFacebookInfo(function(param1:int):void
                  {
                     if(param1 == 0)
                     {
                        FacebookMobile.api("/me",handleUserInfo);
                     }
                     else
                     {
                        close(2);
                     }
                  });
               }
            }
            else if(force)
            {
               close(1);
            }
            else
            {
               FacebookMobile.api("/me",handleUserInfo);
            }
         }
      }
      
      private function checkReloadFacebookInfo(param1:Function) : void
      {
         var _callback:Function = param1;
         MessageDialog.show(2,GameSetting.getUIText("sns.link.facebook.update"),function(param1:int):void
         {
            _callback(param1);
         });
      }
      
      protected function handleUserInfo(param1:Object, param2:Object) : void
      {
         if(param1)
         {
            updateView(param1.id,param1);
         }
      }
      
      protected function getFrinedsInfo() : void
      {
         Engine.showLoading();
         FacebookMobile.api("/me/friends",handFriendsInfo);
      }
      
      protected function handFriendsInfo(param1:Object, param2:Object) : void
      {
         var _loc6_:* = null;
         var _loc4_:* = null;
         var _loc5_:* = null;
         var _loc3_:Array = [];
         for(var _loc7_ in param1)
         {
            _loc4_ = param1[_loc7_];
            if(!_loc6_)
            {
               _loc6_ = {};
            }
            _loc5_ = _loc4_["id"];
            _loc6_[_loc5_] = _loc4_["name"];
            _loc3_.push(_loc5_);
         }
         if(_loc6_)
         {
            DataStorage.getLocalData().setFacebookFriendNameMap(_loc6_);
         }
         if(frinedcallback)
         {
            frinedcallback(1,_loc3_);
         }
         close(0);
      }
      
      private function unlinkFunction() : void
      {
         var _loc1_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(225,1),function(param1:Array):void
         {
            var _loc2_:int = 0;
            if(param1 != null)
            {
               _loc2_ = param1[0];
               var _loc3_:* = UserDataWrapper;
               gudetama.data.UserDataWrapper.wrapper._data.snsFacebookUid = null;
               DataStorage.getLocalData().resetFacebookLink();
               if(_loc2_ == 1)
               {
                  var _loc4_:* = UserDataWrapper;
                  gudetama.data.UserDataWrapper.wrapper._data.snsInterlockType = -1;
               }
               myfacebookid = null;
               close(-1);
            }
         });
      }
      
      private function close(param1:int) : void
      {
         Engine.hideLoading();
         FacebookMobile.clear();
         if(callback)
         {
            callback(1,param1);
         }
         Engine.removePopUp(getInstance(),false);
         callback = null;
         shown = false;
         try
         {
            webView.dispose();
         }
         catch(error:Error)
         {
         }
         webView = null;
      }
      
      override public function dispose() : void
      {
         super.dispose();
      }
   }
}
