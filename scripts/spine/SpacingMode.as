package spine
{
   public class SpacingMode
   {
      
      public static const length:SpacingMode = new SpacingMode();
      
      public static const fixed:SpacingMode = new SpacingMode();
      
      public static const percent:SpacingMode = new SpacingMode();
      
      public static const values:Array = [length,fixed,percent];
       
      
      public function SpacingMode()
      {
         super();
      }
   }
}
