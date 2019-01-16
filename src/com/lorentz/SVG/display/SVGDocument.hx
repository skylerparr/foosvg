package com.lorentz.sVG.display;

import flash.errors.Error;
import haxe.Constraints.Function;
import com.lorentz.sVG.data.style.StyleDeclaration;
import com.lorentz.sVG.display.base.SVGContainer;
import com.lorentz.sVG.display.base.SVGElement;
import com.lorentz.sVG.events.SVGEvent;
import com.lorentz.sVG.parser.AsyncSVGParser;
import com.lorentz.sVG.text.FTESVGTextDrawer;
import com.lorentz.sVG.text.ISVGTextDrawer;
import com.lorentz.sVG.utils.ICloneable;
import com.lorentz.sVG.utils.SVGUtil;
import com.lorentz.sVG.utils.StringUtil;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.geom.Rectangle;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;

@:meta(Event(name="invalidate",type="com.lorentz.SVG.events.SVGEvent"))

@:meta(Event(name="syncValidated",type="com.lorentz.SVG.events.SVGEvent"))

@:meta(Event(name="asyncValidated",type="com.lorentz.SVG.events.SVGEvent"))

@:meta(Event(name="validated",type="com.lorentz.SVG.events.SVGEvent"))

@:meta(Event(name="rendered",type="com.lorentz.SVG.events.SVGEvent"))

@:meta(Event(name="parseStart",type="com.lorentz.SVG.events.SVGEvent"))

@:meta(Event(name="parseComplete",type="com.lorentz.SVG.events.SVGEvent"))

@:meta(Event(name="elementAdded",type="com.lorentz.SVG.events.SVGEvent"))

@:meta(Event(name="elementRemoved",type="com.lorentz.SVG.events.SVGEvent"))

class SVGDocument extends SVGContainer
{
    public var defaultBaseUrl(get, never) : String;
    public var availableWidth(get, set) : Float;
    public var availableHeight(get, set) : Float;

    private var _urlLoader : URLLoader;
    
    private var _parser : AsyncSVGParser;
    private var _parsing : Bool = false;
    
    private var _definitions : Dynamic = { };
    private var _stylesDeclarations : Dynamic = { };
    private var _firstValidationAfterParse : Bool = false;
    
    private var _defaultBaseUrl : String;
    
    private var _availableWidth : Float = 500;
    private var _availableHeight : Float = 500;
    
    /**
		 *  Computed base URL considering the svg path, is null when the svg was not loaded by the library
		 *  That property is used to load svg references, but it can be overriden using the property baseURL
		 */
    private function get_defaultBaseUrl() : String
    {
        return _defaultBaseUrl;
    }
    
    /**
		 * Url used as a base url to search referenced files on svg. 
		 */
    public var baseURL : String;
    
    /**
		 * Determines that the document should validate rendering during parse.
		 * Set to true if you want to progressively show the SVG while it is parsing.
		 * Set to false to improve speed and show it only after parse is complete.
		 */
    public var validateWhileParsing : Bool = true;
    
    /**
		 * Determines if the document should force validation after parse, or should wait the document be on stage.  
		 */
    public var validateAfterParse : Bool = true;
    
    /**
		 * Determines if the document should parse the XML synchronous, without spanning processing on multiple frames
		 */
    public var forceSynchronousParse : Bool = false;
    
    /**
		 * Default value for attribute fontStyle on SVGDocuments, and also is used an embedded font is missing, and missingFontAction on svgDocument is USE_DEFAULT.
		 */
    public var defaultFontName : String = "Verdana";
    
    /**
		 * Determines if the document should use embedded 
		 */
    public var useEmbeddedFonts : Bool = true;
    
    /**
		 * Function that is called before sending svgTextToDraw to TextDrawer, allowing you to change texts formats with your own rule.
		 * The function can alter any property on textFormat
		 * Function parameters: function(textFormat:SVGTextFormat):void
		 * Example: Change all texts inside an svg to a specific embedded font
		 */
    public var textDrawingInterceptor : Function;
    
    /**
		 * Object used to draw texts 
		 */
    public var textDrawer : ISVGTextDrawer = new FTESVGTextDrawer();
    
