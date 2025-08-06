@IsTest
public class RequestTest {
    @IsTest
    static void testConstructorWithValidJson() {
        Map<String, Object> testData = new Map<String, Object>{
            'id' => '123',
            'method' => 'test_method',
            'params' => new Map<String, Object>{ 'param1' => 'value1', 'param2' => 'value2' }
        };
        String jsonBody = JSON.serialize(testData);

        RestRequest mockRequest = new RestRequest();
        mockRequest.requestBody = Blob.valueOf(jsonBody);

        Request request = new Request(mockRequest);

        System.assertEquals('123', request.id);
        System.assertEquals('test_method', request.method);
        System.assertNotEquals(null, request.params);
        System.assertEquals('value1', request.params.get('param1'));
        System.assertEquals('value2', request.params.get('param2'));
    }

    @IsTest
    static void testConstructorWithNullParams() {
        Map<String, Object> testData = new Map<String, Object>{
            'id' => '456',
            'method' => 'another_method',
            'params' => null
        };
        String jsonBody = JSON.serialize(testData);

        RestRequest mockRequest = new RestRequest();
        mockRequest.requestBody = Blob.valueOf(jsonBody);

        Request request = new Request(mockRequest);

        System.assertEquals('456', request.id);
        System.assertEquals('another_method', request.method);
        System.assertEquals(null, request.params);
    }

    @IsTest
    static void testConstructorWithEmptyParams() {
        Map<String, Object> testData = new Map<String, Object>{
            'id' => '789',
            'method' => 'empty_params_method',
            'params' => new Map<String, Object>()
        };
        String jsonBody = JSON.serialize(testData);

        RestRequest mockRequest = new RestRequest();
        mockRequest.requestBody = Blob.valueOf(jsonBody);

        Request request = new Request(mockRequest);

        System.assertEquals('789', request.id);
        System.assertEquals('empty_params_method', request.method);
        System.assertNotEquals(null, request.params);
        System.assertEquals(0, request.params.size());
    }

    @IsTest
    static void testConstructorWithIntegerId() {
        Map<String, Object> testData = new Map<String, Object>{
            'id' => 999,
            'method' => 'integer_id_method',
            'params' => new Map<String, Object>{ 'test' => 'data' }
        };
        String jsonBody = JSON.serialize(testData);

        RestRequest mockRequest = new RestRequest();
        mockRequest.requestBody = Blob.valueOf(jsonBody);

        Request request = new Request(mockRequest);

        System.assertEquals('999', request.id);
        System.assertEquals('integer_id_method', request.method);
        System.assertNotEquals(null, request.params);
    }

    @IsTest
    static void testConstructorWithComplexParams() {
        Map<String, Object> complexParams = new Map<String, Object>{
            'stringParam' => 'test',
            'numberParam' => 42,
            'booleanParam' => true,
            'arrayParam' => new List<String>{ 'item1', 'item2' },
            'objectParam' => new Map<String, Object>{ 'nested' => 'value' }
        };

        Map<String, Object> testData = new Map<String, Object>{
            'id' => 'complex',
            'method' => 'complex_method',
            'params' => complexParams
        };
        String jsonBody = JSON.serialize(testData);

        RestRequest mockRequest = new RestRequest();
        mockRequest.requestBody = Blob.valueOf(jsonBody);

        Request request = new Request(mockRequest);

        System.assertEquals('complex', request.id);
        System.assertEquals('complex_method', request.method);
        System.assertNotEquals(null, request.params);
        System.assertEquals('test', request.params.get('stringParam'));
        System.assertEquals(42, request.params.get('numberParam'));
        System.assertEquals(true, request.params.get('booleanParam'));
    }
}
