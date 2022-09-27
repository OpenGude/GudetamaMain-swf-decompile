package gudetama.data.compati
{
   import flash.utils.ByteArray;
   
   public class UsefulDef
   {
      
      public static const USABLE_HOME:int = 1;
      
      public static const USABLE_COOKING:int = 2;
      
      public static const USABLE_HURRY:int = 4;
       
      
      public var id#2:int;
      
      public var rsrc:int;
      
      public var privately:Boolean;
      
      public var name#2:String;
      
      public var desc:String;
      
      public var usable:int;
      
      public var event:Boolean;
      
      public var abilities:Array;
      
      public var assistAbilities:Array;
      
      public var friendlyValue:int;
      
      public var conditionDesc:String;
      
      public var sortIndex:int;
      
      public var price:ItemParam;
      
      public var isNew:Boolean;
      
      public var eventId:int;
      
      public var kitchenwareTypes:ByteArray;
      
      public var possessionLimit:int;
      
      public var purchaseResetHourOffset:int;
      
      public function UsefulDef()
      {
         super();
      }
      
      public function isUsable(param1:int) : Boolean
      {
         return (usable & param1) != 0;
      }
      
      public function hasAbility() : Boolean
      {
         return abilities != null && abilities.length > 0;
      }
      
      public function existsFlags(param1:int) : Boolean
      {
         if(!hasAbility())
         {
            return false;
         }
         for each(var _loc2_ in abilities)
         {
            if(_loc2_.existsFlags(param1))
            {
               return true;
            }
         }
         return false;
      }
      
      public function getTypesAtFlags(param1:int) : Array
      {
         var _loc3_:int = 0;
         var _loc4_:* = null;
         if(!hasAbility())
         {
            return null;
         }
         var _loc2_:Array = null;
         _loc3_ = 0;
         while(_loc3_ < abilities.length)
         {
            if((_loc4_ = abilities[_loc3_]).existsFlags(param1))
            {
               if(_loc2_ == null)
               {
                  _loc2_ = [];
               }
               _loc2_.push(_loc4_.type);
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function existsAbilityKind(param1:int) : Boolean
      {
         if(!abilities)
         {
            return false;
         }
         for each(var _loc2_ in abilities)
         {
            if(_loc2_.equalsKind(param1))
            {
               return true;
            }
         }
         return false;
      }
      
      public function getUniqueType() : int
      {
         for each(var _loc1_ in abilities)
         {
            if(_loc1_.existsFlags(512))
            {
               return _loc1_.type;
            }
         }
         return -1;
      }
      
      public function sumAbilities(param1:int) : int
      {
         var _loc3_:int = 0;
         for each(var _loc2_ in abilities)
         {
            if(_loc2_.type == param1)
            {
               _loc3_ += _loc2_.getValue(0);
            }
         }
         return _loc3_;
      }
      
      public function sumAssistAbilities(param1:int) : int
      {
         var _loc3_:int = 0;
         for each(var _loc2_ in assistAbilities)
         {
            if(_loc2_.type == param1)
            {
               _loc3_ += _loc2_.getValue(0);
            }
         }
         return _loc3_;
      }
      
      public function hasSuccessInAssistAbilities() : Boolean
      {
         for each(var _loc1_ in assistAbilities)
         {
            if(_loc1_.equalsKind(3))
            {
               return true;
            }
         }
         return false;
      }
      
      public function hasHappeningInAssistAbilities() : Boolean
      {
         for each(var _loc1_ in assistAbilities)
         {
            if(_loc1_.equalsKind(4))
            {
               return true;
            }
         }
         return false;
      }
      
      public function read(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         id#2 = param1.readInt();
         rsrc = param1.readInt();
         privately = param1.readBoolean();
         name#2 = param1.readUTF();
         desc = param1.readUTF();
         usable = param1.readInt();
         event = param1.readBoolean();
         abilities = CompatibleDataIO.read(param1) as Array;
         assistAbilities = CompatibleDataIO.read(param1) as Array;
         friendlyValue = param1.readInt();
         conditionDesc = param1.readUTF();
         sortIndex = param1.readInt();
         price = CompatibleDataIO.read(param1) as ItemParam;
         isNew = param1.readBoolean();
         eventId = param1.readInt();
         kitchenwareTypes = CompatibleDataIO.read(param1) as ByteArray;
         possessionLimit = param1.readInt();
         purchaseResetHourOffset = param1.readByte();
      }
      
      public function write(param1:ByteArray) : void
      {
         param1.writeInt(id#2);
         param1.writeInt(rsrc);
         param1.writeBoolean(privately);
         param1.writeUTF(name#2);
         param1.writeUTF(desc);
         param1.writeInt(usable);
         param1.writeBoolean(event);
         CompatibleDataIO.write(param1,abilities,1);
         CompatibleDataIO.write(param1,assistAbilities,1);
         param1.writeInt(friendlyValue);
         param1.writeUTF(conditionDesc);
         param1.writeInt(sortIndex);
         CompatibleDataIO.write(param1,price);
         param1.writeBoolean(isNew);
         param1.writeInt(eventId);
         CompatibleDataIO.write(param1,kitchenwareTypes,4);
         param1.writeInt(possessionLimit);
         param1.writeByte(purchaseResetHourOffset);
      }
   }
}
