package gudetama.scene.ranking
{
   import feathers.controls.IScrollBar;
   import feathers.controls.List;
   import feathers.controls.ScrollBar;
   import feathers.controls.renderers.IListItemRenderer;
   import feathers.data.ListCollection;
   import feathers.layout.FlowLayout;
   import gudetama.data.GameSetting;
   import gudetama.data.RankingInfoWrapper;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.ItemParam;
   import gudetama.data.compati.LinearTable;
   import gudetama.data.compati.RankingDef;
   import gudetama.data.compati.RankingRecord;
   import gudetama.data.compati.RankingRewardDef;
   import gudetama.data.compati.RankingRewardItemDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.util.SpriteExtractor;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class RankingRecordDialog extends BaseScene
   {
      
      public static var TAB_RANKING:int = 0;
      
      public static var TAB_REWARD:int = 1;
      
      public static var TAB_NUM:int = 2;
       
      
      private var info:RankingInfoWrapper;
      
      private var firstTab:int;
      
      private var dataMap:Object;
      
      private var tabType:int = -1;
      
      private var tabs:Vector.<Tab>;
      
      private var notEnoughText:ColorTextField;
      
      private var list:List;
      
      private var collection:ListCollection;
      
      private var btnClose:ContainerButton;
      
      private var imgTabBtm:Image;
      
      private var imgListBG:Image;
      
      private var recordExtractor:SpriteExtractor;
      
      private var rankRibbonExtractor:SpriteExtractor;
      
      private var rankRewardExtractor:SpriteExtractor;
      
      private var rankingIdx:int = -1;
      
      private var rankRewardIdx:int = -1;
      
      private var ptsRewardIdx:int = -1;
      
      private var loadCount:int;
      
      public function RankingRecordDialog(param1:RankingInfoWrapper, param2:int)
      {
         var _loc11_:int = 0;
         var _loc18_:int = 0;
         var _loc12_:int = 0;
         var _loc22_:int = 0;
         var _loc7_:* = null;
         var _loc17_:* = null;
         var _loc20_:* = null;
         var _loc4_:* = null;
         var _loc13_:* = null;
         var _loc9_:int = 0;
         var _loc21_:* = null;
         var _loc14_:int = 0;
         var _loc5_:* = null;
         var _loc3_:* = null;
         var _loc15_:int = 0;
         var _loc10_:int = 0;
         var _loc16_:Boolean = false;
         var _loc6_:* = null;
         var _loc19_:int = 0;
         collection = new ListCollection();
         super(1);
         this.info = param1;
         this.firstTab = param2;
         dataMap = {};
         _loc11_ = 0;
         while(_loc11_ < TAB_NUM)
         {
            dataMap[_loc11_] = [];
            _loc11_++;
         }
         if(param1.topRecords != null)
         {
            var _loc23_:* = UserDataWrapper;
            _loc22_ = gudetama.data.UserDataWrapper.wrapper._data.encodedUid;
            _loc12_ = -2147483648;
            _loc7_ = param1.topRecords;
            _loc11_ = 0;
            while(_loc11_ < _loc7_.length)
            {
               _loc17_ = _loc7_[_loc11_];
               if(_loc12_ != _loc17_.point)
               {
                  _loc12_ = _loc17_.point;
                  _loc18_ = _loc11_ + 1;
               }
               dataMap[TAB_RANKING].push(new RecordInfo(_loc18_,_loc17_));
               if(rankingIdx == -1 && _loc22_ == _loc17_.encodeUid)
               {
                  rankingIdx = _loc11_;
               }
               _loc11_++;
            }
         }
         var _loc8_:RankingRewardDef;
         if((_loc8_ = GameSetting.def.rankingRewardMap[param1.content.rewardId]).rankingRewards != null)
         {
            _loc20_ = _loc8_.rankingRewards;
            _loc4_ = {};
            _loc11_ = 0;
            while(_loc11_ < _loc20_.length)
            {
               _loc13_ = _loc20_[_loc11_];
               _loc4_[_loc13_.argi] = _loc13_.screeningItems;
               _loc11_++;
            }
            if(param1.isEmptyTopRecords())
            {
               rankRewardIdx = 0;
            }
            _loc9_ = param1.rank;
            _loc21_ = _loc8_.rewardIdTable;
            _loc5_ = GameSetting.getUIText("common.unit.rank");
            _loc3_ = GameSetting.getUIText("common.unit.rank.range");
            _loc15_ = _loc21_.indexes.length;
            _loc10_ = 0;
            _loc11_ = 0;
            for(; _loc11_ < _loc15_; _loc11_++)
            {
               _loc18_ = _loc21_.indexes[_loc11_];
               _loc14_ = _loc21_.values[_loc11_];
               if(_loc11_ + 1 < _loc15_)
               {
                  if(_loc14_ == _loc21_.values[_loc11_ + 1])
                  {
                     _loc19_ = _loc21_.indexes[_loc11_ + 1];
                     _loc16_ = rankRewardIdx == -1 && _loc18_ <= _loc9_ && _loc9_ <= _loc19_;
                     _loc6_ = StringUtil.format(_loc3_,StringUtil.getNumStringCommas(_loc18_),StringUtil.getNumStringCommas(_loc19_));
                     createRankRewardInfo(_loc10_++,_loc6_,_loc4_[_loc14_],_loc16_);
                     _loc11_++;
                     continue;
                  }
               }
               _loc16_ = rankRewardIdx == -1 && _loc18_ == _loc9_;
               _loc6_ = StringUtil.format(_loc5_,StringUtil.getNumStringCommas(_loc18_));
               createRankRewardInfo(_loc10_++,_loc6_,_loc4_[_loc14_],_loc16_);
            }
         }
      }
      
      public static function show(param1:RankingInfoWrapper, param2:int = 0) : void
      {
         Engine.pushScene(new RankingRecordDialog(param1,param2),0,false);
      }
      
      private function createRankRewardInfo(param1:int, param2:String, param3:Array, param4:Boolean) : void
      {
         var _loc5_:int = 0;
         dataMap[TAB_REWARD].push(new RankInfo(param1,param2));
         if(param4)
         {
            rankRewardIdx = dataMap[TAB_REWARD].length;
         }
         _loc5_ = 0;
         while(_loc5_ < param3.length)
         {
            dataMap[TAB_REWARD].push(param3[_loc5_]);
            _loc5_++;
         }
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"RankingRecordDialog",function(param1:Object):void
         {
            var _loc5_:int = 0;
            var _loc2_:* = null;
            displaySprite = param1.object;
            var _loc3_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            var _loc4_:ColorTextField;
            (_loc4_ = _loc3_.getChildByName("title") as ColorTextField).text#2 = StringUtil.format(GameSetting.getUIText("ranking.rank.reward"),UserDataWrapper.eventPart.getRankingPointText());
            var _loc6_:ColorTextField;
            (_loc6_ = _loc3_.getChildByName("rank") as ColorTextField).text#2 = info.getMyRankText();
            var _loc7_:ColorTextField;
            (_loc7_ = _loc3_.getChildByName("point") as ColorTextField).text#2 = StringUtil.getNumStringCommas(info.myPoint);
            tabs = new Vector.<Tab>();
            _loc5_ = 0;
            while(_loc5_ < TAB_NUM)
            {
               _loc2_ = _loc3_.getChildByName("btnTab" + _loc5_) as ContainerButton;
               tabs.push(new Tab(_loc2_,_loc5_,triggeredTabCallback));
               _loc5_++;
            }
            notEnoughText = _loc3_.getChildByName("notEnough") as ColorTextField;
            imgTabBtm = _loc3_.getChildByName("imgTabBtm") as Image;
            imgListBG = _loc3_.getChildByName("imgListBG") as Image;
            list = _loc3_.getChildByName("list") as List;
            btnClose = _loc3_.getChildByName("btnClose") as ContainerButton;
            btnClose.addEventListener("triggered",triggeredClose);
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         setupLayoutForTask(queue,"_SingleRankingRecordItem",function(param1:Object):void
         {
            recordExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         setupLayoutForTask(queue,"_SingleRankingRankRibbonItem",function(param1:Object):void
         {
            rankRibbonExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         setupLayoutForTask(queue,"_SingleRankingRankRewardItem",function(param1:Object):void
         {
            rankRewardExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            setup();
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
         var layout:FlowLayout = new FlowLayout();
         layout.verticalAlign = "top";
         layout.horizontalAlign = "left";
         layout.paddingTop = 5;
         layout.paddingBottom = 5;
         layout.gap = 10;
         list.layout = layout;
         list.factoryIDFunction = function(param1:Object):String
         {
            if(param1 is RecordInfo)
            {
               return "record";
            }
            if(param1 is RankInfo)
            {
               return "rank";
            }
            if(param1 is ItemParam)
            {
               return "rankReward";
            }
         };
         list.setItemRendererFactoryWithID("record",function():IListItemRenderer
         {
            return new RecordItemRenderer(recordExtractor,info.rankingId);
         });
         list.setItemRendererFactoryWithID("rank",function():IListItemRenderer
         {
            return new RankRibbonItemRenderer(rankRibbonExtractor,info.rankingId);
         });
         list.setItemRendererFactoryWithID("rankReward",function():IListItemRenderer
         {
            return new RankRewardItemRenderer(rankRewardExtractor,info.rankingId);
         });
         list.selectedIndex = -1;
         list.dataProvider = collection;
         list.verticalScrollBarFactory = function():IScrollBar
         {
            var _loc1_:ScrollBar = new ScrollBar();
            _loc1_.trackLayoutMode = "single";
            return _loc1_;
         };
         list.scrollBarDisplayMode = "fixedFloat";
         list.horizontalScrollPolicy = "off";
         list.verticalScrollPolicy = "auto";
         list.interactionMode = "touchAndScrollBars";
         var dialogSprite:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("event" + (info.rankingId - 1) + "@title04",function(param1:Texture):void
            {
               var _loc2_:Image = dialogSprite.getChildByName("title04") as Image;
               _loc2_.texture = param1;
               queue.taskDone();
            });
         });
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
            TextureCollector.loadTexture("event" + (info.rankingId - 1) + "@p",function(param1:Texture):void
            {
               var _loc2_:Image = spPts.getChildByName("p") as Image;
               _loc2_.texture = param1;
               queue.taskDone();
            });
         });
         for each(tab in tabs)
         {
            tab.loadButtonTexture(queue,info.rankingId);
         }
         var rDef:RankingDef = GameSetting.def.rankingMap[info.rankingId];
         tabs[0].setButtonColor(rDef.topRecordMatColor);
         tabs[1].setButtonColor(rDef.rankingRewardMatColor);
         var pointText:ColorTextField = dialogSprite.getChildByName("point") as ColorTextField;
         pointText.color = rDef.pointTextColor;
         var titleText:ColorTextField = dialogSprite.getChildByName("title") as ColorTextField;
         titleText.color = rDef.rankingTitleTextColor;
      }
      
      private function setup() : void
      {
         triggeredTabCallback(firstTab);
      }
      
      public function triggeredTabCallback(param1:int) : void
      {
         var _loc7_:int = 0;
         var _loc2_:int = 0;
         var _loc6_:int = 0;
         if(tabType == param1)
         {
            return;
         }
         var _loc5_:RankingDef = GameSetting.def.rankingMap[info.rankingId];
         tabType = param1;
         if(param1 == 0)
         {
            _loc7_ = _loc5_.topRecordMatColor;
            _loc2_ = _loc5_.topRecordBgMatColor;
         }
         else
         {
            _loc7_ = _loc5_.rankingRewardMatColor;
            _loc2_ = _loc5_.rankingRewardBgMatColor;
         }
         imgTabBtm.color = _loc7_;
         imgListBG.color = _loc2_;
         var _loc4_:Array = dataMap[param1];
         var _loc3_:FlowLayout = list.layout as FlowLayout;
         if(param1 == TAB_RANKING)
         {
            notEnoughText.visible = _loc4_.length == 0;
            _loc3_.paddingTop = 5;
            _loc3_.paddingLeft = 30;
            _loc3_.paddingBottom = 5;
         }
         else
         {
            notEnoughText.visible = false;
            _loc3_.paddingLeft = 5;
            if(tabType == TAB_REWARD)
            {
               _loc3_.paddingTop = 5;
            }
            else
            {
               _loc3_.paddingTop = 5;
            }
         }
         collection.removeAll();
         _loc6_ = 0;
         while(_loc6_ < _loc4_.length)
         {
            collection.addItem(_loc4_[_loc6_]);
            _loc6_++;
         }
         if(param1 == TAB_RANKING && rankingIdx > -1)
         {
            list.scrollToDisplayIndex(rankingIdx);
         }
         else if(param1 == TAB_REWARD && rankRewardIdx > -1)
         {
            list.scrollToDisplayIndex(rankRewardIdx);
         }
         else
         {
            list.scrollToDisplayIndex(0);
         }
      }
      
      override protected function addedToContainer() : void
      {
         var _loc1_:RankingDef = GameSetting.def.rankingMap[info.rankingId];
         Engine.lockTouchInput(RankingRecordDialog);
         setBackButtonCallback(backButtonCallback);
         if(_loc1_.groupType == 1)
         {
            setVisibleState(30);
         }
         else
         {
            setVisibleState(28);
         }
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(RankingRecordDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(RankingRecordDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(RankingRecordDialog);
            Engine.popScene(scene);
         });
      }
      
      private function triggeredClose(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         if(tabs)
         {
            for each(var _loc1_ in tabs)
            {
               _loc1_.dispose();
            }
            tabs = null;
         }
         notEnoughText = null;
         list = null;
         btnClose.removeEventListener("triggered",triggeredClose);
         btnClose = null;
         recordExtractor = null;
         rankRewardExtractor = null;
         collection = null;
         super.dispose();
      }
   }
}

import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import muku.core.TaskQueue;
import muku.display.ContainerButton;
import starling.display.Sprite;
import starling.textures.Texture;

class Tab extends UIBase
{
    
   
   private var type:int;
   
   private var callback:Function;
   
   function Tab(param1:Sprite, param2:int, param3:Function)
   {
      super(param1);
      this.type = param2;
      this.callback = param3;
      param1.addEventListener("triggered",triggered);
      (param1 as ContainerButton).setTweenDisable();
   }
   
   public function loadButtonTexture(param1:TaskQueue, param2:int) : void
   {
      var queue:TaskQueue = param1;
      var rankingId:int = param2;
      queue.addTask(function():void
      {
         TextureCollector.loadTexture("event" + (rankingId - 1) + "@btn01",function(param1:Texture):void
         {
            (displaySprite as ContainerButton).background = param1;
            queue.taskDone();
         });
      });
   }
   
   public function setButtonColor(param1:int) : void
   {
      (displaySprite as ContainerButton).color = param1;
   }
   
   private function triggered() : void
   {
      if(callback)
      {
         callback(type);
      }
   }
   
   public function dispose() : void
   {
      if(displaySprite)
      {
         displaySprite.removeEventListener("triggered",triggered);
      }
      callback = null;
   }
}

import gudetama.data.compati.RankingRecord;

class RecordInfo
{
    
   
   public var rank:int;
   
   public var record:RankingRecord;
   
   function RecordInfo(param1:int, param2:RankingRecord)
   {
      super();
      this.rank = param1;
      this.record = param2;
   }
}

class RankInfo
{
    
   
   public var index:int;
   
   public var title:String;
   
   function RankInfo(param1:int, param2:String)
   {
      super();
      this.index = param1;
      this.title = param2;
   }
}

import gudetama.ui.ListItemRendererBase;
import gudetama.util.SpriteExtractor;

class RecordItemRenderer extends ListItemRendererBase
{
    
   
   private var rankingId:int;
   
   private var itemUI:RecordItemUI;
   
   function RecordItemRenderer(param1:SpriteExtractor, param2:int)
   {
      super(param1,null);
      this.rankingId = param2;
   }
   
   override protected function createItemUI() : void
   {
      itemUI = new RecordItemUI(displaySprite,rankingId);
   }
   
   override protected function commitData() : void
   {
      itemUI.updateData(data#2);
   }
   
   override protected function disposeItemUI() : void
   {
      if(itemUI)
      {
         itemUI.dispose();
         itemUI = null;
      }
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.DataStorage;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.AvatarDef;
import gudetama.data.compati.RankingDef;
import gudetama.data.compati.RankingRecord;
import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

class RecordItemUI extends UIBase
{
    
   
   private var rankingId:int;
   
   private var ribbonImage:Image;
   
   private var rankText:ColorTextField;
   
   private var iconImage:Image;
   
   private var snsImage:Image;
   
   private var nameText:ColorTextField;
   
   private var pointText:ColorTextField;
   
   private var info:RecordInfo;
   
   private var loadAvatarUid:int;
   
   private var loadSnsAvatarUid:int;
   
   private var loadSnsIconUid:int;
   
   function RecordItemUI(param1:Sprite, param2:int)
   {
      var displaySprite:Sprite = param1;
      var rankingId:int = param2;
      super(displaySprite);
      this.rankingId = rankingId;
      ribbonImage = displaySprite.getChildByName("ribbon") as Image;
      rankText = displaySprite.getChildByName("rank") as ColorTextField;
      iconImage = displaySprite.getChildByName("icon") as Image;
      snsImage = displaySprite.getChildByName("imgSns") as Image;
      nameText = displaySprite.getChildByName("name") as ColorTextField;
      pointText = displaySprite.getChildByName("point") as ColorTextField;
      var mat_white:Image = displaySprite.getChildByName("mat_white") as Image;
      TextureCollector.loadTexture("event" + (rankingId - 1) + "@mat_white",function(param1:Texture):void
      {
         mat_white.texture = param1;
      });
      TextureCollector.loadTexture("event" + (rankingId - 1) + "@ribbon04",function(param1:Texture):void
      {
         var _loc2_:Image = displaySprite.getChildByName("ribbon04") as Image;
         _loc2_.texture = param1;
      });
      TextureCollector.loadTexture("event" + (rankingId - 1) + "@mat_name",function(param1:Texture):void
      {
         var _loc2_:Image = displaySprite.getChildByName("mat_name") as Image;
         _loc2_.texture = param1;
      });
      TextureCollector.loadTexture("event" + (rankingId - 1) + "@mat_ranking",function(param1:Texture):void
      {
         var _loc2_:Image = displaySprite.getChildByName("mat_ranking") as Image;
         _loc2_.texture = param1;
      });
      TextureCollector.loadTexture("event" + (rankingId - 1) + "@p",function(param1:Texture):void
      {
         var _loc2_:Image = displaySprite.getChildByName("p") as Image;
         _loc2_.texture = param1;
      });
      var rDef:RankingDef = GameSetting.def.rankingMap[rankingId];
      mat_white.color = rDef.recordMatColor;
      pointText.color = rDef.pointTextColor;
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      if(!data)
      {
         return;
      }
      info = data as RecordInfo;
      loadAvatarUid = 0;
      loadSnsAvatarUid = 0;
      loadSnsIconUid = 0;
      var rank:int = info.rank;
      rankText.text#2 = StringUtil.format(GameSetting.getUIText("common.unit.rank"),StringUtil.getNumStringCommas(rank));
      if(rank <= 3)
      {
         ribbonImage.visible = false;
         TextureCollector.loadTexture("event" + (rankingId - 1) + "@ribbon0" + rank,function(param1:Texture):void
         {
            if(ribbonImage)
            {
               ribbonImage.texture = param1;
               ribbonImage.visible = true;
            }
         });
         startTween("top");
         finishTween();
      }
      else
      {
         ribbonImage.visible = false;
         startTween("normal");
         finishTween();
      }
      var record:RankingRecord = info.record;
      nameText.text#2 = record.playerName;
      pointText.text#2 = StringUtil.getNumStringCommas(record.point);
      iconImage.visible = false;
      snsImage.visible = false;
      var _loc3_:* = UserDataWrapper;
      if(record.encodeUid == gudetama.data.UserDataWrapper.wrapper._data.encodedUid)
      {
         if(UserDataWrapper.wrapper.isExtraAvatar())
         {
            var snsType:int = UserDataWrapper.wrapper.getCurrentExtraAvatar();
            iconImage.texture = DataStorage.getLocalData().getSnsImageTexture(snsType);
            iconImage.visible = iconImage.texture != null;
            loadSnsImage(snsType);
         }
         else
         {
            loadNormalAvatarImage(UserDataWrapper.wrapper.getCurrentAvatar());
         }
      }
      else if(record.snsProfileImage != null)
      {
         loadSnsAvatarUid = info.record.encodeUid;
         GudetamaUtil.loadByteArray2Texture(record.snsProfileImage,function(param1:Texture):void
         {
            if(iconImage == null)
            {
               return;
            }
            if(loadSnsAvatarUid != info.record.encodeUid)
            {
               return;
            }
            iconImage.texture = param1;
            iconImage.visible = true;
         });
         loadSnsImage(record.snsType);
      }
      else
      {
         loadNormalAvatarImage(record.avatar);
      }
   }
   
   private function loadSnsImage(param1:int) : void
   {
      var snsType:int = param1;
      loadSnsIconUid = info.record.encodeUid;
      TextureCollector.loadSnsImage(snsType,null,function(param1:Texture):void
      {
         if(snsImage == null || param1 == null)
         {
            return;
         }
         if(loadSnsIconUid != info.record.encodeUid)
         {
            return;
         }
         snsImage.texture = param1;
         snsImage.visible = true;
      });
   }
   
   private function loadNormalAvatarImage(param1:int) : void
   {
      var avatar:int = param1;
      var aDef:AvatarDef = GameSetting.getAvatar(avatar);
      if(aDef == null)
      {
         return;
      }
      loadAvatarUid = info.record.encodeUid;
      TextureCollector.loadTextureRsrc("avatar-" + aDef.rsrc,function(param1:Texture):void
      {
         if(iconImage == null)
         {
            return;
         }
         if(loadAvatarUid != info.record.encodeUid)
         {
            return;
         }
         iconImage.texture = param1;
         iconImage.visible = true;
      });
   }
   
   public function dispose() : void
   {
      iconImage = null;
      snsImage = null;
      nameText = null;
      pointText = null;
   }
}

import gudetama.ui.ListItemRendererBase;
import gudetama.util.SpriteExtractor;

class RankRibbonItemRenderer extends ListItemRendererBase
{
    
   
   private var rankingId:int;
   
   private var itemUI:RankRibbonItemUI;
   
   function RankRibbonItemRenderer(param1:SpriteExtractor, param2:int)
   {
      super(param1,null);
      this.rankingId = param2;
   }
   
   override protected function commitData() : void
   {
      itemUI.updateData(data#2);
   }
   
   override protected function createItemUI() : void
   {
      itemUI = new RankRibbonItemUI(displaySprite,rankingId);
   }
   
   override protected function disposeItemUI() : void
   {
      itemUI.dispose();
      itemUI = null;
   }
}

import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

class RankRibbonItemUI extends UIBase
{
    
   
   private var rankingId:int;
   
   private var ribbonImage:Image;
   
   private var rankText:ColorTextField;
   
   function RankRibbonItemUI(param1:Sprite, param2:int)
   {
      var displaySprite:Sprite = param1;
      var rankingId:int = param2;
      super(displaySprite);
      this.rankingId = rankingId;
      ribbonImage = displaySprite.getChildByName("ribbon") as Image;
      rankText = displaySprite.getChildByName("rank") as ColorTextField;
      TextureCollector.loadTexture("event" + (rankingId - 1) + "@ribbon04",function(param1:Texture):void
      {
         var _loc2_:Image = displaySprite.getChildByName("ribbon04") as Image;
         _loc2_.texture = param1;
      });
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      if(!data)
      {
         return;
      }
      var info:RankInfo = data as RankInfo;
      rankText.text#2 = info.title;
      if(info.index < 3)
      {
         ribbonImage.visible = false;
         TextureCollector.loadTexture("event" + (rankingId - 1) + "@ribbon0" + (info.index + 1),function(param1:Texture):void
         {
            if(ribbonImage == null)
            {
               return;
            }
            ribbonImage.texture = param1;
            ribbonImage.visible = true;
         });
         startTween("top");
      }
      else
      {
         startTween("normal");
      }
      finishTween();
   }
   
   public function dispose() : void
   {
      rankText = null;
   }
}

import gudetama.ui.ListItemRendererBase;
import gudetama.util.SpriteExtractor;

class RankRewardItemRenderer extends ListItemRendererBase
{
    
   
   private var itemUI:RankRewardItemUI;
   
   private var rankingId:int;
   
   function RankRewardItemRenderer(param1:SpriteExtractor, param2:int)
   {
      super(param1,null);
      this.rankingId = param2;
   }
   
   override protected function commitData() : void
   {
      itemUI.updateData(data#2);
   }
   
   override protected function createItemUI() : void
   {
      itemUI = new RankRewardItemUI(displaySprite,rankingId);
   }
   
   override protected function disposeItemUI() : void
   {
      itemUI.dispose();
      itemUI = null;
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.compati.ItemParam;
import gudetama.data.compati.RankingDef;
import gudetama.engine.TextureCollector;
import gudetama.ui.ItemDetailDialog;
import gudetama.ui.UIBase;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

class RankRewardItemUI extends UIBase
{
    
   
   private var icon:Image;
   
   private var lblName:ColorTextField;
   
   private var btnDetail:ContainerButton;
   
   private var item:ItemParam;
   
   function RankRewardItemUI(param1:Sprite, param2:int)
   {
      var displaySprite:Sprite = param1;
      var rankingId:int = param2;
      super(displaySprite);
      btnDetail = displaySprite.getChildByName("btnDetail") as ContainerButton;
      btnDetail.addEventListener("triggered",triggered);
      btnDetail.visible = false;
      lblName = displaySprite.getChildByName("lblName") as ColorTextField;
      icon = displaySprite.getChildByName("icon") as Image;
      var line_white:Image = displaySprite.getChildByName("line_white") as Image;
      TextureCollector.loadTexture("event" + (rankingId - 1) + "@line_white",function(param1:Texture):void
      {
         line_white.texture = param1;
      });
      TextureCollector.loadTexture("event" + (rankingId - 1) + "@btn_play",function(param1:Texture):void
      {
         btnDetail.background = param1;
      });
      var rDef:RankingDef = GameSetting.def.rankingMap[rankingId];
      line_white.color = rDef.rankingRewardLineColor;
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      if(!data)
      {
         return;
      }
      item = data as ItemParam;
      if(item.kind == 9 || item.kind == 17)
      {
         startTween("detail");
      }
      else
      {
         startTween("normal");
      }
      lblName.text#2 = GudetamaUtil.getItemParamNameAndNum(item);
      var imageName:String = GudetamaUtil.getItemIconName(item.kind,item.id#2);
      icon.visible = false;
      TextureCollector.loadTexture(imageName,function(param1:Texture):void
      {
         if(icon == null)
         {
            return;
         }
         icon.texture = param1;
         icon.visible = true;
      });
   }
   
   private function triggered() : void
   {
      ItemDetailDialog.show(item,GameSetting.getUIText("%common.detail"));
   }
   
   public function dispose() : void
   {
      lblName = null;
      if(btnDetail)
      {
         btnDetail.removeEventListener("triggered",triggered);
         btnDetail = null;
      }
   }
}
