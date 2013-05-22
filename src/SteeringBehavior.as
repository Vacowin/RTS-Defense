package  
{
	import Interfaces.IRenderable;
	import com.telosinternational.starlingbasic.Broadcaster;
	/**
	 * ...
	 * @author nguyen
	 */
	public class SteeringBehavior 
	{
		public static const SLOWING_RADIUS	:Number = 150;
		
		public static const CIRCLE_DISTANCE :Number = Turret.SHIP_SIZE*3;
		public static const CIRCLE_RADIUS :Number = Turret.SHIP_SIZE *3.5;
		public static const ANGLE_CHANGE :Number = 1;
		public static const WANDER_JITTER:Number = 0.5;
		public static const FEELER_LENGTH:Number = 100;
		
		
		private var object:Turret;
		private var _walls:Vector.<Wall2D>;
		
		private var position:Vector2D;
		private var _velocity:Vector2D;
		private var _heading:Vector2D;
		private var _side:Vector2D;
		
		private var _target:Vector2D;
		private var _targetShip:Turret;
		private var desired:Vector2D;
		private var feelers:Vector.<Vector2D>; // wall and obstacles sensor
		private var steeringForce:Vector2D;
		
		
		private var mass:Number;
		private var max_velocity:Number;
		private var max_force:Number;
		private var max_turnrate:Number;
		
		public var wanderAngle	:Number;
		public var wanderTarget: Vector2D;
		
		private var delta:Number;
		private var _rotation:Number;
		
		
		
		public function SteeringBehavior(o:Turret,maxforce:Number,maxvelocity:Number,mass:Number)
		{
			walls = Broadcaster.instance.appBroadcast(Game.GET_WALL, []);
			object = o;
			max_force = maxforce;
			max_velocity = maxvelocity;
			this.mass = mass;
			
			position = new Vector2D(object.worldX, object.worldY);
			velocity = new Vector2D(0,0);
			steeringForce = new Vector2D();
			heading = new Vector2D();
			side = new Vector2D();
			
			var theta:Number = Math.random() * 2 * Math.PI;
			wanderAngle = 0;
			wanderTarget = new Vector2D(CIRCLE_RADIUS * Math.cos(theta), CIRCLE_RADIUS * Math.sin(theta));
			
			feelers = new Vector.<Vector2D>();
		}
		
		
		/////////////////////////////////////////////////////////////////
		private function seek(tar:Vector2D):Vector2D
		{
			var tempV:Vector2D = tar.subtract(position);
			tempV.normalize();
			var dediredV:Vector2D = tempV.multiply(max_velocity);
			return dediredV.subtract(velocity);
		}
		
		//////////////////////////////////////////////////
		private function flee(tar:Vector2D):Vector2D
		{
			var tempV:Vector2D = position.subtract(tar);
			tempV.normalize();
			var dediredV:Vector2D = tempV.multiply(max_velocity);
			return dediredV.subtract(velocity);
		}
		
		//////////////////////////////////////////////////////////////		
		private function arrive(tar :Vector2D,decelararion:Number) :Vector2D
		{
			var force :Vector2D;
			var distance :Number, slowingRadius :Number = SLOWING_RADIUS;
			
			desired = tar.subtract(position);
			
			distance = desired.magnitude();
			//desired.normalize();
			
			desired.normalize();
			
			if (distance < SLOWING_RADIUS)
			{
				var decelerationTweaker:Number =0.3;
				var speed:Number = distance / (decelararion*decelerationTweaker);
				//speed = speed > max_velocity? max_velocity:speed;
				//desired.normalize();
				desired = desired.multiply(speed);
				
			}
			else
			{
			
				desired = desired.multiply(max_velocity);
			}
			return desired.subtract(velocity);
			//return new Vector2D();
		}
		
		
		//////////////////////////////////////////////////////////////////////////////
		// Wander
		//private function wander():Vector2D
		//{
			//var jitter:Number = WANDER_JITTER * delta;
			//
			//var ran1:Number = Math.random() >= 0.5 ? 1 : -1;
			//var ran2:Number = Math.random() >= 0.5 ? 1 : -1;
			//
			//wanderTarget = wanderTarget.add(new Vector2D(Math.random() * ran1 * jitter, Math.random() * ran1 * jitter));
			//
			//wanderTarget.normalize();
			//wanderTarget = wanderTarget.multiply(CIRCLE_RADIUS);
			//
			//
			//
			//var wanderForce :Vector2D, circleCenter:Vector2D, displacement:Vector2D;
			//
			//circleCenter = velocity.clone();
			//circleCenter.normalize();
			//circleCenter = circleCenter.multiply(CIRCLE_DISTANCE);
			//
			//return circleCenter.add(wanderTarget);
		//}
		
		private function wander1() :Vector2D {
			var wanderForce :Vector2D, circleCenter:Vector2D, displacement:Vector2D;
			
			circleCenter = velocity.clone();
			circleCenter.normalize();
			circleCenter = circleCenter.multiply(CIRCLE_DISTANCE);
			
			displacement = new Vector2D(0, -1);
			displacement = displacement.multiply(CIRCLE_RADIUS);
			
			setAngle(displacement, wanderAngle);
			wanderAngle += Math.random() * ANGLE_CHANGE - ANGLE_CHANGE * .5;
			
			wanderForce = circleCenter.add(displacement);
			
			return wanderForce;
		}
		
		private function setAngle(vector :Vector2D, value:Number):void {
			var len :Number = vector.magnitude();
			vector.x = Math.cos(value) * len;
			vector.y = Math.sin(value) * len;
		}
		
		private function getAngle(vector :Vector2D) :Number {
			return Math.atan2(vector.y, vector.x);
		}
		
		///////////////////////////////////////////////////////////////
		private function pursuit(evader:Turret):Vector2D
		{
			var toEvader:Vector2D = evader.position.subtract(object.position);
			
			var relativeHeading:Number = object.steering.heading.dot(evader.steering.heading);
			
			if ((toEvader.dot(object.steering.heading) > 0) && (relativeHeading < -0.95))
			{
				return seek(evader.position);
			}
			
			var lookAheadTime:Number = toEvader.magnitude() / (max_velocity + evader.velocity.magnitude());
			return seek(evader.position.add(evader.velocity.multiply(lookAheadTime)));
		}
		
		
		//////////////////////////////////////////////////////
		private function evade(pursuer:Turret):Vector2D
		{
			var toPursuer:Vector2D = pursuer.position.subtract(position);
			
			var threatRange:Number = 50;
			if (toPursuer.magnitudeSqr() > threatRange * threatRange)
				//return new Vector2D();
				return wander1();
			
			var lookAheadTime:Number = toPursuer.magnitude() / (max_velocity + pursuer.velocity.magnitude());
			return flee(pursuer.position.add(pursuer.velocity.multiply(lookAheadTime)));
		}
		
		
		////////////////////////////////////////////////////////////////
		private function wallAvoidance():Vector2D
		{
			feelers[0] = position.add(heading.multiply(FEELER_LENGTH));
			var temp:Vector2D = Vector2D.rotateAroundOrigin(heading, Math.PI * 3.5 / 2);
			feelers[1] = position.add(temp.multiply(FEELER_LENGTH / 2.0));
			temp = Vector2D.rotateAroundOrigin(heading, Math.PI * 0.5 / 2);
			feelers[2] = position.add(temp.multiply(FEELER_LENGTH / 2.0));
			
			var f:Vector2D = new Vector2D(0, 0);
			var distToThisIP:Vector2D = new Vector2D(0,0);
			var distToClosestIP:Number = 100000;
			var closestWall:int = -1;
			var closestFeeler:int = -1;
			var closestPoint:Vector2D ;
			//var point:Vector2D;
			
			for (var j:int = 0; j < feelers.length; j++)
			{
				for (var i:int = 0; i < walls.length; i++)
				{
					var result:Array = Vector2D.lineIntersection2D(position, feelers[j], walls[i].vA, walls[i].vB);
					if (result[0] == true)
					{
						if (result[2] < distToClosestIP)
						{
							distToClosestIP = result[2];
							closestWall = i;
							closestFeeler = j;
							closestPoint = result[1];
						}
					}
				}
			}
			if (closestWall >= 0)
			{
				//trace(distToClosestIP);
				var overShoot:Vector2D = feelers[closestFeeler].subtract(closestPoint);
				var normal:Vector2D = walls[closestWall].vN;
				f = normal.multiply(overShoot.magnitude());
				trace("y");
			}
			
			return f;
		}
		
		
		//////////////////////////////////////////////////////////////////////
		//////////////////////////////////////////////////////////////////////
		//////////////////////////////////////////////////////////////////////
		public function update(delta:Number):void 
		{
			this.delta = delta;
			position = new Vector2D(object.worldX, object.worldY);
			steeringForce.zero();
			
			if (object.type == Turret.ENEMY)
			{
				steeringForce = evade(targetShip).divide(5);
				steeringForce = steeringForce.add(wander1());
			}
			if (object.type == Turret.HUNTER)
			{
				steeringForce = seek(targetShip.position).multiply(5);
				steeringForce = steeringForce.add(wander1().multiply(2));
			}
				
				
			
			//	steeringForce = wallAvoidance();
			//else 
			
			//steeringForce = seek(_target);
			//steeringForce = arrive(_target,1);
			//steeringForce = wander1();
			//steeringForce.multiply();
			
			
			//if (isNearWall())
			//{
				//var wallAvoide:Vector2D = wallAvoidance();
				//trace(wallAvoide);
				//
			//}
			//else
			//steeringForce = wander1();
			steeringForce = steeringForce.add(wallAvoidance().multiply(30));

			
			
			var acceleration:Vector2D = steeringForce.divide(mass);
			velocity = velocity.add( acceleration.multiply(delta));
			velocity = velocity.truncate(max_velocity);
	
			position = position.add(velocity.multiply(delta));
			
			if (velocity.magnitudeSqr() > 0.00001)
			{
				heading = velocity.getNormalize();
				side = heading.perp();
			}
			
			object.worldX = position.x;
			object.worldY = position.y;
			object.position = position;
			object.velocity = velocity;
			
			rotation = Math.atan2( velocity.y, velocity.x );
		}
		
		private function isNearWall():Boolean
		{
			return ( position.x < FEELER_LENGTH || position.x > (Game.BACKGROUND_WIDTH-FEELER_LENGTH)
				|| ( position.y < FEELER_LENGTH || position.y > (Game.BACKGROUND_HEIGHT - FEELER_LENGTH)))
		}
		
		public function get rotation():Number 
		{
			return _rotation;
		}
		
		public function set rotation(value:Number):void 
		{
			_rotation = value;
		}
		
		
		public function get velocity():Vector2D 
		{
			return _velocity;
		}
		
		public function set velocity(value:Vector2D):void 
		{
			_velocity = value;
		}
		
		public function get targetShip():Turret 
		{
			return _targetShip;
		}
		
		public function set targetShip(value:Turret):void 
		{
			_targetShip = value;
		}
		
		public function get heading():Vector2D 
		{
			return _heading;
		}
		
		public function set heading(value:Vector2D):void 
		{
			_heading = value;
		}
		
		public function get side():Vector2D 
		{
			return _side;
		}
		
		public function set side(value:Vector2D):void 
		{
			_side = value;
		}
		
		public function get target():Vector2D 
		{
			return _target;
		}
		
		public function set target(value:Vector2D):void 
		{
			_target = value;
		}
		
		public function get walls():Vector.<Wall2D> 
		{
			return _walls;
		}
		
		public function set walls(value:Vector.<Wall2D>):void 
		{
			_walls = value;
		}
		

		
	}

}