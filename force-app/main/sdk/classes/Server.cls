global with sharing class Server {
    public final static String protocolVersion = '2025-06-18';
    public final String version;
    public final String name;
    public String title; // Optional
    public String instructions; // Optional

    private final List<Tool> tools = new List<Tool>();
    private final List<Resource> resources = new List<Resource>();

    global Server(String version, String name) {
        this.version = version;
        this.name = name;
    }

    global Server(String version, String name, String title, String instructions) {
        this.version = version;
        this.name = name;
        this.title = title;
        this.instructions = instructions;
    }

    global Server setTitle(String title) {
        this.title = title;
        return this;
    }

    global Server setInstructions(String instructions) {
        this.instructions = instructions;
        return this;
    }

    global void registerTool(Tool tool) {
        this.tools.add(tool);
    }

    public List<Tool> getTools() {
        return this.tools;
    }

    global void registerResource(Resource resource) {
        this.resources.add(resource);
    }

    public List<Resource> getResources() {
        return this.resources;
    }

    global void run() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.headers.put('Content-Type', 'application/json');

        try {
            Method method = new Method(this, new Request(req));
            String result = method.execute();
            res.responseBody = Blob.valueOf(result);
        } catch (mcpException e) {
            // All exception thrown internally in the package
            Response.Error error = new Response.Error(e);
            res.responseBody = Blob.valueOf(new Response(-1, error).toJson());
        } catch (Exception e) {
            // All other exceptions
            Response.Error error = new Response.Error(mcpException.Code.INTERNAL_ERROR, e.getMessage());
            res.responseBody = Blob.valueOf(new Response(-1, error).toJson());
        }
    }
}
