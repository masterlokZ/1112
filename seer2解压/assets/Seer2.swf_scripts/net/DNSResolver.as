package net
{
   import events.DNSResolveEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.TimerEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.utils.Timer;
   
   public class DNSResolver extends EventDispatcher
   {
      
      private static const TIMEOUT:int = 4000;
      
      public static const RESOLVE_COMPLETE:String = "resolveComplete";
      
      public static const RESOLVE_ERROR:String = "resolveError";
      
      private static const DNS_SERVERS:Array = ["https://223.5.5.5/resolve","https://dns.google/resolve","https://doh.360.cn/resolve","https://cloudflare-dns.com/dns-resolve","https://223.6.6.6/resolve"];
      
      private var currentDNSIndex:int = 0;
      
      private var targetDomain:String;
      
      private var loader:URLLoader;
      
      private var timer:Timer;
      
      public function DNSResolver(param1:String)
      {
         super();
         this.targetDomain = param1;
         this.loader = new URLLoader();
         this.timer = new Timer(4000,1);
         setupListeners();
      }
      
      public function resolve() : void
      {
         tryNextDNS();
      }
      
      private function setupListeners() : void
      {
         loader.addEventListener("complete",onLoadComplete);
         loader.addEventListener("ioError",onLoadError);
         timer.addEventListener("timerComplete",onTimeout);
      }
      
      private function tryNextDNS() : void
      {
         if(currentDNSIndex >= DNS_SERVERS.length)
         {
            dispatchEvent(new Event("resolveError"));
            return;
         }
         var _loc1_:URLRequest = new URLRequest(DNS_SERVERS[currentDNSIndex] + "?name=" + targetDomain + "&type=TXT");
         _loc1_.requestHeaders = [{
            "name":"accept",
            "value":"application/dns-json"
         }];
         try
         {
            loader.load(_loc1_);
            timer.start();
         }
         catch(e:Error)
         {
            onLoadError(null);
         }
      }
      
      private function onLoadComplete(param1:Event) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         timer.stop();
         try
         {
            _loc2_ = JSON.parse(loader.data);
            if(_loc2_.Answer && _loc2_.Answer.length > 0)
            {
               _loc3_ = _loc2_.Answer[0].data;
               _loc3_ = _loc3_.replace(/"/g,"");
               dispatchEvent(new DNSResolveEvent("resolveComplete",_loc3_));
               return;
            }
         }
         catch(e:Error)
         {
         }
         currentDNSIndex = currentDNSIndex + 1;
         tryNextDNS();
      }
      
      private function onLoadError(param1:IOErrorEvent) : void
      {
         timer.stop();
         currentDNSIndex = currentDNSIndex + 1;
         tryNextDNS();
      }
      
      private function onTimeout(param1:TimerEvent) : void
      {
         loader.close();
         currentDNSIndex = currentDNSIndex + 1;
         tryNextDNS();
      }
      
      public function dispose() : void
      {
         loader.removeEventListener("complete",onLoadComplete);
         loader.removeEventListener("ioError",onLoadError);
         timer.removeEventListener("timerComplete",onTimeout);
         loader = null;
         timer = null;
      }
   }
}

