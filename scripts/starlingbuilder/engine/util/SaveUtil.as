package starlingbuilder.engine.util
{
   public class SaveUtil
   {
       
      
      public function SaveUtil()
      {
         super();
      }
      
      public static function willSave(param1:Object, param2:Object, param3:Object) : Boolean
      {
         if(param1.hasOwnProperty("text") && param2.name == "text" && param3 && param3.customParams && param3.customParams.localizeKey)
         {
            return false;
         }
         if(param2.name == "width" && param1.hasOwnProperty("explicitWidth") && isNaN(param1.explicitWidth))
         {
            return false;
         }
         if(param2.name == "height" && param1.hasOwnProperty("explicitHeight") && isNaN(param1.explicitHeight))
         {
            return false;
         }
         return true;
      }
   }
}
