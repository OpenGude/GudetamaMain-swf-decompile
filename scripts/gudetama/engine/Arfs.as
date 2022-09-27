package gudetama.engine
{
   import flash.errors.IOError;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.OutputProgressEvent;
   import flash.events.ProgressEvent;
   import flash.filesystem.File;
   import flash.filesystem.FileStream;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   
   public class Arfs
   {
      
      public static const BLKSIZE:int = 2048;
      
      public static const PACKETSIZE:int = 2048;
      
      public static const DATASIZE:int = 2036;
      
      public static const FATSIZE:int = 678;
      
      public static const MAGICNO:int = 2086857395;
      
      public static const ARFS_VERSION:int = 21;
      
      private static const MAX_AVAILABLE:int = 20971520;
      
      public static var sequence:int = 0;
       
      
      private var block_dummy:ByteArray;
      
      private var baseFileName:String;
      
      private var comment:String;
      
      public var asyncMode:Boolean = false;
      
      private var opened:Boolean = false;
      
      private var initialized:Boolean = false;
      
      private var openCallback:Function;
      
      private var busy:Boolean = false;
      
      private var processQueue:Array;
      
      private var maxAvailable:int = 0;
      
      private var topDir:File;
      
      public var header:Header;
      
      private var basefile:File;
      
      private var basefileStream:FileStream;
      
      public var fileSize:int;
      
      private var fat0:FAT = null;
      
      private var fatTable:Array;
      
      private var numFat:int = 0;
      
      private var pendingFats:Array;
      
      private var directory:Dictionary;
      
      private var dirTable:Array;
      
      private var numDirBlock:int = 0;
      
      private var preloadCompletionCallback:Function = null;
      
      private var writeCompletionCallback:Function = null;
      
      private var onClosing:Boolean;
      
      private var seq:int;
      
      public function Arfs(param1:String, param2:String, param3:Boolean = true)
      {
         block_dummy = new ByteArray();
         processQueue = [];
         pendingFats = [];
         super();
         this.baseFileName = param1;
         this.comment = param2;
         block_dummy.length = 2048;
         block_dummy.position = 0;
         seq = ++sequence;
         topDir = !!param3 ? File.cacheDirectory : File.applicationStorageDirectory;
      }
      
      public static function netTrace(param1:String) : void
      {
         trace(param1);
      }
      
      public static function writeInt3(param1:ByteArray, param2:int) : void
      {
         var _loc4_:* = (param2 & 16711680) >> 16;
         param1.writeByte(uint(_loc4_));
         var _loc3_:* = param2 & 65535;
         param1.writeShort(_loc3_);
      }
      
      public static function readInt3(param1:ByteArray) : int
      {
         var _loc3_:int = param1.readByte();
         var _loc2_:* = 65535 & int(param1.readUnsignedShort());
         return _loc3_ << 16 | _loc2_;
      }
      
      public function openArfsFile(param1:File) : void
      {
         baseFileName = param1.nativePath;
         setup(param1,null,false);
      }
      
      public function openArfsFileAsync(param1:File, param2:Function = null) : void
      {
         baseFileName = param1.nativePath;
         setup(param1,param2,true);
      }
      
      public function get baseDirName() : String
      {
         return baseFileName;
      }
      
      private function setup(param1:File, param2:Function, param3:Boolean = true) : void
      {
         var baseFile:File = param1;
         var callback:Function = param2;
         var asyncMode:Boolean = param3;
         this.asyncMode = asyncMode;
         openCallback = callback;
         fatTable = [];
         dirTable = [];
         this.basefile = baseFile;
         var created:Boolean = !basefile.exists;
         if(!created)
         {
            fileSize = basefile.size;
            if(fileSize < 2048 * 3)
            {
               created = true;
               Logger.warn("[Arfs:" + baseDirName + "] ","file size was too small, then recreated.");
            }
         }
         basefileStream = new FileStream();
         basefileStream.addEventListener("complete",onComplete);
         basefileStream.addEventListener("ioError",onIOError);
         basefileStream.addEventListener("progress",onProgress);
         basefileStream.addEventListener("outputProgress",onOutProgress);
         basefileStream.readAhead = 2048;
         if(asyncMode)
         {
            if(created)
            {
               preloadCompletionCallback = function(param1:int):void
               {
                  var available:int = param1;
                  preloadCompletionCallback = null;
                  makeArfsInfo(comment,function():void
                  {
                     var _loc1_:* = null;
                     openCallback = null;
                     if(callback)
                     {
                        callback(true);
                     }
                     initialized = true;
                     if(processQueue.length > 0)
                     {
                        _loc1_ = processQueue.shift();
                        processRequest(_loc1_);
                     }
                  });
               };
            }
            else
            {
               fileSize = basefile.size;
               netTrace("[ARFS-" + seq + "] " + "file size of \'" + baseFileName + "\' = " + fileSize);
               preloadCompletionCallback = function(param1:int):void
               {
                  var available:int = param1;
                  preloadCompletionCallback = null;
                  if(available < 2048)
                  {
                     openCallback = null;
                     if(callback)
                     {
                        callback(false);
                     }
                  }
                  else
                  {
                     var buff:ByteArray = new ByteArray();
                     var blockNo:int = basefileStream.readInt();
                     var nextBlockNo:int = basefileStream.readInt();
                     var len:int = basefileStream.readInt();
                     basefileStream.readBytes(buff,0,2036);
                     try
                     {
                        _readHeaderCallback(nextBlockNo,len,buff,function():void
                        {
                           var _loc1_:* = null;
                           openCallback = null;
                           if(callback)
                           {
                              callback(true);
                           }
                           initialized = true;
                           if(processQueue.length > 0)
                           {
                              _loc1_ = processQueue.shift();
                              processRequest(_loc1_);
                           }
                        });
                     }
                     catch(e:Error)
                     {
                        netTrace("[ARFS-" + seq + "] " + "[ERROR] [Arfs] setup " + e);
                        if(callback)
                        {
                           callback(false);
                        }
                     }
                  }
               };
            }
            basefileStream.openAsync(basefile,"update");
         }
         else
         {
            basefileStream.open(basefile,"update");
            if(created)
            {
               makeArfsInfo(comment,callback);
            }
            else
            {
               fileSize = basefile.size;
               netTrace("[ARFS-" + seq + "] " + "file size of \'" + baseFileName + "\' = " + fileSize);
               readArfsInfo(callback);
            }
            initialized = true;
         }
         opened = true;
      }
      
      public function isOpened() : Boolean
      {
         return opened;
      }
      
      public function openAsync(param1:Function = null) : void
      {
         if(opened)
         {
            throw new IOError("already opened as " + (!!asyncMode ? "async mode" : "sync mode"));
         }
         setup(topDir.resolvePath(baseFileName),param1,true);
      }
      
      public function open() : void
      {
         if(opened)
         {
            throw new IOError("already opened as " + (!!asyncMode ? "async mode" : "sync mode"));
         }
         setup(topDir.resolvePath(baseFileName),null,false);
      }
      
      private function onComplete(param1:Event) : void
      {
         if(preloadCompletionCallback)
         {
            preloadCompletionCallback(0);
         }
      }
      
      private function onOutProgress(param1:OutputProgressEvent) : void
      {
         if(param1.bytesPending == 0)
         {
            if(writeCompletionCallback)
            {
               writeCompletionCallback(param1.bytesTotal);
            }
         }
      }
      
      private function onProgress(param1:ProgressEvent) : void
      {
         if(preloadCompletionCallback)
         {
            preloadCompletionCallback(basefileStream.bytesAvailable);
         }
      }
      
      private function onIOError(param1:IOErrorEvent) : void
      {
         Logger.warn("[Arfs:" + baseDirName + "] ","onIOError: " + param1);
         var _loc2_:Function = openCallback;
         openCallback = null;
         if(_loc2_)
         {
            _loc2_(false);
         }
      }
      
      private function flushCache(param1:*) : void
      {
         var callback:* = param1;
         maxAvailable = 0;
         close(function():void
         {
            basefileStream = new FileStream();
            basefileStream.addEventListener("complete",onComplete);
            basefileStream.addEventListener("ioError",onIOError);
            basefileStream.addEventListener("progress",onProgress);
            basefileStream.addEventListener("outputProgress",onOutProgress);
            basefileStream.readAhead = 2048;
            if(asyncMode)
            {
               preloadCompletionCallback = function(param1:int):void
               {
                  preloadCompletionCallback = null;
                  if(callback)
                  {
                     callback();
                  }
               };
               basefileStream.openAsync(basefile,"update");
            }
            else
            {
               basefileStream.open(basefile,"update");
               callback();
            }
         });
      }
      
      private function needsFlushCache() : Boolean
      {
         return false;
      }
      
      private function readDataBlocks(param1:int, param2:int, param3:ByteArray, param4:int, param5:Function) : void
      {
         var blockNo:int = param1;
         var numBlocks:int = param2;
         var buff:ByteArray = param3;
         var offset:int = param4;
         var callback:Function = param5;
         var readCallback:* = function(param1:int):void
         {
            if(param1 > maxAvailable)
            {
               maxAvailable = param1;
            }
            preloadCompletionCallback = null;
            if(param1 < 2048)
            {
               if(callback)
               {
                  callback(0,null);
               }
            }
            else
            {
               if(param1 < 2048 * numBlocks)
               {
                  numBlocks = param1 / 2048;
               }
               if(numBlocks > 0)
               {
                  basefileStream.readBytes(buff,offset,2048 * numBlocks);
                  if(callback)
                  {
                     callback(numBlocks,buff);
                  }
               }
               else if(callback)
               {
                  callback(0,null);
               }
            }
         };
         if(blockNo <= 1)
         {
            throw new IOError("Invalid Block Number: " + blockNo);
         }
         if(asyncMode)
         {
            preloadCompletionCallback = readCallback;
            basefileStream.position = blockNo * 2048;
         }
         else
         {
            basefileStream.position = blockNo * 2048;
            basefileStream.readBytes(buff,offset,2048 * numBlocks);
            if(callback)
            {
               callback(numBlocks,buff);
            }
         }
      }
      
      private function writeDataBlocks(param1:int, param2:int, param3:ByteArray, param4:int, param5:Function) : void
      {
         var blkNo:int = param1;
         var numBlocks:int = param2;
         var buff:ByteArray = param3;
         var offs:int = param4;
         var callback:Function = param5;
         var readCallback:* = function(param1:int):void
         {
            if(param1 > maxAvailable)
            {
               maxAvailable = param1;
            }
            basefileStream.writeBytes(buff,offs,len);
            buff.position = offs + len;
         };
         var writeCallback:* = function(param1:int):void
         {
            var written:int = param1;
            preloadCompletionCallback = null;
            writeCompletionCallback = null;
            if(origLen != len)
            {
               buff.length = origLen + offs;
            }
            if(pendingFats.length > 0 && pendingFats[0].myBlkNo == blkNo + numBlocks)
            {
               writePendingFat(pendingFats.shift(),function():void
               {
                  if(callback)
                  {
                     callback(origLen);
                  }
               });
            }
            else if(callback)
            {
               callback(origLen);
            }
         };
         if(blkNo <= 1)
         {
            throw new IOError("Invalid Block Number: " + blkNo);
         }
         if(pendingFats.length > 0 && pendingFats[0].myBlkNo == blkNo - 1)
         {
            writePendingFat(pendingFats.shift(),function():void
            {
               writeDataBlocks(blkNo,numBlocks,buff,offs,callback);
            });
            return;
         }
         var len:int = 2048 * numBlocks;
         var origLen:int = len;
         if(buff.length < len + offs)
         {
            origLen = buff.length - offs;
            buff.length = len + offs;
         }
         if(asyncMode)
         {
            preloadCompletionCallback = readCallback;
            writeCompletionCallback = writeCallback;
            if(basefileStream.position == blkNo * 2048)
            {
               readCallback(basefileStream.bytesAvailable);
            }
            else
            {
               basefileStream.position = blkNo * 2048;
            }
         }
         else
         {
            basefileStream.position = blkNo * 2048;
            basefileStream.writeBytes(buff,offs,2048 * numBlocks);
            buff.position = offs + len;
            if(origLen != len)
            {
               buff.length = origLen + offs;
            }
            if(callback)
            {
               callback(origLen);
            }
         }
      }
      
      private function readBlock(param1:int, param2:ByteArray, param3:int, param4:Function) : void
      {
         var blockNo:int = param1;
         var buff:ByteArray = param2;
         var offset:int = param3;
         var callback:Function = param4;
         var readCallback:* = function(param1:int):void
         {
            var _loc3_:int = 0;
            var _loc5_:* = 0;
            var _loc2_:int = 0;
            var _loc4_:int = 0;
            if(param1 > maxAvailable)
            {
               maxAvailable = param1;
            }
            preloadCompletionCallback = null;
            if(param1 < 2048)
            {
               if(callback)
               {
                  callback(-1,-1,null);
               }
            }
            else
            {
               _loc3_ = basefileStream.readInt();
               _loc5_ = int(basefileStream.readInt());
               _loc2_ = basefileStream.readInt();
               basefileStream.readBytes(buff,offset,_loc2_);
               if(blockNo != _loc3_)
               {
                  netTrace("[ARFS-" + seq + "] " + "[ERROR] [Arfs]  readBlock got invalid block No." + _loc3_ + ", expected No. is " + blockNo);
                  _loc5_ = -1;
                  _loc2_ = -1;
                  buff = null;
               }
               else if(blockNo > 1 && _loc3_ % 678 != 0)
               {
                  _loc4_ = getNextBlockNo(blockNo);
                  if(_loc5_ != _loc4_ && _loc5_ != 0)
                  {
                     netTrace("[ARFS-" + seq + "] " + "[ERROR] [Arfs]  blockNo=" + blockNo + ", conflict next block No. chain: " + _loc5_ + ", FAT: " + _loc4_);
                     _loc5_ = _loc4_;
                  }
               }
               if(_loc5_ > header.lastBlkNo)
               {
                  Logger.warn("[Arfs:" + baseDirName + "] ","nextBlock:" + _loc5_ + " is out of file(" + header.lastBlkNo + ")  ",baseFileName);
                  _loc5_ = -1;
               }
               if(callback)
               {
                  callback(_loc5_,_loc2_,buff);
               }
            }
         };
         if(blockNo > 1 && blockNo % 678 != 0)
         {
            var nextBlockNoFromFAT:int = getNextBlockNo(blockNo);
            if(nextBlockNoFromFAT == 0)
            {
               netTrace("[ARFS-" + seq + "] " + "[ERROR] [Arfs]  readBlock read unavailable block. No." + blockNo);
               if(callback)
               {
                  callback(-1,-1,null);
               }
               return;
            }
         }
         if(asyncMode)
         {
            preloadCompletionCallback = readCallback;
            basefileStream.position = blockNo * 2048;
         }
         else
         {
            basefileStream.position = blockNo * 2048;
            var blkNo:int = basefileStream.readInt();
            var nextBlockNo:int = basefileStream.readInt();
            var len:int = basefileStream.readInt();
            if(blockNo != blkNo)
            {
               netTrace("[ARFS-" + seq + "] " + "[ERROR] [Arfs]  readBlock got invalid block No." + blkNo + ", expected No. is " + blockNo);
            }
            basefileStream.readBytes(buff,offset,2036);
            if(nextBlockNo > header.lastBlkNo)
            {
               Logger.warn("[Arfs:" + baseDirName + "] ","nextBlock:" + nextBlockNo + " is out of file(" + header.lastBlkNo + ") ",baseFileName);
               nextBlockNo = -1;
            }
            if(callback)
            {
               callback(nextBlockNo,len,buff);
            }
         }
      }
      
      private function writePendingFat(param1:FAT, param2:Function) : void
      {
         var fat:FAT = param1;
         var callback:Function = param2;
         var writeCallback:* = function(param1:int, param2:int, param3:int):void
         {
            if(callback)
            {
               callback();
            }
         };
         var buff:ByteArray = new ByteArray();
         if(fat)
         {
            netTrace("[ARFS-" + seq + "] " + "writePendingFat: seqno=" + fat.seqno + ", blockNo=" + fat.myBlkNo);
            fat.save(buff);
            writeBlock(fat.myBlkNo,fat.nextBlkNo,buff,0,buff.length,writeCallback);
         }
         else if(callback)
         {
            callback();
         }
      }
      
      private function writeBlock(param1:int, param2:int, param3:ByteArray, param4:int, param5:int, param6:Function) : void
      {
         var blkNo:int = param1;
         var nextBlkNo:int = param2;
         var buff:ByteArray = param3;
         var offs:int = param4;
         var len:int = param5;
         var callback:Function = param6;
         var readCallback:* = function(param1:int):void
         {
            if(param1 > maxAvailable)
            {
               maxAvailable = param1;
            }
            var _loc2_:ByteArray = new ByteArray();
            _loc2_.writeInt(blkNo);
            _loc2_.writeInt(nextBlkNo);
            _loc2_.writeInt(len);
            if(buff)
            {
               _loc2_.writeBytes(buff,offs,len);
               buff.position = offs + len;
            }
            _loc2_.length = 2048;
            basefileStream.writeBytes(_loc2_,0,2048);
         };
         var writeCallback:* = function(param1:int):void
         {
            var written:int = param1;
            preloadCompletionCallback = null;
            writeCompletionCallback = null;
            if(pendingFats.length > 0 && pendingFats[0].myBlkNo == blkNo + 1)
            {
               writePendingFat(pendingFats.shift(),function():void
               {
                  if(callback)
                  {
                     callback(blkNo,nextBlkNo,written);
                  }
               });
            }
            else if(callback)
            {
               callback(blkNo,nextBlkNo,written);
            }
         };
         if(pendingFats.length > 0 && pendingFats[0].myBlkNo == blkNo - 1)
         {
            writePendingFat(pendingFats.shift(),function():void
            {
               writeBlock(blkNo,nextBlkNo,buff,offs,len,callback);
            });
            return;
         }
         if(len >= 2036)
         {
            var len:int = 2036;
         }
         if(asyncMode)
         {
            preloadCompletionCallback = readCallback;
            writeCompletionCallback = writeCallback;
            if(basefileStream.position == blkNo * 2048)
            {
               readCallback(basefileStream.bytesAvailable);
            }
            else
            {
               basefileStream.position = blkNo * 2048;
            }
         }
         else
         {
            basefileStream.position = blkNo * 2048;
            basefileStream.writeInt(blkNo);
            basefileStream.writeInt(nextBlkNo);
            if(buff)
            {
               basefileStream.writeInt(buff.length);
               basefileStream.writeBytes(buff,offs,len);
               buff.position = offs + len;
            }
            else
            {
               len = 0;
               basefileStream.writeInt(0);
            }
            if(len < 2036)
            {
               basefileStream.writeBytes(block_dummy,0,2036 - len);
            }
            if(callback)
            {
               callback(blkNo,nextBlkNo,len + 12);
            }
         }
      }
      
      private function _readHeaderCallback(param1:int, param2:int, param3:ByteArray, param4:Function) : void
      {
         var nextBlockNo:int = param1;
         var len:int = param2;
         var buff:ByteArray = param3;
         var callback:Function = param4;
         header = new Header();
         header.load(buff);
         header.lastBlkNo = fileSize / 2048 - 1;
         if(header.fatTableBlkNo != 0)
         {
            readFAT(function(param1:int):void
            {
               var cnt:int = param1;
               numFat = cnt;
               if(cnt > 0)
               {
                  fat0 = FAT(fatTable[0]);
                  var i:int = 0;
                  while(i < fatTable.length)
                  {
                     var f:FAT = FAT(fatTable[i]);
                     var invalidBlock:int = f.checkBlkno(header.lastBlkNo);
                     if(invalidBlock)
                     {
                        Logger.warn("[Arfs:" + baseDirName + "] " + "FAT-" + i + " contains invalid block:" + invalidBlock + ", lastBlock:" + header.lastBlkNo);
                     }
                     i++;
                  }
               }
               if(header.rootdirBlkNo != 0)
               {
                  readDirectory(function(param1:int):void
                  {
                     numDirBlock = param1;
                     if(callback)
                     {
                        callback();
                     }
                  });
               }
               else if(callback)
               {
                  callback();
               }
            });
         }
         else if(callback)
         {
            callback();
         }
      }
      
      private function readArfsInfo(param1:Function) : void
      {
         var callback:Function = param1;
         var buff:ByteArray = new ByteArray();
         readBlock(0,buff,0,function(param1:int, param2:int, param3:ByteArray):void
         {
            _readHeaderCallback(param1,param2,param3,callback);
         });
      }
      
      private function makeArfsInfo(param1:String, param2:Function) : void
      {
         var comment:String = param1;
         var callback:Function = param2;
         var buff:ByteArray = new ByteArray();
         writeBlock(0,0,null,0,0,function(param1:int, param2:int, param3:int):void
         {
            var blkNo:int = param1;
            var nextBlkNo:int = param2;
            var written:int = param3;
            writeBlock(1,0,null,0,0,function(param1:int, param2:int, param3:int):void
            {
               var blkNo:int = param1;
               var nextBlkNo:int = param2;
               var written:int = param3;
               writeBlock(2,0,null,0,0,function(param1:int, param2:int, param3:int):void
               {
                  var blkNo:int = param1;
                  var nextBlkNo:int = param2;
                  var written:int = param3;
                  header = new Header(comment);
                  directory = new Dictionary();
                  writeDirectory(function():void
                  {
                     writeFAT(function():void
                     {
                        header.save(buff);
                        writeBlock(0,0,buff,0,buff.length,function(param1:int, param2:int, param3:int):void
                        {
                           if(callback)
                           {
                              callback();
                           }
                        });
                     });
                  });
               });
            });
         });
      }
      
      public function mkdir(param1:String, param2:Function) : void
      {
      }
      
      private function processRequest(param1:ArfsRequest) : void
      {
         if(onClosing)
         {
            cancelRequest(param1);
            return;
         }
         switch(int(param1.reqType) - 1)
         {
            case 0:
               _create(CreateRequest(param1).path,CreateRequest(param1).buff,param1.proxyCallback);
               break;
            case 1:
               _load(LoadRequest(param1).path,LoadRequest(param1).buff,param1.proxyCallback);
               break;
            case 2:
               break;
            case 3:
               _unlink(UnlinkRequest(param1).path,param1.proxyCallback);
         }
      }
      
      private function cancelRequest(param1:ArfsRequest) : void
      {
         switch(int(param1.reqType) - 1)
         {
            case 0:
               if(param1.proxyCallback)
               {
                  param1.proxyCallback();
               }
               break;
            case 1:
               if(param1.proxyCallback)
               {
                  param1.proxyCallback(null);
               }
               break;
            case 2:
               break;
            case 3:
               if(param1.proxyCallback)
               {
                  param1.proxyCallback(true);
                  break;
               }
         }
      }
      
      private function flushProcessRequestQueue() : void
      {
         var _loc1_:* = null;
         onClosing = true;
         while(processQueue.length > 0)
         {
            _loc1_ = processQueue.shift();
            cancelRequest(_loc1_);
         }
         onClosing = false;
      }
      
      public function create(param1:String, param2:ByteArray, param3:Function) : void
      {
         var path:String = param1;
         var buff:ByteArray = param2;
         var callback:Function = param3;
         var createCallback:* = function():void
         {
            if(origCallback)
            {
               origCallback();
            }
            if(needsFlushCache())
            {
               busy = true;
               flushCache(function():void
               {
                  var _loc1_:* = null;
                  if(processQueue.length > 0)
                  {
                     _loc1_ = processQueue.shift();
                     processRequest(_loc1_);
                  }
                  else
                  {
                     busy = false;
                  }
               });
            }
            else if(processQueue.length > 0)
            {
               var req:ArfsRequest = processQueue.shift();
               processRequest(req);
            }
            else
            {
               busy = false;
            }
         };
         if(!opened)
         {
            throw new IOError("Arfs not opened");
         }
         var path:String = trimPath(path);
         var origCallback:Function = callback;
         if(busy || !initialized)
         {
            busy = true;
            var req:CreateRequest = new CreateRequest();
            req.originalCallback = callback;
            req.proxyCallback = createCallback;
            req.path = path;
            req.buff = buff;
            processQueue[processQueue.length] = req;
         }
         else
         {
            busy = true;
            _create(path,buff,createCallback);
         }
      }
      
      private function _OLD_create(param1:String, param2:ByteArray, param3:Function) : void
      {
         var path:String = param1;
         var buff:ByteArray = param2;
         var callback:Function = param3;
         var writeCallback:* = function(param1:int, param2:int, param3:int):void
         {
            if(param2 == 0)
            {
               if(callback)
               {
                  callback();
               }
               return;
            }
            len = buff.length - buff.position > 2036 ? 2036 : buff.length - buff.position;
            blockIndex++;
            blkNo = blocks[blockIndex];
            nextBlkNo = blockIndex + 1 < blocks.length ? blocks[blockIndex + 1] : 0;
            writeBlock(blkNo,nextBlkNo,buff,buff.position,len,writeCallback);
         };
         var totalSize:int = buff.length;
         var requiredBlocks:int = (totalSize + 2036 - 1) / 2036;
         var blocks:Array = [];
         var firstBlkNo:int = getNextBlkNo();
         var blkNo:int = firstBlkNo;
         blocks[0] = blkNo;
         var i:int = 1;
         while(i < requiredBlocks)
         {
            var prevBlkNo:int = blkNo;
            blkNo = getNextBlkNo();
            blocks[i] = blkNo;
            setBlockNo(prevBlkNo,blkNo);
            i++;
         }
         addPath(path,firstBlkNo,totalSize);
         var blockIndex:int = 0;
         var len:int = 0;
         blkNo = blocks[blockIndex];
         var nextBlkNo:int = blockIndex + 1 < blocks.length ? blocks[blockIndex + 1] : 0;
         writeDirectory(function():void
         {
            writeFAT(function():void
            {
               len = buff.length > 2036 ? 2036 : buff.length;
               writeBlock(blkNo,nextBlkNo,buff,0,len,writeCallback);
            });
         });
      }
      
      private function _getContinuousBlockCount(param1:Array, param2:int, param3:int = 999999) : int
      {
         if(param2 >= param1.length)
         {
            return 0;
         }
         var _loc4_:int = param1[param2];
         var _loc6_:int = param2 + 1;
         var _loc5_:* = _loc4_;
         var _loc7_:* = _loc4_;
         while(_loc6_ < param1.length - 1)
         {
            if((_loc7_ = int(param1[_loc6_])) - _loc5_ > 1)
            {
               break;
            }
            _loc5_ = _loc7_;
            _loc6_++;
            if(_loc6_ - param2 == param3)
            {
               break;
            }
         }
         return _loc6_ - param2;
      }
      
      private function _create(param1:String, param2:ByteArray, param3:Function) : void
      {
         var path:String = param1;
         var buff:ByteArray = param2;
         var callback:Function = param3;
         var writeCallback:* = function(param1:int):void
         {
            var written:int = param1;
            blockIndex += numBlocks;
            if(blockIndex >= blocks.length)
            {
               writeFAT(function():void
               {
                  if(callback)
                  {
                     callback();
                  }
               });
               return;
            }
            blkNo = blocks[blockIndex];
            numBlocks = _getContinuousBlockCount(blocks,blockIndex);
            writeDataBlocks(blkNo,numBlocks,buff,buff.position,writeCallback);
         };
         reserveDirEntry();
         var totalSize:int = buff.length;
         var requiredBlocks:int = (totalSize + 2048 - 1) / 2048;
         var blocks:Array = [];
         var firstBlkNo:int = getNextBlkNo();
         var blkNo:int = firstBlkNo;
         var numBlocks:int = 1;
         blocks[0] = blkNo;
         var i:int = 1;
         while(i < requiredBlocks)
         {
            var prevBlkNo:int = blkNo;
            blkNo = getNextBlkNo();
            blocks[i] = blkNo;
            setBlockNo(prevBlkNo,blkNo);
            i++;
         }
         addPath(path,firstBlkNo,totalSize);
         var blockIndex:int = 0;
         var len:int = 0;
         blkNo = blocks[blockIndex];
         numBlocks = _getContinuousBlockCount(blocks,blockIndex);
         writeDirectory(function():void
         {
            len = buff.length > 2036 ? 2036 : buff.length;
            writeDataBlocks(blkNo,numBlocks,buff,0,writeCallback);
         });
      }
      
      public function isBusyState() : Boolean
      {
         return busy || processQueue.length > 0;
      }
      
      public function wasOpenProcessCompleted() : Boolean
      {
         return opened && initialized;
      }
      
      public function checkBlockAllocation(param1:Array = null) : void
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc3_:* = null;
         var _loc8_:Boolean = false;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc10_:int = 0;
         trace("---- checkBlockAllocation ----");
         var _loc2_:int = fatTable.length * 678;
         var _loc5_:Array = new Array(_loc2_);
         _loc6_ = 0;
         while(_loc6_ < _loc2_)
         {
            _loc5_[_loc6_] = -1;
            _loc6_++;
         }
         _loc5_[0] = -2;
         trace("\tfatTable.length=" + fatTable.length + ", maxNumBlocks=" + _loc2_);
         trace("\r\n### checking directory ###");
         trace("\tdirTable.length=" + dirTable.length);
         _loc7_ = 0;
         while(_loc7_ < dirTable.length)
         {
            _loc3_ = DirBlock(dirTable[_loc7_]);
            if(_loc5_[_loc3_.myBlkNo] != -1)
            {
               trace("\t" + _loc3_.myBlkNo + " was already used by DirBlock-" + _loc5_[_loc3_.myBlkNo]);
            }
            else
            {
               _loc5_[_loc3_.myBlkNo] = -_loc7_ - 10;
            }
            _loc7_++;
         }
         trace("\r\n### checking files ###");
         var _loc9_:Array = [];
         var _loc4_:int = 0;
         var _loc14_:Array = [];
         for each(var _loc11_ in directory)
         {
            _loc9_[_loc9_.length] = _loc11_.fileName;
            trace("checking path: " + _loc11_.fileName + ", size: " + _loc11_.size);
            _loc8_ = param1 && param1.indexOf(_loc11_.fileName) >= 0;
            _loc12_ = 0;
            _loc13_ = _loc11_.firstBlkNo;
            _loc14_.length = 0;
            _loc14_.push(_loc13_);
            if(_loc13_ <= 0)
            {
               trace("\thas invalid block No.:" + _loc13_);
            }
            while(_loc13_ >= 0)
            {
               _loc12_++;
               if(_loc5_[_loc13_] != -1)
               {
                  if(_loc13_ >= 0)
                  {
                     trace("\t" + _loc13_ + " was already used by " + _loc9_[_loc5_[_loc13_]]);
                  }
                  else
                  {
                     trace("\t" + _loc13_ + " was already used by DirBlock-" + _loc5_[_loc13_]);
                  }
               }
               else
               {
                  _loc5_[_loc13_] = _loc4_;
               }
               _loc13_ = getNextBlockNo(_loc13_);
               _loc14_.push(_loc13_);
            }
            _loc10_ = (_loc11_.size + 2048 - 1) / 2048;
            if(_loc8_)
            {
               trace("FAT chain: " + _loc14_);
            }
            if(_loc12_ != _loc10_)
            {
               trace("\toccupiedBlockNum was invalid: " + _loc10_ + ", actual blocks: " + _loc12_);
            }
            _loc4_++;
         }
      }
      
      private function trimPath(param1:String) : String
      {
         if(param1.length > 64)
         {
            param1 = param1.substring(param1.length - 64);
         }
         return param1;
      }
      
      private function findDirEntry(param1:String) : DirEntry
      {
         return directory[param1];
      }
      
      public function list() : Array
      {
         var _loc1_:Array = [];
         for each(var _loc2_ in directory)
         {
            _loc1_[_loc1_.length] = _loc2_.fileName;
         }
         return _loc1_;
      }
      
      public function exists(param1:String) : Boolean
      {
         if(!opened)
         {
            throw new IOError("Arfs not opened");
         }
         if(!initialized)
         {
            return false;
         }
         return findDirEntry(trimPath(param1)) != null;
      }
      
      public function load(param1:String, param2:ByteArray, param3:Function) : void
      {
         var path:String = param1;
         var buff:ByteArray = param2;
         var callback:Function = param3;
         var loadCallback:* = function(param1:ByteArray):void
         {
            var bytes:ByteArray = param1;
            if(origCallback)
            {
               origCallback(bytes);
            }
            if(needsFlushCache())
            {
               busy = true;
               flushCache(function():void
               {
                  var _loc1_:* = null;
                  if(processQueue.length > 0)
                  {
                     _loc1_ = processQueue.shift();
                     processRequest(_loc1_);
                  }
                  else
                  {
                     busy = false;
                  }
               });
            }
            else if(processQueue.length > 0)
            {
               var req:ArfsRequest = processQueue.shift();
               processRequest(req);
            }
            else
            {
               busy = false;
            }
         };
         if(!opened)
         {
            throw new IOError("Arfs not opened");
         }
         var path:String = trimPath(path);
         var origCallback:Function = callback;
         if(busy || !initialized)
         {
            busy = true;
            var req:LoadRequest = new LoadRequest();
            req.originalCallback = callback;
            req.proxyCallback = loadCallback;
            req.path = path;
            req.buff = buff;
            processQueue[processQueue.length] = req;
         }
         else
         {
            busy = true;
            _load(path,buff,loadCallback);
         }
      }
      
      private function _OLD_load(param1:String, param2:ByteArray, param3:Function) : void
      {
         var path:String = param1;
         var buff:ByteArray = param2;
         var callback:Function = param3;
         var readBlockCallback:* = function(param1:int, param2:int, param3:ByteArray):void
         {
            if(!param3)
            {
               if(callback)
               {
                  callback(null);
               }
               return;
            }
            blkNo = param1;
            if(blkNo > 0)
            {
               offs += param2;
               readBlock(blkNo,param3,offs,readBlockCallback);
            }
            else
            {
               param3.position = 0;
               if(callback)
               {
                  callback(param3);
               }
            }
         };
         var entry:DirEntry = findDirEntry(path);
         if(!entry)
         {
            if(callback)
            {
               callback(null);
            }
            return;
         }
         var blkNo:int = entry.firstBlkNo;
         var offs:int = 0;
         if(blkNo > 0)
         {
            readBlock(blkNo,buff,offs,readBlockCallback);
         }
         else if(callback)
         {
            callback(null);
         }
      }
      
      private function _load(param1:String, param2:ByteArray, param3:Function) : void
      {
         var path:String = param1;
         var buff:ByteArray = param2;
         var callback:Function = param3;
         var readBlockCallback:* = function(param1:int, param2:ByteArray):void
         {
            if(!param2)
            {
               netTrace("[ARFS-" + seq + "] " + "_load got null buff, path=" + path);
               if(callback)
               {
                  callback(null);
               }
               return;
            }
            blockIndex += param1;
            if(blockIndex >= blocks.length)
            {
               param2.length = entry.size;
               param2.position = 0;
               if(callback)
               {
                  callback(param2);
               }
               return;
            }
            offs += param1 * 2048;
            blkNo = blocks[blockIndex];
            numBlocks = _getContinuousBlockCount(blocks,blockIndex,4);
            if(blkNo > 0)
            {
               readDataBlocks(blkNo,numBlocks,param2,offs,readBlockCallback);
            }
            else
            {
               param2.length = entry.size;
               param2.position = 0;
               if(callback)
               {
                  callback(param2);
               }
            }
         };
         var entry:DirEntry = findDirEntry(path);
         if(!entry)
         {
            if(callback)
            {
               callback(null);
            }
            return;
         }
         var blocks:Array = [];
         var blkNo:int = entry.firstBlkNo;
         var blockIndex:int = 0;
         var numBlocks:int = 1;
         var prevBlkNo:int = blkNo;
         var nextBlkNo:int = blkNo;
         var offs:int = 0;
         blocks[0] = blkNo;
         do
         {
            nextBlkNo = getNextBlockNo(prevBlkNo);
            if(nextBlkNo > 0)
            {
               blocks[blocks.length] = nextBlkNo;
               prevBlkNo = nextBlkNo;
            }
         }
         while(nextBlkNo > 0);
         
         if(blkNo > 0)
         {
            numBlocks = _getContinuousBlockCount(blocks,blockIndex,4);
            readDataBlocks(blkNo,numBlocks,buff,offs,readBlockCallback);
         }
         else if(callback)
         {
            callback(null);
         }
      }
      
      public function unlink(param1:String, param2:Function) : void
      {
         var fileName:String = param1;
         var callback:Function = param2;
         var unlinkCallback:* = function(param1:Boolean):void
         {
            var success:Boolean = param1;
            if(origCallback)
            {
               origCallback(success);
            }
            if(needsFlushCache())
            {
               busy = true;
               flushCache(function():void
               {
                  var _loc1_:* = null;
                  if(processQueue.length > 0)
                  {
                     _loc1_ = processQueue.shift();
                     processRequest(_loc1_);
                  }
                  else
                  {
                     busy = false;
                  }
               });
            }
            else if(processQueue.length > 0)
            {
               var req:ArfsRequest = processQueue.shift();
               processRequest(req);
            }
            else
            {
               busy = false;
            }
         };
         if(!opened)
         {
            throw new IOError("Arfs not opened");
         }
         var fileName:String = trimPath(fileName);
         var origCallback:Function = callback;
         if(busy || !initialized)
         {
            busy = true;
            var req:UnlinkRequest = new UnlinkRequest();
            req.originalCallback = callback;
            req.proxyCallback = unlinkCallback;
            req.path = fileName;
            processQueue[processQueue.length] = req;
         }
         else
         {
            busy = true;
            _unlink(fileName,unlinkCallback);
         }
      }
      
      private function _unlink(param1:String, param2:Function) : void
      {
         var fileName:String = param1;
         var callback:Function = param2;
         var old:DirEntry = directory[fileName];
         if(old == null)
         {
            if(callback)
            {
               callback(false);
            }
            return;
         }
         delete directory[fileName];
         old.setType(2);
         header.addBlkNoToRemove(old.firstBlkNo);
         header.removeFreeBlock(this);
         writeDirectory(function():void
         {
            writeFAT(function():void
            {
               if(header.isNeedsToSave())
               {
                  var buff:ByteArray = new ByteArray();
                  header.save(buff);
                  writeBlock(0,0,buff,0,buff.length,function(param1:int, param2:int, param3:int):void
                  {
                     if(callback)
                     {
                        callback(true);
                     }
                  });
               }
               else if(callback)
               {
                  callback(true);
               }
            });
         });
      }
      
      public function close(param1:Function = null, param2:Boolean = false) : void
      {
         var callback:Function = param1;
         var dontSave:Boolean = param2;
         var onClosed:* = function(param1:Event):void
         {
            basefileStream = null;
            opened = false;
            var _loc2_:Function = callback;
            callback = null;
            if(_loc2_)
            {
               _loc2_();
            }
         };
         flushProcessRequestQueue();
         try
         {
            var available:uint = basefileStream.bytesAvailable;
         }
         catch(e:Error)
         {
            var callBk:Function = callback;
            var callback:Function = null;
            basefileStream.close();
            basefileStream = null;
            opened = false;
            if(callBk)
            {
               callBk();
            }
            return;
         }
         basefileStream.addEventListener("close",onClosed);
         if(dontSave)
         {
            basefileStream.close();
            if(!asyncMode)
            {
               basefileStream = null;
               opened = false;
               if(callback)
               {
                  callback();
               }
            }
            return;
         }
         header.removeFreeBlock(this);
         writeDirectory(function():void
         {
            writeFAT(function():void
            {
               if(header.isNeedsToSave())
               {
                  var buff:ByteArray = new ByteArray();
                  header.save(buff);
                  writeBlock(0,0,buff,0,buff.length,function(param1:int, param2:int, param3:int):void
                  {
                     basefileStream.close();
                     if(!asyncMode)
                     {
                        basefileStream = null;
                        opened = false;
                        if(callback)
                        {
                           callback();
                        }
                     }
                  });
               }
               else
               {
                  basefileStream.close();
                  if(!asyncMode)
                  {
                     basefileStream = null;
                     opened = false;
                     if(callback)
                     {
                        callback();
                     }
                  }
               }
            });
         });
      }
      
      public function dispose() : void
      {
         netTrace("[ARFS-" + seq + "] " + "Arfs.dispose");
         if(opened)
         {
            throw new IOError("can not dispose archive file opened !");
         }
         if(basefile && basefile.exists)
         {
            basefile.cancel();
            try
            {
               basefile.deleteFile();
               netTrace("[ARFS-" + seq + "] " + "delete basefile. " + basefile.nativePath);
            }
            catch(e:Error)
            {
               Logger.warn("[Arfs:" + baseDirName + "] deleteFile failed.",e);
            }
         }
         processQueue.length = 0;
         fat0 = null;
         fatTable = null;
         numFat = 0;
         directory = null;
         dirTable = null;
         numDirBlock = 0;
         preloadCompletionCallback = null;
         writeCompletionCallback = null;
         initialized = false;
         busy = false;
      }
      
      private function getNextVacantBlk() : int
      {
         var _loc2_:int = 0;
         var _loc1_:int = -1;
         if(fat0 != null)
         {
            _loc1_ = fat0.reserve();
         }
         if(_loc1_ == -1)
         {
            _loc2_ = 1;
            while(_loc2_ < numFat)
            {
               _loc1_ = FAT(fatTable[_loc2_]).reserve();
               if(_loc1_ != -1)
               {
                  break;
               }
               _loc2_++;
            }
         }
         if(_loc1_ > header.lastBlkNo)
         {
            header.lastBlkNo = _loc1_;
         }
         return _loc1_;
      }
      
      private function getNextBlkNo() : int
      {
         var _loc2_:* = null;
         var _loc3_:* = null;
         var _loc1_:int = getNextVacantBlk();
         if(_loc1_ == -1)
         {
            if(numFat > 0)
            {
               _loc3_ = FAT(fatTable[numFat - 1]);
               _loc2_ = _loc3_.addFat(this,(_loc3_.seqno + 1) * 678 - 1);
               _loc3_.blk[678 - 1] = -1;
               fatTable.push(_loc2_);
               pendingFats.push(_loc2_);
               numFat++;
               _loc1_ = _loc2_.reserve();
               if(_loc1_ > header.lastBlkNo)
               {
                  header.lastBlkNo = _loc1_;
               }
            }
            else
            {
               fatTable = [];
               _loc2_ = new FAT(header.lastBlkNo);
               fat0 = _loc2_;
               _loc2_.setSeqNo(0);
               _loc2_.blk[0] = -1;
               _loc2_.blk[header.lastBlkNo] = -1;
               fatTable.push(_loc2_);
               numFat = 1;
               header.lastBlkNo++;
               _loc1_ = _loc2_.reserve();
               if(_loc1_ > header.lastBlkNo)
               {
                  header.lastBlkNo = _loc1_;
               }
            }
         }
         return _loc1_;
      }
      
      public function setRemovedBlock(param1:int) : void
      {
         do
         {
            param1 = setBlockNo(param1,0);
         }
         while(param1 > 0);
         
      }
      
      private function getLastBlockNo(param1:int) : int
      {
         var _loc2_:* = param1;
         while(_loc2_ > 0)
         {
            param1 = _loc2_;
            _loc2_ = int(getNextBlockNo(param1));
         }
         return param1;
      }
      
      private function getFileSize(param1:int) : int
      {
         var _loc2_:int = 0;
         while(param1 > 0)
         {
            param1 = getNextBlockNo(param1);
            if(param1 > 0)
            {
               _loc2_ += 2036;
            }
         }
         if(param1 != 0)
         {
            _loc2_ -= param1 + 1;
         }
         return _loc2_;
      }
      
      private function reserveDirEntry() : void
      {
         var _loc3_:* = null;
         var _loc2_:int = 0;
         for each(var _loc1_ in dirTable)
         {
            _loc2_++;
            if(_loc1_.canAddEntry())
            {
               break;
            }
            if(_loc1_.nextBlkNo == 0 || _loc2_ == dirTable.length)
            {
               if(_loc1_.nextBlkNo)
               {
                  netTrace("[ARFS-" + seq + "] " + "[ERROR} [Arfs] reserveDirEntry. directory tail was lost. losted block = " + _loc1_.nextBlkNo);
                  _loc1_.dirty = true;
                  _loc1_.nextBlkNo = 0;
               }
               _loc3_ = _loc1_.addDirBlock(this,getNextBlkNo());
               dirTable[_loc2_] = _loc3_;
               break;
            }
         }
      }
      
      private function addPath(param1:String, param2:int, param3:int) : void
      {
         var _loc8_:* = null;
         var _loc4_:DirEntry = directory[param1];
         var _loc5_:DirEntry = null;
         var _loc7_:int = 0;
         for each(var _loc6_ in dirTable)
         {
            _loc7_++;
            if(_loc5_ = _loc6_.addEntry(param1,param2,param3))
            {
               break;
            }
            if(_loc6_.nextBlkNo == 0 || _loc7_ == dirTable.length)
            {
               if(_loc6_.nextBlkNo)
               {
                  netTrace("[ARFS-" + seq + "] " + "[ERROR} [Arfs] directory tail was lost. losted block = " + _loc6_.nextBlkNo);
                  _loc6_.dirty = true;
                  _loc6_.nextBlkNo = 0;
               }
               _loc8_ = _loc6_.addDirBlock(this,getNextBlkNo());
               dirTable[dirTable.length] = _loc8_;
               _loc5_ = _loc8_.addEntry(param1,param2,param3);
               break;
            }
            if(_loc5_)
            {
               break;
            }
         }
         if(!_loc5_)
         {
            throw new IOError("add path failed");
         }
         if(_loc4_)
         {
            delete directory[param1];
            _loc4_.setType(2);
            header.addBlkNoToRemove(_loc4_.firstBlkNo);
            header.removeFreeBlock(this);
         }
         directory[param1] = _loc5_;
      }
      
      private function readDirectory(param1:Function = null) : void
      {
         var callback:Function = param1;
         var readBlockCallback:* = function(param1:int, param2:int, param3:ByteArray):void
         {
            var _loc4_:* = null;
            if(!param3)
            {
               (_loc4_ = new DirBlock()).setSeqNo(cnt);
               _loc4_.myBlkNo = blkno;
               _loc4_.nextBlkNo = 0;
               dirTable.push(_loc4_);
               cnt++;
               if(callback)
               {
                  callback(cnt);
               }
               return;
            }
            (_loc4_ = new DirBlock()).setSeqNo(cnt);
            _loc4_.myBlkNo = blkno;
            _loc4_.nextBlkNo = param1;
            _loc4_.readFrom(param3);
            dirTable.push(_loc4_);
            _loc4_.extractEntries(directory,header.lastBlkNo);
            cnt++;
            param3.clear();
            blkno = param1;
            if(blkno > 0)
            {
               if(blkno <= header.lastBlkNo)
               {
                  readBlock(blkno,param3,0,readBlockCallback);
               }
               else
               {
                  netTrace("[ARFS-" + seq + "] " + "readDirectory No." + cnt + " out of range. blkNo=" + blkno);
                  _loc4_.nextBlkNo = 0;
                  if(callback)
                  {
                     callback(cnt);
                  }
               }
            }
            else if(callback)
            {
               callback(cnt);
            }
         };
         directory = new Dictionary();
         var buff:ByteArray = new ByteArray();
         var blkno:int = header.rootdirBlkNo;
         var cnt:int = 0;
         dirTable = [];
         if(blkno > 0)
         {
            readBlock(blkno,buff,0,readBlockCallback);
         }
         else if(callback)
         {
            callback(0);
         }
      }
      
      private function writeDirectory(param1:Function = null) : void
      {
         var callback:Function = param1;
         var writeCallback:* = function(param1:int, param2:int, param3:int):void
         {
            blockIndex++;
            if(blockIndex < dirTable.length)
            {
               buff.clear();
               dirBlock = DirBlock(dirTable[blockIndex]);
               while(!dirBlock.dirty)
               {
                  blockIndex++;
                  if(blockIndex >= dirTable.length)
                  {
                     if(callback)
                     {
                        callback();
                     }
                     return;
                  }
                  dirBlock = DirBlock(dirTable[blockIndex]);
               }
               dirBlock.writeTo(buff);
               writeBlock(dirBlock.myBlkNo,dirBlock.nextBlkNo,buff,0,buff.length,writeCallback);
            }
            else if(callback)
            {
               callback();
            }
         };
         var blockIndex:int = 0;
         if(header.rootdirBlkNo > 0)
         {
            var dirBlock:DirBlock = DirBlock(dirTable[0]);
            if(dirBlock.myBlkNo != header.rootdirBlkNo)
            {
               header.rootdirBlkNo = firstBlkNo;
               header.savedDirBlkNo = header.rootdirBlkNo;
            }
         }
         else
         {
            var firstBlkNo:int = getNextBlkNo();
            var nextBlkNo:int = 0;
            header.rootdirBlkNo = firstBlkNo;
            header.savedDirBlkNo = header.rootdirBlkNo;
            dirBlock = new DirBlock(firstBlkNo);
            dirTable[0] = dirBlock;
            numDirBlock = 1;
         }
         var len:int = 0;
         var buff:ByteArray = new ByteArray();
         while(!dirBlock.dirty)
         {
            blockIndex++;
            if(blockIndex >= dirTable.length)
            {
               if(callback)
               {
                  callback();
               }
               return;
            }
            dirBlock = DirBlock(dirTable[blockIndex]);
         }
         dirBlock.writeTo(buff);
         buff.position = 0;
         writeBlock(dirBlock.myBlkNo,dirBlock.nextBlkNo,buff,0,buff.length,writeCallback);
      }
      
      private function getNextBlockNo(param1:int) : int
      {
         var _loc4_:int = param1 / 678;
         var _loc5_:int = param1 % 678;
         if(_loc4_ >= fatTable.length)
         {
            return 0;
         }
         var _loc3_:FAT = FAT(fatTable[_loc4_]);
         return int(_loc3_.blk[_loc5_]);
      }
      
      public function setBlockNo(param1:int, param2:int) : int
      {
         var _loc5_:int = param1 / 678;
         var _loc6_:int = param1 % 678;
         if(_loc5_ >= fatTable.length)
         {
            return 0;
         }
         var _loc4_:FAT;
         var _loc3_:int = (_loc4_ = FAT(fatTable[_loc5_])).blk[_loc6_];
         _loc4_.blk[_loc6_] = param2;
         _loc4_.dirty = true;
         return _loc3_;
      }
      
      private function readFAT(param1:Function) : void
      {
         var callBack:Function = param1;
         var readBlockCallback:* = function(param1:int, param2:int, param3:ByteArray):void
         {
            if(!param3)
            {
               callBack(cnt);
               return;
            }
            var _loc4_:FAT;
            (_loc4_ = new FAT()).setSeqNo(cnt);
            _loc4_.load(param3,param2);
            _loc4_.myBlkNo = blkno;
            _loc4_.nextBlkNo = param1;
            fatTable.push(_loc4_);
            cnt++;
            param3.clear();
            blkno = param1;
            if(blkno > 0)
            {
               if(blkno <= header.lastBlkNo)
               {
                  readBlock(blkno,param3,0,readBlockCallback);
               }
               else
               {
                  netTrace("[ARFS-" + seq + "] " + "readFAT No." + cnt + " out of range. blkNo=" + blkno);
                  _loc4_.nextBlkNo = 0;
                  callBack(cnt);
               }
            }
            else
            {
               callBack(cnt);
            }
         };
         var buff:ByteArray = new ByteArray();
         var blkno:int = header.fatTableBlkNo;
         var cnt:int = 0;
         fatTable = [];
         if(blkno > 0)
         {
            readBlock(blkno,buff,0,readBlockCallback);
         }
         else
         {
            callBack(0);
         }
      }
      
      private function writeFAT(param1:Function) : void
      {
         var callback:Function = param1;
         var writeCallback:* = function(param1:int, param2:int, param3:int):void
         {
            fat = null;
            while(++findex < numFat)
            {
               fat = FAT(fatTable[findex]);
               if(fat.dirty)
               {
                  break;
               }
               fat = null;
            }
            if(fat)
            {
               buff.clear();
               fat.save(buff);
               writeBlock(fat.myBlkNo,fat.nextBlkNo,buff,0,buff.length,writeCallback);
            }
            else if(callback)
            {
               callback();
            }
         };
         pendingFats = [];
         var buff:ByteArray = new ByteArray();
         var findex:int = 0;
         var fat:FAT = null;
         if(numFat > 0)
         {
            header.fatTableBlkNo = FAT(fatTable[0]).myBlkNo;
         }
         while(findex < numFat)
         {
            fat = FAT(fatTable[findex]);
            if(fat.dirty)
            {
               break;
            }
            fat = null;
            findex++;
         }
         if(fat)
         {
            fat.save(buff);
            writeBlock(fat.myBlkNo,fat.nextBlkNo,buff,0,buff.length,writeCallback);
         }
         else if(callback)
         {
            callback();
         }
      }
   }
}

