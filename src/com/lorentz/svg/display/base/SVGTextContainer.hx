package com.lorentz.svg.display.base;

import com.lorentz.svg.data.text.SVGDrawnText;
import com.lorentz.svg.data.text.SVGTextToDraw;
import com.lorentz.svg.display.SVGText;
import com.lorentz.svg.text.ISVGTextDrawer;
import com.lorentz.svg.utils.SVGColorUtils;
import com.lorentz.svg.utils.SVGUtil;
import com.lorentz.svg.utils.TextUtils;
import flash.display.DisplayObject;

class SVGTextContainer extends SVGGraphicsElement
{
    public var svgX(get, set) : String;
    public var svgY(get, set) : String;
    private var textOwner(get, never) : SVGText;
    public var numTextElements(get, never) : Int;
    private var hasComplexFill(get, never) : Bool;

    private var _svgX : String;
    private var _svgY : String;
    private var _textOwner : SVGText;
    private var _renderObjects : Array<DisplayObject>;
    
    public function new(tagName : String)
    {
        super(tagName);
        
        if (Std.is(this, SVGText))
        {
            _textOwner = try cast(this, SVGText) catch(e:Dynamic) null;
        }
    }
    
    private function get_svgX() : String
    {
        return _svgX;
    }
    private function set_svgX(value : String) : String
    {
        if (_svgX != value)
        {
            _svgX = value;
            invalidateRender();
        }
        return value;
    }
    
    private function get_svgY() : String
    {
        return _svgY;
    }
    private function set_svgY(value : String) : String
    {
        if (_svgY != value)
        {
            _svgY = value;
            invalidateRender();
        }
        return value;
    }
    
    private function get_textOwner() : SVGText
    {
        return _textOwner;
    }
    
    override private function setParentElement(value : SVGElement) : Void
    {
        super.setParentElement(value);
        
        if (Std.is(value, SVGText))
        {
            setTextOwner(try cast(value, SVGText) catch(e:Dynamic) null);
        }
        else if (Std.is(value, SVGTextContainer))
        {
            setTextOwner((try cast(value, SVGTextContainer) catch(e:Dynamic) null).textOwner);
        }
        else
        {
            setTextOwner(try cast(this, SVGText) catch(e:Dynamic) null);
        }
    }
    
    private function setTextOwner(value : SVGText) : Void
    {
        if (_textOwner != value)
        {
            _textOwner = value;
            
            for (element/* AS3HX WARNING could not determine type for var: element exp: EIdent(_textElements) type: null */ in _textElements)
            {
                if (Std.is(element, SVGTextContainer))
                {
                    (try cast(element, SVGTextContainer) catch(e:Dynamic) null).setTextOwner(value);
                }
            }
        }
    }
    
    private var _textElements : Array<Dynamic> = new Array<Dynamic>();
    public function addTextElement(element : Dynamic) : Void
    {
        addTextElementAt(element, numTextElements);
    }
    
    public function addTextElementAt(element : Dynamic, index : Int) : Void
    {
        as3hx.Compat.arraySplice(_textElements, index, 0, [element]);
        
        if (Std.is(element, SVGElement))
        {
            attachElement(try cast(element, SVGElement) catch(e:Dynamic) null);
        }
        
        invalidateRender();
    }
    
    public function getTextElementAt(index : Int) : Dynamic
    {
        return _textElements[index];
    }
    
    private function get_numTextElements() : Int
    {
        return _textElements.length;
    }
    
    public function removeTextElementAt(index : Int) : Void
    {
        if (index < 0 || index >= numTextElements)
        {
            return;
        }
        
        var element : Dynamic = _textElements[index];
        if (Std.is(element, SVGElement))
        {
            detachElement(try cast(element, SVGElement) catch(e:Dynamic) null);
        }
        
        invalidateRender();
    }
    
    override public function invalidateRender() : Void
    {
        super.invalidateRender();
        
        if (textOwner != null && textOwner != this)
        {
            textOwner.invalidateRender();
        }
    }
    
    override private function onStyleChanged(styleName : String, oldValue : String, newValue : String) : Void
    {
        super.onStyleChanged(styleName, oldValue, newValue);
        
        switch (styleName)
        {
            case "font-size", "font-family", "font-weight":
                invalidateRender();
        }
    }
    