    /*
		* Set to autmaticly align the topLeft of the rendered svg content to the svgDocument origin. 
		*/
    public var autoAlign : Bool = false;
    
    public function new()
    {
        super("document");
    }
    
    public function load(urlOrUrlRequest : Dynamic) : Void
    {
        if (_urlLoader != null)
        {
            try
            {
                _urlLoader.close();
            }
            catch (e : Error)
            {
            }
            _urlLoader = null;
        }
        
        var urlRequest : URLRequest;
        
        if (Std.is(urlOrUrlRequest, URLRequest))
        {
            urlRequest = try cast(urlOrUrlRequest, URLRequest) catch(e:Dynamic) null;
        }
        else if (Std.is(urlOrUrlRequest, String))
        {
            urlRequest = new URLRequest(Std.string(urlOrUrlRequest));
        }
        else
        {
            throw new Error("Invalid param 'urlOrUrlRequest'.");
        }
        
        _defaultBaseUrl = urlRequest.url.match(new as3hx.Compat.Regex('^([^?]*\\/)', "g"))[0];
        
        _urlLoader = new URLLoader();
        _urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
        _urlLoader.addEventListener(Event.COMPLETE, urlLoader_completeHandler, false, 0, true);
        _urlLoader.addEventListener(IOErrorEvent.IO_ERROR, urlLoader_ioErrorHandler, false, 0, true);
        _urlLoader.load(urlRequest);
    }
    
    private function urlLoader_completeHandler(e : Event) : Void
    {
        if (e.currentTarget != _urlLoader)
        {
            return;
        }
        
        var svgString : String = Std.string(_urlLoader.data);
        parseInternal(svgString);
        _urlLoader = null;
    }
    
    private function urlLoader_ioErrorHandler(e : IOErrorEvent) : Void
    {
        if (e.currentTarget != _urlLoader)
        {
            return;
        }
        
        trace(e.text);
        _urlLoader = null;
    }
    
    public function parse(xmlOrXmlString : Dynamic) : Void
    {
        _defaultBaseUrl = null;
        parseInternal(xmlOrXmlString);
    }
    
    private function parseInternal(xmlOrXmlString : Dynamic) : Void
    {
        var xml : FastXML;
        
        if (Std.is(xmlOrXmlString, String))
        {
            var xmlString : String = SVGUtil.processXMLEntities(Std.string(xmlOrXmlString));
            
            var oldXMLIgnoreWhitespace : Bool = FastXML.ignoreWhitespace;
            FastXML.ignoreWhitespace = false;
            xml = new FastXML(xmlString);
            FastXML.ignoreWhitespace = oldXMLIgnoreWhitespace;
        }
        else if (Std.is(xmlOrXmlString, FastXML))
        {
            xml = try cast(xmlOrXmlString, FastXML) catch(e:Dynamic) null;
        }
        else
        {
            throw new Error("Invalid param 'xmlOrXmlString'.");
        }
        
        parseXML(xml);
    }
    
    private function parseXML(svg : FastXML) : Void
    {
        clear();
        
        if (_parsing)
        {
            _parser.cancel();
        }
        
        _parsing = true;
        
        if (hasEventListener(SVGEvent.PARSE_START))
        {
            dispatchEvent(new SVGEvent(SVGEvent.PARSE_START));
        }
        
        _parser = new AsyncSVGParser(this, svg);
        _parser.addEventListener(Event.COMPLETE, parser_completeHandler);
        _parser.parse(forceSynchronousParse);
    }
    
    
    private function parser_completeHandler(e : Event) : Void
    {
        _parsing = false;
        _parser = null;
        
        if (hasEventListener(SVGEvent.PARSE_COMPLETE))
        {
            dispatchEvent(new SVGEvent(SVGEvent.PARSE_COMPLETE));
        }
        
        _firstValidationAfterParse = true;
        
        if (validateAfterParse)
        {
            validate();
        }
    }
    
    override private function onValidated() : Void
    {
        super.onValidated();
        
        if (_firstValidationAfterParse)
        {
            _firstValidationAfterParse = false;
            if (hasEventListener(SVGEvent.RENDERED))
            {
                dispatchEvent(new SVGEvent(SVGEvent.RENDERED));
            }
        }
    }
    