import flash.utils.ByteArray;
import gudetama.engine.Arfs;

class FAT
{
    
   
   private var seqno:int = 0;
   
   private var myBlkNo:int;
   
   private var nextBlkNo:int = 0;
   
   private var off:int = 0;
   
   private var blk:Array;
   
   private var dirty:Boolean = true;
   
   function FAT(param1:int = 0)
   {
      var _loc2_:int = 0;
      blk = [];
      super();
      myBlkNo = param1;
      _loc2_ = 0;
      while(_loc2_ < 678)
      {
         blk[_loc2_] = 0;
         _loc2_++;
      }
      dirty = true;
   }
   
   private function setSeqNo(param1:int) : void
   {
      this.seqno = param1;
      off = param1 * 678;
   }
   
   private function load(param1:ByteArray, param2:int) : void
   {
      var _loc4_:int = 0;
      var _loc3_:int = param2 / 3;
      _loc4_ = 0;
      while(_loc4_ < _loc3_)
      {
         blk[_loc4_] = Arfs.readInt3(param1);
         _loc4_++;
      }
      dirty = false;
   }
   
   private function save(param1:ByteArray) : int
   {
      var _loc2_:int = 0;
      _loc2_ = 0;
      while(_loc2_ < 678)
      {
         Arfs.writeInt3(param1,blk[_loc2_]);
         _loc2_++;
      }
      dirty = false;
      return nextBlkNo;
   }
   
