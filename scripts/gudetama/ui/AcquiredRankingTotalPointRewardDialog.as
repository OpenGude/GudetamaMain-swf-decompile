package gudetama.ui
{
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.ItemParam;
   import gudetama.data.compati.RankingContentDef;
   import gudetama.data.compati.RankingDef;
   import gudetama.data.compati.RankingRewardDef;
   import gudetama.data.compati.RankingRewardItemDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.SoundManager;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class AcquiredRankingTotalPointRewardDialog extends BaseScene
   {
       
      
      private var rankingId:int;
      
      private var param:Object;
      
      private var rewardParam:Object;
      
      private var callback:Function;
      
      private var titleText:ColorTextField;
      
      private var iconImage:Image;
      
      private var numText:ColorTextField;
      
      private var messageText:ColorTextField;
      
      private var closeButton:ContainerButton;
      
      private var loadCount:int;
      
      private var pointIndex:int;
      
      private var itemIndex:int;
      
      public function AcquiredRankingTotalPointRewardDialog(param1:int, param2:Object, param3:Object, param4:Function)
      {
         super(2);
         this.rankingId = param1;
         this.param = param2;
         this.rewardParam = param3;
         this.callback = param4;
      }
      
      public static function show(param1:int, param2:Function = null) : void
      {
         var _loc3_:Object = UserDataWrapper.wrapper.popRankingGlobalPointRewardParam();
         if(!_loc3_)
         {
            if(param2)
            {
               param2();
            }
            return;
         }
         var _loc4_:Object;
         if(!(_loc4_ = getRewardParam(_loc3_,0)))
         {
            if(param2)
            {
               param2();
            }
            return;
         }
         Engine.pushScene(new AcquiredRankingTotalPointRewardDialog(param1,_loc3_,_loc4_,param2),0,false);
      }
      
      private static function getRewardParam(param1:Object, param2:int) : Object
      {
         var _loc8_:int = param1.rankingId;
         var _loc6_:int = param1.contentId;
         var _loc10_:Array = param1.points;
         if(param2 >= _loc10_.length)
         {
            return null;
         }
         var _loc9_:int = _loc10_[param2];
         var _loc5_:RankingDef;
         if(!(_loc5_ = GameSetting.getRanking(_loc8_)))
         {
            return null;
         }
         var _loc3_:RankingContentDef = _loc5_.content[_loc6_];
         if(!_loc3_)
         {
            return null;
         }
         var _loc7_:RankingRewardDef;
         if(!(_loc7_ = GameSetting.getRankingReward(_loc3_.rewardId)))
         {
            return null;
         }
         var _loc11_:* = null;
         for each(var _loc4_ in _loc7_.globalRewards)
         {
            if(_loc9_ == _loc4_.argi)
            {
               _loc11_ = _loc4_;
               break;
            }
         }
         if(!_loc11_)
         {
            return null;
         }
         return {
            "point":_loc9_,
            "rankingDef":_loc5_,
            "rankingRewardItemDef":_loc11_
         };
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"AcquiredRankingTotalPointRewardDialog",function(param1:Object):void
         {
            displaySprite = param1.object;
            var _loc2_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            titleText = _loc2_.getChildByName("title") as ColorTextField;
            iconImage = _loc2_.getChildByName("icon") as Image;
            numText = _loc2_.getChildByName("text") as ColorTextField;
            messageText = _loc2_.getChildByName("message") as ColorTextField;
            closeButton = _loc2_.getChildByName("btnClose") as ContainerButton;
            closeButton.addEventListener("triggered",triggeredCloseButton);
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
         setup(queue);
      }
      
      private function setup(param1:TaskQueue) : void
      {
         var queue:TaskQueue = param1;
         titleText.text#2 = GameSetting.getUIText("ranking.tab.level.reward." + rankingId);
         if(titleText.text#2.charAt(0) == "?")
         {
            titleText.text#2 = GameSetting.getUIText("ranking.tab.level.reward");
         }
         var item:ItemParam = rewardParam.rankingRewardItemDef.screeningItems[itemIndex];
         numText.text#2 = GudetamaUtil.getItemParamNameAndNum(item);
         var level:String = rewardParam.rankingRewardItemDef.sortedIndex + 2;
         if(rewardParam.rankingRewardItemDef.last)
         {
            level = GameSetting.getUIText("ranking.total.point.max");
         }
         messageText.text#2 = StringUtil.format(GameSetting.getUIText("ranking.get.level.reward"),rewardParam.rankingDef.title,level);
         TextureCollector.loadTextureForTask(queue,GudetamaUtil.getItemImageName(item.kind,item.id#2),function(param1:Texture):void
         {
            iconImage.texture = param1;
         });
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
            TextureCollector.loadTexture("event" + (rankingId - 1) + "@frame03",function(param1:Texture):void
            {
               var _loc2_:Image = dialogSprite.getChildByName("frame02") as Image;
               _loc2_.texture = param1;
               queue.taskDone();
            });
         });
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(AcquiredRankingTotalPointRewardDialog);
         setBackButtonCallback(backButtonCallback);
         setVisibleState(78);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         SoundManager.playEffect("MaxComboSuccess");
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(AcquiredRankingTotalPointRewardDialog);
         });
      }
      
      override public function backButtonCallback() : void
      {
         if(++itemIndex < rewardParam.rankingRewardItemDef.screeningItems.length)
         {
            next();
         }
         else
         {
            itemIndex = 0;
            rewardParam = getRewardParam(param,++pointIndex);
            if(rewardParam)
            {
               next();
            }
            else
            {
               pointIndex = 0;
               param = UserDataWrapper.wrapper.popRankingGlobalPointRewardParam();
               if(param)
               {
                  rewardParam = getRewardParam(param,0);
                  if(rewardParam)
                  {
                     next();
                  }
                  else
                  {
                     back();
                  }
               }
               else
               {
                  back();
               }
            }
         }
      }
      
      private function next() : void
      {
         Engine.lockTouchInput(AcquiredRankingTotalPointRewardDialog);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            var queue:TaskQueue = new TaskQueue();
            setup(queue);
            queue.registerOnProgress(function(param1:Number):void
            {
               var ratio:Number = param1;
               if(ratio < 1)
               {
                  return;
               }
               SoundManager.playEffect("MaxComboSuccess");
               TweenAnimator.startItself(displaySprite,"show",false,function():void
               {
                  Engine.unlockTouchInput(AcquiredRankingTotalPointRewardDialog);
               });
            });
            queue.startTask();
         });
      }
      
      private function back() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(AcquiredRankingTotalPointRewardDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(AcquiredRankingTotalPointRewardDialog);
            Engine.popScene(scene);
            if(callback != null)
            {
               callback();
            }
         });
      }
      
      private function triggeredCloseButton(param1:Event) : void
      {
         backButtonCallback();
      }
      
      override public function dispose() : void
      {
         titleText = null;
         numText = null;
         messageText = null;
         if(closeButton)
         {
            closeButton.removeEventListener("triggered",triggeredCloseButton);
            closeButton = null;
         }
         super.dispose();
      }
   }
}
