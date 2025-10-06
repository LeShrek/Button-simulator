export type PlayerDataPrefab = {
    Name: string,
    Type: string,
    StartingValue: any,
    DoSave: boolean,
    DataStoreName: string,
    IsOrderedDataStore: boolean
}

return {
    leaderstats = {
        {
            Name = "Rebirths",
            Type = "IntValue",
            StartingValue = 0,
            DoSave = true,
            DataStoreName = "Rebirths",
            IsOrderedDataStore = true
        },
        {
            Name = "Money",
            Type = "IntValue",
            StartingValue = 100,
            DoSave = true,
            DataStoreName = "Money",
            IsOrderedDataStore = true
        }
    },

    hiddenData = {
        {
            Name = "Gems",
            Type = "IntValue",
            StartingValue = 0,
            DoSave = true,
            DataStoreName = "Gems",
            IsOrderedDataStore = false
        }
    }
} :: {[string]: {PlayerDataPrefab}}
