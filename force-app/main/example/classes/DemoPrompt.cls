/**
 * Prompts are designed to be user-controlled, meaning they are exposed from servers to clients with the intention
 * of the user being able to explicitly select them for use.
 * https://modelcontextprotocol.io/specification/2025-06-18/server/prompts
 */
public with sharing class DemoPrompt extends ctx.Prompt {
    public DemoPrompt() {
        super('code_review', 'Code Review', 'Asks the LLM to analyze code quality and suggest improvements');

        this.addArgument(new Argument('code', 'The code to review', true));
    }

    public override List<Message> get(Map<String, Object> input) {
        String code = (String) input.get('code');

        List<Message> messages = new List<Message>();

        messages.add(new Message('user', 'Review the following code and suggest improvements: ' + code));

        return messages;
    }
}
