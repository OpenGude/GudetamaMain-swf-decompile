package starling.display
{
   import flash.geom.Point;
   import starling.geom.Polygon;
   import starling.rendering.IndexData;
   import starling.rendering.VertexData;
   
   public class Canvas extends DisplayObjectContainer
   {
       
      
      private var _polygons:Vector.<Polygon>;
      
      private var _fillColor:uint;
      
      private var _fillAlpha:Number;
      
      public function Canvas()
      {
         super();
         _polygons = new Vector.<Polygon>(0);
         _fillColor = 16777215;
         _fillAlpha = 1;
         touchGroup = true;
      }
      
      override public function dispose() : void
      {
         _polygons.length = 0;
         super.dispose();
      }
      
      override public function hitTest(param1:Point) : DisplayObject
      {
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         if(!visible || !touchable || !hitTestMask(param1))
         {
            return null;
         }
         _loc3_ = 0;
         _loc2_ = _polygons.length;
         while(_loc3_ < _loc2_)
         {
            if(_polygons[_loc3_].containsPoint(param1))
            {
               return this;
            }
            _loc3_++;
         }
         return null;
      }
      
      public function drawCircle(param1:Number, param2:Number, param3:Number) : void
      {
         appendPolygon(Polygon.createCircle(param1,param2,param3));
      }
      
      public function drawEllipse(param1:Number, param2:Number, param3:Number, param4:Number) : void
      {
         var _loc6_:Number = param3 / 2;
         var _loc5_:Number = param4 / 2;
         appendPolygon(Polygon.createEllipse(param1 + _loc6_,param2 + _loc5_,_loc6_,_loc5_));
      }
      
      public function drawRectangle(param1:Number, param2:Number, param3:Number, param4:Number) : void
      {
         appendPolygon(Polygon.createRectangle(param1,param2,param3,param4));
      }
      
      public function drawPolygon(param1:Polygon) : void
      {
         appendPolygon(param1);
      }
      
      public function beginFill(param1:uint = 16777215, param2:Number = 1.0) : void
      {
         _fillColor = param1;
         _fillAlpha = param2;
      }
      
      public function endFill() : void
      {
         _fillColor = 16777215;
         _fillAlpha = 1;
      }
      
      public function clear() : void
      {
         removeChildren(0,-1,true);
         _polygons.length = 0;
      }
      
      private function appendPolygon(param1:Polygon) : void
      {
         var _loc2_:VertexData = new VertexData();
         var _loc3_:IndexData = new IndexData(param1.numTriangles * 3);
         param1.triangulate(_loc3_);
         param1.copyToVertexData(_loc2_);
         _loc2_.colorize("color",_fillColor,_fillAlpha);
         addChild(new Mesh(_loc2_,_loc3_));
         _polygons[_polygons.length] = param1;
      }
   }
}
