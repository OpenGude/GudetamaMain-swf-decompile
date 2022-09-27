package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class HomeDecoData
   {
       
      
      public var stampId:int;
      
      public var index:int;
      
      public var x:Number;
      
      public var y:Number;
      
      public var rotation:Number;
      
      public var scale:Number;
      
      public var screenPosRateX:Number;
      
      public var screenPosRateY:Number;
      
      public var isSpain:Boolean;
      
      public function HomeDecoData()
      {
         super();
      }
      
      public static function convert(param1:Object) : HomeDecoData
      {
         var _loc2_:HomeDecoData = new HomeDecoData();
         _loc2_.stampId = param1.stampId;
         _loc2_.index = param1.index;
         _loc2_.x = param1.x;
         _loc2_.y = param1.y;
         _loc2_.rotation = param1.rotation;
         _loc2_.scale = param1.scale;
         _loc2_.screenPosRateX = param1.screenPosRateX;
         _loc2_.screenPosRateY = param1.screenPosRateY;
         _loc2_.isSpain = param1.isSpain;
         return _loc2_;
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         stampId = param1.readInt();
         index = param1.readShort();
         x = param1.readDouble();
         y = param1.readDouble();
         rotation = param1.readFloat();
         scale = param1.readFloat();
         screenPosRateX = param1.readFloat();
         screenPosRateY = param1.readFloat();
         isSpain = param1.readBoolean();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(stampId);
         param1.writeShort(index);
         param1.writeDouble(x);
         param1.writeDouble(y);
         param1.writeFloat(rotation);
         param1.writeFloat(scale);
         param1.writeFloat(screenPosRateX);
         param1.writeFloat(screenPosRateY);
         param1.writeBoolean(isSpain);
      }
   }
}
