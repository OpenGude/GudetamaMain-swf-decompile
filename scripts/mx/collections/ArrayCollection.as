package mx.collections
{
   import flash.utils.IDataInput;
   import flash.utils.IDataOutput;
   import flash.utils.IExternalizable;
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class ArrayCollection extends ListCollectionView implements IExternalizable
   {
      
      mx_internal static const VERSION:String = "3.0.0.0";
       
      
      public function ArrayCollection(param1:Array = null)
      {
         super();
         this.source#2 = param1;
      }
      
      public function set source#2(param1:Array) : void
      {
         list = new ArrayList(param1);
      }
      
      public function readExternal(param1:IDataInput) : void
      {
         if(list is IExternalizable)
         {
            IExternalizable(list).readExternal(param1);
         }
         else
         {
            source#2 = param1.readObject() as Array;
         }
      }
      
      public function writeExternal(param1:IDataOutput) : void
      {
         if(list is IExternalizable)
         {
            IExternalizable(list).writeExternal(param1);
         }
         else
         {
            param1.writeObject(source#2);
         }
      }
      
      [Bindable("listChanged")]
      public function get source#2() : Array
      {
         if(list && list is ArrayList)
         {
            return ArrayList(list).source#2;
         }
         return null;
      }
   }
}