   private function reserve() : int
   {
      var _loc1_:int = 0;
      _loc1_ = 0;
      while(_loc1_ < 678 - 1)
      {
         if(blk[_loc1_] == 0)
         {
            blk[_loc1_] = -1;
            dirty = true;
            return off + _loc1_;
         }
         _loc1_++;
      }
      return -1;
   }
   
   private function checkBlkno(param1:int) : int
   {
      var _loc3_:int = 0;
      var _loc2_:int = 0;
      _loc3_ = 0;
      while(_loc3_ < 678 - 1)
      {
         if(blk[_loc3_] != 0 && off + _loc3_ > param1)
         {
            blk[_loc3_] = 0;
            dirty = true;
            _loc2_ = off + _loc3_;
         }
         else if(blk[_loc3_] > param1)
         {
            _loc2_ = blk[_loc3_];
            blk[_loc3_] = -1;
            dirty = true;
         }
         _loc3_++;
      }
      return _loc2_;
   }
   
   private function addFat(param1:Arfs, param2:int) : FAT
   {
      nextBlkNo = param2;
      var _loc3_:FAT = new FAT(nextBlkNo);
      _loc3_.setSeqNo(seqno + 1);
      param1.setBlockNo(myBlkNo,nextBlkNo);
      dirty = true;
      return _loc3_;
   }
}

