package com.lorentz.svg.events;

import com.lorentz.svg.display.base.SVGElement;
import flash.events.Event;

class SVGEvent extends Event
{
    public var element(get, never) : SVGElement;

    public static inline var INVALIDATE : String = "invalidate";
    
    public static inline var SYNC_VALIDATED : String = "syncValidated";
    public static inline var ASYNC_VALIDATED : String = "asyncValidated";
    public static inline var VALIDATED : String = "validated";
    public static inline var RENDERED : String = "rendered";
    
    public static inline var PARSE_START : String = "parseStart";
    public static inline var PARSE_COMPLETE : String = "parseComplete";
    public static inline var ELEMENT_ADDED : String = "elementAdded";
    public static inline var ELEMENT_REMOVED : String = "elementRemoved";
    
    private var _element : SVGElement;
    private function get_element() : SVGElement
    {
        return _element;
    }
    
    public function new(type : String, element : SVGElement = null, bubbles : Bool = false, cancelable : Bool = false)
    {
        super(type, bubbles, cancelable);
        _element = element;
    }
    
    override public function clone() : Event
    {
        return new SVGEvent(type, element, bubbles, cancelable);
    }
}
