package com.lorentz.svg.display;

import com.lorentz.svg.display.base.ISVGViewBox;
import com.lorentz.svg.display.base.SVGContainer;
import com.lorentz.svg.parser.SVGParserCommon;
import com.lorentz.svg.utils.SVGUtil;
import com.lorentz.svg.utils.StringUtil;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Rectangle;

class SVGPattern extends SVGContainer implements ISVGViewBox
{
    public var svgHref(get, set) : String;
    public var svgX(get, set) : String;
    public var svgY(get, set) : String;
    public var svgWidth(get, set) : String;
    public var svgHeight(get, set) : String;
    public var patternTransform(get, set) : String;
    public var svgViewBox(get, set) : Rectangle;

    private var _finalSvgX : String;
    private var _finalSvgY : String;
    private var _finalSvgWidth : String;
    private var _finalSvgHeight : String;
    private var _finalPatternTransform : String;
    private var _svgHrefChanged : Bool = false;
    private var _svgHref : String;
    private var _patternWithChildren : SVGPattern;
    
    private function get_svgHref() : String
    {
        return _svgHref;
    }
    private function set_svgHref(value : String) : String
    {
        _svgHref = value;
        _svgHrefChanged = true;
        invalidateProperties();
        return value;
    }
    
    public function new()
    {
        super("pattern");
    }
    
    private function get_svgX() : String
    {
        return Std.string(getAttribute("x"));
    }
    private function set_svgX(value : String) : String
    {
        setAttribute("x", value);
        invalidateProperties();
        return value;
    }
    
    private function get_svgY() : String
    {
        return Std.string(getAttribute("y"));
    }
    private function set_svgY(value : String) : String
    {
        setAttribute("y", value);
        invalidateProperties();
        return value;
    }
    
    private function get_svgWidth() : String
    {
        return Std.string(getAttribute("width"));
    }
    private function set_svgWidth(value : String) : String
    {
        setAttribute("width", value);
        invalidateProperties();
        return value;
    }
    
    private function get_svgHeight() : String
    {
        return Std.string(getAttribute("height"));
    }
    private function set_svgHeight(value : String) : String
    {
        setAttribute("height", value);
        invalidateProperties();
        return value;
    }
    
    private function get_patternTransform() : String
    {
        return Std.string(getAttribute("patternTransform"));
    }
    private function set_patternTransform(value : String) : String
    {
        setAttribute("patternTransform", value);
        invalidateProperties();
        return value;
    }
    
    private function get_svgViewBox() : Rectangle
    {
        return try cast(getAttribute("viewBox"), Rectangle) catch(e:Dynamic) null;
    }
    private function set_svgViewBox(value : Rectangle) : Rectangle
    {
        setAttribute("viewBox", value);
        invalidateProperties();
        return value;
    }
    
    override private function commitProperties() : Void
    {
        super.commitProperties();
        
        if (_patternWithChildren != null && _patternWithChildren != this)
        {
            detachElement(_patternWithChildren);
            _patternWithChildren = null;
        }
        
        _finalSvgX = svgX;
        _finalSvgY = svgY;
        _finalSvgWidth = svgWidth;
        _finalSvgHeight = svgHeight;
        _finalPatternTransform = patternTransform;
        _patternWithChildren = this;
        
        if (svgHref != null)
        {
            var refPattern : SVGPattern = this;
            
            while (refPattern.svgHref != null)
            {
                refPattern = try cast(document.getDefinition(StringUtil.ltrim(refPattern.svgHref, "#")), SVGPattern) catch(e:Dynamic) null;
                
                if (refPattern == null)
                {
                    break;
                }
                
                if (_patternWithChildren.numElements == 0)
                {
                    _patternWithChildren = refPattern;
                }
                if (_finalSvgX == null)
                {
                    _finalSvgX = refPattern.svgX;
                }
                if (_finalSvgY == null)
                {
                    _finalSvgY = refPattern.svgY;
                }
                if (_finalSvgWidth == null)
                {
                    _finalSvgWidth = refPattern.svgWidth;
                }
                if (_finalSvgHeight == null)
                {
                    _finalSvgHeight = refPattern.svgHeight;
                }
                if (_finalPatternTransform == null)
                {
                    _finalPatternTransform = refPattern.patternTransform;
                }
            }
        }
        
        if (_patternWithChildren != null && _patternWithChildren != this)
        {
            _patternWithChildren = try cast(_patternWithChildren.clone(), SVGPattern) catch(e:Dynamic) null;
            attachElement(_patternWithChildren);
        }
    }
    
