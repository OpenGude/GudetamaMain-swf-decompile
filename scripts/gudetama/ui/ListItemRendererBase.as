package gudetama.ui
{
   import feathers.controls.renderers.LayoutGroupListItemRenderer;
   import gudetama.util.SpriteExtractor;
   import starling.display.Sprite;
   
   public class ListItemRendererBase extends LayoutGroupListItemRenderer
   {
       
      
      private var extractor:SpriteExtractor;
      
      protected var callback:Function;
      
      protected var displaySprite:Sprite;
      
      public function ListItemRendererBase(param1:SpriteExtractor, param2:Function)
      {
         super();
         this.extractor = param1;
         this.callback = param2;
      }
      
      override protected function initialize() : void
      {
         if(displaySprite)
         {
            return;
         }
         displaySprite = extractor.duplicateAll() as Sprite;
         createItemUI();
         addChild(displaySprite);
      }
      
      protected function createItemUI() : void
      {
      }
      
      override public function dispose() : void
      {
         extractor = null;
         displaySprite = null;
         disposeItemUI();
         super.dispose();
      }
      
      protected function disposeItemUI() : void
      {
      }
   }
}
