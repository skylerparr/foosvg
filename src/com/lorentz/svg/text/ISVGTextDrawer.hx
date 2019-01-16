package com.lorentz.svg.text;

import com.lorentz.svg.data.text.SVGDrawnText;
import com.lorentz.svg.data.text.SVGTextToDraw;

interface ISVGTextDrawer
{

    function start() : Void
    ;
    
    function drawText(data : SVGTextToDraw) : SVGDrawnText
    ;
    
    function end() : Void
    ;
}
