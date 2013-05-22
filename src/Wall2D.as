package  
{
	/**
	 * ...
	 * @author nguyen
	 */
	public class Wall2D 
	{
		private var _vA:Vector2D;
		private var _vB:Vector2D;
		private var _vN:Vector2D; // normal
		
		public function Wall2D(a:Vector2D, b:Vector2D) 
		{
			vA = a.clone();
			vB = b.clone();
			
			calculateNormal();
		}
		
		private function calculateNormal():void
		{
			var temp:Vector2D = vB.subtract(vA);
			temp.normalize();
			
			vN = new Vector2D( -temp.y, temp.x);
		}
		
		public function getCenter():Vector2D
		{
			return (vA.add(vB)).divide(2.0);
		}
		
		public function get vA():Vector2D 
		{
			return _vA;
		}
		
		public function set vA(value:Vector2D):void 
		{
			_vA = value;
		}
		
		public function get vB():Vector2D 
		{
			return _vB;
		}
		
		public function set vB(value:Vector2D):void 
		{
			_vB = value;
		}
		
		public function get vN():Vector2D 
		{
			return _vN;
		}
		
		public function set vN(value:Vector2D):void 
		{
			_vN = value;
		}
	}

}