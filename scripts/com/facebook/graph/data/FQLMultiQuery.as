package com.facebook.graph.data
{
   public class FQLMultiQuery
   {
       
      
      public var queries:Object;
      
      public function FQLMultiQuery()
      {
         super();
         queries = {};
      }
      
      public function add(param1:String, param2:String, param3:Object = null) : void
      {
         if(queries.hasOwnProperty(param2))
         {
            throw new Error("Query name already exists, there cannot be duplicate names");
         }
         for(var _loc4_ in param3)
         {
            param1 = param1.replace(new RegExp("\\{" + _loc4_ + "\\}","g"),param3[_loc4_]);
         }
         queries[param2] = param1;
      }
      
      public function toString() : String
      {
         return JSON.stringify(queries);
      }
   }
}
