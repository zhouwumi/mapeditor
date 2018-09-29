import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.system.Capabilities;
import flash.system.IME;
import flash.ui.KeyboardType;
import flash.ui.Mouse;

import mx.containers.HBox;
import mx.controls.Alert;
import mx.core.IVisualElement;
import mx.core.UIComponent;
import mx.events.FileEvent;
import mx.events.ScrollEvent;
import mx.managers.PopUpManager;

import spark.components.Button;
import spark.components.Label;
import spark.components.TextInput;
import spark.components.TitleWindow;

import data.MapEditorCost;
import data.MapEditorDataManager;

import handler.MapEditorExportHandler;

import ui.MapBoxSprite;
import ui.MapBoxTypeSprite;

import util.MapEditorUtils;


private var _hasLoadImage:Boolean = false;
private var fileReference:FileReference=new FileReference();
private var loader:Loader=new Loader();
private var _bitmapUIComponent:UIComponent = null;
private var _boxUIComponent:UIComponent = null;
private var _mapOffsetX:Number = 0;
private var _mapOffsetY:Number = 0;
private var _boxSprites:Array = null;
private var _gridTypeSprites:Array = [];
private var _currentSelecetedColorIndex:int = -1;
private var _isMouseDowning:Boolean = false;
private var _clickDownPoint:Point = null;
private var _recordCurrentPoints:Array = null;
private var _firstGridPoint:Point = null;
private var _mapScale:Number = 1;
private var _mapGridCols:int = 0;
private var _mapGridRows:int = 0;

public function initApp():void  
{  
	v_bar.enabled = false;
	h_bar.enabled = false;
	
}  

public function appComplete():void
{
	this.stage.addEventListener(Event.RESIZE, this.resizeHandler); 
	this.stage.addEventListener(MouseEvent.MOUSE_MOVE,this.mouseMoveHandler);
	this.stage.addEventListener(MouseEvent.MOUSE_WHEEL,this.mouseWheelHandler);
	resizeHandler(null);
	showUI(false);
	initUI();
	
	this.stage.stageWidth = Capabilities.screenResolutionX * 3/4;
	this.stage.stageHeight = Capabilities.screenResolutionY * 3/4;
	
	this.width = this.stage.stageWidth;    
	this.height = this.stage.stageHeight;
	
}

public function onClickGo():void  
{  
	var inputLabelX:TextInput = _moveToGroup.getChildByName("_moveToInputX") as TextInput;
	var inputLabelY:TextInput = _moveToGroup.getChildByName("_moveToInputY") as TextInput;
	var inputX:int = int(inputLabelX.text);
	var inputY:int = int(inputLabelY.text);
	
	this.moveToPosition(inputX,inputY);
}  


public function onClickLoadMap():void
{
	if(!MapEditorDataManager.getInstance().isDataReady){
		Alert.show("数据正在初始化中...");
		return;
	}
	var fileFilter:FileFilter=new FileFilter  
		("Images", "*.jpg;*.gif;*.png");  
	fileReference.browse([fileFilter]);  
	fileReference.addEventListener(Event.SELECT,onFileSelected); 
}

public function onClickExportMap():void
{
	if(!MapEditorDataManager.getInstance().isDataReady){
		Alert.show("数据正在初始化中...");
		return;
	}
	if(!_hasLoadImage){
		Alert.show("还没有导入地图");
		return;
	}
	new MapEditorExportHandler().handle(this);
}


