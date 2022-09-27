package gudetama.data
{
   import gudetama.data.compati.ConvertParam;
   
   public class MailDataWrapper
   {
       
      
      private var list:Array;
      
      public function MailDataWrapper()
      {
         super();
         list = [];
      }
      
      public function addItemParam(param1:Object) : void
      {
         var _loc5_:* = null;
         var _loc2_:* = null;
         var _loc3_:* = null;
         switch(param1.kind)
         {
            case 14:
               param1.kind = 0;
               break;
            case 2:
               param1.kind = 1;
         }
         for(var _loc4_ in list)
         {
            if((_loc5_ = list[_loc4_]).kind == param1.kind && _loc5_.id == param1.id)
            {
               _loc5_.num += param1.num;
               if(param1 is ConvertParam && ConvertParam(param1).convertedItem)
               {
                  _loc2_ = ConvertParam(param1);
                  if(_loc5_ is ConvertParam && ConvertParam(_loc5_).convertedItem)
                  {
                     _loc3_ = ConvertParam(_loc5_);
                     _loc3_.originalItem.num += _loc2_.originalItem.num;
                     _loc3_.convertedItem.num += _loc2_.convertedItem.num;
                     _loc3_.convertedParam.num += _loc2_.convertedParam.num;
                  }
                  else
                  {
                     _loc2_.num = _loc5_.num;
                     list.removeAt(_loc4_);
                     list.push(param1);
                  }
               }
               return;
            }
         }
         list.push(param1);
      }
      
      public function getItemList() : Array
      {
         return list;
      }
      
      public function reset() : void
      {
         list = [];
      }
   }
}
