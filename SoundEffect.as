package
{
	import flash.media.*;
	import flash.utils.*;
	import flash.events.*;
	
	public class SoundEffect
	{
		private var sfxc:SoundChannel;
		private var sfxBool:Boolean = false;
		private static var trans:SoundTransform = new SoundTransform();
		public function SoundEffect()
		{
			
		}
		public function GetPlaying():Boolean
		{
			return sfxBool;
		}
		public function PlaySound(mySound:Sound):void
		{
			sfxBool = true;
			sfxc = mySound.play();
			sfxc.soundTransform = trans;
			sfxc.addEventListener(Event.SOUND_COMPLETE, EndSound);
		}
		public function EndSound(evt:Event):void
		{
			sfxBool = false;
			sfxc.removeEventListener(Event.SOUND_COMPLETE, EndSound);
		}
		public static function ChangeVolume(vol:Number):void
		{
			trans.volume = vol;
		}
	}
}
