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
