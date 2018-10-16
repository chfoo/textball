package textball.simple;

import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import org.msgpack.MsgPack;
import resdb.adapter.IntConverter;
import resdb.PagePacker;


class PagePackerTools {
    public static function stringSet(pagePacker:PagePacker, namespace:String,
            key:String, value:Bytes) {
        pagePacker.addRecord(Bytes.ofString('$namespace:$key'), value);
    }

    public static function stringSetString(pagePacker:PagePacker,
            namespace:String, key:String, value:String) {
        stringSet(pagePacker, namespace, key, MsgPack.encode(value));
    }

    public static function stringSetArray(pagePacker:PagePacker,
            namespace:String, key:String, value:Array<String>) {
        if (value.length == 0) {
            throw new Exception("Array can't be empty");
        }

        stringSet(pagePacker, namespace, key, MsgPack.encode(value));
    }

    public static function intSet(pagePacker:PagePacker, namespace:String,
            key:Int, value:Bytes) {
        var buffer = new BytesBuffer();
        buffer.addString(namespace);
        buffer.addString(":");
        buffer.add(IntConverter.intToBytes(key));
        var key = buffer.getBytes();
        pagePacker.addRecord(key, value);
    }

    public static inline function intSetString(pagePacker:PagePacker,
            namespace:String, key:Int, value:String) {
        intSet(pagePacker, namespace, key, MsgPack.encode(value));
    }

    public static inline function intSetArray(pagePacker:PagePacker,
            namespace:String, key:Int, value:Array<String>) {
        intSet(pagePacker, namespace, key, MsgPack.encode(value));
    }
}