import flash.utils.ByteArray;
import gudetama.engine.Arfs;

class DirEntry
{
   
   public static const SizeOfDirEntry:int = 82;
   
   public static const MAX_PATH_LENGTH:int = 64;
   
   public static const NORMAL_FILE:int = 0;
   
   public static const DIRECTORY_FILE:int = 1;
   
   public static const REMOVED_FILE:int = 2;
    
   
   private var removed:Boolean = false;
   
   private var fileName:String;
   
   private var size:int;
   
   private var firstBlkNo:int;
   
   private var type:int = 0;
   
   private var blockIndex:int = 0;
   
   private var parent:DirBlock;
   
   function DirEntry(param1:String = null)
   {
      super();
      this.fileName = param1;
   }
   
   private function setType(param1:int) : void
   {
      this.type = param1;
      if(parent)
      {
         parent.dirty = true;
      }
   }
   
   private function isDirectory() : Boolean
   {
      return type == 1;
   }
   
   private function isRemoved() : Boolean
   {
      return type == 2;
   }
   
   private function readFrom(param1:ByteArray) : void
   {
      var _loc2_:int = param1.position;
      fileName = param1.readUTF();
      param1.position = _loc2_ + 64 + 2;
      type = param1.readByte();
      size = param1.readInt();
      firstBlkNo = Arfs.readInt3(param1);
      param1.position = _loc2_ + 82;
   }
   
