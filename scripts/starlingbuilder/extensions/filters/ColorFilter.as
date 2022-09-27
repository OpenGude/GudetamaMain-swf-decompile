package starlingbuilder.extensions.filters
{
   import starling.filters.ColorMatrixFilter;
   
   public class ColorFilter extends ColorMatrixFilter
   {
       
      
      private var _hue:Number = 0;
      
      private var _contrast:Number = 0;
      
      private var _brightness:Number = 0;
      
      private var _saturation:Number = 0;
      
      public function ColorFilter(param1:Vector.<Number> = null)
      {
         super(param1);
      }
      
      public function set hue(param1:Number) : void
      {
         _hue = param1;
         adjustValues();
      }
      
      public function get hue() : Number
      {
         return _hue;
      }
      
      public function set contrast(param1:Number) : void
      {
         _contrast = param1;
         adjustValues();
      }
      
      public function get contrast() : Number
      {
         return _contrast;
      }
      
      public function set brightness(param1:Number) : void
      {
         _brightness = param1;
         adjustValues();
      }
      
      public function get brightness() : Number
      {
         return _brightness;
      }
      
      public function set saturation(param1:Number) : void
      {
         _saturation = param1;
         adjustValues();
      }
      
      public function get saturation() : Number
      {
         return _saturation;
      }
      
      private function adjustValues() : void
      {
         reset();
         adjustHue(_hue);
         adjustBrightness(_brightness);
         adjustContrast(_contrast);
         adjustSaturation(_saturation);
      }
   }
}
