package com.lorentz.svg.data.text;


class SVGTextToDraw
{
    public var text : String;
    public var parentFontSize : Float;
    public var fontSize : Float;
    public var fontFamily : String;
    public var fontWeight : String;
    public var fontStyle : String;
    public var baselineShift : String;
    public var color : Int = 0;
    public var letterSpacing : Float = 0;
    public var useEmbeddedFonts : Bool;
    
    public function clone() : SVGTextToDraw
    {
        var copy : SVGTextToDraw = new SVGTextToDraw();
        copy.text = text;
        copy.parentFontSize = parentFontSize;
        copy.fontSize = fontSize;
        copy.fontFamily = fontFamily;
        copy.fontWeight = fontWeight;
        copy.fontStyle = fontStyle;
        copy.baselineShift = baselineShift;
        copy.color = color;
        copy.letterSpacing = letterSpacing;
        copy.useEmbeddedFonts = useEmbeddedFonts;
        return copy;
    }

    public function new()
    {
    }
}
