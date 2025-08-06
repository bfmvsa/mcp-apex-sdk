@IsTest
public class ToolTest {
    private class TestTool extends Tool {
        private String returnValue;

        public TestTool(String name, String title, String description) {
            super(name, title, description);
            this.returnValue = 'default result';
        }

        public TestTool(String name, String title, String description, String returnValue) {
            super(name, title, description);
            this.returnValue = returnValue;
        }

        public override String call(Map<String, Object> input) {
            if (input != null && input.containsKey('throw_error')) {
                throw new CalloutException('Test error');
            }
            return this.returnValue;
        }

        public void setReturnValue(String value) {
            this.returnValue = value;
        }
    }

    @IsTest
    static void testGetName() {
        TestTool tool = new TestTool('my_tool', 'My Tool', 'My tool description');

        System.assertEquals('my_tool', tool.getName());
    }

    @IsTest
    static void testCall() {
        TestTool tool = new TestTool('test_tool', 'Test Tool', 'Test description', 'test output');
        Map<String, Object> input = new Map<String, Object>{ 'param1' => 'value1' };

        String result = tool.call(input);

        System.assertEquals('test output', result);
    }

    @IsTest
    static void testCallWithNullInput() {
        TestTool tool = new TestTool('test_tool', 'Test Tool', 'Test description');

        String result = tool.call(null);

        System.assertEquals('default result', result);
    }

    @IsTest
    static void testCallWithEmptyInput() {
        TestTool tool = new TestTool('test_tool', 'Test Tool', 'Test description');
        Map<String, Object> input = new Map<String, Object>();

        String result = tool.call(input);

        System.assertEquals('default result', result);
    }

    @IsTest
    static void testAddProperty() {
        TestTool tool = new TestTool('test_tool', 'Test Tool', 'Test description');
        Tool.Property property = new Tool.Property('param1', 'string', 'First parameter', true);

        tool.addProperty(property);

        String json = tool.toJson();
        System.assert(json.contains('param1'));
        System.assert(json.contains('string'));
        System.assert(json.contains('First parameter'));
    }

    @IsTest
    static void testPropertyConstructor() {
        Tool.Property property = new Tool.Property('test_param', 'number', 'A test parameter', false);

        // Properties are private, but we can test through JSON output
        TestTool tool = new TestTool('test_tool', 'Test Tool', 'Test description');
        tool.addProperty(property);

        String json = tool.toJson();
        System.assert(json.contains('test_param'));
        System.assert(json.contains('number'));
        System.assert(json.contains('A test parameter'));
    }

    @IsTest
    static void testToJsonBasic() {
        TestTool tool = new TestTool('test_tool', 'Test Tool', 'A tool for testing');

        String json = tool.toJson();

        System.assert(json.contains('test_tool'));
        System.assert(json.contains('Test Tool'));
        System.assert(json.contains('A tool for testing'));
        System.assert(json.contains('inputSchema'));
        System.assert(json.contains('properties'));
        System.assert(json.contains('required'));
    }

    @IsTest
    static void testToJsonWithProperties() {
        TestTool tool = new TestTool('complex_tool', 'Complex Tool', 'A complex tool');

        Tool.Property requiredProp = new Tool.Property('required_param', 'string', 'Required parameter', true);
        Tool.Property optionalProp = new Tool.Property('optional_param', 'number', 'Optional parameter', false);

        tool.addProperty(requiredProp);
        tool.addProperty(optionalProp);

        String json = tool.toJson();

        System.assert(json.contains('required_param'));
        System.assert(json.contains('optional_param'));
        System.assert(json.contains('Required parameter'));
        System.assert(json.contains('Optional parameter'));
        System.assert(json.contains('string'));
        System.assert(json.contains('number'));
    }

    @IsTest
    static void testToJsonRequiredArray() {
        TestTool tool = new TestTool('tool_with_requirements', 'Tool With Requirements', 'Test tool');

        Tool.Property requiredProp1 = new Tool.Property('param1', 'string', 'First required', true);
        Tool.Property requiredProp2 = new Tool.Property('param2', 'number', 'Second required', true);
        Tool.Property optionalProp = new Tool.Property('param3', 'boolean', 'Optional param', false);

        tool.addProperty(requiredProp1);
        tool.addProperty(requiredProp2);
        tool.addProperty(optionalProp);

        String payload = tool.toJson();

        // Parse JSON to verify structure
        Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(payload);
        Map<String, Object> inputSchema = (Map<String, Object>) parsed.get('inputSchema');
        List<Object> required = (List<Object>) inputSchema.get('required');

        System.assertEquals(2, required.size());
        System.assert(required.contains('param1'));
        System.assert(required.contains('param2'));
        System.assert(!required.contains('param3'));
    }

    @IsTest
    static void testToJsonSchemaStructure() {
        TestTool tool = new TestTool('schema_test', 'Schema Test', 'Testing schema structure');
        Tool.Property prop = new Tool.Property('test_prop', 'string', 'Test property', true);
        tool.addProperty(prop);

        String payload = tool.toJson();
        Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(payload);

        System.assertEquals('schema_test', parsed.get('name'));
        System.assertEquals('Schema Test', parsed.get('title'));
        System.assertEquals('Testing schema structure', parsed.get('description'));

        Map<String, Object> inputSchema = (Map<String, Object>) parsed.get('inputSchema');
        System.assertEquals('object', inputSchema.get('type'));
        System.assertNotEquals(null, inputSchema.get('properties'));
        System.assertNotEquals(null, inputSchema.get('required'));
    }

    @IsTest
    static void testMultiplePropertiesWithSameName() {
        TestTool tool = new TestTool('duplicate_test', 'Duplicate Test', 'Testing duplicates');

        Tool.Property prop1 = new Tool.Property('same_name', 'string', 'First property', true);
        Tool.Property prop2 = new Tool.Property('same_name', 'number', 'Second property', false);

        tool.addProperty(prop1);
        tool.addProperty(prop2);

        String json = tool.toJson();
        System.assert(json.contains('same_name'));
    }

    @IsTest
    static void testCallWithError() {
        TestTool tool = new TestTool('error_tool', 'Error Tool', 'Tool that throws errors');
        Map<String, Object> input = new Map<String, Object>{ 'throw_error' => true };

        try {
            tool.call(input);
            System.assert(false, 'Expected exception was not thrown');
        } catch (Exception e) {
            System.assert(e instanceof CalloutException);
            System.assertEquals('Test error', e.getMessage());
        }
    }
}
