public with sharing class Request {
    public String id;
    public String method;
    public Map<String, Object> params;

    public Request(RestRequest request) {
        Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(request.requestBody.toString());
        try {
            this.id = requestMap.get('id')?.toString();
            this.method = requestMap.get('method').toString();
            this.params = (Map<String, Object>) requestMap.get('params');
        } catch (Exception e) {
            throw new mcpException(mcpException.Code.INVALID_PARAMS);
        }
    }
}
