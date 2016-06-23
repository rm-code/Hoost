return {
    name     = "FN P90",
    itemType = "Weapon",
    damage   = 38,
    range    = 12,
    rpm      = 900,
    ammoType = "5.7x28mm",
    mode = {
        single = {
            cost = 3,
            accuracy = 65,
            shots = 1,
        },
        burst = {
            cost = 5,
            accuracy = 55,
            shots = 5,
        },
        auto = {
            cost = 8,
            accuracy = 40,
            shots = 13,
        }
    }
}
