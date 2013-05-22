package  
{
	import com.telosinternational.starlingbasic.Broadcaster;
	import flash.geom.Rectangle;
	import Interfaces.IRenderable;
	import starling.display.Image;
	import starling.events.*;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	import starling.textures.Texture;
	/**
	 * ...
	 * @author nguyen
	 */
	public class Bullet extends starling.display.Sprite implements IRenderable
	{
		
		private var _target:Turret;
		private var _damage:int;
 
		private var xSpeed:Number;
		private var ySpeed:Number;
		private var maxSpeed:Number = 1000;
		
		private var xoff:Number = 0//10;
		private var yoff:Number = 0// 8;
		
		private var _direction:Vector2D;
		
		private var lifeTime:Number = 0.5;
		private var totalTime:Number = 0;
		
		public function Bullet() 
		{		
			var rect:Sprite = new flash.display.Sprite();
			rect.graphics.beginFill(0x00FF00, 1);
			rect.graphics.drawCircle( Turret.SHIP_SIZE/20, Turret.SHIP_SIZE/20, Turret.SHIP_SIZE/20);
			rect.graphics.endFill();
				
			var bmd:BitmapData = new BitmapData(rect.width,rect.height, true, 0x00000000);
			bmd.draw(rect);
			var _img:Image =  new Image(Texture.fromBitmapData(bmd, false, false));
			
			addChild(_img);
		}
		
		public function reset():void
		{
			totalTime = 0;
		}
		
		public function eFrame(e:EnterFrameEvent):void 
		{
			var delta:Number = e.passedTime;
			totalTime += delta;
			if (totalTime > lifeTime) 
				destroyThis();
			
			//var yDist:Number=-yoff+target.y - this.y;//how far this guy is from the enemy (x)
			//var xDist:Number=-xoff+target.x - this.x;//how far it is from the enemy (y)
			//var angle:Number=Math.atan2(yDist,xDist);//the angle that it must move
			//ySpeed=Math.sin(angle) * maxSpeed;//calculate how much it should move the enemy vertically
			//xSpeed=Math.cos(angle) * maxSpeed;//calculate how much it should move the enemy horizontally
			
			this.worldX += direction.x * maxSpeed * delta;
			this.worldY += direction.y * maxSpeed * delta;
			
			if (xSpeed == 0 || ySpeed == 0)
				trace("??");
 
			if(this.bounds.intersects(target.bounds)){//if it touches the enemy
				target.takeDamage(_damage);
				destroyThis();
				//this.removeEventListeners();			
				//Broadcaster.instance.appBroadcast(Level.REMOVE_BULLET, [this]);
			}
			if (target == null )
			{
				destroyThis();
				this.removeEventListeners();
				//Broadcaster.instance.appBroadcast(Level.REMOVE_BULLET, [this]);
			}
		}
		
		public function destroyThis():void
		{
			this.removeEventListeners();
			removeEventListeners();
			Broadcaster.instance.appBroadcast( BulletPool.REMOVE_BULLET,[this]);
		}
		
		
		public function lockBounds( zone:Rectangle ):void
		{
			if ( _worldX < zone.x )
			{
				_worldX = zone.x;
			}
			else if (  _worldX > zone.x + zone.width )
			{
				_worldX = zone.x + zone.width;
			}
			if ( _worldY < zone.y )
			{
				_worldY = zone.y;
			}
			else if (  _worldY > zone.y + zone.height )
			{
				_worldY = zone.y + zone.height;
			}
		}
		
		private var _worldX:Number;		
		public function get worldX():Number { return _worldX; }		
		public function set worldX(value:Number):void 
		{ 
			_worldX = value;
		}
		
		private var _worldY:Number;
		public function get worldY():Number { return _worldY; }		
		public function set worldY(value:Number):void 
		{
			_worldY = value;
		}
		
		
		public function get damage():int 
		{
			return _damage;
		}
		
		public function set damage(value:int):void 
		{
			_damage = value;
		}
		
		public function get target():Turret 
		{
			return _target;
		}
		
		public function set target(value:Turret):void 
		{
			_target = value;
		}
		
		public function get direction():Vector2D 
		{
			return _direction;
		}
		
		public function set direction(value:Vector2D):void 
		{
			_direction = value;
		}
		
	}

}