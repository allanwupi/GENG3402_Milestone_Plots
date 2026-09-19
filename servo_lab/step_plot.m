%% GENG3402 Laboratory 2 MATLAB Plots
% Author: Allan Wu (23810308)
% Date/time: 18 September 2026, 10 pm

%% Step response plot for Experiment 1
DATA_POS_FILEPATH = 'data/data_pos_sim2.mat';
DATA_VM_FILEPATH = 'data/data_vm_sim2.mat';
FIG_TITLE = 'Simulated PIV Ramp';
XLIM = [22.5 23.5];
XDELTA = 0.050;


pos = open(DATA_POS_FILEPATH);
vm = open(DATA_VM_FILEPATH);

t = pos.data_pos(:, 1);
theta_d = pos.data_pos(:, 2);
theta_l = pos.data_pos(:, 3);
vm = vm.data_vm(:, 2);

figure;
set(gcf, 'Color', 'white');
box on;
hold on;
plot(t, theta_d, 'Color', 'black', 'LineStyle', '-');
plot(t, theta_l, 'Color', 'black', 'LineWidth', 1);
grid;
title(FIG_TITLE);
xlim(XLIM);
% ylim([-0.16*pi 0.165*pi]);
% yticks([-0.15*pi, -0.125*pi, -0.1*pi, -0.075*pi, -0.05*pi, -0.025*pi, ...
%     0, 0.025*pi, 0.05*pi, 0.075*pi, 0.1*pi, 0.125*pi, 0.15*pi]);
% yticklabels({'-0.150\pi', '-0.125\pi', '-0.100\pi', '-0.075\pi', ...
%     '-0.050\pi', '-0.025\pi', '0', '0.025\pi', '0.050\pi', ...
%     '0.075\pi', '0.100\pi', '0.125\pi', '0.150\pi'}); 
xlabel('Time (s)')
ylabel('Angular position (rad)')
legend({'Desired \theta_d(t)', 'Load \theta_l(t)'})

start_idx = find(t>=XLIM(1),1,'first');
end_idx = find(t>=XLIM(2),1,'first');
step_idx = find(theta_d(start_idx:end_idx) > -0.125*pi, 1, 'first');
t_step = t(start_idx+step_idx);

% Print out 10 sample values
interval = find(t>=XLIM(1)+XDELTA,1,'first') - start_idx;
for n = 0:1:10
    sample_idx = start_idx + step_idx + n*interval;
    sample_rads = theta_l(sample_idx);
    target_rads = theta_d(sample_idx);
    fprintf('dt=%.2f  t=%.2f  r=%+.3fpi  y=%+.3fpi  e=%+.3fpi\n', ...
        n*0.050, t(sample_idx), target_rads/pi, sample_rads/pi, (target_rads-sample_rads)/pi)
end

% Locate peak value
% [y_peak, local_idx] = max(theta_l(start_idx:end_idx));
% t_peak = t(start_idx+local_idx);
% 
% yline(y_peak, 'LineStyle', '-.', 'Color', 'black', ...
%     'Label', sprintf('y_{max} = %.4f\\pi', y_peak/pi), ...
%     'HandleVisibility', 'off', ...
%     'LabelHorizontalAlignment', 'center', ...
%     'LabelVerticalAlignment', 'top');
% xline(t_step, 'LineStyle', '-.', 'Color', 'black', ...
%     'HandleVisibility', 'off', ...
%     'Label', sprintf(' %.2f', t_step), ...
%     'LabelHorizontalAlignment', 'left', ...
%     'LabelVerticalAlignment', 'bottom');
% xline(t_peak, 'LineStyle', '-.', 'Color', 'black', ...
%     'HandleVisibility', 'off', ...
%     'Label', sprintf(' %.2f', t_peak), ...
%     'LabelHorizontalAlignment', 'left', ...
%     'LabelVerticalAlignment', 'bottom');

hold off;