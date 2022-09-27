package starlingbuilder.engine.util
{
   import flash.display.DisplayObject;
   import flash.display.Stage;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.system.Capabilities;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   import starling.display.Stage;
   import starling.utils.RectangleUtil;
   
   public class StageUtil
   {
       
      
      private var _stage:flash.display.Stage;
      
      private var _designStageWidth:int;
      
      private var _designStageHeight:int;
      
      public function StageUtil(param1:flash.display.Stage, param2:int = 640, param3:int = 960)
      {
         super();
         _stage = param1;
         _designStageWidth = param2;
         _designStageHeight = param3;
      }
      
      public static function isAndroid() : Boolean
      {
         return Capabilities.manufacturer.indexOf("Android") != -1;
      }
      
      public static function isiOS() : Boolean
      {
         return Capabilities.manufacturer.indexOf("iOS") != -1;
      }
      
      public static function fitNativeBackground(param1:flash.display.DisplayObject, param2:flash.display.Stage) : void
      {
         var _loc4_:Rectangle = new Rectangle(0,0,param1.width,param1.height);
         var _loc5_:Rectangle = new Rectangle(0,0,param2.stageWidth,param2.stageHeight);
         var _loc3_:Rectangle = RectangleUtil.fit(_loc4_,_loc5_,"noBorder");
         param1.x = _loc3_.x;
         param1.y = _loc3_.y;
         param1.width = _loc3_.width;
         param1.height = _loc3_.height;
      }
      
      public static function fitBackground(param1:starling.display.DisplayObject) : void
      {
         var _loc6_:* = Starling;
         var _loc3_:starling.display.Stage = starling.core.Starling.sCurrent.stage;
         var _loc4_:Rectangle = new Rectangle(0,0,param1.width,param1.height);
         var _loc5_:Rectangle = new Rectangle(0,0,_loc3_.stageWidth,_loc3_.stageHeight);
         var _loc2_:Rectangle = RectangleUtil.fit(_loc4_,_loc5_,"noBorder");
         param1.x = _loc2_.x;
         param1.y = _loc2_.y;
         param1.width = _loc2_.width;
         param1.height = _loc2_.height;
      }
      
      public function get stageWidth() : int
      {
         var _loc2_:Boolean = isiOS();
         var _loc1_:Boolean = isAndroid();
         if(_loc2_ || _loc1_)
         {
            return _stage.fullScreenWidth;
         }
         return _stage.stageWidth;
      }
      
      public function get stageHeight() : int
      {
         var _loc2_:Boolean = isiOS();
         var _loc1_:Boolean = isAndroid();
         if(_loc2_ || _loc1_)
         {
            return _stage.fullScreenHeight;
         }
         return _stage.stageHeight;
      }
      
      public function getScaledStageSize(param1:int = 0, param2:int = 0) : Point
      {
         var _loc3_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc8_:Number = NaN;
         if(param1 == 0 || param2 == 0)
         {
            param1 = this.stageWidth;
            param2 = this.stageHeight;
         }
         var _loc7_:* = param1 < param2 != _designStageWidth < _designStageHeight;
         if(_loc7_ = false)
         {
            _loc3_ = _designStageHeight;
            _loc5_ = _designStageWidth;
         }
         else
         {
            _loc3_ = _designStageWidth;
            _loc5_ = _designStageHeight;
         }
         var _loc4_:Number = 1 * _loc3_ / _loc5_;
         if(1 * param1 / param2 <= _loc4_)
         {
            _loc8_ = _designStageWidth / param1;
         }
         else
         {
            _loc8_ = _designStageHeight / param2;
         }
         _loc6_ = _loc8_ * param1;
         _loc9_ = _loc8_ * param2;
         return new Point(Math.round(_loc6_),Math.round(_loc9_));
      }
   }
}
