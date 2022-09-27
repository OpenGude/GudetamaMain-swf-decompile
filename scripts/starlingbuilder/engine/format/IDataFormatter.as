package starlingbuilder.engine.format
{
   public interface IDataFormatter
   {
       
      
      function read(param1:Object) : Object;
      
      function write(param1:Object) : Object;
      
      function get prettyData() : Boolean;
      
      function set prettyData(param1:Boolean) : void;
   }
}
