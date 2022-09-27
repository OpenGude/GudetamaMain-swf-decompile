package gudetama.common
{
   import gudetama.data.GameSetting;
   import gudetama.data.HomeSkeltonAnimation;
   import gudetama.data.UserDataWrapper;
   import gudetama.data.compati.HomeDecoData;
   import gudetama.data.compati.StampDef;
   import muku.core.TaskQueue;
   import starling.core.Starling;
   import starling.display.Image;
   import starling.display.Sprite;
   
   public class HomeDecoUtil
   {
      
      private static var count:int = -1;
      
      private static var prepearDecoListlen:int;
      
      private static var dacoDataList:Array;
      
      private static var decofinishcallback:Function;
      
      private static var capturedWidth:Number;
      
      private static var capturedHeight:Number;
      
      private static var stampLayer:Sprite;
       
      
      public function HomeDecoUtil()
      {
         super();
      }
      
      private static function addStampFunction(param1:int, param2:Function = null) : void
      {
         if(param2)
         {
            decofinishcallback = param2;
         }
         if(param1 != prepearDecoListlen)
         {
            addDecoDataToStamp(param1,addStampFunction);
         }
         else
         {
            decofinishcallback();
         }
      }
      
      private static function addDecoDataToStamp(param1:int, param2:Function) : void
      {
         var _index:int = param1;
         var _callback:Function = param2;
         var decoData:HomeDecoData = dacoDataList[_index] as HomeDecoData;
         var uniqueId:uint = decoData.index;
         var stampDef:StampDef = GameSetting.getStamp(decoData.stampId);
         var homeSkeltonAnimation:HomeSkeltonAnimation = new HomeSkeltonAnimation(decoData);
         homeSkeltonAnimation.stamp(capturedWidth,capturedHeight,function():void
         {
            if(homeSkeltonAnimation.isSpine())
            {
               stampLayer.addChild(homeSkeltonAnimation.getSkeletonAnimation());
               var _loc1_:* = Starling;
               (!!starling.core.Starling.sCurrent ? starling.core.Starling.sCurrent._juggler : null).add(homeSkeltonAnimation.getSkeletonAnimation());
            }
            else
            {
               stampLayer.addChild(homeSkeltonAnimation.getImage());
            }
            _callback(_index + 1);
         });
      }
      
      public static function setDecoData(param1:Array, param2:Image, param3:Sprite, param4:TaskQueue) : void
      {
         var decodatalist:Array = param1;
         var _roomImage:Image = param2;
         var _stampLayer:Sprite = param3;
         var _queue:TaskQueue = param4;
         if(!decodatalist)
         {
            return;
         }
         prepearDecoListlen = decodatalist.length;
         dacoDataList = decodatalist;
         capturedWidth = _roomImage.texture.width;
         capturedHeight = _roomImage.texture.height;
         stampLayer = _stampLayer;
         _queue.addTask(function():void
         {
            addStampFunction(0,function():void
            {
               _queue.taskDone();
            });
         });
      }
      
      public static function enableHomeDeco() : Boolean
      {
         if(GameSetting.hasScreeningFlag(14))
         {
            return UserDataWrapper.featurePart.existsFeature(16);
         }
         return false;
      }
   }
}
