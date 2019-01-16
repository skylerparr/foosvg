package com.lorentz.processing;

import flash.errors.Error;
import haxe.Constraints.Function;
import flash.display.Stage;
import flash.events.Event;

class ProcessExecutor
{
    public static var instance(get, never) : ProcessExecutor;
    public var percentFrameProcessingTime(get, set) : Float;
    private var internalFrameProcessingTime(get, never) : Float;

    private static var _allowInstantiation : Bool = false;
    private static var _instance : ProcessExecutor;
    
    private static function get_instance() : ProcessExecutor
    {
        if (_instance == null)
        {
            _allowInstantiation = true;
            _instance = new ProcessExecutor();
            _allowInstantiation = false;
        }
        
        return _instance;
    }
    
    private var _stage : Stage;
    private var _processes : Array<IProcess>;
    private var _percentFrameProcessingTime : Float = 0.25;  //Considering the use of 25% of the available time  
    
    public function new()
    {
        if (!_allowInstantiation)
        {
            throw new Error("The class 'ProcessExecutor' is singleton.");
        }
    }
    
    public function initialize(stage : Stage) : Void
    {
        _stage = stage;
        _processes = new Array<IProcess>();
    }
    
    private function get_percentFrameProcessingTime() : Float
    {
        return _percentFrameProcessingTime;
    }
    private function set_percentFrameProcessingTime(value : Float) : Float
    {
        _percentFrameProcessingTime = value;
        return value;
    }
    
    private function get_internalFrameProcessingTime() : Float
    {
        return 1000 / _stage.frameRate * _percentFrameProcessingTime;
    }
    
    private function ensureInitialized() : Void
    {
        if (_stage == null)
        {
            throw new Error("You must initialize the ProcessExecutor. Ex: ProcessExecutor.instance.initialize(stage)");
        }
    }
    
    public function addProcess(process : IProcess) : Void
    {
        ensureInitialized();
        
        if (_processes.length == 0)
        {
            _stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
        }
        
        _processes.push(process);
    }
    
    public function containsProcess(process : IProcess) : Bool
    {
        return Lambda.indexOf(_processes, process) != -1;
    }
    
    public function removeProcess(process : IProcess) : Void
    {
        var index : Int = Lambda.indexOf(_processes, process);
        
        if (index == -1)
        {
            return;
        }
        
        _processes.splice(index, 1);
        
        if (_processes.length == 0)
        {
            _stage.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
        }
    }
    
    private function enterFrameHandler(e : Event) : Void
    {
        var timePerProcess : Int = as3hx.Compat.parseInt(internalFrameProcessingTime / _processes.length);
        
        for (process in _processes)
        {
            executeProcess(process, timePerProcess);
        }
    }
    
    private function executeProcess(process : IProcess, duration : Int) : Void
    {
        var endTime : Int = as3hx.Compat.parseInt(Math.round(haxe.Timer.stamp() * 1000) + duration);
        var executeFunction : Function = process.executeLoop;
        do
        {
            if (executeFunction())
            {
                break;
            }
        }
        while ((Math.round(haxe.Timer.stamp() * 1000) < endTime));
    }
}
