@IsTest
public class MethodTest {
    private class TestTool extends Tool {
        public TestTool(String name, String title, String description) {
            super(name, title, description);
        }

        public override String call(Map<String, Object> input) {
            if (input != null && input.containsKey('throw_error')) {
                throw new CalloutException('Tool error');
            }
            return 'tool result';
        }
    }

    private class TestResource extends Resource {
        public TestResource(String uri, String name) {
            super(uri, name);
        }

        public override List<Content> read() {
            return new List<Content>{ new Content(this.uri, 'test', 'Test Content', 'test content') };
        }
    }

    private class TestPrompt extends Prompt {
        public TestPrompt(String name) {
            super(name);
        }

        public override List<Message> get(Map<String, Object> input) {
            List<Message> messages = new List<Message>();
            messages.add(new Message('user', 'Test prompt message'));
            return messages;
        }
    }

    private static Server createTestServer() {
        Server server = new Server('1.0.0', 'TestServer', 'Test Title', 'Test Instructions');

        TestTool tool = new TestTool('test_tool', 'Test Tool', 'A test tool');
        server.registerTool(tool);

        TestResource resource = new TestResource('test://resource', 'TestResource');
        TestResource templateResource = new TestResource('test://template/{id}', 'TemplateResource');
        server.registerResource(resource);
        server.registerResource(templateResource);

        TestPrompt prompt = new TestPrompt('test_prompt');
        server.registerPrompt(prompt);

        return server;
    }

    private static Request createRequest(String id, String method, Map<String, Object> params) {
        Map<String, Object> requestData = new Map<String, Object>{ 'id' => id, 'method' => method, 'params' => params };

        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(JSON.serialize(requestData));

        return new Request(req);
    }

    @IsTest
    static void testConstructor() {
        Server server = createTestServer();
        Request request = createRequest('1', 'initialize', new Map<String, Object>());

        Method method = new Method(server, request);

        System.assertNotEquals(null, method);
    }

    @IsTest
    static void testInitialize() {
        Server server = createTestServer();
        Request request = createRequest('1', 'initialize', new Map<String, Object>());
        Method method = new Method(server, request);

        String result = method.initialize();

        System.assert(result.contains('protocolVersion'));
        System.assert(result.contains('2025-06-18'));
        System.assert(result.contains('TestServer'));
        System.assert(result.contains('Test Title'));
        System.assert(result.contains('Test Instructions'));
        System.assert(result.contains('serverInfo'));
        System.assert(result.contains('capabilities'));
        System.assert(result.contains('resources'));
        System.assert(result.contains('tools'));
    }

    @IsTest
    static void testInitializeWithoutOptionalFields() {
        Server server = new Server('1.0.0', 'BasicServer');
        Request request = createRequest('1', 'initialize', new Map<String, Object>());
        Method method = new Method(server, request);

        String result = method.initialize();

        System.assert(result.contains('BasicServer'));
        System.assert(!result.contains('instructions'));
        System.assert(!result.contains('title'));
    }

    @IsTest
    static void testResourcesListWithTemplates() {
        Server server = createTestServer();
        Request request = createRequest('2', 'resources/templates/list', new Map<String, Object>());
        Method method = new Method(server, request);

        String result = method.resourcesList(true);

        System.assert(result.contains('resourceTemplates'));
        System.assert(result.contains('TemplateResource'));
        System.assert(!result.contains('TestResource'));
    }

    @IsTest
    static void testResourcesListWithoutTemplates() {
        Server server = createTestServer();
        Request request = createRequest('3', 'resources/list', new Map<String, Object>());
        Method method = new Method(server, request);

        String result = method.resourcesList(false);

        System.assert(result.contains('resources'));
        System.assert(result.contains('TestResource'));
        System.assert(!result.contains('TemplateResource'));
    }

    @IsTest
    static void testResourcesRead() {
        Server server = createTestServer();
        Map<String, Object> params = new Map<String, Object>{ 'uri' => 'test://resource' };
        Request request = createRequest('4', 'resources/read', params);
        Method method = new Method(server, request);

        String result = method.resourcesRead();

        System.assert(result.contains('contents'));
        System.assert(result.contains('test content'));
    }

