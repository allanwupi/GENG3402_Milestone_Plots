%% GENG3402 Assignment 2 MATLAB Script - Group 28 - Allan Wu (2810308).
% In line with assignment requirements, I have only used commands from MATLAB Control Systems Toolbox:
% 1. tf (system representation with transfer function)
% 2. stepplot (plots step response)
% 3. stepinfo (calculates transient response parameters)

%% Transfer function definitions
% Higher-order transfer function T(s), M=3 zeros, N=5 poles.
NUM1 = [12614 214438 2018240 6307000];
DEN1 = [5 95 1135 6915 22380 63070];

% Simplified second-order function T_dp(s).
NUM2 = [1700];
DEN2 = [1 2 17];

%% Time-domain analysis
% Inputs are 2 transfer functions, given as arrays of numerator/denominator coefficients, descending powers.
% Outputs are:
% - Figure: time-domain unit step response plot of both transfer functions
% - Two structs containing the transient-response parameters 
function [S1, S2] = plot_step_response(n1, d1, n2, d2)
    % Define a very fine time vector to increase the precision of step response data over defaults
    t = (0:0.0001:7)';
    sys1 = tf(n1, d1);
    sys2 = tf(n2, d2);
    % Use stepplot function provided by Control System Toolbox for unit step response
    figure;
    stepplot(sys1, sys2, t);
    set(gcf, 'Color', 'w')
    grid
    legend('5th Order System', '2nd Order Approximation');
    hold;
    yss = n1(end) / d1(end);
    % Shade in the settling error bound (95% to 105% of final value)
    yline([yss*0.95 yss*1.05], '--', {'0.95y_{ss}', '1.05y_{ss}'}, ...
        'LabelHorizontalAlignment', 'right', 'LabelVerticalAlignment', 'middle', ...
        'HandleVisibility', 'off', 'Color', '#000000');
    p = patch([xlim fliplr(xlim)], [0.95*yss 0.95*yss 1.05*yss 1.05*yss], [1.0 0.7 0.15], ...
        'FaceAlpha', 0.08, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    uistack(p, 'bottom');
    [y1, t1] = step(sys1, t);
    [y2, t2] = step(sys2, t);
    % Get step response time parameters, setting 5% as the threshold value and the exact yss value
    S1 = stepinfo(y1, t1, yss, SettlingTimeThreshold=0.05);
    S2 = stepinfo(y2, t2, yss, SettlingTimeThreshold=0.05);
    % Calculate delay times and add to step info structs
    halfYss = 0.5*yss;
    delay1 = find(y1 >= halfYss, 1, 'first');
    delay2 = find(y2 >= halfYss, 1, 'first');
    S1.DelayTime = t1(delay1);
    S2.DelayTime = t2(delay2);
    % Draw annotation lines: maximum overshoots, peak times, settling error, settling times
    yline(S1.Peak, 'LineStyle', '-.', 'HandleVisibility', 'off', 'Color', '#1171BE', ...
        'Label', sprintf('%.1f', S1.Peak), ...
        'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'middle');
    xline(S1.PeakTime, 'LineStyle', '-.', 'Color', '#1171BE', 'HandleVisibility', 'off', ...
        'Label', sprintf('  %.3f', S1.PeakTime), ...
        'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'bottom');
    xline(S1.SettlingTime, 'LineStyle', '-.', 'Color', '#1171BE', 'HandleVisibility', 'off', ...
        'Label', sprintf('  %.3f', S1.SettlingTime), ...
        'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'bottom');
    yline(S2.Peak, 'LineStyle', '-.', 'HandleVisibility', 'off', 'Color', '#DD5400', ...
        'Label', sprintf('%.1f', S2.Peak), ...
        'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'middle');
    xline(S2.PeakTime, 'LineStyle', '-.', 'Color', '#DD5400', 'HandleVisibility', 'off', ...
        'Label', sprintf('  %.3f', S2.PeakTime), ...
        'LabelHorizontalAlignment', 'right', 'LabelVerticalAlignment', 'bottom');
    xline(S2.SettlingTime, 'LineStyle', '-.', 'Color', '#DD5400', 'HandleVisibility', 'off', ...
        'Label', sprintf('  %.3f', S2.SettlingTime), ...
        'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'bottom');
    plot(S1.PeakTime, S1.Peak, 'Marker', '.', 'Color', '#1171BE', 'HandleVisibility', 'off');
    plot(S2.PeakTime, S2.Peak, 'Marker', '.', 'Color', '#DD5400', 'HandleVisibility', 'off');
end

%% S-domain analysis
% Inputs are 2 transfer functions, given as arrays of numerator/denominator coefficients, descending powers.
% Outputs are:
% - Figure: pole-zero plot of the higher-order transfer function, dominant poles highlighted.
% - Print the s-domain parameters of complex poles to display
function plot_poles_zeros(n1, d1, d2)
    % Note: No need to pass in numerator of the second-order function (as there are no zeros)
    zeros = roots(n1);
    poles = roots(d1);
    dominantpoles = roots(d2);
    % Create a new figure so that the time-domain plot can be accessed separately
    figure;
    title({'Pole-Zero Plot', ''}); % Empty string in cell array adds vertical padding
    set(gcf, 'Color', 'w')
    xlabel('\sigma');
    ylabel('j\omega');
    grid;
    % Move axes to pass through the origin
    ax = gca;
    ax.XAxisLocation = 'origin';
    ax.YAxisLocation = 'origin';
    axis equal;
    % Change figure limits to square so that circles appear correctly
    max_extent = max(abs(poles))+1;
    xlim([-max_extent max_extent]);
    ylim([-max_extent max_extent]);
    hold on;
    count = 0;
    for z = poles.'
        if imag(z) > 0.1
            count = count+1;
            % Draw circles of natural frequency
            r = abs(z);
            theta = 0:0.01:2*pi;
            x_circle = r * cos(theta);
            y_circle = r * sin(theta);
            plot(x_circle, y_circle, 'LineStyle', '--', 'HandleVisibility', 'off');
            text(r*0.707+0.2, r*0.707+0.2, sprintf('\\omega_{n%d} = 2\\pi\\cdot%.3f', count, r/2/pi));
            % Print the s-domain parameters
            fprintf('s = %.0f ± j%.0f: w_n = 2pi(%.3f), w_d = 2pi(%.3f), damping = %.3f\n', ...
                real(z), imag(z), abs(z)/2/pi, imag(z)/2/pi, -real(z)/abs(z));
        end
    end
    % Plot poles and zeros with appropriate o/x markers
    plot(real(poles), imag(poles), 'bx', 'MarkerSize', 9, 'LineWidth', 1);
    plot(real(zeros), imag(zeros), 'bo', 'MarkerSize', 7, 'LineWidth', 1);
    plot(real(dominantpoles), imag(dominantpoles), 'rx', 'MarkerSize', 9, 'LineWidth', 1);
    legend('Poles', 'Zeros', 'Dominant Poles')
    % Add coordinate labels to all points
    poi = [zeros; poles];
    signs = repmat('+', size(poi));
    signs(imag(poi) < 0) = '-';
    labels = compose("%.0f%sj%.0f", real(poi), signs, abs(imag(poi)));
    text(real(poi), imag(poi)+1, labels, 'HorizontalAlignment', 'center', 'FontSize', 10);
end

fprintf('Higher order transfer function:')
T_s = tf(NUM1, DEN1)
fprintf('Simplified lower order transfer function:')
Tdp_s = tf(NUM2, DEN2)

% Plot step response and print time parameters
[S1, S2] = plot_step_response(NUM1, DEN1, NUM2, DEN2)
% Plot locations of poles and zeros and print s-domain parameters
plot_poles_zeros(NUM1, DEN1, DEN2)