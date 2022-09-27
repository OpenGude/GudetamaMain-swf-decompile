package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class ConvertParam
   {
      
      public static const KIND_MONEY:int = 0;
      
      public static const KIND_FREE_METAL:int = 1;
      
      public static const KIND_CHARGE_METAL:int = 2;
      
      public static const KIND_SUB_METAL:int = 3;
      
      public static const KIND_KITCHENWARE:int = 4;
      
      public static const KIND_RECIPE_NOTE:int = 5;
      
      public static const KIND_RECIPE:int = 6;
      
      public static const KIND_GUDETAMA:int = 7;
      
      public static const KIND_USEFUL:int = 8;
      
      public static const KIND_DECORATION:int = 9;
      
      public static const KIND_UTENSIL:int = 10;
      
      public static const KIND_STAMP:int = 11;
      
      public static const KIND_AVATAR:int = 12;
      
      public static const KIND_COMMENT:int = 13;
      
      public static const KIND_CHARGE_MONEY:int = 14;
      
      public static const KIND_RANKING_POINT:int = 15;
      
      public static const KIND_MONTHLY_BONUS:int = 16;
      
      public static const KIND_ONLY_SHOW:int = 17;
      
      public static const KIND_SET_ITEM:int = 18;
      
      public static const KIND_CUP_GACHA:int = 19;
      
      public static const KIND_FRAME:int = 20;
      
      public static const KIND_NUM:int = 21;
       
      
      public var originalItem:ItemParam;
      
      public var convertedItem:ItemParam;
      
      public var convertedParam:Object;
      
      public var kind:int;
      
      public var id#2:int;
      
      public var num:int;
      
      public function ConvertParam()
      {
         super();
      }
      
      public static function hasNumber(param1:int) : Boolean
      {
         return param1 == 0 || param1 == 1 || param1 == 2 || param1 == 3 || param1 == 7 || param1 == 8 || param1 == 11 || param1 == 14 || param1 == 19;
      }
      
      public static function useOnlyNum(param1:int) : Boolean
      {
         return param1 == 0 || param1 == 14;
      }
      
      public static function useOnlyName(param1:int) : Boolean
      {
         return param1 == 4 || param1 == 5 || param1 == 6 || param1 == 9 || param1 == 10 || param1 == 12 || param1 == 13;
      }
      
      public static function useOnlyNameAndNum(param1:int) : Boolean
      {
         return param1 == 1 || param1 == 2 || param1 == 3 || param1 == 7 || param1 == 8 || param1 == 11 || param1 == 17 || param1 == 19;
      }
      
      public function hasNumber() : Boolean
      {
         return ItemParam.hasNumber(kind);
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         originalItem = CompatibleDataIO.read(param1) as ItemParam;
         convertedItem = CompatibleDataIO.read(param1) as ItemParam;
         convertedParam = CompatibleDataIO.read(param1) as Object;
         kind = param1.readInt();
         id#2 = param1.readInt();
         num = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         CompatibleDataIO.write(param1,originalItem);
         CompatibleDataIO.write(param1,convertedItem);
         CompatibleDataIO.write(param1,convertedParam);
         param1.writeInt(kind);
         param1.writeInt(id#2);
         param1.writeInt(num);
      }
   }
}
