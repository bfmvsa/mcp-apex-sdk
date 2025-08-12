@IsTest
private class PromptTest {
    private class TestPrompt extends Prompt {
        public TestPrompt(String name) {
            super(name);
        }

        public TestPrompt(String name, String title, String description) {
            super(name, title, description);
        }

        public override List<Message> get(Map<String, Object> input) {
            List<Message> messages = new List<Message>();
            messages.add(new Message('user', 'Test prompt message'));
            if (input != null && input.containsKey('extraMessage')) {
                messages.add(new Message('assistant', (String) input.get('extraMessage')));
            }
            return messages;
        }
    }

    @IsTest
    static void testConstructorWithNameOnly() {
        TestPrompt prompt = new TestPrompt('test_prompt');

        System.assertEquals('test_prompt', prompt.name);
        System.assertEquals(null, prompt.title);
        System.assertEquals(null, prompt.description);
        System.assertEquals(0, prompt.arguments.size());
        System.assertEquals(0, prompt.messages.size());
    }

    @IsTest
    static void testConstructorWithAllParameters() {
        TestPrompt prompt = new TestPrompt('test_prompt', 'Test Title', 'Test Description');

        System.assertEquals('test_prompt', prompt.name);
        System.assertEquals('Test Title', prompt.title);
        System.assertEquals('Test Description', prompt.description);
        System.assertEquals(0, prompt.arguments.size());
        System.assertEquals(0, prompt.messages.size());
    }

    @IsTest
    static void testGetName() {
        TestPrompt prompt = new TestPrompt('my_prompt');

        System.assertEquals('my_prompt', prompt.getName());
    }

    @IsTest
    static void testSetTitle() {
        TestPrompt prompt = new TestPrompt('test_prompt');

        Prompt result = prompt.setTitle('New Title');

        System.assertEquals('New Title', prompt.title);
        System.assertEquals(prompt, result);
    }

    @IsTest
    static void testSetDescription() {
        TestPrompt prompt = new TestPrompt('test_prompt');

        Prompt result = prompt.setDescription('New Description');

        System.assertEquals('New Description', prompt.description);
        System.assertEquals(prompt, result);
    }

    @IsTest
    static void testAddArgument() {
        TestPrompt prompt = new TestPrompt('test_prompt');
        Prompt.Argument argument = new Prompt.Argument('param1', 'First parameter', true);

        prompt.addArgument(argument);

        System.assertEquals(1, prompt.arguments.size());
        System.assert(prompt.arguments.contains(argument));
    }

    @IsTest
    static void testAddMultipleArguments() {
        TestPrompt prompt = new TestPrompt('test_prompt');
        Prompt.Argument arg1 = new Prompt.Argument('param1', 'First parameter', true);
        Prompt.Argument arg2 = new Prompt.Argument('param2', 'Second parameter', false);

        prompt.addArgument(arg1);
        prompt.addArgument(arg2);

        System.assertEquals(2, prompt.arguments.size());
        System.assert(prompt.arguments.contains(arg1));
        System.assert(prompt.arguments.contains(arg2));
    }

    @IsTest
    static void testGetWithEmptyInput() {
        TestPrompt prompt = new TestPrompt('test_prompt');

        List<Prompt.Message> messages = prompt.get(new Map<String, Object>());

        System.assertEquals(1, messages.size());
        String messageJson = messages[0].toJson();
        System.assert(messageJson.contains('user'));
        System.assert(messageJson.contains('Test prompt message'));
    }

    @IsTest
    static void testGetWithInputData() {
        TestPrompt prompt = new TestPrompt('test_prompt');
        Map<String, Object> input = new Map<String, Object>{ 'extraMessage' => 'Additional response' };

        List<Prompt.Message> messages = prompt.get(input);

        System.assertEquals(2, messages.size());
        String firstMessageJson = messages[0].toJson();
        String secondMessageJson = messages[1].toJson();
        System.assert(firstMessageJson.contains('user'));
        System.assert(firstMessageJson.contains('Test prompt message'));
        System.assert(secondMessageJson.contains('assistant'));
        System.assert(secondMessageJson.contains('Additional response'));
    }

    @IsTest
    static void testToJsonMinimal() {
        TestPrompt prompt = new TestPrompt('test_prompt');

        String json = prompt.toJson();

        System.assert(json.contains('test_prompt'));
        System.assert(json.contains('arguments'));
        System.assert(!json.contains('title'));
        System.assert(!json.contains('description'));
    }

    @IsTest
    static void testToJsonWithAllFields() {
        TestPrompt prompt = new TestPrompt('test_prompt', 'Test Title', 'Test Description');
        Prompt.Argument argument = new Prompt.Argument('param1', 'Parameter description', true);
        prompt.addArgument(argument);

        String json = prompt.toJson();

        System.assert(json.contains('test_prompt'));
        System.assert(json.contains('Test Title'));
        System.assert(json.contains('Test Description'));
        System.assert(json.contains('arguments'));
        System.assert(json.contains('param1'));
        System.assert(json.contains('Parameter description'));
        System.assert(json.contains('true'));
    }

    @IsTest
    static void testArgumentConstructorAndToJson() {
        Prompt.Argument argument = new Prompt.Argument('test_param', 'Test parameter description', false);

        String json = argument.toJson();

        System.assert(json.contains('test_param'));
        System.assert(json.contains('Test parameter description'));
        System.assert(json.contains('false'));
    }

    @IsTest
    static void testArgumentToJsonRequired() {
        Prompt.Argument argument = new Prompt.Argument('required_param', 'Test description', true);

        String json = argument.toJson();

        System.assert(json.contains('required_param'));
        System.assert(json.contains('Test description'));
        System.assert(json.contains('true'));
    }

    @IsTest
    static void testMessageConstructorAndToJson() {
        Prompt.Message message = new Prompt.Message('user', 'Hello world');

        String json = message.toJson();

        System.assert(json.contains('user'));
        System.assert(json.contains('content'));
        System.assert(json.contains('text'));
        System.assert(json.contains('Hello world'));
    }

    @IsTest
    static void testMessageToJsonAssistant() {
        Prompt.Message message = new Prompt.Message('assistant', 'Hello response');

        String json = message.toJson();

        System.assert(json.contains('assistant'));
        System.assert(json.contains('content'));
        System.assert(json.contains('text'));
        System.assert(json.contains('Hello response'));
    }

    @IsTest
    static void testChainedMethods() {
        TestPrompt prompt = new TestPrompt('test_prompt');

        Prompt result = prompt.setTitle('Chained Title').setDescription('Chained Description');

        System.assertEquals('Chained Title', prompt.title);
        System.assertEquals('Chained Description', prompt.description);
        System.assertEquals(prompt, result);
    }
}
