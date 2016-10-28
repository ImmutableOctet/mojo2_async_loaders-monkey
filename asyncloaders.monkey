Strict

Public

' Imports (Public):
Import mojo2.graphics
Import brl.asyncevent

' Imports (Private):
Private

' Internal:
Import asyncimageloader

Public

' Interfaces:
Interface IOnLoadImageComplete
	' Methods:
	Method OnLoadImageComplete:Void(image:Image, path:String, source:IAsyncEventSource)
End

' Functions:
Function LoadImageAsync:Void(path:String, flags:Int=Image.Managed|Image.Filter, callback:IOnLoadImageComplete)
	Local loader:= New AsyncImageLoader(path, flags, callback)
	
	loader.Start()
	
	Return
End