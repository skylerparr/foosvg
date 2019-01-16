package com.lorentz.sVG.drawing;

import com.lorentz.sVG.data.path.SVGArcToCommand;
import com.lorentz.sVG.data.path.SVGCurveToCubicCommand;
import com.lorentz.sVG.data.path.SVGCurveToCubicSmoothCommand;
import com.lorentz.sVG.data.path.SVGCurveToQuadraticCommand;
import com.lorentz.sVG.data.path.SVGCurveToQuadraticSmoothCommand;
import com.lorentz.sVG.data.path.SVGLineToCommand;
import com.lorentz.sVG.data.path.SVGLineToHorizontalCommand;
import com.lorentz.sVG.data.path.SVGLineToVerticalCommand;
import com.lorentz.sVG.data.path.SVGMoveToCommand;
import com.lorentz.sVG.data.path.SVGPathCommand;
import flash.geom.Point;

class SVGPathRenderer
{
    private var firstPoint : Point;
    private var lastControlPoint : Point;
    
    private var commands : Array<SVGPathCommand>;
    private var _drawer : IDrawer;
    
    public function new(commands : Array<SVGPathCommand>)
    {
        this.commands = commands;
    }
    
    public function render(drawer : IDrawer) : Void
    {
        _drawer = drawer;
        
        if (_drawer.penX != 0 || _drawer.penY != 0)
        {
            _drawer.moveTo(0, 0);
        }
        
        for (pathCommand in commands)
        {
            var _sw0_ = (pathCommand.type);            

            switch (_sw0_)
            {
                case "M", "m":
                    moveTo(try cast(pathCommand, SVGMoveToCommand) catch(e:Dynamic) null);
                case "L", "l":
                    lineTo(try cast(pathCommand, SVGLineToCommand) catch(e:Dynamic) null);
                case "H", "h":
                    lineToHorizontal(try cast(pathCommand, SVGLineToHorizontalCommand) catch(e:Dynamic) null);
                case "V", "v":
                    lineToVertical(try cast(pathCommand, SVGLineToVerticalCommand) catch(e:Dynamic) null);
                case "Q", "q":
                    curveToQuadratic(try cast(pathCommand, SVGCurveToQuadraticCommand) catch(e:Dynamic) null);
                case "T", "t":
                    curveToQuadraticSmooth(try cast(pathCommand, SVGCurveToQuadraticSmoothCommand) catch(e:Dynamic) null);
                case "C", "c":
                    curveToCubic(try cast(pathCommand, SVGCurveToCubicCommand) catch(e:Dynamic) null);
                case "S", "s":
                    curveToCubicSmooth(try cast(pathCommand, SVGCurveToCubicSmoothCommand) catch(e:Dynamic) null);
                case "A", "a":
                    arcTo(try cast(pathCommand, SVGArcToCommand) catch(e:Dynamic) null);
                case "Z", "z":
                    closePath();
            }
        }
    }
    
    private function closePath() : Void
    {
        _drawer.lineTo(firstPoint.x, firstPoint.y);
    }
    
    private function moveTo(command : SVGMoveToCommand) : Void
    {
        var x : Float = command.x;
        var y : Float = command.y;
        
        if (!command.absolute)
        {
            x += _drawer.penX;
            y += _drawer.penY;
        }
        
        _drawer.moveTo(x, y);
        firstPoint = new Point(x, y);
    }
    
    private function lineTo(command : SVGLineToCommand) : Void
    {
        var x : Float = command.x;
        var y : Float = command.y;
        
        if (!command.absolute)
        {
            x += _drawer.penX;
            y += _drawer.penY;
        }
        
        _drawer.lineTo(x, y);
    }
    
    private function lineToHorizontal(command : SVGLineToHorizontalCommand) : Void
    {
        var x : Float = command.x;
        
        if (!command.absolute)
        {
            x += _drawer.penX;
        }
        
        _drawer.lineTo(x, _drawer.penY);
    }
    
    private function lineToVertical(command : SVGLineToVerticalCommand) : Void
    {
        var y : Float = command.y;
        
        if (!command.absolute)
        {
            y += _drawer.penY;
        }
        
        _drawer.lineTo(_drawer.penX, y);
    }
    
    private function curveToQuadratic(command : SVGCurveToQuadraticCommand) : Void
    {
        var x1 : Float = command.x1;
        var y1 : Float = command.y1;
        var x : Float = command.x;
        var y : Float = command.y;
        
        if (!command.absolute)
        {
            x1 += _drawer.penX;
            y1 += _drawer.penY;
            x += _drawer.penX;
            y += _drawer.penY;
        }
        
        _drawer.curveTo(x1, y1, x, y);
        lastControlPoint = new Point(x1, y1);
    }
    
    private function curveToQuadraticSmooth(command : SVGCurveToQuadraticSmoothCommand) : Void
    {
        if (lastControlPoint == null)
        {
            lastControlPoint = new Point(_drawer.penX, _drawer.penY);
        }
        
        var x1 : Float = _drawer.penX + (_drawer.penX - lastControlPoint.x);
        var y1 : Float = _drawer.penY + (_drawer.penY - lastControlPoint.y);
        
        var x : Float = command.x;
        var y : Float = command.y;
        
        if (!command.absolute)
        {
            x += _drawer.penX;
            y += _drawer.penY;
        }
        
        _drawer.curveTo(x1, y1, x, y);
        lastControlPoint = new Point(x1, y1);
    }
    
    private function curveToCubic(command : SVGCurveToCubicCommand) : Void
    {
        var x1 : Float = command.x1;
        var y1 : Float = command.y1;
        var x2 : Float = command.x2;
        var y2 : Float = command.y2;
        var x : Float = command.x;
        var y : Float = command.y;
        
        if (!command.absolute)
        {
            x1 += _drawer.penX;
            y1 += _drawer.penY;
            x2 += _drawer.penX;
            y2 += _drawer.penY;
            x += _drawer.penX;
            y += _drawer.penY;
        }
        
        _drawer.cubicCurveTo(x1, y1, x2, y2, x, y);
        lastControlPoint = new Point(x2, y2);
    }
    
    private function curveToCubicSmooth(command : SVGCurveToCubicSmoothCommand) : Void
    {
        if (lastControlPoint == null)
        {
            lastControlPoint = new Point(_drawer.penX, _drawer.penY);
        }
        
        var x1 : Float = _drawer.penX + (_drawer.penX - lastControlPoint.x);
        var y1 : Float = _drawer.penY + (_drawer.penY - lastControlPoint.y);
        
        var x2 : Float = command.x2;
        var y2 : Float = command.y2;
        var x : Float = command.x;
        var y : Float = command.y;
        
        if (!command.absolute)
        {
            x2 += _drawer.penX;
            y2 += _drawer.penY;
            x += _drawer.penX;
            y += _drawer.penY;
        }
        
        _drawer.cubicCurveTo(x1, y1, x2, y2, x, y);
        lastControlPoint = new Point(x2, y2);
    }
    
    private function arcTo(command : SVGArcToCommand) : Void
    {
        var x : Float = command.x;
        var y : Float = command.y;
        
        if (!command.absolute)
        {
            x += _drawer.penX;
            y += _drawer.penY;
        }
        
        _drawer.arcTo(command.rx, command.ry, command.xAxisRotation, command.largeArc, command.sweep, x, y);
    }
}
