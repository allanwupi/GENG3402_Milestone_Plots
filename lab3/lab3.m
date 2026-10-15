%% GENG3402 Laboratory 3 MATLAB Plots
% Author: Allan Wu (23810308)
% Date/time: 30 September 2026

%% Pre-lab values
Kbb = 0.4183;
prelab_Kc = 3.1456;
prelab_z = 0.9413;

% Tuned values for 8%
Kc = 2.94573254066;
z = 1.07651403732;

function plot_root_locus_ideal(Kbb, Kc, z)
    % Transfer function for BB01 (ideal PD control) is
    % Kbb Kc z / (s^2 + Kbb Kc s + Kbb Kc z)
    s = tf('s');
    T = Kbb*Kc*z / (s^2 + Kbb*Kc*s + Kbb*Kc*z);
    figure;
    rlocusplot(T);
    title('Root locus for ball-beam system with ideal PD and no servo dynamics')
    hold on;
    p = pole(T);
    % Label pole locations
    for i = 1:2
        text(real(p(i)), imag(p(i)), ...
        sprintf('  s_%d = %.3f%+.3fj', i, real(p(i)), imag(p(i))));
    end
    hold off;
    sgrid;
end

function plot_root_locus_practical(Kbb, Kc, z, wf)
    if nargin < 4
        wf = 2*pi;
    end
    % Transfer function for BB01 (ideal PD control) is
    % s^3 + s^2 * wf + (Kbb * Kc * wf + Kbb * Kc * z) * s + Kbb * Kc * z * wf
    s = tf('s');
    T = 1 / (s^3 + s^2 * wf + (Kbb * Kc * wf + Kbb * Kc * z) * s + Kbb * Kc * z * wf);
    figure;
    rlocusplot(T);
    title('Root locus for ball-beam system with practical PD (tuned for PO=8%)')
    hold on;
    p = pole(T);
    % Label pole locations
    for i = 1:3
        text(real(p(i)), imag(p(i)), ...
        sprintf('  s_%d = %.3f%+.3fj', i, real(p(i)), imag(p(i))));
    end
    hold off;
    sgrid;
end

