package gudetama.scene.ranking
{
   import gudetama.data.GameSetting;
   import gudetama.data.RankingInfoWrapper;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.DeliverPointTableDef;
   import gudetama.data.compati.RankingDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.textures.Texture;
   
   public class DeliverListDialog extends BaseScene
   {
       
      
      private const gudeMax:int = 9;
      
      private var info:RankingInfoWrapper;
      
      private var updateCallback:Function;
      
      private var deliverDef:DeliverPointTableDef;
      
      private var lblRank:ColorTextField;
      
      private var lblPts:ColorTextField;
      
      private var btnAll:ContainerButton;
      
      private var btnClose:ContainerButton;
      
      private var selectUI:DeliverItemUI;
      
      private var deliverPtsInfos:Array;
      
      private var loadCount:int;
      
      public function DeliverListDialog(param1:RankingInfoWrapper, param2:Function)
      {
         super(1);
         this.info = param1;
         updateCallback = param2;
         deliverDef = GameSetting.def.deliverPointTableMap[param1.content.deliverTableId];
      }
      
      public static function show(param1:RankingInfoWrapper, param2:Function) : void
      {
         Engine.showLoading(DeliverListDialog);
         Engine.pushScene(new DeliverListDialog(param1,param2),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"DeliverListDialog",function(param1:Object):void
         {
            var _loc2_:* = undefined;
            var _loc8_:int = 0;
            var _loc12_:* = null;
            var _loc5_:* = null;
            var _loc7_:* = null;
            displaySprite = param1.object;
            var _loc3_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            _loc3_.y = 492;
            var _loc4_:Sprite;
            lblRank = (_loc4_ = _loc3_.getChildByName("spRank") as Sprite).getChildByName("lblRank") as ColorTextField;
            if(!lblRank)
            {
               lblRank = _loc3_.getChildByName("lblRank") as ColorTextField;
            }
            updateMyRankLabel();
            var _loc10_:Sprite;
            lblPts = (_loc10_ = _loc3_.getChildByName("spPts") as Sprite).getChildByName("lblPts") as ColorTextField;
            if(!lblPts)
            {
               lblPts = _loc3_.getChildByName("lblPts") as ColorTextField;
            }
            updateMyPointLabel();
            var _loc11_:Object = deliverDef.gudePointMap;
            deliverPtsInfos = [];
            for(var _loc6_ in _loc11_)
            {
               _loc2_ = _loc11_[_loc6_];
               deliverPtsInfos.push(new DeliverPointInfo(_loc2_[1],_loc6_,_loc2_[0]));
            }
            deliverPtsInfos.sort(sortDeliverPointInfo);
            _loc8_ = 0;
            while(_loc8_ < 9)
            {
               _loc12_ = _loc3_.getChildByName("spDeliver" + _loc8_) as Sprite;
               if(_loc8_ < deliverPtsInfos.length)
               {
                  _loc5_ = new DeliverItemUI(_loc12_,info.rankingId,triggeredDeliverUI);
                  _loc7_ = deliverPtsInfos[_loc8_];
                  _loc5_.updateData([_loc7_.gudeId,_loc7_.point]);
               }
               else
               {
                  _loc12_.visible = false;
               }
               _loc8_++;
            }
            btnAll = _loc3_.getChildByName("btnAll") as ContainerButton;
            btnAll.addEventListener("triggered",triggeredAll);
            var _loc9_:ColorTextField;
            (_loc9_ = btnAll.getChildByName("text") as ColorTextField).text#2 = GameSetting.getUIText("ranking.btn.deliver.all");
            btnAll.enableDrawCache(true,true);
            updateAllButtonView();
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
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("event" + (info.rankingId - 1) + "@frame01",function(param1:Texture):void
            {
               var _loc2_:Image = dialogSprite.getChildByName("frame01") as Image;
               _loc2_.texture = param1;
               queue.taskDone();
            });
         });
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("event" + (info.rankingId - 1) + "@frame02",function(param1:Texture):void
            {
               var _loc2_:Image = dialogSprite.getChildByName("frame02") as Image;
               _loc2_.texture = param1;
               queue.taskDone();
            });
         });
         var spRank:Sprite = dialogSprite.getChildByName("spRank") as Sprite;
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("event" + (info.rankingId - 1) + "@mat_ranking",function(param1:Texture):void
            {
               var _loc2_:Image = spRank.getChildByName("mat_ranking") as Image;
               _loc2_.texture = param1;
               queue.taskDone();
            });
         });
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("event" + (info.rankingId - 1) + "@flag",function(param1:Texture):void
            {
               var _loc2_:Image = spRank.getChildByName("flag") as Image;
               _loc2_.texture = param1;
               queue.taskDone();
            });
         });
         var spPts:Sprite = dialogSprite.getChildByName("spPts") as Sprite;
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("event" + (info.rankingId - 1) + "@mat_ranking",function(param1:Texture):void
            {
               var _loc2_:Image = spPts.getChildByName("mat_ranking") as Image;
               _loc2_.texture = param1;
               queue.taskDone();
            });
         });
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("event" + (info.rankingId - 1) + "@item",function(param1:Texture):void
            {
               var _loc2_:Image = spPts.getChildByName("item") as Image;
               _loc2_.texture = param1;
               queue.taskDone();
            });
         });
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("event" + (info.rankingId - 1) + "@btn_exchange_l",function(param1:Texture):void
            {
               btnAll.background = param1;
               queue.taskDone();
            });
         });
         var rDef:RankingDef = GameSetting.def.rankingMap[info.rankingId];
         lblPts.color = rDef.pointTextColor;
      }
      
      private function updateMyRankLabel() : void
      {
         lblRank.text#2 = info.getMyRankText();
      }
      
      private function updateMyPointLabel() : void
      {
         lblPts.text#2 = StringUtil.getNumStringCommas(info.myPoint);
      }
      
      private function sortDeliverPointInfo(param1:DeliverPointInfo, param2:DeliverPointInfo) : int
      {
         return param1.idx - param2.idx;
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(DeliverListDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(92);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(DeliverListDialog);
            Engine.hideLoading(DeliverListDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(DeliverListDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(DeliverListDialog);
            Engine.popScene(scene);
         });
      }
      
      private function triggeredDeliverUI(param1:int, param2:int, param3:DeliverItemUI) : void
      {
         selectUI = param3;
         var _loc4_:int = UserDataWrapper.gudetamaPart.getNumGudetama(param1);
         DeliverNumSelectDialog.show(info.rankingId,param1,_loc4_,param2,deliverCallback);
      }
      
      private function updateAllButtonView() : void
      {
         var _loc2_:int = 0;
         var _loc3_:* = null;
         var _loc1_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < deliverPtsInfos.length)
         {
            _loc3_ = deliverPtsInfos[_loc2_];
            _loc1_ = UserDataWrapper.gudetamaPart.getNumGudetama(_loc3_.gudeId);
            if(_loc1_ > 0)
            {
               btnAll.color = 16777215;
               btnAll.enabled = true;
               return;
            }
            _loc2_++;
         }
         btnAll.color = 8421504;
         btnAll.enabled = false;
      }
      
      private function triggeredAll() : void
      {
         var _loc3_:int = 0;
         var _loc4_:* = null;
         var _loc2_:int = 0;
         var _loc1_:int = 0;
         var _loc5_:int = 0;
         _loc3_ = 0;
         while(_loc3_ < deliverPtsInfos.length)
         {
            _loc4_ = deliverPtsInfos[_loc3_];
            _loc2_ = UserDataWrapper.gudetamaPart.getNumGudetama(_loc4_.gudeId);
            if(_loc2_ > 0)
            {
               _loc1_ += _loc2_;
               _loc5_ += _loc4_.point * _loc2_;
            }
            _loc3_++;
         }
         if(_loc1_ == 0)
         {
            return;
         }
         DeliverAllConfirmDialog.show(info.rankingId,_loc5_,_loc1_,deliverCallback);
      }
      
      private function deliverCallback(param1:int, param2:int, param3:int, param4:Boolean = false) : void
      {
         var _loc5_:int = 0;
         var _loc6_:* = null;
         info.myPoint = param1;
         info.rank = param2;
         info.totalPoint = param3;
         info.checkTopRecordsIn();
         updateCallback(info);
         if(param4)
         {
            _loc5_ = 0;
            while(_loc5_ < deliverPtsInfos.length)
            {
               _loc6_ = deliverPtsInfos[_loc5_];
               UserDataWrapper.gudetamaPart.setGudetamaNum(_loc6_.gudeId,0);
               _loc5_++;
            }
            backButtonCallback();
         }
         else
         {
            selectUI.updateHasNum();
            updateAllButtonView();
            updateMyPointLabel();
            updateMyRankLabel();
         }
      }
      
      override public function dispose() : void
      {
         btnAll.removeEventListener("triggered",triggeredAll);
         btnAll = null;
         btnClose.removeEventListener("triggered",backButtonCallback);
         btnClose = null;
         super.dispose();
      }
   }
}