   private function writeTo(param1:ByteArray) : void
   {
      var _loc2_:int = param1.position;
      param1.writeUTF(fileName);
      param1.length = _loc2_ + 64 + 2;
      param1.position = param1.length;
      param1.writeByte(type);
      param1.writeInt(size);
      Arfs.writeInt3(param1,firstBlkNo);
      param1.length = _loc2_ + 82;
      param1.position = param1.length;
   }
}

import flash.utils.ByteArray;
import flash.utils.Dictionary;
import gudetama.engine.Arfs;
import gudetama.engine.Logger;

class DirBlock
{
   
   public static const MAX_NUM_ENTRIES:int = 24;
    
   
   private var seqno:int = 0;
   
   private var myBlkNo:int;
   
   private var nextBlkNo:int = 0;
   
   private var entries:Array = null;
   
   private var dirty:Boolean = true;
   
   function DirBlock(param1:int = 0)
   {
      super();
      myBlkNo = param1;
      entries = [];
   }
   
   private function setSeqNo(param1:int) : void
   {
      seqno = param1;
   }
   
   private function readFrom(param1:ByteArray) : void
   {
      var _loc4_:int = 0;
      var _loc2_:* = null;
      seqno = param1.readShort();
      var _loc3_:int = param1.readShort();
      entries = [];
      _loc4_ = 0;
      while(_loc4_ < _loc3_)
      {
         _loc2_ = new DirEntry();
         _loc2_.readFrom(param1);
         _loc2_.blockIndex = seqno;
         _loc2_.parent = this;
         entries[_loc4_] = _loc2_;
         _loc4_++;
      }
      dirty = false;
   }
   
