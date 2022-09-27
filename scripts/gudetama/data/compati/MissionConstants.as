package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class MissionConstants
   {
      
      public static const TYPE_NONE:int = 0;
      
      public static const TYPE_RANK:int = 1;
      
      public static const TYPE_VOICE_NUM:int = 2;
      
      public static const TYPE_VOICE_RARE1_NUM:int = 4;
      
      public static const TYPE_VOICE_RARE2_NUM:int = 8;
      
      public static const TYPE_ACCUMULATION:int = 1;
      
      public static const TYPE_ONETIME:int = 2;
      
      public static const TYPE_COUNTER:int = 3;
      
      public static const CONDITION_COOKING_CATEGORY:String = "CookingCategory";
      
      public static const CONDITION_CUP_COOK_TARGET:String = "CupCookTarget";
      
      public static const CONDITION_GUDETAMA_CATEGORY:String = "GudetamaCategory";
      
      public static const CONDITION_GUDETAMA_TARGET:String = "GudetamaTarget";
      
      public static const CONDITION_USE_USEFUL_ITEM:String = "UseUsefulItem";
      
      public static const TYPE_CONDITION_GUDETAMA_TARGET:int = 0;
      
      public static const TYPE_CONDITION_RECIPE_TARGET:int = 1;
       
      
      public function MissionConstants()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
      }
      
      public function write(param1:ByteArray) : void
      {
      }
   }
}
