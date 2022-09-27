package gudetama.engine
{
   import flash.display.BitmapData;
   import muku.core.MukuGlobal;
   import muku.core.TaskQueue;
   import starling.textures.SubTexture;
   import starling.textures.Texture;
   import starling.utils.AssetManager;
   import starlingbuilder.engine.format.DefaultDataFormatter;
   import starlingbuilder.engine.format.IDataFormatter;
   import starlingbuilder.engine.util.ParamUtil;
   
   public class TextureCollector
   {
      
      public static const CACHEMODE_SCENE:int = 0;
      
      public static const CACHEMODE_GLOBAL:int = 1;
      
      public static const CACHEMODE_LAYOUT:int = 2;
      
      private static const cacheObjects:Object = {};
      
      private static var currentCache:CacheObject;
      
      private static var _dataFormatter:IDataFormatter = new DefaultDataFormatter();
       
      
      private var _assetMediator:AssetMediator;
      
      private var _assetManager:AssetManager;
      
      private var _data:Object;
      
      private var _names:Array;
      
      private var _externalRsrcs:Array;
      
      public function TextureCollector(param1:Object, param2:AssetMediator)
      {
         super();
         _assetMediator = param2;
         _assetManager = Engine.assetManager;
         _data = _dataFormatter.read(param1);
         var _loc3_:Array = setupDictionary(_data.layout);
         _names = _loc3_[0];
         _externalRsrcs = _loc3_[1];
         changeCacheMode(0);
      }
      
      private static function changeCacheMode(param1:int) : void
      {
         if(!cacheObjects[param1])
         {
            cacheObjects[param1] = new CacheObject();
         }
         currentCache = cacheObjects[param1];
      }
      
      public static function clearAll(param1:int = 0) : void
      {
         if(cacheObjects[param1])
         {
            (cacheObjects[param1] as CacheObject).dispose();
         }
         cacheObjects[param1] = new CacheObject();
      }
      
      public static function clearAtName(param1:String, param2:int = 0) : void
      {
         if(cacheObjects[param2])
         {
            (cacheObjects[param2] as CacheObject).clearAtName(param1);
         }
      }
      
      private static function getTextureCache(param1:String) : Texture
      {
         var _loc2_:* = null;
         var _loc3_:* = null;
         var _loc8_:int = 0;
         var _loc7_:* = cacheObjects;
         do
         {
            for(var _loc4_ in _loc7_)
            {
               _loc3_ = cacheObjects[_loc4_];
               try
               {
                  _loc2_ = _loc3_.getTextureCache(param1);
               }
               catch(e:Error)
               {
                  Logger.error(e.getStackTrace() + "\nkey:" + param1);
                  _loc2_ = null;
               }
            }
            return null;
         }
         while(_loc2_ === null);
         
         return _loc2_;
      }
      
      private static function hasTextureCache(param1:String) : Boolean
      {
         var _loc2_:* = null;
         for(var _loc3_ in cacheObjects)
         {
            _loc2_ = cacheObjects[_loc3_];
            if(_loc2_.hasTextureCache(param1))
            {
               return true;
            }
         }
         return false;
      }
      
      private static function isExternalSource(param1:Object) : Boolean
      {
         return param1 && param1.customParams && param1.customParams.source;
      }
      
      public static function getAtlasName(param1:String) : String
      {
         var _loc3_:int = param1.indexOf("@");
         if(_loc3_ <= 0)
         {
            return "";
         }
         return param1.substr(0,_loc3_);
      }
      
      private static function parseParams(param1:Object, param2:Array) : void
      {
         var _loc5_:* = null;
         var _loc3_:* = null;
         var _loc4_:Array = [];
         for(_loc5_ in param1.params)
         {
            _loc4_.push(_loc5_);
         }
         for each(_loc5_ in _loc4_)
         {
            _loc3_ = param1.params[_loc5_];
            if(_loc3_ && _loc3_.hasOwnProperty("cls"))
            {
               parseClsAndParams(_loc3_,param2);
            }
         }
      }
      
      private static function parseClsAndParams(param1:Object, param2:Array) : void
      {
         var _loc5_:* = null;
         var _loc3_:* = null;
         if(param1.cls == ParamUtil.getClassName(Texture))
         {
            param2.push({
               "name":param1.textureName,
               "cls":param1.cls
            });
         }
         else if(param1.cls == "feathers.textures.Scale3Textures")
         {
            param2.push({
               "name":param1.textureName,
               "cls":param1.cls,
               "scaleRatio":param1.scaleRatio.concat()
            });
         }
         else if(param1.cls == "feathers.textures.Scale9Textures")
         {
            param2.push({
               "name":param1.textureName,
               "cls":param1.cls,
               "scaleRatio":param1.scaleRatio.concat()
            });
         }
         else if(param1.cls != ParamUtil.getClassName(Vector.<Texture>))
         {
            if(param1.cls == "muku.display.Particle")
            {
               if(param1.params.hasOwnProperty("particleName"))
               {
                  param2.push({
                     "name":param1.params.textureName,
                     "cls":ParamUtil.getClassName(Texture)
                  });
                  param2.push({
                     "name":param1.params.particleName,
                     "cls":"PEX"
                  });
               }
            }
            else if(param1.cls == "starling.display.MovieClip")
            {
               if(param1.params.hasOwnProperty("textureNames"))
               {
                  _loc5_ = ParamUtil.getClassName(Texture);
                  _loc3_ = param1.params.textureNames as Array;
                  for each(var _loc4_ in _loc3_)
                  {
                     param2.push({
                        "name":_loc4_,
                        "cls":_loc5_
                     });
                  }
               }
            }
         }
         var _loc6_:Array = param1.constructorParams as Array;
         for each(var _loc7_ in _loc6_)
         {
            parseClsAndParams(_loc7_,param2);
         }
         parseParams(param1,param2);
      }
      
      private static function createConcreteTexture(param1:BitmapData) : Texture
      {
         return Texture.fromBitmapData(param1);
      }
      
      public static function getTextures(param1:Array, param2:Function, param3:int) : void
      {
         var names:Array = param1;
         var callback:Function = param2;
         var cacheMode:int = param3;
         var table:Object = {};
         var exQueue:TaskQueue = null;
         var requested:Object = {};
         for each(item in names)
         {
            var textureName:String = item is String ? item as String : item.name;
            var atlasName:String = getAtlasName(textureName);
            if(item.hasOwnProperty("cls") && item.cls == "PEX")
            {
               var xmlName:String = textureName + ".pex";
               var xml:Object = Engine.assetManager.getXml(textureName);
               if(xml)
               {
                  table[xmlName] = xml;
               }
               else
               {
                  if(exQueue == null)
                  {
                     exQueue = new TaskQueue();
                  }
                  if(!(xmlName in requested))
                  {
                     _getPEX(exQueue,table,xmlName);
                     requested[xmlName] = xmlName;
                  }
               }
            }
            else if(atlasName != "")
            {
               var subtex:Texture = Engine.assetManager.getTexture(textureName);
               if(subtex)
               {
                  table[textureName] = subtex;
               }
               else
               {
                  changeCacheMode(cacheMode);
                  if(currentCache.hasAtlasCache(atlasName))
                  {
                     table[textureName] = currentCache.getTextureFromCachedAtlas(atlasName,textureName);
                  }
                  else
                  {
                     if(exQueue == null)
                     {
                        exQueue = new TaskQueue();
                     }
                     if(!(textureName in requested))
                     {
                        _getTexInAtlas(exQueue,table,textureName,cacheMode);
                        requested[textureName] = textureName;
                     }
                  }
               }
            }
            else
            {
               var tex:Texture = Engine.assetManager.getTexture(textureName);
               if(tex)
               {
                  table[textureName] = tex;
               }
               else
               {
                  changeCacheMode(cacheMode);
                  tex = getTextureCache(textureName);
                  if(tex)
                  {
                     table[textureName] = tex;
                  }
                  else
                  {
                     if(exQueue == null)
                     {
                        exQueue = new TaskQueue();
                     }
                     if(!(textureName in requested))
                     {
                        _getTexture(exQueue,table,textureName,cacheMode);
                        requested[textureName] = textureName;
                     }
                  }
               }
            }
         }
         requested.length = 0;
         requested = null;
         if(exQueue)
         {
            exQueue.startTask(function(param1:Number):void
            {
               if(param1 == 1)
               {
                  if(callback)
                  {
                     callback(table);
                  }
               }
            });
         }
         else if(callback)
         {
            callback(table);
         }
      }
      
      public static function loadTextureForTask(param1:TaskQueue, param2:String, param3:Function, param4:int = 0) : void
      {
         var queue:TaskQueue = param1;
         var name:String = param2;
         var callback:Function = param3;
         var cacheMode:int = param4;
         queue.addTask(function():void
         {
            loadTexture(name,function(param1:Texture):void
            {
               callback(param1);
               queue.taskDone();
            },cacheMode);
         });
      }
      
      public static function loadTexture(param1:String, param2:Function, param3:int = 0) : void
      {
         var name:String = param1;
         var callback:Function = param2;
         var cacheMode:int = param3;
         var atlasName:String = getAtlasName(name);
         changeCacheMode(cacheMode);
         if(atlasName != "")
         {
            if(currentCache.hasAtlasCache(atlasName))
            {
               callback(currentCache.getTextureFromCachedAtlas(atlasName,name));
            }
            else
            {
               var path:String = "rsrc/atlas/" + atlasName + ".xml";
               currentCache.loadAtlas(atlasName,name,path,callback);
            }
         }
         else
         {
            var tex:Texture = getTextureCache(name);
            if(tex)
            {
               if(callback.length == 1)
               {
                  callback(tex);
               }
               else if(callback.length == 2)
               {
                  tex.getBitmapData(function(param1:BitmapData, param2:Boolean):void
                  {
                     callback(tex,param1);
                  });
               }
            }
            else
            {
               path = MukuGlobal.makePathFromName(name,".png");
               RsrcManager.getInstance().loadBitmapData(path,function(param1:Object):void
               {
                  var _loc2_:BitmapData = param1 as BitmapData;
                  tex = createConcreteTexture(_loc2_);
                  changeCacheMode(cacheMode);
                  currentCache.putTextureCache(name,tex);
                  if(callback.length == 1)
                  {
                     callback(tex);
                  }
                  else if(callback.length == 2)
                  {
                     callback(tex,_loc2_);
                  }
               });
            }
         }
      }
      
      public static function loadTextureRsrc(param1:String, param2:Function, param3:int = 0) : void
      {
         var _loc4_:* = null;
         changeCacheMode(param3);
         if(hasTextureCache(param1))
         {
            param2(getTextureCache(param1));
         }
         else
         {
            _loc4_ = MukuGlobal.makePathFromName(param1,".png");
            currentCache.loadTexture(param1,_loc4_,param2);
         }
      }
      
      private static function _getTexture(param1:TaskQueue, param2:Object, param3:Object, param4:int) : void
      {
         var _loc5_:String = MukuGlobal.makePathFromName(param3 as String,".png");
         param1.addTask(loadBitmapDataTask(param1,param2,_loc5_,String(param3),param4));
      }
      
      private static function _getPEX(param1:TaskQueue, param2:Object, param3:Object) : void
      {
         var _loc4_:String = "rsrc/particle/" + param3;
         param1.addTask(loadXmlTask(param1,param2,_loc4_,String(param3)));
      }
      
      private static function _getTexInAtlas(param1:TaskQueue, param2:Object, param3:String, param4:int) : void
      {
         var _loc5_:String = getAtlasName(param3);
         var _loc6_:String = "rsrc/atlas/" + _loc5_ + ".xml";
         param1.addTask(loadAtlasTask(param1,param2,_loc6_,param3,_loc5_,param4));
      }
      
      private static function _getAtlas(param1:TaskQueue, param2:String, param3:int) : void
      {
         var _loc4_:String = "rsrc/atlas/" + param2 + ".xml";
         param1.addTask(loadAtlasTask(param1,null,_loc4_,null,param2,param3));
      }
      
      private static function loadBitmapDataTask(param1:TaskQueue, param2:Object, param3:String, param4:String, param5:int) : Function
      {
         var exQueue:TaskQueue = param1;
         var table:Object = param2;
         var path:String = param3;
         var textureName:String = param4;
         var cacheMode:int = param5;
         return function():void
         {
            RsrcManager.getInstance().loadBitmapData(path,function(param1:Object):void
            {
               var o:Object = param1;
               changeCacheMode(cacheMode);
               if(hasTextureCache(textureName as String))
               {
                  table[textureName] = getTextureCache(textureName as String);
                  exQueue.taskDone();
                  return;
               }
               var bitmap:BitmapData = o as BitmapData;
               Engine.addSequentialCallback(function():void
               {
                  changeCacheMode(cacheMode);
                  if(hasTextureCache(textureName as String))
                  {
                     table[textureName] = getTextureCache(textureName as String);
                     exQueue.taskDone();
                     return;
                  }
                  var _loc1_:Texture = createConcreteTexture(bitmap);
                  currentCache.putTextureCache(textureName as String,_loc1_);
                  table[textureName] = _loc1_;
                  exQueue.taskDone();
               });
            });
         };
      }
      
      private static function loadXmlTask(param1:TaskQueue, param2:Object, param3:String, param4:String) : Function
      {
         var exQueue:TaskQueue = param1;
         var table:Object = param2;
         var path:String = param3;
         var xmlName:String = param4;
         return function():void
         {
            RsrcManager.getInstance().loadByteArray(path,function(param1:Object):void
            {
               var _loc2_:Object = XML(param1);
               table[xmlName] = _loc2_;
               exQueue.taskDone();
            });
         };
      }
      
      private static function loadAtlasTask(param1:TaskQueue, param2:Object, param3:String, param4:String, param5:String, param6:int) : Function
      {
         var exQueue:TaskQueue = param1;
         var table:Object = param2;
         var path:String = param3;
         var textureName:String = param4;
         var atlasName:String = param5;
         var cacheMode:int = param6;
         return function():void
         {
            changeCacheMode(cacheMode);
            currentCache.loadAtlas(atlasName,textureName,path,function(param1:SubTexture):void
            {
               table[textureName] = param1;
               exQueue.taskDone();
            });
         };
      }
      
      public static function loadSnsImage(param1:int, param2:TaskQueue, param3:Function) : void
      {
         var _loc4_:String = null;
         if(param1 == 0)
         {
            _loc4_ = "ar0@btn_twitter";
         }
         else if(param1 == 1)
         {
            _loc4_ = "ar0@btn_fb";
         }
         if(_loc4_ == null)
         {
            param3(null);
            return;
         }
         if(param2 != null)
         {
            loadTextureForTask(param2,_loc4_,param3);
         }
         else
         {
            loadTexture(_loc4_,param3);
         }
      }
      
      private function parseJsonTree(param1:Object, param2:Array, param3:Array) : void
      {
         var _loc4_:* = null;
         var _loc5_:* = null;
         parseClsAndParams(param1,param2);
         if(param1.children)
         {
            for each(_loc4_ in param1.children)
            {
               if(!(_loc4_.customParams && _loc4_.customParams.forEditor))
               {
                  parseJsonTree(_loc4_,param2,param3);
               }
            }
         }
         if(isExternalSource(param1))
         {
            if(_loc5_ = _dataFormatter.read(_assetMediator.getExternalData(param1.customParams.source)))
            {
               parseJsonTree(_loc5_.layout,param2,param3);
            }
            else
            {
               param3.push({
                  "name":param1.customParams.source,
                  "cls":"JSON"
               });
            }
         }
      }
      
      private function setupDictionary(param1:Object) : Array
      {
         var _loc2_:Array = [];
         var _loc3_:Array = [];
         parseJsonTree(param1,_loc2_,_loc3_);
         return [_loc2_,_loc3_];
      }
      
      private function _getLayouts(param1:Array, param2:Function) : void
      {
         var names:Array = param1;
         var callback:Function = param2;
         var table:Object = {};
         var exQueue:TaskQueue = null;
         var _getJSON:Function = function(param1:Object):void
         {
            var jsonName:Object = param1;
            var path:String = "rsrc/json/" + jsonName;
            var f:Function = function():void
            {
               RsrcManager.getInstance().loadLayoutData(path,function(param1:Object):void
               {
                  if(param1)
                  {
                     table[jsonName] = param1;
                  }
                  exQueue.taskDone();
               });
            };
            exQueue.addTask(f);
         };
         var requested:Object = {};
         for each(item in names)
         {
            var itemName:String = item is String ? item as String : item.name;
            Logger.debug("jsonName:",item.name);
            if(item.hasOwnProperty("cls") && item.cls == "JSON")
            {
               var jsonName:String = itemName + ".json";
               var json:Object = Engine.assetManager.getObject(jsonName);
               if(json)
               {
                  table[jsonName] = json;
               }
               else
               {
                  if(exQueue == null)
                  {
                     exQueue = new TaskQueue();
                  }
                  if(!(jsonName in requested))
                  {
                     _getJSON(jsonName);
                     requested[jsonName] = jsonName;
                  }
               }
            }
         }
         requested.length = 0;
         requested = null;
         if(exQueue)
         {
            exQueue.startTask(function(param1:Number):void
            {
               if(param1 == 1)
               {
                  if(callback)
                  {
                     callback(table);
                  }
               }
            });
         }
         else if(callback)
         {
            callback(table);
         }
      }
      
      public function preloadTextures(param1:Function, param2:int) : void
      {
         var callback:Function = param1;
         var cacheMode:int = param2;
         if(_externalRsrcs.length > 0)
         {
            _getLayouts(_externalRsrcs,function(param1:Object):void
            {
               var _loc2_:* = null;
               _externalRsrcs.length = 0;
               for each(_loc2_ in param1)
               {
                  parseJsonTree(_loc2_.layout,_names,_externalRsrcs);
               }
               preloadTextures(callback,cacheMode);
            });
         }
         else
         {
            getTextures(_names,callback,cacheMode);
         }
      }
   }
}

