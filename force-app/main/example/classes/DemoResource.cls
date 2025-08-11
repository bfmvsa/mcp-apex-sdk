/**
 * Resources in MCP are designed to be application-driven, with host applications determining how to incorporate context based on their needs.
 * https://modelcontextprotocol.io/specification/2025-06-18/server/resources
 */
public with sharing class DemoResource extends Resource {
    public DemoResource() {
        super('@server://demo', 'demo-resource');
    }

    public override List<Content> read() {
        return new List<Content>{ new Content(this.uri, 'demo', 'Demo Content', 'demo content') };
    }
}
