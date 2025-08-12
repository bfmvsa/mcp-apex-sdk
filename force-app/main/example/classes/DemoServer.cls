/**
 * https://{instance_url}/services/apexrest/mcp (for instances WITHOUT namespace)
 * https://{instance_url}/services/apexrest/{namespace}/mcp (for instances WITH namespace)
 */
@RestResource(UrlMapping='/mcp/*')
global with sharing class DemoServer {
    @HttpPost
    global static void post() {
        ctx.Server server = new ctx.Server('1.0.0', 'DemoServer');
        server.registerTool(new DemoTool());
        server.registerResource(new DemoResource());
        server.registerPrompt(new DemoPrompt());
        server.run();
    }
}
