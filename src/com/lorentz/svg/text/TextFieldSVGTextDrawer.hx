package com.lorentz.svg.text;

import com.lorentz.svg.data.text.SVGDrawnText;
import com.lorentz.svg.data.text.SVGTextToDraw;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextLineMetrics;

class TextFieldSVGTextDrawer implements ISVGTextDrawer
{
    public function start() : Void
    {
    }
    
    public function drawText(data : SVGTextToDraw) : SVGDrawnText
    {
        var textField : TextField = new TextField();
        textField.autoSize = TextFieldAutoSize.LEFT;
        textField.text = data.text;
        textField.embedFonts = data.useEmbeddedFonts;
        
        var textFormat : TextFormat = new TextFormat();
        textFormat.font = data.fontFamily;
        textFormat.size = data.fontSize;
        textFormat.bold = data.fontWeight == "bold";
        textFormat.italic = data.fontStyle == "italic";
        textFormat.color = data.color;
        textFormat.letterSpacing = data.letterSpacing;
        textField.setTextFormat(textFormat);
        
        var lineMetrics : TextLineMetrics = textField.getLineMetrics(0);
        
        return new SVGDrawnText(textField, textField.textWidth, 2, lineMetrics.ascent + 2);
    }
    
    public function end() : Void
    {
    }

    public function new()
    {
    }
}
