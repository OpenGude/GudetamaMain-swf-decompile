package feathers.utils.display
{
   import starling.core.Starling;
   import starling.display.Stage;
   
   public function stageToStarling(param1:Stage) : Starling
   {
      var _loc3_:* = Starling;
      for each(var _loc2_ in starling.core.Starling.sAll)
      {
         if(_loc2_.stage === param1)
         {
            return _loc2_;
         }
      }
      return null;
   }
}
