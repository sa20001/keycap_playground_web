def reduction_calculation(step:int, amplitude:float, total_steps:int):
    '''
        Calculates the reduction value for a given step in a tapering curve.
    '''
    return (1 - step / total_steps) * amplitude