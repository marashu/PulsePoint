package
{
	public class BlueVirus extends ppVirus
	{
		public function BlueVirus()
		{
			xSpeed = Math.random() * 3;
			if(Math.floor(Math.random() * 2) == 1)
				xSpeed *= -1;
			xSpeed *= 2;
		}
		private var dir:int = 1;
		override public function Move(bpm:Number):void
		{
			ySpeed+= 0.2 * dir;
			if(Math.abs(ySpeed) >= 5)
				dir *= -1;
			this.x += xSpeed * bpm;
			this.y += ySpeed * bpm;
		}
	}
}
