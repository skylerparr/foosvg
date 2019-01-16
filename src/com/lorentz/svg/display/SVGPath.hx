package com.lorentz.svg.display;

import com.lorentz.svg.data.path.SVGPathCommand;
import com.lorentz.svg.display.base.SVGShape;
import com.lorentz.svg.drawing.IDrawer;
import com.lorentz.svg.drawing.SVGPathRenderer;
import com.lorentz.svg.parser.SVGParserCommon;

class SVGPath extends SVGShape
{
    public var svgPath(get, set) : String;
    public var path(get, set) : Array<SVGPathCommand>;

    private var _invalidPathFlag : Bool = false;
    private var _pathRenderer : SVGPathRenderer;
    private var _path : Array<SVGPathCommand>;
    
    public function new()
    {
        super("path");
    }
    
    private function get_svgPath() : String
    {
        return Std.string(getAttribute("path"));
    }
    private function set_svgPath(value : String) : String
    {
        setAttribute("path", value);
        return value;
    }
    
    private function get_path() : Array<SVGPathCommand>
    {
        return _path;
    }
    private function set_path(value : Array<SVGPathCommand>) : Array<SVGPathCommand>
    {
        _path = value;
        _pathRenderer = null;
        invalidateRender();
        return value;
    }
    
    override private function onAttributeChanged(attributeName : String, oldValue : Dynamic, newValue : Dynamic) : Void
    {
        super.onAttributeChanged(attributeName, oldValue, newValue);
        
        switch (attributeName)
        {
            case "path":
                _invalidPathFlag = true;
                invalidateProperties();
        }
    }
    
    override private function commitProperties() : Void
    {
        super.commitProperties();
        
        if (_invalidPathFlag)
        {
            _invalidPathFlag = false;
            path = SVGParserCommon.parsePathData(svgPath);
        }
    }
    
    override private function beforeDraw() : Void
    {
        super.beforeDraw();
        _pathRenderer = new SVGPathRenderer(path);
    }
    
    override private function drawToDrawer(drawer : IDrawer) : Void
    {
        _pathRenderer.render(drawer);
    }
    
    override public function clone() : Dynamic
    {
        var c : SVGPath = try cast(super.clone(), SVGPath) catch(e:Dynamic) null;
        
        var pathCopy : Array<SVGPathCommand> = new Array<SVGPathCommand>();
        for (command in path)
        {
            pathCopy.push(command.clone());
        }
        c.path = pathCopy;
        
        return c;
    }
}
