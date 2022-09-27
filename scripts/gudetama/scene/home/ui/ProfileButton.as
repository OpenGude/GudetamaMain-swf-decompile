package gudetama.scene.home.ui
{
   import gudetama.data.DataStorage;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.engine.Engine;
   import gudetama.engine.SoundManager;
   import gudetama.engine.TextureCollector;
   import gudetama.scene.profile.ProfileScene;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.ui.UIBase;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import starling.display.Image;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class ProfileButton extends UIBase
   {
       
      
      private var iconImage:Image;
      
      private var imgSns:Image;
      
      private var visible:Boolean = true;
      
      public function ProfileButton(param1:ContainerButton)
      {
         super(param1);
         param1.setStopPropagation(true);
         param1.addEventListener("triggered",triggered);
         iconImage = param1.getChildByName("icon") as Image;
         imgSns = param1.getChildByName("imgSns") as Image;
         imgSns.visible = false;
      }
      
      public function setup(param1:TaskQueue, param2:Boolean = true) : void
      {
         var queue:TaskQueue = param1;
         var _enableDrawCache:Boolean = param2;
         if(UserDataWrapper.wrapper.isExtraAvatar())
         {
            var snsType:int = UserDataWrapper.wrapper.getCurrentExtraAvatar();
            if(DataStorage.getLocalData().getSnsImageTexture(snsType))
            {
               iconImage.texture = DataStorage.getLocalData().getSnsImageTexture(snsType);
               TextureCollector.loadSnsImage(snsType,queue,function(param1:Texture):void
               {
                  if(param1 != null)
                  {
                     imgSns.texture = param1;
                     imgSns.visible = true;
                  }
                  if(_enableDrawCache)
                  {
                     (displaySprite as ContainerButton).enableDrawCache();
                  }
               });
            }
            else if(_enableDrawCache)
            {
               (displaySprite as ContainerButton).enableDrawCache();
            }
         }
         else
         {
            queue.addTask(function():void
            {
               TextureCollector.loadTextureRsrc("avatar-" + GameSetting.getAvatar(UserDataWrapper.wrapper.getCurrentAvatar()).rsrc,function(param1:Texture):void
               {
                  iconImage.texture = param1;
                  (displaySprite as ContainerButton).enableDrawCache();
                  queue.taskDone();
               });
            });
         }
      }
      
      override public function setVisible(param1:Boolean) : void
      {
         visible = param1;
         alpha = displaySprite.alpha;
      }
      
      public function set alpha(param1:Number) : void
      {
         setAlpha(param1);
         displaySprite.visible = visible && param1 > 0;
      }
      
      private function triggered(param1:Event) : void
      {
         var event:Event = param1;
         SoundManager.playEffect("voice_profile_def");
         ResidentMenuUI_Gudetama.getInstance().sendChangeState(145,function():void
         {
            Engine.switchScene(new ProfileScene());
         });
      }
      
      public function dispose() : void
      {
         displaySprite.removeEventListener("triggered",triggered);
         iconImage = null;
         imgSns = null;
      }
   }
}
