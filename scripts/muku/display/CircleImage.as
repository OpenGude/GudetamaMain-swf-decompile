package muku.display
{
   import starling.display.Canvas;
   import starling.display.Image;
   import starling.display.Mesh;
   import starling.geom.Polygon;
   import starling.rendering.IndexData;
   import starling.rendering.VertexData;
   import starling.textures.Texture;
   
   public class CircleImage extends Image
   {
       
      
      private var canvas:Canvas;
      
      private var centerX:Number;
      
      private var centerY:Number;
      
      private var polygonMap:Object;
      
      private var vertexMap:Object;
      
      private var indexMap:Object;
      
      private var meshMap:Object;
      
      private var sides:Number = 8;
      
      public function CircleImage(param1:Texture)
      {
         polygonMap = {};
         vertexMap = {};
         indexMap = {};
         meshMap = {};
         super(param1);
         canvas = new Canvas();
         canvas.touchable = false;
         mask = canvas;
      }
      
      public function init() : void
      {
         centerX = width / scaleX / 2;
         centerY = height / scaleY / 2;
      }
      
      public function setup(param1:Array) : void
      {
         var _loc2_:Number = NaN;
         var _loc4_:Number = NaN;
         canvas.clear();
         for(var _loc3_ in param1)
         {
            _loc2_ = param1[_loc3_][0];
            _loc4_ = param1[_loc3_][1];
            createMask(_loc3_,_loc2_,_loc4_);
         }
      }
      
      private function getPolygon(param1:int) : Polygon
      {
         if(!polygonMap[param1])
         {
            polygonMap[param1] = new Polygon();
         }
         return polygonMap[param1];
      }
      
      private function getVertexData(param1:int) : VertexData
      {
         if(!vertexMap[param1])
         {
            vertexMap[param1] = new VertexData();
         }
         return vertexMap[param1];
      }
      
      private function getIndexData(param1:int) : IndexData
      {
         if(!indexMap[param1])
         {
            indexMap[param1] = new IndexData();
         }
         return indexMap[param1];
      }
      
      private function createMask(param1:int, param2:Number, param3:Number) : void
      {
         var _loc7_:Number = width / 2;
         var _loc4_:Polygon;
         (_loc4_ = getPolygon(param1)).numVertices = 0;
         updatePolygon(_loc4_,param2,param3,_loc7_,centerX,centerY,-1.5707963267948966);
         var _loc6_:IndexData;
         (_loc6_ = getIndexData(param1)).clear();
         var _loc5_:VertexData;
         (_loc5_ = getVertexData(param1)).clear();
         canvas.scale = scale;
         _loc4_.triangulate(_loc6_);
         _loc4_.copyToVertexData(_loc5_);
         if(!meshMap[param1])
         {
            meshMap[param1] = new Mesh(_loc5_,_loc6_);
         }
         canvas.addChild(meshMap[param1]);
      }
      
      private function updatePolygon(param1:Polygon, param2:Number, param3:Number, param4:Number = 50, param5:Number = 0, param6:Number = 0, param7:Number = 0) : void
      {
         var _loc8_:* = 0;
         param1.addVertices(param5,param6);
         if(sides < 3)
         {
            sides = 3;
         }
         param4 /= Math.cos(1 / sides * 3.141592653589793);
         var _loc10_:int = Math.ceil(param2 * sides);
         var _loc9_:int = Math.floor(param3 * sides);
         if(param2 * sides != _loc10_)
         {
            lineToRadians(param1,param2 * (3.141592653589793 * 2) + param7,param4,param5,param6);
         }
         _loc8_ = _loc10_;
         while(_loc8_ <= _loc9_)
         {
            lineToRadians(param1,_loc8_ / sides * (3.141592653589793 * 2) + param7,param4,param5,param6);
            _loc8_++;
         }
         if(param3 * sides != _loc9_)
         {
            lineToRadians(param1,param3 * (3.141592653589793 * 2) + param7,param4,param5,param6);
         }
      }
      
      private function lineToRadians(param1:Polygon, param2:Number, param3:Number, param4:Number, param5:Number) : void
      {
         param1.addVertices(Math.cos(param2) * param3 + param4,Math.sin(param2) * param3 + param5);
      }
      
      override public function dispose() : void
      {
         var _loc2_:* = null;
         var _loc3_:* = null;
         var _loc4_:* = null;
         canvas.clear();
         canvas.dispose();
         for(var _loc1_ in polygonMap)
         {
            delete polygonMap[_loc1_];
         }
         polygonMap = null;
         for(_loc1_ in vertexMap)
         {
            _loc2_ = vertexMap[_loc1_];
            _loc2_.clear();
            delete vertexMap[_loc1_];
         }
         vertexMap = null;
         for(_loc1_ in indexMap)
         {
            _loc3_ = indexMap[_loc1_];
            _loc3_.clear();
            delete indexMap[_loc1_];
         }
         indexMap = null;
         for(_loc1_ in meshMap)
         {
            (_loc4_ = meshMap[_loc1_]).dispose();
            delete meshMap[_loc1_];
         }
         meshMap = null;
         super.dispose();
      }
   }
}
