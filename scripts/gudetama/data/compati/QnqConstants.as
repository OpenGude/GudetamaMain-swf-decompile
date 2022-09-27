package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class QnqConstants
   {
      
      public static const ID_CHARA_MAX:int = 99;
      
      public static const ID_MAIN_STORYGROUP:int = 1;
      
      public static const NUM_QUIZ_OPTIONS:int = 4;
      
      public static const NUM_QUIZ_TWO_OPTIONS:int = 2;
      
      public static const NUM_ELIMINATION_QUIZ_OPTIONS:int = 5;
      
      public static const NUM_NORMAL_QUIZZES:int = 4;
      
      public static const NUM_QUEST_MEMBERS:int = 4;
      
      public static const NUM_JOBS:int = 4;
      
      public static const NUM_JOB_BOOKS:int = 7;
      
      public static const NUM_STATUS_BOOKS:int = 3;
      
      public static const MAX_BATTLE_ENEMIES:int = 3;
      
      public static const NUM_MISSION_REWARD:int = 3;
      
      public static const QUIZ_RATING_DECIMAL_DIGIT:int = 1000;
      
      public static const QUIZ_RATING_MAX:int = 10000000;
      
      public static const QUIZ_RATING_INITIAL:int = -3000000;
      
      public static const QUIZ_RATING_OFFSET:int = 3000;
      
      public static const QUIZ_DIFFICULY_UNKNOWN_RATING:int = 25;
      
      public static const TIME_ATTACK_PRECISION:int = 10;
      
      public static const TIME_ATTACK_MAX:int = 90000;
      
      public static const TYPE_ROOM_PUBLIC:int = 0;
      
      public static const TYPE_ROOM_SPECIFIC_JOB:int = 1;
      
      public static const TYPE_ROOM_PRIVATE:int = 2;
      
      public static const TYPE_ROOM_PROHIBIT:int = 3;
      
      public static const TYPE_ROOM_RENTAL:int = 4;
      
      public static const TYPE_ROOM_ALL_RENTAL:int = 5;
      
      public static const TYPE_ROOM_EVENT:int = 6;
      
      public static const STATE_MEMBER_ACTIVE:int = 0;
      
      public static const STATE_MEMBER_READY:int = 1;
      
      public static const STATE_MEMBER_PREPARE:int = 2;
      
      public static const STATE_MEMBER_SUSPEND:int = 3;
      
      public static const STATE_MEMBER_DISCONNECTED:int = 4;
      
      public static const STATE_MEMBER_LOST:int = 5;
      
      public static const TYPE_PLAYSTYLE_NONE:int = 0;
      
      public static const TYPE_PLAYSTYLE_LEVEL:int = 1;
      
      public static const TYPE_PLAYSTYLE_BEGINNER:int = 2;
      
      public static const TYPE_PLAYSTYLE_EXPERT:int = 3;
      
      public static const TYPE_PLAYSTYLE_MATERIAL:int = 4;
      
      public static const TYPE_PLAYSTYLE_RARE:int = 5;
      
      public static const TYPE_PLAYSTYLE_NUM:int = 6;
      
      public static const BATTLERESULT_GIVEUP:int = -1;
      
      public static const BATTLERESULT_DEFEAT:int = 0;
      
      public static const BATTLERESULT_VICTORY:int = 1;
      
      public static const CHAT_MAX_TEXTLINES:int = 10;
      
      public static const QUIZ_GUILDPOINT_DECIMAL_DIGIT:int = 1000;
      
      public static const QUIZ_GUILDPOINT_MAX:int = 10000000;
      
      public static const SNS_NONE:int = -1;
      
      public static const SNS_TWITTER:int = 0;
      
      public static const SNS_FACEBOOK:int = 1;
       
      
      public function QnqConstants()
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
