package managers
{
   import events.XMLEvent;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   import flash.utils.getDefinitionByName;
   import net.AssetsLoader;
   import net.DLLLoader;
   import net.XMLLoader;
   
   public class ResourceManager
   {
      
      public static var loaderContext:LoaderContext;
      
      private var _assetsLoader:AssetsLoader;
      
      private var _xmlLoader:XMLLoader;
      
      private var _dllLoader:DLLLoader;
      
      private var _loginLoader:Loader;
      
      public function ResourceManager()
      {
         super();
         if(loaderContext == null)
         {
            loaderContext = new LoaderContext(false);
            loaderContext.allowCodeImport = true;
         }
      }
      
      public function loadAssets(param1:Function, param2:Function) : void
      {
         var onComplete:Function = param1;
         var onError:Function = param2;
         this._assetsLoader = new AssetsLoader();
         this._assetsLoader.addEventListener("complete",function(param1:Event):void
         {
            _assetsLoader.removeEventListener("complete",arguments.callee);
            onComplete(_assetsLoader);
         });
         this._assetsLoader.load();
      }
      
      public function loadXML(param1:String, param2:Function, param3:Function, param4:Function = null) : void
      {
         var path:String = param1;
         var onComplete:Function = param2;
         var onError:Function = param3;
         var onProgress:Function = param4;
         this._xmlLoader = new XMLLoader();
         this._xmlLoader.addEventListener("complete",function(param1:XMLEvent):void
         {
            _xmlLoader.removeEventListener("complete",arguments.callee);
            if(onProgress != null)
            {
               _xmlLoader.removeEventListener("progress",onProgress);
            }
            onComplete(param1.data);
         });
         if(onProgress != null)
         {
            this._xmlLoader.addEventListener("progress",onProgress);
         }
         this._xmlLoader.load(path);
      }
      
      public function loadLoginModule(param1:String, param2:Function, param3:Function, param4:Function = null) : void
      {
         var onIOError:Function;
         var path:String = param1;
         var onComplete:Function = param2;
         var onError:Function = param3;
         var onProgress:Function = param4;
         this._loginLoader = new Loader();
         this._loginLoader.contentLoaderInfo.addEventListener("complete",function(param1:Event):void
         {
            var event:Event = param1;
            var loaderInfo:LoaderInfo = event.target as LoaderInfo;
            var secondLoader:Loader = new Loader();
            secondLoader.contentLoaderInfo.addEventListener("complete",function(param1:Event):void
            {
               var _loc3_:LoaderInfo = param1.target as LoaderInfo;
               _loc3_.removeEventListener("complete",arguments.callee);
               onComplete(_loc3_.content);
            });
            secondLoader.loadBytes(loaderInfo.bytes,loaderContext);
            loaderInfo.removeEventListener("complete",arguments.callee);
            if(onProgress != null)
            {
               loaderInfo.removeEventListener("progress",onProgress);
            }
            loaderInfo.removeEventListener("ioError",onIOError);
         });
         onIOError = function(param1:IOErrorEvent):void
         {
            _loginLoader.contentLoaderInfo.removeEventListener("complete",arguments.callee);
            if(onProgress != null)
            {
               _loginLoader.contentLoaderInfo.removeEventListener("progress",onProgress);
            }
            _loginLoader.contentLoaderInfo.removeEventListener("ioError",onIOError);
            onError("加载登录模块失败: " + param1.text);
         };
         if(onProgress != null)
         {
            this._loginLoader.contentLoaderInfo.addEventListener("progress",onProgress);
         }
         this._loginLoader.contentLoaderInfo.addEventListener("ioError",onIOError);
         this._loginLoader.load(new URLRequest(path),loaderContext);
      }
      
      public function loadDLL(param1:*, param2:String, param3:Function, param4:Function, param5:Function = null, param6:Function = null) : void
      {
         var onDecryptSuccess:Function;
         var onDecryptError:Function;
         var file:* = param1;
         var decryptionKey:String = param2;
         var onComplete:Function = param3;
         var onError:Function = param4;
         var onProgress:Function = param5;
         var onDecryptionSuccess:Function = param6;
         this._dllLoader = new DLLLoader();
         this._dllLoader.addEventListener("complete",function(param1:Event):void
         {
            _dllLoader.removeEventListener("complete",arguments.callee);
            if(onProgress != null)
            {
               _dllLoader.removeEventListener("progress",onProgress);
            }
            _dllLoader.removeEventListener("decryptionSuccess",onDecryptSuccess);
            _dllLoader.removeEventListener("decryptionError",onDecryptError);
            onComplete();
         });
         onDecryptSuccess = function(param1:Event):void
         {
            if(onDecryptionSuccess != null)
            {
               onDecryptionSuccess();
            }
         };
         onDecryptError = function(param1:Event):void
         {
            _dllLoader.removeEventListener("complete",arguments.callee);
            if(onProgress != null)
            {
               _dllLoader.removeEventListener("progress",onProgress);
            }
            _dllLoader.removeEventListener("decryptionSuccess",onDecryptSuccess);
            _dllLoader.removeEventListener("decryptionError",onDecryptError);
            onError("DLL解密失败");
         };
         if(onProgress != null)
         {
            this._dllLoader.addEventListener("progress",onProgress);
         }
         this._dllLoader.addEventListener("decryptionSuccess",onDecryptSuccess);
         this._dllLoader.addEventListener("decryptionError",onDecryptError);
         this._dllLoader.loadFromLocal(file,decryptionKey);
      }
      
      public function createMainEntry(param1:String) : Object
      {
         var _loc2_:* = undefined;
         try
         {
            _loc2_ = getDefinitionByName(param1);
            return new _loc2_();
         }
         catch(e:Error)
         {
            throw new Error("创建主入口类失败: " + e.message);
         }
      }
      
      public function unloadLoginModule() : void
      {
         if(this._loginLoader)
         {
            this._loginLoader.unloadAndStop();
            this._loginLoader = null;
         }
      }
      
      public function destroyXMLLoader() : void
      {
         if(this._xmlLoader)
         {
            this._xmlLoader.destroy();
            this._xmlLoader = null;
         }
      }
      
      public function dispose() : void
      {
         if(this._assetsLoader)
         {
            this._assetsLoader.dispose();
            this._assetsLoader = null;
         }
         this.destroyXMLLoader();
         this.unloadLoginModule();
         if(this._dllLoader)
         {
            this._dllLoader = null;
         }
      }
   }
}

