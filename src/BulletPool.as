package  
{
	import com.telosinternational.starlingbasic.Broadcaster;
	import starling.display.Sprite;
	import starling.events.Event;
	/**
	 * ...
	 * @author nguyen
	 */
	public class BulletPool 
	{
		static public const GET_BULLET:String = "get_bullet";
		static public const REMOVE_BULLET:String = "remove_bullet";
		
		private var numBullet:int = 0;
		private var activeBullets:Vector.<Bullet>;
		private var inactiveBullets:Vector.<Bullet>;
		
		private var _gameSprite:Sprite;
		
		public function BulletPool(sprite:Sprite) 
		{
			activeBullets = new Vector.<Bullet>();
			inactiveBullets = new Vector.<Bullet>();
			
			gameSprite = sprite;
			
			Broadcaster.instance.addAppListener( GET_BULLET, this, getBullet );
			Broadcaster.instance.addAppListener( REMOVE_BULLET, this, removeBullet );
		}
		
		
		private function getBullet():Bullet
		{
			var newBullet:Bullet;
			if (inactiveBullets.length == 0)
			{
				newBullet = new Bullet();
				
			}
			else
			{
				newBullet = inactiveBullets.pop();
			}
			activeBullets.push(newBullet);
			//newBullet.x = xPos - 3;
			//newBullet.y = yPos - 3;;
			//newBullet.target = target;
			//newBullet.damage = dmg;
			
			numBullet++;
			return newBullet;
		}
		
		private function removeBullet(b:Bullet):void
		{
			
			_gameSprite.removeChild(b);
			numBullet --;
			var i:int = activeBullets.indexOf(b);
			
			
			activeBullets.splice(i, 1);
			inactiveBullets.push(b);
		}
		
		
		
		
		public function set gameSprite(value:Sprite):void 
		{
			_gameSprite = value;
		}
	}

}