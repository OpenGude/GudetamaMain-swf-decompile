package gudetama.scene.home.ui
{
   import gudetama.common.DialogSystemMailChecker;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.SystemMailData;
   import gudetama.engine.SoundManager;
   import gudetama.engine.TextureCollector;
   import gudetama.ui.UIBase;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class EventButton extends UIBase
   {
       
      
      private var sprite:Sprite;
      
      private var group:Sprite;
      
      private var image:Image;
      
      private var height:Number;
      
      private var imgText:Image;
      
      private var needText:Boolean = false;
      
      private var callback:Function;
      
      public function EventButton(param1:Sprite)
      {
         super(param1);
         param1.addEventListener("triggered",triggeredButton);
         sprite = param1.getChildByName("sprite") as Sprite;
         group = sprite.getChildByName("group") as Sprite;
         image = group.getChildByName("image") as Image;
         height = image.height;
         imgText = group.getChildByName("imgText") as Image;
         if(imgText)
         {
            imgText.visible = false;
         }
      }
      
      public function setup(param1:Function = null) : void
      {
         var _callback:Function = param1;
         callback = _callback;
         var buttonImageName:String = UserDataWrapper.eventPart.getButtonImageName();
         if(buttonImageName)
         {
            var needImgText:Boolean = false;
            if(buttonImageName.indexOf("&") == 0)
            {
               needImgText = true;
               buttonImageName = buttonImageName.slice(1);
            }
            TextureCollector.loadTexture(buttonImageName,function(param1:Texture):void
            {
               startTween("pos1",true);
               finishTween();
               procAfterLoadTexture(param1,needImgText);
            });
         }
         else
         {
            TextureCollector.loadTexture("home1@drink",function(param1:Texture):void
            {
               startTween("pos0",true);
               finishTween();
               procAfterLoadTexture(param1,false);
            });
         }
      }
      
      private function procAfterLoadTexture(param1:Texture, param2:Boolean) : void
      {
         image.texture = param1;
         image.width = param1.width;
         image.height = param1.height;
         sprite.x = 0.5 * param1.width;
         sprite.y = param1.height - 0.5 * height;
         displaySprite.width = param1.width;
         displaySprite.height = param1.height;
         displaySprite.pivotX = 0.5 * param1.width;
         displaySprite.pivotY = param1.height;
         needText = param2;
         if(param2 && imgText)
         {
            imgText.x = image.x;
            imgText.y = image.y;
            imgText.visible = true;
         }
         if(callback)
         {
            callback();
         }
      }
      
      public function visible(param1:Boolean) : void
      {
         setVisible(param1);
         sprite.visible = param1;
         image.visible = param1;
         if(needText)
         {
            imgText.visible = param1;
         }
      }
      
      public function visibleImgText(param1:Boolean) : void
      {
         needText = param1;
         imgText.visible = param1;
      }
      
      private function triggeredButton(param1:Event) : void
      {
         var _loc3_:Number = Math.random();
         if(_loc3_ > 0.5)
         {
            SoundManager.playEffect("put_egg");
         }
         else
         {
            SoundManager.playEffect("tap_nisetama");
         }
         var _loc2_:SystemMailData = UserDataWrapper.eventPart.getSystemMailData();
         if(_loc2_)
         {
            DialogSystemMailChecker.processDialogMail(_loc2_);
         }
      }
      
      public function dispose() : void
      {
         displaySprite.removeEventListener("triggered",triggeredButton);
         sprite = null;
         group = null;
         image = null;
         imgText = null;
      }
   }
}