    private function createTextSprite(text : String, textDrawer : ISVGTextDrawer) : SVGDrawnText
    //Gest last bidiLevel considering overrides
    {
        
        var direction : String = TextUtils.getParagraphDirection(text);
        
        //Patch text adding direction chars, this will ensure spaces around texts will work properly
        if (direction == "rl")
        {
            text = String.fromCharCode(0x200F) + text + String.fromCharCode(0x200F);
        }
        else if (direction == "lr")
        {
            text = String.fromCharCode(0x200E) + text + String.fromCharCode(0x200E);
        }
        
        //Setup text format, to pass to the TextDrawer
        var textToDraw : SVGTextToDraw = new SVGTextToDraw();
        
        textToDraw.text = text;
        
        textToDraw.useEmbeddedFonts = document.useEmbeddedFonts;
        textToDraw.parentFontSize = (parentElement != null) ? parentElement.currentFontSize : currentFontSize;
        textToDraw.fontSize = currentFontSize;
        textToDraw.fontFamily = Std.string(finalStyle.getPropertyValue("font-family") || document.defaultFontName);
        textToDraw.fontWeight = finalStyle.getPropertyValue("font-weight") || "normal";
        textToDraw.fontStyle = finalStyle.getPropertyValue("font-style") || "normal";
        textToDraw.baselineShift = finalStyle.getPropertyValue("baseline-shift") || "baseline";
        
        var letterSpacing : String = finalStyle.getPropertyValue("letter-spacing") || "normal";
        if (letterSpacing != null && letterSpacing.toLowerCase() != "normal")
        {
            textToDraw.letterSpacing = SVGUtil.getUserUnit(letterSpacing, currentFontSize, viewPortWidth, viewPortHeight, SVGUtil.FONT_SIZE);
        }
        
        if (document.textDrawingInterceptor != null)
        {
            document.textDrawingInterceptor(textToDraw);
        }
        
        //If need to draw in right color, pass color inside format
        if (!hasComplexFill)
        {
            textToDraw.color = getFillColor();
        }
        
        //Use configured textDrawer to draw text on a displayObject
        var drawnText : SVGDrawnText = textDrawer.drawText(textToDraw);
        
        //Change drawnText alpha if needed
        if (!hasComplexFill)
        {
            if (hasFill)
            {
                drawnText.displayObject.alpha = getFillOpacity();
            }
            else
            {
                drawnText.displayObject.alpha = 0;
            }
        }
        
        //Adds direction to drawnTextInformation
        drawnText.direction = direction;
        
        return drawnText;
    }
    
    private function get_hasComplexFill() : Bool
    {
        var fill : String = finalStyle.getPropertyValue("fill");
        return fill && fill.indexOf("url") != -1;
    }
    
    private function getFillColor() : Int
    {
        var fill : String = finalStyle.getPropertyValue("fill");
        
        if (fill == null || fill.indexOf("url") > -1)
        {
            return 0x000000;
        }
        else
        {
            return SVGColorUtils.parseToUint(fill);
        }
    }
    
    private function getFillOpacity() : Float
    {
        return finalStyle.getPropertyValue("fill-opacity") || 1;
    }
    
    private function getDirectionFromStyles() : String
    {
        var direction : String = finalStyle.getPropertyValue("direction");
        
        if (direction != null)
        {
            switch (direction)
            {
                case "ltr":
                    return "lr";
                case "tlr":
                    return "rl";
            }
        }
        
        var writingMode : String = finalStyle.getPropertyValue("writing-mode");
        
        switch (writingMode)
        {
            case "lr", "lr-tb":
                return "lr";
            case "rl", "rl-tb":
                return "rl";
            case "tb", "tb-rl":
                return "tb";
        }
        
        return null;
    }
    
    public function doAnchorAlign(direction : String, textStartX : Float, textEndX : Float) : Void
    {
        var textAnchor : String = finalStyle.getPropertyValue("text-anchor") || "start";
        
        var anchorX : Float = getViewPortUserUnit(svgX, SVGUtil.WIDTH);
        
        var offsetX : Float = 0;
        
        if (direction == "lr")
        {
            if (textAnchor == "start")
            {
                offsetX += anchorX - textStartX;
            }
            if (textAnchor == "middle")
            {
                offsetX += anchorX - (textEndX + textStartX) / 2;
            }
            else if (textAnchor == "end")
            {
                offsetX += anchorX - textEndX;
            }
        }
        else
        {
            if (textAnchor == "start")
            {
                offsetX += anchorX - textEndX;
            }
            if (textAnchor == "middle")
            {
                offsetX += anchorX - (textEndX + textStartX) / 2;
            }
            else if (textAnchor == "end")
            {
                offsetX += anchorX - textStartX;
            }
        }
        
        offset(offsetX);
    }
    
    public function offset(offsetX : Float) : Void
    {
        if (_renderObjects == null)
        {
            return;
        }
        
        for (renderedText in _renderObjects)
        {
            if (Std.is(renderedText, SVGTextContainer))
            {
                var textContainer : SVGTextContainer = try cast(renderedText, SVGTextContainer) catch(e:Dynamic) null;
                if (!textContainer.svgX)
                {
                    textContainer.offset(offsetX);
                }
            }
            else
            {
                renderedText.x += offsetX;
            }
        }
    }
    
    public function hasOwnFill() : Bool
    {
        return style.getPropertyValue("fill") != null && style.getPropertyValue("fill") != "" && style.getPropertyValue("fill") != "none";
    }
    
    override public function clone() : Dynamic
    {
        var c : SVGTextContainer = try cast(super.clone(), SVGTextContainer) catch(e:Dynamic) null;
        
        var i : Int = 0;
        while (i < this.numTextElements)
        {
            var textElement : Dynamic = this.getTextElementAt(i);
            if (Std.is(textElement, SVGElement))
            {
                c.addTextElement((try cast(textElement, SVGElement) catch(e:Dynamic) null).clone());
            }
            else
            {
                c.addTextElement(textElement);
            }
            i++;
        }
        
        return c;
    }
}
