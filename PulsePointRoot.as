package
{
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.ui.*;
	import flash.geom.*;
	import flash.text.*;
	import flash.media.*;
	import flash.net.SharedObject;
	//from free actionscript website
	import com.freeactionscript.CollisionTest;
	public class PulsePointRoot extends MovieClip
	{
		private static var so:SharedObject;
		private const WIDTH:int = 800;
		private const HEIGHT:int = 600;
		private var iHeartRate:int;
		private var vViruses:Vector.<ppVirus>;
		private var vPen:Vector.<ppPenicillin>;
		private static var sfxc:Vector.<SoundEffect> = new Vector.<SoundEffect>(5);
		private var tGoalTimer:Timer;
		private var tMeasureTimer:Timer;
		private var mGoal:ppGoal;
		private var mPlayer:ppPlayer;
		private var iScore:int;
		private var bg:BG;
		private var txtScore:TextField;
		private var iHealth:int;
		private var iMaxHealth:int;
		//private var txtHealth:TextField;
		private var hud:HUD_bar;
		private var bPause:Boolean;
		private var enterBox:EnterBPM;
		private var txtEnterBPM:TextField;
		private var txtBPM:TextField;
		private static var bSFX:Boolean;
		private static var sPulse:sfxPulse = new sfxPulse();
		private var collisionTest:CollisionTest;
		private var mHeart:Heart;
		private var mBigHeart:BigHeart;
		private var bInvincible:Boolean;
		private var iInvincibilityCounter:int;
		private var tInvincibilityTimer:Timer;
		private var iPenicillinCounter:int;
		private var iHighScore:int;
		private var iStartBPM:int;
		private var iCurrentBPM:int;
		
		
		public function PulsePointRoot()
		{
			for(var i:int = 0; i < sfxc.length; i++)
			{
				sfxc[i] = new SoundEffect();
			}
			so = SharedObject.getLocal("PulsePoint");
			if(so.data && so.data.highscore)
				iHighScore = so.data.highscore;
			else
				iHighScore = 0;
			iPenicillinCounter = 0;
			bInvincible = false;
			tInvincibilityTimer = new Timer(200);
			bSFX = true;
			stage.focus = this;
			bg = new BG();
			bg.stop();
			addChild(bg);
			hud = new HUD_bar();
			txtScore = new TextField();
			txtScore.selectable = false;
			txtScore.mouseEnabled = false;
			txtScore.x = 309;
			txtScore.y = 45;
			txtScore.width = 77;
			txtScore.defaultTextFormat = SetFontStyle(20, "center");
			//txtHealth = new TextField();
			//txtHealth.selectable = false;
			//txtHealth.mouseEnabled = false;
			//txtHealth.defaultTextFormat = SetFontStyle(20);
			//txtHealth.x = 50;
			
			txtEnterBPM = new TextField;
			txtEnterBPM.x = -68;
			txtEnterBPM.y = 46;
			txtEnterBPM.width = 141;
			txtEnterBPM.height = 31;
			txtEnterBPM.type = "input";
			txtEnterBPM.visible = false;
			txtEnterBPM.defaultTextFormat = SetFontStyle(24,"center","0x000000");
			txtEnterBPM.restrict="0-9";
			
			txtBPM = new TextField;
			txtBPM.selectable = false;
			txtBPM.x = 469;
			txtBPM.y = 63;
			txtBPM.width = 133;
			txtBPM.defaultTextFormat = SetFontStyle(20, "center");
			//Mouse.hide();
			iHeartRate = 60;//default for now - assume 1 beat per second
			iScore = 0;
			iMaxHealth = 15;
			iHealth = iMaxHealth;
			//DecideHeartRate(iHeartRate);
			vViruses = new Vector.<ppVirus>();
			vPen = new Vector.<ppPenicillin>();
			tGoalTimer = new Timer(iHeartRate);
			tMeasureTimer = new Timer(10000);
			mGoal = new ppGoal();
			mPlayer = new ppPlayer();
			mPlayer.mouseEnabled = false;
			mPlayer.mouseChildren = false;
			mPlayer.visible = false;
			tGoalTimer.addEventListener(TimerEvent.TIMER, onTimer);
			tMeasureTimer.addEventListener(TimerEvent.TIMER, onMeasureTimer);
			tInvincibilityTimer.addEventListener(TimerEvent.TIMER, flashPlayer);
			bPause = true;
			
			//create the collision tester
			collisionTest = new CollisionTest();
			
			//Erica wanted the buttons to be a part of the start screen.  Two can play at that game.
			enterBox = new EnterBPM();
			enterBox.gotoAndStop(1);
			enterBox.x = 399;
			enterBox.y = 286;
			enterBox.addEventListener(MouseEvent.CLICK, onClick);
			enterBox.addChild(txtEnterBPM);
			//enterBox.addEventListener(MouseEvent.CLICK, onClick);
			//enterBox.gotoAndStop(3);
			//enterBox.btnPlay.addEventListener(MouseEvent.CLICK, onClick);
			//enterBox.gotoAndStop(1);
			
			mBigHeart = new BigHeart();
			mBigHeart.x = 0 - mBigHeart.width/3 - 20;
			mBigHeart.y = 0 - mBigHeart.height/3 + 30;
			mBigHeart.stop();
			
			mHeart = new Heart();
			mHeart.x = 25;
			mHeart.y = 25;
			
			this.addEventListener(Event.ENTER_FRAME, Update);
			this.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
			hud.addEventListener(MouseEvent.CLICK, onClick);
			
			txtScore.text = iScore.toString();
			mHeart.rHeart.scaleX = iHealth/15;
			mHeart.rHeart.scaleY = iHealth/15;
			//add children
			
			this.addChild(mGoal);
			this.addChild(mPlayer);
			mGoal.visible = false;
			
			//tGoalTimer.start();
			this.addChild(hud);
			this.addChild(mHeart);
			this.addChild(txtScore);
			//this.addChild(txtHealth);
			this.addChild(txtBPM);
			this.addChild(enterBox);
		}
		
		//audio
		public static function playSoundEffect(mySound:Sound)
		{
			if(bSFX)
			{
				for(var i:int = 0; i < sfxc.length; i++)
				{
					if(!sfxc[i].GetPlaying())
					{
						sfxc[i].PlaySound(mySound);
						break;
					}
				}
			}
		}
		public static function adjustSFXVolume(vol:Number)
		{
			
			SoundEffect.ChangeVolume(vol);
				
		}
		
		public function flashPlayer(evt:TimerEvent)
		{
			mPlayer.visible = !mPlayer.visible;
		}
		
		public function SetFontStyle(size:int, ali:String = "left", col:String = "0xFFFFFF"):TextFormat
		{
			var form:TextFormat = new TextFormat();
			form.font = "21 Kilobyte Salute";
			form.size = size;
			form.align = ali;
			form.color = col;
			return form;
		}
		
		//TODO:spawn
		public function SpawnVirus()
		{
			var tempVirus:ppVirus;
			//= new ppVirus();
			switch(Math.floor(Math.random() * 3))
			{
				case 0:
					tempVirus = new GreenVirus();
					break;
				case 1:
					tempVirus = new PurpleVirus();
					break;
				case 2:
					tempVirus = new BlueVirus();
					
					break;
				default:
					tempVirus = new ppVirus();
					break;
			}
			do
			{
				tempVirus.x = Math.random() * (WIDTH - tempVirus.width);
				tempVirus.y = 111 + (Math.random() * (HEIGHT - 111 - tempVirus.height));
				
			}while(GetDistance(tempVirus,mPlayer) < 250);
			vViruses.push(tempVirus);
			bg.addChild(tempVirus);
		}
		
		public function SpawnPen()
		{
			var tempPen:ppPenicillin = new ppPenicillin();
			//= new ppVirus();
			
			do
			{
				tempPen.x = Math.random() * (WIDTH - tempPen.width);
				tempPen.y = 111 + (Math.random() * (HEIGHT - 111 - tempPen.height));
				
			}while(GetDistance(tempPen,mPlayer) < 250);
			vPen.push(tempPen);
			addChild(tempPen);
		}
		
		//TODO:collision
		public function HandleCollision(mc1:MovieClip, mc2:MovieClip):Boolean
		{
			/*
			var r1 = new Rectangle((int)(mc1.x + mc1.width*0.1), (int)(mc1.y + mc1.height*0.1), (int)(mc1.width * 0.8), (int)(mc1.height * 0.8));
			var r2 = new Rectangle((int)(mc2.x + mc2.width*0.1), (int)(mc2.y + mc2.height*0.1), (int)(mc2.width * 0.8), (int)(mc2.height * 0.8));
			if( r1.intersects(r2) || (r1.x > r2.x && r1.x + r1.width < r2.x + r2.width && r1.y > r2.y && r1.y + r1.height < r2.y + r2.height) ||
			(r1.x < r2.x && r1.x + r1.width > r2.x + r2.width && r1.y < r2.y && r1.y + r1.height > r2.y + r2.height))
			*/
				return(collisionTest.complex(mc1, mc2));
			//return false;
		}
		public function HandleRectCollision(r1:Rectangle, r2:Rectangle):Boolean
		{
			return r1.intersects(r2) || (r1.x > r2.x && r1.x + r1.width < r2.x + r2.width && r1.y > r2.y && r1.y + r1.height < r2.y + r2.height) ||
			(r1.x < r2.x && r1.x + r1.width > r2.x + r2.width && r1.y < r2.y && r1.y + r1.height > r2.y + r2.height);
		}
		
		public function GetDistance(mc1:MovieClip, mc2:MovieClip):int
		{
			var x1 = mc1.x + (mc1.width/2);
			var x2 = mc2.x + (mc2.width/2);
			var y1 = mc1.y + (mc1.height/2);
			var y2 = mc2.y + (mc2.height/2);
			
			return Math.sqrt( ( x1 - x2 ) * ( x1 - x2 ) + ( y1 - y2) * ( y1 - y2 ) );
		}
		
		public function Update(evt:Event):void
		{
			if(!bPause)
			{
				//check if player is at goal.  This will impact virus AI
				var bOnGoal:Boolean = HandleRectCollision(mPlayer.GetBB(), mGoal.GetBB());
				//move all the viruses
				for(var i:int = 0; i < vViruses.length; i++)
				{
					
					if(GetDistance(vViruses[i],mPlayer) > 125)
					{
						vViruses[i].Move(1000/iHeartRate);
						if(vViruses[i].x < 0)
						{
							vViruses[i].x = 0;
							vViruses[i].ReflectHorizontal();
						}
						else if(vViruses[i].x > WIDTH - vViruses[i].width)
						{
							vViruses[i].x = WIDTH - vViruses[i].width;
							vViruses[i].ReflectHorizontal();
						}
						if(vViruses[i].y < 111)
						{
							vViruses[i].y = 111;
							vViruses[i].ReflectVertical();
						}
						else if(vViruses[i].y > HEIGHT - vViruses[i].height)
						{
							vViruses[i].y = HEIGHT - vViruses[i].height;
							vViruses[i].ReflectVertical();
						}
					}
					else
					{
						//trace("CHASING");
						
						if(Math.abs((mPlayer.x + mPlayer.width/2) - (vViruses[i].x + vViruses[i].width/2)) > 10)
						{
							if(mPlayer.x + mPlayer.width/2 > vViruses[i].x + vViruses[i].width/2)
								vViruses[i].x += 3500/iHeartRate;
							else
								vViruses[i].x -= 3500/iHeartRate;
						}
						if(Math.abs((mPlayer.y + mPlayer.height/2) - (vViruses[i].y + vViruses[i].height/2)) > 10)
						{
							if(mPlayer.y + mPlayer.height/2 > vViruses[i].y + vViruses[i].height/2)
								vViruses[i].y += 3500/iHeartRate;
							else
								vViruses[i].y -= 3500/iHeartRate;
						}
					}
				}
				for(i = 0; i < vPen.length; i++)
				{
					vPen[i].Move();
					if(HandleCollision(vPen[i],mPlayer))
					{
						vPen = RemovePenFromVec(vPen[i]);
						iScore += 10;
						txtScore.text = iScore.toString();
						if(iHealth < iMaxHealth)
						{
							iHealth++;
							mHeart.rHeart.scaleX = iHealth/15;
							mHeart.rHeart.scaleY = iHealth/15;
						}
						i--;
					}
				}
				
				//now check collision
				if(!bInvincible)
				{
					for(i = 0; i < vViruses.length; i++)
					{
						if(HandleCollision(vViruses[i], mPlayer))
						{
							trace("DEAD");
							iHealth -= 3;
							iMaxHealth -= 1;
							bInvincible = true;
							iInvincibilityCounter = 0;
							tInvincibilityTimer.start();
							mHeart.wHeart.scaleX = iMaxHealth/15;
							mHeart.wHeart.scaleY = iMaxHealth/15;
							//txtHealth.text = iHealth + "/" + iMaxHealth;
							mHeart.rHeart.scaleX = iHealth/15;
							mHeart.rHeart.scaleY = iHealth/15;
							
							if(iHealth <= 0)
								ResetGame();
							else if(iHealth <= 10)
							{
								adjustSFXVolume(iHealth/10);
							}
							break;
						}
					}
				}
				//check for goal safety
				if(!mGoal.GetReached() && HandleRectCollision(mPlayer.GetBB(), mGoal.GetBB()))
				{
					mGoal.ChangeColour();
					mGoal.SetReached(true);
				}
					
			}
		}
		public function RemovePenFromVec(pen:ppPenicillin):Vector.<ppPenicillin>
		{
			var tempVec:Vector.<ppPenicillin> = new Vector.<ppPenicillin>();
			for(var i:int = 0; i < vPen.length; i++)
			{
				if(vPen[i] != pen)
					tempVec.push(vPen[i]);
				else
				{
					if(vPen[i].parent)
						vPen[i].parent.removeChild(vPen[i]);
				}
			}
			return tempVec;
		}
		
		public function ResetGame():void
		{
			iPenicillinCounter = 0;
			DecideHeartRate(iStartBPM);
			tGoalTimer.delay = iHeartRate;
			iCurrentBPM = iStartBPM;
			bInvincible = false;
			tInvincibilityTimer.stop();
			tInvincibilityTimer.reset();
			bPause = true;
			tGoalTimer.stop();
			tGoalTimer.reset();
			for(var i:int = 0; i < vViruses.length; i++)
			{
				if(vViruses[i].parent)
					vViruses[i].parent.removeChild(vViruses[i]);
				
			}
			for(i = 0; i < vPen.length; i++)
			{
				if(vPen[i].parent)
					vPen[i].parent.removeChild(vPen[i]);
				
			}
			vViruses.length = 0;
			vPen.length = 0;
			mGoal.ResetHealth();
			adjustSFXVolume(1);
			SetGoal();
			
			//scoring
			if(iScore > iHighScore)
			{
				iHighScore = iScore;
				so.data.highscore = iHighScore;
				so.flush();
			}
			
			
			
			
			
			txtScore.text = iScore.toString();
			iMaxHealth = 15;
			iHealth = iMaxHealth;
			mHeart.rHeart.scaleX = iHealth/15;
			mHeart.rHeart.scaleY = iHealth/15;
			mHeart.wHeart.scaleX = iMaxHealth/15;
			mHeart.wHeart.scaleY = iMaxHealth/15;
			//txtHealth.text = iHealth + "/" + iMaxHealth;
			enterBox.visible = true;
			enterBox.enabled = true;
			enterBox.gotoAndStop(8);
			enterBox.txtScore.text = iScore.toString();
			enterBox.txtHighScore.text = iHighScore.toString();
			mPlayer.visible = false;
			mGoal.visible = false;
			//txtBPM.text = "";
			//this.removeEventListener(MouseEvent.CLICK, checkColourChange);
			Mouse.show();
			iScore = 0;
			//tGoalTimer.start();
		}
		
		//TODO:adjust heartbeat
		
		public function DecideHeartRate(i:int):void
		{
			//convert the heartrate from beats per minute to seconds to milliseconds, then multiply by 6 because we only do this for 10 seconds
			//first, multiply value by 6
			if(i == 0)
				i = 1;
			iHeartRate = i * 6;
			txtBPM.text = iHeartRate.toString();
			//now, multiply by 60 for seconds and 1000 for millis
			iHeartRate = 10 / i * 1000
			
			
		}
		
		public function checkColourChange(evt:MouseEvent):void
		{
			if(HandleRectCollision(mPlayer.GetBB(), mGoal.GetBB()))
			{
				mGoal.ChangeColour();
				mGoal.SetReached(true);
			}
		}
		
		public function onTimer(evt:TimerEvent):void
		{
			//handle animations
			mGoal.gotoAndPlay(1);
			bg.gotoAndPlay(1);
			playSoundEffect(sPulse);
			if(bInvincible)
			{
				if(++iInvincibilityCounter >= 3)
				{
					iInvincibilityCounter = 0;
					bInvincible = false;
					tInvincibilityTimer.stop();
					tInvincibilityTimer.reset();
					mPlayer.visible = true;
				}
			}
			
			if(++iPenicillinCounter >= 15)
			{
				iPenicillinCounter = 0;
				SpawnPen();
				DecideHeartRate(++iCurrentBPM);
				tGoalTimer.delay = iHeartRate;
			}
			if(HandleRectCollision(mPlayer.GetBB(), mGoal.GetBB()))
			{
				if(iHealth < iMaxHealth)
					iHealth++;
				iScore += 10;
				//txtHealth.text = iHealth + "/" + iMaxHealth;
				mHeart.rHeart.scaleX = iHealth/15;
				mHeart.rHeart.scaleY = iHealth/15;
				txtScore.text = iScore.toString();
				
			}
			else
			{
				iHealth--;
				mHeart.rHeart.scaleX = iHealth/15;
				mHeart.rHeart.scaleY = iHealth/15;
				//txtHealth.text = iHealth + "/" + iMaxHealth;
			}
				mGoal.DecreaseHealth();
				if(mGoal.GetHealth() <= 0)
				{
					
					mGoal.ResetHealth();
					if(!mGoal.GetReached())
					{
						iMaxHealth--;
						if(iHealth > iMaxHealth)
						{
							iHealth = iMaxHealth;
							
						}
						mHeart.wHeart.scaleX = iMaxHealth/15;
						mHeart.wHeart.scaleY = iMaxHealth/15;
						//txtHealth.text = iHealth + "/" + iMaxHealth;
						mHeart.rHeart.scaleX = iHealth/15;
						mHeart.rHeart.scaleY = iHealth/15;
						trace("OUCH");
					}
					SetGoal();
					SpawnVirus();
					
				}
			if(iHealth <= 0)
			{
				trace("DEAD");
				ResetGame();
			}
			else if(iHealth <= 10)
			{
				adjustSFXVolume(iHealth/10);
			}
			
		}
		
		public function onMeasureTimer(evt:TimerEvent):void
		{
			evt.target.stop();
			evt.target.reset();
			enterBox.enabled = true;
			enterBox.gotoAndStop(5);
			enterBox.removeChild(mBigHeart);
			removeEventListener(Event.ENTER_FRAME, ShrinkHeart);
			mBigHeart.rHeart.scaleX = 1;
			mBigHeart.rHeart.scaleY = 1;
			//mBigHeart.stop();
			txtEnterBPM.visible = true;
		}
		public function onMove(evt:MouseEvent):void
		{
			//cursor.visible = true;
			//trace("moving");
			mPlayer.x = evt.stageX - mPlayer.width/2;
			if(mPlayer.x < 0)
				mPlayer.x = 0;
			else if(mPlayer.x > WIDTH - mPlayer.width)
				mPlayer.x = WIDTH - mPlayer.width;
			mPlayer.y = evt.stageY - mPlayer.height/2;
			if(mPlayer.y < 111)
				mPlayer.y = 111;
			else if(mPlayer.y > HEIGHT - mPlayer.height)
				mPlayer.y = HEIGHT - mPlayer.height;
			if(!bPause && evt.stageY >= 111 && !bPause)
				Mouse.hide();
			else
				Mouse.show();
		}
		public function ShrinkHeart(evt:Event):void
		{
			mBigHeart.rHeart.scaleX -= 1/300;
			mBigHeart.rHeart.scaleY -= 1/300;
		}
		
		public function onClick(evt:MouseEvent):void
		{
			switch(evt.target.name)
			{
				case "btnP1":
					enterBox.gotoAndStop(2);
					break;
				case "btnP2":
					enterBox.gotoAndStop(3);
					break;
				case "btnBegin":
					evt.target.parent.enabled = false;
					evt.target.parent.gotoAndStop(4);
					enterBox.addChild(mBigHeart);
					addEventListener(Event.ENTER_FRAME, ShrinkHeart);
					//mBigHeart.gotoAndPlay(1);
					tMeasureTimer.start();
					
					break;
				case "btnCalc":
					var bpm:Number;
					if(txtEnterBPM.text!= null)
						bpm = Number(txtEnterBPM.text);
					else
						bpm = 10;
					iStartBPM = bpm;
					iCurrentBPM = iStartBPM;
					DecideHeartRate(bpm);
					tGoalTimer.delay = iHeartRate;
					txtEnterBPM.visible = false;
					enterBox.gotoAndStop(6);
					enterBox.txtWit.text = "Your heart rate is " + txtBPM.text + " beats per minute.";
					switch(bpm)
					{
						case 1:
						case 2:
						case 3:
							enterBox.txtWit.appendText("\n\n\n  You may need a doctor...");
							break;
						case 4:
						case 5:
						case 6:
							enterBox.txtWit.appendText("\n\n\n  Are you sure you're feeling up to this?");
							break;
						case 7:
						case 8:
						case 9:
							enterBox.txtWit.appendText("\n\n\n  You seem calm.  That's good.");
							break;
						case 10:
						case 11:
						case 12:
						case 13:
						case 14:
						case 15:
						case 16:
						case 17:
							enterBox.txtWit.appendText("\n\n\n  As expected.  Proceed.");
							break;
						case 18:
						case 19:
						case 20:
							enterBox.txtWit.appendText("\n\n\n  Getting pumped?");
							break;
						case 21:
						case 22:
						case 23:
							enterBox.txtWid.appendText("\n\n\n  Feeling a little agitated?");
						case 24:
						case 25:
						case 26:
							enterBox.txtWit.appendText("\n\n\n  Wow, your heart is racing!");
						default:
							enterBox.txtWit.appendText("\n\n\n  Um, you may want to get that checked.");
							break;
					}
					break;
				case "btnPlay":
					evt.target.parent.visible = false;
					evt.target.parent.enabled = false;
					mPlayer.visible = true;
					bPause = false;
					//txtBPM.visible = true;
					
					tGoalTimer.start();
					SetGoal();
					SpawnVirus();
					txtEnterBPM.visible = false;
					//this.addEventListener(MouseEvent.CLICK, checkColourChange);
					Mouse.hide();
					break;
				case "btnSkip":
					evt.target.parent.visible = false;
					evt.target.parent.enabled = false;
					mPlayer.visible = true;
					bPause = false;
					tGoalTimer.start();
					DecideHeartRate(10);
					iStartBPM = 10;
					iCurrentBPM = iStartBPM;
					tGoalTimer.delay = iHeartRate;
					//trace(iHeartRate/60/60);
					SetGoal();
					SpawnVirus();
					txtEnterBPM.visible = false;
					//this.addEventListener(MouseEvent.CLICK, checkColourChange);
					Mouse.hide();
					break;
				case "btnP8":
					enterBox.gotoAndStop(1);
					break;
				case "btnMute":
					bSFX = !bSFX;
					break;
				case "btnHelp":
					if(!bPause)
						bPause = true;
						tGoalTimer.stop();
						if(bInvincible)
							tInvincibilityTimer.stop();
						enterBox.gotoAndStop(7);
						enterBox.visible = true;
						enterBox.enabled = true;
						mPlayer.visible = false;
					break;
				case "btnBack":
					enterBox.visible = false;
					enterBox.enabled = false;
					tGoalTimer.start();
					if(bInvincible)
						tInvincibilityTimer.start();
					bPause = false;
					mPlayer.visible = true;
				default:
					
					break;
			}
		}
		
		
		
		public function SetGoal():void
		{
			mGoal.visible = true;
			do{
			mGoal.x = mGoal.width + Math.random() * (WIDTH - mGoal.width*2);
			mGoal.y = 111 + mGoal.height + (Math.random() * (HEIGHT - 111 - mGoal.height*2));
			}while(GetDistance(mGoal,mPlayer) < 250);
			mGoal.SetReached(false);
			
		}
	}
}
