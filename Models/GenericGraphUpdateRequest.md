# GenericGraphUpdateRequest

## Properties

| Name                  | Type                  | Description                                                                                     | Notes |
| --------------------- | --------------------- | ----------------------------------------------------------------------------------------------- | ----- |
| **id**                | **String**            | The ID for the tile                                                                           |       |
| **subTitle**          | **String**            | The new subtitle for the graph                                                                  |       |
| **unit**              | **String**            | The new unit for the graph                                                                      |       |
| **secondarySubtitle** | **String**            | The secondary subtitle for the graph                                                            |       |
| **timeUnit**          | **String**            | The unit of time to be shown at the bottom of the graph                                         |       |
| **currentValue**      | **String**            | The new value to be added to the graph. If decimal will be truncated to 2 decimal places        |       |
| **color**             | **[Color](Color.md)** | The color to make the graph, if an invalid cover is given it will default to the profiles theme |       |
| **leading**           | **String**            | The leading text to be added to the current value string                                        |       |
| **ending**            | **String**            | The ending text to be added to the current value string                                         |       |
| **initialValues**     | **List(Double)**      | A list of initial values you want the graph to populate with immediately                        |       |
| **startAtZero**       | **Boolean**           | Tells the graph if the y axis should start at zero, defaults to true                            |       |
| **minYOverride**      | **Double**            | Allows you to set a minimum Y value that the graph will not go below                            |       |
| **maxYOverride**      | **Double**            | Allows you to set a maximum Y value that the graph will not go above                            |       |

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
