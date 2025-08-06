# MCP Apex SDK

## Overview

The Model Context Protocol (MCP) allows applications to provide context for LLMs in a standardized way, separating the concerns of providing context from the actual LLM interaction.

This Apex SDK implements the MCP specification, making it easy to:

- Create MCP servers that expose resources and tools
- Use standard Streamable HTTP transport
- Handle MCP protocol messages

## Installation Links

[Production | Developer Org](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tN2000000mIibIAE)

[Sandbox](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tN2000000mIibIAE)

## Quick Start

> **Demo Context:** For this example, we'll imagine a car service company named AutoCare Plus. The organization has a custom object `CarService__c` that stores information about car services and a custom object `CarServiceAppointment__c` that stores appointment information.

Let's create a simple MCP server that exposes tools to get a list of available car services and book appointments.

### Step 1: Create the REST Resource

First, create a REST resource class that will handle all MCP requests, then create the server instance.

> **Note:** For this demo, we assume the MCP server is publicly accessible via a URL like `{instance}/services/apexrest/mcp/`. To set up a REST Resource for public access, please refer to the [Salesforce documentation](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_rest.htm).

```apex
@RestResource(UrlMapping='/mcp/*')
global with sharing class DemoServer {
  @HttpPost
  global static void post() {
    ctx.Server server = new ctx.Server('1.0.0', 'autocare-plus-mcp-server');
    server.run();
  }
}
```

That's it! The server is now valid and ready to accept requests from MCP clients. However, it doesn't provide any functionality yet.

### Step 2: Create Tools

