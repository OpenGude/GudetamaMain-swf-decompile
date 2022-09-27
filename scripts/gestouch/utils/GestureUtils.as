package gestouch.utils
{
   import flash.geom.Point;
   import flash.system.Capabilities;
   
   public class GestureUtils
   {
      
      public static const IPS_TO_PPMS:Number = Capabilities.screenDPI * 0.001;
      
      public static const RADIANS_TO_DEGREES:Number = 57.29577951308232;
      
      public static const DEGREES_TO_RADIANS:Number = 0.017453292519943295;
      
      public static const PI_DOUBLE:Number = 6.283185307179586;
      
      public static const GLOBAL_ZERO:Point = new Point();
       
      
      public function GestureUtils()
      {
         super();
      }
   }
}
