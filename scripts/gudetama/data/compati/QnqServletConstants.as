package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class QnqServletConstants
   {
      
      public static const UIID_LENGTH:int = 36;
      
      public static const PLAYERNAME_LENGTH_MIN:int = 2;
      
      public static const PLAYERNAME_LENGTH_MAX:int = 8;
      
      public static const PLAYERCOMMENT_LENGTH_MIN:int = 2;
      
      public static const PLAYERCOMMENT_LENGTH_MAX:int = 30;
      
      public static const MESSAGE_LENGTH_MIN:int = 2;
      
      public static const MESSAGE_LENGTH_MAX:int = 120;
      
      public static const TAKEOVER_CODE_LENGTH:int = 9;
      
      public static const SUPPORTOR_PRENSET_MESSAGE_LENGTH_MIN:int = 2;
      
      public static const SUPPORTOR_PRENSET_MESSAGE_LENGTH_MAX:int = 15;
      
      public static const GUILDNAME_LENGTH_MIN:int = 2;
      
      public static const GUILDNAME_LENGTH_MAX:int = 10;
      
      public static const GUILDCOMMENT_LENGTH_MIN:int = 2;
      
      public static const GUILDCOMMENT_LENGTH_MAX:int = 15;
      
      public static const GUILDKEY_LENGTH_MIN:int = 2;
      
      public static const GUILDKEY_LENGTH_MAX:int = 10;
      
      public static const TAKEOVER_PASSWORD_LENGTH_MIN:int = 4;
      
      public static const TAKEOVER_PASSWORD_LENGTH_MAX:int = 12;
      
      public static const REQUEST_PARAM_DIRECT:String = "d";
      
      public static const REQUEST_PARAM_DIRECT_APPPLATFORM:String = "a";
      
      public static const REQUEST_PARAM_DIRECT_APPPVERSION:String = "va";
      
      public static const REQUEST_PARAM_UIID:String = "u";
      
      public static const REQUEST_PARAM_APP_VERSION:String = "v";
      
      public static const REQUEST_PARAM_NO_REDIRECT:String = "n";
      
      public static const REQUEST_PARAM_APP_PLATFORM:String = "p";
      
      public static const REQUEST_PARAM_COMPATIBLE_VERSION:String = "c";
      
      public static const REQUEST_PARAM_IDFV:String = "i";
      
      public static const REQUEST_PARAM_LOCALE:String = "l";
      
      public static const REQUEST_PARAM_SESSION:String = "s";
      
      public static const REQUEST_PARAM:String = "r";
      
      public static const REQUEST_PARAM_ENCRYPTED:String = "e";
      
      public static const REQUEST_PARAM_UID:String = "ui";
      
      public static const REQUEST_PARAM_LOG:String = "log";
      
      public static const REQUEST_PARAM_TAKEOVER:String = "t";
      
      public static const REQUEST_PARAM_TAKEOVER_PLATFROM:String = "tp";
      
      public static const REQUEST_PARAM_TAKEOVER_PASSWORD:String = "pwt";
      
      public static const REQUEST_PARAM_APP_ONESTORE:String = "o";
      
      public static const RESPONSE_PLAIN:int = 125;
      
      public static const RESPONSE_ENCRYPTED:int = 78;
      
      public static const RESPONSE_ENCRYPTED_WITH_SEQUENCE:int = 64;
      
      public static const RESPONSE_ERROR_OTHERS:int = -1;
      
      public static const RESPONSE_SESSION_CLOSED:int = -2;
      
      public static const RESPONSE_MAINTENANCE:int = -3;
      
      public static const RESPONSE_CONGESTION:int = -4;
      
      public static const RESPONSE_UNAVAILABLE:int = -5;
      
      public static const RESPONSE_INVALID_REQUEST:int = -6;
      
      public static const RESPONSE_NOT_ALLOWED:int = -7;
      
      public static const RESPONSE_REJECT_WITH_MESSAGE:int = -8;
      
      public static const RESPONSE_DECRYPT_ERROR:int = -9;
      
      public static const ENTRANCE_RESPONSE_OK:int = 14;
      
      public static const ENTRANCE_RESPONSE_REDIRECT:int = 7;
      
      public static const ENTRANCE_RESPONSE_NEED_UPDATE:int = 11;
      
      public static const TAKEOVER_RESPONSE_SUCCESS:int = 25;
      
      public static const TAKEOVER_RESPONSE_INVALID_CODE:int = 21;
      
      public static const TAKEOVER_RESPONSE_CODE_PUBLISHED_SAME_UIID:int = 34;
      
      public static const TAKEOVER_RESPONSE_UNKNOWN_ERROR:int = 42;
      
      public static const RESPONSE_EXTRA_RELOAD_SETTING:String = "reload_setting:";
      
      public static const RESPONSE_EXTRA_NUM_PRESENTS:String = "prs:";
      
      public static const RESPONSE_EXTRA_BANNERIDS:String = "bannerids:";
      
      public static const RESPONSE_EXTRA_NUM_FOLLOWERS:String = "num_followers:";
      
      public static const RESPONSE_EXTRA_NUM_FOLLOWS:String = "num_follows:";
      
      public static const RESPONSE_EXTRA_UPDATED_DAILY_MISSION:String = "m_ud:";
      
      public static const RESPONSE_EXTRA_MODIFIED_MISSION:String = "m_mod:";
      
      public static const RESPONSE_EXTRA_PRIMAL_MISSION:String = "m_prm:";
      
      public static const RESPONSE_EXTRA_INACTIVE_MISSION:String = "m_deact:";
      
      public static const RESPONSE_EXTRA_RECENT_MET_DIRTY:String = "rm_dirty:";
      
      public static const RESPONSE_EXTRA_MENU_BALLOON:String = "m_balloon:";
      
      public static const RESPONSE_EXTRA_NUM_TASTING_QUIZ:String = "num_quizzes:";
      
      public static const RESPONSE_EXTRA_CONTRIBUTE_QUIZ_REWARD:String = "cont_reward:";
      
      public static const RESPONSE_EXTRA_ASSIST:String = "assist:";
      
      public static const RESPONSE_EXTRA_PRESENT_MONEY:String = "present_money:";
      
      public static const RESPONSE_EXTRA_ABILITY:String = "ability:";
      
      public static const RESPONSE_EXTRA_FEATURE:String = "feature:";
      
      public static const RESPONSE_EXTRA_TOUCH:String = "touch:";
      
      public static const RESPONSE_EXTRA_TOUCH_UPDATE:String = "touch_u:";
      
      public static const RESPONSE_EXTRA_TOUCH_INFO:String = "touch_info:";
      
      public static const RESPONSE_EXTRA_KITCHENWARE:String = "kitchenware:";
      
      public static const RESPONSE_EXTRA_RECIPE_NOTE:String = "recipe_note:";
      
      public static const RESPONSE_EXTRA_GUDETAMA:String = "gudetama:";
      
      public static const RESPONSE_EXTRA_AVATAR:String = "avatar:";
      
      public static const RESPONSE_EXTRA_DECORATION:String = "decoration:";
      
      public static const RESPONSE_EXTRA_STAMP:String = "stamp:";
      
      public static const RESPONSE_EXTRA_USEFUL:String = "useful:";
      
      public static const RESPONSE_EXTRA_UTENSIL:String = "utensil:";
      
      public static const RESPONSE_EXTRA_VIDEO_AD_REWARD:String = "video_ad_reward:";
      
      public static const RESPONSE_EXTRA_LINKAGE:String = "linkage:";
      
      public static const RESPONSE_EXTRA_NEW_FRIEND:String = "new_friend:";
      
      public static const RESPONSE_EXTRA_HIDE_GUDE:String = "hidegude:";
      
      public static const RESPONSE_EXTRA_OFFERWALL:String = "offerwall:";
      
      public static const RESPONSE_EXTRA_SNS_LINK_BONUS:String = "slb:";
      
      public static const RESPONSE_EXTRA_MONTHLY_PREMIUM_BONUS:String = "monthly:";
      
      public static const RESPONSE_EXTRA_MENU_ITEMS:String = "menu:";
      
      public static const RESPONSE_EXTRA_EVENT:String = "event:";
      
      public static const RESPONSE_EXTRA_ID_PRESENT:String = "id_present:";
      
      public static const RESPONSE_EXTRA_RANKING_POINT_ADD:String = "rpadd:";
      
      public static const RESPONSE_EXTRA_RANKING_POINT_REWARD:String = "rpreward:";
      
      public static const RESPONSE_EXTRA_RANKING_GLOBAL_POINT_REWARD:String = "rgpreward:";
      
      public static const RESPONSE_EXTRA_TOUCH_COUNT:String = "touch_count:";
      
      public static const RESPONSE_EXTRA_SET_ITEM:String = "set_item:";
      
      public static const RESPONSE_EXTRA_NOTICE_PREMIUM:String = "n_pre:";
      
      public static const RESPONSE_EXTRA_CUP_GACHA:String = "cgacha:";
      
      public static const RESPONSE_SET_PLAYERNAME_CORRECT:int = 0;
      
      public static const RESPONSE_SET_PLAYERNAME_INVALID:int = 1;
      
      public static const RESPONSE_SET_PLAYERNAME_OVER:int = 2;
      
      public static const RESPONSE_SET_PLAYERNAME_NOT_ENOUGH:int = 3;
      
      public static const RESPONSE_SET_PLAYERNAME_BAD:int = 4;
      
      public static const SEND_EXTRA_TOUCH:String = "send_touch:";
      
      public static const SEND_EXTRA_DROP:String = "send_drop:";
      
      public static const SEND_EXTRA_HEAVEN:String = "send_heaven:";
      
      public static const SEND_EXTRA_SHOW_CSBANNER:String = "send_show_csbanner:";
      
      public static const SEND_EXTRA_SHOW_CSBANNER_IDS:String = "send_show_csbanner_ids:";
      
      public static const SEND_EXTRA_SHOW_CSINTERSTITIAL:String = "send_show_csinter:";
      
      public static const RESPONSE_EXTRA_RATE_BANNER_ADS:String = "bannerads:";
      
      public static const RESPONSE_EXTRA_RATE_VIDEO_ADS:String = "videoads:";
      
      public static const RESPONSE_EXTRA_RATE_INTER_ADS:String = "interstitialads:";
      
      public static const RESPONSE_EXTRA_PRIORITY_VIDEO_ADS:String = "priorityvideoads:";
      
      public static const RESPONSE_EXTRA_HELPER:String = "helper:";
      
      public static const TAG_GENERAL:int = 0;
      
      public static const TAG_HOME:int = 1;
      
      public static const TAG_RANKING:int = 2;
      
      public static const TAG_SHOP:int = 3;
      
      public static const TAG_FRIEND:int = 4;
      
      public static const TAG_OPENING:int = 6;
      
      public static const TAG_DEBUG:int = 7;
      
      public static const TAG_COOKING:int = 8;
      
      public static const TAG_COLLECTION:int = 9;
      
      public static const TAG_GACHA:int = 10;
      
      public static const TAG_MISSION:int = 11;
      
      public static const TAG_PROFILE:int = 12;
      
      public static const TAG_DECORATION:int = 13;
      
      public static const TAG_LINKAGE:int = 14;
      
      public static const TAG_OPTION:int = 15;
      
      public static const TAG_AR:int = 16;
      
      public static const TAGMASK_GENERAL:int = 0;
      
      public static const TAGMASK_HOME:int = 16777216;
      
      public static const TAGMASK_RANKING:int = 33554432;
      
      public static const TAGMASK_SHOP:int = 50331648;
      
      public static const TAGMASK_FRIEND:int = 67108864;
      
      public static const TAGMASK_OPENING:int = 100663296;
      
      public static const TAGMASK_DEBUG:int = 117440512;
      
      public static const TAGMASK_COOKING:int = 134217728;
      
      public static const TAGMASK_COLLECTION:int = 150994944;
      
      public static const TAGMASK_GACHA:int = 167772160;
      
      public static const TAGMASK_MISSION:int = 184549376;
      
      public static const TAGMASK_PROFILE:int = 201326592;
      
      public static const TAGMASK_DECORATION:int = 218103808;
      
      public static const TAGMASK_LINKAGE:int = 234881024;
      
      public static const TAGMASK_OPTION:int = 251658240;
      
      public static const TAGMASK_AR:int = 268435456;
      
      public static const DEBUG_GENERATE_USERDATA:int = 117441511;
      
      public static const DEBUG_RELOAD_CONF:int = 117441501;
      
      public static const DEBUG_USER_NAME:int = 117441498;
      
      public static const DEBUG_PURCHASE:int = 117441497;
      
      public static const DEBUG_INPUT_MONEY:int = 117441496;
      
      public static const DEBUG_HIDE_GUDE:int = 117441495;
      
      public static const DEBUG_NOTICE_RETRY:int = 117441494;
      
      public static const DEBUG_LOGOUT:int = 117441493;
      
      public static const DEBUG_UNLOCK_VOICE:int = 117441492;
      
      public static const DEBUG_UNLOCK_ALL:int = 117441491;
      
      public static const DEBUG_UNLOCK_MISSION:int = 117441490;
      
      public static const DEBUG_CHANGE_NOTICE_BIT_FLAG:int = 117441489;
      
      public static const DEBUG_FREE_GUDETAMA:int = 117441488;
      
      public static const DEBUG_CHANGE_METAL:int = 117441487;
      
      public static const DEBUG_FREE_USEFULITEM:int = 117441486;
      
      public static const DEBUG_COOK_GUDETAMA:int = 117441485;
      
      public static const DEBUG_RESET_LOGIN_PRESENT_TIME:int = 117441484;
      
      public static const DEBUG_RESET_CARNAVI:int = 117441483;
      
      public static const DEBUG_RESET_SHARE_BONUS:int = 117441482;
      
      public static const DEBUG_RESET_MONTHLY_PREMIUMBONUS:int = 117441481;
      
      public static const DEBUG_SEND_PRESENT:int = 117441480;
      
      public static const DEBUG_RESET_DAILY_MISSION:int = 117441479;
      
      public static const DEBUG_RESET_NEXT_HIDE_GUDE:int = 117441478;
      
      public static const DEBUG_CHANGE_AREA:int = 117441477;
      
      public static const DEBUG_RESET_GUDE_PRESENT_REST:int = 117441476;
      
      public static const DEBUG_RESET_SETITEM_BUYDATA:int = 117441475;
      
      public static const DEBUG_COOKING_UNLOCK:int = 117441474;
      
      public static const GENERAL_CUP_GACHA_PLACE:int = 1;
      
      public static const GENERAL_INIT_AT_LOGIN:int = 10;
      
      public static const GENERAL_RELOGIN:int = 11;
      
      public static const GENERAL_PUSH_PACKET:int = 19;
      
      public static const GENERAL_PURCHASE:int = 23;
      
      public static const GENERAL_PUSH_TOKEN:int = 25;
      
      public static const GENERAL_SEND_MESSAGE:int = 26;
      
      public static const GENERAL_GET_MESSAGES:int = 27;
      
      public static const GENERAL_REQUEST_TAKEOVER_CODE:int = 28;
      
      public static const GENERAL_PURCHASE_CHECK:int = 29;
      
      public static const GENERAL_PUSH_PERMIT:int = 38;
      
      public static const GENERAL_RANKING_INFO:int = 51;
      
      public static const GENERAL_PING:int = 59;
      
      public static const GENERAL_ENTER_HOME:int = 60;
      
      public static const GENERAL_ENTER_SHOP:int = 62;
      
      public static const GENERAL_ENTER_FRIEND:int = 63;
      
      public static const GENERAL_GET_AVAILABLE_SYSTEM_MAILS:int = 66;
      
      public static const PACKET_GET_NUM_FOLLOWERS:int = 69;
      
      public static const GENERAL_GET_PRESENT:int = 72;
      
      public static const GENERAL_GET_PRESENT_BULK:int = 73;
      
      public static const GENERAL_ENTER_OPENING:int = 77;
      
      public static const PACKET_GET_ANDROID_PUBLIC_KEY:int = 114;
      
      public static const GENERAL_APPSFLYER_UID:int = 119;
      
      public static const GENERAL_CHECK_TAKEOVER_CODE:int = 124;
      
      public static const GENERAL_REQUEST_FOLLOW:int = 127;
      
      public static const GENERAL_ENTER_COOKING:int = 141;
      
      public static const GENERAL_ENTER_COLLECTION:int = 142;
      
      public static const GENERAL_ENTER_GACHA:int = 143;
      
      public static const GENERAL_ENTER_MISSION:int = 144;
      
      public static const GENERAL_ENTER_PROFILE:int = 145;
      
      public static const GENERAL_ENTER_DECORATION:int = 146;
      
      public static const GENERAL_ENTER_LINKAGE:int = 147;
      
      public static const GENERAL_ENTER_OPTION:int = 148;
      
      public static const GENERAL_ENTER_AR:int = 149;
      
      public static const GENERAL_ENTER_RANKING:int = 150;
      
      public static const GENERAL_CHECK_CLEARED_MISSION:int = 159;
      
      public static const GENERAL_READ_INFORMATION:int = 160;
      
      public static const GENERAL_FRIEND_REQUEST_FOLLOW:int = 162;
      
      public static const GENERAL_FRIEND_REMOVE_FOLLOW:int = 163;
      
      public static const GENERAL_UPDATE_WANTED:int = 166;
      
      public static const GENERAL_FRIEND_DETAIL:int = 167;
      
      public static const GENERAL_PRESENT_TO_FRIEND:int = 168;
      
      public static const FRIEND_PRESENT_WARN_NOT_MUTUAL:int = -1;
      
      public static const FRIEND_PRESENT_WARN_NOT_WANTED:int = -2;
      
      public static const FRIEND_PRESENT_MONEY_WARN_ZERO:int = -3;
      
      public static const GENERAL_USE_USEFUL:int = 189;
      
      public static const GENERAL_EXTRA:int = 190;
      
      public static const PACKET_START_TUTORIAL_GUIDE:int = 202;
      
      public static const PACKET_CHECK_AND_START_TUTORIAL_GUIDE:int = 203;
      
      public static const PACKET_CHECK_TUTORIAL_GUIDE:int = 204;
      
      public static const GENERAL_LINK_SNS:int = 208;
      
      public static const GENERAL_SEARCH_SNS_PROFILE:int = 209;
      
      public static const PACKET_DONE_NOTICE_GUIDE:int = 210;
      
      public static const PACKET_SHARED:int = 217;
      
      public static const PACKET_GET_SHARE_BONUS_PARAM:int = 218;
      
      public static const GENERAL_GET_WANTED_FRIENDS:int = 219;
      
      public static const GENERAL_PROFILE_NAME:int = 220;
      
      public static const GENERAL_PRESENT_TO_FRIEND_AT_FREE:int = 221;
      
      public static const GENERAL_UNLINK_SNS:int = 225;
      
      public static const GENERAL_PRESENT_MONEY_TO_FRIEND:int = 228;
      
      public static const GENERAL_GET_OFFERWALL_REWARD:int = 229;
      
      public static const PACKET_TRIED_SHARE:int = 236;
      
      public static const GENERAL_STARTED_VIDEO:int = 237;
      
      public static const GENERAL_GET_VIDEO_RATE:int = 238;
      
      public static const GENERAL_TOUCH_BANNER:int = 239;
      
      public static const GENERAL_IDENTIFIED_PRESENT:int = 240;
      
      public static const GENERAL_PRESENT_TO_FRIEND_AT_GP:int = 241;
      
      public static const GENERAL_CHECK_GUDE_PRESENT:int = 242;
      
      public static const GENERAL_TOUCH_IINTERSTITIAL:int = 243;
      
      public static const GENERAL_GET_DIALOG_SHARE_BONUS:int = 247;
      
      public static const GENERAL_SHARED_DIALOG:int = 248;
      
      public static const GENERAL_CHECK_KITCHENWARE:int = 249;
      
      public static const GACHA_GET_AVAILABLE_DATA_LIST:int = 167772315;
      
      public static const GACHA_PLAY:int = 167772316;
      
      public static const GACHA_PLAY_FREE:int = 167772317;
      
      public static const GACHA_PLAY_ONCE_MORE:int = 167772318;
      
      public static const GACHA_PLAY_ENTRY:int = 167772373;
      
      public static const GACHA_PLAY_STAMP:int = 167772409;
      
      public static const GACHA_PLAY_WARN_OUT_OF_TERM:int = -1;
      
      public static const FRIEND_GET_LIST:int = 67109025;
      
      public static const FRIEND_SEARCH:int = 67109028;
      
      public static const FRIEND_ENTER_ROOM:int = 67109033;
      
      public static const FRIEND_ASSIST:int = 67109034;
      
      public static const FRIEND_ASSIST_WARN_NOT_COOKING:int = -1;
      
      public static const FRIEND_ASSIST_WARN_COMPLETED:int = -2;
      
      public static const FRIEND_ASSIST_WARN_EXISTS_USEFUL:int = -3;
      
      public static const FRIEND_ANSWER_QUESTION:int = 67109035;
      
      public static const FRIEND_EXTENSION:int = 67109036;
      
      public static const FRIEND_REMOVE_FOLLOWER_AUTO:int = 67109037;
      
      public static const PROFILE_INIT:int = 201326757;
      
      public static const PROFILE_SET_AVATAR:int = 201326791;
      
      public static const PROFILE_NAME:int = 201326792;
      
      public static const PROFILE_SET_COMMENT:int = 201326793;
      
      public static const COOKING_START:int = 134217909;
      
      public static const COOKING_START_WARN_OUT_OF_TERM:int = 0;
      
      public static const COOKING_CANCEL:int = 134217910;
      
      public static const COOKING_CANCEL_WARN_COMPLETED:int = 0;
      
      public static const COOKING_HURRY_UP:int = 134217911;
      
      public static const COOKING_HURRY_UP_WARN_COMPLETED:int = 0;
      
      public static const COOKING_HURRY_UP_WARN_OUT_OF_TERM:int = 1;
      
      public static const COOKING_COMPLETE:int = 134217912;
      
      public static const COOKING_ROULETTE:int = 134217923;
      
      public static const COOKING_USEFUL:int = 134217924;
      
      public static const COOKING_UNLOCK:int = 134217925;
      
      public static const COOKING_PURCHASE_RECIPE:int = 134217926;
      
      public static const COOKING_FINISH:int = 134217942;
      
      public static const COOKING_RETRY:int = 134217943;
      
      public static const COOKING_RETRY_FREE:int = 134217951;
      
      public static const COOKING_REPAIR:int = 134217952;
      
      public static const COOKING_PLACE:int = 134217954;
      
      public static const COOKING_ROULETTE_START:int = 134217963;
      
      public static const COOKING_HURRY_UP_BY_USEFUL:int = 134217971;
      
      public static const COOKING_HURRY_UP_BY_USUALLY:int = 134217976;
      
      public static const COOKING_GET_CUP_GACHA_LIST_RECIPE:int = 134217977;
      
      public static const COLLECTION_PLACE:int = 150995129;
      
      public static const HOME_CUP_GACHA_COOK:int = 16777217;
      
      public static const HOME_CUP_GACHA_SHORT:int = 16777218;
      
      public static const HOME_CUP_GACHA_DRAW:int = 16777219;
      
      public static const HOME_CUP_GACHA_GUIDE:int = 16777220;
      
      public static const HOME_DELUSION:int = 16777402;
      
      public static const HOME_GET_INFO:int = 16777403;
      
      public static const HOME_LINKAGE_NOTIFY:int = 16777408;
      
      public static const HOME_USE_CODE:int = 16777409;
      
      public static const USE_CODE_FAILED_NOTFOUND:int = -1;
      
      public static const USE_CODE_FAILED_USED:int = -2;
      
      public static const USE_CODE_FAILED_LIMIT:int = -3;
      
      public static const USE_CODE_FAILED_ACQUIRED:int = -4;
      
      public static const HOME_UNLOCK_VOICE:int = 16777410;
      
      public static const PACKET_GET_GUDETAMA_VOICE_EVENT_TUTORIAL:int = 16777421;
      
      public static const PACKET_GET_HEAVEN_EVENT_TUTORIAL:int = 16777422;
      
      public static const PACKET_FINISHED_TUTORIAL_GUIDE:int = 16777423;
      
      public static const HOME_VIDEO_AD_REWARD:int = 16777428;
      
      public static const HOME_ASSIST_FROM_FRIEND:int = 16777446;
      
      public static const HOME_HIDE_GUDE:int = 16777447;
      
      public static const HOME_GET_HIDE_GUDE_SHARE_BONUS:int = 16777448;
      
      public static const HOME_HIDE_GUDE_SHARE:int = 16777450;
      
      public static const HOME_DECORATION_CHANGE:int = 16777460;
      
      public static const HOME_DECORATION_CHANGE_WARN_OUT_OF_TERM:int = -1;
      
      public static const GENERATE_HIDE_GUDE_4GUIDE:int = 16777461;
      
      public static const HOME_DECORATION_STAMP:int = 16777462;
      
      public static const HOME_DECORATION_EXTENSION_PLACE:int = 16777463;
      
      public static const HOME_UNLOCK_VOICE_USE_HELPER:int = 16777464;
      
      public static const HOME_MANUALDELETION_PRESENT:int = 16777465;
      
      public static const DECORATION_CHANGE:int = 218103999;
      
      public static const PURCHASE_ITEM:int = 50331664;
      
      public static const PACKET_SEND_MONEY_4PICTUREBOOK:int = 50331859;
      
      public static const PACKET_AR_EXTENSION_PLACE:int = 268435672;
      
      public static const AR_CAPTURE:int = 268435683;
      
      public static const RANKING_DELIVER:int = 33554433;
      
      public static const RANKING_DELIVER_ALL:int = 33554434;
      
      public static const PACKET_CHECKED_TERMS_OF_SERVICE:int = 100663307;
      
      public static const PACKET_SET_FIRSTLOGIN_INFO:int = 100663309;
      
      public static const FAIL_OVER_FRIENDS_SELF:int = -5;
      
      public static const FAIL_OVER_FRIENDS:int = -4;
      
      public static const FAIL_OVER_FOLLOWERS_SELF:int = -3;
      
      public static const FAIL_ALREADY_FOLLOW:int = -2;
      
      public static const FAIL_OVER_FOLLOWERS:int = -1;
      
      public static const SUCCESS:int = 0;
      
      public static const SUCCESS_MUTUAL:int = 1;
      
      public static const FAIL_RANKING_INVALID:int = -1;
      
      public static const FAIL_RANKING_NOT_FOUND:int = -2;
       
      
      public function QnqServletConstants()
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
