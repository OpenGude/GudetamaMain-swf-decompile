package starlingbuilder.engine.localization
{
   import flash.utils.Dictionary;
   import starling.display.DisplayObject;
   
   public interface ILocalizationHandler
   {
       
      
      function localize(param1:DisplayObject, param2:String, param3:Dictionary, param4:String) : void;
   }
}
