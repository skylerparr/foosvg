package com.lorentz.svg.display;

import com.lorentz.svg.data.text.SVGDrawnText;
import com.lorentz.svg.display.base.SVGTextContainer;
import com.lorentz.svg.utils.DisplayUtils;
import com.lorentz.svg.utils.SVGUtil;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Rectangle;

class SVGText extends SVGTextContainer
{
    public function new()
    {
        super("text");
    }
    
    public var currentX : Float = 0;
    public var currentY : Float = 0;
    public var textContainer : Sprite;
    
    private var _start : Float = 0;
    private var _end : Float = 0;
    private var fillTextsSprite : Sprite;
    
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
        
        textContainer = content;
        
        document.textDrawer.start();
        
        var direction : String = getDirectionFromStyles();
        if(direction == null) {
            direction = "lr";
        }
        var textDirection : String = direction;
        
        currentX = getViewPortUserUnit(svgX, SVGUtil.WIDTH);
        currentY = getViewPortUserUnit(svgY, SVGUtil.HEIGHT);
        
        _start = currentX;
        _renderObjects = new Array<DisplayObject>();
        
        if (hasComplexFill)
        {
            fillTextsSprite = new Sprite();
            textContainer.addChild(fillTextsSprite);
        }
        else
        {
            fillTextsSprite = textContainer;
        }
        
        for (i in 0...numTextElements)
        {
            var textElement : Dynamic = getTextElementAt(i);
            
            if (Std.is(textElement, String))
            {
                var drawnText : SVGDrawnText = createTextSprite(Std.string(textElement), document.textDrawer);

                if(drawnText.direction == null) {
                    drawnText.direction = direction;
                }

                if (drawnText.direction == "lr")
                {
                    drawnText.displayObject.x = currentX - drawnText.startX;
                    drawnText.displayObject.y = currentY - drawnText.startY - drawnText.baseLineShift;
                    currentX += drawnText.textWidth;
                }
                else
                {
                    drawnText.displayObject.x = currentX - drawnText.textWidth - drawnText.startX;
                    drawnText.displayObject.y = currentY - drawnText.startY - drawnText.baseLineShift;
                    currentX -= drawnText.textWidth;
                }
                
                if (drawnText.direction != null)
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
                    textContainer.addChild(tspan);
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
        
        _end = currentX;
        
        doAnchorAlign(textDirection, _start, _end);
        
        document.textDrawer.end();
        
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
            textContainer.addChildAt(fill, 0);
            
            _renderObjects.push(fill);
        }
    }
    
    override private function getObjectBounds() : Rectangle
    {
        return content.getBounds(this);
    }
    
    override public function clone() : Dynamic
    {
        var c : SVGText = try cast(super.clone(), SVGText) catch(e:Dynamic) null;
        c.svgX = svgX;
        c.svgY = svgY;
        
        return c;
    }
}
