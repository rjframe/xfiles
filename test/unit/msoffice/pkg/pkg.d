module unit.msoffice.pkg.pkg;

import msoffice.trace;
import msoffice.pkg.pkg;

enum xmlDecl = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>`;


@("toXML serializes with values")
unittest {
    struct Values {
        string a;
        int b;
    }
    Values obj = { a: "asdf", b: 15 };

    assert(obj.toXML() ==
            xmlDecl ~ "<Values><a>asdf</a><b>15</b></Values>", obj.toXML());
}

@("toXML serializes with attributes")
unittest {
    @XMLAttribute("myAttr", "my value")
    struct Attrs {
        string a;
        @XMLAttribute("intAttr", "int value")
        int b;
    }
    Attrs obj = { a: "asdf", b: 15 };

    assert(obj.toXML() ==
            xmlDecl ~ `<Attrs myAttr="my value"><a>asdf</a><b intAttr="int value">15</b></Attrs>` ~ "",
            obj.toXML());
}

@("toXML serializes with alternative element names")
unittest {
    struct Elems {
        @XMLElementName("MyTagA")
        string a;
        int b;
    }
    Elems obj = { a: "asdf", b: 15 };

    assert(obj.toXML() ==
            xmlDecl ~ "<Elems><MyTagA>asdf</MyTagA><b>15</b></Elems>",
            obj.toXML());
}

@("toXML serializes with aggregate types")
unittest {
    struct Internal {
        int a;

        this(int v) { a = v; }
    }

    struct Aggregate {
        int b;
        Internal c;
    }

    Aggregate obj = { b: 10, c: Internal(5) };

    assert(obj.toXML() ==
            xmlDecl ~ "<Aggregate><b>10</b><c><a>5</a></c></Aggregate>",
            obj.toXML());
}

@("toXML serializes embedded arrays")
unittest {
    struct Array {
        int a;
        string b;
        int[] c;
    }

    Array obj = { a: 1, b: "two", c: [3, 4, 5] };

    assert(obj.toXML() ==
            xmlDecl ~ "<Array><a>1</a><b>two</b><c>3</c><c>4</c><c>5</c></Array>",
            obj.toXML());
}
