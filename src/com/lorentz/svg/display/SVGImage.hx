package com.lorentz.svg.display;

import com.lorentz.svg.display.base.ISVGViewPort;
import com.lorentz.svg.display.base.SVGElement;
import com.lorentz.svg.utils.Base64AsyncDecoder;
import flash.display.Bitmap;
import flash.display.Loader;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.utils.ByteArray;

class SVGImage extends SVGElement implements ISVGViewPort
{
    public var svgPreserveAspectRatio(get, set) : String;
    public var svgX(get, set) : String;
    public var svgY(get, set) : String;
    public var svgWidth(get, set) : String;
    public var svgHeight(get, set) : String;
    public var svgOverflow(get, set) : String;
    public var svgHref(get, set) : String;

    private var _svgHrefChanged : Bool = false;
    private var _svgHref : String;
    
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
    
    private function get_svgHref() : String
    {
        return _svgHref;
    }
    private function set_svgHref(value : String) : String
    {
        if (_svgHref != value)
        {
            _svgHref = value;
            _svgHrefChanged = true;
            invalidateProperties();
        }
        return value;
    }
    
    private var _loader : Loader;
    
    private var _base64AsyncDecoder : Base64AsyncDecoder;
    
    public function new()
    {
        super("image");
    }
    
    public function loadURL(url : String) : Void
    {
        if (_loader != null)
        {
            content.removeChild(_loader);
            _loader = null;
        }
        
        if (url != null)
        {
            _loader = new Loader();
            _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
            _loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadError);
            _loader.load(new URLRequest(url));
            content.addChild(_loader);
        }
    }
    
    //Thanks to youzi530, for coding base64 embed image support
    public function loadBase64(content : String) : Void
    {
        var base64String : String = new as3hx.Compat.Regex('^data:[a-z\\/]*;base64,', "").replace(content, "");
        
        _base64AsyncDecoder = new Base64AsyncDecoder(base64String);
        _base64AsyncDecoder.addEventListener(Base64AsyncDecoder.COMPLETE, base64AsyncDecoder_completeHandler);
        _base64AsyncDecoder.addEventListener(Base64AsyncDecoder.ERROR, base64AsyncDecoder_errorHandler);
        _base64AsyncDecoder.decode();
    }
    
    private function base64AsyncDecoder_completeHandler(e : Event) : Void
    {
        loadBytes(_base64AsyncDecoder.bytes);
        _base64AsyncDecoder = null;
    }
    
    private function base64AsyncDecoder_errorHandler(e : Event) : Void
    {
        trace(_base64AsyncDecoder.errorMessage);
        _base64AsyncDecoder = null;
    }
    
    public function loadBytes(byteArray : ByteArray) : Void
    {
        if (_loader != null)
        {
            content.removeChild(_loader);
            _loader = null;
        }
        
        if (byteArray != null)
        {
            _loader = new Loader();
            _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
            _loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadError);
            _loader.loadBytes(byteArray);
            content.addChild(_loader);
        }
    }
    
    override private function commitProperties() : Void
    {
        super.commitProperties();
        
        if (_svgHrefChanged)
        {
            _svgHrefChanged = false;
            
            if (svgHref != null && svgHref != "")
            {
                if (svgHref.match(new as3hx.Compat.Regex('^data:[a-z\\/]*;base64,', "")))
                {
                    loadBase64(svgHref);
                    beginASyncValidation("loadImage");
                }
                else
                {
                    loadURL(document.resolveURL(svgHref));
                    beginASyncValidation("loadImage");
                }
            }
        }
    }
    
    private function loadComplete(event : Event) : Void
    {
        if (Std.is(_loader.content, Bitmap))
        {
            (try cast(_loader.content, Bitmap) catch(e:Dynamic) null).smoothing = true;
        }
        
        endASyncValidation("loadImage");
    }
    
    private function loadError(e : IOErrorEvent) : Void
    {
        trace("Failed to load image" + e.text);
        
        endASyncValidation("loadImage");
    }
    
    override private function getContentBox() : Rectangle
    {
        if (_loader == null || _loader.content == null)
        {
            return null;
        }
        
        return new Rectangle(0, 0, _loader.content.width, _loader.content.height);
    }
    
    override public function clone() : Dynamic
    {
        var c : SVGImage = try cast(super.clone(), SVGImage) catch(e:Dynamic) null;
        c.svgHref = svgHref;
        return c;
    }
}
