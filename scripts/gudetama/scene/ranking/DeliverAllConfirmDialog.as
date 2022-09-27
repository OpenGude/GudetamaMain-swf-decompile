package gudetama.scene.ranking
{
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.RankingDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.ui.LocalMessageDialog;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.textures.Texture;
   
   public class DeliverAllConfirmDialog extends BaseScene
   {
       
      
      private var rankingId:int;
      
      private var totalPts:int;
      
      private var totalNum:int;
      
      private var deliverCallback:Function;
      
      private var btnDeliver:ContainerButton;
      
      private var btnClose:ContainerButton;
      
      private var loadCount:int;
      
      public function DeliverAllConfirmDialog(param1:int, param2:int, param3:int, param4:Function)
      {
         super(1);
         this.rankingId = param1;
         this.totalPts = param2;
         this.totalNum = param3;
         deliverCallback = param4;
      }
      
      public static function show(param1:int, param2:int, param3:int, param4:Function) : void
      {
         Engine.pushScene(new DeliverAllConfirmDialog(param1,param2,param3,param4),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         var rDef:RankingDef = GameSetting.def.rankingMap[rankingId];
         var isFes:Boolean = rDef.groupType == 1;
         setupLayoutForTask(queue,!!isFes ? "DeliverAllConfirmDialog" : "DeliverAllConfirmTourDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc3_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            var _loc6_:ColorTextField;
            var _loc4_:Sprite;
            (_loc6_ = (_loc4_ = _loc3_.getChildByName("spPts") as Sprite).getChildByName("lblPts") as ColorTextField).text#2 = StringUtil.getNumStringCommas(totalPts);
            var _loc5_:ColorTextField;
            (_loc5_ = _loc3_.getChildByName("lblConsume") as ColorTextField).text#2 = GameSetting.getUIText("ranking.deliver.consume.num");
            var _loc2_:ColorTextField = _loc3_.getChildByName("lblHas") as ColorTextField;
            _loc2_.text#2 = StringUtil.getNumStringCommas(totalNum);
            btnDeliver = _loc3_.getChildByName("btnDeliver") as ContainerButton;
            btnDeliver.addEventListener("triggered",triggeredDeliver);
            var _loc7_:ColorTextField;
            (_loc7_ = btnDeliver.getChildByName("lblDeliver") as ColorTextField).text#2 = GameSetting.getUIText("ranking.btn.deliver.all");
            btnClose = _loc3_.getChildByName("btnClose") as ContainerButton;
            btnClose.addEventListener("triggered",backButtonCallback);
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
         var rDef:RankingDef = GameSetting.def.rankingMap[rankingId];
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
            TextureCollector.loadTexture("event" + (rankingId - 1) + "@title02",function(param1:Texture):void
            {
               var _loc2_:Image = dialogSprite.getChildByName("title02") as Image;
               _loc2_.texture = param1;
               queue.taskDone();
            });
         });
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("event" + (rankingId - 1) + "@lump",function(param1:Texture):void
            {
               var _loc2_:Image = dialogSprite.getChildByName("lump") as Image;
               _loc2_.texture = param1;
               queue.taskDone();
            });
         });
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("event" + (rankingId - 1) + "@mat_white",function(param1:Texture):void
            {
               var _loc2_:Image = dialogSprite.getChildByName("mat_white") as Image;
               _loc2_.texture = param1;
               queue.taskDone();
            });
         });
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("event" + (rankingId - 1) + "@mat_number",function(param1:Texture):void
            {
               var _loc2_:Image = dialogSprite.getChildByName("mat_number") as Image;
               _loc2_.texture = param1;
               queue.taskDone();
            });
         });
         var spPts:Sprite = dialogSprite.getChildByName("spPts") as Sprite;
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("event" + (rankingId - 1) + "@mat_ranking",function(param1:Texture):void
            {
               var _loc2_:Image = spPts.getChildByName("mat_ranking") as Image;
               _loc2_.texture = param1;
               queue.taskDone();
            });
         });
         queue.addTask(function():void
         {
            var isFes:Boolean = rDef.groupType == 1;
            TextureCollector.loadTexture("event" + (rankingId - 1) + "@" + (!!isFes ? "item" : "p"),function(param1:Texture):void
            {
               var _loc2_:Image = spPts.getChildByName("item") as Image;
               _loc2_.texture = param1;
               queue.taskDone();
            });
         });
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("event" + (rankingId - 1) + "@btn_exchange_l",function(param1:Texture):void
            {
               btnDeliver.background = param1;
               queue.taskDone();
            });
         });
         var lblPts:ColorTextField = spPts.getChildByName("lblPts") as ColorTextField;
         lblPts.color = rDef.pointTextColor;
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(DeliverAllConfirmDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(28);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(DeliverAllConfirmDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(DeliverAllConfirmDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(DeliverAllConfirmDialog);
            Engine.popScene(scene);
         });
      }
      
      private function triggeredDeliver() : void
      {
         Engine.showLoading(triggeredDeliver);
         var _loc1_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(33554434,rankingId),function(param1:*):void
         {
            var res:* = param1;
            Engine.hideLoading(triggeredDeliver);
            if(res is Array)
            {
               var newPts:int = res[0];
               var newRank:int = res[1];
               var totalPoint:int = res[2];
               deliverCallback(newPts,newRank,totalPoint,true);
               backButtonCallback();
            }
            else if(res is int)
            {
               var msg:String = "";
               var _loc3_:* = res;
               if(-1 !== _loc3_)
               {
                  msg = GameSetting.getUIText("ranking.err.deliver." + res);
               }
               else
               {
                  msg = GameSetting.getUIText("ranking.err.deliver." + res).replace("%1",GameSetting.getRanking(rankingId).title).replace("%2",UserDataWrapper.eventPart.getRankingPointText());
               }
               LocalMessageDialog.show(0,msg,function(param1:int):void
               {
                  backButtonCallback();
               });
            }
         });
      }
      
      override public function dispose() : void
      {
         btnDeliver.removeEventListener("triggered",triggeredDeliver);
         btnDeliver = null;
         btnClose.removeEventListener("triggered",backButtonCallback);
         btnClose = null;
         super.dispose();
      }
   }
}
