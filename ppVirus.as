package
{
	import flash.display.*
	import flash.geom.*;
	public class ppVirus extends MovieClip
	{
		protected var bb:Rectangle;
		protected var xSpeed:Number;
		protected var ySpeed:Number;
		public function ppVirus()
		{
			bb = new Rectangle();
			bb.width = (int)(this.width * 0.8);
			bb.height = (int)(this.height * 0.8);
			xSpeed = Math.random() * 10 - 5;
			ySpeed = Math.random() * 10 - 5;
		}
		public function GetBB():Rectangle
		{
			bb.x = (int)(this.x + this.width * 0.1);
			bb.y = (int)(this.y + this.height * 0.1);
			
			return bb;
		}
		public function ReflectHorizontal():void{xSpeed *= -1;}
		public function ReflectVertical():void{ySpeed *= -1;}
		public function Move(bpm:Number):void
		{
			xSpeed += Math.random() * 4 - 2;
			ySpeed += Math.random() * 4 - 2;
			if(xSpeed > 5)
				xSpeed = 5;
			else if(xSpeed < -5)
				xSpeed = -5;
			if(ySpeed > 5)
				ySpeed = 5;
			else if(ySpeed < -5)
				ySpeed = -5;
				
			this.x += xSpeed * bpm;
			this.y += ySpeed * bpm;
		}
	}
}
