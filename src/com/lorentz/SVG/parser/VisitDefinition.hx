package com.lorentz.sVG.parser;

import haxe.Constraints.Function;

class VisitDefinition
{
    public function new(node : FastXML, onComplete : Function = null)
    {
        this.node = node;
        this.onComplete = onComplete;
    }
    
    public var node : FastXML;
    public var onComplete : Function;
}
