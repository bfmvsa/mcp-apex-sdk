@IsTest
public class ResponseTest {
    @IsTest
    static void testErrorConstructorWithCodeAndMessage() {
        Response.Error error = new Response.Error(-32700, 'Parse error');

        String payload = error.toJson();
        System.assert(payload.contains('-32700'));
        System.assert(payload.contains('Parse error'));
        System.assert(!payload.contains('data'));
    }

    @IsTest
    static void testErrorConstructorWithException() {
        mcpException ex = new mcpException(mcpException.Code.INVALID_REQUEST);
        Response.Error error = new Response.Error(ex);

        String payload = error.toJson();
        System.assert(payload.contains('-32600'));
        System.assert(payload.contains('Invalid Request'));
    }

    @IsTest
    static void testErrorConstructorWithExceptionCode() {
        Response.Error error = new Response.Error(mcpException.Code.METHOD_NOT_FOUND, 'Custom message');

        String payload = error.toJson();
        System.assert(payload.contains('-32601'));
        System.assert(payload.contains('Custom message'));
    }

    @IsTest
    static void testErrorWithData() {
        mcpException ex = new mcpException(mcpException.Code.RESOURCE_NOT_FOUND)
            .withData(new Map<String, Object>{ 'uri' => 'test://resource' });
        Response.Error error = new Response.Error(ex);

        String payload = error.toJson();
        System.assert(payload.contains('data'));
        System.assert(payload.contains('test://resource'));
    }

    @IsTest
    static void testResponseConstructorWithId() {
        Response response = new Response(123);

        System.assertEquals(123, response.id);
        System.assertEquals(null, response.result);
        System.assertEquals(null, response.error);
    }

    @IsTest
    static void testResponseConstructorWithIdAndResult() {
        String testResult = '{"status": "success"}';
        Response response = new Response(456, testResult);

        System.assertEquals(456, response.id);
        System.assertEquals(testResult, response.result);
        System.assertEquals(null, response.error);
    }

    @IsTest
    static void testResponseConstructorWithIdAndError() {
        Response.Error error = new Response.Error(-32000, 'Test error');
        Response response = new Response(789, error);

        System.assertEquals(789, response.id);
        System.assertEquals(null, response.result);
        System.assertEquals(error, response.error);
    }

    @IsTest
    static void testResponseToJsonWithResult() {
        String testResult = '{"data": "test"}';
        Response response = new Response(100, testResult);

        String payload = response.toJson();
        System.assert(payload.contains('2.0'));
        System.assert(payload.contains('100'));
        System.assert(payload.contains('result'));
        System.assert(payload.contains('test'));
        System.assert(!payload.contains('error'));
    }

    @IsTest
    static void testResponseToJsonWithError() {
        Response.Error error = new Response.Error(-32603, 'Internal error');
        Response response = new Response(200, error);

        String payload = response.toJson();
        System.assert(payload.contains('2.0'));
        System.assert(payload.contains('200'));
        System.assert(payload.contains('error'));
        System.assert(payload.contains('-32603'));
        System.assert(payload.contains('Internal error'));
        System.assert(!payload.contains('result'));
    }

    @IsTest
    static void testResponseVersionConstant() {
        System.assertEquals('2.0', Response.VERSION);
    }

    @IsTest
    static void testResponseWithComplexResult() {
        Map<String, Object> complexResult = new Map<String, Object>{
            'success' => true,
            'data' => new List<String>{ 'item1', 'item2' },
            'count' => 2
        };
        String jsonResult = JSON.serialize(complexResult);

        Response response = new Response(300, jsonResult);
        String payload = response.toJson();

        System.assert(payload.contains('success'));
        System.assert(payload.contains('item1'));
        System.assert(payload.contains('count'));
    }

    @IsTest
    static void testErrorToJsonWithNullData() {
        Response.Error error = new Response.Error(-32700, 'Parse error');
        String payload = error.toJson();

        Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(payload);
        System.assertEquals(-32700, parsed.get('code'));
        System.assertEquals('Parse error', parsed.get('message'));
        System.assertEquals(false, parsed.containsKey('data'));
    }

    @IsTest
    static void testResponseJsonStructure() {
        Response response = new Response(999, '{"test": "value"}');
        String payload = response.toJson();

        Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(payload);
        System.assertEquals('2.0', parsed.get('jsonrpc'));
        System.assertEquals(999, parsed.get('id'));
        System.assertEquals(true, parsed.containsKey('result'));
        System.assertEquals(false, parsed.containsKey('error'));
    }

    @IsTest
    static void testResponseWithNegativeId() {
        Response response = new Response(-1, '{"status": "error"}');
        String json = response.toJson();

        System.assert(json.contains('-1'));
        System.assert(json.contains('status'));
    }
}
