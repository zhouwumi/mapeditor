package util
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	
	import data.MapEditorCost;

	public class MapEditorUtils
	{
		public function MapEditorUtils()
		{
		}
		
		
		public static function point2Grid(x:Number,y:Number = 0,scale:Number = 1):Point
		{
			var tempX:Number = (Number)(x)/(Number)((MapEditorCost.MAP_GRID_WIDTH) * scale);
			var tempY:Number = (Number)(y)/(Number)((MapEditorCost.MAP_GRID_HEIGHT) * scale);
			var gridX:int = tempX;
			var gridY:int = tempY;
			trace(tempX,tempY,gridX,gridY,x,y,MapEditorCost.MAP_GRID_WIDTH * scale,MapEditorCost.MAP_GRID_HEIGHT * scale)
			return new Point(gridX,gridY);
		}
		
		public static function wapperDisplayObject2Element(displayObjects:Array):IVisualElement
		{
			var uiComponent:UIComponent = new UIComponent();
			displayObjects.forEach(function(displayObject:DisplayObject,index:int,array:Array):void{
				uiComponent.addChild(displayObject);
			});
			return uiComponent;
		}
		
	}
}