package gudetama.data.compati
{
   import flash.utils.ByteArray;
   import gudetama.data.GameSetting;
   
   public class MissionData
   {
       
      
      public var key:int;
      
      public var param:MissionParam;
      
      public var currentValue:int;
      
      public var id#2:int;
      
      public function MissionData()
      {
         super();
      }
      
      public function get title() : String
      {
         var _loc1_:String = GameSetting.getUIText(param.titleKey);
         return formatTitle(_loc1_,param);
      }
      
      public function get guide() : int
      {
         return param.guide;
      }
      
      public function get type() : int
      {
         return param.type;
      }
      
      public function get goal() : int
      {
         return param.goalValue;
      }
      
      public function get targetDesc() : String
      {
         if(param.targetDescKey != null && param.targetDescKey.length > 0)
         {
            return GameSetting.getUIText(param.targetDescKey);
         }
         return GameSetting.getUIText("%mission.defaultTargetDesc.type" + type);
      }
      
      public function get nextTitle() : String
      {
         if(param.nextTitleKey == null)
         {
            return "";
         }
         return GameSetting.getUIText(param.nextTitleKey);
      }
      
      public function get category() : int
      {
         return param.category;
      }
      
      public function get finishSecs() : int
      {
         return param.finishSecs;
      }
      
      public function get rewards() : Array
      {
         return param.rewards;
      }
      
      public function get number() : int
      {
         return param.number;
      }
      
      public function get counterType() : int
      {
         return param.counterType;
      }
      
      private function formatTitle(param1:String, param2:MissionParam) : String
      {
         param1 = param1.replace("<GOAL_VALUE>",param2.goalValue);
         var _loc3_:Array = param2.titleParam;
         if(_loc3_ == null)
         {
            return param1;
         }
         switch(_loc3_[0])
         {
            case "CookingCategory":
               break;
            case "GudetamaCategory":
               break;
            case "GudetamaTarget":
               return param1.replace("<VALUE_1>",GameSetting.getGudetama(_loc3_[1]).name#2);
            case "UseUsefulItem":
               return param1.replace("<VALUE_1>",GameSetting.getUseful(_loc3_[1]).name#2);
            case "CupCookTarget":
               return param1.replace("<VALUE_1>",GameSetting.getCupGachaNameByMissionCommonID(_loc3_[1]));
            default:
               return param1;
         }
         return param1.replace("<VALUE_1>",GameSetting.getUIText(_loc3_[1]));
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         key = param1.readInt();
         param = CompatibleDataIO.read(param1) as MissionParam;
         currentValue = param1.readShort();
         id#2 = param1.readShort();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(key);
         CompatibleDataIO.write(param1,param);
         param1.writeShort(currentValue);
         param1.writeShort(id#2);
      }
   }
}
