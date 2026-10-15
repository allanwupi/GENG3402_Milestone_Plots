%% GENG3402 Assignment 3 - Part 3
% Authors: Allan Wu (2810308) and Bhashon Saha (25253764)
% Last updated: 15 October 2026

DESIRED_POLE = -1+1j;
SETTLING_BAND = 0.02;

PROPORTIONAL_GAIN = 1;
DERIVATIVE_GAIN = -1;

% Proportional-Derivative controller: Gc(s) = Kp + Kd*s = Kd*(s + Kp/Kd)
function T = get_proportional_derivative_tf(Kp, Kd)
    s = tf('s');
    Gc = Kd*s + Kp;        % PD Compensator
    Gv = 0.6 / (3*s + 2);  % Valve
    Gp = 28 / (30*s + 2);  % Heat exchanger
    H = 2 / (5*s + 4);     % Sensor
    % Overall system transfer function T(s)
    T = Gc * Gv * Gp / (1 + Gc * Gv * Gp * H);
end


%% Function to produce annotated root locus plot
% des is the desired pole location (complex value)
function proportional_derivative_root_locus(Kp, Kd, des)
    T = get_proportional_derivative_tf(Kp, Kd);
    figure;
    set(gcf, 'Color', 'w')
    rlocusplot(T);
    title('Root Locus of Proportional-Derivative Compensated System');
    hold on;
    % Annotate the desired pole locations
    poles = [des, conj(des)];
    for i = 1:length(poles)
        plot(real(poles(i)), imag(poles(i)), 'rx', 'MarkerSize', 8, 'LineWidth', 1)
        text(real(poles(i)), imag(poles(i)), ...
        sprintf('  %.2f%+.2fj', real(poles(i)), imag(poles(i))));
        % Calculate and print the natural frequency and damping of desired pole
        wn = abs(poles(i))/2/pi;
        wd = imag(poles(i))/2/pi;
        damping = -real(poles(i))/abs(poles(i));
        fprintf('s = %.0f ± j%.0f: w_n = 2pi(%.4f), w_d = 2pi(%.4f), damping = %.4f\n', ...
            real(poles(i)), imag(poles(i)), wn, wd, damping);
    end
    hold off;
    sgrid;
end


%% Function to produce annotated time response plot
% main purpose of this function is to compute and graphically demonstrate the settling time
% note: delta is the settling error band, 0 < delta < 1.0
function [S] = proportional_derivative_step_response(Kp, Kd, delta, stoptime)
    if nargin < 4
        stoptime = 60.0;
    end
    if nargin < 3
        delta = 0.02; % If not provided, set the default settling band = 2%
    end
    % Define a very fine time vector to increase the precision of step response data over defaults
    t = (0:0.0001:stoptime)';
    T = get_proportional_derivative_tf(Kp, Kd);
    % Use stepplot function provided by Control System Toolbox for unit step response
    figure;
    set(gcf, 'Color', 'w')
    stepplot(T, t);
    title('Step Response of Proportional-Derivative Compensated System');
    grid;
    hold;
    yss = dcgain(T);
    % Shade in the settling error bound
    ylim([0, yss*1.1])
    yline(yss*(1-delta), '--', '(1-\delta)y_{ss}', ...
        'LabelHorizontalAlignment', 'right', 'LabelVerticalAlignment', 'bottom', ...
        'HandleVisibility', 'off', 'Color', '#000000');
    yline(yss*(1+delta), '--', '(1+\delta)y_{ss}', ...
        'LabelHorizontalAlignment', 'right', 'LabelVerticalAlignment', 'top', ...
        'HandleVisibility', 'off', 'Color', '#000000');
    p = patch([xlim fliplr(xlim)], [(1-delta)*yss (1-delta)*yss (1+delta)*yss (1+delta)*yss], [1.0 0.7 0.15], ...
        'FaceAlpha', 0.08, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    uistack(p, 'bottom');
    [ysim, tsim] = step(T, t);
    % Get step response time parameters, pasing in the settling threshold and the exact yss value
    S = stepinfo(ysim, tsim, yss, SettlingTimeThreshold=delta);
    % Draw annotation lines: maximum overshoots, peak times, settling error, settling times
    yline(S.Peak, 'LineStyle', '-.', 'HandleVisibility', 'off', 'Color', '#1171BE', ...
        'Label', sprintf('%.1f', S.Peak), ...
        'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'middle');
    xline(S.PeakTime, 'LineStyle', '-.', 'Color', '#1171BE', 'HandleVisibility', 'off', ...
        'Label', sprintf('  %.3f', S.PeakTime), ...
        'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'bottom');
    xline(S.SettlingTime, 'LineStyle', '-.', 'Color', '#1171BE', 'HandleVisibility', 'off', ...
        'Label', sprintf('  %.3f', S.SettlingTime), ...
        'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'bottom');
    plot(S.PeakTime, S.Peak, 'Marker', '.', 'Color', '#1171BE', 'HandleVisibility', 'off');
end


% Call functions using PD controller parameters
proportional_derivative_root_locus(PROPORTIONAL_GAIN, DERIVATIVE_GAIN, DESIRED_POLE);
S = proportional_derivative_step_response(PROPORTIONAL_GAIN, DERIVATIVE_GAIN, SETTLING_BAND)