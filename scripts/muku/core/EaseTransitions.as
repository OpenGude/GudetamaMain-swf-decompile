package muku.core
{
   import starling.animation.Transitions;
   
   public class EaseTransitions extends Transitions
   {
      
      public static const EASE_IN_QUAD:String = "easeInQuad";
      
      public static const EASE_OUT_QUAD:String = "easeOutQuad";
      
      public static const EASE_IN_OUT_QUAD:String = "easeInOutQuad";
      
      public static const EASE_OUT_IN_QUAD:String = "easeOutInQuad";
      
      public static const EASE_IN_CUBIC:String = "easeInCubic";
      
      public static const EASE_OUT_CUBIC:String = "easeOutCubic";
      
      public static const EASE_IN_OUT_CUBIC:String = "easeInOutCubic";
      
      public static const EASE_OUT_IN_CUBIC:String = "easeOutInCubic";
      
      public static const EASE_IN_QUART:String = "easeInQuart";
      
      public static const EASE_OUT_QUART:String = "easeOutQuart";
      
      public static const EASE_IN_OUT_QUART:String = "easeInOutQuart";
      
      public static const EASE_OUT_IN_QUART:String = "easeOutInQuart";
      
      public static const EASE_IN_QUINT:String = "easeInQuint";
      
      public static const EASE_OUT_QUINT:String = "easeOutQuint";
      
      public static const EASE_IN_OUT_QUINT:String = "easeInOutQuint";
      
      public static const EASE_OUT_IN_QUINT:String = "easeOutInQuint";
      
      public static const EASE_IN_SINE:String = "easeInSine";
      
      public static const EASE_OUT_SINE:String = "easeOutSine";
      
      public static const EASE_IN_OUT_SINE:String = "easeInOutSine";
      
      public static const EASE_OUT_IN_SINE:String = "easeOutInSine";
      
      public static const EASE_IN_EXPO:String = "easeInExpo";
      
      public static const EASE_OUT_EXPO:String = "easeOutExpo";
      
      public static const EASE_IN_OUT_EXPO:String = "easeInOutExpo";
      
      public static const EASE_OUT_IN_EXPO:String = "easeOutInExpo";
      
      public static const EASE_IN_CIRC:String = "easeInCirc";
      
      public static const EASE_OUT_CIRC:String = "easeOutCirc";
      
      public static const EASE_IN_OUT_CIRC:String = "easeInOutCirc";
      
      public static const EASE_OUT_IN_CIRC:String = "easeOutInCirc";
      
      private static var setuped:Boolean = false;
       
      
      public function EaseTransitions()
      {
         super();
      }
      
      public static function setup() : void
      {
         if(!setuped)
         {
            setuped = true;
            register("easeInQuad",easeInQuad);
            register("easeOutQuad",easeOutQuad);
            register("easeInOutQuad",easeInOutQuad);
            register("easeOutInQuad",easeOutInQuad);
            register("easeInCubic",Transitions.getTransition("easeIn"));
            register("easeOutCubic",Transitions.getTransition("easeOut"));
            register("easeInOutCubic",Transitions.getTransition("easeInOut"));
            register("easeOutInCubic",Transitions.getTransition("easeOutIn"));
            register("easeInQuart",easeInQuart);
            register("easeOutQuart",easeOutQuart);
            register("easeInOutQuart",easeInOutQuart);
            register("easeOutInQuart",easeOutInQuart);
            register("easeInQuint",easeInQuint);
            register("easeOutQuint",easeOutQuint);
            register("easeInOutQuint",easeInOutQuint);
            register("easeOutInQuint",easeOutInQuint);
            register("easeInSine",easeInSine);
            register("easeOutSine",easeOutSine);
            register("easeInOutSine",easeInOutSine);
            register("easeOutInSine",easeOutInSine);
            register("easeInExpo",easeInExpo);
            register("easeOutExpo",easeOutExpo);
            register("easeInOutExpo",easeInOutExpo);
            register("easeOutInExpo",easeOutInExpo);
            register("easeInCirc",easeInCirc);
            register("easeOutCirc",easeOutCirc);
            register("easeInOutCirc",easeInOutCirc);
            register("easeOutInCirc",easeOutInCirc);
         }
      }
      
      protected static function easeInQuad(param1:Number) : Number
      {
         return param1 * param1;
      }
      
      protected static function easeOutQuad(param1:Number) : Number
      {
         return -param1 * (param1 - 2);
      }
      
      protected static function easeInOutQuad(param1:Number) : Number
      {
         return easeCombined(easeInQuad,easeOutQuad,param1);
      }
      
      protected static function easeOutInQuad(param1:Number) : Number
      {
         return easeCombined(easeOutQuad,easeInQuad,param1);
      }
      
      protected static function easeInQuart(param1:Number) : Number
      {
         var _loc2_:Number = param1 * param1;
         return _loc2_ * _loc2_;
      }
      
      protected static function easeOutQuart(param1:Number) : Number
      {
         var _loc2_:Number = param1 - 1;
         var _loc3_:Number = _loc2_ * _loc2_;
         return 1 - _loc3_ * _loc3_;
      }
      
      protected static function easeInOutQuart(param1:Number) : Number
      {
         return easeCombined(easeInQuart,easeOutQuart,param1);
      }
      
      protected static function easeOutInQuart(param1:Number) : Number
      {
         return easeCombined(easeOutQuart,easeInQuart,param1);
      }
      
      protected static function easeInQuint(param1:Number) : Number
      {
         var _loc2_:Number = param1 * param1;
         return _loc2_ * _loc2_ * param1;
      }
      
      protected static function easeOutQuint(param1:Number) : Number
      {
         var _loc2_:Number = param1 - 1;
         var _loc3_:Number = _loc2_ * _loc2_;
         return _loc3_ * _loc3_ * _loc2_ + 1;
      }
      
      protected static function easeInOutQuint(param1:Number) : Number
      {
         return easeCombined(easeInQuint,easeOutQuint,param1);
      }
      
      protected static function easeOutInQuint(param1:Number) : Number
      {
         return easeCombined(easeOutQuint,easeInQuint,param1);
      }
      
      protected static function easeInSine(param1:Number) : Number
      {
         return -Math.cos(param1 * (3.141592653589793 / 2)) + 1;
      }
      
      protected static function easeOutSine(param1:Number) : Number
      {
         return Math.sin(param1 * (3.141592653589793 / 2));
      }
      
      protected static function easeInOutSine(param1:Number) : Number
      {
         return easeCombined(easeInSine,easeOutQuint,param1);
      }
      
      protected static function easeOutInSine(param1:Number) : Number
      {
         return easeCombined(easeOutSine,easeInSine,param1);
      }
      
      protected static function easeInExpo(param1:Number) : Number
      {
         if(param1 == 0)
         {
            return 0;
         }
         return Math.pow(2,10 * (param1 - 1));
      }
      
      protected static function easeOutExpo(param1:Number) : Number
      {
         if(param1 == 1)
         {
            return 1;
         }
         return -(Math.pow(2,-10 * param1) + 1);
      }
      
      protected static function easeInOutExpo(param1:Number) : Number
      {
         return easeCombined(easeInExpo,easeInExpo,param1);
      }
      
      protected static function easeOutInExpo(param1:Number) : Number
      {
         return easeCombined(easeInExpo,easeInExpo,param1);
      }
      
      protected static function easeInCirc(param1:Number) : Number
      {
         return 1 - Math.sqrt(1 - param1 * param1);
      }
      
      protected static function easeOutCirc(param1:Number) : Number
      {
         var _loc2_:Number = param1 - 1;
         return Math.sqrt(1 - _loc2_ * _loc2_);
      }
      
      protected static function easeInOutCirc(param1:Number) : Number
      {
         return easeCombined(easeInCirc,easeOutCirc,param1);
      }
      
      protected static function easeOutInCirc(param1:Number) : Number
      {
         return easeCombined(easeOutCirc,easeInCirc,param1);
      }
   }
}
