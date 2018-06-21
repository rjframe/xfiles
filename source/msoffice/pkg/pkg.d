module msoffice.pkg.pkg;

struct Package {
    Part[] parts;

    void save(string path) {
        assert(0, "not implemented.");
    }
}

// 29500-2 Part 9.1
struct Part {
    /** Required: The name of the part.

        The specification allows use of an IRI (this implementation) or URI
        (recommended for better compatibility (ASCII support only)).
    */
    IRI name;
    /** Required: The content type following RFC 2616's definition and syntax
      for media types. Can be an empty string.
    */
    string contentType;
    string contents; // TODO: ubyte[]? Just a reference to another object?
    /** Optional: Growth hint specified by the producer to specify the number of
      bytes by which the part may grow, allowing for in-place modification.
    */
    long growthHint;
}

struct IRI {
    this(string name) {
        // TODO: Full validation of name.
        // See 29500-2 9.1.1.1.1
        assert(name[0] == '/');
        assert(name[$-1] != '/');
        this.name = name;
    }

    // TODO: Provide conversion to a URI?

    string name;
    alias name this;
}

enum TargetMode {
    Internal,
    External
}

struct Relationships {
    enum ns = "http://schemas.openxmlformats.org/package/2006/relationships";
    Relationship[] relationships;
}

struct Relationship {

    /** Optional: Indicates wheter the resource in inside or outside the package. */
    TargetMode targetMode = TargetMode.Internal;
    string target;
    string type;

    string id;
}

// 29500-2 Part 11.
// Core properties part may be omitted if there are no properties to set.
@TagName("cp:coreProperties")
@Attribute("xmlns:cp", "http://schemas.openxmlformats.org/package/2006/metadata/core-properties")
@Attribute("xmlns:dcterms", "http://purl.org/dc/terms/")
@Attribute("xmlns:dc", "http://purl.org/dc/elements/1.1/")
@Attribute("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance")
struct CoreProperties {
    /** Categorization of the package's content (resume, letter, etc.). */
    string category;
    /** Status of the content (draft, final, etc.). */
    string contentStatus;

    /** Resource creation date. */
    @TagName("dcterms:created")
    string created; // TODO: DateTime.

    @TagName("dcterms:modified")
    string modified;

    string description;
    /** A set of keywords to support searching and indexing. */
    Keyword[] keywords;
    string language; // TODO: lang enum?

    @TagName("dc:creator")
    string creator;

    @TagName("cp:lastModifiedBy")
    string lastModifiedBy;
    string lastPrinted; // TODO: DateTime.
    /** Resource revision number. */
    string revision;
    string subject;
    string title;
    string resVersion;

   // string toXML() {
    //}
}

struct Keyword {
    string language; // TODO: lang enum?
    string keyword;
    // TODO: The schema allows more than this.
}

/** Specify an attribute for the XML element generated by the bound object. */
struct Attribute {
    string name;
    string value;

    static string get(alias type)() {
        import std.traits : getUDAs;
        string attrText;
        static foreach(attr; getUDAs!(type, Attribute)) {
            attrText = " " ~ attr.name;
            attrText ~= `="` ~ attr.value ~ `"`;
        }
        return attrText;
    }
}

/** Set the name of the tag generated by the bound object. If not present, the
    name of the tag is the name of the struct or field.
*/
struct TagName {
    string name;

    static string get(alias type)() {
        import std.traits : hasUDA, getUDAs;
        string name;
        static if (hasUDA!(type, TagName)) {
            name = getUDAs!(type, TagName)[0].name;
        } else {
            name = type.stringof;
        }
        return name;
    }
}

// TODO: Refactor this function.
string toXML(T)(T tag) {
    import std.traits;
    import msoffice.trace;

    string xml = "<" ~ TagName.get!T() ~ Attribute.get!T() ~ ">";


    alias fieldNames = FieldNameTuple!T;
    alias fieldTypes = Fields!T;

    static foreach(i; 0..fieldNames.length) {
        // I need to use the attribute check only for open and close tags; the
        // value is the same regardless.
        static if (! hasUDA!(fieldNames[i], Attribute)) {
            static if (isAggregateType!(fieldTypes[i])) {
                trace("TODO: Add aggregate: " ~ fieldNames[i]);
                mixin(`trace("xml of aggregate: ", tag.` ~ fieldNames[i] ~ `.toXML());`);
            } else {
                // Opening tag.
                mixin("xml ~= `<` ~ TagName.get!(tag." ~ fieldNames[i] ~ ")();");
                mixin("xml ~= Attribute.get!(tag." ~ fieldNames[i] ~ ")() ~ `>`;");

                // Value.
                import std.conv : to;
                mixin(`xml ~= tag.` ~ fieldNames[i] ~ `.to!string;`);

                // Closing tag.
                mixin("xml ~= `</` ~ TagName.get!(tag." ~ fieldNames[i]
                        ~ ")() ~ `>`;");
            }
        }
    }

    return xml ~ "</" ~ TagName.get!T() ~ ">\n";
}

