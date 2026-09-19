%% GENG3402 Laboratory 2 MATLAB Plots
% Author: Allan Wu (23810308)
% Date/time: 10 September 2026, 1:15 pm

function plot_servo_experiment(expt_title, pos_matfile, vm_matfile)
    pos = open(pos_matfile);
    vm = open(vm_matfile);

    t = pos.data_pos(:, 1);
    x1 = pos.data_pos(:, 2);
    x2 = pos.data_pos(:, 3);
    vm = vm.data_vm(:, 2);
    
    figure;
    set(gcf, 'Color', 'white');
    layout = tiledlayout(2, 1, "TileSpacing", "compact", "Padding", "compact");
    title(layout, expt_title);
    nexttile;
    plot(t, x1, t, x2);
    grid;
    legend;
    title("Load position \theta_l(t)");
    if max([x1; x2]) < pi/4
        ylim([-3*pi/16 3*pi/16]);
        yticks([-pi/8, 0, pi/8]);
        yticklabels({"-\pi/8", "0", "\pi/8"}); 
    else
        ylim([-7*pi/16 7*pi/16]);
        yticks([-3*pi/8, -pi/4, -pi/8, 0, pi/8, pi/4, 3*pi/8]);
        yticklabels({"-3\pi/8", "-\pi/4", "-\pi/8", "0", "\pi/8", "\pi/4", "3\pi/8"}); 
    end
    xlim([20 25]);
    xlabel('Time (s)')
    ylabel('Angular position (rad)')

    nexttile;
    plot(t, vm);
    title("Motor voltage V_m(t)");
    grid;
    legend;
    if max(vm) < 5
        ylim([-5 5]);
    else
        ylim([-10 10]); 
    end
    xlim([20 25]);
    xlabel('Time (s)')
    ylabel('Voltage (V)')
end

% Store file names as cell array of string tuples (title, data_pos_XX, data_vm_XX)
expt_matfiles = {
    "Ideal PV Controller Step Response", "data/data_pos_sim1_a.mat", "data/data_vm_sim1_a.mat", ...
    "Ideal Filtered PV Step Response", "data/data_pos_sim1_b.mat", "data/data_vm_sim1_b.mat", ...
    "Real PV Controller Step Response","data/data_pos_implementation1.mat", "data/data_vm_implementation1.mat", ...
    "Ideal PV Controller Ramp Response", "data/data_pos_sim2.mat", "data/data_vm_sim2.mat", ...
    "Real PV Controller Ramp Response", "data/data_pos_implementation2.mat", "data/data_vm_implementation2.mat", ...
    "Ideal PIV Controller Ramp Response", "data/data_pos_sim3.mat", "data/data_vm_sim3.mat", ...
    "Real PIV Controller Ramp Response", "data/data_pos_implementation3.mat", "data/data_vm_implementation3.mat"
};

% Plot all data
for i = 1:3:numel(expt_matfiles)
    expt_title = expt_matfiles{i};
    pos_matfile = expt_matfiles{i+1};
    vm_matfile = expt_matfiles{i+2};
    plot_servo_experiment(expt_title, pos_matfile, vm_matfile);
end