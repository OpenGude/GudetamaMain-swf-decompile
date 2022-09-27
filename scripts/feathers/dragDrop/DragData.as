package feathers.dragDrop
{
   public class DragData
   {
       
      
      protected var _data:Object;
      
      public function DragData()
      {
         _data = {};
         super();
      }
      
      public function hasDataForFormat(param1:String) : Boolean
      {
         return this._data.hasOwnProperty(param1);
      }
      
      public function getDataForFormat(param1:String) : *
      {
         if(this._data.hasOwnProperty(param1))
         {
            return this._data[param1];
         }
         return undefined;
      }
      
      public function setDataForFormat(param1:String, param2:*) : void
      {
         this._data[param1] = param2;
      }
      
      public function clearDataForFormat(param1:String) : *
      {
         var _loc2_:* = undefined;
         if(this._data.hasOwnProperty(param1))
         {
            _loc2_ = this._data[param1];
         }
         delete this._data[param1];
         return _loc2_;
      }
   }
}
