abstract global with sharing class Resource {
    global class Content {
        protected final String uri;
        protected String name;
        protected String title; // Optional
        protected String mimeType; // Optional
        protected String text; // Optional
        protected String blobData; // Optional

        global Content(String uri) {
            this.uri = uri;
        }

        global Content(String uri, String text) {
            this.uri = uri;
            this.text = text;
        }

        global Content(String uri, String name, String title, String text) {
            this.uri = uri;
            this.name = name;
            this.title = title;
            this.text = text;
        }

        global Content setName(String name) {
            this.name = name;
            return this;
        }

        global Content setTitle(String title) {
            this.title = title;
            return this;
        }

        global Content setMimeType(String mimeType) {
            this.mimeType = mimeType;
            return this;
        }

        global Content setText(String text) {
            this.text = text;
            return this;
        }

        global Content setBlobData(String blobData) {
            this.blobData = blobData;
            return this;
        }

        public String toJson() {
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('uri', this.uri);
            if (this.name != null) {
                gen.writeStringField('name', this.name);
            }
            if (this.title != null) {
                gen.writeStringField('title', this.title);
            }
            if (this.mimeType != null) {
                gen.writeStringField('mimeType', this.mimeType);
            }
            if (this.text != null) {
                gen.writeStringField('text', this.text);
            }
            if (this.blobData != null) {
                gen.writeStringField('blob', this.blobData);
            }
            gen.writeEndObject();
            return gen.getAsString();
        }
    }

    global class Annotations {
        protected List<String> audience; // "user", "assistant"
        protected Decimal priority; // between 0 and 1
        protected Datetime lastModified; // ISO 8601 formatted timestamp

        global Annotations(List<String> audience, Decimal priority, Datetime lastModified) {
            this.audience = audience;
            this.priority = priority;
            this.lastModified = lastModified;
        }
    }

    protected String uri;
    protected final String name;
    protected String title; // Optional
    protected String description; // Optional
    protected String mimeType; // Optional
    protected Long size; // optional size in bytes
    protected Annotations annotations; // Optional

    global Resource(String uri, String name) {
        this.uri = uri;
        this.name = name;
    }

    global Resource(String uri, String name, String title, String description, String mimeType, Long size) {
        this.uri = uri;
        this.name = name;
        this.title = title;
        this.description = description;
        this.mimeType = mimeType;
        this.size = size;
    }

    global void setUri(String uri) {
        this.uri = uri;
    }

    global Resource setTitle(String title) {
        this.title = title;
        return this;
    }

    global Resource setDescription(String description) {
        this.description = description;
        return this;
    }

    global Resource setMimeType(String mimeType) {
        this.mimeType = mimeType;
        return this;
    }

    global Resource setSize(Long size) {
        this.size = size;
        return this;
    }

    global void setAnnotations(Annotations annotations) {
        this.annotations = annotations;
    }

    public String getUri() {
        return this.uri;
    }

    public Boolean isTemplate() {
        return this.uri.contains('{');
    }

    abstract global List<Content> read();

    public Boolean matchesTemplate(String uri) {
        if (this.uri == null || uri == null) {
            return false;
        }

        List<String> templateParts = this.uri.split('/');
        List<String> uriParts = uri.split('/');

        if (templateParts.size() != uriParts.size()) {
            return false;
        }

        for (Integer i = 0; i < templateParts.size(); i++) {
            String templatePart = templateParts[i];
            String uriPart = uriParts[i];
            if (templatePart.startsWith('{') && templatePart.endsWith('}')) {
                continue;
            }
            if (templatePart != uriPart) {
                return false;
            }
        }

        return true;
    }

    public String toJson() {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField(this.isTemplate() ? 'uriTemplate' : 'uri', this.uri);
        gen.writeStringField('name', this.name);
        if (this.title != null) {
            gen.writeObjectField('title', this.title);
        }
        if (this.description != null) {
            gen.writeObjectField('description', this.description);
        }
        if (this.mimeType != null) {
            gen.writeStringField('mimeType', this.mimeType);
        }
        if (this.size != null) {
            gen.writeNumberField('size', this.size);
        }
        if (this.annotations != null) {
            gen.writeFieldName('annotations');
            gen.writeStartObject();
            gen.writeFieldName('audience');
            gen.writeStartArray();
            for (String audience : this.annotations.audience) {
                gen.writeString(audience);
            }
            gen.writeEndArray();
            gen.writeNumberField('priority', this.annotations.priority);
            gen.writeDateTimeField('lastModified', this.annotations.lastModified);
            gen.writeEndObject();
        }
        gen.writeEndObject();
        return gen.getAsString();
    }
}
