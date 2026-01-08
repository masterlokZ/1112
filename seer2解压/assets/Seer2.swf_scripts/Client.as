package
{
   import async.AsyncTask;
   import async.AsyncTaskManager;
   import com.seer2.extensions.resolution.ResolutionController;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.ProgressEvent;
   import flash.filesystem.File;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import managers.ConfigManager;
   import managers.GameLauncher;
   import managers.NetworkManager;
   import managers.ResourceManager;
   import managers.UIManager;
   
   public class Client extends Sprite
   {
      
      public static var originalWidth:int;
      
      public static var originalHeight:int;
      
      public static var lc:LoaderContext = new LoaderContext(false,ApplicationDomain.currentDomain);
      
      private const MAIN_ENTRY_CLASS_PATH:String = "com.taomee.seer2.app.MainEntry";
      
      private const LOCAL_DLL_PATH:String = "seer2DLL/library.swf";
      
      private const VERSION_URL:String = "version/version.txt";
      
      private const DLL_URL:String = "version/library.swf";
      
      private var _uiManager:UIManager;
      
      private var _configManager:ConfigManager;
      
      private var _networkManager:NetworkManager;
      
      private var _resourceManager:ResourceManager;
      
      private var _gameLauncher:GameLauncher;
      
      private var _taskManager:AsyncTaskManager;
      
      private var _currentState:String = "initializing";
      
      private var _loginData:Object;
      
      private var _dllDecryptionKey:String;
      
      private var _width:Number = 0;
      
      private var _height:Number = 0;
      
      public function Client()
      {
         super();
         lc.allowCodeImport = true;
         this.stage.stageFocusRect = false;
         this.stage.scaleMode = "noScale";
         this.stage.align = "TL";
         ResolutionController.instance.initializeController();
         addEventListener("addedToStage",this.onAddStage);
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = param1;
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set height(param1:Number) : void
      {
         this._height = param1;
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      private function onAddStage(param1:Event) : void
      {
         removeEventListener("addedToStage",this.onAddStage);
         originalWidth = stage.stageWidth;
         originalHeight = stage.stageHeight;
         this.initialize();
      }
      
      private function initialize() : void
      {
         this._uiManager = new UIManager(stage,this);
         this._configManager = new ConfigManager();
         this._networkManager = new NetworkManager();
         this._resourceManager = new ResourceManager();
         this._gameLauncher = new GameLauncher();
         this._taskManager = new AsyncTaskManager();
         this._uiManager.initializeStage();
         this._taskManager.createTask("加载游戏设置",this.taskLoadGameSettings).createTask("加载资源",this.taskLoadAssets).createTask("设置游戏区域",this.taskSetupGameArea).createTask("解析DNS",this.taskResolveDNS).createTask("检查版本",this.taskCheckVersion).createTask("加载Bean配置",this.taskLoadBeanXML).createTask("加载服务器配置",this.taskLoadServerXML).createTask("加载登录界面",this.taskLoadLogin).createTask("等待用户登录",this.taskWaitForLogin).createTask("加载游戏DLL",this.taskLoadDLL).createTask("启动游戏",this.taskLaunchGame);
         this._taskManager.execute(this.onApplicationComplete,this.onApplicationError,this.onTaskComplete);
      }
      
      private function taskLoadAssets(param1:Function, param2:Function) : void
      {
         var complete:Function = param1;
         var error:Function = param2;
         this._currentState = "loading_assets";
         this._resourceManager.loadAssets(function(param1:*):void
         {
            complete(param1);
         },function(param1:String):void
         {
            error("资源加载失败: " + param1);
         });
      }
      
      private function taskSetupGameArea(param1:Function, param2:Function) : void
      {
         var _loc3_:* = undefined;
         try
         {
            _loc3_ = this._taskManager.getPreviousTaskResult();
            this._uiManager.setupGameArea();
            this._uiManager.createBackground();
            this._uiManager.createCloseButton();
            this._uiManager.setupProgressBar(_loc3_.getClassFromLoader("LoginLoadingBarUI"),this);
            this._uiManager.showProgressBar();
            param1();
         }
         catch(e:Error)
         {
            param2("游戏区域设置失败: " + e.message);
         }
      }
      
      private function taskLoadGameSettings(param1:Function, param2:Function) : void
      {
         var complete:Function = param1;
         var error:Function = param2;
         this._currentState = "loading_config";
         this._uiManager.setProgressTitle("正在加载游戏设置");
         this._configManager.loadGameSettings(function(param1:String):void
         {
            complete(param1);
         },function(param1:String):void
         {
            var errorMsg:String = param1;
            if(errorMsg == "CONFIG_NOT_FOUND")
            {
               _networkManager.downloadFileToLocal("initialSWF/GameDefaultSettings.xml","gameSettings/GameSettings.xml",function():void
               {
                  taskLoadGameSettings(complete,error);
               },function(param1:String):void
               {
                  error("下载默认配置失败: " + param1);
               });
            }
            else
            {
               error(errorMsg);
            }
         });
      }
      
      private function taskResolveDNS(param1:Function, param2:Function) : void
      {
         var domain:String;
         var complete:Function = param1;
         var error:Function = param2;
         this._currentState = "resolving_dns";
         this._uiManager.setProgressTitle("正在解析域名, 获取游戏资源地址");
         domain = this._configManager.domain;
         this._networkManager.resolveDNS(domain,function(param1:String):void
         {
            _configManager.setRootURL(param1);
            complete(param1);
         },function(param1:String):void
         {
            var errorMsg:String = param1;
            _uiManager.inputText("请手动输入域名",function(param1:String):void
            {
               var input:String = param1;
               _uiManager.setProgressTitle("正在保存域名");
               _configManager.saveDomainSetting(input,function():void
               {
                  taskResolveDNS(complete,error);
               },function(param1:String):void
               {
                  error("保存域名失败: " + param1);
               });
            });
         });
      }
      
      private function taskCheckVersion(param1:Function, param2:Function) : void
      {
         var complete:Function = param1;
         var error:Function = param2;
         this._currentState = "checking_version";
         this._networkManager.checkVersion(this._configManager.rootURL,"version/version.txt",function(param1:String):void
         {
            _dllDecryptionKey = param1;
            complete(param1);
         },function(param1:String):void
         {
            error(param1);
         });
      }
      
      private function taskLoadBeanXML(param1:Function, param2:Function) : void
      {
         var complete:Function = param1;
         var error:Function = param2;
         this._currentState = "loading_bean_xml";
         this._uiManager.setProgressTitle("正在加载游戏配置");
         this._resourceManager.loadXML("initialSWF/bean.xml",function(param1:XML):void
         {
            _configManager.setBeanXML(param1);
            complete(param1);
         },function(param1:String):void
         {
            error("Bean配置加载失败: " + param1);
         },this.onProgress);
      }
      
      private function taskLoadServerXML(param1:Function, param2:Function) : void
      {
         var complete:Function = param1;
         var error:Function = param2;
         this._currentState = "loading_server_xml";
         this._configManager.setLocalMode(false);
         this._resourceManager.loadXML("initialSWF/Server.xml",function(param1:XML):void
         {
            _configManager.setServerXML(param1);
            _resourceManager.destroyXMLLoader();
            complete(param1);
         },function(param1:String):void
         {
            error("服务器配置加载失败: " + param1);
         },this.onProgress);
      }
      
      private function taskLoadLogin(param1:Function, param2:Function) : void
      {
         var complete:Function = param1;
         var error:Function = param2;
         this._currentState = "loading_login";
         this._uiManager.setProgressTitle("正在加载登录界面");
         this._resourceManager.loadLoginModule("initialSWF/LoginModule.swf",function(param1:DisplayObject):void
         {
            var loginContent:DisplayObject = param1;
            _uiManager.hideProgressBar();
            loginContent["success"] = function(param1:Object):void
            {
               _loginData = param1;
               _uiManager.removeLoginContent();
               _resourceManager.unloadLoginModule();
               complete(param1);
            };
            loginContent["setXmlInfo"](_configManager.serverXML);
            loginContent["init"](_configManager.rootURL);
            _uiManager.setLoginContent(loginContent);
         },function(param1:String):void
         {
            error(param1);
         },this.onProgress);
      }
      
      private function taskWaitForLogin(param1:Function, param2:Function) : void
      {
         this._currentState = "logging_in";
         if(this._loginData)
         {
            param1(this._loginData);
         }
      }
      
      private function taskLoadDLL(param1:Function, param2:Function) : void
      {
         var dllFile:File;
         var complete:Function = param1;
         var error:Function = param2;
         var downloadDLLAndRetry:* = function():void
         {
            _networkManager.downloadFileToLocal(_configManager.rootURL + "version/library.swf","seer2DLL/library.swf",function():void
            {
               taskLoadDLL(complete,error);
            },function(param1:String):void
            {
               error("DLL下载失败: " + param1);
            },function(param1:int):void
            {
               _uiManager.setProgressTitle("DLL需要更新,正在下载DLL");
               _uiManager.updateProgress(param1);
            });
         };
         this._currentState = "loading_dll";
         this._uiManager.setProgressTitle("正在读取游戏核心DLL");
         this._uiManager.showProgressBar();
         dllFile = this._networkManager.getLocalFile("seer2DLL/library.swf");
         if(this._networkManager.checkLocalFileExists("seer2DLL/library.swf"))
         {
            this._resourceManager.loadDLL(dllFile,this._dllDecryptionKey,function():void
            {
               complete();
            },function(param1:String):void
            {
               downloadDLLAndRetry();
            },this.onProgress,function():void
            {
               _uiManager.setProgressTitle("正在加载游戏核心DLL");
            });
         }
         else
         {
            downloadDLLAndRetry();
         }
      }
      
      private function taskLaunchGame(param1:Function, param2:Function) : void
      {
         var _loc3_:Object = null;
         this._currentState = "game_ready";
         try
         {
            _loc3_ = this._resourceManager.createMainEntry("com.taomee.seer2.app.MainEntry");
            this._gameLauncher.launchGame(_loc3_,this,this._configManager.getConfigData(),this._loginData);
            this._uiManager.dispose();
            param1();
         }
         catch(e:Error)
         {
            param2("游戏启动失败: " + e.message);
         }
      }
      
      private function onProgress(param1:ProgressEvent) : void
      {
         var _loc2_:int = param1.bytesLoaded / param1.bytesTotal * 100;
         this._uiManager.updateProgress(_loc2_);
      }
      
      private function onTaskComplete(param1:AsyncTask) : void
      {
      }
      
      private function onApplicationComplete() : void
      {
         this.dispose();
      }
      
      private function onApplicationError(param1:String, param2:AsyncTask) : void
      {
         this._currentState = "error";
         this._uiManager.showError(param1);
      }
      
      public function dispose() : void
      {
         if(this._taskManager)
         {
            this._taskManager.stop();
            this._taskManager = null;
         }
         if(this._configManager)
         {
            this._configManager.dispose();
            this._configManager = null;
         }
         if(this._networkManager)
         {
            this._networkManager.dispose();
            this._networkManager = null;
         }
         if(this._resourceManager)
         {
            this._resourceManager.dispose();
            this._resourceManager = null;
         }
         if(this._gameLauncher)
         {
            this._gameLauncher.dispose();
            this._gameLauncher = null;
         }
      }
      
      public function get currentState() : String
      {
         return this._currentState;
      }
      
      public function get taskProgress() : Number
      {
         return this._taskManager ? this._taskManager.progress : 0;
      }
   }
}

