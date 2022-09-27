package gudetama.scene.shop
{
   import gestouch.events.GestureEvent;
   import gestouch.gestures.SwipeGesture;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.GachaData;
   import gudetama.data.compati.GachaDef;
   import gudetama.data.compati.GachaPriceDef;
   import gudetama.data.compati.GachaResult;
   import gudetama.data.compati.ItemParam;
   import gudetama.data.compati.ScreeningGachaItemParam;
   import gudetama.data.compati.UserGachaData;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.SoundManager;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import gudetama.scene.gacha.GachaActionDialog;
   import gudetama.scene.home.HomeScene;
   import gudetama.ui.LessMetalDialog;
   import gudetama.ui.LessMoneyDialog;
   import gudetama.ui.LocalMessageDialog;
   import gudetama.ui.ResidentMenuUI_Gudetama;
   import gudetama.ui.SmallMessageDialog;
   import gudetama.ui.VideoAdConfirmDialog;
   import gudetama.util.SpriteExtractor;
   import muku.core.TaskQueue;
   import muku.display.ContainerButton;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.events.Event;
   
   public class GachaScene_Gudetama extends BaseScene
   {
      
      public static const SWITCH_INTERVAL:Number = 1;
       
      
      private var positionQuad:Quad;
      
      private var gachaSprite:Sprite;
      
      private var gachaInfo:GachaInfo;
      
      private var rightButton:ContainerButton;
      
      private var leftButton:ContainerButton;
      
      private var swipeGesture:SwipeGesture;
      
      private var extractor:SpriteExtractor;
      
      private var loadCount:int;
      
      private var gachaViews:Vector.<GachaView>;
      
      private var sortDone:Boolean;
      
      private var gachaDataList:Array;
      
      private var currentIndex:int;
      
      private var entryGachaId:int;
      
      private var rank:int = -1;
      
      public function GachaScene_Gudetama()
      {
         gachaViews = new Vector.<GachaView>();
         super(0);
         addEventListener("refreshed_scene_container",refreshedSceneContainer);
         rank = UserDataWrapper.wrapper.getRank();
      }
      
      private static function gachaDataComparator(param1:GachaData, param2:GachaData) : Number
      {
         var _loc3_:GachaDef = GameSetting.getGacha(param1.id#2);
         var _loc4_:GachaDef = GameSetting.getGacha(param2.id#2);
         if(_loc3_.sortIndex > _loc4_.sortIndex)
         {
            return 1;
         }
         if(_loc3_.sortIndex < _loc4_.sortIndex)
         {
            return -1;
         }
         if(_loc3_.id#2 > _loc4_.id#2)
         {
            return 1;
         }
         if(_loc3_.id#2 < _loc4_.id#2)
         {
            return -1;
         }
         return 0;
      }
      
      public static function getPrice(param1:GachaDef, param2:int) : ItemParam
      {
         var _loc3_:GachaPriceDef = param1.prices[param2];
         for each(var _loc4_ in _loc3_.prices)
         {
            if(UserDataWrapper.wrapper.hasItem(_loc4_))
            {
               return _loc4_;
            }
         }
         return _loc3_.prices[_loc3_.prices.length - 1];
      }
      
      public static function isLastPrice(param1:GachaDef, param2:int) : Boolean
      {
         var _loc5_:int = 0;
         var _loc4_:* = null;
         var _loc3_:GachaPriceDef = param1.prices[param2];
         _loc5_ = 0;
         while(_loc5_ < _loc3_.prices.length - 1)
         {
            _loc4_ = _loc3_.prices[_loc5_];
            if(UserDataWrapper.wrapper.hasItem(_loc4_))
            {
               return false;
            }
            _loc5_++;
         }
         return true;
      }
      
      public static function getLastPrice(param1:GachaDef, param2:int) : ItemParam
      {
         var _loc3_:GachaPriceDef = param1.prices[param2];
         return _loc3_.prices[_loc3_.prices.length - 1];
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         setupLayoutForTask(queue,"GachaLayout_Gudetama",function(param1:Object):void
         {
            displaySprite = param1.object;
            positionQuad = displaySprite.getChildByName("positionQuad") as Quad;
            gachaSprite = displaySprite.getChildByName("gachaSprite") as Sprite;
            gachaInfo = new GachaInfo(displaySprite,playGachaCallback,playFreeGachaCallback,playStampGachaCallback);
            rightButton = (displaySprite.getChildByName("rightButton") as Sprite).getChildByName("ArrowButton") as ContainerButton;
            rightButton.addEventListener("triggered",triggeredRightButton);
            leftButton = (displaySprite.getChildByName("leftButton") as Sprite).getChildByName("ArrowButton") as ContainerButton;
            leftButton.addEventListener("triggered",triggeredLeftButton);
            swipeGesture = new SwipeGesture(gachaInfo.getDisplaySprite());
            Engine.setSwipeGestureDefaultParam(swipeGesture);
            swipeGesture.addEventListener("gestureRecognized",gesture);
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         setupLayoutForTask(queue,"_Gacha",function(param1:Object):void
         {
            extractor = SpriteExtractor.forGross(param1.object,param1);
         });
         addTask(function():void
         {
            var _loc1_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(GACHA_GET_AVAILABLE_DATA_LIST),function(param1:Array):void
            {
               gachaDataList = param1[0];
               gachaDataList.sort(gachaDataComparator);
               var _loc3_:Array = param1[1];
               for each(var _loc2_ in _loc3_)
               {
                  UserDataWrapper.gachaPart.updateUserGachaData(_loc2_);
               }
               entryGachaId = param1[2][0];
               currentIndex = 0;
               taskDone();
            });
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
         var _loc2_:int = 0;
         var _loc1_:* = null;
         var _loc3_:* = null;
         gachaInfo.setup(gachaDataList[currentIndex]);
         _loc2_ = 0;
         while(_loc2_ < gachaDataList.length)
         {
            _loc1_ = extractor.duplicateAll() as Sprite;
            _loc3_ = new GachaView(_loc1_,gachaDataList[_loc2_],positionQuad);
            _loc3_.setDegrees(-_loc2_ * 360 / gachaDataList.length);
            gachaViews.push(_loc3_);
            gachaSprite.addChild(_loc1_);
            _loc2_++;
         }
         sortGachaView();
         setup();
      }
      
      private function setup() : void
      {
         for each(var _loc1_ in gachaViews)
         {
            _loc1_.setup(queue);
         }
         for each(var _loc2_ in gachaDataList)
         {
            preloadGachaActionDialog(_loc2_.id#2);
         }
      }
      
      private function preloadGachaActionDialog(param1:int) : void
      {
         var gachaId:int = param1;
         queue.addTask(function():void
         {
            GachaActionDialog.preload(gachaId,function():void
            {
               queue.taskDone();
            });
         });
      }
      
      override protected function addedToContainer() : void
      {
         setBackButtonCallback(backButtonCallback);
         showResidentMenuUI(94);
         displaySprite.visible = true;
         checkEntryGacha();
         TweenAnimator.startItself(leftButton,"start");
         TweenAnimator.startItself(rightButton,"start");
      }
      
      private function checkEntryGacha(param1:Function = null) : void
      {
         var callback:Function = param1;
         if(entryGachaId <= 0)
         {
            if(callback)
            {
               callback();
            }
            return;
         }
         var dialog:GachaActionDialog = setupAction(entryGachaId,function():void
         {
            rank = UserDataWrapper.wrapper.getRank();
            VideoAdConfirmDialog.show("start2",GameSetting.getUIText("videoAdConfirm.title"),GameSetting.getUIText("videoAdConfirm.gacha.desc"),GameSetting.getUIText("videoAdConfirm.gacha.caution"),null,0,94,function(param1:int):void
            {
               var choose:int = param1;
               if(choose == 1)
               {
                  if(dialog)
                  {
                     dialog.backButtonCallback();
                     dialog = null;
                     setVisibleState(94);
                  }
                  return;
               }
               Engine.showLoading(GachaScene_Gudetama);
               var _loc2_:* = HttpConnector;
               if(gudetama.net.HttpConnector.mainConnector == null)
               {
                  gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
               }
               gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(GACHA_PLAY_ENTRY),function(param1:*):void
               {
                  var response:* = param1;
                  Engine.hideLoading(GachaScene_Gudetama);
                  if(response is Array)
                  {
                     LocalMessageDialog.show(0,GameSetting.getUIText("gacha.warn.desc." + Math.abs(response[0])),function(param1:int):void
                     {
                        Engine.switchScene(new GachaScene_Gudetama());
                     },GameSetting.getUIText("gacha.warn.title"));
                     return;
                  }
                  var gachaResult:GachaResult = response as GachaResult;
                  UserDataWrapper.gachaPart.updateUserGachaData(gachaResult.userGachaData);
                  UserDataWrapper.wrapper.addItems(gachaResult.items,gachaResult.params#2);
                  if(!dialog)
                  {
                     gachaInfo.setup(gachaDataList[currentIndex]);
                     ResidentMenuUI_Gudetama.getInstance().updateUserInfo();
                     if(callback)
                     {
                        callback();
                     }
                  }
                  else
                  {
                     dialog.startWithParam(gachaResult.items,gachaResult.convertedItems,gachaResult.rarities,gachaResult.worthFlags,function():void
                     {
                        gachaInfo.setup(gachaDataList[currentIndex]);
                        ResidentMenuUI_Gudetama.getInstance().updateUserInfo();
                        if(callback)
                        {
                           callback();
                        }
                     });
                     dialog = null;
                  }
               });
            });
         });
      }
      
      private function backButtonCallback() : void
      {
         ResidentMenuUI_Gudetama.getInstance().sendChangeState(60,function():void
         {
            Engine.switchScene(new HomeScene());
         });
      }
      
      private function gesture(param1:GestureEvent) : void
      {
         if(Engine.isTouchInputLocked())
         {
            return;
         }
         if(!gachaInfo.isVisible())
         {
            return;
         }
         if(swipeGesture.offsetX > 0)
         {
            rotateGachaView(-1);
         }
         else if(swipeGesture.offsetX < 0)
         {
            rotateGachaView(1);
         }
      }
      
      override public function advanceTime(param1:Number) : void
      {
         var _loc2_:Boolean = false;
         super.advanceTime(param1);
         var _loc4_:* = false;
         for each(var _loc3_ in gachaViews)
         {
            _loc2_ = _loc3_.advanceTime(param1);
            if(!_loc4_)
            {
               _loc4_ = _loc2_;
            }
         }
         if(_loc4_)
         {
            sortGachaView();
         }
      }
      
      private function sortGachaView() : void
      {
         sortDone = false;
         gachaViews.sort(gachaViewCompareFunc);
         if(sortDone)
         {
            gachaSprite.removeChildren(0,gachaSprite.numChildren - 1);
            for each(var _loc1_ in gachaViews)
            {
               gachaSprite.addChild(_loc1_.getDisplaySprite());
            }
         }
      }
      
      private function gachaViewCompareFunc(param1:GachaView, param2:GachaView) : Number
      {
         if(param1.getDisplaySprite().y <= param2.getDisplaySprite().y)
         {
            return -1;
         }
         sortDone = true;
         return 1;
      }
      
      private function triggeredRightButton(param1:Event) : void
      {
         SoundManager.playEffect("Recipe_PageNext");
         rotateGachaView(-1);
      }
      
      private function triggeredLeftButton(param1:Event) : void
      {
         SoundManager.playEffect("Recipe_PageNext");
         rotateGachaView(1);
      }
      
      private function rotateGachaView(param1:int) : void
      {
         var dir:int = param1;
         for each(gachaView in gachaViews)
         {
            gachaView.setToDegrees(dir * 360 / gachaDataList.length);
         }
         gachaInfo.setVisible(false);
         currentIndex = (currentIndex + dir) % gachaDataList.length;
         if(currentIndex < 0)
         {
            currentIndex = gachaDataList.length - 1;
         }
         gachaInfo.setup(gachaDataList[currentIndex]);
         TweenAnimator.finishItself(rightButton);
         TweenAnimator.finishItself(leftButton);
         rightButton.setEnableWithDrawCache(false);
         leftButton.setEnableWithDrawCache(false);
         getSceneJuggler().delayCall(function():void
         {
            gachaInfo.setVisible(true);
            rightButton.setEnableWithDrawCache(true);
            leftButton.setEnableWithDrawCache(true);
            TweenAnimator.startItself(leftButton,"start");
            TweenAnimator.startItself(rightButton,"start");
         },1);
      }
      
      private function playGachaCallback(param1:int, param2:int, param3:Boolean = false) : void
      {
         var id:int = param1;
         var index:int = param2;
         var playAll:Boolean = param3;
         var doGacha:* = function(param1:Boolean = false):void
         {
            var playAll:Boolean = param1;
            Engine.showLoading(GachaScene_Gudetama);
            var _loc2_:* = HttpConnector;
            if(gudetama.net.HttpConnector.mainConnector == null)
            {
               gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
            }
            gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(GACHA_PLAY,[id,index,!!playAll ? 1 : 0]),function(param1:*):void
            {
               var response:* = param1;
               Engine.hideLoading(GachaScene_Gudetama);
               if(response is Array)
               {
                  LocalMessageDialog.show(0,GameSetting.getUIText("gacha.warn.desc." + Math.abs(response[0])),function(param1:int):void
                  {
                     Engine.switchScene(new GachaScene_Gudetama());
                  },GameSetting.getUIText("gacha.warn.title"));
                  return;
               }
               var gachaDef:GachaDef = GameSetting.getGacha(id);
               var gachaPriceDef:GachaPriceDef = gachaDef.prices[index];
               var gachaResult:GachaResult = response as GachaResult;
               UserDataWrapper.gachaPart.updateUserGachaData(gachaResult.userGachaData);
               UserDataWrapper.wrapper.addItems(gachaResult.items,gachaResult.params#2);
               if(gachaResult.useItem)
               {
                  UserDataWrapper.wrapper.useItem(gachaResult.useItem);
               }
               if(gachaResult.onceMore)
               {
                  showAction(id,gachaResult.items,gachaResult.convertedItems,gachaResult.rarities,gachaResult.worthFlags,function():void
                  {
                     gachaInfo.setup(gachaDataList[currentIndex]);
                     ResidentMenuUI_Gudetama.getInstance().updateUserInfo();
                     Engine.showLoading(GachaScene_Gudetama);
                     getSceneJuggler().delayCall(function():void
                     {
                        Engine.hideLoading(GachaScene_Gudetama);
                        playOnceMoreGacha(id);
                     },0.3);
                  });
               }
               else
               {
                  showAction(id,gachaResult.items,gachaResult.convertedItems,gachaResult.rarities,gachaResult.worthFlags,function():void
                  {
                     gachaInfo.setup(gachaDataList[currentIndex]);
                     ResidentMenuUI_Gudetama.getInstance().updateUserInfo();
                  });
               }
            });
         };
         if(!gachaInfo.isVisible())
         {
            return;
         }
         var gachaDef:GachaDef = GameSetting.getGacha(id);
         var gachaPriceDef:GachaPriceDef = gachaDef.prices[index];
         var price:ItemParam = GachaScene_Gudetama.getPrice(gachaDef,index);
         var isTicket:Boolean = price.kind != 0 && price.kind != 14 && price.kind != 1 && price.kind != 2;
         if(!UserDataWrapper.wrapper.hasItem(price))
         {
            if(price.kind == 0 || price.kind == 14)
            {
               LessMoneyDialog.show();
            }
            else if(price.kind == 1 || price.kind == 2)
            {
               LessMetalDialog.show();
            }
            return;
         }
         if(!isTicket || GameSetting.hasScreeningFlag(10))
         {
            GachaConfirmDialog.show(id,index,doGacha);
         }
         else
         {
            SmallMessageDialog.show(GameSetting.getUIText("gacha.confirm.ticket"),function(param1:int):void
            {
               if(param1 == 1)
               {
                  return;
               }
               doGacha();
            },!!isCompleted(id) ? GameSetting.getUIText("%gachaCompletedConfirm.message") : null);
         }
      }
      
      private function isCompleted(param1:int) : Boolean
      {
         var _loc2_:GachaDef = GameSetting.getGacha(param1);
         for each(var _loc3_ in _loc2_.screeningItems)
         {
            if(_loc3_.item.kind == 6)
            {
               if(!UserDataWrapper.gudetamaPart.hasRecipe(_loc3_.item.id#2))
               {
                  return false;
               }
            }
         }
         return true;
      }
      
      private function playFreeGachaCallback(param1:int) : void
      {
         var id:int = param1;
         if(!gachaInfo.isVisible())
         {
            return;
         }
         Engine.showLoading(GachaScene_Gudetama);
         var _loc2_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(GACHA_PLAY_FREE,id),function(param1:*):void
         {
            var response:* = param1;
            Engine.hideLoading(GachaScene_Gudetama);
            if(response is Array)
            {
               LocalMessageDialog.show(0,GameSetting.getUIText("gacha.warn.desc." + Math.abs(response[0])),function(param1:int):void
               {
                  Engine.switchScene(new GachaScene_Gudetama());
               },GameSetting.getUIText("gacha.warn.title"));
               return;
            }
            var gachaResult:GachaResult = response as GachaResult;
            UserDataWrapper.gachaPart.updateUserGachaData(gachaResult.userGachaData);
            UserDataWrapper.wrapper.addItems(gachaResult.items,gachaResult.params#2);
            if(gachaResult.onceMore)
            {
               showAction(id,gachaResult.items,gachaResult.convertedItems,gachaResult.rarities,gachaResult.worthFlags,function():void
               {
                  gachaInfo.setup(gachaDataList[currentIndex]);
                  ResidentMenuUI_Gudetama.getInstance().updateUserInfo();
                  Engine.showLoading(GachaScene_Gudetama);
                  getSceneJuggler().delayCall(function():void
                  {
                     Engine.hideLoading(GachaScene_Gudetama);
                     playOnceMoreGacha(id);
                  },0.3);
               });
            }
            else
            {
               showAction(id,gachaResult.items,gachaResult.convertedItems,gachaResult.rarities,gachaResult.worthFlags,function():void
               {
                  gachaInfo.setup(gachaDataList[currentIndex]);
                  ResidentMenuUI_Gudetama.getInstance().updateUserInfo();
               });
            }
         });
      }
      
      private function playStampGachaCallback(param1:int, param2:int) : void
      {
         var id:int = param1;
         var index:int = param2;
         if(!gachaInfo.isVisible())
         {
            return;
         }
         var gachaDef:GachaDef = GameSetting.getGacha(id);
         var gachaPriceDef:GachaPriceDef = gachaDef.prices[index];
         var price:ItemParam = GachaScene_Gudetama.getPrice(gachaDef,index);
         var isTicket:Boolean = price.kind != 11;
         if(isTicket)
         {
            var doGacha:* = function(param1:Boolean = false):void
            {
               var playAll:Boolean = param1;
               Engine.showLoading(GachaScene_Gudetama);
               var _loc2_:* = HttpConnector;
               if(gudetama.net.HttpConnector.mainConnector == null)
               {
                  gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
               }
               gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(GACHA_PLAY,[id,index,!!playAll ? 1 : 0]),function(param1:*):void
               {
                  var response:* = param1;
                  Engine.hideLoading(GachaScene_Gudetama);
                  if(response is Array)
                  {
                     LocalMessageDialog.show(0,GameSetting.getUIText("gacha.warn.desc." + Math.abs(response[0])),function(param1:int):void
                     {
                        Engine.switchScene(new GachaScene_Gudetama());
                     },GameSetting.getUIText("gacha.warn.title"));
                     return;
                  }
                  var gachaResult:GachaResult = response as GachaResult;
                  var gachaDef:GachaDef = GameSetting.getGacha(id);
                  var gachaPriceDef:GachaPriceDef = gachaDef.prices[index];
                  UserDataWrapper.gachaPart.updateUserGachaData(gachaResult.userGachaData);
                  UserDataWrapper.wrapper.addItems(gachaResult.items,gachaResult.params#2);
                  if(gachaResult.useItem)
                  {
                     UserDataWrapper.wrapper.useItem(gachaResult.useItem);
                  }
                  if(gachaResult.onceMore)
                  {
                     showAction(id,gachaResult.items,gachaResult.convertedItems,gachaResult.rarities,gachaResult.worthFlags,function():void
                     {
                        gachaInfo.setup(gachaDataList[currentIndex]);
                        ResidentMenuUI_Gudetama.getInstance().updateUserInfo();
                        Engine.showLoading(GachaScene_Gudetama);
                        getSceneJuggler().delayCall(function():void
                        {
                           Engine.hideLoading(GachaScene_Gudetama);
                           playOnceMoreGacha(id);
                        },0.3);
                     });
                  }
                  else
                  {
                     showAction(id,gachaResult.items,gachaResult.convertedItems,gachaResult.rarities,gachaResult.worthFlags,function():void
                     {
                        gachaInfo.setup(gachaDataList[currentIndex]);
                        ResidentMenuUI_Gudetama.getInstance().updateUserInfo();
                     });
                  }
               });
            };
            if(!isTicket || GameSetting.hasScreeningFlag(10))
            {
               GachaConfirmDialog.show(id,index,doGacha);
            }
            else
            {
               SmallMessageDialog.show(GameSetting.getUIText("gacha.confirm.ticket"),function(param1:int):void
               {
                  if(param1 == 1)
                  {
                     return;
                  }
                  doGacha();
               },!!isCompleted(id) ? GameSetting.getUIText("%gachaCompletedConfirm.message") : null);
            }
         }
         else
         {
            GachaSelectStampDialog.show(id,index,function(param1:Array):void
            {
               var stamps:Array = param1;
               stamps.unshift(index);
               stamps.unshift(id);
               Engine.showLoading(GachaScene_Gudetama);
               var _loc2_:* = HttpConnector;
               if(gudetama.net.HttpConnector.mainConnector == null)
               {
                  gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
               }
               gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.createWithInt(GACHA_PLAY_STAMP,stamps),function(param1:*):void
               {
                  var response:* = param1;
                  Engine.hideLoading(GachaScene_Gudetama);
                  if(response is Array)
                  {
                     LocalMessageDialog.show(0,GameSetting.getUIText("gacha.warn.desc." + Math.abs(response[0])),function(param1:int):void
                     {
                        Engine.switchScene(new GachaScene_Gudetama());
                     },GameSetting.getUIText("gacha.warn.title"));
                     return;
                  }
                  var gachaResult:GachaResult = response as GachaResult;
                  var gachaDef:GachaDef = GameSetting.getGacha(id);
                  var gachaPriceDef:GachaPriceDef = gachaDef.prices[index];
                  UserDataWrapper.gachaPart.updateUserGachaData(gachaResult.userGachaData);
                  UserDataWrapper.wrapper.addItems(gachaResult.items,gachaResult.params#2);
                  if(gachaResult.useItem)
                  {
                     UserDataWrapper.wrapper.useItem(gachaResult.useItem);
                  }
                  var i:int = 2;
                  while(i < stamps.length - 1)
                  {
                     var stampId:int = stamps[i];
                     var stampNum:int = stamps[i + 1];
                     UserDataWrapper.stampPart.consumeStamp(stampId,stampNum);
                     var i:int = i + 2;
                  }
                  if(gachaResult.onceMore)
                  {
                     showAction(id,gachaResult.items,gachaResult.convertedItems,gachaResult.rarities,gachaResult.worthFlags,function():void
                     {
                        gachaInfo.setup(gachaDataList[currentIndex]);
                        ResidentMenuUI_Gudetama.getInstance().updateUserInfo();
                        Engine.showLoading(GachaScene_Gudetama);
                        getSceneJuggler().delayCall(function():void
                        {
                           Engine.hideLoading(GachaScene_Gudetama);
                           playOnceMoreGacha(id);
                        },0.3);
                     });
                  }
                  else
                  {
                     showAction(id,gachaResult.items,gachaResult.convertedItems,gachaResult.rarities,gachaResult.worthFlags,function():void
                     {
                        gachaInfo.setup(gachaDataList[currentIndex]);
                        ResidentMenuUI_Gudetama.getInstance().updateUserInfo();
                     });
                  }
               });
            });
         }
      }
      
      private function playOnceMoreGacha(param1:int) : void
      {
         var id:int = param1;
         var dialog:GachaActionDialog = setupAction(id,function():void
         {
            VideoAdConfirmDialog.show("start2",GameSetting.getUIText("videoAdConfirm.title"),GameSetting.getUIText("videoAdConfirm.gacha.desc"),GameSetting.getUIText("videoAdConfirm.gacha.caution"),null,0,94,function(param1:int):void
            {
               var choose:int = param1;
               if(choose == 1)
               {
                  if(dialog)
                  {
                     dialog.backButtonCallback();
                     dialog = null;
                     setVisibleState(94);
                  }
                  return;
               }
               Engine.showLoading(GachaScene_Gudetama);
               var _loc2_:* = HttpConnector;
               if(gudetama.net.HttpConnector.mainConnector == null)
               {
                  gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
               }
               gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(GACHA_PLAY_ONCE_MORE),function(param1:GachaResult):void
               {
                  var response:GachaResult = param1;
                  Engine.hideLoading(GachaScene_Gudetama);
                  UserDataWrapper.gachaPart.updateUserGachaData(response.userGachaData);
                  UserDataWrapper.wrapper.addItems(response.items,response.params#2);
                  if(!dialog)
                  {
                     gachaInfo.setup(gachaDataList[currentIndex]);
                     ResidentMenuUI_Gudetama.getInstance().updateUserInfo();
                  }
                  else
                  {
                     dialog.startWithParam(response.items,response.convertedItems,response.rarities,response.worthFlags,function():void
                     {
                        gachaInfo.setup(gachaDataList[currentIndex]);
                        ResidentMenuUI_Gudetama.getInstance().updateUserInfo();
                     });
                     dialog = null;
                  }
               });
            });
         });
      }
      
      private function setupAction(param1:int, param2:Function = null) : GachaActionDialog
      {
         var id:int = param1;
         var callback:Function = param2;
         return GachaActionDialog.show(id,rank,null,null,null,null,function():void
         {
            showResult(callback);
         });
      }
      
      private function showAction(param1:int, param2:Array, param3:Array, param4:Array, param5:Array, param6:Function = null) : void
      {
         var id:int = param1;
         var items:Array = param2;
         var convertedItems:Array = param3;
         var rarities:Array = param4;
         var worthFlags:Array = param5;
         var callback:Function = param6;
         GachaActionDialog.show(id,rank,items,convertedItems,rarities,worthFlags,function():void
         {
            showResult(callback);
         });
      }
      
      private function showResult(param1:Function) : void
      {
         rank = UserDataWrapper.wrapper.getRank();
         if(param1)
         {
            param1();
         }
      }
      
      private function refreshedSceneContainer(param1:Event) : void
      {
      }
      
      override public function dispose() : void
      {
         removeEventListener("refreshed_scene_container",refreshedSceneContainer);
         positionQuad = null;
         gachaSprite = null;
         if(gachaInfo)
         {
            gachaInfo.dispose();
            gachaInfo = null;
         }
         if(swipeGesture)
         {
            swipeGesture.removeEventListener("gestureRecognized",gesture);
            swipeGesture.dispose();
            swipeGesture = null;
         }
         extractor = null;
         for each(var _loc1_ in gachaViews)
         {
            _loc1_.dispose();
         }
         gachaViews.length = 0;
         gachaViews = null;
         super.dispose();
      }
   }
}

import flash.geom.Point;
import gudetama.data.GameSetting;
import gudetama.data.compati.GachaData;
import gudetama.data.compati.GachaDef;
import gudetama.engine.TextureCollector;
import gudetama.ui.UIBase;
import muku.core.TaskQueue;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.textures.Texture;

class GachaView extends UIBase
{
    
   
   private var gachaData:GachaData;
   
   private var gachaImage:Image;
   
   private var silhouetteImage:Image;
   
   private var radius:Number;
   
   private var heightRatio:Number;
   
   private var basePoint:Point;
   
   private var positionQuadHeight:Number;
   
   private var currentDegrees:Number = 0;
   
   private var fromDegrees:Number = NaN;
   
   private var toDegrees:Number = NaN;
   
   private var time:Number;
   
   function GachaView(param1:Sprite, param2:GachaData, param3:Quad)
   {
      super(param1);
      this.gachaData = param2;
      gachaImage = param1.getChildByName("gacha") as Image;
      silhouetteImage = param1.getChildByName("silhouette") as Image;
      radius = 0.5 * param3.width;
      heightRatio = param3.height / param3.width;
      basePoint = new Point(param3.x - 0.5 * param1.width,param3.y - param1.height);
      positionQuadHeight = param3.height;
   }
   
   public function setup(param1:TaskQueue) : void
   {
      var queue:TaskQueue = param1;
      var gachaDef:GachaDef = GameSetting.getGacha(gachaData.id#2);
      queue.addTask(function():void
      {
         TextureCollector.loadTexture("gacha-" + gachaDef.rsrc + "-machine_image",function(param1:Texture):void
         {
            gachaImage.texture = param1;
            queue.taskDone();
         });
      });
      queue.addTask(function():void
      {
         TextureCollector.loadTexture("gacha-" + gachaDef.rsrc + "-machine_silhouette",function(param1:Texture):void
         {
            silhouetteImage.texture = param1;
            queue.taskDone();
         });
      });
   }
   
   public function setDegrees(param1:Number) : void
   {
      currentDegrees = param1;
      fromDegrees = NaN;
      toDegrees = NaN;
      updatePosition();
   }
   
   public function setToDegrees(param1:Number) : void
   {
      if(!isNaN(toDegrees))
      {
         currentDegrees = toDegrees;
      }
      fromDegrees = currentDegrees;
      toDegrees = fromDegrees + param1;
      time = 0;
   }
   
   private function updatePosition() : void
   {
      var _loc4_:int;
      var _loc3_:Number = (_loc4_ = -currentDegrees - 90) * 3.141592653589793 / 180;
      var _loc1_:Number = radius * Math.cos(_loc3_);
      var _loc2_:Number = radius * Math.sin(_loc3_);
      _loc1_ = radius + _loc1_;
      _loc2_ = radius - _loc2_;
      _loc2_ *= heightRatio;
      displaySprite.x = basePoint.x + _loc1_;
      displaySprite.y = basePoint.y + _loc2_;
      gachaImage.alpha = _loc2_ / positionQuadHeight;
      silhouetteImage.alpha = 1 - _loc2_ / positionQuadHeight;
   }
   
   public function advanceTime(param1:Number) : Boolean
   {
      if(isNaN(toDegrees))
      {
         return false;
      }
      time += param1;
      if(time >= 1)
      {
         setDegrees(toDegrees);
         return true;
      }
      currentDegrees = fromDegrees + (toDegrees - fromDegrees) * time / 1;
      updatePosition();
      return true;
   }
   
   public function dispose() : void
   {
      gachaData = null;
      gachaImage = null;
      silhouetteImage = null;
      basePoint = null;
   }
}

import gudetama.common.OfferwallAdvertisingManager;
import gudetama.data.GameSetting;
import gudetama.data.UserDataWrapper;
import gudetama.data.compati.GachaData;
import gudetama.data.compati.GachaDef;
import gudetama.data.compati.GachaPriceDef;
import gudetama.data.compati.ItemParam;
import gudetama.engine.Engine;
import gudetama.engine.TweenAnimator;
import gudetama.scene.shop.GachaLineupDialog;
import gudetama.scene.shop.GachaPlayButtonUI;
import gudetama.scene.shop.GachaScene_Gudetama;
import gudetama.ui.UIBase;
import muku.display.ContainerButton;
import muku.display.SimpleImageButton;
import muku.text.ColorTextField;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;

class GachaInfo extends UIBase
{
    
   
   private var infoSprite:Sprite;
   
   private var nameText:ColorTextField;
   
   private var descText:ColorTextField;
   
   private var pickupImage:Image;
   
   private var offerwallButton:SimpleImageButton;
   
   private var detailButton:ContainerButton;
   
   private var playButtonGroup:Sprite;
   
   private var playButtonUIs:Vector.<GachaPlayButtonUI>;
   
   private var gachaData:GachaData;
   
   function GachaInfo(param1:Sprite, param2:Function, param3:Function, param4:Function)
   {
      var _loc5_:int = 0;
      playButtonUIs = new Vector.<GachaPlayButtonUI>();
      super(param1);
      infoSprite = param1.getChildByName("infoSprite") as Sprite;
      nameText = infoSprite.getChildByName("name") as ColorTextField;
      descText = infoSprite.getChildByName("desc") as ColorTextField;
      pickupImage = infoSprite.getChildByName("pickup") as Image;
      offerwallButton = infoSprite.getChildByName("offerwallButton") as SimpleImageButton;
      offerwallButton.addEventListener("triggered",triggeredOfferwallButton);
      detailButton = param1.getChildByName("detailButton") as ContainerButton;
      detailButton.addEventListener("triggered",triggeredDetailButton);
      playButtonGroup = param1.getChildByName("playButtonGroup") as Sprite;
      _loc5_ = 0;
      while(_loc5_ < playButtonGroup.numChildren)
      {
         playButtonUIs.push(new GachaPlayButtonUI(playButtonGroup.getChildByName("playButton" + _loc5_) as Sprite,param2,param3,param4));
         _loc5_++;
      }
   }
   
   public function setup(param1:GachaData) : void
   {
      this.gachaData = param1;
      var _loc2_:GachaDef = GameSetting.getGacha(param1.id#2);
      nameText.text#2 = _loc2_.name#2;
      descText.text#2 = _loc2_.desc;
      pickupImage.visible = param1.existsPickup;
      TweenAnimator.startItself(pickupImage,"show");
      if(UserDataWrapper.gachaPart.playableAtFree(_loc2_.id#2))
      {
         setupFree(_loc2_);
      }
      else if(useStamp(_loc2_))
      {
         setupStamp(_loc2_);
      }
      else
      {
         setupMoneyOrMetal(_loc2_);
      }
   }
   
   private function useStamp(param1:GachaDef) : Boolean
   {
      if(!param1.prices || param1.prices.length <= 0)
      {
         return false;
      }
      var _loc2_:GachaPriceDef = param1.prices[0];
      if(!_loc2_.prices || _loc2_.prices.length <= 0)
      {
         return false;
      }
      return _loc2_.prices[_loc2_.prices.length - 1].kind == 11;
   }
   
   private function setupMoneyOrMetal(param1:GachaDef) : void
   {
      var _loc7_:int = 0;
      var _loc2_:* = null;
      var _loc4_:* = null;
      var _loc3_:Boolean = false;
      _loc7_ = 0;
      while(_loc7_ < playButtonUIs.length)
      {
         _loc2_ = playButtonUIs[_loc7_];
         if(_loc7_ < param1.prices.length)
         {
            _loc2_.setVisible(true);
            _loc2_.setup(param1,_loc7_);
            if(!_loc3_)
            {
               _loc3_ = (_loc4_ = GachaScene_Gudetama.getPrice(param1,_loc7_)).kind == 1 || _loc4_.kind == 2;
            }
         }
         else
         {
            _loc2_.setVisible(false);
         }
         _loc7_++;
      }
      var _loc5_:* = 0;
      var _loc6_:* = 0;
      _loc7_ = 0;
      while(_loc7_ < playButtonUIs.length)
      {
         _loc2_ = playButtonUIs[_loc7_];
         if(_loc2_.isVisible())
         {
            _loc2_.getDisplaySprite().x = _loc5_;
            _loc6_ = Number((_loc5_ += _loc2_.width + 10) - 10);
         }
         _loc7_++;
      }
      var _loc8_:* = Engine;
      playButtonGroup.x = 0.5 * (gudetama.engine.Engine.designWidth - _loc6_);
      offerwallButton.visible = UserDataWrapper.wrapper.isEnabledOfferwall() && _loc3_;
   }
   
   private function setupStamp(param1:GachaDef) : void
   {
      var _loc5_:int = 0;
      var _loc2_:* = null;
      offerwallButton.visible = false;
      _loc5_ = 0;
      while(_loc5_ < playButtonUIs.length)
      {
         _loc2_ = playButtonUIs[_loc5_];
         if(_loc5_ == 0)
         {
            _loc2_.setVisible(true);
            _loc2_.setupStamp(param1,_loc5_);
         }
         else
         {
            _loc2_.setVisible(false);
         }
         _loc5_++;
      }
      var _loc3_:* = 0;
      var _loc4_:* = 0;
      _loc5_ = 0;
      while(_loc5_ < playButtonUIs.length)
      {
         _loc2_ = playButtonUIs[_loc5_];
         if(_loc2_.isVisible())
         {
            _loc2_.getDisplaySprite().x = _loc3_;
            _loc3_ += _loc2_.width + 10;
            _loc4_ = Number(_loc3_ - 10);
         }
         _loc5_++;
      }
      var _loc6_:* = Engine;
      playButtonGroup.x = 0.5 * (gudetama.engine.Engine.designWidth - _loc4_);
   }
   
   private function setupFree(param1:GachaDef) : void
   {
      var _loc5_:int = 0;
      var _loc2_:* = null;
      offerwallButton.visible = false;
      _loc5_ = 0;
      while(_loc5_ < playButtonUIs.length)
      {
         _loc2_ = playButtonUIs[_loc5_];
         if(_loc5_ == 0)
         {
            _loc2_.setVisible(true);
            _loc2_.setupFree(param1);
         }
         else
         {
            _loc2_.setVisible(false);
         }
         _loc5_++;
      }
      var _loc3_:* = 0;
      var _loc4_:* = 0;
      _loc5_ = 0;
      while(_loc5_ < playButtonUIs.length)
      {
         _loc2_ = playButtonUIs[_loc5_];
         if(_loc2_.isVisible())
         {
            _loc2_.getDisplaySprite().x = _loc3_;
            _loc3_ += _loc2_.width + 10;
            _loc4_ = Number(_loc3_ - 10);
         }
         _loc5_++;
      }
      var _loc6_:* = Engine;
      playButtonGroup.x = 0.5 * (gudetama.engine.Engine.designWidth - _loc4_);
   }
   
   override public function setVisible(param1:Boolean) : void
   {
      infoSprite.visible = param1;
      detailButton.visible = param1;
      playButtonGroup.visible = param1;
   }
   
   override public function isVisible() : Boolean
   {
      return infoSprite.visible;
   }
   
   private function triggeredDetailButton(param1:Event) : void
   {
      GachaLineupDialog.show(gachaData.id#2);
   }
   
   private function triggeredOfferwallButton(param1:Event) : void
   {
      OfferwallAdvertisingManager.showOfferwallAds();
   }
   
   public function dispose() : void
   {
      infoSprite = null;
      nameText = null;
      descText = null;
      offerwallButton.removeEventListener("triggered",triggeredOfferwallButton);
      offerwallButton = null;
      detailButton.removeEventListener("triggered",triggeredDetailButton);
      detailButton = null;
      playButtonGroup = null;
      for each(var _loc1_ in playButtonUIs)
      {
         _loc1_.dispose();
      }
      playButtonUIs.length = 0;
      playButtonUIs = null;
      gachaData = null;
   }
}
