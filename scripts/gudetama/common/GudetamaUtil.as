package gudetama.common
{
   import flash.desktop.NativeApplication;
   import flash.display.BitmapData;
   import flash.display.Loader;
   import flash.display.PNGEncoderOptions;
   import flash.events.Event;
   import flash.geom.Matrix;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.system.ApplicationDomain;
   import flash.text.Font;
   import flash.utils.ByteArray;
   import gudetama.data.DataStorage;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.CupGachaDef;
   import gudetama.data.compati.DeliverPointTableDef;
   import gudetama.data.compati.GudetamaDef;
   import gudetama.data.compati.ItemParam;
   import gudetama.data.compati.KitchenwareDef;
   import gudetama.data.compati.MonthlyPremiumBonusDef;
   import gudetama.data.compati.RankingContentDef;
   import gudetama.data.compati.RankingDef;
   import gudetama.data.compati.RecipeNoteDef;
   import gudetama.data.compati.SetItemAlternativeParam;
   import gudetama.data.compati.SetItemDef;
   import gudetama.data.compati.StampDef;
   import gudetama.data.compati.SystemMailData;
   import gudetama.data.compati.TouchEventParam;
   import gudetama.data.compati.UserData;
   import gudetama.data.compati.UserProfileData;
   import gudetama.data.compati._UserProfileData;
   import gudetama.engine.Engine;
   import gudetama.engine.RsrcManager;
   import gudetama.engine.SoundManager;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.ui.MessageDialog;
   import gudetama.ui.WebViewDialog;
   import gudetama.util.StringUtil;
   import gudetama.util.TimeZoneUtil;
   import muku.text.PartialBitmapFont;
   import starling.display.DisplayObject;
   import starling.display.Image;
   import starling.display.Quad;
   import starling.textures.Texture;
   
   public class GudetamaUtil
   {
      
      private static const TIME_TYPE_MORNING:uint = 0;
      
      private static const TIME_TYPE_NOON:uint = 1;
      
      private static const TIME_TYPE_NIGHT:uint = 2;
       
      
      public function GudetamaUtil()
      {
         super();
      }
      
      public static function getSpineName(param1:int) : String
      {
         var _loc2_:GudetamaDef = GameSetting.getGudetama(param1);
         return "gudetama-" + _loc2_.rsrc + "-manually_spine";
      }
      
      public static function getCollectionIconName(param1:int) : String
      {
         var _loc2_:GudetamaDef = GameSetting.getGudetama(param1);
         return "gudetama-" + _loc2_.rsrc + "-icon_collection";
      }
      
      public static function getARGudetamaIconName(param1:int) : String
      {
         var _loc2_:GudetamaDef = GameSetting.getGudetama(param1);
         return "gudetama-" + _loc2_.rsrc + "-icon_ar";
      }
      
      public static function getGudetamaIconName(param1:int) : String
      {
         var _loc2_:GudetamaDef = GameSetting.getGudetama(param1);
         return "gudetama-" + _loc2_.rsrc + "-icon";
      }
      
      public static function getGudetamaRsrcIconName(param1:int) : String
      {
         return "gudetama-" + param1 + "-icon";
      }
      
      public static function getARStampIconName(param1:int) : String
      {
         var _loc2_:StampDef = GameSetting.getStamp(param1);
         return "stamp-" + _loc2_.rsrc + "-icon";
      }
      
      public static function getARStampName(param1:int) : String
      {
         var _loc2_:StampDef = GameSetting.getStamp(param1);
         return "stamp-" + _loc2_.rsrc + "-stamp";
      }
      
      public static function getHelperSpineName(param1:int) : String
      {
         return "helper-" + param1 + "-home_spine";
      }
      
      public static function getItemIconName(param1:int, param2:int) : String
      {
         var _loc3_:* = null;
         var _loc4_:* = null;
         switch(param1)
         {
            case 0:
               break;
            case 14:
               break;
            case 1:
            case 2:
               return "other-metal";
            case 3:
               return "other-metal_sub";
            case 4:
               return "kitchenware-" + GameSetting.getKitchenware(param2).rsrc + "-icon_s";
            case 5:
               _loc3_ = GameSetting.getRecipeNote(param2);
               _loc4_ = GameSetting.getKitchenware(_loc3_.kitchenwareId);
               return "recipe-" + _loc4_.type + "_icon";
            case 6:
            case 7:
               return "gudetama-" + GameSetting.getGudetama(param2).rsrc + "-icon_ar";
            case 8:
               return "useful-" + GameSetting.getUseful(param2).rsrc + "_icon";
            case 9:
               return "other-room";
            case 10:
               return "utensil-" + GameSetting.getUtensil(param2).rsrc;
            case 11:
               return "stamp-" + GameSetting.getStamp(param2).rsrc + "-icon";
            case 12:
               return "avatar-" + GameSetting.getAvatar(param2).rsrc + "_icon";
            case 13:
               return "other-comment";
            case 16:
               return "other-metal_pack";
            case 17:
               return "onlyshow-" + GameSetting.getOnlyShowItem(param2).rsrc + "_icon";
            case 19:
               return "cupgude-" + GameSetting.getCupGacha(param2).rsrc + "_icon";
            default:
               return "";
         }
         return "other-money";
      }
      
      public static function getItemImageName(param1:int, param2:int) : String
      {
         var _loc3_:* = null;
         var _loc4_:* = null;
         switch(param1)
         {
            case 0:
               break;
            case 14:
               break;
            case 1:
            case 2:
               return "other-metal_image";
            case 3:
               return "other-metal_sub_image";
            case 4:
               return "kitchenware-" + GameSetting.getKitchenware(param2).rsrc + "-image";
            case 5:
               _loc3_ = GameSetting.getRecipeNote(param2);
               _loc4_ = GameSetting.getKitchenware(_loc3_.kitchenwareId);
               return "recipe-" + _loc4_.type + "_image";
            case 6:
            case 7:
               return "gudetama-" + GameSetting.getGudetama(param2).rsrc + "-icon";
            case 8:
               return "useful-" + GameSetting.getUseful(param2).rsrc + "_image";
            case 9:
               return "room-" + GameSetting.getDecoration(param2).rsrc + "-image";
            case 11:
               return "stamp-" + GameSetting.getStamp(param2).rsrc + "-image";
            case 12:
               return "avatar-" + GameSetting.getAvatar(param2).rsrc + "_image";
            case 13:
               return "other-comment_image";
            case 16:
               return "other-metal_pack_image";
            case 17:
               return "onlyshow-" + GameSetting.getOnlyShowItem(param2).rsrc + "_image";
            case 18:
               return getAddableSetItemImageName(param2);
            case 19:
               return "cupgude-" + GameSetting.getCupGacha(param2).rsrc + "_image";
            default:
               return "";
         }
         return "other-money_image";
      }
      
      public static function getAddableSetItemImageName(param1:int) : String
      {
         var id:int = param1;
         var getAlternativeItemImageName:* = function(param1:SetItemAlternativeParam):String
         {
            if(!param1.items || param1.items.length <= 0)
            {
               return "";
            }
            if(param1.rsrc > 0)
            {
               return "setitem-alternative_" + param1.rsrc + "_image";
            }
            return getItemImageName(param1.items[0].kind,param1.items[0].id);
         };
         var setItemDef:SetItemDef = GameSetting.getSetItem(id);
         if(!setItemDef)
         {
            return "";
         }
         if(setItemDef.items)
         {
            for each(item in setItemDef.items)
            {
               if(UserDataWrapper.wrapper.isItemAddable(item))
               {
                  if(setItemDef.rsrc > 0)
                  {
                     return "setitem-setitem_" + setItemDef.rsrc + "_image";
                  }
                  return getItemImageName(item.kind,item.id#2);
               }
            }
            if(setItemDef.alternativeParam)
            {
               return getAlternativeItemImageName(setItemDef.alternativeParam);
            }
         }
         else if(setItemDef.alternativeParam)
         {
            return getAlternativeItemImageName(setItemDef.alternativeParam);
         }
         return "";
      }
      
      public static function isAlternativeItem(param1:ItemParam) : Boolean
      {
         if(!param1)
         {
            return false;
         }
         if(param1.kind != 18)
         {
            return false;
         }
         var _loc2_:SetItemDef = GameSetting.getSetItem(param1.id#2);
         if(!_loc2_)
         {
            return false;
         }
         if(_loc2_.items)
         {
            for each(param1 in _loc2_.items)
            {
               if(UserDataWrapper.wrapper.isItemAddable(param1))
               {
                  return false;
               }
            }
            if(_loc2_.alternativeParam)
            {
               return true;
            }
         }
         else if(_loc2_.alternativeParam)
         {
            return true;
         }
         return false;
      }
      
      public static function getItemParamName(param1:ItemParam) : String
      {
         return getItemName(param1.kind,param1.id#2);
      }
      
      public static function getItemName(param1:int, param2:int) : String
      {
         var _loc3_:* = null;
         switch(param1)
         {
            case 6:
               break;
            case 7:
               break;
            case 8:
               return GameSetting.getUseful(param2).name#2;
            case 5:
               return StringUtil.replaceAll(GameSetting.getRecipeNote(param2).name#2,"\n","");
            case 4:
               return GameSetting.getKitchenware(param2).name#2;
            case 10:
               return GameSetting.getUtensil(param2).name#2;
            case 9:
               return GameSetting.getDecoration(param2).name#2;
            case 12:
               return GameSetting.getAvatar(param2).name#2;
            case 11:
               return GameSetting.getStamp(param2).name#2;
            case 13:
               return GameSetting.getCommentDef(param2).name#2;
            case 0:
            case 14:
               return GameSetting.getUIText("item.name." + param1);
            case 16:
               _loc3_ = GameSetting.getMonthlyPremiumBonusTable()[param2];
               return StringUtil.format(GameSetting.getUIText("item.name." + param1),_loc3_.validDays);
            case 17:
               return GameSetting.getOnlyShowItem(param2).name#2;
            case 18:
               return getAddableSetItemName(param2);
            case 19:
               return GameSetting.getCupGacha(param2).name#2;
            default:
               return GameSetting.getUIText("item.name." + param1);
         }
         return GameSetting.getGudetama(param2).name#2;
      }
      
      public static function getAddableSetItemName(param1:int) : String
      {
         var id:int = param1;
         var getAlternativeItemName:* = function(param1:SetItemAlternativeParam):String
         {
            if(!param1.items || param1.items.length <= 0)
            {
               return "";
            }
            return getItemName(param1.items[0].kind,param1.items[0].id);
         };
         var setItemDef:SetItemDef = GameSetting.getSetItem(id);
         if(!setItemDef)
         {
            return "";
         }
         if(setItemDef.items)
         {
            for each(item in setItemDef.items)
            {
               if(UserDataWrapper.wrapper.isItemAddable(item))
               {
                  return getItemName(item.kind,item.id#2);
               }
            }
            if(setItemDef.alternativeParam)
            {
               return getAlternativeItemName(setItemDef.alternativeParam);
            }
         }
         else if(setItemDef.alternativeParam)
         {
            return getAlternativeItemName(setItemDef.alternativeParam);
         }
         return "";
      }
      
      public static function getItemDesc(param1:int, param2:int) : String
      {
         switch(int(param1) - 4)
         {
            case 0:
               return GameSetting.getKitchenware(param2).desc;
            case 1:
               return GameSetting.getRecipeNote(param2).desc;
            case 2:
            case 3:
               return GameSetting.getGudetama(param2).desc;
            case 4:
               return GameSetting.getUseful(param2).desc;
            case 5:
               return GameSetting.getDecoration(param2).desc;
            case 6:
               return GameSetting.getUtensil(param2).desc;
            case 7:
               return GameSetting.getStamp(param2).desc;
            case 8:
               return GameSetting.getAvatar(param2).desc;
            case 13:
               return GameSetting.getOnlyShowItem(param2).desc;
            case 15:
               return GameSetting.getCupGacha(param2).desc;
            default:
               return "";
         }
      }
      
      public static function getItemParamNum(param1:ItemParam) : String
      {
         return getItemNum(param1.kind,param1.id#2,param1.num);
      }
      
      public static function getItemNum(param1:int, param2:int, param3:int) : String
      {
         var _loc5_:* = null;
         var _loc4_:* = null;
         switch(int(param1) - 16)
         {
            case 0:
               _loc5_ = GameSetting.getMonthlyPremiumBonusTable()[param2];
               return StringUtil.format(GameSetting.getUIText("item.num." + param1),_loc5_.validDays);
            case 2:
               return getAddableSetItemNum(param2);
            default:
               if((_loc4_ = GameSetting.getUIText("item.num." + param1)).indexOf("?") == 0)
               {
                  _loc4_ = GameSetting.getUIText("item.num.common");
               }
               return StringUtil.format(_loc4_,StringUtil.getNumStringCommas(param3));
         }
      }
      
      public static function getAddableSetItemNum(param1:int) : String
      {
         var id:int = param1;
         var getAlternativeItemNum:* = function(param1:SetItemAlternativeParam):String
         {
            if(!param1.items || param1.items.length <= 0)
            {
               return "";
            }
            return getItemNum(param1.items[0].kind,param1.items[0].id,param1.items[0].num);
         };
         var setItemDef:SetItemDef = GameSetting.getSetItem(id);
         if(!setItemDef)
         {
            return "";
         }
         if(setItemDef.items)
         {
            for each(item in setItemDef.items)
            {
               if(UserDataWrapper.wrapper.isItemAddable(item))
               {
                  return getItemNum(item.kind,item.id#2,item.num);
               }
            }
            if(setItemDef.alternativeParam)
            {
               return getAlternativeItemNum(setItemDef.alternativeParam);
            }
         }
         else if(setItemDef.alternativeParam)
         {
            return getAlternativeItemNum(setItemDef.alternativeParam);
         }
         return "";
      }
      
      public static function getItemNameAndNum(param1:int, param2:int, param3:int) : String
      {
         if(ItemParam.useOnlyNum(param1))
         {
            return getItemNum(param1,param2,param3);
         }
         if(ItemParam.useOnlyName(param1))
         {
            return getItemName(param1,param2);
         }
         return getItemName(param1,param2) + " " + getItemNum(param1,param2,param3);
      }
      
      public static function getItemParamNameAndNum(param1:ItemParam) : String
      {
         return getItemNameAndNum(param1.kind,param1.id#2,param1.num);
      }
      
      public static function getItemNameAndMultNum(param1:int, param2:int, param3:int) : String
      {
         if(ItemParam.useOnlyNum(param1))
         {
            return getItemNum(param1,param2,param3);
         }
         if(ItemParam.useOnlyName(param1))
         {
            return getItemName(param1,param2);
         }
         return getItemName(param1,param2) + StringUtil.format(GameSetting.getUIText("mult.mark"),param3);
      }
      
      public static function getItemParamNameAndMultNum(param1:ItemParam) : String
      {
         return getItemNameAndMultNum(param1.kind,param1.id#2,param1.num);
      }
      
      public static function getKitchenwareNameByRecipeNote(param1:RecipeNoteDef) : String
      {
         return GameSetting.getUIText("kitchenware.type.name." + GameSetting.getKitchenware(param1.kitchenwareId).type) + " " + StringUtil.replaceAll(param1.name#2,"\n","");
      }
      
      public static function getItemRsrcId(param1:ItemParam) : int
      {
         switch(int(param1.kind) - 4)
         {
            case 0:
               return GameSetting.getKitchenware(param1.id#2).rsrc;
            case 1:
               return GameSetting.getRecipeNote(param1.id#2).rsrc;
            case 2:
            case 3:
               return GameSetting.getGudetama(param1.id#2).rsrc;
            case 4:
               return GameSetting.getUseful(param1.id#2).rsrc;
            case 5:
               return GameSetting.getDecoration(param1.id#2).rsrc;
            case 6:
               return GameSetting.getUtensil(param1.id#2).rsrc;
            case 7:
               return GameSetting.getStamp(param1.id#2).rsrc;
            case 8:
               return GameSetting.getAvatar(param1.id#2).rsrc;
            default:
               return 0;
         }
      }
      
      public static function getItemDef(param1:ItemParam) : Object
      {
         switch(int(param1.kind) - 4)
         {
            case 0:
               return GameSetting.getKitchenware(param1.id#2);
            case 1:
               return GameSetting.getRecipeNote(param1.id#2);
            case 2:
            case 3:
               return GameSetting.getGudetama(param1.id#2);
            case 4:
               return GameSetting.getUseful(param1.id#2);
            case 5:
               return GameSetting.getDecoration(param1.id#2);
            case 6:
               return GameSetting.getUtensil(param1.id#2);
            case 7:
               return GameSetting.getStamp(param1.id#2);
            case 8:
               return GameSetting.getAvatar(param1.id#2);
            case 9:
               return GameSetting.getCommentDef(param1.id#2);
            case 15:
               return GameSetting.getCupGacha(param1.id#2);
            default:
               return null;
         }
      }
      
      public static function getItemPrice(param1:int, param2:int) : ItemParam
      {
         switch(int(param1) - 8)
         {
            case 0:
               return GameSetting.getUseful(param2).price;
            case 1:
               return GameSetting.getDecoration(param2).price;
            case 2:
               return GameSetting.getUtensil(param2).price;
            case 3:
               return GameSetting.getStamp(param2).price;
            case 4:
               return GameSetting.getAvatar(param2).price;
            default:
               return null;
         }
      }
      
      public static function getEnableLocal(param1:String) : String
      {
         switch(param1)
         {
            case "ja":
               return "ja";
            case "ko":
               return "ko";
            case "cn":
            case "zh-CN":
               return "cn";
            case "tw":
            case "zh-TW":
               break;
            case "zh-HK":
               break;
            case "en":
            default:
               return "en";
         }
         return "tw";
      }
      
      public static function getSystemMailMessage(param1:SystemMailData) : String
      {
         var _loc2_:* = null;
         if(StringUtil.startsWith(param1.message,"#UP"))
         {
            _loc2_ = param1.message.substr("#UP".length);
            return GameSetting.getUIText("mail.present.gudetama").replace("%1",_loc2_);
         }
         return param1.message;
      }
      
      public static function initFont(param1:Function) : void
      {
         var callback:Function = param1;
         var locale:String = Engine.getLocale();
         if(locale == "ja" || locale == "en" || locale == "pt" || locale == "id" || locale == "th" || !isMultiLang())
         {
            var _loc7_:Boolean = true;
            var _loc3_:* = PartialBitmapFont;
            muku.text.PartialBitmapFont.sUseEmbed = _loc7_;
            var _loc8_:* = locale == "th";
            var _loc4_:* = PartialBitmapFont;
            muku.text.PartialBitmapFont.sCheckCombine = _loc8_;
            if(callback != null)
            {
               callback();
            }
            return;
         }
         var _loc5_:* = Engine;
         if(gudetama.engine.Engine.platform == 0)
         {
            var _loc9_:Boolean = false;
            var _loc6_:* = PartialBitmapFont;
            muku.text.PartialBitmapFont.sUseEmbed = _loc9_;
            if(callback != null)
            {
               callback();
            }
            return;
         }
         RsrcManager.getInstance().loadFontSwf(function(param1:ApplicationDomain):void
         {
            var _loc2_:* = null;
            if(param1 != null)
            {
               switch(locale)
               {
                  case "ko":
                     _loc2_ = param1.getDefinition("GudetamaFont_ko") as Class;
                     Font.registerFont(_loc2_.ko_capie);
                     Font.registerFont(_loc2_.ko_capie_bold);
                     Font.registerFont(_loc2_.ko_yuru);
                     var _loc7_:Boolean = true;
                     var _loc3_:* = PartialBitmapFont;
                     muku.text.PartialBitmapFont.sUseEmbed = _loc7_;
                     break;
                  case "cn":
                     _loc2_ = param1.getDefinition("GudetamaFont_cn") as Class;
                     Font.registerFont(_loc2_.cn_capie_bold);
                     Font.registerFont(_loc2_.cn_yuru);
                     var _loc8_:Boolean = true;
                     var _loc4_:* = PartialBitmapFont;
                     muku.text.PartialBitmapFont.sUseEmbed = _loc8_;
                     break;
                  case "tw":
                     _loc2_ = param1.getDefinition("GudetamaFont_tw") as Class;
                     Font.registerFont(_loc2_.tw_capie_bold);
                     Font.registerFont(_loc2_.tw_yuru);
                     var _loc9_:Boolean = true;
                     var _loc5_:* = PartialBitmapFont;
                     muku.text.PartialBitmapFont.sUseEmbed = _loc9_;
                     break;
                  case "vi":
                     _loc2_ = param1.getDefinition("GudetamaFont_vi") as Class;
                     Font.registerFont(_loc2_.vi_capie);
                     Font.registerFont(_loc2_.vi_capie_bold);
                     Font.registerFont(_loc2_.vi_yuru);
                     var _loc10_:Boolean = true;
                     var _loc6_:* = PartialBitmapFont;
                     muku.text.PartialBitmapFont.sUseEmbed = _loc10_;
               }
            }
            if(callback != null)
            {
               callback();
            }
         });
      }
      
      public static function isMultiLang() : Boolean
      {
         var _loc1_:Array = GameSetting.getInitOtherText("langs").split(",");
         return _loc1_.length > 1;
      }
      
      public static function isTranslateByCs(param1:String) : Boolean
      {
         switch(param1)
         {
            case "ja":
            case "en":
            case "ko":
            case "cn":
               break;
            case "tw":
               break;
            default:
               return false;
         }
         return true;
      }
      
      public static function getCenterPosAndWHOnEngine(param1:DisplayObject, param2:Number = 0, param3:Number = 0) : Vector.<Number>
      {
         var _loc5_:Vector.<Number> = new Vector.<Number>(4);
         if(param1 == null)
         {
            _loc5_;
         }
         var _loc4_:Matrix = param1.getTransformationMatrix(Engine.getSceneContainer() as DisplayObject);
         _loc5_[0] = _loc4_.tx - param1.pivotX + param1.width / 2 + param2;
         _loc5_[1] = _loc4_.ty - param1.pivotY + param1.height / 2 + param3;
         _loc5_[2] = param1.width;
         _loc5_[3] = param1.height;
         return _loc5_;
      }
      
      public static function decorationEnbale() : Boolean
      {
         return UserDataWrapper.featurePart.existsFeature(14) && GameSetting.hasScreeningFlag(2);
      }
      
      public static function showHelpPage() : void
      {
         navigateToURL(new URLRequest(GameSetting.getInitOtherText("url.help")),"_self");
      }
      
      public static function showInfoPage() : void
      {
         WebViewDialog.show(GameSetting.getOtherText("url.info"));
      }
      
      public static function getDropItemIconName(param1:TouchEventParam) : String
      {
         return "item-" + (param1.event & 255);
      }
      
      public static function getLastLoginTimeText(param1:UserProfileData) : String
      {
         var _loc2_:int = TimeZoneUtil.getServerTimeSec() - param1.lastActiveSec;
         return TimeZoneUtil.getLastLoginTimeText(_loc2_);
      }
      
      public static function getComment(param1:String) : String
      {
         if(param1 == null || param1.length < 1)
         {
            return GameSetting.getUIText("option.player.comment.def");
         }
         return param1;
      }
      
      public static function getProfileComment(param1:_UserProfileData) : String
      {
         return getComment(param1.comment);
      }
      
      public static function convertEuro(param1:String) : String
      {
         var _loc2_:* = param1.charCodeAt(param1.length - 1) == 8364;
         if(!_loc2_)
         {
            return param1;
         }
         return param1.replace(",","!").replace(".",",").replace("!",".");
      }
      
      public static function registerSnsId(param1:String, param2:int, param3:String, param4:String, param5:Function = null) : void
      {
         var _id:String = param1;
         var _snstype:int = param2;
         var _url:String = param3;
         var _path:String = param4;
         var _callback:Function = param5;
         RsrcManager.loadImageDirectly(_url,_path,function(param1:BitmapData):void
         {
            var pixelsbmp:BitmapData = param1;
            var profileImgbyteArray:ByteArray = new ByteArray();
            pixelsbmp.encode(pixelsbmp.rect,new PNGEncoderOptions(),profileImgbyteArray);
            DataStorage.getLocalData().setSnsImageByteArray(_snstype,profileImgbyteArray,true);
            var _loc3_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithIntAndArrayObject(208,_snstype,_id),function(param1:Array):void
            {
               if(_snstype == 0)
               {
                  var _loc2_:* = UserDataWrapper;
                  gudetama.data.UserDataWrapper.wrapper._data.snsTwitterUid = _id;
               }
               else if(_snstype == 1)
               {
                  var _loc3_:* = UserDataWrapper;
                  gudetama.data.UserDataWrapper.wrapper._data.snsFacebookUid = _id;
               }
               if(_callback)
               {
                  _callback();
               }
            });
         });
      }
      
      public static function confirmGameExit() : void
      {
         var _loc1_:* = Engine;
         if(gudetama.engine.Engine.platform == 0)
         {
            return;
         }
         MessageDialog.show(2,GameSetting.getInitUIText("common.app.quit"),function(param1:int):void
         {
            if(param1 == 1)
            {
               return;
            }
            NativeApplication.nativeApplication.exit();
         });
      }
      
      public static function playFriendSE() : void
      {
         var _loc1_:int = Math.random() * 2;
         switch(int(_loc1_))
         {
            case 0:
               SoundManager.playEffect("voice_friend1");
               break;
            case 1:
               SoundManager.playEffect("voice_friend_def");
         }
      }
      
      public static function cameraButtonSE() : void
      {
         var _loc1_:int = Math.random() * 4;
         switch(int(_loc1_))
         {
            case 0:
               SoundManager.playEffect("voice_camera1");
               break;
            case 1:
               SoundManager.playEffect("voice_camera2");
               break;
            case 2:
               SoundManager.playEffect("voice_camera3");
               break;
            case 3:
               SoundManager.playEffect("voice_camera_def");
         }
      }
      
      public static function getFriendUnlockConditionText() : String
      {
         return GameSetting.getUIText("common.unlock.use.level").replace("%1",GameSetting.getInitOtherInt("friend.unlock.lv"));
      }
      
      public static function loadByteArray2Texture(param1:ByteArray, param2:*) : void
      {
         var imageData:ByteArray = param1;
         var callback:* = param2;
         var loader:Loader = new Loader();
         loader.contentLoaderInfo.addEventListener("complete",function(param1:Event):void
         {
            var _loc2_:BitmapData = new BitmapData(loader.width,loader.height);
            _loc2_.draw(loader);
            callback(Texture.fromBitmapData(_loc2_));
         });
         loader.loadBytes(imageData);
      }
      
      public static function getDeliverPoint(param1:UserProfileData, param2:int, param3:Boolean = true) : int
      {
         var _loc6_:int = 0;
         var _loc4_:* = null;
         var _loc5_:* = null;
         var _loc9_:* = null;
         var _loc8_:int = 0;
         var _loc7_:Array;
         if((_loc7_ = UserDataWrapper.eventPart.getRankingIds(true)) == null)
         {
            return 0;
         }
         var _loc10_:Object = GameSetting.def.rankingMap;
         _loc6_ = 0;
         while(_loc6_ < _loc7_.length)
         {
            _loc4_ = _loc10_[_loc7_[_loc6_]];
            if((_loc5_ = getRankingContent(param1,_loc4_,5)) != null)
            {
               if((_loc9_ = GameSetting.def.deliverPointTableMap[_loc5_.deliverTableId]) != null)
               {
                  if(_loc9_.gudePointMap.hasOwnProperty(param2))
                  {
                     if(param3)
                     {
                        if((_loc8_ = _loc5_.getDeliverPtsPercent(param2)) <= 0)
                        {
                           _loc8_ = GameSetting.getRule().presentDeliverPtsPercent;
                        }
                        return int(_loc9_.gudePointMap[param2][0] * _loc8_ / 100);
                     }
                     return _loc9_.gudePointMap[param2][0];
                  }
               }
            }
            _loc6_++;
         }
         return 0;
      }
      
      public static function isOpenRanking(param1:int) : Boolean
      {
         var _loc3_:int = 0;
         var _loc2_:* = null;
         var _loc4_:Array;
         if((_loc4_ = UserDataWrapper.eventPart.getRankingIds(true)) == null)
         {
            return false;
         }
         var _loc5_:Object = GameSetting.def.rankingMap;
         var _loc7_:* = UserDataWrapper;
         var _loc6_:UserData = gudetama.data.UserDataWrapper.wrapper._data;
         _loc3_ = 0;
         while(_loc3_ < _loc4_.length)
         {
            _loc2_ = _loc5_[_loc4_[_loc3_]];
            if(getRankingContent(_loc6_,_loc2_,param1) != null)
            {
               return true;
            }
            _loc3_++;
         }
         return false;
      }
      
      public static function getRankingContent(param1:Object, param2:RankingDef, param3:int) : RankingContentDef
      {
         var _loc7_:* = null;
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         var _loc6_:int = 0;
         if(param2.groupType != 0)
         {
            _loc5_ = getRankingGroupId(param1,param2);
            _loc4_ = -1;
            if(param2.groupIdIndexMap.hasOwnProperty(_loc5_))
            {
               _loc4_ = param2.groupIdIndexMap[_loc5_];
            }
            if(_loc4_ == -1 || _loc4_ >= param2.content.length)
            {
               if(!param2.hasDefaultGroupContent)
               {
                  return null;
               }
               _loc4_ = param2.content.length - 1;
            }
            if((_loc7_ = param2.content[_loc4_]).type == param3)
            {
               return _loc7_;
            }
         }
         else
         {
            _loc6_ = 0;
            while(_loc6_ < param2.content.length)
            {
               if((_loc7_ = param2.content[_loc6_]).type == param3)
               {
                  return _loc7_;
               }
               _loc6_++;
            }
         }
         return null;
      }
      
      private static function getRankingGroupId(param1:Object, param2:RankingDef) : int
      {
         if(param1 is UserData)
         {
            if(param2.groupType == 1)
            {
               return UserData(param1).area;
            }
         }
         else if(param1 is UserProfileData)
         {
            if(param2.groupType == 1)
            {
               return UserProfileData(param1).area;
            }
         }
         return -1;
      }
      
      public static function compareArray(param1:Array, param2:Array) : Boolean
      {
         var _loc3_:int = 0;
         if(param1 == param2)
         {
            return true;
         }
         if(param1 == null || param2 == null)
         {
            return false;
         }
         if(param1.length != param2.length)
         {
            return false;
         }
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            if(param1[_loc3_] != param2[_loc3_])
            {
               return false;
            }
            _loc3_++;
         }
         return true;
      }
      
      public static function getRestTimeString(param1:int, param2:int, param3:int) : String
      {
         return StringUtil.format(GameSetting.getUIText("common.rest.time"),(param1 < 10 ? "0" : "") + param1,(param2 < 10 ? "0" : "") + param2,(param3 < 10 ? "0" : "") + param3);
      }
      
      public static function getHourAndMinuteStringByMinute(param1:int) : String
      {
         var _loc2_:int = param1 / 60;
         var _loc3_:int = param1 - _loc2_ * 60;
         return getHourAndMinuteString(_loc2_,_loc3_);
      }
      
      public static function getHourAndMinuteString(param1:int, param2:int) : String
      {
         if(param1 == 0)
         {
            return StringUtil.format(GameSetting.getUIText("common.unit.minute"),param2);
         }
         if(param2 == 0)
         {
            return StringUtil.format(GameSetting.getUIText("common.unit.hour"),param1);
         }
         return StringUtil.format(GameSetting.getUIText("common.unit.hour.minute"),param1,param2);
      }
      
      public static function getCupGachaCookTimeString(param1:CupGachaDef) : String
      {
         var _loc5_:int = 3600;
         var _loc2_:int = 60;
         var _loc4_:int;
         var _loc3_:int = (_loc4_ = param1.cookMin * _loc2_) / _loc5_;
         var _loc6_:int = (_loc4_ - _loc3_ * _loc5_) / _loc2_;
         return getHourAndMinuteString(_loc3_,_loc6_);
      }
      
      public static function cupGachaEnable() : Boolean
      {
         return UserDataWrapper.featurePart.existsFeature(15) && GameSetting.hasScreeningFlag(12);
      }
      
      public static function setBGQuadColor(param1:Quad = null, param2:Image = null) : void
      {
         var _loc3_:uint = getHours();
         switch(int(getTimeType(_loc3_)))
         {
            case 0:
               if(param1)
               {
                  param1.color = 11926271;
               }
               if(param2)
               {
                  param2.color = 16777215;
               }
               break;
            case 1:
               if(param1)
               {
                  param1.color = 8310775;
               }
               if(param2)
               {
                  param2.color = 16777215;
               }
               break;
            case 2:
               if(param1)
               {
                  param1.color = 4883885;
               }
               if(param2)
               {
                  param2.color = 9024481;
                  break;
               }
         }
      }
      
      private static function getHours() : uint
      {
         var _loc2_:String = TimeZoneUtil.getDateHHmm(TimeZoneUtil.epochMillisToOffsetSecs()).substr(0,2);
         return uint(_loc2_);
      }
      
      private static function getTimeType(param1:uint) : uint
      {
         if(param1 >= 4 && param1 < 12)
         {
            return 0;
         }
         if(param1 >= 12 && param1 < 18)
         {
            return 1;
         }
         return 2;
      }
      
      public static function getWeatherSpineAnimeName() : String
      {
         var _loc1_:uint = getHours();
         switch(int(getTimeType(_loc1_)))
         {
            case 0:
            case 1:
               return "start_loop";
            case 2:
               return "start2_loop";
            default:
               return "start_loop";
         }
      }
      
      public static function isPushEventGudetamaList(param1:GudetamaDef) : Boolean
      {
         var _loc2_:Boolean = UserDataWrapper.gudetamaPart.isCooked(param1.id#2);
         if(param1.type == 2 && _loc2_)
         {
            return true;
         }
         var _loc3_:Boolean = UserDataWrapper.gudetamaPart.hasRecipe(param1.id#2);
         if(param1.type == 3 && _loc3_)
         {
            return true;
         }
         return false;
      }
   }
}
