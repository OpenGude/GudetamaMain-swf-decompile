package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class GudetamaDef
   {
      
      public static const TYPE_PRIVATELY:int = 0;
      
      public static const TYPE_NUMBERING:int = 1;
      
      public static const TYPE_EVENT:int = 2;
      
      public static const TYPE_EVENT_ONLY_RECIPE:int = 3;
      
      public static const RARE_0:int = 0;
      
      public static const RARE_1:int = 1;
      
      public static const RARE_2:int = 2;
      
      public static const RARE_3:int = 3;
      
      public static const RARE_4:int = 4;
      
      public static const CATEGORY_NATURAL:int = 0;
      
      public static const CATEGORY_CONFECTIONERY:int = 1;
      
      public static const CATEGORY_BOIL:int = 2;
      
      public static const CATEGORY_WONDER:int = 3;
      
      public static const CATEGORY_SOLID:int = 4;
      
      public static const CATEGORY_SIMPLE:int = 5;
      
      public static const CATEGORY_DRESS_UP:int = 6;
      
      public static const CATEGORY_PLENTIFULLY:int = 7;
      
      public static const CATEGORY_NOODLE:int = 8;
      
      public static const CATEGORY_RICE:int = 9;
      
      public static const CATEGORY_MORNING:int = 10;
      
      public static const CATEGORY_SOBER:int = 11;
      
      public static const CATEGORY_PSEUDO:int = 12;
      
      public static const CATEGORY_XMAS:int = 13;
      
      public static const CATEGORY_SEVEN_GODS:int = 14;
      
      public static const CATEGORY_CUP:int = 15;
      
      public static const COUNTRY_JAPAN:int = 0;
      
      public static const COUNTRY_NONE:int = 127;
      
      public static const AREA_HOKKAIDO:int = 0;
      
      public static const AREA_AOMORI:int = 1;
      
      public static const AREA_IWATE:int = 2;
      
      public static const AREA_MIYAGI:int = 3;
      
      public static const AREA_AKITA:int = 4;
      
      public static const AREA_YAMAGATA:int = 5;
      
      public static const AREA_FUKUSHIMA:int = 6;
      
      public static const AREA_IBARAKI:int = 7;
      
      public static const AREA_TOCHIGI:int = 8;
      
      public static const AREA_GUMMA:int = 9;
      
      public static const AREA_SAITAMA:int = 10;
      
      public static const AREA_CHIBA:int = 11;
      
      public static const AREA_TOKYO:int = 12;
      
      public static const AREA_KANAGAWA:int = 13;
      
      public static const AREA_NIIGATA:int = 14;
      
      public static const AREA_TOYAMA:int = 15;
      
      public static const AREA_ISHIKAWA:int = 16;
      
      public static const AREA_FUKUI:int = 17;
      
      public static const AREA_YAMANASHI:int = 18;
      
      public static const AREA_NAGANO:int = 19;
      
      public static const AREA_GIFU:int = 20;
      
      public static const AREA_SHIZUOKA:int = 21;
      
      public static const AREA_AICHI:int = 22;
      
      public static const AREA_MIE:int = 23;
      
      public static const AREA_SHIGA:int = 24;
      
      public static const AREA_KYOTO:int = 25;
      
      public static const AREA_OSAKA:int = 26;
      
      public static const AREA_HYOGO:int = 27;
      
      public static const AREA_NARA:int = 28;
      
      public static const AREA_WAKAYAMA:int = 29;
      
      public static const AREA_TOTTORI:int = 30;
      
      public static const AREA_SHIMANE:int = 31;
      
      public static const AREA_OKAYAMA:int = 32;
      
      public static const AREA_HIROSHIMA:int = 33;
      
      public static const AREA_YAMAGUCHI:int = 34;
      
      public static const AREA_TOKUSHIMA:int = 35;
      
      public static const AREA_KAGAWA:int = 36;
      
      public static const AREA_EHIME:int = 37;
      
      public static const AREA_KOCHI:int = 38;
      
      public static const AREA_FUKUOKA:int = 39;
      
      public static const AREA_SAGA:int = 40;
      
      public static const AREA_NAGASAKI:int = 41;
      
      public static const AREA_KUMAMOTO:int = 42;
      
      public static const AREA_OITA:int = 43;
      
      public static const AREA_MIYAZAKI:int = 44;
      
      public static const AREA_KAGOSHIMA:int = 45;
      
      public static const AREA_OKINAWA:int = 46;
      
      public static const AREA_NONE:int = 999;
      
      public static const MAX_NUM_VOICE:int = 2;
      
      public static const VOICE_OFFSET:int = 2;
      
      public static const VOICE_NORMAL_GUDETAMA:int = 0;
      
      public static const VOICE_GURETAMA:int = 1;
      
      public static const VOICE_NISETAMA:int = 2;
      
      public static const VOICE_HARDBOILED:int = 3;
      
      public static const DROP_ANIME_SWING:int = 0;
      
      public static const DROP_ANIME_SCALING:int = 1;
      
      public static const MATERIAL_SOY_SAUCE:int = 1;
      
      public static const MATERIAL_BACON:int = 2;
      
      public static const MATERIAL_SUGAR:int = 4;
      
      public static const MATERIAL_BREAD:int = 8;
      
      public static const MATERIAL_PASTA:int = 16;
      
      public static const MATERIAL_VEGETABLE:int = 32;
      
      public static const MATERIAL_MEAT:int = 64;
      
      public static const MATERIAL_RICE:int = 128;
      
      public static const MATERIAL_MILK:int = 256;
      
      public static const MATERIAL_NUM:int = 9;
      
      public static const MAX_PERCENT:int = 100;
      
      public static const ROULETTE_SUCCESS:int = 0;
      
      public static const ROULETTE_HAPPENING:int = 1;
      
      public static const ROULETTE_FAILURE:int = 2;
       
      
      public var id#2:int;
      
      public var rsrc:int;
      
      public var uncountable:Boolean;
      
      public var disabledSpine:Boolean;
      
      public var imageOffsX:int;
      
      public var imageOffsY:int;
      
      public var kitchenwareId:int;
      
      public var recipeNoteId:int;
      
      public var type:int;
      
      public var number:int;
      
      public var name#2:String;
      
      public var wrappedName:String;
      
      public var desc:String;
      
      public var cost:int;
      
      public var reward:int;
      
      public var rarity:int;
      
      public var category:int;
      
      public var country:int;
      
      public var area:int;
      
      public var voices:Array;
      
      public var voiceType:int;
      
      public var dropAnime:int;
      
      public var dish:Boolean;
      
      public var materials:int;
      
      public var conditionDesc:String;
      
      public var roulettes:Array;
      
      public var rouletteTimePerRound:int;
      
      public var cookingResultType:int;
      
      public var isGacha:Boolean;
      
      public var requiredGudetamas:Array;
      
      public var touchTextParams:Array;
      
      public var rubTextParams:Array;
      
      public var isCup:Boolean;
      
      public var targetType:int;
      
      public var targetId:int;
      
      public function GudetamaDef()
      {
         super();
      }
      
      public function getWrappedName() : String
      {
         if(!wrappedName || wrappedName.length == 0)
         {
            return name#2;
         }
         return wrappedName;
      }
      
      public function existsHappening() : Boolean
      {
         for each(var _loc1_ in roulettes)
         {
            if(_loc1_.type == 1)
            {
               return true;
            }
         }
         return false;
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         id#2 = param1.readInt();
         rsrc = param1.readInt();
         uncountable = param1.readBoolean();
         disabledSpine = param1.readBoolean();
         imageOffsX = param1.readInt();
         imageOffsY = param1.readInt();
         kitchenwareId = param1.readInt();
         recipeNoteId = param1.readInt();
         type = param1.readByte();
         number = param1.readInt();
         name#2 = param1.readUTF();
         wrappedName = param1.readUTF();
         desc = param1.readUTF();
         cost = param1.readInt();
         reward = param1.readInt();
         rarity = param1.readByte();
         category = param1.readByte();
         country = param1.readByte();
         area = param1.readShort();
         voices = CompatibleDataIO.read(param1) as Array;
         voiceType = param1.readByte();
         dropAnime = param1.readInt();
         dish = param1.readBoolean();
         materials = param1.readInt();
         conditionDesc = param1.readUTF();
         roulettes = CompatibleDataIO.read(param1) as Array;
         rouletteTimePerRound = param1.readInt();
         cookingResultType = param1.readInt();
         isGacha = param1.readBoolean();
         requiredGudetamas = CompatibleDataIO.read(param1) as Array;
         touchTextParams = CompatibleDataIO.read(param1) as Array;
         rubTextParams = CompatibleDataIO.read(param1) as Array;
         isCup = param1.readBoolean();
         targetType = param1.readInt();
         targetId = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(id#2);
         param1.writeInt(rsrc);
         param1.writeBoolean(uncountable);
         param1.writeBoolean(disabledSpine);
         param1.writeInt(imageOffsX);
         param1.writeInt(imageOffsY);
         param1.writeInt(kitchenwareId);
         param1.writeInt(recipeNoteId);
         param1.writeByte(type);
         param1.writeInt(number);
         param1.writeUTF(name#2);
         param1.writeUTF(wrappedName);
         param1.writeUTF(desc);
         param1.writeInt(cost);
         param1.writeInt(reward);
         param1.writeByte(rarity);
         param1.writeByte(category);
         param1.writeByte(country);
         param1.writeShort(area);
         CompatibleDataIO.write(param1,voices,2);
         param1.writeByte(voiceType);
         param1.writeInt(dropAnime);
         param1.writeBoolean(dish);
         param1.writeInt(materials);
         param1.writeUTF(conditionDesc);
         CompatibleDataIO.write(param1,roulettes,1);
         param1.writeInt(rouletteTimePerRound);
         param1.writeInt(cookingResultType);
         param1.writeBoolean(isGacha);
         CompatibleDataIO.write(param1,requiredGudetamas,1);
         CompatibleDataIO.write(param1,touchTextParams,1);
         CompatibleDataIO.write(param1,rubTextParams,1);
         param1.writeBoolean(isCup);
         param1.writeInt(targetType);
         param1.writeInt(targetId);
      }
   }
}
