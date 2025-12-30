package seer2.next.fight.auto
{
   import org.taomee.ds.HashMap;
   
   public class AutoFightVerifyConfig
   {
      
      private static var _xml:XML;
      
      [Embed(source="/_assets_next/auto-fight-verify.xml",mimeType="application/octet-stream")]
      private static var _xmlClass:Class = §auto-fight-verify_xml$98a121ec8e8b9e13ebe05b0219f21cdb-1223216401§;
      
      public static var _map:HashMap = new HashMap();
      
      setup();
      
      private var xmlData:XML;
      
      public function AutoFightVerifyConfig()
      {
         super();
      }
      
      public static function setup() : void
      {
         var fakeHash:String = null;
         var imageId:* = 0;
         var answer:* = 0;
         var pack:AnswerInfo = null;
         _xml = XML(new _xmlClass());
         for each(var imageXML in _xml.descendants("answerQuery"))
         {
            fakeHash = String(imageXML.attribute("fakeHash"));
            imageId = uint(imageXML.attribute("id"));
            answer = uint(imageXML.attribute("answer"));
            pack = new AnswerInfo(imageId,answer);
            _map.add(fakeHash,pack);
         }
      }
      
      public static function getInfo(fakeHash:String) : AnswerInfo
      {
         if(_map.containsKey(fakeHash))
         {
            return _map.getValue(fakeHash);
         }
         return null;
      }
      
      public static function addInfo(fakeHash:String, ans:uint) : Boolean
      {
         if(_map.containsKey(fakeHash))
         {
            return false;
         }
         var imageId:uint = uint(_map.length + 1);
         var answer:* = ans;
         _map.add(fakeHash,new AnswerInfo(imageId,answer));
         _xml.appendChild(<answerQuery fakeHash={fakeHash} id={imageId} answer={answer}/>);
         return true;
      }
   }
}

