package gudetama.engine
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.OutputProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.filesystem.File;
   import flash.filesystem.FileStream;
   import flash.geom.Point;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.utils.ByteArray;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.FileInfoDef;
   import gudetama.net.HttpConnector;
   import gudetama.ui.MessageDialog;
   import gudetama.util.StringUtil;
   import muku.text.PartialBitmapFont;
   import muku.util.ObjectUtil;
   import starling.core.Starling;
   import starling.text.BitmapFont;
   import starling.textures.Texture;
   
   public class RsrcManager
   {
      
      private static const singleton:RsrcManager = new RsrcManager();
      
      public static const FORCE_DELAY_TIME:Number = 0;
      
      public static const MAX_RETRY_COUNT:int = 3;
      
      private static var POINT_ZERO:Point = new Point(0,0);
      
      public static var applicationStandUpDone:Boolean;
       
      
      private var contextMap:Object;
      
      private var fileCheckMap:Object;
      
      private var _loadingCount:int;
      
      private var preloadMode:Boolean;
      
      private var _arfsLoadCount:int;
      
      public var arfs:ArfsGroup;
      
      private const PACKAGE_RSRC_REPLACEABLE:Boolean = true;
      
      public function RsrcManager()
      {
         contextMap = {};
         super();
      }
      
      public static function getInstance() : RsrcManager
      {
         return singleton;
      }
      
      public static function clearCache() : void
      {
         var _loc1_:Object = singleton.contextMap;
         for(var _loc2_ in _loc1_)
         {
            (_loc1_[_loc2_] as RsrcLoadContext).dispose();
            delete _loc1_[_loc2_];
         }
         singleton.contextMap = {};
      }
      
      public static function getTraceString() : String
      {
         var _loc1_:String = "RsrcManager loading:" + singleton._loadingCount + ", arfsLoading:" + singleton._arfsLoadCount;
         var _loc3_:Object = singleton.contextMap;
         for each(var _loc2_ in _loc3_)
         {
            if(_loc2_)
            {
               if(_loc2_.loader)
               {
               }
               _loc1_ += "[" + _loc2_.getTraceString() + "], ";
            }
         }
         return _loc1_;
      }
      
      public static function clearFileCache() : void
      {
         var directory:File = RsrcManager.getInstance().getCacheDirectory();
         if(directory.exists)
         {
            directory.deleteDirectory(true);
         }
         if(singleton.arfs && singleton.arfs.isAvailable)
         {
            var tempArfs:ArfsGroup = singleton.arfs;
            singleton.arfs = null;
            tempArfs.clearCache(function():void
            {
               tempArfs.openAsync();
               singleton.arfs = tempArfs;
            });
         }
      }
      
      private static function getResourceFilePath(param1:String, param2:Function) : void
      {
         var _loc3_:File = RsrcManager.getInstance().getCacheDirectory().resolvePath(param1);
         var _loc4_:File = File.applicationDirectory.resolvePath(param1);
         if(_loc3_.exists)
         {
            param2(_loc3_.nativePath);
         }
         else if(_loc4_.exists)
         {
            param2(param1);
         }
         else
         {
            RsrcManager.getInstance().download(param1,param2);
         }
      }
      
      public static function loadDialogPicture(param1:String, param2:Function) : void
      {
         singleton._loadBitmapData("rsrc/dialog/" + param1 + ".png",param2);
      }
      
      public static function loadImageDirectly(param1:String, param2:String, param3:Function) : void
      {
         singleton._loadBitmapDataDirectly(param1,"rsrc/tmp/" + param2,param3);
      }
      
      public static function getURL(param1:RsrcLoadContext) : String
      {
         var _loc4_:* = null;
         var _loc3_:* = false;
         var _loc2_:String = param1.path;
         if(param1.loadFrom != 1 && param1.loadFrom != 0)
         {
            _loc4_ = Engine.getLocale();
            if(param1.type != 5)
            {
               _loc4_ = getRsrcLocale(_loc4_);
            }
            if(_loc4_ && _loc4_ != "ja" && param1.needRenameRsrc)
            {
               _loc2_ = _loc2_.replace("rsrc","rsrc_" + _loc4_);
            }
         }
         if(param1.loadFrom == 0)
         {
            return _loc2_;
         }
         if(param1.loadFrom == 1)
         {
            return RsrcManager.getInstance().getCacheDirectory().resolvePath(_loc2_).url#2;
         }
         if(param1.loadFrom == 3)
         {
            var _loc5_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            return gudetama.net.HttpConnector.mainConnector.getServletResourceUrl(_loc2_);
         }
         if(_loc2_.indexOf("://") > 0)
         {
            return _loc2_;
         }
         _loc3_ = param1.retryCount >= 3 - 1;
         return ApplicationSettings.getResourceUrl(_loc2_,_loc3_);
      }
      
      public static function getRsrcLocale(param1:String) : String
      {
         switch(param1)
         {
            case "ja":
            case "ko":
            case "cn":
               break;
            case "tw":
               break;
            default:
               return "en";
         }
         return param1;
      }
      
      public function setupFileCheckMap(param1:Array) : void
      {
         fileCheckMap = null;
         if(param1)
         {
            fileCheckMap = {};
            for each(var _loc2_ in param1)
            {
               fileCheckMap[_loc2_.path] = _loc2_;
            }
         }
      }
      
      public function getCacheDirectory() : File
      {
         var _loc1_:* = Engine;
         if(gudetama.engine.Engine.platform == 0)
         {
            return File.cacheDirectory.resolvePath("gudetama");
         }
         return File.applicationStorageDirectory.resolvePath("gudetama");
      }
      
      public function getCacheFile(param1:String) : File
      {
         return getCacheDirectory().resolvePath(param1);
      }
      
      public function checkLoadingCount() : Boolean
      {
         var _loc2_:int = 0;
         for each(var _loc1_ in contextMap)
         {
            if(_loc1_)
            {
               if(_loc1_.loader)
               {
                  _loc2_++;
               }
            }
         }
         if(_loc2_ == _loadingCount)
         {
            return true;
         }
         _loadingCount = _loc2_;
         return false;
      }
      
      public function getLoadingCount() : int
      {
         return _loadingCount;
      }
      
      public function isLoading() : Boolean
      {
         return _loadingCount > 0;
      }
      
      public function setPreloadMode(param1:Boolean) : void
      {
         preloadMode = param1;
      }
      
      private function isCorrectPngData(param1:ByteArray, param2:String, param3:Boolean = false) : Boolean
      {
         if(param3)
         {
            return true;
         }
         param1.position = 0;
         if(!StringUtil.endsWith(param2,".png"))
         {
            return true;
         }
         if(param1.readUnsignedByte() != 137)
         {
            return false;
         }
         if(param1.readUnsignedByte() != 80)
         {
            return false;
         }
         if(param1.readUnsignedByte() != 78)
         {
            return false;
         }
         if(param1.readUnsignedByte() != 71)
         {
            return false;
         }
         if(param1.readUnsignedByte() != 13)
         {
            return false;
         }
         if(param1.readUnsignedByte() != 10)
         {
            return false;
         }
         if(param1.readUnsignedByte() != 26)
         {
            return false;
         }
         if(param1.readUnsignedByte() != 10)
         {
            return false;
         }
         param1.position = 0;
         return true;
      }
      
      private function convertToBitmapData(param1:ByteArray, param2:String, param3:Function) : void
      {
         var buff:ByteArray = param1;
         var path:String = param2;
         var callback:Function = param3;
         var loaderContext:LoaderContext = new LoaderContext();
         loaderContext.imageDecodingPolicy = "onDemand";
         loaderContext.allowCodeImport = true;
         var _loader:Loader = new Loader();
         _loader.contentLoaderInfo.addEventListener("init",function(param1:Event):void
         {
            var _loc2_:BitmapData = new BitmapData(_loader.width,_loader.height,true,0);
            _loc2_.draw(_loader);
            callback(_loc2_);
         });
         _loader.contentLoaderInfo.addEventListener("ioError",function(param1:IOErrorEvent):void
         {
            Logger.error("convertToBitmapData IOErrorEvent.IO_ERROR path={}, e={}",path,param1);
            _loadBitmapData(path,callback);
         });
         _loader.loadBytes(buff,loaderContext);
      }
      
      private function loadBytesFromArfs(param1:*, param2:Function) : void
      {
         var path:* = param1;
         var callback:Function = param2;
         if(!hasValidationInfo(path))
         {
            if(File.applicationDirectory.resolvePath(path).exists)
            {
               callback(null);
               return;
            }
         }
         if(arfs && arfs.canHandle(path))
         {
            _arfsLoadCount++;
            arfs.load(path,new ByteArray(),function(param1:ByteArray):void
            {
               _arfsLoadCount--;
               if(param1)
               {
                  try
                  {
                     validateFile(path,param1);
                     callback(param1);
                     return;
                  }
                  catch(e:Error)
                  {
                     Logger.warn("validatation error in arfs. error={} path={}",e,path);
                     try
                     {
                        arfs.unlink(path);
                     }
                     catch(e:Error)
                     {
                     }
                  }
               }
               callback(null);
            });
         }
         else
         {
            callback(null);
         }
      }
      
      public function loadBitmapData(param1:String, param2:Function) : void
      {
         var path:String = param1;
         var _callback:Function = param2;
         var callback:Function = completeLoad(_callback);
         loadBytesFromArfs(path,function(param1:ByteArray):void
         {
            if(param1 && isCorrectPngData(param1,path))
            {
               convertToBitmapData(param1,path,callback);
               trace("arfs hit bitmap: " + path);
            }
            else
            {
               _loadBitmapData(path,callback);
            }
         });
      }
      
      public function loadByteArray(param1:String, param2:Function) : void
      {
         var path:String = param1;
         var _callback:Function = param2;
         var callback:Function = completeLoad(_callback);
         loadBytesFromArfs(path,function(param1:ByteArray):void
         {
            if(param1)
            {
               param1.position = 0;
               callback(param1);
               trace("arfs ByteArray: " + path);
            }
            else
            {
               _loadByteArray(path,callback);
            }
         });
      }
      
      public function loadBitmapFont(param1:String, param2:Function) : void
      {
         var path:String = param1;
         var callback:Function = param2;
         loadByteArray("rsrc/png/" + path,function(param1:ByteArray):void
         {
            var fontBytes:ByteArray = param1;
            var fontXml:XML = XML(fontBytes);
            var atlasPath:String = path.replace(".xml","");
            var loadBitmapFunc:Function = function(param1:Texture):void
            {
               callback(new BitmapFont(param1,fontXml));
            };
            TextureCollector.loadTexture(atlasPath,loadBitmapFunc);
         });
      }
      
      public function loadTextureAtlas(param1:String, param2:Function) : void
      {
         var path:String = param1;
         var _callback:Function = param2;
         var callback:Function = completeLoad2(_callback);
         loadByteArray(path,function(param1:ByteArray):void
         {
            var atlasBytes:ByteArray = param1;
            var atlasXml:XML = XML(atlasBytes);
            var atlasPath:String = null;
            if(path.lastIndexOf(".xml") != -1)
            {
               atlasPath = path.replace(".xml",".png");
            }
            else if(path.lastIndexOf(".atlas") != -1)
            {
               atlasPath = path.replace(".atlas",".png");
            }
            var loadBitmapFunc:Function = function(param1:BitmapData):void
            {
               callback(atlasXml,param1);
            };
            if(atlasPath.lastIndexOf(".png") != -1)
            {
               loadBytesFromArfs(atlasPath,function(param1:ByteArray):void
               {
                  var _loc3_:* = null;
                  var _loc2_:* = null;
                  if(param1 && isCorrectPngData(param1,path))
                  {
                     convertToBitmapData(param1,path,loadBitmapFunc);
                     trace("arfs hit bitmap0: " + path);
                  }
                  else
                  {
                     _loc3_ = loadBitmapFunc;
                     if(checkCache(atlasPath,_loc3_))
                     {
                        return;
                     }
                     _loc2_ = registerLoadContext(atlasPath,0,false);
                     _loc2_.addCallback(_loc3_);
                     startLoad(_loc2_);
                  }
               });
               return;
            }
            var complete:Function = loadBitmapFunc;
            if(checkCache(atlasPath,complete))
            {
               return;
            }
            var atlasContext:RsrcLoadContext = registerLoadContext(atlasPath,0,false);
            atlasContext.addCallback(complete);
            startLoad(atlasContext);
         });
      }
      
      public function loadTextureAtlasXml(param1:String, param2:Function) : void
      {
         var _name:String = param1;
         var _callback:Function = param2;
         var atlasName:String = TextureCollector.getAtlasName(_name);
         var path:String = "rsrc/atlas/" + atlasName + ".xml";
         loadByteArray(path,function(param1:ByteArray):void
         {
            var _loc2_:XML = XML(param1);
            _callback(_loc2_);
         });
      }
      
      public function loadParticle(param1:String, param2:Function) : void
      {
         var path:String = param1;
         var callback:Function = param2;
         loadByteArray("rsrc/particle/" + path,function(param1:ByteArray):void
         {
            var bytes:ByteArray = param1;
            var getTextureName:* = function(param1:XMLList):String
            {
               return StringUtil.clean(param1.attribute("name")).replace(".png","");
            };
            var configXml:XML = XML(bytes);
            var loadBitmapFunc:Function = function(param1:Texture):void
            {
               callback(configXml,param1);
            };
            TextureCollector.loadTexture(getTextureName(configXml.texture),loadBitmapFunc);
         });
      }
      
      public function loadLayoutData(param1:String, param2:Function) : void
      {
         var path:String = param1;
         var _callback:Function = param2;
         var callback:Function = completeLoad(_callback);
         loadBytesFromArfs(path,function(param1:ByteArray):void
         {
            if(param1)
            {
               callback(JSON.parse(param1.toString()));
            }
            else
            {
               _loadLayoutData(path,callback);
            }
         });
      }
      
      public function loadLocalGameSetting(param1:Function, param2:Boolean = false) : void
      {
         var _loc5_:* = null;
         var _loc6_:* = null;
         var _loc4_:* = null;
         var _loc3_:String = getLocalSettingDatPath();
         if(!param2 && getCacheDirectory().resolvePath(_loc3_).exists)
         {
            (_loc5_ = registerLoadContext(_loc3_,1)).loadFrom = 1;
         }
         else
         {
            _loc6_ = Engine.getLocale();
            _loc4_ = "rsrc/setting/0." + (_loc6_ == "ja" ? "dat" : _loc6_ + ".dat");
            (_loc5_ = registerLoadContext(_loc4_,1)).loadFrom = 0;
         }
         _loc5_.addCallback(param1);
         startLoad(_loc5_);
      }
      
      public function downloadGameSetting(param1:int, param2:Boolean, param3:Function) : void
      {
         var version:int = param1;
         var silent:Boolean = param2;
         var callback:Function = param3;
         var locale:String = Engine.getLocale();
         if(locale == "ja")
         {
            locale = "";
         }
         else
         {
            var locale:String = locale + ".";
         }
         var downloadPath:String = "setting/setting.dat." + locale + version + "." + 34;
         Logger.debug("downloadGameSetting {}",downloadPath);
         var context:RsrcLoadContext = registerLoadContext(downloadPath,1);
         context.loadFrom = 3;
         context.noCache = true;
         context.neverCancel = true;
         context.silent = silent;
         context.addCallbackExt(function(param1:RsrcLoadContext):Boolean
         {
            var context:RsrcLoadContext = param1;
            var bytes:ByteArray = context.loader is Loader ? context.loader.contentLoaderInfo.bytes : context.loader.data;
            GameSetting.checkAndUncompress(bytes);
            createCacheFile(context.loader,getLocalSettingDatPath(),function(param1:Boolean):void
            {
               if(!param1)
               {
                  Logger.warn("downloadGameSetting createCacheFile failed");
               }
               try
               {
                  callback(context.content);
               }
               catch(e:Error)
               {
                  Logger.error("downloadGameSetting callback failed",e);
                  showDownloadErrorMessage(context);
               }
            });
            return false;
         });
         startLoad(context);
      }
      
      public function clearGameSettingCache() : void
      {
         var _loc1_:File = getCacheDirectory().resolvePath(getLocalSettingDatPath());
         if(_loc1_.exists)
         {
            _loc1_.deleteFile();
         }
      }
      
      private function getLocalSettingDatPath() : String
      {
         var _loc1_:String = Engine.getLocale();
         if(_loc1_ == "ja")
         {
            return "setting/setting.dat.34";
         }
         return "setting/setting_" + _loc1_ + ".dat." + 34;
      }
      
      public function cancelLoading() : void
      {
         var _loc2_:* = null;
         if(GameSetting.hasScreeningFlag(3))
         {
            return;
         }
         for(var _loc1_ in contextMap)
         {
            _loc2_ = contextMap[_loc1_];
            if(_loc2_.loader != null && !_loc2_.neverCancel)
            {
               Logger.info("cancel loading",_loc2_.getTraceString());
               _loc2_.canceled = true;
               try
               {
                  _loc2_.loader.close();
               }
               catch(e:Error)
               {
               }
               delete contextMap[_loc1_];
            }
         }
         _loadingCount = 0;
      }
      
      private function checkCache(param1:String, param2:Function) : Boolean
      {
         var _loc4_:* = null;
         if(!(param1 in contextMap))
         {
            return false;
         }
         var _loc3_:RsrcLoadContext = contextMap[param1];
         if(_loc3_.content != null)
         {
            if((_loc4_ = _loc3_.content) is ByteArray)
            {
               (_loc4_ as ByteArray).position = 0;
            }
            param2(_loc3_.content);
            return true;
         }
         _loc3_.addCallback(param2);
         return true;
      }
      
      private function checkCacheExt(param1:String, param2:Function) : Boolean
      {
         if(!(param1 in contextMap))
         {
            return false;
         }
         var _loc3_:RsrcLoadContext = contextMap[param1];
         if(_loc3_.content != null)
         {
            if(!_loc3_.contentExt)
            {
               _loc3_.contentExt = [];
            }
            param2(_loc3_);
            return true;
         }
         _loc3_.addCallbackExt(param2);
         return true;
      }
      
      private function startLoad(param1:RsrcLoadContext, param2:Function = null) : void
      {
         var context:RsrcLoadContext = param1;
         var _callback:Function = param2;
         if(context.loadFrom == 0)
         {
            var fileInfo:Object = fileCheckMap != null ? fileCheckMap[context.path] : null;
            if(fileInfo != null)
            {
               context.needRenameRsrc = fileInfo.hasLocale;
               context.loadFrom = 1;
            }
            else if(!File.applicationDirectory.resolvePath(context.path).exists)
            {
               context.loadFrom = 1;
            }
         }
         if(context.loadFrom == 1)
         {
            if(!getCacheDirectory().resolvePath(context.path).exists)
            {
               context.loadFrom = 2;
            }
         }
         if(!applicationStandUpDone)
         {
            if(context.loadFrom != 0 && context.loadFrom != 3 && context.type != 5)
            {
               Logger.warn("not applicationStandUpDone",context.path);
            }
         }
         var needsURLLoader:Boolean = false;
         if(context.type == 1 || context.type == 3 || context.type == 4 || context.type == 5)
         {
            needsURLLoader = true;
         }
         else if(context.loadFrom == 2 || context.loadFrom == 3)
         {
            needsURLLoader = true;
         }
         else if(context.loadFrom != 0)
         {
            needsURLLoader = true;
         }
         needsURLLoader = true;
         if(needsURLLoader)
         {
            var loader:* = new URLLoader();
            var urlLoadIoErrorFunc:Function = function(param1:IOErrorEvent):void
            {
               param1.target.removeEventListener("complete",urlLoadCompletedFunc);
               param1.target.removeEventListener("ioError",urlLoadIoErrorFunc);
               param1.target.removeEventListener("securityError",urlLoadSecurityErrorFunc);
               if(loadErrorOccurred(param1,context,_callback))
               {
                  if(_callback)
                  {
                     _callback();
                  }
               }
            };
            var urlLoadSecurityErrorFunc:Function = function(param1:SecurityErrorEvent):void
            {
               param1.target.removeEventListener("complete",urlLoadCompletedFunc);
               param1.target.removeEventListener("ioError",urlLoadIoErrorFunc);
               param1.target.removeEventListener("securityError",urlLoadSecurityErrorFunc);
               loadSecurityErrorOccurred(param1,context);
            };
            var urlLoadCompletedFunc:Function = function(param1:Event):void
            {
               var event:Event = param1;
               event.target.removeEventListener("complete",urlLoadCompletedFunc);
               event.target.removeEventListener("ioError",urlLoadIoErrorFunc);
               event.target.removeEventListener("securityError",urlLoadSecurityErrorFunc);
               Engine.addSequentialCallback(function():void
               {
                  loadCompleted(event,context);
               });
            };
            loader.addEventListener("complete",urlLoadCompletedFunc);
            loader.addEventListener("ioError",urlLoadIoErrorFunc);
            loader.addEventListener("securityError",urlLoadSecurityErrorFunc);
            loader.dataFormat = "binary";
            loader.load(new URLRequest(!!context.directly ? context.directlyPath : getURL(context)));
         }
         else
         {
            loader = new Loader();
            var loadIoErrorFunc:Function = function(param1:IOErrorEvent):void
            {
               param1.target.removeEventListener("complete",loadCompletedFunc);
               param1.target.removeEventListener("ioError",loadIoErrorFunc);
               if(loadErrorOccurred(param1,context,_callback))
               {
                  if(_callback)
                  {
                     _callback();
                  }
               }
            };
            var loadCompletedFunc:Function = function(param1:Event):void
            {
               var event:Event = param1;
               event.target.removeEventListener("complete",loadCompletedFunc);
               event.target.removeEventListener("ioError",loadIoErrorFunc);
               Engine.addSequentialCallback(function():void
               {
                  loadCompleted(event,context);
               });
            };
            loader.contentLoaderInfo.addEventListener("complete",loadCompletedFunc);
            loader.contentLoaderInfo.addEventListener("ioError",loadIoErrorFunc);
            var loaderContext:LoaderContext = new LoaderContext(false,ApplicationDomain.currentDomain,null);
            loader.load(new URLRequest(!!context.directly ? context.directlyPath : getURL(context)),loaderContext);
         }
         context.loader = loader;
      }
      
      private function registerLoadContext(param1:String, param2:int, param3:Boolean = true) : RsrcLoadContext
      {
         var _loc4_:RsrcLoadContext = new RsrcLoadContext(param1,param2);
         if(param3)
         {
            contextMap[param1] = _loc4_;
         }
         return _loc4_;
      }
      
      private function _loadBitmapData(param1:String, param2:Function) : void
      {
         var path:String = param1;
         var callback:Function = param2;
         var complete:Function = completeLoad(callback);
         if(checkCache(path,complete))
         {
            return;
         }
         var context:RsrcLoadContext = registerLoadContext(path,0,false);
         context.addCallback(complete);
         startLoad(context,function():void
         {
            complete(null);
         });
      }
      
      private function _loadBitmapDataDirectly(param1:String, param2:String, param3:Function) : void
      {
         if(checkCache(param2,param3))
         {
            return;
         }
         var _loc4_:RsrcLoadContext;
         (_loc4_ = registerLoadContext(param2,0,false)).directly = true;
         _loc4_.directlyPath = param1;
         _loc4_.neverCancel = true;
         _loc4_.addCallback(param3);
         startLoad(_loc4_);
      }
      
      private function _loadLayoutData(param1:String, param2:Function) : void
      {
         var path:String = param1;
         var complete:Function = param2;
         if(checkCache(path,complete))
         {
            return;
         }
         var context:RsrcLoadContext = registerLoadContext(path,4);
         context.addCallback(complete);
         startLoad(context,function():void
         {
            complete(null);
         });
      }
      
      private function _loadByteArray(param1:String, param2:Function) : void
      {
         var path:String = param1;
         var complete:Function = param2;
         if(checkCache(path,complete))
         {
            return;
         }
         var context:RsrcLoadContext = registerLoadContext(path,1);
         context.addCallback(complete);
         startLoad(context,function():void
         {
            complete(null);
         });
      }
      
      public function download(param1:String, param2:Function) : void
      {
         var path:String = param1;
         var callback:Function = param2;
         var complete:Function = callback;
         var context:RsrcLoadContext = registerLoadContext(path,3);
         context.addCallback(complete);
         startLoad(context,function():void
         {
            complete(null);
         });
      }
      
      private function completeLoad(param1:Function) : Function
      {
         var callback:Function = param1;
         _loadingCount++;
         return function():*
         {
            var complete:Function;
            return complete = function(param1:*):void
            {
               _loadingCount--;
               callback(param1);
            };
         }();
      }
      
      private function completeLoad2(param1:Function) : Function
      {
         var callback:Function = param1;
         _loadingCount++;
         return function():*
         {
            var complete:Function;
            return complete = function(param1:*, param2:*):void
            {
               _loadingCount--;
               callback(param1,param2);
            };
         }();
      }
      
      private function createCacheFile(param1:*, param2:String, param3:Function) : void
      {
         var loader:* = param1;
         var cachePath:String = param2;
         var callback:Function = param3;
         var onProgress:* = function(param1:OutputProgressEvent):void
         {
            Engine.traceLog("createCacheFile onProgress pending",param1,cachePath,param1.bytesPending);
         };
         var onClosed:* = function(param1:Event):void
         {
            out.removeEventListener("close",onClosed,true);
            out.removeEventListener("close",onClosed,false);
            out.removeEventListener("ioError",onIOError);
            callback(true);
         };
         var onComplete:* = function(param1:Event):void
         {
         };
         var onIOError:* = function(param1:IOErrorEvent):void
         {
            Engine.traceLog("createCacheFile onIOError",param1,cachePath);
            out.removeEventListener("close",onClosed,true);
            out.removeEventListener("close",onClosed,false);
            out.removeEventListener("ioError",onIOError);
            out.addEventListener("close",onErrorClosed);
            try
            {
               out.close();
               outFile.cancel();
            }
            catch(e:Error)
            {
            }
            deleteCacheFile(cachePath);
            callback(false);
         };
         var onErrorClosed:* = function(param1:Event):void
         {
            Engine.traceLog("createCacheFile onErrorClosed",param1,cachePath);
            out.removeEventListener("close",onErrorClosed);
            outFile.cancel();
            deleteCacheFile(cachePath);
         };
         var out:FileStream = new FileStream();
         var outFile:File = getCacheDirectory().resolvePath(cachePath);
         if(!outFile.parent.exists)
         {
            outFile.parent.createDirectory();
         }
         out.addEventListener("ioError",onIOError);
         out.addEventListener("close",onClosed);
         out.openAsync(outFile,"write");
         try
         {
            var bytes:ByteArray = loader is Loader ? loader.contentLoaderInfo.bytes : loader.data;
            bytes.position = 0;
            if(bytes.length > 0)
            {
               out.writeBytes(bytes,0,bytes.length);
            }
            out.close();
         }
         catch(e:Error)
         {
            Engine.traceLog(e,"createCacheFile failed: " + loader + " - " + cachePath);
            try
            {
               out.removeEventListener("close",onClosed,true);
               out.removeEventListener("close",onClosed,false);
               out.removeEventListener("ioError",onIOError);
               out.close();
            }
            catch(e2:Error)
            {
            }
            deleteCacheFile(cachePath);
            callback(false);
         }
      }
      
      private function deleteCacheFile(param1:String) : void
      {
         if(!param1 || param1.indexOf("://") >= 0)
         {
            return;
         }
         if(arfs && arfs.exists(param1))
         {
            arfs.unlink(param1);
         }
         var _loc2_:File = getCacheDirectory().resolvePath(param1);
         if(_loc2_.exists)
         {
            try
            {
               _loc2_.deleteFile();
            }
            catch(e:Error)
            {
               Engine.traceLog(e);
            }
         }
      }
      
      private function _loadCacheFile(param1:File, param2:ByteArray, param3:Function = null) : void
      {
         var file:File = param1;
         var buff:ByteArray = param2;
         var callback:Function = param3;
         var onComplete:* = function(param1:Event):void
         {
            stream.readBytes(buff,0,stream.bytesAvailable);
            buff.position = 0;
            stream.close();
         };
         var onIOError:* = function(param1:IOErrorEvent):void
         {
            trace("onIOError: " + param1);
            callback(null);
         };
         var onClosed:* = function(param1:Event):void
         {
            if(callback)
            {
               callback(buff);
            }
         };
         var stream:FileStream = new FileStream();
         stream.addEventListener("complete",onComplete);
         stream.addEventListener("ioError",onIOError);
         stream.addEventListener("close",onClosed);
         stream.openAsync(file,"read");
      }
      
      private function _checkPlainCacheDirectory(param1:File, param2:ByteArray, param3:*, param4:Function) : void
      {
         var dir:File = param1;
         var bytes:ByteArray = param2;
         var progressDialog:* = param3;
         var callback:Function = param4;
         var _doCheckPlainFile:* = function():void
         {
            var _loc1_:* = null;
            if(index >= files.length || progressDialog.isCanceled)
            {
               if(callback)
               {
                  callback(!hasError);
               }
            }
            else if(files[index].isDirectory)
            {
               _checkPlainCacheDirectory(files[index],bytes,progressDialog,_chekingDirectoryDone);
            }
            else
            {
               _loc1_ = getCacheDirectory().getRelativePath(files[index]);
               progressDialog.increaseChecked();
               trace("_doCheckPlainFile: path=" + _loc1_ + ", size=" + files[index].size);
               if(!hasValidationInfo(_loc1_))
               {
                  trace("[_doCheckPlainFile] " + _loc1_ + " has not FileInfo, then removed");
                  files[index].deleteFile();
                  index++;
                  _doCheckPlainFile();
               }
               else if(!isValidFileSize(_loc1_,files[index].size))
               {
                  Logger.warn("[_doCheckPlainFile] " + _loc1_ + " is invalid file size, then removed");
                  progressDialog.increaseBroken();
                  files[index].deleteFile();
                  index++;
                  _doCheckPlainFile();
               }
               else
               {
                  bytes.clear();
                  _loadCacheFile(files[index],bytes,_checkPlainCacheFile);
               }
            }
         };
         var _chekingDirectoryDone:* = function(param1:Boolean):void
         {
            if(!param1)
            {
               hasError = true;
            }
            index++;
            _doCheckPlainFile();
         };
         var _checkPlainCacheFile:* = function(param1:ByteArray):void
         {
            var _loc2_:String = getCacheDirectory().getRelativePath(files[index]);
            if(!hasValidationInfo(_loc2_))
            {
               trace("[_checkPlainCacheFile] " + _loc2_ + " has not FileInfo, then removed");
               files[index].deleteFile();
            }
            else if(!param1)
            {
               trace("[_checkPlainCacheFile] " + _loc2_ + " has no data, then removed");
               files[index].deleteFile();
            }
            else
            {
               try
               {
                  validateFile(_loc2_,param1);
               }
               catch(e:Error)
               {
                  Logger.warn("[_checkPlainCacheFile] " + _loc2_ + " has invalid data, then removed");
                  hasError = true;
                  progressDialog.increaseBroken();
                  files[index].deleteFile();
               }
            }
            index++;
            _doCheckPlainFile();
         };
         if(!dir.exists)
         {
            if(callback)
            {
               callback(true);
            }
            return;
         }
         var hasError:Boolean = false;
         var files:Array = dir.getDirectoryListing();
         var index:int = 0;
         _doCheckPlainFile();
      }
      
      public function checkCacheFiles(param1:*, param2:* = null) : void
      {
         var callback:* = param1;
         var progressDialog:* = param2;
         var bytes:ByteArray = new ByteArray();
         var hasError:Boolean = false;
         var cacheDir:File = getCacheDirectory().resolvePath("rsrc");
         _checkPlainCacheDirectory(cacheDir,bytes,progressDialog,function(param1:Boolean):void
         {
            var success:Boolean = param1;
            Logger.info("[_checkPlainCacheDirectory] done. success=" + success);
            hasError = !success;
            if(arfs && arfs.isAvailable)
            {
               arfs.checkStatus(function(param1:Boolean):void
               {
                  var ok:Boolean = param1;
                  var _checkFileInArfs:* = function(param1:ByteArray):void
                  {
                     progressDialog.increaseChecked();
                     if(!hasValidationInfo(files[index]))
                     {
                        trace("[_checkFileInArfs] " + files[index] + " has not FileInfo, then removed");
                        arfs.unlink(files[index]);
                     }
                     else if(!param1)
                     {
                        trace("[_checkFileInArfs] " + files[index] + " has no data, then removed");
                        arfs.unlink(files[index]);
                     }
                     else
                     {
                        try
                        {
                           validateFile(files[index],param1);
                        }
                        catch(e:Error)
                        {
                           Logger.warn("[_checkFileInArfs] " + files[index] + " has invalid data, then removed");
                           hasError = true;
                           progressDialog.increaseBroken();
                           arfs.unlink(files[index]);
                        }
                     }
                     index++;
                     if(index >= files.length || progressDialog.isCanceled)
                     {
                        if(callback)
                        {
                           callback(!hasError);
                        }
                     }
                     else
                     {
                        bytes.clear();
                        arfs.load(files[index],bytes,_checkFileInArfs);
                     }
                  };
                  var files:Array = arfs.list();
                  if(files.length == 0)
                  {
                     if(callback)
                     {
                        callback(!hasError);
                     }
                     return;
                  }
                  var index:int = 0;
                  arfs.load(files[index],bytes,_checkFileInArfs);
               });
            }
            else if(callback)
            {
               callback(!hasError);
            }
         });
      }
      
      public function validateFile(param1:String, param2:ByteArray) : void
      {
         var _loc4_:* = null;
         var _loc3_:int = 0;
         if(fileCheckMap == null)
         {
            return;
         }
         if(param1 in fileCheckMap)
         {
            if((_loc4_ = fileCheckMap[param1]) == null)
            {
               return;
            }
            _loc3_ = ObjectUtil.hashValueExt(param2);
            if(_loc4_.size != param2.length)
            {
               throw new FileInfoValidationError({
                  "path":param1,
                  "size":param2.length,
                  "hash":_loc3_,
                  "hasLocale":_loc4_.hasLocale,
                  "info_size":_loc4_.size,
                  "info_hash":_loc4_.hash
               },"file size of " + param1 + " was invalid: " + _loc4_.size + " - " + param2.length);
            }
            if(_loc4_.hash != _loc3_)
            {
               throw new FileInfoValidationError({
                  "path":param1,
                  "size":param2.length,
                  "hash":_loc3_,
                  "hasLocale":_loc4_.hasLocale,
                  "info_size":_loc4_.size,
                  "info_hash":_loc4_.hash
               },"hash value of " + param1 + " was invalid");
            }
         }
      }
      
      public function hasValidationInfo(param1:String) : Boolean
      {
         return fileCheckMap != null && param1 in fileCheckMap;
      }
      
      public function isValidFileSize(param1:String, param2:int) : Boolean
      {
         var _loc3_:* = null;
         if(fileCheckMap == null)
         {
            return true;
         }
         if(param1 in fileCheckMap)
         {
            _loc3_ = fileCheckMap[param1];
            if(_loc3_ == null)
            {
               return true;
            }
            if(_loc3_.size != param2)
            {
               return false;
            }
         }
         return true;
      }
      
      public function getFileSize(param1:String) : int
      {
         var _loc2_:* = null;
         if(fileCheckMap == null)
         {
            return -1;
         }
         if(param1 in fileCheckMap)
         {
            _loc2_ = fileCheckMap[param1];
            if(_loc2_ == null)
            {
               return -1;
            }
            return _loc2_.size;
         }
         return -1;
      }
      
      public function getFileCheckMap() : Object
      {
         return fileCheckMap;
      }
      
      public function forceUpdateFileInfo(param1:Object) : void
      {
         if(fileCheckMap)
         {
            fileCheckMap[param1.path] = param1;
            Logger.info("forceUpdateFileInfo. path=" + param1.path + ", fileInfo=" + param1);
         }
      }
      
      private function loadCompleted(param1:Event, param2:RsrcLoadContext) : void
      {
         var event:Event = param1;
         var context:RsrcLoadContext = param2;
         _loadCompleted(event,context);
      }
      
      private function _loadCompleted(param1:Event, param2:RsrcLoadContext) : void
      {
         var event:Event = param1;
         var context:RsrcLoadContext = param2;
         if(context.canceled)
         {
            return;
         }
         var fromCache:Boolean = false;
         if(context.loadFrom == 1)
         {
            fromCache = true;
         }
         if(context.loadFrom != 0)
         {
            trace("_loadCompleted",context.getTraceString());
         }
         if((context.loadFrom == 2 || context.loadFrom == 3) && !context.noCache)
         {
            var succeededFunc:Function = function():void
            {
               context.loadFrom = 1;
               postLoadCompleted(event,context,fromCache);
            };
            if(context.path.indexOf("://") >= 0)
            {
               succeededFunc();
            }
            else if(arfs && arfs.canHandle(context.path))
            {
               var bytes:ByteArray = context.loader is Loader ? context.loader.contentLoaderInfo.bytes : context.loader.data;
               bytes.position = 0;
               arfs.create(context.path,bytes,succeededFunc);
            }
            else
            {
               var retryCount:int = 0;
               var createCacheFileFunc:Function = function():void
               {
                  createCacheFile(context.loader,context.path,function(param1:Boolean):void
                  {
                     if(param1)
                     {
                        succeededFunc();
                        return;
                     }
                     Logger.warn("storage error? context={}, retryCount={}",context.getTraceString(),retryCount);
                     if(retryCount < 3)
                     {
                        retryCount++;
                        var _loc2_:* = Starling;
                        (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).delayCall(createCacheFileFunc,0.2);
                        return;
                     }
                     if(StringUtil.endsWith(context.path,"mp3"))
                     {
                        succeededFunc();
                     }
                     else
                     {
                        showStorageErrorMessage(context);
                     }
                  });
               };
               createCacheFileFunc();
            }
         }
         else
         {
            postLoadCompleted(event,context,fromCache);
         }
      }
      
      private function postLoadCompleted(param1:Event, param2:RsrcLoadContext, param3:Boolean) : void
      {
         var event:Event = param1;
         var context:RsrcLoadContext = param2;
         var fromCache:Boolean = param3;
         if(context.canceled)
         {
            return;
         }
         try
         {
            if(context.loadFrom == 1)
            {
               var dataBytes:ByteArray = context.loader is Loader ? context.loader.contentLoaderInfo.bytes : context.loader.data;
               try
               {
                  validateFile(context.path,dataBytes);
               }
               catch(ve:Error)
               {
                  trace("validation error " + context.path);
                  if(!(ve is FileInfoValidationError))
                  {
                     throw ve;
                  }
                  if(context.retryCount == 3 - 1)
                  {
                     context.fileInfo = FileInfoValidationError(ve).fileInfo;
                     throw ve;
                  }
                  if(context.retryCount != 3)
                  {
                     throw ve;
                  }
                  var fileInfo:Object = FileInfoValidationError(ve).fileInfo;
                  if(!(context.fileInfo && context.fileInfo.path == fileInfo.path && context.fileInfo.size == fileInfo.size && context.fileInfo.hash == fileInfo.hash))
                  {
                     throw ve;
                  }
                  forceUpdateFileInfo(fileInfo);
               }
            }
            if(context.type == 0)
            {
               if(context.loader is URLLoader)
               {
                  var _loader:Loader = new Loader();
                  _loader.contentLoaderInfo.addEventListener("init",function(param1:Event):void
                  {
                     if(context.canceled)
                     {
                        return;
                     }
                     var _loc2_:BitmapData = new BitmapData(_loader.width,_loader.height,true,0);
                     _loc2_.draw(_loader);
                     context.completeLoad(_loc2_);
                  });
                  _loader.contentLoaderInfo.addEventListener("ioError",function(param1:IOErrorEvent):void
                  {
                     Logger.error("RsrcLoadContext.TYPE_BITMAP IOErrorEvent.IO_ERROR path={}, e={}",context.path,param1);
                     context.completeLoad(context.loader.data);
                  });
                  if(!isCorrectPngData(context.loader.data,context.path,context.directly))
                  {
                     throw new FileInfoValidationError({
                        "path":context.path,
                        "size":context.loader.data.length
                     },"Invalid PNG. " + context.path);
                  }
                  _loader.loadBytes(context.loader.data);
               }
               else if(context.loader is Loader)
               {
                  var bitmap:Bitmap = context.loader.content as Bitmap;
                  var pixels:BitmapData = bitmap.bitmapData;
                  context.completeLoad(pixels);
               }
            }
            else if(context.type == 1)
            {
               context.completeLoad(context.loader.data);
            }
            else if(context.type == 2)
            {
               var aclip:MovieClip = context.loader.content as MovieClip;
               aclip.cacheAsBitmap = true;
               context.completeLoad(aclip);
            }
            else if(context.type == 3)
            {
               context.completeLoad(getURL(context));
            }
            else if(context.type == 4)
            {
               context.completeLoad(JSON.parse(context.loader.data));
            }
            else if(context.type == 5)
            {
               var ba:ByteArray = URLLoader(context.loader).data#2;
               var lc:LoaderContext = new LoaderContext(false,ApplicationDomain.currentDomain);
               lc.allowLoadBytesCodeExecution = true;
               _loader = new Loader();
               _loader.contentLoaderInfo.addEventListener("complete",function():void
               {
                  context.completeLoad(_loader.contentLoaderInfo.applicationDomain);
               });
               _loader.loadBytes(ba,lc);
            }
         }
         catch(e:Error)
         {
            if(fromCache)
            {
               deleteCacheFile(context.path);
            }
            else if(context.loadFrom == 1)
            {
               deleteCacheFile(context.path);
            }
            if(context.retryCount < 3)
            {
               context.retryCount++;
               startLoad(context);
               return;
            }
            if(e is FileInfoValidationError)
            {
               Logger.error("loadCompleted validation error",context.path,context.loadFrom,context.loader,e);
               showDownloadErrorMessage(context);
            }
            else
            {
               Logger.error("loadCompleted unknown error",context.path,context.loadFrom,context.loader,e);
               MessageDialog.show(10,GameSetting.getUIText("message.error.unknown"),function(param1:int):void
               {
                  _loadingCount--;
                  Engine.recoverScene();
               });
            }
         }
      }
      
      private function loadSecurityErrorOccurred(param1:Event, param2:RsrcLoadContext) : void
      {
         Logger.error("loadSecurityErrorOccurred: ",param2.loader,param1);
         param2.loader = null;
      }
      
      private function loadErrorOccurred(param1:Event, param2:RsrcLoadContext, param3:Function) : Boolean
      {
         if(param2.retryCount >= 2)
         {
            Logger.warn("loadErrorOccurred",UserDataWrapper.wrapper.getUid(),param2.getTraceString(),param1);
         }
         else
         {
            Logger.debug("loadErrorOccurred",UserDataWrapper.wrapper.getUid(),param2.getTraceString(),param1);
         }
         param2.loader = null;
         if(param2.loadFrom == 0)
         {
            param2.loadFrom = 1;
            startLoad(param2,param3);
         }
         else if(param2.loadFrom == 1)
         {
            param2.loadFrom = 2;
            startLoad(param2,param3);
         }
         else if(param2.retryCount < 3)
         {
            param2.retryCount++;
            startLoad(param2,param3);
         }
         else
         {
            if(param2.type == 5)
            {
               return true;
            }
            if(param2.path.indexOf("voice/") >= 0)
            {
               _loadingCount--;
               if(param2.path in contextMap)
               {
                  delete contextMap[param2.path];
               }
               return true;
            }
            showDownloadErrorMessage(param2);
         }
         return false;
      }
      
      private function loadDummyResource(param1:RsrcLoadContext) : Boolean
      {
         if(param1.type == 0)
         {
            param1.loadFrom = 0;
            param1.path = "rsrc/test/dummy.png";
            startLoad(param1);
            return false;
         }
         if(param1.type == 3)
         {
         }
         return true;
      }
      
      private function showDownloadErrorMessage(param1:RsrcLoadContext) : void
      {
         var context:RsrcLoadContext = param1;
         if(context.silent)
         {
            _loadingCount--;
            if(context.path in contextMap)
            {
               delete contextMap[context.path];
            }
            return;
         }
         MessageDialog.show(11,GameSetting.getUIText("message.connection.error.download"),function(param1:int):void
         {
            if(param1 == 0)
            {
               context.retryCount = 0;
               startLoad(context);
            }
            else
            {
               _loadingCount--;
               if(context.path in contextMap)
               {
                  delete contextMap[context.path];
               }
               Engine.recoverScene();
            }
         });
      }
      
      private function showStorageErrorMessage(param1:RsrcLoadContext) : void
      {
         var context:RsrcLoadContext = param1;
         cancelLoading();
         if(context.path in contextMap)
         {
            delete contextMap[context.path];
         }
         if(context.silent)
         {
            return;
         }
         MessageDialog.show(10,GameSetting.getUIText("message.error.storage_failed"),function(param1:int):void
         {
            Engine.recoverScene();
         });
      }
      
      public function loadFontSwf(param1:Function) : void
      {
         var callback:Function = param1;
         var context:RsrcLoadContext = registerLoadContext("rsrc/font/GudetamaFont.swf",5);
         context.loadFrom = 1;
         context.needRenameRsrc = true;
         context.addCallback(function(param1:ApplicationDomain):void
         {
            Engine.hideLoading(loadFontSwf);
            callback(param1);
         });
         Engine.showLoading(loadFontSwf);
         startLoad(context,function():void
         {
            Engine.hideLoading(loadFontSwf);
            var _loc2_:Boolean = false;
            var _loc1_:* = PartialBitmapFont;
            muku.text.PartialBitmapFont.sUseEmbed = _loc2_;
            callback(null);
         });
      }
   }
}
