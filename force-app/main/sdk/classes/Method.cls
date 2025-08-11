public with sharing class Method {
    private final Server mcpServer;
    private final Request request;

    public Method(Server mcpServer, Request request) {
        this.mcpServer = mcpServer;
        this.request = request;
    }

    public String execute() {
        if (this.request.method == 'initialize') {
            return this.initialize();
        } else if (this.request.method == 'resources/templates/list') {
            return this.resourcesList(true);
        } else if (this.request.method == 'resources/list') {
            return this.resourcesList(false);
        } else if (this.request.method == 'resources/read') {
            return this.resourcesRead();
        } else if (this.request.method == 'tools/list') {
            return this.toolsList();
        } else if (this.request.method == 'tools/call') {
            return this.toolsCall();
        } else if (this.request.method == 'prompts/list') {
            return this.promptsList();
        } else if (this.request.method == 'prompts/get') {
            return this.promptsGet();
        }

        // TODO: Add list of unsupported methods, and do not throw exception

        throw new mcpException(mcpException.Code.METHOD_NOT_FOUND);
    }

    public String initialize() {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('protocolVersion', Server.protocolVersion);
        if (this.mcpServer.instructions != null) {
            gen.writeStringField('instructions', this.mcpServer.instructions);
        }

        // SERVER INFO
        gen.writeFieldName('serverInfo');
        gen.writeStartObject();
        gen.writeStringField('name', this.mcpServer.name);
        if (this.mcpServer.title != null) {
            gen.writeStringField('title', this.mcpServer.title);
        }
        gen.writeStringField('version', this.mcpServer.version);
        gen.writeEndObject();
        // END SERVER INFO

        // CAPABILITIES
        gen.writeFieldName('capabilities');
        gen.writeStartObject();
        if (!this.mcpServer.getResources().isEmpty()) {
            gen.writeFieldName('resources');
            gen.writeStartObject();
            gen.writeBooleanField('listChanged', true);
            gen.writeEndObject();
        }
        if (!this.mcpServer.getTools().isEmpty()) {
            gen.writeFieldName('tools');
            gen.writeStartObject();
            gen.writeBooleanField('listChanged', true);
            gen.writeEndObject();
        }
        if (!this.mcpServer.getPrompts().isEmpty()) {
            gen.writeFieldName('prompts');
            gen.writeStartObject();
            gen.writeBooleanField('listChanged', true);
            gen.writeEndObject();
        }
        gen.writeEndObject();
        // END CAPABILITIES

        gen.writeEndObject();

        return new Response(Integer.valueOf(this.request.id), gen.getAsString()).toJson();
    }

    public String resourcesList(Boolean retrieveTemplates) {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName(retrieveTemplates ? 'resourceTemplates' : 'resources');
        gen.writeStartArray();
        for (Resource resource : this.mcpServer.getResources()) {
            if (retrieveTemplates && resource.isTemplate()) {
                gen.writeObject(JSON.deserializeUntyped(resource.toJson()));
            } else if (!retrieveTemplates && !resource.isTemplate()) {
                gen.writeObject(JSON.deserializeUntyped(resource.toJson()));
            }
        }
        gen.writeEndArray();
        gen.writeEndObject();
        String result = gen.getAsString();

        return new Response(Integer.valueOf(request.id), result).toJson();
    }

    public String resourcesRead() {
        Map<String, Object> params = request.params;
        String resourceUri = (String) params.get('uri');

        List<Resource.Content> result = new List<Resource.Content>();
        Boolean found = false;
        for (Resource resource : this.mcpServer.getResources()) {
            try {
                if (resource.matchesTemplate(resourceUri)) {
                    resource.setUri(resourceUri);
                    result = resource.read();
                    found = true;
                    break;
                }
            } catch (Exception e) {
                throw new mcpException(mcpException.Code.INTERNAL_ERROR);
            }
        }

        if (!found) {
            throw new mcpException(mcpException.Code.RESOURCE_NOT_FOUND)
                .withData(new Map<String, Object>{ 'uri' => resourceUri });
        }

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();

        gen.writeFieldName('contents');
        gen.writeStartArray();
        for (Resource.Content content : result) {
            gen.writeObject(JSON.deserializeUntyped(content.toJson()));
        }
        gen.writeEndArray();
        gen.writeEndObject();

        return new Response(Integer.valueOf(this.request.id), gen.getAsString()).toJson();
    }

    public String toolsList() {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('tools');
        gen.writeStartArray();
        for (Tool tool : this.mcpServer.getTools()) {
            gen.writeObject(JSON.deserializeUntyped(tool.toJson()));
        }
        gen.writeEndArray();
        gen.writeEndObject();
        String result = gen.getAsString();

        return new Response(Integer.valueOf(request.id), result).toJson();
    }

    public String toolsCall() {
        Map<String, Object> params = request.params;
        String toolName = (String) params.get('name');
        Map<String, Object> arguments = (Map<String, Object>) params.get('arguments');

        String result = '';
        Boolean hasError = false;
        for (Tool tool : this.mcpServer.getTools()) {
            if (tool.getName() == toolName) {
                try {
                    result = tool.call(arguments);
                } catch (Exception e) {
                    result = e.getMessage();
                    hasError = true;
                }
            }
        }

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();

        gen.writeFieldName('content');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('type', 'text');
        gen.writeStringField('text', result);
        gen.writeEndObject();
        gen.writeEndArray();

        gen.writeBooleanField('isError', hasError);
        gen.writeEndObject();

        return new Response(Integer.valueOf(this.request.id), gen.getAsString()).toJson();
    }

    public String promptsList() {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();

        gen.writeFieldName('prompts');
        gen.writeStartArray();
        for (Prompt prompt : this.mcpServer.getPrompts()) {
            gen.writeObject(JSON.deserializeUntyped(prompt.toJson()));
        }
        gen.writeEndArray();
        gen.writeEndObject();

        return new Response(Integer.valueOf(this.request.id), gen.getAsString()).toJson();
    }

    public String promptsGet() {
        Map<String, Object> params = request.params;
        String promptName = (String) params.get('name');
        Map<String, Object> arguments = (Map<String, Object>) params.get('arguments');

        List<Prompt.Message> resultMessages = new List<Prompt.Message>();
        Boolean hasError = false;
        for (Prompt prompt : this.mcpServer.getPrompts()) {
            if (prompt.getName() == promptName) {
                try {
                    resultMessages = prompt.get(arguments);
                } catch (Exception e) {
                    hasError = true;
                }
            }
        }

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('description', 'desc');
        gen.writeFieldName('messages');
        gen.writeStartArray();
        for (Prompt.Message message : resultMessages) {
            gen.writeObject(JSON.deserializeUntyped(message.toJson()));
        }
        gen.writeEndArray();
        gen.writeEndObject();

        return new Response(Integer.valueOf(this.request.id), gen.getAsString()).toJson();
    }
}
