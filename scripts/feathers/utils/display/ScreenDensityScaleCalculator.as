package feathers.utils.display
{
   import flash.errors.IllegalOperationError;
   
   public class ScreenDensityScaleCalculator
   {
       
      
      protected var _buckets:Vector.<ScreenDensityBucket>;
      
      public function ScreenDensityScaleCalculator()
      {
         _buckets = new Vector.<ScreenDensityBucket>(0);
         super();
      }
      
      public function addScaleForDensity(param1:int, param2:Number) : void
      {
         var _loc5_:int = 0;
         var _loc3_:* = null;
         var _loc4_:int = this._buckets.length;
         _loc5_ = 0;
         while(_loc5_ < _loc4_)
         {
            _loc3_ = this._buckets[_loc5_];
            if(_loc3_.density > param1)
            {
               break;
            }
            if(_loc3_.density === param1)
            {
               throw new ArgumentError("Screen density cannot be added more than once: " + param1);
            }
            _loc5_++;
         }
         this._buckets.insertAt(_loc5_,new ScreenDensityBucket(param1,param2));
      }
      
      public function removeScaleForDensity(param1:int) : void
      {
         var _loc4_:int = 0;
         var _loc2_:* = null;
         var _loc3_:int = this._buckets.length;
         _loc4_ = 0;
         while(_loc4_ < _loc3_)
         {
            _loc2_ = this._buckets[_loc4_];
            if(_loc2_.density === param1)
            {
               this._buckets.removeAt(_loc4_);
               return;
            }
            _loc4_++;
         }
      }
      
      public function getScale(param1:int) : Number
      {
         var _loc6_:int = 0;
         var _loc4_:Number = NaN;
         if(this._buckets.length === 0)
         {
            throw new IllegalOperationError("Cannot choose scale because none have been added");
         }
         var _loc2_:ScreenDensityBucket = this._buckets[0];
         if(param1 <= _loc2_.density)
         {
            return _loc2_.scale;
         }
         var _loc3_:* = _loc2_;
         var _loc5_:int = this._buckets.length;
         _loc6_ = 1;
         while(_loc6_ < _loc5_)
         {
            _loc2_ = this._buckets[_loc6_];
            if(param1 <= _loc2_.density)
            {
               _loc4_ = (_loc2_.density + _loc3_.density) / 2;
               if(param1 < _loc4_)
               {
                  return _loc3_.scale;
               }
            }
            continue;
            _loc3_ = _loc2_;
            _loc6_++;
            return _loc2_.scale;
         }
         return _loc2_.scale;
      }
   }
}

class ScreenDensityBucket
{
    
   
   public var density:Number;
   
   public var scale:Number;
   
   function ScreenDensityBucket(param1:Number, param2:Number)
   {
      super();
      this.density = param1;
      this.scale = param2;
   }
}
