package  
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import Interfaces.IRenderable;
	import org.casalib.util.StageReference;
	import starling.display.Image;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	import com.telosinternational.starlingbasic.StarlingUtils;
	import com.telosinternational.starlingbasic.Broadcaster;
	import starling.textures.Texture;
	import starling.events.*;

	public class Turret extends starling.display.Sprite implements IRenderable
	{	
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
		private var reloadTime:Number = 0.1;//how long it takes to fire another shot
		private var loaded:Boolean = true;//whether or not this turret can shoot

		private var xoff:Number = 10;
		private var yoff:Number = 8;;
		
		private var steering:Steering;
		private var camera:Camera;
		public function Turret (x:Number, y:Number) 
		{
			camera = Broadcaster.instance.appBroadcast(Game.GET_CAMERA, []);
			
			_img =  new Image( Broadcaster.instance.appBroadcast(Game.GET_TEXTURE, ["ship1"] ));
			_img.width = SHIP_SIZE;
			_img.height = SHIP_SIZE;
			addChild(_img);
			this.worldX = x
			this.worldY = y 
			this.pivotX = SHIP_SIZE /2 ;
			this.pivotY = SHIP_SIZE/2 ;
			
			steering = new Steering(this, 0.5, 5, 20);
		
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
		
			steering.target = new Vector3D(p.x, p.y);
			steering.update(delta);
			
			
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
		
		
		
		
		
		
	}

}