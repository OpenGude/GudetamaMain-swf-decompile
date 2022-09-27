import os
import re

src = """      public static const DEBUG_GENERATE_USERDATA:int = 117441511;
      
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
            
      public static const FRIEND_GET_LIST:int = 67109025;
      
      public static const FRIEND_SEARCH:int = 67109028;
      
      public static const FRIEND_ENTER_ROOM:int = 67109033;
      
      public static const FRIEND_ASSIST:int = 67109034;
      
      public static const FRIEND_ANSWER_QUESTION:int = 67109035;
      
      public static const FRIEND_EXTENSION:int = 67109036;
      
      public static const FRIEND_REMOVE_FOLLOWER_AUTO:int = 67109037;
      
      public static const PROFILE_INIT:int = 201326757;
      
      public static const PROFILE_SET_AVATAR:int = 201326791;
      
      public static const PROFILE_NAME:int = 201326792;
      
      public static const PROFILE_SET_COMMENT:int = 201326793;
      
      public static const COOKING_START:int = 134217909;
            
      public static const COOKING_CANCEL:int = 134217910;
            
      public static const COOKING_HURRY_UP:int = 134217911;
      
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
      
      public static const PACKET_SET_FIRSTLOGIN_INFO:int = 100663309;"""

request_types = {}

for line in src.split("\n"):
	line = line.strip()
	if not line:
		continue
	a = line.split(" const ")[1].split(":")[0]
	b = int(line.split("int = ")[1].split(";")[0])
	print(a, "=", hex(b))
	assert(b not in request_types)
	request_types[b] = a

def id_replace(match):
	num = match.group(2)
	return match.group(1) + request_types[int(num)] + match.group(3)

for root, subdirs, files in os.walk("scripts/"):
	for file in files:
		path = root + "/" + file
		source = open(path).read()
		fixed = re.sub(r"(PacketUtil\.create.*\()([0-9]+)([,\)])", id_replace, source)
		if fixed == source:
			continue
		with open(path, "w") as out:
			out.write(fixed)
