package ui
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	
	import spark.components.Label;
	import data.MapEditorCost;
	
	
	public class MapBoxTypeSprite extends Sprite
	{
		private var selectedSprite:Sprite = null;
		public function MapBoxTypeSprite()
		{
			super();
		}
		
		public function draw(colorIndex:int):void
		{
			
			var graphics:Graphics = this.graphics;
			graphics.beginFill(getBoxTypeColor(colorIndex),getBoxTypeAlpha(colorIndex));
			graphics.drawRect(0,0,50,50);
			graphics.endFill();
			
			var selectSprite:Sprite = new Sprite();
			var graphics:Graphics = selectSprite.graphics;
			graphics.lineStyle(2,0xFFFF00);
			graphics.drawRect(0,0,50,50);
			graphics.endFill();
			
			this.addChild(selectSprite);
			this.selectedSprite = selectSprite;
			this.showSelected(false);
		}
		
		private function getBoxTypeColor(colorIndex:int):uint
		{
			if(colorIndex == MapEditorCost.BOX_RED){
				return 0xFF0000;
			}else if(colorIndex == MapEditorCost.BOX_ALPHA){
				return 0x00FF00;
			}
			return 0x666666;
		}
		
		private function getBoxTypeAlpha(colorIndex:int):Number
		{
			if(colorIndex == MapEditorCost.BOX_RED){
				return 0.5;
			}else if(colorIndex == MapEditorCost.BOX_ALPHA){
				return 0.5;
			}
			return 0.5;
		}
		
		public function getGridTypeName(colorIndex:int):String
		{
			if(colorIndex == MapEditorCost.BOX_RED){
				return "不可\n通过"
			}else if(colorIndex == MapEditorCost.BOX_ALPHA){
				return "可以\n通过";
			}
			return "阴影\n效果";
		}
		
		public function showSelected(visible):void
		{
			this.selectedSprite.visible = visible;
		}
	}
}