   private function writeTo(param1:ByteArray) : void
   {
      var _loc2_:int = 0;
      var _loc3_:int = param1.position;
      param1.writeShort(seqno);
      param1.writeShort(entries.length);
      _loc2_ = 0;
      while(_loc2_ < entries.length)
      {
         entries[_loc2_].writeTo(param1);
         _loc2_++;
      }
      param1.length = _loc3_ + 2036;
      param1.position = param1.length;
      dirty = false;
   }
   
   private function extractEntries(param1:Dictionary, param2:int) : void
   {
      for each(var _loc3_ in entries)
      {
         if(!_loc3_.isRemoved())
         {
            if(_loc3_.firstBlkNo > param2)
            {
               Logger.warn("[Arfs] extractEntries. path has invalid block. path=" + _loc3_.fileName + ", firstBlkNo=" + _loc3_.firstBlkNo + ", lastBlkNo=" + param2);
               _loc3_.removed = true;
               _loc3_.setType(2);
            }
            else
            {
               if(param1[_loc3_.fileName])
               {
                  Arfs.netTrace("[ERROR] [Arfs] extractEntries. path is already exist. path=" + _loc3_.fileName + ", myBlkNo=" + myBlkNo);
               }
               param1[_loc3_.fileName] = _loc3_;
            }
         }
      }
   }
   
