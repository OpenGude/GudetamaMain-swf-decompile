package gudetama.ui
{
   import gudetama.util.SpriteExtractor;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Sprite;
   
   public class PageButton extends Sprite
   {
       
      
      private var triggerFunc:Function;
      
      private var _page:int;
      
      private var btn:ContainerButton;
      
      private var txtPage:ColorTextField;
      
      public function PageButton(param1:SpriteExtractor, param2:Function, param3:Boolean)
      {
         super();
         this.triggerFunc = param2;
         var _loc4_:Sprite;
         btn = (_loc4_ = param1.duplicateAll() as Sprite).getChildByName("btn") as ContainerButton;
         btn.addEventListener("triggered",triggeredBtn);
         btn.alphaWhenDisabled = 1;
         addChild(btn);
         txtPage = btn.getChildByName("text") as ColorTextField;
         addChild(txtPage);
      }
      
      private function triggeredBtn() : void
      {
         triggerFunc(page);
      }
      
      public function set page(param1:int) : void
      {
         _page = param1;
         if(txtPage != null)
         {
            txtPage.text#2 = (param1 + 1).toString();
         }
      }
      
      public function get page() : int
      {
         return _page;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         btn.color = !!param1 ? 16777215 : 8421504;
         btn.enabled = param1;
      }
      
      override public function dispose() : void
      {
         btn.removeEventListener("triggered",triggeredBtn);
         btn = null;
         triggerFunc = null;
         txtPage = null;
         super.dispose();
      }
   }
}
