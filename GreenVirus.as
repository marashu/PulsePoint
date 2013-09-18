package
{
	public class GreenVirus extends ppVirus
	{
		override public function Move(bpm:Number):void
		{
			this.x += xSpeed * bpm;
			this.y += ySpeed * bpm;
		}
	}
}
