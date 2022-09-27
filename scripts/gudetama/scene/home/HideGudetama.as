package gudetama.scene.home
{
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.GetItemResult;
   import gudetama.engine.Engine;
   import gudetama.engine.SoundManager;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import gudetama.net.HttpConnector;
   import gudetama.net.PacketUtil;
   import muku.core.TaskQueue;
   import muku.display.SimpleImageButton;
   import starling.core.Starling;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   
   public class HideGudetama extends Sprite
   {
       
      
      private var id:int;
      
      private var homeScene:HomeScene;
      
      private var btn:SimpleImageButton;
      
      private var loop:Boolean;
      
      private var pushed:Boolean = false;
      
      private var startTweenData:Array;
      
      private var lost:Boolean = false;
      
      public function HideGudetama(param1:TaskQueue, param2:int)
      {
         var queue:TaskQueue = param1;
         var id:int = param2;
         super();
         this.id = id;
         userObject.noStopAll = true;
         TextureCollector.loadTextureForTask(queue,"hideGude-" + id,function(param1:Texture):void
         {
            btn = new SimpleImageButton(param1);
            btn.setStopPropagation(true);
            btn.addEventListener("triggered",triggered);
            btn.alignPivot();
            btn.x = btn.width / 2;
            btn.y = btn.height / 2;
            addChild(btn);
         });
         visible = false;
      }
      
      private function setup() : void
      {
         switch(int(id) - 1)
         {
            case 0:
               initDoctor();
               break;
            case 1:
               initMars();
               break;
            case 2:
               initRion();
               break;
            case 3:
               initPicture();
               break;
            case 4:
               initThinker();
               break;
            case 5:
               initKappa();
               break;
            case 7:
               initShyakipiyo();
               break;
            default:
               initWalk();
         }
         visible = true;
      }
      
      private function initDoctor() : void
      {
         loop = true;
         var _loc1_:int = 188;
         var _loc2_:int = 870;
         this.x = _loc1_;
         this.y = _loc2_;
         startTweenData = [];
         startTweenData = [{
            "from":{
               "x":_loc1_,
               "y":_loc2_
            },
            "properties":{
               "transition":"easeIn",
               "delay":0,
               "x":_loc1_ + 30,
               "y":_loc2_
            },
            "time":0.4
         },{
            "from":{"y":_loc2_},
            "properties":{
               "transition":"easeIn",
               "delay":0.4,
               "x":_loc1_ + 25
            },
            "time":0.1
         },{
            "from":{"y":_loc2_},
            "properties":{
               "transition":"easeIn",
               "delay":0.5,
               "x":_loc1_ + 30
            },
            "time":0.1
         },{
            "from":{"y":_loc2_},
            "properties":{
               "transition":"easeIn",
               "delay":0.6,
               "x":_loc1_ + 25
            },
            "time":0.1
         },{
            "from":{"y":_loc2_},
            "properties":{
               "transition":"easeIn",
               "delay":0.7,
               "x":_loc1_ + 30
            },
            "time":0.1
         },{
            "from":{"y":_loc2_},
            "properties":{
               "transition":"easeIn",
               "delay":0.8,
               "x":_loc1_
            },
            "time":0.4
         },{
            "from":{"y":_loc2_},
            "properties":{
               "transition":"easeIn",
               "delay":1.2,
               "x":_loc1_ - 30
            },
            "time":0.4
         },{
            "from":{"y":_loc2_},
            "properties":{
               "transition":"easeIn",
               "delay":1.6,
               "x":_loc1_ - 25
            },
            "time":0.1
         },{
            "from":{"y":_loc2_},
            "properties":{
               "transition":"easeIn",
               "delay":1.7,
               "x":_loc1_ - 30
            },
            "time":0.1
         },{
            "from":{"y":_loc2_},
            "properties":{
               "transition":"easeIn",
               "delay":1.8,
               "x":_loc1_ - 25
            },
            "time":0.1
         },{
            "from":{"y":_loc2_},
            "properties":{
               "transition":"easeIn",
               "delay":1.9,
               "x":_loc1_ - 30
            },
            "time":0.1
         },{
            "from":{"y":_loc2_},
            "properties":{
               "transition":"easeIn",
               "delay":2,
               "x":_loc1_
            },
            "time":0.4
         }];
      }
      
      private function initMars() : void
      {
         loop = true;
         var _loc1_:int = 1050;
         var _loc2_:int = 120;
         this.x = _loc1_;
         this.y = _loc2_;
         startTweenData = [];
         startTweenData = [{
            "from":{
               "x":_loc1_,
               "y":_loc2_
            },
            "properties":{"delay":0},
            "delta":{
               "x":-20,
               "y":30
            },
            "time":0.8
         },{
            "properties":{"delay":0.8},
            "delta":{
               "x":-40,
               "y":0
            },
            "time":0.8
         },{
            "properties":{"delay":1.6},
            "delta":{
               "x":-60,
               "y":30
            },
            "time":0.8
         },{
            "properties":{"delay":2.4},
            "delta":{
               "x":-80,
               "y":0
            },
            "time":0.8
         },{
            "properties":{"delay":3.2},
            "delta":{
               "x":-60,
               "y":30
            },
            "time":0.8
         },{
            "properties":{"delay":4},
            "delta":{
               "x":-40,
               "y":0
            },
            "time":0.8
         },{
            "properties":{"delay":4.8},
            "delta":{
               "x":-20,
               "y":30
            },
            "time":0.8
         },{
            "properties":{"delay":5.6},
            "delta":{
               "x":0,
               "y":0
            },
            "time":0.8
         }];
      }
      
      private function initRion() : void
      {
         loop = true;
         var _loc1_:int = 1400;
         var _loc2_:int = 750;
         this.x = _loc1_;
         this.y = _loc2_;
         startTweenData = [];
         startTweenData = [{
            "from":{
               "x":_loc1_,
               "y":_loc2_
            },
            "properties":{
               "x":_loc1_,
               "y":_loc2_
            },
            "time":0
         },{
            "from":{
               "x":_loc1_,
               "y":_loc2_
            },
            "properties":{
               "delay":1,
               "x":_loc1_ - 100,
               "y":_loc2_
            },
            "time":0.8
         },{
            "from":{
               "x":_loc1_ - 120,
               "y":_loc2_
            },
            "properties":{
               "delay":1.8,
               "x":_loc1_ - 80,
               "y":_loc2_
            },
            "time":0.2
         },{
            "from":{
               "x":_loc1_ - 80,
               "y":_loc2_
            },
            "properties":{
               "delay":2,
               "x":_loc1_ - 135,
               "y":_loc2_
            },
            "time":0.6
         },{
            "from":{
               "x":_loc1_ - 135,
               "y":_loc2_
            },
            "properties":{
               "delay":3.1,
               "x":_loc1_,
               "y":_loc2_
            },
            "time":0.75
         },{
            "from":{
               "x":_loc1_,
               "y":_loc2_
            },
            "properties":{
               "x":_loc1_,
               "y":_loc2_
            },
            "time":0.01
         }];
      }
      
      private function initPicture() : void
      {
         loop = true;
         alignPivot();
         var _loc2_:int = 460;
         var _loc3_:int = 162;
         this.x = _loc2_;
         this.y = _loc3_;
         var _loc1_:* = 0.05;
         var _loc4_:* = 0.1;
         startTweenData = [];
         startTweenData = [{
            "from":{
               "rotation":0,
               "x":_loc2_,
               "y":_loc3_
            },
            "properties":{
               "transition":"easeIn",
               "delay":0,
               "rotation":_loc1_
            },
            "time":0.05
         },{
            "from":{
               "rotation":_loc1_,
               "x":_loc2_,
               "y":_loc3_
            },
            "properties":{
               "transition":"easeIn",
               "delay":0.05,
               "rotation":-_loc1_
            },
            "time":0.05
         },{
            "from":{
               "rotation":-_loc1_,
               "x":_loc2_,
               "y":_loc3_
            },
            "properties":{
               "transition":"easeIn",
               "delay":0.1,
               "rotation":_loc1_
            },
            "time":0.05
         },{
            "from":{
               "rotation":_loc1_,
               "x":_loc2_,
               "y":_loc3_
            },
            "properties":{
               "transition":"easeIn",
               "delay":0.15,
               "rotation":0
            },
            "time":0.05
         },{
            "from":{
               "rotation":0,
               "x":_loc2_,
               "y":_loc3_
            },
            "properties":{
               "transition":"easeIn",
               "delay":0.5,
               "rotation":_loc4_
            },
            "time":0.05
         },{
            "from":{
               "rotation":_loc4_,
               "x":_loc2_,
               "y":_loc3_
            },
            "properties":{
               "transition":"easeIn",
               "delay":0.55,
               "rotation":-_loc4_
            },
            "time":0.05
         },{
            "from":{
               "rotation":-_loc4_,
               "x":_loc2_,
               "y":_loc3_
            },
            "properties":{
               "transition":"easeIn",
               "delay":0.6,
               "rotation":_loc4_
            },
            "time":0.05
         },{
            "from":{
               "rotation":_loc4_,
               "x":_loc2_,
               "y":_loc3_
            },
            "properties":{
               "transition":"easeIn",
               "delay":0.65,
               "rotation":0
            },
            "time":0.05
         }];
      }
      
      private function initThinker() : void
      {
         loop = true;
         var _loc1_:int = 300;
         var _loc3_:int = 1050;
         var _loc4_:int = 900;
         var _loc2_:int = 950;
         this.x = _loc1_;
         this.y = _loc3_;
         startTweenData = [];
         startTweenData = [{
            "properties":{
               "x":_loc1_,
               "y":_loc3_
            },
            "time":0
         },{
            "from":{
               "x":_loc1_,
               "y":_loc3_
            },
            "properties":{
               "delay":1,
               "x":_loc1_,
               "y":_loc4_
            },
            "time":0.5
         },{
            "from":{
               "x":_loc1_,
               "y":_loc4_
            },
            "properties":{
               "delay":2,
               "x":_loc1_,
               "y":_loc3_
            },
            "time":0.5
         },{
            "from":{
               "x":_loc1_,
               "y":_loc3_
            },
            "properties":{
               "delay":2.5,
               "x":_loc1_,
               "y":_loc2_
            },
            "time":0.5
         },{
            "from":{
               "x":_loc1_,
               "y":_loc2_
            },
            "properties":{
               "delay":3.25,
               "x":_loc1_,
               "y":_loc3_ + 100
            },
            "time":0.75
         },{
            "from":{
               "x":_loc1_,
               "y":_loc3_
            },
            "properties":{
               "x":_loc1_,
               "y":_loc3_
            },
            "time":0.01
         }];
      }
      
      private function initKappa() : void
      {
         loop = true;
         var _loc1_:int = 1400;
         var _loc2_:int = 100;
         this.x = _loc1_;
         this.y = _loc2_;
         startTweenData = [];
         startTweenData = [{
            "from":{
               "x":_loc1_,
               "y":_loc2_
            },
            "properties":{
               "x":200,
               "y":1200
            },
            "time":5
         },{
            "from":{
               "x":_loc1_,
               "y":_loc2_
            },
            "properties":{
               "x":_loc1_,
               "y":_loc2_
            },
            "time":0.01
         }];
      }
      
      private function initShyakipiyo() : void
      {
         loop = true;
         var _loc1_:int = 300;
         var _loc3_:int = 1050;
         var _loc4_:int = 900;
         var _loc2_:int = 950;
         this.x = _loc1_;
         this.y = _loc3_;
         startTweenData = [];
         startTweenData = [{
            "properties":{
               "x":_loc1_,
               "y":_loc3_
            },
            "time":0
         },{
            "from":{
               "x":_loc1_,
               "y":_loc3_
            },
            "properties":{
               "delay":1,
               "x":_loc1_,
               "y":_loc4_
            },
            "time":0.5
         },{
            "from":{
               "x":_loc1_,
               "y":_loc4_
            },
            "properties":{
               "delay":2,
               "x":_loc1_,
               "y":_loc3_
            },
            "time":0.5
         },{
            "from":{
               "x":_loc1_,
               "y":_loc3_
            },
            "properties":{
               "delay":2.5,
               "x":_loc1_,
               "y":_loc2_
            },
            "time":0.5
         },{
            "from":{
               "x":_loc1_,
               "y":_loc2_
            },
            "properties":{
               "delay":3.25,
               "x":_loc1_,
               "y":_loc3_ + 100
            },
            "time":0.75
         },{
            "from":{
               "x":_loc1_,
               "y":_loc3_
            },
            "properties":{
               "x":_loc1_,
               "y":_loc3_
            },
            "time":0.01
         }];
      }
      
      private function initWalk() : void
      {
         var _loc6_:* = NaN;
         var _loc4_:int = 0;
         var _loc3_:int = 1400;
         var _loc5_:int = 280;
         this.x = _loc3_;
         this.y = _loc5_;
         startTweenData = [];
         var _loc1_:* = 0;
         var _loc7_:int = 0;
         var _loc2_:int = 30;
         var _loc8_:int = 0;
         _loc4_ = 0;
         while(_loc4_ < 5)
         {
            _loc7_ = -_loc2_;
            _loc6_ = 0;
            startTweenData.push({
               "from":{
                  "x":_loc3_,
                  "y":_loc5_
               },
               "properties":{"delay":_loc1_ + _loc6_},
               "delta":{
                  "x":_loc8_ + _loc7_,
                  "y":-2
               },
               "time":0.2
            });
            _loc6_ = 0.2;
            _loc7_ -= _loc2_;
            startTweenData.push({
               "properties":{"delay":_loc1_ + _loc6_},
               "delta":{
                  "x":_loc8_ + _loc7_,
                  "y":-5
               },
               "time":0.2
            });
            _loc6_ += 0.2;
            _loc7_ -= _loc2_;
            startTweenData.push({
               "properties":{"delay":_loc1_ + _loc6_},
               "delta":{
                  "x":_loc8_ + _loc7_,
                  "y":-9
               },
               "time":0.2
            });
            _loc6_ += 0.2;
            _loc7_ -= _loc2_;
            startTweenData.push({
               "properties":{"delay":_loc1_ + _loc6_},
               "delta":{
                  "x":_loc8_ + _loc7_,
                  "y":-14
               },
               "time":0.2
            });
            _loc6_ += 0.2;
            _loc7_ -= _loc2_;
            startTweenData.push({
               "properties":{"delay":_loc1_ + _loc6_},
               "delta":{
                  "x":_loc8_ + _loc7_,
                  "y":-20
               },
               "time":0.2
            });
            _loc6_ += 0.2;
            _loc7_ -= _loc2_;
            startTweenData.push({
               "properties":{"delay":_loc1_ + _loc6_},
               "delta":{
                  "x":_loc8_ + _loc7_,
                  "y":-20
               },
               "time":0.2
            });
            _loc6_ += 0.2;
            _loc7_ -= _loc2_;
            startTweenData.push({
               "properties":{"delay":_loc1_ + _loc6_},
               "delta":{
                  "x":_loc8_ + _loc7_,
                  "y":-14
               },
               "time":0.2
            });
            _loc6_ += 0.2;
            _loc7_ -= _loc2_;
            startTweenData.push({
               "properties":{"delay":_loc1_ + _loc6_},
               "delta":{
                  "x":_loc8_ + _loc7_,
                  "y":-9
               },
               "time":0.2
            });
            _loc6_ += 0.2;
            _loc7_ -= _loc2_;
            startTweenData.push({
               "properties":{"delay":_loc1_ + _loc6_},
               "delta":{
                  "x":_loc8_ + _loc7_,
                  "y":-5
               },
               "time":0.2
            });
            _loc6_ += 0.2;
            _loc7_ -= _loc2_;
            startTweenData.push({
               "properties":{"delay":_loc1_ + _loc6_},
               "delta":{
                  "x":_loc8_ + _loc7_,
                  "y":-2
               },
               "time":0.2
            });
            _loc6_ += 0.2;
            _loc7_ -= _loc2_;
            startTweenData.push({
               "properties":{"delay":_loc1_ + _loc6_},
               "delta":{
                  "x":_loc8_ + _loc7_,
                  "y":0
               },
               "time":0.2
            });
            _loc6_ += 0.2;
            _loc8_ += _loc7_;
            _loc1_ += _loc6_;
            _loc4_++;
         }
      }
      
      public function setHomeScene(param1:HomeScene) : void
      {
         this.homeScene = param1;
         setup();
      }
      
      public function startMove() : void
      {
         lost = false;
         TweenAnimator.startPrimevally(this,this,startTweenData,function():void
         {
            if(pushed)
            {
               return;
            }
            if(loop)
            {
               startMove();
            }
            else
            {
               endAnime();
            }
         });
      }
      
      private function endAnime() : void
      {
         var btnTween:Object = {
            "properties":{
               "repeatCount":0,
               "reverse":true,
               "scaleX":-1
            },
            "time":0.1
         };
         TweenAnimator.startPrimevally(btn,btn,btnTween);
         var endTween:Object = {
            "from":{"x":x},
            "properties":{
               "transition":"easeIn",
               "alpha":0,
               "delay":0.1,
               "x":x
            },
            "delta":{"y":-40},
            "time":1
         };
         TweenAnimator.startPrimevally(this,this,endTween,function():void
         {
            UserDataWrapper.wrapper.hideGudeId = 0;
            lost = true;
         });
      }
      
      private function triggered(param1:Event) : void
      {
         var e:Event = param1;
         if(pushed)
         {
            return;
         }
         SoundManager.playEffect("put_egg");
         pushed = true;
         delete userObject["noStopAll"];
         TweenAnimator.cancel(this,this);
         Engine.showLoading(HideGudetama);
         var _loc2_:* = HttpConnector;
         if(gudetama.net.HttpConnector.mainConnector == null)
         {
            gudetama.net.HttpConnector.mainConnector = new gudetama.net.HttpConnector();
         }
         gudetama.net.HttpConnector.mainConnector.sendRequest(PacketUtil.create(16777447),function(param1:*):void
         {
            var response:* = param1;
            Engine.hideLoading(HideGudetama);
            UserDataWrapper.wrapper.hideGudeId = 0;
            var result:GetItemResult = response;
            HideGudetamaTouchDialog.show(id,result,homeScene,function():void
            {
               homeScene.updateInfoButton();
               endAnime();
            });
         });
      }
      
      public function isLost() : Boolean
      {
         return lost;
      }
      
      override public function dispose() : void
      {
         homeScene = null;
         startTweenData = null;
         btn.removeEventListener("triggered",triggered);
         btn = null;
         super.dispose();
      }
   }
}
