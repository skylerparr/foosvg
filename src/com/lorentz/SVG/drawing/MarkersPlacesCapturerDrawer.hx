package com.lorentz.sVG.drawing;

import com.lorentz.sVG.data.MarkerPlace;
import com.lorentz.sVG.data.MarkerType;
import com.lorentz.sVG.utils.ArcUtils;
import com.lorentz.sVG.utils.MathUtils;
import flash.geom.Point;

class MarkersPlacesCapturerDrawer implements IDrawer
{
    public var penX(get, never) : Float;
    public var penY(get, never) : Float;

    private var _baseDrawer : IDrawer;
    
    private var _markersInfo : Array<MarkerPlace> = new Array<MarkerPlace>();
    
    private var _firstCommand : Bool = true;
    
    public function getMarkersInfo() : Array<MarkerPlace>
    {
        setLastMarkAsEndMark();
        return _markersInfo;
    }
    
    public function new(baseDrawer : IDrawer)
    {
        _baseDrawer = baseDrawer;
    }
    
    public function arcTo(rx : Float, ry : Float, angle : Float, largeArcFlag : Bool, sweepFlag : Bool, x : Float, y : Float) : Void
    {
        var startAngle : Float = getArcStartAngle(rx, ry, angle, largeArcFlag, sweepFlag, x, y, penX, penY);
        var endAngle : Float = getArcEndAngle(rx, ry, angle, largeArcFlag, sweepFlag, x, y, penX, penY);
        
        if (_firstCommand)
        {
            _firstCommand = false;
            
            _markersInfo.push(new MarkerPlace(new Point(penX, penY), startAngle, MarkerType.START));
        }
        else
        {
            _markersInfo[_markersInfo.length - 1].averageAngle(startAngle);
        }
        
        _markersInfo.push(new MarkerPlace(new Point(x, y), endAngle, MarkerType.MID));
        
        _baseDrawer.arcTo(rx, ry, angle, largeArcFlag, sweepFlag, x, y);
    }
    
    public function cubicCurveTo(cx1 : Float, cy1 : Float, cx2 : Float, cy2 : Float, x : Float, y : Float) : Void
    {
        var startAngle : Float = getCubicCurveStartAngle(penX, penY, cx1, cy1, cx2, cy2, x, y);
        var endAngle : Float = getCubicCurveEndAngle(penX, penY, cx1, cy1, cx2, cy2, x, y);
        
        if (_firstCommand)
        {
            _firstCommand = false;
            
            _markersInfo.push(new MarkerPlace(new Point(penX, penY), startAngle, MarkerType.START));
        }
        else
        {
            _markersInfo[_markersInfo.length - 1].averageAngle(startAngle);
        }
        
        _markersInfo.push(new MarkerPlace(new Point(x, y), endAngle, MarkerType.MID));
        
        _baseDrawer.cubicCurveTo(cx1, cy1, cx2, cy2, x, y);
    }
    
    public function curveTo(cx : Float, cy : Float, x : Float, y : Float) : Void
    {
        var startAngle : Float = getQuadCurveStartAngle(penX, penY, cx, cy, x, y);
        var endAngle : Float = getQuadCurveEndAngle(penX, penY, cx, cy, x, y);
        
        if (_firstCommand)
        {
            _firstCommand = false;
            
            _markersInfo.push(new MarkerPlace(new Point(penX, penY), startAngle, MarkerType.START));
        }
        else
        {
            _markersInfo[_markersInfo.length - 1].averageAngle(startAngle);
        }
        
        _markersInfo.push(new MarkerPlace(new Point(x, y), endAngle, MarkerType.MID));
        
        _baseDrawer.curveTo(cx, cy, x, y);
    }
    
    public function lineTo(x : Float, y : Float) : Void
    {
        var angle : Float = getLineAngle(penX, penY, x, y);
        
        if (_firstCommand)
        {
            _firstCommand = false;
            
            _markersInfo.push(new MarkerPlace(new Point(penX, penY), angle, MarkerType.START));
        }
        else
        {
            _markersInfo[_markersInfo.length - 1].averageAngle(angle);
        }
        
        _markersInfo.push(new MarkerPlace(new Point(x, y), angle, MarkerType.MID));
        
        _baseDrawer.lineTo(x, y);
    }
    
