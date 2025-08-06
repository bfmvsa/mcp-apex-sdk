public with sharing class Response {
    public class Error {
        private final Integer code;
        private final String message;
        private final Object data;

        public Error(Integer code, String message) {
            this.code = code;
            this.message = message;
        }

        public Error(mcpException e) {
            this.code = e.code;
            this.message = e.message;
            this.data = e.data;
        }

        public Error(mcpException.Code code, String message) {
            this.code = mcpException.errorCodes.get(code);
            this.message = message;
        }

        public String toJson() {
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeNumberField('code', code);
            gen.writeStringField('message', message);
            if (this.data != null) {
                gen.writeFieldName('data');
                gen.writeObject(this.data);
            }
            gen.writeEndObject();
            return gen.getAsString();
        }
    }

    final public static String VERSION = '2.0';
    public Integer id;
    public String result;
    public Error error;

    public Response(Integer id) {
        this.id = id;
    }

    public Response(Integer id, String result) {
        this.id = id;
        this.result = result;
    }

    public Response(Integer id, Error error) {
        this.id = id;
        this.error = error;
    }

    public String toJson() {
        JSONGenerator gen = JSON.createGenerator(true);

        gen.writeStartObject();
        gen.writeStringField('jsonrpc', VERSION);
        gen.writeNumberField('id', id);

        if (this.error != null) {
            gen.writeFieldName('error');
            gen.writeObject(JSON.deserializeUntyped(this.error.toJson()));
        } else {
            gen.writeFieldName('result');
            gen.writeObject(JSON.deserializeUntyped(this.result));
        }

        gen.writeEndObject();

        return gen.getAsString();
    }
}
