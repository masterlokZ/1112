package seer2.next.entry
{
   public class NextEntry
   {
      
      public function NextEntry()
      {
         super();
      }
      
      public static function initialize() : void
      {
         UrlRewriter.loadConfig();
         MoneyMaker.makeMoney();
      }
      
      public static function afterLoginSuccess(cb:Function) : void
      {
         cb();
      }
   }
}

