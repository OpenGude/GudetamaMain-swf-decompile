package gudetama.engine
{
   import flash.display.BitmapData;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.net.URLLoader;
   import flash.utils.ByteArray;
   
   public class RsrcLoadContext
   {
      
      public static const TYPE_BITMAP:int = 0;
      
      public static const TYPE_BYTEARRAY:int = 1;
      
      public static const TYPE_MOVIECLIP:int = 2;
      
      public static const TYPE_DOWNLOAD:int = 3;
      
      public static const TYPE_LAYOUTDATA:int = 4;
      
      public static const TYPE_FONT_SWF:int = 5;
      
      public static const LOADFROM_APPFILE:uint = 0;
      
      public static const LOADFROM_CACHEFILE:uint = 1;
      
      public static const LOADFROM_HTTP_RESOURCE:uint = 2;
      
      public static const LOADFROM_HTTP_SERVLET:uint = 3;
       
      
      public var type:int = -1;
      
      public var path:String;
      
      public var noCache:Boolean;
      
      public var neverCancel:Boolean;
      
      public var silent:Boolean;
      
      public var callbackList:Vector.<Function>;
      
      public var callbackListExt:Vector.<Function>;
      
      public var contentExt:Array;
      
      public var loader;
      
      public var content;
      
      public var canceled:Boolean;
      
      public var retryCount:int;
      
      public var needRenameRsrc:Boolean;
      
      public var fileInfo:Object;
      
      public var loadFrom:int = 0;
      
      public var directly:Boolean = false;
      
      public var directlyPath:String;
      
      public function RsrcLoadContext(param1:String, param2:int)
      {
         super();
         path = param1;
         type = param2;
      }
      
      public function addCallback(param1:Function) : void
      {
         if(callbackList == null)
         {
            callbackList = new Vector.<Function>();
         }
         callbackList.push(param1);
      }
      
      public function addCallbackExt(param1:Function) : void
      {
         if(callbackListExt == null)
         {
            callbackListExt = new Vector.<Function>();
         }
         callbackListExt.push(param1);
         contentExt = [];
      }
      
      public function callbackExt() : void
      {
         var _loc2_:* = 0;
         var _loc1_:Boolean = false;
         if(callbackListExt == null)
         {
            return;
         }
         _loc2_ = uint(0);
         while(_loc2_ < callbackListExt.length)
         {
            if(callbackListExt[_loc2_] != null)
            {
               _loc1_ = callbackListExt[_loc2_](this);
               callbackListExt[_loc2_] = null;
               if(_loc1_)
               {
                  return;
               }
            }
            _loc2_++;
         }
         callbackListExt = null;
      }
      
      public function completeLoad(param1:*) : void
      {
         content = param1;
         if(callbackList != null)
         {
            for each(var _loc2_ in callbackList)
            {
               _loc2_(content);
            }
            callbackList = null;
         }
         callbackExt();
         if(loader is Loader)
         {
            (loader as Loader).unloadAndStop();
         }
         else if(loader is URLLoader)
         {
         }
         loader = null;
      }
      
      public function dispose() : void
      {
         if(type == 1)
         {
            if(content)
            {
               ByteArray(content).clear();
            }
         }
         else if(type == 0)
         {
            if(content)
            {
               (content as BitmapData).dispose();
               content = null;
            }
            for each(var _loc1_ in contentExt)
            {
               _loc1_.dispose();
            }
         }
         else if(type == 2)
         {
            if(content)
            {
               MovieClip(content).loaderInfo.loader.unloadAndStop();
            }
         }
      }
      
      public function getTraceString() : String
      {
         var _loc1_:String = "_";
         if(fileInfo)
         {
            _loc1_ = "<" + fileInfo.path + "," + fileInfo.size + "," + fileInfo.hash + ">";
         }
         return "LoadContext[" + type + ", " + loadFrom + ", " + RsrcManager.getURL(this) + ", " + _loc1_ + ", retry=" + retryCount + "]";
      }
   }
}
