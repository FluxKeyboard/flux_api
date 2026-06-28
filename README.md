# Documentation for Polymath Local API

<a name="documentation-for-api-endpoints"></a>
## Documentation for API Endpoints

All URIs are relative to *https://localhost:52323/v1*

| Class | Method | HTTP request | Description |
|------------ | ------------- | ------------- | -------------|
| *DefaultApi* | [**authenticationCheckGet**](Apis/DefaultApi.md#authenticationcheckget) | **GET** /authentication/check | Validate API key |
*DefaultApi* | [**authenticationRegisterPost**](Apis/DefaultApi.md#authenticationregisterpost) | **POST** /authentication/register | Register application and generate API key |
*DefaultApi* | [**configAddIconPost**](Apis/DefaultApi.md#configaddiconpost) | **POST** /config/addIcon | Add icons to configuration |
*DefaultApi* | [**configAddKeystyleToAppearancePut**](Apis/DefaultApi.md#configaddkeystyletoappearanceput) | **PUT** /config/addKeystyleToAppearance | Add keystyle(s) to appearance |
*DefaultApi* | [**configChangeGet**](Apis/DefaultApi.md#configchangeget) | **GET** /configChange | WebSocket session stream |
*DefaultApi* | [**configImportPost**](Apis/DefaultApi.md#configimportpost) | **POST** /config/import | Import .flux configuration file |
*DefaultApi* | [**configKeymapDataGet**](Apis/DefaultApi.md#configkeymapdataget) | **GET** /config/keymapData | Get keymap data |
*DefaultApi* | [**configSavePost**](Apis/DefaultApi.md#configsavepost) | **POST** /config/save | Save configuration to keyboard |
*DefaultApi* | [**configUpdateActiveProcessPost**](Apis/DefaultApi.md#configupdateactiveprocesspost) | **POST** /config/updateActiveProcess | Update foreground active process (Linux only) |
*DefaultApi* | [**configUpdateProcessesPost**](Apis/DefaultApi.md#configupdateprocessespost) | **POST** /config/updateProcesses | Update list of active processes on Linux |
*DefaultApi* | [**docsGet**](Apis/DefaultApi.md#docsget) | **GET** /docs | Link to documentation |


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

