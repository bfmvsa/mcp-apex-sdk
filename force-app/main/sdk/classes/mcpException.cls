public with sharing class mcpException extends Exception {
    public enum Code {
        PARSE_ERROR,
        INVALID_REQUEST,
        METHOD_NOT_FOUND,
        INVALID_PARAMS,
        INTERNAL_ERROR,
        RESOURCE_NOT_FOUND
    }

    public static final Map<Code, Integer> errorCodes = new Map<Code, Integer>{
        Code.PARSE_ERROR => -32700,
        Code.INVALID_REQUEST => -32600,
        Code.METHOD_NOT_FOUND => -32601,
        Code.INVALID_PARAMS => -32602,
        Code.INTERNAL_ERROR => -32603,
        Code.RESOURCE_NOT_FOUND => -32002
    };

    public static final Map<Code, String> errorMessages = new Map<Code, String>{
        Code.PARSE_ERROR => 'Parse error',
        Code.INVALID_REQUEST => 'Invalid Request',
        Code.METHOD_NOT_FOUND => 'Method not found',
        Code.INVALID_PARAMS => 'Invalid params',
        Code.INTERNAL_ERROR => 'Internal error',
        Code.RESOURCE_NOT_FOUND => 'Resource not found'
    };

    public final Integer code;
    public final String message;
    public Object data;

    public mcpException(Code code) {
        this.code = errorCodes.get(code);
        this.message = errorMessages.get(code);
        this.setMessage(message);
    }

    public mcpException(Code code, String message) {
        this.code = errorCodes.get(code);
        this.message = message;
        this.setMessage(message);
    }

    public mcpException withData(Object data) {
        this.data = data;
        return this;
    }
}
