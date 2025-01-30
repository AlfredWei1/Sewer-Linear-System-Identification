from pyswmm import Simulation, Links, Nodes, SystemStats
import matlab.engine

eng = matlab.engine.connect_matlab()


def double_to_float(x):
    temp = str(x).replace('[', '')
    temp = temp.replace(']', '')
    return float(temp)

# LQR Control
with Simulation('SWMM File/system/system.inp') as sim:
    SU1 = Nodes(sim)["SU1"]
    SU2 = Nodes(sim)["SU2"]
    SU3 = Nodes(sim)["SU3"]
    WWTP = Nodes(sim)["WWTP"]
    JI3 = Nodes(sim)["JI_3"]
    SU1level = []
    SU2level = []
    SU3level = []
    WWTPlevel = []
    string_input_LQR = ["SU1level", "SU2level", "SU3level", "WWTPlevel"]
    SU1flood = []
    SU2flood = []
    SU3flood = []
    WWTPflood = []
    JI3flood = []
    string_input_LQR.extend(["SU1flood", "SU2flood", "SU3flood", "WWTPflood", "JI3flood"])

    OR1 = Links(sim)["OR1"]
    OR2 = Links(sim)["OR2"]
    OR3 = Links(sim)["OR3"]
    ORI = Links(sim)["OR_WWTP"]
    OR1set = []
    OR2set = []
    OR3set = []
    ORIset = []
    OR1flow = []
    OR2flow = []
    OR3flow = []
    ORIflow = []
    string_input_LQR.extend(["OR1set", "OR2set", "OR3set", "ORIset", "OR1flow", "OR2flow", "OR3flow", "ORIflow"])

    CSO1 = Links(sim)["CSO1"]
    CSO2 = Links(sim)["CSO2"]
    CSO3 = Links(sim)["CSO3"]
    CSO1flow = []
    CSO2flow = []
    CSO3flow = []
    string_input_LQR.extend(["CSO1flow", "CSO2flow", "CSO3flow"])

    system_stats = SystemStats(sim)
    flooding = []
    string_input_LQR.append("flooding")

    t = 0
    sim.step_advance(300)
    for step in sim:
        SU1level.append(SU1.depth)
        SU2level.append(SU2.depth)
        SU3level.append(SU3.depth)
        WWTPlevel.append(WWTP.depth)
        if t <= 10:
            current_depth = [SU1.depth, SU2.depth, SU3.depth, WWTP.depth]
            zero_depth = [0,0,0,0]
            current_state = [current_depth,zero_depth,zero_depth,zero_depth,zero_depth,zero_depth,
                     zero_depth,zero_depth,zero_depth,zero_depth,zero_depth]
        elif t > 10:
            current_depth = [SU1.depth, SU2.depth, SU3.depth, WWTP.depth]
            depth1 = [SU1level[t-1], SU2level[t-1], SU3level[t-1], WWTPlevel[t-1]]
            depth2 = [SU1level[t - 2], SU2level[t - 2], SU3level[t - 2], WWTPlevel[t - 2]]
            depth3 = [SU1level[t - 3], SU2level[t - 3], SU3level[t - 3], WWTPlevel[t - 3]]
            depth4 = [SU1level[t - 4], SU2level[t - 4], SU3level[t - 4], WWTPlevel[t - 4]]
            depth5 = [SU1level[t - 5], SU2level[t - 5], SU3level[t - 5], WWTPlevel[t - 5]]
            depth6 = [SU1level[t - 6], SU2level[t - 6], SU3level[t - 6], WWTPlevel[t - 6]]
            depth7 = [SU1level[t - 7], SU2level[t - 7], SU3level[t - 7], WWTPlevel[t - 7]]
            depth8 = [SU1level[t - 8], SU2level[t - 8], SU3level[t - 8], WWTPlevel[t - 8]]
            depth9 = [SU1level[t - 9], SU2level[t - 9], SU3level[t - 9], WWTPlevel[t - 9]]
            depth10 = [SU1level[t - 10], SU2level[t - 10], SU3level[t - 10], WWTPlevel[t - 10]]
            current_state = [current_depth,depth1,depth2,depth3,depth4,depth5,depth6,depth7,depth8,depth9,depth10]

        u = eng.control_execution(current_state,t)
        u1 = double_to_float(u[0])
        u2 = double_to_float(u[1])
        u3 = double_to_float(u[2])
        u4 = double_to_float(u[3])
        OR1.target_setting = u1
        OR2.target_setting = u2
        OR3.target_setting = u3
        ORI.target_setting = 0.5


        SU1flood.append(SU1.flooding)
        SU2flood.append(SU2.flooding)
        SU3flood.append(SU3.flooding)
        WWTPflood.append(WWTP.flooding)
        JI3flood.append(JI3.flooding)
        OR1set.append(OR1.target_setting)
        OR2set.append(OR2.target_setting)
        OR3set.append(OR3.target_setting)
        ORIset.append(ORI.target_setting)
        OR1flow.append(OR1.flow)
        OR2flow.append(OR2.flow)
        OR3flow.append(OR3.flow)
        ORIflow.append(ORI.flow)
        CSO1flow.append(CSO1.flow)
        CSO2flow.append(CSO2.flow)
        CSO3flow.append(CSO3.flow)
        runoffstats = system_stats.routing_stats
        flooding.append(runoffstats.get('flooding'))

        t = t+1

    data_input_LQR = [SU1level, SU2level, SU3level, WWTPlevel, SU1flood, SU2flood, SU3flood, WWTPflood,JI3flood]
    data_input_LQR.extend([OR1set, OR2set, OR3set, ORIset, OR1flow, OR2flow, OR3flow, ORIflow,
                  CSO1flow, CSO2flow, CSO3flow, flooding])

