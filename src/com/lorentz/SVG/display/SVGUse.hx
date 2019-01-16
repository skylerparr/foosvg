package com.lorentz.sVG.display;

import com.lorentz.sVG.display.base.ISVGViewBox;
import com.lorentz.sVG.display.base.ISVGViewPort;
import com.lorentz.sVG.display.base.SVGElement;
import com.lorentz.sVG.utils.SVGUtil;
import com.lorentz.sVG.utils.StringUtil;
import flash.geom.Rectangle;

class SVGUse extends SVGElement implements ISVGViewPort
{
    public var svgHref(get, set) : String;
    public var svgPreserveAspectRatio(get, set) : String;
    public var svgX(get, set) : String;
    public var svgY(get, set) : String;
    public var svgWidth(get, set) : String;
    public var svgHeight(get, set) : String;
    public var svgOverflow(get, set) : String;

    private var _includedElement : SVGElement;
    private var _svgHrefChanged : Bool = false;
    private var _svgHref : String;
    
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
        super("use");
    }
    
    private function get_svgPreserveAspectRatio() : String
    {
        return Std.string(getAttribute("preserveAspectRatio"));
    }
    private function set_svgPreserveAspectRatio(value : String) : String
    {
        setAttribute("preserveAspectRatio", value);
        return value;
    }
    
    private function get_svgX() : String
    {
        return Std.string(getAttribute("x"));
    }
    private function set_svgX(value : String) : String
    {
        setAttribute("x", value);
        return value;
    }
    
    private function get_svgY() : String
    {
        return Std.string(getAttribute("y"));
    }
    private function set_svgY(value : String) : String
    {
        setAttribute("y", value);
        return value;
    }
    
    private function get_svgWidth() : String
    {
        return Std.string(getAttribute("width"));
    }
    private function set_svgWidth(value : String) : String
    {
        setAttribute("width", value);
        return value;
    }
    
    private function get_svgHeight() : String
    {
        return Std.string(getAttribute("height"));
    }
    private function set_svgHeight(value : String) : String
    {
        setAttribute("height", value);
        return value;
    }
    
    private function get_svgOverflow() : String
    {
        return Std.string(getAttribute("overflow"));
    }
    private function set_svgOverflow(value : String) : String
    {
        setAttribute("overflow", value);
        return value;
    }
    
    override private function commitProperties() : Void
    {
        x = (svgX != null) ? getViewPortUserUnit(svgX, SVGUtil.WIDTH) : 0;
        y = (svgY != null) ? getViewPortUserUnit(svgY, SVGUtil.HEIGHT) : 0;
        
        super.commitProperties();
        
        if (_svgHrefChanged)
        {
            _svgHrefChanged = false;
            
            if (_includedElement != null)
            {
                content.removeChild(_includedElement);
                detachElement(_includedElement);
                _includedElement = null;
            }
            
            if (svgHref != null)
            {
                _includedElement = try cast(document.getDefinitionClone(StringUtil.ltrim(svgHref, "#")), SVGElement) catch(e:Dynamic) null;
                if (_includedElement != null)
                {
                    attachElement(_includedElement);
                    content.addChild(_includedElement);
                }
            }
        }
        
        if (_includedElement != null)
        {
            if (Std.is(_includedElement, SVG))
            {
                var includedSVG : SVG = try cast(_includedElement, SVG) catch(e:Dynamic) null;
                if (svgWidth != null)
                {
                    includedSVG.svgWidth = svgWidth;
                }
                if (svgHeight != null)
                {
                    includedSVG.svgHeight = svgHeight;
                }
            }
        }
    }
    
    override private function getContentBox() : Rectangle
    {
        if (Std.is(_includedElement, ISVGViewBox))
        {
            return (try cast(_includedElement, ISVGViewBox) catch(e:Dynamic) null).svgViewBox;
        }
        
        return null;
    }
    
    override public function clone() : Dynamic
    {
        var c : SVGUse = try cast(super.clone(), SVGUse) catch(e:Dynamic) null;
        c.svgHref = svgHref;
        return c;
    }
}
