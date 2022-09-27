package gudetama.scene.home.ui
{
   import flash.geom.Rectangle;
   import gudetama.common.VoiceManager;
   import gudetama.data.compati.VoiceDef;
   import gudetama.engine.TweenAnimator;
   import gudetama.ui.UIBase;
   import muku.text.ColorTextField;
   import starling.display.Sprite;
   
   public class SerifUI extends UIBase
   {
      
      private static const PHASE_NONE:int = 0;
      
      private static const PHASE_SHOW:int = 1;
      
      private static const PHASE_PLAYING:int = 2;
      
      private static const PHASE_HIDE:int = 3;
       
      
      private var rightSerifText:ColorTextField;
      
      private var leftSerifGroup:Sprite;
      
      private var leftSerifText:ColorTextField;
      
      private var phase:int = 0;
      
      private var voiceManager:VoiceManager;
      
      private var rightDefaultX:Number;
      
      private var leftDefaultX:Number;
      
      private var defaultY:Number;
      
      public function SerifUI(param1:Sprite, param2:Sprite)
      {
         voiceManager = new VoiceManager(show,hide);
         super(param1);
         rightSerifText = param1.getChildByName("serif") as ColorTextField;
         this.leftSerifGroup = param2;
         leftSerifText = param2.getChildByName("serif") as ColorTextField;
         setVisible(false);
         param2.visible = false;
      }
      
      public function setup(param1:Rectangle = null) : void
      {
         rightDefaultX = displaySprite.x;
         leftDefaultX = leftSerifGroup.x;
         defaultY = !!param1 ? param1.y - 30 : Number(displaySprite.y);
      }
      
      public function play(param1:VoiceDef) : void
      {
         voiceManager.playVoice(param1);
         phase = 1;
      }
      
      public function advanceTime(param1:Number) : void
      {
         if(!voiceManager.updateVoice() && phase == 2)
         {
            phase = 3;
         }
      }
      
      public function isPlaying() : Boolean
      {
         return phase != 0;
      }
      
      private function show(param1:String, param2:int, param3:Array) : void
      {
         var name:String = param1;
         var position:int = param2;
         var offset:Array = param3;
         if(position == 0)
         {
            finishTween();
            setVisible(true);
            rightSerifText.text#2 = name;
            displaySprite.x = rightDefaultX + (!!offset ? offset[0] : 0);
            displaySprite.y = defaultY + (!!offset ? offset[1] : 0);
            startTween("show",false,function():void
            {
               if(phase == 1)
               {
                  phase = 2;
               }
            });
         }
         else
         {
            TweenAnimator.finishItself(leftSerifGroup);
            leftSerifGroup.visible = true;
            leftSerifText.text#2 = name;
            leftSerifGroup.x = leftDefaultX + (!!offset ? offset[0] : 0);
            leftSerifGroup.y = defaultY + (!!offset ? offset[1] : 0);
            TweenAnimator.startItself(leftSerifGroup,"show",false,function():void
            {
               if(phase == 1)
               {
                  phase = 2;
               }
            });
         }
      }
      
      private function hide(param1:String, param2:int) : void
      {
         var name:String = param1;
         var position:int = param2;
         if(position == 0)
         {
            if(rightSerifText.text#2 != name)
            {
               return;
            }
            startTween("hide",false,function():void
            {
               setVisible(false);
               if(phase == 3)
               {
                  phase = 0;
               }
            });
         }
         else
         {
            if(leftSerifText.text#2 != name)
            {
               return;
            }
            TweenAnimator.startItself(leftSerifGroup,"hide",false,function():void
            {
               leftSerifGroup.visible = false;
               if(phase == 3)
               {
                  phase = 0;
               }
            });
         }
      }
      
      public function dispose() : void
      {
         rightSerifText = null;
         leftSerifGroup = null;
         leftSerifText = null;
         if(voiceManager)
         {
            voiceManager.dispose();
            voiceManager = null;
         }
      }
   }
}
