package net
{
   import com.hurlant.crypto.prng.ARC4;
   import com.hurlant.crypto.symmetric.AESKey;
   import com.hurlant.crypto.symmetric.ECBMode;
   import flash.utils.ByteArray;
   
   public class Crypto
   {
      
      public function Crypto()
      {
         super();
      }
      
      public static function aesDecrypt(param1:ByteArray, param2:String) : void
      {
         var _loc3_:ByteArray = new ByteArray();
         _loc3_.writeUTFBytes(param2);
         _loc3_.position = 0;
         var _loc5_:AESKey = new AESKey(_loc3_);
         var _loc4_:ECBMode = new ECBMode(_loc5_);
         _loc4_.decrypt(param1);
      }
      
      public static function rc4Decrypt(param1:ByteArray, param2:String) : void
      {
         var _loc3_:ByteArray = new ByteArray();
         _loc3_.writeUTFBytes(param2);
         _loc3_.position = 0;
         var _loc4_:ARC4 = new ARC4(_loc3_);
         _loc4_.decrypt(param1);
      }
   }
}