private function initUI():void
{
	_selectGridTypeWindow.closeButton.visible = false;
	_selectGridTypeWindow.isPopUp = true;
	
	var colors:Array = [MapEditorCost.BOX_RED,MapEditorCost.BOX_ALPHA,MapEditorCost.BOX_GRAY];
	for(var i:int = 0;i<3;i++)
	{
		var colorIndex:int = colors[i];
		var boxTypeSprite:MapBoxTypeSprite = new MapBoxTypeSprite();
		boxTypeSprite.name = "box_name_" + colorIndex;
		boxTypeSprite.draw(colorIndex);
		boxTypeSprite.buttonMode = true;
		boxTypeSprite.addEventListener(MouseEvent.CLICK,this.onClickGridType);
		_gridTypeSprites.push(boxTypeSprite);
		
		var label:Label = new Label();
		label.setStyle("color",0x000000);
		label.setStyle("fontSize",15)
		label.text = boxTypeSprite.getGridTypeName(colorIndex);
		label.width = 100;
		label.height = 50;
		label.x = 10;
		label.y = 10;
		label.mouseEnabled = false;
		
		var uiComponent:UIComponent = MapEditorUtils.wapperDisplayObject2Element([boxTypeSprite,label]) as UIComponent;
		_selectGridTypeWindow.addElement(uiComponent);
		uiComponent.y = i * 64 +10;
		uiComponent.x = 5;
	}
	MapEditorDataManager.getInstance();
}

private function onClickGridType(event:MouseEvent):void
{
	var target:DisplayObject = event.currentTarget as DisplayObject;
	var name:String = target.name;
	var queryString:String = "box_name_";
	var index:int = name.indexOf(queryString);
	if(index == -1){
		return;
	}
	var nameSub:String = name.substring(index+queryString.length);
	var colorIndex:int = int(nameSub);
	this._currentSelecetedColorIndex = colorIndex;
	this._gridTypeSprites.forEach(function(boxTypeSprite:MapBoxTypeSprite,index:int,array:Array):void{
		boxTypeSprite.showSelected(false);
	},this);
	(target as MapBoxTypeSprite).showSelected(true);
}


private function moveToPosition(mapX:int,mapY:int):void
{
	var mapWidth:int = MapEditorDataManager.getInstance().mapWidth;
	var mapHeight:int = MapEditorDataManager.getInstance().mapHeight;
	mapX = mapX < 0 ? 0:mapX;
	mapX = mapX > mapWidth - this.width ? mapWidth - this.width:mapX;
	
	mapY = mapY < 0 ? 0:mapY;
	mapY = mapY > mapHeight - this.height ? mapHeight - this.height:mapY;
	
	var percentX:Number = (Number)(mapX)/(mapWidth - this.width);
	var percentY:Number = (Number)(mapY)/(mapHeight - this.height);
	
	var scollPositionX:int = Math.floor(percentX * h_bar.maxScrollPosition);
	var scrollPositionY:int = Math.floor(percentY * v_bar.maxScrollPosition);
	h_bar.scrollPosition = scollPositionX;
	v_bar.scrollPosition = scrollPositionY;
	
	this.moveMapByPercent(percentX,percentY);
}

private function showUI(visible:Boolean):void
{
	_positionLabel.visible = visible;
	_moveToGroup.visible = visible;
//	_selectGridTypeWindow.visible = visible;
}

private function onFileSelected(event:Event):void
{
	fileReference.addEventListener(Event.COMPLETE,onFileLoadComplete);  
	fileReference.removeEventListener(Event.SELECT,onFileSelected);
	fileReference.load();
}

private function onFileLoadComplete(event:Event):void
{
	fileReference.removeEventListener(Event.COMPLETE,onFileLoadComplete);
	loader.loadBytes(fileReference.data);
	loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onFileDataLoadCompelete);
}

private function onFileDataLoadCompelete(event:Event):void
{
	if(this._boxUIComponent)
	{
		this.removeElement(this._boxUIComponent);
		this._boxUIComponent = null;
	}
	if(this._bitmapUIComponent)
	{
		this.removeElement(this._bitmapUIComponent);
		this._bitmapUIComponent = null;
	}
	
	var tempData:BitmapData=new BitmapData(loader.width,loader.height,false);  
	tempData.draw(loader);  
	var bitmap:Bitmap=new Bitmap(tempData);  
	bitmap.y=50;  
	MapEditorDataManager.getInstance().mapBitmap = bitmap;
	var uiComponent:UIComponent = new UIComponent(); 
	uiComponent.addChild(bitmap);
	
	showUI(true);
	
	_bitmapUIComponent = uiComponent;
	this.addElement(uiComponent); 
	this.setElementIndex(uiComponent,0);
	loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,onFileDataLoadCompelete);  
	this.handleLoadMapCompelete(bitmap.width,bitmap.height);
}

