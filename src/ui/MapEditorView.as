import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.controls.Alert;
import mx.graphics.codec.JPEGEncoder;
import mx.graphics.codec.PNGEncoder;
import mx.managers.PopUpManager;

import spark.components.TextInput;
import spark.primitives.Rect;

import data.MapEditorCost;
import data.MapEditorDataManager;

private var scene_id_str:String = "";
private var scene_name_str:String = "";
private var scene_splice_width:int = 0;
private var scene_splice_height:int = 0;
private var export_quality:int = 50;

public function onClickOK()
{
	var textInput1:TextInput =  group1.getChildByName("group1_scene_id_label_value") as TextInput;
	var scene_id_str:String = textInput1.text;
	if(scene_id_str  == "" || scene_id_str == "0"){
		Alert.show("请输入正确格式的场景id");
		return;
	}
	this.scene_id_str = scene_id_str;
	var textInput2:TextInput =  group2.getChildByName("group2_scene_name_label_value") as TextInput;
	var scene_name_str:String = textInput2.text;
	
	if(scene_name_str == ""){
		scene_name_str = "null"
	}
	
	var textInput3:TextInput =  group3.getChildByName("group3_scene_splice_wdith_value") as TextInput;
	var scene_splice_width:String = textInput3.text;
	this.scene_splice_width = int(scene_splice_width);
		
	var textInput4:TextInput =  group4.getChildByName("group4_scene_splice_wdith_value") as TextInput;
	var scene_splice_height:String = textInput4.text;
	this.scene_splice_height = int(scene_splice_height);
	
	var textInput6:TextInput =  group6.getChildByName("group6_value") as TextInput;
	var qualityStr:String = textInput6.text;
	this.export_quality = int(qualityStr);
	if(this.export_quality == 0){
		this.export_quality = 50;
	}
	this.exportWalkableArea();
	var selectedValue:String = radiogroup.selectedValue as String;
	if(selectedValue == "jpg"){
		this.spliceJpgs();
	}else if(selectedValue == "png"){
		this.splicePngs()
	}
	
	PopUpManager.removePopUp(this);
}


private function exportWalkableArea():void
{
	trace(MapEditorDataManager.getInstance().mapWidth,MapEditorDataManager.getInstance().mapHeight,MapEditorDataManager.getInstance().mapGridXCount,MapEditorDataManager.getInstance().mapGridYCount);
	var MSceneName = "M"+scene_id_str
	var result:String = "";
	result += "--\n";
	result += "-- Author:wuqiang   hehehe@qq.com\n";
	result += "-- 地图自动导出配置\n";
	result += ("local "+MSceneName+ "= class(\""+MSceneName+"\")\n");
	result += ("function "+MSceneName+ ":ctor()"+"\n");
	result += ("	self.gridColume = "+ MapEditorDataManager.getInstance().mapGridXCount +"\n");
	result += ("	self.gridRow = "+ MapEditorDataManager.getInstance().mapGridYCount +"\n");
	result += ("	self.height = "+ MapEditorDataManager.getInstance().mapHeight +"\n");
	result += ("	self.width = "+ MapEditorDataManager.getInstance().mapWidth +"\n");
	result += ("	self.mapId = "+ scene_id_str +"\n");
	result += ("	self.mapName = \""+ scene_name_str +"\"\n");
	result += ("	self.grids = {"+"\n");
	
	var gridColume:int = MapEditorDataManager.getInstance().mapGridXCount;
	var gridRow:int = MapEditorDataManager.getInstance().mapGridYCount;
	for(var row:int = 0;row<gridRow; row++)
	{
		var str = "		["+(row+1)+"] = {"
		for(var col:int = 0;col<gridColume;col++)
		{
			var grid:int = row * gridColume + col;
			var state = MapEditorDataManager.getInstance().gridColors[grid];
			str += ((state-1));
			if(col != gridColume -1){
				str += ",";
			}else{
				str +="},\n"
			}
		}
		result += str;
	}
	
	result += ("	}"+"\n");
	result += ("end"+"\n");
	result += ("return "+MSceneName+"\n");
	
	var file:File = new File("E:/map/"+MSceneName+".lua");    //若没有此文件就创建它  
	var stream:FileStream = new FileStream();    //创建FileStream对象
	stream.open(file, FileMode.WRITE);    //使用FileStream对象以只读方式打开File对象
	stream.writeMultiByte(result,"cn-gb");
	stream.close();    //关闭FileStream对象  
}

private function spliceJpgs():void
{
	var currentBitmap:Bitmap = MapEditorDataManager.getInstance().mapBitmap;
	if(!currentBitmap) return;
	var spliceCol:int = Math.floor(MapEditorDataManager.getInstance().mapWidth/this.scene_splice_width);
	var spliceRow:int = Math.floor(MapEditorDataManager.getInstance().mapHeight/this.scene_splice_height);
	var start_point:Point = new Point(0,0);
	for(var row:int = 0;row<spliceRow;row++)
	{
		for(var col:int = 0;col<spliceCol;col++)
		{
			var rect:Rectangle = new Rectangle(col* this.scene_splice_height,row * this.scene_splice_width,this.scene_splice_width,this.scene_splice_height);
			var bitmapData:BitmapData = new BitmapData(this.scene_splice_width,this.scene_splice_height);
			bitmapData.copyPixels(currentBitmap.bitmapData,rect,start_point);
			var jpgEncoder:JPEGEncoder = new JPEGEncoder(this.export_quality);
			var imgByteArray:ByteArray = jpgEncoder.encode(bitmapData);
			
			var file:File = File.desktopDirectory.resolvePath("E:/map/splice/"+this.scene_id_str+"/jpg/"+row+"_"+col+".jpg");
			var stream:FileStream = new FileStream();
			stream.open(file,FileMode.WRITE);
			stream.writeBytes(imgByteArray);
			file.clone();
		}
	}
}


private function splicePngs():void
{
	var currentBitmap:Bitmap = MapEditorDataManager.getInstance().mapBitmap;
	if(!currentBitmap) return;
	var spliceCol:int = Math.floor(MapEditorDataManager.getInstance().mapWidth/this.scene_splice_width);
	var spliceRow:int = Math.floor(MapEditorDataManager.getInstance().mapHeight/this.scene_splice_height);
	var start_point:Point = new Point(0,0);
	for(var row:int = 0;row<spliceRow;row++)
	{
		for(var col:int = 0;col<spliceCol;col++)
		{
			var rect:Rectangle = new Rectangle(col* this.scene_splice_height,row * this.scene_splice_width,this.scene_splice_width,this.scene_splice_height);
			var bitmapData:BitmapData = new BitmapData(this.scene_splice_width,this.scene_splice_height);
			bitmapData.copyPixels(currentBitmap.bitmapData,rect,start_point);
			var pngEncoder:PNGEncoder = new PNGEncoder();
			var imgByteArray:ByteArray = pngEncoder.encode(bitmapData);
			var file:File = File.desktopDirectory.resolvePath("E:/map/splice/"+this.scene_id_str+"/png/"+row+"_"+col+".png");
			var stream:FileStream = new FileStream();
			stream.open(file,FileMode.WRITE);
			stream.writeBytes(imgByteArray);
			file.clone();
		}
	}
}


public function onClickCancel()
{
	PopUpManager.removePopUp(this);
}

