package gudetama.common
{
   import gudetama.data.UserDataWrapper;
   import gudetama.engine.Engine;
   import gudetama.engine.Logger;
   import gudetama.engine.SoundManager;
   import gudetama.util.StringUtil;
   import muku.text.ApplicationTextControl;
   
   public class GudetamaTextProcessor implements ApplicationTextControl
   {
       
      
      private var gender:int;
      
      public function GudetamaTextProcessor()
      {
         super();
      }
      
      public function replaceText(param1:String) : String
      {
         if(UserDataWrapper.isInitialized())
         {
            if(param1.indexOf("<PLAYER>") >= 0)
            {
               param1 = StringUtil.replaceAll(param1,"<PLAYER>",UserDataWrapper.wrapper.getPlayerName());
            }
            if(param1.indexOf("<MALE>") >= 0 && param1.indexOf("<FEMALE>"))
            {
               if(UserDataWrapper.wrapper.getGender() == 0)
               {
                  param1 = param1.substring(param1.lastIndexOf("<MALE>") + 6,param1.lastIndexOf("</MALE>"));
               }
               else
               {
                  param1 = param1.substring(param1.lastIndexOf("<FEMALE>") + 8,param1.lastIndexOf("</FEMALE>"));
               }
            }
         }
         return param1;
      }
      
      public function initCode() : void
      {
         gender = -1;
      }
      
      public function setCode(param1:String) : Boolean
      {
         if(param1.indexOf("MALE") == 0)
         {
            gender = 0;
            return true;
         }
         if(param1.indexOf("FEMALE") == 0)
         {
            gender = 1;
            return true;
         }
         return false;
      }
      
      public function unsetCode(param1:String) : Boolean
      {
         try
         {
            if(param1.indexOf("MALE") == 0 || param1.indexOf("FEMALE") == 0)
            {
               gender = -1;
               return true;
            }
         }
         catch(e:Error)
         {
            Logger.error(e.getStackTrace());
         }
         return false;
      }
      
      public function skipCharacter() : Boolean
      {
         if(UserDataWrapper.isInitialized() && gender >= 0)
         {
            return gender != UserDataWrapper.wrapper.getGender();
         }
         return false;
      }
      
      public function playSound(param1:String) : void
      {
         SoundManager.playEffect(param1);
      }
      
      public function getDefaultFontName() : String
      {
         return convertFontName("round");
      }
      
      public function convertFontName(param1:String) : String
      {
         var _loc2_:String = Engine.getLocale();
         switch(_loc2_)
         {
            case "en":
            case "pt":
               break;
            case "id":
               break;
            case "ko":
               switch(param1)
               {
                  case "capie":
                     return "ko_capie";
                  case "capie_bold":
                     return "ko_capie_bold";
                  case "yuru":
                     break;
                  case "waku":
                     break;
                  default:
                     return param1;
               }
               return "ko_yuru";
            case "cn":
               switch(param1)
               {
                  case "capie":
                     break;
                  case "capie_bold":
                     break;
                  case "yuru":
                  case "waku":
                     return "cn_yuru";
                  default:
                     return param1;
               }
               return "cn_capie_bold";
            case "tw":
               switch(param1)
               {
                  case "capie":
                     break;
                  case "capie_bold":
                     break;
                  case "yuru":
                  case "waku":
                     return "tw_yuru";
                  default:
                     return param1;
               }
               return "tw_capie_bold";
            case "th":
               switch(param1)
               {
                  case "capie":
                     return "th_capie";
                  case "capie_bold":
                     return "th_capie_bold";
                  case "yuru":
                     break;
                  case "waku":
                     break;
                  default:
                     return param1;
               }
               return "th_yuru";
            case "vi":
               switch(param1)
               {
                  case "capie":
                     return "vi_capie";
                  case "capie_bold":
                     return "vi_capie_bold";
                  case "yuru":
                     break;
                  case "waku":
                     break;
                  default:
                     return param1;
               }
               return "vi_yuru";
            case "ja":
            default:
               return param1;
         }
         var _loc3_:* = param1;
         if("waku" !== _loc3_)
         {
            return param1;
         }
         return "yuru";
      }
   }
}
