package
{
	import flash.display.*
	import flash.geom.*;
	public class ppGoal extends MovieClip
	{
		private var iHealth:int;
		private var bb:Rectangle;
		private var bGoalReached:Boolean;
		private var maxWidth:int;
		private var maxHeight:int;
		private var mColour:ColorTransform;
		private var defaultColour:ColorTransform;
		public function ppGoal()
		{
			stop();
			bb = new Rectangle();
			bb.width = (int)(this.width * 0.8);
			bb.height = (int)(this.height * 0.8);
			iHealth = 5;
			bGoalReached = false;
			maxWidth = this.width;
			maxHeight = this.height;
			mColour = new ColorTransform();
			defaultColour = this.transform.colorTransform;
		}
		public function GetHealth():int{return iHealth;}
		public function DecreaseHealth()
		{
			iHealth--;
			this.width -= maxWidth/5;
			this.height -= maxHeight/5;
			bb.width = (int)(this.width * 0.8);
			bb.height = (int)(this.height * 0.8);
		}
		public function ChangeColour():void
		{
			mColour.color = 0x00FF00;
			this.transform.colorTransform = mColour;
		}
		public function ResetHealth():void
		{
			iHealth = 5;
			ResetSize();
			//mColour.color = defaultColour;
			this.transform.colorTransform = defaultColour;
		}
		
		public function GetReached():Boolean{return bGoalReached;}
		public function SetReached(b:Boolean):void{bGoalReached = b};
		public function ResetSize():void
		{
			this.width = maxWidth;
			this.height = maxHeight;
			bb.width = (int)(this.width * 0.8);
			bb.height = (int)(this.height * 0.8);
		}
		
		public function GetBB():Rectangle
		{
			bb.x = (int)(this.x - this.width/2 + this.width * 0.1);
			bb.y = (int)(this.y - this.height/2 + this.height * 0.1);
			
			return bb;
		}
	}
}
