package spine.starling
{
   import spine.Bone;
   import spine.Skin;
   import spine.attachments.AttachmentLoader;
   import spine.attachments.BoundingBoxAttachment;
   import spine.attachments.MeshAttachment;
   import spine.attachments.PathAttachment;
   import spine.attachments.RegionAttachment;
   import starling.display.Image;
   import starling.textures.SubTexture;
   import starling.textures.Texture;
   
   public class StarlingTextureAttachmentLoader implements AttachmentLoader
   {
       
      
      private var texture:Texture;
      
      public function StarlingTextureAttachmentLoader(param1:Texture)
      {
         super();
         texture = param1;
         Bone.yDown = true;
      }
      
      public function newRegionAttachment(param1:Skin, param2:String, param3:String) : RegionAttachment
      {
         if(texture == null)
         {
            throw new Error("Region not found in Starling texture:  (region attachment: " + param2 + ")");
         }
         var _loc4_:RegionAttachment;
         (_loc4_ = new RegionAttachment(param2)).rendererObject = new Image(Texture.fromTexture(texture));
         _loc4_.regionOffsetX = 0;
         _loc4_.regionOffsetY = 0;
         _loc4_.regionWidth = texture.width;
         _loc4_.regionHeight = texture.height;
         _loc4_.regionOriginalWidth = texture.width;
         _loc4_.regionOriginalHeight = texture.height;
         _loc4_.x = 0;
         _loc4_.y = 0;
         _loc4_.rotation = 0;
         _loc4_.width = texture.width;
         _loc4_.height = texture.height;
         _loc4_["regionU"] = 0;
         _loc4_["regionV"] = 0;
         _loc4_["regionU2"] = texture.width / texture.root.width;
         _loc4_["regionV2"] = texture.height / texture.root.height;
         _loc4_.setUVs(_loc4_["regionU"],_loc4_["regionV"],_loc4_["regionU2"],_loc4_["regionV2"],false);
         _loc4_.updateOffset();
         return _loc4_;
      }
      
      public function newMeshAttachment(param1:Skin, param2:String, param3:String) : MeshAttachment
      {
         if(texture == null)
         {
            throw new Error("Region not found in Starling texture:  (mesh attachment: " + param2 + ")");
         }
         var _loc4_:MeshAttachment;
         (_loc4_ = new MeshAttachment(param2)).rendererObject = new Image(Texture.fromTexture(texture));
         var _loc5_:SubTexture = texture as SubTexture;
         _loc4_.x = 0;
         _loc4_.y = 0;
         _loc4_.rotation = 0;
         _loc4_.regionU = 0;
         _loc4_.regionV = 0;
         _loc4_.regionU2 = texture.width / texture.root.width;
         _loc4_.regionV2 = texture.height / texture.root.height;
         _loc4_.regionOffsetX = 0;
         _loc4_.regionOffsetY = 0;
         _loc4_.regionWidth = texture.width;
         _loc4_.regionHeight = texture.height;
         _loc4_.regionOriginalWidth = texture.width;
         _loc4_.regionOriginalHeight = texture.height;
         return _loc4_;
      }
      
      public function newBoundingBoxAttachment(param1:Skin, param2:String) : BoundingBoxAttachment
      {
         return new BoundingBoxAttachment(param2);
      }
      
      public function newPathAttachment(param1:Skin, param2:String) : PathAttachment
      {
         return new PathAttachment(param2);
      }
   }
}
