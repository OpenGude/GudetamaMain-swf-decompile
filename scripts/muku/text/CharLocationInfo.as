package muku.text
{
   import starling.text.BitmapChar;
   
   public class CharLocationInfo
   {
      
      public static const EMPTY_CHARA_LOCATION_INFO:Vector.<CharLocationInfo> = new Vector.<CharLocationInfo>(0);
      
      private static var sInstancePool:Vector.<CharLocationInfo> = new Vector.<CharLocationInfo>(0);
      
      private static var sVectorPool:Array = [];
       
      
      public var char:BitmapChar;
      
      public var scale:Number;
      
      public var x:Number;
      
      public var y:Number;
      
      public var color:uint;
      
      public var idx:int;
      
      public var waitCount:int;
      
      public var visible:Boolean;
      
      public var typingSpeed:Number;
      
      public var word:String;
      
      public function CharLocationInfo(param1:BitmapChar)
      {
         super();
         reset(param1);
      }
      
      public static function instanceFromPool(param1:BitmapChar) : CharLocationInfo
      {
         var _loc2_:CharLocationInfo = sInstancePool.length > 0 ? sInstancePool.pop() : new CharLocationInfo(param1);
         _loc2_.reset(param1);
         return _loc2_;
      }
      
      public static function instanceToPool(param1:CharLocationInfo) : void
      {
         param1.char = null;
         sInstancePool[sInstancePool.length] = param1;
      }
      
      public static function vectorInstanceToPool(param1:Vector.<CharLocationInfo>) : void
      {
         var _loc2_:* = null;
         while(param1.length > 0)
         {
            _loc2_ = param1.pop();
            _loc2_.char = null;
            sInstancePool[sInstancePool.length] = _loc2_;
         }
      }
      
      public static function vectorToPool(param1:Vector.<CharLocationInfo>) : void
      {
         sVectorPool[sVectorPool.length] = param1;
      }
      
      public static function vectorFromPool() : Vector.<CharLocationInfo>
      {
         var _loc1_:Vector.<CharLocationInfo> = sVectorPool.length > 0 ? sVectorPool.pop() : new Vector.<CharLocationInfo>(0);
         _loc1_.length = 0;
         return _loc1_;
      }
      
      private function reset(param1:BitmapChar) : CharLocationInfo
      {
         this.char = param1;
         this.idx = 0;
         this.waitCount = 0;
         this.visible = true;
         this.typingSpeed = 0;
         this.word = null;
         return this;
      }
   }
}
