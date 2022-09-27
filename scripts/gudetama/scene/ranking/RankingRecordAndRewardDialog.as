package gudetama.scene.ranking
{
   import feathers.controls.IScrollBar;
   import feathers.controls.List;
   import feathers.controls.ScrollBar;
   import feathers.controls.renderers.IListItemRenderer;
   import feathers.data.ListCollection;
   import feathers.layout.VerticalLayout;
   import gudetama.common.GudetamaUtil;
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
   
   public class RankingRecordAndRewardDialog extends BaseScene
   {
      
      public static var TAB_RANKING:int = 0;
      
      public static var TAB_RANK_REWARD:int = 1;
      
      public static var TAB_PTS_REWARD:int = 2;
       
      
      private var info:RankingInfoWrapper;
      
      private var tabType:int = -1;
      
      private var firstTab:int;
      
      private var tabs:Array;
      
      private var imgTabBtm:Image;
      
      private var imgListBG:Image;
      
      private var dataMap:Object;
      
      private var lblNoRecord:ColorTextField;
      
      private var list:List;
      
      private var collection:ListCollection;
      
      private var btnClose:ContainerButton;
      
      private var recordExtractor:SpriteExtractor;
      
      private var rankRibbonExtractor:SpriteExtractor;
      
      private var rankRewardExtractor:SpriteExtractor;
      
      private var ptsRewardExtractor:SpriteExtractor;
      
      private var rankingIdx:int = -1;
      
      private var rankRewardIdx:int = -1;
      
      private var ptsRewardIdx:int = -1;
      
      private var loadCount:int;
      
      public function RankingRecordAndRewardDialog(param1:RankingInfoWrapper, param2:int)
      {
         var _loc11_:int = 0;
         var _loc18_:int = 0;
         var _loc12_:int = 0;
         var _loc23_:int = 0;
         var _loc7_:* = null;
         var _loc17_:* = null;
         var _loc21_:* = null;
         var _loc4_:* = null;
         var _loc13_:* = null;
         var _loc9_:int = 0;
         var _loc22_:* = null;
         var _loc14_:int = 0;
         var _loc5_:* = null;
         var _loc3_:* = null;
         var _loc15_:int = 0;
         var _loc10_:int = 0;
         var _loc16_:Boolean = false;
         var _loc6_:* = null;
         var _loc20_:int = 0;
         var _loc19_:int = 0;
         var _loc24_:* = false;
         collection = new ListCollection();
         super(1);
         this.info = param1;
         this.firstTab = param2;
         dataMap = {};
         _loc11_ = 0;
         while(_loc11_ < 3)
         {
            dataMap[_loc11_] = [];
            _loc11_++;
         }
         if(param1.topRecords != null)
         {
            var _loc25_:* = UserDataWrapper;
            _loc23_ = gudetama.data.UserDataWrapper.wrapper._data.encodedUid;
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
               dataMap[0].push(new RecordInfo(_loc18_,_loc17_));
               if(rankingIdx == -1 && _loc23_ == _loc17_.encodeUid)
               {
                  rankingIdx = _loc11_;
               }
               _loc11_++;
            }
         }
         var _loc8_:RankingRewardDef;
         if((_loc8_ = GameSetting.def.rankingRewardMap[param1.content.rewardId]).rankingRewards != null)
         {
            _loc21_ = _loc8_.rankingRewards;
            _loc4_ = {};
            _loc11_ = 0;
            while(_loc11_ < _loc21_.length)
            {
               _loc13_ = _loc21_[_loc11_];
               _loc4_[_loc13_.argi] = _loc13_.screeningItems;
               _loc11_++;
            }
            if(param1.isEmptyTopRecords())
            {
               rankRewardIdx = 0;
            }
            _loc9_ = param1.rank;
            _loc22_ = _loc8_.rewardIdTable;
            _loc5_ = GameSetting.getUIText("common.unit.rank");
            _loc3_ = GameSetting.getUIText("common.unit.rank.range");
            _loc15_ = _loc22_.indexes.length;
            _loc10_ = 0;
            _loc11_ = 0;
            for(; _loc11_ < _loc15_; _loc11_++)
            {
               _loc18_ = _loc22_.indexes[_loc11_];
               _loc14_ = _loc22_.values[_loc11_];
               if(_loc11_ + 1 < _loc15_)
               {
                  if(_loc14_ == _loc22_.values[_loc11_ + 1])
                  {
                     _loc20_ = _loc22_.indexes[_loc11_ + 1];
                     _loc16_ = rankRewardIdx == -1 && _loc18_ <= _loc9_ && _loc9_ <= _loc20_;
                     _loc6_ = _loc3_.replace("%1",StringUtil.getNumStringCommas(_loc18_)).replace("%2",StringUtil.getNumStringCommas(_loc20_));
                     createRankRewardInfo(_loc10_++,_loc6_,_loc4_[_loc14_],_loc16_);
                     _loc11_++;
                     continue;
                  }
               }
               _loc16_ = rankRewardIdx == -1 && _loc18_ == _loc9_;
               _loc6_ = _loc5_.replace("%1",StringUtil.getNumStringCommas(_loc18_));
               createRankRewardInfo(_loc10_++,_loc6_,_loc4_[_loc14_],_loc16_);
            }
         }
         if(_loc8_.pointRewards != null)
         {
            _loc19_ = param1.myPoint;
            _loc11_ = 0;
            while(_loc11_ < _loc8_.pointRewards.length)
            {
               _loc12_ = (_loc13_ = _loc8_.pointRewards[_loc11_]).argi;
               _loc6_ = StringUtil.getNumStringCommas(_loc12_);
               _loc24_ = _loc19_ >= _loc12_;
               dataMap[2].push(new PtsRewardInfo(_loc6_,_loc13_.screeningItems,_loc24_));
               if(!_loc24_ && ptsRewardIdx == -1)
               {
                  ptsRewardIdx = _loc11_;
               }
               _loc11_++;
            }
            if(ptsRewardIdx == -1)
            {
               ptsRewardIdx = _loc8_.pointRewards.length - 1;
            }
         }
      }
      
      public static function show(param1:RankingInfoWrapper, param2:int = 0) : void
      {
         Engine.pushScene(new RankingRecordAndRewardDialog(param1,param2),0,false);
      }
      
      private function createRankRewardInfo(param1:int, param2:String, param3:Array, param4:Boolean) : void
      {
         var _loc5_:int = 0;
         dataMap[1].push(new RankInfo(param1,param2));
         if(param4)
         {
            rankRewardIdx = dataMap[1].length;
         }
         _loc5_ = 0;
         while(_loc5_ < param3.length)
         {
            dataMap[1].push(param3[_loc5_]);
            _loc5_++;
         }
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"RankingRecordAndRewardDialog",function(param1:Object):void
         {
            var _loc2_:int = 0;
            var _loc8_:int = 0;
            var _loc13_:* = null;
            displaySprite = param1.object;
            var _loc5_:Sprite;
            var _loc3_:ColorTextField = (_loc5_ = displaySprite.getChildByName("dialogSprite") as Sprite).getChildByName("lblRankAndPts") as ColorTextField;
            _loc3_.text#2 = GameSetting.getUIText("ranking.rank.reward").replace("%1",UserDataWrapper.eventPart.getRankingPointText());
            var _loc10_:ColorTextField;
            var _loc6_:Sprite;
            (_loc10_ = (_loc6_ = _loc5_.getChildByName("spRank") as Sprite).getChildByName("lblRank") as ColorTextField).text#2 = info.getMyRankText();
            var _loc12_:ColorTextField;
            var _loc11_:Sprite;
            (_loc12_ = (_loc11_ = _loc5_.getChildByName("spPts") as Sprite).getChildByName("lblPts") as ColorTextField).text#2 = StringUtil.getNumStringCommas(info.myPoint);
            var _loc9_:Sprite;
            var _loc4_:ColorTextField = (_loc9_ = _loc5_.getChildByName("spTeam") as Sprite).getChildByName("lblTeam") as ColorTextField;
            var _loc7_:RankingDef;
            if((_loc7_ = GameSetting.def.rankingMap[info.rankingId]).groupType == 1)
            {
               var _loc14_:* = UserDataWrapper;
               _loc2_ = gudetama.data.UserDataWrapper.wrapper._data.area;
               _loc4_.text#2 = GameSetting.getUIText("%ranking.join.team") + ":" + GameSetting.getUIText("profile.area." + _loc2_);
            }
            else
            {
               _loc9_.visible = false;
            }
            tabs = [];
            _loc8_ = 0;
            while(_loc8_ < 3)
            {
               _loc13_ = _loc5_.getChildByName("btnTab" + _loc8_) as ContainerButton;
               tabs.push(new Tab(_loc8_,_loc13_,changeTabType));
               _loc8_++;
            }
            imgTabBtm = _loc5_.getChildByName("imgTabBtm") as Image;
            lblNoRecord = _loc5_.getChildByName("lblNoRecord") as ColorTextField;
            imgListBG = _loc5_.getChildByName("imgListBG") as Image;
            list = _loc5_.getChildByName("list") as List;
            btnClose = _loc5_.getChildByName("btnClose") as ContainerButton;
            btnClose.addEventListener("triggered",triggeredClose);
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         setupLayoutForTask(queue,"_RankingRecordItem",function(param1:Object):void
         {
            recordExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         setupLayoutForTask(queue,"_RankingRankRibbonItem",function(param1:Object):void
         {
            rankRibbonExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         setupLayoutForTask(queue,"_RankingRankRewardItem",function(param1:Object):void
         {
            rankRewardExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         setupLayoutForTask(queue,"_RankingPtsRewardItem",function(param1:Object):void
         {
            ptsRewardExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         loadIcons();
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
      
      private function loadIcons() : void
      {
         var _loc5_:int = 0;
         var _loc1_:* = null;
         var _loc2_:* = null;
         var _loc3_:* = null;
         var _loc6_:int = 0;
         var _loc4_:RankingRewardDef = GameSetting.def.rankingRewardMap[info.content.rewardId];
         var _loc7_:Object = {};
         if(_loc4_.rankingRewards != null)
         {
            _loc5_ = 0;
            while(_loc5_ < _loc4_.rankingRewards.length)
            {
               _loc1_ = _loc4_.rankingRewards[_loc5_];
               for each(_loc2_ in _loc1_.screeningItems)
               {
                  _loc3_ = GudetamaUtil.getItemIconName(_loc2_.kind,_loc2_.id#2);
                  _loc7_[_loc3_] = _loc2_;
               }
               _loc5_++;
            }
         }
         if(_loc4_.pointRewards)
         {
            _loc6_ = info.myPoint;
            _loc5_ = 0;
            while(_loc5_ < _loc4_.pointRewards.length)
            {
               _loc1_ = _loc4_.pointRewards[_loc5_];
               for each(_loc2_ in _loc1_.screeningItems)
               {
                  _loc3_ = GudetamaUtil.getItemIconName(_loc2_.kind,_loc2_.id#2);
                  _loc7_[_loc3_] = _loc2_;
               }
               _loc5_++;
            }
         }
         for(_loc3_ in _loc7_)
         {
            loadIcon(_loc3_);
         }
      }
      
      private function loadIcon(param1:String) : void
      {
         var name:String = param1;
         loadCount++;
         queue.addTask(function():void
         {
            TextureCollector.loadTexture(name,function(param1:Texture):void
            {
               loadCount--;
               checkInit();
               queue.taskDone();
            });
         });
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
         var layout:VerticalLayout = new VerticalLayout();
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
            if(param1 is PtsRewardInfo)
            {
               return "pts";
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
         list.setItemRendererFactoryWithID("pts",function():IListItemRenderer
         {
            return new PtsRewardItemRenderer(ptsRewardExtractor,info.rankingId);
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
            TextureCollector.loadTexture("event" + (info.rankingId - 1) + "@title03",function(param1:Texture):void
            {
               var _loc2_:Image = dialogSprite.getChildByName("title03") as Image;
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
            TextureCollector.loadTexture("event" + (info.rankingId - 1) + "@item",function(param1:Texture):void
            {
               var _loc2_:Image = spPts.getChildByName("item") as Image;
               _loc2_.texture = param1;
               queue.taskDone();
            });
         });
         var spTeam:Sprite = dialogSprite.getChildByName("spTeam") as Sprite;
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("event" + (info.rankingId - 1) + "@mat_ranking",function(param1:Texture):void
            {
               var _loc2_:Image = spTeam.getChildByName("mat_ranking") as Image;
               _loc2_.texture = param1;
               queue.taskDone();
            });
         });
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("event" + (info.rankingId - 1) + "@flag02",function(param1:Texture):void
            {
               var _loc2_:Image = spTeam.getChildByName("flag02") as Image;
               _loc2_.texture = param1;
               queue.taskDone();
            });
         });
         for each(tab in tabs)
         {
            tab.loadButtonTexture(queue,info.rankingId);
         }
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("event" + (info.rankingId - 1) + "@mat01",function(param1:Texture):void
            {
               imgTabBtm.texture = param1;
               queue.taskDone();
            });
         });
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("event" + (info.rankingId - 1) + "@mat02",function(param1:Texture):void
            {
               imgListBG.texture = param1;
               queue.taskDone();
            });
         });
         var rDef:RankingDef = GameSetting.def.rankingMap[info.rankingId];
         tabs[0].setButtonColor(rDef.topRecordMatColor);
         tabs[1].setButtonColor(rDef.rankingRewardMatColor);
         tabs[2].setButtonColor(rDef.pointRewardMatColor);
         var lblPts:ColorTextField = spPts.getChildByName("lblPts") as ColorTextField;
         lblPts.color = rDef.pointTextColor;
      }
      
      private function setup() : void
      {
         changeTabType(firstTab);
      }
      
      public function changeTabType(param1:int) : void
      {
         var _loc7_:int = 0;
         var _loc2_:int = 0;
         var _loc6_:int = 0;
         if(tabType == param1)
         {
            return;
         }
         if(tabType != -1)
         {
            Tab(tabs[tabType]).select(false);
         }
         var _loc5_:RankingDef = GameSetting.def.rankingMap[info.rankingId];
         tabType = param1;
         Tab(tabs[tabType]).select(true);
         if(param1 == 0)
         {
            _loc7_ = _loc5_.topRecordMatColor;
            _loc2_ = _loc5_.topRecordBgMatColor;
         }
         else if(param1 == 1)
         {
            _loc7_ = _loc5_.rankingRewardMatColor;
            _loc2_ = _loc5_.rankingRewardBgMatColor;
         }
         else
         {
            _loc7_ = _loc5_.pointRewardMatColor;
            _loc2_ = _loc5_.pointRewardBgMatColor;
         }
         imgTabBtm.color = _loc7_;
         imgListBG.color = _loc2_;
         var _loc4_:Array = dataMap[param1];
         var _loc3_:VerticalLayout = list.layout as VerticalLayout;
         if(param1 == TAB_RANKING)
         {
            lblNoRecord.visible = _loc4_.length == 0;
            _loc3_.paddingTop = 5;
            _loc3_.paddingLeft = 30;
         }
         else
         {
            lblNoRecord.visible = false;
            _loc3_.paddingLeft = 5;
            if(tabType == TAB_RANK_REWARD)
            {
               _loc3_.paddingTop = -47;
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
         else if(param1 == TAB_PTS_REWARD && ptsRewardIdx > -1)
         {
            list.scrollToDisplayIndex(ptsRewardIdx);
         }
         else if(param1 == TAB_RANK_REWARD && rankRewardIdx > -1)
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
         Engine.lockTouchInput(RankingRecordAndRewardDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(30);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(RankingRecordAndRewardDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(RankingRecordAndRewardDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(RankingRecordAndRewardDialog);
            Engine.popScene(scene);
         });
      }
      
      private function triggeredClose(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         lblNoRecord = null;
         list = null;
         btnClose.removeEventListener("triggered",triggeredClose);
         btnClose = null;
         recordExtractor = null;
         rankRewardExtractor = null;
         ptsRewardExtractor = null;
         collection = null;
         super.dispose();
      }
   }
}

import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.engine.TextureCollector;
import muku.core.TaskQueue;
import muku.display.ContainerButton;
import muku.text.ColorTextField;
import starling.textures.Texture;

class Tab
{
    
   
   private var type:int;
   
   private var btn:ContainerButton;
   
   private var lbl:ColorTextField;
   
   private var callback:Function;
   
   function Tab(param1:int, param2:ContainerButton, param3:Function)
   {
      super();
      this.type = param1;
      this.btn = param2;
      param2.addEventListener("triggered",triggered);
      param2.setTweenDisable();
      this.callback = param3;
      lbl = param2.getChildByName("lbl") as ColorTextField;
      if(param1 == 2)
      {
         lbl.text#2 = GameSetting.getUIText("ranking.tab.pts.reward").replace("%1",UserDataWrapper.eventPart.getRankingPointText());
      }
   }
   
   public function loadButtonTexture(param1:TaskQueue, param2:int) : void
   {
      var queue:TaskQueue = param1;
      var rankingId:int = param2;
      queue.addTask(function():void
      {
         TextureCollector.loadTexture("event" + (rankingId - 1) + "@btn01",function(param1:Texture):void
         {
            btn.background = param1;
            queue.taskDone();
         });
      });
   }
   
   public function setButtonColor(param1:int) : void
   {
      btn.color = param1;
   }
   
   public function select(param1:Boolean) : void
   {
      if(param1)
      {
         lbl.color = 6698775;
      }
      else
      {
         lbl.color = 16777215;
      }
   }
   
   private function triggered() : void
   {
      callback(type);
   }
   
   public function dispose() : void
   {
      lbl = null;
      btn.removeEventListener("triggered",triggered);
      btn = null;
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

class PtsRewardInfo
{
    
   
   public var title:String;
   
   public var items:Array;
   
   public var isGot:Boolean;
   
   function PtsRewardInfo(param1:String, param2:Array, param3:Boolean)
   {
      super();
      this.title = param1;
      this.items = param2;
      this.isGot = param3;
   }
}

import gudetama.ui.ListItemRendererBase;
import gudetama.util.SpriteExtractor;

class RecordItemRenderer extends ListItemRendererBase
{
    
   
   private var itemUI:RecordItemUI;
   
   private var rankingId:int;
   
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
      itemUI.dispose();
      itemUI = null;
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
   
   private var imgTop:Image;
   
   private var lblTop:ColorTextField;
   
   private var imgNormal:Image;
   
   private var lblNormal:ColorTextField;
   
   private var icon:Image;
   
   private var imgSns:Image;
   
   private var lblName:ColorTextField;
   
   private var lblPts:ColorTextField;
   
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
      var spRibbon:Sprite = displaySprite.getChildByName("spRibbon") as Sprite;
      imgTop = spRibbon.getChildByName("imgTop") as Image;
      lblTop = spRibbon.getChildByName("lblTop") as ColorTextField;
      imgNormal = spRibbon.getChildByName("imgNormal") as Image;
      lblNormal = spRibbon.getChildByName("lblNormal") as ColorTextField;
      icon = displaySprite.getChildByName("icon") as Image;
      imgSns = displaySprite.getChildByName("imgSns") as Image;
      lblName = displaySprite.getChildByName("lblName") as ColorTextField;
      var spPts:Sprite = displaySprite.getChildByName("spPts") as Sprite;
      lblPts = spPts.getChildByName("lblPts") as ColorTextField;
      var mat03:Image = displaySprite.getChildByName("mat03") as Image;
      TextureCollector.loadTexture("event" + (rankingId - 1) + "@mat03",function(param1:Texture):void
      {
         mat03.texture = param1;
      });
      TextureCollector.loadTexture("event" + (rankingId - 1) + "@ribbon04",function(param1:Texture):void
      {
         imgNormal.texture = param1;
      });
      var mat_name:Image = displaySprite.getChildByName("mat_name") as Image;
      TextureCollector.loadTexture("event" + (rankingId - 1) + "@mat_name",function(param1:Texture):void
      {
         mat_name.texture = param1;
      });
      var mat_ranking:Image = spPts.getChildByName("mat_ranking") as Image;
      TextureCollector.loadTexture("event" + (rankingId - 1) + "@mat_ranking",function(param1:Texture):void
      {
         mat_ranking.texture = param1;
      });
      var item:Image = spPts.getChildByName("item") as Image;
      TextureCollector.loadTexture("event" + (rankingId - 1) + "@item",function(param1:Texture):void
      {
         item.texture = param1;
      });
      var rDef:RankingDef = GameSetting.def.rankingMap[rankingId];
      lblPts.color = rDef.pointTextColor;
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
      var rankText:String = GameSetting.getUIText("common.unit.rank").replace("%1",StringUtil.getNumStringCommas(rank));
      if(rank <= 3)
      {
         imgNormal.visible = false;
         lblNormal.visible = false;
         imgTop.visible = false;
         TextureCollector.loadTexture("event" + (rankingId - 1) + "@ribbon0" + rank,function(param1:Texture):void
         {
            if(imgTop == null)
            {
               return;
            }
            imgTop.texture = param1;
            imgTop.visible = true;
         });
         lblTop.text#2 = rankText;
         lblTop.visible = true;
      }
      else
      {
         imgTop.visible = false;
         lblTop.visible = false;
         imgNormal.visible = true;
         lblNormal.text#2 = rankText;
         lblNormal.visible = true;
      }
      var record:RankingRecord = info.record;
      lblName.text#2 = record.playerName;
      lblPts.text#2 = StringUtil.getNumStringCommas(record.point);
      icon.visible = false;
      imgSns.visible = false;
      var _loc3_:* = UserDataWrapper;
      if(record.encodeUid == gudetama.data.UserDataWrapper.wrapper._data.encodedUid)
      {
         if(UserDataWrapper.wrapper.isExtraAvatar())
         {
            var snsType:int = UserDataWrapper.wrapper.getCurrentExtraAvatar();
            icon.texture = DataStorage.getLocalData().getSnsImageTexture(snsType);
            icon.visible = icon.texture != null;
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
            if(icon == null)
            {
               return;
            }
            if(loadSnsAvatarUid != info.record.encodeUid)
            {
               return;
            }
            icon.texture = param1;
            icon.visible = true;
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
         if(imgSns == null || param1 == null)
         {
            return;
         }
         if(loadSnsIconUid != info.record.encodeUid)
         {
            return;
         }
         imgSns.texture = param1;
         imgSns.visible = true;
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
         if(icon == null)
         {
            return;
         }
         if(loadAvatarUid != info.record.encodeUid)
         {
            return;
         }
         icon.texture = param1;
         icon.visible = true;
      });
   }
   
   public function dispose() : void
   {
      imgTop = null;
      lblTop = null;
      imgNormal = null;
      lblNormal = null;
      icon = null;
      imgSns = null;
      lblName = null;
      lblPts = null;
   }
}

import gudetama.ui.ListItemRendererBase;
import gudetama.util.SpriteExtractor;

class RankRibbonItemRenderer extends ListItemRendererBase
{
    
   
   private var itemUI:RankRibbonItemUI;
   
   private var rankingId:int;
   
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
   
   private var imgTop:Image;
   
   private var lblTop:ColorTextField;
   
   private var imgNormal:Image;
   
   private var lblNormal:ColorTextField;
   
   function RankRibbonItemUI(param1:Sprite, param2:int)
   {
      var displaySprite:Sprite = param1;
      var rankingId:int = param2;
      super(displaySprite);
      this.rankingId = rankingId;
      imgTop = displaySprite.getChildByName("imgTop") as Image;
      lblTop = displaySprite.getChildByName("lblTop") as ColorTextField;
      imgNormal = displaySprite.getChildByName("imgNormal") as Image;
      lblNormal = displaySprite.getChildByName("lblNormal") as ColorTextField;
      TextureCollector.loadTexture("event" + (rankingId - 1) + "@ribbon04",function(param1:Texture):void
      {
         imgNormal.texture = param1;
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
      if(info.index < 3)
      {
         imgNormal.visible = false;
         lblNormal.visible = false;
         imgTop.visible = false;
         TextureCollector.loadTexture("event" + (rankingId - 1) + "@ribbon0" + (info.index + 1),function(param1:Texture):void
         {
            if(imgTop == null)
            {
               return;
            }
            imgTop.texture = param1;
            imgTop.visible = true;
         });
         lblTop.text#2 = info.title;
         lblTop.visible = true;
      }
      else
      {
         imgTop.visible = false;
         lblTop.visible = false;
         imgNormal.visible = true;
         lblNormal.text#2 = info.title;
         lblNormal.visible = true;
      }
   }
   
   public function dispose() : void
   {
      imgTop = null;
      lblTop = null;
      imgNormal = null;
      lblNormal = null;
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
      lblName = displaySprite.getChildByName("lblName") as ColorTextField;
      icon = displaySprite.getChildByName("icon") as Image;
      var line_white:Image = displaySprite.getChildByName("line_white") as Image;
      TextureCollector.loadTexture("event" + (rankingId - 1) + "@line_white",function(param1:Texture):void
      {
         line_white.texture = param1;
         var _loc2_:RankingDef = GameSetting.def.rankingMap[rankingId];
         line_white.color = _loc2_.rankingRewardLineColor;
      });
      TextureCollector.loadTexture("event" + (rankingId - 1) + "@btn_play",function(param1:Texture):void
      {
         btnDetail.background = param1;
      });
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
         btnDetail.visible = true;
         lblName.width = btnDetail.x - lblName.x - 10;
      }
      else
      {
         btnDetail.visible = false;
         lblName.width = btnDetail.x + btnDetail.width - lblName.x;
      }
      lblName.text#2 = GudetamaUtil.getItemParamNameAndNum(item);
      var imageName:String = GudetamaUtil.getItemIconName(item.kind,item.id#2);
      TextureCollector.loadTexture(imageName,function(param1:Texture):void
      {
         if(icon == null)
         {
            return;
         }
         icon.texture = param1;
      });
   }
   
   private function triggered() : void
   {
      ItemDetailDialog.show(item,GameSetting.getUIText("%common.detail"));
   }
   
   public function dispose() : void
   {
      icon = null;
      lblName = null;
      btnDetail.removeEventListener("triggered",triggered);
      btnDetail = null;
   }
}

import gudetama.ui.ListItemRendererBase;
import gudetama.util.SpriteExtractor;

class PtsRewardItemRenderer extends ListItemRendererBase
{
    
   
   private var itemUI:PtsRewardItemUI;
   
   private var rankingId:int;
   
   function PtsRewardItemRenderer(param1:SpriteExtractor, param2:int)
   {
      super(param1,null);
      this.rankingId = param2;
   }
   
   override protected function createItemUI() : void
   {
      itemUI = new PtsRewardItemUI(displaySprite,rankingId);
   }
   
   override protected function commitData() : void
   {
      itemUI.updateData(data#2);
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
import gudetama.ui.UIBase;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

class PtsRewardItemUI extends UIBase
{
    
   
   private var lblPts:ColorTextField;
   
   private var lblName:ColorTextField;
   
   private var icon:Image;
   
   private var imgGet:Image;
   
   function PtsRewardItemUI(param1:Sprite, param2:int)
   {
      var displaySprite:Sprite = param1;
      var rankingId:int = param2;
      super(displaySprite);
      lblPts = displaySprite.getChildByName("lblPts") as ColorTextField;
      lblName = displaySprite.getChildByName("lblName") as ColorTextField;
      icon = displaySprite.getChildByName("icon") as Image;
      imgGet = displaySprite.getChildByName("imgGet") as Image;
      var line_white:Image = displaySprite.getChildByName("line_white") as Image;
      TextureCollector.loadTexture("event" + (rankingId - 1) + "@line_white",function(param1:Texture):void
      {
         line_white.texture = param1;
      });
      var mat_item:Image = displaySprite.getChildByName("mat_item") as Image;
      TextureCollector.loadTexture("event" + (rankingId - 1) + "@mat_item",function(param1:Texture):void
      {
         mat_item.texture = param1;
      });
      var rDef:RankingDef = GameSetting.def.rankingMap[rankingId];
      lblPts.color = rDef.pointTextColor;
      lblName.color = rDef.pointTextColor;
      line_white.color = rDef.pointRewardLineColor;
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      if(!data)
      {
         return;
      }
      var info:PtsRewardInfo = data as PtsRewardInfo;
      lblPts.text#2 = info.title;
      var item:ItemParam = info.items[0];
      lblName.text#2 = GudetamaUtil.getItemParamNameAndNum(item);
      var imageName:String = GudetamaUtil.getItemIconName(item.kind,item.id#2);
      TextureCollector.loadTexture(imageName,function(param1:Texture):void
      {
         if(icon == null)
         {
            return;
         }
         icon.texture = param1;
      });
      imgGet.visible = info.isGot;
   }
   
   public function dispose() : void
   {
      lblPts = null;
      lblName = null;
      icon = null;
      imgGet = null;
   }
}
