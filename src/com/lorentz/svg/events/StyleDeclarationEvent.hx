package com.lorentz.svg.events;

import flash.events.Event;

class StyleDeclarationEvent extends Event
{
    public var propertyName(get, never) : String;
    public var oldValue(get, never) : String;
    public var newValue(get, never) : String;

    public static inline var PROPERTY_CHANGE : String = "propertyChange";
    
    private var _propertyName : String;
    private var _oldValue : String;
    private var _newValue : String;
    
    public function new(type : String, propertyName : String, oldValue : String, newValue : String)
    {
        super(type);
        
        _propertyName = propertyName;
        _oldValue = oldValue;
        _newValue = newValue;
    }
    
    private function get_propertyName() : String
    {
        return _propertyName;
    }
    
    private function get_oldValue() : String
    {
        return _oldValue;
    }
    
    private function get_newValue() : String
    {
        return _newValue;
    }
}
