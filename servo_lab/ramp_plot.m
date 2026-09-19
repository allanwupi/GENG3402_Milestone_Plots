%% GENG3402 Laboratory 2 MATLAB Plots
% Author: Allan Wu (23810308)
% Date/time: 18 September 2026, 11 pm

%% Ramp response plot for Experiment 2
DATA_POS_FILEPATH = 'data/data_pos_implementation2.mat';
DATA_VM_FILEPATH = 'data/data_vm_implementation2.mat';
FIG_TITLE = 'Real PV Ramp Response';
XLIM = [22.4 23.5];
XDELTA = 0.1;


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
ylim([-0.4*pi 0.375*pi]);
yticks([-0.375*pi, -0.250*pi, -0.125*pi, 0, ...
    0.125*pi, 0.250*pi, 0.375*pi]);
yticklabels({'-0.375\pi', '-0.250\pi', '-0.125\pi', '0', ...
    '0.125\pi', '0.250\pi', '0.375\pi'}); 
xlabel('Time (s)')
ylabel('Angular position (rad)')
legend({'Desired \theta_d(t)', 'Load \theta_l(t)'})

start_idx = find(t>=XLIM(1),1,'first');
end_idx = find(t>=XLIM(2),1,'first');
step_idx = find(theta_d(start_idx:end_idx) <= -1.047, 1, 'first');
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
[r_peak, local_idx] = max(theta_d(start_idx:end_idx));
t_peak = t(start_idx+local_idx);
y_peak = theta_l(start_idx+local_idx);
error = r_peak-y_peak;

yline(r_peak, 'LineStyle', '-.', 'Color', 'black', ...
    'Label', sprintf('r = %.4f\\pi, e = %.4f\\pi', r_peak/pi, error/pi), ...
    'HandleVisibility', 'off', ...
    'LabelHorizontalAlignment', 'center', ...
    'LabelVerticalAlignment', 'top');
yline(y_peak, 'LineStyle', '-.', 'Color', 'black', ...
    'Label', sprintf('y = %.4f\\pi', y_peak/pi), ...
    'HandleVisibility', 'off', ...
    'LabelHorizontalAlignment', 'center', ...
    'LabelVerticalAlignment', 'top');
xline(t_step, 'LineStyle', '-.', 'Color', 'black', ...
    'HandleVisibility', 'off', ...
    'Label', sprintf(' %.2f', t_step), ...
    'LabelHorizontalAlignment', 'left', ...
    'LabelVerticalAlignment', 'bottom');
xline(t_peak, 'LineStyle', '-.', 'Color', 'black', ...
    'HandleVisibility', 'off', ...
    'Label', sprintf(' %.2f', t_peak), ...
    'LabelHorizontalAlignment', 'left', ...
    'LabelVerticalAlignment', 'bottom');

hold off;