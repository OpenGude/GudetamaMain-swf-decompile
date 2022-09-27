package muku.display
{
   import feathers.controls.ToggleButton;
   import starling.display.Image;
   import starling.events.Event;
   import starling.events.TouchEvent;
   import starling.extensions.ColorOffsetStyle;
   import starling.textures.Texture;
   
   public class ToggleButton extends feathers.controls.ToggleButton
   {
       
      
      private var _defaultTexture:Texture;
      
      private var _defaultImage:Image;
      
      private var _selectedTexture:Texture;
      
      private var _selectedImage:Image;
      
      private var defaultColorStyle:ColorOffsetStyle;
      
      private var selectedColorStyle:ColorOffsetStyle;
      
      private var _defaultColorOffset:Number = 0.0;
      
      private var stopPropagate:Boolean;
      
      public function ToggleButton()
      {
         super();
         scaleWhenDown = 1;
         defaultColorStyle = new ColorOffsetStyle();
         selectedColorStyle = new ColorOffsetStyle();
         addEventListener("touch",onTouch);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         _defaultImage.dispose();
         _selectedImage.dispose();
         defaultColorStyle = null;
         selectedColorStyle = null;
      }
      
      override protected function initialize() : void
      {
         super.initialize();
         addEventListener("creationComplete",creationComplete);
      }
      
      protected function creationComplete(param1:Event) : void
      {
         removeEventListener("creationComplete",creationComplete);
         defaultSkin = _defaultImage;
         defaultSelectedSkin = _selectedImage;
         setSkinForState("down",null);
      }
      
      override protected function changeState(param1:String) : void
      {
         super.changeState(param1);
         if(param1 == "down")
         {
            defaultColorStyle.setTo(0.15,0.15,0.15);
            selectedColorStyle.setTo(0.15,0.15,0.15);
         }
         else
         {
            defaultColorStyle.setTo(_defaultColorOffset,_defaultColorOffset,_defaultColorOffset);
            selectedColorStyle.setTo();
         }
      }
      
      private function onTouch(param1:TouchEvent) : void
      {
         if(stopPropagate)
         {
            param1.stopPropagation();
         }
      }
      
      public function setStopPropagation(param1:Boolean) : void
      {
         stopPropagate = param1;
      }
      
      public function setToggleChangeCallback(param1:Function) : void
      {
         var callback:Function = param1;
         addEventListener("triggered",function(param1:Event):void
         {
            isSelected = !isSelected;
            callback(isSelected);
         });
      }
      
      public function set defaultColorOffset(param1:Number) : void
      {
         _defaultColorOffset = param1;
      }
      
      public function get defaultColorOffset() : Number
      {
         return _defaultColorOffset;
      }
      
      public function set defaultTexture(param1:Texture) : void
      {
         if(_defaultTexture)
         {
            _defaultImage.dispose();
            _defaultImage = null;
         }
         _defaultTexture = param1;
         _defaultImage = new Image(_defaultTexture);
         if(isInitialized)
         {
            defaultSkin = _defaultImage;
         }
         this.invalidate("data");
         _defaultImage.style = defaultColorStyle;
      }
      
      public function get defaultTexture() : Texture
      {
         return _defaultTexture;
      }
      
      public function set selectedTexture(param1:Texture) : void
      {
         if(_selectedTexture)
         {
            _selectedImage.dispose();
            _selectedImage = null;
         }
         _selectedTexture = param1;
         _selectedImage = new Image(_selectedTexture);
         if(isInitialized)
         {
            defaultSelectedSkin = _selectedImage;
         }
         this.invalidate("data");
         _selectedImage.style = selectedColorStyle;
      }
      
      public function get selectedTexture() : Texture
      {
         return _selectedTexture;
      }
   }
}