    public function clear() : Void
    {
        id = null;
        svgClass = null;
        svgClipPath = null;
        svgMask = null;
        svgTransform = null;
        
        _stylesDeclarations = { };
        
        style.clear();
        
        for (id in Reflect.fields(_definitions))
        {
            removeDefinition(id);
        }
        
        while (numElements > 0)
        {
            removeElementAt(0);
        }
        
        while (content.numChildren > 0)
        {
            content.removeChildAt(0);
        }
        
        content.scaleX = 1;
        content.scaleY = 1;
    }
    
    public function listStyleDeclarations() : Array<String>
    {
        var selectorsList : Array<String> = new Array<String>();
        for (id in Reflect.fields(_stylesDeclarations))
        {
            selectorsList.push(id);
        }
        return selectorsList;
    }
    
    public function addStyleDeclaration(selector : String, styleDeclaration : StyleDeclaration) : Void
    {
        Reflect.setField(_stylesDeclarations, selector, styleDeclaration);
    }
    
    public function getStyleDeclaration(selector : String) : StyleDeclaration
    {
        return Reflect.field(_stylesDeclarations, selector);
    }
    
    public function removeStyleDeclaration(selector : String) : StyleDeclaration
    {
        var value : StyleDeclaration = Reflect.field(_stylesDeclarations, selector);
        Reflect.deleteField(_stylesDeclarations, selector);
        return value;
    }
    
    public function listDefinitions() : Array<String>
    {
        var definitionsList : Array<String> = new Array<String>();
        for (id in Reflect.fields(_definitions))
        {
            definitionsList.push(id);
        }
        return definitionsList;
    }
    
    public function addDefinition(id : String, object : Dynamic) : Void
    {
        if (Reflect.field(_definitions, id) == null)
        {
            Reflect.setField(_definitions, id, object);
        }
    }
    
    public function hasDefinition(id : String) : Bool
    {
        return Reflect.field(_definitions, id) != null;
    }
    
    public function getDefinition(id : String) : Dynamic
    {
        return Reflect.field(_definitions, id);
    }
    
    public function getDefinitionClone(id : String) : Dynamic
    {
        var object : Dynamic = Reflect.field(_definitions, id);
        
        if (Std.is(object, ICloneable))
        {
            return (try cast(object, ICloneable) catch(e:Dynamic) null).clone();
        }
        
        return object;
    }
    
    public function removeDefinition(id : String) : Void
    {
        if (Reflect.field(_definitions, id) != null)
        {
            Reflect.setField(_definitions, id, null);
        }
    }
    
    public function onElementAdded(element : SVGElement) : Void
    {
        if (hasEventListener(SVGEvent.ELEMENT_ADDED))
        {
            dispatchEvent(new SVGEvent(SVGEvent.ELEMENT_ADDED, element));
        }
    }
    
    public function onElementRemoved(element : SVGElement) : Void
    {
        if (hasEventListener(SVGEvent.ELEMENT_REMOVED))
        {
            dispatchEvent(new SVGEvent(SVGEvent.ELEMENT_REMOVED, element));
        }
    }
    
    public function resolveURL(url : String) : String
    {
        var baseUrlFinal : String = baseURL || defaultBaseUrl;
        
        if (url != null && !isHttpURL(url) && baseUrlFinal != null)
        {
            if (url.indexOf("./") == 0)
            {
                url = url.substring(2);
            }
            
            if (isHttpURL(baseUrlFinal))
            {
                var slashPos : Float;
                
                if (url.charAt(0) == "/")
                
                // non-relative path, "/dev/foo.bar".{
                    
                    slashPos = baseUrlFinal.indexOf("/", 8);
                    if (slashPos == -1)
                    {
                        slashPos = baseUrlFinal.length;
                    }
                }
                // relative path, "dev/foo.bar".
                else
                {
                    
                    slashPos = baseUrlFinal.lastIndexOf("/") + 1;
                    if (slashPos <= 8)
                    {
                        baseUrlFinal += "/";
                        slashPos = baseUrlFinal.length;
                    }
                }
                
                if (slashPos > 0)
                {
                    url = baseUrlFinal.substring(0, slashPos) + url;
                }
            }
            else
            {
                url = StringUtil.rtrim(baseUrlFinal, "/") + "/" + url;
            }
        }
        
