package com.lorentz.sVG.display;

import com.lorentz.sVG.data.text.SVGDrawnText;
import com.lorentz.sVG.display.base.SVGTextContainer;
import com.lorentz.sVG.utils.DisplayUtils;
import com.lorentz.sVG.utils.SVGUtil;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Rectangle;

class SVGTSpan extends SVGTextContainer
{
    public var svgDx(get, set) : String;
    public var svgDy(get, set) : String;

    private var _svgDx : String;
    private function get_svgDx() : String
    {
        return _svgDx;
    }
    private function set_svgDx(value : String) : String
    {
        if (_svgDx != value)
        {
            _svgDx = value;
            invalidateRender();
        }
        return value;
    }
    
    private var _svgDy : String;
    private function get_svgDy() : String
    {
        return _svgDy;
    }
    private function set_svgDy(value : String) : String
    {
        if (_svgDy != value)
        {
            _svgDy = value;
            invalidateRender();
        }
        return value;
    }
    
    public function new()
    {
        super("tspan");
    }
    
    private var _start : Float = 0;
    private var _end : Float = 0;
    
    override private function render() : Void
    {
        super.render();
        
        while (content.numChildren > 0)
        {
            content.removeChildAt(0);
        }
        
        if (this.numTextElements == 0)
        {
            return;
        }
        
        var direction : String = getDirectionFromStyles() || "lr";
        var textDirection : String = direction;
        
        if (svgX)
        {
            textOwner.currentX = getViewPortUserUnit(svgX, SVGUtil.WIDTH);
        }
        if (svgY)
        {
            textOwner.currentY = getViewPortUserUnit(svgY, SVGUtil.HEIGHT);
        }
        
        _start = textOwner.currentX;
        _renderObjects = new Array<DisplayObject>();
        
        if (svgDx != null)
        {
            textOwner.currentX += getViewPortUserUnit(svgDx, SVGUtil.WIDTH);
        }
        if (svgDy != null)
        {
            textOwner.currentY += getViewPortUserUnit(svgDy, SVGUtil.HEIGHT);
        }
        
        var fillTextsSprite : Sprite;
        
        if (hasComplexFill)
        {
            fillTextsSprite = new Sprite();
            content.addChild(fillTextsSprite);
        }
        else
        {
            fillTextsSprite = content;
        }
        
        for (i in 0...numTextElements)
        {
            var textElement : Dynamic = getTextElementAt(i);
            
            if (Std.is(textElement, String))
            {
                var drawnText : SVGDrawnText = createTextSprite(Std.string(textElement), document.textDrawer);
                
                if ((drawnText.direction || direction) == "lr")
                {
                    drawnText.displayObject.x = textOwner.currentX - drawnText.startX;
                    drawnText.displayObject.y = textOwner.currentY - drawnText.startY - drawnText.baseLineShift;
                    textOwner.currentX += drawnText.textWidth;
                }
                else
                {
                    drawnText.displayObject.x = textOwner.currentX - drawnText.textWidth - drawnText.startX;
                    drawnText.displayObject.y = textOwner.currentY - drawnText.startY - drawnText.baseLineShift;
                    textOwner.currentX -= drawnText.textWidth;
                }
                
                if (drawnText.direction)
                {
                    textDirection = drawnText.direction;
                }
                
                fillTextsSprite.addChild(drawnText.displayObject);
                _renderObjects.push(drawnText.displayObject);
            }
            else if (Std.is(textElement, SVGTextContainer))
            {
                var tspan : SVGTextContainer = try cast(textElement, SVGTextContainer) catch(e:Dynamic) null;
                
                if (tspan.hasOwnFill())
                {
                    textOwner.textContainer.addChild(tspan);
                }
                else
                {
                    fillTextsSprite.addChild(tspan);
                }
                
                tspan.invalidateRender();
                tspan.validate();
                
                _renderObjects.push(tspan);
            }
        }
        
        _end = textOwner.currentX;
        
        if (svgX)
        {
            doAnchorAlign(textDirection, _start, _end);
        }
        
        if (hasComplexFill && fillTextsSprite.numChildren > 0)
        {
            var bounds : Rectangle = DisplayUtils.safeGetBounds(fillTextsSprite, content);
            bounds.inflate(2, 2);
            var fill : Sprite = new Sprite();
            beginFill(fill.graphics);
            fill.graphics.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);
            fill.mask = fillTextsSprite;
            fillTextsSprite.cacheAsBitmap = true;
            fill.cacheAsBitmap = true;
            content.addChildAt(fill, 0);
            
            _renderObjects.push(fill);
        }
    }
    
    override public function clone() : Dynamic
    {
        var c : SVGTSpan = try cast(super.clone(), SVGTSpan) catch(e:Dynamic) null;
        c.svgX = svgX;
        c.svgY = svgY;
        c.svgDx = svgDx;
        c.svgDy = svgDy;
        return c;
    }
}