   private function canAddEntry() : Boolean
   {
      if(entries.length + 1 < 24)
      {
         return true;
      }
      for each(var _loc1_ in entries)
      {
         if(_loc1_.isRemoved())
         {
            return true;
         }
      }
      return false;
   }
   
   private function addEntry(param1:String, param2:int, param3:int) : DirEntry
   {
      var _loc4_:* = null;
      if(entries.length + 1 < 24)
      {
         (_loc4_ = new DirEntry()).fileName = param1;
         _loc4_.firstBlkNo = param2;
         _loc4_.size = param3;
         _loc4_.blockIndex = seqno;
         _loc4_.parent = this;
         entries[entries.length] = _loc4_;
         dirty = true;
         return _loc4_;
      }
      for each(var _loc5_ in entries)
      {
         if(_loc5_.isRemoved())
         {
            _loc5_.setType(0);
            _loc5_.fileName = param1;
            _loc5_.firstBlkNo = param2;
            _loc5_.size = param3;
            _loc5_.blockIndex = seqno;
            dirty = true;
            return _loc5_;
         }
      }
      return null;
   }
   
   private function addDirBlock(param1:Arfs, param2:int) : DirBlock
   {
      nextBlkNo = param2;
      var _loc3_:DirBlock = new DirBlock(param2);
      _loc3_.setSeqNo(seqno + 1);
      param1.setBlockNo(myBlkNo,nextBlkNo);
      dirty = true;
      return _loc3_;
   }
}

