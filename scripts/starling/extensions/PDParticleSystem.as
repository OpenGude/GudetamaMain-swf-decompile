package starling.extensions
{
   import starling.display.DisplayObject;
   import starling.textures.Texture;
   import starling.utils.deg2rad;
   
   public class PDParticleSystem extends ParticleSystem
   {
      
      public static const EMITTER_TYPE_GRAVITY:int = 0;
      
      public static const EMITTER_TYPE_RADIAL:int = 1;
       
      
      private var _emitterType:int;
      
      private var _emitterXVariance:Number;
      
      private var _emitterYVariance:Number;
      
      private var _defaultDuration:Number;
      
      private var _lifespan:Number;
      
      private var _lifespanVariance:Number;
      
      private var _startSize:Number;
      
      private var _startSizeVariance:Number;
      
      private var _endSize:Number;
      
      private var _endSizeVariance:Number;
      
      private var _emitAngle:Number;
      
      private var _emitAngleVariance:Number;
      
      private var _startRotation:Number;
      
      private var _startRotationVariance:Number;
      
      private var _endRotation:Number;
      
      private var _endRotationVariance:Number;
      
      private var _speed:Number;
      
      private var _speedVariance:Number;
      
      private var _gravityX:Number;
      
      private var _gravityY:Number;
      
      private var _radialAcceleration:Number;
      
      private var _radialAccelerationVariance:Number;
      
      private var _tangentialAcceleration:Number;
      
      private var _tangentialAccelerationVariance:Number;
      
      private var _maxRadius:Number;
      
      private var _maxRadiusVariance:Number;
      
      private var _minRadius:Number;
      
      private var _minRadiusVariance:Number;
      
      private var _rotatePerSecond:Number;
      
      private var _rotatePerSecondVariance:Number;
      
      private var _startColor:ColorArgb;
      
      private var _startColorVariance:ColorArgb;
      
      private var _endColor:ColorArgb;
      
      private var _endColorVariance:ColorArgb;
      
      public function PDParticleSystem(param1:XML, param2:Texture)
      {
         super(param2);
         parseConfig(param1);
      }
      
      override protected function createParticle() : Particle
      {
         return new PDParticle();
      }
      
      override protected function initParticle(param1:Particle) : void
      {
         var _loc18_:PDParticle = param1 as PDParticle;
         var _loc4_:Number = _lifespan + _lifespanVariance * (Math.random() * 2 - 1);
         var _loc5_:Number = !!texture ? texture.width : 16;
         _loc18_.currentTime = 0;
         _loc18_.totalTime = _loc4_ > 0 ? _loc4_ : 0;
         if(_loc4_ <= 0)
         {
            return;
         }
         if(mEmitterObject && mTargetSpace)
         {
            mEmitterObject.getTargetSpacePoint(mTargetSpace,mEmitterPoint);
         }
         else if(mTargetSpace)
         {
            getTargetSpacePoint(mTargetSpace,mEmitterPoint);
         }
         _loc18_.x = mEmitterPoint.x + _emitterXVariance * (Math.random() * 2 - 1);
         _loc18_.y = mEmitterPoint.y + _emitterYVariance * (Math.random() * 2 - 1);
         _loc18_.startX = mEmitterPoint.x;
         _loc18_.startY = mEmitterPoint.y;
         var _loc17_:Number = _emitAngle + _emitAngleVariance * (Math.random() * 2 - 1);
         var _loc9_:Number = _speed + _speedVariance * (Math.random() * 2 - 1);
         _loc18_.velocityX = _loc9_ * Math.cos(_loc17_);
         _loc18_.velocityY = _loc9_ * Math.sin(_loc17_);
         var _loc6_:Number = _maxRadius + _maxRadiusVariance * (Math.random() * 2 - 1);
         var _loc10_:Number = _minRadius + _minRadiusVariance * (Math.random() * 2 - 1);
         _loc18_.emitRadius = _loc6_;
         _loc18_.emitRadiusDelta = (_loc10_ - _loc6_) / _loc4_;
         _loc18_.emitRotation = _emitAngle + _emitAngleVariance * (Math.random() * 2 - 1);
         _loc18_.emitRotationDelta = _rotatePerSecond + _rotatePerSecondVariance * (Math.random() * 2 - 1);
         _loc18_.radialAcceleration = _radialAcceleration + _radialAccelerationVariance * (Math.random() * 2 - 1);
         _loc18_.tangentialAcceleration = _tangentialAcceleration + _tangentialAccelerationVariance * (Math.random() * 2 - 1);
         var _loc16_:* = Number(_startSize + _startSizeVariance * (Math.random() * 2 - 1));
         var _loc11_:* = Number(_endSize + _endSizeVariance * (Math.random() * 2 - 1));
         if(_loc16_ < 0.1)
         {
            _loc16_ = 0.1;
         }
         if(_loc11_ < 0.1)
         {
            _loc11_ = 0.1;
         }
         _loc18_.scale = _loc16_ / _loc5_;
         _loc18_.scaleDelta = (_loc11_ - _loc16_) / _loc4_ / _loc5_;
         var _loc14_:ColorArgb = _loc18_.colorArgb;
         var _loc12_:ColorArgb = _loc18_.colorArgbDelta;
         _loc14_.red = _startColor.red;
         _loc14_.green = _startColor.green;
         _loc14_.blue = _startColor.blue;
         _loc14_.alpha = _startColor.alpha;
         if(_startColorVariance.red != 0)
         {
            _loc14_.red += _startColorVariance.red * (Math.random() * 2 - 1);
         }
         if(_startColorVariance.green != 0)
         {
            _loc14_.green += _startColorVariance.green * (Math.random() * 2 - 1);
         }
         if(_startColorVariance.blue != 0)
         {
            _loc14_.blue += _startColorVariance.blue * (Math.random() * 2 - 1);
         }
         if(_startColorVariance.alpha != 0)
         {
            _loc14_.alpha += _startColorVariance.alpha * (Math.random() * 2 - 1);
         }
         var _loc7_:Number = _endColor.red;
         var _loc2_:Number = _endColor.green;
         var _loc3_:Number = _endColor.blue;
         var _loc15_:Number = _endColor.alpha;
         if(_endColorVariance.red != 0)
         {
            _loc7_ += _endColorVariance.red * (Math.random() * 2 - 1);
         }
         if(_endColorVariance.green != 0)
         {
            _loc2_ += _endColorVariance.green * (Math.random() * 2 - 1);
         }
         if(_endColorVariance.blue != 0)
         {
            _loc3_ += _endColorVariance.blue * (Math.random() * 2 - 1);
         }
         if(_endColorVariance.alpha != 0)
         {
            _loc15_ += _endColorVariance.alpha * (Math.random() * 2 - 1);
         }
         _loc12_.red = (_loc7_ - _loc14_.red) / _loc4_;
         _loc12_.green = (_loc2_ - _loc14_.green) / _loc4_;
         _loc12_.blue = (_loc3_ - _loc14_.blue) / _loc4_;
         _loc12_.alpha = (_loc15_ - _loc14_.alpha) / _loc4_;
         var _loc8_:Number = _startRotation + _startRotationVariance * (Math.random() * 2 - 1);
         var _loc13_:Number = _endRotation + _endRotationVariance * (Math.random() * 2 - 1);
         _loc18_.rotation = _loc8_;
         _loc18_.rotationDelta = (_loc13_ - _loc8_) / _loc4_;
      }
      
      override protected function advanceParticle(param1:Particle, param2:Number) : void
      {
         var _loc12_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc5_:* = NaN;
         var _loc6_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc9_:* = NaN;
         var _loc7_:* = NaN;
         var _loc10_:* = NaN;
         var _loc8_:PDParticle;
         var _loc3_:Number = (_loc8_ = param1 as PDParticle).totalTime - _loc8_.currentTime;
         param2 = _loc3_ > param2 ? param2 : Number(_loc3_);
         _loc8_.currentTime += param2;
         if(_emitterType == 1)
         {
            _loc8_.emitRotation += _loc8_.emitRotationDelta * param2;
            _loc8_.emitRadius += _loc8_.emitRadiusDelta * param2;
            _loc8_.x = mEmitterPoint.x - Math.cos(_loc8_.emitRotation) * _loc8_.emitRadius;
            _loc8_.y = mEmitterPoint.y - Math.sin(_loc8_.emitRotation) * _loc8_.emitRadius;
         }
         else
         {
            _loc12_ = _loc8_.x - _loc8_.startX;
            _loc11_ = _loc8_.y - _loc8_.startY;
            if((_loc5_ = Number(Math.sqrt(_loc12_ * _loc12_ + _loc11_ * _loc11_))) < 0.01)
            {
               _loc5_ = 0.01;
            }
            _loc6_ = _loc12_ / _loc5_;
            _loc4_ = _loc11_ / _loc5_;
            _loc9_ = _loc6_;
            _loc7_ = _loc4_;
            _loc6_ *= _loc8_.radialAcceleration;
            _loc4_ *= _loc8_.radialAcceleration;
            _loc10_ = _loc9_;
            _loc9_ = Number(-_loc7_ * _loc8_.tangentialAcceleration);
            _loc7_ = Number(_loc10_ * _loc8_.tangentialAcceleration);
            _loc8_.velocityX += param2 * (_gravityX + _loc6_ + _loc9_);
            _loc8_.velocityY += param2 * (_gravityY + _loc4_ + _loc7_);
            _loc8_.x += _loc8_.velocityX * param2;
            _loc8_.y += _loc8_.velocityY * param2;
         }
         _loc8_.scale += _loc8_.scaleDelta * param2;
         _loc8_.rotation += _loc8_.rotationDelta * param2;
         _loc8_.colorArgb.red += _loc8_.colorArgbDelta.red * param2;
         _loc8_.colorArgb.green += _loc8_.colorArgbDelta.green * param2;
         _loc8_.colorArgb.blue += _loc8_.colorArgbDelta.blue * param2;
         _loc8_.colorArgb.alpha += _loc8_.colorArgbDelta.alpha * param2;
         _loc8_.color = _loc8_.colorArgb.toRgb();
         _loc8_.alpha = _loc8_.colorArgb.alpha;
      }
      
      private function updateEmissionRate() : void
      {
         emissionRate = capacity / _lifespan;
      }
      
      protected function parseConfig(param1:XML) : void
      {
         _emitterXVariance = parseFloat(param1.sourcePositionVariance.attribute("x"));
         _emitterYVariance = parseFloat(param1.sourcePositionVariance.attribute("y"));
         _gravityX = parseFloat(param1.gravity.attribute("x"));
         _gravityY = parseFloat(param1.gravity.attribute("y"));
         _emitterType = getIntValue(param1.emitterType);
         _lifespan = Math.max(0.01,getFloatValue(param1.particleLifeSpan));
         _lifespanVariance = getFloatValue(param1.particleLifespanVariance);
         _startSize = getFloatValue(param1.startParticleSize);
         _startSizeVariance = getFloatValue(param1.startParticleSizeVariance);
         _endSize = getFloatValue(param1.finishParticleSize);
         _endSizeVariance = getFloatValue(param1.FinishParticleSizeVariance);
         _emitAngle = deg2rad(getFloatValue(param1.angle));
         _emitAngleVariance = deg2rad(getFloatValue(param1.angleVariance));
         _startRotation = deg2rad(getFloatValue(param1.rotationStart));
         _startRotationVariance = deg2rad(getFloatValue(param1.rotationStartVariance));
         _endRotation = deg2rad(getFloatValue(param1.rotationEnd));
         _endRotationVariance = deg2rad(getFloatValue(param1.rotationEndVariance));
         _speed = getFloatValue(param1.speed);
         _speedVariance = getFloatValue(param1.speedVariance);
         _radialAcceleration = getFloatValue(param1.radialAcceleration);
         _radialAccelerationVariance = getFloatValue(param1.radialAccelVariance);
         _tangentialAcceleration = getFloatValue(param1.tangentialAcceleration);
         _tangentialAccelerationVariance = getFloatValue(param1.tangentialAccelVariance);
         _maxRadius = getFloatValue(param1.maxRadius);
         _maxRadiusVariance = getFloatValue(param1.maxRadiusVariance);
         _minRadius = getFloatValue(param1.minRadius);
         _minRadiusVariance = getFloatValue(param1.minRadiusVariance);
         _rotatePerSecond = deg2rad(getFloatValue(param1.rotatePerSecond));
         _rotatePerSecondVariance = deg2rad(getFloatValue(param1.rotatePerSecondVariance));
         _startColor = getColor(param1.startColor);
         _startColorVariance = getColor(param1.startColorVariance);
         _endColor = getColor(param1.finishColor);
         _endColorVariance = getColor(param1.finishColorVariance);
         blendFactorSource = getBlendFunc(param1.blendFuncSource);
         blendFactorDestination = getBlendFunc(param1.blendFuncDestination);
         defaultDuration = getFloatValue(param1.duration);
         capacity = getIntValue(param1.maxParticles);
         if(isNaN(_endSizeVariance))
         {
            _endSizeVariance = getFloatValue(param1.finishParticleSizeVariance);
         }
         if(isNaN(_lifespan))
         {
            _lifespan = Math.max(0.01,getFloatValue(param1.particleLifespan));
         }
         if(isNaN(_lifespanVariance))
         {
            _lifespanVariance = getFloatValue(param1.particleLifeSpanVariance);
         }
         if(isNaN(_minRadiusVariance))
         {
            _minRadiusVariance = 0;
         }
         updateEmissionRate();
      }
      
      private function getIntValue(param1:XMLList) : int
      {
         return parseInt(param1.attribute("value"));
      }
      
      private function getFloatValue(param1:XMLList) : Number
      {
         return parseFloat(param1.attribute("value"));
      }
      
      private function getColor(param1:XMLList) : ColorArgb
      {
         var _loc2_:ColorArgb = new ColorArgb();
         _loc2_.red = parseFloat(param1.attribute("red"));
         _loc2_.green = parseFloat(param1.attribute("green"));
         _loc2_.blue = parseFloat(param1.attribute("blue"));
         _loc2_.alpha = parseFloat(param1.attribute("alpha"));
         return _loc2_;
      }
      
      private function getBlendFunc(param1:XMLList) : String
      {
         var _loc2_:int = getIntValue(param1);
         switch(_loc2_)
         {
            case 0:
               return "zero";
            case 1:
               return "one";
            case 768:
               return "sourceColor";
            case 769:
               return "oneMinusSourceColor";
            case 770:
               return "sourceAlpha";
            case 771:
               return "oneMinusSourceAlpha";
            case 772:
               return "destinationAlpha";
            case 773:
               return "oneMinusDestinationAlpha";
            case 774:
               return "destinationColor";
            case 775:
               return "oneMinusDestinationColor";
            default:
               throw new ArgumentError("unsupported blending function: " + _loc2_);
         }
      }
      
      public function get emitterType() : int
      {
         return _emitterType;
      }
      
      public function set emitterType(param1:int) : void
      {
         _emitterType = param1;
      }
      
      public function get emitterXVariance() : Number
      {
         return _emitterXVariance;
      }
      
      public function set emitterXVariance(param1:Number) : void
      {
         _emitterXVariance = param1;
      }
      
      public function get emitterYVariance() : Number
      {
         return _emitterYVariance;
      }
      
      public function set emitterYVariance(param1:Number) : void
      {
         _emitterYVariance = param1;
      }
      
      public function get defaultDuration() : Number
      {
         return _defaultDuration;
      }
      
      public function set defaultDuration(param1:Number) : void
      {
         _defaultDuration = param1 < 0 ? 1.7976931348623157e+308 : Number(param1);
      }
      
      override public function set capacity(param1:int) : void
      {
         super.capacity = param1;
         updateEmissionRate();
      }
      
      public function get lifespan() : Number
      {
         return _lifespan;
      }
      
      public function set lifespan(param1:Number) : void
      {
         _lifespan = Math.max(0.01,param1);
         updateEmissionRate();
      }
      
      public function get lifespanVariance() : Number
      {
         return _lifespanVariance;
      }
      
      public function set lifespanVariance(param1:Number) : void
      {
         _lifespanVariance = param1;
      }
      
      public function get startSize() : Number
      {
         return _startSize;
      }
      
      public function set startSize(param1:Number) : void
      {
         _startSize = param1;
      }
      
      public function get startSizeVariance() : Number
      {
         return _startSizeVariance;
      }
      
      public function set startSizeVariance(param1:Number) : void
      {
         _startSizeVariance = param1;
      }
      
      public function get endSize() : Number
      {
         return _endSize;
      }
      
      public function set endSize(param1:Number) : void
      {
         _endSize = param1;
      }
      
      public function get endSizeVariance() : Number
      {
         return _endSizeVariance;
      }
      
      public function set endSizeVariance(param1:Number) : void
      {
         _endSizeVariance = param1;
      }
      
      public function get emitAngle() : Number
      {
         return _emitAngle;
      }
      
      public function set emitAngle(param1:Number) : void
      {
         _emitAngle = param1;
      }
      
      public function get emitAngleVariance() : Number
      {
         return _emitAngleVariance;
      }
      
      public function set emitAngleVariance(param1:Number) : void
      {
         _emitAngleVariance = param1;
      }
      
      public function get startRotation() : Number
      {
         return _startRotation;
      }
      
      public function set startRotation(param1:Number) : void
      {
         _startRotation = param1;
      }
      
      public function get startRotationVariance() : Number
      {
         return _startRotationVariance;
      }
      
      public function set startRotationVariance(param1:Number) : void
      {
         _startRotationVariance = param1;
      }
      
      public function get endRotation() : Number
      {
         return _endRotation;
      }
      
      public function set endRotation(param1:Number) : void
      {
         _endRotation = param1;
      }
      
      public function get endRotationVariance() : Number
      {
         return _endRotationVariance;
      }
      
      public function set endRotationVariance(param1:Number) : void
      {
         _endRotationVariance = param1;
      }
      
      public function get speed() : Number
      {
         return _speed;
      }
      
      public function set speed(param1:Number) : void
      {
         _speed = param1;
      }
      
      public function get speedVariance() : Number
      {
         return _speedVariance;
      }
      
      public function set speedVariance(param1:Number) : void
      {
         _speedVariance = param1;
      }
      
      public function get gravityX() : Number
      {
         return _gravityX;
      }
      
      public function set gravityX(param1:Number) : void
      {
         _gravityX = param1;
      }
      
      public function get gravityY() : Number
      {
         return _gravityY;
      }
      
      public function set gravityY(param1:Number) : void
      {
         _gravityY = param1;
      }
      
      public function get radialAcceleration() : Number
      {
         return _radialAcceleration;
      }
      
      public function set radialAcceleration(param1:Number) : void
      {
         _radialAcceleration = param1;
      }
      
      public function get radialAccelerationVariance() : Number
      {
         return _radialAccelerationVariance;
      }
      
      public function set radialAccelerationVariance(param1:Number) : void
      {
         _radialAccelerationVariance = param1;
      }
      
      public function get tangentialAcceleration() : Number
      {
         return _tangentialAcceleration;
      }
      
      public function set tangentialAcceleration(param1:Number) : void
      {
         _tangentialAcceleration = param1;
      }
      
      public function get tangentialAccelerationVariance() : Number
      {
         return _tangentialAccelerationVariance;
      }
      
      public function set tangentialAccelerationVariance(param1:Number) : void
      {
         _tangentialAccelerationVariance = param1;
      }
      
      public function get maxRadius() : Number
      {
         return _maxRadius;
      }
      
      public function set maxRadius(param1:Number) : void
      {
         _maxRadius = param1;
      }
      
      public function get maxRadiusVariance() : Number
      {
         return _maxRadiusVariance;
      }
      
      public function set maxRadiusVariance(param1:Number) : void
      {
         _maxRadiusVariance = param1;
      }
      
      public function get minRadius() : Number
      {
         return _minRadius;
      }
      
      public function set minRadius(param1:Number) : void
      {
         _minRadius = param1;
      }
      
      public function get minRadiusVariance() : Number
      {
         return _minRadiusVariance;
      }
      
      public function set minRadiusVariance(param1:Number) : void
      {
         _minRadiusVariance = param1;
      }
      
      public function get rotatePerSecond() : Number
      {
         return _rotatePerSecond;
      }
      
      public function set rotatePerSecond(param1:Number) : void
      {
         _rotatePerSecond = param1;
      }
      
      public function get rotatePerSecondVariance() : Number
      {
         return _rotatePerSecondVariance;
      }
      
      public function set rotatePerSecondVariance(param1:Number) : void
      {
         _rotatePerSecondVariance = param1;
      }
      
      public function get startColor() : ColorArgb
      {
         return _startColor;
      }
      
      public function set startColor(param1:ColorArgb) : void
      {
         _startColor = param1;
      }
      
      public function get startColorVariance() : ColorArgb
      {
         return _startColorVariance;
      }
      
      public function set startColorVariance(param1:ColorArgb) : void
      {
         _startColorVariance = param1;
      }
      
      public function get endColor() : ColorArgb
      {
         return _endColor;
      }
      
      public function set endColor(param1:ColorArgb) : void
      {
         _endColor = param1;
      }
      
      public function get endColorVariance() : ColorArgb
      {
         return _endColorVariance;
      }
      
      public function set endColorVariance(param1:ColorArgb) : void
      {
         _endColorVariance = param1;
      }
   }
}