    @IsTest
    static void testResourcesReadWithTemplate() {
        Server server = createTestServer();
        Map<String, Object> params = new Map<String, Object>{ 'uri' => 'test://template/123' };
        Request request = createRequest('5', 'resources/read', params);
        Method method = new Method(server, request);

        String result = method.resourcesRead();

        System.assert(result.contains('contents'));
    }

    @IsTest
    static void testResourcesReadNotFound() {
        Server server = createTestServer();
        Map<String, Object> params = new Map<String, Object>{ 'uri' => 'test://nonexistent' };
        Request request = createRequest('6', 'resources/read', params);
        Method method = new Method(server, request);

        try {
            method.resourcesRead();
            System.assert(false, 'Expected mException was not thrown');
        } catch (mcpException e) {
            System.assertEquals(mcpException.errorCodes.get(mcpException.Code.RESOURCE_NOT_FOUND), e.code);
            System.assertNotEquals(null, e.data);
        }
    }

    @IsTest
    static void testToolsList() {
        Server server = createTestServer();
        Request request = createRequest('7', 'tools/list', new Map<String, Object>());
        Method method = new Method(server, request);

        String result = method.toolsList();

        System.assert(result.contains('tools'));
        System.assert(result.contains('test_tool'));
        System.assert(result.contains('Test Tool'));
    }

    @IsTest
    static void testToolsCall() {
        Server server = createTestServer();
        Map<String, Object> params = new Map<String, Object>{
            'name' => 'test_tool',
            'arguments' => new Map<String, Object>()
        };
        Request request = createRequest('8', 'tools/call', params);
        Method method = new Method(server, request);

        String result = method.toolsCall();

        System.assert(result.contains('content'));
        System.assert(result.contains('tool result'));
        System.assert(result.contains('isError'));
        System.assert(result.contains('false'));
    }

    @IsTest
    static void testToolsCallWithError() {
        Server server = createTestServer();
        Map<String, Object> params = new Map<String, Object>{
            'name' => 'test_tool',
            'arguments' => new Map<String, Object>{ 'throw_error' => true }
        };
        Request request = createRequest('9', 'tools/call', params);
        Method method = new Method(server, request);

        String result = method.toolsCall();

        System.assert(result.contains('content'));
        System.assert(result.contains('Tool error'));
        System.assert(result.contains('isError'));
        System.assert(result.contains('true'));
    }

    @IsTest
    static void testToolsCallNonexistentTool() {
        Server server = createTestServer();
        Map<String, Object> params = new Map<String, Object>{
            'name' => 'nonexistent_tool',
            'arguments' => new Map<String, Object>()
        };
        Request request = createRequest('10', 'tools/call', params);
        Method method = new Method(server, request);

        String result = method.toolsCall();

        System.assert(result.contains('content'));
        System.assert(result.contains('text'));
        System.assert(result.contains('isError'));
    }

    @IsTest
    static void testPromptsList() {
        Server server = createTestServer();
        Request request = createRequest('11', 'prompts/list', new Map<String, Object>());
        Method method = new Method(server, request);

        String result = method.promptsList();

        System.assert(result.contains('prompts'));
    }

    @IsTest
    static void testPromptsGet() {
        Server server = createTestServer();
        Map<String, Object> params = new Map<String, Object>{
            'name' => 'test_prompt',
            'arguments' => new Map<String, Object>()
        };
        Request request = createRequest('12', 'prompts/get', params);
        Method method = new Method(server, request);

        String result = method.promptsGet();

        System.assert(result.contains('messages'));
    }

    @IsTest
    static void testCapabilitiesWithEmptyLists() {
        Server server = new Server('1.0.0', 'EmptyServer');
        Request request = createRequest('11', 'initialize', new Map<String, Object>());
        Method method = new Method(server, request);

        String result = method.initialize();

        System.assert(result.contains('capabilities'));
        System.assert(!result.contains('listChanged'));
    }

    @IsTest
    static void testResponseIdConsistency() {
        Server server = createTestServer();
        Request request = createRequest('42', 'initialize', new Map<String, Object>());
        Method method = new Method(server, request);

        String result = method.initialize();

        System.assert(result.contains('42'));
    }

    @IsTest
    static void testPing() {
        Server server = createTestServer();
        Request request = createRequest('12', 'ping', new Map<String, Object>());
        Method method = new Method(server, request);

        String result = method.ping();

        System.assert(result.contains('12'));
    }
}
