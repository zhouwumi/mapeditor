package data
{
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	public class MapEditorDataManager
	{
		
		public var mapWidth:int = 0;//场景宽度
		public var mapHeight:int = 0;//场景高度
		public var mapGridXCount:int = 0;//场景宽的个数
		public var mapGridYCount:int = 0;//场景高的个数
		public var mapBitmap:Bitmap = null;
		public var gridColors:Array = [];
		public var isDataReady:Boolean = false;
		
		private static var DEFAULT_GRID_WIDTH:int = 64;
		private static var DEFAULT_GRID_HEIGHT:int = 64;
		private static var _instance:MapEditorDataManager = null;
		private var _file:File = null;
		private var _callbacks:Array = [];
		
		public static function getInstance():MapEditorDataManager
		{
			if(!_instance){
				_instance = new MapEditorDataManager();
			}
			return _instance;
		}
		
		public function MapEditorDataManager()
		{
			//trace(File.applicationDirectory.url,File.applicationDirectory.nativePath);
			//trace(File.applicationStorageDirectory.url,File.applicationStorageDirectory.nativePath);
			//trace(File.desktopDirectory.url,File.desktopDirectory.nativePath);
			//trace(File.documentsDirectory.url,File.documentsDirectory.nativePath);
			
			_file = new File(File.applicationDirectory.nativePath + "\\config.json");
			if(!_file.exists){
				var fileStream:FileStream = new FileStream();
				fileStream.open( _file, FileMode.WRITE);
				fileStream.close();
			}
			_file.addEventListener(Event.COMPLETE,loadJsonCompelete);
			_file.load();
		}
		
		private function loadJsonCompelete(event:Event):void
		{
			this.isDataReady = true;
			_file.removeEventListener(Event.COMPLETE,loadJsonCompelete);
			var bytes:ByteArray = _file.data;
			var byteStr:String = bytes.toString();
			trace("loadJsonCompelete",byteStr.length,byteStr);
			var jsonObject:Object = {};
			if(byteStr != ""){
				jsonObject = JSON.parse(byteStr);
			}
			
			var hasWrite:Boolean = false;
			if(!jsonObject.hasOwnProperty("grid_width")){
				jsonObject["grid_width"] = DEFAULT_GRID_WIDTH;
				hasWrite = true
			}
			if(!jsonObject.hasOwnProperty("grid_height")){
				jsonObject["grid_height"] = DEFAULT_GRID_HEIGHT;
				hasWrite = true;
			}
			if(!jsonObject.hasOwnProperty("debug_position")){
				jsonObject["debug_position"] = false;
				hasWrite = true;
			}
			if(hasWrite)
			{
				var writeStr:String = JSON.stringify(jsonObject);
				trace("等待输入的数据是：",writeStr)
				var fileStream:FileStream = new FileStream();
				fileStream.open( _file, FileMode.WRITE);
				fileStream.writeMultiByte(writeStr,"cn-gb");
				fileStream.close();
			}
			
			MapEditorCost.MAP_GRID_WIDTH = 	jsonObject["grid_width"];
			MapEditorCost.MAP_GRID_HEIGHT = jsonObject["grid_height"];
			MapEditorCost.DEBUG_SHOW_POSITION = jsonObject["debug_position"]
			trace("loadJsonCompelete",MapEditorCost.MAP_GRID_WIDTH,MapEditorCost.MAP_GRID_HEIGHT)
			
			this._callbacks.forEach(function(listener:Function,index:int,array:Array):void{
				listener();
			},this);
			this._callbacks = [];
		}
		
		public function addLoadCompeleteListener(listener:Function):void
		{
			if(!listener) return ;
			if(isDataReady){
				listener();
				return
			}
			_callbacks.push(listener);	
		}
		
		public function removeLoadCompeleteListener(listener:Function):void
		{
			for(var index:int = 0;index < _callbacks.length;index++)
			{
				var callback:Function = _callbacks[index] as Function;
				if(callback == listener)
				{
					_callbacks.splice(index);
					return
				}
			}
		}
	}
}