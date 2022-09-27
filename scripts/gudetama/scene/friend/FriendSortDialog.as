package gudetama.scene.friend
{
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TweenAnimator;
   import gudetama.util.FriendSortUtil;
   import muku.display.ContainerButton;
   import starling.display.DisplayObject;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class FriendSortDialog extends BaseScene
   {
       
      
      private var sources:Vector.<Object>;
      
      private var changeBtn:ContainerButton;
      
      private var sortBtnList:Vector.<ContainerButton>;
      
      private var selectSprite:Sprite;
      
      private var currentSprite:Sprite;
      
      private var currentSort:int;
      
      private var selectSort:int;
      
      private var callback:Function;
      
      public function FriendSortDialog(param1:Vector.<Object>, param2:int, param3:Function)
      {
         sortBtnList = new Vector.<ContainerButton>(4,true);
         super(1);
         this.sources = param1;
         this.currentSort = param2;
         this.callback = param3;
      }
      
      public static function show(param1:Vector.<Object>, param2:int, param3:Function) : void
      {
         Engine.pushScene(new FriendSortDialog(param1,param2,param3));
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         Engine.setupLayoutForTask(queue,"FriendSortDialogLayout",function(param1:Object):void
         {
            var layout:Object = param1;
            displaySprite = layout.object as Sprite;
            var dialogSprite:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            var changeBtn:ContainerButton = dialogSprite.getChildByName("changeBtn") as ContainerButton;
            changeBtn.addEventListener("triggered",triggeredChangeBtn);
            var setupSortButton:Function = function(param1:int):void
            {
               var _loc2_:ContainerButton = sortSprite.getChildByName("sortBtn" + param1) as ContainerButton;
               _loc2_.userObject.sortType = param1;
               _loc2_.addEventListener("triggered",triggeredSelectSortBtn);
               _loc2_.setTweenDisable();
               sortBtnList[param1] = _loc2_;
            };
            var sortSprite:Sprite = dialogSprite.getChildByName("sortBtnSprite") as Sprite;
            setupSortButton(0);
            setupSortButton(1);
            setupSortButton(2);
            setupSortButton(3);
            currentSprite = sortSprite.getChildByName("currentSprite") as Sprite;
            selectSprite = sortSprite.getChildByName("selectedSprite") as Sprite;
            selectSprite.visible = false;
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         queue.startTask(onProgress);
      }
      
      override protected function addedToContainer() : void
      {
         setBackButtonCallback(backButtonCallback);
         var _loc1_:ContainerButton = sortBtnList[currentSort];
         _loc1_.touchable = false;
         currentSprite.x = _loc1_.x;
         currentSprite.y = _loc1_.y;
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show");
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.popScene(scene);
            callback = null;
         });
      }
      
      private function triggeredChangeBtn(param1:Event) : void
      {
         var event:Event = param1;
         FriendSortUtil.processSort(sources,true,selectSort);
         TweenAnimator.startItself(displaySprite,"hide",false,function(param1:DisplayObject):void
         {
            Engine.popScene(scene);
            if(callback)
            {
               callback(selectSort);
               callback = null;
            }
         });
      }
      
      private function triggeredSelectSortBtn(param1:Event) : void
      {
         var _loc2_:ContainerButton = param1.target as ContainerButton;
         selectSort = _loc2_.userObject.sortType;
         selectSprite.x = _loc2_.x;
         selectSprite.y = _loc2_.y;
         selectSprite.visible = true;
      }
   }
}
