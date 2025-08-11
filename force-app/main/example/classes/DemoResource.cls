public with sharing class DemoResource extends Resource {
    public DemoResource() {
        super('@server://demo', 'demo-resource');
    }

    public override List<Content> read() {
        return new List<Content>{ new Content(this.uri, 'demo', 'Demo Content', 'demo content') };
    }
}
