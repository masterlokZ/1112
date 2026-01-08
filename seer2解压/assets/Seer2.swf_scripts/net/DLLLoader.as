package net
{
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.filesystem.File;
   import flash.filesystem.FileStream;
   import flash.net.URLRequest;
   import flash.net.URLStream;
   import flash.utils.ByteArray;
   
   public class DLLLoader extends EventDispatcher
   {
      
      public static const DECRYPTION_ERROR:String = "decryptionError";
      
      public static const DECRYPTION_SUCCESS:String = "decryptionSuccess";
      
      private var _loader:Loader;
      
      private var urlStream:URLStream;
      
      private var fileStream:FileStream;
      
      private var key:String;
      
      public function DLLLoader()
      {
         super();
         this._loader = new Loader();
      }
      
      public function loadFromOrigin(param1:String, param2:String) : void
      {
         this.urlStream = new URLStream();
         this.key = param2;
         this.urlStream.addEventListener("progress",this.onProgress);
         this.urlStream.addEventListener("complete",this.onStreamComplete);
         this.urlStream.load(new URLRequest(param1));
      }
      
      public function loadFromLocal(param1:File, param2:String) : void
      {
         this.fileStream = new FileStream();
         this.key = param2;
         this.fileStream.addEventListener("progress",this.onProgress);
         this.fileStream.addEventListener("complete",this.onStreamComplete);
         this.fileStream.openAsync(param1,"read");
      }
      
      private function onStreamComplete(param1:Event) : void
      {
         var _loc2_:ByteArray = new ByteArray();
         if(this.fileStream != null)
         {
            this.fileStream.readBytes(_loc2_);
            this.fileStream.close();
            this.fileStream.removeEventListener("progress",this.onProgress);
            this.fileStream = null;
         }
         else
         {
            this.urlStream.readBytes(_loc2_);
            this.urlStream.close();
            this.urlStream.removeEventListener("progress",this.onProgress);
            this.urlStream = null;
         }
         Crypto.rc4Decrypt(_loc2_,this.key);
         this._loader.contentLoaderInfo.addEventListener("complete",this.onLoaderOver);
         this._loader.contentLoaderInfo.addEventListener("ioError",this.onLoaderError);
         this._loader.loadBytes(_loc2_,Client.lc);
      }
      
      private function onLoaderOver(param1:Event) : void
      {
         this._loader.contentLoaderInfo.removeEventListener("complete",this.onLoaderOver);
         this._loader.contentLoaderInfo.removeEventListener("ioError",this.onLoaderError);
         dispatchEvent(new Event("complete"));
      }
      
      private function onLoaderError(param1:IOErrorEvent) : void
      {
         this._loader.contentLoaderInfo.removeEventListener("complete",this.onLoaderOver);
         this._loader.contentLoaderInfo.removeEventListener("ioError",this.onLoaderError);
         dispatchEvent(new Event("decryptionError"));
      }
      
      private function onProgress(param1:ProgressEvent) : void
      {
         dispatchEvent(param1);
      }
   }
}