private function handleLoadMapCompelete(mapWidth:int,mapHeight:int):void
{
	MapEditorDataManager.getInstance().mapWidth = mapWidth;
	MapEditorDataManager.getInstance().mapHeight = mapHeight;
	var gridWidth:int = MapEditorCost.MAP_GRID_WIDTH;
	var gridHeight:int = MapEditorCost.MAP_GRID_HEIGHT;
	var gridX:int = Math.ceil(mapWidth/gridWidth);
	var gridY:int = Math.ceil(mapHeight/gridHeight);
	MapEditorDataManager.getInstance().mapGridXCount = gridX;
	MapEditorDataManager.getInstance().mapGridYCount = gridY;
	trace("地图大小：",gridX,gridY)
	
	_hasLoadImage = true;
	this.invalidScrollBar();
	v_bar.pageSize = this.height;
	h_bar.pageSize = this.width;
	v_bar.scrollPosition  = 0;
	h_bar.scrollPosition = 0;
	_boxSprites = [];
	this.drawBoxSprites();
	this.updateMapPosition();
	
}


private function drawBoxSprites():void
{
	
	var uiComponent:UIComponent = new UIComponent(); 
	
	var sprite:Sprite = new Sprite();
	
	var gridColors:Array = MapEditorDataManager.getInstance().gridColors = [];
	
	var gridRows:int = MapEditorDataManager.getInstance().mapGridYCount;
	var gridCols:int = MapEditorDataManager.getInstance().mapGridXCount;
	for(var j:int = 0;j<gridRows;j++)
	{
		for(var i:int = 0;i<gridCols;i++)
		{
			var boxSprite:MapBoxSprite = new MapBoxSprite(i,j);
			boxSprite.draw();
			sprite.addChild(boxSprite);
			boxSprite.x = i * MapEditorCost.MAP_GRID_WIDTH;
			boxSprite.y = j * MapEditorCost.MAP_GRID_HEIGHT;
			_boxSprites.push(boxSprite);
			gridColors.push(boxSprite.getColorIndex());
		}
	}
	uiComponent.addChild(sprite);
	trace("地图格子数量",gridRows,gridCols,gridColors.length);
	
	if(MapEditorCost.DEBUG_SHOW_POSITION){
		for(var j:int = 0;j<gridRows;j++)
		{
			for(var i:int = 0;i<gridCols;i++)
			{
				
				var label:Label = new Label();
				label.setStyle("color",0x000000);
				label.setStyle("fontSize",15)
				label.text = "("+i+","+j+")";
				label.width = 64;
				label.height = 64;
				label.mouseEnabled = false;
				uiComponent.addChild(label);
				label.x = i * MapEditorCost.MAP_GRID_WIDTH + 10;
				label.y = j * MapEditorCost.MAP_GRID_HEIGHT + MapEditorCost.MAP_GRID_HEIGHT/2 - 5;
			}
		}
	}
	
	
	this.addElement(uiComponent);
	this.setElementIndex(uiComponent,1);
	this._boxUIComponent = uiComponent;
	
	this._boxUIComponent.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseClickDownHandler);
	this.stage.addEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler);
}

private function moveMapByPercent(percentX:Number,percentY:Number):void
{
	_mapOffsetX = percentX * (MapEditorDataManager.getInstance().mapWidth * this._mapScale - this.width) * -1
	_mapOffsetY = percentY * (MapEditorDataManager.getInstance().mapHeight * this._mapScale - this.height)* -1
	this._bitmapUIComponent.x = _mapOffsetX;
	this._bitmapUIComponent.y = _mapOffsetY-50 * this._mapScale; //不知道为什么会有这个偏移
	trace("moveMapByPercent  ",this._bitmapUIComponent.x,this._bitmapUIComponent.y)
	this._boxUIComponent.x = _mapOffsetX;
	this._boxUIComponent.y = _mapOffsetY;
	this._firstGridPoint = MapEditorUtils.point2Grid(_mapOffsetX * -1,_mapOffsetY * -1,this._mapScale);
}

