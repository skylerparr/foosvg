package com.lorentz.svg.parser;

import haxe.xml.Fast;
import haxe.Constraints.Function;

class VisitDefinition
{
    public function new(node : Fast, onComplete : Function = null)
    {
        this.node = node;
        this.onComplete = onComplete;
    }
    
    public var node : Fast;
    public var onComplete : Function;
}
