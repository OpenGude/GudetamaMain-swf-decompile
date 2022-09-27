package starlingbuilder.engine
{
   import flash.utils.Dictionary;
   import starling.display.DisplayObject;
   import starling.display.DisplayObjectContainer;
   import starlingbuilder.engine.localization.ILocalization;
   import starlingbuilder.engine.localization.ILocalizationHandler;
   import starlingbuilder.engine.tween.ITweenBuilder;
   
   public interface IUIBuilder
   {
       
      
      function load(param1:Object, param2:Boolean = true, param3:Object = null) : Object;
      
      function save(param1:DisplayObjectContainer, param2:Object, param3:String, param4:Object = null) : Object;
      
      function createUIElement(param1:Object) : Object;
      
      function isContainer(param1:Object) : Boolean;
      
      function copy(param1:DisplayObject, param2:Object) : String;
      
      function paste(param1:String) : Object;
      
      function setExternalSource(param1:Object, param2:String) : void;
      
      function localizeTexts(param1:DisplayObject, param2:Dictionary) : void;
      
      function create(param1:Object, param2:Boolean = true, param3:Object = null) : Object;
      
      function get tweenBuilder() : ITweenBuilder;
      
      function set tweenBuilder(param1:ITweenBuilder) : void;
      
      function get localization() : ILocalization;
      
      function set localization(param1:ILocalization) : void;
      
      function get localizationHandler() : ILocalizationHandler;
      
      function set localizationHandler(param1:ILocalizationHandler) : void;
      
      function get displayObjectHandler() : IDisplayObjectHandler;
      
      function set displayObjectHandler(param1:IDisplayObjectHandler) : void;
      
      function get prettyData() : Boolean;
      
      function set prettyData(param1:Boolean) : void;
   }
}
