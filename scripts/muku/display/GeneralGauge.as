package muku.display
{
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.textures.Texture;
   
   public class GeneralGauge extends Sprite
   {
       
      
      private var _texture:Texture;
      
      private var _image:Image;
      
      private var _percent:Number;
      
      private var _fromLeft:Boolean = true;
      
      private var _fromUp:Boolean = true;
      
      private var horizontalMode:Boolean = true;
      
      public function GeneralGauge(param1:Texture, param2:Number = 1.0)
      {
         super();
         _texture = param1;
         _image = new Image(_texture);
         addChild(_image);
         percent = param2;
      }
      
      public function get horizontal() : Boolean
      {
         return horizontalMode;
      }
      
      public function set horizontal(param1:Boolean) : void
      {
         if(horizontalMode == param1)
         {
            return;
         }
         horizontalMode = param1;
         percent = _percent;
      }
      
      public function get fromUp() : Boolean
      {
         return _fromUp;
      }
      
      public function set fromUp(param1:Boolean) : void
      {
         _fromUp = param1;
         if(_fromUp)
         {
            _image.setTexCoords(0,0,0);
            _image.setTexCoords(1,1,0);
         }
         else
         {
            _image.setTexCoords(2,0,1);
            _image.setTexCoords(3,1,1);
         }
         percent = _percent;
      }
      
      public function get fromLeft() : Boolean
      {
         return _fromLeft;
      }
      
      public function set fromLeft(param1:Boolean) : void
      {
         _fromLeft = param1;
         if(_fromLeft)
         {
            _image.setTexCoords(1,1,0);
            _image.setTexCoords(3,1,1);
         }
         else
         {
            _image.setTexCoords(0,0,0);
            _image.setTexCoords(2,0,1);
         }
         percent = _percent;
      }
      
      public function get percent() : Number
      {
         return _percent;
      }
      
      public function set percent(param1:Number) : void
      {
         _percent = param1;
         if(horizontal)
         {
            if(_fromLeft)
            {
               _image.scaleX = _percent;
               _image.x = _image.texture.width * (1 - _percent);
               _image.setTexCoords(0,1 - _percent,0);
               _image.setTexCoords(2,1 - _percent,1);
            }
            else
            {
               _image.scaleX = _percent;
               _image.setTexCoords(1,_percent,0);
               _image.setTexCoords(3,_percent,1);
            }
         }
         else if(_fromUp)
         {
            _image.scaleY = _percent;
            _image.y = _image.texture.height * (1 - _percent);
            _image.setTexCoords(0,0,1 - _percent);
            _image.setTexCoords(1,1,1 - _percent);
         }
         else
         {
            _image.scaleY = _percent;
            _image.setTexCoords(2,0,_percent);
            _image.setTexCoords(3,1,_percent);
         }
         setRequiresRedraw();
      }
      
      public function get texture() : Texture
      {
         return _texture;
      }
      
      public function set texture(param1:Texture) : void
      {
         _texture = param1;
         if(_texture == null)
         {
            return;
         }
         _image.texture = _texture;
      }
      
      public function get color() : uint
      {
         return _image.color;
      }
      
      public function set color(param1:uint) : void
      {
         _image.color = param1;
      }
   }
}
