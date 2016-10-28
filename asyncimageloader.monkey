Strict

Public

' Imports (Public):
Import mojo2.graphics
Import asyncloaders

Import brl.asyncevent

' Imports (Private):
Private

Import brl.thread

Import mojo.data

Import opengl.gles20
'Import opengl.gles11

Public

' Classes (Private):
Private

Class AsyncImageLoaderThread Extends Thread
	' Fields:
	Field result:Bool
	
	Field path:String
	Field data:DataBuffer
	Field resolution:Int[]
	
	' Methods:
	Method Start:Void()
		' Create a blank buffer.
		data = New DataBuffer ' ()
		resolution = New Int[2] ' 4
		
		Super.Start()
	End
	
	Method Run__UNSAFE__:Void()
		result = (BBLoadImageData(data, path, resolution) <> Null)
	End
End

Public

' Classes (Public):
Class AsyncImageLoader Extends AsyncImageLoaderThread Implements IAsyncEventSource
	' Constructor(s):
	Method New(path:String, flags:Int, onComplete:IOnLoadImageComplete)
		Self.realPath = path
		Self.path = FixDataPath(path)
		Self.flags = flags
		Self.onComplete = onComplete
	End
	
	' Methods (Public):
	Method Start:Void()
		AddAsyncEventSource(Self)
		
		Super.Start()
		
		Return
	End
	
	' Methods (Protected):
	Protected
	
	Method UpdateAsyncEvents:Void()
		If (IsRunning()) Then
			Return
		Endif
		
		RemoveAsyncEventSource(Self)
		
		If (result) Then
			Local width:= resolution[0]
			Local height:= resolution[1]
			
			Local img:= New Image(width, height, 0.5, 0.5, flags)
			
			img.WritePixels(0, 0, width, height, data)
			
			onComplete.OnLoadImageComplete(img, realPath, Self)
		Else
			onComplete.OnLoadImageComplete(Null, realPath, Self)
		Endif
	End
	
	Public
	
	' Fields (Protected):
	Protected
	
	Field realPath:String
	Field flags:Int
	
	Field onComplete:IOnLoadImageComplete
	
	Public
End