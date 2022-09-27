package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class _AbilityParam
   {
      
      public static const UNIQUE_BITFLAG:int = -2147483648;
      
      public static const MOST_POWERFUL_BITFLAG:int = 1073741824;
      
      public static const LOW_POWER_STRENGTH_BITFLAG:int = 536870912;
      
      public static const TYPE_CORRECT_HP_HEAL:int = 0;
      
      public static const TYPE_CORRECT_CRITICAL_ATTACK:int = 1;
      
      public static const TYPE_CORRECT_SP_BONUS:int = 2;
      
      public static const TYPE_REDUCE_OPTION:int = 3;
      
      public static const TYPE_DIED_ENDURE_HP1:int = 4;
      
      public static const TYPE_DAMAED_AVOIDANCE:int = 5;
      
      public static const TYPE_STATUS_SKILL_CT_DOWN:int = 6;
      
      public static const TYPE_STATUS_SKILL_POWER_UP:int = -2147483641;
      
      public static const TYPE_STATUS_SKILL_CHARGED:int = -2147483640;
      
      public static const TYPE_CORRECT_REVIVE_COUNTUP:int = 9;
      
      public static const TYPE_STATUS_MONEY_BONUS:int = 10;
      
      public static const TYPE_STATUS_MORIBUND_ATK_UP:int = 11;
      
      public static const TYPE_CORRECT_MORIBUND_CRITICAL:int = 12;
      
      public static const TYPE_CORRECT_CHAIN_SP_BONUS:int = 1610612749;
      
      public static const TYPE_COLLABO_GENRE_DESIGNATION:int = 14;
      
      public static const TYPE_RANKING_POINT_UP:int = 15;
      
      public static const TYPE_BASE_SKILL_LEVEL_UP:int = -2147483632;
      
      public static const JOB_TYPE:Array = [1,0,3,3,2,2,3,0,3,1,3,0,0,1,3,3,0];
      
      public static const RATIOS:Array = [1,0.5,0.4,0.3,0.2,0.1,0.05];
       
      
      public var type:int;
      
      public var name#2:String;
      
      public var desc:String;
      
      public var genre:int;
      
      public var difficulty:int;
      
      public var grade:int;
      
      public var power:int;
      
      public var startTimeSecs:int;
      
      public var endTimeSecs:int;
      
      public function _AbilityParam()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         type = param1.readInt();
         name#2 = param1.readUTF();
         desc = param1.readUTF();
         genre = param1.readInt();
         difficulty = param1.readInt();
         grade = param1.readByte();
         power = param1.readInt();
         startTimeSecs = param1.readInt();
         endTimeSecs = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(type);
         param1.writeUTF(name#2);
         param1.writeUTF(desc);
         param1.writeInt(genre);
         param1.writeInt(difficulty);
         param1.writeByte(grade);
         param1.writeInt(power);
         param1.writeInt(startTimeSecs);
         param1.writeInt(endTimeSecs);
      }
   }
}
