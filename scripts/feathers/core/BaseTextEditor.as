package feathers.core
{
   import feathers.text.FontStylesSet;
   import starling.events.Event;
   
   public class BaseTextEditor extends FeathersControl implements IStateObserver
   {
       
      
      protected var _text:String = "";
      
      protected var _stateContext:IStateContext;
      
      protected var _fontStyles:FontStylesSet;
      
      public function BaseTextEditor()
      {
         super();
      }
      
      public function get text#2() : String
      {
         return this._text;
      }
      
      public function set text#2(param1:String) : void
      {
         if(!param1)
         {
            param1 = "";
         }
         if(this._text == param1)
         {
            return;
         }
         this._text = param1;
         this.invalidate("data");
         this.dispatchEventWith("change");
      }
      
      public function get stateContext() : IStateContext
      {
         return this._stateContext;
      }
      
      public function set stateContext(param1:IStateContext) : void
      {
         if(this._stateContext === param1)
         {
            return;
         }
         if(this._stateContext)
         {
            this._stateContext.removeEventListener("stageChange",stateContext_stateChangeHandler);
         }
         this._stateContext = param1;
         if(this._stateContext)
         {
            this._stateContext.addEventListener("stageChange",stateContext_stateChangeHandler);
         }
         this.invalidate("state");
      }
      
      public function get fontStyles() : FontStylesSet
      {
         return this._fontStyles;
      }
      
      public function set fontStyles(param1:FontStylesSet) : void
      {
         if(this._fontStyles === param1)
         {
            return;
         }
         if(this._fontStyles !== null)
         {
            this._fontStyles.removeEventListener("change",fontStylesSet_changeHandler);
         }
         this._fontStyles = param1;
         if(this._fontStyles !== null)
         {
            this._fontStyles.addEventListener("change",fontStylesSet_changeHandler);
         }
         this.invalidate("styles");
      }
      
      override public function dispose() : void
      {
         this.stateContext = null;
         this.fontStyles = null;
         super.dispose();
      }
      
      protected function stateContext_stateChangeHandler(param1:Event) : void
      {
         this.invalidate("state");
      }
      
      protected function fontStylesSet_changeHandler(param1:Event) : void
      {
         this.invalidate("styles");
      }
   }
}
