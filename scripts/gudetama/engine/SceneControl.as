package gudetama.engine
{
   import starling.animation.Juggler;
   
   public interface SceneControl
   {
       
      
      function getSceneJuggler() : Juggler;
      
      function getSceneFrameRate() : Number;
   }
}
