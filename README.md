# Documentation for Polymath Local API

<a name="ssl-info"></a>

## TLS Certificates

The Flux Polymath API uses a self signed TLS certificate. These certificates are generated at runtime and replaced as needed (when they expire) so that each installation has a unique certificate.

For your plugins you will need to get the certificate to create a security context in your requests. The locations are as follows

### Windows

`%APPDATA%\Polymath\tls\cert.pem`

### macOS

`~/Library/Application Support/Polymath/tls/cert.pem`

### Linux

`~/.config/Polymath/tls/cert.pem`

<a name="documentation-for-api-endpoints"></a>

## Documentation for API Endpoints

All URIs are relative to _https://localhost:PORT/v1_

| Method       | HTTP request                                                                                | Description                             |                                               |
| ------------ | ------------------------------------------------------------------------------------------- | --------------------------------------- | --------------------------------------------- |
| _DefaultApi_ | [**authenticationCheckGet**](Apis/DefaultApi.md#authenticationcheckget)                     | **GET** /authentication/check           | Validate API key                              |
| _DefaultApi_ | [**authenticationRegisterPost**](Apis/DefaultApi.md#authenticationregisterpost)             | **POST** /authentication/register       | Register application and generate API key     |
| _DefaultApi_ | [**configAddIconPost**](Apis/DefaultApi.md#configaddiconpost)                               | **POST** /config/addIcon                | Add icons to configuration                    |
| _DefaultApi_ | [**configAddKeystyleToAppearancePut**](Apis/DefaultApi.md#configaddkeystyletoappearanceput) | **PUT** /config/addKeystyleToAppearance | Add keystyle(s) to appearance                 |
| _DefaultApi_ | [**configChangeGet**](Apis/DefaultApi.md#configchangeget)                                   | **GET** /configChange                   | WebSocket session stream                      |
| _DefaultApi_ | [**configImportPost**](Apis/DefaultApi.md#configimportpost)                                 | **POST** /config/import                 | Import .flux configuration file               |
| _DefaultApi_ | [**configKeymapDataGet**](Apis/DefaultApi.md#configkeymapdataget)                           | **GET** /config/keymapData              | Get keymap data                               |
| _DefaultApi_ | [**configSavePost**](Apis/DefaultApi.md#configsavepost)                                     | **POST** /config/save                   | Save configuration to keyboard                |
| _DefaultApi_ | [**configUpdateActiveProcessPost**](Apis/DefaultApi.md#configupdateactiveprocesspost)       | **POST** /config/updateActiveProcess    | Update foreground active process (Linux only) |
| _DefaultApi_ | [**configUpdateProcessesPost**](Apis/DefaultApi.md#configupdateprocessespost)               | **POST** /config/updateProcesses        | Update list of active processes on Linux      |
| _DefaultApi_ | [**docsGet**](Apis/DefaultApi.md#docsget)                                                   | **GET** /docs                           | Link to documentation                         |

<a name="documentation-for-models"></a>

## Documentation for Models

- [ActiveProcessRequest](./Models/ActiveProcessRequest.md)
- [ErrorResponse](./Models/ErrorResponse.md)
- [IconImportResponse](./Models/IconImportResponse.md)
- [IconRequest](./Models/IconRequest.md)
- [IconRequest_icons_inner](./Models/IconRequest_icons_inner.md)
- [ImportFileRequest](./Models/ImportFileRequest.md)
- [ImportResponse](./Models/ImportResponse.md)
- [KeyAction](./Models/KeyAction.md)
- [KeyModel](./Models/KeyModel.md)
- [KeyStyle](./Models/KeyStyle.md)
- [KeymapLayer](./Models/KeymapLayer.md)
- [KeymapResponse](./Models/KeymapResponse.md)
- [KeystyleRequest](./Models/KeystyleRequest.md)
- [MessageResponse](./Models/MessageResponse.md)
- [ProcessUpdateRequest](./Models/ProcessUpdateRequest.md)
- [WebSocketMessage](./Models/WebSocketMessage.md)

<a name="documentation-for-authorization"></a>

## Documentation for Authorization

<a name="bearerAuth"></a>

### bearerAuth

- **Type**: HTTP Bearer Token authentication (API-Key)
