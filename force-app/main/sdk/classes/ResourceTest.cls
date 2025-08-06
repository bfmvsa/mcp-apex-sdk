@IsTest
public class ResourceTest {
    private class TestResource extends Resource {
        private List<Content> testContents;

        public TestResource(String uri, String name) {
            super(uri, name);
            this.testContents = new List<Content>();
        }

        public TestResource(String uri, String name, String title, String description, String mimeType) {
            super(uri, name, title, description, mimeType, 1024);
            this.testContents = new List<Content>();
        }

        public override List<Content> read() {
            return this.testContents;
        }

        public void addTestContent(Content content) {
            this.testContents.add(content);
        }
    }

    @IsTest
    static void testConstructorWithUriAndName() {
        TestResource resource = new TestResource('test://uri', 'TestResource');

        System.assertEquals('test://uri', resource.getUri());
        System.assertEquals(false, resource.isTemplate());
    }

    @IsTest
    static void testConstructorWithAllFields() {
        TestResource resource = new TestResource(
            'test://uri',
            'TestResource',
            'Test Title',
            'Test Description',
            'text/plain'
        );

        System.assertEquals('test://uri', resource.getUri());
        System.assertEquals(false, resource.isTemplate());
    }

    @IsTest
    static void testSetAndGetUri() {
        TestResource resource = new TestResource('original://uri', 'TestResource');

        resource.setUri('new://uri');
        System.assertEquals('new://uri', resource.getUri());
    }

    @IsTest
    static void testIsTemplate() {
        TestResource nonTemplate = new TestResource('test://static/uri', 'NonTemplate');
        TestResource template = new TestResource('test://uri/{id}/details', 'Template');

        System.assertEquals(false, nonTemplate.isTemplate());
        System.assertEquals(true, template.isTemplate());
    }

    @IsTest
    static void testMatchesTemplate() {
        TestResource template = new TestResource('test://api/{version}/users/{id}', 'UserTemplate');

        System.assertEquals(true, template.matchesTemplate('test://api/v1/users/123'));
        System.assertEquals(true, template.matchesTemplate('test://api/v2/users/456'));
        System.assertEquals(false, template.matchesTemplate('test://api/v1/posts/123'));
        System.assertEquals(false, template.matchesTemplate('test://api/v1/users'));
        System.assertEquals(false, template.matchesTemplate('test://api/v1/users/123/details'));
    }

    @IsTest
    static void testMatchesTemplateWithNullValues() {
        TestResource resource = new TestResource(null, 'TestResource');

        System.assertEquals(false, resource.matchesTemplate('test://uri'));
        System.assertEquals(false, resource.matchesTemplate(null));

        resource.setUri('test://uri');
        System.assertEquals(false, resource.matchesTemplate(null));
    }

    @IsTest
    static void testMatchesTemplateExactMatch() {
        TestResource resource = new TestResource('test://static/uri', 'StaticResource');

        System.assertEquals(true, resource.matchesTemplate('test://static/uri'));
        System.assertEquals(false, resource.matchesTemplate('test://static/different'));
    }

    @IsTest
    static void testContentClass() {
        Resource.Content content = new Resource.Content('test://uri', 'TestContent', 'Test Title', 'Test content text');

        String json = content.toJson();
        System.assert(json.contains('test://uri'));
        System.assert(json.contains('TestContent'));
        System.assert(json.contains('Test Title'));
        System.assert(json.contains('Test content text'));
    }

    @IsTest
    static void testContentWithBlob() {
        Resource.Content content = new Resource.Content('test://uri', 'BlobContent');

        content.setBlobData('base64encodeddata');

        String json = content.toJson();
        System.assert(json.contains('base64encodeddata'));
        System.assert(json.contains('blob'));
    }

    @IsTest
    static void testAnnotationsClass() {
        List<String> audience = new List<String>{ 'user', 'assistant' };
        Datetime lastModified = Datetime.now();

        Resource.Annotations annotations = new Resource.Annotations(audience, 0.8, lastModified);

        System.assertNotEquals(null, annotations);
    }

    @IsTest
    static void testSetAnnotations() {
        TestResource resource = new TestResource('test://uri', 'TestResource');
        List<String> audience = new List<String>{ 'user' };

        Resource.Annotations annotations = new Resource.Annotations(audience, 0.5, Datetime.now());

        resource.setAnnotations(annotations);
        // No getter for annotations, but we can test JSON output
        String json = resource.toJson();
        System.assert(json.contains('annotations'));
    }

    @IsTest
    static void testToJsonBasic() {
        TestResource resource = new TestResource('test://uri', 'TestResource');

        String json = resource.toJson();
        System.assert(json.contains('test://uri'));
        System.assert(json.contains('TestResource'));
        System.assert(json.contains('uri'));
        System.assert(!json.contains('uriTemplate'));
    }

    @IsTest
    static void testToJsonTemplate() {
        TestResource resource = new TestResource('test://uri/{id}', 'TemplateResource');

        String json = resource.toJson();
        System.assert(json.contains('test://uri/{id}'));
        System.assert(json.contains('uriTemplate'));
        System.assert(!json.contains('"uri"'));
    }

    @IsTest
    static void testToJsonWithAllFields() {
        TestResource resource = new TestResource(
            'test://uri',
            'FullResource',
            'Full Title',
            'Full Description',
            'application/json'
        );

        List<String> audience = new List<String>{ 'user', 'assistant' };
        Resource.Annotations annotations = new Resource.Annotations(audience, 0.9, Datetime.now());
        resource.setAnnotations(annotations);

        String json = resource.toJson();
        System.assert(json.contains('FullResource'));
        System.assert(json.contains('Full Title'));
        System.assert(json.contains('Full Description'));
        System.assert(json.contains('application/json'));
        System.assert(json.contains('annotations'));
        System.assert(json.contains('audience'));
        System.assert(json.contains('priority'));
    }

    @IsTest
    static void testRead() {
        TestResource resource = new TestResource('test://uri', 'TestResource');
        Resource.Content content = new Resource.Content('test://uri', 'content', 'title', 'test text');
        resource.addTestContent(content);

        List<Resource.Content> result = resource.read();
        System.assertEquals(1, result.size());
        System.assertEquals(content, result[0]);
    }
}
