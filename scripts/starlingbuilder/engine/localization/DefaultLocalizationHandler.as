package starlingbuilder.engine.localization
{
   import flash.utils.Dictionary;
   import starling.display.DisplayObject;
   import starling.text.TextField;
   
   public class DefaultLocalizationHandler implements ILocalizationHandler
   {
       
      
      public function DefaultLocalizationHandler()
      {
         super();
      }
      
      public function localize(param1:DisplayObject, param2:String, param3:Dictionary, param4:String) : void
      {
         var _loc5_:* = null;
         if(param1 is TextField)
         {
            if((_loc5_ = param1 as TextField).autoSize != "none")
            {
               _loc5_.alignPivot();
            }
         }
      }
   }
}
