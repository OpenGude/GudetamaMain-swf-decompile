package spine.starling
{
   import starling.display.Mesh;
   import starling.rendering.IndexData;
   import starling.rendering.VertexData;
   import starling.styles.MeshStyle;
   import starling.textures.Texture;
   
   public class SkeletonMesh extends Mesh
   {
       
      
      public function SkeletonMesh(param1:Texture, param2:VertexData = null, param3:IndexData = null, param4:MeshStyle = null)
      {
         super(param2 == null ? new VertexData() : param2,param3 == null ? new IndexData() : param3,param4);
         this.texture = param1;
      }
      
      public function getVertexData() : VertexData
      {
         return this.vertexData;
      }
      
      public function getIndexData() : IndexData
      {
         return this.indexData;
      }
   }
}