import flash.display.BitmapData;
import gudetama.engine.RsrcManager;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

class CacheObject
{
    
   
   private var textureCache:Object;
   
   private var atlasCache:Object;
   
   private var asyncCallbackTable:Object;
   
   private var disposed:Boolean;
   
   function CacheObject()
   {
      super();
      textureCache = {};
      atlasCache = {};
      asyncCallbackTable = {};
   }
   
   public function dispose() : void
   {
      disposed = true;
      for each(var _loc1_ in textureCache)
      {
         if(_loc1_ is Texture)
         {
            _loc1_.dispose();
         }
      }
      for each(var _loc2_ in atlasCache)
      {
         if(_loc2_ is TextureAtlas)
         {
            _loc2_.dispose();
         }
      }
   }
   
   public function clearAtName(param1:String) : void
   {
      if(textureCache[param1])
      {
         textureCache[param1].dispose();
         delete textureCache[param1];
      }
      if(atlasCache[param1])
      {
         atlasCache[param1].dispose();
         delete atlasCache[param1];
      }
   }
   
   public function hasAsyncCallback(param1:String) : Boolean
   {
      return asyncCallbackTable.hasOwnProperty(param1);
   }
   
   public function putAsyncCallback(param1:String, param2:Function) : void
   {
      if(!asyncCallbackTable.hasOwnProperty(param1))
      {
         asyncCallbackTable[param1] = new Vector.<Function>();
      }
      asyncCallbackTable[param1].push(param2);
   }
   
