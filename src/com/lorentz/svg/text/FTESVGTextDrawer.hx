package com.lorentz.svg.text;

import com.lorentz.svg.data.text.SVGDrawnText;
import com.lorentz.svg.data.text.SVGTextToDraw;
import com.lorentz.svg.utils.TextUtils;
//import flash.text.engine.ElementFormat;
//import flash.text.engine.FontDescription;
//import flash.text.engine.FontLookup;
//import flash.text.engine.FontPosture;
//import flash.text.engine.FontWeight;
//import flash.text.engine.TextBlock;
//import flash.text.engine.TextElement;
//import flash.text.engine.TextLine;

class FTESVGTextDrawer implements ISVGTextDrawer {
    public function start(): Void {
    }

    public function drawText(data: SVGTextToDraw): SVGDrawnText {
//        var fontDescription: FontDescription = new FontDescription();
//        fontDescription.fontLookup = (data.useEmbeddedFonts) ? FontLookup.EMBEDDED_CFF : FontLookup.DEVICE;
//        fontDescription.fontName = data.fontFamily;
//        fontDescription.fontWeight = (data.fontWeight == "bold") ? FontWeight.BOLD : FontWeight.NORMAL;
//        fontDescription.fontPosture = (data.fontStyle == "italic") ? FontPosture.ITALIC : FontPosture.NORMAL;
//
//        var elementFormat: ElementFormat = new ElementFormat(fontDescription);
//        elementFormat.fontSize = data.fontSize;
//        elementFormat.color = data.color;
//        elementFormat.trackingRight = Math.round(data.letterSpacing);
//
//        var textBlock: TextBlock = new TextBlock(new TextElement(data.text, elementFormat));
//        var textLine: TextLine = textBlock.createTextLine(null);
//
//        var baseLineShift: Float = 0;
//        switch (data.baselineShift.toLowerCase())
//        {
//            case "super":
//                baseLineShift = Math.abs(elementFormat.getFontMetrics().superscriptOffset || TextUtils.SUPERSCRIPT_OFFSET) * data.parentFontSize;
//            case "sub":
//                baseLineShift = -Math.abs(elementFormat.getFontMetrics().subscriptOffset || TextUtils.SUBSCRIPT_OFFSET) * data.parentFontSize;
//        }
//
//        return new SVGDrawnText(textLine, textLine.width, 0, 0, baseLineShift);
        return new SVGDrawnText();
    }

    public function end(): Void {
    }

    public function new() {
    }
}
