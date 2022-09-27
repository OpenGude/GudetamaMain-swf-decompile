package gudetama.engine
{
   import flash.filesystem.File;
   import flash.filesystem.FileStream;
   import muku.core.MukuGlobal;
   import starling.textures.Texture;
   import starling.utils.AssetManager;
   import starlingbuilder.engine.DefaultAssetMediator;
   import starlingbuilder.engine.IAssetMediator;
   
   public class AssetMediator extends DefaultAssetMediator implements IAssetMediator
   {
      
      private static var _cache:Object;
       
      
      private var _file:File;
      
      public function AssetMediator(param1:AssetManager)
      {
         super(param1);
         _assetManager = param1;
      }
      
      public static function setTextureCache(param1:Object) : void
      {
         _cache = param1;
      }
      
      public static function clearTextureCache() : void
      {
         _cache = null;
      }
      
      public function getLayoutData(param1:String, param2:Function) : void
      {
         var _loc3_:Object = getObject(param1);
         if(_loc3_)
         {
            param2(_loc3_);
            return;
         }
         if(param1.indexOf("-") >= 0)
         {
            param1 = MukuGlobal.makePathFromName(param1,".json");
         }
         else
         {
            param1 = "rsrc/json/" + param1 + ".json";
         }
         RsrcManager.getInstance().loadLayoutData(param1,param2);
      }
      
      override public function getXml(param1:String) : XML
      {
         var _loc2_:* = null;
         if(_cache)
         {
            _loc2_ = _cache[param1 + ".pex"] as XML;
            if(_loc2_)
            {
               return _loc2_;
            }
         }
         return super.getXml(param1);
      }
      
      override public function getTexture(param1:String) : Texture
      {
         var _loc2_:* = null;
         if(_cache)
         {
            _loc2_ = _cache[param1];
            if(_loc2_)
            {
               return _loc2_;
            }
         }
         return _assetManager.getTexture(param1);
      }
      
      override public function getTextures(param1:String = "", param2:Vector.<Texture> = null) : Vector.<Texture>
      {
         return _assetManager.getTextures(param1,param2);
      }
      
      override public function getExternalData(param1:String) : Object
      {
         var _loc4_:* = null;
         var _loc3_:* = null;
         if(_file == null)
         {
            throw new Error("Current Directory not found!");
         }
         for each(var _loc2_ in _file.parent.getDirectoryListing())
         {
            if(FileListingHelper.stripPostfix(_loc2_.name#2) == param1)
            {
               (_loc4_ = new FileStream()).open(_loc2_,"read");
               _loc3_ = _loc4_.readUTFBytes(_loc4_.bytesAvailable);
               _loc4_.close();
               return _loc3_;
            }
         }
         return null;
      }
      
      public function get file() : File
      {
         return _file;
      }
      
      public function set file(param1:File) : void
      {
         _file = param1;
      }
   }
}
