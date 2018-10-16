package textball;


/**
    Base class for all exceptions raised by this library.
**/
class Exception extends haxe.Exception {
    override function toString():String {
        return '[${Type.getClassName(Type.getClass(this))} ${message}]';
    }
}
