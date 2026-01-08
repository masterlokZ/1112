package managers
{
   import flash.filesystem.File;
   import flash.filesystem.FileStream;
   
   public class ConfigManager
   {
      
      private var _settingsXML:XML;
      
      private var _serverXML:XML;
      
      private var _beanXML:XML;
      
      private var _isDebug:Boolean = false;
      
      private var _isLocal:Boolean = false;
      
      private var _domain:String = "fish-yet.733702.xyz";
      
      private var _rootURL:String = "http://8.217.250.123/seer2/";
      
      public function ConfigManager()
      {
         super();
      }
      
      public function loadGameSettings(param1:Function, param2:Function) : void
      {
         var _loc3_:File = null;
         var _loc4_:FileStream = null;
         try
         {
            _loc3_ = File.applicationStorageDirectory.resolvePath("gameSettings/GameSettings.xml");
            if(_loc3_.exists)
            {
               _loc4_ = new FileStream();
               _loc4_.open(_loc3_,"read");
               this._settingsXML = XML(_loc4_.readUTFBytes(_loc4_.bytesAvailable));
               _loc4_.close();
               if(this._settingsXML.elements("domain").length() == 0)
               {
                  this._settingsXML.appendChild(<domain>{this._domain}</domain>);
                  param1("fish-yet.733702.xyz");
               }
               else
               {
                  this._domain = this._settingsXML.elements("domain")[0].toString();
                  param1(this._domain);
               }
            }
            else
            {
               param2("CONFIG_NOT_FOUND");
            }
         }
         catch(e:Error)
         {
            param2("读取配置文件失败: " + e.message);
         }
      }
      
      public function saveDomainSetting(param1:String, param2:Function, param3:Function) : void
      {
         var _loc4_:File = null;
         var _loc5_:FileStream = null;
         try
         {
            _loc4_ = File.applicationStorageDirectory.resolvePath("gameSettings/GameSettings.xml");
            _loc5_ = new FileStream();
            _loc5_.open(_loc4_,"write");
            if(this._settingsXML.elements("domain").length() == 0)
            {
               this._settingsXML.appendChild(<domain>{param1}</domain>);
            }
            else
            {
               this._settingsXML.elements("domain")[0] = param1;
            }
            _loc5_.writeUTFBytes(this._settingsXML);
            _loc5_.close();
            param2();
         }
         catch(e:Error)
         {
            param3("保存配置失败: " + e.message);
         }
      }
      
      public function setBeanXML(param1:XML) : void
      {
         this._beanXML = param1;
      }
      
      public function setServerXML(param1:XML) : void
      {
         this._serverXML = param1;
      }
      
      public function setRootURL(param1:String) : void
      {
         this._rootURL = param1;
      }
      
      public function setDebugMode(param1:Boolean) : void
      {
         this._isDebug = param1;
      }
      
      public function setLocalMode(param1:Boolean) : void
      {
         this._isLocal = param1;
      }
      
      public function getConfigData() : Object
      {
         return {
            "settingsXML":this._settingsXML,
            "serverXML":this._serverXML,
            "beanXML":this._beanXML,
            "rootURL":this._rootURL,
            "isDebug":this._isDebug,
            "isLocal":this._isLocal
         };
      }
      
      public function get settingsXML() : XML
      {
         return this._settingsXML;
      }
      
      public function get serverXML() : XML
      {
         return this._serverXML;
      }
      
      public function get beanXML() : XML
      {
         return this._beanXML;
      }
      
      public function get rootURL() : String
      {
         return this._rootURL;
      }
      
      public function get domain() : String
      {
         return this._domain;
      }
      
      public function get isDebug() : Boolean
      {
         return this._isDebug;
      }
      
      public function get isLocal() : Boolean
      {
         return this._isLocal;
      }
      
      public function dispose() : void
      {
         this._settingsXML = null;
         this._serverXML = null;
         this._beanXML = null;
      }
   }
}

