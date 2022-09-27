package muku.util
{
   import flash.filesystem.File;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import gudetama.engine.Logger;
   import gudetama.engine.RsrcManager;
   import gudetama.engine.TextureCollector;
   import spine.Skeleton;
   import spine.SkeletonData;
   import spine.Skin;
   import spine.animation.AnimationStateData;
   import spine.atlas.Atlas;
   import spine.attachments.AtlasAttachmentLoader;
   import spine.attachments.AttachmentLoader;
   import spine.attachments.RegionAttachment;
   import spine.starling.StarlingTextureAttachmentLoader;
   import spine.starling.StarlingTextureLoader;
   import starling.textures.Texture;
   
   public final class SpineUtil
   {
      
      private static var cacheMap:Dictionary = new Dictionary();
      
      private static const MY_PATTERN:RegExp = /-/g;
       
      
      public function SpineUtil()
      {
         super();
      }
      
      private static function checkCache(param1:String, param2:Function) : Boolean
      {
         var _loc3_:* = null;
         var _loc4_:* = null;
         if(!(param1 in cacheMap))
         {
            _loc3_ = cacheMap[param1] = new CacheObject();
            _loc3_.callbacks.push(param2);
            return false;
         }
         _loc3_ = cacheMap[param1];
         if(_loc3_.skeletonBinary != null)
         {
            _loc4_ = _loc3_.skeletonBinary.readSkinData();
            param2(_loc4_,new AnimationStateData(_loc4_));
            return true;
         }
         _loc3_.callbacks.push(param2);
         return true;
      }
      
      public static function clearCache() : void
      {
         cacheMap = new Dictionary();
      }
      
      public static function removeCache(param1:String) : Vector.<String>
      {
         var _loc2_:CacheObject = cacheMap[param1];
         if(!_loc2_)
         {
            return null;
         }
         delete cacheMap[param1];
         return _loc2_.atlasNames;
      }
      
      public static function existSkeletonAnimationData(param1:String) : Boolean
      {
         var _loc2_:String = makePath(param1,".atlas");
         if(!RsrcManager.getInstance().hasValidationInfo(_loc2_))
         {
            if(!File.applicationDirectory.resolvePath(_loc2_).exists)
            {
               return false;
            }
         }
         return true;
      }
      
      public static function loadSkeletonAnimation(param1:String, param2:Function, param3:Array = null, param4:int = 0) : void
      {
         var name:String = param1;
         var callback:Function = param2;
         var animationNames:Array = param3;
         var textureCacheMode:int = param4;
         var loadAtlasList:* = function(param1:Vector.<String>, param2:Function):void
         {
            var atlasNames:Vector.<String> = param1;
            var _callback:Function = param2;
            var nextLoad:* = function(param1:String, param2:int, param3:Object):void
            {
               var _path:String = param1;
               var index:int = param2;
               var results:Object = param3;
               TextureCollector.loadTextureRsrc(atlasNames[index].replace(".png",""),function(param1:Texture):void
               {
                  results[atlasNames[index]] = param1;
                  index++;
                  if(index == max)
                  {
                     _callback(results);
                  }
                  else
                  {
                     nextLoad(_path,index,results);
                  }
               },textureCacheMode);
            };
            var max:int = atlasNames.length;
            nextLoad(makePath(name),0,{});
         };
         var loadBinary:* = function(param1:ByteArray, param2:Object, param3:Vector.<String>, param4:Function = null):void
         {
            var atlasData:ByteArray = param1;
            var bitmaps:Object = param2;
            var atlasNames:Vector.<String> = param3;
            var loadFaildCallback:Function = param4;
            RsrcManager.getInstance().loadByteArray(makePath(name,".skel"),function(param1:ByteArray):void
            {
               var _loc6_:* = null;
               var _loc5_:int = 0;
               var _loc7_:int = 0;
               if(!param1 && loadFaildCallback)
               {
                  loadFaildCallback();
                  return;
               }
               atlasData.position = 0;
               var _loc4_:Atlas = new Atlas(atlasData,new StarlingTextureLoader(bitmaps));
               var _loc2_:AttachmentLoader = new AtlasAttachmentLoader(_loc4_);
               var _loc3_:CacheObject = _cacheMap[name];
               if(!_loc3_)
               {
                  Logger.warn("not found in cache " + name);
               }
               if(_loc3_)
               {
                  param1.position = 0;
                  _loc3_.skeletonBinary = new SkeletonBinary(_loc2_);
                  _loc3_.atlasNames = atlasNames;
                  _loc6_ = _loc3_.skeletonBinary.readSkeletonData(param1);
                  _loc5_ = _loc3_.callbacks.length;
                  while(_loc7_ < _loc5_)
                  {
                     if(0 < _loc7_)
                     {
                        _loc6_ = _loc3_.skeletonBinary.readSkinData();
                     }
                     _loc3_.callbacks[_loc7_](_loc6_,new AnimationStateData(_loc6_));
                     _loc7_++;
                  }
               }
               else
               {
                  param1.position = 0;
                  _loc6_ = new SkeletonBinary(_loc2_).readSkeletonData(param1);
                  callback(_loc6_,new AnimationStateData(_loc6_));
               }
            });
         };
         if(checkCache(name,callback))
         {
            return;
         }
         var _cacheMap:Dictionary = cacheMap;
         RsrcManager.getInstance().loadByteArray(makePath(name,".atlas"),function(param1:ByteArray):void
         {
            var atlasData:ByteArray = param1;
            var atlasNames:Vector.<String> = getPageNames(atlasData);
            if(atlasNames.length > 0)
            {
               loadAtlasList(atlasNames,function(param1:Object):void
               {
                  loadBinary(atlasData,param1,atlasNames);
               });
            }
         });
      }
      
      public static function changeSkeletonAttachmentTexture(param1:Skeleton, param2:Texture, param3:String, param4:String = null, param5:String = null) : void
      {
         var _loc8_:* = null;
         if(param5 == null)
         {
            param5 = "default";
         }
         if(param4 == null)
         {
            param4 = param3;
         }
         var _loc7_:StarlingTextureAttachmentLoader;
         var _loc6_:RegionAttachment = (_loc7_ = new StarlingTextureAttachmentLoader(param2)).newRegionAttachment(null,param4,null);
         var _loc9_:int = param1.findSlotIndex(param3);
         param1.skin = param5 == "default" ? param1.data#2.defaultSkin : param1.data#2.findSkin(param5);
         if(param1.skin)
         {
            _loc8_ = RegionAttachment(param1.skin.getAttachment(_loc9_,param4));
            _loc6_.x = _loc8_.x;
            _loc6_.y = _loc8_.y;
            _loc6_.rotation = _loc8_.rotation;
            _loc6_.scaleX = _loc8_.scaleX;
            _loc6_.scaleY = _loc8_.scaleY;
            _loc6_.a = _loc8_.a;
            _loc6_.updateOffset();
            param1.skin.addAttachment(_loc9_,param4,_loc6_);
            param1.setAttachment(param3,param4);
            param1.setToSetupPose();
            return;
         }
         throw new Error("skeleton.skin == null");
      }
      
      public static function changeSkeletonAttachmentTextureForTest(param1:Skeleton, param2:Texture, param3:String, param4:String = null, param5:String = null) : void
      {
         var _loc8_:* = null;
         if(param5 == null)
         {
            param5 = "default";
         }
         if(param4 == null)
         {
            param4 = param3;
         }
         var _loc7_:StarlingTextureAttachmentLoader;
         var _loc6_:RegionAttachment = (_loc7_ = new StarlingTextureAttachmentLoader(param2)).newRegionAttachment(null,param4,null);
         var _loc9_:int = param1.findSlotIndex(param3);
         param1.skin = param5 == "default" ? param1.data#2.defaultSkin : param1.data#2.findSkin(param5);
         if(param1.skin)
         {
            _loc8_ = RegionAttachment(param1.skin.getAttachment(_loc9_,param4));
            _loc6_.x = _loc8_.x;
            _loc6_.y = _loc8_.y;
            _loc6_.rotation = _loc8_.rotation;
            _loc6_.scaleX = _loc8_.scaleX;
            _loc6_.scaleY = _loc8_.scaleY;
            _loc6_.a = _loc8_.a;
            _loc6_.updateOffset();
            param1.skin.addAttachment(_loc9_,param4,_loc6_);
            param1.setAttachment(param3,param4);
            param1.setToSetupPose();
            return;
         }
         throw new Error("skeleton.skin == null");
      }
      
      public static function parsEventString(param1:String) : Object
      {
         var _loc5_:* = null;
         var _loc4_:int = 0;
         if(param1 == null)
         {
            return null;
         }
         var _loc2_:Object = {};
         var _loc6_:Array;
         var _loc3_:int = (_loc6_ = param1.split(",")).length;
         _loc4_ = 0;
         while(_loc4_ < _loc3_)
         {
            _loc5_ = (_loc6_[_loc4_] as String).split(":");
            _loc2_[_loc5_[0]] = _loc5_[1];
            _loc4_++;
         }
         return _loc2_;
      }
      
      private static function makePath(param1:String, param2:String = null) : String
      {
         if(param2)
         {
            return "rsrc/" + param1.replace(MY_PATTERN,"/").replace(param1.substring(param1.lastIndexOf("-") + 1),param1) + param2;
         }
         return "rsrc/" + param1.replace(MY_PATTERN,"/").replace(param1.substring(param1.lastIndexOf("-") + 1),"");
      }
      
      private static function getPageNames(param1:*) : Vector.<String>
      {
         var _loc3_:* = null;
         var _loc6_:* = null;
         var _loc2_:Vector.<String> = new Vector.<String>();
         if(param1 is String)
         {
            _loc3_ = String(param1);
         }
         else
         {
            if(!(param1 is ByteArray))
            {
               throw new ArgumentError("object must be a TextureAtlas.");
            }
            (param1 as ByteArray).position = 0;
            _loc3_ = ByteArray(param1).readUTFBytes(ByteArray(param1).length);
         }
         var _loc4_:Boolean = false;
         var _loc5_:Reader = new Reader(_loc3_);
         while((_loc6_ = _loc5_.readLine()) != null)
         {
            if((_loc6_ = _loc5_.trim(_loc6_)).length == 0)
            {
               _loc4_ = false;
            }
            else if(!_loc4_)
            {
               _loc4_ = true;
               _loc2_.push(_loc6_);
            }
         }
         return _loc2_;
      }
      
      public static function loadSkeletonAnimationForEditor(param1:String, param2:Function) : void
      {
      }
      
      private function loadSkeleton(param1:String, param2:Function, param3:SkeletonBinary, param4:Function = null) : void
      {
         var name:String = param1;
         var callback:Function = param2;
         var binary:SkeletonBinary = param3;
         var loadFaildCallback:Function = param4;
         RsrcManager.getInstance().loadByteArray(makePath(name,".skel"),function(param1:ByteArray):void
         {
            if(!param1 && loadFaildCallback)
            {
               loadFaildCallback();
               return;
            }
            param1.position = 0;
            var _loc2_:SkeletonData = binary.readSkeletonData(param1);
            var _loc3_:AnimationStateData = new AnimationStateData(_loc2_);
            callback(_loc2_,_loc3_);
         });
      }
   }
}

