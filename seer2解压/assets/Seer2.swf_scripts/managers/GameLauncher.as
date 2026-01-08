package managers
{
   import com.seer2.extensions.resolution.ResolutionController;
   
   public class GameLauncher
   {
      
      private var _mainEntry:Object;
      
      public function GameLauncher()
      {
         super();
      }
      
      public function launchGame(param1:Object, param2:Client, param3:Object, param4:Object) : void
      {
         var sett:Function;
         var mainEntry:Object = param1;
         var client:Client = param2;
         var configData:Object = param3;
         var loginData:Object = param4;
         this._mainEntry = mainEntry;
         this._mainEntry.setXML(configData.serverXML,configData.beanXML,configData.settingsXML);
         this._mainEntry.setConfig(configData.isDebug,configData.rootURL,configData.isLocal);
         sett = function(param1:Number):void
         {
            ResolutionController.instance.setResolutionScale(param1);
         };
         this._mainEntry.setResolution(ResolutionController.instance.setResolutionScale,Client.originalWidth,Client.originalHeight);
         this._mainEntry.initialize(client,loginData);
      }
      
      public function get mainEntry() : Object
      {
         return this._mainEntry;
      }
      
      public function dispose() : void
      {
         this._mainEntry = null;
      }
   }
}

