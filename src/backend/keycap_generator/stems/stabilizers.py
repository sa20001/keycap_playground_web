from ..utilities import KEY_UNIT, STAB_SPACING, KeyUnit

def stabilizer_stems_coords(widthU:KeyUnit, heightU:KeyUnit) -> list[tuple[float, float]]:
    unit = max(widthU, heightU)
    if unit >= KeyUnit.U6: # If spacebar
        distance = (unit - 1) * KEY_UNIT / 2
    else:
        distance = STAB_SPACING / 2
    if widthU > heightU:
        return [
            (-distance, 0),  # left stabilizer
            (distance, 0),   # right stabilizer
        ]
    else:
        return [
            (0, -distance),  # down stabilizer
            (0, distance),   # up stabilizer
        ]

def stabilizers_iso() -> list[tuple[float, float]]:
    return [
        (0, -STAB_SPACING / 2),  # down stabilizer
        (0, STAB_SPACING / 2),   # up stabilizer
    ]