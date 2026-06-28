# DefaultApi

All URIs are relative to _https://localhost:52323/v1_

| Method                                                                                 | HTTP request                            | Description                                   |
| -------------------------------------------------------------------------------------- | --------------------------------------- | --------------------------------------------- |
| [**authenticationCheckGet**](DefaultApi.md#authenticationCheckGet)                     | **GET** /authentication/check           | Validate API key                              |
| [**authenticationRegisterPost**](DefaultApi.md#authenticationRegisterPost)             | **POST** /authentication/register       | Register application and generate API key     |
| [**configAddIconPost**](DefaultApi.md#configAddIconPost)                               | **POST** /config/addIcon                | Add icons to configuration                    |
| [**configAddKeystyleToAppearancePut**](DefaultApi.md#configAddKeystyleToAppearancePut) | **PUT** /config/addKeystyleToAppearance | Add keystyle(s) to appearance                 |
| [**configChangeGet**](DefaultApi.md#configChangeGet)                                   | **GET** /configChange                   | WebSocket session stream                      |
| [**configImportPost**](DefaultApi.md#configImportPost)                                 | **POST** /config/import                 | Import .flux configuration file               |
| [**configKeymapDataGet**](DefaultApi.md#configKeymapDataGet)                           | **GET** /config/keymapData              | Get keymap data                               |
| [**configSavePost**](DefaultApi.md#configSavePost)                                     | **POST** /config/save                   | Save configuration to keyboard                |
| [**configUpdateActiveProcessPost**](DefaultApi.md#configUpdateActiveProcessPost)       | **POST** /config/updateActiveProcess    | Update foreground active process (Linux only) |
| [**configUpdateProcessesPost**](DefaultApi.md#configUpdateProcessesPost)               | **POST** /config/updateProcesses        | Update list of active processes on Linux      |
| [**docsGet**](DefaultApi.md#docsGet)                                                   | **GET** /docs                           | Link to documentation                         |

<a name="authenticationCheckGet"></a>

# **authenticationCheckGet**

> authenticationCheckGet(User-Agent)

Validate API key

### Parameters

| Name           | Type       | Description | Notes |
| -------------- | ---------- | ----------- | ----- |
| **User-Agent** | **String** |             |       |

### Return type

null (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: Not defined

<a name="authenticationRegisterPost"></a>

# **authenticationRegisterPost**

> MessageResponse authenticationRegisterPost(User-Agent)

Register application and generate API key

### Parameters

| Name           | Type       | Description | Notes |
| -------------- | ---------- | ----------- | ----- |
| **User-Agent** | **String** |             |       |

### Return type

[**MessageResponse**](../Models/MessageResponse.md)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json

<a name="configAddIconPost"></a>

# **configAddIconPost**

> IconImportResponse configAddIconPost(IconRequest)

Add icons to configuration

### Parameters

| Name            | Type                                        | Description | Notes |
| --------------- | ------------------------------------------- | ----------- | ----- |
| **IconRequest** | [**IconRequest**](../Models/IconRequest.md) |             |       |

### Return type

[**IconImportResponse**](../Models/IconImportResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json

<a name="configAddKeystyleToAppearancePut"></a>

# **configAddKeystyleToAppearancePut**

> MessageResponse configAddKeystyleToAppearancePut(KeystyleRequest)

Add keystyle(s) to appearance

### Parameters

| Name                | Type                                                | Description | Notes |
| ------------------- | --------------------------------------------------- | ----------- | ----- |
| **KeystyleRequest** | [**KeystyleRequest**](../Models/KeystyleRequest.md) |             |       |

### Return type

[**MessageResponse**](../Models/MessageResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json

<a name="configChangeGet"></a>

# **configChangeGet**

> configChangeGet(User-Agent, WebSocketMessage)

WebSocket session stream

    WebSocket routes: - changeProfile - currentProfile - changeContext - currentContext

### Parameters

| Name                 | Type                                                  | Description | Notes      |
| -------------------- | ----------------------------------------------------- | ----------- | ---------- |
| **User-Agent**       | **String**                                            |             |            |
| **WebSocketMessage** | [**WebSocketMessage**](../Models/WebSocketMessage.md) |             | [optional] |

### Return type

null (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: Not defined

<a name="configImportPost"></a>

# **configImportPost**

> ImportResponse configImportPost(User-Agent, ImportFileRequest)

Import .flux configuration file

### Parameters

| Name                  | Type                                                    | Description | Notes |
| --------------------- | ------------------------------------------------------- | ----------- | ----- |
| **User-Agent**        | **String**                                              |             |       |
| **ImportFileRequest** | [**ImportFileRequest**](../Models/ImportFileRequest.md) |             |       |

### Return type

[**ImportResponse**](../Models/ImportResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json

<a name="configKeymapDataGet"></a>

# **configKeymapDataGet**

> KeymapResponse configKeymapDataGet()

Get keymap data

### Parameters

This endpoint does not need any parameter.

### Return type

[**KeymapResponse**](../Models/KeymapResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json

<a name="configSavePost"></a>

# **configSavePost**

> MessageResponse configSavePost(User-Agent)

Save configuration to keyboard

### Parameters

| Name           | Type       | Description | Notes |
| -------------- | ---------- | ----------- | ----- |
| **User-Agent** | **String** |             |       |

### Return type

[**MessageResponse**](../Models/MessageResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json

<a name="configUpdateActiveProcessPost"></a>

# **configUpdateActiveProcessPost**

> MessageResponse configUpdateActiveProcessPost(ActiveProcessRequest)

Update foreground active process (Linux only)

### Parameters

| Name                     | Type                                                          | Description | Notes |
| ------------------------ | ------------------------------------------------------------- | ----------- | ----- |
| **ActiveProcessRequest** | [**ActiveProcessRequest**](../Models/ActiveProcessRequest.md) |             |       |

### Return type

[**MessageResponse**](../Models/MessageResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json

<a name="configUpdateProcessesPost"></a>

# **configUpdateProcessesPost**

> MessageResponse configUpdateProcessesPost(ProcessUpdateRequest)

Update list of active processes on Linux

### Parameters

| Name                     | Type                                                          | Description | Notes |
| ------------------------ | ------------------------------------------------------------- | ----------- | ----- |
| **ProcessUpdateRequest** | [**ProcessUpdateRequest**](../Models/ProcessUpdateRequest.md) |             |       |

### Return type

[**MessageResponse**](../Models/MessageResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json

<a name="docsGet"></a>

# **docsGet**

> String docsGet()

Link to documentation

### Parameters

This endpoint does not need any parameter.

### Return type

**String**

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: text/plain
