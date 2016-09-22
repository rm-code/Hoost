return {
    id       = "weapon_hkmp5",
    itemType = "Weapon",
    weaponType = "Submachine Gun",
    weight   = 2.0,
    damage   = 36,
    rpm      = 800,
    caliber  = "9x19mm",
    magSize  = 30,
    equippable = true,
    range = 25,
    mode = {
        {
            name = "Single",
            cost = 3,
            accuracy = 75,
            attacks = 1,
        },
        {
            name = "5-Round Burst",
            cost = 5,
            accuracy = 60,
            attacks = 5,
        }
    }
}