> [Tools](https://modelcontextprotocol.io/specification/2025-06-18/server/tools) allow servers to expose executable functions that can be invoked by language models.

#### Tool 1: Get Available Car Services

Create a tool that allows clients to retrieve the list of all available car services. To do this, create a class that extends `ctx.Tool` and implements the `call` method:

```apex
public with sharing class GetAvailableCarServicesTool extends ctx.Tool {
  public GetAvailableCarServicesTool() {
    super('get-available-car-services-tool', 'Get available car services');
  }

  public override String call(Map<String, Object> input) {
    List<CarService__c> carServices = [SELECT Id, Name FROM CarService__c];
    return JSON.serialize(carServices);
  }
}
```

#### Tool 2: Book an Appointment

Create a tool that allows clients to book appointments. This tool accepts parameters for the service, customer information, and preferred time:

```apex
public with sharing class BookAppointmentTool extends ctx.Tool {
  public BookAppointmentTool() {
    super('book-appointment-tool', 'Book an appointment for a car service');

    ctx.Tool.Property carServiceId = new ctx.Tool.Property(
      'carServiceId',
      'string',
      'The Salesforce record ID for the car service',
      true
    );

    ctx.Tool.Property customerPhone = new ctx.Tool.Property(
      'customerPhone',
      'string',
      'The phone number of the customer',
      true
    );

    ctx.Tool.Property preferredTime = new ctx.Tool.Property(
      'preferredTime',
      'string',
      'The preferred time for the appointment in ISO 8601 format',
      true
    );

    this.addProperty(carServiceId);
    this.addProperty(customerPhone);
    this.addProperty(preferredTime);
  }

  public override String call(Map<String, Object> input) {
    // Get input parameters
    Id carServiceId = (Id) input.get('carServiceId');
    String customerPhone = (String) input.get('customerPhone');
    Datetime preferredTime = (Datetime) JSON.deserialize((String) input.get('preferredTime'), Datetime.class);

    // Create a new appointment record
    insert new CarServiceAppointment__c(
      CarService__c = carServiceId,
      CustomerPhone__c = customerPhone,
      PreferredTime__c = preferredTime
    );

    return JSON.serialize(true);
  }
}
```

### Step 3: Register Tools with the Server

Now that we've implemented our tools, we need to register them with the server:

```apex
@RestResource(UrlMapping='/mcp/*')
global with sharing class DemoServer {
  @HttpPost
  global static void post() {
    ctx.Server server = new ctx.Server('1.0.0', 'AutoCare Plus MCP Server');
    server.registerTool(new GetAvailableCarServicesTool());
    server.registerTool(new BookAppointmentTool());
    server.run();
  }
}
```

That's it! We've successfully implemented our first MCP server 🎉

## Testing

To test the server, we'll use the [MCP Inspector](https://github.com/modelcontextprotocol/inspector) tool.

### Prerequisites

- Node.js v22.7.5 or higher

### Running the Inspector

If you have Node.js installed, run the following command:

```bash
npx @modelcontextprotocol/inspector
```

### Connecting to Your Server

1. Select **Transport Type**: Streamable HTTP
2. Enter your server URL
3. Click **Connect**

After a successful connection, you should see the list of available resources and tools, as shown in the screenshot below:

![MCP Inspector](https://i.imgur.com/cJhxBV6.png)

If you see the interface above, your server is working correctly! You're now ready to integrate with Claude Desktop or other MCP clients.

Check out [short demo video](https://www.youtube.com/watch?v=Iin7_ZNGaBI) how to add MCP server to Claude Desktop and use it:

# Core Concepts

## Server

The are several ways to create mcp server

### 1. Only required fields

```apex
ctx.Server server = new ctx.Server('1.0.0', 'autocare-plus-mcp-server');
```

### 2. All available fields

```apex
String version = '1.0.0';
String serverName = 'autocare-plus-mcp-server';
String serverTitle = 'AutoCare Plus MCP Server';
String instructions = 'AutoCare Plus car service who exposes list of available services and too to book appointment.';

ctx.Server server = new ctx.Server(version, serverName, serverTitle, instructions);
```

### 3. Using method chaining

```apex
ctx.Server server = new ctx.Server('1.0.0', 'autocare-plus-mcp-server')
        .setInstructions(instructions)
        .setTitle(serverTitle);
```

## Tools

### 1. Creating a tool with only required fields

```apex
public with sharing class GetAvailableCarServicesTool extends ctx.Tool {
  public static final String toolName = 'get-available-car-services-tool';
  public static final String toolDescription = 'Retrieves all available car services with salesforce record id.';

  public GetAvailableCarServicesTool() {
    super(toolName, toolDescription);
  }

  //...
}
```

### 2. All available fields in constructor

```apex
public with sharing class GetAvailableCarServicesTool extends ctx.Tool {
  public static final String toolName = 'get-available-car-services-tool';
  public static final String toolTitle = 'Get available car services';
  public static final String toolDescription = 'Retrieves all available car services with salesforce record id.';

  public GetAvailableCarServicesTool() {
    super(toolName, toolTitle, toolDescription);
  }

  //...
}
```

### 3. Adding properties

```apex
public with sharing class WeatherTool extends ctx.Tool {
  public WeatherTool() {
    super('get-weather-details', 'Get weather details for specific city');

    ctx.Tool.Property cityName = new ctx.Tool.Property(
      'cityName', // Property name
      'string', // Property type
      'The name of the city', // Property description
      true // true if property is Required, false if Optional
    );

    this.addProperty(cityName);
  }

  //...
}
```

### 4. Work with properties

```apex
public with sharing class WeatherTool extends ctx.Tool {
  //...

  public override String call(Map<String, Object> input) {
    String cityName = (String) input.get('cityName');

    // Do some logic here..
    String result = 'The weather in ' + cityName + ' is perfect!';

    return result;
  }
}
```

## Resources

### 1. Creating a resource (Only required fields)

```apex
public with sharing class CarServiceResource extends ctx.Resource {
  public static final String uri = '@server://services';
  public static final String resourceName = 'service-catalog';

  public CarServiceResource() {
    super(uri, resourceName);
  }

  // ..
}
```

### 2. Creating a resource (all available fields)

```apex
public with sharing class CarServiceResource extends ctx.Resource {
  public static final String uri = '@server://services';
  public static final String resourceName = 'service-catalog';
  public static final String resourceTitle = 'Catalog of services';
  public static final String resourceDescription = 'List of all available car services';
  public static final String resourceMimeType = 'application/json';
  public static Long resourceSize = 65536;

  public CarServiceResource() {
    super(uri, resourceName, resourceTitle, resourceDescription, resourceMimeType, resourceSize);
  }

  // ..
}
```

### 3. Creating a resource using method chaining

```apex
public with sharing class CarServiceResource extends ctx.Resource {
  public static final String uri = '@server://services';
  public static final String resourceName = 'service-catalog';
  public static final String resourceTitle = 'Catalog of services';
  public static final String resourceDescription = 'List of all available car services';
  public static final String resourceMimeType = 'application/json';
  public static Long resourceSize = 65536;

  public CarServiceResource() {
    super(uri, resourceName);
    this.setTitle(resourceTitle)
      .setDescription(resourceDescription)
      .setMimeType(resourceMimeType)
      .setSize(resourceSize);
  }

  // ..
}
```

### 4. Retrieving resource data

```apex
public with sharing class CarServiceResource extends ctx.Resource {
  // ..

  public override List<ctx.Resource.Content> read() {
    // The method MUST retrieve List<ctx.Content>
    List<String> services = new List<String>{ 'Oil Change', 'Battery Check' };

    List<ctx.Resource.Content> result = new List<ctx.Resource.Content>();
    for (String service : services) {
      result.add(new ctx.Resource.Content(this.uri, service));
    }

    return result;
  }
}
```

#### 4.1 Creating ctx.Resource.Content (only required fields)

```apex
ctx.Resource.Content content = new ctx.Resource.Content('uri', 'text-data');
```

#### 4.2 Creating ctx.Resource.Content (all fields)

```apex
String uri = '@server://service/oil-change';
String name = 'oil-change';
String title = 'Oil Change';
String text = 'Oil Change Service';

ctx.Resource.Content content = new ctx.Resource.Content(uri, name, title, text);
```

#### 4.3 Creating ctx.Resource.Content using method chaining

```apex
String uri = '@server://service/oil-change';
String name = 'oil-change';
String title = 'Oil Change';
String text = 'Oil Change Service';

ctx.Resource.Content content = new ctx.Resource.Content(uri, text)
    .setTitle(title)
    .setMimeType('plain/text')
    .setText(text);
```

#### 4.3 Creating ctx.Resource.Content with Binary content

```apex
String uri = '@file:///example.png';
String name = 'example.png';
String title = 'Example Image';

ctx.Resource.Content content = new ctx.Resource.Content(uri)
    .setName(name)
    .setTitle(title)
    .setMimeType('image/png')
    .setBlobData('base64-encoded-data');
```

### 5. Adding resource annotations

```apex
public with sharing class CarServiceResource extends ctx.Resource {
  public static final String uri = '@server://services';
  public static final String resourceName = 'service-catalog';

  public CarServiceResource() {
    super(uri, resourceName);

    List<String> audience = new List<String>{ 'user', 'assistant' }; // "user" or "assistant" or both
    Decimal priority = 0.8; // between 0 and 1
    Datetime lastModified = System.now(); // ISO 8601 formatted timestamp

    ctx.Resource.Annotations annotations = new ctx.Resource.Annotations(audience, priority, lastModified);

    this.setAnnotations(annotations);
  }

  // ..
}
```
