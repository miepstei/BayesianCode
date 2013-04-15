function [datasim,mech]=simulate(time)
    mech = DataController.read_CK_demo();
    %recording=ScnRecording(sim.sojourns,[sim.states(:).conductance],zeros(1,length(sim.states)),length(sim.states));
    %mecs=DataController.list_mechanisms('Samples/demomec.mec');
    %mec=DataController.load_mechanism('Samples/demomec.mec',mecs.mec_struct(1));
    datasim=generate(mech,time);
    %recording=ScnRecording(sim.sojourns,[sim.states(:).conductance],zeros(1,length(sim.states)),length(sim.states));
end