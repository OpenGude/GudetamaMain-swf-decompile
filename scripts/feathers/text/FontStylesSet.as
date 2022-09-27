package feathers.text
{
   import feathers.core.IFeathersControl;
   import feathers.core.IStateContext;
   import feathers.core.IStateObserver;
   import feathers.core.IToggle;
   import starling.events.Event;
   import starling.events.EventDispatcher;
   import starling.text.TextFormat;
   
   public class FontStylesSet extends EventDispatcher
   {
       
      
      protected var _stateToFormat:Object;
      
      protected var _format:TextFormat;
      
      protected var _disabledFormat:TextFormat;
      
      protected var _selectedFormat:TextFormat;
      
      public function FontStylesSet()
      {
         super();
      }
      
      public function get format() : TextFormat
      {
         return this._format;
      }
      
      public function set format(param1:TextFormat) : void
      {
         if(this._format === param1)
         {
            return;
         }
         if(param1 === null && this._format !== null)
         {
            this._format.removeEventListener("change",format_changeHandler);
            this._format = null;
         }
         else if(param1 !== null)
         {
            if(this._format === null)
            {
               this._format = param1.clone();
               this._format.addEventListener("change",format_changeHandler);
            }
            else
            {
               this._format.copyFrom(param1);
            }
         }
         this.dispatchEventWith("change");
      }
      
      public function get disabledFormat() : TextFormat
      {
         return this._disabledFormat;
      }
      
      public function set disabledFormat(param1:TextFormat) : void
      {
         if(this._disabledFormat === param1)
         {
            return;
         }
         if(param1 === null && this._disabledFormat !== null)
         {
            this._disabledFormat.removeEventListener("change",format_changeHandler);
            this._disabledFormat = null;
         }
         else if(param1 !== null)
         {
            if(this._disabledFormat === null)
            {
               this._disabledFormat = param1.clone();
               this._disabledFormat.addEventListener("change",format_changeHandler);
            }
            else
            {
               this._disabledFormat.copyFrom(param1);
            }
         }
         this.dispatchEventWith("change");
      }
      
      public function get selectedFormat() : TextFormat
      {
         return this._selectedFormat;
      }
      
      public function set selectedFormat(param1:TextFormat) : void
      {
         if(this._selectedFormat === param1)
         {
            return;
         }
         if(param1 === null && this._selectedFormat !== null)
         {
            this._selectedFormat.removeEventListener("change",format_changeHandler);
            this._selectedFormat = null;
         }
         else if(param1 !== null)
         {
            if(this._selectedFormat === null)
            {
               this._selectedFormat = param1.clone();
               this._selectedFormat.addEventListener("change",format_changeHandler);
            }
            else
            {
               this._selectedFormat.copyFrom(param1);
            }
         }
         this.dispatchEventWith("change");
      }
      
      public function getFormatForState(param1:String) : TextFormat
      {
         if(this._stateToFormat === null)
         {
            return null;
         }
         return TextFormat(this._stateToFormat[param1]);
      }
      
      public function setFormatForState(param1:String, param2:TextFormat) : void
      {
         var _loc3_:TextFormat = null;
         if(param2 !== null)
         {
            if(this._stateToFormat === null)
            {
               this._stateToFormat = {};
            }
            else
            {
               _loc3_ = TextFormat(this._stateToFormat[param1]);
            }
            if(_loc3_ === null)
            {
               _loc3_ = param2.clone();
               _loc3_.addEventListener("change",format_changeHandler);
               this._stateToFormat[param1] = _loc3_;
            }
            else
            {
               _loc3_.copyFrom(param2);
            }
         }
         else
         {
            switch(_loc3_)
            {
               default:
                  _loc3_.removeEventListener("change",format_changeHandler);
                  delete this._stateToFormat[param1];
                  break;
               case null:
               case null:
            }
         }
      }
      
      public function getTextFormatForTarget(param1:IFeathersControl) : TextFormat
      {
         var _loc4_:* = null;
         var _loc2_:* = null;
         var _loc3_:* = null;
         if(param1 is IStateObserver)
         {
            _loc2_ = IStateObserver(param1).stateContext;
         }
         switch(_loc2_)
         {
            case null:
               if(this._disabledFormat !== null && !param1.isEnabled)
               {
                  _loc4_ = this._disabledFormat;
                  break;
               }
               break;
            default:
               _loc3_ = _loc2_.currentState;
               if(_loc3_ in this._stateToFormat)
               {
                  _loc4_ = TextFormat(this._stateToFormat[_loc3_]);
               }
            case null:
               if(_loc4_ === null && this._disabledFormat !== null && _loc2_ is IFeathersControl && !IFeathersControl(_loc2_).isEnabled)
               {
                  _loc4_ = this._disabledFormat;
               }
               if(_loc4_ === null && this._selectedFormat !== null && _loc2_ is IToggle && IToggle(_loc2_).isSelected)
               {
                  _loc4_ = this._selectedFormat;
               }
         }
         if(_loc4_ === null)
         {
            _loc4_ = this._format;
         }
         return _loc4_;
      }
      
      protected function format_changeHandler(param1:Event) : void
      {
         this.dispatchEventWith("change");
      }
   }
}
