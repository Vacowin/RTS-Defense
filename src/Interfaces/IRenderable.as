package Interfaces
{
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Aaron Malley
	 */
	public interface IRenderable 
	{
		function get x():Number;
		function set x(value:Number):void;
		
		function get y():Number;
		function set y(value:Number):void;
		
		function get worldX():Number;
		function set worldX(value:Number):void;
		
		function get worldY():Number;
		function set worldY(value:Number):void;
		
		function lockBounds( zone:Rectangle ):void;
	}
	
}