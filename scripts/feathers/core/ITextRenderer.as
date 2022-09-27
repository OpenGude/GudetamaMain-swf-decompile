package feathers.core
{
   import feathers.text.FontStylesSet;
   import flash.geom.Point;
   
   public interface ITextRenderer extends IStateObserver, IFeathersControl, ITextBaselineControl
   {
       
      
      function get text() : String;
      
      function set text(param1:String) : void;
      
      function get wordWrap() : Boolean;
      
      function set wordWrap(param1:Boolean) : void;
      
      function get numLines() : int;
      
      function get fontStyles() : FontStylesSet;
      
      function set fontStyles(param1:FontStylesSet) : void;
      
      function measureText(param1:Point = null) : Point;
   }
}
