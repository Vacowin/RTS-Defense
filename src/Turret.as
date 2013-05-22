package  
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import Interfaces.IRenderable;
	import org.casalib.util.StageReference;
	import starling.animation.Transitions;
	import starling.display.Image;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	import com.telosinternational.starlingbasic.StarlingUtils;
	import com.telosinternational.starlingbasic.Broadcaster;
	import starling.textures.Texture;
	import starling.events.*;
	import starling.core.Starling;

	public class Turret extends starling.display.Sprite implements IRenderable
	{	
		static public const HUNTER:String = "SHIP_HUNTER"; 
		static public const ENEMY:String = "SHIP_ENEMY"; 
		
		static public const SHIP_SIZE:Number = 70;
		static public const REMOVE_BULLET:String = "remove_bullet";
		
		static public const RANGE:Number = 150;
		
		private var _img:Image;
		
		private var angle:Number; //the angle that the turret is currently rotated at
		private var radiansToDegrees:Number = 180/Math.PI;
		private var damage:int = 10;
		private var range:int = RANGE;
		//private var enTarget:Enemy;
		private var cTime:Number = 0;//how much time since a shot was fired by this turret
		private var reloadTime:Number = 0.05;//how long it takes to fire another shot
		private var loaded:Boolean = true;//whether or not this turret can shoot

		private var xoff:Number = 10;
		private var yoff:Number = 8;;
		
		private var _steering:SteeringBehavior;
		private var camera:Camera;
		
		private var _type:String;
		private var _velocity:Vector2D;
		private var _position:Vector2D;
		
		private var _health:Number = 100;
		private var _target:Turret;
		
		public function Turret (x:Number, y:Number, t:String) 
		{
			camera = Broadcaster.instance.appBroadcast(Game.GET_CAMERA, []);
			
			type = t;
			
			if (type == ENEMY)
				_img =  new Image( Broadcaster.instance.appBroadcast(Game.GET_TEXTURE, ["ship1"] ));
			if (type == HUNTER)
				_img =  new Image( Broadcaster.instance.appBroadcast(Game.GET_TEXTURE, ["ship2"] ));
			_img.width = SHIP_SIZE;
			_img.height = SHIP_SIZE;
			addChild(_img);
			this.worldX = x - SHIP_SIZE / 2;
			this.worldY = y - SHIP_SIZE / 2;
			this.pivotX = SHIP_SIZE /2 ;
			this.pivotY = SHIP_SIZE/2 ;
			
			position = new Vector2D(x, y);
			velocity = new Vector2D();
			
			var spd:Number = 200;
			
			if (type == ENEMY) spd += 40;
			
			steering = new SteeringBehavior(this, 1, spd, 2);
		
			
			this.addEventListener(Event.ENTER_FRAME, eFrame);
			//Broadcaster.instance.addAppListener( REMOVE_BULLET, this, removeBullet );
		}
		
		//private function removeBullet(b:Bullet):void
		//{
			//(this.parent).removeChild(b);
			//b.dispose();
			//b = null;
		//}
		
		private function eFrame(e:EnterFrameEvent):void 
		{
			var delta:Number = e.passedTime;
			//rotation += delta * 1;
			
			
			var p:Point =  new Point( StageReference.getStage().mouseX, StageReference.getStage().mouseY ) ;
			p.x +=  ( camera.x - Game.HALF_WIDTH );
			p.y +=  ( camera.y - Game.HALF_HEIGHT );	
		
			steering.target = new Vector2D(p.x, p.y);
			steering.update(delta);
			this.velocity = steering.velocity;
			this.rotation = steering.rotation;
			
			
			lockBounds(new Rectangle(0, 0, 1600, 1200));
			//trace(worldX + "    " + worldY);
			
			//var enemies:Vector.<Enemy> = Broadcaster.instance.appBroadcast( Level.GET_ENEMY,[]);
			//FINDING THE NEAREST ENEMY WITHIN RANGE
			//var distance:Number = range;
			//enTarget = null;
			//for(var i:int=enemies.length-1;i>=0;i--){
				//var cEnemy:Enemy = enemies[i];
				//if(Math.sqrt(Math.pow(cEnemy.y - y, 2) + Math.pow(cEnemy.x - x, 2)) < distance){
					//enTarget = cEnemy;
				//}
			//}
			//ROTATING TOWARDS TARGET
			//if (enTarget != null)
			//{
				//this.rotation = Math.atan2(yoff+enTarget.y-y, xoff+enTarget.x-x) - Math.PI/2 ;
				//if(loaded){//if the turret is able to shoot
					//loaded = false;//then make in unable to do it for a bit
					//var newBullet:Bullet = Broadcaster.instance.appBroadcast(Level.GET_BULLET, []);
					//newBullet.x = this.x - 3;
					//newBullet.y = this.y - 3;;
					//newBullet.target = enTarget;
					//newBullet.damage = damage;
					//newBullet.addEventListener(Event.ENTER_FRAME, newBullet.eFrame);
					//(this.parent).addChild(newBullet);
					//
				//}
			//}
			
			
			if (loaded && type == HUNTER)
			{	
				if (position.subtract(target.position).magnitude() > 250) 
					return;
					
				loaded = false;//then make in unable to do it for a bit
				var newBullet:Bullet = Broadcaster.instance.appBroadcast(BulletPool.GET_BULLET, []);
				newBullet.reset();
				newBullet.worldX = this.worldX ;
				newBullet.worldY = this.worldY ;
				newBullet.direction = steering.heading;
				newBullet.target = target ;
				newBullet.damage = damage;
				newBullet.addEventListener(Event.ENTER_FRAME, newBullet.eFrame);
				(this.parent).addChild(newBullet);
					
			}
				
				
			//LOADING THE TURRET
			if (!loaded)
			{
				cTime += delta;
				if (cTime > reloadTime)
				{
					loaded = true;//load the turret
					cTime = 0;//and reset the time
				}
			}
		}
		
		public function takeDamage(dmg:Number):void
		{
			_health -= dmg;
			//Starling.juggler.tween(this.img, 0.5, {
				//transition: Transitions.EASE_IN,
				//delay: 0,
				//repeatCount: 0,
				//onComplete: function():void { },
				//color : 0
			//});
			
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
		
		
		public function get img():Image 
		{
			return _img;
		}
		
		public function set img(value:Image):void 
		{
			_img = value;
		}
		
		public function get type():String 
		{
			return _type;
		}
		
		public function set type(value:String):void 
		{
			_type = value;
		}
		
		public function get velocity():Vector2D 
		{
			return _velocity;
		}
		
		public function set velocity(value:Vector2D):void 
		{
			_velocity = value;
		}
		
		public function get position():Vector2D 
		{
			return _position;
		}
		
		public function set position(value:Vector2D):void 
		{
			_position = value;
		}
		
		public function get steering():SteeringBehavior 
		{
			return _steering;
		}
		
		public function set steering(value:SteeringBehavior):void 
		{
			_steering = value;
		}
		
		public function get health():Number 
		{
			return _health;
		}
		
		public function set health(value:Number):void 
		{
			_health = value;
		}
		
		public function get target():Turret 
		{
			return _target;
		}
		
		public function set target(value:Turret):void 
		{
			_target = value;
		}
		
		
		
		
		
		
	}

}