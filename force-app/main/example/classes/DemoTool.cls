/**
 * Tools in MCP are designed to be model-controlled, meaning that the language model can discover and invoke tools
 * automatically based on its contextual understanding and the user’s prompts.
 * https://modelcontextprotocol.io/specification/2025-06-18/server/tools
 */
public with sharing class DemoTool extends Tool {
    public DemoTool() {
        super('get_weather', 'Weather Information Provider', 'Get current weather information for a location');
        this.addProperty(new Property('location', 'string', 'City name or zip code', true));
    }

    public override String call(Map<String, Object> input) {
        String location = (String) input.get('location');
        return 'Windy and rainy, 20 degrees above zero in ' + location;
    }
}
