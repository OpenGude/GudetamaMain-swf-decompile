package muku.display
{
   import starling.animation.IAnimatable;
   import starling.core.Starling;
   import starling.display.Canvas;
   import starling.display.Image;
   import starling.display.Mesh;
   import starling.geom.Polygon;
   import starling.rendering.IndexData;
   import starling.rendering.VertexData;
   import starling.textures.Texture;
   
   public class CircleGauge extends Image implements IAnimatable
   {
       
      
      private var canvas:Canvas;
      
      private var polygon:Polygon;
      
      private var sides:Number = 8;
      
      private var _percent:Number = 1.0;
      
      private var _cycleTime:Number;
      
      private var _play:Boolean;
      
      private var elapsedTime:Number;
      
      private var _invert:Boolean;
      
      private var _reverse:Boolean;
      
      private var centerX:Number;
      
      private var centerY:Number;
      
      private var vertexData:VertexData;
      
      private var indexData:IndexData;
      
      private var mesh:Mesh;
      
      public function CircleGauge(param1:Texture)
      {
         vertexData = new VertexData();
         indexData = new IndexData();
         super(param1);
         _invert = false;
         _reverse = false;
         canvas = new Canvas();
         canvas.touchable = false;
         polygon = new Polygon();
         createMask(_percent);
         mask = canvas;
      }
      
      public function init() : void
      {
         _play = true;
         percent = 0;
         elapsedTime = 0;
         centerX = width / scaleX / 2;
         centerY = height / scaleY / 2;
      }
      
      public function start() : void
      {
         init();
         var _loc1_:* = Starling;
         starling.core.Starling.sCurrent.juggler.add(this);
      }
      
      public function play() : void
      {
         _play = true;
      }
      
      public function stop() : void
      {
         _play = false;
      }
      
      public function finish() : void
      {
         stop();
         dispatchEventWith("removeFromJuggler");
      }
      
      override public function dispose() : void
      {
         dispatchEventWith("removeFromJuggler");
         canvas.clear();
         canvas.dispose();
         super.dispose();
      }
      
      public function advanceTime(param1:Number) : void
      {
         if(!_play)
         {
            return;
         }
         elapsedTime += param1;
         var _loc2_:* = Number(elapsedTime / _cycleTime);
         if(_loc2_ >= 1)
         {
            _loc2_ = 1;
         }
         percent = _loc2_;
      }
      
      public function setCycleTime(param1:Number) : void
      {
         _cycleTime = param1;
      }
      
      private function updatePolygon(param1:Number, param2:Number = 50, param3:Number = 0, param4:Number = 0, param5:Number = 0) : void
      {
         var _loc7_:int = 0;
         polygon.addVertices(param3,param4);
         if(sides < 3)
         {
            sides = 3;
         }
         param2 /= Math.cos(1 / sides * 3.141592653589793);
         var _loc6_:int = Math.floor(param1 * sides);
         if(_reverse)
         {
            if(param1 * sides != _loc6_)
            {
               lineToRadians(polygon,param1 * (3.141592653589793 * 2) + param5,param2,param3,param4);
            }
            _loc7_ = _loc6_ + 1;
            while(_loc7_ <= sides)
            {
               lineToRadians(polygon,_loc7_ / sides * (3.141592653589793 * 2) + param5,param2,param3,param4);
               _loc7_++;
            }
         }
         else
         {
            _loc7_ = 0;
            while(_loc7_ <= _loc6_)
            {
               lineToRadians(polygon,_loc7_ / sides * (3.141592653589793 * 2) + param5,param2,param3,param4);
               _loc7_++;
            }
            if(param1 * sides != _loc6_)
            {
               lineToRadians(polygon,param1 * (3.141592653589793 * 2) + param5,param2,param3,param4);
            }
         }
      }
      
      private function lineToRadians(param1:Polygon, param2:Number, param3:Number, param4:Number, param5:Number) : void
      {
         param1.addVertices(Math.cos(param2) * param3 + param4,Math.sin(param2) * param3 + param5);
      }
      
      private function createMask(param1:Number) : void
      {
         var _loc2_:Number = width / 2;
         polygon.numVertices = 0;
         updatePolygon(param1,_loc2_,centerX,centerY,-1.5707963267948966);
         indexData.clear();
         vertexData.clear();
         canvas.scale = scale;
         canvas.clear();
         canvas.beginFill(16711680);
         polygon.triangulate(indexData);
         polygon.copyToVertexData(vertexData);
         vertexData.colorize("color",16711680,1);
         if(!mesh)
         {
            mesh = new Mesh(vertexData,indexData);
         }
         canvas.addChild(mesh);
         canvas.endFill();
      }
      
      public function get percent() : Number
      {
         return _percent;
      }
      
      public function set percent(param1:Number) : void
      {
         if(_percent != param1)
         {
            _percent = param1;
            if(_invert)
            {
               createMask(1 - _percent);
            }
            else
            {
               createMask(_percent);
            }
            setRequiresRedraw();
         }
      }
      
      public function get invert() : Boolean
      {
         return _invert;
      }
      
      public function set invert(param1:Boolean) : void
      {
         if(_invert == param1)
         {
            return;
         }
         _invert = param1;
      }
      
      public function get reverse() : Boolean
      {
         return _reverse;
      }
      
      public function set reverse(param1:Boolean) : void
      {
         if(_reverse == param1)
         {
            return;
         }
         _reverse = param1;
      }
   }
}