private function updateMapPosition():void
{
	if(!_hasLoadImage){
		return;
	}
	
	var percentX:Number = h_bar.scrollPosition/h_bar.maxScrollPosition;
	var percentY:Number = v_bar.scrollPosition/v_bar.maxScrollPosition;
	this.moveMapByPercent(percentX,percentY);
}

//刷新滚动条
private function invalidScrollBar():void
{
	v_bar.x = this.width - 15;
	v_bar.height = this.height - 20
	h_bar.y = this.height - 15;
	h_bar.width = this.width - 20;
	if(!_hasLoadImage){
		return
	}
	
	if(MapEditorDataManager.getInstance().mapWidth * this._mapScale > this.width){
		h_bar.enabled = true;
	}else{
		h_bar.enabled = false;
	}
	if(MapEditorDataManager.getInstance().mapHeight * this._mapScale > this.height){
		v_bar.enabled = true;
	}else{
		v_bar.enabled = false;
	}
	
}

//刷新功能按钮
private function invalidBtns():void
{
	var btns:Array = [_loadMapBtn,_exportMapBtn];
	for(var btnIndex:int = 0;btnIndex<btns.length;btnIndex++)
	{
		var btn = btns[btnIndex];
		btn.y = 0;
		btn.x = this.width/2 + (btnIndex - btns.length/2) * MapEditorCost.BTN_SIZE_WIDTH;
	}
	
	_positionLabel.x = _loadMapBtn.x - _positionLabel.width - 100;
	_positionLabel.y = _loadMapBtn.height/2;
}

private function resizeHandler(event:Event):void
{
	this.invalidScrollBar();
	this.invalidBtns();
	this.updateMapPosition();
}

private function myHScroll(event:ScrollEvent):void
{
	this.updateMapPosition();
}

private function myVScroll(event:ScrollEvent):void
{
	trace("is calling myVScroll function");
	this.updateMapPosition();
}

private function tryFillBoxSpritesInScope(beginGridX:int,endGridX:int,beginGridY:int,endGridY:int):void
{
	var minX:int = beginGridX < endGridX ? beginGridX:endGridX;
	var maxX:int = beginGridX < endGridX ? endGridX:beginGridX;
	var minY:int = beginGridY < endGridY ? beginGridY:endGridY;
	var maxY:int = beginGridY < endGridY ? endGridY:beginGridY;
	this._recordCurrentPoints.forEach(function(boxSprite:MapBoxSprite,index:int,array:Array):void{
		boxSprite.cancelTryColor();
	},this);
	this._recordCurrentPoints =[];
	for(var tempX:int = minX;tempX<=maxX;tempX++)
	{
		for(var tempY:int = minY;tempY<=maxY;tempY++)
		{
			var boxSprite:MapBoxSprite = this.getBoxSpriteByGridXY(tempX,tempY);
			if(boxSprite){
				this._recordCurrentPoints.push(boxSprite);
				boxSprite.trySetTempColorIndex(this._currentSelecetedColorIndex);
			}else{
				trace("tryFillBoxSpritesInScope",tempX,tempY)
			}
			
		}
	}
}

private function mouseMoveHandler(event:MouseEvent):void
{
	var mouseWorldPoint:Point = this.getMouseWorldPoint();
	var x:int = mouseWorldPoint.x;
	var y:int = mouseWorldPoint.y;
	_positionLabel.text = "当前鼠标位置: x:" + x + " y:" + y;
	
	if(this._isMouseDowning && this.isSelectedTypeSpriteIndexValid()){
		var current_mouse_point:Point = MapEditorUtils.point2Grid(x,y,this._mapScale);
		if(!this.isGridValid(current_mouse_point.x,current_mouse_point.y)){
			return;
		}
		this.tryFillBoxSpritesInScope(this._clickDownPoint.x,current_mouse_point.x,this._clickDownPoint.y,current_mouse_point.y);
	}
}

