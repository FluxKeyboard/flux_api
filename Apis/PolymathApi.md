# PolymathApi

All URIs are relative to _https://localhost:PORT/v1_, _https://localIp:PORT/v1_, or depending on how you set up port forwarding, _https://customDomain/v1_ or _https://customDomain:PORT/v1_

| HTTP request                                                                               | Description                                                                   |
| ------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------- |
| [**GET** /authentication/check](PolymathApi.md#authenticationCheckGet)                     | Validate API key                                                              |
| [**POST** /authentication/register](PolymathApi.md#authenticationRegisterPost)             | Register application and generate API key                                     |
| [**POST** /config/addIcon](PolymathApi.md#configAddIconPost)                               | Add icons to configuration                                                    |
| [**PUT** /config/addKeystyleToAppearance](PolymathApi.md#configAddKeystyleToAppearancePut) | Add keystyle(s) to appearance                                                 |
| [**WSS** /configChange](PolymathApi.md#configChangeGet)                                    | WebSocket session stream                                                      |
| [**POST** /config/import](PolymathApi.md#configImportPost)                                 | Import .flux configuration file                                               |
| [**POST** /config/createGenericModule ](PolymathApi.md#configGenericCreatePost)            | Creates a generic module of the given type                                    |
| [**PUT** /config/updateGenericModule ](PolymathApi.md#configGenericUpdatePut)              | Updates the current data of a generic module                                  |
| [**GET** /config/keymapData](PolymathApi.md#configKeymapDataGet)                           | Get keymap data                                                               |
| [**POST** /config/save](PolymathApi.md#configSavePost)                                     | Save configuration to keyboard                                                |
| [**POST** /config/updateActiveProcess](PolymathApi.md#configUpdateActiveProcessPost)       | Update foreground active process (Linux only)                                 |
| [**POST** /config/updateInputLanguage](PolymathApi.md#configUpdateInputLanguagePost)       | Update the active keyboard input language (Linux only)                        |
| [**POST** /config/updateProcesses](PolymathApi.md#configUpdateProcessesPost)               | Update list of active processes (Linux only)                                  |
| [**GET** /docs](PolymathApi.md#docsGet)                                                    | Gets a link to the current documentation, can also be used to ping the server |

<a name="authenticationCheckGet"></a>

# **GET /authentication/check**

Validate API key

### Parameters

This endpoint does not need any parameter.

### Return type

null (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: Not defined
- **User-Agent**: Your Application

<a name="authenticationRegisterPost"></a>

# **POST /authentication/register**

Register application and generate API key

### Parameters

This endpoint does not need any parameter.

### Return type

[**MessageResponse**](../Models/MessageResponse.md)

### Authorization

No authorization required

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json
- **User-Agent**: Your Application

<a name="configAddIconPost"></a>

# **POST /config/addIcon**

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
- **User-Agent**: Your Application

<a name="configAddKeystyleToAppearancePut"></a>

# **PUT /config/addKeystyleToAppearance**

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
- **User-Agent**: Your Application

<a name="configChangeGet"></a>

# **WSS /configChange**

WebSocket session stream

WebSocket routes: - changeProfile - currentProfile - changeContext - currentContext

changeProfile: Takes in the name of the profile to switch to. Will return 403 if the user denies the request

currentProfile: Returns the current active profile on the keyboard based on the automated settings

changeContext: Updates the current context in the active shortcut collection. Will return 404 if the context doesn't exist, and 403 if the user denies the request

currentContext: Returns the name of the current active shortcut context

### Parameters

| Name                 | Type                                                  | Description                                                   | Notes      |
| -------------------- | ----------------------------------------------------- | ------------------------------------------------------------- | ---------- |
| **WebSocketMessage** | [**WebSocketMessage**](../Models/WebSocketMessage.md) | Not needed for initial handshake, only for websocket messages | [optional] |

### Return type

null (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: Not defined
- **User-Agent**: Your Application

<a name="configImportPost"></a>

# **POST /config/import**

Import .flux configuration file

### Parameters

| Name                  | Type                                                    | Description | Notes |
| --------------------- | ------------------------------------------------------- | ----------- | ----- |
| **ImportFileRequest** | [**ImportFileRequest**](../Models/ImportFileRequest.md) |             |       |

### Return type

[**ImportResponse**](../Models/ImportResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json
- **User-Agent**: Your Application

<a name="configGenericCreatePost"></a>

# **POST /config/createGenericModule**

Creates a generic module of the given type

### Parameters

| Name                             | Type                                                                          | Description | Notes |
| -------------------------------- | ----------------------------------------------------------------------------- | ----------- | ----- |
| **GenericModuleCreationRequest** | [**GenericModuleCreationRequest**](../Models/GenericModuleCreationRequest.md) |             |       |

### Return type

[**GenericModuleCreationResponse**](../Models/GenericModuleCreationResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json
- **User-Agent**: Your Application

<a name="configGenericUpdatePut"></a>

# **PUT /config/updateGenericModule**

Updates the current data of a generic module

### Parameters

| Name                           | Type                                                                      | Description | Notes |
| ------------------------------ | ------------------------------------------------------------------------- | ----------- | ----- |
| **GenericModuleUpdateRequest** | [**GenericModuleUpdateRequest**](../Models/GenericModuleUpdateRequest.md) |             |       |

### Return type

[**GenericModuleUpdateResponse**](../Models/GenericModuleUpdateResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json
- **User-Agent**: Your Application

<a name="configKeymapDataGet"></a>

# **GET /config/keymapData**

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
- **User-Agent**: Your Application

<a name="configSavePost"></a>

# **POST /config/save**

Save configuration to keyboard

### Parameters

This endpoint does not need any parameter.

### Return type

[**MessageResponse**](../Models/MessageResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: Not defined
- **Accept**: application/json
- **User-Agent**: Your Application

<a name="configUpdateActiveProcessPost"></a>

# **POST /config/updateActiveProcess**

Update foreground active process (Linux only)

Polymath serves this value only while your application keeps calling the API. See [Detection overrides](../README.md#detection-overrides).

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
- **User-Agent**: Your Application

<a name="configUpdateInputLanguagePost"></a>

# **POST /config/updateInputLanguage**

Update the active keyboard input language (Linux only)

Polymath serves this value only while your application keeps calling the API. See [Detection overrides](../README.md#detection-overrides).

### Parameters

| Name                      | Type                                                            | Description | Notes |
| ------------------------- | --------------------------------------------------------------- | ----------- | ----- |
| **InputLanguageRequest**  | [**InputLanguageRequest**](../Models/InputLanguageRequest.md)   |             |       |

### Return type

[**MessageResponse**](../Models/MessageResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

- **Content-Type**: application/json
- **Accept**: application/json
- **User-Agent**: Your Application

<a name="configUpdateProcessesPost"></a>

# **POST /config/updateProcesses**

Update list of active processes (Linux only)

Polymath serves this value only while your application keeps calling the API. See [Detection overrides](../README.md#detection-overrides).

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
- **User-Agent**: Your Application

<a name="docsGet"></a>

# **GET /docs**

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