function plot_position_theta(start_time, end_time, x_matfile, theta_matfile, vm_matfile)
    x = open(x_matfile);
    if nargin < 5
        vm_matfile = "data/data_vm_simulation412.mat";
    end
    if nargin < 4
        theta_matfile = "data/data_theta_l_simulation411.mat";
    end
    theta_l = open(theta_matfile);
    vm = open(vm_matfile);

    t = x.data_x(:, 1);
    end_idx = find(t>=end_time, 1, 'first');
    if start_time < 0.0
        end_idx = length(t);
    end
    start_idx = find(t>=start_time, 1, 'first');

    figure;
    set(gcf, 'Color', 'white');
    tiledlayout(nargin-2,1,'TileSpacing','tight');
    nexttile;
    box on;
    hold on;
    % Add titles manually in figure window
    % title('Simulated ideal PD with no servo dynamics');
    grid;
    plot(x.data_x(start_idx:end_idx, 1), x.data_x(start_idx:end_idx, 2), ...
        'Color', 'black', 'LineStyle', '-.', 'LineWidth', 0.75);
    plot(x.data_x(start_idx:end_idx, 1), x.data_x(start_idx:end_idx, 3), ...
        'Color', 'black', 'LineStyle', '-', 'LineWidth', 1);
    [peak, peak_idx] = max(x.data_x(start_idx:end_idx, 3));
    peak_time = t(start_idx+peak_idx);
    yline(peak, 'LineStyle', '-.', 'HandleVisibility', 'off', 'Color', 'black', ...
        'Label', sprintf('%.3f', peak), ...
        'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'top');
    xline(peak_time, 'LineStyle', '--', 'Color', 'black', 'HandleVisibility', 'off', ...
    'Label', sprintf('  %.3f', peak_time), ...
    'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'bottom');
    ylabel('Position (cm)');
    ylim([-8 8]);
    legend({'Setpoint Position', 'Ball Position'}, 'Location', 'southeast');

    if start_time > 0.0
        ylim([-6 7]);
        xi = x.data_x(start_idx, 3);
        xf = x.data_x(end_idx, 3);
        ess = x.data_x(end_idx-1, 2) - xf;
        upper = xi + (xf-xi)*1.04;
        lower = xi + (xf-xi)*0.96;
        settle_idx = find(x.data_x(start_idx:end_idx, 3) >= upper, 1, 'last');
        settle_time = t(start_idx+settle_idx);
        yline(lower, '--', ...
            'LabelHorizontalAlignment', 'right', 'LabelVerticalAlignment', 'middle', ...
            'HandleVisibility', 'off', 'Color', '#000000');
        yline(upper, '--', 'Label', sprintf('e_{ss} = %.3f', ess), ...
            'LabelHorizontalAlignment', 'right', 'LabelVerticalAlignment', 'middle', ...
            'HandleVisibility', 'off', 'Color', '#000000');
        p = patch([xlim fliplr(xlim)], [lower lower upper upper], [1.0 0.7 0.15], ...
            'FaceAlpha', 0.08, 'EdgeColor', 'none', 'HandleVisibility', 'off');
        xline(settle_time, 'LineStyle', '--', 'Color', 'black', 'HandleVisibility', 'off', ...
            'Label', sprintf('  %.3f', settle_time), ...
            'LabelHorizontalAlignment', 'right', 'LabelVerticalAlignment', 'bottom');
        uistack(p, 'bottom');
    end

    if nargin >= 4
        nexttile;
        colororder({'k', 'k'}); % Override axes colors
        yyaxis right;
        plot(x.data_x(start_idx:end_idx, 1), x.data_x(start_idx:end_idx, 3), ...
            'Color', 'black', 'LineStyle', '-', 'LineWidth', 1);
        ylabel('Position (cm)');
        ylim([-8 8]);
        xlabel('Time (s)');
        yyaxis left;
        plot(theta_l.data_theta_l(start_idx:end_idx, 1), ...
            theta_l.data_theta_l(start_idx:end_idx, 2), ...
            'Color', 'red', 'LineWidth', 1);
        ylabel('Load angle (degrees)');
        maxpeak = max(theta_l.data_theta_l(start_idx:end_idx, 2));
        yline(maxpeak, 'LineStyle', '-.', 'HandleVisibility', 'off', 'Color', 'red', ...
            'Label', sprintf('%.3f', maxpeak), ...
            'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'top');
        minpeak = min(theta_l.data_theta_l(start_idx:end_idx, 2));
        yline(minpeak, 'LineStyle', '-.', 'HandleVisibility', 'off', 'Color', 'red', ...
            'Label', sprintf('%.3f', minpeak), ...
            'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'top');
        legend({'Ball Position', 'Load Shaft Angle'}, 'Location', 'southeast');
        grid;
    end

    if nargin >= 5
        nexttile;
        grid;
        hold on;
        plot(vm.data_vm(start_idx:end_idx, 1), vm.data_vm(start_idx:end_idx, 2), ...
            'Color', [0.9 0.5 0], 'LineStyle', '-', 'LineWidth', 1.0);
        hold off;
        maxpeak = max(vm.data_vm(start_idx:end_idx, 2));
        yline(maxpeak, 'LineStyle', '-.', 'HandleVisibility', 'off', 'Color', [0.9 0.5 0], ...
            'Label', sprintf('  %.3f', maxpeak), ...
            'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'top');
        if start_time < 1.0
            minpeak = min(vm.data_vm(start_idx:end_idx, 2));
            yline(minpeak, 'LineStyle', '-.', 'HandleVisibility', 'off', 'Color', [0.9 0.5 0], ...
                'Label', sprintf('  %.3f', minpeak), ...
                'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'top');
        end
        ylim([-6 6]);
        legend('Servo Motor Voltage', 'Location', 'southeast');
    end
end


%% Begin main script
% Plot root locus for ideal PD controller
plot_root_locus_ideal(Kbb, prelab_Kc, prelab_z);

% Plot root locus for practical PD controller
plot_root_locus_practical(Kbb, Kc, z);

% Plot for section 4.1.1 step 9
plot_position_theta(-1, 25.0, ...
    "data/data_x_simulation411.mat", ...
    "data/data_theta_l_simulation412.mat", ...
    "data/data_vm_simulation412.mat");

plot_position_theta(9.0, 19.0, ...
    "data/data_x_simulation411.mat", ...
    "data/data_theta_l_simulation412.mat", ...
    "data/data_vm_simulation412.mat");