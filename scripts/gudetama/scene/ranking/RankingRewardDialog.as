package gudetama.scene.ranking
{
   import feathers.controls.IScrollBar;
   import feathers.controls.List;
   import feathers.controls.ScrollBar;
   import feathers.controls.renderers.IListItemRenderer;
   import feathers.data.ListCollection;
   import feathers.layout.FlowLayout;
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.RankingInfoWrapper;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.ItemParam;
   import gudetama.data.compati.RankingDef;
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
   
   public class RankingRewardDialog extends BaseScene
   {
      
      public static var TAB_LEVEL:int = 0;
      
      public static var TAB_POINT:int = 1;
      
      public static var TAB_NUM:int = 2;
       
      
      private var info:RankingInfoWrapper;
      
      private var firstTab:int;
      
      private var dataMap:Object;
      
      private var tabType:int = -1;
      
      private var tabs:Vector.<Tab>;
      
      private var levelRewardLabel:ColorTextField;
      
      private var list:List;
      
      private var collection:ListCollection;
      
      private var btnClose:ContainerButton;
      
      private var imgTabBtm:Image;
      
      private var imgListBG:Image;
      
      private var rankRibbonExtractor:SpriteExtractor;
      
      private var rankRewardExtractor:SpriteExtractor;
      
      private var ptsRewardExtractor:SpriteExtractor;
      
      private var levelRewardIdx:int = -1;
      
      private var ptsRewardIdx:int = -1;
      
      private var loadCount:int;
      
      public function RankingRewardDialog(param1:RankingInfoWrapper, param2:int)
      {
         var _loc6_:int = 0;
         var _loc9_:* = null;
         var _loc8_:int = 0;
         var _loc11_:* = null;
         var _loc10_:int = 0;
         var _loc4_:int = 0;
         var _loc7_:int = 0;
         var _loc5_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:* = false;
         collection = new ListCollection();
         super(1);
         this.info = param1;
         this.firstTab = param2;
         dataMap = {};
         _loc6_ = 0;
         while(_loc6_ < TAB_NUM)
         {
            dataMap[_loc6_] = [];
            _loc6_++;
         }
         var _loc3_:RankingRewardDef = GameSetting.def.rankingRewardMap[param1.content.rewardId];
         if(_loc3_.globalRewards)
         {
            _loc10_ = param1.totalPoint;
            _loc4_ = 0;
            _loc6_ = _loc3_.globalRewards.length - 1;
            while(_loc6_ >= 0)
            {
               _loc8_ = (_loc9_ = _loc3_.globalRewards[_loc6_]).argi;
               if((_loc7_ = _loc3_.globalRewards.length - 1 - _loc6_) == 0)
               {
                  _loc11_ = StringUtil.format(GameSetting.getUIText("ranking.label.level"),GameSetting.getUIText("ranking.total.point.max"));
               }
               else
               {
                  _loc11_ = StringUtil.format(GameSetting.getUIText("ranking.label.level"),_loc6_ + 2);
               }
               dataMap[TAB_LEVEL].push(new LevelRewardInfo(_loc7_,_loc11_,_loc9_.screeningItems));
               if(_loc8_ > _loc10_)
               {
                  _loc5_ = 1 + _loc9_.screeningItems.length;
                  levelRewardIdx = _loc4_ + Math.min(_loc5_,2);
                  _loc4_ += _loc5_;
               }
               _loc6_--;
            }
            levelRewardIdx = Math.max(0,--levelRewardIdx);
         }
         if(_loc3_.pointRewards)
         {
            _loc12_ = param1.myPoint;
            _loc6_ = 0;
            while(_loc6_ < _loc3_.pointRewards.length)
            {
               _loc8_ = (_loc9_ = _loc3_.pointRewards[_loc6_]).argi;
               _loc11_ = StringUtil.getNumStringCommas(_loc8_);
               _loc13_ = _loc12_ >= _loc8_;
               dataMap[TAB_POINT].push(new PtsRewardInfo(_loc11_,_loc9_.screeningItems,_loc13_));
               if(!_loc13_ && ptsRewardIdx == -1)
               {
                  ptsRewardIdx = _loc6_;
               }
               _loc6_++;
            }
            if(ptsRewardIdx == -1)
            {
               ptsRewardIdx = _loc3_.pointRewards.length - 1;
            }
         }
      }
      
      public static function show(param1:RankingInfoWrapper, param2:int = 0) : void
      {
         Engine.pushScene(new RankingRewardDialog(param1,param2),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"RankingRewardDialog",function(param1:Object):void
         {
            var _loc7_:int = 0;
            var _loc2_:* = null;
            displaySprite = param1.object;
            var _loc5_:Sprite;
            var _loc6_:ColorTextField = (_loc5_ = displaySprite.getChildByName("dialogSprite") as Sprite).getChildByName("title") as ColorTextField;
            var _loc8_:String;
            if((_loc8_ = GameSetting.getUIText("ranking.level.reward." + info.rankingId)).charAt(0) == "?")
            {
               _loc8_ = GameSetting.getUIText("ranking.level.reward");
            }
            _loc6_.text#2 = StringUtil.format(_loc8_,UserDataWrapper.eventPart.getRankingPointText());
            var _loc4_:ColorTextField = _loc5_.getChildByName("level") as ColorTextField;
            var _loc3_:RankingRewardItemDef = info.currentRankingGlobalReward;
            if(_loc3_)
            {
               _loc4_.text#2 = StringUtil.format(GameSetting.getUIText("ranking.current.level"),info.currentLevel);
            }
            else
            {
               _loc4_.text#2 = StringUtil.format(GameSetting.getUIText("ranking.current.level"),_loc4_.text#2 = GameSetting.getUIText("ranking.total.point.max"));
            }
            var _loc9_:ColorTextField;
            (_loc9_ = _loc5_.getChildByName("point") as ColorTextField).text#2 = StringUtil.getNumStringCommas(info.myPoint);
            tabs = new Vector.<Tab>();
            _loc7_ = 0;
            while(_loc7_ < TAB_NUM)
            {
               _loc2_ = _loc5_.getChildByName("btnTab" + _loc7_) as ContainerButton;
               tabs.push(new Tab(_loc2_,_loc7_,triggeredTabCallback));
               _loc7_++;
            }
            imgTabBtm = _loc5_.getChildByName("imgTabBtm") as Image;
            imgListBG = _loc5_.getChildByName("imgListBG") as Image;
            levelRewardLabel = _loc5_.getChildByName("levelRewardLabel") as ColorTextField;
            if(levelRewardLabel)
            {
               levelRewardLabel.text#2 = StringUtil.format(GameSetting.getUIText("ranking.reward.label.max"),GameSetting.getUIText("%ranking.label.current.level." + info.rankingId));
            }
            list = _loc5_.getChildByName("list") as List;
            btnClose = _loc5_.getChildByName("btnClose") as ContainerButton;
            btnClose.addEventListener("triggered",triggeredClose);
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         setupLayoutForTask(queue,"_SingleRankingRankRibbonItem",function(param1:Object):void
         {
            rankRibbonExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         setupLayoutForTask(queue,"_SingleRankingLevelRewardItem",function(param1:Object):void
         {
            rankRewardExtractor = SpriteExtractor.forGross(param1.object,param1);
         });
         setupLayoutForTask(queue,"_SingleRankingPtsRewardItem",function(param1:Object):void
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
         var _loc7_:int = 0;
         var _loc1_:* = null;
         var _loc2_:* = null;
         var _loc4_:* = null;
         var _loc3_:int = 0;
         var _loc6_:int = 0;
         var _loc8_:int = 0;
         var _loc5_:RankingRewardDef = GameSetting.def.rankingRewardMap[info.content.rewardId];
         var _loc9_:Object = {};
         if(_loc5_.globalRewards)
         {
            _loc3_ = info.totalPoint;
            _loc6_ = 0;
            _loc7_ = _loc5_.globalRewards.length - 1;
            while(_loc7_ >= 0)
            {
               _loc1_ = _loc5_.globalRewards[_loc7_];
               for each(_loc2_ in _loc1_.screeningItems)
               {
                  _loc4_ = GudetamaUtil.getItemIconName(_loc2_.kind,_loc2_.id#2);
                  _loc9_[_loc4_] = _loc2_;
               }
               _loc7_--;
            }
         }
         if(_loc5_.pointRewards)
         {
            _loc8_ = info.myPoint;
            _loc7_ = 0;
            while(_loc7_ < _loc5_.pointRewards.length)
            {
               _loc1_ = _loc5_.pointRewards[_loc7_];
               for each(_loc2_ in _loc1_.screeningItems)
               {
                  _loc4_ = GudetamaUtil.getItemIconName(_loc2_.kind,_loc2_.id#2);
                  _loc9_[_loc4_] = _loc2_;
               }
               _loc7_++;
            }
         }
         for(_loc4_ in _loc9_)
         {
            loadIcon(_loc4_);
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
         var layout:FlowLayout = new FlowLayout();
         layout.verticalAlign = "top";
         layout.horizontalAlign = "left";
         layout.paddingLeft = 12;
         layout.paddingTop = 5;
         layout.paddingBottom = 5;
         layout.gap = 10;
         list.layout = layout;
         list.factoryIDFunction = function(param1:Object):String
         {
            if(param1 is LevelRewardInfo)
            {
               return "level";
            }
            if(param1 is ItemParam)
            {
               return "reward";
            }
            if(param1 is PtsRewardInfo)
            {
               return "pts";
            }
         };
         list.setItemRendererFactoryWithID("level",function():IListItemRenderer
         {
            return new LevelRibbonItemRenderer(rankRibbonExtractor,info.rankingId);
         });
         list.setItemRendererFactoryWithID("reward",function():IListItemRenderer
         {
            return new LevelRewardItemRenderer(rankRewardExtractor,info.rankingId);
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
            TextureCollector.loadTexture("event" + (info.rankingId - 1) + "@frame03",function(param1:Texture):void
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
            TextureCollector.loadTexture("event" + (info.rankingId - 1) + "@level",function(param1:Texture):void
            {
               var _loc2_:Image = spRank.getChildByName("level") as Image;
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
         tabs[0].setButtonColor(rDef.levelRewardMatColor);
         tabs[1].setButtonColor(rDef.pointRewardMatColor);
         var pointText:ColorTextField = dialogSprite.getChildByName("point") as ColorTextField;
         pointText.color = rDef.pointTextColor;
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
         var _loc8_:* = null;
         if(tabType == param1)
         {
            return;
         }
         tabType = param1;
         var _loc5_:RankingDef = GameSetting.def.rankingMap[this.info.rankingId];
         if(param1 == 0)
         {
            _loc7_ = _loc5_.levelRewardMatColor;
            _loc2_ = _loc5_.levelRewardBgMatColor;
         }
         else
         {
            _loc7_ = _loc5_.pointRewardMatColor;
            _loc2_ = _loc5_.pointRewardBgMatColor;
         }
         imgTabBtm.color = _loc7_;
         imgListBG.color = _loc2_;
         var _loc4_:Array = dataMap[param1];
         collection.removeAll();
         if(param1 == TAB_LEVEL)
         {
            _loc6_ = 0;
            while(_loc6_ < _loc4_.length)
            {
               _loc8_ = _loc4_[_loc6_];
               collection.addItem(_loc8_);
               for each(var _loc3_ in _loc8_.items)
               {
                  collection.addItem(_loc3_);
               }
               _loc6_++;
            }
         }
         else
         {
            _loc6_ = 0;
            while(_loc6_ < _loc4_.length)
            {
               collection.addItem(_loc4_[_loc6_]);
               _loc6_++;
            }
         }
         if(param1 == TAB_LEVEL && levelRewardIdx > -1)
         {
            list.scrollToDisplayIndex(levelRewardIdx);
         }
         else if(param1 == TAB_POINT && ptsRewardIdx > -1)
         {
            list.scrollToDisplayIndex(ptsRewardIdx);
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
         list = null;
         if(btnClose)
         {
            btnClose.removeEventListener("triggered",triggeredClose);
            btnClose = null;
         }
         rankRibbonExtractor = null;
         rankRewardExtractor = null;
         ptsRewardExtractor = null;
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

class LevelRewardInfo
{
    
   
   public var index:int;
   
   public var title:String;
   
   public var items:Array;
   
   function LevelRewardInfo(param1:int, param2:String, param3:Array)
   {
      super();
      this.index = param1;
      this.title = param2;
      this.items = param3;
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

class LevelRibbonItemRenderer extends ListItemRendererBase
{
    
   
   private var rankingId:int;
   
   private var itemUI:LevelRibbonItemUI;
   
   function LevelRibbonItemRenderer(param1:SpriteExtractor, param2:int)
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
      itemUI = new LevelRibbonItemUI(displaySprite,rankingId);
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

class LevelRibbonItemUI extends UIBase
{
    
   
   private var rankingId:int;
   
   private var ribbonImage:Image;
   
   private var levelText:ColorTextField;
   
   function LevelRibbonItemUI(param1:Sprite, param2:int)
   {
      var displaySprite:Sprite = param1;
      var rankingId:int = param2;
      super(displaySprite);
      this.rankingId = rankingId;
      ribbonImage = displaySprite.getChildByName("ribbon") as Image;
      levelText = displaySprite.getChildByName("rank") as ColorTextField;
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
      var info:LevelRewardInfo = data as LevelRewardInfo;
      levelText.text#2 = info.title;
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
      levelText = null;
   }
}

import gudetama.ui.ListItemRendererBase;
import gudetama.util.SpriteExtractor;

class LevelRewardItemRenderer extends ListItemRendererBase
{
    
   
   private var itemUI:LevelRewardItemUI;
   
   private var rankingId:int;
   
   function LevelRewardItemRenderer(param1:SpriteExtractor, param2:int)
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
      itemUI = new LevelRewardItemUI(displaySprite,rankingId);
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

class LevelRewardItemUI extends UIBase
{
    
   
   private var icon:Image;
   
   private var lblName:ColorTextField;
   
   private var btnDetail:ContainerButton;
   
   private var item:ItemParam;
   
   function LevelRewardItemUI(param1:Sprite, param2:int)
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
      line_white.color = rDef.levelRewardLineColor;
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
      TextureCollector.loadTexture("event" + (rankingId - 1) + "@mat_p",function(param1:Texture):void
      {
         var _loc2_:Image = displaySprite.getChildByName("mat_p") as Image;
         _loc2_.texture = param1;
      });
      var line_white:Image = displaySprite.getChildByName("line_white") as Image;
      TextureCollector.loadTexture("event" + (rankingId - 1) + "@line_white",function(param1:Texture):void
      {
         line_white.texture = param1;
      });
      TextureCollector.loadTexture("event" + (rankingId - 1) + "@get",function(param1:Texture):void
      {
         imgGet.texture = param1;
      });
      var rDef:RankingDef = GameSetting.def.rankingMap[rankingId];
      line_white.color = rDef.pointRewardLineColor;
      lblPts.color = rDef.pointTextColor;
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
