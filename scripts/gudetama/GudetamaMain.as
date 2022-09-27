package gudetama
{
   import flash.display.Sprite;
   import flash.events.Event;
   import gudetama.engine.Engine;
   import gudetama.scene.initial.InitialScene;
   
   public class GudetamaMain extends Sprite
   {
      
      private static var DESIGN_WIDTH:int = 640;
      
      private static var DESIGN_HEIGHT:int = 1136;
      
      private static var DESIGN_WIDTH_MARGIN:int = 30;
       
      
      public function GudetamaMain()
      {
         super();
         addEventListener("enterFrame",onEnterFrame);
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         removeEventListener("enterFrame",onEnterFrame);
         Engine.init(InitialScene,stage,DESIGN_WIDTH,DESIGN_HEIGHT,DESIGN_WIDTH_MARGIN);
      }
   }
}
