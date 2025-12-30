package com.taomee.seer2.app.arena.data
{
   public class AnimiationHitInfo
   {
      
      public var id:uint;
      
      public var physics:uint;
      
      public var attribute:uint;
      
      public var special:uint;
      
      public var critical:uint;
      
      public var fit:uint;
      
      public function AnimiationHitInfo()
      {
         super();
      }
      
      public function getHitValue(param1:String) : Number
      {
         var _loc2_:Number = 0;
         switch(param1)
         {
            case "物理攻击":
               _loc2_ = this.physics;
               break;
            case "属性攻击":
               _loc2_ = this.attribute;
               break;
            case "特殊攻击":
               _loc2_ = this.special;
               break;
            case "必杀":
               _loc2_ = this.critical;
               break;
            case "合体攻击":
               _loc2_ = this.fit;
         }
         return _loc2_ * 40;
      }
   }
}

