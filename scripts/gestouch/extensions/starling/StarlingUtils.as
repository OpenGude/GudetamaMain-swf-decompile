package gestouch.extensions.starling
{
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import starling.core.Starling;
   import starling.display.Stage;
   
   public final class StarlingUtils
   {
       
      
      public function StarlingUtils()
      {
         super();
      }
      
      public static function adjustGlobalPoint(param1:Starling, param2:Point) : Point
      {
         var _loc3_:Rectangle = param1.viewPort;
         var _loc4_:Stage = param1.stage;
         if(_loc3_.x != 0 || _loc3_.y != 0 || _loc4_.stageWidth != _loc3_.width || _loc4_.stageHeight != _loc3_.height)
         {
            param2 = param2.clone();
            param2.x = _loc4_.stageWidth * (param2.x - _loc3_.x) / _loc3_.width;
            param2.y = _loc4_.stageHeight * (param2.y - _loc3_.y) / _loc3_.height;
         }
         return param2;
      }
   }
}
