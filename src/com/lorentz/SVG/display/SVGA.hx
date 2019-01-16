package com.lorentz.sVG.display;

import com.lorentz.sVG.display.base.SVGContainer;
import flash.events.MouseEvent;
import flash.net.URLRequest;

class SVGA extends SVGContainer
{
    public function new()
    {
        super("a");
    }
    
    public var svgHref : String;
    
    override private function initialize() : Void
    {
        super.initialize();
        
        this.buttonMode = true;
        this.addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
    }
    
    private function clickHandler(e : MouseEvent) : Void
    {
        if (svgHref != null && svgHref != "")
        {
            flash.Lib.getURL(new URLRequest(svgHref));
        }
    }
    
    override public function clone() : Dynamic
    {
        var c : SVGA = try cast(super.clone(), SVGA) catch(e:Dynamic) null;
        c.svgHref = svgHref;
        return c;
    }
}