        return url;
    }
    
    public static function isHttpURL(url : String) : Bool
    {
        return url != null &&
        (url.indexOf("http://") == 0 ||
        url.indexOf("https://") == 0);
    }
    
    override public function validate() : Void
    {
        super.validate();
        if (this.numInvalidElements > 0)
        {
            queueValidation();
        }
    }
    
    override private function get_numInvalidElements() : Int
    {
        return super.numInvalidElements;
    }
    
    override private function set_numInvalidElements(value : Int) : Int
    {
        if (super.numInvalidElements == 0 && value > 0)
        {
            queueValidation();
        }
        
        super.numInvalidElements = value;
        return value;
    }
    
    private var _validationQueued : Bool;
    private function queueValidation() : Void
    {
        if (!_validationQueued)
        {
            _validationQueued = false;
            
            if (stage != null)
            {
                stage.addEventListener(Event.ENTER_FRAME, validateCaller, false, 0, true);
                stage.addEventListener(Event.RENDER, validateCaller, false, 0, true);
                stage.invalidate();
            }
            else
            {
                addEventListener(Event.ADDED_TO_STAGE, validateCaller, false, 0, true);
            }
        }
    }
    
    private function validateCaller(e : Event) : Void
    {
        _validationQueued = false;
        
        if (_parsing && !validateWhileParsing)
        {
            queueValidation();
            return;
        }
        
        if (e.type == Event.ADDED_TO_STAGE)
        {
            removeEventListener(Event.ADDED_TO_STAGE, validateCaller);
        }
        else
        {
            e.target.removeEventListener(Event.ENTER_FRAME, validateCaller, false);
            e.target.removeEventListener(Event.RENDER, validateCaller, false);
            if (stage == null)
            
            // received render, but the stage is not available, so we will listen for addedToStage again:{
                
                addEventListener(Event.ADDED_TO_STAGE, validateCaller, false, 0, true);
                return;
            }
        }
        
        validate();
    }
    
    
    override private function onPartialyValidated() : Void
    {
        super.onPartialyValidated();
        
        if (autoAlign)
        {
            var bounds : Rectangle = content.getBounds(content);
            content.x = -bounds.left;
            content.y = -bounds.top;
        }
        else
        {
            content.x = 0;
            content.y = 0;
        }
    }
    
    private function get_availableWidth() : Float
    {
        return _availableWidth;
    }
    private function set_availableWidth(value : Float) : Float
    {
        _availableWidth = value;
        return value;
    }
    
    private function get_availableHeight() : Float
    {
        return _availableHeight;
    }
    private function set_availableHeight(value : Float) : Float
    {
        _availableHeight = value;
        return value;
    }
    
    override public function clone() : Dynamic
    {
        var c : SVGDocument = try cast(super.clone(), SVGDocument) catch(e:Dynamic) null;
        c.availableWidth = availableWidth;
        c.availableHeight = availableHeight;
        c._defaultBaseUrl = _defaultBaseUrl;
        c.baseURL = baseURL;
        c.validateWhileParsing = validateWhileParsing;
        c.validateAfterParse = validateAfterParse;
        c.defaultFontName = defaultFontName;
        c.useEmbeddedFonts = useEmbeddedFonts;
        c.textDrawingInterceptor = textDrawingInterceptor;
        c.textDrawer = textDrawer;
        
        for (id/* AS3HX WARNING could not determine type for var: id exp: ECall(EIdent(listDefinitions),[]) type: null */ in listDefinitions())
        {
            var object : Dynamic = getDefinition(id);
            if (Std.is(object, ICloneable))
            {
                c.addDefinition(id, (try cast(object, ICloneable) catch(e:Dynamic) null).clone());
            }
        }
        
        for (selector/* AS3HX WARNING could not determine type for var: selector exp: ECall(EIdent(listStyleDeclarations),[]) type: null */ in listStyleDeclarations())
        {
            var style : StyleDeclaration = getStyleDeclaration(selector);
            c.addStyleDeclaration(selector, try cast(style.clone(), StyleDeclaration) catch(e:Dynamic) null);
        }
        
        return c;
    }
}
