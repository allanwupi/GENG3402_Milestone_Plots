%% GENG3402 Assignment 3 - Part 2
% Authors: Allan Wu (2810308) and Bhashon Saha (25253764)
% Last updated: 15 October 2026

CONTROLLER_GAIN = 1;
CONTROLLER_ZERO = -1;
CONTROLLER_POLE = -10;


% Phase-lead controller: Gc(s) = Kc*(s+z)/(s+p) where |p| > |z|
function T = get_phase_lead_tf(Kc, z, p)
    s = tf('s');
    Gc = Kc * (s-z)/(s-p); % Compensator
    Gv = 0.6 / (3*s + 2);  % Valve
    Gp = 28 / (30*s + 2);  % Heat exchanger
    H = 2 / (5*s + 4);     % Sensor
    % Overall system transfer function T(s)
    T = Gc * Gv * Gp / (1 + Gc * Gv * Gp * H);
end


%% Function to produce annotated root locus plot
function phase_lead_root_locus(Kc, z, p)
    T = get_phase_lead_tf(Kc, z, p);
    figure;
    rlocusplot(T);
    title('Root locus of phase-lead compensated system');
    hold on;
    p = pole(T);
    % Add labels for the pole locations
    for i = 1:length(p)
        text(real(p(i)), imag(p(i)), ...
        sprintf('  s_%d = %.3f%+.3fj', i, real(p(i)), imag(p(i))));
        % Calculate the s-domain parameters
        wn = abs(p(i))/2/pi;
        wd = imag(p(i))/2/pi;
        damping = -real(p(i))/abs(p(i));
        fprintf('s = %.0f ± j%.0f: w_n = 2pi(%.3f), w_d = 2pi(%.3f), damping = %.3f\n', ...
            real(p(i)), imag(p(i)), wn, wd, damping);
    end
    hold off;
    sgrid;
end


%% Function to produce annotated time response plot
% main purpose of this function is to compute and graphically demonstrate the settling time
% note: delta is the settling error band, 0 < delta < 1.0
function [S] = phase_lead_step_response(Kc, z, p, delta)
    if nargin < 4
        delta = 0.02; % If not provided, set the default settling band = 2%
    end
    % Define a very fine time vector to increase the precision of step response data over defaults
    t = (0:0.0001:7)';
    T = get_phase_lead_tf(Kc, z, p);
    % Use stepplot function provided by Control System Toolbox for unit step response
    figure;
    stepplot(T, t);
    set(gcf, 'Color', 'w')
    grid
    legend('5th Order System', '2nd Order Approximation');
    hold;
    yss = dcgain(T);
    % Shade in the settling error bound
    yline([yss*(1-delta) yss*(1+delta)], '--', {'(1-\delta)y_{ss}', '(1+\delta)y_{ss}'}, ...
        'LabelHorizontalAlignment', 'right', 'LabelVerticalAlignment', 'middle', ...
        'HandleVisibility', 'off', 'Color', '#000000');
    p = patch([xlim fliplr(xlim)], [(1-delta)*yss (1-delta)*yss (1+delta)*yss (1+delta)*yss], [1.0 0.7 0.15], ...
        'FaceAlpha', 0.08, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    uistack(p, 'bottom');
    [ysim, tsim] = step(sys1, t);
    % Get step response time parameters, setting 5% as the threshold value and the exact yss value
    S = stepinfo(ysim, t1, yss, SettlingTimeThreshold=0.05);
    % Calculate delay times and add to step info structs
    halfYss = 0.5*yss;
    delay = find(ysim >= halfYss, 1, 'first');
    S.DelayTime = tsim(delay);
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


% Call functions using calculated controller parameters
T = get_phase_lead_tf(CONTROLLER_GAIN, CONTROLLER_ZERO, CONTROLLER_POLE)
%phase_lead_root_locus(CONTROLLER_GAIN, CONTROLLER_ZERO, CONTROLLER_POLE);
%phase_lead_step_response(CONTROLLER_GAIN, CONTROLLER_ZERO, CONTROLLER_POLE);
