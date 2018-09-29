package handler
{
	import flash.display.DisplayObject;
	
	import mx.managers.PopUpManager;

	public class MapEditorExportHandler
	{
		public function MapEditorExportHandler()
		{
		}
		
		public function handle(parent:DisplayObject):void
		{
			var add_window:MapExportView=new MapExportView();  
			add_window.title="导出地图";  
			PopUpManager.addPopUp(add_window,parent);  
			PopUpManager.centerPopUp(add_window);    
		}
	}
}