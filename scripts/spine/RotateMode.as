package spine
{
   public class RotateMode
   {
      
      public static const tangent:RotateMode = new RotateMode();
      
      public static const chain:RotateMode = new RotateMode();
      
      public static const chainScale:RotateMode = new RotateMode();
      
      public static const values:Array = [tangent,chain,chainScale];
       
      
      public function RotateMode()
      {
         super();
      }
   }
}
