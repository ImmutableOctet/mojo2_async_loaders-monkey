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
			
			' Allocate a new image using the detected resolution.
			Local img:= New Image(width, height, 0.5, 0.5, flags)
			
			' Multiply each of the pixel's RGB color channels by the pixel's alpha channel:
			For Local pixelIndex:= 0 Until data.Length Step 4
				Local pixel:= data.PeekInt(pixelIndex)
				
				' Retrieve the alpha channel.
				Local a:= (pixel Shr 24 & 255)
				
				' Calculate the floating-point representation of 'a'. (0.0 to 1.0)
				Local a_f:= (Float(a) / 255.0)
				
				' Retrieve each color value from our pixel, then multiply each by our alpha:
				Local b:= Int(Float(pixel Shr 16 & 255) * a_f)
				Local g:= Int(Float(pixel Shr 8 & 255) * a_f)
				Local r:= Int(Float(pixel & 255) * a_f)
				
				' Rewrite to the image-buffer using a composite of our color channels.
				data.PokeInt(pixelIndex, ((a Shl 24) | (b Shl 16) | (g Shl 8) | r))
			Next
			
			' Upload the image-buffer.
			img.WritePixels(0, 0, width, height, data)
			
			' Notify the user of our success.
			onComplete.OnLoadImageComplete(img, realPath, Self)
		Else
			' Notify the user that we have failed.
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