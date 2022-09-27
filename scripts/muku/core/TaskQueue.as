package muku.core
{
   public class TaskQueue
   {
       
      
      private var execQueue:Vector.<Function>;
      
      private var callbacks:Vector.<Function>;
      
      protected var started:Boolean;
      
      private var numRequested:int;
      
      private var numDone:int;
      
      public function TaskQueue()
      {
         super();
         execQueue = new Vector.<Function>();
         callbacks = new Vector.<Function>();
      }
      
      public static function get IMMEDIATE() : TaskQueue
      {
         return ImmediateTaskQueue.SINGLETON;
      }
      
      public function addTask(param1:Function) : void
      {
         numRequested++;
         if(started)
         {
            param1();
         }
         else
         {
            execQueue.push(param1);
         }
      }
      
      public function taskDone() : void
      {
         numDone++;
         var ratio:Number = numDone / numRequested;
         var func:Function = function():void
         {
            ratio = numDone / numRequested;
            for each(var _loc1_ in callbacks)
            {
               _loc1_(ratio);
            }
            if(ratio >= 1)
            {
               callbacks.length = 0;
            }
         };
         if(ratio >= 1)
         {
            MukuGlobal.engine.addSequentialCallback(func);
         }
         else
         {
            func();
         }
      }
      
      public function startTask(param1:Function = null) : void
      {
         if(started)
         {
            return;
         }
         if(param1)
         {
            callbacks.push(param1);
         }
         started = true;
         if(execQueue.length == 0)
         {
            for each(var _loc2_ in callbacks)
            {
               _loc2_(1);
            }
         }
         else
         {
            for each(var _loc3_ in execQueue)
            {
               _loc3_();
            }
            execQueue.length = 0;
         }
      }
      
      public function isStarted() : Boolean
      {
         return started;
      }
      
      public function registerOnProgress(param1:Function) : void
      {
         if(started)
         {
            if(numRequested == 0)
            {
               param1(1);
            }
            else
            {
               param1(numDone / numRequested);
               callbacks.push(param1);
            }
         }
         else
         {
            callbacks.push(param1);
         }
      }
      
      public function isFinished() : Boolean
      {
         return started && numDone >= numRequested;
      }
      
      public function getTraceString() : String
      {
         return "TaskQueue: " + started + ", " + numDone + ", " + numRequested;
      }
      
      public function get numRest() : int
      {
         return numRequested - numDone;
      }
      
      public function end() : void
      {
         execQueue.length = 0;
         callbacks.length = 0;
         numRequested = 2147483647;
         numDone = 0;
      }
      
      public function reset__deprecated() : void
      {
         execQueue.length = 0;
         callbacks.length = 0;
         numRequested = 0;
         numDone = 0;
         started = false;
      }
   }
}

import muku.core.TaskQueue;

class ImmediateTaskQueue extends TaskQueue
{
   
   public static const SINGLETON:ImmediateTaskQueue = new ImmediateTaskQueue();
    
   
   function ImmediateTaskQueue()
   {
      super();
   }
   
   override public function addTask(param1:Function) : void
   {
      started = true;
      param1();
   }
   
   override public function taskDone() : void
   {
   }
}
