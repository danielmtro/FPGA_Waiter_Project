def calculate_turn_radius(wheel_distance, v_inner, v_outer):
    """
    Calculate the radius of the turn based on the distance between the inner and outer wheels
    and the linear velocities of the inner and outer wheels.

    Parameters:
    wheel_distance (float): Distance between the inner and outer wheels (meters).
    v_inner (float): Linear velocity of the inner wheels (m/s).
    v_outer (float): Linear velocity of the outer wheels (m/s).

    Returns:
    float: Radius of the turn (meters).
    """
    if v_inner == v_outer:
        return float('inf')  # Straight line, infinite radius

    # Calculate the radius of the turn
    radius = (wheel_distance * (v_inner + v_outer)) / (2 * (v_outer - v_inner))
    
    return radius

wheel_distance = (126 + 50.21) / 1000
v_inner = 0.3
v_outer = 0.5

radius = calculate_turn_radius(wheel_distance, v_inner, v_outer)
print(radius)