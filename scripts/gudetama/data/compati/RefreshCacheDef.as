package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class RefreshCacheDef
   {
       
      
      public var id#2:int;
      
      public var ability:Array;
      
      public var battleitem:Array;
      
      public var boost:Array;
      
      public var effect:Array;
      
      public var emo:Array;
      
      public var field:Array;
      
      public var gacha:Array;
      
      public var image:Array;
      
      public var music:Array;
      
      public var other:Array;
      
      public var planet:Array;
      
      public var stage:Array;
      
      public var test:Array;
      
      public var ui:Array;
      
      public var upgrade:Array;
      
      public var voice:Array;
      
      public var robo:Array;
      
      public var dialog:Array;
      
      public function RefreshCacheDef()
      {
         super();
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         id#2 = param1.readInt();
         ability = CompatibleDataIO.read(param1) as Array;
         battleitem = CompatibleDataIO.read(param1) as Array;
         boost = CompatibleDataIO.read(param1) as Array;
         effect = CompatibleDataIO.read(param1) as Array;
         emo = CompatibleDataIO.read(param1) as Array;
         field = CompatibleDataIO.read(param1) as Array;
         gacha = CompatibleDataIO.read(param1) as Array;
         image = CompatibleDataIO.read(param1) as Array;
         music = CompatibleDataIO.read(param1) as Array;
         other = CompatibleDataIO.read(param1) as Array;
         planet = CompatibleDataIO.read(param1) as Array;
         stage = CompatibleDataIO.read(param1) as Array;
         test = CompatibleDataIO.read(param1) as Array;
         ui = CompatibleDataIO.read(param1) as Array;
         upgrade = CompatibleDataIO.read(param1) as Array;
         voice = CompatibleDataIO.read(param1) as Array;
         robo = CompatibleDataIO.read(param1) as Array;
         dialog = CompatibleDataIO.read(param1) as Array;
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(id#2);
         CompatibleDataIO.write(param1,ability,2);
         CompatibleDataIO.write(param1,battleitem,2);
         CompatibleDataIO.write(param1,boost,2);
         CompatibleDataIO.write(param1,effect,1);
         CompatibleDataIO.write(param1,emo,2);
         CompatibleDataIO.write(param1,field,2);
         CompatibleDataIO.write(param1,gacha,2);
         CompatibleDataIO.write(param1,image,1);
         CompatibleDataIO.write(param1,music,1);
         CompatibleDataIO.write(param1,other,1);
         CompatibleDataIO.write(param1,planet,2);
         CompatibleDataIO.write(param1,stage,2);
         CompatibleDataIO.write(param1,test,1);
         CompatibleDataIO.write(param1,ui,1);
         CompatibleDataIO.write(param1,upgrade,2);
         CompatibleDataIO.write(param1,voice,2);
         CompatibleDataIO.write(param1,robo,2);
         CompatibleDataIO.write(param1,dialog,1);
      }
   }
}
