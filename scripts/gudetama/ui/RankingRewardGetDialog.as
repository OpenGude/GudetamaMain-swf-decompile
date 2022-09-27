package gudetama.ui
{
   import gudetama.common.GudetamaUtil;
   import gudetama.data.compati.ItemParam;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.SoundManager;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.textures.Texture;
   
   public class RankingRewardGetDialog extends BaseScene
   {
       
      
      private var rankingId:int;
      
      private var items:Array;
      
      private var callback:Function;
      
      private var msgs:Array;
      
      private var titles:Array;
      
      private var currentIdx:int = 0;
      
      private var lblTitle:ColorTextField;
      
      private var lblName:ColorTextField;
      
      private var lblMsg:ColorTextField;
      
      private var imgPrize:Image;
      
      private var imgToge:Image;
      
      private var btnClose:ContainerButton;
      
      private var loadCount:int;
      
      public function RankingRewardGetDialog(param1:int, param2:Array, param3:Function, param4:Array, param5:Array)
      {
         super(2);
         this.rankingId = param1;
         this.items = param2;
         this.callback = param3;
         this.msgs = param4;
         this.titles = param5;
      }
      
      public static function show(param1:int, param2:Array, param3:Function, param4:Array, param5:Array = null) : void
      {
         Engine.pushScene(new RankingRewardGetDialog(param1,param2,param3,param4,param5),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"RankingRewardGetDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            lblTitle = _loc2_.getChildByName("title") as ColorTextField;
            imgToge = _loc2_.getChildByName("imgToge") as Image;
            lblName = _loc2_.getChildByName("text") as ColorTextField;
            lblMsg = _loc2_.getChildByName("message") as ColorTextField;
            btnClose = _loc2_.getChildByName("btnClose") as ContainerButton;
            btnClose.addEventListener("triggered",backButtonCallback);
            displaySprite.visible = false;
            addChild(displaySprite);
            setup();
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
      
      private function setupLayoutForTask(param1:TaskQueue, param2:Object, param3:Function) : void
      {
         var queue:TaskQueue = param1;
         var layoutData:Object = param2;
         var callback:Function = param3;
         loadCount++;
         Engine.setupLayoutForTask(queue,layoutData,function(param1:Object):void
         {
            loadCount--;
            callback(param1);
            checkInit();
         });
      }
      
      private function addTask(param1:Function) : void
      {
         loadCount++;
         queue.addTask(param1);
      }
      
      private function taskDone() : void
      {
         loadCount--;
         checkInit();
         queue.taskDone();
      }
      
      private function checkInit() : void
      {
         if(loadCount > 0)
         {
            return;
         }
         init();
      }
      
      private function init() : void
      {
         var dialogSprite:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("event" + (rankingId - 1) + "@frame01",function(param1:Texture):void
            {
               var _loc2_:Image = dialogSprite.getChildByName("frame01") as Image;
               _loc2_.texture = param1;
               queue.taskDone();
            });
         });
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("event" + (rankingId - 1) + "@frame02",function(param1:Texture):void
            {
               var _loc2_:Image = dialogSprite.getChildByName("frame02") as Image;
               _loc2_.texture = param1;
               queue.taskDone();
            });
         });
      }
      
      private function setup() : void
      {
         if(titles != null)
         {
            if(currentIdx < titles.length)
            {
               lblTitle.text#2 = titles[currentIdx];
            }
         }
         else
         {
            lblTitle.text#2 = "";
         }
         var item:ItemParam = items[currentIdx];
         lblName.text#2 = GudetamaUtil.getItemParamNameAndNum(item);
         lblMsg.text#2 = msgs[currentIdx];
         TextureCollector.loadTextureForTask(queue,GudetamaUtil.getItemImageName(item.kind,item.id#2),function(param1:Texture):void
         {
            if(imgPrize == null)
            {
               imgPrize = new Image(param1);
               imgPrize.alignPivot();
               imgPrize.x = imgToge.x;
               imgPrize.y = imgToge.y;
               (displaySprite.getChildByName("dialogSprite") as Sprite).addChild(imgPrize);
            }
            else
            {
               imgPrize.texture = param1;
            }
         });
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(RankingRewardGetDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(78);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         SoundManager.playEffect("MaxComboSuccess");
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(RankingRewardGetDialog);
            TweenAnimator.startItself(imgToge,"start");
         });
      }
      
      override public function backButtonCallback() : void
      {
         if(++currentIdx >= items.length)
         {
            close();
         }
         else
         {
            next();
         }
      }
      
      private function next() : void
      {
         Engine.lockTouchInput(RankingRewardGetDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            setup();
            queue.registerOnProgress(function(param1:Number):void
            {
               var ratio:Number = param1;
               if(ratio < 1)
               {
                  return;
               }
               TweenAnimator.startItself(displaySprite,"show",false,function():void
               {
                  Engine.unlockTouchInput(RankingRewardGetDialog);
                  TweenAnimator.startItself(imgToge,"start");
                  setBackButtonCallback(backButtonCallback);
               });
            });
            queue.startTask();
         });
      }
      
      private function close() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(RankingRewardGetDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(RankingRewardGetDialog);
            Engine.popScene(scene);
            if(callback != null)
            {
               callback();
            }
         });
      }
      
      override public function dispose() : void
      {
         lblTitle = null;
         lblName = null;
         lblMsg = null;
         imgToge = null;
         imgPrize = null;
         btnClose.removeEventListener("triggered",backButtonCallback);
         btnClose = null;
         super.dispose();
      }
   }
}
