package gestouch.extensions.starling
{
   import flash.geom.Point;
   import gestouch.core.ITouchHitTester;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   
   public class StarlingTouchHitTester implements ITouchHitTester
   {
       
      
      private var starling:Starling;
      
      public function StarlingTouchHitTester(param1:Starling)
      {
         super();
         if(!param1)
         {
            throw ArgumentError("Missing starling argument.");
         }
         this.starling = param1;
      }
      
      public function hitTest(param1:Point, param2:Object = null) : Object
      {
         if(param2 && param2 is DisplayObject)
         {
            return param2;
         }
         param1 = StarlingUtils.adjustGlobalPoint(starling,param1);
         return starling.stage.hitTest(param1);
      }
   }
}
