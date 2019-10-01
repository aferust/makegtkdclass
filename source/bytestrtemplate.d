module bytestrtemplate;

__gshared const string bytestr_template = "

/+
d code generated with makegtkdclass. 
PLEASE DO \"NOT\" EDIT THIS FILE!
+/

module {{gladeName}}bytes;

__gshared const ubyte[{{arrLen}}] {{gladeName}}_bytearray = {{bytearrayStr}};

";