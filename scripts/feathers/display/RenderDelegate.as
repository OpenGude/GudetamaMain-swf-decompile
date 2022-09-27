package feathers.display
{
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import starling.display.DisplayObject;
   import starling.rendering.Painter;
   import starling.utils.MatrixUtil;
   import starling.utils.Pool;
   
   public class RenderDelegate extends DisplayObject
   {
      
      private static const HELPER_POINT:Point = new Point();
       
      
      protected var _target:DisplayObject;
      
      public function RenderDelegate(param1:DisplayObject)
      {
         super();
         this.target = param1;
      }
      
      public function get target() : DisplayObject
      {
         return this._target;
      }
      
      public function set target(param1:DisplayObject) : void
      {
         if(this._target === param1)
         {
            return;
         }
         this._target = param1;
         this.setRequiresRedraw();
      }
      
      override public function getBounds(param1:DisplayObject, param2:Rectangle = null) : Rectangle
      {
         var _loc7_:int = 0;
         param2 = this._target.getBounds(this._target,param2);
         var _loc8_:Matrix = Pool.getMatrix();
         this.getTransformationMatrix(param1,_loc8_);
         var _loc4_:* = 1.7976931348623157e+308;
         var _loc6_:* = -1.7976931348623157e+308;
         var _loc3_:* = 1.7976931348623157e+308;
         var _loc5_:* = -1.7976931348623157e+308;
         _loc7_ = 0;
         while(_loc7_ < 4)
         {
            MatrixUtil.transformCoords(_loc8_,_loc7_ % 2 == 0 ? 0 : Number(param2.width),_loc7_ < 2 ? 0 : Number(param2.height),HELPER_POINT);
            if(HELPER_POINT.x < _loc4_)
            {
               _loc4_ = Number(HELPER_POINT.x);
            }
            if(HELPER_POINT.x > _loc6_)
            {
               _loc6_ = Number(HELPER_POINT.x);
            }
            if(HELPER_POINT.y < _loc3_)
            {
               _loc3_ = Number(HELPER_POINT.y);
            }
            if(HELPER_POINT.y > _loc5_)
            {
               _loc5_ = Number(HELPER_POINT.y);
            }
            _loc7_++;
         }
         Pool.putMatrix(_loc8_);
         param2.setTo(_loc4_,_loc3_,_loc6_ - _loc4_,_loc5_ - _loc3_);
         return param2;
      }
      
      override public function render(param1:Painter) : void
      {
         var _loc2_:Boolean = param1.cacheEnabled;
         param1.cacheEnabled = false;
         this._target.render(param1);
         param1.cacheEnabled = _loc2_;
         param1.excludeFromCache(this);
      }
   }
}