import flash.errors.IOError;
import flash.utils.ByteArray;
import gudetama.engine.Arfs;

class Header
{
    
   
   private var magic:int = 2086857395;
   
   private var lastBlkNo:int = 1;
   
   private var rootdirBlkNo:int = 0;
   
   private var savedDirBlkNo:int = 0;
   
   private var fatTableBlkNo:int = 0;
   
   private var savedFatTableBlkNo:int = 0;
   
   private var version:int = 21;
   
   private var comment:String = "";
   
   private var rmBlkCnt:int = 0;
   
   private var rmblkSz:int = 20;
   
   private var rmblks:Array;
   
   private var rmBlkCntLoaded:int = 0;
   
   private var dirty:Boolean = false;
   
   function Header(param1:String = null)
   {
      super();
      this.comment = param1;
      dirty = true;
      rmBlkCntLoaded = -1;
      rmblks = [];
   }
   
   private function isNeedsToSave() : Boolean
   {
      return dirty && (rmBlkCntLoaded != 0 || rmBlkCntLoaded != rmBlkCnt);
   }
   
   private function load(param1:ByteArray) : void
   {
      var _loc2_:int = 0;
      param1.position = 0;
      magic = param1.readInt();
      if(magic != 2086857395)
      {
         throw new IOError("invalid file format");
      }
      version = param1.readShort();
      if(version < 21)
      {
         throw new IOError("old version");
      }
      lastBlkNo = Arfs.readInt3(param1);
      rootdirBlkNo = Arfs.readInt3(param1);
      savedDirBlkNo = Arfs.readInt3(param1);
      fatTableBlkNo = Arfs.readInt3(param1);
      savedFatTableBlkNo = Arfs.readInt3(param1);
      comment = param1.readUTF();
      rmBlkCnt = param1.readShort();
      rmblkSz = (2036 - param1.position) / 3;
      rmblks = [];
      _loc2_ = 0;
      while(_loc2_ < rmBlkCnt)
      {
         rmblks[_loc2_] = Arfs.readInt3(param1);
         _loc2_++;
      }
      rmBlkCntLoaded = rmBlkCnt;
      dirty = false;
   }
   
   private function save(param1:ByteArray) : void
   {
      var _loc2_:int = 0;
      param1.position = 0;
      param1.writeInt(magic);
      param1.writeShort(version);
      Arfs.writeInt3(param1,lastBlkNo);
      Arfs.writeInt3(param1,rootdirBlkNo);
      Arfs.writeInt3(param1,savedDirBlkNo);
      Arfs.writeInt3(param1,fatTableBlkNo);
      Arfs.writeInt3(param1,savedFatTableBlkNo);
      param1.writeUTF(comment);
      param1.writeShort(rmBlkCnt);
      rmblkSz = (2036 - param1.position) / 3;
      _loc2_ = 0;
      while(_loc2_ < rmBlkCnt)
      {
         Arfs.writeInt3(param1,rmblks[_loc2_]);
         _loc2_++;
      }
      rmBlkCntLoaded = rmBlkCnt;
      dirty = false;
   }
   
   private function addBlkNoToRemove(param1:int) : void
   {
      if(param1 <= 0)
      {
         return;
      }
      if(rmBlkCnt < rmblkSz)
      {
         rmblks[rmBlkCnt++] = param1;
      }
      else
      {
         keepRmBlock(param1);
      }
      dirty = true;
   }
   
   private function keepRmBlock(param1:int) : void
   {
      Arfs.netTrace("FreeBlock table full");
   }
   
   private function removeFreeBlock(param1:Arfs) : void
   {
      var _loc2_:int = 0;
      _loc2_ = 0;
      while(_loc2_ < rmBlkCnt)
      {
         param1.setRemovedBlock(rmblks[_loc2_]);
         _loc2_++;
      }
      rmBlkCnt = 0;
      dirty = true;
   }
}

class ArfsRequest
{
   
   public static const REQ_CRETAE:int = 1;
   
   public static const REQ_LOAD:int = 2;
   
   public static const REQ_MKDIR:int = 3;
   
   public static const REQ_UNLINK:int = 4;
    
   
   public var reqType:int;
   
   public var originalCallback:Function;
   
   public var proxyCallback:Function;
   
   function ArfsRequest()
   {
      super();
   }
}

class ReadBlockRequest extends ArfsRequest
{
    
   
   public var blockNoRequested:int;
   
   function ReadBlockRequest()
   {
      super();
   }
}

import flash.utils.ByteArray;

class WriteBlockRequest extends ArfsRequest
{
    
   
   public var blockNoRequested:int;
   
   public var buff:ByteArray;
   
   function WriteBlockRequest()
   {
      super();
   }
}

import flash.utils.ByteArray;

class CreateRequest extends ArfsRequest
{
    
   
   public var path:String;
   
   public var buff:ByteArray;
   
   function CreateRequest()
   {
      super();
      reqType = 1;
   }
}

import flash.utils.ByteArray;

class LoadRequest extends ArfsRequest
{
    
   
   public var path:String;
   
   public var buff:ByteArray;
   
   function LoadRequest()
   {
      super();
      reqType = 2;
   }
}

class MkdirRequest extends ArfsRequest
{
    
   
   public var path:String;
   
   function MkdirRequest()
   {
      super();
      reqType = 3;
   }
}

class UnlinkRequest extends ArfsRequest
{
    
   
   public var path:String;
   
   function UnlinkRequest()
   {
      super();
      reqType = 4;
   }
}

class ProgressInfo
{
    
   
   public var blockNoRequested:int;
   
   public var completionCallback:Function;
   
   function ProgressInfo()
   {
      super();
   }
}
