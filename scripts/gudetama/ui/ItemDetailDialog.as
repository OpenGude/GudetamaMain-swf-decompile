package gudetama.ui
{
   import gudetama.common.GudetamaUtil;
   import gudetama.data.compati.ItemParam;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.textures.Texture;
   
   public class ItemDetailDialog extends BaseScene
   {
       
      
      private var item:ItemParam;
      
      private var title:String;
      
      private var imgPrize:Image;
      
      private var quadIcon:Quad;
      
      private var btnClose:ContainerButton;
      
      public function ItemDetailDialog(param1:ItemParam, param2:String)
      {
         super(2);
         this.item = param1;
         this.title = param2;
      }
      
      public static function show(param1:ItemParam, param2:String = "") : void
      {
         Engine.pushScene(new ItemDetailDialog(param1,param2),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"ItemDetailDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc5_:ColorTextField;
            var _loc4_:Sprite;
            (_loc5_ = (_loc4_ = displaySprite.getChildByName("dialogSprite") as Sprite).getChildByName("title") as ColorTextField).text#2 = title;
            quadIcon = _loc4_.getChildByName("quadIcon") as Quad;
            var _loc3_:ColorTextField = _loc4_.getChildByName("text") as ColorTextField;
            _loc3_.text#2 = GudetamaUtil.getItemParamNameAndNum(item);
            var _loc2_:ColorTextField = _loc4_.getChildByName("message") as ColorTextField;
            _loc2_.text#2 = GudetamaUtil.getItemDesc(item.kind,item.id#2);
            btnClose = _loc4_.getChildByName("btnClose") as ContainerButton;
            btnClose.addEventListener("triggered",backButtonCallback);
            setup();
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
         });
         queue.startTask(onProgress);
      }
      
      private function setup() : void
      {
         TextureCollector.loadTextureForTask(queue,GudetamaUtil.getItemImageName(item.kind,item.id#2),function(param1:Texture):void
         {
            imgPrize = new Image(param1);
            imgPrize.alignPivot();
            imgPrize.x = quadIcon.x;
            imgPrize.y = quadIcon.y;
            (displaySprite.getChildByName("dialogSprite") as Sprite).addChild(imgPrize);
            queue.taskDone();
         });
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(ItemDetailDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(94);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(ItemDetailDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(ItemGetDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(ItemDetailDialog);
            Engine.popScene(scene);
         });
      }
      
      override public function dispose() : void
      {
         quadIcon = null;
         imgPrize = null;
         btnClose.removeEventListener("triggered",backButtonCallback);
         btnClose = null;
         super.dispose();
      }
   }
}
