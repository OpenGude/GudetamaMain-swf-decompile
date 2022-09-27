package starlingbuilder.engine.localization
{
   public interface ILocalization
   {
       
      
      function getLocalizedText(param1:String) : String;
      
      function getLocales() : Array;
      
      function getKeys() : Array;
      
      function get locale() : String;
      
      function set locale(param1:String) : void;
   }
}
