import numpy as np

def generate_linear_model(rate_matrix, params, params0):
    """
    Generate a linear model of the rate matrix.

    Parameters:
    - rate_matrix (ndarray): Rate matrix (Trial x Time)
    - params (ndarray): Parameters (peak velocity, duration) shape (Trial x 2)
    - params0 (array-like): Grand average parameters [peak velocity, average velocity]

    Returns:
    - linmod (dict): Linear model structure containing:
        - wv0: reduced model velocity coefficients
        - wv: full model velocity coefficients
        - wr: full model duration coefficients
        - ssc: corrected PSTH for full model
        - ssc0: corrected PSTH for reduced model
        - v00: grand average peak velocity
        - r00: grand average average velocity
    """
    vpeak = np.abs(params[:][0])  # peak velocity
    sdur = np.abs(params[:][1])   # duration
    ss = rate_matrix              # rate matrix

    ss0 = np.nanmean(ss, axis=0)  # mean rate across trials
    dss = ss - ss0                # deviation from mean rate
    v0 = np.nanmean(vpeak)        # mean peak velocity
    r0 = np.nanmean(15. / sdur)   # mean average velocity

    dv = vpeak - v0
    dr = 15 / sdur - r0
    dz = np.stack((dv, dr), axis=1)  # shape (Trial, 2)

    # Full model coefficients
    cc = dz.T @ dz
    w12 = np.linalg.pinv(cc) @ dz.T @ dss  # shape (2, Time)

    wv = w12[0, :]  # velocity coefficients
    wr = w12[1, :]  # duration coefficients

    # Reduced model with only velocity
    wv0 = (dv.T @ dss) / (dv.T @ dv)  # shape (Time,)

    # Grand averages
    v00 = params0[0]
    r00 = params0[1]

    # Corrected PSTH for full model
    wc = (v00 - v0) * wv + (r00 - r0) * wr
    ssc = ss0 + wc

    # Corrected PSTH for reduced model
    wc0 = (v00 - v0) * wv0
    ssc0 = ss0 + wc0

    linmod = {
        'wv0': wv0,
        'wv': wv,
        'wr': wr,
        'ssc': ssc,
        'ssc0': ssc0,
        'v00': v00,
        'r00': r00
    }

    return linmod