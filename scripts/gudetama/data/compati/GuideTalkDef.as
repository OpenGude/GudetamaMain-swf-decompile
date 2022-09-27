package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class GuideTalkDef
   {
      
      public static const NONE:int = 0;
      
      public static const FRONT:int = 1;
      
      public static const LEFT:int = 2;
      
      public static const RIGHT:int = 3;
      
      public static const CENTER:int = 4;
      
      public static const WINDOW:int = 5;
      
      public static const BACKGROUND:int = 6;
      
      public static const FILL:int = 7;
      
      public static const SHUTTER:int = 8;
      
      public static const PICTURE_IMAGE:int = 9;
      
      public static const EVENT_NONE:int = -1;
      
      public static const EVENT_CHANGE:int = 0;
      
      public static const EVENT_ANIMATION:int = 1;
      
      public static const EVENT_CHOICES:int = 2;
      
      public static const EVENT_BACKGROUND:int = 3;
      
      public static const EVENT_DISAPPEAR:int = 4;
      
      public static const EVENT_TWEEN:int = 5;
      
      public static const EVENT_MUSIC:int = 6;
      
      public static const EVENT_EMOTION:int = 7;
      
      public static const EVENT_PICTURE_IMAGE:int = 8;
      
      public static const EVENT_OPPONENT_POS:int = 9;
      
      public static const EVENT_BACKGROUND_POS:int = 10;
      
      public static const EVENT_SOUND:int = 11;
      
      public static const EVENT_FOCUS_CHARACTER:int = 12;
      
      public static const EVENT_MOVIE:int = 13;
      
      public static const EVENT_BACKGROUND_SPINE:int = 14;
      
      public static const EVENT_SCREEN_EFFECT:int = 15;
      
      public static const EVENT_EXTRA:int = 16;
      
      public static const EVENT_CALLBACK:int = 17;
      
      public static const EVENT_INTERRUPTION:int = 18;
      
      public static const EVENT_GUIDE_ARROW:int = 19;
      
      public static const POS_LEFT:int = -1;
      
      public static const POS_CENTER:int = 0;
      
      public static const POS_RIGHT:int = 1;
      
      public static const EXTRA:int = -2147483648;
       
      
      public var id#2:int;
      
      public var paragraph:GuideTalkParagraphParam;
      
      public var cannotSkip:Boolean;
      
      public function GuideTalkDef()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         id#2 = param1.readInt();
         paragraph = CompatibleDataIO.read(param1) as GuideTalkParagraphParam;
         cannotSkip = param1.readBoolean();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(id#2);
         CompatibleDataIO.write(param1,paragraph);
         param1.writeBoolean(cannotSkip);
      }
   }
}
