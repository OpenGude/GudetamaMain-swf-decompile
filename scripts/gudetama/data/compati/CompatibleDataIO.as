package gudetama.data.compati
{
   import flash.utils.ByteArray;
   import flash.utils.getQualifiedClassName;
   
   public class CompatibleDataIO
   {
      
      public static const CURRENT_VERSION:uint = 34;
      
      public static const ID_NULL:int = 0;
      
      public static const ID_OBJECT_ARRAY:int = 1;
      
      public static const ID_INT_ARRAY:int = 2;
      
      public static const ID_SHORT_ARRAY:int = 3;
      
      public static const ID_ByteArray:int = 4;
      
      public static const ID_FLOAT_ARRAY:int = 5;
      
      public static const ID_String:int = 6;
      
      public static const ID_INTHASHMAP:int = 7;
      
      public static const ID_HASHMAP:int = 8;
      
      public static const ID_ARRAYLIST:int = 9;
      
      public static const ID_INT:int = 10;
      
      public static const ID_SHORT:int = 11;
      
      public static const ID_CommonConstants:int = 12;
      
      public static const ID_QnqConstants:int = 13;
      
      public static const ID_Packet:int = 14;
      
      public static const ID_QnqServletConstants:int = 15;
      
      public static const ID_FileInfoDef:int = 16;
      
      public static const ID_ScreeningDef:int = 17;
      
      public static const ID_GameDef:int = 18;
      
      public static const ID_DictDef:int = 19;
      
      public static const ID_RuleDef:int = 20;
      
      public static const ID_MissionDef:int = 21;
      
      public static const ID_MissionParam:int = 22;
      
      public static const ID_MissionConstants:int = 23;
      
      public static const ID_GuideTalkDef:int = 24;
      
      public static const ID_GuideTalkParagraphParam:int = 25;
      
      public static const ID_GuideTalkSentenceParam:int = 26;
      
      public static const ID_EventPreset:int = 27;
      
      public static const ID_FirstLoginInfo:int = 28;
      
      public static const ID_ItemParam:int = 29;
      
      public static const ID_ConvertParam:int = 30;
      
      public static const ID_SequenceTable:int = 31;
      
      public static const ID_LinearTable:int = 32;
      
      public static const ID_UserData:int = 33;
      
      public static const ID_NoticeFlagData:int = 34;
      
      public static const ID_SystemMailData:int = 35;
      
      public static const ID_RankingRecord:int = 36;
      
      public static const ID_RankingDef:int = 37;
      
      public static const ID_RankingInfo:int = 38;
      
      public static const ID_MissionData:int = 39;
      
      public static const ID_MetalShopDef:int = 40;
      
      public static const ID_MetalShopItemDef:int = 41;
      
      public static const ID_CheckedMessageInfo:int = 42;
      
      public static const ID_RankingContentDef:int = 43;
      
      public static const ID_RankingRewardDef:int = 44;
      
      public static const ID_RankingRewardItemDef:int = 45;
      
      public static const ID_UserRankingData:int = 46;
      
      public static const ID_GudetamaConstants:int = 47;
      
      public static const ID_UserProfileData:int = 48;
      
      public static const ID_UserWantedData:int = 49;
      
      public static const ID_PresentLogData:int = 50;
      
      public static const ID_FriendInfo:int = 51;
      
      public static const ID_FriendPresentResult:int = 52;
      
      public static const ID_FriendAssistResult:int = 53;
      
      public static const ID_KitchenwareDef:int = 54;
      
      public static const ID_KitchenwareData:int = 55;
      
      public static const ID_KitchenwareParam:int = 56;
      
      public static const ID_KitchenwareInfo:int = 57;
      
      public static const ID_RecipeNoteDef:int = 58;
      
      public static const ID_RecipeNoteData:int = 59;
      
      public static const ID_GudetamaDef:int = 60;
      
      public static const ID_GudetamaData:int = 61;
      
      public static const ID_PossibleRouletteParam:int = 62;
      
      public static const ID_VoiceDef:int = 63;
      
      public static const ID_GachaDef:int = 64;
      
      public static const ID_GachaPriceDef:int = 65;
      
      public static const ID_GachaData:int = 66;
      
      public static const ID_UserGachaData:int = 67;
      
      public static const ID_UserGachaPriceData:int = 68;
      
      public static const ID_GachaResult:int = 69;
      
      public static const ID_ScreeningGachaItemParam:int = 70;
      
      public static const ID_UsefulDef:int = 71;
      
      public static const ID_UsefulData:int = 72;
      
      public static const ID_DecorationDef:int = 73;
      
      public static const ID_DecorationData:int = 74;
      
      public static const ID_DecorationInfo:int = 75;
      
      public static const ID_UtensilDef:int = 76;
      
      public static const ID_UtensilData:int = 77;
      
      public static const ID_StampDef:int = 78;
      
      public static const ID_AvatarDef:int = 79;
      
      public static const ID_MailPresentResult:int = 80;
      
      public static const ID_UserRoomInfo:int = 81;
      
      public static const ID_AssistInfo:int = 82;
      
      public static const ID_UserPresentMoneyData:int = 83;
      
      public static const ID_UserAssistData:int = 84;
      
      public static const ID_TouchEventDef:int = 85;
      
      public static const ID_DelusionDef:int = 86;
      
      public static const ID_DelusionParam:int = 87;
      
      public static const ID_TouchInfo:int = 88;
      
      public static const ID_TouchEventParam:int = 89;
      
      public static const ID_AbilityParam:int = 90;
      
      public static const ID_UserAbilityData:int = 91;
      
      public static const ID_FeatureDef:int = 92;
      
      public static const ID_FeatureParam:int = 93;
      
      public static const ID_LinkageDef:int = 94;
      
      public static const ID_LinkageData:int = 95;
      
      public static const ID_AvatarData:int = 96;
      
      public static const ID_QuestionDef:int = 97;
      
      public static const ID_QuestionParam:int = 98;
      
      public static const ID_QuestionInfo:int = 99;
      
      public static const ID_InitDictDef:int = 100;
      
      public static const ID_StampData:int = 101;
      
      public static const ID_StampInfo:int = 102;
      
      public static const ID_AvatarInfo:int = 103;
      
      public static const ID_UsefulInfo:int = 104;
      
      public static const ID_UtensilInfo:int = 105;
      
      public static const ID_VideoAdRewardDef:int = 106;
      
      public static const ID_PurchasePresentDef:int = 107;
      
      public static const ID_PurchasePresentItemDef:int = 108;
      
      public static const ID_FriendlyDef:int = 109;
      
      public static const ID_FriendlyParam:int = 110;
      
      public static const ID_FriendlyData:int = 111;
      
      public static const ID_ARExpansionGoodsDef:int = 112;
      
      public static const ID_TouchDef:int = 113;
      
      public static const ID_HideGudetamaDef:int = 114;
      
      public static const ID_CommentDef:int = 115;
      
      public static const ID_GetItemResult:int = 116;
      
      public static const ID_MonthlyPremiumBonusDef:int = 117;
      
      public static const ID_EventData:int = 118;
      
      public static const ID_PromotionVideoDef:int = 119;
      
      public static const ID_PromotionBannerSettingDef:int = 120;
      
      public static const ID_IdentifiedPresentDef:int = 121;
      
      public static const ID_VoiceParam:int = 122;
      
      public static const ID_DeliverPointTableDef:int = 123;
      
      public static const ID_SetItemDef:int = 124;
      
      public static const ID_SetItemBuyData:int = 125;
      
      public static const ID_ComicDef:int = 126;
      
      public static const ID_PromotionInterstitialSettingDef:int = 127;
      
      public static const ID_OnlyShowItemDef:int = 128;
      
      public static const ID_ShareBonusDef:int = 129;
      
      public static const ID_SetItemAlternativeParam:int = 130;
      
      public static const ID_CupGachaDef:int = 131;
      
      public static const ID_CupGachaData:int = 132;
      
      public static const ID_CupGachaResult:int = 133;
      
      public static const ID_HomeDecoData:int = 134;
      
      public static const ID_HomeExpansionGoodsDef:int = 135;
      
      public static const ID_HomeStampSettingDef:int = 136;
      
      public static const ID_SubHomeStampSettingDef:int = 137;
      
      public static const ID_HelperCharaDef:int = 138;
      
      public static const ID_ComicSpineDef:int = 139;
       
      
      public function CompatibleDataIO()
      {
         super();
      }
      
      public static function countKeys(param1:Object) : uint
      {
         var _loc2_:uint = 0;
         for(var _loc3_ in param1)
         {
            _loc2_++;
         }
         return _loc2_;
      }
      
      public static function getClassID(param1:Object) : int
      {
         if(param1 == null)
         {
            return 0;
         }
         var _loc2_:String = getQualifiedClassName(param1);
         if(_loc2_.indexOf("::") >= 0)
         {
            _loc2_ = getQualifiedClassName(param1).match(/::(.*)/)[1];
         }
         var _loc3_:String = "ID_" + _loc2_;
         if(_loc3_ in CompatibleDataIO)
         {
            return CompatibleDataIO[_loc3_];
         }
         return -1;
      }
      
      public static function write(param1:ByteArray, param2:Object, param3:int = -1) : void
      {
         var _loc4_:* = null;
         var _loc5_:int = 0;
         var _loc6_:* = null;
         var _loc7_:int = 0;
         if(param2 == null)
         {
            param3 = 0;
         }
         if(param3 < 0)
         {
            param3 = getClassID(param2);
         }
         if(param3 < 0)
         {
            trace("not supported type: " + param2);
            return;
         }
         param1.writeShort(param3);
         if(param3 >= 12)
         {
            param2.write(param1);
            return;
         }
         switch(int(param3))
         {
            case 0:
               break;
            case 1:
               param1.writeShort(param2.length);
               _loc7_ = -1;
               if(param2.length > 0)
               {
                  _loc7_ = getClassID(param2[0]);
               }
               if(_loc7_ >= 12)
               {
                  _loc5_ = 0;
                  while(_loc5_ < param2.length)
                  {
                     param2[_loc5_].write(param1);
                     _loc5_++;
                  }
               }
               else
               {
                  _loc5_ = 0;
                  while(_loc5_ < param2.length)
                  {
                     write(param1,param2[_loc5_]);
                     _loc5_++;
                  }
               }
               break;
            case 2:
               param1.writeShort(param2.length);
               _loc5_ = 0;
               while(_loc5_ < param2.length)
               {
                  param1.writeInt(param2[_loc5_]);
                  _loc5_++;
               }
               break;
            case 3:
               param1.writeShort(param2.length);
               _loc5_ = 0;
               while(_loc5_ < param2.length)
               {
                  param1.writeShort(param2[_loc5_]);
                  _loc5_++;
               }
               break;
            case 4:
               param1.writeInt(param2.length);
               param1.writeBytes(param2 as ByteArray,0,param2.length);
               break;
            case 5:
               param1.writeShort(param2.length);
               _loc5_ = 0;
               while(_loc5_ < param2.length)
               {
                  param1.writeFloat(param2[_loc5_]);
                  _loc5_++;
               }
               break;
            case 6:
               param1.writeUTF(param2 as String);
               break;
            case 7:
               param1.writeShort(countKeys(param2));
               for(_loc6_ in param2)
               {
                  param1.writeInt(int(_loc6_));
                  write(param1,param2[_loc6_]);
               }
               break;
            case 8:
               param1.writeShort(countKeys(param2));
               for(_loc6_ in param2)
               {
                  param1.writeUTF(_loc6_);
                  write(param1,param2[_loc6_]);
               }
               break;
            case 9:
               param1.writeShort(param2.length);
               _loc5_ = 0;
               while(_loc5_ < param2.length)
               {
                  write(param1,param2[_loc5_]);
                  _loc5_++;
               }
               break;
            case 10:
               param1.writeInt(param2 as int);
               break;
            case 11:
               param1.writeShort(param2 as int);
         }
      }
      
      public static function read(param1:ByteArray) : Object
      {
         var _loc46_:* = null;
         var _loc11_:* = 0;
         var _loc58_:int = 0;
         var _loc18_:* = null;
         var _loc23_:* = null;
         var _loc55_:* = null;
         var _loc130_:* = null;
         var _loc79_:* = null;
         var _loc127_:* = null;
         var _loc60_:* = null;
         var _loc32_:* = null;
         var _loc100_:* = null;
         var _loc80_:* = null;
         var _loc36_:* = null;
         var _loc71_:* = null;
         var _loc38_:* = null;
         var _loc6_:* = null;
         var _loc67_:* = null;
         var _loc113_:* = null;
         var _loc68_:* = null;
         var _loc128_:* = null;
         var _loc103_:* = null;
         var _loc114_:* = null;
         var _loc76_:* = null;
         var _loc86_:* = null;
         var _loc69_:* = null;
         var _loc106_:* = null;
         var _loc3_:* = null;
         var _loc15_:* = null;
         var _loc119_:* = null;
         var _loc59_:* = null;
         var _loc26_:* = null;
         var _loc90_:* = null;
         var _loc4_:* = null;
         var _loc40_:* = null;
         var _loc97_:* = null;
         var _loc91_:* = null;
         var _loc99_:* = null;
         var _loc31_:* = null;
         var _loc104_:* = null;
         var _loc34_:* = null;
         var _loc54_:* = null;
         var _loc50_:* = null;
         var _loc5_:* = null;
         var _loc92_:* = null;
         var _loc56_:* = null;
         var _loc19_:* = null;
         var _loc72_:* = null;
         var _loc12_:* = null;
         var _loc13_:* = null;
         var _loc78_:* = null;
         var _loc41_:* = null;
         var _loc9_:* = null;
         var _loc22_:* = null;
         var _loc64_:* = null;
         var _loc16_:* = null;
         var _loc37_:* = null;
         var _loc49_:* = null;
         var _loc85_:* = null;
         var _loc10_:* = null;
         var _loc109_:* = null;
         var _loc33_:* = null;
         var _loc30_:* = null;
         var _loc51_:* = null;
         var _loc88_:* = null;
         var _loc115_:* = null;
         var _loc116_:* = null;
         var _loc112_:* = null;
         var _loc24_:* = null;
         var _loc129_:* = null;
         var _loc48_:* = null;
         var _loc111_:* = null;
         var _loc52_:* = null;
         var _loc28_:* = null;
         var _loc73_:* = null;
         var _loc108_:* = null;
         var _loc81_:* = null;
         var _loc105_:* = null;
         var _loc89_:* = null;
         var _loc45_:* = null;
         var _loc44_:* = null;
         var _loc93_:* = null;
         var _loc47_:* = null;
         var _loc118_:* = null;
         var _loc75_:* = null;
         var _loc123_:* = null;
         var _loc74_:* = null;
         var _loc101_:* = null;
         var _loc7_:* = null;
         var _loc131_:* = null;
         var _loc77_:* = null;
         var _loc70_:* = null;
         var _loc62_:* = null;
         var _loc57_:* = null;
         var _loc95_:* = null;
         var _loc42_:* = null;
         var _loc21_:* = null;
         var _loc120_:* = null;
         var _loc63_:* = null;
         var _loc53_:* = null;
         var _loc20_:* = null;
         var _loc98_:* = null;
         var _loc14_:* = null;
         var _loc65_:* = null;
         var _loc102_:* = null;
         var _loc27_:* = null;
         var _loc82_:* = null;
         var _loc125_:* = null;
         var _loc35_:* = null;
         var _loc61_:* = null;
         var _loc25_:* = null;
         var _loc122_:* = null;
         var _loc124_:* = null;
         var _loc132_:* = null;
         var _loc87_:* = null;
         var _loc29_:* = null;
         var _loc39_:* = null;
         var _loc84_:* = null;
         var _loc2_:* = null;
         var _loc66_:* = null;
         var _loc133_:* = null;
         var _loc94_:* = null;
         var _loc107_:* = null;
         var _loc126_:* = null;
         var _loc117_:* = null;
         var _loc8_:* = null;
         var _loc110_:* = null;
         var _loc43_:* = null;
         var _loc96_:* = null;
         var _loc83_:* = null;
         var _loc121_:* = null;
         var _loc17_:int;
         switch(_loc17_ = param1.readShort())
         {
            case 0:
               return null;
            case 1:
               _loc11_ = uint(param1.readShort());
               _loc46_ = new Array(_loc11_);
               _loc58_ = 0;
               while(_loc58_ < _loc11_)
               {
                  _loc46_[_loc58_] = read(param1);
                  _loc58_++;
               }
               break;
            case 2:
               _loc11_ = uint(param1.readShort());
               _loc46_ = new Array(_loc11_);
               _loc58_ = 0;
               while(_loc58_ < _loc11_)
               {
                  _loc46_[_loc58_] = param1.readInt();
                  _loc58_++;
               }
               break;
            case 3:
               _loc11_ = uint(param1.readShort());
               _loc46_ = new Array(_loc11_);
               _loc58_ = 0;
               while(_loc58_ < _loc11_)
               {
                  _loc46_[_loc58_] = param1.readShort();
                  _loc58_++;
               }
               break;
            case 4:
               _loc11_ = uint(param1.readInt());
               _loc46_ = new ByteArray();
               param1.readBytes(_loc46_ as ByteArray,0,_loc11_);
               break;
            case 5:
               _loc11_ = uint(param1.readShort());
               _loc46_ = new Array(_loc11_);
               _loc58_ = 0;
               while(_loc58_ < _loc11_)
               {
                  _loc46_[_loc58_] = param1.readFloat();
                  _loc58_++;
               }
               break;
            case 6:
               _loc46_ = param1.readUTF();
               break;
            case 7:
               _loc11_ = uint(param1.readShort());
               _loc46_ = {};
               _loc58_ = 0;
               while(_loc58_ < _loc11_)
               {
                  _loc46_[param1.readInt()] = CompatibleDataIO.read(param1);
                  _loc58_++;
               }
               break;
            case 8:
               _loc11_ = uint(param1.readShort());
               _loc46_ = {};
               _loc58_ = 0;
               while(_loc58_ < _loc11_)
               {
                  _loc46_[param1.readUTF()] = CompatibleDataIO.read(param1);
                  _loc58_++;
               }
               break;
            case 9:
               _loc11_ = uint(param1.readShort());
               _loc46_ = new Array(_loc11_);
               _loc58_ = 0;
               while(_loc58_ < _loc11_)
               {
                  _loc46_[_loc58_] = CompatibleDataIO.read(param1);
                  _loc58_++;
               }
               break;
            case 10:
               _loc46_ = param1.readInt();
               break;
            case 11:
               _loc46_ = param1.readUnsignedShort();
               break;
            case 12:
               (_loc18_ = new CommonConstants()).read(param1);
               _loc46_ = _loc18_;
               break;
            case 13:
               (_loc23_ = new QnqConstants()).read(param1);
               _loc46_ = _loc23_;
               break;
            case 14:
               (_loc55_ = new Packet()).read(param1);
               _loc46_ = _loc55_;
               break;
            case 15:
               (_loc130_ = new QnqServletConstants()).read(param1);
               _loc46_ = _loc130_;
               break;
            case 16:
               (_loc79_ = new FileInfoDef()).read(param1);
               _loc46_ = _loc79_;
               break;
            case 17:
               (_loc127_ = new ScreeningDef()).read(param1);
               _loc46_ = _loc127_;
               break;
            case 18:
               (_loc60_ = new GameDef()).read(param1);
               _loc46_ = _loc60_;
               break;
            case 19:
               (_loc32_ = new DictDef()).read(param1);
               _loc46_ = _loc32_;
               break;
            case 20:
               (_loc100_ = new RuleDef()).read(param1);
               _loc46_ = _loc100_;
               break;
            case 21:
               (_loc80_ = new MissionDef()).read(param1);
               _loc46_ = _loc80_;
               break;
            case 22:
               (_loc36_ = new MissionParam()).read(param1);
               _loc46_ = _loc36_;
               break;
            case 23:
               (_loc71_ = new MissionConstants()).read(param1);
               _loc46_ = _loc71_;
               break;
            case 24:
               (_loc38_ = new GuideTalkDef()).read(param1);
               _loc46_ = _loc38_;
               break;
            case 25:
               (_loc6_ = new GuideTalkParagraphParam()).read(param1);
               _loc46_ = _loc6_;
               break;
            case 26:
               (_loc67_ = new GuideTalkSentenceParam()).read(param1);
               _loc46_ = _loc67_;
               break;
            case 27:
               (_loc113_ = new EventPreset()).read(param1);
               _loc46_ = _loc113_;
               break;
            case 28:
               (_loc68_ = new FirstLoginInfo()).read(param1);
               _loc46_ = _loc68_;
               break;
            case 29:
               (_loc128_ = new ItemParam()).read(param1);
               _loc46_ = _loc128_;
               break;
            case 30:
               (_loc103_ = new ConvertParam()).read(param1);
               _loc46_ = _loc103_;
               break;
            case 31:
               (_loc114_ = new SequenceTable()).read(param1);
               _loc46_ = _loc114_;
               break;
            case 32:
               (_loc76_ = new LinearTable()).read(param1);
               _loc46_ = _loc76_;
               break;
            case 33:
               (_loc86_ = new UserData()).read(param1);
               _loc46_ = _loc86_;
               break;
            case 34:
               (_loc69_ = new NoticeFlagData()).read(param1);
               _loc46_ = _loc69_;
               break;
            case 35:
               (_loc106_ = new SystemMailData()).read(param1);
               _loc46_ = _loc106_;
               break;
            case 36:
               _loc3_ = new RankingRecord();
               _loc3_.read(param1);
               _loc46_ = _loc3_;
               break;
            case 37:
               (_loc15_ = new RankingDef()).read(param1);
               _loc46_ = _loc15_;
               break;
            case 38:
               (_loc119_ = new RankingInfo()).read(param1);
               _loc46_ = _loc119_;
               break;
            case 39:
               (_loc59_ = new MissionData()).read(param1);
               _loc46_ = _loc59_;
               break;
            case 40:
               (_loc26_ = new MetalShopDef()).read(param1);
               _loc46_ = _loc26_;
               break;
            case 41:
               (_loc90_ = new MetalShopItemDef()).read(param1);
               _loc46_ = _loc90_;
               break;
            case 42:
               (_loc4_ = new CheckedMessageInfo()).read(param1);
               _loc46_ = _loc4_;
               break;
            case 43:
               (_loc40_ = new RankingContentDef()).read(param1);
               _loc46_ = _loc40_;
               break;
            case 44:
               (_loc97_ = new RankingRewardDef()).read(param1);
               _loc46_ = _loc97_;
               break;
            case 45:
               (_loc91_ = new RankingRewardItemDef()).read(param1);
               _loc46_ = _loc91_;
               break;
            case 46:
               (_loc99_ = new UserRankingData()).read(param1);
               _loc46_ = _loc99_;
               break;
            case 47:
               (_loc31_ = new GudetamaConstants()).read(param1);
               _loc46_ = _loc31_;
               break;
            case 48:
               (_loc104_ = new UserProfileData()).read(param1);
               _loc46_ = _loc104_;
               break;
            case 49:
               (_loc34_ = new UserWantedData()).read(param1);
               _loc46_ = _loc34_;
               break;
            case 50:
               (_loc54_ = new PresentLogData()).read(param1);
               _loc46_ = _loc54_;
               break;
            case 51:
               (_loc50_ = new FriendInfo()).read(param1);
               _loc46_ = _loc50_;
               break;
            case 52:
               (_loc5_ = new FriendPresentResult()).read(param1);
               _loc46_ = _loc5_;
               break;
            case 53:
               (_loc92_ = new FriendAssistResult()).read(param1);
               _loc46_ = _loc92_;
               break;
            case 54:
               (_loc56_ = new KitchenwareDef()).read(param1);
               _loc46_ = _loc56_;
               break;
            case 55:
               (_loc19_ = new KitchenwareData()).read(param1);
               _loc46_ = _loc19_;
               break;
            case 56:
               (_loc72_ = new KitchenwareParam()).read(param1);
               _loc46_ = _loc72_;
               break;
            case 57:
               (_loc12_ = new KitchenwareInfo()).read(param1);
               _loc46_ = _loc12_;
               break;
            case 58:
               (_loc13_ = new RecipeNoteDef()).read(param1);
               _loc46_ = _loc13_;
               break;
            case 59:
               (_loc78_ = new RecipeNoteData()).read(param1);
               _loc46_ = _loc78_;
               break;
            case 60:
               (_loc41_ = new GudetamaDef()).read(param1);
               _loc46_ = _loc41_;
               break;
            case 61:
               (_loc9_ = new GudetamaData()).read(param1);
               _loc46_ = _loc9_;
               break;
            case 62:
               (_loc22_ = new PossibleRouletteParam()).read(param1);
               _loc46_ = _loc22_;
               break;
            case 63:
               (_loc64_ = new VoiceDef()).read(param1);
               _loc46_ = _loc64_;
               break;
            case 64:
               (_loc16_ = new GachaDef()).read(param1);
               _loc46_ = _loc16_;
               break;
            case 65:
               (_loc37_ = new GachaPriceDef()).read(param1);
               _loc46_ = _loc37_;
               break;
            case 66:
               (_loc49_ = new GachaData()).read(param1);
               _loc46_ = _loc49_;
               break;
            case 67:
               (_loc85_ = new UserGachaData()).read(param1);
               _loc46_ = _loc85_;
               break;
            case 68:
               (_loc10_ = new UserGachaPriceData()).read(param1);
               _loc46_ = _loc10_;
               break;
            case 69:
               (_loc109_ = new GachaResult()).read(param1);
               _loc46_ = _loc109_;
               break;
            case 70:
               (_loc33_ = new ScreeningGachaItemParam()).read(param1);
               _loc46_ = _loc33_;
               break;
            case 71:
               (_loc30_ = new UsefulDef()).read(param1);
               _loc46_ = _loc30_;
               break;
            case 72:
               (_loc51_ = new UsefulData()).read(param1);
               _loc46_ = _loc51_;
               break;
            case 73:
               (_loc88_ = new DecorationDef()).read(param1);
               _loc46_ = _loc88_;
               break;
            case 74:
               (_loc115_ = new DecorationData()).read(param1);
               _loc46_ = _loc115_;
               break;
            case 75:
               (_loc116_ = new DecorationInfo()).read(param1);
               _loc46_ = _loc116_;
               break;
            case 76:
               (_loc112_ = new UtensilDef()).read(param1);
               _loc46_ = _loc112_;
               break;
            case 77:
               (_loc24_ = new UtensilData()).read(param1);
               _loc46_ = _loc24_;
               break;
            case 78:
               (_loc129_ = new StampDef()).read(param1);
               _loc46_ = _loc129_;
               break;
            case 79:
               (_loc48_ = new AvatarDef()).read(param1);
               _loc46_ = _loc48_;
               break;
            case 80:
               (_loc111_ = new MailPresentResult()).read(param1);
               _loc46_ = _loc111_;
               break;
            case 81:
               (_loc52_ = new UserRoomInfo()).read(param1);
               _loc46_ = _loc52_;
               break;
            case 82:
               (_loc28_ = new AssistInfo()).read(param1);
               _loc46_ = _loc28_;
               break;
            case 83:
               (_loc73_ = new UserPresentMoneyData()).read(param1);
               _loc46_ = _loc73_;
               break;
            case 84:
               (_loc108_ = new UserAssistData()).read(param1);
               _loc46_ = _loc108_;
               break;
            case 85:
               (_loc81_ = new TouchEventDef()).read(param1);
               _loc46_ = _loc81_;
               break;
            case 86:
               (_loc105_ = new DelusionDef()).read(param1);
               _loc46_ = _loc105_;
               break;
            case 87:
               (_loc89_ = new DelusionParam()).read(param1);
               _loc46_ = _loc89_;
               break;
            case 88:
               (_loc45_ = new TouchInfo()).read(param1);
               _loc46_ = _loc45_;
               break;
            case 89:
               (_loc44_ = new TouchEventParam()).read(param1);
               _loc46_ = _loc44_;
               break;
            case 90:
               (_loc93_ = new AbilityParam()).read(param1);
               _loc46_ = _loc93_;
               break;
            case 91:
               (_loc47_ = new UserAbilityData()).read(param1);
               _loc46_ = _loc47_;
               break;
            case 92:
               (_loc118_ = new FeatureDef()).read(param1);
               _loc46_ = _loc118_;
               break;
            case 93:
               (_loc75_ = new FeatureParam()).read(param1);
               _loc46_ = _loc75_;
               break;
            case 94:
               (_loc123_ = new LinkageDef()).read(param1);
               _loc46_ = _loc123_;
               break;
            case 95:
               (_loc74_ = new LinkageData()).read(param1);
               _loc46_ = _loc74_;
               break;
            case 96:
               (_loc101_ = new AvatarData()).read(param1);
               _loc46_ = _loc101_;
               break;
            case 97:
               (_loc7_ = new QuestionDef()).read(param1);
               _loc46_ = _loc7_;
               break;
            case 98:
               (_loc131_ = new QuestionParam()).read(param1);
               _loc46_ = _loc131_;
               break;
            case 99:
               (_loc77_ = new QuestionInfo()).read(param1);
               _loc46_ = _loc77_;
               break;
            case 100:
               (_loc70_ = new InitDictDef()).read(param1);
               _loc46_ = _loc70_;
               break;
            case 101:
               (_loc62_ = new StampData()).read(param1);
               _loc46_ = _loc62_;
               break;
            case 102:
               (_loc57_ = new StampInfo()).read(param1);
               _loc46_ = _loc57_;
               break;
            case 103:
               (_loc95_ = new AvatarInfo()).read(param1);
               _loc46_ = _loc95_;
               break;
            case 104:
               (_loc42_ = new UsefulInfo()).read(param1);
               _loc46_ = _loc42_;
               break;
            case 105:
               (_loc21_ = new UtensilInfo()).read(param1);
               _loc46_ = _loc21_;
               break;
            case 106:
               (_loc120_ = new VideoAdRewardDef()).read(param1);
               _loc46_ = _loc120_;
               break;
            case 107:
               (_loc63_ = new PurchasePresentDef()).read(param1);
               _loc46_ = _loc63_;
               break;
            case 108:
               (_loc53_ = new PurchasePresentItemDef()).read(param1);
               _loc46_ = _loc53_;
               break;
            case 109:
               (_loc20_ = new FriendlyDef()).read(param1);
               _loc46_ = _loc20_;
               break;
            case 110:
               (_loc98_ = new FriendlyParam()).read(param1);
               _loc46_ = _loc98_;
               break;
            case 111:
               (_loc14_ = new FriendlyData()).read(param1);
               _loc46_ = _loc14_;
               break;
            case 112:
               (_loc65_ = new ARExpansionGoodsDef()).read(param1);
               _loc46_ = _loc65_;
               break;
            case 113:
               (_loc102_ = new TouchDef()).read(param1);
               _loc46_ = _loc102_;
               break;
            case 114:
               (_loc27_ = new HideGudetamaDef()).read(param1);
               _loc46_ = _loc27_;
               break;
            case 115:
               (_loc82_ = new CommentDef()).read(param1);
               _loc46_ = _loc82_;
               break;
            case 116:
               (_loc125_ = new GetItemResult()).read(param1);
               _loc46_ = _loc125_;
               break;
            case 117:
               (_loc35_ = new MonthlyPremiumBonusDef()).read(param1);
               _loc46_ = _loc35_;
               break;
            case 118:
               (_loc61_ = new EventData()).read(param1);
               _loc46_ = _loc61_;
               break;
            case 119:
               (_loc25_ = new PromotionVideoDef()).read(param1);
               _loc46_ = _loc25_;
               break;
            case 120:
               (_loc122_ = new PromotionBannerSettingDef()).read(param1);
               _loc46_ = _loc122_;
               break;
            case 121:
               (_loc124_ = new IdentifiedPresentDef()).read(param1);
               _loc46_ = _loc124_;
               break;
            case 122:
               (_loc132_ = new VoiceParam()).read(param1);
               _loc46_ = _loc132_;
               break;
            case 123:
               (_loc87_ = new DeliverPointTableDef()).read(param1);
               _loc46_ = _loc87_;
               break;
            case 124:
               (_loc29_ = new SetItemDef()).read(param1);
               _loc46_ = _loc29_;
               break;
            case 125:
               (_loc39_ = new SetItemBuyData()).read(param1);
               _loc46_ = _loc39_;
               break;
            case 126:
               (_loc84_ = new ComicDef()).read(param1);
               _loc46_ = _loc84_;
               break;
            case 127:
               _loc2_ = new PromotionInterstitialSettingDef();
               _loc2_.read(param1);
               _loc46_ = _loc2_;
               break;
            case 128:
               (_loc66_ = new OnlyShowItemDef()).read(param1);
               _loc46_ = _loc66_;
               break;
            case 129:
               (_loc133_ = new ShareBonusDef()).read(param1);
               _loc46_ = _loc133_;
               break;
            case 130:
               (_loc94_ = new SetItemAlternativeParam()).read(param1);
               _loc46_ = _loc94_;
               break;
            case 131:
               (_loc107_ = new CupGachaDef()).read(param1);
               _loc46_ = _loc107_;
               break;
            case 132:
               (_loc126_ = new CupGachaData()).read(param1);
               _loc46_ = _loc126_;
               break;
            case 133:
               (_loc117_ = new CupGachaResult()).read(param1);
               _loc46_ = _loc117_;
               break;
            case 134:
               (_loc8_ = new HomeDecoData()).read(param1);
               _loc46_ = _loc8_;
               break;
            case 135:
               (_loc110_ = new HomeExpansionGoodsDef()).read(param1);
               _loc46_ = _loc110_;
               break;
            case 136:
               (_loc43_ = new HomeStampSettingDef()).read(param1);
               _loc46_ = _loc43_;
               break;
            case 137:
               (_loc96_ = new SubHomeStampSettingDef()).read(param1);
               _loc46_ = _loc96_;
               break;
            case 138:
               (_loc83_ = new HelperCharaDef()).read(param1);
               _loc46_ = _loc83_;
               break;
            case 139:
               (_loc121_ = new ComicSpineDef()).read(param1);
               _loc46_ = _loc121_;
               break;
            default:
               trace("not supported type: " + _loc17_);
               _loc46_ = null;
         }
         return _loc46_;
      }
   }
}
