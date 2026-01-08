package net
{
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   
   public class AssetsLoader extends EventDispatcher
   {
      
      private var _loader:Loader;
      
      private const ASSETS_PATH:String = "initialSWF/Assets.swf";
      
      public function AssetsLoader()
      {
         super();
         this._loader = new Loader();
         this._loader.contentLoaderInfo.addEventListener("complete",this.onComplete);
      }
      
      public function dispose() : void
      {
         this._loader.contentLoaderInfo.removeEventListener("complete",this.onComplete);
         this._loader = null;
      }
      
      public function load() : void
      {
         this._loader.load(new URLRequest("initialSWF/Assets.swf"));
      }
      
      private function onComplete(param1:Event) : void
      {
         this._loader.contentLoaderInfo.removeEventListener("complete",this.onComplete);
         dispatchEvent(new Event("complete"));
      }
      
      public function getClassFromLoader(param1:String) : Class
      {
         var _loc2_:ApplicationDomain = this._loader.contentLoaderInfo.applicationDomain;
         if(_loc2_.hasDefinition(param1))
         {
            return _loc2_.getDefinition(param1) as Class;
         }
         return null;
      }
   }
}

