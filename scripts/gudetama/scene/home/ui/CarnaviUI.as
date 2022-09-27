package gudetama.scene.home.ui
{
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.ui.UIBase;
   import muku.core.TaskQueue;
   import muku.display.SpineModel;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.textures.Texture;
   
   public class CarnaviUI extends UIBase
   {
      
      private static const INTERVAL:int = 20000;
       
      
      private var image:Image;
      
      private var spineModel:SpineModel;
      
      private var carnaviImages:Vector.<Texture>;
      
      private var currentIndex:int;
      
      private var nextTime:uint;
      
      public function CarnaviUI(param1:Sprite)
      {
         carnaviImages = new Vector.<Texture>();
         super(param1);
         image = param1.getChildByName("image") as Image;
         spineModel = param1.getChildByName("spineModel") as SpineModel;
         spineModel.visible = false;
      }
      
      public function load(param1:TaskQueue) : void
      {
         var _loc3_:int = 0;
         var _loc2_:Array = GameSetting.getRule().carnaviIds;
         carnaviImages.length = _loc2_.length;
         _loc3_ = 0;
         while(_loc3_ < _loc2_.length)
         {
            loadCarnaviImage(param1,_loc3_,_loc2_[_loc3_]);
            _loc3_++;
         }
      }
      
      private function loadCarnaviImage(param1:TaskQueue, param2:int, param3:int) : void
      {
         var queue:TaskQueue = param1;
         var index:int = param2;
         var id:int = param3;
         queue.addTask(function():void
         {
            TextureCollector.loadTextureRsrc("carnavi-" + id,function(param1:Texture):void
            {
               carnaviImages[index] = param1;
               queue.taskDone();
            });
         });
      }
      
      public function setup() : void
      {
         image.texture = carnaviImages[currentIndex];
         nextTime = Engine.now + 20000;
         update();
      }
      
      public function update() : void
      {
         var _loc1_:int = UserDataWrapper.videoAdPart.getRestNum();
         setVisible(_loc1_ > 0);
      }
      
      public function advanceTime(param1:Number) : void
      {
         var dt:Number = param1;
         if(Engine.now < nextTime)
         {
            return;
         }
         currentIndex = (currentIndex + 1) % carnaviImages.length;
         spineModel.show();
         spineModel.changeAnimation("start1",false,function():void
         {
            image.texture = carnaviImages[currentIndex];
            spineModel.changeAnimation("start2",false,function():void
            {
               spineModel.hide();
            });
         });
         nextTime = Engine.now + 20000;
      }
      
      public function dispose() : void
      {
         image = null;
         spineModel = null;
         carnaviImages.length = 0;
         carnaviImages = null;
      }
   }
}
