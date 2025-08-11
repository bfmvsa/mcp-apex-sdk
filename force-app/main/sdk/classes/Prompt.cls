abstract global with sharing class Prompt {
    global class Argument {
        private final String name;
        private final String description;
        private final Boolean required;

        global Argument(String name, String description, Boolean required) {
            this.name = name;
            this.description = description;
            this.required = required;
        }

        public String toJson() {
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('name', this.name);
            gen.writeStringField('description', this.description);
            gen.writeBooleanField('required', this.required);
            gen.writeEndObject();
            return gen.getAsString();
        }
    }

    global class Message {
        private final String role;
        private final String text;

        global Message(String role, String text) {
            this.role = role;
            this.text = text;
        }

        public String toJson() {
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('role', this.role);
            gen.writeFieldName('content');
            gen.writeStartObject();
            gen.writeStringField('type', 'text');
            gen.writeStringField('text', this.text);
            gen.writeEndObject();
            gen.writeEndObject();
            return gen.getAsString();
        }
    }

    public String name;
    public String title;
    public String description;
    public Set<Argument> arguments = new Set<Argument>();
    public List<Message> messages = new List<Message>();

    global Prompt(String name) {
        this.name = name;
    }

    global Prompt(String name, String title, String description) {
        this.name = name;
        this.title = title;
        this.description = description;
    }

    abstract global List<Message> get(Map<String, Object> input);

    public String getName() {
        return this.name;
    }

    global Prompt setTitle(String title) {
        this.title = title;
        return this;
    }

    global Prompt setDescription(String description) {
        this.description = description;
        return this;
    }

    global void addArgument(Argument argument) {
        this.arguments.add(argument);
    }

    public String toJson() {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('name', this.name);
        if (this.title != null) {
            gen.writeStringField('title', this.title);
        }
        if (this.description != null) {
            gen.writeStringField('description', this.description);
        }
        gen.writeFieldName('arguments');
        gen.writeStartArray();
        for (Argument argument : this.arguments) {
            gen.writeObject(JSON.deserializeUntyped(argument.toJson()));
        }
        gen.writeEndArray();
        gen.writeEndObject();
        return gen.getAsString();
    }
}
