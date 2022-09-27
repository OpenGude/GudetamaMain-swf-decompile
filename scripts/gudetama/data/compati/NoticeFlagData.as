package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class NoticeFlagData
   {
      
      public static const FLAG_NOTSET:int = 0;
      
      public static const FLAG_SET:int = 1;
      
      public static const FLAG_DONE:int = 2;
      
      public static const PROGRESS_CHECKED_TERMS_OF_SERVICE:int = 0;
      
      public static const PROGRESS_GENDER_AND_NAME:int = 1;
      
      public static const PROGRESS_GUDETAMA_GREETING:int = 2;
      
      public static const PROGRESS_GUDETAMA_INTRODUCTION:int = 3;
      
      public static const PROGRESS_FIRST_COOKING:int = 4;
      
      public static const PROGRESS_FIRST_TAPGUIDE:int = 5;
      
      public static const PROGRESS_FIRST_PUSH:int = 6;
      
      public static const PROGRESS_MAX:int = 7;
      
      public static const PROGRESS_FIRST_LOGIN:int = 3;
      
      public static const PROGRESS_FIRST_STORY:int = 4;
      
      public static const PROGRESS_FIRST_DECK_EDIT:int = 5;
      
      public static const PROGRESS_SECOND_STORY:int = 6;
      
      public static const PROGRESS_FIRST_GACHA_PLAY:int = 7;
      
      public static const PROGRESS_SECOND_DECK_EDIT:int = 8;
      
      public static const PROGRESS_THIRD_STORY:int = 9;
      
      public static const PROGRESS_RANK_UP4:int = 10;
      
      public static const PROGRESS_FOURTH_STORY:int = 11;
      
      public static const NOTICE_SECOND_COOKING:int = 0;
      
      public static const NOTICE_FIRST_PROFILE:int = 1;
      
      public static const NOTICE_FIRST_SHOPPING:int = 2;
      
      public static const NOTICE_FIRST_PICTURE_BOOK:int = 3;
      
      public static const NOTICE_GOLD_EGG_INTRO:int = 4;
      
      public static const NOTICE_FRIEND_LIST:int = 5;
      
      public static const NOTICE_ROOM_DECORATION:int = 6;
      
      public static const NOTICE_FIRST_ITEM_INFO:int = 7;
      
      public static const NOTICE_MISSION_ATTENTION:int = 8;
      
      public static const NOTICE_MISSION_INFO:int = 9;
      
      public static const NOTICE_MISSION_DAILY_INFO:int = 10;
      
      public static const NOTICE_FRIEND_DETAIL:int = 11;
      
      public static const NOTICE_FRIEND_ROOM:int = 12;
      
      public static const NOTICE_RECIPE_RELEASE:int = 13;
      
      public static const NOTICE_AR_CAMERA_INTRO:int = 14;
      
      public static const NOTICE_COOKING_ITEM_INFO:int = 15;
      
      public static const NOTICE_COOKING_ITEM_ALREADY:int = 16;
      
      public static const NOTICE_AR_CAMERA_HOME_INDUCTION:int = 17;
      
      public static const NOTICE_GACHA_INFO:int = 18;
      
      public static const NOTICE_SNS_ICON:int = 19;
      
      public static const NOTICE_RARE_VOICE:int = 20;
      
      public static const NOTICE_MISSION_EVENT_INFO:int = 21;
      
      public static const NOTICE_MICROWAVE_ATTENTION:int = 22;
      
      public static const NOTICE_RANKING_EVENT_INFO:int = 23;
      
      public static const NOTICE_EVENT_KW_INFO:int = 24;
      
      public static const NOTICE_HIDE_GUDE_GUIDE:int = 25;
      
      public static const NOTICE_DECO_GUIDE:int = 26;
      
      public static const NOTICE_CUP_GACHA_GUIDE:int = 27;
      
      public static const NOTICE_HOME_DECO_GUIDE:int = 28;
      
      public static const NOTICE_HELPER1_INFO:int = 29;
      
      public static const NOTICE_SECOND_PICTURE_BOOK:int = 30;
      
      public static const NOTICE_GUIDE_TALK_BASE_ID:int = 1000;
      
      public static const BIT_SNS_LINK_BONUS:int = 1;
       
      
      public var noticeFlags:ByteArray;
      
      public var tutorialProgress:int;
      
      public var bitFlags:int;
      
      public function NoticeFlagData()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         noticeFlags = CompatibleDataIO.read(param1) as ByteArray;
         tutorialProgress = param1.readInt();
         bitFlags = param1.readInt();
      }
      
      public function write(param1:ByteArray) : void
      {
         CompatibleDataIO.write(param1,noticeFlags,4);
         param1.writeInt(tutorialProgress);
         param1.writeInt(bitFlags);
      }
   }
}
