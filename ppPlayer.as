package
{
	import flash.display.*
	import flash.geom.*;
	public class ppPlayer extends MovieClip
	{
		private var bb:Rectangle;
		public function ppPlayer()
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
	}
}
