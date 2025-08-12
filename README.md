# MCP Apex SDK

## Overview

The [Model Context Protocol (MCP)](https://modelcontextprotocol.io/docs/getting-started/intro) provides a standardized way for applications to supply context to LLMs, separating
context provision from LLM interaction.

This Apex SDK implements the MCP specification, enabling you to:

- Create MCP servers that expose resources, tools, and prompts as primitives
- Use standard Streamable HTTP transport
- Handle MCP protocol messages

<a name="installation-links"></a>

## Installation Links

[![Static Badge](https://img.shields.io/badge/Deploy%20To%20Production-%23009EDB?style=for-the-badge&logo=salesforce&logoColor=white)](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tN2000000mLmvIAE)

[![Static Badge](https://img.shields.io/badge/Deploy%20To%20Sandbox-%23009EDB?style=for-the-badge&logo=salesforce&logoColor=white)](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tN2000000mLmvIAE)

`/packaging/installPackage.apexp?p0=04tN2000000mLmvIAE`

## Quick Start

1. [Install](#installation-links) the package in your Salesforce org
2. Deploy demo classes from the `force-app/main/example` folder
3. [Expose](#how-to-expose-server) the `DemoServer` from the example folder as a REST resource
4. [Test](#testing-the-mcp-server) the functionality using
   the [MCP Inspector](https://github.com/modelcontextprotocol/inspector) tool

<a name="how-to-expose-server"></a>

### How to Expose an MCP Server

To expose the server to guest users, create a site and enable the `DemoServer` class for guest users:

1. Navigate to `Setup > User Interface > Sites and Domains > Sites`
2. Click `New` and enter the `Site Label` and `Site Name`, then click `Save`
3. On the site details page, click `Activate`, then click `Public Access Settings`
4. In the `Enabled Apex Class Access` section, add `DemoServer` to the `Enabled Apex Classes`
5. Return to `Setup > User Interface > Sites and Domains > Sites`, find your newly created site, and copy its `Site URL`
6. Append `/services/apexrest/mcp` to the copied `Site URL` to get the full URL for your MCP server

> [!NOTE]
> If your org has a namespace, the URL will be `{site_url}/services/apexrest/{namespace}/mcp`.

<a name="testing-the-mcp-server"></a>

### Testing the MCP Server

To test the server, use the [MCP Inspector](https://github.com/modelcontextprotocol/inspector) tool.

### Connecting to Your Server

1. Select **Transport Type**: Streamable HTTP
2. Enter your server URL (e.g., `https://{instance_url}/services/apexrest/mcp`)
3. Click **Connect**

After a successful connection, you'll see the list of available resources, tools, and prompts, as shown in the
screenshot below:

![MCP Inspector](https://i.imgur.com/pkNvuRg.png)

# Core Concepts

## Server

There are several ways to create an MCP server:

### 1. With Required Fields Only

```apex
ctx.Server server = new ctx.Server('1.0.0', 'autocare-plus-mcp-server');
```

### 2. With All Available Fields

```apex
String version = '1.0.0';
String serverName = 'autocare-plus-mcp-server';
String serverTitle = 'AutoCare Plus MCP Server';
String instructions = 'AutoCare Plus car service that exposes a list of available services and a tool to book appointments.';

ctx.Server server = new ctx.Server(version, serverName, serverTitle, instructions);
```

### 3. Using Method Chaining

```apex
ctx.Server server = new ctx.Server('1.0.0', 'autocare-plus-mcp-server')
        .setInstructions(instructions)
        .setTitle(serverTitle);
```

## Tools

### 1. Creating a Tool with Required Fields Only

```apex
public with sharing class GetAvailableCarServicesTool extends ctx.Tool {
  public static final String toolName = 'get-available-car-services-tool';
  public static final String toolDescription = 'Retrieves all available car services with their Salesforce record IDs.';

  public GetAvailableCarServicesTool() {
    super(toolName, toolDescription);
  }

  //...
}
```

### 2. Using All Available Constructor Fields

```apex
public with sharing class GetAvailableCarServicesTool extends ctx.Tool {
  public static final String toolName = 'get-available-car-services-tool';
  public static final String toolTitle = 'Get Available Car Services';
  public static final String toolDescription = 'Retrieves all available car services with their Salesforce record IDs.';

  public GetAvailableCarServicesTool() {
    super(toolName, toolTitle, toolDescription);
  }

  //...
}
```

### 3. Adding Properties

```apex
public with sharing class WeatherTool extends ctx.Tool {
  public WeatherTool() {
    super('get-weather-details', 'Get weather details for a specific city');

    ctx.Tool.Property cityName = new ctx.Tool.Property(
      'cityName', // Property name
      'string', // Property type
      'The name of the city', // Property description
      true // true if property is required, false if optional
    );

    this.addProperty(cityName);
  }

  //...
}
```

### 4. Working with Properties

```apex
public with sharing class WeatherTool extends ctx.Tool {
  //...

  public override String call(Map<String, Object> input) {
    String cityName = (String) input.get('cityName');

    // Perform logic here...
    String result = 'The weather in ' + cityName + ' is perfect!';

    return result;
  }
}
```

## Resources

### 1. Creating a Resource (Required Fields Only)

```apex
public with sharing class CarServiceResource extends ctx.Resource {
  public static final String uri = '@server://services';
  public static final String resourceName = 'service-catalog';

  public CarServiceResource() {
    super(uri, resourceName);
  }

  // ...
}
```

### 2. Creating a Resource (All Available Fields)

```apex
public with sharing class CarServiceResource extends ctx.Resource {
  public static final String uri = '@server://services';
  public static final String resourceName = 'service-catalog';
  public static final String resourceTitle = 'Catalog of Services';
  public static final String resourceDescription = 'List of all available car services';
  public static final String resourceMimeType = 'application/json';
  public static Long resourceSize = 65536;

  public CarServiceResource() {
    super(uri, resourceName, resourceTitle, resourceDescription, resourceMimeType, resourceSize);
  }

  // ...
}
```

### 3. Creating a Resource Using Method Chaining

```apex
public with sharing class CarServiceResource extends ctx.Resource {
  public static final String uri = '@server://services';
  public static final String resourceName = 'service-catalog';
  public static final String resourceTitle = 'Catalog of Services';
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

  // ...
}
```

### 4. Retrieving Resource Data

```apex
public with sharing class CarServiceResource extends ctx.Resource {
  // ...

  public override List<ctx.Resource.Content> read() {
    // This method MUST return List<ctx.Resource.Content>
    List<String> services = new List<String>{ 'Oil Change', 'Battery Check' };

    List<ctx.Resource.Content> result = new List<ctx.Resource.Content>();
    for (String service : services) {
      result.add(new ctx.Resource.Content(this.uri, service));
    }

    return result;
  }
}
```

#### 4.1 Creating ctx.Resource.Content (Required Fields Only)

```apex
ctx.Resource.Content content = new ctx.Resource.Content('uri', 'text-data');
```

#### 4.2 Creating ctx.Resource.Content (All Fields)

```apex
String uri = '@server://service/oil-change';
String name = 'oil-change';
String title = 'Oil Change';
String text = 'Oil Change Service';

ctx.Resource.Content content = new ctx.Resource.Content(uri, name, title, text);
```

#### 4.3 Creating ctx.Resource.Content Using Method Chaining

```apex
String uri = '@server://service/oil-change';
String name = 'oil-change';
String title = 'Oil Change';
String text = 'Oil Change Service';

ctx.Resource.Content content = new ctx.Resource.Content(uri, text)
        .setTitle(title)
        .setMimeType('text/plain')
        .setText(text);
```

#### 4.4 Creating ctx.Resource.Content with Binary Content

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

### 5. Adding Resource Annotations

```apex
public with sharing class CarServiceResource extends ctx.Resource {
  public static final String uri = '@server://services';
  public static final String resourceName = 'service-catalog';

  public CarServiceResource() {
    super(uri, resourceName);

    List<String> audience = new List<String>{ 'user', 'assistant' }; // "user" or "assistant" or both
    Decimal priority = 0.8; // Value between 0 and 1
    Datetime lastModified = System.now(); // ISO 8601 formatted timestamp

    ctx.Resource.Annotations annotations = new ctx.Resource.Annotations(audience, priority, lastModified);

    this.setAnnotations(annotations);
  }

  // ...
}
```

## Prompts

### 1. Creating a Prompt (Required Fields Only)

```apex
public with sharing class CodeReviewPrompt extends ctx.Prompt {
  public CodeReviewPrompt() {
    super('code-review');
  }

  // ...
}
```

### 2. Creating a Prompt (All Available Fields)

```apex
public with sharing class CodeReviewPrompt extends ctx.Prompt {
  public CodeReviewPrompt() {
    super('code-review', 'Code Review', 'Asks the LLM to analyze code quality and suggest improvements');
  }

  // ...
}
```

### 3. Creating a Prompt Using Method Chaining

```apex
public with sharing class CodeReviewPrompt extends ctx.Prompt {
  public CodeReviewPrompt() {
    super('code-review');
    this.setTitle('Code Review').setDescription('Asks the LLM to analyze code quality and suggest improvements');
  }

  // ...
}
```

### 4. Adding Prompt Arguments

```apex
public with sharing class CodeReviewPrompt extends ctx.Prompt {
  public CodeReviewPrompt() {
    super('code-review', 'Code Review', 'Asks the LLM to analyze code quality and suggest improvements');

    ctx.Prompt.Argument code = new ctx.Prompt.Argument('code', 'The code to review', true);

    this.addArgument(code);
  }

  // ...
}
```

### 5. Retrieving Prompt Messages

```apex
public with sharing class CodeReviewPrompt extends ctx.Prompt {
  // ...

  public override List<ctx.Prompt.Message> get(Map<String, Object> input) {
    String code = (String) input.get('code');

    List<ctx.Prompt.Message> messages = new List<ctx.Prompt.Message>();

    messages.add(new ctx.Prompt.Message('user', 'Review the following code and suggest improvements: ' + code));

    return messages;
  }
}
```
