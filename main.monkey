Strict

Public

' Imports:
Import mojo2

Import asyncloaders

' Classes:
Class Application Extends App Implements IOnLoadImageComplete
	' Constant variable(s):
	Const IMAGE_LOCATION:String = "monkey://data/test.png"
	
	' Methods:
	Method OnCreate:Int()
		' Create a graphical context.
		graphics = New Canvas()
		
		' Hide the cursor when the user mouses over the window.
		HideMouse()
		
		Return 0
	End
	
	Method OnRender:Int()
		' Constant variable(s):
		Const STATUS_X:= 8.0
		Const STATUS_Y:= 8.0
		
		' Clear the screen.
		graphics.Clear(0.75, 0.25, 0.35)
		
		' Get the mouse location.
		Local x:= MouseX()
		Local y:= MouseY()
		
		If (ImageLoaded) Then
			graphics.DrawText("Image loaded from: ~q" + IMAGE_LOCATION + "~q", STATUS_X, STATUS_Y)
			
			graphics.DrawImage(image, x, y)
		Else
			graphics.DrawText("Pending image location: ~q" + IMAGE_LOCATION + "~q", STATUS_X, STATUS_Y)
			
			If (Not loadingImage) Then
				graphics.DrawText("Click to load the image.", x, y, 0.5, 0.5)
			Else
				graphics.DrawText("Loading the image...", x, y, 0.5, 0.5)
			Endif
		Endif
		
		' Flush the context.
		graphics.Flush()
		
		Return 0
	End
	
	Method OnUpdate:Int()
		If (KeyHit(KEY_ESCAPE)) Then
			OnClose()
			
			Return 0 ' 1
		Endif
		
		UpdateAsyncEvents()
		
		If (Not ImageLoaded) Then
			If (Not loadingImage) Then
				If (MouseHit(MOUSE_LEFT)) Then
					Print("Loading an image from: ~q" + IMAGE_LOCATION + "~q")
					
					LoadImageAsync(IMAGE_LOCATION, Image.Managed, Self)
					
					Self.loadingImage = True
				Endif
			Endif
		Endif
		
		Return 0
	End
	
	Method OnLoadImageComplete:Void(img:Image, path:String, source:IAsyncEventSource)
		Self.loadingImage = False
		
		If (img = Null) Then
			Print("Error loading image from: ~q" + path + "~q")
		Else
			Self.image = img
			
			Print("Loaded image successfully: ~q" + path + "~q")
		Endif
	End
	
	' Properties:
	Method ImageLoaded:Bool() Property
		Return (Self.image <> Null)
	End
	
	' Fields:
	Field graphics:Canvas
	Field image:Image
	
	Field loadingImage:Bool
End

' Functions:
Function Main:Int()
	New Application()
	
	Return 0
End