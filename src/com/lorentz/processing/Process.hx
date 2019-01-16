package com.lorentz.processing;

import flash.errors.Error;
import haxe.Constraints.Function;

class Process implements IProcess
{
    public var loopFunction(get, never) : Function;
    public var completeFunction(get, never) : Function;
    public var startFunction(get, never) : Function;
    public var isComplete(get, never) : Bool;
    public var isRunning(get, never) : Bool;

    public static inline var CONTINUE : Int = 0;
    public static inline var SKIP_FRAME : Int = 1;
    public static inline var COMPLETE : Int = 2;
    
    public function new(startFunction : Function, loopFunction : Function, completeFunction : Function = null)
    {
        _startFunction = startFunction;
        _loopFunction = loopFunction;
        _completeFunction = completeFunction;
    }
    
    private var _loopFunction : Function;
    private function get_loopFunction() : Function
    {
        return _loopFunction;
    }
    
    private var _completeFunction : Function;
    private function get_completeFunction() : Function
    {
        return _completeFunction;
    }
    
    private var _startFunction : Function;
    private function get_startFunction() : Function
    {
        return _startFunction;
    }
    
    @:allow(com.lorentz.processing)
    private var _isComplete : Bool = false;
    private function get_isComplete() : Bool
    {
        return _isComplete;
    }
    
    @:allow(com.lorentz.processing)
    private var _isRunning : Bool = false;
    private function get_isRunning() : Bool
    {
        return _isRunning;
    }
    
    public function start() : Void
    {
        if (_isRunning)
        {
            throw new Error("This process is already running.");
        }
        
        if (_isComplete)
        {
            throw new Error("This process is complete.");
        }
        
        _isRunning = true;
        
        if (startFunction != null)
        {
            startFunction();
        }
        
        ProcessExecutor.instance.addProcess(this);
    }
    
    public function execute() : Void
    {
        if (startFunction != null)
        {
            startFunction();
        }
        
        while (loopFunction() != COMPLETE)
        {
        }
        
        complete();
    }
    
    public function stop() : Void
    {
        _isRunning = false;
        ProcessExecutor.instance.removeProcess(this);
    }
    
    public function complete() : Void
    {
        _isRunning = false;
        _isComplete = true;
        
        if (completeFunction != null)
        {
            completeFunction();
        }
        
        ProcessExecutor.instance.removeProcess(this);
    }
    
    public function reset() : Void
    {
        if (_isRunning)
        {
            stop();
        }
        
        _isComplete = false;
    }
    
    public function executeLoop() : Bool
    {
        var r : Dynamic = loopFunction();
        if (r == COMPLETE)
        {
            complete();
        }
        return r;
    }
}