   public function callAsyncCallbacks(param1:String, param2:Texture) : void
   {
      var _loc5_:* = null;
      var _loc6_:int = 0;
      var _loc4_:Vector.<Function>;
      var _loc3_:int = (_loc4_ = asyncCallbackTable[param1] as Vector.<Function>).length;
      _loc6_ = 0;
      while(_loc6_ < _loc3_)
      {
         (_loc5_ = _loc4_.pop())(param2);
         _loc6_++;
      }
      _loc4_ = null;
      delete asyncCallbackTable[param1];
   }
   
   public function putTextureCache(param1:String, param2:Texture) : void
   {
      if(param2)
      {
         textureCache[param1] = param2;
      }
   }
   
   public function getTextureCache(param1:String) : Texture
   {
      return textureCache[param1];
   }
   
   public function hasTextureCache(param1:String) : Boolean
   {
      return textureCache.hasOwnProperty(param1) && textureCache[param1] is Texture;
   }
   
   public function loadTexture(param1:String, param2:String, param3:Function) : void
   {
      var fileName:String = param1;
      var path:String = param2;
      var callback:Function = param3;
      if(!textureCache[fileName])
      {
         textureCache[fileName] = new Vector.<Function>();
         textureCache[fileName].push(callback);
         RsrcManager.getInstance().loadBitmapData(path,function(param1:BitmapData):void
         {
            var _loc6_:* = null;
            var _loc4_:int = 0;
            var _loc2_:Texture = Texture.fromBitmapData(param1);
            var _loc5_:Vector.<Function>;
            var _loc3_:int = (_loc5_ = textureCache[fileName] as Vector.<Function>).length;
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               (_loc6_ = _loc5_.shift())(_loc2_);
               _loc4_++;
            }
            textureCache[fileName] = _loc2_;
         });
      }
      else if(textureCache[fileName] is Texture)
      {
         callback(textureCache[fileName]);
      }
      else
      {
         textureCache[fileName].push(callback);
      }
   }
   
   public function putAtlasCache(param1:String, param2:TextureAtlas) : void
   {
      if(param2)
      {
         atlasCache[param1] = param2;
      }
   }
   
   public function getAtlasCache(param1:String) : TextureAtlas
   {
      return atlasCache[param1];
   }
   
   public function getTextureFromCachedAtlas(param1:String, param2:String) : Texture
   {
      if(!atlasCache.hasOwnProperty(param1))
      {
         return null;
      }
      return atlasCache[param1].getTexture(param2);
   }
   
   public function hasAtlasCache(param1:String) : Boolean
   {
      return atlasCache.hasOwnProperty(param1) && atlasCache[param1] is TextureAtlas;
   }
   
   public function loadAtlas(param1:String, param2:String, param3:String, param4:Function) : void
   {
      var atlasName:String = param1;
      var subName:String = param2;
      var path:String = param3;
      var callback:Function = param4;
      if(!atlasCache[atlasName])
      {
         atlasCache[atlasName] = new Vector.<Object>();
         atlasCache[atlasName].push({
            "name":subName,
            "cb":callback
         });
         RsrcManager.getInstance().loadTextureAtlas(path,function(param1:XML, param2:BitmapData):void
         {
            var _loc7_:* = null;
            var _loc5_:int = 0;
            var _loc3_:TextureAtlas = new TextureAtlas(Texture.fromBitmapData(param2),param1);
            var _loc6_:Vector.<Object>;
            var _loc4_:int = (_loc6_ = atlasCache[atlasName] as Vector.<Object>).length;
            _loc5_ = 0;
            while(_loc5_ < _loc4_)
            {
               (_loc7_ = _loc6_.shift()).cb(_loc3_.getTexture(_loc7_.name));
               _loc5_++;
            }
            atlasCache[atlasName] = _loc3_;
         });
      }
      else if(atlasCache[atlasName] is TextureAtlas)
      {
         callback(getTextureFromCachedAtlas(atlasName,subName));
      }
      else
      {
         atlasCache[atlasName].push({
            "name":subName,
            "cb":callback
         });
      }
   }
}