private function mouseUpHandler(event:MouseEvent):void
{
	if(!_hasLoadImage){
		return;
	}
	if(!this._isMouseDowning){
		return;
	}
	this._isMouseDowning = false;
	if(this._recordCurrentPoints.length == 0 && this.isSelectedTypeSpriteIndexValid()){//没有拖动，只点击了
		var boxSprite:MapBoxSprite = this.getBoxSpriteByGridXY(this._clickDownPoint.x,this._clickDownPoint.y);
		boxSprite.setColorIndex(this._currentSelecetedColorIndex);
		var gridIndex:int = this.getGridIndexByGridXY(this._clickDownPoint.x,this._clickDownPoint.y)
		MapEditorDataManager.getInstance().gridColors[gridIndex] = boxSprite.getColorIndex();
	}else{
		this._recordCurrentPoints.forEach(function(boxSprite:MapBoxSprite,index:int,array:Array):void{
			var gridIndex:int = this.getGridIndexByGridXY(boxSprite.getGridX(),boxSprite.getGridY());
			boxSprite.confirmTryColor();
			MapEditorDataManager.getInstance().gridColors[gridIndex] = boxSprite.getColorIndex();
		},this);
		
	}
	
	trace("鼠标弹起了")
}

private function mouseWheelHandler(event:MouseEvent):void
{
	if(!_hasLoadImage){
		return;
	}
	if(_isMouseDowning){
		return;
	}
	var isCtrlActive:Boolean = event.ctrlKey;
	if(isCtrlActive){
		var scale:Number = event.delta * 0.05
		this._mapScale += scale;
		if(this._mapScale < 0.4){
			this._mapScale = 0.4;
		}
		this._bitmapUIComponent.scaleX = this._bitmapUIComponent.scaleY = this._mapScale;
		this._boxUIComponent.scaleX = this._boxUIComponent.scaleY = this._mapScale;
		this.invalidScrollBar();
		this.updateMapPosition();
	}
}

private function mouseClickDownHandler(event:MouseEvent):void
{
	if(!_hasLoadImage){
		return;
	}
	var mouseWorldPoint:Point = this.getMouseWorldPoint();
	this._clickDownPoint = MapEditorUtils.point2Grid(mouseWorldPoint.x,mouseWorldPoint.y,this._mapScale);
	this._recordCurrentPoints = [];
	this._isMouseDowning = true;
	trace("鼠标按下了",this._clickDownPoint.x,this._clickDownPoint.y)
}



private function getBoxSpriteByGridXY(x:int,y:int):MapBoxSprite
{
	var mapGridCols:int = MapEditorDataManager.getInstance().mapGridXCount; 
	var offset:int = y * mapGridCols  + x;
	var boxSprite:MapBoxSprite = this._boxSprites[offset] as MapBoxSprite;
	return boxSprite;
}

private function getGridIndexByGridXY(x:int,y:int):int
{
	return y * MapEditorDataManager.getInstance().mapGridXCount + x;
}

private function isSelectedTypeSpriteIndexValid():Boolean
{
	return this._currentSelecetedColorIndex != -1;
}

private function clientPoint2WorldPoint(x:Number,y:Number):Point
{
	return new Point(_mapOffsetX * -1 + x,_mapOffsetY * -1 + y)
}

private function getMouseWorldPoint():Point
{
	return clientPoint2WorldPoint(stage.mouseX,stage.mouseY);
}


private function isGridValid(gridX:int,gridY:int):Boolean
{
	var isXValid:Boolean = gridX < MapEditorDataManager.getInstance().mapGridXCount && gridX >= 0;
	var isYValid:Boolean = gridY < MapEditorDataManager.getInstance().mapGridYCount && gridY >= 0;
	return isXValid && isYValid;
}
	