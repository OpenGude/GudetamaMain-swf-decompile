package feathers.data
{
   import starling.events.EventDispatcher;
   
   public class ListCollection extends EventDispatcher
   {
       
      
      protected var _localDataDescriptor:ArrayListCollectionDataDescriptor;
      
      protected var _localData:Array;
      
      protected var _data:Object;
      
      protected var _dataDescriptor:IListCollectionDataDescriptor;
      
      protected var _pendingRefresh:Boolean = false;
      
      protected var _filterFunction:Function;
      
      public function ListCollection(param1:Object = null)
      {
         super();
         if(!param1)
         {
            param1 = [];
         }
         this.data#2 = param1;
      }
      
      public function get data#2() : Object
      {
         return _data;
      }
      
      public function set data#2(param1:Object) : void
      {
         if(this._data == param1)
         {
            return;
         }
         this._data = param1;
         if(this._data is Array && !(this._dataDescriptor is ArrayListCollectionDataDescriptor))
         {
            this._dataDescriptor = new ArrayListCollectionDataDescriptor();
         }
         else if(this._data is Vector.<Number> && !(this._dataDescriptor is VectorNumberListCollectionDataDescriptor))
         {
            this._dataDescriptor = new VectorNumberListCollectionDataDescriptor();
         }
         else if(this._data is Vector.<int> && !(this._dataDescriptor is VectorIntListCollectionDataDescriptor))
         {
            this._dataDescriptor = new VectorIntListCollectionDataDescriptor();
         }
         else if(this._data is Vector.<uint> && !(this._dataDescriptor is VectorUintListCollectionDataDescriptor))
         {
            this._dataDescriptor = new VectorUintListCollectionDataDescriptor();
         }
         else if(this._data is Vector.<*> && !(this._dataDescriptor is VectorListCollectionDataDescriptor))
         {
            this._dataDescriptor = new VectorListCollectionDataDescriptor();
         }
         else if(this._data is XMLList && !(this._dataDescriptor is XMLListListCollectionDataDescriptor))
         {
            this._dataDescriptor = new XMLListListCollectionDataDescriptor();
         }
         if(this._data === null)
         {
            this._dataDescriptor = null;
         }
         this.dispatchEventWith("reset");
         this.dispatchEventWith("change");
      }
      
      public function get dataDescriptor() : IListCollectionDataDescriptor
      {
         return this._dataDescriptor;
      }
      
      public function set dataDescriptor(param1:IListCollectionDataDescriptor) : void
      {
         if(this._dataDescriptor == param1)
         {
            return;
         }
         this._dataDescriptor = param1;
         this.dispatchEventWith("reset");
         this.dispatchEventWith("change");
      }
      
      public function get filterFunction() : Function
      {
         return this._filterFunction;
      }
      
      public function set filterFunction(param1:Function) : void
      {
         if(this._filterFunction === param1)
         {
            return;
         }
         this._filterFunction = param1;
         this._pendingRefresh = true;
         this.dispatchEventWith("change");
         this.dispatchEventWith("filterChange");
      }
      
      public function get length() : int
      {
         if(!this._dataDescriptor)
         {
            return 0;
         }
         if(this._pendingRefresh)
         {
            this.refresh();
         }
         if(this._localData !== null)
         {
            return this._localDataDescriptor.getLength(this._localData);
         }
         return this._dataDescriptor.getLength(this._data);
      }
      
      public function refreshFilter() : void
      {
         if(this._filterFunction === null)
         {
            return;
         }
         this._pendingRefresh = true;
         this.dispatchEventWith("change");
         this.dispatchEventWith("filterChange");
      }
      
      protected function refresh() : void
      {
         var _loc1_:* = null;
         var _loc3_:int = 0;
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         var _loc2_:* = null;
         this._pendingRefresh = false;
         switch(_loc1_)
         {
            case null:
               this._localData = null;
               this._localDataDescriptor = null;
               break;
            case null:
               _loc1_ = [];
               addr33:
               _loc3_ = this._dataDescriptor.getLength(this._data);
               _loc5_ = 0;
               _loc4_ = 0;
               while(_loc4_ < _loc3_)
               {
                  _loc2_ = this._dataDescriptor.getItemAt(this._data,_loc4_);
                  if(this._filterFunction(_loc2_))
                  {
                     _loc1_[_loc5_] = _loc2_;
                     _loc5_++;
                  }
                  _loc4_++;
               }
               this._localData = _loc1_;
               this._localDataDescriptor = new ArrayListCollectionDataDescriptor();
               break;
            default:
               _loc1_.length = 0;
               §§goto(addr33);
         }
      }
      
      public function updateItemAt(param1:int) : void
      {
         this.dispatchEventWith("updateItem",false,param1);
      }
      
      public function updateAll() : void
      {
         this.dispatchEventWith("updateAll");
      }
      
      public function getItemAt(param1:int) : Object
      {
         if(this._pendingRefresh)
         {
            this.refresh();
         }
         if(this._localData !== null)
         {
            return this._localDataDescriptor.getItemAt(this._localData,param1);
         }
         return this._dataDescriptor.getItemAt(this._data,param1);
      }
      
      public function getItemIndex(param1:Object) : int
      {
         if(this._pendingRefresh)
         {
            this.refresh();
         }
         if(this._localData !== null)
         {
            return this._localDataDescriptor.getItemIndex(this._localData,param1);
         }
         return this._dataDescriptor.getItemIndex(this._data,param1);
      }
      
      public function addItemAt(param1:Object, param2:int) : void
      {
         var _loc4_:* = null;
         var _loc3_:int = 0;
         var _loc5_:Boolean = false;
         if(this._pendingRefresh)
         {
            this.refresh();
         }
         if(this._localData !== null)
         {
            if(param2 < this._localDataDescriptor.getLength(this._localData))
            {
               _loc4_ = this._localDataDescriptor.getItemAt(this._localData,param2);
               _loc3_ = this._dataDescriptor.getItemIndex(this._data,_loc4_);
            }
            else
            {
               _loc3_ = this._dataDescriptor.getLength(this._data);
            }
            this._dataDescriptor.addItemAt(this._data,param1,_loc3_);
            _loc5_ = true;
            if(this._filterFunction !== null)
            {
               _loc5_ = this._filterFunction(param1);
            }
            if(_loc5_)
            {
               this._localDataDescriptor.addItemAt(this._localData,param1,param2);
               this.dispatchEventWith("change");
               this.dispatchEventWith("addItem",false,param2);
            }
         }
         else
         {
            this._dataDescriptor.addItemAt(this._data,param1,param2);
            this.dispatchEventWith("change");
            this.dispatchEventWith("addItem",false,param2);
         }
      }
      
      public function removeItemAt(param1:int) : Object
      {
         var _loc2_:* = null;
         var _loc3_:int = 0;
         if(this._pendingRefresh)
         {
            this.refresh();
         }
         if(this._localData !== null)
         {
            _loc2_ = this._localDataDescriptor.removeItemAt(this._localData,param1);
            _loc3_ = this._dataDescriptor.getItemIndex(this._data,_loc2_);
            this._dataDescriptor.removeItemAt(this._data,_loc3_);
         }
         else
         {
            _loc2_ = this._dataDescriptor.removeItemAt(this._data,param1);
         }
         this.dispatchEventWith("change");
         this.dispatchEventWith("removeItem",false,param1);
         return _loc2_;
      }
      
      public function removeItem(param1:Object) : void
      {
         var _loc2_:int = this.getItemIndex(param1);
         if(_loc2_ >= 0)
         {
            this.removeItemAt(_loc2_);
         }
      }
      
      public function removeAll() : void
      {
         if(this._pendingRefresh)
         {
            this.refresh();
         }
         if(this.length === 0)
         {
            return;
         }
         if(this._localData !== null)
         {
            this._localDataDescriptor.removeAll(this._localData);
         }
         else
         {
            this._dataDescriptor.removeAll(this._data);
         }
         this.dispatchEventWith("removeAll");
         this.dispatchEventWith("change");
      }
      
      public function setItemAt(param1:Object, param2:int) : void
      {
         var _loc4_:* = null;
         var _loc3_:int = 0;
         var _loc5_:Boolean = false;
         if(this._pendingRefresh)
         {
            this.refresh();
         }
         if(this._filterFunction !== null)
         {
            _loc4_ = this._localDataDescriptor.getItemAt(this._localData,param2);
            _loc3_ = this._dataDescriptor.getItemIndex(this._data,_loc4_);
            this._dataDescriptor.setItemAt(this._data,param1,_loc3_);
            if(this._filterFunction !== null)
            {
               if(_loc5_ = this._filterFunction(param1))
               {
                  this._localDataDescriptor.setItemAt(this._localData,param1,param2);
                  this.dispatchEventWith("change");
                  this.dispatchEventWith("replaceItem",false,param2);
                  return;
               }
               this._localDataDescriptor.removeItemAt(this._localData,param2);
               this.dispatchEventWith("change");
               this.dispatchEventWith("removeItem",false,param2);
            }
         }
         else
         {
            this._dataDescriptor.setItemAt(this._data,param1,param2);
            this.dispatchEventWith("change");
            this.dispatchEventWith("replaceItem",false,param2);
         }
      }
      
      public function addItem(param1:Object) : void
      {
         this.addItemAt(param1,this.length);
      }
      
      public function push(param1:Object) : void
      {
         this.addItemAt(param1,this.length);
      }
      
      public function addAll(param1:ListCollection) : void
      {
         var _loc4_:int = 0;
         var _loc2_:* = null;
         var _loc3_:int = param1.length;
         _loc4_ = 0;
         while(_loc4_ < _loc3_)
         {
            _loc2_ = param1.getItemAt(_loc4_);
            this.addItem(_loc2_);
            _loc4_++;
         }
      }
      
      public function addAllAt(param1:ListCollection, param2:int) : void
      {
         var _loc5_:int = 0;
         var _loc3_:* = null;
         var _loc4_:int = param1.length;
         var _loc6_:* = param2;
         _loc5_ = 0;
         while(_loc5_ < _loc4_)
         {
            _loc3_ = param1.getItemAt(_loc5_);
            this.addItemAt(_loc3_,_loc6_);
            _loc6_++;
            _loc5_++;
         }
      }
      
      public function pop() : Object
      {
         return this.removeItemAt(this.length - 1);
      }
      
      public function unshift(param1:Object) : void
      {
         this.addItemAt(param1,0);
      }
      
      public function shift() : Object
      {
         return this.removeItemAt(0);
      }
      
      public function contains(param1:Object) : Boolean
      {
         return this.getItemIndex(param1) >= 0;
      }
      
      public function dispose(param1:Function) : void
      {
         var _loc3_:int = 0;
         var _loc2_:* = null;
         this._filterFunction = null;
         this.refresh();
         var _loc4_:int = this.length;
         _loc3_ = 0;
         while(_loc3_ < _loc4_)
         {
            _loc2_ = this.getItemAt(_loc3_);
            param1(_loc2_);
            _loc3_++;
         }
      }
   }
}
