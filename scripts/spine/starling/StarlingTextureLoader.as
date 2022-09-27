package spine.starling
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import spine.atlas.AtlasPage;
   import spine.atlas.AtlasRegion;
   import spine.atlas.TextureLoader;
   import starling.display.Image;
   import starling.textures.Texture;
   
   public class StarlingTextureLoader implements TextureLoader
   {
       
      
      public var bitmapDatasOrTextures:Object;
      
      public var singleBitmapDataOrTexture:Object;
      
      public function StarlingTextureLoader(param1:Object)
      {
         var _loc4_:* = undefined;
         var _loc3_:* = null;
         bitmapDatasOrTextures = {};
         super();
         if(param1 is BitmapData)
         {
            singleBitmapDataOrTexture = BitmapData(param1);
            return;
         }
         if(param1 is Bitmap)
         {
            singleBitmapDataOrTexture = Bitmap(param1).bitmapData;
            return;
         }
         if(param1 is Texture)
         {
            singleBitmapDataOrTexture = Texture(param1);
            return;
         }
         for(var _loc2_ in param1)
         {
            if((_loc4_ = param1[_loc2_]) is BitmapData)
            {
               _loc3_ = BitmapData(_loc4_);
            }
            else if(_loc4_ is Bitmap)
            {
               _loc3_ = Bitmap(_loc4_).bitmapData;
            }
            else
            {
               if(!(_loc4_ is Texture))
               {
                  throw new ArgumentError("Object for path \"" + _loc2_ + "\" must be a Bitmap, BitmapData or Texture: " + _loc4_);
               }
               _loc3_ = Texture(_loc4_);
            }
            bitmapDatasOrTextures[_loc2_] = _loc3_;
         }
      }
      
      public function loadPage(param1:AtlasPage, param2:String) : void
      {
         var _loc4_:* = null;
         var _loc5_:* = null;
         var _loc3_:Object = singleBitmapDataOrTexture || bitmapDatasOrTextures[param2];
         if(!_loc3_)
         {
            throw new ArgumentError("BitmapData/Texture not found with name: " + param2);
         }
         if(_loc3_ is BitmapData)
         {
            _loc4_ = BitmapData(_loc3_);
            param1.rendererObject = Texture.fromBitmapData(_loc4_);
            param1.width = _loc4_.width;
            param1.height = _loc4_.height;
         }
         else
         {
            _loc5_ = Texture(_loc3_);
            param1.rendererObject = _loc5_;
            param1.width = _loc5_.width;
            param1.height = _loc5_.height;
         }
      }
      
      public function loadRegion(param1:AtlasRegion) : void
      {
         var _loc2_:Image = new Image(Texture(param1.page.rendererObject));
         if(param1.rotate)
         {
            _loc2_.setTexCoords(0,param1.u,param1.v2);
            _loc2_.setTexCoords(1,param1.u,param1.v);
            _loc2_.setTexCoords(2,param1.u2,param1.v2);
            _loc2_.setTexCoords(3,param1.u2,param1.v);
         }
         else
         {
            _loc2_.setTexCoords(0,param1.u,param1.v);
            _loc2_.setTexCoords(1,param1.u2,param1.v);
            _loc2_.setTexCoords(2,param1.u,param1.v2);
            _loc2_.setTexCoords(3,param1.u2,param1.v2);
         }
         param1.rendererObject = _loc2_;
      }
      
      public function unloadPage(param1:AtlasPage) : void
      {
         Texture(param1.rendererObject).dispose();
      }
   }
}
