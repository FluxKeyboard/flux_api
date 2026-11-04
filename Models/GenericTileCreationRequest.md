# GenericTileCreationRequest

## Properties

| Name       | Type                  | Description                                                                                                                                                                                          | Notes                              |
| ---------- | --------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------- |
| **title**  | **String**            | The title of the created tile. The ID will be directly comparable to the title                                                                                                                       |                                    |
| **type**   | **GenericModuleType** | The type of generic tile you wish to create                                                                                                                                                          |                                    |
| **index**  | **int**               | The position in the top bar you want the module to be placed. Must be a number between 0 and 3                                                                                                       |                                    |
| **length** | **int**               | How large you want the x axis on the graph tile to be, limted to 100,000                                                                                                                             | Only required for the graph module |
| **gridX**  | **[Grid](Grid.md)**   | X is replaced by the grid number you are declaring, with the first one being numbered 1. For example, grid1 would be the definition for the first grid in the top left. Repeat this item up to grid6 | Only required for the grid module  |

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
