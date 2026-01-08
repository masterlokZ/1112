package managers
{
   import events.DNSResolveEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.filesystem.File;
   import flash.filesystem.FileStream;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLStream;
   import flash.utils.ByteArray;
   import net.DNSResolver;
   import net.VersionInfoParser;
   
   public class NetworkManager
   {
      
      private var _dnsResolver:DNSResolver;
      
      private var _versionInfoStream:URLStream;
      
      private var _currentDownloadLoader:URLLoader;
      
      public function NetworkManager()
      {
         super();
      }
      
      public function resolveDNS(param1:String, param2:Function, param3:Function) : void
      {
         var onDNSError:Function;
         var domain:String = param1;
         var onComplete:Function = param2;
         var onError:Function = param3;
         this._dnsResolver = new DNSResolver(domain);
         this._dnsResolver.addEventListener("resolveComplete",function(param1:DNSResolveEvent):void
         {
            _dnsResolver.removeEventListener("resolveComplete",arguments.callee);
            _dnsResolver.removeEventListener("resolveError",onDNSError);
            onComplete(param1.data);
         });
         onDNSError = function(param1:Event):void
         {
            _dnsResolver.removeEventListener("resolveComplete",arguments.callee);
            _dnsResolver.removeEventListener("resolveError",onDNSError);
            onError("DNS解析失败");
         };
         this._dnsResolver.addEventListener("resolveError",onDNSError);
         this._dnsResolver.resolve();
      }
      
      public function checkVersion(param1:String, param2:String, param3:Function, param4:Function) : void
      {
         var onVersionError:Function;
         var rootURL:String = param1;
         var versionURL:String = param2;
         var onComplete:Function = param3;
         var onError:Function = param4;
         this._versionInfoStream = new URLStream();
         this._versionInfoStream.addEventListener("complete",function(param1:Event):void
         {
            _versionInfoStream.removeEventListener("complete",arguments.callee);
            _versionInfoStream.removeEventListener("ioError",onVersionError);
            var _loc5_:ByteArray = new ByteArray();
            _versionInfoStream.readBytes(_loc5_);
            _versionInfoStream.close();
            _versionInfoStream = null;
            var _loc4_:VersionInfoParser = new VersionInfoParser();
            var _loc3_:String = _loc4_.parseVersionInfo(_loc5_);
            if(_loc3_ == "时间码不对")
            {
               onComplete(_loc3_);
            }
            else if(_loc3_ == "要更新应用")
            {
               onError("需要版本更新啦!");
            }
            else
            {
               onComplete(_loc3_);
            }
         });
         onVersionError = function(param1:IOErrorEvent):void
         {
            _versionInfoStream.removeEventListener("complete",arguments.callee);
            _versionInfoStream.removeEventListener("ioError",onVersionError);
            onError("版本检查失败: " + param1.text);
         };
         this._versionInfoStream.addEventListener("ioError",onVersionError);
         this._versionInfoStream.load(new URLRequest(rootURL + versionURL));
      }
      
      public function downloadFileToLocal(param1:String, param2:String, param3:Function, param4:Function, param5:Function = null) : void
      {
         var file:File;
         var onDownloadComplete:Function;
         var onDownloadError:Function;
         var onDownloadProgress:Function;
         var url:String = param1;
         var localPath:String = param2;
         var onComplete:Function = param3;
         var onError:Function = param4;
         var onProgress:Function = param5;
         var urlRequest:URLRequest = new URLRequest(url);
         this._currentDownloadLoader = new URLLoader(urlRequest);
         file = File.applicationStorageDirectory.resolvePath(localPath);
         if(file.exists)
         {
            file.deleteFile();
         }
         onDownloadComplete = function(param1:Event):void
         {
            var _loc2_:FileStream = null;
            _currentDownloadLoader.removeEventListener("complete",onDownloadComplete);
            _currentDownloadLoader.removeEventListener("progress",onDownloadProgress);
            _currentDownloadLoader.removeEventListener("ioError",onDownloadError);
            try
            {
               _loc2_ = new FileStream();
               _loc2_.open(file,"write");
               _loc2_.writeBytes(_currentDownloadLoader.data);
               _loc2_.close();
               onComplete(file.url);
            }
            catch(e:Error)
            {
               onError("文件保存失败: " + e.message);
            }
         };
         onDownloadError = function(param1:IOErrorEvent):void
         {
            _currentDownloadLoader.removeEventListener("complete",onDownloadComplete);
            _currentDownloadLoader.removeEventListener("progress",onDownloadProgress);
            _currentDownloadLoader.removeEventListener("ioError",onDownloadError);
            onError("文件下载失败: " + param1.text);
         };
         onDownloadProgress = function(param1:ProgressEvent):void
         {
            var _loc2_:int = 0;
            if(onProgress != null)
            {
               _loc2_ = param1.bytesLoaded / param1.bytesTotal * 100;
               onProgress(_loc2_);
            }
         };
         this._currentDownloadLoader.dataFormat = "binary";
         this._currentDownloadLoader.addEventListener("complete",onDownloadComplete);
         this._currentDownloadLoader.addEventListener("progress",onDownloadProgress);
         this._currentDownloadLoader.addEventListener("ioError",onDownloadError);
         this._currentDownloadLoader.load(urlRequest);
      }
      
      public function checkLocalFileExists(param1:String) : Boolean
      {
         var _loc2_:File = File.applicationStorageDirectory.resolvePath(param1);
         return _loc2_.exists;
      }
      
      public function getLocalFile(param1:String) : File
      {
         return File.applicationStorageDirectory.resolvePath(param1);
      }
      
      public function dispose() : void
      {
         if(this._dnsResolver)
         {
            this._dnsResolver = null;
         }
         if(this._versionInfoStream)
         {
            this._versionInfoStream.close();
            this._versionInfoStream = null;
         }
         if(this._currentDownloadLoader)
         {
            try
            {
               this._currentDownloadLoader.close();
            }
            catch(e:Error)
            {
            }
            this._currentDownloadLoader = null;
         }
      }
   }
}