    public function beginFill(graphics : Graphics) : Void
    {
        var x : Float = 0;
        if (_finalSvgX != null)
        {
            x = getViewPortUserUnit(_finalSvgX, SVGUtil.WIDTH);
        }
        
        var y : Float = 0;
        if (_finalSvgY != null)
        {
            y = getViewPortUserUnit(_finalSvgY, SVGUtil.HEIGHT);
        }
        
        var w : Float = 0;
        if (_finalSvgWidth != null)
        {
            w = getViewPortUserUnit(_finalSvgWidth, SVGUtil.WIDTH);
        }
        
        var h : Float = 0;
        if (_finalSvgHeight != null)
        {
            h = getViewPortUserUnit(_finalSvgHeight, SVGUtil.HEIGHT);
        }
        
        var patternMat : Matrix = new Matrix();
        patternMat.translate(x, y);
        if (_finalPatternTransform != null)
        {
            patternMat.concat(SVGParserCommon.parseTransformation(_finalPatternTransform));
        }
        
        var patScaleX : Float = Math.sqrt(patternMat.a * patternMat.a + patternMat.c * patternMat.c);
        var patScaleY : Float = Math.sqrt(patternMat.b * patternMat.b + patternMat.d * patternMat.d);
        var patScale : Float = Math.max(patScaleX, patScaleY);
        
        var bitmapW : Int = Math.round(w * patScale);
        var bitmapH : Int = Math.round(h * patScale);
        
        if (bitmapW == 0 || bitmapH == 0)
        {
            return;
        }
        
        var bd : BitmapData = new BitmapData(bitmapW, bitmapH, true, 0);
        
        var spriteToRender : Sprite = new Sprite();
        var contentParent : Sprite = new Sprite();
        var content : Sprite = _patternWithChildren.content;
        
        spriteToRender.addChild(contentParent);
        contentParent.addChild(content);
        
        content.transform.matrix = new Matrix();
        
        contentParent.scaleX = contentParent.scaleY = patScale;
        
        var bounds : Rectangle = content.getBounds(content);
        var x0 : Float = Math.floor(bounds.left / w) * w;
        var x1 : Float = Math.floor(bounds.right / w) * w;
        var y0 : Float = Math.floor(bounds.top / h) * h;
        var y1 : Float = Math.floor(bounds.bottom / h) * h;
        
        var drawY : Float = -y1;
        while (drawY <= -y0)
        {
            var drawX : Float = -x1;
            while (drawX <= -x0)
            {
                content.x = drawX;
                content.y = drawY;
                bd.draw(spriteToRender, null, null, null, null, true);
                drawX += w;
            }
            drawY += h;
        }
        
        var mat : Matrix = contentParent.transform.matrix.clone();
        mat.invert();
        mat.concat(patternMat);
        
        graphics.beginBitmapFill(bd, mat, true, true);
        
        _patternWithChildren.addChild(content);
    }
    
    override public function clone() : Dynamic
    {
        var c : SVGPattern = try cast(super.clone(), SVGPattern) catch(e:Dynamic) null;
        c.svgX = svgX;
        c.svgY = svgY;
        c.svgWidth = svgWidth;
        c.svgHeight = svgHeight;
        c.patternTransform = patternTransform;
        c.svgHref = svgHref;
        return c;
    }
}
