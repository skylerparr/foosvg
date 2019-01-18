package com.lorentz.svg.display;

import com.lorentz.svg.data.MarkerPlace;
import com.lorentz.svg.display.base.ISVGPreserveAspectRatio;
import com.lorentz.svg.display.base.ISVGViewBox;
import com.lorentz.svg.display.base.SVGContainer;
import com.lorentz.svg.display.base.SVGElement;
import com.lorentz.svg.parser.SVGParserCommon;
import com.lorentz.svg.utils.SVGUtil;
import com.lorentz.svg.utils.SVGViewPortUtils;
import flash.geom.Point;
import flash.geom.Rectangle;

class SVGMarker extends SVGContainer implements ISVGViewBox implements ISVGPreserveAspectRatio
{
    public var svgRefX(get, set) : String;
    public var svgRefY(get, set) : String;
    public var svgMarkerWidth(get, set) : String;
    public var svgMarkerHeight(get, set) : String;
    public var svgOrient(get, set) : String;
    public var svgViewBox(get, set) : Rectangle;
    public var svgPreserveAspectRatio(get, set) : String;
    public var markerPlace(get, set) : MarkerPlace;

    private var _invalidPlacement : Bool = true;
    private var _markerPlace : MarkerPlace;
    
    public function new()
    {
        super("marker");
    }
    
    private function get_svgRefX() : String
    {
        return Std.string(getAttribute("refX"));
    }
    private function set_svgRefX(value : String) : String
    {
        setAttribute("refX", value);
        invalidatePlacement();
        return value;
    }
    
    private function get_svgRefY() : String
    {
        return Std.string(getAttribute("refY"));
    }
    private function set_svgRefY(value : String) : String
    {
        setAttribute("refY", value);
        invalidatePlacement();
        return value;
    }
    
    private function get_svgMarkerWidth() : String
    {
        return Std.string(getAttribute("markerWidth"));
    }
    private function set_svgMarkerWidth(value : String) : String
    {
        setAttribute("markerWidth", value);
        invalidatePlacement();
        return value;
    }
    
    private function get_svgMarkerHeight() : String
    {
        return Std.string(getAttribute("markerHeight"));
    }
    private function set_svgMarkerHeight(value : String) : String
    {
        setAttribute("markerHeight", value);
        invalidatePlacement();
        return value;
    }
    
    private function get_svgOrient() : String
    {
        return Std.string(getAttribute("orient"));
    }
    private function set_svgOrient(value : String) : String
    {
        setAttribute("orient", value);
        invalidatePlacement();
        return value;
    }
    
    private function get_svgViewBox() : Rectangle
    {
        return try cast(getAttribute("viewBox"), Rectangle) catch(e:Dynamic) null;
    }
    private function set_svgViewBox(value : Rectangle) : Rectangle
    {
        setAttribute("viewBox", value);
        invalidatePlacement();
        return value;
    }
    
    private function get_svgPreserveAspectRatio() : String
    {
        return Std.string(getAttribute("preserveAspectRatio"));
    }
    private function set_svgPreserveAspectRatio(value : String) : String
    {
        setAttribute("preserveAspectRatio", value);
        invalidatePlacement();
        return value;
    }
    
    private function invalidatePlacement() : Void
    {
        if (!_invalidPlacement)
        {
            _invalidPlacement = true;
            _invalidate();
        }
    }
    
    override private function getElementToInheritStyles() : SVGElement
    {
        if (parentElement == null)
        {
            return null;
        }
        
        return parentElement.parentElement;
    }
    
    private function get_markerPlace() : MarkerPlace
    {
        return _markerPlace;
    }
    private function set_markerPlace(value : MarkerPlace) : MarkerPlace
    {
        _markerPlace = value;
        invalidatePlacement();
        return value;
    }
    
    override public function validate() : Void
    {
        super.validate();
        
        if (_invalidPlacement)
        {
            _invalidPlacement = false;
            
            //viewport
            scrollRect = null;
            content.scaleX = 1;
            content.scaleY = 1;
            content.x = 0;
            content.y = 0;
            
            var markerWidth : Float = 3;
            if (svgMarkerWidth != null)
            {
                markerWidth = getViewPortUserUnit(svgMarkerWidth, SVGUtil.WIDTH);
            }
            
            var markerHeight : Float = 3;
            if (svgMarkerHeight != null)
            {
                markerHeight = getViewPortUserUnit(svgMarkerHeight, SVGUtil.HEIGHT);
            }
            
            if (svgViewBox != null)
            {
                if (svgPreserveAspectRatio != "none")
                {
                    var viewPortBox : Rectangle = new Rectangle(0, 0, markerWidth, markerHeight);

                    if(svgPreserveAspectRatio == null) {
                        svgPreserveAspectRatio = "";
                    }
                    var preserveAspectRatio : Dynamic = SVGParserCommon.parsePreserveAspectRatio(svgPreserveAspectRatio);
                    
                    var viewPortContentMetrics : Dynamic = SVGViewPortUtils.getContentMetrics(viewPortBox, svgViewBox, preserveAspectRatio.align, preserveAspectRatio.meetOrSlice);
                    
                    if (preserveAspectRatio.meetOrSlice == "slice")
                    {
                        scrollRect = viewPortBox;
                    }
                    
                    content.scaleX = viewPortContentMetrics.contentScaleX;
                    content.scaleY = viewPortContentMetrics.contentScaleY;
                    content.x = viewPortContentMetrics.contentX;
                    content.y = viewPortContentMetrics.contentY;
                }
                else
                {
                    content.x = x;
                    content.y = y;
                    content.scaleX = markerWidth / content.width;
                    content.scaleY = markerHeight / content.height;
                }
            }
            
            //Position and so on
            var refX : Float = 0;
            if (svgRefX != null)
            {
                refX = getViewPortUserUnit(svgRefX, SVGUtil.WIDTH);
            }
            
            var refY : Float = 0;
            if (svgRefY != null)
            {
                refY = getViewPortUserUnit(svgRefY, SVGUtil.HEIGHT);
            }
            
            rotation = !(svgOrient != null || svgOrient == "auto") ? markerPlace.angle : as3hx.Compat.parseFloat(svgOrient);
            scaleX = markerPlace.strokeWidth;
            scaleY = markerPlace.strokeWidth;
            
            var referenceGlobal : Point = content.localToGlobal(new Point(refX, refY));
            var referencePointOnParentObject : Point = parent.globalToLocal(referenceGlobal);
            
            x = markerPlace.position.x - referencePointOnParentObject.x - x;
            y = markerPlace.position.y - referencePointOnParentObject.y - y;
        }
    }
    
    override public function clone() : Dynamic
    {
        var c : SVGMarker = try cast(super.clone(), SVGMarker) catch(e:Dynamic) null;
        c.svgRefX = svgRefX;
        c.svgRefY = svgRefY;
        c.svgMarkerWidth = svgMarkerWidth;
        c.svgMarkerHeight = svgMarkerHeight;
        c.svgOrient = svgOrient;
        return c;
    }
}
