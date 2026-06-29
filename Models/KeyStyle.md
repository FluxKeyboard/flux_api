# KeyStyle

## Properties

| Name              | Type                              | Description                                                                                                                                                                                                                 | Notes |
| ----------------- | --------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----- |
| **style**         | **[LegendStyle](LegendStyle.md)** | The style for the key to render as. You send in the number of the enum you wish                                                                                                                                             |       |
| **label**         | **String**                        | The label, if any, you wish to have on the key                                                                                                                                                                              |       |
| **icon**          | **int**                           | This is a flutter internal object, 99.9% of the time you will not use this. However if you have an interest in using it, here is[documentation](https://api.flutter.dev/flutter/material/Icons-class.html) to get the codes |       |
| **iconAssetPath** | **String**                        | This is the absolute path to the imported icon that you wish to add to the style. If it doesn't exist in the icons directory in the config, the request will be rejected and you will be directed to /addIcon               |       |

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
