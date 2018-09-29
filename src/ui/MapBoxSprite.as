package ui
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	
	import data.MapEditorCost;
	
	
	public class MapBoxSprite extends Sprite
	{
		private var _redSprite:Sprite = null;  //障碍物颜色
		private var _alphaSprite:Sprite = null;//非障碍物颜色
		private var _graySprite:Sprite = null;//半透明颜色
		
		private var _originIndex:int = 0;
		private var _currentIndex:int = 0;
		private var _gridX:int = 0;
		private var _gridY:int = 0;
		
		public function MapBoxSprite(x:int,y:int)
		{
			super();
			this._gridX = x;
			this._gridY = y;
		}
		
		public function draw():void
		{
			_redSprite = new Sprite();
			var graphic:Graphics = _redSprite.graphics;
			graphic.lineStyle(1,0x000000);
			graphic.beginFill(0xFF0000,0.5);
			graphic.drawRect(0,0,MapEditorCost.MAP_GRID_WIDTH,MapEditorCost.MAP_GRID_HEIGHT);
			graphic.endFill();
			this.addChild(_redSprite);
			
			
			_alphaSprite = new Sprite();
			var graphic:Graphics = _alphaSprite.graphics;
			graphic.lineStyle(1,0x000000);
			graphic.beginFill(0x000000,0);
			graphic.drawRect(0,0,MapEditorCost.MAP_GRID_WIDTH,MapEditorCost.MAP_GRID_HEIGHT);
			graphic.endFill();
			this.addChild(_alphaSprite);
			
			
			_graySprite = new Sprite();
			var graphic:Graphics = _graySprite.graphics;
			graphic.lineStyle(1,0x000000);
			graphic.beginFill(0x666666,0.5);
			graphic.drawRect(0,0,MapEditorCost.MAP_GRID_WIDTH,MapEditorCost.MAP_GRID_HEIGHT);
			graphic.endFill();
			this.addChild(_graySprite);
			
			this.setColorIndex(MapEditorCost.BOX_ALPHA);
		}
		
		public function setColorIndex(index:int):void
		{
			_originIndex = index;
			this.updateColor(index)
		}
		
		public function trySetTempColorIndex(index:int):void
		{
			_currentIndex = index;
			this.updateColor(index);
		}
		
		
		private function updateColor(index:int):void
		{
			_redSprite.visible = false;
			_alphaSprite.visible = false;
			_graySprite.visible = false;
			if(index == MapEditorCost.BOX_RED){
				_redSprite.visible = true;
			}else if(index == MapEditorCost.BOX_ALPHA){
				_alphaSprite.visible = true;
			}else if(index == MapEditorCost.BOX_GRAY){
				_graySprite.visible = true;
			}
		}
		
		public function cancelTryColor():void
		{
			_currentIndex = 0;
			this.updateColor(_originIndex);
		}
		
		public function confirmTryColor():void
		{
			_originIndex = _currentIndex;
			_currentIndex = 0;
			this.updateColor(_originIndex);
		}
		
		public function getColorIndex():int
		{
			return this._originIndex;
		}
		
		public function getGridX():int
		{
			return this._gridX
		}
		
		public function getGridY():int
		{
			return this._gridY;
		}
	}
}