package gudetama.ui
{
   import gudetama.common.GudetamaUtil;
   import gudetama.data.GameSetting;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.CupGachaDef;
   import gudetama.data.compati.GetItemResult;
   import gudetama.data.compati.ItemParam;
   import gudetama.engine.BaseScene;
   import gudetama.engine.Engine;
   import gudetama.engine.SoundManager;
   import gudetama.engine.TextureCollector;
   import gudetama.engine.TweenAnimator;
   import muku.display.ContainerButton;
   import muku.text.ColorTextField;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.textures.Texture;
   
   public class ItemGetDialog extends BaseScene
   {
       
      
      private var result:GetItemResult;
      
      private var callback:Function;
      
      private var msg:String;
      
      private var title:String;
      
      private var imgPrize:Image;
      
      private var texPrize:Texture;
      
      private var imgToge:Image;
      
      private var btnClose:ContainerButton;
      
      public function ItemGetDialog(param1:GetItemResult, param2:Function, param3:String, param4:String)
      {
         super(2);
         this.result = param1;
         this.callback = param2;
         this.msg = param3;
         this.title = param4;
      }
      
      public static function show(param1:GetItemResult, param2:Function, param3:String, param4:String = "") : void
      {
         Engine.pushScene(new ItemGetDialog(param1,param2,param3,param4),0,false);
      }
      
      override protected function setupProgress(param1:Function) : void
      {
         var onProgress:Function = param1;
         var item:ItemParam = result.item;
         Engine.setupLayoutForTask(queue,"ItemGetDialog",function(param1:Object):void
         {
            var _loc4_:* = null;
            var _loc8_:Number = NaN;
            var _loc11_:* = null;
            displaySprite = param1.object;
            var _loc10_:ColorTextField;
            var _loc5_:Sprite;
            (_loc10_ = (_loc5_ = displaySprite.getChildByName("dialogSprite") as Sprite).getChildByName("title") as ColorTextField).text#2 = title;
            imgToge = _loc5_.getChildByName("imgToge") as Image;
            var _loc3_:ColorTextField = _loc5_.getChildByName("text") as ColorTextField;
            _loc3_.text#2 = GudetamaUtil.getItemParamNameAndNum(item);
            var _loc2_:ColorTextField = _loc5_.getChildByName("message") as ColorTextField;
            var _loc6_:Number = _loc2_.height;
            _loc2_.height = 200;
            var _loc9_:Image = _loc5_.getChildByName("imgMsgBg") as Image;
            if(result.toMail)
            {
               _loc2_.text#2 = msg != null ? msg + "\n\n" : "";
               _loc2_.text#2 += GameSetting.getUIText("common.tomail");
               if(item.kind == 19)
               {
                  if((_loc4_ = GameSetting.getCupGacha(item.id#2)).cookMin != 0)
                  {
                     _loc2_.text#2 += "\n" + GameSetting.getUIText("cupgacha.warn.mail.keep").replace("%1",GameSetting.getRule().cupGachaMailKeepDay).replace("%2",4);
                  }
               }
            }
            else
            {
               if(msg == null)
               {
                  msg = GudetamaUtil.getItemDesc(item.kind,item.id#2);
               }
               _loc2_.text#2 = msg;
            }
            btnClose = _loc5_.getChildByName("btnClose") as ContainerButton;
            btnClose.addEventListener("triggered",triggeredClose);
            var _loc7_:Number;
            if((_loc7_ = _loc2_.textBounds.height) + 20 > _loc9_.height)
            {
               _loc9_.height = _loc7_ + 20;
               _loc2_.height = _loc7_;
               _loc8_ = _loc7_ - _loc6_;
               _loc11_.height = (_loc11_ = _loc5_.getChildByName("imgFrame") as Image).height + _loc8_;
               btnClose.y += _loc8_;
               _loc5_.alignPivot();
            }
            else
            {
               _loc2_.height = _loc6_;
            }
            displaySprite.visible = false;
            addChild(displaySprite);
         });
         TextureCollector.loadTextureForTask(queue,GudetamaUtil.getItemImageName(item.kind,item.id#2),function(param1:Texture):void
         {
            texPrize = param1;
         });
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            imgPrize = new Image(texPrize);
            imgPrize.alignPivot();
            imgPrize.x = imgToge.x;
            imgPrize.y = imgToge.y;
            (displaySprite.getChildByName("dialogSprite") as Sprite).addChild(imgPrize);
         });
         queue.startTask(onProgress);
      }
      
      override protected function addedToContainer() : void
      {
         Engine.lockTouchInput(ItemGetDialog);
         setBackButtonCallback(triggeredClose);
         setVisibleState(78);
      }
      
      override protected function transitionOpenFinished() : void
      {
         displaySprite.visible = true;
         SoundManager.playEffect("MaxComboSuccess");
         TweenAnimator.startItself(displaySprite,"show",false,function():void
         {
            Engine.unlockTouchInput(ItemGetDialog);
            TweenAnimator.startItself(imgToge,"start");
         });
      }
      
      private function triggeredClose() : void
      {
         backButtonCallback();
      }
      
      override public function backButtonCallback() : void
      {
         super.backButtonCallback();
         Engine.lockTouchInput(ItemGetDialog);
         setBackButtonCallback(null);
         TweenAnimator.startItself(displaySprite,"hide",false,function():void
         {
            Engine.unlockTouchInput(ItemGetDialog);
            Engine.popScene(scene);
            if(!result.toMail)
            {
               ConvertDialog.show([result.item],[result.param],function():void
               {
                  UserDataWrapper.wrapper.addItem(result.item,result.param);
                  if(callback != null)
                  {
                     callback();
                  }
               });
            }
            else if(callback != null)
            {
               callback();
            }
         });
      }
      
      override public function dispose() : void
      {
         imgToge = null;
         imgPrize = null;
         texPrize = null;
         if(btnClose)
         {
            btnClose.removeEventListener("triggered",triggeredClose);
         }
         btnClose = null;
         super.dispose();
      }
   }
}
