package com.hurlant.math
{
   use namespace bi_internal;
   
   class ClassicReduction implements IReduction
   {
       
      
      private var m:BigInteger;
      
      function ClassicReduction(param1:BigInteger)
      {
         super();
         this.m = param1;
      }
      
      public function revert(param1:BigInteger) : BigInteger
      {
         return param1;
      }
      
      public function reduce(param1:BigInteger) : void
      {
         param1.divRemTo(m,null,param1);
      }
      
      public function mulTo(param1:BigInteger, param2:BigInteger, param3:BigInteger) : void
      {
         param1.multiplyTo(param2,param3);
         reduce(param3);
      }
      
      public function sqrTo(param1:BigInteger, param2:BigInteger) : void
      {
         param1.squareTo(param2);
         reduce(param2);
      }
      
      public function convert(param1:BigInteger) : BigInteger
      {
         if(param1.s < 0 || param1.compareTo(m) >= 0)
         {
            return param1.mod(m);
         }
         return param1;
      }
   }
}
