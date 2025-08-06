@IsTest
public class mcpExceptionTest {
    @IsTest
    static void testConstructorWithCode() {
        mcpException ex = new mcpException(mcpException.Code.PARSE_ERROR);

        System.assertEquals(-32700, ex.code);
        System.assertEquals('Parse error', ex.message);
        System.assertEquals(null, ex.data);
    }

    @IsTest
    static void testConstructorWithCodeAndMessage() {
        String customMessage = 'Custom error message';
        mcpException ex = new mcpException(mcpException.Code.INVALID_REQUEST, customMessage);

        System.assertEquals(-32600, ex.code);
        System.assertEquals(customMessage, ex.message);
        System.assertEquals(null, ex.data);
    }

    @IsTest
    static void testWithData() {
        Map<String, Object> testData = new Map<String, Object>{ 'key' => 'value' };
        mcpException ex = new mcpException(mcpException.Code.INTERNAL_ERROR).withData(testData);

        System.assertEquals(-32603, ex.code);
        System.assertEquals('Internal error', ex.message);
        System.assertEquals(testData, ex.data);
    }

    @IsTest
    static void testAllErrorCodes() {
        System.assertEquals(-32700, mcpException.errorCodes.get(mcpException.Code.PARSE_ERROR));
        System.assertEquals(-32600, mcpException.errorCodes.get(mcpException.Code.INVALID_REQUEST));
        System.assertEquals(-32601, mcpException.errorCodes.get(mcpException.Code.METHOD_NOT_FOUND));
        System.assertEquals(-32602, mcpException.errorCodes.get(mcpException.Code.INVALID_PARAMS));
        System.assertEquals(-32603, mcpException.errorCodes.get(mcpException.Code.INTERNAL_ERROR));
        System.assertEquals(-32002, mcpException.errorCodes.get(mcpException.Code.RESOURCE_NOT_FOUND));
    }

    @IsTest
    static void testAllErrorMessages() {
        System.assertEquals('Parse error', mcpException.errorMessages.get(mcpException.Code.PARSE_ERROR));
        System.assertEquals('Invalid Request', mcpException.errorMessages.get(mcpException.Code.INVALID_REQUEST));
        System.assertEquals('Method not found', mcpException.errorMessages.get(mcpException.Code.METHOD_NOT_FOUND));
        System.assertEquals('Invalid params', mcpException.errorMessages.get(mcpException.Code.INVALID_PARAMS));
        System.assertEquals('Internal error', mcpException.errorMessages.get(mcpException.Code.INTERNAL_ERROR));
        System.assertEquals('Resource not found', mcpException.errorMessages.get(mcpException.Code.RESOURCE_NOT_FOUND));
    }

    @IsTest
    static void testExceptionInheritance() {
        mcpException ex = new mcpException(mcpException.Code.PARSE_ERROR);
        System.assert(ex.code == mcpException.errorCodes.get(mcpException.Code.PARSE_ERROR));
    }

    @IsTest
    static void testChainedWithData() {
        Map<String, Object> data1 = new Map<String, Object>{ 'first' => 'data' };
        Map<String, Object> data2 = new Map<String, Object>{ 'second' => 'data' };

        mcpException ex = new mcpException(mcpException.Code.RESOURCE_NOT_FOUND).withData(data1).withData(data2);

        System.assertEquals(data2, ex.data);
    }
}
