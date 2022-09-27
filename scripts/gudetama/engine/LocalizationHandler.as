package gudetama.engine
{
   import flash.utils.Dictionary;
   import starling.display.DisplayObject;
   import starling.text.TextField;
   import starlingbuilder.engine.localization.DefaultLocalizationHandler;
   
   public class LocalizationHandler extends DefaultLocalizationHandler
   {
       
      
      public function LocalizationHandler()
      {
         super();
      }
      
      override public function localize(param1:DisplayObject, param2:String, param3:Dictionary, param4:String) : void
      {
         var _loc5_:TextField;
         if(_loc5_ = param1 as TextField)
         {
            if(param4 == "cn_ZH")
            {
               _loc5_.format.font = "_sans";
            }
         }
         super.localize(param1,param2,param3,param4);
      }
   }
}
