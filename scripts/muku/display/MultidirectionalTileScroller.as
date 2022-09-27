package muku.display
{
   import flash.geom.Point;
   import muku.core.MukuGlobal;
   import starling.display.DisplayObjectContainer;
   import starling.display.Image;
   import starling.display.MeshBatch;
   import starling.events.EnterFrameEvent;
   import starling.textures.Texture;
   
   public class MultidirectionalTileScroller extends DisplayObjectContainer
   {
       
      
      private var m_Canvas:MeshBatch;
      
      private var m_Width:uint;
      
      private var m_Height:uint;
      
      private var m_Texture:Texture;
      
      private var m_Image:Image;
      
      private var m_TextureNativeWidth:Number;
      
      private var m_TextureNativeHeight:Number;
      
      private var m_TextureScaleX:Number = 1.0;
      
      private var m_TextureScaleY:Number = 1.0;
      
      private var m_TextureWidth:Number;
      
      private var m_TextureHeight:Number;
      
      private var m_PivotPoint:Point;
      
      private var m_IsAnimating:Boolean;
      
      private var m_Speed:Number = 0.0;
      
      private var m_Angle:Number = 0.0;
      
      private var _maskTexture:Texture;
      
      private var _maskImage:Image;
      
      private var _color:uint = 16777215;
      
      public function MultidirectionalTileScroller(param1:Texture)
      {
         super();
         m_Texture = param1;
         m_Width = m_Texture.width;
         m_Height = m_Texture.height;
         m_TextureScaleX = textureScaleX;
         m_TextureScaleY = textureScaleY;
         init();
      }
      
      private function init() : void
      {
         touchable = MukuGlobal.isBuilderMode();
         drawTexture();
      }
      
      private function drawTexture() : void
      {
         m_TextureNativeWidth = m_Texture.nativeWidth;
         m_TextureNativeHeight = m_Texture.nativeHeight;
         m_Image = new Image(m_Texture);
         m_Image.scaleX = m_TextureScaleX;
         m_Image.scaleY = m_TextureScaleY;
         drawCanvas();
      }
      
      private function drawCanvas() : void
      {
         var _loc1_:* = 0;
         var _loc2_:* = 0;
         if(numChildren)
         {
            removeChildren();
         }
         m_Canvas = new MeshBatch();
         _loc1_ = uint(0);
         while(_loc1_ <= Math.ceil(m_Width / (m_TextureNativeWidth * m_TextureScaleX)) + 1)
         {
            _loc2_ = uint(0);
            while(_loc2_ <= Math.ceil(m_Height / (m_TextureNativeHeight * m_TextureScaleY)) + 1)
            {
               m_Image.x = m_TextureNativeWidth * m_TextureScaleX * _loc1_;
               m_Image.y = m_TextureNativeHeight * m_TextureScaleY * _loc2_;
               m_Image.color = _color;
               m_Canvas.addMesh(m_Image);
               _loc2_++;
            }
            _loc1_++;
         }
         m_TextureWidth = m_TextureNativeWidth * m_TextureScaleX;
         m_TextureHeight = m_TextureNativeHeight * m_TextureScaleY;
         m_PivotPoint = new Point(m_Width / 2,m_Height / 2);
         m_Canvas.alignPivot();
         m_Canvas.x = m_PivotPoint.x;
         m_Canvas.y = m_PivotPoint.y;
         if(_maskImage)
         {
            _maskImage.alignPivot();
            _maskImage.x = m_PivotPoint.x;
            _maskImage.y = m_PivotPoint.y;
         }
         addChild(m_Canvas);
      }
      
      public function play(param1:Number = NaN, param2:Number = NaN) : void
      {
         this.speed = !!isNaN(param1) ? this.speed : Number(param1);
         this.angle = !!isNaN(param1) ? this.angle : Number(param2);
         m_IsAnimating = true;
         if(!m_Canvas.hasEventListener("enterFrame"))
         {
            m_Canvas.addEventListener("enterFrame",enterFrameEventHandler);
         }
      }
      
      public function stop() : void
      {
         m_IsAnimating = false;
         if(m_Canvas.hasEventListener("enterFrame"))
         {
            m_Canvas.removeEventListener("enterFrame",enterFrameEventHandler);
         }
      }
      
      private function enterFrameEventHandler(param1:EnterFrameEvent) : void
      {
         m_Canvas.x += Math.cos(m_Angle) * m_Speed;
         m_Canvas.y += Math.sin(m_Angle) * m_Speed;
         if(m_Canvas.x < m_PivotPoint.x - m_TextureWidth)
         {
            m_Canvas.x += m_TextureWidth;
         }
         if(m_Canvas.x > m_PivotPoint.x + m_TextureWidth)
         {
            m_Canvas.x -= m_TextureWidth;
         }
         if(m_Canvas.y < m_PivotPoint.y - m_TextureHeight)
         {
            m_Canvas.y += m_TextureHeight;
         }
         if(m_Canvas.y > m_PivotPoint.y + m_TextureHeight)
         {
            m_Canvas.y -= m_TextureHeight;
         }
      }
      
      override public function dispose() : void
      {
         stop();
         m_Texture.dispose();
         super.dispose();
      }
      
      public function setTexture(param1:Texture, param2:Number = 1.0, param3:Number = 1.0) : void
      {
         if(isAnimating)
         {
            stop();
         }
         if(m_Texture)
         {
            m_Texture.dispose();
         }
         m_Texture = param1;
         m_TextureScaleX = param2;
         m_TextureScaleY = m_TextureScaleY;
         drawTexture();
      }
      
      public function setSize(param1:uint, param2:uint) : void
      {
         m_Width = param1;
         m_Height = param2;
         drawCanvas();
         setRequiresRedraw();
      }
      
      public function get isAnimating() : Boolean
      {
         return m_IsAnimating;
      }
      
      public function get speed() : Number
      {
         return m_Speed;
      }
      
      public function set speed(param1:Number) : void
      {
         m_Speed = isNaN(param1) || param1 <= 0 ? 0 : Number(Math.min(param1,Math.min(m_TextureWidth,m_TextureHeight)));
      }
      
      public function get angle() : Number
      {
         return 180 - m_Angle * 180 / 3.141592653589793;
      }
      
      public function set angle(param1:Number) : void
      {
         m_Angle = (!!isNaN(param1) ? 180 : Number(180 - param1)) * 3.141592653589793 / 180;
      }
      
      public function get textureWidth() : Number
      {
         return m_Width;
      }
      
      public function set textureWidth(param1:Number) : void
      {
         m_Width = param1;
         setSize(m_Width,m_Height);
      }
      
      public function get textureHeight() : Number
      {
         return m_Height;
      }
      
      public function set textureHeight(param1:Number) : void
      {
         m_Height = param1;
         setSize(m_Width,m_Height);
      }
      
      public function get textureScaleX() : Number
      {
         return m_TextureScaleX;
      }
      
      public function set textureScaleX(param1:Number) : void
      {
         m_TextureScaleX = param1;
         setTexture(m_Texture,m_TextureScaleX,m_TextureScaleY);
      }
      
      public function get textureScaleY() : Number
      {
         return m_TextureScaleY;
      }
      
      public function set textureScaleY(param1:Number) : void
      {
         m_TextureScaleY = param1;
         setTexture(m_Texture,m_TextureScaleX,m_TextureScaleY);
      }
      
      public function get texture() : Texture
      {
         return m_Texture;
      }
      
      public function set texture(param1:Texture) : void
      {
         m_Texture = texture;
         setTexture(m_Texture,m_TextureScaleX,m_TextureScaleY);
      }
      
      public function get maskTexture() : Texture
      {
         return _maskTexture;
      }
      
      public function set maskTexture(param1:Texture) : void
      {
         var _loc2_:* = null;
         _maskTexture = param1;
         if(_maskTexture)
         {
            _maskImage = new Image(_maskTexture);
            _loc2_ = new TextureMaskStyle();
            _maskImage.style = _loc2_;
            mask = _maskImage;
         }
         else
         {
            mask = null;
         }
      }
      
      public function get color() : uint
      {
         return _color;
      }
      
      public function set color(param1:uint) : void
      {
         if(_color == param1)
         {
            return;
         }
         _color = param1;
         drawCanvas();
      }
      
      public function cleanUpForBuilder() : void
      {
         removeChild(m_Canvas);
      }
   }
}
