package gudetama.engine
{
   import flash.filesystem.File;
   import flash.filesystem.FileStream;
   import starling.textures.TextureOptions;
   import starling.utils.AssetManager;
   
   public class AssetLoaderWithOptions
   {
      
      public static const DEFAULT_OPTION:String = "default_option";
       
      
      private var _assetManager:AssetManager;
      
      private var _workspace:File;
      
      private var _options:Object;
      
      public function AssetLoaderWithOptions(param1:AssetManager, param2:File)
      {
         super();
         _assetManager = param1;
         _workspace = param2;
         loadOptions();
      }
      
      private function loadOptions() : void
      {
         var _loc2_:* = null;
         var _loc1_:File = _workspace.resolvePath("settings/texture_options.json");
         if(_loc1_.exists)
         {
            _loc2_ = new FileStream();
            _loc2_.open(_loc1_,"read");
            _options = JSON.parse(_loc2_.readUTFBytes(_loc2_.bytesAvailable));
         }
         else
         {
            _options = {};
         }
      }
      
      public function enqueue(... rest) : void
      {
         var _loc2_:* = null;
         for each(var _loc3_ in rest)
         {
            if(_loc3_ is File)
            {
               _loc2_ = _loc3_ as File;
               _loc3_ = unescape(_loc2_.url#2);
               if(_loc2_.isDirectory)
               {
                  enqueue.apply(this,_loc2_.getDirectoryListing());
               }
               else
               {
                  _assetManager.enqueueWithName(_loc3_,null,getTextureOptions(_loc2_.url#2));
               }
            }
            else
            {
               _assetManager.enqueue.apply(this,rest);
            }
         }
      }
      
      private function getTextureOptions(param1:String) : TextureOptions
      {
         var _loc3_:* = null;
         var _loc2_:* = null;
         for(var _loc4_ in _options)
         {
            _loc3_ = new RegExp(_loc4_);
            _loc2_ = param1.match(_loc3_);
            if(_loc2_ && _loc2_.length > 0)
            {
               return new TextureOptions(_options[_loc4_].scale);
            }
         }
         if("default_option" in _options)
         {
            return new TextureOptions(_options["default_option"].scale);
         }
         return null;
      }
   }
}
