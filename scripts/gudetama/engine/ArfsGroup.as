package gudetama.engine
{
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import gudetama.util.StringUtil;
   import muku.core.TaskQueue;
   
   public class ArfsGroup
   {
      
      private static const OTHERS:String = "others";
       
      
      private var arfsMap:Dictionary;
      
      private var dirNameList:Array;
      
      private var arfsForOthers:Arfs;
      
      private var exceptSuffix:Array;
      
      private var result:Object;
      
      private var available:Boolean = true;
      
      public function ArfsGroup(param1:String, param2:Array, param3:Array = null)
      {
         var baseDirName:String = param1;
         var dirNames:Array = param2;
         var exceptSuffix:Array = param3;
         arfsMap = new Dictionary();
         dirNameList = [];
         result = {};
         super();
         this.exceptSuffix = exceptSuffix;
         if(dirNames)
         {
            dirNameList = dirNames.concat();
            var i:int = 0;
            while(i < dirNameList.length)
            {
               if(!StringUtil.endsWith(dirNameList[i],"/"))
               {
                  dirNameList[i] += "/";
               }
               i++;
            }
            dirNameList.sort(function(param1:*, param2:*):int
            {
               if(param1.length > param2.length)
               {
                  return -1;
               }
               if(param1.length < param2.length)
               {
                  return 1;
               }
               return 0;
            });
            for each(dir in dirNameList)
            {
               var arfs:Arfs = new Arfs(baseDirName + "/" + StringUtil.replaceAll(dir,"/","_") + ".arfs",dir);
               arfsMap[dir] = arfs;
            }
         }
         arfsForOthers = new Arfs(baseDirName + "/" + "others" + ".arfs","others");
      }
      
      public function openAsync(param1:Function = null) : void
      {
         var callback:Function = param1;
         var addTask:* = function(param1:Arfs):void
         {
            var a:Arfs = param1;
            queue.addTask(function():void
            {
               var openCallback:* = function(param1:Boolean = true):void
               {
                  var success:Boolean = param1;
                  if(success)
                  {
                     queue.taskDone();
                  }
                  else
                  {
                     a.close(function():void
                     {
                        a.dispose();
                        if(++numRetry > 3)
                        {
                           trace("[ERROR] [Arfs] retrying openAsync failed.");
                           available = false;
                           queue.taskDone();
                        }
                        else
                        {
                           trace("[WARN] [Arfs] retrying openAsync: " + numRetry);
                           a.openAsync(openCallback);
                        }
                     },true);
                  }
               };
               var numRetry:int = 0;
               a.openAsync(openCallback);
            });
         };
         var queue:TaskQueue = new TaskQueue();
         for each(arfs in arfsMap)
         {
            addTask(arfs);
         }
         addTask(arfsForOthers);
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            if(callback)
            {
               callback();
            }
         });
         queue.startTask();
      }
      
      public function open() : void
      {
         for each(var _loc1_ in arfsMap)
         {
            _loc1_.open();
         }
         arfsForOthers.open();
      }
      
      public function get isAvailable() : Boolean
      {
         return available;
      }
      
      public function canHandle(param1:String) : Boolean
      {
         if(!available)
         {
            return false;
         }
         if(!param1 || param1.indexOf("://") >= 0)
         {
            return false;
         }
         for each(var _loc2_ in exceptSuffix)
         {
            if(StringUtil.endsWith(param1,_loc2_))
            {
               return false;
            }
         }
         return true;
      }
      
      private function getArfs(param1:String) : Object
      {
         var _loc2_:Arfs = null;
         for each(var _loc3_ in dirNameList)
         {
            if(StringUtil.startsWith(param1,_loc3_))
            {
               result.arfs = arfsMap[_loc3_];
               result.path = param1.substring(_loc3_.length);
               return result;
            }
         }
         result.arfs = arfsForOthers;
         result.path = param1;
         return result;
      }
      
      public function create(param1:String, param2:ByteArray, param3:Function = null) : void
      {
         var _loc4_:Object;
         (_loc4_ = getArfs(param1)).arfs.create(_loc4_.path,param2,param3);
      }
      
      public function load(param1:String, param2:ByteArray, param3:Function = null) : void
      {
         if(!param1)
         {
            Logger.warn("[ArfsGroup] load. path was null");
            param3(null);
            return;
         }
         var _loc4_:Object;
         (_loc4_ = getArfs(param1)).arfs.load(_loc4_.path,param2,param3);
      }
      
      public function unlink(param1:String, param2:Function = null) : void
      {
         var _loc3_:Object = getArfs(param1);
         _loc3_.arfs.unlink(_loc3_.path,param2);
      }
      
      public function exists(param1:String) : Boolean
      {
         var _loc2_:Object = getArfs(param1);
         return _loc2_.arfs.exists(_loc2_.path);
      }
      
      public function mkdir(param1:String, param2:Function) : void
      {
         var _loc3_:Object = getArfs(param1);
         _loc3_.arfs.mkdir(_loc3_.path,param2);
      }
      
      public function recreate(param1:Arfs, param2:Function) : void
      {
         var arfs:Arfs = param1;
         var callback:Function = param2;
         arfs.close(function():void
         {
            arfs.dispose();
            arfs.openAsync(callback);
         },true);
      }
      
      public function checkStatus(param1:Function) : void
      {
         var callback:Function = param1;
         var hang:Array = [];
         for each(arfs in arfsMap)
         {
            if(arfs.isBusyState() || !arfs.wasOpenProcessCompleted())
            {
               Logger.warn("[Arfs:" + arfs.baseDirName + "] is probably hanging, then recreated.");
               hang[hang.length] = arfs;
            }
         }
         if(arfsForOthers.isBusyState() || !arfsForOthers.wasOpenProcessCompleted())
         {
            Logger.warn("[Arfs:" + arfsForOthers.baseDirName + "] is probably hanging, then recreated.");
            hang[hang.length] = arfsForOthers;
         }
         if(hang.length == 0)
         {
            callback(true);
         }
         else
         {
            var addTask:* = function(param1:Arfs):void
            {
               var a:Arfs = param1;
               queue.addTask(function():void
               {
                  var openCallbask:* = function(param1:Boolean = true):void
                  {
                     queue.taskDone();
                  };
                  var numRetry:int = 0;
                  recreate(a,openCallbask);
               });
            };
            var queue:TaskQueue = new TaskQueue();
            for each(hang_arfs in hang)
            {
               addTask(hang_arfs);
            }
            queue.registerOnProgress(function(param1:Number):void
            {
               if(param1 < 1)
               {
                  return;
               }
               if(callback)
               {
                  callback(false);
               }
            });
            queue.startTask();
         }
      }
      
      public function list() : Array
      {
         var _loc3_:* = null;
         var _loc5_:* = null;
         var _loc1_:Array = [];
         for each(var _loc6_ in dirNameList)
         {
            _loc3_ = arfsMap[_loc6_];
            _loc5_ = _loc3_.list();
            for each(var _loc2_ in _loc5_)
            {
               _loc1_[_loc1_.length] = _loc6_ + _loc2_;
            }
         }
         var _loc4_:Array = arfsForOthers.list();
         return _loc1_.concat(_loc4_);
      }
      
      public function close(param1:Function, param2:Boolean = false) : void
      {
         var callback:Function = param1;
         var dontSave:Boolean = param2;
         var addTask:* = function(param1:Arfs):void
         {
            var a:Arfs = param1;
            queue.addTask(function():void
            {
               a.close(function():void
               {
                  queue.taskDone();
               },dontSave);
            });
         };
         var queue:TaskQueue = new TaskQueue();
         for each(arfs in arfsMap)
         {
            addTask(arfs);
         }
         addTask(arfsForOthers);
         queue.registerOnProgress(function(param1:Number):void
         {
            if(param1 < 1)
            {
               return;
            }
            if(callback)
            {
               callback();
            }
         });
         queue.startTask();
      }
      
      public function clearCache(param1:Function = null) : void
      {
         var callback:Function = param1;
         close(function():void
         {
            for each(var _loc1_ in arfsMap)
            {
               _loc1_.dispose();
            }
            arfsForOthers.dispose();
            if(callback)
            {
               callback();
            }
         },true);
      }
   }
}
