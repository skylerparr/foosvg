package com.lorentz.sVG.utils;

import com.lorentz.sVG.data.style.StyleDeclaration;
import flash.geom.Matrix;

class SVGUtil
{
    public static function processXMLEntities(xmlString : String) : String
    {
        while (true)
        {
            var entity : Array<Dynamic> = new as3hx.Compat.Regex('<!ENTITY\\s+(\\w*)\\s+"((?:.|\\s)*?)"\\s*>', "").exec(xmlString);
            if (entity == null)
            {
                break;
            }
            
            var entityDeclaration : String = entity[0];
            var entityName : String = entity[1];
            var entityValue : String = entity[2];
            
            xmlString = StringTools.replace(xmlString, entityDeclaration, "");
            xmlString = xmlString.replace(new as3hx.Compat.Regex("&" + entityName + ";", "g"), entityValue);
        }
        
        return xmlString;
    }
    
    private static var _specialXMLEntities : Dynamic = {
            quot : "\"",
            amp : "&",
            apos : "'",
            lt : "<",
            gt : ">",
            nbsp : " "
        };
    
    public static function processSpecialXMLEntities(s : String) : String
    {
        for (entityName in Reflect.fields(_specialXMLEntities))
        {
            s = s.replace(new as3hx.Compat.Regex("\\&" + entityName + ";", "g"), Reflect.field(_specialXMLEntities, entityName));
        }
        
        return s;
    }
    
    public static function replaceCharacterReferences(s : String) : String
    {
        for (hexaUnicode/* AS3HX WARNING could not determine type for var: hexaUnicode exp: ECall(EField(EIdent(s),match),[ERegexp(&#x[A-Fa-f0-9]+;,g)]) type: null */ in s.match(new as3hx.Compat.Regex('&#x[A-Fa-f0-9]+;', "g")))
        {
            var hexaValue : String = new as3hx.Compat.Regex('&#x([A-Fa-f0-9]+);', "").exec(hexaUnicode)[1];
            s = s.replace(new as3hx.Compat.Regex("\\&#x" + hexaValue + ";", "g"), String.fromCharCode("0x" + hexaValue));
        }
        
        for (decimalUnicode/* AS3HX WARNING could not determine type for var: decimalUnicode exp: ECall(EField(EIdent(s),match),[ERegexp(&#[0-9]+;,g)]) type: null */ in s.match(new as3hx.Compat.Regex('&#[0-9]+;', "g")))
        {
            var decimalValue : String = new as3hx.Compat.Regex('&#([0-9]+);', "").exec(decimalUnicode)[1];
            s = s.replace(new as3hx.Compat.Regex("\\&#" + decimalValue + ";", "g"), String.fromCharCode(as3hx.Compat.parseInt(decimalValue)));
        }
        
        return s;
    }
    
    public static function prepareXMLText(s : String) : String
    {
        s = processSpecialXMLEntities(s);
        //s = replaceCharacterReferences(s); //Flash XML parser already replaces it
        
        s = new as3hx.Compat.Regex('(?:[ ]+(\\n|\\r)+[ ]*)|(?:[ ]*(\\n|\\r)+[ ]+)', "g").replace(s, " ");  //Replace lines breaks with whitespace around it by single whitespace  
        s = new as3hx.Compat.Regex('\\n|\\r|\\t', "g").replace(s, "");  //Remove remaining line breaks and tabs  
        return s;
    }
    
    
    private static var presentationStyles : Array<Dynamic> = [
        "display", 
        "visibility", 
        "opacity", 
        "fill", 
        "fill-opacity", 
        "fill-rule", 
        "stroke", 
        "stroke-opacity", 
        "stroke-width", 
        "stroke-linecap", 
        "stroke-linejoin", 
        "stroke-dasharray", 
        "stroke-dashoffset", 
        "stroke-dashalign", 
        "font-size", 
        "font-family", 
        "font-weight", 
        "text-anchor", 
        "letter-spacing", 
        "dominant-baseline", 
        "direction", 
        "filter", 
        "marker", 
        "marker-start", 
        "marker-mid", 
        "marker-end"
    ];
    
    public static function presentationStyleToStyleDeclaration(elt : FastXML, styleDeclaration : StyleDeclaration = null) : StyleDeclaration
    {
        if (styleDeclaration == null)
        {
            styleDeclaration = new StyleDeclaration();
        }
        
        for (styleName in presentationStyles)
        {
            if (Lambda.has(elt, "@" + styleName))
            {
                styleDeclaration.setProperty(styleName, elt.get("@" + styleName));
            }
        }
        
        return styleDeclaration;
    }
    
