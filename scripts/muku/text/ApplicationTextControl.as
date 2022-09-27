package muku.text
{
   public interface ApplicationTextControl
   {
       
      
      function replaceText(param1:String) : String;
      
      function initCode() : void;
      
      function setCode(param1:String) : Boolean;
      
      function unsetCode(param1:String) : Boolean;
      
      function skipCharacter() : Boolean;
      
      function playSound(param1:String) : void;
      
      function getDefaultFontName() : String;
      
      function convertFontName(param1:String) : String;
   }
}
