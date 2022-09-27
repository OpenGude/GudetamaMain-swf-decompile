package gudetama.scene.home.ui
{
   import gudetama.data.UserDataWrapper;
   import gudetama.engine.BaseScene;
   import gudetama.scene.home.HomeScene;
   import gudetama.ui.UIBase;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class InfoButtonUI extends UIBase
   {
       
      
      private var scene:HomeScene;
      
      private var newImage:Image;
      
      private var friendGroup:Sprite;
      
      private var numFriendText:ColorTextField;
      
      public function InfoButtonUI(param1:Sprite, param2:BaseScene)
      {
         super(param1);
         this.scene = param2 as HomeScene;
         ContainerButton(param1).setStopPropagation(true);
         param1.addEventListener("triggered",triggeredButton);
         newImage = param1.getChildByName("new") as Image;
         friendGroup = param1.getChildByName("friendPresent") as Sprite;
         numFriendText = friendGroup.getChildByName("num") as ColorTextField;
      }
      
      public function show() : void
      {
         startTween("show");
      }
      
      public function update() : void
      {
         newImage.visible = UserDataWrapper.wrapper.existsUnreadInfoOrPresent();
         var _loc1_:int = UserDataWrapper.wrapper.getNumFriendPresents();
         friendGroup.visible = _loc1_ > 0;
         numFriendText.text#2 = _loc1_.toString();
      }
      
      public function set touchable(param1:Boolean) : void
      {
         displaySprite.touchable = param1;
      }
      
      private function triggeredButton(param1:Event) : void
      {
         scene.showInfoListDialog();
      }
      
      public function setupMin() : void
      {
         friendGroup.visible = false;
         newImage.visible = false;
      }
      
      public function dispose() : void
      {
         displaySprite.removeEventListener("triggered",triggeredButton);
         newImage = null;
         friendGroup = null;
         numFriendText = null;
      }
   }
}