    public static function flashRadialGradientMatrix(cx : Float, cy : Float, r : Float, fx : Float, fy : Float) : Matrix
    {
        var d : Float = r * 2;
        var mat : Matrix = new flash.geom.Matrix();
        mat.createGradientBox(d, d, 0, 0, 0);
        
        var a : Float = Math.atan2(fy - cy, fx - cx);
        mat.translate(-cx, -cy);
        mat.rotate(-a);
        mat.translate(cx, cy);
        
        mat.translate(cx - r, cy - r);
        
        return mat;
    }
    
    public static function flashLinearGradientMatrix(x1 : Float, y1 : Float, x2 : Float, y2 : Float) : Matrix
    {
        var w : Float = x2 - x1;
        var h : Float = y2 - y1;
        var a : Float = Math.atan2(h, w);
        var vl : Float = Math.sqrt(Math.pow(w, 2) + Math.pow(h, 2));
        
        var matr : Matrix = new flash.geom.Matrix();
        matr.createGradientBox(1, 1, 0, 0, 0);
        
        matr.rotate(a);
        matr.scale(vl, vl);
        matr.translate(x1, y1);
        
        return matr;
    }
    
    public static function extractUrlId(url : String) : String
    {
        var matches : Array<Dynamic> = new as3hx.Compat.Regex('url\\s*\\(#(.*?)\\)', "").exec(url);
        if (matches == null)
        {
            return null;
        }
        return matches[1];
    }
    
    public static inline var WIDTH : String = "width";
    public static inline var HEIGHT : String = "height";
    public static inline var WIDTH_HEIGHT : String = "width_height";
    public static inline var FONT_SIZE : String = "font_size";
    
    public static function getFontSize(s : String, currentFontSize : Float, viewPortWidth : Float, viewPortHeight : Float) : Float
    {
        switch (s)
        {
            case "xx-small":s = "6.94pt";
            case "x-small":s = "8.33pt";
            case "small":s = "10pt";
            case "medium":s = "12pt";
            case "large":s = "14.4pt";
            case "x-large":s = "17.28pt";
            case "xx-large":s = "20.736pt";
        }
        return getUserUnit(s, currentFontSize, viewPortWidth, viewPortHeight, FONT_SIZE);
    }
    
    public static function getUserUnit(s : String, referenceFontSize : Float, referenceWidth : Float, referenceHeight : Float, referenceMode : String) : Float
    {
        var value : Float;
        
        if (s.indexOf("pt") != -1)
        {
            value = as3hx.Compat.parseFloat(StringUtil.remove(s, "pt"));
            return value * 1.25;
        }
        else if (s.indexOf("pc") != -1)
        {
            value = as3hx.Compat.parseFloat(StringUtil.remove(s, "pc"));
            return value * 15;
        }
        else if (s.indexOf("mm") != -1)
        {
            value = as3hx.Compat.parseFloat(StringUtil.remove(s, "mm"));
            return value * 3.543307;
        }
        else if (s.indexOf("cm") != -1)
        {
            value = as3hx.Compat.parseFloat(StringUtil.remove(s, "cm"));
            return value * 35.43307;
        }
        else if (s.indexOf("in") != -1)
        {
            value = as3hx.Compat.parseFloat(StringUtil.remove(s, "in"));
            return value * 90;
        }
        else if (s.indexOf("px") != -1)
        {
            value = as3hx.Compat.parseFloat(StringUtil.remove(s, "px"));
            return value;
        }
        else if (s.indexOf("em") != -1)
        {
            value = as3hx.Compat.parseFloat(StringUtil.remove(s, "em"));
            return value * referenceFontSize;
        }
        else if (s.indexOf("%") != -1)
        {
            value = as3hx.Compat.parseFloat(StringUtil.remove(s, "%"));
            
            switch (referenceMode)
            {
                case WIDTH:
                    return value / 100 * referenceWidth;
                case HEIGHT:
                    return value / 100 * referenceHeight;
                case FONT_SIZE:
                    return value / 100 * referenceFontSize;
                default:
                    return value / 100 * Math.sqrt(Math.pow(referenceWidth, 2) + Math.pow(referenceHeight, 2)) / Math.sqrt(2);
            }
        }
        else
        {
            return as3hx.Compat.parseFloat(s);
        }
    }

    public function new()
    {
    }
}
