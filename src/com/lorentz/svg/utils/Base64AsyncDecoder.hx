package com.lorentz.svg.utils;

import com.lorentz.processing.Process;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.ByteArray;

/**
	 * A utility class to decode a Base64 encoded String to a ByteArray.
	 */
class Base64AsyncDecoder extends EventDispatcher
{
    public static inline var COMPLETE : String = "complete";
    public static inline var ERROR : String = "fail";
    
    public var bytes : ByteArray;
    public var errorMessage : String;
    
    private var encoded : String;
    
    public function new(encoded : String)
    {
        super();
        this.encoded = encoded;
    }
    
    public function decode() : Void
    {
        new Process(startFunction, loopFunction, completeFunction).start();
    }
    
    private function startFunction() : Void
    {
        bytes = new ByteArray();
        count = 0;
        filled = 0;
        index = 0;
        errorMessage = null;
    }
    
    private function loopFunction() : Int
    {
        for (z in 0...100)
        {
            if (index == encoded.length)
            {
                return Process.COMPLETE;
            }
            
            var c : Float = encoded.charCodeAt(index++);
            
            if (c == ESCAPE_CHAR_CODE)
            {
                work[count++] = -1;
            }
            else if (Reflect.field(inverse, Std.string(c)) != 64)
            {
                work[count++] = Reflect.field(inverse, Std.string(c));
            }
            else
            {
                continue;
            }
            
            if (count == 4)
            {
                count = 0;
                bytes.writeByte((work[0] << 2) | ((work[1] & 0xFF) >> 4));
                filled++;
                
                if (work[2] == -1)
                {
                    return Process.COMPLETE;
                }
                
                bytes.writeByte((work[1] << 4) | ((work[2] & 0xFF) >> 2));
                filled++;
                
                if (work[3] == -1)
                {
                    return Process.COMPLETE;
                }
                
                bytes.writeByte((work[2] << 6) | work[3]);
                filled++;
            }
        }
        return Process.CONTINUE;
    }
    
    private function completeFunction() : Void
    {
        if (count > 0)
        {
            this.errorMessage = "A partial block (" + count + " of 4 bytes) was dropped. Decoded data is probably truncated!";
            dispatchEvent(new Event(ERROR));
        }
        else
        {
            dispatchEvent(new Event(COMPLETE));
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Private Variables
    //
    //--------------------------------------------------------------------------
    
    private var index : Int = 0;
    private var count : Int = 0;
    private var filled : Int = 0;
    private var work : Array<Dynamic> = [0, 0, 0, 0];
    
    private static inline var ESCAPE_CHAR_CODE : Float = 61;  // The '=' char  
    
    private static var inverse : Array<Dynamic> = 
        [
        64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 
        64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 
        64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 62, 64, 64, 64, 63, 
        52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 64, 64, 64, 64, 64, 64, 
        64, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 
        15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 64, 64, 64, 64, 64, 
        64, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 
        41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 64, 64, 64, 64, 64, 
        64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 
        64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 
        64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 
        64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 
        64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 
        64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 
        64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 
        64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64
    ];
}
