abstract global with sharing class Tool {
    global class Property {
        private final String name;
        private final String type;
        private final String description;
        private final Boolean isRequired;

        global Property(String name, String type, String description, Boolean isRequired) {
            this.name = name;
            this.type = type;
            this.description = description;
            this.isRequired = isRequired;
        }
    }

    protected String name;
    protected String title;
    protected String description;
    protected Set<Property> properties = new Set<Property>();

    global Tool(String name, String description) {
        this.name = name;
        this.description = description;
    }

    global Tool(String name, String title, String description) {
        this.name = name;
        this.title = title;
        this.description = description;
    }

    public String getName() {
        return this.name;
    }

    abstract global String call(Map<String, Object> input);

    global void addProperty(Property property) {
        properties.add(property);
    }

    public String toJson() {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('name', this.name);
        if (this.title != null) {
            gen.writeStringField('title', this.title);
        }
        gen.writeStringField('description', this.description);

        gen.writeFieldName('inputSchema');
        gen.writeStartObject();
        gen.writeStringField('type', 'object');

        gen.writeFieldName('properties');
        gen.writeStartObject();
        for (Property property : properties) {
            gen.writeFieldName(property.name);
            gen.writeStartObject();
            gen.writeStringField('type', property.type);
            gen.writeStringField('description', property.description);
            gen.writeEndObject();
        }
        gen.writeEndObject();

        gen.writeFieldName('required');
        gen.writeStartArray();
        for (Property property : properties) {
            if (property.isRequired) {
                gen.writeString(property.name);
            }
        }
        gen.writeEndArray();
        gen.writeEndObject();

        gen.writeEndObject();
        return gen.getAsString();
    }
}
