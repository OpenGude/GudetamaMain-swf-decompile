package muku.display
{
   import starling.extensions.PDParticleSystem;
   import starling.textures.Texture;
   
   public class ParticleSystem extends PDParticleSystem
   {
       
      
      private var particleName:String;
      
      public function ParticleSystem(param1:XML, param2:Texture, param3:String)
      {
         this.particleName = param3;
         super(param1,param2);
      }
      
      public static function disposeConfigPool() : void
      {
         ConfigPool.getInstance().dispose();
      }
      
      override protected function parseConfig(param1:XML) : void
      {
         if(ConfigPool.getInstance().hasConfig(particleName))
         {
            ConfigPool.getInstance().getConfig(particleName,this);
         }
         else
         {
            super.parseConfig(param1);
            ConfigPool.getInstance().addConfig(particleName,this);
         }
      }
   }
}

import flash.utils.ByteArray;
import muku.display.ParticleSystem;
import starling.extensions.ColorArgb;

class ConfigPool
{
   
   private static const instance:ConfigPool = new ConfigPool();
    
   
   private const pool:Object = {};
   
   function ConfigPool()
   {
      super();
   }
   
   public static function getInstance() : ConfigPool
   {
      return instance;
   }
   
   public function dispose() : void
   {
      var _loc1_:* = null;
      for(_loc1_ in pool)
      {
         pool[_loc1_].clear();
         delete pool[_loc1_];
      }
   }
   
   public function addConfig(param1:String, param2:ParticleSystem) : void
   {
      var _loc3_:ByteArray = new ByteArray();
      _loc3_.writeFloat(param2.emitterXVariance);
      _loc3_.writeFloat(param2.emitterYVariance);
      _loc3_.writeFloat(param2.gravityX);
      _loc3_.writeFloat(param2.gravityY);
      _loc3_.writeInt(param2.emitterType);
      _loc3_.writeFloat(param2.lifespan);
      _loc3_.writeFloat(param2.lifespanVariance);
      _loc3_.writeFloat(param2.startSize);
      _loc3_.writeFloat(param2.startSizeVariance);
      _loc3_.writeFloat(param2.endSize);
      _loc3_.writeFloat(param2.endSizeVariance);
      _loc3_.writeFloat(param2.emitAngle);
      _loc3_.writeFloat(param2.emitAngleVariance);
      _loc3_.writeFloat(param2.startRotation);
      _loc3_.writeFloat(param2.startRotationVariance);
      _loc3_.writeFloat(param2.endRotation);
      _loc3_.writeFloat(param2.endRotationVariance);
      _loc3_.writeFloat(param2.speed);
      _loc3_.writeFloat(param2.speedVariance);
      _loc3_.writeFloat(param2.radialAcceleration);
      _loc3_.writeFloat(param2.radialAccelerationVariance);
      _loc3_.writeFloat(param2.tangentialAcceleration);
      _loc3_.writeFloat(param2.tangentialAccelerationVariance);
      _loc3_.writeFloat(param2.maxRadius);
      _loc3_.writeFloat(param2.maxRadiusVariance);
      _loc3_.writeFloat(param2.minRadius);
      _loc3_.writeFloat(param2.minRadiusVariance);
      _loc3_.writeFloat(param2.rotatePerSecond);
      _loc3_.writeFloat(param2.rotatePerSecondVariance);
      _loc3_.writeUnsignedInt(param2.startColor.toArgb());
      _loc3_.writeUnsignedInt(param2.startColorVariance.toArgb());
      _loc3_.writeUnsignedInt(param2.endColor.toArgb());
      _loc3_.writeUnsignedInt(param2.endColorVariance.toArgb());
      _loc3_.writeUTF(param2.blendFactorSource);
      _loc3_.writeUTF(param2.blendFactorDestination);
      _loc3_.writeFloat(param2.defaultDuration);
      _loc3_.writeInt(param2.capacity);
      _loc3_.writeFloat(param2.emissionRate);
      pool[param1] = _loc3_;
   }
   
   public function getConfig(param1:String, param2:ParticleSystem) : void
   {
      var _loc3_:ByteArray = pool[param1] as ByteArray;
      _loc3_.position = 0;
      param2.emitterXVariance = _loc3_.readFloat();
      param2.emitterYVariance = _loc3_.readFloat();
      param2.gravityX = _loc3_.readFloat();
      param2.gravityY = _loc3_.readFloat();
      param2.emitterType = _loc3_.readInt();
      param2.lifespan = _loc3_.readFloat();
      param2.lifespanVariance = _loc3_.readFloat();
      param2.startSize = _loc3_.readFloat();
      param2.startSizeVariance = _loc3_.readFloat();
      param2.endSize = _loc3_.readFloat();
      param2.endSizeVariance = _loc3_.readFloat();
      param2.emitAngle = _loc3_.readFloat();
      param2.emitAngleVariance = _loc3_.readFloat();
      param2.startRotation = _loc3_.readFloat();
      param2.startRotationVariance = _loc3_.readFloat();
      param2.endRotation = _loc3_.readFloat();
      param2.endRotationVariance = _loc3_.readFloat();
      param2.speed = _loc3_.readFloat();
      param2.speedVariance = _loc3_.readFloat();
      param2.radialAcceleration = _loc3_.readFloat();
      param2.radialAccelerationVariance = _loc3_.readFloat();
      param2.tangentialAcceleration = _loc3_.readFloat();
      param2.tangentialAccelerationVariance = _loc3_.readFloat();
      param2.maxRadius = _loc3_.readFloat();
      param2.maxRadiusVariance = _loc3_.readFloat();
      param2.minRadius = _loc3_.readFloat();
      param2.minRadiusVariance = _loc3_.readFloat();
      param2.rotatePerSecond = _loc3_.readFloat();
      param2.rotatePerSecondVariance = _loc3_.readFloat();
      param2.startColor = ColorArgb.fromArgb(_loc3_.readUnsignedInt());
      param2.startColorVariance = ColorArgb.fromArgb(_loc3_.readUnsignedInt());
      param2.endColor = ColorArgb.fromArgb(_loc3_.readUnsignedInt());
      param2.endColorVariance = ColorArgb.fromArgb(_loc3_.readUnsignedInt());
      param2.blendFactorSource = _loc3_.readUTF();
      param2.blendFactorDestination = _loc3_.readUTF();
      param2.defaultDuration = _loc3_.readFloat();
      param2.capacity = _loc3_.readInt();
      param2.emissionRate = _loc3_.readFloat();
   }
   
   public function hasConfig(param1:String) : Boolean
   {
      return pool.hasOwnProperty(param1);
   }
}