# Rule-Based Control
with Simulation('SWMM File/system/system.inp') as sim:
        CSO1_Z0 = 0.5
        CSO2_Z0 = 0.5
        CSO3_Z0 = 0.5

        SU1 = Nodes(sim)["SU1"]
        SU2 = Nodes(sim)["SU2"]
        SU3 = Nodes(sim)["SU3"]
        WWTP = Nodes(sim)["WWTP"]
        JI3 = Nodes(sim)["JI_3"]
        SU1level = []
        SU2level = []
        SU3level = []
        WWTPlevel = []
        string_input_RB = ["SU1level", "SU2level", "SU3level", "WWTPlevel"]
        SU1flood = []
        SU2flood = []
        SU3flood = []
        WWTPflood = []
        JI3flood = []
        string_input_RB.extend(["SU1flood", "SU2flood", "SU3flood", "WWTPflood", "JI3flood"])

        OR1 = Links(sim)["OR1"]
        OR2 = Links(sim)["OR2"]
        OR3 = Links(sim)["OR3"]
        ORI = Links(sim)["OR_WWTP"]
        OR1set = []
        OR2set = []
        OR3set = []
        ORIset = []
        OR1flow = []
        OR2flow = []
        OR3flow = []
        ORIflow = []
        string_input_RB.extend(["OR1set", "OR2set", "OR3set", "ORIset", "OR1flow", "OR2flow", "OR3flow", "ORIflow"])

        CSO1 = Links(sim)["CSO1"]
        CSO2 = Links(sim)["CSO2"]
        CSO3 = Links(sim)["CSO3"]
        CSO1flow = []
        CSO2flow = []
        CSO3flow = []
        string_input_RB.extend(["CSO1flow", "CSO2flow", "CSO3flow"])

        system_stats = SystemStats(sim)
        flooding = []
        string_input_RB.append("flooding")

        t = 0
        sim.step_advance(300)
        for step in sim:
            SU1level.append(SU1.depth)
            SU2level.append(SU2.depth)
            SU3level.append(SU3.depth)
            WWTPlevel.append(WWTP.depth)


            if SU1.depth >= CSO1_Z0:
                OR1.target_setting = 0.9
            elif SU1.depth < CSO1_Z0:
                OR1.target_setting = 1

            if SU2.depth >= CSO2_Z0:
                OR2.target_setting = 0.4
            elif SU2.depth < CSO2_Z0:
                OR2.target_setting = 1

            if SU3.depth >= CSO3_Z0:
                OR3.target_setting = 0.7
            elif SU3.depth < CSO3_Z0:
                OR3.target_setting = 1

            ORI.target_setting = 0.5

            SU1flood.append(SU1.flooding)
            SU2flood.append(SU2.flooding)
            SU3flood.append(SU3.flooding)
            WWTPflood.append(WWTP.flooding)
            JI3flood.append(JI3.flooding)
            OR1set.append(OR1.target_setting)
            OR2set.append(OR2.target_setting)
            OR3set.append(OR3.target_setting)
            ORIset.append(ORI.target_setting)
            OR1flow.append(OR1.flow)
            OR2flow.append(OR2.flow)
            OR3flow.append(OR3.flow)
            ORIflow.append(ORI.flow)
            CSO1flow.append(CSO1.flow)
            CSO2flow.append(CSO2.flow)
            CSO3flow.append(CSO3.flow)
            runoffstats = system_stats.routing_stats
            flooding.append(runoffstats.get('flooding'))

            t = t + 1

        data_input_RB = [SU1level, SU2level, SU3level, WWTPlevel, SU1flood, SU2flood, SU3flood, WWTPflood, JI3flood]
        data_input_RB.extend([OR1set, OR2set, OR3set, ORIset, OR1flow, OR2flow, OR3flow, ORIflow,
                               CSO1flow, CSO2flow, CSO3flow, flooding])



output = eng.plot_result(data_input_LQR, string_input_LQR,data_input_RB,string_input_RB)