package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class MissionParam
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
       
      
      public var number:int;
      
      public var type:int;
      
      public var category:int;
      
      public var guide:int;
      
      public var goalValue:int;
      
      public var finishSecs:int;
      
      public var targetDescKey:String;
      
      public var titleKey:String;
      
      public var nextTitleKey:String;
      
      public var rewards:Array;
      
      public var titleParam:Array;
      
      public var counterType:int;
      
      public function MissionParam()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         number = param1.readInt();
         type = param1.readByte();
         category = param1.readByte();
         guide = param1.readShort();
         goalValue = param1.readShort();
         finishSecs = param1.readInt();
         targetDescKey = param1.readUTF();
         titleKey = param1.readUTF();
         nextTitleKey = param1.readUTF();
         rewards = CompatibleDataIO.read(param1) as Array;
         titleParam = CompatibleDataIO.read(param1) as Array;
         counterType = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(number);
         param1.writeByte(type);
         param1.writeByte(category);
         param1.writeShort(guide);
         param1.writeShort(goalValue);
         param1.writeInt(finishSecs);
         param1.writeUTF(targetDescKey);
         param1.writeUTF(titleKey);
         param1.writeUTF(nextTitleKey);
         CompatibleDataIO.write(param1,rewards,1);
         CompatibleDataIO.write(param1,titleParam,1);
         param1.writeInt(counterType);
      }
   }
}
