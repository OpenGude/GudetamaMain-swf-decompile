package starlingbuilder.engine
{
   import flash.utils.ByteArray;
   import starling.textures.Texture;
   import starling.utils.AssetManager;
   
   public class DefaultAssetMediator implements IAssetMediator
   {
       
      
      protected var _assetManager:AssetManager;
      
      public function DefaultAssetMediator(param1:AssetManager)
      {
         super();
         _assetManager = param1;
      }
      
      public function getTexture(param1:String) : Texture
      {
         return _assetManager.getTexture(param1);
      }
      
      public function getTextures(param1:String = "", param2:Vector.<Texture> = null) : Vector.<Texture>
      {
         return _assetManager.getTextures(param1,param2);
      }
      
      public function getExternalData(param1:String) : Object
      {
         return null;
      }
      
      public function getXml(param1:String) : XML
      {
         return _assetManager.getXml(param1);
      }
      
      public function getObject(param1:String) : Object
      {
         return _assetManager.getObject(param1);
      }
      
      public function getByteArray(param1:String) : ByteArray
      {
         return _assetManager.getByteArray(param1);
      }
   }
}
