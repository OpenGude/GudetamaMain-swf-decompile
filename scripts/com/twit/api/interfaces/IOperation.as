package com.twit.api.interfaces
{
   import flash.events.IEventDispatcher;
   
   public interface IOperation extends IEventDispatcher
   {
       
      
      function execute() : void;
   }
}
