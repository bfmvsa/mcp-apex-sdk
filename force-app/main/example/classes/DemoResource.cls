/**
 * Resources in MCP are designed to be application-driven, with host applications determining how to incorporate context based on their needs.
 * https://modelcontextprotocol.io/specification/2025-06-18/server/resources
 */
public with sharing class DemoResource extends ctx.Resource {
    public static final String uri = '@server://demo';
    public static final String resourceName = 'demo-resource';

    public DemoResource() {
        super(uri, resourceName);
    }

    public override List<ctx.Resource.Content> read() {
        return new List<ctx.Resource.Content>{ new ctx.Resource.Content(uri, 'demo', 'Demo Content', 'demo content') };
    }
}
