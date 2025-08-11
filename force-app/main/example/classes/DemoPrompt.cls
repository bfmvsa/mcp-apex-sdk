public with sharing class DemoPrompt extends Prompt {
    public DemoPrompt() {
        super('code_review', 'Code Review', 'Asks the LLM to analyze code quality and suggest improvements');

        this.arguments.add(new Argument('code', 'The code to review', true));
    }

    public override List<Message> get(Map<String, Object> input) {
        String code = (String) input.get('code');

        List<Message> messages = new List<Message>();

        messages.add(new Message('user', 'Review the following code and suggest improvements: ' + code));

        return messages;
    }
}
