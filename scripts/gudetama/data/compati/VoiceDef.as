package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class VoiceDef
   {
      
      public static const TYPE_PRIVATELY:int = 0;
      
      public static const TYPE_NUMBERING:int = 1;
      
      public static const TYPE_EVENT:int = 2;
      
      public static const POS_RIGHT:int = 0;
      
      public static const POS_LEFT:int = 1;
       
      
      public var id#2:int;
      
      public var rsrc:int;
      
      public var gudetamaId:int;
      
      public var type:int;
      
      public var number:int;
      
      public var name#2:String;
      
      public var position:int;
      
      public var offset:Array;
      
      public var params#2:Array;
      
      public function VoiceDef()
      {
         super();
      }
      
      public function get length() : int
      {
         var _loc1_:int = 0;
         if(rsrc > 0)
         {
            _loc1_ = 1;
         }
         if(params#2)
         {
            _loc1_ += params#2.length;
         }
         return _loc1_;
      }
      
      public function getResources(param1:int) : Array
      {
         var _loc3_:int = -1;
         if(rsrc > 0)
         {
            _loc3_++;
            if(_loc3_ == param1)
            {
               return [rsrc];
            }
         }
         if(params#2)
         {
            for each(var _loc2_ in params#2)
            {
               _loc3_++;
               if(_loc3_ == param1)
               {
                  return _loc2_.resources;
               }
            }
         }
         return null;
      }
      
      public function getNames(param1:int) : Array
      {
         var _loc3_:int = -1;
         if(rsrc > 0)
         {
            _loc3_++;
            if(_loc3_ == param1)
            {
               return [name#2];
            }
         }
         if(params#2)
         {
            for each(var _loc2_ in params#2)
            {
               _loc3_++;
               if(_loc3_ == param1)
               {
                  return _loc2_.names;
               }
            }
         }
         return null;
      }
      
      public function getDelays(param1:int) : Array
      {
         var _loc3_:int = -1;
         if(rsrc > 0)
         {
            _loc3_++;
            if(_loc3_ == param1)
            {
               return [0];
            }
         }
         if(params#2)
         {
            for each(var _loc2_ in params#2)
            {
               _loc3_++;
               if(_loc3_ == param1)
               {
                  return _loc2_.delays;
               }
            }
         }
         return null;
      }
      
      public function getPositions(param1:int) : Array
      {
         var _loc3_:int = -1;
         if(rsrc > 0)
         {
            _loc3_++;
            if(_loc3_ == param1)
            {
               return [position];
            }
         }
         if(params#2)
         {
            for each(var _loc2_ in params#2)
            {
               _loc3_++;
               if(_loc3_ == param1)
               {
                  return _loc2_.positions;
               }
            }
         }
         return null;
      }
      
      public function getOffsets(param1:int) : Array
      {
         var _loc3_:int = -1;
         if(rsrc > 0)
         {
            _loc3_++;
            if(_loc3_ == param1)
            {
               return [offset];
            }
         }
         if(params#2)
         {
            for each(var _loc2_ in params#2)
            {
               _loc3_++;
               if(_loc3_ == param1)
               {
                  return _loc2_.offsets;
               }
            }
         }
         return null;
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         id#2 = param1.readInt();
         rsrc = param1.readInt();
         gudetamaId = param1.readInt();
         type = param1.readByte();
         number = param1.readInt();
         name#2 = param1.readUTF();
         position = param1.readInt();
         offset = CompatibleDataIO.read(param1) as Array;
         params#2 = CompatibleDataIO.read(param1) as Array;
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(id#2);
         param1.writeInt(rsrc);
         param1.writeInt(gudetamaId);
         param1.writeByte(type);
         param1.writeInt(number);
         param1.writeUTF(name#2);
         param1.writeInt(position);
         CompatibleDataIO.write(param1,offset,2);
         CompatibleDataIO.write(param1,params#2,1);
      }
   }
}
