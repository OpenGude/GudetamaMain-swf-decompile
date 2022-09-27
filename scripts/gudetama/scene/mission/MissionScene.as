package gudetama.scene.mission
{
   import feathers.controls.IScrollBar;
   import feathers.controls.List;
   import feathers.controls.ScrollBar;
   import feathers.controls.renderers.IListItemRenderer;
   import feathers.controls.supportClasses.ListDataViewPort;
   import feathers.data.ListCollection;
   import feathers.layout.FlowLayout;
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.MissionData;
   import gudetama.data.compati.MissionDef;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.scene.home.HomeScene;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.util.SpriteExtractor;
   import muku.core.TaskQueue;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class MissionScene extends BaseScene
   {
      
      public static const TYPE_DAILY_MISSION:int = 0;
      
      public static const TYPE_NORMAL_MISSION:int = 1;
      
      public static const TYPE_EVENT_MISSION:int = 2;
      
      public static const TYPES:Array = [2,0,1];
      
      private static const SORT_NUMBER:int = 0;
      
      private static const SORT_UNACHIEVE:int = 1;
      
      private static const SORT_ACHIEVE:int = 2;
      
      private static const UPDATE_INTERVAL:int = 1000;
       
      
      private var backgrounds:Vector.<Sprite>;
      
      private var starImage:Image;
      
      private var achieveText:ColorTextField;
      
      private var maxAchieveText:ColorTextField;
      
      private var toggleUIGroup:ToggleUIGroup;
      
      private var pageGroups:Vector.<PageGroup>;
      
      private var list:List;
      
      private var extractor:SpriteExtractor;
      
      private var collection:ListCollection;
      
      private var missions:Vector.<*>;
      
      private var sortComparators:Vector.<SortComparatorBase>;
      
      private var starTexture:Texture;
      
      private var smallStarTexture:Texture;
      
      private var eventStarTexture:Texture;
      
      private var eventSmallStarTexture:Texture;
      
      private var comparator:Function;
      
      private var sortIndex:int = -1;
      
      private var triggerCount:int = -1;
      
      private var loadCount:int;
      
      private var nextUpdateTime:int;
      
      private var lastHour:int = -1;
      
      private var lastMinute:int = -1;
      
      private var defaultTab:int = -1;
      
      private var moveToMissionId:int = -1;
      
      public function MissionScene(param1:int = -1, param2:int = -1)
      {
         backgrounds = new Vector.<Sprite>(TYPES.length);
         pageGroups = new Vector.<PageGroup>(TYPES.length);
         collection = new ListCollection();
         missions = new Vector.<*>();
         sortComparators = new Vector.<SortComparatorBase>(TYPES.length);
         super(0);
         defaultTab = param1;
         moveToMissionId = param2;
         addEventListener("refreshed_scene_container",refreshedSceneContainer);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"MissionLayout",function(param1:Object):void
         {
            displaySprite = param1.object;
            backgrounds[0] = displaySprite.getChildByName("bg0") as Sprite;
            backgrounds[1] = displaySprite.getChildByName("bg1") as Sprite;
            backgrounds[2] = displaySprite.getChildByName("bg2") as Sprite;
            var _loc3_:Sprite = displaySprite.getChildByName("dialogSprite") as Sprite;
            starImage = _loc3_.getChildByName("star") as Image;
            achieveText = _loc3_.getChildByName("achieve") as ColorTextField;
            maxAchieveText = _loc3_.getChildByName("maxAchieve") as ColorTextField;
            toggleUIGroup = new ToggleUIGroup(_loc3_.getChildByName("tabGroup") as Sprite,triggeredToggleButtonCallback);
            var _loc8_:Sprite = _loc3_.getChildByName("listGroup") as Sprite;
            var _loc6_:TouchFieldUI = new TouchFieldUI(_loc8_.getChildByName("numberTouchField") as Sprite,0,triggeredTouchFieldUI);
            var _loc4_:TouchFieldUI = new TouchFieldUI(_loc8_.getChildByName("unachieveTouchField") as Sprite,1,triggeredTouchFieldUI);
            var _loc2_:TouchFieldUI = new TouchFieldUI(_loc8_.getChildByName("dailyAchieveTouchField") as Sprite,2,triggeredTouchFieldUI);
            var _loc13_:TouchFieldUI = new TouchFieldUI(_loc8_.getChildByName("normalAchieveTouchField") as Sprite,2,triggeredTouchFieldUI);
            var _loc5_:TouchFieldUI = new TouchFieldUI(_loc8_.getChildByName("eventAchieveTouchField") as Sprite,2,triggeredTouchFieldUI);
            var _loc7_:Sprite = _loc8_.getChildByName("numberGroup") as Sprite;
            var _loc10_:Sprite = _loc8_.getChildByName("unachieveGroup") as Sprite;
            var _loc11_:Sprite = _loc8_.getChildByName("dailyAchieveGroup") as Sprite;
            var _loc12_:Sprite = _loc8_.getChildByName("normalAchieveGroup") as Sprite;
            var _loc9_:Sprite = _loc8_.getChildByName("eventAchieveGroup") as Sprite;
            pageGroups[0] = new PageGroup(new PageUI(_loc6_,_loc7_),new PageUI(_loc4_,_loc10_),new PageUI(_loc2_,_loc11_));
            pageGroups[1] = new PageGroup(new PageUI(_loc6_,_loc7_),new PageUI(_loc4_,_loc10_),new PageUI(_loc13_,_loc12_));
            pageGroups[2] = new PageGroup(new PageUI(_loc6_,_loc7_),new PageUI(_loc4_,_loc10_),new PageUI(_loc5_,_loc9_));
            list = _loc8_.getChildByName("list") as List;
            sortComparators[0] = new DailySortComparator();
            sortComparators[1] = new NormalSortComparator();
            sortComparators[2] = new NormalSortComparator();
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         setupLayoutForTask(queue,"_MissionItem_1",function(param1:Object):void
         {
            extractor = SpriteExtractor.forGross(param1.object,param1);
         });
         addTask(function():void
         {
            TextureCollector.loadTexture("challenge0@star01",function(param1:Texture):void
            {
               starTexture = param1;
               taskDone();
            });
         });
         addTask(function():void
         {
            TextureCollector.loadTexture("challenge0@star03",function(param1:Texture):void
            {
               smallStarTexture = param1;
               taskDone();
            });
         });
         addTask(function():void
         {
            TextureCollector.loadTexture("challenge0@star01_p",function(param1:Texture):void
            {
               eventStarTexture = param1;
               taskDone();
            });
         });
         addTask(function():void
         {
            TextureCollector.loadTexture("challenge0@star03_p",function(param1:Texture):void
            {
               eventSmallStarTexture = param1;
               taskDone();
            });
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
         var layout:FlowLayout = new FlowLayout();
         layout.horizontalAlign = "left";
         layout.horizontalGap = 10;
         layout.verticalGap = 10;
         layout.paddingTop = 5;
         layout.paddingLeft = 15;
         list.layout = layout;
         list.itemRendererFactory = function():IListItemRenderer
         {
            return new MissionListItemRenderer(extractor);
         };
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
         list.addEventListener("scrollComplete",scrollComplete);
         setup();
      }
      
      private function scrollComplete(param1:Event) : void
      {
         var _loc2_:* = null;
         var _loc3_:* = null;
         var _loc4_:int = 0;
         _loc2_ = list.getChildAt(0) as ListDataViewPort;
         _loc4_ = 0;
         while(_loc4_ < _loc2_.numChildren)
         {
            _loc3_ = _loc2_.getChildAt(_loc4_) as MissionListItemRenderer;
            if(_loc3_)
            {
               _loc3_.update();
            }
            _loc4_++;
         }
      }
      
      private function processTutorial() : Boolean
      {
         return UserDataWrapper.wrapper.isCanStartNoticeFlag(9) && UserDataWrapper.featurePart.existsFeature(8);
      }
      
      private function processDailyTutorial() : Boolean
      {
         return UserDataWrapper.wrapper.isCanStartNoticeFlag(10) && UserDataWrapper.featurePart.existsFeature(11);
      }
      
      private function setup() : void
      {
         var numTab:int = 1;
         var initType:int = 1;
         var disabledEvent:Boolean = UserDataWrapper.wrapper.isCanStartNoticeFlag(21) && (processTutorial() || processDailyTutorial()) && Engine.getGuideTalkPanel();
         if(UserDataWrapper.featurePart.existsFeature(11))
         {
            numTab++;
            initType = 0;
         }
         else
         {
            toggleUIGroup.setVisibleToggleUI(0,false);
         }
         if(UserDataWrapper.missionPart.getNumEventMission() > 0 && !disabledEvent)
         {
            numTab++;
            initType = 2;
         }
         else
         {
            toggleUIGroup.setVisibleToggleUI(2,false);
         }
         if(!processTutorial() && processDailyTutorial())
         {
            initType = 0;
         }
         if(numTab <= 1)
         {
            toggleUIGroup.setVisible(false);
            queue.addTask(function():void
            {
               TweenAnimator.startItself(displaySprite,"pos0",false,function():void
               {
                  queue.taskDone();
               });
            });
         }
         else
         {
            queue.addTask(function():void
            {
               TweenAnimator.startItself(displaySprite,"pos1",false,function():void
               {
                  queue.taskDone();
               });
            });
         }
         toggleUIGroup.setupButtonImage(queue);
         toggleUIGroup.triggeredButtonCallback(initType);
      }
      
      override protected function addedToContainer() : void
      {
         var _loc1_:int = 0;
         var _loc3_:* = null;
         toggleUIGroup.setupLayout();
         setBackButtonCallback(backButtonCallback);
         showResidentMenuUI(94);
         displaySprite.visible = true;
         var _loc2_:int = checkMissionTutorial();
         if(_loc2_ != -1)
         {
            resumeNoticeTutorial(_loc2_,noticeTutorialAction,getGuideArrowPos);
         }
         else if(defaultTab >= 0)
         {
            triggeredToggleButtonCallback(0,defaultTab);
            toggleUIGroup.triggeredButtonCallback(defaultTab);
            _loc1_ = 0;
            while(_loc1_ < collection.length)
            {
               _loc3_ = collection.getItemAt(_loc1_).missionData;
               if(_loc3_)
               {
                  if(_loc3_.id#2 == moveToMissionId)
                  {
                     list.selectedItem = collection.getItemAt(_loc1_);
                     list.scrollToDisplayIndex(_loc1_);
                     break;
                  }
               }
               _loc1_++;
            }
         }
      }
      
      private function checkMissionTutorial() : int
      {
         var _loc3_:Boolean = processTutorial();
         var _loc1_:Boolean = processDailyTutorial();
         var _loc2_:Boolean = UserDataWrapper.wrapper.isCanStartNoticeFlag(21) && Engine.getGuideTalkPanel();
         if(_loc3_)
         {
            return 9;
         }
         if(_loc1_)
         {
            return 10;
         }
         if(_loc2_)
         {
            return 21;
         }
         return -1;
      }
      
      public function getGuideArrowPos(param1:int) : Vector.<Number>
      {
         return GudetamaUtil.getCenterPosAndWHOnEngine(toggleUIGroup.getButton(param1));
      }
      
      private function noticeTutorialAction(param1:int) : void
      {
      }
      
      private function getPageGroup(param1:int) : PageGroup
      {
         return pageGroups[param1];
      }
      
      private function triggeredToggleButtonCallback(param1:int, param2:int) : void
      {
         var _loc4_:int = 0;
         var _loc3_:* = null;
         var _loc6_:* = 0;
         var _loc10_:* = null;
         var _loc7_:* = null;
         var _loc5_:* = null;
         _loc4_ = 0;
         while(_loc4_ < backgrounds.length)
         {
            backgrounds[_loc4_].visible = _loc4_ == param2;
            _loc4_++;
         }
         _loc4_ = 0;
         while(_loc4_ < pageGroups.length)
         {
            pageGroups[_loc4_].setVisible(_loc4_ == param2);
            _loc4_++;
         }
         pageGroups[param2].setVisible(true);
         missions.length = 0;
         var _loc8_:int = 0;
         if(param2 == 0)
         {
            starImage.texture = smallStarTexture;
            _loc5_ = UserDataWrapper.missionPart.getDailyMissionKeyList();
            for each(var _loc9_ in _loc5_)
            {
               missions.push(UserDataWrapper.missionPart.getMissionData(_loc9_));
               if(UserDataWrapper.missionPart.isCleared(_loc9_))
               {
                  _loc8_++;
               }
            }
         }
         else if(param2 == 2)
         {
            starImage.texture = eventSmallStarTexture;
            _loc3_ = GameSetting.getMissionMap();
            for(_loc6_ in _loc3_)
            {
               if((_loc10_ = GameSetting.getMission(_loc6_)).eventId > 0)
               {
                  if(UserDataWrapper.eventPart.isRunningEvent(_loc10_.eventId))
                  {
                     if(checkShowMission(_loc10_))
                     {
                        if(_loc10_.number > 0)
                        {
                           missions.push(_loc10_);
                        }
                        if((_loc7_ = UserDataWrapper.missionPart.getMissionDataById(_loc10_.id#2)) && UserDataWrapper.missionPart.isCleared(_loc7_.key))
                        {
                           _loc8_++;
                        }
                     }
                  }
               }
            }
         }
         else
         {
            starImage.texture = smallStarTexture;
            _loc3_ = GameSetting.getMissionMap();
            for(_loc6_ in _loc3_)
            {
               if((_loc10_ = GameSetting.getMission(_loc6_)).eventId <= 0)
               {
                  if(_loc10_.number > 0)
                  {
                     if(checkShowMission(_loc10_))
                     {
                        missions.push(_loc10_);
                        if((_loc7_ = UserDataWrapper.missionPart.getMissionDataById(_loc10_.id#2)) && UserDataWrapper.missionPart.isCleared(_loc7_.key))
                        {
                           _loc8_++;
                        }
                     }
                  }
               }
            }
         }
         achieveText.text#2 = _loc8_.toString();
         maxAchieveText.text#2 = missions.length.toString();
         comparator = null;
         sortIndex = -1;
         triggerCount = -1;
         updateList(0);
         if(processDailyTutorial())
         {
            resumeNoticeTutorial(10,noticeTutorialAction,getGuideArrowPos);
         }
      }
      
      private function checkShowMission(param1:MissionDef) : Boolean
      {
         var _loc2_:Array = param1.enableCountryFlags;
         if(!_loc2_)
         {
            return true;
         }
         return _loc2_.indexOf(Engine.getCountryCode()) >= 0;
      }
      
      private function triggeredTouchFieldUI(param1:int) : void
      {
         updateList(param1);
      }
      
      private function updateList(param1:int) : void
      {
         var _loc6_:int = 0;
         var _loc3_:int = 0;
         var _loc8_:* = null;
         var _loc7_:int = 0;
         var _loc5_:* = false;
         var _loc10_:* = false;
         var _loc11_:* = null;
         var _loc4_:* = null;
         var _loc9_:int = this.triggerCount + 1;
         if(param1 != sortIndex)
         {
            _loc9_ = 0;
         }
         var _loc2_:Function = sortComparators[toggleUIGroup.selectedType].getComparator(param1,_loc9_);
         if(this.comparator == _loc2_)
         {
            return;
         }
         this.comparator = _loc2_;
         sortIndex = param1;
         this.triggerCount = _loc9_;
         getPageGroup(toggleUIGroup.selectedType).select = param1;
         missions.sort(_loc2_);
         collection.removeAll();
         list.stopScrolling();
         list.scrollToPosition(0,0,0);
         _loc6_ = 0;
         while(_loc6_ < missions.length)
         {
            _loc5_ = (_loc7_ = toggleUIGroup.selectedType) == 0;
            _loc10_ = _loc7_ == 2;
            if(missions[_loc6_] as MissionDef)
            {
               _loc11_ = missions[_loc6_];
               _loc8_ = UserDataWrapper.missionPart.getMissionDataById(_loc11_.id#2);
               _loc3_ = _loc11_.number;
            }
            else
            {
               _loc3_ = (_loc8_ = missions[_loc6_]).number;
            }
            _loc4_ = !!_loc10_ ? eventStarTexture : starTexture;
            if(param1 == 0)
            {
               collection.addItem({
                  "number":_loc3_,
                  "missionData":_loc8_,
                  "star":_loc4_,
                  "isDaily":_loc5_,
                  "isEvent":_loc10_
               });
            }
            else if(param1 == 2 && _loc8_ && _loc8_.currentValue >= _loc8_.goal)
            {
               collection.addItem({
                  "number":_loc3_,
                  "missionData":_loc8_,
                  "star":_loc4_,
                  "isDaily":_loc5_,
                  "isEvent":_loc10_
               });
            }
            else if(param1 == 1)
            {
               if(!_loc8_)
               {
                  collection.addItem({
                     "number":_loc3_,
                     "missionData":_loc8_,
                     "star":_loc4_,
                     "isDaily":_loc5_,
                     "isEvent":_loc10_
                  });
               }
               else if(_loc8_ && _loc8_.currentValue < _loc8_.goal)
               {
                  collection.addItem({
                     "number":_loc3_,
                     "missionData":_loc8_,
                     "star":_loc4_,
                     "isDaily":_loc5_,
                     "isEvent":_loc10_
                  });
               }
            }
            _loc6_++;
         }
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
      
      override public function advanceTime(param1:Number) : void
      {
         var _loc3_:int = 0;
         var _loc2_:* = null;
         super.advanceTime(param1);
         _loc3_ = 0;
         while(_loc3_ < collection.length)
         {
            _loc2_ = collection.getItemAt(_loc3_).missionItemUI;
            if(_loc2_)
            {
               _loc2_.advanceTime(param1);
            }
            _loc3_++;
         }
      }
      
      private function refreshedSceneContainer(param1:Event) : void
      {
      }
      
      override public function dispose() : void
      {
         removeEventListener("refreshed_scene_container",refreshedSceneContainer);
         backgrounds.length = 0;
         backgrounds = null;
         starImage = null;
         achieveText = null;
         maxAchieveText = null;
         toggleUIGroup.dispose();
         toggleUIGroup = null;
         for each(var _loc2_ in pageGroups)
         {
            _loc2_.dispose();
         }
         pageGroups.length = 0;
         pageGroups = null;
         list = null;
         extractor = null;
         collection = null;
         missions.length = 0;
         missions = null;
         for each(var _loc1_ in sortComparators)
         {
            _loc1_.dispose();
         }
         sortComparators.length = 0;
         sortComparators = null;
         comparator = null;
         starTexture = null;
         smallStarTexture = null;
         eventStarTexture = null;
         eventSmallStarTexture = null;
         super.dispose();
      }
   }
}

class PageGroup
{
    
   
   private var pageUIs:Vector.<PageUI>;
   
   function PageGroup(... rest)
   {
      pageUIs = new Vector.<PageUI>();
      super();
      for each(var _loc2_ in rest)
      {
         pageUIs.push(_loc2_);
      }
   }
   
   public function setVisible(param1:Boolean) : void
   {
      for each(var _loc2_ in pageUIs)
      {
         _loc2_.setVisible(param1);
      }
   }
   
   public function set select(param1:int) : void
   {
      var _loc2_:int = 0;
      _loc2_ = 0;
      while(_loc2_ < pageUIs.length)
      {
         pageUIs[_loc2_].select = _loc2_ == param1;
         _loc2_++;
      }
   }
   
   public function dispose() : void
   {
      for each(var _loc1_ in pageUIs)
      {
         _loc1_.dispose();
      }
      pageUIs.length = 0;
      pageUIs = null;
   }
}

import starling.display.Sprite;

class PageUI
{
    
   
   private var touchFieldUI:TouchFieldUI;
   
   private var background:Sprite;
   
   function PageUI(param1:TouchFieldUI, param2:Sprite)
   {
      super();
      this.touchFieldUI = param1;
      this.background = param2;
   }
   
   public function setVisible(param1:Boolean) : void
   {
      touchFieldUI.setVisible(param1);
      background.visible = param1;
   }
   
   public function set select(param1:Boolean) : void
   {
      touchFieldUI.select = param1;
      background.visible = param1;
   }
   
   public function dispose() : void
   {
      touchFieldUI.dispose();
      touchFieldUI = null;
      background = null;
   }
}

import flash.geom.Point;
import gudetama.ui.UIBase;
import muku.text.ColorTextField;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Touch;
import starling.events.TouchEvent;

class TouchFieldUI extends UIBase
{
    
   
   private var index:int;
   
   private var callback:Function;
   
   private var quad:Quad;
   
   private var text:ColorTextField;
   
   private var localPoint:Point;
   
   function TouchFieldUI(param1:Sprite, param2:int, param3:Function)
   {
      localPoint = new Point();
      super(param1);
      this.index = param2;
      this.callback = param3;
      quad = param1.getChildByName("quad") as Quad;
      quad.addEventListener("touch",onTouch);
      text = param1.getChildByName("text") as ColorTextField;
   }
   
   public function set select(param1:Boolean) : void
   {
      text.color = !!param1 ? 5521974 : 16777215;
   }
   
   private function onTouch(param1:TouchEvent) : void
   {
      var _loc2_:Touch = param1.getTouch(quad);
      if(_loc2_ == null)
      {
         return;
      }
      if(_loc2_.phase == "ended")
      {
         localPoint.setTo(_loc2_.globalX,_loc2_.globalY);
         displaySprite.globalToLocal(localPoint,localPoint);
         if(displaySprite.hitTest(localPoint))
         {
            callback(index);
         }
      }
   }
   
   public function dispose() : void
   {
      callback = null;
      if(quad)
      {
         quad.removeEventListener("touch",onTouch);
         quad = null;
      }
      text = null;
      localPoint = null;
   }
}

class SortComparatorBase
{
    
   
   private var comparatorPairs:Array;
   
   function SortComparatorBase()
   {
      comparatorPairs = [[ascendingNumberComparator,descendingNumberComparator],[ascendingUnachieveComparator,descendingUnachieveComparator],[ascendingAchieveComparator,descendingAchieveComparator]];
      super();
   }
   
   public function getComparator(param1:int, param2:int) : Function
   {
      var _loc3_:Array = comparatorPairs[param1];
      return _loc3_[param2 % _loc3_.length];
   }
   
   protected function ascendingIdComparator(param1:*, param2:*) : Number
   {
      return 0;
   }
   
   protected function descendingIdComparator(param1:*, param2:*) : Number
   {
      return 0;
   }
   
   protected function ascendingNumberComparator(param1:*, param2:*) : Number
   {
      return 0;
   }
   
   protected function descendingNumberComparator(param1:*, param2:*) : Number
   {
      return 0;
   }
   
   protected function ascendingUnachieveComparator(param1:*, param2:*) : Number
   {
      return 0;
   }
   
   protected function descendingUnachieveComparator(param1:*, param2:*) : Number
   {
      return 0;
   }
   
   protected function ascendingAchieveComparator(param1:*, param2:*) : Number
   {
      return 0;
   }
   
   protected function descendingAchieveComparator(param1:*, param2:*) : Number
   {
      return 0;
   }
   
   public function dispose() : void
   {
      for each(var _loc1_ in comparatorPairs)
      {
         _loc1_.length = 0;
      }
      comparatorPairs.length = 0;
      comparatorPairs = null;
   }
}

import gudetama.data.UserDataWrapper;

class DailySortComparator extends SortComparatorBase
{
    
   
   function DailySortComparator()
   {
      super();
   }
   
   override protected function ascendingIdComparator(param1:*, param2:*) : Number
   {
      if(param1.id > param2.id)
      {
         return 1;
      }
      if(param1.id < param2.id)
      {
         return -1;
      }
      return 0;
   }
   
   override protected function descendingIdComparator(param1:*, param2:*) : Number
   {
      if(param1.id > param2.id)
      {
         return -1;
      }
      if(param1.id < param2.id)
      {
         return 1;
      }
      return 0;
   }
   
   override protected function ascendingNumberComparator(param1:*, param2:*) : Number
   {
      if(param1.number > param2.number)
      {
         return 1;
      }
      if(param1.number < param2.number)
      {
         return -1;
      }
      return ascendingIdComparator(param1,param2);
   }
   
   override protected function descendingNumberComparator(param1:*, param2:*) : Number
   {
      if(param1.number > param2.number)
      {
         return -1;
      }
      if(param1.number < param2.number)
      {
         return 1;
      }
      return descendingIdComparator(param1,param2);
   }
   
   override protected function ascendingUnachieveComparator(param1:*, param2:*) : Number
   {
      var _loc4_:Boolean = UserDataWrapper.missionPart.isCleared(param1.key);
      var _loc3_:Boolean = UserDataWrapper.missionPart.isCleared(param2.key);
      if(!_loc4_ && _loc3_)
      {
         return -1;
      }
      if(_loc4_ && !_loc3_)
      {
         return 1;
      }
      return ascendingNumberComparator(param1,param2);
   }
   
   override protected function descendingUnachieveComparator(param1:*, param2:*) : Number
   {
      var _loc4_:Boolean = UserDataWrapper.missionPart.isCleared(param1.key);
      var _loc3_:Boolean = UserDataWrapper.missionPart.isCleared(param2.key);
      if(!_loc4_ && _loc3_)
      {
         return 1;
      }
      if(_loc4_ && !_loc3_)
      {
         return -1;
      }
      return descendingNumberComparator(param1,param2);
   }
   
   override protected function ascendingAchieveComparator(param1:*, param2:*) : Number
   {
      var _loc4_:Boolean = UserDataWrapper.missionPart.isCleared(param1.key);
      var _loc3_:Boolean = UserDataWrapper.missionPart.isCleared(param2.key);
      if(!_loc4_ && _loc3_)
      {
         return 1;
      }
      if(_loc4_ && !_loc3_)
      {
         return -1;
      }
      return ascendingNumberComparator(param1,param2);
   }
   
   override protected function descendingAchieveComparator(param1:*, param2:*) : Number
   {
      var _loc4_:Boolean = UserDataWrapper.missionPart.isCleared(param1.key);
      var _loc3_:Boolean = UserDataWrapper.missionPart.isCleared(param2.key);
      if(!_loc4_ && _loc3_)
      {
         return -1;
      }
      if(_loc4_ && !_loc3_)
      {
         return 1;
      }
      return descendingNumberComparator(param1,param2);
   }
}

import gudetama.data.UserDataWrapper;

class NormalSortComparator extends SortComparatorBase
{
    
   
   function NormalSortComparator()
   {
      super();
   }
   
   override protected function ascendingIdComparator(param1:*, param2:*) : Number
   {
      if(param1.id > param2.id)
      {
         return 1;
      }
      if(param1.id < param2.id)
      {
         return -1;
      }
      return 0;
   }
   
   override protected function descendingIdComparator(param1:*, param2:*) : Number
   {
      if(param1.id > param2.id)
      {
         return -1;
      }
      if(param1.id < param2.id)
      {
         return 1;
      }
      return 0;
   }
   
   override protected function ascendingNumberComparator(param1:*, param2:*) : Number
   {
      if(param1.number > param2.number)
      {
         return 1;
      }
      if(param1.number < param2.number)
      {
         return -1;
      }
      return ascendingIdComparator(param1,param2);
   }
   
   override protected function descendingNumberComparator(param1:*, param2:*) : Number
   {
      if(param1.number > param2.number)
      {
         return -1;
      }
      if(param1.number < param2.number)
      {
         return 1;
      }
      return descendingIdComparator(param1,param2);
   }
   
   override protected function ascendingUnachieveComparator(param1:*, param2:*) : Number
   {
      var _loc4_:Boolean = UserDataWrapper.missionPart.isClearedById(param1.id);
      var _loc3_:Boolean = UserDataWrapper.missionPart.isClearedById(param2.id);
      if(!_loc4_ && _loc3_)
      {
         return -1;
      }
      if(_loc4_ && !_loc3_)
      {
         return 1;
      }
      return ascendingNumberComparator(param1,param2);
   }
   
   override protected function descendingUnachieveComparator(param1:*, param2:*) : Number
   {
      var _loc4_:Boolean = UserDataWrapper.missionPart.isClearedById(param1.id);
      var _loc3_:Boolean = UserDataWrapper.missionPart.isClearedById(param2.id);
      if(!_loc4_ && _loc3_)
      {
         return 1;
      }
      if(_loc4_ && !_loc3_)
      {
         return -1;
      }
      return descendingNumberComparator(param1,param2);
   }
   
   override protected function ascendingAchieveComparator(param1:*, param2:*) : Number
   {
      var _loc4_:Boolean = UserDataWrapper.missionPart.isClearedById(param1.id);
      var _loc3_:Boolean = UserDataWrapper.missionPart.isClearedById(param2.id);
      if(!_loc4_ && _loc3_)
      {
         return 1;
      }
      if(_loc4_ && !_loc3_)
      {
         return -1;
      }
      var _loc5_:Boolean = UserDataWrapper.missionPart.getMissionDataById(param1.id);
      var _loc6_:Boolean = UserDataWrapper.missionPart.getMissionDataById(param2.id);
      if(!_loc5_ && _loc6_)
      {
         return 1;
      }
      if(_loc5_ && !_loc6_)
      {
         return -1;
      }
      return ascendingNumberComparator(param1,param2);
   }
   
   override protected function descendingAchieveComparator(param1:*, param2:*) : Number
   {
      var _loc4_:Boolean = UserDataWrapper.missionPart.isClearedById(param1.id);
      var _loc3_:Boolean = UserDataWrapper.missionPart.isClearedById(param2.id);
      if(!_loc4_ && _loc3_)
      {
         return -1;
      }
      if(_loc4_ && !_loc3_)
      {
         return 1;
      }
      var _loc5_:Boolean = UserDataWrapper.missionPart.getMissionDataById(param1.id);
      var _loc6_:Boolean = UserDataWrapper.missionPart.getMissionDataById(param2.id);
      if(!_loc5_ && _loc6_)
      {
         return -1;
      }
      if(_loc5_ && !_loc6_)
      {
         return 1;
      }
      return descendingNumberComparator(param1,param2);
   }
}

import feathers.controls.renderers.LayoutGroupListItemRenderer;
import gudetama.util.SpriteExtractor;
import starling.display.Sprite;

class MissionListItemRenderer extends LayoutGroupListItemRenderer
{
    
   
   private var extractor:SpriteExtractor;
   
   private var displaySprite:Sprite;
   
   private var missionItemUI:MissionItemUI;
   
   function MissionListItemRenderer(param1:SpriteExtractor)
   {
      super();
      this.extractor = param1;
   }
   
   override protected function initialize() : void
   {
      if(displaySprite)
      {
         return;
      }
      displaySprite = extractor.duplicateAll() as Sprite;
      missionItemUI = new MissionItemUI(displaySprite);
      addChild(displaySprite);
   }
   
   public function update() : void
   {
      missionItemUI.updateData(data#2);
   }
   
   override protected function commitData() : void
   {
      missionItemUI.updateData(data#2);
   }
   
   override public function dispose() : void
   {
      extractor = null;
      displaySprite = null;
      missionItemUI.dispose();
      missionItemUI = null;
      super.dispose();
   }
}

import gudetama.common.GudetamaUtil;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.ItemParam;
import gudetama.data.compati.MissionData;
import gudetama.data.compati.MissionDef;
import gudetama.data.compati.MissionParam;
import gudetama.engine.Engine;
import gudetama.engine.TextureCollector;
import gudetama.scene.mission.MissionDetailDialog;
import gudetama.ui.UIBase;
import gudetama.util.StringUtil;
import gudetama.util.TimeZoneUtil;
import muku.display.ContainerButton;
import muku.display.GeneralGauge;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class MissionItemUI extends UIBase
{
   
   private static const UPDATE_INTERVAL:int = 1000;
    
   
   private var incompleteGroup:Sprite;
   
   private var completeGroup:Sprite;
   
   private var icon:Image;
   
   private var imgComp:Image;
   
   private var nameText:ColorTextField;
   
   private var numberText:ColorTextField;
   
   private var timeGroup:Sprite;
   
   private var timeText:ColorTextField;
   
   private var gauge:GeneralGauge;
   
   private var numText:ColorTextField;
   
   private var maxText:ColorTextField;
   
   private var detailButton:ContainerButton;
   
   private var missionData:MissionData;
   
   private var isDaily:Boolean;
   
   private var isEvent:Boolean;
   
   private var nextUpdateTime:int;
   
   private var lastHour:int = -1;
   
   private var lastEventDay:int = -1;
   
   private var lastEventHour:int = -1;
   
   private var prizeNumText:ColorTextField;
   
   function MissionItemUI(param1:Sprite)
   {
      super(param1);
      incompleteGroup = param1.getChildByName("incompleteGroup") as Sprite;
      completeGroup = param1.getChildByName("completeGroup") as Sprite;
      icon = param1.getChildByName("icon") as Image;
      imgComp = param1.getChildByName("imgComp") as Image;
      imgComp.visible = false;
      prizeNumText = param1.getChildByName("priceNum") as ColorTextField;
      nameText = param1.getChildByName("name") as ColorTextField;
      numberText = param1.getChildByName("number") as ColorTextField;
      timeGroup = param1.getChildByName("timeGroup") as Sprite;
      timeText = timeGroup.getChildByName("time") as ColorTextField;
      gauge = param1.getChildByName("gauge") as GeneralGauge;
      numText = param1.getChildByName("num") as ColorTextField;
      maxText = param1.getChildByName("max") as ColorTextField;
      detailButton = param1.getChildByName("detailButton") as ContainerButton;
      detailButton.addEventListener("triggered",triggeredDetailButton);
   }
   
   public function updateData(param1:Object) : void
   {
      var data:Object = param1;
      imgComp.visible = false;
      if(!data)
      {
         return;
      }
      data["missionItemUI"] = this;
      var number:int = data.number;
      missionData = data.missionData;
      isDaily = data.isDaily;
      isEvent = data.isEvent;
      lastHour = -1;
      lastEventDay = -1;
      lastEventHour = -1;
      nextUpdateTime = 0;
      numberText.text#2 = StringUtil.decimalFormat(GameSetting.getUIText("mission.number.format"),number);
      if(missionData)
      {
         setupEnabled();
      }
      else
      {
         setupDisabled();
      }
      if(missionData)
      {
         var param:MissionParam = missionData.param;
         var item:ItemParam = param.rewards[0];
         prizeNumText.text#2 = StringUtil.format(GameSetting.getUIText("ranking.next.pts.reward.num"),item.num);
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
      else
      {
         prizeNumText.text#2 = GameSetting.getUIText("collection.voice.invisible");
      }
      advanceTime(0);
   }
   
   public function refreshMissionData() : void
   {
      var _loc1_:MissionData = UserDataWrapper.missionPart.getMissionDataById(this.missionData.id#2);
      if(!_loc1_)
      {
         return;
      }
      this.missionData = _loc1_;
      setupEnabled();
   }
   
   private function setupEnabled() : void
   {
      timeGroup.visible = isDaily || isEvent;
      timeText.visible = isDaily || isEvent;
      incompleteGroup.visible = !UserDataWrapper.missionPart.isCleared(missionData.key);
      completeGroup.visible = UserDataWrapper.missionPart.isCleared(missionData.key);
      imgComp.visible = !incompleteGroup.visible;
      nameText.text#2 = missionData.title;
      gauge.percent = Math.min(1,missionData.currentValue / missionData.goal);
      gauge.visible = true;
      numText.text#2 = Math.min(missionData.currentValue,missionData.goal).toString();
      maxText.text#2 = missionData.goal.toString();
      detailButton.visible = true;
   }
   
   private function setupDisabled() : void
   {
      timeGroup.visible = false;
      timeText.visible = false;
      incompleteGroup.visible = true;
      completeGroup.visible = false;
      gauge.visible = false;
      numText.text#2 = GameSetting.getUIText("mission.value.invisible");
      maxText.text#2 = GameSetting.getUIText("mission.value.invisible");
      nameText.text#2 = GameSetting.getUIText("mission.title.invisible");
      detailButton.visible = false;
   }
   
   private function triggeredDetailButton(param1:Event) : void
   {
      MissionDetailDialog.show(missionData);
   }
   
   public function advanceTime(param1:Number) : void
   {
      if(!timeGroup || !timeGroup.visible)
      {
         return;
      }
      if(Engine.now < nextUpdateTime)
      {
         return;
      }
      nextUpdateTime = Engine.now + 1000;
      if(isDaily)
      {
         advanceTimeForDaily(param1);
      }
      else if(isEvent)
      {
         advanceTimeForEvent(param1);
      }
   }
   
   public function advanceTimeForDaily(param1:Number) : void
   {
      var _loc3_:int = TimeZoneUtil.epochMillisToOffsetSecs();
      var _loc4_:int = UserDataWrapper.missionPart.getNextDailyMissionSupplySecs();
      var _loc5_:int;
      var _loc2_:int = (_loc5_ = Math.max(0,_loc4_ - _loc3_)) / 3600;
      if(_loc2_ == lastHour)
      {
         return;
      }
      timeText.text#2 = StringUtil.format(GameSetting.getUIText("mission.daily.time"),_loc2_);
      lastHour = _loc2_;
   }
   
   public function advanceTimeForEvent(param1:Number) : void
   {
      var _loc4_:int = 0;
      var _loc2_:int = 0;
      if(!missionData)
      {
         return;
      }
      var _loc5_:MissionDef;
      if(!(_loc5_ = GameSetting.getMission(missionData.id#2)) || _loc5_.eventId <= 0)
      {
         return;
      }
      var _loc3_:int = UserDataWrapper.eventPart.getRestTimeSecs(_loc5_.eventId);
      if(_loc3_ > 86400)
      {
         if((_loc4_ = _loc3_ / 86400) == lastEventDay)
         {
            return;
         }
         timeText.text#2 = StringUtil.format(GameSetting.getUIText("mission.event.time"),_loc4_);
         lastEventDay = _loc4_;
      }
      else
      {
         _loc2_ = _loc3_ / 3600;
         if(_loc2_ == lastEventHour)
         {
            return;
         }
         timeText.text#2 = StringUtil.format(GameSetting.getUIText("mission.daily.time"),_loc2_);
         lastEventHour = _loc2_;
      }
   }
   
   public function getMissionData() : MissionData
   {
      return missionData;
   }
   
   public function dispose() : void
   {
      incompleteGroup = null;
      completeGroup = null;
      nameText = null;
      numberText = null;
      timeGroup = null;
      timeText = null;
      gauge = null;
      numText = null;
      maxText = null;
      detailButton.removeEventListener("triggered",triggeredDetailButton);
      detailButton = null;
   }
}

import feathers.core.ToggleGroup;
import gudetama.scene.mission.MissionScene;
import muku.core.TaskQueue;
import starling.display.DisplayObject;
import starling.display.Sprite;

class ToggleUIGroup
{
    
   
   private var displaySprite:Sprite;
   
   private var callback:Function;
   
   private var toggleGroup:ToggleGroup;
   
   private var toggleUIList:Vector.<ToggleUI>;
   
   private var width:Number;
   
   function ToggleUIGroup(param1:Sprite, param2:Function)
   {
      var _loc3_:int = 0;
      var _loc4_:int = 0;
      toggleUIList = new Vector.<ToggleUI>(3,true);
      super();
      this.displaySprite = param1;
      this.callback = param2;
      toggleGroup = new ToggleGroup();
      _loc3_ = 0;
      while(_loc3_ < MissionScene.TYPES.length)
      {
         _loc4_ = MissionScene.TYPES[_loc3_];
         toggleUIList[_loc3_] = new ToggleUI(param1.getChildByName("btn_tab" + _loc4_) as Sprite,triggeredButtonCallback,_loc4_,toggleGroup);
         _loc3_++;
      }
      width = param1.width;
   }
   
   public function setVisible(param1:Boolean) : void
   {
      displaySprite.visible = param1;
   }
   
   public function setVisibleToggleUI(param1:int, param2:Boolean) : void
   {
      toggleUIList[getIndexByType(param1)].setVisible(param2);
   }
   
   public function setupLayout() : void
   {
      var _loc2_:int = 0;
      for each(var _loc1_ in toggleUIList)
      {
         if(_loc1_.isVisible())
         {
            _loc2_++;
         }
      }
      var _loc3_:int = 0;
      for each(_loc1_ in toggleUIList)
      {
         if(_loc1_.isVisible())
         {
            _loc1_.getDisplaySprite().x = (_loc3_ + 1) * (width - _loc2_ * _loc1_.getDisplaySprite().width) / (_loc2_ + 1) + _loc3_ * _loc1_.getDisplaySprite().width;
            _loc3_++;
         }
      }
   }
   
   public function setupButtonImage(param1:TaskQueue) : void
   {
      var _loc3_:int = 0;
      for each(var _loc2_ in toggleUIList)
      {
         if(_loc2_.isVisible())
         {
            _loc3_++;
         }
      }
      for each(_loc2_ in toggleUIList)
      {
         _loc2_.setupButtonImage(param1,_loc3_);
      }
   }
   
   private function getIndexByType(param1:int) : int
   {
      var _loc3_:int = 0;
      var _loc2_:* = null;
      _loc3_ = 0;
      while(_loc3_ < toggleUIList.length)
      {
         _loc2_ = toggleUIList[_loc3_];
         if(_loc2_.type == param1)
         {
            return _loc3_;
         }
         _loc3_++;
      }
      return -1;
   }
   
   public function get selectedType() : int
   {
      return toggleUIList[toggleGroup.selectedIndex].type;
   }
   
   public function triggeredButtonCallback(param1:int) : void
   {
      var _loc3_:int = 0;
      var _loc2_:int = getIndexByType(param1);
      if(toggleGroup.selectedIndex != _loc2_)
      {
         toggleGroup.selectedIndex = _loc2_;
      }
      _loc3_ = 0;
      while(_loc3_ < toggleUIList.length)
      {
         toggleUIList[_loc3_].setSelect(_loc3_ == _loc2_);
         _loc3_++;
      }
      if(callback)
      {
         callback(_loc2_,param1);
      }
   }
   
   public function getButton(param1:int) : DisplayObject
   {
      var _loc2_:int = getIndexByType(param1);
      if(toggleUIList[_loc2_] == null)
      {
         return null;
      }
      return toggleUIList[_loc2_].getDisplaySprite();
   }
   
   public function dispose() : void
   {
      displaySprite = null;
      callback = null;
      toggleGroup.removeAllItems();
      toggleGroup = null;
      for each(var _loc1_ in toggleUIList)
      {
         _loc1_.dispose();
      }
      toggleUIList.fixed = false;
      toggleUIList.length = 0;
      toggleUIList = null;
   }
}

import feathers.core.ToggleGroup;
import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import muku.core.TaskQueue;
import muku.display.ToggleButton;
import muku.text.ColorTextField;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.Texture;

class ToggleUI extends UIBase
{
    
   
   private var callback:Function;
   
   public var type:int;
   
   private var button:ToggleButton;
   
   private var text:ColorTextField;
   
   function ToggleUI(param1:Sprite, param2:Function, param3:int, param4:ToggleGroup)
   {
      super(param1);
      this.callback = param2;
      this.type = param3;
      button = param1.getChildByName("toggle_btn") as ToggleButton;
      button.toggleGroup = param4;
      button.addEventListener("triggered",triggered);
      text = param1.getChildByName("text") as ColorTextField;
   }
   
   public function setupButtonImage(param1:TaskQueue, param2:int) : void
   {
      var queue:TaskQueue = param1;
      var num:int = param2;
      if(num == 3)
      {
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("profile0@btn_off",function(param1:Texture):void
            {
               button.defaultTexture = param1;
               button.width = param1.width;
               button.height = param1.height;
               text.width = param1.width;
               queue.taskDone();
            });
         });
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("profile0@btn_on",function(param1:Texture):void
            {
               button.selectedTexture = param1;
               queue.taskDone();
            });
         });
      }
      else
      {
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("challenge0@btn_off",function(param1:Texture):void
            {
               button.defaultTexture = param1;
               button.width = param1.width;
               button.height = param1.height;
               text.width = param1.width;
               queue.taskDone();
            });
         });
         queue.addTask(function():void
         {
            TextureCollector.loadTexture("challenge0@btn_on",function(param1:Texture):void
            {
               button.selectedTexture = param1;
               queue.taskDone();
            });
         });
      }
   }
   
   public function setSelect(param1:Boolean) : void
   {
      text.color = !!param1 ? 5521974 : 16777215;
   }
   
   private function triggered(param1:Event) : void
   {
      if(callback)
      {
         callback(type);
      }
   }
   
   public function dispose() : void
   {
      callback = null;
      button.removeEventListener("triggered",triggered);
      button = null;
      text = null;
   }
}
