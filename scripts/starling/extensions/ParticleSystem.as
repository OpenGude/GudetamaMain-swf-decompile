package starling.extensions
{
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import starling.animation.IAnimatable;
   import starling.display.BlendMode;
   import starling.display.DisplayObject;
   import starling.display.Mesh;
   import starling.rendering.IndexData;
   import starling.rendering.MeshEffect;
   import starling.rendering.Painter;
   import starling.rendering.VertexData;
   import starling.styles.MeshStyle;
   import starling.textures.Texture;
   import starling.utils.MatrixUtil;
   
   public class ParticleSystem extends Mesh implements IAnimatable
   {
      
      public static const MAX_NUM_PARTICLES:int = 16383;
      
      private static var sHelperMatrix:Matrix = new Matrix();
      
      private static var sHelperPoint:Point = new Point();
       
      
      private var _effect:MeshEffect;
      
      private var _vertexData:VertexData;
      
      private var _indexData:IndexData;
      
      private var _requiresSync:Boolean;
      
      private var _batchable:Boolean;
      
      private var _particles:Vector.<Particle>;
      
      private var _frameTime:Number;
      
      private var _numParticles:int;
      
      private var _emissionRate:Number;
      
      private var _emissionTime:Number;
      
      private var _emitterX:Number;
      
      private var _emitterY:Number;
      
      private var _blendFactorSource:String;
      
      private var _blendFactorDestination:String;
      
      protected var mEmitterPoint:Point;
      
      protected var mEmitterObject:DisplayObject;
      
      protected var mTargetSpace:DisplayObject;
      
      public function ParticleSystem(param1:Texture = null)
      {
         _vertexData = new VertexData();
         _indexData = new IndexData();
         super(_vertexData,_indexData);
         _particles = new Vector.<Particle>(0,false);
         _frameTime = 0;
         _emitterX = _emitterY = 0;
         mEmitterPoint = new Point(0,0);
         _emissionTime = 0;
         _emissionRate = 10;
         _blendFactorSource = "one";
         _blendFactorDestination = "oneMinusSourceAlpha";
         _batchable = false;
         this.capacity = 128;
         this.texture = param1;
         updateBlendMode();
      }
      
      override public function dispose() : void
      {
         _effect.dispose();
         mEmitterObject = null;
         mTargetSpace = null;
         super.dispose();
      }
      
      override public function hitTest(param1:Point) : DisplayObject
      {
         return null;
      }
      
      private function updateBlendMode() : void
      {
         var _loc1_:Boolean = !!texture ? texture.premultipliedAlpha : true;
         if(_blendFactorSource == "one" && _blendFactorDestination == "oneMinusSourceAlpha")
         {
            _vertexData.premultipliedAlpha = _loc1_;
            if(!_loc1_)
            {
               _blendFactorSource = "sourceAlpha";
            }
         }
         else
         {
            _vertexData.premultipliedAlpha = false;
         }
         blendMode = _blendFactorSource + ", " + _blendFactorDestination;
         BlendMode.register(blendMode,_blendFactorSource,_blendFactorDestination);
      }
      
      protected function createParticle() : Particle
      {
         return new Particle();
      }
      
      protected function initParticle(param1:Particle) : void
      {
         param1.x = mEmitterPoint.x;
         param1.y = mEmitterPoint.y;
         param1.currentTime = 0;
         param1.totalTime = 1;
         param1.color = Math.random() * 16777215;
      }
      
      protected function advanceParticle(param1:Particle, param2:Number) : void
      {
         param1.y += param2 * 250;
         param1.alpha = 1 - param1.currentTime / param1.totalTime;
         param1.currentTime += param2;
      }
      
      private function setRequiresSync() : void
      {
         _requiresSync = true;
      }
      
      private function syncBuffers() : void
      {
         _effect.uploadVertexData(_vertexData);
         _effect.uploadIndexData(_indexData);
         _requiresSync = false;
      }
      
      public function start(param1:Number = 1.7976931348623157E308) : void
      {
         if(_emissionRate != 0)
         {
            _emissionTime = param1;
         }
      }
      
      public function stop(param1:Boolean = false) : void
      {
         _emissionTime = 0;
         if(param1)
         {
            clear();
         }
      }
      
      public function clear() : void
      {
         _numParticles = 0;
      }
      
      override public function getBounds(param1:DisplayObject, param2:Rectangle = null) : Rectangle
      {
         if(param2 == null)
         {
            param2 = new Rectangle();
         }
         getTransformationMatrix(param1,sHelperMatrix);
         MatrixUtil.transformCoords(sHelperMatrix,0,0,sHelperPoint);
         param2.x = sHelperPoint.x;
         param2.y = sHelperPoint.y;
         param2.width = param2.height = 0;
         return param2;
      }
      
      public function advanceTime(param1:Number) : void
      {
         var _loc18_:* = null;
         var _loc9_:* = null;
         var _loc20_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc6_:int = 0;
         var _loc4_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc12_:Number = NaN;
         if(mEmitterObject && mEmitterObject.root == null || mTargetSpace && mTargetSpace.root == null)
         {
            stop(true);
            dispatchEventWith("complete");
            return;
         }
         setRequiresRedraw();
         setRequiresSync();
         var _loc13_:int = 0;
         var _loc2_:int = capacity;
         while(_loc13_ < _numParticles)
         {
            if((_loc18_ = _particles[_loc13_] as Particle).currentTime < _loc18_.totalTime)
            {
               advanceParticle(_loc18_,param1);
               _loc13_++;
            }
            else
            {
               if(_loc13_ != _numParticles - 1)
               {
                  _loc9_ = _particles[int(_numParticles - 1)] as Particle;
                  _particles[int(_numParticles - 1)] = _loc18_;
                  _particles[_loc13_] = _loc9_;
               }
               --_numParticles;
               if(_numParticles == 0 && _emissionTime == 0)
               {
                  dispatchEventWith("complete");
               }
            }
         }
         if(_emissionTime > 0)
         {
            _loc20_ = 1 / _emissionRate;
            _frameTime += param1;
            while(_frameTime > 0)
            {
               if(_numParticles < _loc2_)
               {
                  _loc18_ = _particles[_numParticles] as Particle;
                  initParticle(_loc18_);
                  if(_loc18_.totalTime > 0)
                  {
                     advanceParticle(_loc18_,_frameTime);
                     ++_numParticles;
                  }
               }
               _frameTime -= _loc20_;
            }
            if(_emissionTime != 1.7976931348623157e+308)
            {
               _emissionTime = _emissionTime > param1 ? _emissionTime - param1 : 0;
            }
            if(_numParticles == 0 && _emissionTime == 0)
            {
               dispatchEventWith("complete");
            }
         }
         var _loc3_:int = 0;
         var _loc8_:Number = !!texture ? texture.width / 2 : 5;
         var _loc7_:Number = !!texture ? texture.height / 2 : 5;
         _loc6_ = 0;
         while(_loc6_ < _numParticles)
         {
            _loc3_ = _loc6_ * 4;
            _loc5_ = (_loc18_ = _particles[_loc6_] as Particle).rotation;
            _loc10_ = _loc8_ * _loc18_.scale;
            _loc11_ = _loc7_ * _loc18_.scale;
            _loc15_ = _loc18_.x;
            _loc16_ = _loc18_.y;
            _vertexData.colorize("color",_loc18_.color,_loc18_.alpha,_loc3_,4);
            if(_loc5_)
            {
               _loc4_ = Math.cos(_loc5_);
               _loc17_ = Math.sin(_loc5_);
               _loc21_ = _loc4_ * _loc10_;
               _loc19_ = _loc4_ * _loc11_;
               _loc14_ = _loc17_ * _loc10_;
               _loc12_ = _loc17_ * _loc11_;
               _vertexData.setPoint(_loc3_,"position",_loc15_ - _loc21_ + _loc12_,_loc16_ - _loc14_ - _loc19_);
               _vertexData.setPoint(_loc3_ + 1,"position",_loc15_ + _loc21_ + _loc12_,_loc16_ + _loc14_ - _loc19_);
               _vertexData.setPoint(_loc3_ + 2,"position",_loc15_ - _loc21_ - _loc12_,_loc16_ - _loc14_ + _loc19_);
               _vertexData.setPoint(_loc3_ + 3,"position",_loc15_ + _loc21_ - _loc12_,_loc16_ + _loc14_ + _loc19_);
            }
            else
            {
               _vertexData.setPoint(_loc3_,"position",_loc15_ - _loc10_,_loc16_ - _loc11_);
               _vertexData.setPoint(_loc3_ + 1,"position",_loc15_ + _loc10_,_loc16_ - _loc11_);
               _vertexData.setPoint(_loc3_ + 2,"position",_loc15_ - _loc10_,_loc16_ + _loc11_);
               _vertexData.setPoint(_loc3_ + 3,"position",_loc15_ + _loc10_,_loc16_ + _loc11_);
            }
            _loc6_++;
         }
      }
      
      override public function render(param1:Painter) : void
      {
         if(_numParticles != 0)
         {
            if(_batchable)
            {
               param1.batchMesh(this);
            }
            else
            {
               param1.finishMeshBatch();
               param1.drawCount += 1;
               param1.prepareToDraw();
               param1.excludeFromCache(this);
               if(_requiresSync)
               {
                  syncBuffers();
               }
               style.updateEffect(_effect,param1.state);
               _effect.render(0,_numParticles * 2);
            }
         }
      }
      
      public function populate(param1:int) : void
      {
         var _loc2_:* = null;
         var _loc4_:int = 0;
         var _loc3_:int = capacity;
         param1 = Math.min(param1,_loc3_ - _numParticles);
         _loc4_ = 0;
         while(_loc4_ < param1)
         {
            _loc2_ = _particles[_numParticles + _loc4_];
            initParticle(_loc2_);
            advanceParticle(_loc2_,Math.random() * _loc2_.totalTime);
            _loc4_++;
         }
         _numParticles += param1;
      }
      
      public function get capacity() : int
      {
         return _vertexData.numVertices / 4;
      }
      
      public function set capacity(param1:int) : void
      {
         var _loc7_:* = 0;
         var _loc2_:int = 0;
         var _loc3_:int = capacity;
         var _loc6_:int = param1 > 16383 ? 16383 : int(param1);
         var _loc4_:VertexData = new VertexData(style.vertexFormat,4);
         var _loc5_:Texture;
         if(_loc5_ = this.texture)
         {
            _loc5_.setupVertexPositions(_loc4_);
            _loc5_.setupTextureCoordinates(_loc4_);
         }
         else
         {
            _loc4_.setPoint(0,"position",0,0);
            _loc4_.setPoint(1,"position",10,0);
            _loc4_.setPoint(2,"position",0,10);
            _loc4_.setPoint(3,"position",10,10);
         }
         _loc7_ = _loc3_;
         while(_loc7_ < _loc6_)
         {
            _loc2_ = _loc7_ * 4;
            _loc4_.copyTo(_vertexData,_loc2_);
            _indexData.addQuad(_loc2_,_loc2_ + 1,_loc2_ + 2,_loc2_ + 3);
            _particles[_loc7_] = createParticle();
            _loc7_++;
         }
         if(_loc6_ < _loc3_)
         {
            _particles.length = _loc6_;
            _indexData.numIndices = _loc6_ * 6;
            _vertexData.numVertices = _loc6_ * 4;
         }
         _indexData.trim();
         _vertexData.trim();
         setRequiresSync();
      }
      
      public function get isEmitting() : Boolean
      {
         return _emissionTime > 0 && _emissionRate > 0;
      }
      
      public function get numParticles() : int
      {
         return _numParticles;
      }
      
      public function get emissionRate() : Number
      {
         return _emissionRate;
      }
      
      public function set emissionRate(param1:Number) : void
      {
         _emissionRate = param1;
      }
      
      public function get emitterX() : Number
      {
         return mEmitterPoint.x;
      }
      
      public function set emitterX(param1:Number) : void
      {
         mEmitterPoint.x = param1;
      }
      
      public function get emitterY() : Number
      {
         return mEmitterPoint.y;
      }
      
      public function set emitterY(param1:Number) : void
      {
         mEmitterPoint.y = param1;
      }
      
      public function get emitterObject() : DisplayObject
      {
         return mEmitterObject;
      }
      
      public function set emitterObject(param1:DisplayObject) : void
      {
         mEmitterObject = param1;
      }
      
      public function get targetSpace() : DisplayObject
      {
         return mTargetSpace;
      }
      
      public function set targetSpace(param1:DisplayObject) : void
      {
         mTargetSpace = param1;
      }
      
      public function get blendFactorSource() : String
      {
         return _blendFactorSource;
      }
      
      public function set blendFactorSource(param1:String) : void
      {
         _blendFactorSource = param1;
         updateBlendMode();
      }
      
      public function get blendFactorDestination() : String
      {
         return _blendFactorDestination;
      }
      
      public function set blendFactorDestination(param1:String) : void
      {
         _blendFactorDestination = param1;
         updateBlendMode();
      }
      
      override public function set texture(param1:Texture) : void
      {
         var _loc2_:int = 0;
         super.texture = param1;
         if(param1)
         {
            _loc2_ = _vertexData.numVertices - 4;
            while(_loc2_ >= 0)
            {
               param1.setupVertexPositions(_vertexData,_loc2_);
               param1.setupTextureCoordinates(_vertexData,_loc2_);
               _loc2_ -= 4;
            }
         }
         updateBlendMode();
      }
      
      override public function setStyle(param1:MeshStyle = null, param2:Boolean = true) : void
      {
         super.setStyle(param1,param2);
         if(_effect)
         {
            _effect.dispose();
         }
         _effect = style.createEffect();
         _effect.onRestore = setRequiresSync;
      }
      
      public function get batchable() : Boolean
      {
         return _batchable;
      }
      
      public function set batchable(param1:Boolean) : void
      {
         _batchable = param1;
         setRequiresRedraw();
      }
   }
}