    public function moveTo(x : Float, y : Float) : Void
    {
        setLastMarkAsEndMark();
        
        _firstCommand = true;
        _baseDrawer.moveTo(x, y);
    }
    
    private function get_penX() : Float
    {
        return _baseDrawer.penX;
    }
    
    private function get_penY() : Float
    {
        return _baseDrawer.penY;
    }
    
    private function getArcStartAngle(rx : Float, ry : Float, angle : Float, largeArcFlag : Bool, sweepFlag : Bool, x : Float, y : Float, sx : Float, sy : Float) : Float
    {
        var ellipticalArc : Dynamic = ArcUtils.computeSvgArc(rx, ry, angle, largeArcFlag, sweepFlag, x, y, sx, sy);
        
        var curves : Array<Dynamic> = ArcUtils.convertToCurves(ellipticalArc.cx, ellipticalArc.cy, ellipticalArc.startAngle, ellipticalArc.arc, ellipticalArc.radius, ellipticalArc.yRadius, ellipticalArc.xAxisRotation);
        
        var firstQuadCurve : Dynamic = curves[0];
        
        return getQuadCurveStartAngle(firstQuadCurve.s.x, firstQuadCurve.s.y, firstQuadCurve.c.x, firstQuadCurve.c.y, firstQuadCurve.p.x, firstQuadCurve.p.y);
    }
    
    private function getArcEndAngle(rx : Float, ry : Float, angle : Float, largeArcFlag : Bool, sweepFlag : Bool, x : Float, y : Float, sx : Float, sy : Float) : Float
    {
        var ellipticalArc : Dynamic = ArcUtils.computeSvgArc(rx, ry, angle, largeArcFlag, sweepFlag, x, y, sx, sy);
        
        var curves : Array<Dynamic> = ArcUtils.convertToCurves(ellipticalArc.cx, ellipticalArc.cy, ellipticalArc.startAngle, ellipticalArc.arc, ellipticalArc.radius, ellipticalArc.yRadius, ellipticalArc.xAxisRotation);
        
        var lastQuadCurve : Dynamic = curves[curves.length - 1];
        
        return getQuadCurveEndAngle(lastQuadCurve.s.x, lastQuadCurve.s.y, lastQuadCurve.c.x, lastQuadCurve.c.y, lastQuadCurve.p.x, lastQuadCurve.p.y);
    }
    
    private function getCubicCurveStartAngle(sx : Float, sy : Float, cx1 : Float, cy1 : Float, cx2 : Float, cy2 : Float, x : Float, y : Float) : Float
    {
        if (cx1 == sx && cy1 == sy)
        {
            return MathUtils.radiusToDegress(Math.atan2(cy2 - sy, cx2 - sx));
        }
        else
        {
            return MathUtils.radiusToDegress(Math.atan2(cy1 - sy, cx1 - sx));
        }
    }
    
    private function getCubicCurveEndAngle(sx : Float, sy : Float, cx1 : Float, cy1 : Float, cx2 : Float, cy2 : Float, x : Float, y : Float) : Float
    {
        if (cx2 == x && cy2 == y)
        {
            return MathUtils.radiusToDegress(Math.atan2(y - cy1, x - cx1));
        }
        else
        {
            return MathUtils.radiusToDegress(Math.atan2(y - cy2, x - cx2));
        }
    }
    
    
    private function getQuadCurveStartAngle(sx : Float, sy : Float, cx : Float, cy : Float, x : Float, y : Float) : Float
    {
        return MathUtils.radiusToDegress(Math.atan2(cy - sy, cx - sx));
    }
    
    private function getQuadCurveEndAngle(sx : Float, sy : Float, cx : Float, cy : Float, x : Float, y : Float) : Float
    {
        return MathUtils.radiusToDegress(Math.atan2(y - cy, x - cx));
    }
    
    private function getLineAngle(sx : Float, sy : Float, x : Float, y : Float) : Float
    {
        return MathUtils.radiusToDegress(Math.atan2(y - sy, x - sx));
    }
    
    private function setLastMarkAsEndMark() : Void
    {
        if (_markersInfo.length > 0)
        {
            _markersInfo[_markersInfo.length - 1].type = MarkerType.END;
        }
    }
}
