
[MeasureBlur]
Measure=Plugin
Plugin=EasyBlur
UpdateDivider=-1
ScreenAreaWidth=#VSCREENAREAWIDTH#
ScreenAreaHeight=#VSCREENAREAHEIGHT#
XPos=#CURRENTCONFIGX#
YPos=#CURRENTCONFIGY#
XWidth=(#Clock.Size#*#ScaleDpi#)
XHeight=(#Clock.Size#*#ScaleDpi#)
Intensity=4
DontResize=0
Zoom=1
ImagePath=
Disabled=#BlurDisabled#
FastBlur=1

[BlurContainer]
Meter=Shape
Shape=Rectangle 0,0,(#Size#*#ScaleDpi#),(#Size#*#ScaleDpi#),(#Size#*#ScaleDpi#*0.18) | Fill Color 36,36,36,255 | StrokeWidth 0

[Blur]
Meter=Image
MeasureName=MeasureBlur
X=0
Y=0
W=(#Size#*#ScaleDpi#)
H=(#Size#*#ScaleDpi#)
Container=BlurContainer
UpdateDivider=-1

[Shape]
Meter=Shape
Shape=Rectangle 0,0,(#Size#*#ScaleDpi#),(#Size#*#ScaleDpi#),(#Size#*#ScaleDpi#*0.18) | StrokeWidth (#ClockDate.StrokeWidthDark#*#ScaleDpi#) | Stroke Color 255,255,255,30 | Fill LinearGradient FillGradient
FillGradient=#DarkGradient#
X=0
Y=0
AntiAlias=1
