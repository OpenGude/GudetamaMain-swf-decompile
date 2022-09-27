package gudetama.scene.ranking
{
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.GudetamaDef;
   import gudetama.data.compati.KitchenwareDef;
   import gudetama.data.compati.RankingDef;
   import gudetama.data.compati.RecipeNoteDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.scene.collection.GudetamaDetailDialog;
   import gudetama.scene.friend.FriendPresentListDialog;
   import gudetama.ui.LocalMessageDialog;
   import gudetama.util.GudeActUtil;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.display.SimpleImageButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class DeliverNumSelectDialog extends BaseScene
   {
       
      
      private var rankingId:int;
      
      private var gudeId:int;
      
      private var hasNum:int;
      
      private var pts:int;
      
      private var deliverCallback:Function;
      
      private var currentNum:int = 1;
      
      private var stateWant:int;
      
      private var statePresent:int;
      
      private var stateCook:int;
      
      private var icon:Image;
      
      private var imgPoster:Image;
      
      private var lblNum:ColorTextField;
      
      private var lblPts:ColorTextField;
      
      private var btnAdd:SimpleImageButton;
      
      private var btnSub:SimpleImageButton;
      
      private var btnWant:SimpleImageButton;
      
      private var btnPresent:SimpleImageButton;
      
      private var btnCook:SimpleImageButton;
      
      private var btnDeliver:ContainerButton;
      
      private var btnClose:ContainerButton;
      
      private var loadCount:int;
      
      public function DeliverNumSelectDialog(param1:int, param2:int, param3:int, param4:int, param5:Function)
      {
         super(1);
         this.rankingId = param1;
         this.gudeId = param2;
         this.hasNum = param3;
         this.pts = param4;
         deliverCallback = param5;
      }
      
      public static function show(param1:int, param2:int, param3:int, param4:int, param5:Function) : void
      {
         Engine.pushScene(new DeliverNumSelectDialog(param1,param2,param3,param4,param5),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         var rDef:RankingDef = GameSetting.def.rankingMap[rankingId];
         var isFes:Boolean = rDef.groupType == 1;
         setupLayoutForTask(queue,!!isFes ? "DeliverNumSelectDialog" : "DeliverNumSelectTourDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc4_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            var _loc8_:GudetamaDef = GameSetting.getGudetama(gudeId);
            var _loc2_:ColorTextField = _loc4_.getChildByName("lblName") as ColorTextField;
            _loc2_.text#2 = _loc8_.name#2;
            icon = _loc4_.getChildByName("icon") as Image;
            var _loc9_:ColorTextField;
            var _loc6_:Sprite;
            (_loc9_ = (_loc6_ = _loc4_.getChildByName("spCost") as Sprite).getChildByName("lblCost") as ColorTextField).text#2 = StringUtil.getNumStringCommas(_loc8_.cost);
            var _loc7_:ColorTextField;
            (_loc7_ = _loc6_.getChildByName("lblUnitGP") as ColorTextField).text#2 = GameSetting.getUIText("item.name.0");
            imgPoster = _loc4_.getChildByName("imgPoster") as Image;
            var _loc5_:Sprite;
            lblPts = (_loc5_ = _loc4_.getChildByName("spPts") as Sprite).getChildByName("lblPts") as ColorTextField;
            var _loc3_:ColorTextField = _loc4_.getChildByName("lblHas") as ColorTextField;
            _loc3_.text#2 = StringUtil.getNumStringCommas(hasNum);
            lblNum = _loc4_.getChildByName("lblNum") as ColorTextField;
            btnAdd = _loc4_.getChildByName("btnAdd") as SimpleImageButton;
            btnAdd.addEventListener("triggered",triggeredAdd);
            btnSub = _loc4_.getChildByName("btnSub") as SimpleImageButton;
            btnSub.addEventListener("triggered",triggeredSub);
            btnWant = _loc4_.getChildByName("btnWant") as SimpleImageButton;
            btnWant.addEventListener("triggered",triggeredWant);
            btnPresent = _loc4_.getChildByName("btnPresent") as SimpleImageButton;
            btnPresent.addEventListener("triggered",triggeredPresent);
            btnCook = _loc4_.getChildByName("btnCook") as SimpleImageButton;
            btnCook.addEventListener("triggered",triggeredCook);
            btnDeliver = _loc4_.getChildByName("btnDeliver") as ContainerButton;
            btnDeliver.addEventListener("triggered",triggeredDeliver);
            var _loc10_:ColorTextField;
            (_loc10_ = btnDeliver.getChildByName("lblDeliver") as ColorTextField).text#2 = GameSetting.getUIText("ranking.btn.deliver").replace("%1",UserDataWrapper.eventPart.getRankingPointText());
            if(hasNum == 0)
            {
               updateButtonsView(false);
            }
            btnClose = _loc4_.getChildByName("btnClose") as ContainerButton;
            btnClose.addEventListener("triggered",triggeredClose);
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
         var spCost:Sprite = dialogSprite.getChildByName("spCost") as Sprite;
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("event" + (rankingId - 1) + "@mat_name",function(param1:Texture):void
            {
               var _loc2_:Image = spCost.getChildByName("mat_name") as Image;
               _loc2_.texture = param1;
               queue.taskDone();
            });
         });
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("event" + (rankingId - 1) + "@btn_02",function(param1:Texture):void
            {
               btnWant.texture = param1;
               queue.taskDone();
            });
         });
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("event" + (rankingId - 1) + "@btn_01",function(param1:Texture):void
            {
               btnPresent.texture = param1;
               queue.taskDone();
            });
         });
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("event" + (rankingId - 1) + "@btn_03",function(param1:Texture):void
            {
               btnCook.texture = param1;
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
            TextureCollector.loadTexture("event" + (rankingId - 1) + "@mat_exchangenum",function(param1:Texture):void
            {
               var _loc2_:Image = dialogSprite.getChildByName("mat_exchangenum") as Image;
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
            TextureCollector.loadTexture("event" + (rankingId - 1) + "@mat_number",function(param1:Texture):void
            {
               var _loc2_:Image = dialogSprite.getChildByName("mat_number") as Image;
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
         lblPts.color = rDef.pointTextColor;
      }
      
      private function updateButtonsView(param1:Boolean) : void
      {
         var _loc2_:int = !!param1 ? 16777215 : 8421504;
         btnAdd.enabled = param1;
         btnAdd.color = _loc2_;
         btnSub.enabled = param1;
         btnSub.color = _loc2_;
         btnDeliver.enableDrawCache(true);
         btnDeliver.color = _loc2_;
         btnDeliver.enabled = param1;
      }
      
      private function setup() : void
      {
         var imageName:String = GudetamaUtil.getItemImageName(7,gudeId);
         TextureCollector.loadTextureForTask(queue,imageName,function(param1:Texture):void
         {
            icon.texture = param1;
         });
         var rDef:RankingDef = GameSetting.def.rankingMap[rankingId];
         var gudeDef:GudetamaDef = GameSetting.getGudetama(gudeId);
         var noteDef:RecipeNoteDef = GameSetting.getRecipeNote(gudeDef.recipeNoteId);
         var kwDef:KitchenwareDef = GameSetting.getKitchenware(noteDef.kitchenwareId);
         var posterName:String = "event" + (rankingId - 1) + "@poster_l_0" + (kwDef.type != 4 ? 1 : 2);
         TextureCollector.loadTextureForTask(queue,posterName,function(param1:Texture):void
         {
            imgPoster.texture = param1;
         });
         stateWant = GudeActUtil.checkState(gudeId,GudeActUtil.getWantCheckStates(),false,!UserDataWrapper.wantedPart.exists(gudeId),false);
         updateWantButtonView();
         stateCook = GudeActUtil.checkState(gudeId,GudeActUtil.getCookCheckStates(),false,false,true);
         btnCook.visible = stateCook == 0;
         statePresent = GudeActUtil.checkState(gudeId,GudeActUtil.getPresentCheckStates(),!UserDataWrapper.featurePart.existsFeature(12),UserDataWrapper.gudetamaPart.hasGudetama(gudeId,1),false);
         updatePresentButtonView();
         currentNum = hasNum;
         changedCurrentNum();
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(DeliverListDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(28);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(DeliverListDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(DeliverNumSelectDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(DeliverNumSelectDialog);
            Engine.popScene(scene);
         });
      }
      
      private function triggeredClose(param1:Event) : void
      {
         backButtonCallback();
      }
      
      private function triggeredAdd() : void
      {
         if(currentNum >= hasNum)
         {
            return;
         }
         currentNum++;
         changedCurrentNum();
      }
      
      private function triggeredSub() : void
      {
         if(currentNum <= 1)
         {
            return;
         }
         currentNum--;
         changedCurrentNum();
      }
      
      private function changedCurrentNum() : void
      {
         lblNum.text#2 = StringUtil.getNumStringCommas(currentNum);
         lblPts.text#2 = StringUtil.getNumStringCommas(currentNum * pts);
      }
      
      private function updateWantButtonView() : void
      {
         if(stateWant == 0)
         {
            btnWant.color = 16777215;
            btnWant.visible = true;
         }
         else if((stateWant & 8) > 0)
         {
            btnWant.color = 8421504;
            btnWant.visible = true;
         }
         else
         {
            btnWant.visible = false;
         }
      }
      
      private function triggeredWant() : void
      {
         if((stateWant & 8) > 0)
         {
            LocalMessageDialog.show(0,GameSetting.getUIText("gudetamaDetail.message.list.disabled.desc"),null,GameSetting.getUIText("gudetamaDetail.message.list.title"));
            return;
         }
         GudetamaDetailDialog.addWantedGudetama(GameSetting.getGudetama(gudeId),function():void
         {
            stateWant |= 8;
            updateWantButtonView();
         });
      }
      
      private function updatePresentButtonView() : void
      {
         if(statePresent == 0)
         {
            btnPresent.color = 16777215;
            btnPresent.visible = true;
         }
         else if((statePresent & 2) > 0)
         {
            btnPresent.color = 8421504;
            btnPresent.visible = true;
         }
         else
         {
            btnPresent.visible = false;
         }
      }
      
      private function triggeredPresent() : void
      {
         if((statePresent & 2) > 0)
         {
            LocalMessageDialog.show(0,GudetamaUtil.getFriendUnlockConditionText(),null,GameSetting.getUIText("gudetamaDetail.message.present.title"));
            return;
         }
         FriendPresentListDialog.show(gudeId,true);
      }
      
      private function triggeredCook() : void
      {
         GudetamaDetailDialog.tryCook(GameSetting.getGudetama(gudeId),null);
      }
      
      private function triggeredDeliver() : void
      {
         var packet:Array = [rankingId,gudeId,currentNum];
         Engine.showLoading(triggeredDeliver);
         var _loc2_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(RANKING_DELIVER,packet),function(param1:*):void
         {
            var res:* = param1;
            Engine.hideLoading(triggeredDeliver);
            if(res is Array)
            {
               var newPts:int = res[0];
               var newRank:int = res[1];
               var totalPoint:int = res[2];
               UserDataWrapper.gudetamaPart.consumeGudetama(gudeId,currentNum);
               if(deliverCallback != null)
               {
                  deliverCallback(newPts,newRank,totalPoint);
               }
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
         btnAdd.removeEventListener("triggered",triggeredAdd);
         btnAdd = null;
         btnSub.removeEventListener("triggered",triggeredSub);
         btnSub = null;
         btnWant.removeEventListener("triggered",triggeredWant);
         btnWant = null;
         btnPresent.removeEventListener("triggered",triggeredPresent);
         btnPresent = null;
         btnCook.removeEventListener("triggered",triggeredCook);
         btnCook = null;
         btnDeliver.removeEventListener("triggered",triggeredDeliver);
         btnDeliver = null;
         btnClose.removeEventListener("triggered",triggeredClose);
         btnClose = null;
         super.dispose();
      }
   }
}
