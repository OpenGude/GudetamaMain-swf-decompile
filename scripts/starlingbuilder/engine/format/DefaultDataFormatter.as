package starlingbuilder.engine.format
{
   public class DefaultDataFormatter implements IDataFormatter
   {
       
      
      private var _prettyData:Boolean = true;
      
      public function DefaultDataFormatter()
      {
         super();
      }
      
      public function read(param1:Object) : Object
      {
         if(param1 is String)
         {
            return JSON.parse(param1 as String);
         }
         return param1;
      }
      
      public function write(param1:Object) : Object
      {
         if(_prettyData)
         {
            return StableJSONEncoder.stringify(param1,2);
         }
         return StableJSONEncoder.stringify(param1,0);
      }
      
      public function get prettyData() : Boolean
      {
         return _prettyData;
      }
      
      public function set prettyData(param1:Boolean) : void
      {
         _prettyData = param1;
      }
   }
}
