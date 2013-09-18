package
{
	import flash.display.*
	import flash.geom.*;
	public class ppPenicillin extends MovieClip
	{
		protected var bb:Rectangle;
		
		public function ppPenicillin()
		{
			bb = new Rectangle();
			bb.width = (int)(this.width * 0.8);
			bb.height = (int)(this.height * 0.8);
			
		}
		public function GetBB():Rectangle
		{
			bb.x = (int)(this.x + this.width * 0.1);
			bb.y = (int)(this.y + this.height * 0.1);
			
			return bb;
		}
		
		public function Move():void
		{
			this.x += Math.random() * 4 - 2;
			this.y += Math.random() * 4 - 2;
			
		}
	}
}
