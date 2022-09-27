package gudetama.scene.ranking
{
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.RankingInfoWrapper;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.ComicDef;
   import gudetama.data.compati.EventData;
   import gudetama.data.compati.ItemParam;
   import gudetama.data.compati.RankingDef;
   import gudetama.data.compati.RankingInfo;
   import gudetama.data.compati.RankingRewardDef;
   import gudetama.data.compati.RankingRewardItemDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.scene.home.HomeScene;
   import gudetama.scene.home.UsefulListDialog;
   import gudetama.scene.shop.ShopScene_Gudetama;
   import gudetama.ui.ComicDialog;
   import gudetama.ui.LocalMessageDialog;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.util.StringUtil;
   import gudetama.util.TimeZoneUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.display.GeneralGauge;
   import muku.display.SimpleImageButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class RankingScene extends BaseScene
   {
      
      private static var rankingInfoMap:Object;
       
      
      private var infos:Array;
      
      private var infosIdx:int;
      
      private var lblTerm:ColorTextField;
      
      private var lblRest:ColorTextField;
      
      private var btnNextReward:ContainerButton;
      
      private var btnNextBalloon:Sprite;
      
      private var imgReward:Image;
      
      private var finishSprite:Sprite;
      
      private var lblNextReward:ColorTextField;
      
      private var lblRestNext:ColorTextField;
      
      private var lblNumReward:ColorTextField;
      
      private var finishReward:Sprite;
      
      private var lblRank:ColorTextField;
      
      private var btnRanking:ContainerButton;
      
      private var btnSingleRanking:ContainerButton;
      
      private var btnSingleReward:ContainerButton;
      
      private var lbl:ColorTextField;
      
      private var lblPts:ColorTextField;
      
      private var btnDeliver:ContainerButton;
      
      private var btnHowToPlay:ContainerButton;
      
      private var btnUseful:ContainerButton;
      
      private var nextPtsReward:ItemParam;
      
      private var totalPointGauge:GeneralGauge;
      
      private var totalPointLevel:ColorTextField;
      
      private var totalPointLabel:ColorTextField;
      
      private var totalPoint:ColorTextField;
      
      private var goToShopButton:SimpleImageButton;
      
      private var loadCount:int;
      
      public function RankingScene(param1:Object = null)
      {
         var _loc3_:* = null;
         var _loc2_:* = null;
         infos = [];
         super(0);
         if(param1)
         {
            rankingInfoMap = param1;
         }
         var _loc5_:Object = GameSetting.def.rankingMap;
         for(var _loc4_ in rankingInfoMap)
         {
            _loc3_ = _loc5_[_loc4_];
            if(_loc3_ != null)
            {
               _loc2_ = rankingInfoMap[_loc4_];
               for each(var _loc6_ in _loc2_)
               {
                  if(_loc6_.contentIndex < _loc3_.content.length)
                  {
                     infos.push(new RankingInfoWrapper(_loc6_,_loc4_,_loc3_.content[_loc6_.contentIndex]));
                  }
               }
            }
         }
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         var info:RankingInfoWrapper = getCurrentInfo();
         var rDef:RankingDef = GameSetting.def.rankingMap[info.rankingId];
         var isFes:Boolean = rDef.groupType == 1;
         setupLayoutForTask(queue,"RankingLayout" + (!!isFes ? "Fes" : "Tours"),function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("spTerm") as Sprite;
            lblTerm = _loc2_.getChildByName("lblTerm") as ColorTextField;
            lblRest = _loc2_.getChildByName("lblRest") as ColorTextField;
            btnHowToPlay = displaySprite.getChildByName("btnHowToPlay") as ContainerButton;
            btnHowToPlay.addEventListener("triggered",triggeredHowToPlay);
            btnNextReward = displaySprite.getChildByName("btnNextReward") as ContainerButton;
            btnNextReward.addEventListener("triggered",triggeredNextReward);
            btnNextBalloon = btnNextReward.getChildByName("balloon") as Sprite;
            if(btnNextBalloon)
            {
               lblRestNext = btnNextBalloon.getChildByName("lblRestNext") as ColorTextField;
            }
            else
            {
               lblRestNext = btnNextReward.getChildByName("lblRestNext") as ColorTextField;
            }
            lblNextReward = btnNextReward.getChildByName("lblNextReward") as ColorTextField;
            if(lblNextReward.text#2.charAt(0) != "%")
            {
               lblNextReward.text#2 = GameSetting.getUIText("ranking.next.pts.reward").replace("%1",UserDataWrapper.eventPart.getRankingPointText(false));
            }
            imgReward = btnNextReward.getChildByName("imgReward") as Image;
            finishSprite = btnNextReward.getChildByName("finishSprite") as Sprite;
            lblNumReward = btnNextReward.getChildByName("lblNumReward") as ColorTextField;
            finishReward = displaySprite.getChildByName("finishReward") as Sprite;
            btnUseful = displaySprite.getChildByName("btnUseful") as ContainerButton;
            if(btnUseful)
            {
               btnUseful.addEventListener("triggered",triggeredUseful);
            }
            var _loc3_:Sprite = displaySprite.getChildByName("spRank") as Sprite;
            lblRank = _loc3_.getChildByName("lblRank") as ColorTextField;
            btnRanking = _loc3_.getChildByName("btnRanking") as ContainerButton;
            if(btnRanking)
            {
               btnRanking.addEventListener("triggered",triggeredRanking);
            }
            btnSingleRanking = _loc3_.getChildByName("btnSingleRanking") as ContainerButton;
            if(btnSingleRanking)
            {
               btnSingleRanking.addEventListener("triggered",triggeredSingleRanking);
            }
            btnSingleReward = _loc3_.getChildByName("btnSingleReward") as ContainerButton;
            if(btnSingleReward)
            {
               btnSingleReward.addEventListener("triggered",triggeredSingleReward);
            }
            var _loc4_:Sprite;
            lbl = (_loc4_ = displaySprite.getChildByName("spPts") as Sprite).getChildByName("lbl") as ColorTextField;
            if(lbl)
            {
               lbl.text#2 = UserDataWrapper.eventPart.getRankingPointText(false);
            }
            lblPts = _loc4_.getChildByName("lblPts") as ColorTextField;
            btnDeliver = _loc4_.getChildByName("btnDeliver") as ContainerButton;
            btnDeliver.addEventListener("triggered",triggeredDeliver);
            var _loc5_:ColorTextField;
            (_loc5_ = btnDeliver.getChildByName("lblDeliver") as ColorTextField).text#2 = GameSetting.getUIText("ranking.btn.deliver").replace("%1",UserDataWrapper.eventPart.getRankingPointText(false));
            totalPointGauge = _loc4_.getChildByName("gauge") as GeneralGauge;
            totalPointLevel = _loc4_.getChildByName("level") as ColorTextField;
            totalPointLabel = _loc4_.getChildByName("label") as ColorTextField;
            totalPoint = _loc4_.getChildByName("point") as ColorTextField;
            goToShopButton = displaySprite.getChildByName("btnGoShop") as SimpleImageButton;
            if(goToShopButton)
            {
               goToShopButton.addEventListener("triggered",triggeredGoToShopButton);
            }
            displaySprite.visible = false;
            addChild(displaySprite);
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
         var info:RankingInfoWrapper = getCurrentInfo();
         var rDef:RankingDef = GameSetting.def.rankingMap[info.rankingId];
         var isFes:Boolean = rDef.groupType == 1;
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("bg-eventtop" + rDef.id#2,function(param1:Texture):void
            {
               var _loc2_:Image = displaySprite.getChildByName("bg") as Image;
               _loc2_.texture = param1;
               queue.taskDone();
            });
         });
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("event" + (rDef.id#2 - 1) + "@banner01",function(param1:Texture):void
            {
               goToShopButton.texture = param1;
               queue.taskDone();
            });
         });
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("event" + (rDef.id#2 - 1) + "@title01",function(param1:Texture):void
            {
               var _loc2_:Image = displaySprite.getChildByName("title") as Image;
               _loc2_.texture = param1;
               queue.taskDone();
            });
         });
         var spTerm:Sprite = displaySprite.getChildByName("spTerm") as Sprite;
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("event" + (rDef.id#2 - 1) + "@" + (!!isFes ? "mat_term02" : "mat_name"),function(param1:Texture):void
            {
               var _loc2_:Image = spTerm.getChildByName("term02") as Image;
               _loc2_.texture = param1;
               queue.taskDone();
            });
         });
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("event" + (rDef.id#2 - 1) + "@mat_term01",function(param1:Texture):void
            {
               var _loc2_:Image = spTerm.getChildByName("term01") as Image;
               _loc2_.texture = param1;
               queue.taskDone();
            });
         });
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("event" + (rDef.id#2 - 1) + "@btn_play",function(param1:Texture):void
            {
               btnHowToPlay.background = param1;
               queue.taskDone();
            });
         });
         if(finishReward)
         {
            queue.addTask(function():void
            {
               TextureCollector.loadTexture("event" + (rDef.id#2 - 1) + "@reward",function(param1:Texture):void
               {
                  var _loc2_:Image = finishReward.getChildByName("reward") as Image;
                  _loc2_.texture = param1;
                  queue.taskDone();
               });
            });
         }
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("event" + (rDef.id#2 - 1) + "@reward",function(param1:Texture):void
            {
               var _loc2_:Image = btnNextReward.getChildByName("reward") as Image;
               if(_loc2_)
               {
                  _loc2_.texture = param1;
               }
               else
               {
                  btnNextReward.background = param1;
               }
               queue.taskDone();
            });
         });
         var mat_rewardnum:Image = btnNextReward.getChildByName("mat_rewardnum") as Image;
         if(mat_rewardnum)
         {
            queue.addTask(function():void
            {
               TextureCollector.loadTexture("event" + (rDef.id#2 - 1) + "@mat_rewardnum",function(param1:Texture):void
               {
                  mat_rewardnum.texture = param1;
                  queue.taskDone();
               });
            });
         }
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("event" + (rDef.id#2 - 1) + "@" + (!!isFes ? "balloon_item" : "balloon_reward"),function(param1:Texture):void
            {
               var _loc2_:Image = btnNextBalloon.getChildByName("balloon_item") as Image;
               _loc2_.texture = param1;
               queue.taskDone();
            });
         });
         var spRank:Sprite = displaySprite.getChildByName("spRank") as Sprite;
         var mat_ranking:Image = spRank.getChildByName("mat_ranking") as Image;
         if(mat_ranking)
         {
            queue.addTask(function():void
            {
               TextureCollector.loadTexture("event" + (rDef.id#2 - 1) + "@mat_ranking",function(param1:Texture):void
               {
                  mat_ranking.texture = param1;
                  queue.taskDone();
               });
            });
         }
         var flag:Image = spRank.getChildByName("flag") as Image;
         if(flag)
         {
            queue.addTask(function():void
            {
               TextureCollector.loadTexture("event" + (rDef.id#2 - 1) + "@flag",function(param1:Texture):void
               {
                  flag.texture = param1;
                  queue.taskDone();
               });
            });
         }
         if(btnRanking)
         {
            queue.addTask(function():void
            {
               TextureCollector.loadTexture("event" + (rDef.id#2 - 1) + "@btn_ranking",function(param1:Texture):void
               {
                  btnRanking.background = param1;
                  queue.taskDone();
               });
            });
         }
         if(btnSingleRanking)
         {
            queue.addTask(function():void
            {
               TextureCollector.loadTexture("event" + (rDef.id#2 - 1) + "@btn_ranking",function(param1:Texture):void
               {
                  btnSingleRanking.background = param1;
                  queue.taskDone();
               });
            });
         }
         if(btnSingleReward)
         {
            queue.addTask(function():void
            {
               TextureCollector.loadTexture("event" + (rDef.id#2 - 1) + "@btn_reward",function(param1:Texture):void
               {
                  btnSingleReward.background = param1;
                  queue.taskDone();
               });
            });
         }
         var spPts:Sprite = displaySprite.getChildByName("spPts") as Sprite;
         var mat_level:Image = spPts.getChildByName("mat_level") as Image;
         if(mat_level)
         {
            queue.addTask(function():void
            {
               TextureCollector.loadTexture("event" + (rDef.id#2 - 1) + "@mat_level",function(param1:Texture):void
               {
                  mat_level.texture = param1;
                  queue.taskDone();
               });
            });
         }
         var level_l:Image = spPts.getChildByName("level_l") as Image;
         if(level_l)
         {
            queue.addTask(function():void
            {
               TextureCollector.loadTexture("event" + (rDef.id#2 - 1) + "@level_l",function(param1:Texture):void
               {
                  level_l.texture = param1;
                  queue.taskDone();
               });
            });
         }
         var compbar1:Image = spPts.getChildByName("compbar1") as Image;
         if(compbar1)
         {
            queue.addTask(function():void
            {
               TextureCollector.loadTexture("event" + (rDef.id#2 - 1) + "@compbar1",function(param1:Texture):void
               {
                  compbar1.texture = param1;
                  queue.taskDone();
               });
            });
         }
         var gauge:GeneralGauge = spPts.getChildByName("gauge") as GeneralGauge;
         if(gauge)
         {
            queue.addTask(function():void
            {
               TextureCollector.loadTexture("event" + (rDef.id#2 - 1) + "@compbar2",function(param1:Texture):void
               {
                  gauge.texture = param1;
                  queue.taskDone();
               });
            });
         }
         mat_ranking = spPts.getChildByName("mat_ranking") as Image;
         if(mat_ranking)
         {
            queue.addTask(function():void
            {
               TextureCollector.loadTexture("event" + (rDef.id#2 - 1) + "@mat_ranking",function(param1:Texture):void
               {
                  mat_ranking.texture = param1;
                  queue.taskDone();
               });
            });
         }
         var item:Image = spPts.getChildByName("item") as Image;
         if(item)
         {
            queue.addTask(function():void
            {
               TextureCollector.loadTexture("event" + (rDef.id#2 - 1) + "@item",function(param1:Texture):void
               {
                  item.texture = param1;
                  queue.taskDone();
               });
            });
         }
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("event" + (rDef.id#2 - 1) + "@btn_exchange_s",function(param1:Texture):void
            {
               btnDeliver.background = param1;
               queue.taskDone();
            });
         });
         var spTeam:Sprite = displaySprite.getChildByName("spTeam") as Sprite;
         if(spTeam)
         {
            queue.addTask(function():void
            {
               TextureCollector.loadTexture("event" + (rDef.id#2 - 1) + "@team",function(param1:Texture):void
               {
                  var _loc2_:Image = spTeam.getChildByName("team") as Image;
                  _loc2_.texture = param1;
                  queue.taskDone();
               });
            });
         }
         var lbl:ColorTextField = spRank.getChildByName("lbl") as ColorTextField;
         if(lbl)
         {
            lbl.color = rDef.rankTextColor;
         }
         lbl = spPts.getChildByName("lbl") as ColorTextField;
         if(lbl)
         {
            lbl.color = rDef.pointTextColor;
         }
         if(lblPts)
         {
            lblPts.color = rDef.pointTextColor;
         }
         lblRestNext.color = rDef.balloonTextColor;
         lblNextReward.color = rDef.rewardTextColor;
      }
      
      private function setup() : void
      {
         infosIdx = 0;
         updateUI();
      }
      
      private function updateUI() : void
      {
         var _loc4_:RankingInfoWrapper = getCurrentInfo();
         var _loc2_:RankingDef = GameSetting.def.rankingMap[_loc4_.rankingId];
         btnHowToPlay.visible = _loc2_.storyComicId > 0 || _loc2_.howtoComicId > 0;
         var _loc1_:EventData = UserDataWrapper.eventPart.getEventDataByRankingId(_loc2_.id#2);
         var _loc3_:Boolean = _loc1_ == null || _loc1_.endTallyRestTimeSecs <= 0 || _loc4_.showOnly;
         lblTerm.text#2 = _loc2_.desc;
         if(_loc3_)
         {
            lblRest.text#2 = GameSetting.getUIText("ranking.finished");
         }
         else
         {
            lblRest.text#2 = TimeZoneUtil.getRestTimeText(_loc1_.endTallyRestTimeSecs);
         }
         if(_loc3_)
         {
            btnNextReward.visible = false;
            if(finishReward)
            {
               finishReward.visible = false;
            }
         }
         else
         {
            updateNextPtsPrize(_loc4_);
         }
         updateRankUI(_loc4_,true);
         if(totalPointLabel)
         {
            totalPointLabel.text#2 = GameSetting.getUIText("%ranking.label.current.level." + _loc4_.rankingId);
            if(totalPointLabel.text#2.charAt(0) == "?")
            {
               totalPointLabel.text#2 = GameSetting.getUIText("%ranking.label.current.level");
            }
         }
         btnDeliver.visible = _loc4_.isDeliverRanking() && !_loc3_;
         if(goToShopButton)
         {
            goToShopButton.visible = GameSetting.getRule().usefulShopShortcut;
         }
      }
      
      private function updateNextPtsPrize(param1:RankingInfoWrapper) : void
      {
         var info:RankingInfoWrapper = param1;
         var rewardDef:RankingRewardDef = GameSetting.def.rankingRewardMap[info.content.rewardId];
         if(rewardDef.pointRewards != null)
         {
            var _nextPtsReward:ItemParam = null;
            var i:int = 0;
            while(i < rewardDef.pointRewards.length)
            {
               var itemDef:RankingRewardItemDef = rewardDef.pointRewards[i];
               if(info.myPoint < itemDef.argi)
               {
                  _nextPtsReward = nextPtsReward = itemDef.screeningItems[0];
                  var restNext:int = itemDef.argi - info.myPoint;
                  break;
               }
               i++;
            }
            if(_nextPtsReward != null)
            {
               btnNextReward.visible = false;
               if(finishReward)
               {
                  finishReward.visible = false;
               }
               else if(finishSprite)
               {
                  finishSprite.visible = false;
               }
               TextureCollector.loadTexture(GudetamaUtil.getItemIconName(_nextPtsReward.kind,_nextPtsReward.id#2),function(param1:Texture):void
               {
                  if(imgReward != null)
                  {
                     imgReward.texture = param1;
                     btnNextReward.visible = true;
                     btnNextBalloon.visible = true;
                     lblNextReward.visible = true;
                     imgReward.visible = true;
                  }
               });
               var restText:String = GameSetting.getUIText("ranking.next.pts.reward.rest." + info.rankingId);
               if(restText.charAt(0) == "?")
               {
                  restText = GameSetting.getUIText("ranking.next.pts.reward.rest");
               }
               lblRestNext.text#2 = restText.replace("%1",StringUtil.getNumStringCommas(restNext));
               if(lblNumReward)
               {
                  lblNumReward.text#2 = StringUtil.format(GameSetting.getUIText("ranking.next.pts.reward.num"),_nextPtsReward.num);
               }
            }
            else if(finishReward)
            {
               btnNextReward.visible = false;
               finishReward.visible = true;
            }
            else if(finishSprite)
            {
               btnNextReward.visible = true;
               btnNextBalloon.visible = false;
               lblNextReward.visible = false;
               imgReward.visible = false;
               finishSprite.visible = true;
            }
         }
         else
         {
            btnNextReward.visible = false;
            if(finishReward)
            {
               finishReward.visible = false;
            }
         }
      }
      
      private function updateRankUI(param1:RankingInfoWrapper, param2:Boolean) : void
      {
         var _loc3_:* = null;
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         if(param2)
         {
            param1.checkTopRecordsIn();
         }
         if(lblRank)
         {
            lblRank.text#2 = param1.getMyRankText();
         }
         if(lblPts)
         {
            lblPts.text#2 = StringUtil.getNumStringCommas(param1.myPoint);
         }
         if(totalPointGauge)
         {
            _loc3_ = param1.currentRankingGlobalReward;
            if(_loc3_)
            {
               _loc5_ = Math.max(0,param1.totalPoint - param1.lastMaxPoint);
               _loc4_ = param1.restMaxPoint;
               totalPoint.text#2 = StringUtil.format(GameSetting.getUIText("ranking.total.point"),StringUtil.getNumStringCommas(_loc5_),StringUtil.getNumStringCommas(_loc4_));
               totalPointLevel.text#2 = String(_loc3_.sortedIndex + 1);
               totalPointGauge.percent = Math.min(1,_loc5_ / _loc4_);
            }
            else
            {
               totalPoint.text#2 = StringUtil.format(GameSetting.getUIText("ranking.total.point"),GameSetting.getUIText("ranking.total.point.none"),GameSetting.getUIText("ranking.total.point.none"));
               totalPointLevel.text#2 = GameSetting.getUIText("ranking.total.point.max");
               totalPointGauge.percent = 1;
            }
         }
      }
      
      override protected function addedToContainer() : void
      {
         var info:RankingInfoWrapper = getCurrentInfo();
         var rDef:RankingDef = GameSetting.def.rankingMap[info.rankingId];
         setBackButtonCallback(backButtonCallback);
         showResidentMenuUI(92);
         displaySprite.visible = true;
         if(HomeScene.isStartableConditionByNotice(23,UserDataWrapper.wrapper))
         {
            resumeNoticeTutorial(23,noticeTutorialAction,getGuideArrowPos);
         }
         else if(!info.isAttendable())
         {
            LocalMessageDialog.show(0,GameSetting.getUIText("ranking.yet.dialog.desc"),function(param1:int):void
            {
               var choose:int = param1;
               ResidentMenuUI_Gudetama.getInstance().sendChangeState(60,function():void
               {
                  Engine.switchScene(new HomeScene());
               });
            },GameSetting.getUIText("ranking.yet.dialog.title"));
         }
         else
         {
            ResidentMenuUI_Gudetama.showRankingGlobalPointRewards(info.rankingId);
         }
      }
      
      private function noticeTutorialAction(param1:int) : void
      {
         triggeredHowToPlay();
      }
      
      private function getGuideArrowPos(param1:int) : Vector.<Number>
      {
         return GudetamaUtil.getCenterPosAndWHOnEngine(btnHowToPlay);
      }
      
      private function backButtonCallback() : void
      {
         if(Engine.getGuideTalkPanel() != null)
         {
            return;
         }
         ResidentMenuUI_Gudetama.getInstance().sendChangeState(60,function():void
         {
            Engine.switchScene(new HomeScene());
         });
      }
      
      private function triggeredRanking() : void
      {
         RankingRecordAndRewardDialog.show(getCurrentInfo());
      }
      
      private function triggeredSingleRanking() : void
      {
         RankingRecordDialog.show(getCurrentInfo());
      }
      
      private function triggeredSingleReward() : void
      {
         RankingRewardDialog.show(getCurrentInfo());
      }
      
      private function triggeredNextReward() : void
      {
         var _loc2_:RankingInfoWrapper = getCurrentInfo();
         var _loc1_:RankingDef = GameSetting.def.rankingMap[_loc2_.rankingId];
         if(_loc1_.groupType == 1)
         {
            RankingRecordAndRewardDialog.show(getCurrentInfo(),RankingRecordAndRewardDialog.TAB_PTS_REWARD);
         }
         else
         {
            RankingRewardDialog.show(getCurrentInfo(),RankingRewardDialog.TAB_POINT);
         }
      }
      
      private function triggeredDeliver() : void
      {
         var _loc1_:RankingInfoWrapper = getCurrentInfo();
         DeliverListDialog.show(_loc1_,deliverCallback);
      }
      
      private function deliverCallback(param1:RankingInfoWrapper) : void
      {
         updateNextPtsPrize(param1);
         updateRankUI(param1,false);
      }
      
      private function triggeredHowToPlay() : void
      {
         var isGuide:Boolean = Engine.getGuideTalkPanel() != null;
         var info:RankingInfoWrapper = getCurrentInfo();
         var rDef:RankingDef = GameSetting.def.rankingMap[info.rankingId];
         var story:ComicDef = !!isGuide ? null : GameSetting.def.comicMap[rDef.storyComicId];
         var howto:ComicDef = GameSetting.def.comicMap[rDef.howtoComicId];
         if(story == null && howto == null)
         {
            if(isGuide)
            {
               Engine.getGuideTalkPanel().finish();
            }
            return;
         }
         ComicDialog.show(rDef.id#2,story,howto,function():void
         {
            if(!isGuide)
            {
               return;
            }
            resumeNoticeTutorial(23,null);
         });
      }
      
      private function triggeredUseful() : void
      {
         HomeScene.usefulButtonSE();
         var _loc1_:Boolean = nextPtsReward != null && nextPtsReward.kind == 8;
         UsefulListDialog.show(null,!_loc1_);
      }
      
      private function triggeredGoToShopButton(param1:Event) : void
      {
         var event:Event = param1;
         LocalMessageDialog.show(1,GameSetting.getUIText("common.confirm.go.shop"),function(param1:int):void
         {
            var choose:int = param1;
            if(choose == 1)
            {
               return;
            }
            ResidentMenuUI_Gudetama.getInstance().sendChangeState(62,function():void
            {
               Engine.switchScene(new ShopScene_Gudetama(3).addBackClass(RankingScene));
            });
         });
      }
      
      private function getCurrentInfo() : RankingInfoWrapper
      {
         return infos[infosIdx];
      }
      
      override public function dispose() : void
      {
         lblRest = null;
         lblRank = null;
         lblPts = null;
         totalPointGauge = null;
         totalPointLevel = null;
         totalPoint = null;
         if(btnRanking != null)
         {
            btnRanking.removeEventListener("triggered",triggeredRanking);
            btnRanking = null;
         }
         if(btnSingleRanking)
         {
            btnSingleRanking.removeEventListener("triggered",triggeredSingleRanking);
            btnSingleRanking = null;
         }
         if(btnSingleReward)
         {
            btnSingleReward.removeEventListener("triggered",triggeredSingleReward);
            btnSingleReward = null;
         }
         if(btnDeliver != null)
         {
            btnDeliver.removeEventListener("triggered",triggeredDeliver);
            btnDeliver = null;
         }
         if(btnHowToPlay != null)
         {
            btnHowToPlay.removeEventListener("triggered",triggeredHowToPlay);
            btnHowToPlay = null;
         }
         if(btnUseful != null)
         {
            btnUseful.removeEventListener("triggered",triggeredUseful);
            btnUseful = null;
         }
         if(btnNextReward != null)
         {
            btnNextReward.removeEventListener("triggered",triggeredNextReward);
            btnNextReward = null;
         }
         if(goToShopButton)
         {
            goToShopButton.removeEventListener("triggered",triggeredGoToShopButton);
            goToShopButton = null;
         }
         super.dispose();
      }
   }
}
