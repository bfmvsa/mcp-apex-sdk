@IsTest
public class ServerTest {
    private class TestTool extends Tool {
        public TestTool(String name, String title, String description) {
            super(name, title, description);
        }

        public override String call(Map<String, Object> input) {
            return 'test result';
        }
    }

    private class TestResource extends Resource {
        public TestResource(String uri, String name) {
            super(uri, name);
        }

        public override List<Content> read() {
            return new List<Content>{ new Content('test://uri', 'test', 'Test', 'content') };
        }
    }

    @IsTest
    static void testConstructorWithVersionAndName() {
        Server server = new Server('1.0.0', 'TestServer');

        System.assertEquals('1.0.0', server.version);
        System.assertEquals('TestServer', server.name);
        System.assertEquals(null, server.title);
        System.assertEquals(null, server.instructions);
    }

    @IsTest
    static void testConstructorWithTitle() {
        Server server = new Server('1.0.0', 'TestServer');

        System.assertEquals('1.0.0', server.version);
        System.assertEquals('TestServer', server.name);
        System.assertEquals(null, server.instructions);
    }

    @IsTest
    static void testConstructorWithAllParameters() {
        Server server = new Server('1.0.0', 'TestServer', 'Test Title', 'Test Instructions');

        System.assertEquals('1.0.0', server.version);
        System.assertEquals('TestServer', server.name);
        System.assertEquals('Test Title', server.title);
        System.assertEquals('Test Instructions', server.instructions);
    }

    @IsTest
    static void testProtocolVersionConstant() {
        System.assertEquals('2025-06-18', Server.protocolVersion);
    }

    @IsTest
    static void testRegisterAndGetTool() {
        Server server = new Server('1.0.0', 'TestServer');
        TestTool tool = new TestTool('test_tool', 'Test Tool', 'A test tool');

        server.registerTool(tool);
        List<Tool> tools = server.getTools();

        System.assertEquals(1, tools.size());
        System.assertEquals(tool, tools[0]);
    }

    @IsTest
    static void testRegisterMultipleTools() {
        Server server = new Server('1.0.0', 'TestServer');
        TestTool tool1 = new TestTool('tool1', 'Tool 1', 'First tool');
        TestTool tool2 = new TestTool('tool2', 'Tool 2', 'Second tool');

        server.registerTool(tool1);
        server.registerTool(tool2);
        List<Tool> tools = server.getTools();

        System.assertEquals(2, tools.size());
    }

    @IsTest
    static void testRegisterAndGetResource() {
        Server server = new Server('1.0.0', 'TestServer');
        TestResource resource = new TestResource('test://resource', 'TestResource');

        server.registerResource(resource);
        List<Resource> resources = server.getResources();

        System.assertEquals(1, resources.size());
        System.assertEquals(resource, resources[0]);
    }

    @IsTest
    static void testRegisterMultipleResources() {
        Server server = new Server('1.0.0', 'TestServer');
        TestResource resource1 = new TestResource('test://resource1', 'Resource1');
        TestResource resource2 = new TestResource('test://resource2', 'Resource2');

        server.registerResource(resource1);
        server.registerResource(resource2);
        List<Resource> resources = server.getResources();

        System.assertEquals(2, resources.size());
    }

    @IsTest
    static void testRunWithInitializeRequest() {
        Server server = new Server('1.0.0', 'TestServer', 'Test Title', 'Test Instructions');

        Map<String, Object> requestData = new Map<String, Object>{
            'id' => '1',
            'method' => 'initialize',
            'params' => new Map<String, Object>()
        };

        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(JSON.serialize(requestData));

        RestResponse res = new RestResponse();

        RestContext.request = req;
        RestContext.response = res;

        server.run();

        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('protocolVersion'));
        System.assert(responseBody.contains('2025-06-18'));
        System.assert(responseBody.contains('TestServer'));
        System.assert(responseBody.contains('Test Instructions'));
    }

    @IsTest
    static void testRunWithToolsListRequest() {
        Server server = new Server('1.0.0', 'TestServer');
        TestTool tool = new TestTool('test_tool', 'Test Tool', 'A test tool');
        server.registerTool(tool);

        Map<String, Object> requestData = new Map<String, Object>{
            'id' => '2',
            'method' => 'tools/list',
            'params' => new Map<String, Object>()
        };

        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(JSON.serialize(requestData));

        RestResponse res = new RestResponse();

        RestContext.request = req;
        RestContext.response = res;

        server.run();

        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('tools'));
        System.assert(responseBody.contains('test_tool'));
    }

    @IsTest
    static void testRunWithResourcesListRequest() {
        Server server = new Server('1.0.0', 'TestServer');
        TestResource resource = new TestResource('test://resource', 'TestResource');
        server.registerResource(resource);

        Map<String, Object> requestData = new Map<String, Object>{
            'id' => '3',
            'method' => 'resources/list',
            'params' => new Map<String, Object>()
        };

        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(JSON.serialize(requestData));

        RestResponse res = new RestResponse();

        RestContext.request = req;
        RestContext.response = res;

        server.run();

        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('resources'));
        System.assert(responseBody.contains('TestResource'));
    }

    @IsTest
    static void testRunWithResourcesReadRequest() {
        Server server = new Server('1.0.0', 'TestServer');
        TestResource resource = new TestResource('test://resource', 'TestResource');
        server.registerResource(resource);

        Map<String, Object> requestData = new Map<String, Object>{
            'id' => '4',
            'method' => 'resources/read',
            'params' => new Map<String, Object>{ 'uri' => 'test://resource' }
        };

        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(JSON.serialize(requestData));

        RestResponse res = new RestResponse();

        RestContext.request = req;
        RestContext.response = res;

        server.run();

        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('contents'));
        System.assert(responseBody.contains('content'));
    }

    @IsTest
    static void testRunWithToolsCallRequest() {
        Server server = new Server('1.0.0', 'TestServer');
        TestTool tool = new TestTool('test_tool', 'Test Tool', 'A test tool');
        server.registerTool(tool);

        Map<String, Object> requestData = new Map<String, Object>{
            'id' => '5',
            'method' => 'tools/call',
            'params' => new Map<String, Object>{ 'name' => 'test_tool', 'arguments' => new Map<String, Object>() }
        };

        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(JSON.serialize(requestData));

        RestResponse res = new RestResponse();

        RestContext.request = req;
        RestContext.response = res;

        server.run();

        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('content'));
        System.assert(responseBody.contains('test result'));
    }

    @IsTest
    static void testRunWithInvalidMethod() {
        Server server = new Server('1.0.0', 'TestServer');

        Map<String, Object> requestData = new Map<String, Object>{
            'id' => '6',
            'method' => 'invalid/method',
            'params' => new Map<String, Object>()
        };

        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(JSON.serialize(requestData));

        RestResponse res = new RestResponse();

        RestContext.request = req;
        RestContext.response = res;

        server.run();

        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('error'));
        System.assert(responseBody.contains('-32601'));
    }

    @IsTest
    static void testRunWithException() {
        Server server = new Server('1.0.0', 'TestServer');

        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf('invalid json');

        RestResponse res = new RestResponse();

        RestContext.request = req;
        RestContext.response = res;

        server.run();

        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('error'));
        System.assert(responseBody.contains('-32603'));
    }
}
