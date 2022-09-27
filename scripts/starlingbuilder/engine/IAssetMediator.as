package starlingbuilder.engine
{
   import flash.utils.ByteArray;
   import starling.textures.Texture;
   
   public interface IAssetMediator
   {
       
      
      function getTexture(param1:String) : Texture;
      
      function getTextures(param1:String = "", param2:Vector.<Texture> = null) : Vector.<Texture>;
      
      function getExternalData(param1:String) : Object;
      
      function getXml(param1:String) : XML;
      
      function getObject(param1:String) : Object;
      
      function getByteArray(param1:String) : ByteArray;
   }
}