class Reader
{
    
   
   private var lines:Array;
   
   private var index:int;
   
   function Reader(param1:String)
   {
      super();
      lines = param1.split(/\r\n|\r|\n/);
   }
   
   public function trim(param1:String) : String
   {
      return param1.replace(/^\s+|\s+$/sg,"");
   }
   
   public function readLine() : String
   {
      if(index >= lines.length)
      {
         return null;
      }
      return lines[index++];
   }
   
   public function readValue() : String
   {
      var _loc1_:String = readLine();
      var _loc2_:int = _loc1_.indexOf(":");
      if(_loc2_ == -1)
      {
         throw new Error("Invalid line: " + _loc1_);
      }
      return trim(_loc1_.substring(_loc2_ + 1));
   }
   
   public function readTuple(param1:Array) : int
   {
      var _loc2_:int = 0;
      var _loc5_:int;
      var _loc4_:String;
      if((_loc5_ = (_loc4_ = readLine()).indexOf(":")) == -1)
      {
         throw new Error("Invalid line: " + _loc4_);
      }
      var _loc6_:int = 0;
      var _loc3_:int = _loc5_ + 1;
      while(_loc6_ < 3)
      {
         _loc2_ = _loc4_.indexOf(",",_loc3_);
         if(_loc2_ == -1)
         {
            break;
         }
         param1[_loc6_] = trim(_loc4_.substr(_loc3_,_loc2_ - _loc3_));
         _loc3_ = _loc2_ + 1;
         _loc6_++;
      }
      param1[_loc6_] = trim(_loc4_.substring(_loc3_));
      return _loc6_ + 1;
   }
}

import muku.util.SkeletonBinary;

class CacheObject
{
    
   
   public var skeletonBinary:SkeletonBinary;
   
   public var callbacks:Vector.<Function>;
   
   public var atlasNames:Vector.<String>;
   
   function CacheObject()
   {
      callbacks = new Vector.<Function>();
      super();
   }
}
