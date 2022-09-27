package gudetama.util
{
   import gudetama.engine.Logger;
   import starling.animation.DelayedCall;
   import starling.animation.IAnimatable;
   import starling.animation.Juggler;
   import starling.animation.Tween;
   
   public class JugglerEx extends Juggler
   {
      
      public static const COMPLETE_DT:Number = 120;
       
      
      public function JugglerEx()
      {
         super();
      }
      
      public function purgeWithComplete() : void
      {
         var _loc5_:int = 0;
         var _loc6_:* = null;
         var _loc1_:* = null;
         var _loc7_:* = null;
         var _loc3_:int = objects.length;
         var _loc2_:Vector.<IAnimatable> = objects;
         var _loc4_:int = 0;
         while(_loc2_.length > 0)
         {
            _loc5_ = _loc2_.length - 1;
            while(_loc5_ >= 0)
            {
               if(_loc6_ = _loc2_[_loc5_])
               {
                  _loc1_ = _loc6_ as DelayedCall;
                  if(_loc1_)
                  {
                     _loc1_.repeatCount = 1;
                  }
                  if(_loc7_ = _loc6_ as Tween)
                  {
                     _loc7_.forceFinish();
                  }
               }
               _loc5_--;
            }
            advanceTime(120);
            if(_loc4_++ > 5)
            {
               Logger.warn("JugglerEx purgeWithComplete",_loc2_.length,_loc2_.length > 0 ? _loc2_[0] : null);
               purge();
               break;
            }
         }
      }
   }
}
