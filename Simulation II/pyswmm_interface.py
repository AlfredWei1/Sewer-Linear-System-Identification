from pyswmm import Simulation, Links, Nodes, SystemStats
import matlab.engine

eng = matlab.engine.connect_matlab()

# Series-Merging Test
with Simulation('SWMM File/system/system.inp') as sim:
    string_input = []
    for node in Nodes(sim):
        node_name = node.nodeid
        exec(node_name + "= node")
        exec(node_name + "inflow" + "= []") # First quantity needed
        string_input.append(node_name + "inflow")
        exec(node_name + "level" + "= []") # Second quantity needed
        string_input.append(node_name + "level")

    for link in Links(sim):
        link_name = link.linkid
        exec(link_name + "= link")
        exec(link_name + "flow" + "= []") # Third quantity needed
        string_input.append(link_name + "flow")
        exec(link_name + "downlevel" + '= []') # Fourth quantity needed
        string_input.append(link_name + "downlevel")
        down_node = Nodes(sim)[link.outlet_node]
        exec(link_name + "_down_node" + "= down_node")

    system_stats = SystemStats(sim)
    rainfall = []

    sim.step_advance(300)
    for step in sim:

        for node in Nodes(sim):
            node_name = node.nodeid
            exec(node_name + "inflow.append(" + node_name + ".lateral_inflow)")
            exec(node_name + "level.append(" + node_name + ".depth)")

        for link in Links(sim):
            link_name = link.linkid
            exec(link_name + "flow.append(" + link_name + ".flow)")
            exec(link_name + "downlevel.append(" + link_name +"_down_node.depth)")
        runoffstats = system_stats.runoff_stats
        rainfall.append(runoffstats.get('rainfall'))


    #Now save all four quantities in data
    data_input = []
    for node in Nodes(sim):
        node_name = node.nodeid
        exec("data_input.append(" + node_name + "inflow)")
        exec("data_input.append(" + node_name + "level)")
    for link in Links(sim):
        link_name = link.linkid
        exec("data_input.append(" + link_name + "flow)")
        exec("data_input.append(" + link_name + "downlevel)")
    data_input.append(rainfall)
    string_input.append("rainfall")

    output = eng.save_system_data(data_input,string_input)