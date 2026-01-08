package net
{
   import flash.errors.EOFError;
   import flash.utils.ByteArray;
   
   public class VersionInfoParser
   {
      
      public static const EXPIRED:String = "时间码不对";
      
      public static const CLIENT_NEED_UPDATE:String = "要更新应用";
      
      public static const DLL_NEED_UPDATE:String = "要更新dll";
      
      private const VERSION_INFO_KEY:String = "玩萨特头&玩四害&刷分卡人炸服狗";
      
      private const CLIENT_VERSION:uint = 10;
      
      private var firstPageVersion:uint;
      
      private var time:uint;
      
      private var clientSwfVersion:uint;
      
      private var dllDecryptionKey:String;
      
      public function VersionInfoParser()
      {
         super();
      }
      
      public function parseVersionInfo(param1:ByteArray) : String
      {
         var _loc4_:ByteArray = null;
         var _loc3_:int = 0;
         var _loc2_:ByteArray = null;
         try
         {
            this.firstPageVersion = param1.readUnsignedShort();
            _loc4_ = new ByteArray();
            _loc3_ = 0;
            while(_loc3_ < 10)
            {
               _loc4_.writeByte(param1.readByte());
               _loc4_.writeByte(param1.readByte());
               param1.readBytes(new ByteArray(),0,2);
               _loc3_++;
            }
            _loc4_.position = 0;
            _loc2_ = new ByteArray();
            param1.readBytes(_loc2_,0,param1.length - param1.position);
            Crypto.aesDecrypt(_loc2_,"玩萨特头&玩四害&刷分卡人炸服狗" + _loc4_.readUTFBytes(_loc4_.length));
            _loc2_.position = 0;
            this.time = _loc2_.readUnsignedInt();
            this.clientSwfVersion = _loc2_.readUnsignedShort();
            this.dllDecryptionKey = _loc2_.readUTFBytes(_loc2_.length - _loc2_.position);
            return versionVerify();
         }
         catch(e:EOFError)
         {
            var _loc7_:String = "时间码不对";
         }
         return _loc7_;
      }
      
      private function versionVerify() : String
      {
         if(this.clientSwfVersion != 10)
         {
            return "要更新应用";
         }
         return this.dllDecryptionKey;
      }
   }
}