class DeliverPointInfo
{
    
   
   private var idx:int;
   
   private var gudeId:int;
   
   private var point:int;
   
   function DeliverPointInfo(param1:int, param2:int, param3:int)
   {
      super();
      this.idx = param1;
      this.gudeId = param2;
      this.point = param3;
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.GudetamaDef;
import gudetama.data.compati.KitchenwareDef;
import gudetama.data.compati.RankingDef;
import gudetama.data.compati.RecipeNoteDef;
import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

class DeliverItemUI extends UIBase
{
    
   
   private var rankingId:int;
   
   private var callback:Function;
   
   private var gudeId:int;
   
   private var pts:int;
   
   private var button:ContainerButton;
   
   private var imgIcon:Image;
   
   private var imgKw:Image;
   
   private var lblName:ColorTextField;
   
   private var lblPts:ColorTextField;
   
   private var lblNum:ColorTextField;
   
   function DeliverItemUI(param1:Sprite, param2:int, param3:Function)
   {
      super(param1);
      this.rankingId = param2;
      this.callback = param3;
      button = param1.getChildByName("button") as ContainerButton;
      button.addEventListener("triggered",triggeredButton);
      imgIcon = button.getChildByName("imgIcon") as Image;
      imgKw = button.getChildByName("imgKw") as Image;
      lblName = button.getChildByName("lblName") as ColorTextField;
      lblPts = button.getChildByName("lblPts") as ColorTextField;
      lblNum = button.getChildByName("lblNum") as ColorTextField;
      var _loc4_:RankingDef = GameSetting.def.rankingMap[param2];
      lblPts.color = _loc4_.pointTextColor;
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      if(!data)
      {
         return;
      }
      gudeId = data[0];
      pts = data[1];
      var imageName:String = GudetamaUtil.getItemImageName(7,gudeId);
      TextureCollector.loadTexture(imageName,function(param1:Texture):void
      {
         if(imgIcon != null)
         {
            imgIcon.texture = param1;
         }
      });
      var gudeDef:GudetamaDef = GameSetting.getGudetama(gudeId);
      var noteDef:RecipeNoteDef = GameSetting.getRecipeNote(gudeDef.recipeNoteId);
      var kwDef:KitchenwareDef = GameSetting.getKitchenware(noteDef.kitchenwareId);
      TextureCollector.loadTexture("recipe0@circle" + (kwDef.id#2 - 1),function(param1:Texture):void
      {
         if(imgKw != null)
         {
            imgKw.texture = param1;
         }
      });
      var posterName:String = "event" + (rankingId - 1) + "@poster0" + (kwDef.type != 4 ? 1 : 2);
      TextureCollector.loadTexture(posterName,function(param1:Texture):void
      {
         if(button != null)
         {
            button.background = param1;
         }
      });
      lblName.text#2 = GudetamaUtil.getItemName(7,gudeId);
      lblPts.text#2 = StringUtil.getNumStringCommas(pts);
      updateHasNum();
   }
   
   public function updateHasNum() : void
   {
      lblNum.text#2 = GameSetting.getUIText("mult.mark").replace("%1",StringUtil.getNumStringCommas(UserDataWrapper.gudetamaPart.getNumGudetama(gudeId)));
   }
   
   private function triggeredButton() : void
   {
      callback(gudeId,pts,this);
   }
   
   public function dispose() : void
   {
      callback = null;
      button.removeEventListener("triggered",triggeredButton);
      button = null;
      imgIcon = null;
      imgKw = null;
      lblName = null;
      lblPts = null;
      lblNum = null;
   }
}
