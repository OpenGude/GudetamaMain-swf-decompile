package gudetama.util
{
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.GudetamaDef;
   import gudetama.data.compati.KitchenwareDef;
   import gudetama.data.compati.RecipeNoteDef;
   
   public class GudeActUtil
   {
      
      public static const STATE_ENABLED:int = 0;
      
      public static const STATE_UNCOUNTABLE:int = 1;
      
      public static const STATE_LOCKED:int = 2;
      
      public static const STATE_NOT_COOKED:int = 4;
      
      public static const STATE_DISABLED:int = 8;
      
      public static const STATE_NOT_COOKABLE:int = 16;
      
      public static const STATE_NEED_AVAILABLE_KITCHENWARE:int = 32;
      
      public static const STATE_OUT_OF_TERM:int = 64;
      
      public static const STATE_INVISIBLE_RECIPE_NOTE:int = 128;
      
      public static const STATE_NEED_AVAILABLE_RECIPE_NOTE:int = 256;
      
      public static const STATE_NEED_PURCHASE:int = 512;
      
      public static const STATE_NEED_AVAILABLE_RECIPE:int = 1024;
       
      
      public function GudeActUtil()
      {
         super();
      }
      
      public static function checkState(param1:int, param2:int, param3:Boolean, param4:Boolean, param5:Boolean) : int
      {
         var _loc6_:* = 0;
         if((param2 & 2) != 0 && param3)
         {
            _loc6_ |= 2;
         }
         var _loc9_:GudetamaDef = GameSetting.getGudetama(param1);
         if((param2 & 1) != 0 && _loc9_.uncountable)
         {
            _loc6_ |= 1;
         }
         if((param2 & 4) != 0 && !UserDataWrapper.gudetamaPart.isCooked(param1))
         {
            _loc6_ |= 4;
         }
         if((param2 & 8) != 0 && !param4)
         {
            _loc6_ |= 8;
         }
         if(!param5)
         {
            return _loc6_;
         }
         var _loc8_:KitchenwareDef;
         var _loc7_:RecipeNoteDef;
         if(!(_loc8_ = !!(_loc7_ = !!_loc9_ ? GameSetting.getRecipeNote(_loc9_.recipeNoteId) : null) ? GameSetting.getKitchenware(_loc7_.kitchenwareId) : null) && _loc9_.kitchenwareId > 0)
         {
            _loc8_ = GameSetting.getKitchenware(_loc9_.kitchenwareId);
         }
         if((param2 & 16) != 0 && !_loc7_ && !_loc8_)
         {
            _loc6_ |= 16;
         }
         if((param2 & 32) != 0 && _loc8_ && !UserDataWrapper.kitchenwarePart.isAvailable(_loc8_.type,_loc8_.grade))
         {
            _loc6_ |= 32;
         }
         if((param2 & 64) != 0 && _loc7_ && !UserDataWrapper.eventPart.inTerm(_loc7_.eventId,true))
         {
            _loc6_ |= 64;
         }
         if(UserDataWrapper.gudetamaPart.isFailure(param1))
         {
            return _loc6_;
         }
         if(_loc7_)
         {
            if((param2 & 128) != 0 && !UserDataWrapper.recipeNotePart.isVisible(_loc7_.id#2))
            {
               _loc6_ |= 128;
            }
            if((param2 & 256) != 0 && !UserDataWrapper.recipeNotePart.isAvailable(_loc7_.id#2))
            {
               _loc6_ |= 256;
            }
            if((param2 & 512) != 0 && !UserDataWrapper.recipeNotePart.isPurchased(_loc7_.id#2))
            {
               _loc6_ |= 512;
            }
         }
         if(!UserDataWrapper.gudetamaPart.isHappening(param1))
         {
            if((param2 & 1024) != 0 && !UserDataWrapper.gudetamaPart.isAvailable(param1))
            {
               _loc6_ |= 1024;
            }
         }
         return _loc6_;
      }
      
      public static function getCookCheckStates() : int
      {
         return 1 | 16 | 64 | 32 | 128 | 256 | 512 | 1024;
      }
      
      public static function getWantCheckStates() : int
      {
         return 1 | 8 | 4;
      }
      
      public static function getShareCheckStates() : int
      {
         return 1 | 2;
      }
      
      public static function getPresentCheckStates() : int
      {
         return 1 | 2 | 8;
      }
   }
}
