package spine
{
   public class PositionMode
   {
      
      public static const fixed:PositionMode = new PositionMode();
      
      public static const percent:PositionMode = new PositionMode();
      
      public static const values:Array = [fixed,percent];
       
      
      public function PositionMode()
      {
         super();
      }
   }
}
