package com.facebook.graph.utils
{
   public class FQLMultiQueryParser implements IResultParser
   {
       
      
      public function FQLMultiQueryParser()
      {
         super();
      }
      
      public function parse(param1:Object) : Object
      {
         var _loc3_:Object = {};
         for(var _loc2_ in param1)
         {
            _loc3_[param1[_loc2_].name] = param1[_loc2_].fql_result_set;
         }
         return _loc3_;
      }
   }
}
