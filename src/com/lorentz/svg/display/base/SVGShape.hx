package com.lorentz.svg.display.base;

import com.lorentz.svg.data.MarkerPlace;
import com.lorentz.svg.display.SVGMarker;
import com.lorentz.svg.drawing.DashedDrawer;
import com.lorentz.svg.drawing.GraphicsPathDrawer;
import com.lorentz.svg.drawing.IDrawer;
import com.lorentz.svg.drawing.MarkersPlacesCapturerDrawer;
import com.lorentz.svg.utils.SVGUtil;
import flash.display.Graphics;
import flash.display.GraphicsPathWinding;
import flash.geom.Rectangle;

class SVGShape extends SVGGraphicsElement
{
    private var hasDrawDirectlyToGraphics(get, never) : Bool;
    private var hasMarkers(get, never) : Bool;

    private var _markers : Array<SVGMarker> = new Array<SVGMarker>();
    private var _markersPlaces : Array<MarkerPlace>;
    
    public function new(tagName : String)
    {
        super(tagName);
    }
    
    override private function initialize() : Void
    {
        super.initialize();
        this.mouseChildren = false;
    }
    
    override private function render() : Void
    {
        super.render();
        
        _markersPlaces = null;
        
        beforeDraw();
        
        content.graphics.clear();
        
        if (hasStroke && !hasDashedStroke)
        {
            lineStyle(content.graphics);
        }
        
        beginFill(content.graphics, function() : Void
                {
                    drawWithAppropriateMethod();
                    content.graphics.endFill();
                });
        
        if (hasDashedStroke)
        {
            var dashedGraphicsPathDrawer : GraphicsPathDrawer = new GraphicsPathDrawer();
            var dashedDrawer : DashedDrawer = new DashedDrawer(dashedGraphicsPathDrawer);
            configureDashedDrawer(dashedDrawer);
            drawToDrawer(dashedDrawer);
            
            lineStyle(content.graphics);
            
            content.graphics.drawPath(dashedGraphicsPathDrawer.commands, dashedGraphicsPathDrawer.pathData);
            content.graphics.endFill();
        }
        
        renderMarkers();
    }
    
    private function drawWithAppropriateMethod() : Void
    {
        var captureMarkers : Bool = hasMarkers && _markersPlaces == null;

        if (!captureMarkers && hasDrawDirectlyToGraphics)
        {
            drawDirectlyToGraphics(content.graphics);
        }
        else
        {
            var graphicsPathDrawer : GraphicsPathDrawer = new GraphicsPathDrawer();
            
            if (captureMarkers)
            {
                var extractMarkersInfoInterceptor : MarkersPlacesCapturerDrawer = new MarkersPlacesCapturerDrawer(graphicsPathDrawer);
                content.graphics.drawPath(graphicsPathDrawer.commands, graphicsPathDrawer.pathData, getFlashWinding());
                drawToDrawer(extractMarkersInfoInterceptor);
                _markersPlaces = extractMarkersInfoInterceptor.getMarkersInfo();
            }
            else
            {
                drawToDrawer(graphicsPathDrawer);
            }

            content.graphics.drawPath(graphicsPathDrawer.commands, graphicsPathDrawer.pathData, getFlashWinding());
        }
    }
    
    private function beforeDraw() : Void
    {
    }
    
    private function drawToDrawer(drawer : IDrawer) : Void
    {
    }
    
    private function drawDirectlyToGraphics(graphics : Graphics) : Void
    {
    }
    
    private function get_hasDrawDirectlyToGraphics() : Bool
    {
        return false;
    }
    
    private function get_hasMarkers() : Bool
    {
        return hasStroke && (style.getPropertyValue("marker")
        || style.getPropertyValue("marker-start")
        || style.getPropertyValue("marker-mid")
        || style.getPropertyValue("marker-end"));
    }
    
    private function getFlashWinding() : String
    {
        var winding : String = finalStyle.getPropertyValue("fill-rule");
        if(winding == null) {
            winding = "nonzero";
        }
        switch (winding.toLowerCase())
        {
            case "evenodd":
                return GraphicsPathWinding.EVEN_ODD;
            
            case "nonzero":
                return GraphicsPathWinding.NON_ZERO;
        }
        return GraphicsPathWinding.NON_ZERO;
    }
    
    private function renderMarkers() : Void
    {
        for (oldMarker in _markers)
        {
            detachElement(oldMarker);
            content.removeChild(oldMarker);
        }

        if (_markersPlaces != null)
        {
            for (markerPlace in _markersPlaces)
            {
                var markerStyle : String = "marker-" + markerPlace.type;
                
                var markerLink : String = finalStyle.getPropertyValue(markerStyle);
                if(markerLink == null) {
                    markerLink = finalStyle.getPropertyValue("marker");
                }
                
                if (markerLink == null)
                {
                    continue;
                }
                
                var markerId : String = SVGUtil.extractUrlId(markerLink);
                if (markerId == null)
                {
                    continue;
                }
                
                var marker : SVGMarker = try cast(document.getDefinitionClone(markerId), SVGMarker) catch(e:Dynamic) null;
                
                if (marker == null)
                {
                    continue;
                }
                
                var strokeWidth : Float = 1;
                if (finalStyle.getPropertyValue("stroke-width"))
                {
                    strokeWidth = getViewPortUserUnit(finalStyle.getPropertyValue("stroke-width"), SVGUtil.WIDTH_HEIGHT);
                }
                
                markerPlace.strokeWidth = strokeWidth;
                marker.markerPlace = markerPlace;
                content.addChild(marker);
                attachElement(marker);
                _markers.push(marker);
            }
        }
    }
    
    override private function getObjectBounds() : Rectangle
    {
        graphics.beginFill(0);
        drawWithAppropriateMethod();
        return content.getBounds(this);
    }
}
