package muku.display
{
   import flash.geom.Rectangle;
   import starling.display.Image;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class MaskedImage extends Image
   {
       
      
      private var _maskTexture:Texture;
      
      private var _maskImage:Image;
      
      private var _maskOrgWidth:Number;
      
      private var _maskOrgHeight:Number;
      
      private var _rect:Rectangle;
      
      private var _maskStyle:TextureMaskStyle;
      
      private var _maskAlphaThreshold:Number;
      
      public function MaskedImage(param1:Texture)
      {
         var tex:Texture = param1;
         super(tex);
         _maskAlphaThreshold = 0.5;
         addEventListener("addedToStage",function(param1:Event):void
         {
            removeEventListener("addedToStage",arguments.callee);
            maskScale9Grid = _rect;
         });
      }
      
      public function get maskTexture() : Texture
      {
         return _maskTexture;
      }
      
      public function set maskTexture(param1:Texture) : void
      {
         _maskTexture = param1;
         if(_maskTexture)
         {
            _maskImage = new Image(_maskTexture);
            _maskStyle = new TextureMaskStyle();
            _maskStyle.threshold = _maskAlphaThreshold;
            _maskImage.style = _maskStyle;
            _maskOrgWidth = _maskImage.width;
            _maskOrgHeight = _maskImage.height;
            maskScale9Grid = _rect;
            mask = _maskImage;
         }
         else
         {
            mask = null;
            _maskStyle = null;
         }
      }
      
      public function get maskAlphaThreshold() : Number
      {
         return _maskAlphaThreshold;
      }
      
      public function set maskAlphaThreshold(param1:Number) : void
      {
         _maskAlphaThreshold = param1;
         if(_maskStyle)
         {
            _maskStyle.threshold = _maskAlphaThreshold;
         }
      }
      
      public function get maskScale9Grid() : Rectangle
      {
         return _rect;
      }
      
      public function set maskScale9Grid(param1:Rectangle) : void
      {
         if(param1)
         {
            if(!_rect)
            {
               _rect = param1.clone();
            }
            else
            {
               _rect.copyFrom(param1);
            }
         }
         else
         {
            _rect = null;
         }
         if(!_maskImage)
         {
            return;
         }
         _maskStyle.scaleX = width / _maskOrgWidth;
         _maskStyle.scaleY = height / _maskOrgHeight;
         _maskStyle.scale9Grid = param1;
         mask = _maskImage;
      }
      
      override public function get scaleX() : Number
      {
         return super.scaleX;
      }
      
      override public function set scaleX(param1:Number) : void
      {
         super.scaleX = param1;
         if(_maskImage)
         {
            _maskImage.width = width / param1;
            _maskStyle.scaleX = width / _maskOrgWidth;
         }
      }
      
      override public function get scaleY() : Number
      {
         return super.scaleY;
      }
      
      override public function set scaleY(param1:Number) : void
      {
         super.scaleY = param1;
         if(_maskImage)
         {
            _maskImage.height = height / param1;
            _maskStyle.scaleY = height / _maskOrgHeight;
         }
      }
   }
}
