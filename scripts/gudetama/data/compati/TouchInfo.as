package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class TouchInfo
   {
       
      
      public var params#2:Array;
      
      public var bonusRange:Array;
      
      public function TouchInfo()
      {
         super();
      }
      
      public function next(param1:TouchEventParam) : TouchEventParam
      {
         if(!param1)
         {
            return params#2[0];
         }
         for each(var _loc2_ in params#2)
         {
            if(_loc2_.touchNum > param1.touchNum)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         params#2 = CompatibleDataIO.read(param1) as Array;
         bonusRange = CompatibleDataIO.read(param1) as Array;
      }
      
      public function write(param1:ByteArray) : void
      {
         CompatibleDataIO.write(param1,params#2,1);
         CompatibleDataIO.write(param1,bonusRange,2);
      }
   }
}
